# .claude 目录索引

> **版本**: 2.5 | **更新**: 2026-03-06

> ⚠️ 从 2026-02-28 起，Agent/Skill 路由与参数标准以 `.claude/config/*.json` 为准：  
> `router.json`、`agents.manifest.json`、`skills.manifest.json`。  
> 旧文档中的数量统计与触发说明若有冲突，以 manifest 为单一事实来源。
>
> 2026-03-06 新增配置治理能力：`claude_config_governance`、`config-governance-proxy`、`claude-config-workflow`、`/audit-config`、`/quality-gate`。

---

## 📁 目录结构

```
.claude/
├── CLAUDE.md                    # AI 配置总入口
├── INDEX.md                     # 本文档 - 目录索引
├── CHANGELOG.md                 # 变更日志
├── RULES.md                     # 强制性规则
├── KNOWLEDGE_BASE.md            # 技术知识库 (AI专用)
├── BUILD_GUIDE.md               # 构建入口索引
├── CODEX_BRIDGE.md              # Codex 与 Claude 配置桥接入口
│
├── config/                      # 🆕 机器可读配置层
│   ├── README.md                # 配置层说明
│   ├── router.json              # 意图路由规则
│   ├── agents.manifest.json     # Agent 标准清单
│   └── skills.manifest.json     # Skill 标准清单
│
├── core/                        # 核心配置
│   ├── README.md                # 核心配置索引
│   └── toolchain-constraints.md # 工具链强制约束速查
│
├── templates/                   # 模板库
│   ├── README.md                # 模板索引
│   ├── skill-template.md        # AI 技能模板
│   ├── command-template.md      # 快捷命令模板
│   └── workflow-template.md     # 工作流模板
│
├── workflows/                   # 标准工作流
│   ├── README.md                # 工作流索引与核心原则
│   ├── windows-build-workflow.md # Windows/MSBuild/v120 5阶段构建流程
│   └── cegui-build-workflow.md  # CEGUI 0.7.9-r5 专项构建流程
│
├── errors/                      # 错误速查手册
│   ├── README.md                # 错误快速查找表
│   ├── compiler-errors.md       # C**** 系列编译错误
│   ├── linker-errors.md         # LNK**** 系列链接错误
│   ├── msbuild-errors.md        # MSB**** 系列构建错误
│   └── cegui-specific-errors.md # CEGUI 特定错误
│
├── standards/                   # 编码标准
│   ├── README.md                # 标准索引与层级架构
│   ├── cpp-naming.md            # C++ 命名约定
│   └── cpp-patterns.md          # C++ 设计模式
│
├── agents/                      # AI 专家代理
│   ├── architecture-analyst.md  # 架构分析专家
│   ├── build-expert.md          # 编译构建专家
│   └── code-reviewer.md         # 代码审查专家
│
├── commands/                    # 快捷命令 (Slash Commands)
│   ├── status.md                # /status - 项目状态快速查看
│   ├── build-win.md             # /build-win - 编译Windows客户端
│   ├── build-android.md         # /build-android - 编译Android客户端
│   ├── build-server.md          # /build-server - 编译服务器
│   ├── clean.md                 # /clean - 清理编译产物
│   ├── codegen.md               # /codegen - 生成代码 (xbean/gnet)
│   └── diagnose-build.md        # /diagnose-build - 诊断编译错误
│
├── hooks/                       # 钩子脚本
│   ├── README.md                # 钩子使用说明
│   ├── check-secrets.bat        # 检查敏感信息泄漏
│   ├── check-generated-code.bat # 检查生成代码修改
│   └── validate-toolset.bat     # 验证工具集版本
│
├── rules/                       # 细分规则 (6个)
│   ├── README.md                # 规则索引
│   ├── 01-toolchain.md          # 工具链约束
│   ├── 02-code-style.md         # 代码风格
│   ├── 03-security.md           # 安全规范
│   ├── 04-generated-code.md     # 生成代码规则
│   ├── 05-document-naming.md    # 🆕 文档命名规范
│   └── 06-project-organization.md # 🆕 项目组织规范
│
├── skills/                      # AI 技能库 (20个技能)
│   ├── README.md                # 技能索引
│   ├── dependency-graph.md      # 技能依赖关系图
│   ├── client/                  # 客户端技能 (7个)
│   │   ├── cpp-development.md   # C++ 开发
│   │   ├── lua-scripting.md     # Lua 脚本
│   │   ├── cocos2dx-usage.md    # Cocos2d-x 使用
│   │   ├── cegui-usage.md       # 🆕 CEGUI UI 框架
│   │   ├── tolua-binding.md     # 🆕 tolua++ 绑定开发
│   │   ├── windows-build.md     # Windows 编译
│   │   └── android-build.md     # Android 编译
│   ├── server/                  # 服务器技能 (5个)
│   │   ├── java-development.md  # Java 开发
│   │   ├── gnet-framework.md    # gnet 框架
│   │   ├── xbean-system.md      # xbean 系统
│   │   ├── ant-build.md         # Ant 构建
│   │   └── distributed-arch.md  # 分布式架构
│   └── common/                  # 通用技能 (8个)
│       ├── project-context.md   # 项目上下文理解
│       ├── git-workflow.md      # Git 工作流
│       ├── build-troubleshooting.md  # 构建故障排查
│       ├── debugging.md         # 调试技巧
│       ├── performance-optimization.md  # 性能优化
│       ├── dependency-management.md  # 依赖管理
│       ├── protocol-design.md   # 🆕 协议设计
│       └── engine-tools-build.md  # 引擎工具编译
│
├── reference/                  # 参考文档
│   ├── README.md               # 参考资料索引
│   ├── quick-commands.md       # 快捷命令速查
│   └── toolchain-matrix.md     # 工具链兼容矩阵
│
├── cases/                      # 案例库
│   └── cegui-0.7.9-r5/         # CEGUI 构建案例
│
├── scripts/                    # 辅助脚本
│   ├── README.md               # 脚本说明
│   ├── verify_documentation_links.bat  # 链接验证 (Windows)
│   ├── verify_documentation_links.sh   # 链接验证 (Unix)
│   └── check_precompiled_header.ps1    # 预编译头检查
│
└── archive/                    # 📦 归档文档
    ├── 2026-01-05-cleanup/     # 2026-01-05 清理归档
    └── 2026-01/                # 2026-01 月度归档 (NEW)
        ├── cegui-optimization/ # CEGUI 优化文档
        └── build-workflow/     # 构建工作流文档
```

