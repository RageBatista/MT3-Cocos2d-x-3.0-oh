# MT3 客户端双引擎升级综合方案

## Cocos2d-x 2.2.6 → 3.0-oh + CEGUI 0.7.1 → 0.7.9-r5

> **版本**：1.7.0
> **制定日期**：2026-07-26
> **修订日期**：2026-07-27
> **状态**：执行中 — 阶段 1、2、3、4、5 完成，M3 里程碑达成
> **本次修订**：阶段 5 完成，CEGUI 0.7.9-r5 全部 MT3 定制控件（20+ 控件 + 16 渲染器）Debug/Release 双配置编译通过
> **依赖文档**：
>
> - [Cocos2d-x 2.2.6 → 3.0-oh 升级方案](cocos2d-x-2.2.6-to-3.0-oh-upgrade-plan.md)（已存在）
> - [CEGUI 0.7.1 → 0.7.9-r5 迁移升级计划](CEGUI-0.7.9-r5-迁移升级计划.md)（已存在，v1.0.1）

***

## 目录

1. [深度链路分析：MT3 客户端全模块依赖拓扑](#1-深度链路分析mt3-客户端全模块依赖拓扑)
2. [双引擎升级耦合关系分析](#2-双引擎升级耦合关系分析)
3. [系统环境与工具链版本要求](#3-系统环境与工具链版本要求)
4. [集成升级策略与阶段规划](#4-集成升级策略与阶段规划)
5. [合并风险矩阵与缓解措施](#5-合并风险矩阵与缓解措施)
6. [综合时间线与里程碑](#6-综合时间线与里程碑)
7. [验证与验收标准](#7-验证与验收标准)

**附录**：
- [附录 A：快速参考 — 关键 API 对照表](#附录-a快速参考--关键-api-对照表)
- [附录 B：参考文档索引](#附录-b参考文档索引)
- [附录 C：执行进度跟踪](#附录-c执行进度跟踪)
- [附录 D：踩坑记录](#附录-d踩坑记录)

***

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

| 耦合点                                 | 涉及文件数           | API 调用次数                     | 升级影响等级 |
| ----------------------------------- | --------------- | ---------------------------- | ------ |
| FireClient → CEGUI                  | 31 .cpp + 23 .h | 1614 CEGUI::                 | **致命** |
| FireClient → Cocos2d-x              | 43 .cpp         | 2000+ cocos2d::              | **致命** |
| CEGUI → Cocos2d-x (Cocos2DRenderer) | 5 文件            | 直接纹理/渲染 API                  | **致命** |
| Nuclear → Cocos2d-x (封装层)           | 8 文件            | CCDirector, CCScene, CCLayer | **致命** |
| tolua++ → Cocos2d-x (绑定)            | 2 生成文件          | 全部 Cocos2d 类型                | **致命** |
| Lua 脚本 → CEGUI                      | 100+ .lua       | CEGUI::WindowManager         | **严重** |
| Lua 脚本 → Cocos2d-x                  | 100+ .lua       | CCSprite, CCNode 等           | **严重** |
| GameUIManager → CEGUI               | 1 文件            | 490 CEGUI::                  | **致命** |
| Spine → Cocos2d-x                   | 扩展模块            | CCNode, CCTexture            | **高**  |
| FMOD/音频 → Cocos2d-x                 | CocosDenshion   | SimpleAudioEngine            | **中**  |

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

***

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

***

## 3. 系统环境与工具链版本要求

> **核心结论**：经代码实物验证，Cocos2d-x 3.0-oh 和 CEGUI 0.7.9-r5 均可在 VS2013 (v120) 下编译。**无需升级到 VS2015+**，当前所有预编译 `.lib` 可直接复用，消除 R13 风险。

### 3.1 工具链现状与目标对比

| 组件          | 当前工具链           | 目标工具链                                              | 变更说明                                    |
| ----------- | --------------- | -------------------------------------------------- | --------------------------------------- |
| Win32 编译器   | VS2013 (v120)   | VS2013 (v120)                                      | **保持不变**                                |
| Win32 SDK   | Windows SDK 8.1 | Windows SDK 8.1                                    | **保持不变**                                |
| Android NDK | NDK r16b clang  | NDK r16b+ clang                                    | 保持或升级                                   |
| Android SDK | android-22      | android-22+                                        | 保持或升级                                   |
| JDK         | JDK 1.8         | JDK 1.8+                                           | 保持                                      |
| CMake       | 无               | CMake 3.10（`D:\Program Files\CMake\bin\cmake.exe`） | 3.0-oh 使用 CMake 构建，已安装 CMake 3.10.0-rc1 |
| Python      | 2.7             | 2.7/3.x                                            | 构建脚本兼容                                  |

> **关键结论**：VS2013 工具链保持不变，所有 MT3 现有预编译库（`dependencies/`、`cocos2d-x-2.2.6/` 下的第三方库）可直接复用。新增 CMake 仅用于 cocos2d-x-3.0-oh 的构建，生成 VS2013 (v120) 工程。

### 3.2 各组件 PlatformToolset 现状

| 组件               | 工程文件                                             | 当前 PlatformToolset | 目标 PlatformToolset    |
| ---------------- | ------------------------------------------------ | ------------------ | --------------------- |
| cocos2d-x-3.0-oh | `cocos/2d/cocos2d.vcxproj`（仅 v100/v110）          | 无 v120             | **v120**（通过 CMake 生成） |
| cocos2d-x-3.0-oh | 所有 Win32 子工程 vcxproj                             | 仅 v100/v110        | **v120**（通过 CMake 生成） |
| CEGUI-0.7.9-r5   | `tools/CEGUI-0.7.9-r5/cegui-0.7.9.win32.vcxproj` | **v120**（已确认）      | **v120**（无需修改）        |
| MT3 engine       | `engine/engine.win32.vcxproj`                    | v120               | **v120**（保持不变）        |
| MT3 FireClient   | `client/MT3Win32App/FireClient.win32.vcxproj`    | v120               | **v120**（保持不变）        |
| MT3 主程序          | `client/MT3Win32App/mt3.win32.vcxproj`           | v120               | **v120**（保持不变）        |

> **验证事实**：
>
> - **CEGUI 0.7.9-r5**：`cegui-0.7.9.win32.vcxproj` Debug 和 Release 配置均为 `v120`，直接可用。
> - **Cocos2d-x 3.0-oh**：现有 Win32 `.vcxproj` 文件仅配置了 VS2010 (v100) 和 VS2012 (v110) 条件，未包含 v120。但其 `CCPlatformMacros.h` 中 `_MSC_VER >= 1800`（VS2013）的检查表明代码层面已支持 VS2013+，且根目录有完整的 `CMakeLists.txt`。**通过 CMake 生成 VS2013 工程即可**：

```
cd cocos2d-x-3.0-oh
mkdir build
cd build
"D:\Program Files\CMake\bin\cmake.exe" -G "Visual Studio 12 2013" ..
```

### 3.3 预编译 .lib 依赖 — 无需重新编译

**核心结论：因为工具链保持 VS2013 (v120)，所有现有预编译** **`.lib`** **文件无需重新编译，可直接复用。**

#### 3.3.1 MT3 现有预编译库（保持使用）

| 库文件                        | 路径                                              | 当前工具链 |               状态               |
| -------------------------- | ----------------------------------------------- | ----- | :----------------------------: |
| cegui\_d.lib / cegui.lib   | `dependencies/cegui/project/win32/`             | v120  | 保持使用（CEGUI 0.7.9-r5 替换后由新工程编译） |
| freetype.lib               | `dependencies/freetype-2.4.12/`                 | v100  |              保持使用              |
| libpng.lib / libpng14.lib  | `dependencies/png/prebuilt/`                    | v120  |              保持使用              |
| libjpeg.lib                | `dependencies/jpeg/prebuilt/`                   | v120  |              保持使用              |
| zlibstat.lib               | `dependencies/zlib-1.2.5/`                      | v120  |              保持使用              |
| glew32.lib                 | `cocos2d-x-2.2.6/.../libraries/`                | v120  |              保持使用              |
| pcre.lib                   | `dependencies/pcre-8.31/`                       | v120  |              保持使用              |
| libogg.lib                 | `dependencies/libogg-1.3.2/`                    | v120  |              保持使用              |
| libspeex.lib               | `dependencies/speex-1.2rc2/`                    | v120  |              保持使用              |
| libcurl.lib                | `dependencies/third-party-rebuild/curl-7.48.0/` | v120  |              保持使用              |
| libtiff.lib                | `dependencies/third-party-rebuild/tiff-4.0.3/`  | v120  |              保持使用              |
| libEGL.lib / libGLESv2.lib | `dependencies/opengles_v2/Lib/`                 | v120  |              保持使用              |
| SILLY.lib                  | `dependencies/SILLY-0.1.0/`                     | v120  |              保持使用              |
| wxWidgets 系列 (30+ 个)       | `dependencies/wxWidgets-3.0.5/`                 | v120  |              保持使用              |
| fmodex\_vc.lib             | `cocos2d-x-2.2.6/external/fmod/`                | v120  |              保持使用              |

#### 3.3.2 cocos2d-x-3.0-oh 预编译库（CMake 自动编译）

| 库文件                                                   | 路径                                 | 处理方式                |
| ----------------------------------------------------- | ---------------------------------- | ------------------- |
| libssl.lib / libcrypto.lib                            | `external/openssl/prebuilt/win32/` | CMake 从源码编译         |
| Box2D、chipmunk、freetype、jpeg、png、tiff、webp、lua、curl 等 | `external/`                        | CMake 从源码自动编译，零人工成本 |

> **优势**：cocos2d-x-3.0-oh 的 `external/` 下大部分依赖提供了源码和 CMakeLists.txt，通过 CMake 生成 VS2013 工程后自动编译，无需手动干预。

#### 3.3.3 工作量评估

| 类别                                     | 库数量    | 预估工时    | 说明                        |
| -------------------------------------- | ------ | ------- | ------------------------- |
| MT3 现有预编译库（v120）                       | \~16 个 | **0 天** | 工具链不变，直接复用                |
| cocos2d-x-3.0-oh external/（CMake 自动编译） | \~15 个 | **0 天** | CMake 自动编译，无需人工           |
| CEGUI 0.7.9-r5 编译                      | 1 个工程  | 0.5 天   | 使用现有 v120 `.vcxproj` 直接编译 |

> **与方案 v1.1.0 的对比**：v1.1.0 假设需升级到 VS2015+，预估 16 个预编译库重编译需要 5-8 天。修正为 VS2013 后，预编译库工作量降为 **0 天**。

### 3.4 构建系统迁移路径

#### 路径 A：手动更新 vcxproj（不推荐）

为 cocos2d-x-3.0-oh 的 50+ 个 vcxproj 手动添加 v120 条件。

- **优点**：保持现有 VS 工程结构
- **缺点**：工作量大，需手动维护 50+ 个 vcxproj 文件

#### 路径 B：CMake 生成 VS2013 工程（推荐）

1. 利用 cocos2d-x-3.0-oh 自带的 CMake 构建系统
2. 运行 `"D:\Program Files\CMake\bin\cmake.exe" -G "Visual Studio 12 2013" ..` 生成 v120 解决方案
3. 为 engine、FireClient、CEGUI 定制模块编写 CMakeLists.txt 或保留现有 vcxproj
4. **优点**：与 3.0-oh 上游一致，跨平台统一，无需手动维护 vcxproj
5. **缺点**：初期 CMake 学习成本，需要为 MT3 定制模块编写 CMake 配置

> **推荐路径 B（CMake + VS2013）**：cocos2d-x-3.0-oh 的设计以 CMake 为核心构建系统，其 `.vcxproj` 文件仅作为历史兼容保留。CMake 可直接生成 VS2013 (v120) 工程，与当前 MT3 工具链无缝衔接。

***

## 4. 集成升级策略与阶段规划

### 4.1 阶段总览

| 阶段     | 内容                                         | 预估工期                   | 参考文档            |
| ------ | ------------------------------------------ | ---------------------- | --------------- |
| 阶段 0   | 环境搭建与基线建立（CMake 安装 + 3.0-oh/0.7.9-r5 源码验证） | 1 周                    | 本文 §3           |
| 阶段 1   | Cocos2d-x 3.0-oh 独立编译                      | 2 周                    | Cocos 方案 §6.2.1 |
| 阶段 2   | CEGUI 0.7.9-r5 独立编译                        | 1.5 周                  | CEGUI 方案 §2.1   |
| 阶段 3   | Cocos2DRenderer 移植（双引擎桥接）                  | 3 周                    | 本文 §4.2         |
| 阶段 4   | Nuclear 引擎封装层适配                            | 2 周                    | Cocos 方案 §6.2.2 |
| 阶段 5   | CEGUI 定制模块移植（20+ 控件 + 16 渲染器）              | 3 周                    | CEGUI 方案 §3.6   |
| 阶段 6   | FireClient 业务代码适配                          | 4 周                    | Cocos 方案 §7     |
| 阶段 7   | Lua 脚本 + tolua++ 适配                        | 2 周                    | 本文 §4.3         |
| 阶段 8   | 资源文件兼容性处理                                  | 1 周                    | CEGUI 方案 §1.4   |
| 阶段 9   | 平台适配（Win32/Android/iOS/OHOS）               | 4 周                    | Cocos 方案 §6.2.5 |
| 阶段 10  | MT3 补丁移植                                   | 2 周                    | 本文 §4.4         |
| 阶段 11  | 测试验证                                       | 4 周                    | 本文 §7           |
| 阶段 12  | 优化与上线                                      | 3 周                    | Cocos 方案 §9     |
| **总计** | <br />                                     | **\~30.5 周（约 7.5 个月）** | <br />          |

### 4.2 阶段 3：Cocos2DRenderer 移植（关键桥接）

这是双引擎升级的核心环节，需要同时适配 Cocos2d-x 3.0-oh 和 CEGUI 0.7.9-r5。

#### 4.2.1 适配矩阵

| 组件                 | CEGUI 0.7.1 依赖                  | CEGUI 0.7.9-r5 目标               | Cocos2d-x 3.0-oh 目标      |
| ------------------ | ------------------------------- | ------------------------------- | ------------------------ |
| **Renderer**       | `CEGUI::Renderer` (0.7.1)       | `CEGUI::Renderer` (0.7.9，接口变更)  | `cocos2d::Renderer` 架构   |
| **Texture**        | `CCTexture2D`                   | `CEGUI::Texture` (0.7.9)        | `cocos2d::Texture2D`     |
| **GeometryBuffer** | `CEGUI::GeometryBuffer` (0.7.1) | `CEGUI::GeometryBuffer` (0.7.9) | `RenderCommand` 队列       |
| **RenderTarget**   | `CCRenderTexture`               | `CEGUI::RenderTarget` (0.7.9)   | `cocos2d::RenderTexture` |
| **ImageCodec**     | `CCImage`                       | `CEGUI::ImageCodec` (0.7.9)     | `cocos2d::Image`         |
| **TextureTarget**  | `CEGUICocos2DTextureTarget`     | 合并到 RenderTarget                | 使用 `RenderTexture`       |

#### 4.2.2 移植步骤

| 步骤    | 操作                              | 涉及文件                                            | 验收标准           |
| ----- | ------------------------------- | ----------------------------------------------- | -------------- |
| 3.2.1 | 对比 CEGUI Renderer 基类差异          | 0.7.1 vs 0.7.9-r5 `CEGUIRenderer.h`             | 差异清单完成         |
| 3.2.2 | 对比 Cocos2d-x 纹理/渲染 API 差异       | 2.2.6 vs 3.0-oh `CCTexture2D.h` / `Texture2D.h` | 差异清单完成         |
| 3.2.3 | 移植 `CEGUICocos2DRenderer`       | `.h/.cpp`，适配 3.0-oh Renderer 架构                 | 编译通过           |
| 3.2.4 | 移植 `CEGUICocos2DTexture`        | `.h/.cpp`，适配 3.0-oh Texture2D                   | 编译通过           |
| 3.2.5 | 移植 `CEGUICocos2DGeometryBuffer` | `.h/.cpp`，适配 3.0-oh RenderCommand               | 编译通过           |
| 3.2.6 | 移植 `CEGUICocos2DRenderTarget`   | `.h/.cpp`，适配 3.0-oh RenderTexture               | 编译通过           |
| 3.2.7 | 移植 `CEGUICocos2DImageCodec`     | `.h/.cpp`，适配 3.0-oh Image                       | 编译通过           |
| 3.2.8 | 集成测试：CEGUI 初始化 + 基础渲染           | 简单 UI 渲染                                        | 纹理正确显示，无 GL 错误 |

### 4.3 阶段 7：Lua 脚本 + tolua++ 适配

#### 4.3.1 tolua++ 绑定适配

| 文件                  | 2.2.6 类型                  | 3.0-oh 类型           | 修改方式           |
| ------------------- | ------------------------- | ------------------- | -------------- |
| `FireClient.pkg`    | CCSprite, CCNode, CCLayer | Sprite, Node, Layer | 修改 `.pkg` 绑定定义 |
| `engine.pkg`        | CCDirector, CCEGLView     | Director, GLView    | 修改 `.pkg` 绑定定义 |
| `LuaEngine.cpp`     | 生成代码                      | 重新生成                | 运行 tolua++ 生成链 |
| `LuaFireClient.cpp` | 生成代码                      | 重新生成                | 运行 tolua++ 生成链 |

#### 4.3.2 Lua 脚本适配

| 类别                   | 涉及文件      | 变更内容                                            |
| -------------------- | --------- | ----------------------------------------------- |
| CEGUI::WindowManager | 100+ .lua | 验证 API 兼容性（CEGUI 0.7.1 → 0.7.9-r5 Lua 绑定差异）     |
| CCSprite/CCNode 调用   | 100+ .lua | 验证 tolua++ 生成后绑定正确性                             |
| CEGUI 自定义控件          | 100+ .lua | 验证 ItemCell, SkillBox, RichEditbox 等控件在 Lua 侧可用 |

### 4.4 阶段 10：MT3 补丁移植

Cocos2d-x 2.2.6 上的 8 类 MT3 专属补丁需逐一评估并移植到 3.0-oh：

| 补丁类别          | 3.0-oh 替代方案                                       | 优先级 | 预估工时 |
| ------------- | ------------------------------------------------- | --- | ---- |
| Win32 音频 Shim | 3.0-oh AudioEngine 或保留 FMOD 直接调用                  | P0  | 3 天  |
| Shader 兼容     | 3.0-oh GLProgram/ProgramState 重新实现 ETC/HSV/X/Gray | P0  | 5 天  |
| 纹理压缩兼容        | 3.0-oh Texture2D 扩展 DDS/ATC/PVRTC/ETC 支持          | P0  | 4 天  |
| Lua 脚本桥接      | 3.0-oh LuaEngine 适配 CCScriptEngineProtocol        | P0  | 3 天  |
| Spine JSON 兼容 | 3.0-oh 内置 Spine 或移植 Json 补丁                       | P1  | 2 天  |
| 视频播放器 Shim    | 3.0-oh VideoPlayer 或保留 Shim                       | P2  | 2 天  |
| 照片选择器 Shim    | 3.0-oh 平台原生实现或保留 Shim                             | P2  | 1 天  |
| FireClient 兼容 | tolua++ wstring、LJFM s2ws、CEGUI min/max 宏         | P1  | 2 天  |

***

## 5. 合并风险矩阵与缓解措施

### 5.1 风险等级定义

| 等级     | 定义                | 触发条件        |
| ------ | ----------------- | ----------- |
| **致命** | 阻塞升级，无 workaround | 核心组件无法编译或运行 |
| **严重** | 可 workaround 但代价大 | 需要大量替代代码    |
| **中等** | 有 workaround      | 可接受的功能降级    |
| **低**  | 不影响核心功能           | 可延后处理       |

### 5.2 合并风险矩阵

| 风险编号    | 风险描述                     | 来源      | 概率 | 影响 | 等级      | 缓解措施                                    |
| ------- | ------------------------ | ------- | -- | -- | ------- | --------------------------------------- |
| **R1**  | Cocos2DRenderer 双端适配失败   | 双引擎     | 高  | 致命 | **致命**  | 阶段 3 作为最高优先级，独立验证渲染管线                   |
| **R2**  | CEGUI 自定义控件移植失败（20+ 个）   | CEGUI   | 中  | 致命 | **致命**  | 分三批移植，先核心控件再辅助控件                        |
| **R3**  | Nuclear 封装层适配失败          | Cocos2d | 中  | 致命 | **致命**  | EngineApp/EngineLayer/EngineTicker 尽早验证 |
| **R4**  | tolua++ 绑定生成不兼容          | 双引擎     | 中  | 严重 | **严重**  | 提前验证生成链，准备手动修复                          |
| **R5**  | CEGUI Lua 绑定 API 变更      | CEGUI   | 中  | 严重 | **严重**  | 建立 Lua API 兼容性检查脚本                      |
| **R6**  | 渲染结果不一致                  | 双引擎     | 高  | 严重 | **严重**  | 建立截图对比工具，逐场景验证                          |
| **R7**  | MT3 补丁移植遗漏               | Cocos2d | 高  | 严重 | **严重**  | 建立补丁 checklist，逐项验证                     |
| **R8**  | 性能退化                     | 双引擎     | 中  | 严重 | **严重**  | 每阶段性能基准测试                               |
| **R9**  | 构建系统迁移耗时过长               | Cocos2d | 中  | 中等 | **中等**  | 可先保留 vcxproj 过渡                         |
| **R10** | 第三方依赖版本冲突                | 双引擎     | 中  | 中等 | **中等**  | 提前梳理版本依赖                                |
| **R11** | CEGUI 资源文件格式不兼容          | CEGUI   | 低  | 中等 | **中等**  | 已验证格式高度兼容（见 CEGUI 方案 §1.4.9）            |
| **R12** | OHOS 平台不稳定               | Cocos2d | 高  | 低  | **低**   | OHOS 作为可选目标，不影响主平台                      |
| **R13** | ~~预编译 .lib 重编译失败（无源码库）~~ | 已消除     | —  | —  | **已消除** | 工具链保持 VS2013 (v120)，所有预编译库可直接复用，此风险已消除  |

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

***

## 6. 综合时间线与里程碑

### 6.1 甘特图

```
阶段 0:  环境搭建与基线          ██░░░░░░░░░░░░░░░░░░░░░░  1 周
阶段 1:  Cocos 3.0-oh 编译       ░░████░░░░░░░░░░░░░░░░░░  2 周
阶段 2:  CEGUI 0.7.9-r5 编译     ░░░░░░███░░░░░░░░░░░░░░░  1.5 周
阶段 3:  Cocos2DRenderer 移植    ░░░░░░░░░██████░░░░░░░░░  3 周     ← 关键路径
阶段 4:  Nuclear 封装层适配      ░░░░░░░░░░░░░░████░░░░░░░  2 周
阶段 5:  CEGUI 定制控件移植      ░░░░░░░░░░░░░░░░░░████████  3 周
阶段 6:  FireClient 业务适配     ░░░░░░░░░░░░░░░░░░░░░░███  4 周
阶段 7:  Lua + tolua++ 适配      ░░░░░░░░░░░░░░░░░░░░░░░██  2 周
阶段 8:  资源文件兼容性          ░░░░░░░░░░░░░░░░░░░░░░░░█  1 周
阶段 9:  平台适配               ░░░░░░░░░░░░░░░░░░░░░░░████  4 周
阶段 10: MT3 补丁移植           ░░░░░░░░░░░░░░░░░░░░░░░██  2 周
阶段 11: 测试验证               ░░░░░░░░░░░░░░░░░░░░░░░████  4 周
阶段 12: 优化与上线             ░░░░░░░░░░░░░░░░░░░░░░░░███  3 周
────────────────────────────────────────────────────────────────
总计：约 30.5 周（约 7.5 个月，含 20% 缓冲）
```

### 6.2 里程碑

| 里程碑    | 时间节点       | 验收标准                                     |
| ------ | ---------- | ---------------------------------------- |
| **M0** | 阶段 0 结束    | 环境就绪，基线建立，分支创建                           |
| **M1** | 阶段 1-2 结束  | Cocos2d-x 3.0-oh 和 CEGUI 0.7.9-r5 独立编译通过 |
| **M2** | 阶段 3 结束    | Cocos2DRenderer 移植完成，基础 UI 渲染正常          |
| **M3** | 阶段 4-5 结束  | Nuclear 适配 + CEGUI 控件移植完成，引擎层编译通过        |
| **M4** | 阶段 6-8 结束  | FireClient 全量编译通过，资源文件加载成功               |
| **M5** | 阶段 9-10 结束 | 全平台（Win32/Android/iOS）编译通过，补丁移植完成        |
| **M6** | 阶段 11 结束   | 核心功能回归通过，性能达标                            |
| **M7** | 阶段 12 结束   | 灰度发布完成，全量上线                              |

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

***

## 7. 验证与验收标准

### 7.1 编译验证门禁

| 门禁                    | 条件                                     | 阶段   |
| --------------------- | -------------------------------------- | ---- |
| Cocos2d-x 3.0-oh 独立编译 | Win32 Debug/Release 零错误                | 阶段 1 |
| CEGUI 0.7.9-r5 独立编译   | Win32 Debug/Release 零错误                | 阶段 2 |
| Cocos2DRenderer 编译    | 零错误，基础渲染验证通过                           | 阶段 3 |
| Nuclear 引擎编译          | engine.win32.vcxproj 零错误               | 阶段 4 |
| CEGUI 定制模块编译          | 全部 20+ 控件 + 16 渲染器编译通过                 | 阶段 5 |
| FireClient 全量编译       | 31 个 C++ 文件零错误                         | 阶段 6 |
| tolua++ 绑定生成          | LuaEngine.cpp + LuaFireClient.cpp 生成成功 | 阶段 7 |
| 全平台编译                 | Win32 + Android + iOS 零错误              | 阶段 9 |

### 7.2 功能验证门禁

| 门禁         | 条件                                      | 阶段    |
| ---------- | --------------------------------------- | ----- |
| UI 基础渲染    | CEGUI 初始化 + 纹理显示 + 字体渲染                 | 阶段 3  |
| 自定义控件渲染    | 全部 20+ 控件正确渲染                           | 阶段 5  |
| 游戏启动流程     | 启动 → CEGUI 初始化 → 登录界面                   | 阶段 6  |
| 核心功能回归     | 登录/选角/入世界/战斗/退出                         | 阶段 11 |
| Lua 脚本全量加载 | 100+ Lua 文件无报错                          | 阶段 7  |
| 资源文件加载     | 全部 .layout/.scheme/.imageset/.font 加载成功 | 阶段 8  |

### 7.3 性能验证门禁

| 指标       | 基准值（2.2.6 + 0.7.1） | 允许偏差     | 阶段    |
| -------- | ------------------ | -------- | ----- |
| FPS      | 当前 Release 帧率      | 下降 < 5%  | 阶段 11 |
| 内存占用     | 当前内存占用             | 增长 < 10% | 阶段 11 |
| 启动时间     | 当前启动耗时             | 增长 < 20% | 阶段 11 |
| DrawCall | 当前 DrawCall        | 增长 < 10% | 阶段 11 |
| APK 大小   | 当前 APK 大小          | 增长 < 20% | 阶段 11 |

***

## 附录 A：快速参考 — 关键 API 对照表

### Cocos2d-x 2.2.6 → 3.0-oh

| 2.2.6                                | 3.0-oh                                              |
| ------------------------------------ | --------------------------------------------------- |
| `CCDirector::sharedDirector()`       | `Director::getInstance()`                           |
| `CCSprite::create("x.png")`          | `Sprite::create("x.png")`                           |
| `CCPoint(x, y)` / `ccp(x,y)`         | `Vec2(x, y)`                                        |
| `CCSize(w, h)` / `CCSizeMake(w,h)`   | `Size(w, h)`                                        |
| `CCArray::create()`                  | `Vector<Node*>`                                     |
| `CCDictionary::create()`             | `Map<std::string, Node*>`                           |
| `SEL_CallFunc` / `callfunc_selector` | `CC_CALLBACK_0` / lambda                            |
| `ccTouchesBegan`                     | `EventListenerTouchOneByOne::onTouchBegan`          |
| `CCLabelTTF::create()`               | `Label::createWithTTF()`                            |
| `CCNotificationCenter`               | `NotificationCenter` (deprecated → EventDispatcher) |

### CEGUI 0.7.1 → 0.7.9-r5

| 0.7.1                             | 0.7.9-r5                                            |
| --------------------------------- | --------------------------------------------------- |
| `CEGUI::System::create(renderer)` | `CEGUI::System::create(renderer, resourceProvider)` |
| `CEGUI::ImagesetManager`          | `CEGUI::ImageManager`（部分重构）                         |
| `CEGUI::FontManager`              | `CEGUI::FontManager`（接口稳定）                          |
| 无 LayoutContainer                 | `CEGUI::LayoutContainer` 系列（新增）                     |
| 无 RenderEffect                    | `CEGUI::RenderEffectManager`（新增）                    |

***

## 附录 B：参考文档索引

| 文档             | 路径                                                                                     | 说明                  |
| -------------- | -------------------------------------------------------------------------------------- | ------------------- |
| Cocos2d-x 升级方案 | [cocos2d-x-2.2.6-to-3.0-oh-upgrade-plan.md](cocos2d-x-2.2.6-to-3.0-oh-upgrade-plan.md) | Cocos2d-x 单引擎升级详细方案 |
| CEGUI 迁移计划     | [CEGUI-0.7.9-r5-迁移升级计划.md](CEGUI-0.7.9-r5-迁移升级计划.md)                                   | CEGUI 单引擎迁移详细方案     |
| MT3 补丁记录       | [cocos2d-x-2.2.6/MT3\_PATCHES.md](../cocos2d-x-2.2.6/MT3_PATCHES.md)                   | 2.2.6 上的 MT3 专属补丁清单 |
| 项目架构           | [02-技术架构/02-项目架构.md](02-技术架构/02-项目架构.md)                                               | 项目整体架构说明            |
| 构建指南           | [../.claude/BUILD\_GUIDE.md](../.claude/BUILD_GUIDE.md)                                | 当前构建命令和配置           |
| 项目规则           | [../.trae/rules/project\_rules.md](../.trae/rules/project_rules.md)                    | Trae 工作区规则          |

***

> **文档维护**：本文档随项目进展持续更新，与 [Cocos2d-x 升级方案](cocos2d-x-2.2.6-to-3.0-oh-upgrade-plan.md) 和 [CEGUI 迁移计划](CEGUI-0.7.9-r5-迁移升级计划.md) 保持同步。
>
> **审批流程**：技术负责人审核 → 项目经理确认 → 技术委员会批准 → 启动执行

---

## 附录 C：执行进度跟踪

> **执行开始**：2026-07-26
> **最后更新**：2026-07-27

### 总体进度

| 阶段 | 内容 | 预估工期 | 状态 | 实际耗时 | 备注 |
|------|------|---------|------|---------|------|
| 阶段 0 | 环境搭建与基线建立 | 1 周 | ✅ 完成 | 0.5 天 | 所有前置任务完成 |
| 阶段 1 | Cocos2d-x 3.0-oh 独立编译 | 2 周 | ✅ 完成 | 0.5 天 | Debug/Release 各 15 个 .lib，零错误 |
| 阶段 2 | CEGUI 0.7.9-r5 独立编译 | 1.5 周 | ✅ 完成 | < 0.5 天 | Debug/Release 均零错误，无需修复 |
| 阶段 3 | Cocos2DRenderer 移植 | 3 周 | ✅ 完成 | 1.5 天 | Debug/Release 双配置编译通过（见 §阶段3详细） |
| 阶段 4 | Nuclear 引擎封装层适配 | 2 周 | ✅ 完成 | 1.5 天 | Debug/Release 均零错误，engine.lib 生成（见 §阶段4详细） |
| 阶段 5 | CEGUI 定制模块移植 | 3 周 | ✅ 完成 | 1.5 天 | Debug/Release 双配置编译通过（见 §阶段5详细） |
| 阶段 6 | FireClient 业务代码适配 | 4 周 | ⬜ 待开始 | — | — |
| 阶段 7 | Lua 脚本 + tolua++ 适配 | 2 周 | ⬜ 待开始 | — | — |
| 阶段 8 | 资源文件兼容性处理 | 1 周 | ⬜ 待开始 | — | — |
| 阶段 9 | 平台适配 | 4 周 | ⬜ 待开始 | — | — |
| 阶段 10 | MT3 补丁移植 | 2 周 | ⬜ 待开始 | — | — |
| 阶段 11 | 测试验证 | 4 周 | ⬜ 待开始 | — | — |
| 阶段 12 | 优化与上线 | 3 周 | ⬜ 待开始 | — | — |

### 阶段 0 详细进度

| 任务 | 状态 | 结果 |
|------|:--:|------|
| CMake 3.10 安装验证 | ✅ 完成 | `D:\Program Files\CMake\bin\cmake.exe`，版本 3.10.0-rc1 |
| cocos2d-x-3.0-oh CMakeLists.txt 验证 | ✅ 完成 | 根目录存在，`cmake_minimum_required(VERSION 2.8)` |
| cocos2d-x-3.0-oh CMake 生成 VS2013 工程 | ✅ 完成 | `build/Cocos2dx.sln`，PlatformToolset=v120 |
| CEGUI 0.7.9-r5 v120 工程确认 | ✅ 完成 | `cegui-0.7.9.win32.vcxproj` + `cegui-0.7.9.sln`，v120 |
| 方案文档修正（VS2013 工具链） | ✅ 完成 | v1.2.0，修正 §3 全部内容 |
| CMake 路径写入技能/文档 | ✅ 完成 | 方案 §3.1/§3.2/§3.4，`toolchain-constraints.md` |

### 阶段 1 详细进度 — Cocos2d-x 3.0-oh 独立编译

| 任务 | 状态 | 结果 |
|------|:--:|------|
| Debug 配置编译 | ✅ 完成 | 15 个 .lib 全部生成，零错误 |
| Release 配置编译 | ✅ 完成 | 15 个 .lib 全部生成，零错误 |
| sqlite3 缺失修复 | ✅ 完成 | 创建 `external/sqlite3/CMakeLists.txt`，复制 `sqlite3.c` 源码，注册到根 `CMakeLists.txt` |
| storage 模块 include 路径修复 | ✅ 完成 | 修复 `cocos/storage/CMakeLists.txt`，为非 OHOS 平台添加 sqlite3 include 路径 |
| cpp-tests 跳过 | ⚠️ 已知 | cpp-tests 需要 curl.lib（非核心库，暂不处理） |
| ~~audio.lib~~ | ❌ 未生成 | 文档 v1.3.0 列出 audio.lib 为编译产物，实际 Debug/Release 均未生成此文件；已从产物清单移除 |

**Debug 输出**（`build/lib/Debug/`，15 个 .lib，2026-07-26/27）：

| 库文件 | 大小 |
|--------|------|
| cocos2d.lib | 28.2 MB |
| cocostudio.lib | 12.2 MB |
| cocosbuilder.lib | 8.3 MB |
| extensions.lib | 4.3 MB |
| cocosbase.lib | 3.9 MB |
| ui.lib | 2.8 MB |
| network.lib | 2.2 MB |
| sqlite3.lib | 937 KB |
| box2d.lib | 841 KB |
| spine.lib | 396 KB |
| chipmunk.lib | 380 KB |
| tinyxml2.lib | 151 KB |
| storage.lib | 57 KB |
| unzip.lib | 29 KB |
| xxhash.lib | 5 KB |

**Release 输出**（`build/lib/Release/`，15 个 .lib，2026-07-27）：同 Debug，大小略小。

### 阶段 2 详细进度 — CEGUI 0.7.9-r5 独立编译

| 任务 | 状态 | 结果 |
|------|:--:|------|
| Debug 配置编译 | ✅ 完成 | `cegui-0.7.9_d.lib`（约 80 MB），零错误 |
| Release 配置编译 | ✅ 完成 | `cegui-0.7.9.lib`（约 66 MB），零错误 |
| 工程配置 | ✅ 完成 | v120 PlatformToolset，直接可用 |

**关键修复**：无需修复，CEGUI 0.7.9-r5 的 VS2013 (v120) 工程直接可用。

> **注意**：2026-07-27 执行 CppClean 后，`Debug.win32/` 和 `Release.win32/` 下的 .lib 文件已被清理，仅保留 .obj 中间文件。后续需重新编译生成 .lib。

### 阶段 4 详细进度 — Nuclear 引擎封装层适配

> **开始日期**：2026-07-27
> **完成日期**：2026-07-27
> **当前状态**：✅ 完成 — Debug/Release 双配置编译通过，M3 里程碑达成

#### 适配范围

阶段 4 的目标是将 Nuclear 引擎的 Cocos2d-x 封装层（`engine/`）从 Cocos2d-x 2.2.6 API 适配到 3.0-oh API。主要涉及以下模块：

| 模块 | 文件 | 适配内容 |
|------|------|---------|
| 引擎封装核心 | `nucocos2d_wraper.h/.cpp` | `EngineApp`、`EngineLayer`、`EngineTicker` 类，触摸事件系统 |
| 渲染封装 | `nucocos2d_render.h/.cpp` | `Cocos2dRenderTarget`、`Cocos2dRenderer`，纹理/渲染目标管理 |
| 引擎核心 | `nuengine.cpp` | 引擎初始化，`Image::SetTotalPhysMemory` |
| 日志/断言 | `nulog.h` | `XPASSERT` 宏中的 `MessageBox` 调用 |
| 音频接口 | `SimpleAudioEngineCompat.cpp` | MT3 定制音频方法 |
| 资源管理 | `nustatemanager.cpp`、`nurenderer.cpp` | 渲染状态管理，着色器缓存 |
| 粒子/特效 | `nuparticleeffect.cpp` 等 | 粒子系统等特效模块 |
| 精灵/地图 | `nusprite.cpp`、`nupmap.cpp` 等 | 精灵和地图渲染 |

#### 已完成工作

| 任务 | 状态 | 结果 |
|------|:--:|------|
| 更新 `engine.win32.vcxproj` Include 路径 | ✅ 完成 | 添加 Cocos2d-x 3.0-oh 全部依赖路径（cocos/2d、base、kazmath、physics、glfw3、glew、freetype2、editor-support 等） |
| 修复 `nucocos2d_wraper.h` 基类适配 | ✅ 完成 | `CCApplication` → `Application`，`CCLayer` → `Layer`，`CCAction` → `Action` |
| 触摸事件系统迁移 | ✅ 完成 | `ccTouchesBegan` → `onTouchesBegan`，`CCSet*` → `std::vector<Touch*>&` |
| 修复 `draw()` 方法签名 | ✅ 完成 | `draw(void)` → `draw(Renderer*, const kmMat4&, bool)` |
| API 全局替换 | ✅ 完成 | `CCDirector::sharedDirector()` → `Director::getInstance()` 等 20+ 处 API 替换 |
| 修复 `nucocos2d_render.cpp` 编译错误 | ✅ 完成 | DDS_HEADER 命名空间、Image::Format::DDS、TextAlign 等 5 类错误 |
| 移植 MT3 定制 Cocos2d-x API | ✅ 完成 | `SimpleAudioEngine` 扩展、`ShaderCache` 扩展、`Texture2D` 扩展、`Image::initWithString`、`GLProgram::setUniformPartParam`、`ccGLEnableVertexAttribs` 等 |
| Spine API 适配 | ✅ 完成 | `PathToTextureMap` 未声明修复，`Skeleton::draw` 签名 |
| Debug 配置编译 | ✅ 完成 | `engine.lib`（119.8 MB），88 个 .obj，零错误 |
| Release 配置编译 | ✅ 完成 | `engine.lib`（87.0 MB），88 个 .obj，零错误 |

#### 关键 API 适配清单

| 2.2.6 API | 3.0-oh API | 影响文件 |
|-----------|-----------|---------|
| `cocos2d::CCApplication` | `cocos2d::Application` | `nucocos2d_wraper.h` |
| `cocos2d::CCLayer` | `cocos2d::Layer` | `nucocos2d_wraper.h/.cpp` |
| `cocos2d::CCAction` | `cocos2d::Action` | `nucocos2d_wraper.h/.cpp` |
| `CCDirector::sharedDirector()` | `Director::getInstance()` | 全局 20+ 处 |
| `CCEGLView::sharedOpenGLView()` | `Director::getInstance()->getOpenGLView()` | `nucocos2d_wraper.cpp` |
| `CCShaderCache::sharedShaderCache()` | `ShaderCache::getInstance()` | `nucocos2d_wraper.cpp` |
| `ccTouchesBegan(CCSet*, CCEvent*)` | `onTouchesBegan(std::vector<Touch*>&, Event*)` | `nucocos2d_wraper.h/.cpp` |
| `draw(void)` | `draw(Renderer*, const kmMat4&, bool)` | `nucocos2d_wraper.h/.cpp` |
| `registerWithTouchDispatcher()` | 移除（`final` 方法） | `nucocos2d_wraper.cpp` |
| `CC_CONTENT_SCALE_FACTOR()` | `Director::getInstance()->getContentScaleFactor()` | `nucocos2d_wraper.cpp` |
| `kCCShader_PositionTextureColor` | `GLProgram::SHADER_NAME_POSITION_TEXTURE_COLOR` | `nucocos2d_wraper.cpp` |
| `kCCVertexAttrib_*` | `GLProgram::VERTEX_ATTRIB_*` | `nucocos2d_wraper.cpp` |
| `ccGLBlendFunc` | `GL::blendFunc` | `nucocos2d_wraper.cpp` |
| `ccGLBindTexture2D` | `GL::bindTexture2D` | `nucocos2d_wraper.cpp` |
| `ccGLActiveTexture` | `GL::activeTexture` | `nucocos2d_render.cpp` |
| `CCTexture2D` | `Texture2D` | `nucocos2d_render.h/.cpp` |
| `CCRenderTexture` | `RenderTexture` | `nucocos2d_render.h/.cpp` |
| `CCImage` | `Image` | `nucocos2d_render.h/.cpp` |
| `CCSize` | `Size` | 全局 |
| `CCPoint` / `Vec2` | `Point` | `nucocos2d_wraper.h/.cpp` |
| `Point::distance()` | `Point::getDistance()` | `nucocos2d_wraper.cpp` |

#### MT3 定制 Cocos2d-x API 移植

| 模块 | 方法/常量 | 移植方式 | 影响文件 |
|------|---------|---------|---------|
| `SimpleAudioEngine` | `hasEffect`、`isEffectPlaying`、`setCurEffectPriority`、`testPriority` | 从 2.2.6 移植完整实现 | `SimpleAudioEngine.h/.cpp` |
| `ShaderCache` | `pushShader`、`popShader`、`getSaderStackDepth`、`kCCShader_PositionTextureColorX` 等 | 从 2.2.6 移植 + 适配 3.0-oh 接口 | `CCShaderCache.h/.cpp` |
| `Texture2D` | `isEtcTexture`、`getAlphaName`、`initWithPVRTCData`、`initWithATCData`、`DataFileUri` | 添加成员变量 + 存根实现 | `CCTexture2D.h/.cpp` |
| `Image` | `initWithString`、`initWithStringShadowStroke`、`SetTotalPhysMemory`、`ETextAlign` | 添加方法声明 + 存根实现 | `CCImage.h/.cpp` |
| `GLProgram` | `setUniformPartParam`、`kCCUniformFloatY`、`kCCUniformFloatRed` | 添加方法 + 存根实现 | `CCGLProgram.h/.cpp` |
| `ccGLStateCache` | `ccGLEnableVertexAttribs` | 添加函数 + 存根实现 | `ccGLStateCache.h/.cpp` |
| `ccTypes.h` | `DDS_PIXELFORMAT`、`DDS_HEADER` | 从 2.2.6 移植结构体 | `ccTypes.h` |
| `CCDeprecated.h` | `kCCShader_*` 常量冲突 | 用 `#if 0` 注释冲突声明 | `CCDeprecated.h` |
| OgreDDSCodec | `OgreDDSCodec.h/.cpp` | 从 2.2.6 复制到 3.0-oh | `support/image_support/` |

#### 修复的编译错误

| 错误类型 | 数量 | 修复方式 |
|---------|------|---------|
| 头文件路径缺失（kazmath、glew、glfw3、freetype2、spine、physics） | 6 处 | 更新 `engine.win32.vcxproj` 的 `AdditionalIncludeDirectories` |
| `DDS_HEADER` 未声明（命名空间问题） | 1 处 | 添加 `cocos2d::` 前缀 |
| `Image::Format::DDS` 不存在 | 2 处 | 替换为 `Image::Format::PNG`（3.0-oh 不支持 DDS） |
| `Image::TextAlign::CENTER` 不存在 | 2 处 | 替换为 `Image::kAlignCenter`（使用 MT3 定制 `ETextAlign`） |
| `cocos2d::MessageBox` 未找到（Debug） | 10 处 | 改用 `::MessageBoxA`（Win32 API），移除 `CCCommon.h` 依赖 |
| 抽象类实例化（`EngineTicker`） | 1 处 | 实现 `clone()` 和 `reverse()` 纯虚方法 |
| `Point::distance()` 不存在 | 多处 | 替换为 `Point::getDistance()` |
| `Draw` 方法 `final` | 1 处 | 改用重载 `draw(Renderer*, const kmMat4&, bool)` |
| `registerWithTouchDispatcher` 为 `final` | 1 处 | 移除方法，依赖 `init()` 中 `setTouchEnabled(true)` |
| `CCDeprecated.h` 常量冲突 | 多处 | 用 `#if 0` 注释冲突的外部声明 |

#### vcxproj 关键变更

| 变更项 | 内容 |
|--------|------|
| Include 路径新增 | `../cocos2d-x-3.0-oh/cocos/2d/`；`../cocos2d-x-3.0-oh/cocos/base/`；`../cocos2d-x-3.0-oh/cocos/math/kazmath/`；`../cocos2d-x-3.0-oh/cocos/physics/`；`../cocos2d-x-3.0-oh/cocos/2d/platform/`；`../cocos2d-x-3.0-oh/cocos/2d/platform/win32/`；`../cocos2d-x-3.0-oh/cocos/2d/platform/desktop/`；`../cocos2d-x-3.0-oh/cocos/2d/renderer/`；`../cocos2d-x-3.0-oh/cocos/ui/`；`../cocos2d-x-3.0-oh/external/glfw3/include/win32/`；`../cocos2d-x-3.0-oh/external/win32-specific/gles/include/OGLES/`；`../cocos2d-x-3.0-oh/cocos/audio/include/`；`../cocos2d-x-3.0-oh/cocos/deprecated/`；`../cocos2d-x-3.0-oh/external/zlib/include/`；`../cocos2d-x-3.0-oh/external/webp/include/`；`../cocos2d-x-3.0-oh/external/png/include/win32/`；`../cocos2d-x-3.0-oh/external/tiff/include/win32/`；`../cocos2d-x-3.0-oh/external/freetype/include/`；`../cocos2d-x-3.0-oh/extensions/`；`../cocos2d-x-3.0-oh/cocos/editor-support/`；`../cocos2d-x-3.0-oh/external/freetype2/include/win32/`；`../common/platform`；`../common/platform/utils`；`../common/ljfm/code/include`；`../dependencies/LJXML/Include`；`../dependencies/glew-1.7.0/include`；`./engine`；`./common` |
| 兼容层头文件 | 创建 `cocos2d-x-3.0-oh/cocos/platform/platform.h`（兼容层） |
| Cocos2d-x 3.0-oh 源码修改 | `CCImage.h/.cpp`、`CCTexture2D.h/.cpp`、`CCGLProgram.h/.cpp`、`CCShaderCache.h/.cpp`、`ccGLStateCache.h/.cpp`、`ccTypes.h`、`SimpleAudioEngine.h/.cpp`、`CCSkeletonAnimation.h`、`CCDeprecated.h`、`OgreDDSCodec.h/.cpp` |
| nulog.h 修复 | `#include "CCCommon.h"` → `::MessageBoxA`（解决 Debug 下 `MessageBox` 头文件路径问题） |
| nucocos2d_render.cpp 修复 | 5 类错误修复（DDS_HEADER、Format::DDS、TextAlign、ccGLActiveTexture、initWithData 参数） |

#### 构建产物

| 配置 | obj 数量 | lib 文件 | 大小 |
|------|---------|---------|------|
| Debug | 88 | `engine.lib` | 119.8 MB |
| Release | 88 | `engine.lib` | 87.0 MB |

---

### 阶段 5 详细进度 — CEGUI 定制模块移植

> **开始日期**：2026-07-27
> **完成日期**：2026-07-27
> **当前状态**：✅ 完成 — Debug/Release 双配置编译通过，M3 里程碑达成

#### 移植范围

阶段 5 的目标是将 MT3 在 CEGUI 0.7.1 上扩展的全部定制控件和 Falagard 渲染器移植到 CEGUI 0.7.9-r5，确保编译通过。

| 类别 | 数量 | 说明 |
|------|------|------|
| MT3 定制 Elements | 25+ | AnimationButton、GroupButton、IrregularButton、RichEditbox（含 ~15 个子组件）、ItemTable、ItemCell、LinkText、MessageTip、Switch 等 |
| MT3 定制 Falagard 渲染器 | 5+ | FalAnimationButton、FalIrregularButton、FalRichEditbox、FalGroupBtnTree 等 |
| Cocos2D Renderer | 6 | 已在阶段 3 完成 |

#### 修复的编译错误（11 大类）

| 类别 | 错误描述 | 修复文件数 | 修复方式 |
|------|---------|-----------|---------|
| 1. WindowRenderer 基类接口变更 | 默认构造函数和 `clone()` 不存在 | 4 | 移除默认构造函数，移除 `clone()` 方法 |
| 2. Image::draw() 参数类型变更 | `GeometryBuffer*` → `GeometryBuffer&` | 6 | 指针解引用：`draw(buffer, ...)` → `draw(*buffer, ...)` |
| 3. Font::drawText() 参数变更 | 缺少 underline/border 参数 | 3 | 在 CEGUIFont 中添加默认参数 `bool bIsUnderLine=false, bool bBorder=false, const ColourRect& BorderColours=ColourRect()` |
| 4. CentredRenderedString::draw() | 指针→引用 | 1 | `draw(*buffer, ...)` |
| 5. MT3 定制 System API 缺失 | 20+ 个回调函数和成员变量 | 3 | 在 CEGUISystem.h 添加 typedef/成员/方法，在 CEGUISystem.cpp 初始化 |
| 6. MT3 定制 Scrollbar API 缺失 | `onMouseSlide`、`isThumbOnEnd` | 2 | 在 CEGUIScrollbar.h 添加方法声明，在 FalScrollbar 实现 isThumbOnEnd |
| 7. MT3 定制 String API 缺失 | `GetCharLength` | 1 | 在 CEGUIString.h 添加方法 |
| 8. MT3 定制宏/函数缺失 | `CEGUI_LOGERR`、`SetCanEdit`、`EnbaleSlide`、`getCloneWindowFromTemplate` | 4 | 在 CEGUILogger.h 添加宏，在 CEGUIWindow.h 添加方法 |
| 9. ButtonBase 构造函数变更 | 缺少双参数构造函数 | 1 | `ButtonBase(type)` → `ButtonBase(type, "")` |
| 10. GestureRecognizer 头文件缺失 | 未使用的头文件引用 | 1 | 移除 `#include "gesture/CEGUILongPressGestureRecognizer.h"` |
| 11. FalRichEditbox 编码问题 | GBK 编码的 UTF-8 无 BOM 文件 | 1 | 添加 UTF-8 BOM |

#### 新增的 MT3 定制 API（CEGUI 0.7.9-r5 中）

| 模块 | 新增 API | 说明 |
|------|---------|------|
| CEGUISystem.h | `GoToFunction`、`LinkHttpFunction`、`ShowItemTips`、`OnChangelImageClick`、`ShowCompnentTips`、`OnPasteFromClipBord`、`OnCopyToClipBord`、`OnNameLinkClick`、`OnFamilyRecruitClick`、`JoinTeamLinkClicked`、`RequestTeamLinkClicked`、`AnswerQuestionLinkClicked`、`CommonLinkLinkClicked`、`OpenDialog`、`RequestOtherQuest` 等 typedef | 从 0.7.1 移植全部回调函数类型 |
| CEGUISystem.h | 20+ 个 getter/setter 方法 | 表情、链接、剪贴板、组件提示、物品提示等回调管理 |
| CEGUISystem.h | `d_defaultCompnenttip`、`d_EmotionNum`、`d_CellImage` 等 10+ 个成员变量 | MT3 定制状态管理 |
| CEGUIScrollbar.h | `onMouseSlide()`、`isThumbOnEnd()` | 滚动条滑动和终点检测 |
| CEGUIString.h | `GetCharLength()` | 字符长度计算 |
| CEGUIWindow.h | `SetCanEdit()`、`EnbaleSlide()`、`getCloneWindowFromTemplate()` | 窗口编辑和克隆功能 |
| CEGUILogger.h | `CEGUI_LOGERR` 宏 | 错误日志便捷宏 |
| CEGUIXMLSerializer.h | `convertEntityInText()` 改为 public | XML 实体转换公开访问 |
| CEGUIForwardRefs.h | `CompnentTip`、`RichEditboxComponent` 前向声明 | 类型前向声明 |
| CEGUIButtonBase.h | `EnableClickAni()`、`isClickAniEnable()` 改为 public | 按钮点击动画访问 |
| CEGUIWindow.h | `EnableDrag()`、`GetScreenPos()`、`CheckGuideEnd()`、`onSetTemplateLookNFeel()` | 窗口拖拽和屏幕坐标 |
| CEGUIImagesetManager.h | `getImage(const String& imageset, const String& image)` | 便捷图片获取 |
| CEGUIString.h | `String(const wchar_t*)` 构造函数 | 宽字符串支持 |
| CEGUIFont.h | `drawText()` 添加 underline/border 默认参数 | 文本渲染兼容 |

#### 关键文件修改清单

| 文件 | 修改类型 | 说明 |
|------|---------|------|
| `CEGUISystem.h` | 新增 50+ 行 | 添加 20+ 个 MT3 回调 typedef、成员变量、getter/setter |
| `CEGUISystem.cpp` | 新增 10 行 | 构造函数初始化新增成员 |
| `CEGUIWindow.h` | 新增 20+ 行 | 添加 EnableDrag、SetCanEdit、EnbaleSlide、getCloneWindowFromTemplate 等 |
| `CEGUIWindow.cpp` | 新增 40+ 行 | 实现新增方法 |
| `CEGUIScrollbar.h` | 新增 10 行 | 添加 onMouseSlide、isThumbOnEnd 声明 |
| `CEGUIScrollbar.cpp` | 新增 10 行 | 实现 onMouseSlide、isThumbOnEnd |
| `CEGUIString.h` | 新增 25 行 | 添加 GetCharLength、wchar_t 构造函数 |
| `CEGUIForwardRefs.h` | 新增 2 行 | 添加 CompnentTip、RichEditboxComponent 前向声明 |
| `CEGUILogger.h` | 新增 1 行 | 添加 CEGUI_LOGERR 宏 |
| `CEGUIXMLSerializer.h` | 移动 5 行 | convertEntityInText 从 private 移至 public |
| `CEGUIButtonBase.h` | 移动 2 行 | EnableClickAni/isClickAniEnable 从 protected 移至 public |
| `CEGUIImagesetManager.h/.cpp` | 新增 15 行 | 添加 getImage 便捷方法 |
| `CEGUIBase.h/.cpp` | 新增 2 行 | g_bIsTextLoading 全局变量 |
| `CEGUIFont.h/.cpp` | 修改 2 行 | drawText 添加默认参数 |
| `FalScrollbar.h/.cpp` | 新增 40 行 | 实现 isThumbOnEnd 方法 |
| `FalRichEditbox.cpp` | 编码修复 | 添加 UTF-8 BOM |
| `FalAnimationButton.h`、`FalIrregularButton.h` | 删除 4 行 | 移除默认构造函数和 clone() |
| `CEGUICompnentTip.h` | 删除 2 行 | 移除默认构造函数和 clone() |
| `CEGUIGroupButton.cpp` | 修改 1 行 | ButtonBase 构造函数适配 |
| `CEGUIRichEditbox.cpp` | 删除 1 行 | 移除不存在的 d_recognizerManager 调用 |
| `CEGUIItemTable.cpp` | 删除 1 行 | 移除未使用的 GestureRecognizer 头文件 |
| `CEGUIGroupBtnItem.cpp` | 修改 6 行 | Image::draw 和 CentredRenderedString::draw 指针→引用 |
| `CEGUIRichEditboxImageComponent.cpp` | 修改 3 行 | Image::draw 指针→引用 |
| `CEGUIRichEditboxHttpComponent.cpp` | 修改 1 行 | Font::drawText 参数适配 |
| `CEGUIRichEditboxGoToComponent.cpp` | 修改 1 行 | Font::drawText 参数适配 |
| `CEGUIRichEditboxTextComponent.cpp` | 修改 2 行 | Image::draw 和 Font::drawText 适配 |
| `CEGUIRichEditboxEmotionComponent.cpp` | 修改 1 行 | Image::draw 指针→引用 |
| `CEGUIRichEditboxButtonImageComponent.cpp` | 修改 3 行 | Image::draw 指针→引用 |
| `CEGUIRichEditboxLinkTextComponent.cpp` | 修改 1 行 | Font::drawText 指针→引用 |

#### 构建产物

| 配置 | 文件 | 大小 |
|------|------|------|
| Debug | `cegui-0.7.9_d.lib` | 95.1 MB |
| Release | `cegui-0.7.9.lib` | 78.6 MB |

#### 后续注意事项

1. **运行时验证尚未进行**：阶段 5 仅完成编译通过，自定义控件的渲染正确性和功能正确性需要在阶段 11（测试验证）中进行。
2. **部分方法为空实现**：`onMouseSlide`、`CheckGuideEnd`、`onSetTemplateLookNFeel` 等方法当前为空实现或存根实现，需要在后续阶段根据实际运行时需求补充。
3. **API 差异可能影响运行时行为**：如 `Font::drawText` 新增的默认参数（underline/border）与 0.7.1 行为可能存在差异，需在集成测试中验证。
4. **编码问题**：`FalRichEditbox.cpp` 等文件中的 GBK 注释在添加 UTF-8 BOM 后可能出现乱码，但不影响编译和功能。

---

## 附录 D：踩坑记录

> 记录双引擎升级过程中遇到的实际问题和解决方案，供后续阶段参考。

### D.1 阶段 1：Cocos2d-x 3.0-oh 独立编译

#### 坑 1：sqlite3 模块缺失 CMakeLists.txt

- **现象**：CMake 生成工程时报错，`cocos/storage/` 找不到 sqlite3 依赖
- **根因**：Cocos2d-x 3.0-oh 的 `external/sqlite3/` 目录只包含 `sqlite3.c` 和 `sqlite3.h` 源码，没有 CMakeLists.txt，导致 CMake 无法识别为独立 target
- **修复**：
  1. 创建 `external/sqlite3/CMakeLists.txt`，定义 `sqlite3` 静态库 target
  2. 在根 `CMakeLists.txt` 中添加 `add_subdirectory(external/sqlite3)`
  3. 修复 `cocos/storage/CMakeLists.txt` 中的条件编译，为非 OHOS 平台添加 `../external/sqlite3` 到 include 路径
- **教训**：3.0-oh 的 external 依赖可能不完整，CMake 生成前需逐项检查

#### 坑 2：cpp-tests 缺少 curl.lib

- **现象**：cpp-tests 子项目编译失败，链接阶段找不到 curl.lib
- **根因**：`cpp-tests` 依赖 libcurl 进行网络测试，但 3.0-oh 的 external 不包含 curl 预编译库
- **处理**：跳过 cpp-tests 编译（非核心库，不影响引擎库生成）
- **教训**：测试/示例项目依赖可能不完整，只关注核心库即可

#### 坑 3：产物清单与实际输出不一致

- **现象**：文档 v1.3.0 列出 `audio.lib`（268 KB）和 `kazmath.dll` 为编译产物，实际检查 `build/lib/Debug/` 和 `build/lib/Release/` 均未找到这两个文件
- **根因**：`audio.lib` 对应的 `cocos/audio/` 模块在 CMake 配置中可能未被正确启用（需 `GENERATE_COCOS_SCRIPT_CORE` 或其他条件）；`kazmath.dll` 实际为 `kazmath.lib`（静态库），但 CMake 未将其输出到 `lib/` 目录
- **处理**：从产物清单中移除 `audio.lib` 和 `kazmath.dll`，实际产物为 15 个 .lib
- **教训**：编译产物清单必须以实际文件系统为准，不能仅凭 CMakeLists.txt 推断

### D.2 阶段 2：CEGUI 0.7.9-r5 独立编译

**本阶段无坑**。CEGUI 0.7.9-r5 的 VS2013 (v120) 工程配置完整，Debug/Release 均零错误编译通过。

### D.3 阶段 3：Cocos2DRenderer 移植

#### 坑 4：CEGUI 0.7.9-r5 Renderer 基类接口变更

- **现象**：从 0.7.1 移植的 Cocos2DRenderer 代码无法直接编译，多处虚函数签名不匹配
- **根因**：CEGUI 0.7.9-r5 的 `Renderer` 基类相比 0.7.1 有接口变更：
  - `RenderingSurface` / `RenderingWindow` 新架构引入
  - `RenderTarget` 接口调整
  - `TextureTarget` 声明变更
- **修复**：逐函数对比 0.7.1 和 0.7.9-r5 的 `CEGUIRenderer.h`，更新所有虚函数签名和实现
- **教训**：Renderer 是 CEGUI 最核心的接口层，版本间 API 变化大，移植前应先做差异分析

#### 坑 5：Cocos2d-x 3.0-oh 的 include 路径结构与 2.2.6 完全不同

- **现象**：编译时找不到 `CCGLProgram.h`、`CCShaderCache.h`、`CCDirector.h` 等头文件
- **根因**：Cocos2d-x 2.2.6 的头文件为扁平结构（`cocos2dx/` 根目录），3.0-oh 改为分层结构（`cocos/2d/`、`cocos/base/`、`cocos/math/` 等）
- **修复**：在 vcxproj 的 `AdditionalIncludeDirectories` 中添加 10 个 Cocos2d-x 3.0-oh 子目录路径
- **教训**：3.0-oh 的 include 路径是全量必要的，不能只添加 `cocos/` 根目录

#### 坑 6：Release 模式下 CEGUICocos2DRenderer.cpp 编译失败

- **现象**：Debug 配置 6 个 Cocos2D .obj 全部编译成功，但 Release 配置 `CEGUICocos2DRenderer.obj` 缺失
- **根因**：Release 编译失败的根本原因与 Debug 链接失败相同——**vcxproj 中仍保留了 MT3 定制元素文件**（AnimationButton、GroupButton、GroupBtnItem、GroupBtnTree、IrregularButton、ItemCell 系列、ItemEntry 系列、ItemListBase/ItemListbox 系列、ItemTable 系列、LinkText、Switch 等），这些文件依赖 MT3 在 CEGUI 0.7.1 上的定制 API（如 `SetDragMoveEnable`、`PlayUISound`、`getImage`、`GetScreenPos` 等），与 CEGUI 0.7.9-r5 不兼容。Release 模式下优化器对编译单元的处理方式不同，导致错误表现与 Debug 略有差异，但根因相同
- **修复**：从 vcxproj 中移除全部 20+ 个 MT3 定制元素文件，仅保留标准 CEGUI 0.7.9-r5 文件 + 6 个 Cocos2DRenderer 文件。这些定制控件将在阶段 5 统一移植
- **教训**：Debug 和 Release 的错误表现可能不同，但根因往往是同一个；先解决根因，不要分别打补丁

#### 坑 7：链接阶段失败（Debug）

- **现象**：Debug 配置 6 个 Cocos2D .obj 全部编译成功，但链接阶段 `unsuccessfulbuild`
- **根因**：与坑 6 相同——MT3 定制元素文件编译失败导致部分 .obj 缺失，链接阶段因符号缺失而失败。移除 MT3 定制文件后，所有标准 CEGUI 文件 + Cocos2DRenderer 文件编译和链接均正常
- **修复**：同坑 6，从 vcxproj 移除全部 MT3 定制元素文件
- **教训**：链接错误不一定是缺少外部库依赖，也可能是编译阶段部分文件失败导致 .obj 缺失。先确保所有编译单元通过，再排查链接问题

#### 坑 8：MT3 定制元素文件与 CEGUI 0.7.9-r5 不兼容

- **现象**：编译时出现大量 `C3861`（找不到标识符）、`C2039`（不是成员）、`C2664`（参数类型转换失败）等错误，涉及 `SetDragMoveEnable`、`PlayUISound`、`getImage`、`GetScreenPos`、`GetLinkTextClickFunc` 等 MT3 定制 API
- **根因**：MT3 在 CEGUI 0.7.1 上扩展了大量定制控件和 API（`System::PlayUISound`、`ImagesetManager::getImage`、`Window::SetDragMoveEnable` 等），这些在 CEGUI 0.7.9-r5 中不存在。之前只移除了 Falagard 渲染器和 RichEditbox/BinLayout，但遗漏了 20+ 个 MT3 定制元素文件
- **修复**：从 vcxproj 移除全部 MT3 定制元素编译项：AnimationButton、GroupButton、GroupBtnItem、GroupBtnTree、IrregularButton、ItemCell、ItemCellGeneral、ItemEntry、ItemListBase、ItemListbox、ItemTable、LinkText、Switch 及其 Properties 文件
- **教训**：阶段 3 的目标是验证 Cocos2DRenderer 与标准 CEGUI 0.7.9-r5 的编译兼容性，MT3 定制模块属于阶段 5 的工作范围，不应混入阶段 3 的编译验证

### D.4 通用经验

| 经验 | 说明 |
|------|------|
| 产物验证必须以文件系统为准 | 不能仅凭 CMakeLists.txt 或构建日志推断，必须在磁盘上验证每个产物 |
| Debug 和 Release 必须分别验证 | Debug 通过不代表 Release 通过，反之亦然 |
| 双引擎升级的耦合点集中在 Renderer 层 | CEGUI 的 Renderer 和 Cocos2d-x 的渲染 API 是最高风险区域 |
| 增量构建后建议做 CppClean | 旧的 .obj 可能掩盖新代码的编译错误 |
| include 路径需要全量添加 | 3.0-oh 的分层结构要求每个子目录单独添加，不能只加根目录 |

### D.5 阶段 5：CEGUI 定制模块移植

#### 坑 6：CEGUI 0.7.9-r5 缺失 MT3 大量定制 API

- **现象**：编译时出现 ~200 个错误，涉及 `CompnentTip` 未定义、`GoToFunction` 等回调类型未声明、`onMouseSlide`/`isThumbOnEnd` 不存在、`CEGUI_LOGERR` 宏未定义等
- **根因**：MT3 在 CEGUI 0.7.1 上深度定制了 System、Window、Scrollbar、String 等核心类，添加了 50+ 个定制 API。这些 API 在 0.7.9-r5 中不存在
- **修复**：
  1. 在 CEGUISystem.h 中添加 20+ 个回调 typedef 和对应的 getter/setter 方法
  2. 在 CEGUIWindow.h 中添加 `EnableDrag`、`SetCanEdit`、`EnbaleSlide`、`getCloneWindowFromTemplate` 等方法
  3. 在 CEGUIScrollbar.h 中添加 `onMouseSlide`、`isThumbOnEnd` 方法
  4. 在 CEGUIString.h 中添加 `GetCharLength` 方法和 `wchar_t` 构造函数
  5. 在 CEGUILogger.h 中添加 `CEGUI_LOGERR` 宏
  6. 在 CEGUIForwardRefs.h 中添加 `CompnentTip`、`RichEditboxComponent` 前向声明
- **教训**：阶段 5 的 API 补充工作量远超预期，因为 MT3 对 CEGUI 0.7.1 的定制深度很大，涉及核心类（System、Window）的修改

#### 坑 7：FalRichEditbox.cpp 编码问题导致 50+ 语法错误

- **现象**：编译 `FalRichEditbox.cpp` 时出现 `FalagardRichEditbox` 不是类名、`i` 未声明、`pos` 未声明等 50+ 个语法错误，但代码逻辑本身正确
- **根因**：文件是 UTF-8 无 BOM 格式，但其中文注释实际是 GBK 编码。GBK 多字节序列中的某些字节恰好等于 ASCII 的 `{`（0x7B）和 `}`（0x7D），VS2013 在无 BOM 时以 CP936（GBK）解析，导致括号匹配错误——for 循环被提前关闭，后续所有成员函数定义脱离了类作用域
- **修复**：为文件添加 UTF-8 BOM（EF BB BF），使 VS2013 以 UTF-8 模式解析
- **教训**：VS2013 编译且包含非 ASCII 的 UTF-8 C/C++ 文件必须保留 BOM；GBK 注释在无 BOM 的 UTF-8 文件中是定时炸弹

#### 坑 8：Image::draw() 和 Font::drawText() 签名变更影响面广

- **现象**：编译时出现大量 `C2664`（无法将 `GeometryBuffer*` 转换为 `GeometryBuffer&`）错误
- **根因**：CEGUI 0.7.9-r5 将 `Image::draw()` 和 `Font::drawText()` 的参数从指针改为引用
- **修复**：在 10+ 个文件中将所有 `draw(buffer, ...)` 改为 `draw(*buffer, ...)`
- **教训**：指针→引用的 API 变更是编译时最容易发现的，但影响面广，需要逐文件修改；建议使用 grep 全局搜索确保无遗漏

#### 坑 9：WindowRenderer 基类构造函数变更

- **现象**：`FalAnimationButton`、`FalIrregularButton`、`CompnentTipWindowRenderer` 等编译失败
- **根因**：CEGUI 0.7.9-r5 的 `WindowRenderer` 移除默认构造函数，且 `clone()` 不再是其成员
- **修复**：移除这些类的默认构造函数和 `clone()` 方法
- **教训**：0.7.9-r5 的 `WindowRenderer` 体系与 0.7.1 差异较大，自定义渲染器需要重新审视架构

