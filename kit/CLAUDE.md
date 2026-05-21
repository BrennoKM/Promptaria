# Instruções do Agente — {{NOME_DO_PROJETO}}

<!--
  ════════════════════════════════════════════════════════════════════════
  CONFIGURAÇÃO INICIAL DA PROMPTARIA — leia antes de qualquer ação

  Verifique:
    1. Existe um arquivo `.promptaria` na raiz do repo? OU
    2. Este arquivo CLAUDE.md ainda tem placeholders `{{...}}` não preenchidos?

  Se SIM em qualquer dos dois:
    A Promptaria foi instalada mas a configuração interativa ainda não foi
    feita. Dispare IMEDIATAMENTE a skill `.claude/skills/configurar-projeto/SKILL.md`
    antes de qualquer outra ação. Não tente operar com este CLAUDE.md incompleto.
  ════════════════════════════════════════════════════════════════════════
-->

Este repositório usa a **Promptaria** como framework de agente.

## Sobre o projeto

{{DESCRICAO_CURTA}}

## Stack

{{STACK}}

<!-- Exemplo de formato (substitua pelo real durante configurar-projeto):
- Backend: Java 21 + Spring Boot 3.x
- Frontend: Next.js 14 (App Router) + TypeScript
- Banco: PostgreSQL 16, migrations com Flyway
- Testes: JUnit 5 (back), Vitest + Playwright (front)
-->

## Como rodar localmente

{{COMO_RODAR}}

## Como testar

{{COMO_TESTAR}}

## Estrutura

{{ESTRUTURA}}

## Padrão de commit

{{PADRAO_COMMIT}}

## Padrão de branch

{{PADRAO_BRANCH}}

<!-- Exemplo de formato (substitua pelo real durante configurar-projeto):
`feature/<codigo-da-demanda>-descricao-curta`, branch base `dev`, merge com `--no-ff`.
-->


## Como receber uma demanda

Quem solicita cola o texto da demanda no chat (geralmente vindo de ClickUp/Jira/Linear). A demanda pode chegar em formatos diferentes — a Promptaria opera sob o princípio **SDD (Spec-Driven Development)**: a precisão da spec determina a qualidade da entrega.

### Formatos reconhecidos

A demanda colada pode ser uma de quatro **specs formais** ou texto livre. Reconheça pelo conteúdo:

| Formato | Sinais de reconhecimento | Trate como |
|---|---|---|
| **História de Usuário** | "Como [papel], Quero [ação], Para [benefício]"; códigos `REQ-XXX-NN`, `RN-XXX-NN`, `AC-XXX-NN` em BDD (Dado/Quando/Então) | Comportamento com usuário final |
| **Feature Spec** | "Propósito Técnico", "Contrato Público", códigos `REQ-XXX-NN`, `RT-XXX-NN`, `AC-XXX-NN` | Módulo/feature técnica interna |
| **Experiment Plan** | "Hipótese", códigos `HIP-XXX-NN`, `CS-XXX-NN`, `CF-XXX-NN`, "Procedimento" | PoC ou validação de hipótese |
| **Contract Spec** | "Schema", "Partes (publisher/consumers)", códigos `CL-XXX-NN`, `GAR-XXX-NN` | Definição de contrato (API, evento, schema) |
| **Texto livre** | Bullets soltos, linguagem natural, sem códigos ou estrutura formal | Spec incompleta — aplicar precisão antes de codar |

> **Referência completa dos formatos e dos códigos** (REQ, RN, AC, RT, HIP, CS, CF, CL, GAR): veja [`.claude/specs.md`](.claude/specs.md). Leia esse arquivo sob demanda quando precisar reconhecer uma spec colada OU construir uma do zero.

### Princípio operacional

> **Quanto mais formal a spec, mais o agente respeita os códigos como contrato.**
> **Quanto mais livre o texto, mais o agente exige precisão antes de partir pro código.**

Caminhos possíveis:

1. **Spec formal colada** → usa [`implementar-demanda`](.claude/skills/implementar-demanda/SKILL.md) diretamente
2. **Texto livre vago** → oferece [`formular-spec`](.claude/skills/formular-spec/SKILL.md) pra construir a spec primeiro; depois implementa
3. **Texto livre suficiente** → segue `implementar-demanda` aplicando teste de precisão; se travar, recua pra `formular-spec`

Em todos os casos: **não invente requisito**.

## Regras inegociáveis (Promptaria — universais)

