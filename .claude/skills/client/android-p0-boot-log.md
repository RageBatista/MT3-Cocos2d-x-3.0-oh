---
name: android-p0-boot-log
version: 1.2.0
priority: high
category: client
description: |
  MuMu 模拟器 Android 启动日志采集技能。
  目标是稳定抓取包含 [P0][BOOT] 标记的 logcat 证据并生成可复现报告。
  触发词: MuMu, mumu, [P0][BOOT], BOOT日志, 启动日志, logcat, adb日志
allowed-tools:
  - Bash
  - Read
  - Grep
  - Write
---

# Android [P0][BOOT] 日志采集（MuMu）

## 适用场景

- 需要复现 Android 客户端冷启动问题。
- 需要采集并上报 `[P0][BOOT]` 关键日志。
- 需要在 MuMu 模拟器环境做稳定复测。

## 前置检查

1. 识别 adb 可用性
- 优先用系统 `adb`，若不可用再尝试 MuMu 自带 `adb.exe`。
- 示例：
```powershell
where adb
```

2. 连接 MuMu 设备
- 常见 MuMu 端口：`127.0.0.1:16384`（MuMu12），部分环境为 `127.0.0.1:7555`。
- 示例：
```powershell
adb connect 127.0.0.1:16384
adb connect 127.0.0.1:7555
adb devices
```

3. 确认目标序列号
- 后续命令统一使用 `-s <serial>`，避免多设备串扰。

## 标准采集流程（必须按顺序）

1. 清空旧日志并扩容缓冲区
```powershell
adb -s <serial> logcat -G 32M
adb -s <serial> logcat -c
```

2. 启动实时采集（原始全量）
```powershell
adb -s <serial> logcat -v threadtime > <log_path>\\android-boot-raw.log
```

3. 在 MuMu 内触发“冷启动”
- 先强杀应用再启动，确保覆盖 BOOT 阶段。
- 示例（包名需按实际替换）：
```powershell
adb -s <serial> shell am force-stop <package_name>
adb -s <serial> shell monkey -p <package_name> -c android.intent.category.LAUNCHER 1
```

4. 采集窗口结束后停止 logcat
- 保留 `android-boot-raw.log` 作为原始证据。

5. 提取 `[P0][BOOT]` 关键片段
```powershell
Get-Content -Encoding UTF8 <log_path>\\android-boot-raw.log | Select-String -Pattern "\\[P0\\]\\[BOOT\\]" | Set-Content -Encoding UTF8 <log_path>\\android-boot-p0-boot.log
```

## 结果验收

- `android-boot-raw.log` 文件存在且非空。
- `android-boot-p0-boot.log` 至少包含 1 条 `[P0][BOOT]`。
- 报告中包含：
  - 模拟器版本（MuMu 版本/Android 版本）
  - 设备序列号（`adb devices`）
  - 触发时间窗口
  - 关键日志摘录（前后各 5 行上下文）

## 输出模板

```markdown
## MuMu Android [P0][BOOT] 采集结果
- Emulator: MuMu (version=?)
- Device: <serial>
- Package: <package_name>
- Raw Log: <log_path>/android-boot-raw.log
- Filtered Log: <log_path>/android-boot-p0-boot.log
- Hit Count: <n>
- Conclusion: [PASS/FAIL]
- Notes:
```

