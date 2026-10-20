# Prometheus + Grafana Alert Rules (preview)

A free preview of the Prometheus + Grafana Alert Rules & Dashboards Pack. This subset has three node alerts, the Node overview dashboard, a promtool unit test, and a local demo.

Alerts in this preview:

| Alert | Severity | What it watches |
| --- | --- | --- |
| NodeInstanceDown | critical | `up{job="node"} == 0` for 2 minutes |
| NodeDiskWillFill | warning | `predict_linear` says the filesystem hits zero within 24 hours, and free space is already under 20% |
| NodeHighMemory | warning | memory use above 90% for 5 minutes |

Each alert has a `severity` label and `summary`, `description`, and `runbook` annotations. Checks are in [docs/RUNBOOK.md](docs/RUNBOOK.md).

## Quick start

1. Install Docker Engine and the Docker Compose v2 plugin.
2. From this directory:

```bash
make demo
```

The same command is `./demo.sh`.

3. Open Prometheus at <http://127.0.0.1:9090> and Grafana at <http://127.0.0.1:3000>.
4. The demo login is `admin` / `admin`. It is for this local demo only. Change it before you expose port 3000.
5. Stop it and delete the volume:

```bash
make demo-down
```

The node target is relabelled to `demo-host:9100`. Rules expect `job="node"`.

## Deliverables / 交付物清单

- `rules/node.rules.yml` with NodeInstanceDown, NodeDiskWillFill, and NodeHighMemory
- `rules/tests/node.test.yml`
- `dashboards/node-overview.json` and Grafana provisioning
- `demo/docker-compose.yml` (Prometheus, node_exporter, Grafana)
- `docs/RUNBOOK.md` for those three alerts
- `tests/run_tests.sh`
- `LICENSE` (MIT)

## Estimated setup time / 预计部署时间

About 15 minutes the first time, most of it the image download. About 5 minutes when the images are already local.

## 预计交付时间 / Estimated delivery time

Download is instant after payment. Setup on your own machine is about 15 minutes the first time, most of it the image download, and about 5 minutes when the images are already local. A custom setup service, if you order one, takes 1–2 business days.

付款后立即下载。自行部署第一次大约 15 分钟，主要花在拉镜像；镜像已在本地时大约 5 分钟。如果需要代为部署，定制服务为 1–2 个工作日。

## Requirements

- Docker Engine 20.10 or newer and Docker Compose v2
- Free TCP ports 3000, 9090, and 9100. The demo uses host networking.
- Or, without the demo: Prometheus 2.40 or newer and Grafana 10 or newer

```bash
bash tests/run_tests.sh
```

The script prints `PASS` or `FAIL` per check, writes `tests/RESULTS.md`, and removes the demo containers and volume.

## License

MIT. See [LICENSE](LICENSE).

## Full version / 完整版

The full pack is at GUMROAD_URL.

