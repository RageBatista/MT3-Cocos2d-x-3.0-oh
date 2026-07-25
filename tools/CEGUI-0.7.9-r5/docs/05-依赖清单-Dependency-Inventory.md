# 依赖清单（CEGUI 0.7.9-r5）

---

## 1. 已内置依赖（dependencies/）

### 1.1 头文件

- FreeType (`freetype/`, `ft2build.h`)
- PCRE (`pcre.h`)
- Expat (`expat.h`)
- Lua 5.1 (`lua.h`, `lauxlib.h`, `lualib.h`)
- TinyXML (`tinyxml.h`, `tinystr.h`)
- Xerces-C (`xercesc/`)
- GLEW / GLFW / GLM
- Minizip (`minizip/`)

### 1.2 动态库 / 静态库

- `freetype`, `pcre`, `expat`, `zlib`
- `libpng`, `jpeg`
- `lua`, `toluapp`
- `SILLY`, `tinyxml`
- `xerces-c_3`
- `glew`, `glfw`, `glm`

---

## 2. 图像编解码器依赖（已内置且可用）

> **修正说明 (2026-01-05)**: 经验证，以下模块在 `dependencies/` 目录中**已完整包含**，无需外部补充。

以下模块在 `config.lua` 默认开启，且 **dependencies 内已包含对应库**：

### 2.1 DevIL ImageCodec ✅
- **库文件**: `DevIL.lib`, `DevIL_d.lib`
- **DLL**: `DevIL.dll`, `DevIL_d.dll`
- **位置**: `dependencies/lib/dynamic/`, `dependencies/bin/`
- **CRT版本**: MSVCR120.dll (v120)

### 2.2 FreeImage ImageCodec ✅
- **库文件**: `FreeImage.lib`, `FreeImaged.lib`
- **DLL**: `FreeImage.dll`, `FreeImaged.dll`
- **位置**: `dependencies/lib/dynamic/`, `dependencies/bin/`
- **CRT版本**: MSVCR120.dll (v120)

### 2.3 Corona ImageCodec ✅
- **库文件**: `corona.lib`, `corona_d.lib`
- **类型**: 静态库（无 DLL）
- **位置**: `dependencies/lib/dynamic/`
- **CRT版本**: MSVCR120.dll (v120)

**使用方式**：

- ✅ `config.lua` 中默认配置正确，无需修改
- ✅ 编译时自动链接这些库
- ✅ 运行时需确保 DLL 在 PATH 或程序目录
- ✅ 所有库与 VS2013 (v120) 工具集 ABI 兼容

---

## 3. 渲染器依赖说明

- OpenGL：系统自带 `OpenGL32.lib` / `GLU32.lib`
- Direct3D9：`d3dx9.lib` / `dxerr.lib`（来自 DXSDK June 2010）
- Ogre：需要外部 Ogre SDK + Boost

---

## 4. 依赖快速检查（PowerShell）

```powershell
# 基础依赖目录
Test-Path e:\MT3\tools\CEGUI-0.7.9-r5\dependencies\include
Test-Path e:\MT3\tools\CEGUI-0.7.9-r5\dependencies\lib\dynamic
Test-Path e:\MT3\tools\CEGUI-0.7.9-r5\dependencies\bin

# 核心库
Test-Path e:\MT3\tools\CEGUI-0.7.9-r5\dependencies\lib\dynamic\freetype.lib
Test-Path e:\MT3\tools\CEGUI-0.7.9-r5\dependencies\lib\dynamic\pcre.lib
Test-Path e:\MT3\tools\CEGUI-0.7.9-r5\dependencies\lib\dynamic\expat.lib
Test-Path e:\MT3\tools\CEGUI-0.7.9-r5\dependencies\lib\dynamic\SILLY.lib
```