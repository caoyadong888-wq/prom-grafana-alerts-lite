# Runbook

Preview alerts only. Each one has a `severity` label and a `runbook` annotation. Thresholds are starter values. Rules expect `job="node"`, matching the demo scrape.

# 运行手册

这里只有预览版的三条告警。每条都有 `severity` 标签和 `runbook` 注释。阈值是起点。规则要求 `job="node"`，与演示抓取一致。

<a id="NodeInstanceDown"></a>

## NodeInstanceDown

**Severity:** critical

**Expression:** `up{job="node"} == 0` for 2 minutes.

### What it means

Prometheus has not scraped this node_exporter for two minutes. The host may be down, node_exporter may have crashed, or TCP 9100 may be filtered.

### Checks

1. Open the Node overview dashboard and confirm the instance stat is DOWN.
2. On the Prometheus targets page, read the error for job `node`.
3. On the target, confirm node_exporter is running and listening on port 9100.
4. Check the firewall or security group for TCP 9100 from the Prometheus host.
5. Read node_exporter logs for a crash loop.

### Mitigation

Restart node_exporter. If the host is down, recover the host first.

### 中文

**含义：** Prometheus 已连续 2 分钟抓不到该 node_exporter。主机可能宕机、导出器崩溃，或 TCP 9100 被拦截。

**排查：**

1. 打开 Node overview，确认实例为 DOWN。
2. 在 Prometheus targets 页面查看 `node` 任务的错误。
3. 在目标机确认 node_exporter 正在监听 9100。
4. 检查防火墙是否放行 Prometheus 到 9100。
5. 查看 node_exporter 日志是否在崩溃循环。

**处理：** 重启 node_exporter。主机宕机时先恢复主机。

<a id="NodeHighMemory"></a>

## NodeHighMemory

**Severity:** warning

**Expression:** `1 - MemAvailable / MemTotal` above 90% for 5 minutes.

### What it means

Available memory includes free pages and reclaimable cache. Above 90% the host is close to swapping or to the OOM killer.

### Checks

1. Read `MemAvailable` and `MemTotal` on the Node overview memory panel.
2. Check swap usage.
3. List processes by resident memory.

### Mitigation

Restart a leaked process or add memory.

### 中文

**含义：** 可用内存连续 5 分钟低于总量的 10%。可用内存含可回收缓存。再往上就可能换页或触发 OOM killer。

**排查：**

1. 在内存面板查看 MemAvailable 与 MemTotal。
2. 查看 swap。
3. 按驻留内存列出进程。

**处理：** 重启泄漏进程或增加内存。

<a id="NodeDiskWillFill"></a>

## NodeDiskWillFill

**Severity:** warning

**Expression:** `predict_linear` on available bytes over 6 hours, projected 24 hours ahead, is below zero, and free space is already under 20%. `tmpfs`, `devtmpfs`, `overlay`, `squashfs`, `aufs`, `iso9660`, and `/boot` are excluded.

### What it means

The filesystem is both somewhat full and still shrinking fast enough to hit zero inside a day.

### Checks

1. On the Node overview filesystem panel, identify the mountpoint in the alert label.
2. Find large new files and logs on that mount.
3. Check log rotation and backup jobs that write to the same disk.

### Mitigation

Delete or ship logs, or expand the volume. The 15 minute `for` waits out a short copy job.

### 中文

**含义：** 用 6 小时可用字节做 `predict_linear`，外推 24 小时小于 0，并且当前剩余已经低于 20%。已排除临时文件系统和 `/boot`。

磁盘要同时“已经比较满”和“还在快速变小”才会响。

**排查：**

1. 按告警里的 mountpoint 在文件系统面板上定位。
2. 在该挂载点找新增大文件和日志。
3. 检查写到同一块盘的日志轮转和备份。

**处理：** 清理日志或扩容。`for` 15 分钟用来躲过短复制。
