# CEGUI 0.7.9-r5 Dependencies 可用性分析

**版本**: 1.0
**分析日期**: 2026-01-02
**分析目的**: 确定 CEGUI 0.7.9-r5 依赖库是否可用于 VS2013 (v120) 编译

---

## 执行摘要

### 关键发现

| 检查项 | 结果 | 说明 |
|-------|------|------|
| **依赖库 CRT 版本** | ✅ MSVCR120.dll | 与 VS2013 (v120) **ABI 兼容** |
| **依赖库完整性** | ✅ 100% | 所有必需 DLL 存在 |
| **头文件可用性** | ✅ 完整 | include/ 目录包含所有头文件 |
| **库文件可用性** | ✅ 完整 | lib/ 目录包含动态和静态库 |
| **可用性结论** | ✅ **可直接使用** | 无需重新编译依赖库 |

### 重要结论

> **CEGUI 0.7.9-r5 的依赖库已使用 Visual Studio 2013 (v120) 编译**
>
> 这意味着这些依赖库可以**直接用于** VS2013 编译的 CEImagesetEditor 和 CEGUI，无需重新编译依赖库。

---

## 1. 依赖库目录结构

### 1.1 完整目录树

```
CEGUI-0.7.9-r5/dependencies/
├── include/                    # 头文件目录
│   ├── expat/                 # Expat XML 解析器
│   ├── freetype2/             # FreeType 字体渲染
│   ├── GL/                    # OpenGL 头文件
│   ├── GL/                    # GLEW 扩展
│   ├── glm/                   # GLM 数学库
│   ├── jpeg/                  # JPEG 图像
│   ├── lua/                   # Lua 5.1
│   ├── minizip/               # ZIP 压缩
│   ├── pcre/                  # 正则表达式
│   ├── png/                   # PNG 图像
│   ├── SILLY/                 # SILLY 图像加载
│   ├── tinyxml/               # TinyXML 解析器
│   ├── tolua++/               # tolua++ 绑定
│   ├── xercesc/               # Xerces-C++ XML
│   └── zlib/                  # ZLIB 压缩
├── lib/                        # 库文件目录
│   ├── dynamic/               # 动态链接库 (.lib)
│   │   ├── expat.lib
│   │   ├── freetype.lib
│   │   ├── pcre.lib
│   │   ├── SILLY.lib
│   │   ├── lua.lib
│   │   ├── ... (共 17 个库)
│   └── static/                # 静态库 (.lib)
│       ├── ... (对应静态库)
└── bin/                        # 运行时 DLL 目录
    ├── expat.dll / expat_d.dll
    ├── freetype.dll / freetype_d.dll
    ├── glew.dll / glew_d.dll
    ├── glfw.dll / glfw_d.dll
    ├── jpeg.dll / jpeg_d.dll
    ├── libpng.dll / libpng_d.dll
    ├── lua.dll / lua_d.dll
    ├── minizip.dll / minizip_d.dll
    ├── pcre.dll / pcre_d.dll
    ├── SILLY.dll / SILLY_d.dll
    ├── tinyxml.dll / tinyxml_d.dll
    ├── toluapp.dll / toluapp_d.dll
    ├── xerces-c_3.dll / xerces-c_3_d.dll
    └── zlib.dll / zlib_d.dll
```

### 1.2 文件统计

| 类型 | 数量 | 说明 |
|-----|------|------|
| 头文件目录 | 15 | 每个依赖库一个目录 |
| 动态库文件 (.lib) | 17 | Debug + Release |
| 静态库文件 (.lib) | 17 | Debug + Release |
| 运行时 DLL | 26 | Debug + Release (含 D3DX11Effects) |

---

## 2. CRT 版本分析

### 2.1 检测方法

使用 Visual Studio 2013 的 `dumpbin.exe` 工具检查 DLL 的导入依赖：

```batch
"D:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\bin\dumpbin.exe" /DEPENDENTS <dll_file>
```

### 2.2 检测结果

所有 CEGUI 0.7.9-r5 依赖库 DLL 都依赖 **MSVCR120.dll**：

