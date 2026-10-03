#!/usr/bin/env bash
# Instala as ferramentas do curso "DevOps do Zero ao Deploy".
#   Windows (Git Bash) → winget
#   macOS              → Homebrew
#   Linux              → downloads oficiais
# Ferramentas já instaladas são mantidas. Rode de novo quando quiser.
set -euo pipefail

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
ok()   { printf '\033[1;32m ✔\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m ⚠\033[0m %s\n' "$*"; }
fail() { printf '\033[1;31m ✘ %s\033[0m\n' "$*" >&2; exit 1; }

tem() { command -v "$1" >/dev/null 2>&1; }

instalar_windows() {
  tem winget.exe || fail "winget não encontrado. Atualize o 'Instalador de Aplicativo' pela Microsoft Store e tente de novo."

  # comando que deve existir depois  |  id do pacote no winget
  local pacotes=(
    "code|Microsoft.VisualStudioCode"
    "kubectl|Kubernetes.kubectl"
    "kind|Kubernetes.kind"
    "helm|Helm.Helm"
    "terraform|Hashicorp.Terraform"
    "node|OpenJS.NodeJS.LTS"
    "docker|Docker.DockerDesktop"
  )
  local instalou=false
  for item in "${pacotes[@]}"; do
    local cmd="${item%%|*}" id="${item##*|}"
    if tem "$cmd"; then
      ok "$cmd já instalado"
    else
      info "Instalando $id"
      winget.exe install --id "$id" --exact --silent \
        --accept-package-agreements --accept-source-agreements --disable-interactivity
      instalou=true
    fi
  done

  if [ "$instalou" = true ]; then
    echo
    warn "Feche TODOS os terminais e abra o Git Bash de novo para o Windows atualizar o PATH."
    warn "Se o Docker Desktop foi instalado agora: reinicie o computador e abra o Docker Desktop uma vez."
  fi
}

instalar_macos() {
  tem brew || fail "Homebrew não encontrado. Instale em https://brew.sh e rode de novo."
  brew install kubectl kind helm hashicorp/tap/terraform node@24
  tem docker || brew install --cask docker
  tem code   || brew install --cask visual-studio-code
}

instalar_linux() {
  local arch
  case "$(uname -m)" in
    x86_64) arch=amd64 ;; aarch64|arm64) arch=arm64 ;;
    *) fail "Arquitetura não suportada: $(uname -m)" ;;
  esac
  tem curl  || fail "Instale o curl: sudo apt install -y curl"
  tem unzip || fail "Instale o unzip: sudo apt install -y unzip"
  local tmp; tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' RETURN

  if ! tem kubectl; then
    info "Instalando kubectl"
    curl -fsSLo "$tmp/kubectl" "https://dl.k8s.io/release/$(curl -fsSL https://dl.k8s.io/release/stable.txt)/bin/linux/$arch/kubectl"
    sudo install -m 0755 "$tmp/kubectl" /usr/local/bin/kubectl
  fi
  if ! tem kind; then
    info "Instalando kind"
    curl -fsSLo "$tmp/kind" "https://github.com/kubernetes-sigs/kind/releases/latest/download/kind-linux-$arch"
    sudo install -m 0755 "$tmp/kind" /usr/local/bin/kind
  fi
  if ! tem helm; then
    info "Instalando helm"
    curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-4 | bash
  fi
  if ! tem terraform; then
    info "Instalando terraform"
    local versao
    versao="$(curl -fsSL https://checkpoint-api.hashicorp.com/v1/check/terraform | sed -E 's/.*"current_version":"([^"]+)".*/\1/')"
    curl -fsSLo "$tmp/tf.zip" "https://releases.hashicorp.com/terraform/${versao}/terraform_${versao}_linux_${arch}.zip"
    unzip -q "$tmp/tf.zip" -d "$tmp" && sudo install -m 0755 "$tmp/terraform" /usr/local/bin/terraform
  fi
  tem node   || warn "Node.js não encontrado (opcional, para rodar os testes localmente): https://nodejs.org"
  tem docker || warn "Docker não encontrado: https://docs.docker.com/engine/install/"
}

case "$(uname -s)" in
  MINGW*|MSYS*|CYGWIN*) instalar_windows ;;
  Darwin)               instalar_macos ;;
  Linux)                instalar_linux ;;
  *)                    fail "Sistema não suportado: $(uname -s)" ;;
esac

echo
ok "Pronto. Próximo passo: bash setup/verificar-ambiente.sh"
