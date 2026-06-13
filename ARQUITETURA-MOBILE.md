# Mobile Architecture Decision — TrainUp

**Responsável:** Mobile Architect (Flutter)
**Stack:** Flutter 3.x / Dart 3.x + Supabase
**Min Target:** Android API 24 (7.0) / iOS 13

---

## Arquitetura

**Clean Architecture + Riverpod 2.x** (com `riverpod_generator`).

> Por que Riverpod em vez de BLoC (padrão da empresa para times grandes):
> prazo de 1 mês, equipe pequena, e Riverpod reduz boilerplate sem perder
> testabilidade — `flutter_bloc` fica como padrão se o time crescer numa
> fase 2.

### Estrutura de Pacotes

```
lib/
├── core/
│   ├── config/            # env, flavors (dev/staging/prod)
│   ├── network/            # SupabaseClient wrapper, exceptions
│   ├── storage/            # drift (cache offline), secure storage
│   ├── router/             # GoRouter + redirects por role
│   └── theme/               # paleta (verde, azul escuro, preto/branco)
├── features/
│   ├── auth/                 # login, cadastro, escolha de perfil
│   ├── onboarding/           # anamnese (objetivo, nível, dias, equipamento, restrições)
│   ├── workout_engine/       # motor de regras: monta plano a partir da anamnese
│   ├── workout_session/      # execução do treino (cronômetro, séries, cargas)
│   ├── progress/              # gráficos de evolução (carga, peso, medidas)
│   ├── exercise_library/     # biblioteca de exercícios (busca, vídeo)
│   ├── academy/               # admin academia: lista de alunos, código de convite
│   ├── personal/              # personal: alunos vinculados, montar/editar treino
│   └── wearables/             # integração health (Google Fit / Apple Health)
│       each com: data/ (datasources + repositories) · domain/ (entities, usecases) · presentation/ (providers, pages, widgets)
├── shared/                    # widgets, formatters, validators
└── main.dart
```

Cada `feature/*` segue: `data/` (Supabase datasource + repository impl),
`domain/` (entities + use cases + repo interface), `presentation/`
(Riverpod providers/notifiers + pages + widgets).

---

## Decisões de Design

| Decisão | Escolha | Justificativa |
|---------|---------|----------------|
| Backend | Supabase (Postgres + Auth + Storage Realtime) | Free tier cobre RNF-002 (≤R$100/mês p/ 10 usuários) |
| Estado | Riverpod 2.x + riverpod_generator | Menos boilerplate, bom para equipe pequena/prazo curto |
| Navegação | GoRouter com redirect por `role` do perfil | 4 perfis (aluno, personal, admin academia, recepção) com home distintas |
| Acesso a dados | `supabase_flutter` direto nos datasources (sem Dio/Retrofit) | Supabase SDK já cobre REST + Realtime + Auth + Storage |
| Cache/offline | `drift` para sessão de treino em andamento | Garante registro de séries mesmo sem internet na academia; sync ao final |
| Vídeos de exercício | URLs externas (YouTube não-listado ou storage gratuito), **não** Supabase Storage | Evita consumir os 1GB do free tier de Storage |
| Wearables | `health` package (Google Fit + Apple Health) | Cobre RF-009 sem custo adicional |
| Segurança de dados sensíveis | RLS no Supabase (cada usuário só lê/escreve seus próprios dados de saúde) + `flutter_secure_storage` para tokens | Atende RNF-003 (LGPD) |
| Motor de regras (RF-002) | 100% data-driven nas tabelas Supabase (ver schema abaixo) | Permite ajustar metodologia do Prof. Rafael sem novo deploy do app |

---

## Modelo de Dados (Supabase / Postgres)

> Todas as tabelas com `user_id` têm **RLS** habilitada: usuário só
> acessa suas próprias linhas. Tabelas de configuração (exercícios, splits,
> parâmetros de objetivo) são `read-only` para o app e editáveis apenas via
> painel Supabase (sem necessidade de admin UI no MVP).

### Identidade e Vínculos

```sql
-- Estende auth.users do Supabase
profiles (
  id              uuid primary key references auth.users,
  full_name       text not null,
  role            text not null check (role in ('aluno','personal','admin_academia','recepcao')),
  sex             text,
  birthdate       date,
  height_cm       numeric,
  created_at      timestamptz default now()
)

academies (
  id            uuid primary key default gen_random_uuid(),
  name          text not null,
  invite_code   text unique not null,
  owner_id      uuid references profiles(id)
)

academy_members (
  academy_id    uuid references academies(id),
  student_id    uuid references profiles(id),
  joined_at     timestamptz default now(),
  primary key (academy_id, student_id)
)

personal_trainers (
  id            uuid primary key references profiles(id),
  invite_code   text unique not null
)

personal_students (
  personal_id   uuid references personal_trainers(id),
  student_id    uuid references profiles(id),
  joined_at     timestamptz default now(),
  primary key (personal_id, student_id)
)
```

> RF-004b/c: vínculo via `invite_code` — app valida o código contra
> `academies` ou `personal_trainers` e cria a linha em
> `academy_members`/`personal_students`.

### Motor de Regras (RF-002) — Metodologia do Prof. Rafael

