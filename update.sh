#!/bin/sh
set -eu
cd "$(dirname "$0")"

case "${1:-}" in
  --with-caddy|--without-caddy)
    [ "$#" -eq 1 ] || { echo "Uso: $0 [--with-caddy|--without-caddy]" >&2; exit 1; }
    mode=$1 ;;
  "")
    printf '1) Com Caddy\n2) Sem Caddy\nEscolha o modo em uso [1/2]: '
    read -r choice
    case "$choice" in
      1) mode=--with-caddy ;;
      2) mode=--without-caddy ;;
      *) echo "Opção inválida." >&2; exit 1 ;;
    esac ;;
  *) echo "Uso: $0 [--with-caddy|--without-caddy]" >&2; exit 1 ;;
esac

[ -f .env ] || { echo "Arquivo .env ausente. Configure e execute ./init.sh primeiro." >&2; exit 1; }

# Só recria os serviços depois que todas as imagens forem baixadas.
sh ./init.sh "$mode" config --quiet
printf 'Baixando imagens atualizadas...\n'
sh ./init.sh "$mode" pull
printf 'Aplicando atualização...\n'
sh ./init.sh "$mode" up -d --remove-orphans
sh ./init.sh "$mode" ps
printf 'Atualização aplicada. Confira o estado dos serviços acima e os logs.\n'
