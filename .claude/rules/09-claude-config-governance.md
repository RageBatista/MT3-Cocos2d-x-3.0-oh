# Claude 配置治理规则

> 优先级: 🔴 强制
> 适用范围: `.claude/` 全目录及其关联脚本

---

## 1. 单一事实来源

- `router.json`、`*.manifest.json`、`quality-gates.json` 是 `.claude` 配置的机器可读真源。
- Markdown 说明文件必须服从 manifest，不能只改说明不改配置。

## 2. 路由与能力绑定

- 新增意图时，必须同时明确：
  - `default_proxy`
  - `primary_agent`
  - `skills`
  - `mode`
  - `workflow_id` 或 `workflow_candidates`
- 路由挂载技能数量不得突破资源模式预算。

## 3. 命令与 Hook 必须可执行

- 新增命令必须能映射到仓库内真实脚本、真实命令或真实工作流。
- 新增 Hook 必须同时登记：
  - `.claude/config/hooks.manifest.json`
  - `.claude/hooks/hooks.json`
  - 对应脚本文件
- 默认优先 `warn`，只有高风险场景才能 `block`。

## 4. 生成代码边界

- 下列路径视为生成代码或生成产物，默认禁止直接手改：
  - `server/**/xbean/*.java`
  - `server/**/rpc/*.java`
  - `client/**/tolua++/*.cpp`
  - `client/FireClient/Application/ProtoDef/**`
- 需要变更时，优先修改源定义文件并重新生成。

## 5. 编码与平台兼容

- `.claude` 下的 `.md/.json/.yaml/.ps1` 默认保持 UTF-8 无 BOM。
- 治理主链与 hook 样例固定使用 PowerShell 7 (`pwsh.exe`) 解析 UTF-8 no-BOM；只有带双 Shell fixture 的 ASCII 脚本才声明 Windows PowerShell 5.1 兼容。
- 命令示例必须优先给出当前仓库可直接执行的 PowerShell 形式。

## 6. 配置变更后的必做验证

- 修改 `.claude` 任意结构后，必须执行：

```powershell
pwsh.exe -NoLogo -NoProfile -File .\.claude\scripts\audit_claude_config.ps1
pwsh.exe -NoLogo -NoProfile -File .\.claude\scripts\quality_gate.ps1 -ChangedOnly
```

- 若新增外部依赖或 MCP 服务器，必须注明环境变量与默认启用策略。

## 7. 文档同步

- 新增 Skill、Workflow、Rule、Command、Hook 后，至少同步更新相关 `README`/`INDEX`/`CHANGELOG`。
- 若版本号或能力数量已失真，必须在同一批次内修正。
