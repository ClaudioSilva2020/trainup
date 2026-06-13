# Documento de Requisitos — TrainUp

**Cliente:** (a definir) | **Data:** 2026-06-13 | **Versão:** 1.0
**Responsável:** DevOps Manager | **Status:** Rascunho

---

## 1. Visão Geral

App de treino para academias e alunos avulsos. Resolve três problemas:

- Alunos sem acesso a personal trainer não sabem o que treinar.
- Academias perdem controle de frequência/engajamento dos alunos.
- Falta de retenção: alunos abandonam o treino por falta de acompanhamento.

O TrainUp oferece treinos estruturados e personalizados (gerados pelo próprio
app via regras/algoritmo, sem depender de personal humano), permite que
personal trainers montem treinos customizados para seus alunos, e dá às
academias uma forma de cadastrar e acompanhar alunos (filiados ou avulsos).

Diferencial: alternativa **acessível** a apps pagos caros (ex: GymApp e
similares).

---

## 2. Stakeholders

| Papel | Nome/Área | Responsabilidade |
|-------|----------|-------------------|
| Cliente / Patrocinador | (a definir) | Define escopo, aprova entregas |
| Aluno (com personal) | Usuário final | Executa treinos definidos pelo personal |
| Aluno (sem personal/avulso) | Usuário final | Recebe treino gerado automaticamente pelo app |
| Personal Trainer (vinculado ou autônomo) | Usuário final | Monta e acompanha treinos de seus alunos |
| Administrador da academia | Usuário final | Gerencia alunos vinculados à academia |
| Recepção | Usuário final | Operações do dia a dia (consulta de alunos) |
| Especialista em Educação Física | Consultor externo | Define a metodologia de prescrição de treino automático que alimentará o motor de regras |

---

## 3. Requisitos Funcionais

| ID | Descrição | Prioridade | Critério de Aceite |
|----|-----------|-----------|---------------------|
| RF-001 | Cadastro/login de Aluno, Personal e Academia (perfis distintos) | 🔴 Must | Usuário escolhe perfil no cadastro e acessa fluxo correspondente |
| RF-002 | Geração automática de treino personalizado para aluno sem personal/academia | 🔴 Must | App sugere treino com exercícios, séries, repetições e carga inicial com base em dados do aluno (objetivo, nível, dias disponíveis) |
| RF-003 | Personal monta/edita treinos personalizados para seus alunos | 🔴 Must | Personal cria treino vinculado a um aluno específico, aluno visualiza no app |
| RF-004 | Academia cadastra e visualiza lista de alunos (filiados e avulsos) | 🔴 Must | Admin da academia vê lista de alunos vinculados |
| RF-004b | Vínculo aluno ↔ academia via código de convite | 🔴 Must | Academia gera/exibe um código; aluno insere o código no app e passa a aparecer na lista de alunos da academia |
| RF-004c | Personal autônomo (sem academia) também pode ter alunos vinculados via código de convite próprio | 🔴 Must | Personal gera código de convite; aluno vincula-se ao personal independentemente de academia |
| RF-005 | Execução de treino: cronômetro, registro de séries/repetições/carga | 🔴 Must | Aluno registra cada série durante o treino e salva ao final |
| RF-006 | Histórico de treinos realizados | 🔴 Must | Aluno consulta treinos passados com dados registrados |
| RF-007 | Biblioteca de exercícios com descrição/vídeo demonstrativo | 🔴 Must | Cada exercício do treino tem vídeo/imagem + instrução |
| RF-008 | Acompanhamento de evolução (gráficos de carga, peso, medidas) | 🔴 Must | Aluno visualiza gráfico de evolução por exercício e por medida corporal |
| RF-009 | Integração com wearables (Google Fit / Apple Health) | 🟡 Should | App sincroniza dados básicos (passos, frequência cardíaca, calorias) |
| RF-010 | Controle de frequência/check-in do aluno | 🟡 Should | Sistema registra quando o aluno realiza um treino (proxy de frequência) |

---

## 4. Requisitos Não-Funcionais