| DLL 文件 | CRT 依赖 | 编译器 |
|---------|---------|--------|
| expat.dll | MSVCR120.dll | VS2013 (v120) |
| freetype.dll | MSVCR120.dll | VS2013 (v120) |
| pcre.dll | MSVCR120.dll | VS2013 (v120) |
| SILLY.dll | MSVCR120.dll | VS2013 (v120) |
| lua.dll | MSVCR120.dll | VS2013 (v120) |
| zlib.dll | MSVCR120.dll | VS2013 (v120) |
| libpng.dll | MSVCR120.dll | VS2013 (v120) |
| jpeg.dll | MSVCR120.dll | VS2013 (v120) |

### 2.3 CRT 版本对照表

| CRT DLL | Visual Studio | 工具集 | 状态 |
|---------|--------------|--------|------|
| MSVCR71.dll | VS2003 | v71 | 旧版可运行 CEGUI |
| MSVCR90.dll | VS2008 | v90 | CEGUI 0.7.1 依赖（原始） |
| MSVCR100.dll | VS2010 | v100 | CEGUI 0.7.9 项目默认 |
| **MSVCR120.dll** | **VS2013** | **v120** | **CEGUI 0.7.9-r5 依赖（当前）** |
| MSVCR140.dll | VS2015 | v140 | ❌ 不兼容 |

---

## 3. 跨版本兼容性分析

### 3.1 CEGUI 分布版本对比

