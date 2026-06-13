# Metodologia de Prescrição Automática de Treino (RF-002)

**Responsável técnico:** Prof. Dr. Rafael Mendes (Coach de Alto Rendimento)
**Para:** TrainUp — motor de regras de geração automática de treino
**Versão:** 1.0

---

## Análise

Para um motor de regras (sem ML) gerar treinos seguros e eficazes para usuários
sem personal, preciso definir três coisas: (1) **o que perguntar** ao usuário
na anamnese, (2) **como classificar** essas respostas em parâmetros de
treinamento, e (3) **como montar** o treino a partir desses parâmetros de
forma que o time de dev consiga modelar em tabelas no Supabase — sem precisar
de inteligência artificial para o MVP.

Importante: este é um sistema de **prescrição genérica baseada em triagem**,
não uma avaliação individualizada completa. Isso precisa estar explícito no
app (termo de uso) — não substitui avaliação física presencial, principalmente
para usuários com histórico de lesão.

---

## Recomendação

### 1. Anamnese de Onboarding (inputs do app)

| Campo | Opções | Uso |
|-------|--------|-----|
| Objetivo principal | Hipertrofia / Perda de gordura (recomposição) / Condicionamento geral & saúde | Define volume, intensidade, descanso |
| Nível de treinamento | Iniciante (<6 meses) / Intermediário (6m–2 anos) / Avançado (2+ anos) | Define complexidade do split, progressão |
| Dias disponíveis/semana | 2, 3, 4, 5 ou 6 | Define o split (divisão de treino) |
| Ambiente/equipamento | Academia completa / Casa com halteres / Sem equipamento (peso corporal) | Filtra variações de exercício na biblioteca |
| Restrições/lesões | Lista: joelho, ombro, lombar, punho, nenhuma | Exclui exercícios da biblioteca marcados com essa restrição |
| Sexo, idade, peso, altura | Numéricos | Cálculo de carga inicial estimada e referência para evolução |

**Critério de segurança:** se o usuário marcar lesão ativa/recente ou idade <16
ou >65 com restrição, o app deve exibir aviso recomendando avaliação
profissional antes de iniciar — não bloqueia, mas alerta.

---

### 2. Classificação → Parâmetros de Treino

Cada combinação **Objetivo** define uma faixa de **volume/intensidade**:

| Objetivo | Séries por exercício | Repetições | RIR* | Descanso |
|----------|----------------------|------------|------|----------|
| Hipertrofia | 3–4 | 8–12 | 1–3 | 60–90s |
| Perda de gordura / recomposição | 3 | 12–15 | 1–2 | 30–60s (preferir circuitos) |
| Condicionamento geral & saúde | 2–3 | 10–15 | 2–3 | 45–60s |

*RIR = Repetições em Reserva (controle de intensidade sem precisar de % de 1RM)

---

### 3. Split (divisão semanal) por Nível + Dias Disponíveis

| Dias/semana | Iniciante | Intermediário | Avançado |
|-------------|-----------|----------------|----------|
| 2 | Full Body A/B | Full Body A/B | Full Body A/B (maior volume) |
| 3 | Full Body A/B/C | Push/Pull/Legs | Push/Pull/Legs |
| 4 | Full Body A/B/A/B | Upper/Lower x2 | Upper/Lower x2 (com ênfase) |
| 5 | Upper/Lower + Full Body | Push/Pull/Legs + Upper/Lower | PPL + Upper/Lower |
| 6 | Não recomendado p/ iniciante (cair para 4-5) | Push/Pull/Legs x2 | Push/Pull/Legs x2 |

**Regra de iniciante:** priorizar **exercícios compostos/multiarticulares**
(padrões de movimento: empurrar, puxar, agachar, dobradiça de quadril) e
limitar exercícios de isolamento a no máximo 2 por sessão. Foco em técnica
antes de carga.

---

### 4. Estrutura da Biblioteca de Exercícios (para a base de dados)

Cada exercício precisa dos seguintes atributos (para o motor de regras
filtrar e montar o treino):

```
- nome
- grupo_muscular_primario (peito, dorsal, ombro, quadríceps, posterior, glúteo, core, etc.)
- padrao_movimento (empurrar horizontal, empurrar vertical, puxar horizontal,
  puxar vertical, agachar, dobradiça de quadril, isolamento, core)
- tipo (composto / isolamento)
- equipamento (academia / halteres / peso corporal) — pode ter múltiplas variações do mesmo exercício
- nivel_dificuldade (iniciante / intermediário / avançado)
- restricoes (lista de articulações sensíveis — ex: "joelho", "ombro")
- video/descricao
```

