# Integrações MCP (Model Context Protocol)

Esta pasta guarda as integrações opcionais da Promptaria com servidores MCP — serviços
externos que o agente pode ler e escrever (trackers, docs, etc.) durante o fluxo.

> **MCP é 100% opt-in.** Sem nenhum MCP configurado, a Promptaria funciona normalmente:
> o agente entrega tudo em bloco copy-paste e você cola no tracker manualmente. Conectar
> um MCP só adiciona um caminho automatizado (com aprovação explícita), nunca substitui
> o fluxo manual nem o torna obrigatório. Isso preserva o princípio agnóstico do framework.

## Como está organizado

```
.claude/MCP/
├── README.md          🌐 versionado — este arquivo
└── {Servico}/         uma pasta por MCP (ex: ClickUp/)
    ├── README.md      🌐 versionado — doc genérica: como conectar, capacidades, limites
    └── config.md      💻 LOCAL — IDs e defaults pessoais deste dev (NÃO vai pro git)
```

**Regra de versionamento:** informação genérica do projeto (como conectar, o que o MCP
faz) é versionada e compartilhada pelo time. Informação pessoal de cada dev (IDs de
workspace, mapa de assignees, defaults) fica em `config.md`, que é gitignorado
(`MCP/*/config.md` no `.claude/.gitignore`).

## MCPs disponíveis

| Serviço | Pasta | O que habilita |
|---|---|---|
| ClickUp | [`ClickUp/`](ClickUp/README.md) | Criar card a partir da spec, atribuir (assignee/prioridade/due date/status), comentar guias, mover status |

## Como conectar um MCP

A skill `configurar-projeto` pergunta, na instalação, se você quer conectar algum MCP.
Pra (re)conectar manualmente depois, abra o Claude Code no projeto e diga
*"configurar projeto"* — ela conduz a escolha de MCP, a coleta de IDs e a criação do
`config.md` local.

A conexão em si (autenticação OAuth) é por-dev e descrita no README de cada serviço.

## Adicionar um novo MCP no futuro

1. Criar `.claude/MCP/{Servico}/README.md` (versionado) com: endpoint, como autenticar,
   capacidades e limites.
2. Criar o molde de `config.md` (gerado localmente pela `configurar-projeto`, nunca
   versionado — já coberto pelo padrão `MCP/*/config.md` no `.gitignore`).
3. Registrar o serviço na tabela "MCPs disponíveis" acima e no passo "Escolher MCP" da
   skill `configurar-projeto`.
