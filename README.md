# SearXNG

SearXNG + Valkey, com Caddy opcional. Requer Docker com Compose v2 e OpenSSL.

## Configuração

```sh
git clone https://github.com/ArcoverdePedro/SearXNG.git
cd SearXNG
cp .env.example .env
```

Edite `.env`. `SITE_URL` é o endereço público completo, incluindo protocolo:

| Uso | SITE_URL | Inicialização |
| --- | --- | --- |
| Caddy em HTTP local | `http://localhost` | `./init.sh --with-caddy` |
| Caddy em HTTP na rede | `http://busca.lan` | `./init.sh --with-caddy` |
| Caddy com HTTPS | `https://busca.exemplo.com` | `./init.sh --with-caddy` |
| HTTP direto | `http://localhost:8080` | `./init.sh --without-caddy` |
| Proxy externo com HTTPS | `https://busca.exemplo.com` | `./init.sh --without-caddy` |

Use apenas a origem (sem caminho, consulta ou fragmento). No modo Caddy, use as portas padrão 80/443. HTTPS público exige domínio apontando para o servidor e portas 80/443 acessíveis; o Caddy emite e renova o certificado. HTTP explícito não solicita certificado.

Sem argumentos, `./init.sh` mostra as duas opções. O script pode ser chamado de qualquer diretório, cria `.env` se necessário e gera a chave secreta uma única vez. Não altera `/etc/hosts` nem exige execução como root, desde que seu usuário tenha acesso ao Docker.

Para domínio local, configure DNS ou `/etc/hosts` nos dispositivos que acessarão o site. Para HTTP direto pela rede, defina `BIND_ADDRESS=0.0.0.0` e ajuste `SITE_URL` para o IP/domínio do servidor e a porta configurada em `SEARXNG_PORT`.

## Proxy próprio

Sem Caddy, a porta padrão fica em `127.0.0.1:8080`. Um Nginx ou Caddy no host pode encaminhar para `http://127.0.0.1:8080`. Defina `SITE_URL` com a URL externa, mesmo quando o backend usar HTTP.

Para um proxy em outro container, conecte-o à rede padrão deste projeto e encaminhe para `searxng:8080`. Nesse cenário também é possível usar somente `compose.yml`, sem publicar porta:

```sh
# Execute o init uma vez para preparar .env e a chave antes do uso manual.
docker compose -f compose.yml up -d
```

Preserve o Host e encaminhe os cabeçalhos de protocolo e IP do cliente. Ajuste `trusted_proxies` em `searxng/limiter.toml` para os IPs/sub-redes dos seus proxies confiáveis, inclusive do Caddy em Docker, para o limitador reconhecer os clientes corretamente.

## Operação

O mesmo init aceita comandos do Compose:

```sh
./init.sh --with-caddy logs -f
./init.sh --with-caddy down
./init.sh --without-caddy pull
./init.sh --without-caddy
```

Para trocar de modo, pare o anterior com `down` (sem `-v`) e inicie o novo. Ajuste `SITE_URL` ao trocar. Os volumes mantêm os dados; não use `down -v` para uma troca normal.

## Atualizar containers

```sh
./update.sh --with-caddy
# ou, se usa acesso direto/proxy próprio:
./update.sh --without-caddy
```

Sem argumentos, o script pergunta qual modo está em uso. Ele valida o Compose, baixa as imagens e executa `up -d` para recriar os serviços que mudaram, preservando `.env`, configurações e volumes. Se o download falhar, não inicia a recriação. Não executa `down`, `git pull` nem limpeza de imagens. Escolha o mesmo modo usado na inicialização; este comando não serve para trocar de modo. Pode haver uma breve interrupção durante a recriação.

Ao terminar, mostra o estado dos containers. Para conferir os logs, use `./init.sh --with-caddy logs -f` (ou `--without-caddy`). Tags/digests fixos só serão atualizados após editar a versão no Compose.

## Organização

- `compose.yml`: SearXNG e Valkey, sem portas publicadas.
- `compose.direct.yml`: publica a porta HTTP do SearXNG.
- `compose.caddy.yml` e `Caddyfile`: proxy opcional.
- `.env`: URL, porta, endereço de escuta e chave local (não versionado).
- `searxng/settings.yml`: personalizações sobre os padrões oficiais; mantém pt-BR, busca segura e tema escuro.
- `valkey/valkey.conf`: cache interno, sem senha fixa e sem exposição no host.

A antiga cópia integral das configurações foi substituída por `use_default_settings`: a lista de motores e demais padrões passam a acompanhar a imagem instalada. Personalize motores em `searxng/settings.yml` se precisar fixar escolhas. As imagens continuam usando tags móveis; para versões reproduzíveis, fixe tags ou digests nos arquivos Compose.

## Instalações existentes

Faça backup de `.env`, `searxng/` e volumes antes da atualização. O init antigo criava entradas de `searxng.lan` em `/etc/hosts`; remova-as manualmente se não forem mais usadas. Os nomes explícitos de containers foram removidos: se vier da configuração antiga, pare o Compose antigo antes de atualizar. A nova chave invalida sessões antigas. O Valkey permanece na rede interna e seu volume existente é preservado quando o nome do projeto Compose permanece igual.
