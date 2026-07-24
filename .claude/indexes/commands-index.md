# Commands 快速索引

> **版本**: 1.1.0 | **更新**: 2026-03-05 | **命令数量**: 13

---

## 📋 命令列表

| 命令 | 描述 | 关联技能 | 关联代理 | 文件 |
|-----|------|---------|---------|------|
| `/status` | 项目状态快速查看 | project-context | architecture-analyst | [status.md](../commands/status.md) |
| `/plan` | 先规划后实施并等待确认 | search-first | planner | [plan.md](../commands/plan.md) |
| `/orchestrate` | 多代理编排执行复杂任务 | verification-loop | workflow-orchestrator | [orchestrate.md](../commands/orchestrate.md) |
| `/verify` | 执行统一验证门禁 | verification-loop | test-engineer | [verify.md](../commands/verify.md) |
| `/mcp-status` | 查看 MCP 建议启用集 | project-context | doc-writer | [mcp-status.md](../commands/mcp-status.md) |
| `/build-win` | 编译 Windows 客户端 | windows-build | build-expert | [build-win.md](../commands/build-win.md) |
| `/build-android` | 编译 Android 客户端 | android-build | build-expert | [build-android.md](../commands/build-android.md) |
| `/build-server` | 编译服务器主模块 | ant-build | build-expert | [build-server.md](../commands/build-server.md) |
| `/build-cegui` | 编译 CEGUI 0.7.9-r5 | cegui-usage | build-expert | [build-cegui.md](../commands/build-cegui.md) |
| `/diagnose-build` | 诊断编译错误 | build-troubleshooting | build-error-resolver | [diagnose-build.md](../commands/diagnose-build.md) |
| `/fix-cegui` | 修复 CEGUI 构建问题 | cegui-usage | build-error-resolver | [fix-cegui.md](../commands/fix-cegui.md) |
| `/codegen` | 生成 gnet/xbean 代码 | gnet-framework, xbean-system | build-expert | [codegen.md](../commands/codegen.md) |
| `/clean` | 清理编译产物 | build-troubleshooting | build-expert | [clean.md](../commands/clean.md) |

---

## 🎯 按能力分类

### 规划与编排
- `/plan`
- `/orchestrate`

### 验证与质量
- `/verify`
- `/diagnose-build`

### 构建与生成
- `/build-win`
- `/build-android`
- `/build-server`
- `/build-cegui`
- `/codegen`
- `/clean`

### 配置与状态
- `/status`
- `/mcp-status`

---

## 📌 说明

- 命令元数据以 [`commands.manifest.json`](../config/commands.manifest.json) 为准。
- 代理编排策略以 [`proxies.manifest.json`](../config/proxies.manifest.json) 为准。