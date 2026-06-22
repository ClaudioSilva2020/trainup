-- TrainUp — Seed: Biblioteca de Exercícios (curadoria inicial TechIndev)
-- Fonte: METODOLOGIA-PRESCRICAO.md, Seção 4
-- Campos: name, primary_muscle, movement_pattern, exercise_type, equipment, difficulty_level, restrictions, video_url, description

insert into public.exercises
  (name, primary_muscle, movement_pattern, exercise_type, equipment, difficulty_level, restrictions, description)
values

-- ============================================================
-- AGACHAR
-- ============================================================
('Agachamento Livre', 'quadriceps', 'agachar', 'composto', 'academia', 'intermediario',
 '{joelho,lombar}', 'Barra nas costas, descer até coxas paralelas ao chão.'),

('Agachamento Goblet', 'quadriceps', 'agachar', 'composto', 'halteres', 'iniciante',
 '{joelho}', 'Haltere segurado com as duas mãos na altura do peito.'),

('Leg Press 45°', 'quadriceps', 'agachar', 'composto', 'academia', 'iniciante',
 '{joelho,quadril}', 'Pés na plataforma na largura dos ombros. Não trancar os joelhos.'),

('Agachamento Búlgaro', 'quadriceps', 'agachar', 'composto', 'halteres', 'intermediario',
 '{joelho,tornozelo}', 'Pé traseiro apoiado em banco. Exige equilíbrio e mobilidade.'),

('Afundo com Halteres', 'quadriceps', 'agachar', 'composto', 'halteres', 'iniciante',
 '{joelho}', 'Passada à frente alternando as pernas.'),

('Agachamento com Peso Corporal', 'quadriceps', 'agachar', 'composto', 'peso_corporal', 'iniciante',
 '{}', 'Variação sem peso. Ótimo para iniciantes ou aquecimento.'),

-- ============================================================
-- HIP HINGE
-- ============================================================
('Levantamento Terra', 'isquiotibiais', 'hip_hinge', 'composto', 'academia', 'avancado',
 '{lombar}', 'Barra no chão. Quadril dobra, costas neutras. Alto risco técnico.'),

('Stiff com Halteres', 'isquiotibiais', 'hip_hinge', 'composto', 'halteres', 'intermediario',
 '{lombar}', 'Joelhos levemente flexionados. Descida com costas retas até canela.'),

('Hip Thrust na Máquina', 'gluteo', 'hip_hinge', 'composto', 'academia', 'iniciante',
 '{}', 'Extensão de quadril com carga. Foco em glúteo máximo.'),

('Elevação Pélvica com Haltere', 'gluteo', 'hip_hinge', 'composto', 'halteres', 'iniciante',
 '{}', 'Ombros apoiados no banco, haltere no quadril.'),

('Good Morning', 'isquiotibiais', 'hip_hinge', 'composto', 'academia', 'avancado',
 '{lombar}', 'Barra nas costas, inclinar o tronco à frente mantendo costas retas.'),

('Cadeira Flexora', 'isquiotibiais', 'hip_hinge', 'isolamento', 'academia', 'iniciante',
 '{joelho}', 'Isolar isquiotibiais com flexão de joelho na máquina.'),

-- ============================================================
-- EMPURRAR HORIZONTAL
-- ============================================================
('Supino Reto com Barra', 'peitoral', 'empurrar_horizontal', 'composto', 'academia', 'intermediario',
 '{ombro}', 'Clássico. Barra desce até peito. Cotovelos a 45-75°.'),

('Supino Reto com Halteres', 'peitoral', 'empurrar_horizontal', 'composto', 'halteres', 'intermediario',
 '{ombro}', 'Maior amplitude que a barra. Exige mais estabilização.'),

('Supino Inclinado com Halteres', 'peitoral', 'empurrar_horizontal', 'composto', 'halteres', 'iniciante',
 '{ombro}', 'Banco a 30-45°. Ênfase em peitoral superior.'),

('Flexão de Braço', 'peitoral', 'empurrar_horizontal', 'composto', 'peso_corporal', 'iniciante',
 '{ombro}', 'Base para desenvolvimento de empurrar. Escalar com pés elevados.'),

('Crossover na Polia', 'peitoral', 'empurrar_horizontal', 'isolamento', 'academia', 'iniciante',
 '{}', 'Adução horizontal com ênfase em peitoral. Bom para finalizar.'),

-- ============================================================
-- EMPURRAR VERTICAL
-- ============================================================
('Desenvolvimento com Halteres', 'deltoides', 'empurrar_vertical', 'composto', 'halteres', 'iniciante',
 '{ombro}', 'Sentado ou em pé. Halteres na altura dos ombros, empurrar acima da cabeça.'),

('Desenvolvimento com Barra', 'deltoides', 'empurrar_vertical', 'composto', 'academia', 'intermediario',
 '{ombro,lombar}', 'OHP clássico. Barra na frente ou atrás da cabeça.'),

('Arnold Press', 'deltoides', 'empurrar_vertical', 'composto', 'halteres', 'intermediario',
 '{ombro}', 'Rotação dos halteres no movimento. Maior recrutamento de deltoides.'),

('Elevação Lateral', 'deltoides', 'isolamento_ombro', 'isolamento', 'halteres', 'iniciante',
 '{}', 'Isola deltoides lateral. Cotovelos levemente flexionados.'),

