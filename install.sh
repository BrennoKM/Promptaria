#!/usr/bin/env bash
#
# Promptaria: instalador
#
# Dois modos:
#
#   1) Remoto (não precisa clonar o repo da Promptaria):
#      A partir da raiz do projeto onde quer instalar, rode:
#        curl -fsSL https://raw.githubusercontent.com/BrennoKM/Promptaria/main/install.sh | bash
#
#   2) Local (a partir de um clone do repo da Promptaria):
#      git clone https://github.com/BrennoKM/Promptaria.git
#      cd /caminho/pro/meu-projeto/
#      bash /caminho/pra/Promptaria/install.sh
#
# Em ambos os modos, copia o conteúdo de kit/ pra raiz do diretório atual
# e cria o marcador .promptaria pra sinalizar que a configuração interativa
# (preencher stack, como rodar, etc.) ainda não foi feita.

set -e

REPO_URL="https://github.com/BrennoKM/Promptaria"
REPO_BRANCH="main"
REPO_TARBALL="$REPO_URL/archive/refs/heads/$REPO_BRANCH.tar.gz"

TARGET_DIR="$(pwd)"

# Detecta modo: local (kit/ adjacente ao script) ou remoto (precisa baixar)
SCRIPT_PATH="${BASH_SOURCE[0]:-$0}"
if [ -f "$SCRIPT_PATH" ]; then
  SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" 2>/dev/null && pwd)"
else
  SCRIPT_DIR=""
fi

if [ -n "$SCRIPT_DIR" ] && [ -d "$SCRIPT_DIR/kit" ]; then
  MODE="local"
  KIT_DIR="$SCRIPT_DIR/kit"
  ORIGEM="$SCRIPT_DIR"
else
  MODE="remoto"

  # Checa dependências
  for cmd in curl tar; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
      echo "ERRO: '$cmd' não encontrado. Instale ou use o modo local (clone + bash install.sh)."
      exit 1
    fi
  done

  TEMP=$(mktemp -d)
  trap 'rm -rf "$TEMP"' EXIT

  echo "Baixando Promptaria ($REPO_BRANCH) de $REPO_URL ..."
  if ! curl -fsSL "$REPO_TARBALL" | tar -xz -C "$TEMP"; then
    echo "ERRO: falha ao baixar/extrair Promptaria. Confira sua conexão ou tente o modo local."
    exit 1
  fi

  KIT_DIR="$TEMP/Promptaria-$REPO_BRANCH/kit"
  ORIGEM="$REPO_URL ($REPO_BRANCH, baixado via curl)"

  if [ ! -d "$KIT_DIR" ]; then
    echo "ERRO: pasta 'kit/' não encontrada no tarball. Estrutura do repo mudou?"
    exit 1
  fi
fi

# Não rodar dentro do próprio repo da Promptaria (caso modo local)
if [ "$MODE" = "local" ] && [ "$TARGET_DIR" = "$SCRIPT_DIR" ]; then
  echo "ERRO: não rode install.sh dentro do próprio repositório da Promptaria."
  echo "Vá pra raiz do projeto onde quer instalar e rode de lá."
  exit 1
fi

# Detecta arquivos conflitantes (file-level, recursivamente em kit/).
# Só conta como conflito se o arquivo do destino DIFERE do que o kit traz.
# Arquivos idênticos seriam sobrescritos por cópia idêntica, então não precisam de backup.
CONFLICT_FILES=()
while IFS= read -r -d '' src; do
  rel="${src#$KIT_DIR/}"
  dst="$TARGET_DIR/$rel"
  if [ -f "$dst" ] && ! cmp -s "$src" "$dst"; then
    CONFLICT_FILES+=("$rel")
  fi
done < <(find "$KIT_DIR" -type f -print0)

TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BACKUPS=()

