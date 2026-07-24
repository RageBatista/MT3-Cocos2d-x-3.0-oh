# P0 主线 CI 质量门禁任务单（CI Quality Gate）

> 创建日期：2026-06-08  
> 严重程度：致命  
> 优先级：P0  
> 状态：待执行  
> 负责人建议：构建/CI 负责人 + Windows 客户端负责人 + 服务端负责人

## 目标

为 MT3 建立最小可阻断严重回归的主线质量门禁，覆盖 Win32 构建、Server 生成/打包、runtime audit、资源/UI 门禁与安全扫描。

## 范围

- `.gitlab-ci.yml`
- `.github/workflows/**`
- `tools/scripts/Check-v120Toolset.ps1`
- `tools/scripts/Build-MT3-Exe-Canonical.ps1`
- `tools/scripts/Audit-RuntimeDependencies.ps1`
- `server/server/game_server/build.xml`
- 安全、资源、UI 门禁脚本

## 约束

- 不替换 Win32 `v120 + VS2013` 主线。
- 不把 Android 主线改为 Gradle。
- 不把 Server 主线改为 Maven/Gradle。
- 不要求每次提交都跑全量 SafeChain；发版前必须跑严格链路。

## 已确认证据

- `.gitlab-ci.yml` 当前主要为 encoding-check。
- 未发现 CI 中执行 `Build-MT3-Exe-Canonical.ps1`、Android 构建或 `server/server/game_server/build.xml dist`。
- 近期 Win32 本地构建日志存在且成功，但警告规模较高。

## 执行项

### 1. CI 分层设计

- [ ] 保留现有 encoding-check。
- [ ] 新增 `p0-static-gate`：编码检查 + v120 主线工具链检查。
- [ ] 新增 `p0-win32-build`：Win32 Release Incremental 构建。
- [ ] 新增 `p0-server-build`：Server `genfiles` + `dist`。
- [ ] 新增 `p0-runtime-audit`：Runtime dependency audit。
- [ ] 新增 `p0-security-gate`：凭证、HTTP、私网 IP、测试域名扫描。
- [ ] 新增 `p0-resource-ui-gate`：资源与 CEGUI/Lua UI 静态门禁。

### 2. Win32 主线构建门禁

- [ ] CI runner 明确安装 VS2013/MSBuild 12.0。
- [ ] 执行 v120 工具链检查。
- [ ] 执行 Win32 Release 快速构建。
- [ ] 保存 `build_logs/**` 与 `client/resource/bin/Release/MT3.exe` 产物元信息。

建议命令：

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\scripts\Check-v120Toolset.ps1
powershell -ExecutionPolicy Bypass -File .\tools\scripts\Build-MT3-Exe-Canonical.ps1 -Configuration Release -Platform Win32 -BuildMode Incremental -MaxParallelJobs 8
```

### 3. Server 生成链与打包门禁

- [ ] 执行 `genfiles`，验证 `genrpc/genxdb/gengbeans` 生成链。
- [ ] 执行 `dist`，验证服务端可打包。
- [ ] 若生成物发生变化，CI 报告必须提示来源定义和生成入口。

建议命令：

```powershell
ant -f .\server\server\game_server\build.xml genfiles
ant -f .\server\server\game_server\build.xml dist
```

### 4. Runtime 与安全门禁

- [ ] 执行 runtime dependency audit。
- [ ] High 问题必须阻断。
- [ ] Controlled/Info 写入 artifact，定期收敛。
- [ ] 执行安全扫描门禁，真实凭证、私网 IP、生产 HTTP、测试域名命中时阻断。

建议命令：

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\scripts\Audit-RuntimeDependencies.ps1 -ReportPath build_logs/runtime-audit-ci.json
powershell -ExecutionPolicy Bypass -File .\tools\scripts\Test-MT3-SecurityGate.ps1
```

### 5. Artifact 与追溯

- [ ] artifact 保存编码检查报告。
- [ ] artifact 保存 Win32 构建日志。
- [ ] artifact 保存 Server Ant 日志。
- [ ] artifact 保存 runtime audit JSON。
- [ ] artifact 保存安全/资源/UI 门禁 JSON 或 Markdown 摘要。
- [ ] 报告中记录 commit、分支、时间、工具链版本、产物 hash。

## 验收标准

- [ ] CI 至少覆盖编码、v120、Win32 构建、Server gen/dist、runtime audit、安全扫描、资源/UI 门禁。
- [ ] 任一 P0 门禁失败会阻断合并或发布。
- [ ] CI 不误把 vendor/example 工程当主线失败。
- [ ] 报告可追溯具体 commit 和产物。

## 回滚策略

- runner 环境不完整时，新增 job 可先设为 manual，但发布前必须执行。
- 新门禁误报时只允许临时白名单，白名单必须包含负责人、原因和到期日期。