Related: the [$9 n8n DevOps Automation Pack](https://caoyadong.gumroad.com/l/yvmcqj).

These items are only in the full version:

- `NodeHighCpu`, `NodeInodeLow`, and `NodeLoadHigh` in `rules/node.rules.yml`
- `rules/container.rules.yml` (`ContainerRestarting`, `ContainerOOM`, `ContainerCpuThrottling`)
- `rules/blackbox.rules.yml` (`BlackboxProbeFailed`, `BlackboxSslExpirySoon`, `BlackboxSlowHttp`)
- `rules/nginx.rules.yml` (`NginxExporterDown`, `NginxHighConnections`)
- `rules/postgres.rules.yml` (`PostgresExporterDown`, `PostgresHighConnections`)
- `rules/tests/container.test.yml`, `rules/tests/blackbox.test.yml`, `rules/tests/nginx.test.yml`, `rules/tests/postgres.test.yml`, and the extra node cases in the full `rules/tests/node.test.yml`
- `alertmanager/alertmanager.example.yml` (severity routes, inhibit rule, placeholder receivers)
- `dashboards/containers.json` and `dashboards/blackbox-ssl.json`
- Runbook sections for every alert above
- Full demo stack: blackbox_exporter plus probes for `http://192.0.2.1/` and `https://example.com/`
- `CHANGELOG.md`
- `marketing/listing_en.md`, `marketing/cover.png`, `marketing/thumb.png`, `marketing/make_images.py`
- `GUMROAD_LISTING.md`

# 中文说明

这是 Prometheus + Grafana 告警规则与仪表板包的免费预览。本子集包含三条节点告警、Node overview 仪表板、一个 promtool 单元测试，以及本地演示。

预览里的告警：

| 告警 | 级别 | 看什么 |
| --- | --- | --- |
| NodeInstanceDown | critical | `up{job="node"} == 0` 持续 2 分钟 |
| NodeDiskWillFill | warning | `predict_linear` 判断文件系统会在 24 小时内写满，且剩余已经低于 20% |
| NodeHighMemory | warning | 内存使用连续 5 分钟高于 90% |

每条告警有 `severity` 标签，以及 `summary`、`description`、`runbook` 注释。排查见 [docs/RUNBOOK.md](docs/RUNBOOK.md)。

## 快速开始

1. 安装 Docker Engine 和 Docker Compose v2 插件。
2. 在本目录执行：

```bash
make demo
```

同一条命令也是 `./demo.sh`。

3. 打开 Prometheus <http://127.0.0.1:9090> 和 Grafana <http://127.0.0.1:3000>。
4. 演示登录是 `admin` / `admin`，只给本机演示用。暴露 3000 端口之前请改掉。
5. 停止并删除数据卷：

```bash
make demo-down
```

节点目标会被改写成 `demo-host:9100`。规则要求 `job="node"`。

## 交付物清单 / Deliverables

- `rules/node.rules.yml`：NodeInstanceDown、NodeDiskWillFill、NodeHighMemory
- `rules/tests/node.test.yml`
- `dashboards/node-overview.json` 和 Grafana provisioning
- `demo/docker-compose.yml`（Prometheus、node_exporter、Grafana）
- 这三条告警的 `docs/RUNBOOK.md`
- `tests/run_tests.sh`
- MIT `LICENSE`

## 预计部署时间

第一次大约 15 分钟，主要花在拉镜像。镜像已在本地时大约 5 分钟。

## 预计交付时间 / Estimated delivery time

付款后立即下载。自行部署第一次大约 15 分钟，主要花在拉镜像；镜像已在本地时大约 5 分钟。如果需要代为部署，定制服务为 1–2 个工作日。

Download is instant after payment. Setup on your own machine is about 15 minutes the first time, or about 5 minutes when the images are already local. A custom setup service takes 1–2 business days.

## 环境要求

- Docker Engine 20.10 或更新版本，以及 Docker Compose v2
- TCP 3000、9090、9100 空闲。演示使用 host 网络。
- 不用演示时：Prometheus 2.40 或更新，Grafana 10 或更新

```bash
bash tests/run_tests.sh
```

脚本对每项检查打印 `PASS` 或 `FAIL`，把结果写到 `tests/RESULTS.md`，并删掉演示容器和数据卷。

## 许可证

MIT。见 [LICENSE](LICENSE)。

## 完整版

完整包地址：GUMROAD_URL。

相关套件：[$9 n8n DevOps Automation Pack](https://caoyadong.gumroad.com/l/yvmcqj)。

只在完整版里的内容：

- `rules/node.rules.yml` 中的 `NodeHighCpu`、`NodeInodeLow`、`NodeLoadHigh`
- `rules/container.rules.yml`（`ContainerRestarting`、`ContainerOOM`、`ContainerCpuThrottling`）
- `rules/blackbox.rules.yml`（`BlackboxProbeFailed`、`BlackboxSslExpirySoon`、`BlackboxSlowHttp`）
- `rules/nginx.rules.yml`（`NginxExporterDown`、`NginxHighConnections`）
- `rules/postgres.rules.yml`（`PostgresExporterDown`、`PostgresHighConnections`）
- `rules/tests/container.test.yml`、`rules/tests/blackbox.test.yml`、`rules/tests/nginx.test.yml`、`rules/tests/postgres.test.yml`，以及完整版 `rules/tests/node.test.yml` 里多出来的节点用例
- `alertmanager/alertmanager.example.yml`（按严重级别分流、抑制规则、占位接收器）
- `dashboards/containers.json` 和 `dashboards/blackbox-ssl.json`
- 上面每条告警的运行手册章节
- 完整演示：blackbox_exporter，以及对 `http://192.0.2.1/` 和 `https://example.com/` 的探测
- `CHANGELOG.md`
- `marketing/listing_en.md`、`marketing/cover.png`、`marketing/thumb.png`、`marketing/make_images.py`
- `GUMROAD_LISTING.md`
