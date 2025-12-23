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
