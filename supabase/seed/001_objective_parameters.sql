-- TrainUp — Seed: Parâmetros de Objetivo (Metodologia Prof. Dr. Rafael Mendes)
-- Fonte: METODOLOGIA-PRESCRICAO.md, Seção 2

insert into public.objective_parameters
  (objective, sets_min, sets_max, reps_min, reps_max, rir_min, rir_max, rest_seconds)
values
  ('hipertrofia',      3, 5, 6,  12, 1, 3, 90),
  ('perda_gordura',    2, 4, 12, 20, 2, 4, 60),
  ('condicionamento',  2, 3, 15, 25, 2, 4, 45)
on conflict (objective) do update set
  sets_min     = excluded.sets_min,
  sets_max     = excluded.sets_max,
  reps_min     = excluded.reps_min,
  reps_max     = excluded.reps_max,
  rir_min      = excluded.rir_min,
  rir_max      = excluded.rir_max,
  rest_seconds = excluded.rest_seconds;
