-- TrainUp — Migration 001: Schema completo
-- Executar no Supabase SQL Editor (painel > SQL Editor > New Query)
-- Ordem: extensions → identidade/vínculos → motor de regras → treino/histórico → índices

-- ---------------------------------------------------------------------------
-- Extensions
-- ---------------------------------------------------------------------------
create extension if not exists "pgcrypto";

-- ---------------------------------------------------------------------------
-- 1. IDENTIDADE E VÍNCULOS
-- ---------------------------------------------------------------------------

create table public.profiles (
  id          uuid primary key references auth.users on delete cascade,
  full_name   text not null,
  role        text not null check (role in ('aluno','personal','admin_academia','recepcao')),
  sex         text check (sex in ('M','F','outro')),
  birthdate   date,
  height_cm   numeric(5,1),
  created_at  timestamptz not null default now()
);

create table public.academies (
  id            uuid primary key default gen_random_uuid(),
  name          text not null,
  invite_code   text unique not null,
  owner_id      uuid references public.profiles(id) on delete set null,
  created_at    timestamptz not null default now()
);

create table public.academy_members (
  academy_id  uuid not null references public.academies(id) on delete cascade,
  student_id  uuid not null references public.profiles(id) on delete cascade,
  joined_at   timestamptz not null default now(),
  primary key (academy_id, student_id)
);

create table public.personal_trainers (
  id            uuid primary key references public.profiles(id) on delete cascade,
  invite_code   text unique not null,
  created_at    timestamptz not null default now()
);

create table public.personal_students (
  personal_id   uuid not null references public.personal_trainers(id) on delete cascade,
  student_id    uuid not null references public.profiles(id) on delete cascade,
  joined_at     timestamptz not null default now(),
  primary key (personal_id, student_id)
);

-- ---------------------------------------------------------------------------
-- 2. MOTOR DE REGRAS — Metodologia Prof. Dr. Rafael Mendes
-- ---------------------------------------------------------------------------

create table public.exercises (
  id                uuid primary key default gen_random_uuid(),
  name              text not null,
  primary_muscle    text not null,
  movement_pattern  text not null,
  exercise_type     text not null check (exercise_type in ('composto','isolamento')),
  equipment         text not null check (equipment in ('academia','halteres','peso_corporal')),
  difficulty_level  text not null check (difficulty_level in ('iniciante','intermediario','avancado')),
  restrictions      text[] not null default '{}',
  video_url         text,
  description       text,
  created_at        timestamptz not null default now()
);

create table public.split_templates (
  id            uuid primary key default gen_random_uuid(),
  level         text not null check (level in ('iniciante','intermediario','avancado')),
  days_per_week int not null check (days_per_week between 2 and 6),
  name          text not null,
  structure     jsonb not null,
  created_at    timestamptz not null default now()
);

create table public.objective_parameters (
  objective     text primary key check (objective in ('hipertrofia','perda_gordura','condicionamento')),
  sets_min      int not null,
  sets_max      int not null,
  reps_min      int not null,
  reps_max      int not null,
  rir_min       int not null,
  rir_max       int not null,
  rest_seconds  int not null
);

-- ---------------------------------------------------------------------------
-- 3. PERFIL DE TREINO E PLANOS
-- ---------------------------------------------------------------------------

create table public.user_training_profile (
  user_id        uuid primary key references public.profiles(id) on delete cascade,
  objective      text not null references public.objective_parameters(objective),
  level          text not null check (level in ('iniciante','intermediario','avancado')),
  days_per_week  int not null check (days_per_week between 2 and 6),
  equipment      text not null check (equipment in ('academia','halteres','peso_corporal')),
  restrictions   text[] not null default '{}',
  updated_at     timestamptz not null default now()
);

create table public.workout_plans (
  id                  uuid primary key default gen_random_uuid(),
  user_id             uuid not null references public.profiles(id) on delete cascade,
  source              text not null check (source in ('auto','personal')),
  created_by          uuid references public.profiles(id),
  cycle_week          int not null default 1 check (cycle_week between 1 and 4),
  split_template_id   uuid references public.split_templates(id),
  active              boolean not null default true,
  created_at          timestamptz not null default now()
);

create table public.workout_plan_exercises (
  id            uuid primary key default gen_random_uuid(),
  plan_id       uuid not null references public.workout_plans(id) on delete cascade,
  day_index     int not null,
  exercise_id   uuid not null references public.exercises(id),
  order_index   int not null,
  sets          int not null,
  reps_min      int not null,
  reps_max      int not null,
  rir           int not null,
  rest_seconds  int not null
);

-- ---------------------------------------------------------------------------
-- 4. EXECUÇÃO, HISTÓRICO E EVOLUÇÃO
-- ---------------------------------------------------------------------------

create table public.workout_sessions (
  id               uuid primary key default gen_random_uuid(),
  user_id          uuid not null references public.profiles(id) on delete cascade,
  plan_id          uuid references public.workout_plans(id) on delete set null,
  day_index        int not null,
  performed_at     timestamptz not null default now(),
  duration_seconds int
);

create table public.session_sets (
  id            uuid primary key default gen_random_uuid(),
  session_id    uuid not null references public.workout_sessions(id) on delete cascade,
  exercise_id   uuid not null references public.exercises(id),
  set_number    int not null,
  reps_done     int,
  weight_kg     numeric(6,2),
  rir_reported  int
);

create table public.body_measurements (
  id            uuid primary key default gen_random_uuid(),
  user_id       uuid not null references public.profiles(id) on delete cascade,
  measured_at   date not null default current_date,
  weight_kg     numeric(5,2),
  measurements  jsonb
);

create table public.wearable_data (
  id              uuid primary key default gen_random_uuid(),
  user_id         uuid not null references public.profiles(id) on delete cascade,
  date            date not null,
  steps           int,
  avg_heart_rate  int,
  calories        numeric(8,2),
  unique (user_id, date)
);

-- ---------------------------------------------------------------------------
-- 5. ÍNDICES DE PERFORMANCE
-- ---------------------------------------------------------------------------
create index on public.workout_plans (user_id, active);
create index on public.workout_plan_exercises (plan_id, day_index, order_index);
create index on public.workout_sessions (user_id, performed_at desc);
create index on public.session_sets (session_id);
create index on public.body_measurements (user_id, measured_at desc);
create index on public.exercises (equipment, difficulty_level, movement_pattern);
create index on public.academy_members (student_id);
create index on public.personal_students (student_id);
