# TrainUp — Supabase: Provisioning Guide

## 1. Criar o projeto

1. Acessar [supabase.com](https://supabase.com) → **New Project**
2. Nome: `trainup-dev` | Região: `South America (São Paulo)` | Free tier
3. Anotar:
   - **Project URL** → ex: `https://xyzxyz.supabase.co`
   - **anon public key** (Settings → API → Project API keys)
   - **service_role key** (manter em segredo — só para migrations/admin)

## 2. Rodar as migrations (SQL Editor)

Painel Supabase → **SQL Editor** → **New Query**. Executar na ordem:

```
supabase/migrations/001_schema.sql   ← schema completo + índices
supabase/migrations/002_rls.sql      ← RLS policies + trigger de perfil
```

## 3. Popular dados de configuração (Seed)

Ainda no SQL Editor, executar na ordem:

```
supabase/seed/001_objective_parameters.sql  ← parâmetros de volume/intensidade
supabase/seed/002_split_templates.sql       ← divisões de treino por nível/dias
supabase/seed/003_exercises.sql             ← biblioteca inicial de exercícios
```

## 4. Configurar o Flutter

Criar `lib/core/config/supabase_config.dart` (não versionar — adicionar ao `.gitignore`):

```dart
class SupabaseConfig {
  static const url = 'https://SEU_PROJECT_REF.supabase.co';
  static const anonKey = 'SUA_ANON_KEY';
}
```

E no `main.dart`, antes do `runApp`:

```dart
await Supabase.initialize(
  url: SupabaseConfig.url,
  anonKey: SupabaseConfig.anonKey,
);
```

## 5. Autenticação (Supabase Auth)

- **Email + senha** habilitado por padrão
- Desabilitar confirmação de e-mail para MVP (Authentication → Providers → Email → desmarcar "Confirm email")
- O trigger `on_auth_user_created` cria o `profiles` automaticamente com `role = 'aluno'`

## 6. Verificar RLS

No SQL Editor, testar como usuário autenticado:

```sql
-- Deve retornar apenas o registro do usuário logado
select * from profiles;
select * from user_training_profile;

-- Deve retornar todos (read-only público autenticado)
select count(*) from exercises;
select count(*) from split_templates;
select count(*) from objective_parameters;
```

## Estrutura de arquivos

```
supabase/
├── migrations/
│   ├── 001_schema.sql   ← schema completo (tabelas + índices)
│   └── 002_rls.sql      ← RLS policies + trigger de novo usuário
└── seed/
    ├── 001_objective_parameters.sql
    ├── 002_split_templates.sql
    └── 003_exercises.sql
```
