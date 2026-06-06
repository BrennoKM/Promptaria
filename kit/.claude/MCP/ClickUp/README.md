# MCP ClickUp

Integração opcional que deixa o agente **ler** uma task do ClickUp como spec e **escrever**
no ClickUp (criar card, atribuir, comentar, mover status) — sempre com aprovação explícita
a cada escrita.

> Doc genérica e versionada (sem IDs). Os IDs e defaults pessoais deste dev ficam em
> `config.md` (mesma pasta), que é gitignorado.

## Endpoint e autenticação

- **Endpoint:** `https://mcp.clickup.com/mcp` (MCP remoto, transporte HTTP)
- **Autenticação:** **somente OAuth 2.1 + PKCE.** API key ou token de conta **não funcionam**.
  Cada dev autentica na própria máquina; não dá pra compartilhar credencial.

### Conectar (por-dev, uma vez)

No terminal, na raiz do projeto:

```bash
claude mcp add --transport http clickup https://mcp.clickup.com/mcp
```

Na primeira chamada o Claude Code abre o fluxo OAuth no navegador. Aprove o acesso ao
seu workspace ClickUp e pronto.

## Capacidades usadas pela Promptaria

- Criar task (card) com título e descrição (a spec em markdown)
- Atribuir: assignee, prioridade, due date, status
- Buscar task por ID/URL (pra ler a demanda como spec)
- Comentar na task (postar Guia de Validação + Guia de Contexto Técnico)
- Mover status (refletir a fase: spec criada → em implementação → em revisão)

## Limites importantes

- **Beta público.** A API pode mudar. O caminho copy-paste continua sempre disponível
  como fallback.
- **Sem exclusão.** O MCP bloqueia delete de propósito (segurança). Correções são feitas
  por **update** ou **comentário**, nunca recriando/apagando.
- **Aprovação explícita.** O agente nunca cria/edita um card por iniciativa própria —
  mostra o que vai fazer e espera "sim" a cada escrita.
- **Rate limits** variam por plano e pela presença do add-on "Everything AI".

## Configuração local

Os IDs (workspace, space, list, user) e os defaults de criação ficam em
[`config.md`](config.md) — gerado localmente pela skill `configurar-projeto`. Se o arquivo
não existir, o MCP não é acionado e o fluxo segue copy-paste.
