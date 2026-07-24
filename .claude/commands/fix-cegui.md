---
name: fix-cegui
version: 1.0.0
description: 修复 CEGUI 问题
linked-skill: client/cegui-usage
linked-agent: build-expert
allowed-tools:
  - Bash
  - Read
  - Grep
---

# CEGUI 问题修复命令

**关联技能**: [cegui-usage](../skills/client/cegui-usage.md)
**关联代理**: [build-expert](../agents/build-expert.md)

自动诊断和修复 CEGUI 0.7.9-r5 编译错误。

自动诊断和修复 CEGUI 0.7.9-r5 编译错误

## 用法

```bash
/fix-cegui
```

## 功能

AI 将自动执行以下流程:

### 1. 错误诊断 (1-2分钟)

```yaml
步骤:
  - 读取最新 CEGUI 编译日志
  - 提取错误码和错误数量
  - 匹配错误模式:
    * 212 个 LNK2019 → Cocos2d 依赖问题
    * 67 个 LNK2001 → Falagard 导出符号问题
    * 23 个 C2491 → Falagard 模块化问题
```

### 2. 自动修复 (5-10分钟)

根据错误类型应用对应修复方案:

**场景 A: LNK2019 (212个) - Cocos2d 依赖**

```yaml
修复:
  1. Read: CEGUIBase.vcxproj
  2. 找到 8 个 Cocos2d 源文件
  3. 批量添加 <ExcludedFromBuild>true</ExcludedFromBuild>
  4. 重新编译
```

**场景 B: LNK2001 (67个) - Falagard 导出符号**

```yaml
修复:
  1. Read: CEGUIBase.vcxproj
  2. 搜索 <PreprocessorDefinitions>
  3. 移除 FALAGARDWRBASE_EXPORTS;
  4. 重新编译
```

**场景 C: C2491 (23个) - Falagard 模块化**

```yaml
修复:
  1. Read: CEGUIBase.vcxproj
  2. 找到所有 Fal*.cpp 文件 (~20个)
  3. 批量添加 <ExcludedFromBuild>true</ExcludedFromBuild>
  4. 重新编译
```

### 3. 验证修复 (1-2分钟)

```yaml
验证:
  - 检查编译是否成功
  - 验证生成的 lib 文件大小 (~2.7 MB)
  - 生成 FIX_REPORT.md
```

## 修复报告示例

```markdown
# CEGUI 修复报告

## 错误诊断

- 初始错误: 212 个 LNK2019 错误
- 错误类型: Cocos2d 依赖问题

## 修复方案

- 方案: 禁用 Cocos2d 代码 (8个文件)
- 修改文件: CEGUIBase.vcxproj

## 修复结果

- ✅ 编译成功
- ✅ CEGUIBase_d.lib: 2.7 MB
- ✅ CEGUIBase.lib: 2.7 MB

## 耗时

- 诊断: 2 分钟
- 修复: 8 分钟
- 验证: 1 分钟
- 总计: 11 分钟
```

## 参考文档

- [errors/cegui-specific-errors.md](../errors/cegui-specific-errors.md) - CEGUI 错误完整诊断
- [workflows/cegui-build-workflow.md](../workflows/cegui-build-workflow.md) - CEGUI 构建流程
- [cases/cegui-0.7.9-r5/](../cases/cegui-0.7.9-r5/) - CEGUI 案例研究
