#!/usr/bin/env bash
# Confere se o seu computador está pronto para o curso.
# Rode sempre que algo estranho acontecer: bash setup/verificar-ambiente.sh
set -uo pipefail

problemas=0
ok()   { printf '\033[1;32m ✔\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m ⚠\033[0m %s\n' "$*"; }
erro() { printf '\033[1;31m ✘\033[0m %s\n' "$*"; problemas=$((problemas + 1)); }

versao() { "$@" 2>/dev/null | head -1 | tr -d '\r'; }

echo "Ferramentas"
command -v git       >/dev/null && ok "git        $(versao git --version)"                 || erro "git não encontrado"
command -v code      >/dev/null && ok "VS Code    instalado"|| warn "comando 'code' não encontrado (o VS Code pode estar instalado, mas fora do PATH)"
command -v docker    >/dev/null && ok "docker     $(versao docker version --format '{{.Client.Version}}')" || erro "docker não encontrado"
command -v kubectl   >/dev/null && ok "kubectl    $(versao kubectl version --client | sed 's/Client Version: //')" || erro "kubectl não encontrado"
command -v kind      >/dev/null && ok "kind       $(versao kind version)"                   || erro "kind não encontrado"
command -v helm      >/dev/null && ok "helm       $(versao helm version --short)"           || erro "helm não encontrado"
command -v terraform >/dev/null && ok "terraform  $(versao terraform version)"              || erro "terraform não encontrado"
command -v node      >/dev/null && ok "node       $(versao node --version)"                 || warn "node não encontrado (opcional: só para rodar os testes localmente)"

echo
echo "Docker"
if docker info >/dev/null 2>&1; then
  mem_gb=$(( $(docker info --format '{{.MemTotal}}' 2>/dev/null || echo 0) / 1024 / 1024 / 1024 ))
  if [ "$mem_gb" -ge 6 ]; then
    ok "Docker rodando, com ~${mem_gb} GB de memória"
  else
    warn "Docker rodando, mas com só ~${mem_gb} GB de memória — o Módulo 6 (monitoramento) precisa de pelo menos 6 GB"
  fi
else
  erro "O Docker não está respondendo — abra o Docker Desktop e espere ele ficar pronto"
fi

echo
echo "Git"
nome="$(git config --global user.name || true)"
email="$(git config --global user.email || true)"
if [ -n "$nome" ] && [ -n "$email" ]; then
  ok "identidade: $nome <$email>"
else
  erro "configure sua identidade: git config --global user.name \"Seu Nome\" && git config --global user.email \"voce@exemplo.com\""
fi

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  if [ -n "$(git ls-files --eol 2>/dev/null | grep 'i/crlf')" ]; then
    erro "há arquivos com quebra de linha do Windows (CRLF) no repositório — veja a lição de setup"
  else
    ok "quebras de linha (LF) corretas"
  fi
fi

echo
if [ "$problemas" -eq 0 ]; then
  ok "Tudo certo! Seu ambiente está pronto para o curso."
else
  erro "$problemas problema(s) encontrado(s) — corrija e rode este script de novo."
  exit 1
fi
