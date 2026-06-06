---
name: configurar-projeto
description: Configuração inicial guiada da Promptaria. Conduz a primeira execução do repositório — inventaria o repo (manifests, Dockerfile, CI), preenche os placeholders {{...}} do CLAUDE.md (stack, como rodar, como testar, padrões) e popula .claude/regras-projeto.md. Dispara automaticamente quando existe `.promptaria` na raiz ou quando o CLAUDE.md ainda tem placeholders.
---

# Skill: configurar-projeto

Conduzir a configuração interativa do repositório recém-instalado com Promptaria — preencher os placeholders `{{...}}` no `CLAUDE.md` (stack, como rodar, como testar, padrão de commit, etc.) através de uma conversa estruturada.

## Quando usar

Disparar automaticamente quando:

- O arquivo `.promptaria` existir na raiz do repositório (marca deixada pelo `install.sh`)
- OU o `CLAUDE.md` da raiz ainda tem placeholders `{{...}}` não preenchidos
- OU alguém pedir explicitamente: "configurar projeto", "completar instalação da Promptaria"

## Princípio operacional

Esta skill **investiga primeiro, pergunta depois**. Boa parte da informação (stack, como rodar, estrutura) está visível no repositório — leia antes de perguntar. Só pergunte o que não dá pra inferir com confiança.

Resultado final: `CLAUDE.md` preenchido + `.promptaria` removido.

---

## Passo 0 — Detectar e fundir backups de instalação anterior

Antes de qualquer coisa, procure por arquivos `*.bak-*` no projeto (raiz, `.claude/`, `.claude/skills/*/`). Esses arquivos são gerados pelo `install.sh` quando o instalador encontra arquivos do projeto diferentes da versão do kit (acontece em update, ou em instalação sobre projeto já existente).

Se **não houver** nenhum `.bak-*`, pule este passo e vá pro Passo 1.

Se **houver**, conduza a fusão antes de seguir:

1. Liste os `.bak-*` encontrados pra quem solicita, agrupados por tipo:
   - **Customização do time** (vai exigir fusão real): `CLAUDE.md.bak-*`, `.claude/regras-projeto.md.bak-*`
   - **Infra da Promptaria modificada localmente** (geralmente o usuário só quer descartar a versão antiga): `.claude/processos/specs.md.bak-*`, `.claude/templates/guia-validacao.md.bak-*`, `.claude/templates/guia-contexto-tecnico.md.bak-*`, `.claude/skills/*/SKILL.md.bak-*`, qualquer `.gitignore.bak-*`

2. Pra cada `.bak-*` da categoria "Customização do time":
   - Mostre o diff entre o `.bak-*` e o arquivo novo correspondente.
   - Pergunte: *"Quer manter o conteúdo antigo, o novo, ou fundir os dois?"*. Conduza a fusão item por item se for o caso.
   - Aplique o resultado ao arquivo novo (sem o sufixo `.bak-*`).

3. Pra cada `.bak-*` da categoria "Infra":
   - Mostre o diff resumido (uma frase explicando o que mudou).
   - Pergunte: *"Você tinha modificado esse arquivo de infra de propósito? Se sim, vou conduzir fusão. Se não, descarto o .bak-*."*.

4. Ao final, pergunte: *"Posso apagar os `.bak-*` agora que o conteúdo foi fundido (ou descartado)?"*. Só apague com confirmação explícita. Nunca apague por iniciativa própria.

5. Só depois disso, prossiga pro Passo 1.

> **Não pule esta detecção.** Ignorar `.bak-*` significa perder customização do time silenciosamente, que é o motivo pelo qual o install.sh gera os backups em primeiro lugar.

---

## Passo 1 — Inventariar o repositório

Antes de qualquer pergunta, leia o que está no diretório:

- **Arquivos de manifest:** `package.json`, `pyproject.toml`, `pom.xml`, `build.gradle`, `Cargo.toml`, `go.mod`, `composer.json`, `Gemfile`, etc.
- **Arquivos de config:** `Dockerfile`, `docker-compose.yml`, `Makefile`, `justfile`, `.env.example`
- **README existente** se houver
- **Estrutura de pastas raiz** (`src/`, `app/`, `backend/`, `frontend/`, etc.)
- **CI** (`.github/workflows/`, `.gitlab-ci.yml`) — revela como testar e rodar
- **Git config:** branch padrão, padrão de nome de branch existente em `git branch -a`

Resuma internamente o que aprendeu sobre: stack, como rodar, como testar, estrutura.

---

## Passo 2 — Apresentar diagnóstico

