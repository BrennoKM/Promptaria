#!/usr/bin/env bash
#
# Promptaria — instalador
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

# Avisa se algum item-chave já existe no destino
CONFLICTS=()
for f in CLAUDE.md .claude .specs; do
  if [ -e "$TARGET_DIR/$f" ]; then
    CONFLICTS+=("$f")
  fi
done

if [ ${#CONFLICTS[@]} -gt 0 ]; then
  echo "Os seguintes itens já existem no destino e serão sobrescritos/mesclados:"
  for c in "${CONFLICTS[@]}"; do
    echo "  - $c"
  done
  # Lê do terminal mesmo quando o script vem via pipe (curl | bash)
  if [ -t 0 ] || [ -e /dev/tty ]; then
    read -r -p "Continuar? [s/N] " resp < /dev/tty
  else
    resp="n"
  fi
  if [[ ! "$resp" =~ ^[Ss]$ ]]; then
    echo "Cancelado."
    exit 0
  fi
fi

echo "Copiando kit/ → $TARGET_DIR ..."
cp -r "$KIT_DIR/." "$TARGET_DIR/"

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
echo "Próximo passo:"
echo "  1. Abra o Claude Code neste diretório (\`claude\`)"
echo "  2. Diga: \"configurar projeto\" — o agente vai te guiar"
echo ""
