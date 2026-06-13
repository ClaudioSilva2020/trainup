# TrainUp

O TrainUp oferece treinos estruturados e personalizados (gerados pelo próprio app via regras/algoritmo, sem depender de personal humano), permite que personal trainers montem treinos customizados para seus alunos, e dá às academias uma forma de cadastrar e acompanhar alunos (filiados ou avulsos).

## Documentação

- [Documento de Requisitos](REQUISITOS.md)
- [Metodologia de Prescrição de Treino](METODOLOGIA-PRESCRICAO.md)
- [Arquitetura Mobile (Flutter + Supabase)](ARQUITETURA-MOBILE.md)

## Identidade Visual

A marca usa azul-marinho (`#0B2545`), verde (`#1FD65F`) e um acento amarelo
(`#FFD60A`), com preto e branco — referência à paleta verde/azul/amarelo
sugerida pelo cliente. Os arquivos da logo estão em
[`assets/branding/`](assets/branding/):

- `icon.svg` — ícone do app (selo com "T" formado por uma barra de halteres + seta de progresso)
- `logo_horizontal.svg` — logo com wordmark "TrainUp"

## Como executar o protótipo

```bash
flutter pub get
flutter run            # dispositivo/emulador
flutter run -d chrome  # navegador
```

A tela inicial (`SplashScreen`) apresenta a marca; o botão "Começar" leva a um
mock da Home do aluno com o "treino de hoje" e o card de evolução — conteúdo
ilustrativo para validação com o cliente.

## Estrutura

```
lib/
├── core/theme/         # paleta de cores e ThemeData
├── features/
│   ├── splash/         # tela de boas-vindas
│   └── home/           # mock da home do aluno
└── shared/widgets/      # TrainUpLogo e outros componentes reutilizáveis
```