Mostre ao usuário, em formato curto, o que você inferiu. Algo como:

```
Inventário do repositório:
- Stack: Java 21 + Spring Boot 3.2 (do pom.xml), PostgreSQL (do docker-compose.yml)
- Como rodar: `./mvnw spring-boot:run` (inferido de mvnw + Spring)
- Como testar: `./mvnw test` (inferido)
- Estrutura: src/main/java + src/test/java (Maven padrão)
- CI: GitHub Actions roda testes em PR (.github/workflows/test.yml)

Está correto? Vou usar isso pra preencher o CLAUDE.md. Algo a ajustar/adicionar?
```

Espere a confirmação antes de seguir.

---

## Passo 3 — Perguntar só o que falta

Itens que normalmente **não dá pra inferir** e exigem pergunta:

| Campo do CLAUDE.md | Pergunta sugerida |
|---|---|
| Nome do projeto | "Qual o nome do projeto? (vai aparecer no título do CLAUDE.md)" |
| Descrição curta | "Em 1-2 linhas: o que esse projeto faz?" |
| Padrão de commit | "Padrão de mensagem de commit? (ex: Conventional Commits, Gitmoji, livre)" |
| Padrão de branch | "Como nomear branches de feature? Qual a branch base? Merge com --no-ff?" |
| Convenções específicas | "Há alguma convenção do time que o agente deve respeitar? (ex: migrations com timestamp, sem mocks em integração, etc.)" |

Faça as perguntas **uma de cada vez** — não despeje tudo. Confirme cada resposta antes de seguir.

---

## Passo 4 — Preencher o CLAUDE.md

Substitua os placeholders `{{...}}` no `CLAUDE.md` pela informação coletada. Mantenha o resto do arquivo intacto (regras inegociáveis, princípios SDD, etc. são da Promptaria — não mexer).

Após preencher, mostre o `CLAUDE.md` final ao usuário pra confirmação.

---

## Passo 5 — Preencher regras inegociáveis específicas do projeto

Abra `.claude/regras-projeto.md` (já criado pelo install.sh com placeholders).

Pergunte: *"Há regras específicas do time/projeto que devem ser inegociáveis pro agente? Pense em coisas como: 'migrations sempre com timestamp', 'nunca usar X biblioteca', 'rodar lint antes de commit', 'endpoints em /api/v1/'. Pode passar quantas quiser, ou pular se ainda não tem."*

Preencha a seção "Regras" do arquivo com cada item respondido, no formato:
```
- **Nome curto:** explicação completa em uma frase. Motivo opcional entre parênteses.
```

Substitua o placeholder `{{REGRAS_DO_PROJETO}}` pelas regras coletadas (ou por "_(nenhuma regra específica neste momento — adicionar quando surgir)_" se quem solicita pulou).

Substitua `{{NOME_DO_PROJETO}}` no header e `{{DATA}}` no histórico pela data atual em ISO (YYYY-MM-DD).

Não toque na seção "Como usar este arquivo" — ela é fixa.

---

## Passo 6 — Escolher integração MCP (opcional)

A Promptaria pode se conectar a um servidor MCP pra ler a demanda e escrever de volta no
tracker (criar card, atribuir, comentar). É **opcional e por-dev** — preserva o princípio
agnóstico do framework.

Pergunte:

> *"Quer conectar a Promptaria a algum MCP pra automatizar o tracker? As escritas sempre
> pedem sua aprovação, uma a uma. Opções:*
> *1. **ClickUp** — criar card a partir da spec, atribuir (assignee/prioridade/due
>    date/status), comentar os guias.*
> *2. **Nenhum MCP** — mantenho o fluxo copy-paste (você cola no tracker manualmente).*
> *Qual prefere?"*

### Se escolher "Nenhum MCP"
Não crie nada. As skills detectam a ausência de `.claude/MCP/{Servico}/config.md` e seguem
o fluxo copy-paste de sempre. Siga pro Passo 7.

### Se escolher "ClickUp"

1. **Explique a conexão OAuth** (por-dev, uma vez). Instrua a rodar no terminal:
   ```bash
   claude mcp add --transport http clickup https://mcp.clickup.com/mcp
   ```
   E completar o login OAuth no navegador (ClickUp só aceita OAuth, não API key).
   Detalhes em [`.claude/MCP/ClickUp/README.md`](../../MCP/ClickUp/README.md).

