#!/usr/bin/env python3
"""Validate the preview dashboard, runbook anchors, and screenshot PNGs."""
import json
import re
import sys
from pathlib import Path

root = Path(sys.argv[1])
data = json.loads((root / "dashboards" / "node-overview.json").read_text(encoding="utf-8"))
for key in ("uid", "title", "panels", "schemaVersion"):
    if not data.get(key):
        raise SystemExit(f"missing {key}")
if data["uid"] != "node-overview":
    raise SystemExit(f"unexpected uid {data['uid']}")
for panel in data["panels"]:
    if (panel.get("datasource") or {}).get("uid") != "prometheus":
        raise SystemExit(f"panel {panel.get('id')} datasource")
    if not panel.get("targets"):
        raise SystemExit(f"panel {panel.get('id')} has no targets")
print(f"node-overview panels={len(data['panels'])}")

runbook = (root / "docs" / "RUNBOOK.md").read_text(encoding="utf-8")
rules = (root / "rules" / "node.rules.yml").read_text(encoding="utf-8")
anchors = re.findall(r'runbook:\s*"docs/RUNBOOK.md#([^"]+)"', rules)
missing = [anchor for anchor in anchors if f'id="{anchor}"' not in runbook]
if missing or set(anchors) != {"NodeInstanceDown", "NodeHighMemory", "NodeDiskWillFill"}:
    print("anchors", anchors, "missing", missing)
    raise SystemExit(1)
print("anchors", " ".join(anchors))

pngs = sorted((root / "screenshots").glob("*.png"))
if len(pngs) < 2:
    raise SystemExit(f"need at least 2 pngs, found {len(pngs)}")
for path in pngs:
    blob = path.read_bytes()
    if blob[:8] != b"\x89PNG\r\n\x1a\n" or len(blob) < 1000:
        raise SystemExit(f"bad png {path.name}")
    print(path.name, len(blob))
