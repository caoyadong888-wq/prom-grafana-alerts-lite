#!/usr/bin/env bash
# Smaller checks for the preview: promtool, dashboard JSON, demo, rules API, Grafana search.
set -u

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

PROM_IMAGE="prom/prometheus:v2.55.1"
GRAFANA_IMAGE="grafana/grafana:11.4.0"
COMPOSE_FILE="$ROOT/demo/docker-compose.yml"

OUT="$(mktemp -d)"
LOG="$OUT/details.log"
SUMMARY="$OUT/summary.txt"
VERSIONS="$OUT/versions.txt"
FAIL=0
DATE="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
: >"$LOG"
: >"$SUMMARY"
: >"$VERSIONS"

write_results() {
  {
    echo "# Test results"
    echo
    echo "Date: $DATE"
    echo
    echo "## Summary"
    echo
    cat "$SUMMARY" 2>/dev/null || true
    echo
    echo "## Tool versions"
    echo
    cat "$VERSIONS" 2>/dev/null || true
    echo
    echo "## Output"
    echo
    echo '```'
    cat "$LOG" 2>/dev/null || true
    echo '```'
  } >"$ROOT/tests/RESULTS.md"
}

cleanup() {
  docker compose -f "$COMPOSE_FILE" down -v --remove-orphans >>"$LOG" 2>&1 || true
  write_results
  rm -rf "$OUT"
}
trap cleanup EXIT

record() {
  local status="$1"
  local name="$2"
  echo "$status: $name" | tee -a "$SUMMARY"
  if [ "$status" = "FAIL" ]; then
    FAIL=1
  fi
}

run_check() {
  local name="$1"
  shift
  echo "### $name" >>"$LOG"
  if "$@" >"$OUT/one.txt" 2>&1; then
    record PASS "$name"
  else
    record FAIL "$name"
  fi
  cat "$OUT/one.txt" >>"$LOG"
  echo >>"$LOG"
}

promtool() {
  docker run --rm --entrypoint promtool -v "$ROOT:/work" -w /work "$PROM_IMAGE" "$@"
}

{
  echo "date: $DATE"
  echo "docker: $(docker version --format '{{.Server.Version}}' 2>/dev/null || echo missing)"
  echo "promtool:"
  docker run --rm --entrypoint promtool "$PROM_IMAGE" --version 2>&1 || true
  echo "grafana:"
  docker run --rm --entrypoint grafana "$GRAFANA_IMAGE" --version 2>&1 || true
  echo "python: $(python3 --version 2>&1)"
} >"$VERSIONS"

run_check "promtool check rules" promtool check rules rules/node.rules.yml
run_check "promtool test rules" promtool test rules rules/tests/node.test.yml
run_check "promtool check config" promtool check config prometheus.yml

run_check "validate dashboard JSON, runbook anchors, screenshots" python3 "$ROOT/tests/check_static.py" "$ROOT"

docker compose -f "$COMPOSE_FILE" down -v --remove-orphans >>"$LOG" 2>&1 || true

echo "### demo compose up" >>"$LOG"
if docker compose -f "$COMPOSE_FILE" up -d >"$OUT/one.txt" 2>&1; then
  record PASS "demo compose up"
else
  record FAIL "demo compose up"
fi
cat "$OUT/one.txt" >>"$LOG"
echo >>"$LOG"

wait_http() {
  local url="$1"
  local tries="$2"
  local i
  for i in $(seq 1 "$tries"); do
    if curl -sf --max-time 3 "$url" >/dev/null 2>&1; then
      return 0
    fi
    sleep 2
  done
  return 1
}

echo "### prometheus ready" >>"$LOG"
if wait_http "http://127.0.0.1:9090/-/ready" 40; then
  record PASS "prometheus ready"
else
  record FAIL "prometheus ready"
  docker compose -f "$COMPOSE_FILE" logs --no-color --tail 80 >>"$LOG" 2>&1 || true
fi

echo "### grafana ready" >>"$LOG"
if wait_http "http://127.0.0.1:3000/api/health" 50; then
  record PASS "grafana ready"
else
  record FAIL "grafana ready"
  docker compose -f "$COMPOSE_FILE" logs --no-color --tail 80 >>"$LOG" 2>&1 || true
fi

touch "$OUT/rules.txt" "$OUT/search.txt"

echo "### rules loaded via /api/v1/rules" >>"$LOG"
rules_ok=0
for _ in $(seq 1 15); do
  if curl -sf --max-time 5 "http://127.0.0.1:9090/api/v1/rules" -o "$OUT/rules.json"; then
    if python3 - "$OUT/rules.json" >"$OUT/rules.txt" <<'PY'
import json
import sys

data = json.load(open(sys.argv[1], encoding="utf-8"))
required = {"NodeInstanceDown", "NodeHighMemory", "NodeDiskWillFill"}
forbidden = {"NodeHighCpu", "ContainerOOM", "BlackboxProbeFailed", "NginxExporterDown", "PostgresExporterDown"}
found = set()
print("group\trule\thealth\tstate")
for group in data.get("data", {}).get("groups", []):
    for rule in group.get("rules", []):
        found.add(rule.get("name"))
        print(f"{group.get('name')}\t{rule.get('name')}\t{rule.get('health')}\t{rule.get('state')}")
missing = sorted(required - found)
extra = sorted(forbidden & found)
if missing or extra:
    print("MISSING", " ".join(missing))
    print("EXTRA", " ".join(extra))
    raise SystemExit(1)
print("loaded", " ".join(sorted(found)))
PY
    then
      rules_ok=1
      break
    fi
  fi
  sleep 2
done
if [ "$rules_ok" -eq 1 ]; then
  record PASS "rules loaded via /api/v1/rules"
else
  record FAIL "rules loaded via /api/v1/rules"
fi
cat "$OUT/rules.txt" >>"$LOG" 2>/dev/null || true
echo >>"$LOG"

echo "### grafana /api/search" >>"$LOG"
search_ok=0
for _ in $(seq 1 20); do
  if curl -sf --max-time 5 -u admin:admin "http://127.0.0.1:3000/api/search?type=dash-db" -o "$OUT/search.json"; then
    if python3 - "$OUT/search.json" >"$OUT/search.txt" <<'PY'
import json
import sys

items = json.load(open(sys.argv[1], encoding="utf-8"))
found = {item.get("uid") for item in items}
print("type\tuid\ttitle\tfolder")
for item in items:
    print(f"{item.get('type')}\t{item.get('uid')}\t{item.get('title')}\t{item.get('folderTitle')}")
if "node-overview" not in found:
    print("MISSING node-overview")
    raise SystemExit(1)
extra = sorted(found & {"containers", "blackbox-ssl"})
if extra:
    print("EXTRA", " ".join(extra))
    raise SystemExit(1)
print("dashboards", len(items))
PY
    then
      search_ok=1
      break
    fi
  fi
  sleep 2
done
if [ "$search_ok" -eq 1 ]; then
  record PASS "grafana /api/search dashboards"
else
  record FAIL "grafana /api/search dashboards"
fi
cat "$OUT/search.txt" >>"$LOG" 2>/dev/null || true
echo >>"$LOG"

echo "### demo compose down -v" >>"$LOG"
if docker compose -f "$COMPOSE_FILE" down -v --remove-orphans >"$OUT/one.txt" 2>&1; then
  record PASS "demo compose down -v"
else
  record FAIL "demo compose down -v"
fi
cat "$OUT/one.txt" >>"$LOG"
echo >>"$LOG"

if [ "$FAIL" -eq 0 ]; then
  echo "ALL PASS"
else
  echo "SOME FAILED"
fi
exit "$FAIL"