2. **Colete os IDs e defaults**, uma pergunta de cada vez. Se o MCP já estiver conectado,
   você pode buscar os valores via MCP (listar workspaces/spaces/lists/membros) e oferecer
   pra escolher por nome em vez de pedir o ID cru. Itens:
   - Workspace (Team) ID
   - Space ID
   - Lista padrão (List ID) onde os cards nascem
   - Mapa de assignees (nome → user ID) — pelo menos o do próprio dev
   - Defaults ao criar card: assignee padrão, prioridade padrão (urgent/high/normal/low),
     status inicial, e se usa due date por padrão
   - Mapa de status (fase Promptaria → status do ClickUp): "spec criada", "em
     implementação", "em revisão (PR aberto)"

3. **Crie o arquivo local** `.claude/MCP/ClickUp/config.md` (gitignorado — é pessoal deste
   dev, não vai pro git) com os valores coletados, neste formato:

   ```markdown
   # Configuração — MCP ClickUp (LOCAL, não versionado)

   ## Identificadores
   - Workspace (Team) ID: <id>
   - Space ID: <id>
   - Lista padrão (List ID): <id>

   ## Assignees (nome → user ID)
   - <nome>: <user id>

   ## Defaults ao criar card
   - Assignee padrão: <nome/id>
   - Prioridade padrão: <urgent|high|normal|low>
   - Status inicial: <status>
   - Usa due date por padrão: <sim/não — regra, ex: "+3 dias úteis" ou "não">

   ## Mapa de status (fase Promptaria → status ClickUp)
   - spec criada: <status>
   - em implementação: <status>
   - em revisão (PR aberto): <status>
   ```

   Para qualquer valor que o dev não souber agora, use `[a definir]` (nunca invente IDs).

4. Confirme: *"Config salva em `.claude/MCP/ClickUp/config.md` (local, não vai pro git).
   As skills `formular-spec` e `implementar-demanda` vão oferecer criar/atualizar cards a
   partir de agora — sempre pedindo sua aprovação antes de cada escrita."*

> **Extensível:** se no futuro existir outro MCP (Jira, Linear), este passo lista a nova
> opção e cria `.claude/MCP/{Servico}/config.md` no mesmo padrão.

---

## Passo 7 — Validar instalação

Confira que estes arquivos existem na raiz do repositório:

- [ ] `CLAUDE.md` (preenchido, sem `{{...}}` restantes)
- [ ] `.claude/processos/specs.md` (referência dos formatos)
- [ ] `.claude/regras-projeto.md` (preenchido, sem `{{...}}` restantes)
- [ ] `.claude/.gitignore` (marca `skills/` e `memory/` como locais)
- [ ] `.claude/memory/.gitignore` (sistema de memória local)
- [ ] `.specs/README.md` + `.specs/.gitignore` (workspace local de rascunhos de spec)
- [ ] `.claude/skills/configurar-projeto/SKILL.md` (esta própria)
- [ ] `.claude/skills/formular-spec/SKILL.md`
- [ ] `.claude/skills/implementar-demanda/SKILL.md`
- [ ] `.claude/skills/validar-entrega/SKILL.md`
- [ ] `.claude/skills/gerenciar-memoria/SKILL.md`
- [ ] `.claude/templates/guia-validacao.md`
- [ ] `.claude/templates/guia-contexto-tecnico.md`
- [ ] `.claude/MCP/README.md` + `.claude/MCP/ClickUp/README.md` (doc dos MCPs disponíveis)
- [ ] Se escolheu ClickUp no Passo 6: `.claude/MCP/ClickUp/config.md` (local, com IDs)

Se algum estiver faltando, avisar o usuário (possível instalação incompleta).

---

## Passo 8 — Limpar marcador

Remova o arquivo `.promptaria` da raiz:

```bash
rm .promptaria
```

Confirme a remoção e finalize com uma mensagem do tipo:

> "Configuração concluída. A Promptaria está pronta. Próximo passo: cole uma demanda no chat e o agente vai seguir o fluxo da skill `implementar-demanda`."

---

## Edge cases

| Situação | Como tratar |
|---|---|
| `CLAUDE.md` não existe | Avisar — instalação falhou ou foi parcial. Pedir pra rodar `install.sh` novamente |
| Stack heterogênea (mono-repo com 2+ stacks) | Documentar todas no CLAUDE.md em seções claras (Backend / Frontend / etc.) |
| Manifest ambíguo (ex: package.json com várias possibilidades) | Perguntar especificamente: "esse package.json é do frontend, do backend, ou root?" |
| Nada inferível (repo vazio ou só docs) | Perguntar tudo desde o início, sem inferir |
| Placeholder `{{...}}` que não tem informação real ainda | Manter como `[a definir]` em vez de inventar — sinaliza ao agente que falta info |
