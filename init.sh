#!/bin/sh
set -eu
cd "$(dirname "$0")"

case "${1:-}" in
  --with-caddy|--without-caddy) mode=$1 ;;
  "")
    printf '1) Com Caddy\n2) Sem Caddy\nEscolha [1/2]: '
    read -r choice
    case "$choice" in
      1) mode=--with-caddy ;;
      2) mode=--without-caddy ;;
      *) echo "Opção inválida." >&2; exit 1 ;;
    esac ;;
  *) echo "Uso: $0 [--with-caddy|--without-caddy] [comando do Compose...]" >&2; exit 1 ;;
esac
if [ "$#" -gt 0 ]; then shift; fi
command -v docker >/dev/null 2>&1 || { echo "Instale Docker com Compose v2." >&2; exit 1; }
docker compose version >/dev/null

if [ ! -f .env ]; then
  (umask 077; cp .env.example .env)
  echo "Criado .env. Ajuste SITE_URL conforme seu endereço."
fi
# O .env é lido pelo Compose; nunca é executado como script shell.
if ! grep -Eq '^SEARXNG_SECRET=.+$' .env; then
  command -v openssl >/dev/null 2>&1 || { echo "Instale openssl para gerar a chave." >&2; exit 1; }
  secret=$(openssl rand -hex 32)
  sed '/^SEARXNG_SECRET=/d' .env > .env.tmp
  printf '\nSEARXNG_SECRET=%s\n' "$secret" >> .env.tmp
  chmod 600 .env.tmp
  mv .env.tmp .env
fi

case "$mode" in
  --with-caddy) override=compose.caddy.yml ;;
  --without-caddy) override=compose.direct.yml ;;
esac
if [ "$#" -eq 0 ]; then set -- up -d --remove-orphans; fi
exec docker compose --env-file .env -f compose.yml -f "$override" "$@"
