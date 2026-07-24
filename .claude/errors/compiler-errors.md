# C++ 编译错误 (Compiler Errors)

> **范围**: C**** 系列错误
> **版本**: 1.0 | **更新**: 2026-01-07

---

## C2491: 不能定义 dllimport 静态数据成员

### 错误描述

```
error C2491: "CEGUI::FalagardToggleButton::TypeName": 不能定义 dllimport 静态数据成员 的定义
```

### 典型症状

- 批量出现 (10-30 个)
- 涉及窗口渲染器类 (Fal*.cpp)
- 关键词: "dllimport 静态数据成员"

### 根本原因

静态成员被标记为 `dllimport`,但在当前编译单元中被**定义**。

**C++ DLL 语义冲突**:
```cpp
// 头文件: 声明为 dllimport
class __declspec(dllimport) MyClass {
    static const char* TypeName;  // 声明
};

// .cpp 文件: 错误地定义
const char* MyClass::TypeName = "MyClass";  // ❌ C2491
```

### 调查步骤

```yaml
1. 识别类名: CEGUI::FalagardToggleButton
2. 检查预处理器定义:
   - Read: project.vcxproj → <PreprocessorDefinitions>
   - 查找是否有相关 EXPORTS 宏
3. 检查源文件包含:
   - 这些源文件是否应该在当前项目中?
```

### CEGUI 实战案例

**问题**: CEGUIBase 移除 FALAGARDWRBASE_EXPORTS 后,23 个 C2491 错误

**根因**: Falagard 类被标记为 dllimport (从 CEGUIFalagardWRBase.dll 导入),但源文件仍在 CEGUIBase 中编译

**解决方案**: 排除 Falagard 源文件
```xml
<ClCompile Include="FalToggleButton.cpp">
  <ExcludedFromBuild>true</ExcludedFromBuild>
</ClCompile>
```

**参考**: [CEGUI 专项错误](cegui-specific-errors.md#c2491-falagard-模块化问题)

---

## C2065: 未声明的标识符

### 错误描述

```
error C2065: 'CCSprite': 未声明的标识符
```

### 典型症状

- 涉及类名/函数名/变量名
- 关键词: "未声明的标识符"

### 根本原因

编译器找不到符号声明,常见场景:

1. 缺少头文件包含
2. 命名空间问题
3. 拼写错误
4. 前向声明不完整

### 解决方案

**方案 A: 添加头文件**
```cpp
#include "nupch.h"    // 预编译头 (第一行)
#include "CCSprite.h" // 添加缺失头文件
```

**方案 B: 命名空间前缀**
```cpp
cocos2d::CCSprite* sprite = cocos2d::CCSprite::create();
```

**方案 C: using 声明**
```cpp
using namespace cocos2d;
CCSprite* sprite = CCSprite::create();
```

---

## C1010: 预编译头错误

### 错误描述

```
fatal error C1010: 在查找预编译头时遇到意外的文件结尾。是否忘记了向源中添加"#include \"nupch.h\""?
```

### 根本原因

.cpp 文件未包含预编译头 `nupch.h`

### 解决方案

```cpp
// 每个 .cpp 文件第一行必须是:
#include "nupch.h"
```

**效果**: 编译时间减少 85%

---

## 其他常见编译错误

| 错误码 | 描述 | 快速修复 |
|--------|------|----------|
| C2039 | 不是成员 | 检查头文件版本,命名空间 |
| C2664 | 不能转换参数 | 检查参数类型,const 限定符 |
| C2143 | 语法错误 | 检查分号,括号匹配 |
| C4251 | 需要 dll 接口 | 添加导出宏或忽略警告 |

---

**文档版本**: 1.0
**最后更新**: 2026-01-07
