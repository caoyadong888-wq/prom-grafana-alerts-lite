# Test results

Date: 2026-10-20T04:04:45Z

## Summary

PASS: promtool check rules
PASS: promtool test rules
PASS: promtool check config
PASS: validate dashboard JSON, runbook anchors, screenshots
PASS: demo compose up
PASS: prometheus ready
PASS: grafana ready
PASS: rules loaded via /api/v1/rules
PASS: grafana /api/search dashboards
PASS: demo compose down -v

## Tool versions

date: 2026-10-20T04:04:45Z
docker: 26.1.5+dfsg1
promtool:
promtool, version 2.55.1 (branch: HEAD, revision: 6d7569113f1ca814f1e149f74176656540043b8d)
  build user:       root@194e0f5dd5e8
  build date:       20241106-10:08:33
  go version:       go1.23.2
  platform:         linux/amd64
  tags:             netgo,builtinassets,stringlabels
grafana:
grafana version 11.4.0
python: Python 3.13.5

## Output

```
### promtool check rules
Checking rules/node.rules.yml
  SUCCESS: 3 rules found


### promtool test rules
  SUCCESS


### promtool check config
Checking prometheus.yml
  SUCCESS: 1 rule files found
 SUCCESS: prometheus.yml is valid prometheus config file syntax

Checking rules/node.rules.yml
  SUCCESS: 3 rules found


### validate dashboard JSON, runbook anchors, screenshots
node-overview panels=10
anchors NodeInstanceDown NodeHighMemory NodeDiskWillFill
grafana-blackbox.png 80942
grafana-node-overview.png 81761
grafana-search.png 28561
promtool-tests.png 13003
rules-api.png 76105

 Volume pga-lite_promdata  Removing
 Volume pga-lite_promdata  Removed
### demo compose up
 Volume "pga-lite_promdata"  Creating
 Volume "pga-lite_promdata"  Created
 Container pga-lite-node-exporter-1  Creating
 Container pga-lite-node-exporter-1  Created
 Container pga-lite-prometheus-1  Creating
 Container pga-lite-prometheus-1  Created
 Container pga-lite-grafana-1  Creating
 Container pga-lite-grafana-1  Created
 Container pga-lite-node-exporter-1  Starting
 Container pga-lite-node-exporter-1  Started
 Container pga-lite-prometheus-1  Starting
 Container pga-lite-prometheus-1  Started
 Container pga-lite-grafana-1  Starting
 Container pga-lite-grafana-1  Started

### prometheus ready
### grafana ready
### rules loaded via /api/v1/rules
group	rule	health	state
node.rules	NodeInstanceDown	unknown	inactive
node.rules	NodeHighMemory	unknown	inactive
node.rules	NodeDiskWillFill	unknown	inactive
loaded NodeDiskWillFill NodeHighMemory NodeInstanceDown

### grafana /api/search
type	uid	title	folder
dash-db	node-overview	Node overview	Observability
dashboards 1

### demo compose down -v
 Container pga-lite-grafana-1  Stopping
 Container pga-lite-grafana-1  Stopped
 Container pga-lite-grafana-1  Removing
 Container pga-lite-grafana-1  Removed
 Container pga-lite-prometheus-1  Stopping
 Container pga-lite-prometheus-1  Stopped
 Container pga-lite-prometheus-1  Removing
 Container pga-lite-prometheus-1  Removed
 Container pga-lite-node-exporter-1  Stopping
 Container pga-lite-node-exporter-1  Stopped
 Container pga-lite-node-exporter-1  Removing
 Container pga-lite-node-exporter-1  Removed
 Volume pga-lite_promdata  Removing
 Volume pga-lite_promdata  Removed

 Volume pga-lite_promdata  Removing
 Volume pga-lite_promdata  Removed
```
