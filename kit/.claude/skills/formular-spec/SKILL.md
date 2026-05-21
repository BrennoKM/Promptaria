---
name: formular-spec
description: Constrói uma spec (História de Usuário, Feature Spec, Experiment Plan ou Contract Spec) interativamente a partir de demanda crua ou texto vago. Use quando a demanda chegou sem critérios mensuráveis, ou quando o usuário pede explicitamente ajuda pra formular antes de implementar. Escolhe o formato via árvore de decisão, conduz uma conversa estruturada, e entrega bloco copy-paste pronto pra colar no card.
---

# Skill: formular-spec

Construir uma spec a partir de uma demanda crua, de forma interativa. Útil quando quem solicita não tem spec pronta e precisa de ajuda pra formular antes (ou em vez) de codar direto.

## Quando usar

- A demanda chegou como texto livre vago ("preciso de um login", "criar tela de cadastro")
- Quem solicita pediu explicitamente: "me ajuda a escrever uma spec pra X"
- Durante `implementar-demanda`, o teste de precisão falhou e seria melhor formalizar antes
- Pra documentar algo que vai ser feito hoje, gerando artefato pro card/PR

## Princípio operacional

A skill **escolhe o formato certo primeiro**, depois conduz uma conversa estruturada que preenche cada seção. O resultado é um bloco markdown completo, copy-paste-ready, no formato definido em `.claude/specs.md`.

Spec não é teatro — não preencher só por preencher. Se uma seção não se aplica, marcar "N/A" ou omitir.

---

## Passo 1 — Escolher o formato

Faça as perguntas na ordem. Pare na primeira que tiver resposta clara.

### Pergunta 1: Existe um usuário humano que interage diretamente com isso?

- **Sim** → **História de Usuário**
- **Não** → Pergunta 2

### Pergunta 2: É uma hipótese a ser validada (PoC, spike, A/B test, prova de arquitetura)?

- **Sim** → **Experiment Plan**
- **Não** → Pergunta 3

### Pergunta 3: É a definição de como dois componentes se comunicam (API, evento, schema, protocolo)?

- **Sim** → **Contract Spec**
- **Não** → Pergunta 4

### Pergunta 4: É um módulo/feature técnica interna (sem UX, sem ser apenas contrato)?

- **Sim** → **Feature Spec**
- **Não** → pause, peça mais detalhe

Confirme o formato com quem solicita antes de prosseguir. Mostre por quê escolheu (cite as respostas).

---

## Passo 2 — Coletar conteúdo (varia por formato)

Consulte `.claude/specs.md` pra estrutura completa de cada formato. Resumo do que perguntar por formato:

### História de Usuário

| Campo | Pergunta |
|---|---|
| Papel | "Quem usa? recepcionista, paciente, admin, sistema automático?" |
| Ação + benefício | "O quê quer fazer e por quê? Qual problema isso resolve pra essa pessoa?" |
| Contexto | "Como isso é feito hoje (ou por que não é feito)?" |
| Requisitos (REQ) | "Liste os comportamentos do sistema. 'O sistema deve...' (sem misturar com restrições)" |
| Regras de negócio (RN) | "Tem alguma regra/restrição de domínio? 'Só pode quando...', 'Não pode...'" |
| Critérios de aceite (AC) | "Pra cada cenário (sucesso + erro + borda), descreva: Dado/Quando/Então" |
| Fora do escopo | "O que NÃO faz parte? (mesmo que pareça relacionado)" |
| Dependências | "Depende de alguma feature ainda não existe?" |

### Feature Spec

| Campo | Pergunta |
|---|---|
| Propósito técnico | "Tecnicamente, o que esse módulo precisa garantir? (sem usuário no meio)" |
| Contrato público | "Quem chama esse módulo? Que interface/função/decorator ele expõe?" |
| Integração | "De que outros módulos depende? Publica/consome eventos? Tem feature flag?" |
| Requisitos técnicos (REQ) | "Comportamentos técnicos: 'O módulo deve...'" |
| Restrições técnicas (RT) | "Invariantes ou acoplamentos proibidos: 'Não pode importar X', 'sempre via Y'" |
| Critérios de aceite (AC) | "Cenários técnicos verificáveis em BDD adaptado" |
| Performance/observabilidade | "Tem expectativa de latência? Logs/métricas obrigatórios?" |

### Experiment Plan