> Regras universais do framework. NÃO editar — são fundação. Pra regras específicas deste projeto, ver [`.claude/regras-projeto.md`](.claude/regras-projeto.md).

- **Nunca invente requisito.** Demanda vaga → pergunta antes de codar.
- **Nunca commite sem aprovação.** Sempre apresente o plano de commit e espere OK.
- **Sempre rode os testes** antes de declarar uma tarefa concluída.
- **Nunca pule hooks de pre-commit** (`--no-verify`) sem permissão explícita.
- **PR sempre** com base na branch definida na seção `Padrão de branch` deste arquivo.
- **Se a demanda tem códigos formais** (REQ, RN, AC, RT, HIP, CS, CF, CL, GAR), trate-os como **contrato** — cada código deve aparecer rastreável no plano, na implementação e nos testes.
- **Toda entrega exige Guia de Validação.** Sem ele, a tarefa NÃO está pronta. Vai junto na descrição do PR, formato em [`.claude/guia-validacao.md`](.claude/guia-validacao.md). Aplica-se a tudo: feature, bugfix, refactor, ajuste de config.
- **Nunca publique nada externo por iniciativa própria.** Sem `git push`, sem `gh pr create`, sem `gh pr comment` — prepare tudo copy-paste e instrua quem solicitou a executar.

## Regras inegociáveis do projeto

Consulte [`.claude/regras-projeto.md`](.claude/regras-projeto.md). Esse arquivo é populado pela skill `configurar-projeto` durante a instalação e é mantido pelo time. Toda regra lá tem o mesmo peso das universais acima.

## Aprendizados do projeto

> Conhecimento coletivo do time sobre comportamento do projeto. **Cada item aqui é algo que o agente já errou antes — e que o time corrigiu — pra não cair na mesma armadilha de novo.**
>
> Adicionado pela skill `gerenciar-memoria` quando uma descoberta vale pra todo mundo (vs algo só seu, que vai pra `.claude/memory/`). Mantenha enxuto — poucos e bons. Se virar enxurrada, sinal pra refatorar (virar regra de projeto, ou virar comentário no código).

### Domínio

<!--
  Termos, jargões, regras de negócio do cliente que o agente costuma confundir.
  Exemplo:
  - **"Beneficiário" ≠ titular** — no jargão do cliente, "beneficiário" é o paciente que usa o plano, não quem assinou o contrato.
-->

_(nenhum aprendizado registrado ainda)_

### Convenção implícita

<!--
  Padrões do código que não estão em ADR/doc mas todo mundo segue.
  Exemplo:
  - **Endpoints de admin sempre `/admin/v1/`** — não documentado, mas padrão do código existente. Agente já criou `/api/v1/admin/` errado antes.
-->

_(nenhum aprendizado registrado ainda)_

### Gotcha técnico

<!--
  Pegadinhas do projeto que custam tempo descobrir sozinho.
  Exemplo:
  - **Cache invalida só em deploy, não em restart** — reiniciar o serviço local NÃO limpa cache. Use `make cache:clear` antes de testar.
-->

_(nenhum aprendizado registrado ainda)_

## Skills disponíveis

- [configurar-projeto](.claude/skills/configurar-projeto/SKILL.md) — configuração inicial guiada do CLAUDE.md (preenche stack, como rodar, etc.). Dispara automaticamente na primeira execução após instalar a Promptaria.
- [formular-spec](.claude/skills/formular-spec/SKILL.md) — construir uma spec (História, Feature, Experimento, Contrato) interativamente a partir de demanda crua. Útil quando não vem spec pronta.
- [implementar-demanda](.claude/skills/implementar-demanda/SKILL.md) — fluxo completo: reconhecer formato → planejar → implementar → testar → gerar guia de validação → entregar bloco copy-paste pra abrir PR.
- [validar-entrega](.claude/skills/validar-entrega/SKILL.md) — gerar Guia de Validação pra trabalho feito por terceiro (outra pessoa, outro time). Útil pra quem recebe PR sem roteiro de teste e precisa produzir um.
- [gerenciar-memoria](.claude/skills/gerenciar-memoria/SKILL.md) — salvar/atualizar/consultar memórias locais do projeto em `.claude/memory/`. Use ao descobrir convenção/decisão/gotcha que vai ser útil em sessões futuras.

> **Referência de formatos de spec:** [`.claude/specs.md`](.claude/specs.md)
> **Memórias acumuladas deste projeto:** [`.claude/memory/MEMORY.md`](.claude/memory/MEMORY.md) (índice — leia no início de tarefas relevantes; carregue memórias individuais sob demanda)
