#!/bin/bash
set -e

docker compose -f compose.yml -f compose.prod.yml build
docker compose -f compose.yml -f compose.prod.yml run --rm node
docker compose -f compose.yml -f compose.prod.yml up -d --scale node=0