| Campo | Pergunta |
|---|---|
| Hipótese (HIP) | "Em uma frase: o que estamos afirmando que pode ser provado ou refutado?" |
| Motivação | "Qual decisão maior depende desse resultado?" |
| Procedimento | "Como executaríamos isso? (passo a passo reproduzível)" |
| Critérios de sucesso (CS) | "O que precisa ser observado pra hipótese ser confirmada? (mensurável)" |
| Critérios de falha (CF) | "O que, se acontecer, mata a hipótese? (decidir AGORA, não depois)" |
| Métricas | "O que vamos medir e como?" |
| Próximos passos | "Se confirmar/refutar/inconclusivo, o que fazemos depois?" |

### Contract Spec

| Campo | Pergunta |
|---|---|
| Partes | "Quem é o dono (publisher)? Quem consome?" |
| Schema | "Formato dos dados trocados? Pode dar exemplo?" |
| Cláusulas (CL) | "Regras explícitas sobre os campos (UUID, ISO-8601, etc.)" |
| Garantias (GAR) | "Entrega at-least-once? Ordem? Idempotência? Latência?" |
| Casos de erro | "Quais erros esperados e qual a resposta de cada?" |
| Versionamento | "Como vai evoluir sem quebrar consumidores?" |

> **Dica geral sobre lacunas:**
> - Se quem solicita **vai decidir depois sem urgência** → marque `[a definir]` e siga.
> - Se quem solicita **não sabe e a resposta é necessária pra implementar** → marque `[DÚVIDA: <pergunta específica>]`. Spec com `[DÚVIDA: ...]` não pode ir pra implementação até a resposta vir.
>
> Ver `.claude/specs.md` seção "Marcador `[DÚVIDA: ...]`" pra regras completas.

---

## Passo 3 — Validar a spec construída

Aplique o **teste de precisão**: leia a spec construída e pergunte mentalmente *"se eu implementar isso, alguém pode dizer que ficou errado por interpretação diferente?"*

Checklist mínimo (independente do formato):
- [ ] Sujeito da spec claro (quem é o ator: pessoa, sistema, módulo, hipótese, contrato)
- [ ] Pelo menos um item mensurável (AC, CS, GAR)
- [ ] Fora do escopo declarado (mesmo que seja "N/A")
- [ ] Não usa palavras vagas tipo "rápido", "fácil", "intuitivo" sem definição
- [ ] Toda lacuna sem resposta marcada como `[DÚVIDA: <pergunta>]` (não inventada)

Se algum item falha, volte ao Passo 2 nas seções relevantes.

---

## Passo 4 — Entregar a spec

Apresente a spec completa como bloco markdown copy-paste-ready:

```
─────────────────────────────────────────────────────
SPEC ({formato}) — {nome curto}
─────────────────────────────────────────────────────
{spec completa}
─────────────────────────────────────────────────────
```

Em seguida, ofereça as opções de destino:

> Onde você quer guardar essa spec?
> 1. **Só me dá o bloco** pra eu colar onde quiser (ClickUp/Jira, vault SDLC, papel) — já fiz isso acima ☝️
> 2. **Salva em `.specs/{NOME}/spec.md`** — workspace local não-versionado (cantinho de rascunho)
> 3. **Ambos** — entrego o bloco E salvo em `.specs/`

Se escolherem 2 ou 3, salve em `.specs/{NOME}/spec.md` (use o `código` da spec como nome da pasta — letras maiúsculas; ex: `.specs/RETRY/spec.md`, `.specs/AGE-CRI/spec.md`). Crie a pasta `.specs/{NOME}/` se não existir.

> **Nunca salve em `specs/` (sem ponto) por iniciativa própria.** Essa pasta seria versionada — fora do default da Promptaria. Se quem solicita pedir explicitamente, OK, mas mencione o tradeoff (vai pro git).

Depois, pergunte: *"quer que eu siga pra implementar essa spec agora? (skill `implementar-demanda`)"*

Se sim, a spec construída já vai como input formal pro `implementar-demanda` — o agente vai tratar todos os códigos (REQ/AC/etc.) como contrato verificável.

---

## O que NÃO fazer

- Não escolher formato sem confirmar com quem solicita.
- Não inventar valores ("a latência esperada é < 100ms" se ninguém disse isso). Marcar `[a definir]` ou `[DÚVIDA: <pergunta>]` conforme o caso.
- Não despejar todas as perguntas de uma vez — conduzir uma seção por vez.
- Não preencher seções por preencher. "N/A — motivo" é resposta válida.
- Não passar pra implementação sem a spec ter passado no checklist do Passo 3.
- Não passar pra implementação se ainda houver qualquer `[DÚVIDA: ...]` na spec.
- **Não salvar em `specs/` (sem ponto) por padrão.** Salvar local é `.specs/` (gitignorado). `specs/` versionado só com pedido explícito + aviso.
