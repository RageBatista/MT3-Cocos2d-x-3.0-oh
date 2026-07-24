# MT3 Agent Skills

> MT3 项目 AI 辅助开发技能文档体系

## 目录结构

```
.trae/
├── cegui/              # CEGUI UI 开发技能
├── cocos2dx/           # Cocos2d-x 2.0 开发技能
├── references/         # 公共参考文档
├── reports/            # 审计报告
├── README.md           # 本文档
├── INDEX.md            # 技能索引
└── QUICKSTART.md       # 快速入门指南
```

## 技能文档索引

| 技能 | 描述 | 文档 |
|------|------|------|
| CEGUI | UI 开发技能 | [SKILL.md](cegui/SKILL.md) |
| Cocos2d-x | 场景/精灵开发技能 | [SKILL.md](cocos2dx/SKILL.md) |

## 参考文档索引

| 文档 | 描述 |
|------|------|
| [公共约束](references/common-constraints.md) | 编码规范、文件命名、代码风格 |
| [Nuclear 集成指南](references/nuclear-integration.md) | Nuclear 引擎集成方法 |
| [调试命令集合](references/debugging-commands.md) | 常用调试命令和技巧 |
| [错误处理策略](references/error-handling.md) | 错误处理最佳实践 |
| [性能优化指南](references/performance-guide.md) | 性能优化策略 |
| [资源管理策略](references/resource-management.md) | 资源加载和管理 |
| [项目规则](references/project-rules.md) | 项目开发规则 |

## 推荐阅读顺序

### 新手入门
1. 阅读本 README.md
2. 阅读 [快速入门指南](QUICKSTART.md)
3. 阅读 [公共约束](references/common-constraints.md)

### UI 开发
1. 阅读 [CEGUI 技能](cegui/SKILL.md)
2. 参考 [Nuclear 集成指南](references/nuclear-integration.md)
3. 参考 [错误处理策略](references/error-handling.md)

### 场景/精灵开发
1. 阅读 [Cocos2d-x 技能](cocos2dx/SKILL.md)
2. 参考 [Nuclear 集成指南](references/nuclear-integration.md)
3. 参考 [性能优化指南](references/performance-guide.md)

### 调试问题
1. 阅读 [调试命令集合](references/debugging-commands.md)
2. 阅读 [错误处理策略](references/error-handling.md)

### 性能优化
1. 阅读 [性能优化指南](references/performance-guide.md)
2. 阅读 [资源管理策略](references/resource-management.md)

## 技能依赖关系

```
CEGUI 技能 ← Nuclear 集成指南 ← 公共约束
Cocos2d-x 技能 ← Nuclear 集成指南 ← 公共约束
```

## 快速链接

- [技能索引](INDEX.md) - 查看所有技能文档
- [快速入门](QUICKSTART.md) - 新手快速上手
- [审计报告](reports/skill-audit-report-2025-01-27.md) - 查看审计结果

## 文档规范

所有技能文档遵循统一的 Agent Skills 规范：
- **何时使用** - 明确使用场景
- **何时不使用** - 避免误用
- **输入要求** - 前置条件和输入
- **关键约束** - 重要限制和注意事项
- **工作流程** - 执行步骤
- **代码示例** - 实际代码演示
- **常见错误** - 错误场景和解决方案
- **调试技巧** - 调试方法
- **性能优化** - 优化建议
- **注意事项** - 其他重要提示

## 版本历史

- v2.0.0 (2026-01-27) - 第二轮深度审计后优化
- v1.0.0 (2025-01-27) - 初始版本

## 维护者

技术委员会
