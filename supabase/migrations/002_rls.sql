-- TrainUp — Migration 002: Row Level Security (LGPD / RNF-003)
-- Idempotente: pode ser executado múltiplas vezes sem erro.
-- Executar APÓS 001_schema.sql

-- ---------------------------------------------------------------------------
-- Habilitar RLS em todas as tabelas com dados pessoais/sensíveis
-- ---------------------------------------------------------------------------
alter table public.profiles               enable row level security;
alter table public.academies              enable row level security;
alter table public.academy_members        enable row level security;
alter table public.personal_trainers      enable row level security;
alter table public.personal_students      enable row level security;
alter table public.user_training_profile  enable row level security;
alter table public.workout_plans          enable row level security;
alter table public.workout_plan_exercises enable row level security;
alter table public.workout_sessions       enable row level security;
alter table public.session_sets           enable row level security;
alter table public.body_measurements      enable row level security;
alter table public.wearable_data          enable row level security;

-- Tabelas de configuração (read-only para todos os autenticados)
alter table public.exercises              enable row level security;
alter table public.split_templates        enable row level security;
alter table public.objective_parameters   enable row level security;

-- ---------------------------------------------------------------------------
-- Drop policies existentes (idempotência)
-- ---------------------------------------------------------------------------
do $$ declare
  r record;
begin
  for r in
    select policyname, tablename
    from pg_policies
    where schemaname = 'public'
  loop
    execute format('drop policy if exists %I on public.%I', r.policyname, r.tablename);
  end loop;
end $$;

-- ---------------------------------------------------------------------------
-- PROFILES
-- ---------------------------------------------------------------------------
create policy "profiles: leitura própria"
  on public.profiles for select
  using (auth.uid() = id);

create policy "profiles: atualização própria"
  on public.profiles for update
  using (auth.uid() = id);

-- ---------------------------------------------------------------------------
-- ACADEMIES
-- ---------------------------------------------------------------------------
create policy "academies: leitura pelo owner"
  on public.academies for select
  using (owner_id = auth.uid());

create policy "academies: leitura por membro"
  on public.academies for select
  using (
    exists (
      select 1 from public.academy_members
      where academy_id = academies.id and student_id = auth.uid()
    )
  );

create policy "academies: criação pelo próprio admin"
  on public.academies for insert
  with check (owner_id = auth.uid());

create policy "academies: atualização pelo owner"
  on public.academies for update
  using (owner_id = auth.uid());

-- ---------------------------------------------------------------------------
-- ACADEMY MEMBERS
-- ---------------------------------------------------------------------------
create policy "academy_members: leitura pelo aluno"
  on public.academy_members for select
  using (student_id = auth.uid());

create policy "academy_members: leitura pelo admin da academia"
  on public.academy_members for select
  using (
    exists (
      select 1 from public.academies
      where id = academy_members.academy_id and owner_id = auth.uid()
    )
  );

create policy "academy_members: aluno pode se vincular"
  on public.academy_members for insert
  with check (student_id = auth.uid());

create policy "academy_members: aluno pode se desvincular"
  on public.academy_members for delete
  using (student_id = auth.uid());

-- ---------------------------------------------------------------------------
-- PERSONAL TRAINERS
-- ---------------------------------------------------------------------------
create policy "personal_trainers: leitura própria"
  on public.personal_trainers for select
  using (id = auth.uid());

create policy "personal_trainers: inserção própria"
  on public.personal_trainers for insert
  with check (id = auth.uid());

-- ---------------------------------------------------------------------------
-- PERSONAL STUDENTS
-- ---------------------------------------------------------------------------
create policy "personal_students: leitura pelo personal"
  on public.personal_students for select
  using (personal_id = auth.uid());

create policy "personal_students: leitura pelo aluno"
  on public.personal_students for select
  using (student_id = auth.uid());

create policy "personal_students: aluno pode se vincular"
  on public.personal_students for insert
  with check (student_id = auth.uid());

-- ---------------------------------------------------------------------------
-- USER TRAINING PROFILE
-- ---------------------------------------------------------------------------
create policy "user_training_profile: próprio"
  on public.user_training_profile for all
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

create policy "user_training_profile: leitura pelo personal"
  on public.user_training_profile for select
  using (
    exists (
      select 1 from public.personal_students
      where personal_id = auth.uid() and student_id = user_training_profile.user_id
    )
  );

