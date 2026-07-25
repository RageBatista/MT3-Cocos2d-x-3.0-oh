# 产物校验（CEGUI 0.7.9-r5）

---

## 1. 主要产物位置

- 动态库输出：`bin/`
- 静态库输出：`lib/`
- ReleaseWithSymbols：`bin/ReleaseWithSymbols` / `lib/ReleaseWithSymbols`

---

## 2. 关键动态库检查（Release）

`bin/`：

<!-- 修正日期: 2026-01-28 -->
<!-- 新增: CEGUICocos2DRenderer.dll 校验项 -->

- `CEGUIBase.dll`
- `CEGUIOpenGLRenderer.dll`
- `CEGUIDirect3D9Renderer.dll`
- `CEGUICocos2DRenderer.dll` *(Cocos2D渲染器)*
- `CEGUIOgreRenderer.dll` *(如开启)*
- `CEGUIExpatParser.dll`
- `CEGUIFalagardWRBase.dll`
- `CEGUISILLYImageCodec.dll`
- `CEGUITGAImageCodec.dll`
- `CEGUISTBImageCodec.dll`
- `CEGUILuaScriptModule.dll`

> DevIL/FreeImage/Corona 编解码库仅在依赖齐全时可生成。

---

## 3. 运行时 DLL 检查

将 `dependencies/bin/*.dll` 拷贝到 `bin/`：

- `freetype.dll`, `pcre.dll`, `expat.dll`, `zlib.dll`
- `libpng.dll`, `jpeg.dll`
- `lua.dll`, `toluapp.dll`
- `SILLY.dll`
- `tinyxml.dll` *(仅启用 TinyXML 时)*
- `xerces-c_3.dll` *(仅启用 Xerces 时)*
- `glew.dll`, `glfw.dll` *(仅相关模块/样例)*

---

## 4. 自动校验

### 4.1 脚本位置

- `docs/scripts/Verify-CEGUI-0.7.9-r5.ps1`

### 4.2 用法

```powershell
powershell -ExecutionPolicy Bypass -File tools\CEGUI-0.7.9-r5\docs\scripts\Verify-CEGUI-0.7.9-r5.ps1
```

### 4.3 检查项

- 依赖目录存在性
- 核心依赖库（freetype/pcre/expat/SILLY）
- bin / lib 输出文件
- config.h 默认模块
- Ogre SDK 路径存在性（若 config.lua 使用默认路径）