if [ ${#CONFLICT_FILES[@]} -gt 0 ]; then
  echo "Os seguintes arquivos do projeto serão preservados como backup antes da instalação:"
  for f in "${CONFLICT_FILES[@]}"; do
    echo "  - $f → $f.bak-$TIMESTAMP"
  done
  echo ""

  # Default é S (seguro: tem backup). Tenta abrir TTY; se não der, prossegue.
  resp="s"
  if { exec 3</dev/tty; } 2>/dev/null; then
    read -r -p "Continuar? [S/n] " resp <&3
    exec 3<&-
    resp="${resp:-s}"
  fi
  if [[ ! "$resp" =~ ^[SsYy]$ ]]; then
    echo "Cancelado."
    exit 0
  fi

  echo "Criando backups..."
  for f in "${CONFLICT_FILES[@]}"; do
    mv "$TARGET_DIR/$f" "$TARGET_DIR/$f.bak-$TIMESTAMP"
    BACKUPS+=("$f.bak-$TIMESTAMP")
  done
fi

echo "Copiando kit/ → $TARGET_DIR ..."
cp -r "$KIT_DIR/." "$TARGET_DIR/"

# Injeta entradas no .gitignore raiz do projeto destino
# para garantir que .specs/ e .promptaria não sejam versionados.
ROOT_GITIGNORE="$TARGET_DIR/.gitignore"

inject_gitignore_block() {
  local file="$1"
  local marker="$2"
  local block="$3"
  # Só injeta se o marcador ainda não existir no arquivo
  if ! grep -qF "$marker" "$file" 2>/dev/null; then
    printf '\n%s\n' "$block" >> "$file"
    echo "  ↳ entradas Promptaria adicionadas em $(basename "$file")"
  fi
}

SPECS_BLOCK="# Promptaria: specs locais — apenas .gitignore e README.md são versionados
.specs/*
!.specs/.gitignore
!.specs/README.md"

PROMPTARIA_BLOCK="# Promptaria: marcador de configuração pendente (local, não versionar)
.promptaria"

inject_gitignore_block "$ROOT_GITIGNORE" "Promptaria: specs locais" "$SPECS_BLOCK"
inject_gitignore_block "$ROOT_GITIGNORE" "Promptaria: marcador de configuração" "$PROMPTARIA_BLOCK"

cat > "$TARGET_DIR/.promptaria" <<EOF
# Marcador de configuração inicial da Promptaria

Este arquivo indica que a Promptaria foi instalada mas a configuração interativa
(preencher stack, como rodar, como testar, etc. no CLAUDE.md) ainda não foi feita.

Na primeira vez que o Claude Code for aberto neste repositório, o agente deve:

1. Ler o CLAUDE.md e detectar placeholders {{...}} ainda preenchidos
2. Disparar a skill .claude/skills/configurar-projeto/SKILL.md
3. Conduzir a configuração interativa
4. Apagar este arquivo (.promptaria) ao final

Instalado em: $(date -Iseconds)
Origem: $ORIGEM
Modo de instalação: $MODE
EOF

echo ""
echo "✓ Promptaria instalada em $TARGET_DIR (modo $MODE)"
echo ""

if [ ${#BACKUPS[@]} -gt 0 ]; then
  echo "Backups dos arquivos anteriores do projeto (NÃO foram apagados):"
  for b in "${BACKUPS[@]}"; do
    echo "  - $b"
  done
  echo ""
  echo "Esses .bak guardam o que estava no projeto antes da instalação."
  echo "Quando você abrir o Claude Code (próximo passo), o agente detecta os .bak"
  echo "e conduz a fusão com os arquivos novos durante a configuração."
  echo ""
fi

echo "Próximo passo:"
echo "  1. Abra o Claude Code neste diretório (\`claude\`)"
echo "  2. Diga: \"configurar projeto\" e o agente vai te guiar"
echo ""
echo "Atenção: .claude/skills/ e .claude/memory/ são LOCAIS (não vão pro git)."
echo "Outros devs do time precisam rodar este install.sh por conta também."
echo ""
