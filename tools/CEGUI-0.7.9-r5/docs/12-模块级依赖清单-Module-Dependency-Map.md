# 模块级依赖清单（CEGUI 0.7.9-r5）

来源：`projects/premake/**.vcxproj` 的 `AdditionalDependencies`。

---

## 1. 核心模块

| 模块 | Debug 依赖 | Release 依赖 |
| --- | --- | --- |
| CEGUIBase | freetype_d, pcre_d, zlib_d, Winmm | freetype, pcre, zlib, Winmm |
| CEGUIExpatParser | CEGUIBase_d, expat_d | CEGUIBase, expat |
| CEGUIFalagardWRBase | CEGUIBase_d | CEGUIBase |
| CEGUIOpenGLRenderer | CEGUIBase_d, GLU32, OpenGL32 | CEGUIBase, GLU32, OpenGL32 |
| CEGUIDirect3D9Renderer | CEGUIBase_d, d3dx9d, dxerr | CEGUIBase, d3dx9, dxerr |
| CEGUIOgreRenderer | CEGUIBase_d, OgreMain_d | CEGUIBase, OgreMain |

---

## 2. 图像编解码模块

| 模块 | Debug 依赖 | Release 依赖 |
| --- | --- | --- |
| CEGUISILLYImageCodec | CEGUIBase_d, SILLY_d | CEGUIBase, SILLY |
| CEGUITGAImageCodec | CEGUIBase_d | CEGUIBase |
| CEGUISTBImageCodec | CEGUIBase_d | CEGUIBase |
| CEGUIDevILImageCodec | CEGUIBase_d, DevIL_d, ILU_d | CEGUIBase, DevIL, ILU |
| CEGUIFreeImageImageCodec | CEGUIBase_d, FreeImaged | CEGUIBase, FreeImage |
| CEGUICoronaImageCodec | CEGUIBase_d, corona_d | CEGUIBase, corona |

---

## 3. 脚本模块

| 模块 | Debug 依赖 | Release 依赖 |
| --- | --- | --- |
| CEGUILuaScriptModule | CEGUIBase_d, tolua++_d, lua_d | CEGUIBase, tolua++, lua |
| tolua++ | lua_d | lua |
| tolua++cegui | tolua++_d, lua_d | tolua++, lua |