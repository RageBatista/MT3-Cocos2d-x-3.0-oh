# CEGUI 0.7.9-r5 编译构建流程（MT3 适配说明）

**适用范围**: `E:\MT3\tools\CEGUI-0.7.9-r5` 目录内 CEGUI 0.7.9-r5 源码与工程文件。

<!-- 修正日期: 2026-01-28 -->
<!-- 原错误: **工具链**: VS2013 (v120) - 已验证可用。 -->

**工具链**: VS2010 (v100) / VS2013 (v120需适配)

**最后更新**: 2026-01-05

**状态**: ✅ Cocos2DRenderer 模块已成功编译

---

## 最新编译记录 (2026-01-05)

### Cocos2DRenderer 模块

| 配置 | 输出文件 | 大小 | 状态 |
|------|----------|------|------|
| Release | `CEGUICocos2DRenderer.lib` | 2.1 MB | ✅ 成功 |
| Debug | `CEGUICocos2DRenderer_d.lib` | 2.8 MB | ✅ 成功 |

**输出路径**: `projects/win32/lib/$(Configuration).win32/`

**关键配置修复**:
- 添加预处理器宏: `PUBLISHED_VERSION`, `HAVE_CONFIG_H`
- 添加 Include 路径: `common/ljfm/code/include`, `cegui/include/ImageCodecModules/Cocos2DImageCodec`

详细信息请参阅 [CEGUI分析与优化报告](../2026-01-05-CEGUI分析与优化报告-CEGUI-Analysis-And-Optimization-Report.md)

---

## 文档导航（建议阅读顺序）

- `00-文档索引-Documentation-Index.md`
- `02-环境准备-Environment-Setup.md`
- `03-依赖清单-Dependency-Inventory.md`
- `04-从零构建-From-Scratch-Build.md`
- `05-产物校验-Output-Verification.md`
- `08-模块级依赖清单-Module-Dependency-Map.md`
- `11-VS2013-v120适配清单-VS2013-v120-Adaptation.md`

---

## 1. 目录结构与构建入口

```
CEGUI-0.7.9-r5/
├── cegui/                  # 核心源码
├── projects/premake/        # premake 脚本 + VS 解决方案
│   ├── CEGUI.sln            # VS2010 解决方案
│   ├── CEGUISamples.sln     # Samples 解决方案
│   ├── config.lua           # 构建开关
│   ├── cegui.lua            # 模块生成逻辑
│   └── helpers.lua          # 通用构建规则
├── dependencies/            # 预编译依赖与头文件
├── bin/                     # 动态库输出目录
├── lib/                     # 静态库输出目录
├── datafiles/               # GUI 资源
├── Samples/                 # 示例项目源码
└── docs/                    # 构建与分析文档
```

---

## 2. premake 构建配置（config.lua 摘要）

- `WANT_RELEASE_WITH_SYMBOLS_BUILD = true`
- `WANT_STATIC_BUILD = true`
- `STATIC_BUILD_WITH_DYNAMIC_DEPS = false`
- `MINIZIP_RESOURCE_PROVIDER = true`

**渲染器**（默认）：
- OpenGL ✅
- Direct3D9 ✅
- Ogre ✅
- D3D10/D3D11/Irrlicht/Null ❌

**图像编解码**（默认）：
- SILLY / TGA / STB ✅
- DevIL / FreeImage / Corona ✅（但依赖未内置，见 03）

**XML 解析器**（默认）：
- Expat ✅
- Xerces / TinyXML / RapidXML / LibXML ❌

**脚本模块**：
- Lua ✅
- Python ❌

---

## 3. VS 解决方案结构（CEGUI.sln）

核心工程包括：

- `CEGUIBase`
- `CEGUIExpatParser`
- `CEGUIFalagardWRBase`
- `CEGUIOpenGLRenderer`
- `CEGUIDirect3D9Renderer`
- `CEGUIOgreRenderer`
- `CEGUITGAImageCodec`
- `CEGUISILLYImageCodec`
- `CEGUISTBImageCodec`
- `CEGUIFreeImageImageCodec` *(需外部依赖)*
- `CEGUIDevILImageCodec` *(需外部依赖)*
- `CEGUICoronaImageCodec` *(需外部依赖)*
- `CEGUILuaScriptModule`
- `tolua++` / `tolua++cegui`

Samples 工程位于 `CEGUISamples.sln`。

---

## 4. config.h 与默认模块

`cegui/include/config.h` 由 premake 生成，当前关键宏：

- `CEGUI_DEFAULT_XMLPARSER = ExpatParser`
- `CEGUI_DEFAULT_IMAGE_CODEC = SILLYImageCodec`
- `CEGUI_CODEC_SILLY = 1`
- `CEGUI_HAS_MINIZIP_RESOURCE_PROVIDER`

如需切换默认模块，应修改 `projects/premake/config.lua` 并重新生成工程与 `config.h`。