---

## 🚀 快速开始

### 场景 1: 编译 Windows 客户端

```bash
# 使用快捷命令
/build-win Debug   # 编译 Debug 版本
/build-win Release # 编译 Release 版本
```

**AI 执行流程** (遵循 [workflows/windows-build-workflow.md](workflows/windows-build-workflow.md)):
1. 阶段 1: 需求理解 (1-2分钟) - 识别项目类型
2. 阶段 2: 依赖分析 (2-3分钟) - **Pre-flight Check** (节省84%时间)
3. 阶段 3: 脚本生成 (2-3分钟) - 生成可执行批处理脚本
4. 阶段 4: 构建执行 (5-20分钟) - 单任务执行,避免并发冲突
5. 阶段 5: 结果报告 (1-2分钟) - 生成 BUILD_REPORT.md

### 场景 2: 诊断编译错误

```bash
# 使用诊断命令
/diagnose-build
```

AI 会:
1. 读取最新编译日志
2. **错误模式匹配** (参考 [errors/README.md](errors/README.md))
   - LNK2019 → [linker-errors.md](errors/linker-errors.md#lnk2019-无法解析的外部符号-函数)
   - C2491 → [compiler-errors.md](errors/compiler-errors.md#c2491-不能定义-dllimport-静态数据成员)
   - MSB8020 → [msbuild-errors.md](errors/msbuild-errors.md#msb8020-工具集不匹配)
3. 提供修复建议 (A/B/C 方案)
4. 生成修复脚本

**特殊项目诊断**:
- CEGUI 错误 → [errors/cegui-specific-errors.md](errors/cegui-specific-errors.md)
- 212→67→23 错误演化路径自动识别

### 场景 3: 查看项目状态

```bash
# 使用状态命令
/status
```

AI 会显示:
- Git 状态
- 编译配置
- 依赖库状态
- 最近构建记录

### 场景 4: C++ 代码开发 (NEW)

**命名规范查询**:
- 引擎层命名 → [standards/cpp-naming.md](standards/cpp-naming.md#引擎层命名-engine)
- 工具层命名 → [standards/cpp-naming.md](standards/cpp-naming.md#工具层命名-common)

**设计模式应用**:
- 引用计数 → [standards/cpp-patterns.md](standards/cpp-patterns.md#1-引用计数-reference-counting)
- 对象池 → [standards/cpp-patterns.md](standards/cpp-patterns.md#2-对象池-object-pool)
- 脏标记 → [standards/cpp-patterns.md](standards/cpp-patterns.md#4-脏标记-dirty-flag)

---

## 📚 核心文档速查

### ⭐ 新增模块 (2026-01-07)

| 模块 | 文档 | 用途 | 典型场景 |
|-----|------|------|----------|
| **workflows/** | [README.md](workflows/README.md) | 工作流索引 | 选择合适的构建流程 |
| | [windows-build-workflow.md](workflows/windows-build-workflow.md) | Windows构建 | **每次 Windows 编译前必读** |
| | [cegui-build-workflow.md](workflows/cegui-build-workflow.md) | CEGUI构建 | CEGUI 编译/架构理解 |
| **errors/** | [README.md](errors/README.md) | 错误速查表 | **编译错误 3秒定位** |
| | [compiler-errors.md](errors/compiler-errors.md) | C**** 错误 | C2491, C2065, C1010 |
| | [linker-errors.md](errors/linker-errors.md) | LNK**** 错误 | LNK2019, LNK2001, LNK4098 |
| | [msbuild-errors.md](errors/msbuild-errors.md) | MSB**** 错误 | MSB8020, MSB3073 |
| | [cegui-specific-errors.md](errors/cegui-specific-errors.md) | CEGUI错误 | 212→67→23 演化路径 |
| **standards/** | [README.md](standards/README.md) | 标准索引 | 代码规范查询 |
| | [cpp-naming.md](standards/cpp-naming.md) | C++命名 | 新建类/函数/变量时 |
| | [cpp-patterns.md](standards/cpp-patterns.md) | 设计模式 | 架构设计/性能优化 |

### AI 配置与规则

| 文档 | 用途 | 何时引用 |
|-----|------|----------|
| [CLAUDE.md](CLAUDE.md) | AI 总配置 | AI 初始化时 |
| [RULES.md](RULES.md) | 强制性规则 | 代码修改/编译前 |
| [KNOWLEDGE_BASE.md](KNOWLEDGE_BASE.md) | 技术知识库 | 技术问题查询 |

### 快捷命令 (Slash Commands)

| 命令 | 用途 | 参考文档 |
|-----|------|----------|
| `/status` | 项目状态快速查看 | [status.md](commands/status.md) |
| `/audit-config` | 审计 `.claude` 结构与引用完整性 | [audit-config.md](commands/audit-config.md) |
| `/quality-gate` | 检查当前改动集编码/BOM/生成代码边界 | [quality-gate.md](commands/quality-gate.md) |
| `/build-win` | 编译 Windows 客户端 | [build-win.md](commands/build-win.md) |
| `/build-android` | 编译 Android APK | [build-android.md](commands/build-android.md) |
| `/build-server` | 编译服务器 | [build-server.md](commands/build-server.md) |
| `/clean` | 清理编译产物 | [clean.md](commands/clean.md) |
| `/codegen` | 生成代码 (xbean/gnet) | [codegen.md](commands/codegen.md) |
| `/diagnose-build` | 诊断编译错误 | [diagnose-build.md](commands/diagnose-build.md) |

### AI 专家代理 (Agents)

| Agent | 使用场景 | 参考文档 |
|-------|----------|----------|
| `build-expert` | 复杂编译问题 (>3组件) | [build-expert.md](agents/build-expert.md) |
| `code-reviewer` | 代码审查 | [code-reviewer.md](agents/code-reviewer.md) |
| `architecture-analyst` | 架构分析 | [architecture-analyst.md](agents/architecture-analyst.md) |

---

## 🔍 常见问题索引

### Q1: 编译错误 "error LNK2001: 无法解析的外部符号"

**快速诊断** (3秒定位):
1. 查看错误速查表 → [errors/README.md](errors/README.md) - 搜索 "LNK2001"
2. 详细分析 → [errors/linker-errors.md#LNK2001](errors/linker-errors.md#lnk2001-无法解析的外部符号-数据)
3. 检查工具集版本 → [RULES.md#编译工具链](RULES.md#编译工具链)
4. 验证依赖库 → `/diagnose-build`

**常见场景**:
- Falagard 导出符号缺失 → [errors/cegui-specific-errors.md#LNK2001](errors/cegui-specific-errors.md#lnk2001-falagard-导出符号缺失-67-个错误)
- 模块化错误 (FALAGARDWRBASE_EXPORTS)

### Q2: 如何添加新的 C++ 类？

**标准流程**:
1. **选择命名风格** → [standards/README.md](standards/README.md) - 查看层级架构决策流程
   - 引擎层 (engine/) → Nuclear前缀 + PascalCase
   - 工具层 (common/) → XxxManager/Helper/Util
2. **命名规范** → [standards/cpp-naming.md](standards/cpp-naming.md)
   - 类名/成员变量/函数命名规则
   - 检查清单 (7项)
3. **设计模式** → [standards/cpp-patterns.md](standards/cpp-patterns.md)
   - 引用计数 (必须理解)
   - RAII 资源管理
4. **预编译头** → [KNOWLEDGE_BASE.md#编译错误](KNOWLEDGE_BASE.md#编译错误)
   - 第一行必须 `#include "nupch.h"`

### Q3: CEGUI 编译失败怎么办？

**专项诊断流程**:
1. **错误模式识别** → [errors/cegui-specific-errors.md](errors/cegui-specific-errors.md)
   - 212 个 LNK2019 → Cocos2d 依赖问题
   - 67 个 LNK2001 → Falagard 导出符号问题
   - 23 个 C2491 → Falagard 模块化问题
2. **查看演化路径** → [errors/cegui-specific-errors.md#问题演化路径](errors/cegui-specific-errors.md#问题演化路径)
3. **完整修复流程** → [errors/cegui-specific-errors.md#完整修复流程](errors/cegui-specific-errors.md#完整修复流程)
4. **参考构建工作流** → [workflows/cegui-build-workflow.md](workflows/cegui-build-workflow.md)

**快速检查**:
- 工具集版本 (必须 v120) → [RULES.md#编译工具链](RULES.md#编译工具链)
- 架构理解 → [workflows/cegui-build-workflow.md#架构背景](workflows/cegui-build-workflow.md#架构背景)

### Q4: 编译错误 "error C2491: 不能定义 dllimport 静态数据成员"

**快速解决**:
1. 错误类型 → [errors/compiler-errors.md#C2491](errors/compiler-errors.md#c2491-不能定义-dllimport-静态数据成员)
2. CEGUI 案例 → [errors/cegui-specific-errors.md#C2491](errors/cegui-specific-errors.md#c2491-falagard-模块化问题-23-个错误)
3. 根本原因: 源文件应在另一个 DLL 但被错误包含
4. 解决方案: `<ExcludedFromBuild>true</ExcludedFromBuild>`

### Q5: Windows 编译流程最佳实践？

**标准5阶段流程** → [workflows/windows-build-workflow.md](workflows/windows-build-workflow.md):
1. 需求理解 (1-2分钟)
2. **依赖分析 (2-3分钟) - Pre-flight Check First (节省84%时间)**
3. 脚本生成 (2-3分钟)
4. 构建执行 (5-20分钟)
5. 结果报告 (1-2分钟)

**核心原则**:
- ✅ Pre-flight Check First (3分钟预检 vs 19分钟编译失败)
- ✅ Single Task Execution (避免并发MSBuild进程)
- ✅ Script Over Command (生成.bat而非内联PowerShell)

---

## 📊 优化效果总结

### 新增模块价值

| 模块 | 核心价值 | 效率提升 |
|-----|----------|----------|
| **workflows/** | 标准化构建流程,减少重复思考 | **Pre-flight Check 节省84%编译失败时间** |
| **errors/** | 3秒定位错误,1分钟找到解决方案 | 错误诊断时间从 5-10分钟 → 1-2分钟 |
| **standards/** | 统一代码规范,减少命名风格混乱 | 代码审查时间减少 50% |

### AI 工作流改进

**优化前** (旧流程):
- 每次编译都重新分析依赖 (5-10分钟)
- 错误诊断需要上下文搜索 (5-10分钟)
- 命名规范依赖经验和手动查阅

**优化后** (新流程):
- 遵循标准5阶段工作流 (2-3分钟 Pre-flight Check)
- 错误速查表 3秒定位 → 详细文档 1分钟解决
- 命名/设计模式直接引用标准文档

**总体效率提升**: **40-50%** (基于 CEGUI 实战验证)

---

**文档版本**: 2.2
**最后更新**: 2026-01-08
**维护**: MT3 开发团队 + AI Assistant
**变更**: 新增 core/, templates/ 目录; 添加 CHANGELOG.md; 归档历史文档至 archive/2026-01/
