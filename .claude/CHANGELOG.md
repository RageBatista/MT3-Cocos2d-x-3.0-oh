# .claude 配置变更日志

> 所有重要变更都会记录在此文件中。

---

## [2.5.1] - 2026-03-07

### 文档
- `docs/23-Debug启动问题排查-2026-03-03.md`
  - 新增“主城高密度场景时装模型发白/发虚排查沉淀（2026-03-07）”
  - 记录 C++ 渲染链路根因、修复点、回归矩阵、构建命令、产物哈希与恢复后快速校验命令
- `docs/05-平台专项/android/06_完整排错手册.md`
  - 新增第 11 节“主城高密度场景时装发白/发虚专项（2026-03-07）”
  - 固化 Android 侧触发条件、修复文件、回归检查点与可用 APK 指纹

### 追踪
- 本次沉淀明确“同屏数量是触发条件，不是根因”：
  - 根因为分区贴图句柄在高负载下失效时的 C++ 染色渲染降级链路不完整
  - 避免后续代码回退后重复从零定位

## [2.5.0] - 2026-03-06

### 新增
- `.claude/skills/common/claude-config-engineering.md`
- `.claude/workflows/claude-config-workflow.md`
- `.claude/rules/09-claude-config-governance.md`
- `.claude/commands/audit-config.md`
- `.claude/commands/quality-gate.md`
- `.claude/scripts/quality_gate.ps1`
- `.claude/hooks/session-start-profile.ps1`
- `.claude/hooks/stop-quality-gate.ps1`

### 变更
- `config/router.json` 新增 `claude_config_governance` 意图，并将 `mcp_management` 切换到配置治理代理
- `config/proxies.manifest.json` 新增 `config-governance-proxy`
- `config/skills.manifest.json` 新增 `claude-config-engineering` 技能元数据
- `config/commands.manifest.json` 新增 `audit-config`、`quality-gate`
- `config/hooks.manifest.json` 与 `hooks/hooks.json` 新增 SessionStart/Stop 生命周期治理 Hook，并补齐 `MultiEdit` 支持
- `config/mcp.manifest.json` 补充配置治理、验证、评审、协议分析意图绑定
- `hooks/post-edit-encoding-reminder.ps1` 升级为实际 BOM/编码校验
- `hooks/post-edit-generated-guard.ps1` 扩展到 `client/FireClient/Application/ProtoDef/**` 生成产物
- `hooks/stop-config-audit.ps1` 升级为“按审计报告新鲜度”提醒

### 文档
- 更新 `config/README.md`、`config/INDEX.md`、`hooks/README.md`、`workflows/README.md`、`rules/README.md`、`INDEX.md`

## [2.2.0] - 2026-01-08

### 新增
- `core/` 核心配置目录
  - `toolchain-constraints.md` - 工具链约束速查
  - `README.md` - 目录说明
- `templates/` 模板目录
  - `skill-template.md` - 技能模板
  - `command-template.md` - 命令模板
  - `README.md` - 模板索引
- `archive/2026-01/` 月度归档目录
  - `cegui-optimization/` - CEGUI 优化文档归档
  - `build-workflow/` - 构建工作流文档归档
- `CHANGELOG.md` - 本变更日志

### 变更
- `INDEX.md` 升级至 v2.2，新增目录结构文档

### 移动
- `CEGUI_BUILD_FINAL_REPORT.md` → `archive/2026-01/cegui-optimization/`
- `CEGUI_OPTIMIZATION_SUMMARY.md` → `archive/2026-01/cegui-optimization/`
- `CEGUI_VERSION_COMPARISON.md` → `archive/2026-01/cegui-optimization/`
- `BUILD_WORKFLOW_REFLECTION.md` → `archive/2026-01/build-workflow/`
- `CLAUDE_BUILD_WORKFLOW_OPTIMIZED.md` → `archive/2026-01/build-workflow/`

### 优化
- 根目录文件数从 12 减少到 7 (-42%)
- 添加结构化归档机制

---

## [2.1.0] - 2026-01-07

### 新增
- `workflows/` 标准工作流目录
  - `windows-build-workflow.md` - Windows 5阶段构建流程
  - `cegui-build-workflow.md` - CEGUI 专项构建流程
- `errors/` 错误速查手册
  - `compiler-errors.md` - C**** 编译错误
  - `linker-errors.md` - LNK**** 链接错误
  - `msbuild-errors.md` - MSB**** 构建错误
  - `cegui-specific-errors.md` - CEGUI 特定错误
- `standards/` 编码标准
  - `cpp-naming.md` - C++ 命名约定
  - `cpp-patterns.md` - C++ 设计模式

### 优化
- 错误诊断时间从 5-10分钟 降至 1-2分钟
- Pre-flight Check 节省 84% 编译失败时间

---

## [2.0.0] - 2026-01-05

### 新增
- `agents/` AI 专家代理
- `commands/` 快捷命令 (7个)
- `hooks/` 钩子脚本
- `rules/` 细分规则
- `skills/` AI 技能库 (17个)
- `KNOWLEDGE_BASE.md` 技术知识库
- `DOCUMENT_NAMING_RULES.md` 文档命名规范
- `PROJECT_ORGANIZATION_RULES.md` 项目组织规范

### 变更
- `CLAUDE.md` 重构为 v2.0
- `RULES.md` 完善技术约束

### 归档
- 历史文档移至 `archive/2026-01-05-cleanup/`

---

## [1.0.0] - 2025-12-xx

### 初始版本
- `CLAUDE.md` 基础配置
- `RULES.md` 基本规则

---

**格式说明**: 基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)
**版本规范**: 遵循 [语义化版本](https://semver.org/lang/zh-CN/)
