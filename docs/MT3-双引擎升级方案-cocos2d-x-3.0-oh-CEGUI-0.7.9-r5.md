# MT3 客户端双引擎升级综合方案

## Cocos2d-x 2.2.6 → 3.0-oh + CEGUI 0.7.1 → 0.7.9-r5

> **版本**：1.1.0
> **制定日期**：2026-07-26
> **修订日期**：2026-07-26
> **状态**：草案
> **依赖文档**：
> - [Cocos2d-x 2.2.6 → 3.0-oh 升级方案](cocos2d-x-2.2.6-to-3.0-oh-upgrade-plan.md)（已存在）
> - [CEGUI 0.7.1 → 0.7.9-r5 迁移升级计划](CEGUI-0.7.9-r5-迁移升级计划.md)（已存在，v1.0.1）

---

## 目录

1. [深度链路分析：MT3 客户端全模块依赖拓扑](#1-深度链路分析mt3-客户端全模块依赖拓扑)
2. [双引擎升级耦合关系分析](#2-双引擎升级耦合关系分析)
3. [系统环境与工具链版本要求](#3-系统环境与工具链版本要求)
4. [集成升级策略与阶段规划](#4-集成升级策略与阶段规划)
5. [合并风险矩阵与缓解措施](#5-合并风险矩阵与缓解措施)
6. [综合时间线与里程碑](#6-综合时间线与里程碑)
7. [验证与验收标准](#7-验证与验收标准)

---

## 1. 深度链路分析：MT3 客户端全模块依赖拓扑

### 1.1 五层依赖链路图

```
┌─────────────────────────────────────────────────────────────────┐
│  Layer 5: 业务脚本层 (Lua)                                       │
│  client/resource/res/script/** (100+ .lua, CEGUI:: + cocos2d::) │
│  client/resource/res/ui/** (200+ .layout, 2 .scheme, 2 .looknfeel)│
└──────────────────────────┬──────────────────────────────────────┘
                           │ CEGUI::WindowManager, tolua++ binding
┌──────────────────────────▼──────────────────────────────────────┐
│  Layer 4: FireClient 业务层 (C++)                                │
│  client/FireClient/Application/** (31 .cpp, 1614 CEGUI:: 引用)   │
│  ├── Manager/ (GameUIManager: 490 CEGUI::, 18 CCDirector)       │
│  ├── Framework/ (LuaFireClient: 297 CEGUI:: + 297 cocos2d::)    │
│  ├── GameUI/ (UISprite: CCSprite, CCNode)                       │
│  ├── SceneObj/ (角色: CCSprite, CCAnimation)                     │
│  └── Battle/ (Battler: 92 CEGUI:: + CCAction/CCSequence)        │
└──────────┬───────────────────────────────┬──────────────────────┘
           │ CEGUI::System                   │ cocos2d::CCDirector
┌──────────▼──────────────┐ ┌───────────────▼──────────────────────┐
│  Layer 3a: CEGUI 0.7.1  │ │  Layer 3b: Nuclear 引擎              │
│  dependencies/cegui/    │ │  engine/                             │
│  ├── Cocos2DRenderer    │ │  ├── EngineApp : CCApplication       │
│  ├── Cocos2DImageCodec  │ │  ├── EngineLayer : CCLayer           │
│  ├── 16 自定义 Falagard │ │  ├── EngineTicker : CCAction         │
│  ├── 20+ 自定义控件     │ │  ├── nucocos2d_wraper (CCDirector,   │
│  ├── LuaScriptModule    │ │  │   CCEGLView, CCScene, CCTouch,    │
│  ├── XMLIOParser        │ │  │   CCShaderCache, CCGLProgram)     │
│  └── PfsResourceProvider│ │  └── nucocos2d_render (CCRenderTexture)│
└──────────┬──────────────┘ └───────────────┬──────────────────────┘
           │ CEGUICocos2DTexture              │ CCNode, CCSprite
           │ CEGUICocos2DRenderer             │ CCDirector, CCTexture
┌──────────▼─────────────────────────────────▼────────────────────┐
│  Layer 2: Cocos2d-x 2.2.6 (含 8 类 MT3 补丁)                    │
│  cocos2d-x-2.2.6/cocos2dx/                                      │
│  ├── CCNode, CCSprite, CCLayer, CCScene, CCDirector             │
│  ├── CCTexture2D, CCTextureCache, CCSpriteFrameCache            │
│  ├── CCAction, CCSequence, CCCallFunc (SEL 选择器回调)           │
│  ├── CCTouchDispatcher, CCTouchDelegate                         │
│  ├── CCArray, CCDictionary, CCSet, CCString                      │
│  ├── CCNotificationCenter, CCUserDefault, CCFileUtils            │
│  ├── CCGLProgram, CCShaderCache (MT3 ETC/HSV/X/Gray Shader)     │
│  ├── CCLuaEngine, CCScriptEngineProtocol (MT3 Lua Bridge)       │
│  ├── SimpleAudioEngine (MT3 Win32 MCI Shim)                     │
│  └── CCTexture2D (MT3 DDS/ATC/PVRTC/ETC 纹理直载)               │
└──────────────────────────┬──────────────────────────────────────┘
                           │ OpenGL/EGL
┌──────────────────────────▼──────────────────────────────────────┐
│  Layer 1: 平台壳层 + 第三方库                                    │
│  ├── Win32: MT3Win32App (WinMain, CCEGLView, v120)              │
│  ├── Android: LocojoyProject (JNI, NDK r16, Ant)                │
│  ├── iOS: FireClient.xcodeproj (ObjC++, EAGLView)               │
│  ├── 第三方: CEGUI 0.7.1, tolua++ 1.0.93, Spine, FMOD, LJFM    │
│  ├── 依赖库: freetype, libpng, zlib, glew, glm (40+ 库)         │
│  └── 资源链: LJFilePack → res_android/res_ios/res_win           │
└─────────────────────────────────────────────────────────────────┘
```

### 1.2 关键耦合点量化统计

| 耦合点 | 涉及文件数 | API 调用次数 | 升级影响等级 |
|--------|-----------|-------------|-------------|
| FireClient → CEGUI | 31 .cpp + 23 .h | 1614 CEGUI:: | **致命** |
| FireClient → Cocos2d-x | 43 .cpp | 2000+ cocos2d:: | **致命** |
| CEGUI → Cocos2d-x (Cocos2DRenderer) | 5 文件 | 直接纹理/渲染 API | **致命** |
| Nuclear → Cocos2d-x (封装层) | 8 文件 | CCDirector, CCScene, CCLayer | **致命** |
| tolua++ → Cocos2d-x (绑定) | 2 生成文件 | 全部 Cocos2d 类型 | **致命** |
| Lua 脚本 → CEGUI | 100+ .lua | CEGUI::WindowManager | **严重** |
| Lua 脚本 → Cocos2d-x | 100+ .lua | CCSprite, CCNode 等 | **严重** |
| GameUIManager → CEGUI | 1 文件 | 490 CEGUI:: | **致命** |
| Spine → Cocos2d-x | 扩展模块 | CCNode, CCTexture | **高** |
| FMOD/音频 → Cocos2d-x | CocosDenshion | SimpleAudioEngine | **中** |

### 1.3 双引擎之间的交叉耦合

CEGUI 0.7.1 的 Cocos2D Renderer 是连接 CEGUI 和 Cocos2d-x 的关键桥梁：

```
CEGUI::System
  → CEGUI::Cocos2DRenderer (继承 CEGUI::Renderer)
    → CEGUICocos2DTexture (基于 CCTexture2D)
    → CEGUICocos2DGeometryBuffer (基于 CCNode/CCSprite 渲染)
    → CEGUICocos2DRenderTarget (基于 CCRenderTexture)
  → CEGUICocos2DImageCodec (基于 CCImage)
```

升级到 Cocos2d-x 3.0-oh 时，Cocos2DRenderer 需要适配：
- `CCTexture2D` → `Texture2D`（3.0 纹理 API 变更）
- `CCImage` → `Image`（3.0 图像 API 变更）
- `CCRenderTexture` → `RenderTexture`（3.0 渲染目标 API 变更）
- 渲染管线从固定管线 → `Renderer` + `RenderCommand` 架构

同时升级 CEGUI 到 0.7.9-r5 时，Cocos2DRenderer 还需要适配：
- CEGUI `Renderer` 基类接口变更（0.7.1 → 0.7.9）
- CEGUI `RenderingSurface`/`RenderingWindow` 新架构

---

## 2. 双引擎升级耦合关系分析

### 2.1 升级路径依赖图

```
                    ┌──────────────────────┐
                    │  Cocos2d-x 2.2.6     │
                    │  + CEGUI 0.7.1       │
                    │  (当前基线)          │
                    └──────┬───────────────┘
                           │
            ┌──────────────┼──────────────┐
            ▼              ▼              ▼
    ┌──────────────┐ ┌───────────┐ ┌──────────────┐
    │ 路径 A:       │ │ 路径 B:   │ │ 路径 C:      │
    │ 先升 Cocos    │ │ 先升 CEGUI│ │ 同时升级     │
    │ 再升 CEGUI    │ │ 再升 Cocos│ │ (推荐)       │
    └──────┬───────┘ └─────┬─────┘ └──────┬───────┘
           │               │              │
           ▼               ▼              ▼
    ┌──────────────────────────────────────────┐
    │  Cocos2d-x 3.0-oh + CEGUI 0.7.9-r5      │
    │  (目标基线)                              │
    └──────────────────────────────────────────┘
```

### 2.2 路径 C（同时升级，推荐）的理由

1. **Cocos2DRenderer 只需适配一次**：如果在 0.7.1 上先适配 Cocos2d-x 3.0，再升级 CEGUI 到 0.7.9-r5 时 Renderer 基类接口已变，需要再次适配。同时升级可直接适配到最终目标。

2. **CEGUI 0.7.9-r5 的 Cocos2DRenderer 移植**：CEGUI 0.7.9-r5 本身不含 Cocos2D Renderer，需要从 0.7.1 移植。移植时直接对接 3.0-oh 的 API，避免两次适配。

3. **构建系统一次性变更**：vcxproj、Android.mk、.clangd 等配置文件只需修改一次，同时切换两个引擎的路径。

4. **减少中间状态的验证成本**：路径 A 和 B 都需要在中间状态（仅升级一个引擎）进行全量验证，而该中间状态不会上线，验证成本浪费。

### 2.3 升级顺序策略

虽然采用路径 C 同时升级，但内部仍有明确的先后顺序：

```
Step 1: Cocos2d-x 3.0-oh 独立编译验证
  → Step 2: CEGUI 0.7.9-r5 独立编译验证
    → Step 3: Cocos2DRenderer 移植（同时对接 3.0-oh + 0.7.9-r5）
      → Step 4: Nuclear 引擎封装层适配 3.0-oh
        → Step 5: FireClient 业务代码适配（Cocos2d + CEGUI 双 API）
          → Step 6: Lua 脚本适配
            → Step 7: 资源文件兼容性验证
              → Step 8: 平台适配（Win32 → Android → iOS → OHOS）
```

---

## 3. 系统环境与工具链版本要求

> **核心问题**：升级到 VS2015+ 后，所有预编译 `.lib` 是否必须重新编译？MT3 的定制组件是否支持 VS2015+ 编译？

### 3.1 工具链现状与目标对比

| 组件 | 当前工具链 | 目标工具链 | 变更说明 |
|------|-----------|-----------|---------|
| Win32 编译器 | VS2013 (v120) | VS2019 (v142，推荐) | Cocos2d-x 3.0-oh 需要 VS2015+ |
| Win32 SDK | Windows SDK 8.1 | Windows 10 SDK | VS2019 内置 |
| Android NDK | NDK r16b clang | NDK r16b+ clang | 保持或升级 |
| Android SDK | android-22 | android-22+ | 保持或升级 |
| JDK | JDK 1.8 | JDK 1.8+ | 保持 |
| CMake | 无 | CMake 3.16+ | 3.0-oh 使用 CMake 构建 |
| Python | 2.7 | 2.7/3.x | 构建脚本兼容 |

### 3.2 各组件 PlatformToolset 现状

| 组件 | 工程文件 | 当前 PlatformToolset | 需升级到 |
|------|---------|---------------------|---------|
| cocos2d-x-3.0-oh | `cocos/2d/cocos2d.vcxproj` | v100 / v110（条件） | v140+ |
| cocos2d-x-3.0-oh | `extensions/proj.win32/libExtensions.vcxproj` | v100 / v110（条件） | v140+ |
| CEGUI-0.7.9-r5 | `tools/CEGUI-0.7.9-r5/cegui-0.7.9.win32.vcxproj` | v120 | v140+ |
| MT3 engine | `engine/engine.win32.vcxproj` | v120 | v140+ |
| MT3 FireClient | `client/MT3Win32App/FireClient.win32.vcxproj` | v120 | v140+ |
| MT3 主程序 | `client/MT3Win32App/mt3.win32.vcxproj` | v120 | v140+ |
| MT3 CEGUI 定制 | `dependencies/cegui/project/win32/cegui.win32.vcxproj` | v120 | v140+ |

> **关键发现**：cocos2d-x-3.0-oh 的 Win32 `.vcxproj` 文件仅配置了 VS2010 (v100) 和 VS2012 (v110) 的工具集条件，未包含 VS2013 (v120) 或 VS2015 (v140)。其 `CCPlatformMacros.h` 中 `_MSC_VER >= 1800`（VS2013）的检查表明代码层面已支持 VS2013+，但工程文件需要手动补充 v140+ 条件，或改用 CMake 构建（推荐）。

### 3.3 预编译 .lib 依赖清单及重新编译必要性

**核心结论：VS2015+ (v140) 引入了 Universal CRT (UCRT)，与 VS2013 (v120) 的 MSVCRT 存在 ABI 硬断裂。所有 v120 及更早版本编译的 .lib 文件必须使用 VS2015+ 工具链重新编译，否则链接阶段将出现大量未解析符号错误（如 `__imp___iob_func`、`__imp___stdio_common_vsprintf` 等）。**

#### 3.3.1 cocos2d-x-3.0-oh 预编译库

| 库文件 | 路径 | 当前工具链 | 需重新编译 | 说明 |
|--------|------|-----------|:--:|------|
| libssl.lib | `external/openssl/prebuilt/win32/` | 未知（预编译） | **是** | 需从源码编译或获取 VS2015+ 版本 |
| libcrypto.lib | `external/openssl/prebuilt/win32/` | 未知（预编译） | **是** | 需从源码编译或获取 VS2015+ 版本 |

> 注：cocos2d-x-3.0-oh 的 `external/` 下大部分依赖（Box2D、chipmunk、freetype、jpeg、png、tiff、webp、lua、curl 等）提供了源码和 CMakeLists.txt，可通过 CMake + VS2015+ 从源码编译，无需依赖预编译库。

#### 3.3.2 MT3 dependencies/ 预编译库

| 库文件 | 路径 | 当前工具链 | 需重新编译 | 说明 |
|--------|------|-----------|:--:|------|
| cegui_d.lib | `dependencies/cegui/project/win32/Debug.win32/` | v120 | **是** | 源码在 `dependencies/cegui/`，可用 v140+ 重编 |
| cegui-0.7.9_d.lib | `dependencies/cegui-0.7.9/` | v120 | **是** | 将使用 `tools/CEGUI-0.7.9-r5/` 源码重编 |
| freetype.lib | `dependencies/freetype-2.4.12/objs/win32/vc2010/` | v100 | **是** | 含源码，需 v140+ 重编 |
| libpng.lib / libpng14.lib | `dependencies/png/prebuilt/` | 未知 | **是** | 含源码，需 v140+ 重编 |
| libjpeg.lib | `dependencies/jpeg/prebuilt/` | 未知 | **是** | 含源码，需 v140+ 重编 |
| zlibstat.lib | `dependencies/zlib-1.2.5/` | 未知 | **是** | 含源码，需 v140+ 重编 |
| glew32.lib | `cocos2d-x-2.2.6/.../libraries/` | 未知 | **是** | 需从 `dependencies/glew-1.7.0/` 源码重编 |
| pcre.lib | `dependencies/pcre-8.31/` | 未知 | **是** | 含源码，需 v140+ 重编 |
| libogg.lib | `dependencies/libogg-1.3.2/` | VS2010 | **是** | 含源码，需 v140+ 重编 |
| libspeex.lib | `dependencies/speex-1.2rc2/` | VS2008 | **是** | 含源码，需 v140+ 重编 |
| libcurl.lib | `dependencies/third-party-rebuild/curl-7.48.0/` | v120 | **是** | 含源码，需 v140+ 重编 |
| libtiff.lib | `dependencies/third-party-rebuild/tiff-4.0.3/` | 未知 | **是** | 含源码，需 v140+ 重编 |
| libEGL.lib / libGLESv2.lib | `dependencies/opengles_v2/Lib/` | 未知 | **是** | 无源码，需获取 VS2015+ 兼容版本 |
| SILLY.lib | `dependencies/SILLY-0.1.0/` | 未知 | **是** | 含源码，需 v140+ 重编 |
| wxWidgets 系列 (30+ 个) | `dependencies/wxWidgets-3.0.5/` | 未知 | **是** | 含源码，需 v140+ 重编 |
| fmodex_vc.lib | `cocos2d-x-2.2.6/external/fmod/` | 未知 | **是** | 无源码，需获取 VS2015+ 兼容版本或替换为 FMOD Studio |

#### 3.3.3 重新编译工作量评估

| 类别 | 库数量 | 预估工时 | 说明 |
|------|--------|---------|------|
| 有源码、有 vcxproj | ~10 个 | 2-3 天 | 修改 PlatformToolset 为 v140 后直接编译 |
| 有源码、无 vcxproj | ~10 个 | 3-5 天 | 需创建 VS2015+ 工程或使用 CMake |
| 无源码（二进制 only） | ~3 个 | 1-3 天 | 需寻找替代版本或获取新版 SDK |
| cocos2d-x-3.0-oh external/ 自带源码 | ~15 个 | 0 天 | 通过 CMake 自动编译 |

> **建议**：优先使用 cocos2d-x-3.0-oh 自带的 CMake 构建系统来编译其 `external/` 下的依赖库（freetype、jpeg、png、tiff、webp、curl、openssl、lua 等），减少手动创建 VS 工程的工作量。MT3 特有的依赖（如 SILLY、speex、pcre 等）需单独处理。

### 3.4 MT3 定制组件 VS2015+ 兼容性评估

#### 3.4.1 代码兼容性扫描结果

| 检查项 | engine/ | FireClient/ | dependencies/cegui/ | cocos2d-x-2.2.6 | cocos2d-x-3.0-oh |
|--------|:---:|:---:|:---:|:---:|:---:|
| `std::auto_ptr`（C++17 移除） | 无 | 无 | 无 | 1 处（CCString.h） | 1 处（deprecated/CCString.h） |
| `std::unary_function`（C++17 移除） | 无 | 无 | 无 | 无 | 无 |
| `std::binary_function`（C++17 移除） | 无 | 无 | 无 | 无 | 无 |
| `sprintf`/`strcpy`（VS2015 废弃警告） | 8 处 | 待验证 | 待验证 | 多处 | 多处 |
| C++11 `override`/`final` | 有使用 | 有使用 | 有使用 | 有使用 | 有使用 |
| C++11 `auto`/`nullptr` | 有使用 | 有使用 | 有使用 | 有使用 | 有使用 |

#### 3.4.2 各组件兼容性结论

| 组件 | VS2015 (v140) | VS2017 (v141) | VS2019+ (v142) | 注意事项 |
|------|:---:|:---:|:---:|------|
| **engine/** | 兼容 | 兼容 | 兼容 | `sprintf`/`strcpy` 需加 `_CRT_SECURE_NO_WARNINGS` 或替换为 `sprintf_s`/`strcpy_s` |
| **FireClient/** | 兼容 | 兼容 | 兼容 | 未发现 `std::auto_ptr` 等 C++17 移除项，兼容性良好 |
| **dependencies/cegui/ (0.7.1)** | 兼容 | 兼容 | 兼容 | 已被 CEGUI-0.7.9-r5 替换，不再单独维护 |
| **cocos2d-x-2.2.6** | 兼容 | 兼容 | 兼容 | 升级后不再使用，仅作参考 |
| **cocos2d-x-3.0-oh** | 兼容 | 兼容 | 兼容 | `CCPlatformMacros.h` 已适配 `_MSC_VER >= 1800`（VS2013+）；`std::auto_ptr` 仅在 deprecated 头中，不影响核心编译 |
| **CEGUI-0.7.9-r5** | 兼容 | 兼容 | 兼容 | 需将 PlatformToolset 从 v120 改为 v140+ |

#### 3.4.3 VS2015 vs VS2017 vs VS2019 选择建议

| VS 版本 | PlatformToolset | 优势 | 劣势 |
|---------|----------------|------|------|
| VS2015 | v140 | 最接近当前 v120，迁移阻力最小 | 已停止主流支持，工具链较老 |
| VS2017 | v141 | 支持 C++17，更好的标准合规性 | `std::auto_ptr` 等会产生警告 |
| **VS2019** (推荐) | v142 | 最新工具链，C++17/20 支持，更好的优化 | `std::auto_ptr` 会报错（仅需修复 2 处 deprecated 头） |

> **推荐 VS2019 (v142)**：虽然 VS2015 迁移阻力最小，但 VS2019 的工具链优化更好，且对 C++14/17 的支持更完善。cocos2d-x-3.0-oh 代码中仅 deprecated 头有 1 处 `std::auto_ptr`（`deprecated/CCString.h`），修复成本极低。同时可选 VS2022 (v143) 作为备选，提供更好的 C++20 支持和更快的编译速度。

### 3.5 构建系统迁移路径

#### 路径 A：手动更新 vcxproj（过渡方案）

1. 在所有 `.vcxproj` 中为 VS2015+ 添加 PlatformToolset 条件
2. 逐个重新编译预编译 `.lib`
3. 解决编译警告和错误
4. **优点**：保持现有 VS 工程结构，团队学习成本低
5. **缺点**：工作量大，需手动维护 50+ 个 vcxproj 文件

#### 路径 B：CMake 统一构建（推荐方案）

1. 利用 cocos2d-x-3.0-oh 自带的 CMake 构建系统
2. 为 engine、FireClient、CEGUI 定制模块编写 CMakeLists.txt
3. 使用 CMake 生成 VS2015+ 解决方案
4. **优点**：与 3.0-oh 上游一致，跨平台统一，易于维护
5. **缺点**：初期 CMake 学习成本，需要为 MT3 定制模块编写 CMake 配置

> **推荐路径 B（CMake）**：cocos2d-x-3.0-oh 的设计就是以 CMake 为核心构建系统，其 `.vcxproj` 文件仅作为历史兼容保留。采用 CMake 可以避免手动维护大量 vcxproj 的 PlatformToolset 条件，且与 Android/iOS/OHOS 平台的构建方式统一。

---

## 4. 集成升级策略与阶段规划

### 4.1 阶段总览

| 阶段 | 内容 | 预估工期 | 参考文档 |
|------|------|---------|---------|
| 阶段 0 | 环境搭建与基线建立（含工具链升级） | 2 周 | 本文 §3 |
| 阶段 1 | Cocos2d-x 3.0-oh 独立编译 | 2 周 | Cocos 方案 §6.2.1 |
| 阶段 2 | CEGUI 0.7.9-r5 独立编译 | 1.5 周 | CEGUI 方案 §2.1 |
| 阶段 3 | Cocos2DRenderer 移植（双引擎桥接） | 3 周 | 本文 §4.2 |
| 阶段 4 | Nuclear 引擎封装层适配 | 2 周 | Cocos 方案 §6.2.2 |
| 阶段 5 | CEGUI 定制模块移植（20+ 控件 + 16 渲染器） | 3 周 | CEGUI 方案 §3.6 |
| 阶段 6 | FireClient 业务代码适配 | 4 周 | Cocos 方案 §7 |
| 阶段 7 | Lua 脚本 + tolua++ 适配 | 2 周 | 本文 §4.3 |
| 阶段 8 | 资源文件兼容性处理 | 1 周 | CEGUI 方案 §1.4 |
| 阶段 9 | 平台适配（Win32/Android/iOS/OHOS） | 4 周 | Cocos 方案 §6.2.5 |
| 阶段 10 | MT3 补丁移植 | 2 周 | 本文 §4.4 |
| 阶段 11 | 测试验证 | 4 周 | 本文 §7 |
| 阶段 12 | 优化与上线 | 3 周 | Cocos 方案 §9 |
| **总计** | | **~31.5 周（约 8 个月）** | |

### 4.2 阶段 3：Cocos2DRenderer 移植（关键桥接）

这是双引擎升级的核心环节，需要同时适配 Cocos2d-x 3.0-oh 和 CEGUI 0.7.9-r5。

#### 4.2.1 适配矩阵

| 组件 | CEGUI 0.7.1 依赖 | CEGUI 0.7.9-r5 目标 | Cocos2d-x 3.0-oh 目标 |
|------|-----------------|--------------------|----------------------|
| **Renderer** | `CEGUI::Renderer` (0.7.1) | `CEGUI::Renderer` (0.7.9，接口变更) | `cocos2d::Renderer` 架构 |
| **Texture** | `CCTexture2D` | `CEGUI::Texture` (0.7.9) | `cocos2d::Texture2D` |
| **GeometryBuffer** | `CEGUI::GeometryBuffer` (0.7.1) | `CEGUI::GeometryBuffer` (0.7.9) | `RenderCommand` 队列 |
| **RenderTarget** | `CCRenderTexture` | `CEGUI::RenderTarget` (0.7.9) | `cocos2d::RenderTexture` |
| **ImageCodec** | `CCImage` | `CEGUI::ImageCodec` (0.7.9) | `cocos2d::Image` |
| **TextureTarget** | `CEGUICocos2DTextureTarget` | 合并到 RenderTarget | 使用 `RenderTexture` |

#### 4.2.2 移植步骤

| 步骤 | 操作 | 涉及文件 | 验收标准 |
|------|------|---------|---------|
| 3.2.1 | 对比 CEGUI Renderer 基类差异 | 0.7.1 vs 0.7.9-r5 `CEGUIRenderer.h` | 差异清单完成 |
| 3.2.2 | 对比 Cocos2d-x 纹理/渲染 API 差异 | 2.2.6 vs 3.0-oh `CCTexture2D.h` / `Texture2D.h` | 差异清单完成 |
| 3.2.3 | 移植 `CEGUICocos2DRenderer` | `.h/.cpp`，适配 3.0-oh Renderer 架构 | 编译通过 |
| 3.2.4 | 移植 `CEGUICocos2DTexture` | `.h/.cpp`，适配 3.0-oh Texture2D | 编译通过 |
| 3.2.5 | 移植 `CEGUICocos2DGeometryBuffer` | `.h/.cpp`，适配 3.0-oh RenderCommand | 编译通过 |
| 3.2.6 | 移植 `CEGUICocos2DRenderTarget` | `.h/.cpp`，适配 3.0-oh RenderTexture | 编译通过 |
| 3.2.7 | 移植 `CEGUICocos2DImageCodec` | `.h/.cpp`，适配 3.0-oh Image | 编译通过 |
| 3.2.8 | 集成测试：CEGUI 初始化 + 基础渲染 | 简单 UI 渲染 | 纹理正确显示，无 GL 错误 |

### 4.3 阶段 7：Lua 脚本 + tolua++ 适配

#### 4.3.1 tolua++ 绑定适配

| 文件 | 2.2.6 类型 | 3.0-oh 类型 | 修改方式 |
|------|-----------|------------|---------|
| `FireClient.pkg` | CCSprite, CCNode, CCLayer | Sprite, Node, Layer | 修改 `.pkg` 绑定定义 |
| `engine.pkg` | CCDirector, CCEGLView | Director, GLView | 修改 `.pkg` 绑定定义 |
| `LuaEngine.cpp` | 生成代码 | 重新生成 | 运行 tolua++ 生成链 |
| `LuaFireClient.cpp` | 生成代码 | 重新生成 | 运行 tolua++ 生成链 |

#### 4.3.2 Lua 脚本适配

| 类别 | 涉及文件 | 变更内容 |
|------|---------|---------|
| CEGUI::WindowManager | 100+ .lua | 验证 API 兼容性（CEGUI 0.7.1 → 0.7.9-r5 Lua 绑定差异） |
| CCSprite/CCNode 调用 | 100+ .lua | 验证 tolua++ 生成后绑定正确性 |
| CEGUI 自定义控件 | 100+ .lua | 验证 ItemCell, SkillBox, RichEditbox 等控件在 Lua 侧可用 |

### 4.4 阶段 10：MT3 补丁移植

Cocos2d-x 2.2.6 上的 8 类 MT3 专属补丁需逐一评估并移植到 3.0-oh：

| 补丁类别 | 3.0-oh 替代方案 | 优先级 | 预估工时 |
|----------|----------------|--------|---------|
| Win32 音频 Shim | 3.0-oh AudioEngine 或保留 FMOD 直接调用 | P0 | 3 天 |
| Shader 兼容 | 3.0-oh GLProgram/ProgramState 重新实现 ETC/HSV/X/Gray | P0 | 5 天 |
| 纹理压缩兼容 | 3.0-oh Texture2D 扩展 DDS/ATC/PVRTC/ETC 支持 | P0 | 4 天 |
| Lua 脚本桥接 | 3.0-oh LuaEngine 适配 CCScriptEngineProtocol | P0 | 3 天 |
| Spine JSON 兼容 | 3.0-oh 内置 Spine 或移植 Json 补丁 | P1 | 2 天 |
| 视频播放器 Shim | 3.0-oh VideoPlayer 或保留 Shim | P2 | 2 天 |
| 照片选择器 Shim | 3.0-oh 平台原生实现或保留 Shim | P2 | 1 天 |
| FireClient 兼容 | tolua++ wstring、LJFM s2ws、CEGUI min/max 宏 | P1 | 2 天 |

---

## 5. 合并风险矩阵与缓解措施

### 5.1 风险等级定义

| 等级 | 定义 | 触发条件 |
|------|------|---------|
| **致命** | 阻塞升级，无 workaround | 核心组件无法编译或运行 |
| **严重** | 可 workaround 但代价大 | 需要大量替代代码 |
| **中等** | 有 workaround | 可接受的功能降级 |
| **低** | 不影响核心功能 | 可延后处理 |

### 5.2 合并风险矩阵

| 风险编号 | 风险描述 | 来源 | 概率 | 影响 | 等级 | 缓解措施 |
|---------|---------|------|------|------|------|---------|
| **R1** | Cocos2DRenderer 双端适配失败 | 双引擎 | 高 | 致命 | **致命** | 阶段 3 作为最高优先级，独立验证渲染管线 |
| **R2** | CEGUI 自定义控件移植失败（20+ 个） | CEGUI | 中 | 致命 | **致命** | 分三批移植，先核心控件再辅助控件 |
| **R3** | Nuclear 封装层适配失败 | Cocos2d | 中 | 致命 | **致命** | EngineApp/EngineLayer/EngineTicker 尽早验证 |
| **R4** | tolua++ 绑定生成不兼容 | 双引擎 | 中 | 严重 | **严重** | 提前验证生成链，准备手动修复 |
| **R5** | CEGUI Lua 绑定 API 变更 | CEGUI | 中 | 严重 | **严重** | 建立 Lua API 兼容性检查脚本 |
| **R6** | 渲染结果不一致 | 双引擎 | 高 | 严重 | **严重** | 建立截图对比工具，逐场景验证 |
| **R7** | MT3 补丁移植遗漏 | Cocos2d | 高 | 严重 | **严重** | 建立补丁 checklist，逐项验证 |
| **R8** | 性能退化 | 双引擎 | 中 | 严重 | **严重** | 每阶段性能基准测试 |
| **R9** | 构建系统迁移耗时过长 | Cocos2d | 中 | 中等 | **中等** | 可先保留 vcxproj 过渡 |
| **R10** | 第三方依赖版本冲突 | 双引擎 | 中 | 中等 | **中等** | 提前梳理版本依赖 |
| **R11** | CEGUI 资源文件格式不兼容 | CEGUI | 低 | 中等 | **中等** | 已验证格式高度兼容（见 CEGUI 方案 §1.4.9） |
| **R12** | OHOS 平台不稳定 | Cocos2d | 高 | 低 | **低** | OHOS 作为可选目标，不影响主平台 |
| **R13** | 预编译 .lib 重编译失败（无源码库） | 双引擎 | 中 | 严重 | **严重** | libEGL/libGLESv2/fmodex 等无源码库需提前确认替代方案 |

### 5.3 关键风险缓解措施

#### R1/R6 缓解：渲染一致性保障

```
1. 建立 Cocos2DRenderer 独立测试工程
   - 先脱离 MT3 主工程，独立验证 CEGUI + Cocos2d-x 3.0-oh 渲染管线
   - 测试基本纹理渲染、几何缓冲、渲染目标
2. 渲染对比工具
   - 同场景、同输入在 2.2.6 和 3.0-oh 上截图对比
   - 像素级对比，超过 5% 差异需人工审核
3. 分阶段验证
   - 阶段 3 完成：基础纹理渲染
   - 阶段 5 完成：自定义控件渲染
   - 阶段 6 完成：完整 UI 场景渲染
```

#### R2 缓解：CEGUI 控件分批移植

```
第一批（核心控件，4 天）：MessageTip, RichEditbox, ItemCell, ItemTable, LinkText
第二批（常用控件，3 天）：ItemListbox, ItemEntry, SkillBox, ProgressBarTwoValue, Switch, AnimateText, AnimationButton
第三批（辅助控件，2 天）：GroupBtnTree, IrregularButton, IrregularFigure, SpecialTree, CompnentTip, Panel 系列
```

#### R3 缓解：Nuclear 封装层独立验证

```
1. EngineApp : Application 生命周期验证
2. EngineLayer : Layer 触摸事件验证
3. EngineTicker : Action 调度验证
4. nucocos2d_render : RenderTexture 渲染目标验证
```

---

## 6. 综合时间线与里程碑

### 6.1 甘特图

```
阶段 0:  环境搭建与基线          ████░░░░░░░░░░░░░░░░░░░░  2 周
阶段 1:  Cocos 3.0-oh 编译       ░░░░████░░░░░░░░░░░░░░░░  2 周
阶段 2:  CEGUI 0.7.9-r5 编译     ░░░░░░░░███░░░░░░░░░░░░░  1.5 周
阶段 3:  Cocos2DRenderer 移植    ░░░░░░░░░░░██████░░░░░░░  3 周     ← 关键路径
阶段 4:  Nuclear 封装层适配      ░░░░░░░░░░░░░░░░████░░░░░  2 周
阶段 5:  CEGUI 定制控件移植      ░░░░░░░░░░░░░░░░░░░██████  3 周
阶段 6:  FireClient 业务适配     ░░░░░░░░░░░░░░░░░░░░░████  4 周
阶段 7:  Lua + tolua++ 适配      ░░░░░░░░░░░░░░░░░░░░░░███  2 周
阶段 8:  资源文件兼容性          ░░░░░░░░░░░░░░░░░░░░░░░░█  1 周
阶段 9:  平台适配               ░░░░░░░░░░░░░░░░░░░░░░░████  4 周
阶段 10: MT3 补丁移植           ░░░░░░░░░░░░░░░░░░░░░░░░██  2 周
阶段 11: 测试验证               ░░░░░░░░░░░░░░░░░░░░░░░░████  4 周
阶段 12: 优化与上线             ░░░░░░░░░░░░░░░░░░░░░░░░░███  3 周
────────────────────────────────────────────────────────────────
总计：约 31.5 周（约 8 个月，含 20% 缓冲）
```

### 6.2 里程碑

| 里程碑 | 时间节点 | 验收标准 |
|--------|---------|---------|
| **M0** | 阶段 0 结束 | 环境就绪，基线建立，分支创建 |
| **M1** | 阶段 1-2 结束 | Cocos2d-x 3.0-oh 和 CEGUI 0.7.9-r5 独立编译通过 |
| **M2** | 阶段 3 结束 | Cocos2DRenderer 移植完成，基础 UI 渲染正常 |
| **M3** | 阶段 4-5 结束 | Nuclear 适配 + CEGUI 控件移植完成，引擎层编译通过 |
| **M4** | 阶段 6-8 结束 | FireClient 全量编译通过，资源文件加载成功 |
| **M5** | 阶段 9-10 结束 | 全平台（Win32/Android/iOS）编译通过，补丁移植完成 |
| **M6** | 阶段 11 结束 | 核心功能回归通过，性能达标 |
| **M7** | 阶段 12 结束 | 灰度发布完成，全量上线 |

### 6.3 关键路径

```
M0 → M1 (Cocos + CEGUI 独立编译)
  → M2 (Cocos2DRenderer 移植) ← 最大风险点
    → M3 (引擎层适配)
      → M4 (业务层迁移)
        → M5 (全平台)
          → M6 (测试)
            → M7 (上线)
```

---

## 7. 验证与验收标准

### 7.1 编译验证门禁

| 门禁 | 条件 | 阶段 |
|------|------|------|
| Cocos2d-x 3.0-oh 独立编译 | Win32 Debug/Release 零错误 | 阶段 1 |
| CEGUI 0.7.9-r5 独立编译 | Win32 Debug/Release 零错误 | 阶段 2 |
| Cocos2DRenderer 编译 | 零错误，基础渲染验证通过 | 阶段 3 |
| Nuclear 引擎编译 | engine.win32.vcxproj 零错误 | 阶段 4 |
| CEGUI 定制模块编译 | 全部 20+ 控件 + 16 渲染器编译通过 | 阶段 5 |
| FireClient 全量编译 | 31 个 C++ 文件零错误 | 阶段 6 |
| tolua++ 绑定生成 | LuaEngine.cpp + LuaFireClient.cpp 生成成功 | 阶段 7 |
| 全平台编译 | Win32 + Android + iOS 零错误 | 阶段 9 |

### 7.2 功能验证门禁

| 门禁 | 条件 | 阶段 |
|------|------|------|
| UI 基础渲染 | CEGUI 初始化 + 纹理显示 + 字体渲染 | 阶段 3 |
| 自定义控件渲染 | 全部 20+ 控件正确渲染 | 阶段 5 |
| 游戏启动流程 | 启动 → CEGUI 初始化 → 登录界面 | 阶段 6 |
| 核心功能回归 | 登录/选角/入世界/战斗/退出 | 阶段 11 |
| Lua 脚本全量加载 | 100+ Lua 文件无报错 | 阶段 7 |
| 资源文件加载 | 全部 .layout/.scheme/.imageset/.font 加载成功 | 阶段 8 |

### 7.3 性能验证门禁

| 指标 | 基准值（2.2.6 + 0.7.1） | 允许偏差 | 阶段 |
|------|------------------------|---------|------|
| FPS | 当前 Release 帧率 | 下降 < 5% | 阶段 11 |
| 内存占用 | 当前内存占用 | 增长 < 10% | 阶段 11 |
| 启动时间 | 当前启动耗时 | 增长 < 20% | 阶段 11 |
| DrawCall | 当前 DrawCall | 增长 < 10% | 阶段 11 |
| APK 大小 | 当前 APK 大小 | 增长 < 20% | 阶段 11 |

---

## 附录 A：快速参考 — 关键 API 对照表

### Cocos2d-x 2.2.6 → 3.0-oh

| 2.2.6 | 3.0-oh |
|-------|--------|
| `CCDirector::sharedDirector()` | `Director::getInstance()` |
| `CCSprite::create("x.png")` | `Sprite::create("x.png")` |
| `CCPoint(x, y)` / `ccp(x,y)` | `Vec2(x, y)` |
| `CCSize(w, h)` / `CCSizeMake(w,h)` | `Size(w, h)` |
| `CCArray::create()` | `Vector<Node*>` |
| `CCDictionary::create()` | `Map<std::string, Node*>` |
| `SEL_CallFunc` / `callfunc_selector` | `CC_CALLBACK_0` / lambda |
| `ccTouchesBegan` | `EventListenerTouchOneByOne::onTouchBegan` |
| `CCLabelTTF::create()` | `Label::createWithTTF()` |
| `CCNotificationCenter` | `NotificationCenter` (deprecated → EventDispatcher) |

### CEGUI 0.7.1 → 0.7.9-r5

| 0.7.1 | 0.7.9-r5 |
|-------|---------|
| `CEGUI::System::create(renderer)` | `CEGUI::System::create(renderer, resourceProvider)` |
| `CEGUI::ImagesetManager` | `CEGUI::ImageManager`（部分重构） |
| `CEGUI::FontManager` | `CEGUI::FontManager`（接口稳定） |
| 无 LayoutContainer | `CEGUI::LayoutContainer` 系列（新增） |
| 无 RenderEffect | `CEGUI::RenderEffectManager`（新增） |

---

## 附录 B：参考文档索引

| 文档 | 路径 | 说明 |
|------|------|------|
| Cocos2d-x 升级方案 | [cocos2d-x-2.2.6-to-3.0-oh-upgrade-plan.md](cocos2d-x-2.2.6-to-3.0-oh-upgrade-plan.md) | Cocos2d-x 单引擎升级详细方案 |
| CEGUI 迁移计划 | [CEGUI-0.7.9-r5-迁移升级计划.md](CEGUI-0.7.9-r5-迁移升级计划.md) | CEGUI 单引擎迁移详细方案 |
| MT3 补丁记录 | [cocos2d-x-2.2.6/MT3_PATCHES.md](../cocos2d-x-2.2.6/MT3_PATCHES.md) | 2.2.6 上的 MT3 专属补丁清单 |
| 项目架构 | [02-技术架构/02-项目架构.md](02-技术架构/02-项目架构.md) | 项目整体架构说明 |
| 构建指南 | [../.claude/BUILD_GUIDE.md](../.claude/BUILD_GUIDE.md) | 当前构建命令和配置 |
| 项目规则 | [../.trae/rules/project_rules.md](../.trae/rules/project_rules.md) | Trae 工作区规则 |

---

> **文档维护**：本文档随项目进展持续更新，与 [Cocos2d-x 升级方案](cocos2d-x-2.2.6-to-3.0-oh-upgrade-plan.md) 和 [CEGUI 迁移计划](CEGUI-0.7.9-r5-迁移升级计划.md) 保持同步。
>
> **审批流程**：技术负责人审核 → 项目经理确认 → 技术委员会批准 → 启动执行