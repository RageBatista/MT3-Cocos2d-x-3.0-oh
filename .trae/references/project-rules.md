# MT3 项目规则

> 本文件定义了 MT3 项目的编码规范和项目规则。

## 框架版本及依赖

| 框架/库 | 版本 | 说明 |
|----------|------|------|
| Cocos2d-x | 2.0-rc2-x-2.0.1 | Win32 平台使用原生 OpenGL 2.0，非 OpenGL ES |
| CEGUI | 0.x | 静态链接，启用 `CEGUI_STATIC` 宏 |
| Lua | 5.1 | 配合 tolua++ 进行 C++/Lua 绑定 |
| tolua++ | 1.0.93 | C++ 与 Lua 绑定工具 |
| Visual Studio | 2013 | 使用 v120 平台工具集，绝对禁止升级 |
| Windows SDK | 8.1 | 项目依赖此 SDK |

## 编译配置

### 运行时库

```yaml
Release 配置：MultiThreadedDLL
Debug 配置：MultiThreadedDebugDLL
```

### 链接器选项

```yaml
必需选项：
  - /DYNAMICBASE:NO      # 禁用 ASLR
  - /GS-                 # 禁用安全检查
```

### 静态链接

```cpp
#define CEGUI_STATIC    // CEGUI 静态链接
#define GLEW_STATIC     // GLEW 静态链接
```

## 编码规范

### 字符集

- 使用 Unicode 字符集

### 文件编码

| 文件类型 | 编码格式 |
|----------|----------|
| `.cpp`, `.c`, `.h`, `.hpp` | UTF-8 with BOM |
| `.lua`, `.java`, `.md`, `.xml`, `.json` | UTF-8 without BOM |

### 代码格式

```yaml
缩进：4 空格
花括号：行尾
```

### 命名约定

| 类型 | 约定 | 示例 |
|------|------|------|
| 类名 | PascalCase | `GamePlayer`, `SceneManager` |
| 方法/变量 | camelCase | `updatePosition()`, `m_position` |
| 常量 | 全大写下划线 | `MAX_PLAYERS`, `DEFAULT_TIMEOUT` |

## 预处理器定义

```yaml
必需定义：
  - _CRT_SECURE_NO_WARNINGS
  - _SCL_SECURE_NO_WARNINGS
```

## 编译警告

```yaml
级别：Level3
禁用警告：4267, 4251, 4244
SDL 检查：启用
```

## 内存管理

### Cocos2d-x 引用计数

- 遵循 Cocos2d-x 引用计数（`retain`/`release`/`autorelease`）
- 使用 `create()` 工厂方法创建对象
- 使用 `CC_SAFE_DELETE` 和 `CC_SAFE_RELEASE` 宏释放资源
- 避免循环引用，必要时使用弱引用

## 禁止事项

```yaml
禁止：
  - 升级 Cocos2d-x 版本
  - 更改预编译库
  - 使用 C++14/17/20 特性
  - 在 Win32 平台使用 OpenGL ES API（应使用原生 OpenGL）
  - 修改 toolset v120 设置
  - 在 Win32 平台链接 libEGL.lib 和 libGLESv2.lib
  - 使用 VS2015/2017/2019/2022 编译
```

## Lua 集成规范

- 使用 tolua++ 进行 C++ 与 Lua 绑定
- Lua 脚本文件使用 UTF-8 without BOM 编码
- 避免全局变量污染
- 保持 Lua 函数在全局作用域或正确引用

## 测试要求

```yaml
单元测试：关键模块必须单元测试
集成测试：验证模块交互
性能测试：覆盖 FPS、内存、加载速度
兼容性测试：支持 Windows/Android/iOS
```

## 平台特定规则

### Win32 平台

```yaml
渲染：原生 OpenGL 2.0
库：opengl32.lib + glew32.lib
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
库：libEGL.lib + libGLESv2.lib
注意：触摸输入 API 差异
```

## 参考资料

- [公共约束](common-constraints.md)
- [完整项目架构](../../docs/19-项目架构分析报告-Project-Architecture-Analysis.md)
- [编译环境准备](../../docs/05-编译环境准备.md)
- [编译完整指南](../../docs/06-编译完整指南.md)
