# P0 资源与 UI 健康门禁任务单（Resource UI Gate）

> 创建日期：2026-06-08  
> 严重程度：严重  
> 优先级：P0  
> 状态：待执行  
> 负责人建议：资源发布负责人 + UI/Lua 负责人 + 客户端负责人

## 目标

建立资源热更新、PFS、CEGUI、Lua UI 的发布前 P0 健康门禁，阻断资源缺失、UI 空白、按钮失效、热更漏包进入发布包。

## 范围

- `client/resource/res/ui/**`
- `client/resource/res/script/**`
- `client/resource/res/**` 关键运行资源
- `.agents/skills/cegui-layout-integration/scripts/check-cegui-bindings.ps1`
- `.agents/skills/cegui-layout-integration/scripts/validate-cegui-resources.ps1`
- `tools/scripts/Validate-UnpackedResources.ps1`
- `plans/unpacked-res-validation-20260424.json`

## 已确认证据

- `plans/unpacked-res-validation-20260424.json` 状态为 `needs_attention`。
- 资源审计存在 failed、missing、unresolved 等项。
- UI 规模大：约 849 个 layout、2560 个 Lua、629 个 imageset、87 个 font。
- CEGUI/Lua 绑定检查脚本存在，但未形成稳定 CI 门禁。

## 核心玩家路径

发布前 P0 门禁优先覆盖：

1. 启动更新
2. 登录首屏
3. 选服
4. 创建角色
5. 入世界主界面
6. 背包
7. 商城/充值
8. 战斗入口
9. 聊天/社交
10. 客服/公告

## 执行项

### 1. 资源包与索引校验

- [ ] 复用或修正 `Validate-UnpackedResources.ps1`。
- [ ] 输出 JSON/Markdown 报告。
- [ ] P0 阻断条件：
  - 关键资源目录缺失
  - 关键 UI layout 缺失
  - 关键 imageset/font 缺失
  - failed item 大于 0
  - 关键路径 missing final path 大于 0
  - `ver.ljvi` / `fl.ljpi` / PFS 索引不一致

建议命令：

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\scripts\Validate-UnpackedResources.ps1
```

### 2. CEGUI layout 与 Lua 绑定检查

- [ ] 执行 Lua/layout 绑定检查。
- [ ] 执行 layout/imageset/font 资源存在性检查。
- [ ] 对登录、创建角色、主界面、背包、商城、战斗、客服路径建立核心白名单。
- [ ] 核心白名单内任何缺失均阻断。

建议命令：

```powershell
powershell -ExecutionPolicy Bypass -File .\.agents\skills\cegui-layout-integration\scripts\check-cegui-bindings.ps1
powershell -ExecutionPolicy Bypass -File .\.agents\skills\cegui-layout-integration\scripts\validate-cegui-resources.ps1
```

### 3. 核心 UI 资源健康清单

- [ ] 新建核心 UI 清单文档或 JSON。
- [ ] 每个核心 UI 项记录：
  - 玩家路径
  - Lua dialog 文件
  - layout 文件
  - 根窗口路径
  - 必需按钮/事件
  - 必需 imageset/font
  - 对应 smoke 验收方式

建议新建：

- `docs/03-开发指南/核心UI资源健康门禁清单-2026-06-08.md`

### 4. 聚合门禁脚本

- [ ] 新建或复用 `tools/scripts/Test-MT3-ResourceUiGate.ps1`。
- [ ] 聚合资源校验、CEGUI 绑定检查、CEGUI 资源检查。
- [ ] 输出 `build_logs/resource-ui-gate.json`。
- [ ] CI 或发布流程调用该脚本。

建议命令：

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\scripts\Test-MT3-ResourceUiGate.ps1 -ReportPath build_logs/resource-ui-gate.json
```

## 验收标准

- [ ] 资源校验不再处于 P0 阻断状态。
- [ ] 核心 UI 清单覆盖 10 条玩家路径。
- [ ] 缺 layout、imageset、font、窗口路径、核心事件时门禁失败。
- [ ] CI 或发布流程保存资源/UI 检查报告。
- [ ] 不通过手工改生成索引掩盖资源源问题。

## 回滚策略

- 门禁误报时可临时白名单，但必须写明负责人、原因、到期日期。
- 登录、更新、支付、入世界链路不得白名单跳过。