| 版本 | 位置 | CRT 版本 | 编译器 | 可用性 |
|-----|------|---------|--------|-------|
| 旧版可运行 | client/resource/tools/CEGUIImagesetEditer/ | MSVCR71.dll | VS2003 (v71) | ✅ 可运行（遗留） |
| CEGUI-0.7.1 | tools/CEGUI-0.7.1/ | MSVCR120.dll | VS2013 (v120) | ✅ 可用 |
| **CEGUI 0.7.9-r5** | **tools/CEGUI-0.7.9-r5/** | **MSVCR120.dll** | **VS2013 (v120)** | **✅ 直接可用** |

### 3.2 ABI 兼容性说明

**重要原则**：不同版本的 CRT (MSVCR*.dll) 之间存在 **ABI 不兼容**：

- ❌ **不能混用**：使用 v120 编译的 EXE 只能链接使用 v120 编译的 DLL
- ❌ **不能混用**：使用 v120 编译的 DLL 只能链接使用 v120 编译的依赖库
- ✅ **好消息**：CEGUI 0.7.9-r5 依赖库使用 v120 编译，与目标配置一致

### 3.3 项目配置差异

**当前情况**：
- CEGUI 0.7.9-r5 项目文件 (`.vcxproj`) 配置为 `v100` (VS2010)
- 但 dependencies/bin/ 中的 DLL 使用 `v120` (VS2013) 编译

**结论**：
1. 依赖库是 v120 编译的，**可以直接用于 VS2013 项目**
2. 只需将 CEGUI 项目文件的 `PlatformToolset` 从 `v100` 改为 `v120`
3. 无需重新编译依赖库

---

## 4. 依赖库详细清单

### 4.1 核心依赖（必需）

| 库名 | 版本 | 用途 | Release DLL 大小 |
|-----|------|------|----------------|
| **freetype** | 2.x | 字体渲染 | 459 KB |
| **expat** | 2.x | XML 解析 | 107 KB |
| **pcre** | 8.x | 正则表达式 | 112 KB |
| **SILLY** | - | 图像加载 | 21 KB |
| **zlib** | 1.x | 压缩 | 66 KB |

### 4.2 图像支持（可选）

| 库名 | 版本 | 用途 | Release DLL 大小 |
|-----|------|------|----------------|
| **libpng** | 1.x | PNG 图像 | 115 KB |
| **jpeg** | - | JPEG 图像 | 232 KB |
| **minizip** | - | ZIP 支持 | 32 KB |

### 4.3 脚本支持（可选）

| 库名 | 版本 | 用途 | Release DLL 大小 |
|-----|------|------|----------------|
| **lua** | 5.1 | Lua 脚本引擎 | 131 KB |
| **toluapp** | - | tolua++ 绑定 | 24 KB |

### 4.4 渲染支持（可选）

| 库名 | 版本 | 用途 | Release DLL 大小 |
|-----|------|------|----------------|
| **glew** | - | OpenGL 扩展 | 271 KB |
| **glfw** | - | 窗口管理 | 41 KB |
| **D3DX11Effects** | - | DirectX 11 效果 | 2.9 MB |

### 4.5 XML 解析（可选）

| 库名 | 版本 | 用途 | Release DLL 大小 |
|-----|------|------|----------------|
| **tinyxml** | - | XML 解析 | 59 KB |
| **xerces-c_3** | 3.x | XML 解析 | 2.3 MB |

---

## 5. 集成指南

### 5.1 用于 CEImagesetEditor

**步骤 1：配置项目属性**

在 `vc++9/CEImagesetEditor.vcxproj` 中配置：

```xml
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">
  <IncludePath>$(ProjectDir)..\..\CEGUI-0.7.9-r5\dependencies\include;$(IncludePath)</IncludePath>
  <LibraryPath>$(ProjectDir)..\..\CEGUI-0.7.9-r5\dependencies\lib\dynamic;$(LibraryPath)</LibraryPath>
</PropertyGroup>
```

**步骤 2：复制运行时 DLL**

```powershell
# 复制所有依赖 DLL 到输出目录
$SRC = "E:\MT3\tools\CEGUI-0.7.9-r5\dependencies\bin"
$DST = "E:\MT3\tools\CEImagesetEditor-0.7.1\bin\debug"

Copy-Item "$SRC\*.dll" $DST -Force
```

### 5.2 编译 CEGUI 0.7.9-r5

**步骤 1：升级工具集**

批量修改所有 `.vcxproj` 文件：

```xml
<!-- 从 -->
<PlatformToolset>v100</PlatformToolset>
<!-- 改为 -->
<PlatformToolset>v120</PlatformToolset>
```

**步骤 2：编译项目**

```batch
cd E:\MT3\tools\CEGUI-0.7.9-r5\projects\premake
msbuild CEGUI.sln /t:Rebuild /p:Configuration=Release /p:Platform=Win32 /p:PlatformToolset=v120
```

---

## 6. 验证检查清单

编译前确认以下条件：

- [ ] VS2013 (v120) 已安装
- [ ] CEGUI 项目文件 PlatformToolset 设置为 v120
- [ ] Include 路径包含 dependencies/include
- [ ] LibraryPath 包含 dependencies/lib/dynamic
- [ ] 运行时目录包含 dependencies/bin 中的所有 DLL

运行时确认：

- [ ] msvcp120.dll 和 msvcr120.dll 在系统 PATH 中
- [ ] 所有依赖 DLL 与可执行文件在同一目录
- [ ] 使用 dumpbin 验证 EXE 依赖 MSVCR120.dll

---

## 7. 总结与建议

### 7.1 核心结论

✅ **CEGUI 0.7.9-r5 的依赖库可以直接用于 VS2013 (v120) 编译**

### 7.2 具体建议

1. **对于 CEImagesetEditor**：
   - ✅ 直接使用 `CEGUI-0.7.9-r5/dependencies/` 中的库
   - ✅ 配置正确的 IncludePath 和 LibraryPath
   - ✅ 复制 bin/ 目录中的 DLL 到输出目录

2. **对于编译 CEGUI 0.7.9-r5**：
   - ⚠️ 需要修改项目文件的 PlatformToolset 从 v100 到 v120
   - ✅ 无需重新编译依赖库
   - ✅ 可以直接使用现有的 dependencies/

3. **ABI 兼容性**：
   - ❌ 不要使用 v140+ (VS2015+) 编译
   - ✅ 必须使用 v120 (VS2013)
   - ✅ 所有模块使用相同的 CRT 版本

### 7.3 下一步

1. 修改 CEGUI 0.7.9-r5 项目文件的 PlatformToolset
2. 编译 CEGUI 核心库
3. 集成到 CEImagesetEditor 项目
4. 运行时验证

---

**文档版本**: 1.0
**最后更新**: 2026-01-02
**分析者**: MT3 开发团队
