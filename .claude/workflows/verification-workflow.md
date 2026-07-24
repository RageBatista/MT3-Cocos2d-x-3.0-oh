# 验证门禁工作流（Verification Workflow）

> 版本: 1.0.0  
> 更新: 2026-03-05  
> 适用: 代码提交前、PR 前、发布前

## 目标

以最小可执行集合完成质量验证，保证“可构建、可回归、可追溯”。

## 标准阶段

1. 环境与配置预检
- 确认工具链版本满足 MT3 约束（Win32 v120 / Android NDK r16 + Ant + JDK8 / Server JDK 1.7-1.8）。
- 检查是否触发生成代码边界（xbean/rpc/tolua++）。

2. 构建与类型检查
- Windows 客户端：优先执行 `tools/scripts/Build-MT3-Exe-Canonical.ps1`。
- Android 客户端：优先执行 `tools/scripts/Build-Android-Locojoy-WithGate.ps1`。
- 服务端：在 `server/server/game_server` 执行 `ant dist`（必要时先 `genrpc/genxdb/gengbeans`）。

3. 代码质量检查
- lint/静态检查（若子模块有配置则按子模块执行）。
- 安全检查（敏感信息、密钥、凭证泄漏）。

4. 测试与回归
- 执行最小关键路径回归（按改动范围决定）。
- 修复缺陷后必须补充回归步骤或用例。

5. 交付结论
- 输出 PASS/FAIL 与阻断项。
- 记录剩余风险与回滚建议。

## 输出模板

```markdown
VERIFICATION: [PASS/FAIL]

- Build: [OK/FAIL]
- Toolchain: [OK/FAIL]
- Generated-Code Boundary: [OK/WARN/FAIL]
- Security: [OK/WARN/FAIL]
- Tests: [OK/FAIL]
- Ready for PR: [YES/NO]
```
