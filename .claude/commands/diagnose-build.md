---
name: diagnose-build
version: 1.0.0
description: 诊断并解决编译错误
linked-skill: common/build-troubleshooting
linked-agent: build-expert
allowed-tools:
  - Bash
  - Read
  - Grep
  - Glob
---

# 编译错误诊断命令

**关联技能**: [build-troubleshooting](../skills/common/build-troubleshooting.md)
**关联代理**: [build-expert](../agents/build-expert.md)

系统化诊断和解决编译错误。

## 诊断流程

### 1. 错误分类

根据错误码判断问题类型:

| 错误码 | 类型 | 可能原因 |
|--------|------|----------|
| LNK2001/LNK2019 | 链接错误 | 工具集不匹配、缺少库 |
| LNK2038 | 不匹配 | RuntimeLibrary 配置错误 |
| C1083 | 头文件 | 包含路径错误 |
| C2065/C2039 | 未声明 | 头文件缺失或顺序错误 |
| MSB3073 | 构建 | 预编译头配置错误 |

### 2. 工具集检查

```bash
# 检查项目工具集
findstr /i "PlatformToolset" "E:\MT3\client\MT3Win32App\*.vcxproj"

# 预期结果: v120
# 如果不是 v120，这是主要问题原因
```

### 3. 依赖库检查

```bash
# 检查 FireClient.lib
dir /s /b "E:\MT3\client\FireClient\*.lib"

# 检查 Cocos2d-x 库
dir /s /b "E:\MT3\cocos2d-2.0-rc2-x-2.0.1\*.lib"
```

### 4. 配置检查

- RuntimeLibrary: Release 应为 /MD, Debug 应为 /MDd
- 字符集: Unicode
- 预编译头: nupch.h

## 解决方案模板

根据诊断结果提供:
1. 问题根因
2. 具体修复步骤
3. 验证方法
4. 相关文档链接

## 参考文档

- [编译故障排查](../skills/common/build-troubleshooting.md)
- [工具链规则](../rules/01-toolchain.md)

分析用户提供的错误信息，执行诊断并提供解决方案。
