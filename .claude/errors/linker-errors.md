# 链接错误 (Linker Errors)

> **范围**: LNK**** 系列错误
> **版本**: 1.0 | **更新**: 2026-01-07

---

## LNK2019: 无法解析的外部符号 (函数)

### 错误描述

```
error LNK2019: 无法解析的外部符号 "public: static class cocos2d::CCDirector * __cdecl cocos2d::CCDirector::sharedDirector(void)"
```

### 典型症状

- 最常见的链接错误
- 涉及函数调用
- 关键词: "无法解析的外部符号"

### 根本原因

函数被调用,但链接器找不到函数实现,常见场景:

1. **缺少库文件**: 函数在某个 .lib 中,但未链接
2. **工具集不匹配**: v120 vs v140 ABI 不兼容
3. **库顺序错误**: 依赖库顺序不对
4. **导出符号缺失**: DLL 未正确导出符号

### 调查步骤

```yaml
步骤 1: 提取符号信息
  - 符号名: "cocos2d::CCDirector::sharedDirector"
  - 所属命名空间: cocos2d
  - 符号类型: 函数 (静态方法)

步骤 2: 定位所属库
  - Grep: "CCDirector::sharedDirector" → cocos2d 库
  - 预期库: libcocos2d.lib

步骤 3: 检查项目配置
  - Read: project.vcxproj → <AdditionalDependencies>
  - 检查是否包含 libcocos2d.lib

步骤 4: 验证库文件
  - Bash: dir "dependencies\libcocos2d.lib"
  - 检查库文件是否存在

步骤 5: 检查工具集
  - 确认库和项目都使用 v120
```

### CEGUI 实战案例

**问题**: 212 个 LNK2019 错误,全部涉及 cocos2d::

**根因**: CEGUIBase 包含 8 个 Cocos2d 源文件,但未链接 libcocos2d.lib

**解决方案**: 禁用 Cocos2d 源文件
```xml
<ClCompile Include="CEGUICocos2DRenderer.cpp">
  <ExcludedFromBuild>true</ExcludedFromBuild>
</ClCompile>
```

**参考**: [CEGUI Cocos2d 依赖错误](cegui-specific-errors.md#lnk2019-cocos2d-依赖)

---

## LNK2001: 无法解析的外部符号 (数据)

### 错误描述

```
error LNK2001: 无法解析的外部符号 "public: void __thiscall CEGUI::FalagardScrollbar::setVertical(bool)"
```

### 典型症状

- 涉及数据成员或虚函数
- 通常与 LNK2019 类似,但针对数据/虚表

### 根本原因

符号被声明但未定义,常见场景:

1. **导出符号缺失**: 类被声明为 dllexport,但实现未导出
2. **模块化错误**: 代码应在另一个 DLL,但错误地引用
3. **库版本不匹配**: 头文件和库不匹配

### CEGUI 实战案例

**问题**: 67 个 LNK2001 错误,涉及 Falagard 类方法

**根因**: CEGUIBase 定义 FALAGARDWRBASE_EXPORTS,但 Falagard 源文件未包含

**解决方案**: 移除 FALAGARDWRBASE_EXPORTS
```xml
<!-- 移除前 -->
<PreprocessorDefinitions>...; FALAGARDWRBASE_EXPORTS;...</PreprocessorDefinitions>

<!-- 移除后 -->
<PreprocessorDefinitions>...;...</PreprocessorDefinitions>
```

**参考**: [CEGUI Falagard 导出问题](cegui-specific-errors.md#lnk2001-falagard-导出符号缺失)

---

## LNK4098: CRT 运行时库冲突

### 错误描述

```
warning LNK4098: defaultlib 'MSVCRT' 与其他库的使用冲突; 请使用 /NODEFAULTLIB:library
```

### 典型症状

- 警告级别 (非致命)
- 涉及 MSVCRT, LIBCMT
- 关键词: "defaultlib", "冲突"

### 根本原因

项目混用了不同的 CRT 运行时库:

- `/MT` (MultiThreaded) - 静态链接 LIBCMT.lib
- `/MD` (MultiThreadedDLL) - 动态链接 MSVCRT.lib
- `/MTd` (Debug 静态) - LIBCMTD.lib
- `/MDd` (Debug 动态) - MSVCRTD.lib

### 解决方案

**统一运行时库** (MT3 项目标准):
```xml
<!-- Release -->
<RuntimeLibrary>MultiThreadedDLL</RuntimeLibrary>  <!-- /MD -->

<!-- Debug -->
<RuntimeLibrary>MultiThreadedDebugDLL</RuntimeLibrary>  <!-- /MDd -->
```

**检查所有依赖库**: 确保预编译库也使用相同运行时库

**⚠️ 禁止使用 /FORCE:MULTIPLE**: 会掩盖问题,导致运行时崩溃

---

## 其他常见链接错误

| 错误码 | 描述 | 快速修复 |
|--------|------|----------|
| LNK1104 | 无法打开文件 | 检查库路径,文件是否存在 |
| LNK2005 | 重复定义 | 检查多个 .cpp 包含同一实现 |
| LNK4042 | 对象被多次指定 | 忽略 (通常无害) |
| LNK1120 | N 个无法解析 | 汇总错误,修复上述 LNK2019/2001 |

---

**文档版本**: 1.0
**最后更新**: 2026-01-07
