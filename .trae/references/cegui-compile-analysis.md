# CEGUI 编译分析报告

> CEGUI-0.7.1 编译构建分析报告

## 文档信息

- **文档版本**: v1.0
- **创建日期**: 2026-01-27
- **分析对象**: tools/CEGUI-0.7.1/projects/premake/CEGUI.sln

---

## 一、项目概况

### 1.1 解决方案信息

- **解决方案文件**: CEGUI.sln
- **Visual Studio 版本**: 2013 (v120)
- **平台**: Win32
- **配置类型**:
  - Debug_Static (静态库)
  - Debug (动态库)
  - Release_Static (静态库)
  - Release (动态库)
  - ReleaseWithSymbols (动态库 + 符号)

### 1.2 项目组成

CEGUI 解决方案包含以下项目：

| 项目名称 | 项目类型 | 说明 |
|---------|---------|------|
| CEGUIBase | 静态/动态库 | CEGUI 核心库 |
| CEGUILuaScriptModule | 静态/动态库 | Lua 脚本模块 |
| tolua++ | 可执行文件 | tolua++ 工具 |
| tolua++cegui | 可执行文件 | tolua++ CEGUI 绑定工具 |
| CEGUIFalagardWRBase | 静态/动态库 | Falagard 窗口渲染器 |
| CEGUICoronaImageCodec | 静态/动态库 | Corona 图片编解码器 |
| CEGUIDevILImageCodec | 静态/动态库 | DevIL 图片编解码器 |
| CEGUIFreeImageImageCodec | 静态/动态库 | FreeImage 图片编解码器 |
| CEGUITGAImageCodec | 静态/动态库 | TGA 图片编解码器 |
| CEGUISILLYImageCodec | 静态/动态库 | SILLY 图片编解码器 |
| CEGUIExpatParser | 静态/动态库 | Expat XML 解析器 |
| CEGUIOpenGLRenderer | 静态/动态库 | OpenGL 渲染器 |
| CEGUIDirect3D9Renderer | 静态/动态库 | Direct3D 9 渲染器 |

---

## 二、编译环境分析

### 2.1 编译工具

- **编译器**: Visual Studio 2013 (v120)
- **平台工具集**: v120
- **字符集**: MultiByte
- **运行时库**:
  - Debug: MultiThreadedDebugDLL
  - Release: MultiThreadedDLL
  - Debug_Static: MultiThreadedDebug
  - Release_Static: MultiThreaded

### 2.2 依赖库

#### 核心依赖

| 库名称 | 用途 |
|-------|------|
| freetype.lib | 字体渲染 |
| pcre.lib | 正则表达式 |
| Winmm.lib | Windows 多媒体 |
| zlib.lib | 压缩库 |
| advapi32.lib | Windows API |
| Ws2_32.lib | Windows Socket |
| Shlwapi.lib | Windows Shell 轻量级工具 |
| platform.lib | MT3 平台库 |
| ljfm.lib | MT3 文件管理库 |

#### 图片编解码器依赖

| 库名称 | 用途 |
|-------|------|
| DevIL.lib | DevIL 图片库 |
| FreeImage.lib | FreeImage 图片库 |
| SILLY.lib | SILLY 图片库 |
| corona.lib | Corona 图片库 |
| jpeg.lib | JPEG 支持 |
| libpng.lib | PNG 支持 |
| libtiff.lib | TIFF 支持 |
| libmng.lib | MNG 支持 |

### 2.3 头文件路径

#### CEGUI 头文件

- `../../../cegui/include`
- `../../../cegui/include/XMLParserModules/LJXMLParser`
- `../../../cegui/include/WindowRendererSets/Falagard`

#### 依赖库头文件

- `../../../dependencies/include`

#### MT3 项目头文件

- `../../../../../common/platform`
- `../../../../../common`
- `../../../../../common/ljfm/code/include`
- `../../../../../cocos2d-2.0-rc2-x-2.0.1/cocos2dx`
- `../../../../../cocos2d-2.0-rc2-x-2.0.1/cocos2dx/include`
- `../../../../../cocos2d-2.0-rc2-x-2.0.1/cocos2dx/platform/win32`
- `../../../../../cocos2d-2.0-rc2-x-2.0.1/cocos2dx/platform/third_party/win32/OGLES`
- `../../../../../cocos2d-2.0-rc2-x-2.0.1/cocos2dx/kazmath/include`
- `../../../../../dependencies/LJXML/Include`

---

## 三、编译配置分析

### 3.1 Debug 配置

