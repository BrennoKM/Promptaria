# Promptaria

> Oficina de prompts pra agentes de IA escreverem código com regra, contexto e processo.

Promptaria é um framework stack-agnóstico que transforma qualquer repositório em um ambiente preparado pra um agente de IA (Claude Code, Cursor, etc.) implementar demandas seguindo o processo do time.

---

## Pra quem é

A Promptaria foi pensada pra times pequenos e devs solo. O foco é dar disciplina sem virar burocracia.

Não é pensada pra equipes grandes com ferramentas SDD já consolidadas, multi-agente complexo, ou pipelines rígidos. Pra esses casos, opções como Spec Kit, BMAD ou Kiro cobrem melhor.

---

## SDD-aware por padrão

A Promptaria opera no princípio **SDD (Spec-Driven Development)**: trata a spec como contrato e adapta o rigor conforme o formato recebido.

- **Spec formal** (com códigos REQ, RN, AC, RT, HIP, CS, CF, CL, GAR) → tratada como contrato verificável; cada código deve aparecer no plano, no código e nos testes.
- **Texto livre** → submetido ao teste de precisão; se houver ambiguidade que possa virar bug, o agente pergunta antes de codar.

Reconhece quatro formatos: História de Usuário, Feature Spec, Experiment Plan, Contract Spec.

**Toda entrega exige Guia de Validação + Guia de Contexto Técnico** na descrição do PR. Sem ambos, a tarefa não está pronta. Resolvem dois atritos comuns: validador receber "tá no PR, testa aí" sem saber o que testar; e revisor de código (ou quem mexer no código meses depois) virar arqueólogo pra entender o que era intencional.

---

## Comparação com alternativas

O ecossistema SDD cresceu rápido em 2025-2026. Algumas opções e como a Promptaria se diferencia:

- **GitHub Spec Kit**: CLI vendor-neutral, padrão de mercado, em inglês, com curva técnica. Promptaria é mais leve e em PT-BR.
- **AWS Kiro**: IDE proprietário, pago, pipeline rígido. Bom pra setor regulado. Promptaria é flexível e sem custo.
- **BMAD-METHOD**: orquestra múltiplos agentes (PM, arquiteto, QA) com handoffs formais. Promptaria usa um agente só com skills modulares.
- **Tessl**: aposta radical de "código vira artefato compilado a partir de spec". Promptaria mantém código como fonte da verdade.

A Promptaria pegou ideias do ecossistema, como o marcador de lacuna (inspirado no `[NEEDS CLARIFICATION]` do Spec Kit, traduzido pra `[DÚVIDA: ...]`), rastreabilidade bidirecional e gates entre fases. Adicionou algumas coisas próprias: Guia de Validação obrigatório em toda entrega, reconhecimento de 4 formatos de spec, controle total de quem solicita sobre publicação externa, e foco em PT-BR.

---

## Filosofia

### O problema

A maior fonte de defeito em time de desenvolvimento é a **distância entre a demanda e o código**. Quanto mais passos não-explicitados entre "o cliente pediu X" e "o PR foi aberto", mais lugar pra desentendimento, retrabalho e bug.

Agentes de IA prometem encurtar essa distância, mas trazem um problema novo: **alucinam quando a demanda é vaga**. Sem contexto e processo, o agente preenche os buracos sozinho, e o resultado é código plausível mas errado.

### A aposta

A Promptaria aposta que **a qualidade da entrega do agente é função direta do contexto e processo que ele recebe**.

Por isso o framework foca em três coisas:

1. **Contexto enxuto e específico**: `CLAUDE.md` com stack, como rodar, como testar e estrutura. Sem firula.
2. **Processo explícito**: skills que descrevem o "como fazer" passo a passo (ler demanda, planejar, implementar, testar, abrir PR).
3. **Pontos de parada**: momentos onde o agente DEVE perguntar ou pedir aprovação, em vez de seguir em frente alucinando.

### Princípios

