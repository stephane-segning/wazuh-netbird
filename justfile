set shell := ["bash", "-cu"]

compose := "docker compose -f compose.yml"

default:
  @just --list

certs:
  docker compose -f generate-indexer-certs.yml run --rm generator

up: certs
  {{compose}} up -d

down:
  {{compose}} down

logs:
  {{compose}} logs -f --tail=200

ps:
  {{compose}} ps

test-routing:
  set -euo pipefail
  {{compose}} exec -T ubuntu-agent-wazuh-net bash -lc 'for p in 1514 1515 55000; do timeout 3 bash -lc "</dev/tcp/$WAZUH_MANAGER/$p" >/dev/null && echo "ok ubuntu-agent-wazuh-net:$p"; done'
  {{compose}} exec -T ubuntu-agent-nb1 bash -lc 'for p in 1514 1515 55000; do timeout 3 bash -lc "</dev/tcp/$WAZUH_MANAGER/$p" >/dev/null && echo "ok ubuntu-agent-nb1:$p"; done'
  {{compose}} exec -T ubuntu-agent-nb2 bash -lc 'for p in 1514 1515 55000; do timeout 3 bash -lc "</dev/tcp/$WAZUH_MANAGER/$p" >/dev/null && echo "ok ubuntu-agent-nb2:$p"; done'
  {{compose}} exec -T ubuntu-agent-nb3 bash -lc 'for p in 1514 1515 55000; do timeout 3 bash -lc "</dev/tcp/$WAZUH_MANAGER/$p" >/dev/null && echo "ok ubuntu-agent-nb3:$p"; done'