```xml
<ClCompile>
  <Optimization>Disabled</Optimization>
  <AdditionalIncludeDirectories>...</AdditionalIncludeDirectories>
  <PreprocessorDefinitions>
    WIN32;WIN7_32;_WINDOWS;FORCEGUIEDITOR;
    _CRT_SECURE_NO_DEPRECATE;HAVE_CONFIG_H;PCRE_STATIC;
    _DEBUG;XPP_WIN;CC_SUPPORT_PVRTC;PUBLISHED_VERSION;
    CEGUIBASE_EXPORTS;CEGUIEXPATPARSER_EXPORTS;
    FALAGARDWRBASE_EXPORTS;CEGUISILLYIMAGECODEC_EXPORTS
  </PreprocessorDefinitions>
  <RuntimeLibrary>MultiThreadedDebugDLL</RuntimeLibrary>
  <WarningLevel>Level3</WarningLevel>
  <DebugInformationFormat>EditAndContinue</DebugInformationFormat>
</ClCompile>
```

### 3.2 Release 配置

```xml
<ClCompile>
  <Optimization>MaxSpeed</Optimization>
  <OmitFramePointers>true</OmitFramePointers>
  <AdditionalIncludeDirectories>...</AdditionalIncludeDirectories>
  <PreprocessorDefinitions>
    WIN32;WIN7_32;_WINDOWS;FORCEGUIEDITOR;
    _CRT_SECURE_NO_DEPRECATE;HAVE_CONFIG_H;PCRE_STATIC;
    NDEBUG;XPP_WIN;CC_SUPPORT_PVRTC;PUBLISHED_VERSION;
    CEGUIBASE_EXPORTS;FALAGARDWRBASE_EXPORTS;
    CEGUIEXPATPARSER_EXPORTS;CEGUISILLYIMAGECODEC_EXPORTS
  </PreprocessorDefinitions>
  <RuntimeLibrary>MultiThreadedDLL</RuntimeLibrary>
  <WarningLevel>Level3</WarningLevel>
</ClCompile>
```

### 3.3 Release_Static 配置

```xml
<ClCompile>
  <Optimization>MaxSpeed</Optimization>
  <OmitFramePointers>true</OmitFramePointers>
  <AdditionalIncludeDirectories>...</AdditionalIncludeDirectories>
  <PreprocessorDefinitions>
    _CRT_SECURE_NO_DEPRECATE;HAVE_CONFIG_H;PCRE_STATIC;
    CEGUIBASE_EXPORTS;CEGUI_STATIC;TOLUA_STATIC
  </PreprocessorDefinitions>
  <RuntimeLibrary>MultiThreaded</RuntimeLibrary>
  <WarningLevel>Level3</WarningLevel>
</ClCompile>
```

---

## 四、编译问题分析

### 4.1 已知编译问题

#### 问题 1: 缺少 Visual Studio 2013

**问题描述**: 系统未安装 Visual Studio 2013

**解决方案**:
- 安装 Visual Studio 2013
- 或使用已编译好的库文件（位于 `tools/CEGUI-0.7.1-bulid/lib/`）

#### 问题 2: 依赖库路径错误

**问题描述**: 项目配置的依赖库路径可能不正确

**解决方案**:
- 验证 `dependencies/lib/dynamic` 和 `dependencies/lib/static` 目录存在
- 验证所有依赖库文件存在
- 检查库文件版本是否匹配

#### 问题 3: 头文件路径错误

**问题描述**: MT3 项目头文件路径可能不正确

**解决方案**:
- 验证 `common/platform` 目录存在
- 验证 `cocos2d-2.0-rc2-x-2.0.1` 目录存在
- 验证 `dependencies/LJXML/Include` 目录存在

### 4.2 潜在编译问题

#### 问题 1: 预处理器定义冲突

**问题描述**: `_CRT_SECURE_NO_DEPRECATE` 和 `_CRT_SECURE_NO_WARNINGS` 可能冲突

**解决方案**:
```xml
<PreprocessorDefinitions>
  _CRT_SECURE_NO_WARNINGS;
  _SCL_SECURE_NO_WARNINGS;
  ...
</PreprocessorDefinitions>
```

#### 问题 2: 运行时库不匹配

**问题描述**: 不同项目使用不同的运行时库可能导致链接错误

**解决方案**:
- 确保所有项目使用相同的运行时库配置
- Debug: MultiThreadedDebugDLL
- Release: MultiThreadedDLL

#### 问题 3: 链接器选项缺失

**问题描述**: 项目配置可能缺少必要的链接器选项

**解决方案**:
```xml
<Link>
  <AdditionalOptions>/DYNAMICBASE:NO /GS- %(AdditionalOptions)</AdditionalOptions>
</Link>
```

---

## 五、编译建议

### 5.1 使用已编译的库文件

**推荐方案**: 使用已编译好的库文件