-- ============================================================
-- PUXAR VERTICAL
-- ============================================================
('Puxada no Pulley (Barra)', 'latissimo', 'puxar_vertical', 'composto', 'academia', 'iniciante',
 '{ombro}', 'Barra na largura dos ombros. Puxar até queixo.'),

('Puxada Supinada (Barra Fechada)', 'latissimo', 'puxar_vertical', 'composto', 'academia', 'iniciante',
 '{ombro,cotovelo}', 'Pegada supinada recruta mais bíceps. Bom para iniciantes.'),

('Barra Fixa', 'latissimo', 'puxar_vertical', 'composto', 'peso_corporal', 'avancado',
 '{ombro}', 'Pull-up com peso corporal. Referência de força relativa.'),

('Pullover com Haltere', 'latissimo', 'puxar_vertical', 'isolamento', 'halteres', 'iniciante',
 '{ombro}', 'Deitado no banco, haltere atrás da cabeça. Boa amplitude.'),

-- ============================================================
-- PUXAR HORIZONTAL
-- ============================================================
('Remada Curvada com Barra', 'dorsais', 'puxar_horizontal', 'composto', 'academia', 'intermediario',
 '{lombar}', 'Tronco inclinado, barra vem até umbigo. Boa ativação de dorsais.'),

('Remada com Haltere (unilateral)', 'dorsais', 'puxar_horizontal', 'composto', 'halteres', 'iniciante',
 '{}', 'Apoio no banco. Permite maior amplitude. Bom para corrigir assimetrias.'),

('Remada na Polia Baixa (triângulo)', 'dorsais', 'puxar_horizontal', 'composto', 'academia', 'iniciante',
 '{}', 'Tronco ereto, puxar triângulo até abdômen.'),

('Face Pull', 'trapezio', 'puxar_horizontal', 'isolamento', 'academia', 'iniciante',
 '{}', 'Polia alta, puxar até rosto. Saúde de ombros e trapézio.'),

-- ============================================================
-- ISOLAMENTO — BÍCEPS
-- ============================================================
('Rosca Direta com Barra', 'biceps', 'isolamento_biceps', 'isolamento', 'academia', 'iniciante',
 '{cotovelo}', 'Clássico para bíceps. Cotovelos fixos.'),

('Rosca Alternada com Halteres', 'biceps', 'isolamento_biceps', 'isolamento', 'halteres', 'iniciante',
 '{cotovelo}', 'Permite supinação no final do movimento.'),

('Rosca Concentrada', 'biceps', 'isolamento_biceps', 'isolamento', 'halteres', 'iniciante',
 '{}', 'Cotovelo apoiado na coxa. Isola pico do bíceps.'),

-- ============================================================
-- ISOLAMENTO — TRÍCEPS
-- ============================================================
('Tríceps Testa com Barra', 'triceps', 'isolamento_triceps', 'isolamento', 'academia', 'intermediario',
 '{cotovelo,ombro}', 'Deitado, baixar barra à testa. Alta carga possível.'),

('Tríceps Polia (corda)', 'triceps', 'isolamento_triceps', 'isolamento', 'academia', 'iniciante',
 '{}', 'Extensão de cotovelo na polia. Abertura da corda no final.'),

('Mergulho em Banco', 'triceps', 'isolamento_triceps', 'composto', 'peso_corporal', 'iniciante',
 '{ombro}', 'Mãos no banco atrás. Flexão de cotovelo. Elevar pés para dificultar.'),

-- ============================================================
-- ISOLAMENTO — QUADRICEPS / ISQUIOS / PANTURRILHA
-- ============================================================
('Cadeira Extensora', 'quadriceps', 'isolamento_quadriceps', 'isolamento', 'academia', 'iniciante',
 '{joelho}', 'Extensão de joelho na máquina. Isolar quadríceps.'),

('Mesa Flexora', 'isquiotibiais', 'isolamento_isquiotibiais', 'isolamento', 'academia', 'iniciante',
 '{joelho}', 'Deitado, flexão de joelho. Isolamento de isquiotibiais.'),

('Panturrilha em Pé (Smith/Máquina)', 'panturrilha', 'isolamento_panturrilha', 'isolamento', 'academia', 'iniciante',
 '{}', 'Flexão plantar em pé. Isolar gastrocnêmio.'),

('Panturrilha Sentado', 'panturrilha', 'isolamento_panturrilha', 'isolamento', 'academia', 'iniciante',
 '{}', 'Flexão plantar sentado. Ênfase em sóleo.'),

-- ============================================================
-- CORE
-- ============================================================
('Prancha Abdominal', 'core', 'core', 'composto', 'peso_corporal', 'iniciante',
 '{lombar}', 'Isométrico. Cotovelos no chão. Progressão: aumentar tempo.'),

('Abdominal Supra (Crunch)', 'core', 'core', 'isolamento', 'peso_corporal', 'iniciante',
 '{lombar,pescoco}', 'Flexão de tronco com lombar no chão.'),

('Abdominal na Polia', 'core', 'core', 'isolamento', 'academia', 'intermediario',
 '{lombar}', 'Permite sobrecarga progressiva no core.'),

('Elevação de Pernas', 'core', 'core', 'composto', 'peso_corporal', 'intermediario',
 '{lombar}', 'Deitado ou em barra. Elevação de membros inferiores com core contraído.');
