# Specs locais — workspace de prototipagem

Diretório pra rascunhar specs e guardar backup de guias de validação durante o trabalho. **Não vai pro git** (ver `.gitignore`).

## Organização

Uma pasta por demanda, nome em maiúsculas (mesmo código usado na spec):

```
.specs/
├── RETRY/
│   ├── spec.md           ← rascunho da spec (gerado por formular-spec)
│   └── validacao.md      ← backup do Guia de Validação (gerado por implementar-demanda)
├── AGE-CRI/
│   ├── spec.md
│   └── validacao.md
└── USER-EVENTS/
    └── spec.md           ← (só spec, sem validação salva ainda)
```

Não tem subpastas obrigatórias. Se a demanda só gerou spec, só `spec.md`. Se só gerou validação, só `validacao.md`. Se gerou ambos, ambos.

## Pra quê serve cada arquivo

| Arquivo | Origem | Pra quê |
|---|---|---|
| `spec.md` | skill `formular-spec` quando você optou por salvar | Consultar a spec depois sem precisar voltar no card/vault |
| `validacao.md` | skill `implementar-demanda` (salvamento automático no Passo 5) | Backup local do Guia de Validação caso esqueça de colar no PR — recupera o histórico do trabalho |

## Quando usar

- Construir uma spec via skill `formular-spec` e querer guardar localmente
- O agente automaticamente salva `validacao.md` toda vez que gera um Guia de Validação — você não precisa fazer nada, é backup
- Rascunhar variações de uma spec antes de levar pra discussão
- Anotar contexto local sobre uma demanda em andamento

## Quando NÃO usar

- Pra a spec "oficial" combinada com cliente/time — mora upstream (vault SDLC, ClickUp/Jira/Linear)
- Pro Guia de Validação que vai pro time validar — esse vai no **corpo do PR** e **comentário do card**. O `validacao.md` aqui é só backup pessoal.

## Como compartilhar com o time

Por padrão, tudo aqui é privado. Pra compartilhar:

1. **Vai pro upstream:** levar pro vault SDLC e refinar com QA/PM
2. **Vai pro PR/card:** colar a spec e/ou validação na descrição do PR e comentário do card
3. **Remover o `.gitignore`:** se o time decidir versionar, edite o `.gitignore` (mas pense duas vezes — costuma poluir o repo)