- **Stack-agnóstico**: o `CLAUDE.md` do projeto traz a stack. O framework funciona pra qualquer linguagem.
- **Texto > Configuração**: tudo é markdown. Sem YAML, sem JSON, sem schema rígido.
- **Cópia > Dependência**: o conteúdo de `kit/` é copiado pra raiz do projeto, não linkado. O time é dono da sua versão dos arquivos compartilhados (`CLAUDE.md`, `processos/specs.md`, etc.) e cada dev é dono da própria versão das skills.
- **Demanda do humano, não do vault**: quem solicita cola o texto da demanda no chat. Funciona com qualquer fonte (ClickUp, Jira, Linear, papel).
- **Inegociáveis acima de produtividade**: pedir aprovação antes de commitar, não inventar requisito, não pular hooks. Velocidade vem da confiança, não do atalho.

---

## Instalação

A instalação tem duas etapas: **cópia** (script) e **configuração** (interativa, conduzida pelo próprio agente).

### Pré-requisitos

- Um repositório git inicializado onde a Promptaria será instalada
- Claude Code (ou outro agente que leia `CLAUDE.md`) instalado
- `curl` e `tar` instalados (universais em Linux/macOS), só pro modo remoto

### Etapa 1: Cópia (`install.sh`)

Dois modos de rodar, escolha o que preferir:

#### Modo A: Remoto (não precisa clonar)

A partir da raiz do projeto onde quer instalar:

```bash
curl -fsSL https://raw.githubusercontent.com/BrennoKM/Promptaria/main/install.sh | bash
```

O script baixa o conteúdo de `kit/` diretamente do GitHub e copia pra raiz do projeto. Sem precisar clonar a Promptaria.

#### Modo B: Local (a partir de um clone)

Se você quer ver o código antes, ou já tem a Promptaria clonada:

```bash
git clone https://github.com/BrennoKM/Promptaria.git
cd /caminho/pro/meu-projeto/
bash /caminho/pra/Promptaria/install.sh
```

O script detecta automaticamente que tem `kit/` adjacente e usa o conteúdo local (sem rebaixar do GitHub).

#### O que o `install.sh` faz (ambos os modos)

- Copia o conteúdo de `kit/` (CLAUDE.md, skills, processos/specs.md, etc.) pra raiz do projeto
- Cria o marcador `.promptaria` pra sinalizar que a configuração interativa ainda não foi feita
- Pede confirmação se algum arquivo conflitante já existir (`CLAUDE.md`, `.claude/`, `.specs/`)

### Etapa 2: Configuração (interativa)

Abra o Claude Code no diretório do projeto:

```bash
claude
```

Na primeira invocação, o agente detecta o `.promptaria` (ou os placeholders `{{...}}` no CLAUDE.md), dispara automaticamente a skill `configurar-projeto`, inventaria o repo (manifests, Dockerfile, CI, etc.) pra inferir stack/como rodar/como testar, e pergunta só o que não conseguiu inferir.

Se a skill não disparar sozinha, diga ao agente: *"configurar projeto"*.

### O que vai pro seu projeto

Legenda: 🌐 versionado (compartilhado pelo time via git) · 💻 local (só na máquina do dev, ignorado pelo git)

```
{seu-projeto}/
├── (código do projeto: src/, package.json, etc.)
├── CLAUDE.md                                  🌐 preenchido com sua stack/processo
├── .claude/
│   ├── .gitignore                             🌐 marca skills/ e memory/ como locais
│   ├── regras-projeto.md                      🌐 regras inegociáveis específicas do time
│   ├── processos/
│   │   └── specs.md                           🌐 referência dos 4 formatos de spec e códigos
│   ├── templates/
│   │   ├── guia-validacao.md                  🌐 formato canônico do Guia de Validação
│   │   └── guia-contexto-tecnico.md           🌐 formato canônico do Guia de Contexto Técnico
│   ├── memory/                                💻 memórias pessoais de cada dev
│   │   ├── .gitignore
│   │   └── (memórias criadas pelo agente, não vão pro git)
│   └── skills/                                💻 cada dev instala/atualiza Promptaria por conta
│       ├── configurar-projeto/SKILL.md
│       ├── formular-spec/SKILL.md
│       ├── implementar-demanda/SKILL.md
│       ├── validar-entrega/SKILL.md
│       └── gerenciar-memoria/SKILL.md
└── .specs/                                    💻 workspace local — três artefatos por demanda
    ├── README.md
    ├── .gitignore                             (ignora todo .md interno)
    └── {NOME-DA-DEMANDA}/                     uma pasta por demanda
        ├── spec.md                            spec (salva automaticamente em formular-spec e implementar-demanda)
        ├── validacao.md                       Guia de Validação (salvo automaticamente em implementar-demanda)
        └── contexto-tecnico.md               Guia de Contexto Técnico (salvo automaticamente em implementar-demanda)
```