**原因**:
- `tools/CEGUI-0.7.1-bulid/lib/` 目录已包含所有编译好的库文件
- 避免重复编译
- 减少编译错误风险

**操作步骤**:
1. 复制 `tools/CEGUI-0.7.1-bulid/lib/` 目录到 `tools/CEGUI-0.7.1/lib/`
2. 在 MT3 项目中引用这些库文件

### 5.2 手动编译（如需要）

**前提条件**:
- 安装 Visual Studio 2013
- 确保所有依赖库文件存在
- 确保所有头文件路径正确

**操作步骤**:
1. 打开 Visual Studio 2013 命令提示符
2. 导航到 `tools/CEGUI-0.7.1/projects/premake` 目录
3. 执行以下命令：

```batch
# 编译 Debug 版本
devenv CEGUI.sln /Build Debug

# 编译 Release 版本
devenv CEGUI.sln /Build Release

# 编译 Release_Static 版本
devenv CEGUI.sln /Build Release_Static
```

### 5.3 修复编译错误

#### 修复 1: 更新预处理器定义

```xml
<PreprocessorDefinitions>
  _CRT_SECURE_NO_WARNINGS;
  _SCL_SECURE_NO_WARNINGS;
  WIN32;WIN7_32;_WINDOWS;FORCEGUIEDITOR;
  HAVE_CONFIG_H;PCRE_STATIC;XPP_WIN;CC_SUPPORT_PVRTC;
  PUBLISHED_VERSION;CEGUIBASE_EXPORTS;CEGUIEXPATPARSER_EXPORTS;
  FALAGARDWRBASE_EXPORTS;CEGUISILLYIMAGECODEC_EXPORTS
</PreprocessorDefinitions>
```

#### 修复 2: 添加链接器选项

```xml
<Link>
  <AdditionalOptions>/DYNAMICBASE:NO /GS- %(AdditionalOptions)</AdditionalOptions>
</Link>
```

#### 修复 3: 更新运行时库

```xml
<!-- Debug 配置 -->
<RuntimeLibrary>MultiThreadedDebugDLL</RuntimeLibrary>

<!-- Release 配置 -->
<RuntimeLibrary>MultiThreadedDLL</RuntimeLibrary>

<!-- Debug_Static 配置 -->
<RuntimeLibrary>MultiThreadedDebug</RuntimeLibrary>

<!-- Release_Static 配置 -->
<RuntimeLibrary>MultiThreaded</RuntimeLibrary>
```

---

## 六、已编译库文件清单

### 6.1 Debug 库文件

| 库文件 | 说明 |
|-------|------|
| CEGUIBase_d.lib | CEGUI 核心库 |
| CEGUIFalagardWRBase_d.lib | Falagard 窗口渲染器 |
| CEGUIOpenGLRenderer_d.lib | OpenGL 渲染器 |
| CEGUIDirect3D9Renderer_d.lib | Direct3D 9 渲染器 |
| CEGUIExpatParser_d.lib | Expat XML 解析器 |
| CEGUICoronaImageCodec_d.lib | Corona 图片编解码器 |
| CEGUIDevILImageCodec_d.lib | DevIL 图片编解码器 |
| CEGUIFreeImageImageCodec_d.lib | FreeImage 图片编解码器 |
| CEGUITGAImageCodec_d.lib | TGA 图片编解码器 |
| CEGUISILLYImageCodec_d.lib | SILLY 图片编解码器 |
| CEGUILJXMLParser_d.lib | LJXML 解析器 |

### 6.2 Release 库文件

| 库文件 | 说明 |
|-------|------|
| CEGUIBase.lib | CEGUI 核心库 |

---

## 七、最佳实践

### 7.1 使用静态链接

**推荐**: 使用静态链接配置（Release_Static）

**原因**:
- 减少依赖 DLL 文件
- 简化部署
- 提高性能

**配置**:
```xml
<PreprocessorDefinitions>
  CEGUI_STATIC;TOLUA_STATIC
</PreprocessorDefinitions>
<RuntimeLibrary>MultiThreaded</RuntimeLibrary>
```

### 7.2 禁用警告

**推荐**: 禁用不必要的警告

**配置**:
```xml
<DisableSpecificWarnings>
  4267;4251;4244
</DisableSpecificWarnings>
```

### 7.3 启用 SDL 检查

**推荐**: 启用 SDL 检查以提高安全性

**配置**:
```xml
<SDLCheck>true</SDLCheck>
```

---

## 八、参考资料

- [公共约束](../references/common-constraints.md)
- [CEGUI 技能](../skills/cegui/SKILL.md)
- [编译环境准备](../../docs/05-编译环境准备.md)
- [编译完整指南](../../docs/06-编译完整指南.md)
