-- TrainUp — Seed: Split Templates (Metodologia Prof. Dr. Rafael Mendes)
-- Fonte: METODOLOGIA-PRESCRICAO.md, Seção 3

insert into public.split_templates (level, days_per_week, name, structure) values

-- ============================================================
-- INICIANTE
-- ============================================================
('iniciante', 2, 'Full Body A/B', '[
  {"day": "A", "label": "Full Body A", "patterns": ["agachar","empurrar_horizontal","puxar_vertical","core"]},
  {"day": "B", "label": "Full Body B", "patterns": ["hip_hinge","empurrar_vertical","puxar_horizontal","core"]}
]'::jsonb),

('iniciante', 3, 'Full Body A/B/A', '[
  {"day": "A", "label": "Full Body A", "patterns": ["agachar","empurrar_horizontal","puxar_vertical","core"]},
  {"day": "B", "label": "Full Body B", "patterns": ["hip_hinge","empurrar_vertical","puxar_horizontal","core"]},
  {"day": "A2", "label": "Full Body A (repetição)", "patterns": ["agachar","empurrar_horizontal","puxar_vertical","core"]}
]'::jsonb),

-- ============================================================
-- INTERMEDIÁRIO
-- ============================================================
('intermediario', 3, 'Push/Pull/Legs (3x)', '[
  {"day": "Push", "label": "Empurrar", "patterns": ["empurrar_horizontal","empurrar_vertical","isolamento_triceps"]},
  {"day": "Pull", "label": "Puxar",    "patterns": ["puxar_vertical","puxar_horizontal","isolamento_biceps"]},
  {"day": "Legs", "label": "Pernas",   "patterns": ["agachar","hip_hinge","isolamento_quadriceps","isolamento_isquiotibiais","isolamento_panturrilha"]}
]'::jsonb),

('intermediario', 4, 'Upper/Lower (4x)', '[
  {"day": "Upper A", "label": "Superior A", "patterns": ["empurrar_horizontal","puxar_vertical","isolamento_biceps","isolamento_triceps"]},
  {"day": "Lower A", "label": "Inferior A", "patterns": ["agachar","hip_hinge","isolamento_panturrilha","core"]},
  {"day": "Upper B", "label": "Superior B", "patterns": ["empurrar_vertical","puxar_horizontal","isolamento_biceps","isolamento_triceps"]},
  {"day": "Lower B", "label": "Inferior B", "patterns": ["hip_hinge","agachar","isolamento_quadriceps","isolamento_isquiotibiais"]}
]'::jsonb),

-- ============================================================
-- AVANÇADO
-- ============================================================
('avancado', 5, 'Push/Pull/Legs (5x)', '[
  {"day": "Push",   "label": "Empurrar",         "patterns": ["empurrar_horizontal","empurrar_vertical","isolamento_triceps","isolamento_ombro"]},
  {"day": "Pull",   "label": "Puxar",             "patterns": ["puxar_vertical","puxar_horizontal","isolamento_biceps","isolamento_trapezio"]},
  {"day": "Legs",   "label": "Pernas",            "patterns": ["agachar","hip_hinge","isolamento_quadriceps","isolamento_isquiotibiais","isolamento_panturrilha","core"]},
  {"day": "Upper",  "label": "Superior Fullness", "patterns": ["empurrar_horizontal","puxar_horizontal","isolamento_biceps","isolamento_triceps"]},
  {"day": "Lower",  "label": "Inferior Fullness", "patterns": ["agachar","hip_hinge","isolamento_panturrilha","core"]}
]'::jsonb),

('avancado', 6, 'PPL PPL (6x)', '[
  {"day": "Push A", "label": "Empurrar A", "patterns": ["empurrar_horizontal","isolamento_triceps","isolamento_ombro"]},
  {"day": "Pull A", "label": "Puxar A",   "patterns": ["puxar_vertical","isolamento_biceps","isolamento_trapezio"]},
  {"day": "Legs A", "label": "Pernas A",  "patterns": ["agachar","isolamento_quadriceps","isolamento_panturrilha","core"]},
  {"day": "Push B", "label": "Empurrar B","patterns": ["empurrar_vertical","empurrar_horizontal","isolamento_triceps"]},
  {"day": "Pull B", "label": "Puxar B",   "patterns": ["puxar_horizontal","puxar_vertical","isolamento_biceps"]},
  {"day": "Legs B", "label": "Pernas B",  "patterns": ["hip_hinge","isolamento_isquiotibiais","isolamento_panturrilha","core"]}
]'::jsonb);