> **Por que `skills/` é local?** As skills são "infra do agente", não do produto. Manter local evita que o repo carregue infraestrutura específica de ferramenta de IA, e deixa cada dev livre pra atualizar a Promptaria no próprio ritmo. O que o time precisa concordar (processo, regras, formato de spec) está nos arquivos versionados acima.
>
> **Pra compartilhar aprendizado entre devs**, use a seção "Aprendizados do projeto" no `CLAUDE.md` (versionado). A skill `gerenciar-memoria` já te conduz a salvar lá quando o conhecimento é coletivo.

---

## Uso

Depois de instalado, cole uma demanda no chat. O agente reconhece o formato e dispara a skill apropriada:

- **Demanda já vem como spec estruturada** (História, Feature, Experimento, Contrato) → `implementar-demanda`: reconhecer formato → planejar → implementar → testar → gerar Guia de Validação → entregar bloco copy-paste pra abrir o PR
- **Demanda vem como texto vago** (bullets, descrição livre sem critérios) → `formular-spec`: construir a spec interativamente primeiro, depois implementar
- **Trabalho feito por terceiro precisa de roteiro de teste** → `validar-entrega`: lê o diff, infere o que foi feito e produz o Guia de Validação pra você colar

A Promptaria reconhece 4 formatos de spec (História de Usuário, Feature Spec, Experiment Plan, Contract Spec) com códigos próprios (REQ, RN, AC, RT, HIP, CS, CF, CL, GAR). A referência completa fica em `.claude/processos/specs.md` no projeto instalado, e o agente consulta sob demanda.

> **O agente nunca publica nada externo por iniciativa própria.** Não dá `git push`, não abre PR, não posta comentário. Ele prepara tudo prontinho pra copiar e colar e instrui passo a passo. Quem solicitou continua no controle de tudo que sai pra fora da máquina.

---

## Atualizar a Promptaria depois

**Basta rodar o `install.sh` de novo** (mesmo comando da instalação). O instalador é idempotente e seguro:

- Faz `cmp` arquivo-por-arquivo entre kit/ e o destino.
- O que está **idêntico** ao kit (caso comum: skills, `processos/specs.md`, `templates/guia-validacao.md` que ninguém mexeu) é sobrescrito direto, sem backup.
- O que está **diferente** (geralmente só `CLAUDE.md` e `regras-projeto.md`, customizados pelo time) é renomeado pra `.bak-{timestamp}` antes da cópia, pra você comparar e fundir manualmente.
- Memória pessoal (`.claude/memory/*`), skills custom suas, e specs locais (`.specs/*`) nunca aparecem como conflito (não existem no kit), então ficam intactas.

Update é **por dev**: cada um roda no próprio clone, já que skills são locais.

Pra arquivos versionados (`CLAUDE.md`, `processos/specs.md`, `templates/guia-validacao.md`, `regras-projeto.md`), quem mergear os .bak deveria fazer num PR pro time revisar, já que mexe com algo compartilhado.

---

## Desinstalação

```bash
rm -rf CLAUDE.md .claude/ .specs/ .promptaria
```

(Cuidado se já usar `.claude/` pra outras coisas. Remova só o que veio da Promptaria.)