```sql
-- Biblioteca de exercícios (seção 4 da metodologia)
exercises (
  id                  uuid primary key default gen_random_uuid(),
  name                text not null,
  primary_muscle      text not null,
  movement_pattern    text not null,   -- empurrar_horizontal, puxar_vertical, agachar, etc.
  exercise_type       text not null check (exercise_type in ('composto','isolamento')),
  equipment           text not null check (equipment in ('academia','halteres','peso_corporal')),
  difficulty_level    text not null check (difficulty_level in ('iniciante','intermediario','avancado')),
  restrictions        text[] default '{}',  -- ex: {'joelho','ombro'}
  video_url           text,
  description         text
)

-- Splits por nível x dias/semana (seção 3)
split_templates (
  id              uuid primary key default gen_random_uuid(),
  level           text not null,
  days_per_week   int not null,
  name            text not null,        -- "Push/Pull/Legs", "Full Body A/B"
  structure       jsonb not null        -- [{"day":"Push","patterns":["empurrar_horizontal","empurrar_vertical","isolamento_triceps"]}, ...]
)

-- Parâmetros de volume/intensidade por objetivo (seção 2)
objective_parameters (
  objective       text primary key,     -- hipertrofia, perda_gordura, condicionamento
  sets_min        int not null,
  sets_max        int not null,
  reps_min        int not null,
  reps_max        int not null,
  rir_min         int not null,
  rir_max         int not null,
  rest_seconds    int not null
)
```

### Perfil de Treino e Planos Gerados

```sql
user_training_profile (
  user_id         uuid primary key references profiles(id),
  objective       text references objective_parameters(objective),
  level           text not null,
  days_per_week   int not null,
  equipment       text not null,
  restrictions    text[] default '{}',
  updated_at      timestamptz default now()
)

workout_plans (
  id              uuid primary key default gen_random_uuid(),
  user_id         uuid references profiles(id),
  source          text not null check (source in ('auto','personal')), -- RF-002 vs RF-003
  created_by      uuid references profiles(id), -- personal_id se source='personal'
  cycle_week      int not null default 1,        -- 1-4 (seção 7: deload na semana 4)
  split_template_id uuid references split_templates(id),
  created_at      timestamptz default now(),
  active          boolean default true
)

workout_plan_exercises (
  id              uuid primary key default gen_random_uuid(),
  plan_id         uuid references workout_plans(id),
  day_index       int not null,          -- referencia structure do split_template
  exercise_id     uuid references exercises(id),
  order_index     int not null,
  sets            int not null,
  reps_min        int not null,
  reps_max        int not null,
  rir             int not null,
  rest_seconds    int not null
)
```

### Execução, Histórico e Evolução

```sql
workout_sessions (
  id              uuid primary key default gen_random_uuid(),
  user_id         uuid references profiles(id),
  plan_id         uuid references workout_plans(id),
  day_index       int not null,
  performed_at    timestamptz default now(),
  duration_seconds int
)

session_sets (
  id              uuid primary key default gen_random_uuid(),
  session_id      uuid references workout_sessions(id),
  exercise_id     uuid references exercises(id),
  set_number      int not null,
  reps_done       int,
  weight_kg       numeric,
  rir_reported    int
)

body_measurements (
  id              uuid primary key default gen_random_uuid(),
  user_id         uuid references profiles(id),
  measured_at     date default current_date,
  weight_kg       numeric,
  measurements    jsonb  -- {"peito":..,"cintura":..,"braco":..}
)

wearable_data (
  id              uuid primary key default gen_random_uuid(),
  user_id         uuid references profiles(id),
  date            date not null,
  steps           int,
  avg_heart_rate  int,
  calories        numeric,
  unique (user_id, date)
)
```

---

## Algoritmo RF-002 — Implementação

1. App lê `user_training_profile` do usuário.
2. Busca `split_templates` por `level` + `days_per_week`.
3. Para cada dia do `structure` (JSON), filtra `exercises` por
   `movement_pattern`, `equipment`, `difficulty_level <= level` e exclui
   exercícios cujo `restrictions` colida com as restrições do usuário.
4. Aplica `objective_parameters` (sets/reps/rir/rest) ao montar
   `workout_plan_exercises`.
5. `cycle_week` controla deload: na semana 4, reduzir `sets` em ~40% na
   geração (client-side, sem nova tabela — regra fixa no código do
   `workout_engine`).

Isso mantém **toda a metodologia editável via Supabase** (novos splits,
exercícios, parâmetros) sem alterar o app.

---

## Estratégia Offline

- `drift` armazena a sessão de treino em andamento (`workout_sessions` +
  `session_sets` localmente) — funciona mesmo sem sinal na academia.
- Ao final da sessão (ou quando detectar conectividade via
  `connectivity_plus`), sincroniza com Supabase.
- `workout_plans` e `exercises` são cacheados localmente após o primeiro
  carregamento (consulta pouco frequente).

---

## Roteiro de Telas (alto nível, por perfil)

| Perfil | Telas principais |
|--------|-------------------|
| Aluno | Onboarding (anamnese) → Home (plano da semana) → Execução de treino → Histórico/Evolução → Perfil (código de convite p/ academia/personal) |
| Personal | Home (lista de alunos vinculados) → Detalhe do aluno → Editor de treino (substitui plano `source='auto'` por `source='personal'`) → Código de convite |
| Admin Academia | Home (lista de alunos via `academy_members`) → Código de convite da academia |
| Recepção | Consulta de alunos (somente leitura) |

---

## CI/CD Mobile (alinhado ao stack da empresa)

```yaml
stages:
  - lint:       dart analyze, flutter analyze
  - test:       flutter test (unit + widget)
  - build:      flutter build apk --flavor staging (debug), assinado para prod
  - distribute: Firebase App Distribution (10 usuários piloto)
```

---

## Próximos Passos

1. **Flutter Senior Developer:** implementar estrutura de pacotes acima e
   módulos `auth` + `onboarding` primeiro (bloqueiam todo o resto).
2. **TechIndev (curadoria):** popular `exercises` e `split_templates` via
   SQL/seed script — formato já compatível com o schema acima.
3. **DevOps:** provisionar projeto Supabase (free tier), configurar RLS
   policies por tabela, e variáveis de ambiente por flavor (dev/staging/prod).