| ID | Categoria | Requisito | Métrica |
|----|-----------|-----------|---------|
| RNF-001 | Plataforma | Mobile nativo via Flutter | iOS + Android a partir de um único código |
| RNF-002 | Custo de Infraestrutura | Operar dentro de free tier / custo mínimo | ≤ R$ 100/mês para ~10 usuários |
| RNF-003 | Privacidade (LGPD) | Dados de saúde (peso, medidas, frequência cardíaca) tratados como dados sensíveis | Consentimento explícito + política de privacidade + dados criptografados em trânsito e repouso |
| RNF-004 | Escalabilidade | Arquitetura deve permitir crescimento além de 10 usuários sem retrabalho estrutural | Troca de tier do provedor sem reescrever app |
| RNF-005 | Usabilidade | Fluxo de geração de treino automático deve ser simples para usuário leigo | Aluno consegue obter primeiro treino em < 3 telas |

---

## 5. Restrições

- **Plataforma:** Mobile apenas (Flutter — Android e iOS), sem painel web nesta fase.
- **Prazo:** 1 mês para protótipo/MVP.
- **Orçamento:** até R$ 100/mês de infraestrutura — **restrição crítica**, define stack (ver Riscos).
- **Conteúdo:** biblioteca de exercícios (textos, descrições, vídeos) inexistente — TechIndev fará curadoria de conteúdo aberto/gratuito (CC0, licenças livres) para o protótipo.
- **Backend:** Supabase (Postgres + Auth + Storage), plano free tier.
- **Metodologia de treino:** ainda não definida — será idealizada com apoio de um especialista em Educação Física (consultor externo ao time técnico).
- **Regulatório:** LGPD aplicável (dados de saúde dos usuários).
- **Identidade visual:** ainda não definida. Paleta de referência do cliente: verde, azul escuro, cores da bandeira do Brasil, preto e branco.

---

## 6. Áreas Envolvidas

- [ ] Firmware (C/C++ bare metal / RTOS) — não aplicável
- [ ] Embedded Linux / Yocto — não aplicável
- [x] Backend — leve (BaaS, ver Riscos/Recomendação técnica)
- [ ] Frontend (React / Angular) — não aplicável (só mobile)
- [x] Mobile (Flutter)
- [x] DevOps / Infra — provisionamento mínimo, free tier

---

## 7. Riscos

| Risco | Probabilidade | Impacto | Mitigação |
|-------|--------------|---------|-----------|
| Orçamento de R$ 100/mês inviabiliza backend dedicado | 🔴 Alta | Alto | Supabase free tier para auth, banco (Postgres) e storage; revisar arquitetura quando a base de usuários crescer |
| Dados de saúde + free tier podem gerar conflito com LGPD | 🟡 Média | Alto | Validar política de privacidade do Supabase (região de hospedagem dos dados); criptografia de dados sensíveis; termo de consentimento no app |
| Curadoria de conteúdo aberto pode trazer exercícios com qualidade/consistência variável | 🟡 Média | Médio | TechIndev seleciona conjunto inicial reduzido (15-20 exercícios) de fontes abertas confiáveis (ex: wger, ExerciseDB), revisado pelo especialista em Educação Física |
| Metodologia de prescrição depende de consultor externo (Educação Física) ainda não engajado | 🔴 Alta | Alto | Engajar o especialista o quanto antes — definição da metodologia é pré-requisito para o motor de regras (RF-002) |
| Algoritmo de geração automática de treino pode ter complexidade subestimada | 🟡 Média | Médio | Para o MVP, usar motor baseado em regras (templates por objetivo/nível) definidos pelo especialista, não ML |
| Modelo de monetização não definido (sem pagamentos no app) | 🟡 Média | Médio | Não bloqueia o protótipo, mas deve ser discutido antes de evoluir para produção |
| Prazo de 1 mês é apertado dado o escopo (3 perfis + geração automática + evolução + wearables) | 🔴 Alta | Alto | Priorizar RF-001 a RF-008 (+RF-004b/c) para o protótipo; RF-009 e RF-010 podem ficar para a fase 2 |

---

## 8. Cronograma de Alto Nível (Protótipo — 4 semanas)