-- ---------------------------------------------------------------------------
-- WORKOUT PLANS
-- ---------------------------------------------------------------------------
create policy "workout_plans: leitura pelo dono do plano"
  on public.workout_plans for select
  using (user_id = auth.uid());

create policy "workout_plans: leitura pelo personal que criou"
  on public.workout_plans for select
  using (created_by = auth.uid());

create policy "workout_plans: criação para si (auto) ou pelo personal"
  on public.workout_plans for insert
  with check (
    (source = 'auto' and user_id = auth.uid()) or
    (source = 'personal' and created_by = auth.uid() and exists (
      select 1 from public.personal_students
      where personal_id = auth.uid() and student_id = workout_plans.user_id
    ))
  );

create policy "workout_plans: atualização pelo personal"
  on public.workout_plans for update
  using (created_by = auth.uid());

-- ---------------------------------------------------------------------------
-- WORKOUT PLAN EXERCISES
-- ---------------------------------------------------------------------------
create policy "workout_plan_exercises: leitura"
  on public.workout_plan_exercises for select
  using (
    exists (
      select 1 from public.workout_plans wp
      where wp.id = workout_plan_exercises.plan_id
        and (wp.user_id = auth.uid() or wp.created_by = auth.uid())
    )
  );

create policy "workout_plan_exercises: escrita pelo personal"
  on public.workout_plan_exercises for insert
  with check (
    exists (
      select 1 from public.workout_plans wp
      where wp.id = workout_plan_exercises.plan_id
        and (wp.user_id = auth.uid() or wp.created_by = auth.uid())
    )
  );

-- ---------------------------------------------------------------------------
-- WORKOUT SESSIONS
-- ---------------------------------------------------------------------------
create policy "workout_sessions: próprias"
  on public.workout_sessions for all
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

create policy "workout_sessions: leitura pelo personal"
  on public.workout_sessions for select
  using (
    exists (
      select 1 from public.personal_students
      where personal_id = auth.uid() and student_id = workout_sessions.user_id
    )
  );

-- ---------------------------------------------------------------------------
-- SESSION SETS
-- ---------------------------------------------------------------------------
create policy "session_sets: próprias"
  on public.session_sets for all
  using (
    exists (
      select 1 from public.workout_sessions ws
      where ws.id = session_sets.session_id and ws.user_id = auth.uid()
    )
  );

create policy "session_sets: leitura pelo personal"
  on public.session_sets for select
  using (
    exists (
      select 1 from public.workout_sessions ws
      join public.personal_students ps on ps.student_id = ws.user_id
      where ws.id = session_sets.session_id and ps.personal_id = auth.uid()
    )
  );

-- ---------------------------------------------------------------------------
-- BODY MEASUREMENTS
-- ---------------------------------------------------------------------------
create policy "body_measurements: próprias"
  on public.body_measurements for all
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

create policy "body_measurements: leitura pelo personal"
  on public.body_measurements for select
  using (
    exists (
      select 1 from public.personal_students
      where personal_id = auth.uid() and student_id = body_measurements.user_id
    )
  );

-- ---------------------------------------------------------------------------
-- WEARABLE DATA
-- ---------------------------------------------------------------------------
create policy "wearable_data: próprios"
  on public.wearable_data for all
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

-- ---------------------------------------------------------------------------
-- TABELAS DE CONFIGURAÇÃO (read-only para usuários autenticados)
-- ---------------------------------------------------------------------------
create policy "exercises: leitura pública autenticada"
  on public.exercises for select
  to authenticated
  using (true);

create policy "split_templates: leitura pública autenticada"
  on public.split_templates for select
  to authenticated
  using (true);

create policy "objective_parameters: leitura pública autenticada"
  on public.objective_parameters for select
  to authenticated
  using (true);

-- ---------------------------------------------------------------------------
-- TRIGGER: criar profile automaticamente ao registrar usuário
-- ---------------------------------------------------------------------------
create or replace function public.handle_new_user()
returns trigger
language plpgsql security definer
as $$
begin
  insert into public.profiles (id, full_name, role)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'full_name', 'Usuário'),
    coalesce(new.raw_user_meta_data->>'role', 'aluno')
  );
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();
