#!/usr/bin/env bash
# One-click local preview. Login is the local demo pair only.
set -euo pipefail
cd "$(dirname "$0")"
docker compose -f demo/docker-compose.yml up -d
cat <<'EOF'
Prometheus  http://127.0.0.1:9090
Grafana     http://127.0.0.1:3000
Demo login  admin / admin  (local demo only)

Stop and remove volumes: docker compose -f demo/docker-compose.yml down -v
EOF
