# Memória local da Promptaria

Este diretório guarda **memórias acumuladas pelo agente** sobre este projeto: decisões tomadas, gotchas descobertos, convenções estabelecidas, contexto de domínio que vale lembrar entre sessões.

## Como funciona

- O agente escreve aqui via skill [`gerenciar-memoria`](../skills/gerenciar-memoria/SKILL.md).
- O agente lê o índice `MEMORY.md` no início de tarefas relevantes e carrega memórias individuais quando o tópico aparece.
- **Conteúdo NÃO é versionado.** Só este `README.md` e o `.gitignore` vão pro git — todo `.md` de memória fica local na máquina.

## Por que não versionar

Por padrão a Promptaria mantém memória local pra:
- **Privacidade:** evita que contexto de domínio (clientes, dados, decisões internas) vaze pro git público.
- **Personalização:** cada dev acumula sua própria leitura do projeto sem brigar em merge.
- **Simplicidade:** zero overhead de PR review pra mudanças de memória.

Se o time quiser compartilhar memória entre devs, remova `*` do `.gitignore` deste diretório. **Considere antes** o que vai vazar pro repo.

## Tipos de memória

| Tipo | O que é | Exemplo |
|---|---|---|
| `decisao` | Decisão técnica/arquitetural tomada (não no nível de ADR — algo menor) | "decidimos usar paginação cursor em vez de offset porque o dataset cresce muito" |
| `gotcha` | Armadilha conhecida, pegadinha que custou tempo descobrir | "cache do módulo X invalida só ao subir versão da config — não basta restart" |
| `convencao` | Padrão informal do time que ainda não virou regra inegociável | "PRs pequenas (<300 LoC) são preferidas — desestimulamos PRs grandes" |
| `dominio` | Termo, conceito ou regra do domínio do cliente | "no jargão do cliente, 'beneficiário' = paciente da assinatura, não titular" |
| `referencia` | Onde encontrar coisa externa relevante | "dashboard de latência: https://grafana.empresa/d/api-latency" |

## Estrutura de cada memória

Arquivo: `tipo-slug.md` (ex: `gotcha-cache-invalida.md`, `decisao-paginacao-cursor.md`)

Conteúdo:

```markdown
---
nome: gotcha-cache-invalida
tipo: gotcha
descricao: Cache do módulo X só invalida ao subir versão da config
criada_em: 2026-05-21
atualizada_em: 2026-05-21
---

{conteúdo da memória — direto ao ponto, sem firula}
```

E uma entrada no `MEMORY.md` (índice) com 1 linha:
```
- [Cache do módulo X só invalida ao subir versão](gotcha-cache-invalida.md) — gotcha
```