| Fase | Duração Estimada | Entregável |
|------|-------------------|-----------|
| Requisitos | Concluído | Este documento |
| Arquitetura | 3-4 dias | Definição de stack (Flutter + BaaS), modelo de dados, motor de regras de treino |
| Conteúdo inicial | Em paralelo | Conjunto reduzido de exercícios (texto + vídeo/gif) para protótipo |
| Desenvolvimento | 2-2,5 semanas | App funcional: cadastro, geração de treino, execução, histórico, evolução |
| QA | 2-3 dias | Testes manuais nos 3 perfis (Aluno, Personal, Academia) |
| Entrega do protótipo | - | APK/IPA para teste com os 10 usuários iniciais |

---

## 9. Perguntas Respondidas pelo Cliente

1. **Conteúdo (vídeos de exercícios):** TechIndev fará a curadoria de conteúdo aberto/gratuito para o protótipo.
2. **Algoritmo de treino automático:** metodologia ainda será idealizada — será incluído um especialista em Educação Física para defini-la.
3. **Vínculo Academia ↔ Aluno:** via código de convite da academia (ver RF-004b).
4. **Conta de Personal sem academia:** sim, perfil válido — assim como aluno sem academia e sem personal (vínculo via código de convite do personal, ver RF-004c).
5. **Provedor BaaS:** Supabase.

## 9.1 Novas Perguntas Abertas — Resolvidas

1. ~~Especialista em Educação Física~~ — **Resolvido.** O especialista da própria TechIndev (Prof. Dr. Rafael Mendes, Coach de Alto Rendimento) definiu a metodologia. Ver [METODOLOGIA-PRESCRICAO.md](METODOLOGIA-PRESCRICAO.md).
2. ~~Prazo para definição da metodologia~~ — **Resolvido.** Metodologia entregue; não é mais bloqueio para o cronograma.

A metodologia define: anamnese de onboarding, classificação de parâmetros de
treino por objetivo, splits por nível/dias disponíveis, estrutura de atributos
da biblioteca de exercícios, algoritmo de montagem do treino, regras de
progressão e periodização simplificada (ciclo de 4 semanas com deload).

**Impacto na arquitetura:** o RF-002 deixa de ser um "algoritmo a definir" e
passa a ser um **motor de regras data-driven** — splits, parâmetros de
volume/intensidade e atributos de exercícios devem ser modelados como dados
configuráveis no Supabase (não hardcoded), conforme seção 5 do documento de
metodologia.

**Impacto na curadoria de conteúdo:** a biblioteca inicial de exercícios deve
seguir o checklist de atributos da seção 4 do documento de metodologia, com
cobertura mínima de todos os padrões de movimento por tipo de equipamento.

---

## 10. Recomendação de Equipe e Próximos Passos

**Equipe recomendada para o protótipo:**
- **Mobile Architect (Flutter)** — define arquitetura do app, estrutura de pastas, gerenciamento de estado, integração com BaaS.
- **Mobile Senior (Flutter)** — implementação das telas e fluxos dos 3 perfis.
- **DevOps** — provisionamento do BaaS (free tier), configuração de ambientes, política de privacidade/LGPD.
- **QA** — testes manuais dos fluxos críticos antes da entrega.

*(Backend dedicado não recomendado nesta fase — uso de BaaS reduz custo e complexidade dentro da restrição de R$ 100/mês.)*

**Estimativa:** **M** (Médio) — escopo enxuto, mas com 3 perfis distintos e geração automática de treino em 1 mês exige foco no essencial (RF-001 a RF-008).

**Próximos passos:**
1. ~~Definir metodologia de prescrição~~ — **Concluído** (ver METODOLOGIA-PRESCRICAO.md).
2. ~~Arquitetura Flutter + Supabase~~ — **Concluído** (ver ARQUITETURA-MOBILE.md).
3. **TechIndev (curadoria):** popular `exercises` e `split_templates` (schema definido na arquitetura), seguindo o checklist da seção 4 da metodologia.
4. **Flutter Senior Developer:** iniciar implementação — módulos `auth` e `onboarding` primeiro (bloqueiam os demais).
5. **DevOps:** provisionar projeto Supabase (free tier) e configurar RLS por tabela.
