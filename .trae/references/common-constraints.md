# MT3 项目公共约束

> 本文件定义了 MT3 项目中所有技能共享的公共约束条件。在编辑 C++/Lua 代码时必须严格遵守。

## 编译工具链约束

| 项目 | 要求 | 禁止 | 原因 |
|------|------|------|------|
| **Visual Studio** | VS2013 (v120 工具集) | VS2015/2017/2019/2022 | 预编译库 ABI 不兼容 |
| **Windows SDK** | Windows SDK 8.1 | - | 项目依赖此 SDK |
| **C++ 标准** | C++11 | C++14/17/20 | 预编译库兼容性 |
| **运行时库** | MultiThreadedDLL (Release) / MultiThreadedDebugDLL (Debug) | - | 项目统一配置 |

## 预编译库约束

以下库为预编译库（v120），禁止修改或重新编译：

```yaml
不可修改的库：
  - dependencies/cegui/**/*.lib
  - cocos2d-2.0-rc2-x-2.0.1/**/*.lib
  - common/platform/**/*.lib
  - client/FireClient/FireClient.lib

修改后果：
  - LNK2001/LNK2019 链接错误
  - Access Violation 运行时崩溃
  - ABI 不兼容问题
```

## 源文件编码约束

| 文件类型 | 编码格式 | 说明 |
|----------|----------|------|
| `.cpp`, `.c`, `.h`, `.hpp` | **UTF-8 with BOM** | VS2013 需要 BOM 识别 UTF-8 无 BOM|
| `.rc` (资源文件) | **UTF-8 with BOM** | MFC 资源文件 |
| `.lua`, `.java` | UTF-8 | 脚本/服务器代码 |
| `.md`, `.xml`, `.json` | UTF-8 | 文档与配置文件 |

### 添加 BOM 方法（PowerShell）

```powershell
$enc = New-Object System.Text.UTF8Encoding($true)
$text = [System.IO.File]::ReadAllText("file.cpp", [System.Text.Encoding]::UTF8)
[System.IO.File]::WriteAllText("file.cpp", $text, $enc)
```

### 验证 BOM 方法

```powershell
Format-Hex -Path "file.cpp" | Select-Object -First 1
# 应显示: EF BB BF ...
```

## 编译配置约束

### 链接器选项

```yaml
必需选项：
  - /DYNAMICBASE:NO      # 禁用 ASLR
  - /GS-                 # 禁用安全检查

预处理器定义：
  - _CRT_SECURE_NO_WARNINGS
  - _SCL_SECURE_NO_WARNINGS

编译警告：
  - Level: /W3
  - 禁用警告：4267, 4251, 4244

SDL 检查：
  - 启用 SDLCheck
```

### 静态链接宏

```cpp
#define CEGUI_STATIC    // CEGUI 静态链接
#define GLEW_STATIC     // GLEW 静态链接
```

## 依赖库版本约束

### 核心依赖（禁止升级）

| 库 | 版本 | 说明 |
|----|------|------|
| Cocos2d-x | 2.0-rc2-x-2.0.1 | 引擎核心 |
| CEGUI | 0.7.1 | UI 框架 |
| Lua | 5.1 | 脚本引擎 |
| tolua++ | 1.0.93 | C++/Lua 绑定 |
| FMOD | Ex | 音频引擎 |

### 平台特定依赖

| 平台 | OpenGL 库 | 说明 |
|------|-----------|------|
| **Win32** | opengl32.lib + glew32.lib | 原生 OpenGL 2.0 |
| **Android/iOS** | - | OpenGL ES |
| **WinRT/WP8** | libEGL.lib + libGLESv2.lib | OpenGL ES + ANGLE |

### 禁止事项

```yaml
禁止：
  - 升级 Cocos2d-x 版本
  - 升级 CEGUI 版本
  - 更换 Lua 版本
  - 使用 C++14/17/20 特性
  - 在 Win32 平台使用 OpenGL ES API
  - 修改 toolset v120 设置
  - 在 Win32 平台链接 libEGL.lib 和 libGLESv2.lib
```

## 编码规范

### 命名约定

| 类型 | 约定 | 示例 |
|------|------|------|
| 类名 | PascalCase | `GamePlayer`, `SceneManager` |
| 函数名 | camelCase | `updatePosition()`, `loadTexture()` |
| 成员变量 | m_ 前缀 + camelCase | `m_position`, `m_texture` |
| 常量 | 全大写 + 下划线 | `MAX_PLAYERS`, `DEFAULT_TIMEOUT` |
| 宏定义 | 全大写 + 下划线 | `CEGUI_STATIC`, `GLEW_STATIC` |

### 代码格式

```yaml
缩进：4 空格
花括号：行尾
字符集：Unicode
换行：CRLF (Windows)
```

### 预编译头

```cpp
// 必须包含 stdafx.h
#include "stdafx.h"

// 不要在头文件中包含 stdafx.h
```

## 内存管理约束

### Cocos2d-x 引用计数

```cpp
// 使用 create() 工厂方法（推荐）
CCSprite* sprite = CCSprite::create("sprite.png");
sprite->autorelease();

// 手动管理（谨慎使用）
CCSprite* sprite = new CCSprite();
sprite->init();
sprite->autorelease();

// 释放资源
CC_SAFE_DELETE(ptr);
CC_SAFE_RELEASE(ptr);
```

### 避免循环引用

```cpp
// 错误：循环引用
class A {
    B* m_b;
};
class B {
    A* m_a;
};

// 正确：使用弱引用或手动断开
class A {
    B* m_b;
};
class B {
    A* m_a;
    void cleanup() { m_a = nullptr; }
};
```

## Lua 集成规范

### 文件编码

- Lua 脚本文件使用 **UTF-8 without BOM** 编码

### 避免全局变量污染

```lua
-- 错误：污染全局命名空间
function doSomething() end

-- 正确：使用模块
local MyModule = {}
function MyModule.doSomething() end
return MyModule
```

### 保持函数引用

```lua
-- 错误：函数可能被垃圾回收
button:subscribeEvent("Clicked", function()
    print("Clicked!")
end)

-- 正确：保持函数引用
local function onButtonClicked(args)
    print("Clicked!")
end
button:subscribeEvent("Clicked", onButtonClicked)
```

## 平台特定规则

### Win32 平台

```yaml
渲染：原生 OpenGL 2.0
库：opengl32.lib, glew32.lib
禁止：OpenGL ES API
```

### Android/iOS 平台

```yaml
渲染：OpenGL ES
库：系统提供
注意：与 Win32 API 差异
```

### WinRT/WP8 平台

```yaml
渲染：OpenGL ES + ANGLE
库：libEGL.lib, libGLESv2.lib
注意：触摸输入 API 差异
```

## 参考文档

- [完整项目架构](../../docs/02-技术架构/02-项目架构.md)
- [编译环境准备](../../docs/03-开发指南/01-Windows编译环境准备.md)
- [编译完整指南](../../docs/03-开发指南/02-Windows完整构建指南.md)
- [依赖矩阵](../../docs/06-工具链/02-依赖矩阵.md)