### 5. Algoritmo de Montagem do Treino (pseudocódigo)

```
1. Definir split conforme nível + dias disponíveis (tabela seção 3)
2. Para cada dia do split:
   a. Listar padrões de movimento exigidos pelo dia
      (ex: dia "Push" = empurrar horizontal + empurrar vertical + isolamento tríceps/ombro)
   b. Para cada padrão, filtrar exercícios da biblioteca por:
      - equipamento disponível do usuário
      - nivel_dificuldade <= nível do usuário
      - restricoes não conflitam com lesões informadas
   c. Selecionar 1 exercício por padrão (aleatório dentre os filtrados,
      ou primeiro da lista priorizada — para variar entre semanas)
   d. Aplicar séries/reps/descanso conforme objetivo (tabela seção 2)
3. Estimar carga inicial:
   - Se usuário informar 1RM ou carga conhecida → usar % conforme RIR
   - Se não informar → iniciar com carga conservadora (ex: barra vazia /
     halteres leves) e ajustar nas 2 primeiras sessões via feedback do RIR
```

---

### 6. Progressão (entre sessões/semanas)

| Nível | Regra de progressão |
|-------|---------------------|
| Iniciante | Progressão linear: se completou todas as séries/reps com RIR ≥ 2 em 2 sessões consecutivas → aumentar carga em ~2,5–5% (ou incremento mínimo do equipamento) |
| Intermediário/Avançado | Progressão dupla: primeiro aumentar repetições até o topo da faixa, depois aumentar carga e voltar ao piso da faixa de reps |

### 7. Periodização Simplificada (Macro do MVP)

- **Ciclo de 4 semanas:**
  - Semanas 1–3: progressão conforme regras da seção 6
  - Semana 4: **deload** — reduzir volume em ~40% (menos séries, mesma carga ou levemente menor)
- Ao fim do ciclo, app pergunta novamente objetivo/disponibilidade e pode
  ajustar o split (reavaliação leve).

---

## Fundamentação Científica

- O uso de **RIR** em vez de %1RM evita a necessidade de testes de força
  máxima (mais seguro para iniciantes sem supervisão) e é validado na
  literatura de treinamento de força como proxy confiável de intensidade.
- A priorização de **exercícios compostos** para iniciantes maximiza
  eficiência de tempo e adaptação neuromuscular, reduzindo risco de erro
  técnico em isolamentos complexos sem supervisão.
- **Deload programado** (a cada 4 semanas) é uma estratégia conservadora de
  gestão de fadiga, especialmente relevante para usuários autodirigidos sem
  monitoramento de carga interna (PSE/HRV).
- A divisão por **padrões de movimento** (em vez de só grupo muscular) garante
  cobertura equilibrada do corpo mesmo com biblioteca de exercícios reduzida
  no MVP.

---

## Pontos de Atenção

- Este motor **não substitui avaliação física** — o app deve deixar isso
  explícito (termo de uso + aviso para usuários com lesões/condições
  especiais).
- A biblioteca inicial (15–20 exercícios) precisa ter **cobertura mínima de
  todos os padrões de movimento** em pelo menos uma variação por equipamento
  (academia / halteres / peso corporal) — senão o motor não conseguirá montar
  alguns splits.
- Repetição de exercícios entre semanas pode gerar monotonia — para o MVP é
  aceitável, mas vale registrar como melhoria futura (rotação maior de
  variações).
- Usuários que não informarem carga inicial vão precisar de uma fase de
  "calibração" nas primeiras 1-2 sessões — isso deve estar no fluxo de UX.

---

## Próximos Passos

1. **Mobile/Backend Architect:** modelar as tabelas Supabase conforme seção 4
   (biblioteca de exercícios) e a lógica da seção 5 (montagem do treino) como
   dados configuráveis — não hardcoded — para permitir ajustes futuros sem
   deploy de app.
2. **TechIndev (curadoria de conteúdo):** ao buscar exercícios de fontes
   abertas, classificar cada um conforme os atributos da seção 4 — usar esta
   tabela como checklist de cobertura mínima.
3. Após o MVP, com dados reais de uso, revisar splits e regras de progressão
   com base em feedback (PSE) dos usuários.
