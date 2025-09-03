#!/bin/sh

# Define as entradas
HOSTS_ENTRY_IPV4="127.0.0.1 pedro.local"
HOSTS_ENTRY_IPV6="::1 pedro.local"
HOSTS_FILE="/etc/hosts"

# Verifica se o script está sendo executado como root
if [ "$(id -u)" -ne 0 ]; then
  echo "Este script precisa ser executado como root (com sudo)."
  exit 1
fi

echo "Configurando o arquivo $HOSTS_FILE..."

# Adiciona a entrada IPv4 se não existir.
# O `grep -q` suprime a saída, e o `||` executa o segundo comando
# se o primeiro falhar (ou seja, se a entrada não for encontrada).
grep -q "$HOSTS_ENTRY_IPV4" "$HOSTS_FILE" || echo "$HOSTS_ENTRY_IPV4" >> "$HOSTS_FILE"
echo "Entrada IPv4 para pedro.local garantida."

# Adiciona a entrada IPv6 se não existir.
grep -q "$HOSTS_ENTRY_IPV6" "$HOSTS_FILE" || echo "$HOSTS_ENTRY_IPV6" >> "$HOSTS_FILE"
echo "Entrada IPv6 para pedro.local garantida."

echo "Configuração do arquivo de hosts concluída."

### Inicializando o Docker Compose

echo ""
echo "Inicializando o Docker Compose..."
# Usa 'sudo -E' para manter as variáveis de ambiente necessárias para o Docker
sudo -E docker-compose up -d

echo "Script concluído."