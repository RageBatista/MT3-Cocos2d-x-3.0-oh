# 规则目录索引

> MT3 项目模块化规则系统
> 版本: 1.3.0 | 更新: 2026-03-06

---

## 规则文件列表

| 文件 | 优先级 | 说明 |
|------|--------|------|
| [01-toolchain.md](01-toolchain.md) | 🔴 强制 | 编译工具链约束 (v120, Android NDK r16) |
| [02-code-style.md](02-code-style.md) | 🟡 重要 | C++/Lua/Java 代码规范 |
| [03-security.md](03-security.md) | 🔴 强制 | 安全规则和检查清单 |
| [04-generated-code.md](04-generated-code.md) | 🔴 强制 | xbean/gnet/tolua++ 生成代码规则 |
| [05-document-naming.md](05-document-naming.md) | 🟡 重要 | 🆕 文档命名规范 |
| [06-project-organization.md](06-project-organization.md) | 🟡 重要 | 🆕 项目组织规范 |
| [07-agent-orchestration.md](07-agent-orchestration.md) | 🟡 重要 | 🆕 多代理编排与交接规范 |
| [08-verification-gates.md](08-verification-gates.md) | 🔴 强制 | 🆕 验证门禁与交付判定规范 |
| [09-claude-config-governance.md](09-claude-config-governance.md) | 🔴 强制 | 🆕 `.claude` 路由/命令/Hook/MCP 配置治理规范 |

---

## 优先级说明

```yaml
🔴 强制性 (不可违背):
  - 违反会导致编译失败或运行时崩溃
  - 必须严格遵守

🟡 重要 (强烈建议):
  - 影响代码质量和可维护性
  - 团队约定，应该遵守

🟢 推荐 (最佳实践):
  - 优化建议
  - 可根据具体情况灵活处理
```

---

## 规则冲突解决

当规则冲突时，按以下优先级处理:

1. **安全性** > 功能性
2. **稳定性** > 性能
3. **可维护性** > 简洁性
4. **项目约束** > 通用最佳实践

---

## 快速参考

### 编译前检查

```bash
# Windows 客户端
- [ ] 工具集 = v120
- [ ] 运行时库 = /MD (Release) 或 /MDd (Debug)
- [ ] 字符集 = Unicode

# Android 客户端
- [ ] NDK = r16 (16.1.4479499)
- [ ] API Level = 22
- [ ] 构建系统 = Ant
```

### 代码提交前检查

```bash
- [ ] 没有硬编码密码
- [ ] 没有手动修改生成代码
- [ ] 符合命名规范
- [ ] 通过编译测试
```

---

## 相关文档

- [RULES.md](../RULES.md) - 完整规则文档
- [CLAUDE.md](../CLAUDE.md) - AI 配置
- [skills/](../skills/) - 技能文档

---

**维护者**: MT3 技术团队
**更新周期**: 按需更新
