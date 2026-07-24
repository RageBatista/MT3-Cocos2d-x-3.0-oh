---
name: verify
version: 1.0.0
description: 执行统一验证门禁并输出 PASS/FAIL
linked-skill: common/verification-loop
linked-agent: test-engineer
allowed-tools:
  - Bash
  - Read
  - Grep
---

# 验证命令

执行验证闭环，默认覆盖构建、质量与回归。

## 执行顺序

1. 工具链预检（v120 / Android NDK r16 + Ant + JDK8 / Server JDK 1.7-1.8）
2. 相关构建任务
3. 安全与生成代码边界检查
4. 回归验证
5. 输出结论

## 输出模板

```markdown
VERIFICATION: [PASS/FAIL]
- Build:
- Toolchain:
- Security:
- Regression:
- Ready for PR: [YES/NO]
```
