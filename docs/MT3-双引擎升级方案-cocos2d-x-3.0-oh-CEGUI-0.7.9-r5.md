# MT3 客户端双引擎升级综合方案

## Cocos2d-x 2.2.6 → 3.0-oh + CEGUI 0.7.1 → 0.7.9-r5

> **版本**：2.1.1
> **制定日期**：2026-07-26
> **修订日期**：2026-07-29 13:07 (UTC+8)
> **状态**：[进行中] — 验收证据加权进度 **53.2%**；阶段 1-2 已完成，阶段 0/3-11 进行中，阶段 12 未启动；M1 已完成，M0/M2-M6 进行中，M7 未启动
> **本次修订**：
>
>- **Win32 目标链闭环前移**：canonical 入口已支持 `-EngineProfile Upgrade30`，Debug 增量构建完成最终链接并生成目标 `MT3.exe`
>- **P0 崩溃修复**：修复 JPEG 8/9 ABI 混编与 SILLY `setjmp` 生命周期问题，移除重复动画定义；冷启动 11 步初始化和主循环已到达
>- **运行依赖审计**：Debug 运行目录严格审计 `MissingDepCount=0`、`MissingDepHighCount=0`、`RuntimeImportHighCount=0`，当前崩溃不是 DLL 缺失；Cocos/CEGUI 以静态库链接进入 `MT3.exe`
>- **资源链修复与暴露**：补齐 `beijingtu1-10` 图片实物和 `common_bgcase` 九宫格映射；仍有 45 个静态布局失败、29 个运行时未注册 Imageset、4 类旧 LookNFeel 元素及 `CompnentTip` 工厂缺口
>- **验收边界**：12:53 冷启动连续运行 60 秒，约 40 秒恢复响应，正常关窗退出码为 0，无新增 WER/`.dmp`；登录首屏仍报告黑屏，Release/clean build、交互、GPU 截图和全平台验收尚未闭环

> **依赖文档**：
>
> - [Cocos2d-x 2.2.6 → 3.0-oh 升级方案](cocos2d-x-2.2.6-to-3.0-oh-upgrade-plan.md)（已存在）
> - [CEGUI 0.7.1 → 0.7.9-r5 迁移升级计划](CEGUI-0.7.9-r5-迁移升级计划.md)（已存在，v1.0.1）
> - [双引擎升级后续执行详细实施方案](MT3-双引擎升级后续执行详细实施方案-2026-07-29.md)（本次新增）

***

## 目录

1. [深度链路分析：MT3 客户端全模块依赖拓扑](#1-深度链路分析mt3-客户端全模块依赖拓扑)
2. [双引擎升级耦合关系分析](#2-双引擎升级耦合关系分析)
3. [系统环境与工具链版本要求](#3-系统环境与工具链版本要求)
4. [集成升级策略与阶段规划](#4-集成升级策略与阶段规划)
5. [合并风险矩阵与缓解措施](#5-合并风险矩阵与缓解措施)
6. [综合时间线与里程碑](#6-综合时间线与里程碑)
7. [验证与验收标准](#7-验证与验收标准)
8. [当前进度核查基线](#8-当前进度核查基线2026-07-28)

**附录**：

- [附录 A：快速参考 — 关键 API 对照表](#附录-a快速参考--关键-api-对照表)
- [附录 B：参考文档索引](#附录-b参考文档索引)
- [附录 C：历史执行记录](#附录-c历史执行记录非当前状态基线)
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
│  Layer 3a: CEGUI 0.7.1 → 0.7.9-r5 (**FireClient 已切换**) │ │  Layer 3b: Nuclear 引擎              │
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
│  Layer 2: Cocos2d-x 2.2.6/3.0-oh (含 8 类 MT3 补丁)           │
│  **FireClient.win32.vcxproj 已切换至 3.0-oh**                     │
│  cocos2d-x-3.0-oh/cocos/ ← **FireClient 已切换到此**         │
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

> **当前结论**：代码与部分静态库证明 Cocos2d-x 3.0-oh 和 CEGUI 0.7.9-r5 可使用 VS2013 (v120) 编译，主线工具链无需升级。该事实不等于所有预编译 `.lib` 已通过 ABI/CRT 和最终链接验证；R13 已按 §8 重新打开。

### 3.1 工具链现状与目标对比

| 组件          | 当前工具链           | 目标工具链                                              | 变更说明                                    |
| ----------- | --------------- | -------------------------------------------------- | --------------------------------------- |
| Win32 编译器   | VS2013 (v120)   | VS2013 (v120)                                      | **保持不变**                                |
| Win32 SDK   | Windows SDK 8.1 | Windows SDK 8.1                                    | **保持不变**                                |
| Android NDK | NDK r16b clang  | NDK r16b clang                                     | 保持固定基线                                  |
| Android SDK | android-22      | android-22                                         | 保持固定基线                                  |
| JDK         | JDK 1.8         | JDK 1.8                                            | 保持固定基线                                  |
| CMake       | 无               | CMake 3.10                                         | 3.0-oh 评估构建使用，命令从 PATH 解析               |
| Python      | 2.7             | 2.7/3.x                                            | 构建脚本兼容                                  |

> **关键结论**：VS2013 工具链保持不变；现有第三方库只作为候选复用项，必须通过 CRT/toolset/架构审计、目标最终链接和运行验证。CMake 用于生成 cocos2d-x-3.0-oh 的 VS2013 (v120) 工程。

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
cmake -G "Visual Studio 12 2013" ..
```

### 3.3 预编译 .lib 依赖 — 候选复用，需逐项验证

**当前结论：保持 VS2013 (v120) 只降低工具集迁移风险，不证明现有 `.lib` 可直接进入目标产物。下表是候选复用清单；在 clean build、最终链接、CRT/ABI 审计和目标运行通过前，不标记为完成。**

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
2. 运行 `cmake -G "Visual Studio 12 2013" ..` 生成 v120 解决方案
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
| **总计** | <br />                                     | **\~32.5 周（约 7.5 个月）** | 原 30.5 周为求和错误 |

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

| 风险编号    | 风险描述                     | 来源      | 概率         | 影响                                                                                                                                                                                                   | 等级     | 缓解措施                                    |
| ------- | ------------------------ | ------- | ---------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------ | --------------------------------------- |
| **R1**  | Cocos2DRenderer 双端适配失败   | 双引擎     | 高          | 致命                                                                                                                                                                                                   | **致命** | 阶段 3 作为最高优先级，独立验证渲染管线                   |
| **R2**  | CEGUI 自定义控件移植失败（20+ 个）   | CEGUI   | 中          | 致命                                                                                                                                                                                                   | **致命** | 分三批移植，先核心控件再辅助控件                        |
| **R3**  | Nuclear 封装层适配失败          | Cocos2d | 中          | 致命                                                                                                                                                                                                   | **致命** | EngineApp/EngineLayer/EngineTicker 尽早验证 |
| **R4**  | tolua++ 绑定生成不兼容          | 双引擎     | 中          | 严重                                                                                                                                                                                                   | **严重** | 提前验证生成链，准备手动修复                          |
| **R5**  | CEGUI Lua 绑定 API 变更      | CEGUI   | 中          | 严重                                                                                                                                                                                                   | **严重** | 建立 Lua API 兼容性检查脚本                      |
| **R6**  | 渲染结果不一致                  | 双引擎     | 高          | 严重                                                                                                                                                                                                   | **严重** | 建立截图对比工具，逐场景验证                          |
| **R7**  | MT3 补丁移植遗漏               | Cocos2d | 高          | 严重                                                                                                                                                                                                   | **严重** | 建立补丁 checklist，逐项验证                     |
| **R8**  | 性能退化                     | 双引擎     | 中          | 严重                                                                                                                                                                                                   | **严重** | 每阶段性能基准测试                               |
| **R9**  | 构建系统迁移耗时过长               | Cocos2d | 中          | 中等                                                                                                                                                                                                   | **中等** | 可先保留 vcxproj 过渡                         |
| **R10** | 第三方依赖版本冲突                | 双引擎     | 中          | 中等                                                                                                                                                                                                   | **中等** | 提前梳理版本依赖                                |
| **R11** | CEGUI 资源文件格式不兼容          | CEGUI   | 低          | 中等                                                                                                                                                                                                   | **中等** | 已验证格式高度兼容（见 CEGUI 方案 §1.4.9）            |
| **R12** | OHOS 平台不稳定               | Cocos2d | 高          | 低                                                                                                                                                                                                    | **低**  | OHOS 作为可选目标，不影响主平台                      |
| **R13** | 预编译库/目标库 ABI 与路径不一致 | 双引擎 | 高 | 最终 MT3.exe 链接、运行时 ABI | **严重** | 重新打开：目标独立库已生成，但 canonical 脚本仍构建 2.2.6，最终目标链接/运行未通过；全链双配置通过后再关闭 |

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
总计：约 32.5 周（约 7.5 个月，原 30.5 周为求和错误；是否含缓冲需重新基线化）
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

> **2026-07-28 核查结论**：此前 M3/M4 “达成”仅有静态库编译证据，缺少基础 UI 渲染、目标 MT3.exe、资源全量加载和运行时证据。当前里程碑状态以 §8.3 为准。

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

## 8. 当前进度核查基线（2026-07-29）

> **核查时点**：2026-07-29 13:07 (UTC+8)
> **事实来源**：工程/源码/脚本/产物/实测结果优先于本文旧记录。
> **状态定义**：`[已完成]` 表示方案验收条件均有当前证据；`[进行中]` 表示已有实现但至少一项门禁未闭环；`[未启动]` 表示未发现目标实现或验证证据。
> **责任人说明**：仓库未记录实名责任人；下文先登记责任角色，项目经理应在 2026-07-29 前补齐姓名。

### 8.1 计算口径与总体进度

1. 静态库生成只计编译证据，不替代最终链接、运行时、资源或平台验收。
2. 阶段进度按规划子任务、编译门禁、功能门禁和平台门禁综合估算。
3. 整体进度按工期加权：`Σ(阶段工期 × 阶段完成率) / 32.5 周 = 53.2%`。
4. §4.1 工期实际求和为 **32.5 周**，原 30.5 周少算 **2 周 / 6.6%**。

| 阶段 | 工期 | 审计进度 | 状态 | 主要证据/缺口 |
| --- | ---: | ---: | --- | --- |
| 0 环境与基线 | 1 周 | 85% | [进行中] | VS2013/v120 与 Upgrade30 canonical profile 已可用；缺专用分支、旧基线和 clean 双配置证据 |
| 1 Cocos 独立编译 | 2 周 | 100% | [已完成] | `cocos2d-x-3.0-oh/build/lib` 当前有 Debug 18 个、Release 17 个静态库 |
| 2 CEGUI 独立编译 | 1.5 周 | 100% | [已完成] | Debug/Release v120 静态库当前存在 |
| 3 Cocos2DRenderer | 3 周 | 75% | [进行中] | CEGUI/SILLY/JPEG 运行链已启动；登录画面、纹理状态和 RT/裁剪 TODO 未闭环 |
| 4 Nuclear 适配 | 2 周 | 80% | [进行中] | 双配置库及 Win32 启动/主循环/退出已有证据；触摸、调度、RT 专项未验 |
| 5 CEGUI 定制模块 | 3 周 | 75% | [进行中] | 0.7.9 运行时初始化完成；29 个 Imageset 注册、4 类 LookNFeel 元素和 `CompnentTip` 未闭环 |
| 6 FireClient | 4 周 | 85% | [进行中] | Upgrade30 Debug `MT3.exe` 已链接并完成 11 步初始化；Release、登录可视结果和交互未验 |
| 7 Lua + tolua++ | 2 周 | 60% | [进行中] | `dofile_main.lua` 与登录 Lua 入口运行成功；生成链和全量自定义控件仍未验 |
| 8 资源兼容 | 1 周 | 55% | [进行中] | 动画重复和背景图实物已修；静态 812/857、运行时 29 个 Imageset 与 4 类旧元素仍失败 |
| 9 平台适配 | 4 周 | 20% | [进行中] | Win32 Debug 构建/启动已到主循环；Release、Android/iOS 和 OHOS 未闭环 |
| 10 MT3 补丁 | 2 周 | 35% | [进行中] | JPEG ABI 已修；音频/Shader/压缩纹理/Lua/Spine 仍有存根/TODO |
| 11 测试验证 | 4 周 | 5% | [进行中] | 已有 Win32 Debug 冷启动、DLL 审计和转储回归；功能/性能/稳定性矩阵未执行 |
| 12 优化上线 | 3 周 | 0% | [未启动] | 依赖阶段 11 |
| **整体** | **32.5 周** | **53.2%** | **[进行中]** | 已取得 17.30 个工期加权周，尚余 15.20 个 |

### 8.2 逐项任务对照

#### 8.2.1 阶段 0-2

| WBS | 子任务 | 状态 | 核查结果 |
| --- | --- | --- | --- |
| 0.1 | CMake/VS2013/v120 环境与工程 | [已完成] | `build/CMakeCache.txt` 和生成 vcxproj 已验证 |
| 0.2 | 3.0-oh/0.7.9-r5 源码基线 | [已完成] | 源码与 CEGUI v120 工程存在 |
| 0.3 | 升级专用分支 | [未启动] | 当前为 `main`，未发现专用分支 |
| 0.4 | 旧版功能/性能基线 | [未启动] | FPS、内存、启动时间、DrawCall、APK 大小无实测值 |
| 0.5 | 目标 canonical 构建入口 | [进行中] | wrapper 已支持 `Upgrade30` 且 Debug 严格审计通过；clean Debug/Release 尚缺 |
| 1.1 | CMake 生成 v120 Cocos 工程 | [已完成] | 生成工程为 v120 |
| 1.2 | sqlite3/storage 修复 | [已完成] | 修复已落库 |
| 1.3 | Debug 独立编译 | [已完成] | 目标目录当前有 18 个 lib（含 tolua.lib） |
| 1.4 | Release 独立编译 | [已完成] | 目标目录当前有 17 个 lib |
| 1.5 | Cocos 产物接入下游 | [已完成] | 下游工程引用 `cocos2d-x-3.0-oh/build/lib/$(Configuration)` |
| 1.6 | cpp-tests/curl 验证 | [未启动] | 原记录明确跳过；不阻塞核心库，但不应表述为全量零错误 |
| 2.1 | CEGUI v120 工程 | [已完成] | Debug/Release 均为 v120 |
| 2.2 | CEGUI Debug | [已完成] | `cegui-0.7.9_d.lib`，98,892,504 bytes |
| 2.3 | CEGUI Release | [已完成] | `cegui-0.7.9.lib`，79,578,922 bytes |

#### 8.2.2 阶段 3-5

| WBS | 子任务 | 状态 | 核查结果 |
| --- | --- | --- | --- |
| 3.2.1 | CEGUI Renderer 差异清单 | [已完成] | 目标实现已按 0.7.9 接口编译 |
| 3.2.2 | Cocos 纹理/渲染差异清单 | [已完成] | 迁移点已有实现记录 |
| 3.2.3 | CEGUICocos2DRenderer | [进行中] | 已编译；UI/XP 状态保存恢复仍有 TODO |
| 3.2.4 | CEGUICocos2DTexture | [进行中] | 已编译；ETC/alpha/压缩纹理仍有默认返回/TODO |
| 3.2.5 | GeometryBuffer | [进行中] | 已编译；RenderCommand、裁剪、批处理未验 |
| 3.2.6 | Render/Texture/ViewportTarget | [进行中] | 已编译；翻转、恢复、嵌套 RT 未验 |
| 3.2.7 | Cocos2DImageCodec | [进行中] | 运行时采用 SILLY，JPEG 9 ABI 探针与解码路径已通过；PNG/压缩纹理和设计决策待补 |
| 3.2.8 | CEGUI 初始化 + 基础 UI | [进行中] | `OnInit step=4 success` 且主循环到达；登录首屏仍黑，基础 UI 可视验收未通过 |
| 4.1 | engine 工程切到 3.0-oh | [已完成] | 工程路径已切换 |
| 4.2 | EngineApp/Layer/Ticker API | [已完成] | 双配置编译 |
| 4.3 | 触摸/draw/Director/GL API | [已完成] | 源码迁移已编译 |
| 4.4 | MT3 定制 Cocos API | [进行中] | Texture2D/Image/GLProgram 等仍有存根/降级路径 |
| 4.5 | engine Debug/Release | [已完成] | 119,766,434 / 87,002,328 bytes |
| 4.6 | 生命周期/触摸/调度/RT 验证 | [进行中] | Win32 启动、Ticker 主循环和正常退出已有日志；触摸/调度/RT 专项待补 |
| 5.1 | 第一批核心控件 | [进行中] | 已编译；渲染、输入、富文本未验 |
| 5.2 | 第二批常用控件 | [进行中] | 已编译；运行时未验 |
| 5.3 | 第三批辅助控件 | [进行中] | 已编译；运行时未验 |
| 5.4 | MT3 CEGUI 定制 API | [进行中] | 多数接口已编译，部分为空实现/存根 |
| 5.5 | CEGUI 双配置集成编译 | [已完成] | 目标静态库存在 |
| 5.6 | 20+ 控件/16 渲染器验收 | [未启动] | 无截图、交互或日志证据 |

#### 8.2.3 阶段 6-8

| WBS | 子任务 | 状态 | 核查结果 |
| --- | --- | --- | --- |
| 6.1 | FireClient 工程切换 | [已完成] | 已引用目标头/库路径，但 Cocos lib 路径尚未闭环 |
| 6.2 | tolua/HTTP/类型兼容 | [已完成] | 已进入双配置静态库 |
| 6.3 | FireClient Debug/Release | [已完成] | 177,398,148 / 128,040,360 bytes |
| 6.4 | 最终 MT3.exe 链接 | [进行中] | Upgrade30 Debug `MT3.exe` 已生成并运行；clean Debug 和 Release 最终链接待补 |
| 6.5 | 冷启动/CEGUI/登录首屏 | [进行中] | 11 步初始化、LoginManager、QuickLogin 和主循环已到达且无新转储；可视登录仍黑 |
| 6.6 | 5262 条警告分类/门禁 | [未启动] | 大量警告会掩盖新增缺陷 |
| 7.1 | `.pkg` API 适配 | [已完成] | 有 3 文件/11 处修改记录 |
| 7.2 | 重生成 LuaEngine.cpp | [未启动] | 无本轮生成日志 |
| 7.3 | 重生成 LuaFireClient/Win32 | [未启动] | 原记录明确“跳过”，与 §7.1 门禁冲突 |
| 7.4 | Lua 静态 API 扫描 | [进行中] | 有数量结论，缺可复现报告和绑定差异校验 |
| 7.5 | CEGUI LuaFunctor/事件 | [进行中] | 源码有修改，未运行时验证 |
| 7.6 | Lua 全量加载/自定义控件 | [进行中] | `dofile_main.lua`、登录背景和快速登录入口已执行；全量业务脚本/自定义控件待回归 |
| 8.1 | 资源类型/数量盘点 | [已完成] | 857 layout 等数量已核对 |
| 8.2 | XML 可解析性 | [进行中] | 至少有 `jinglingtiwen.layout` 等解析错误 |
| 8.3 | Scheme/WidgetLook 映射 | [进行中] | 多个 `TaharezLook/*` 类型未映射 |
| 8.4 | Imageset/Font 引用 | [进行中] | 631 个 `.imageset` 图片实物引用已齐；运行时仍有 29 个 Imageset 未注册及静态字体/图片缺口 |
| 8.5 | 全量静态门禁 | [进行中] | 857 中 812 通过、45 失败，通过率 94.7%；统一 baseline gate 为 FAIL：418 项中 417 已知、1 项新增、3 项已解决 |
| 8.6 | 目标运行时全量加载 | [进行中] | 启动 Scheme、动画和登录资源已实跑；长尾页面未覆盖，当前 CEGUI 日志仍有 2093 条错误 |

#### 8.2.4 阶段 9-12

| WBS | 子任务 | 状态 | 核查结果 |
| --- | --- | --- | --- |
| 9.1 | Win32 工程切换 | [已完成] | 三个主工程已切主要路径 |
| 9.2 | Win32 最终构建/运行 | [进行中] | Upgrade30 Debug 构建、严格 DLL 审计、冷启动和主循环通过；Release/可视/交互待验 |
| 9.3 | Android 迁移/构建/运行 | [未启动] | Locojoy/common/Joysdk/Yijie Android.mk 仍引用 2.2.6 |
| 9.4 | iOS 迁移/构建/运行 | [未启动] | FireClient/engine Xcode 工程仍引用 2.2.6/旧 CEGUI |
| 9.5 | OHOS 范围/工程/验收 | [未启动] | 只有评估树，交付范围未定 |
| 10.1 | Win32 音频 Shim | [进行中] | 接口已移植，播放/优先级未验 |
| 10.2 | Shader 兼容 | [进行中] | 接口已移植，部分存根，像素一致性未验 |
| 10.3 | DDS/ATC/PVRTC/ETC | [进行中] | Renderer/Texture2D 仍有 TODO/默认返回 |
| 10.4 | Lua 桥接 | [进行中] | 兼容 API 已编译，生成链/运行时未闭环 |
| 10.5 | Spine JSON | [进行中] | legacy helper 已加入，目标资源未回归 |
| 10.6 | 视频播放器 Shim | [未启动] | 无实现/验收证据 |
| 10.7 | 照片选择器 Shim | [未启动] | 无实现/验收证据 |
| 10.8 | FireClient 兼容 | [进行中] | Debug 启动和登录管理主链已运行；选角、入世界、战斗等业务路径待验 |
| 11.1 | 全平台编译/功能回归 | [进行中] | Win32 Debug 冷启动烟测完成；登录可视、选角、入世界、战斗及其他平台未执行 |
| 11.2 | 截图/边界/性能/稳定性 | [未启动] | 无旧基线或新结果 |
| 12.1 | 优化/缺陷清零 | [未启动] | 依赖阶段 11 |
| 12.2 | 灰度/回滚/上线 | [未启动] | 依赖阶段 11 |

### 8.3 偏差与里程碑

| 口径 | 计划/声明 | 审计值 | 偏差 |
| --- | ---: | ---: | ---: |
| 7 月 26 日起名义顺排，7 月 29 日含首尾 4 天 | 1.8% | 53.2% | **+51.4 个百分点**，实现并行提前但验收仍滞后 |
| 旧文档自报“阶段 0-8 完成” | 60.0% | 53.2% | **-6.8 个百分点 / 约 2.2 计划周验收缺口** |
| 总工期 | 30.5 周 | 32.5 周 | **+2 周 / +6.6%** |
| 阶段 9 开始 | 2026-08-18 | 按前 19.5 周顺排为 2026-12-09 12:00 | 旧日期压缩 **113.5 天** |
| 全项目完成 | 2026-11-17 | 按 32.5 周顺排为 2027-03-10 12:00 | 旧日期压缩约 **113.5 天** |

旧排期没有记录并行人力假设，不能同时满足工期和绝对日期。当前不是相对 7 月 28 日名义计划落后，而是旧文档把未验收工作提前记为完成；M4 建议闭环日为 2026-08-14，旧结论提前 **17 天**。

| 里程碑 | 进度 | 状态 | 未闭环项 |
| --- | ---: | --- | --- |
| M0 | 85% | [进行中] | 专用分支、旧基线、clean 双配置 canonical |
| M1 | 100% | [已完成] | Cocos 与 CEGUI 独立双配置静态库当前存在 |
| M2 | 75% | [进行中] | Renderer TODO、登录可视与像素/RT 验收 |
| M3 | 77.0% | [进行中] | Nuclear 专项与控件运行验收 |
| M4 | 73.6% | [进行中] | Release、Lua 生成、45 个静态失败、29 个运行时 Imageset、登录首屏 |
| M5 | 38.3% | [进行中] | Win32 剩余验收、三端、OHOS 决策和其余补丁 |
| M6 | 5% | [进行中] | 仅 Win32 Debug 启动烟测，阶段 11 矩阵未展开 |
| M7 | 0% | [未启动] | 阶段 12 |

### 8.4 已解决问题与验证状态

| 问题 | 结果 | 验证状态 |
| --- | --- | --- |
| VS2013/v120 生成能力 | CMakeCache/生成工程均为 VS2013/v120 | 已验证 |
| CEGUI 双配置静态库 | 两个目标 lib 当前存在 | 已验证（编译层） |
| Nuclear 主要 API 适配 | engine 双配置 lib 存在 | 已验证（编译层） |
| FireClient 主要 API 适配 | FireClient 双配置 lib 存在 | 已验证（编译层） |
| Win32 主工程路径切换 | 三个工程可检索到目标路径 | 已验证（配置层） |
| sqlite/storage 缺口 | 修复已落库 | 部分验证，需 clean rebuild |
| 资源检查工具 | 可复现 857/812/45；统一 gate 报告为 418 当前项、417 已知项、1 个新增 P1、3 个已解决项 | 已验证（工具层），业务门禁失败 |
| 平台壳层入口 | 旧 Win32/Android/iOS 入口探针通过 | 已验证（旧基线），不代表升级完成 |
| Upgrade30 Debug 最终链接 | canonical `Incremental + Upgrade30 + StrictRuntimeAudit` 生成 24,704,000 bytes 的 `MT3.exe` | 已验证（Debug 增量构建层） |
| Debug 运行目录 DLL | 严格审计 `MissingDepCount=0`、`MissingDepHighCount=0`、`RuntimeImportHighCount=0`；PE 仅直接导入系统库、`websockets.dll`、`libcurld.dll` 和 Debug CRT | 已验证，当前崩溃与 DLL 缺失无关；Cocos/CEGUI 为静态链接 |
| JPEG 解码 ABI | 统一到 Cocos 3 JPEG 9，移除 wxJPEG 6b 对象并修复 SILLY `setjmp` 生命周期 | 已验证（ABI 探针、重建、MAP 与冷启动） |
| CEGUI 动画重复 | 删除 `sample.xml` 中 4 个重复名称，保留比例坐标定义 | 已验证（重复名 0，`loadAnimationsFromXML` 错误消失） |
| 登录背景图片实物 | `beijingtu1-10` 声明图片全部存在，631 个 `.imageset` 图片实物引用缺失数为 0 | 已验证（静态实物 + 运行时文件打开错误归零） |
| `common_bgcase` 九宫格 | 复用 `common.png` 的 `common_bg2_*` 坐标并注册别名 Imageset | 已验证（9/9 坐标一致，运行时该错误由 512 次降为 0） |
| Win32 Debug 冷启动 | 12:53 实测连续运行 60 秒；约 40 秒恢复响应，11 个 `OnInit` 步骤、QuickLogin、Ticker 主循环均到达，正常关窗退出码为 0 | 已验证（无新增 WER/`.dmp`），登录画面仍待 GPU 可视验收 |

### 8.5 待解决问题、阻碍与责任

> **排期口径**：下表覆盖 §8.2 中全部 `[进行中]` / `[未启动]` 子任务；日期是本次核查建议完成时间，不代表责任人承诺。实名责任人应由项目经理在 2026-07-29 前补齐。

| WBS | 优先级 | 未完成任务/直接阻碍 | 影响范围 | 当前解决进展 | 责任角色 | 建议完成时间 |
| --- | --- | --- | --- | --- | --- | --- |
| 0.3 | P1 | 尚未建立升级专用分支 | 变更隔离、回滚、审计 | 当前仍在 `main` 推进 | 项目经理/配置负责人（待实名） | 2026-07-29 |
| 0.4 | P0 | 旧版功能和性能基线未采集 | 阶段 11 无可靠对照 | 已明确 FPS/内存/启动/DrawCall/APK 五项指标 | 性能 QA（待实名） | 2026-08-07 |
| 0.5 | P0 | Upgrade30 canonical 仅完成 Debug 增量构建 | clean build、Release、可复现性 | profile 与严格审计已可用 | Win32 构建负责人（待实名） | 2026-08-03 |
| 1.6 | P2 | cpp-tests 仍缺 curl 验证 | Cocos 非核心样例覆盖 | 核心静态库已生成，原执行记录明确跳过 | Cocos 构建负责人（待实名） | 2026-08-07 |
| 3.2.3 | P0 | Renderer 状态保存/恢复存在 TODO | UI 与 XP 渲染一致性 | 主类已编译 | 渲染/CEGUI 负责人（待实名） | 2026-08-07 |
| 3.2.4 | P0 | ETC/alpha/压缩纹理路径为默认返回或 TODO | Android 纹理、透明度、资源显示 | Texture 已编译，行为未验证 | 渲染/纹理负责人（待实名） | 2026-08-07 |
| 3.2.5 | P0 | RenderCommand、裁剪、批处理未验 | 控件层级、DrawCall、可见区域 | GeometryBuffer 已编译 | 渲染/CEGUI 负责人（待实名） | 2026-08-08 |
| 3.2.6 | P0 | 翻转、状态恢复、嵌套 RT 未验 | 特效、离屏渲染、设备恢复 | 相关 Target 类已编译 | 渲染/引擎负责人（待实名） | 2026-08-08 |
| 3.2.7 | P0 | SILLY/JPEG 仅闭环 JPEG，PNG/压缩纹理和职责决策未完整 | 图片解码和三端兼容 | JPEG 9 ABI 与冷启动已通过 | 技术负责人/CEGUI 负责人（待实名） | 2026-08-03 决策 |
| 3.2.8 | P0 | 登录客户区仍报告黑屏，缺可靠 GPU/像素和基础 UI 截图 | M2、登录可用性 | CEGUI 初始化和主循环已通过，GDI 截图不作为 GPU 画面通过证据 | 客户端集成/渲染负责人（待实名） | 2026-08-04 |
| 4.4 | P0 | MT3 定制 Texture2D/Image/GLProgram 等仍有存根 | Shader、纹理、字体、GL 行为 | 接口已进入 engine 双配置静态库 | Cocos/Nuclear 负责人（待实名） | 2026-08-10 |
| 4.6 | P0 | 仅启动/主循环/退出有运行证据，触摸、调度和 RT 无专项用例 | M3、输入和场景稳定性 | 基础生命周期已到达 | Nuclear/QA 负责人（待实名） | 2026-08-10 |
| 5.1 | P0 | 登录/核心控件仍未完成可视、输入和富文本验证 | 登录、主界面 | 初始化通过但画面未验收 | CEGUI/UI QA（待实名） | 2026-08-05 |
| 5.2 | P1 | 第二批常用控件未做运行验证 | 背包、聊天、任务等页面 | 已编译 | CEGUI/UI QA（待实名） | 2026-08-14 |
| 5.3 | P1 | 第三批辅助控件未做运行验证 | 长尾 UI 页面 | 已编译 | CEGUI/UI QA（待实名） | 2026-08-14 |
| 5.4 | P0 | `CEGUI/CompnentTip` 工厂未注册，4 类旧 LookNFeel 元素产生 1209 次错误 | 控件创建、边框/颜色属性、日志质量 | 已定位 4 个元素名和单次工厂错误 | CEGUI 负责人（待实名） | 2026-08-04 |
| 5.6 | P1 | 20+ 控件/16 渲染器缺截图、交互和日志证据 | M3 完整性 | 等待基础 UI 和控件用例 | CEGUI/UI QA（待实名） | 2026-08-14 |
| 6.4 | P0 | Debug 增量最终链接已通过，clean Debug/Release 尚未闭环 | Win32 可复现构建和交付 | 目标 Debug `MT3.exe` 已运行 | Win32/引擎负责人（待实名） | 2026-08-03 |
| 6.5 | P0 | 冷启动已到主循环，但登录首屏仍黑且核心交互未验 | M4、用户可用性 | 无新转储，启动链完成 | 客户端集成负责人（待实名） | 2026-08-05 |
| 6.6 | P1 | 5262 条警告未分类和设门禁 | 新缺陷可见性、后续维护 | 当前只有数量记录 | 模块负责人/CI（待实名） | 2026-08-14 |
| 7.2 | P0 | LuaEngine.cpp 未按修改后的 `.pkg` 重生成 | Lua ABI、方法表 | 源 `.pkg` 已修改 | Lua 工具链负责人（待实名） | 2026-08-10 |
| 7.3 | P0 | LuaFireClient/Win32 绑定重生成被跳过 | Win32 Lua 桥接 | 已确认旧记录与生成门禁冲突 | Lua 工具链负责人（待实名） | 2026-08-10 |
| 7.4 | P1 | Lua 静态扫描缺可复现报告和差异校验 | 绑定覆盖率 | 已有数量结论 | Lua 工具链/QA（待实名） | 2026-08-10 |
| 7.5 | P0 | LuaFunctor 和 CEGUI 事件只完成源码修改 | UI 事件、回调生命周期 | 修改已编译，未实跑 | Lua/CEGUI 负责人（待实名） | 2026-08-12 |
| 7.6 | P0 | 仅启动/登录 Lua 入口有运行日志，全量脚本和自定义控件未覆盖 | 登录后业务脚本 | `dofile_main.lua` 和 QuickLogin 已执行 | Lua/客户端集成负责人（待实名） | 2026-08-14 |
| 8.2 | P0 | layout XML 至少存在解析错误 | UI 启动和页面加载 | 已定位 `jinglingtiwen.layout` 等失败项 | UI 资源负责人（待实名） | 2026-08-10 |
| 8.3 | P0 | 多个 `TaharezLook/*` WidgetLook 未映射 | 控件创建、皮肤显示 | 失败类型已分类 | UI 资源/CEGUI 负责人（待实名） | 2026-08-12 |
| 8.4 | P0 | 图片实物引用已补齐，但运行时仍有 29 个 Imageset 未在 Scheme 注册 | 长尾 LookNFeel、图片和控件背景 | `common_bgcase` 已关闭；其余 29 个名称已统计 | UI 资源/CEGUI 负责人（待实名） | 2026-08-06 |
| 8.5 | P0 | 静态门禁仍有 45/857 失败；`jinglingtiwen.layout` 旧解析缺陷因详细消息改变 issue ID，被 baseline 判为 1 个新增 P1 | M4、资源回归、门禁稳定性 | 当前通过 812/857（94.7%）；统一 gate 为 418/417/1/3 | UI 资源/门禁负责人（待实名） | 2026-08-13 |
| 8.6 | P0 | 启动资源已实跑，但 CEGUI 当前仍有 2093 条错误且长尾页面未加载 | 真实依赖、日志和资源组完整性 | 动画/背景 P0 已关闭，首错已前移 | UI 资源/客户端集成负责人（待实名） | 2026-08-10 |
| 9.2 | P0 | Win32 Debug 已运行，Release、黑屏、输入和关闭矩阵未闭环 | Win32 平台验收、M5 | 严格 DLL 审计和基础主循环通过 | Win32 负责人（待实名） | 2026-08-14 |
| 9.3 | P1 | Android 工程仍引用 2.2.6 | APK、JNI、arm64 ABI | 尚未迁移 | Android 负责人（待实名） | 2026-08-28 |
| 9.4 | P1 | iOS 工程仍引用 2.2.6/旧 CEGUI | iOS 构建、生命周期 | 尚未迁移，依赖 macOS/Xcode 执行器 | iOS 负责人（待实名） | 2026-09-11 |
| 9.5 | P2 | OHOS 是否纳入本期尚未决策 | 范围、工期、人员 | 当前仅有评估树 | 技术/产品负责人（待实名） | 2026-08-03 决策 |
| 10.1 | P1 | 音频 Shim 未验证播放和优先级 | 音效、音乐、资源释放 | 接口已移植 | 音频/平台负责人（待实名） | 2026-08-12 |
| 10.2 | P0 | Shader 兼容存在存根且无像素对比 | 全局渲染、特效 | 接口已移植 | 渲染负责人（待实名） | 2026-08-12 |
| 10.3 | P0 | DDS/ATC/PVRTC/ETC 路径存在 TODO | 三端纹理与包体 | Renderer/Texture2D 已有部分实现 | 渲染/平台负责人（待实名） | 2026-08-12 |
| 10.4 | P0 | Lua 桥接生成链和运行时未闭环 | 脚本 ABI、UI 事件 | 兼容 API 已编译 | Lua 工具链负责人（待实名） | 2026-08-14 |
| 10.5 | P1 | Spine legacy helper 未用目标资源回归 | 角色、特效动画 | helper 已加入 | 动画/引擎负责人（待实名） | 2026-08-14 |
| 10.6 | P1 | 视频播放器 Shim 无实现/验收证据 | 视频功能、平台媒体能力 | 未发现目标实现 | 平台负责人（待实名） | 2026-09-11 |
| 10.7 | P1 | 照片选择器 Shim 无实现/验收证据 | 相册/头像等平台功能 | 未发现目标实现 | 平台负责人（待实名） | 2026-09-11 |
| 10.8 | P0 | FireClient 已到启动/登录管理层，选角、入世界和战斗未验 | 核心业务主链 | Debug 启动与 Ticker 已运行 | 客户端集成负责人（待实名） | 2026-08-14 |
| 11.1 | P1 | 仅 Win32 Debug 冷启动烟测完成 | 登录、选角、入世界、战斗、退出 | DLL/转储/启动证据已建立 | 功能 QA/平台负责人（待实名） | 2026-10-02 |
| 11.2 | P1 | 截图、边界、性能和稳定性缺旧基线/目标产物 | 质量准入、容量和性能 | 验收阈值已定义，数据未采集 | 性能 QA（待实名） | 2026-10-09 |
| 12.1 | P1 | 优化和阻断缺陷清零依赖阶段 11 | 发布质量 | 尚未启动 | 各模块负责人（待实名） | 2026-10-30 |
| 12.2 | P1 | 灰度、回滚演练和上线批准依赖 12.1 | 正式发布 | 尚未启动 | 发布/运维/项目经理（待实名） | 2026-11-06 |

### 8.6 质量与完整性评估

评分：优 90-100，良 75-89，中 60-74，差 0-59；阶段 11/12 不纳入已开展工作均值。

| 范围 | 分数/等级 | 主要缺陷 | 改进建议 |
| --- | --- | --- | --- |
| 阶段 0 | 80 / 良 | Upgrade30 profile 已可用；缺旧基线和 clean 双配置 | 固化 clean 命令、产物和旧版指标 |
| 阶段 1 | 85 / 良 | 双配置产物齐全，非核心 cpp-tests 未覆盖 | 固化 clean build 命令、日志和产物清单 |
| 阶段 2 | 85 / 良 | 缺 clean build 日志指纹 | 固化命令、日志、依赖指纹 |
| 阶段 3 | 68 / 中 | JPEG/启动已验；黑屏和 Renderer TODO 未闭环 | GPU 画面、纹理、裁剪和 RT 回归 |
| 阶段 4 | 75 / 良 | 基础生命周期已验，触摸/调度/RT 缺专项 | 补独立用例 |
| 阶段 5 | 60 / 中 | 初始化通过但 2093 条资源/旧元素错误、控件行为未验 | 先清日志首错，再分批截图/输入/事件回归 |
| 阶段 6 | 78 / 良 | Debug 目标 exe 已运行；Release和可视登录未验 | clean 双配置 + 登录交互关闭阶段 |
| 阶段 7 | 60 / 中 | 启动 Lua 已运行，源定义和生成物仍可能漂移 | 强制重生成并比较符号/行为 |
| 阶段 8 | 55 / 差 | 动画/背景已修，45 个静态失败与 29 个运行时 Imageset 仍在 | 分类旧缺陷/升级回归并全量加载 |
| 阶段 9 | 40 / 差 | Win32 Debug 到主循环，其他配置/平台未验 | 平台拆负责人和独立门禁 |
| 阶段 10 | 45 / 差 | JPEG ABI 关闭，其余补丁行为未验 | 8 类补丁逐项输入/输出验收 |
| **阶段 0-8 综合** | **72 / 中** | 编译和 Win32 启动覆盖改善；可视渲染、生成链和资源仍不足 | 保持 Win32 P0 收敛，不扩大平台改动面 |
| **含阶段 9-10 的整体** | **66 / 中** | Win32 已进入运行验证，跨平台和补丁行为成熟度仍低 | 先完成 Win32 闭环，再按平台独立验收 |

潜在兼容性问题：Debug 最终链接不替代 clean/Release；Renderer ETC/alpha、状态切换、嵌套 RT、裁剪/批处理未验；登录画面仍黑；29 个 Imageset 未注册、4 类旧 LookNFeel 元素及 `CompnentTip` 工厂缺口会造成控件缺图/缺属性；Lua 生成物漂移；45 个静态资源失败；Android/iOS Clang/ObjC++ 未编译；性能阈值缺旧基线。

### 8.7 根本原因与风险

**根本原因**：完成定义长期被缩成“静态库零错误”；旧 JPEG 对象、目标 JPEG 库和错误跳转生命周期发生 ABI/异常处理混编；历史资源合并留下同名动画与未注册 Imageset；0.7.1 定制 LookNFeel 元素和窗口工厂未完整移植到 0.7.9；高耦合 Renderer/API 以存根穿过编译；tolua 生成链被绕过；排期缺人力/并行假设。12:05 的 WER/转储为 `0xE06D7363` C++ 异常，类型为 `CEGUI::UnknownObjectException`，调用链落在 `AnimationManager::createAnimation()` 处理 `sample.xml` 重名动画；严格 DLL 审计及 12:53 稳定实跑共同证明该故障不是运行目录动态库缺失。

| 风险 | 状态/变化 | 等级 | 应对与关闭条件 |
| --- | --- | --- | --- |
| R1/R6 Renderer/一致性 | 初始化和主循环通过，登录仍黑，部分缓解 | 致命 | 基础 UI/纹理/RT/GPU 像素对比通过 |
| R2 CEGUI 控件 | 29 个 Imageset、4 类旧元素和工厂缺口暴露 | 严重 | 当前 2093 条错误归零，20+ 控件渲染/输入/事件通过 |
| R3 Nuclear | 启动/Ticker/退出通过，部分缓解 | 严重 | 触摸/调度/RT 专项通过 |
| R4/R5 tolua/Lua | 启动 Lua 通过但未重生成，部分缓解 | 严重 | 重生成、差异审查、Lua 全量加载 |
| R7 MT3 补丁 | 存根/TODO，风险上升 | 致命 | 8 类补丁 checklist 全闭环 |
| R8 性能 | 无基线 | 严重 | 先采旧基线，再跑 §7.3 |
| R9 构建迁移 | Upgrade30 Debug 增量通过，部分缓解 | 严重 | clean checkout canonical 双配置成功 |
| R10/R13 依赖/ABI | DLL 审计与 JPEG 9 ABI 已通过，仍缺 Release/全链 | 严重 | CRT/toolset/架构审计 + clean 双配置运行 |
| R11 资源 | 动画/背景已缓解；45 个静态失败和 29 个运行时 Imageset 仍在 | 严重 | 静态 857/857 + CEGUI 错误归零 + 运行时全量加载 |
| R12 OHOS | 范围未决 | 中等 | 2026-08-03 前决策 |
| R14 文档/证据漂移 | 新发现 | 严重 | §8 单一状态源，每项绑定命令/产物/日志 |

### 8.8 调整排期与资源建议

| 工作包 | 日期 | 退出条件 |
| --- | --- | --- |
| Win32 P0 运行时收敛 | 07-29 至 08-04 | 登录非黑屏、CEGUI 启动错误归零、无新增转储 |
| 构建基线收敛 | 08-01 至 08-04 | Upgrade30 canonical clean Debug/Release、DLL/ABI 严格审计 |
| Win32 Renderer/补丁/链接 | 08-03 至 08-10 | Renderer 关键 TODO/存根、GPU 截图和交互关闭 |
| M2-M4 恢复冲刺 | 08-05 至 08-14 | 控件、Lua 重生成、857/857、登录/选角/入世界 |
| Android | 08-17 至 08-28 | free 主线 APK、ABI 门禁、连续 3 次登录 |
| iOS | 08-31 至 09-11 | Xcode 双配置、启动/登录/生命周期 |
| 集成/性能测试 | 09-14 至 10-09 | §7 全门禁、性能达标 |
| 优化/灰度/回滚/上线 | 10-12 至 11-06 | 灰度稳定、回滚演练、发布批准 |
| 管理缓冲 | 11-09 至 11-17 | 只处理阻断缺陷 |

OHOS 若纳入本期，需独立平台工作包并顺延至少 3-4 周；否则明确移出 M5。资源建议：1 名构建负责人、2 名渲染/引擎、1 名 Lua/生成链、1 名 UI 资源 + 1 名 QA、Android/iOS 各 1 名平台负责人（iOS 配 macOS 执行器）、阶段 11 配功能和性能 QA。每个 `[已完成]` 项必须绑定命令、退出码、产物路径/大小/时间、日志或截图之一。

### 8.9 核查证据摘要

| 证据 | 结果 |
| --- | --- |
| `git status --short` | 13:07 快照显示 Win32 链接诊断配置、背景资源、CEGUI Scheme 及未构建的图片空数据防御改动仍在工作树推进 |
| CMakeCache/vcxproj | VS2013/v120 已确认 |
| 产物盘点 | Cocos/CEGUI/engine/FireClient 双配置存在；Upgrade30 Debug `MT3.exe` 为 24,704,000 bytes |
| canonical 脚本检索 | wrapper/内部脚本已提供 `Upgrade30` profile，Debug 增量严格审计已执行 |
| Renderer TODO 检索 | 压缩纹理、状态保存恢复、ABI 兼容存根未闭环 |
| CEGUI 资源门禁 | 静态 FAIL：857/812/45；统一 baseline gate：418 当前、417 已知、1 新增、3 已解决，其中新增项为 `jinglingtiwen.layout` 旧解析缺陷的详细消息新 ID；运行时仍有 2093 条 CEGUI 错误 |
| Android/iOS 工程 | 仍引用 2.2.6；iOS 仍引用旧 CEGUI |
| Win32 冷启动 | 12:53 实测连续运行 60 秒，约 40 秒恢复响应；`OnInit` 11 步、QuickLogin、Ticker 到达，正常关窗退出码 0；无新 WER/`.dmp` |
| DLL/ABI | 严格审计 0 缺失；PE 导入表确认 Cocos/CEGUI 为静态链接；JPEG 9 ABI 探针、MAP 和冷启动通过 |

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

***

## 附录 C：历史执行记录（非当前状态基线）

> **执行开始**：2026-07-26
> **最后更新**：2026-07-28
>
> **审计说明**：本附录只追溯“做过什么”。其中“完成”多指源码或静态库编译完成，不再代表阶段验收完成；当前状态、百分比、里程碑、阻碍、责任角色和排期统一以 §8 为准。

### 总体进度

| 阶段    | 内容                    | 预估工期  | 状态    | 实际耗时       | 备注                                              |
| ----- | --------------------- | ----- | ----- | ---------- | ----------------------------------------------- |
| 阶段 0  | 环境搭建与基线建立             | 1 周   | ✅ 完成  | 0.5 天      | 所有前置任务完成                                        |
| 阶段 1  | Cocos2d-x 3.0-oh 独立编译 | 2 周   | ✅ 完成  | 0.5 天      | Debug/Release 各 15 个 .lib，零错误                   |
| 阶段 2  | CEGUI 0.7.9-r5 独立编译   | 1.5 周 | ✅ 完成  | < 0.5 天    | Debug/Release 均零错误，无需修复                         |
| 阶段 3  | Cocos2DRenderer 移植    | 3 周   | ✅ 完成  | 1.5 天      | Debug/Release 双配置编译通过（见 §阶段3详细）                 |
| 阶段 4  | Nuclear 引擎封装层适配       | 2 周   | ✅ 完成  | 1.5 天      | Debug/Release 均零错误，engine.lib 生成（见 §阶段4详细）      |
| 阶段 5  | CEGUI 定制模块移植          | 3 周   | ✅ 完成  | 1.5 天      | Debug/Release 双配置编译通过（见 §阶段5详细）                 |
| 阶段 6  | FireClient 业务代码适配     | 4 周   | ✅ 完成  | 1 天        | Debug 编译零错误，FireClient.lib（约 167MB）生成（见 §阶段6详细） |
| 阶段 7  | Lua 脚本 + tolua++ 适配   | 2 周   | ✅ 完成  | 0.5 天      | Debug/Release 编译通过，Lua脚本无需适配（见§阶段7详细）           |
| 阶段 8  | 资源文件兼容性处理             | 1 周   | ✅ 完成  | 0.5 天      | 静态验证通过，资源无需修改（见§阶段8详细）                          |
| 阶段 9  | 平台适配                  | 4 周   | ⬜ 待开始 | 2026-08-18 | 2026-09-15                                      |
| 阶段 10 | MT3 补丁移植              | 2 周   | ⬜ 待开始 | 2026-09-15 | 2026-09-29                                      |
| 阶段 11 | 测试验证                  | 4 周   | ⬜ 待开始 | 2026-09-29 | 2026-10-27                                      |
| 阶段 12 | 优化与上线                 | 3 周   | ⬜ 待开始 | 2026-10-27 | 2026-11-17                                      |

### 阶段 0 详细进度

| 任务                                  |  状态  | 结果                                                   |
| ----------------------------------- | :--: | ---------------------------------------------------- |
| CMake 3.10 安装验证                     | ✅ 完成 | 19:00 历史记录为 3.10.0-rc1；当前命令应从 PATH 解析          |
| cocos2d-x-3.0-oh CMakeLists.txt 验证  | ✅ 完成 | 根目录存在，`cmake_minimum_required(VERSION 2.8)`          |
| cocos2d-x-3.0-oh CMake 生成 VS2013 工程 | ✅ 完成 | `build/Cocos2dx.sln`，PlatformToolset=v120            |
| CEGUI 0.7.9-r5 v120 工程确认            | ✅ 完成 | `cegui-0.7.9.win32.vcxproj` + `cegui-0.7.9.sln`，v120 |
| 方案文档修正（VS2013 工具链）                  | ✅ 完成 | v1.2.0，修正 §3 全部内容                                    |
| CMake 路径写入技能/文档                     | ✅ 完成 | 方案 §3.1/§3.2/§3.4，`toolchain-constraints.md`         |

### 阶段 1 详细进度 — Cocos2d-x 3.0-oh 独立编译

| 任务                      |   状态  | 结果                                                                           |
| ----------------------- | :---: | ---------------------------------------------------------------------------- |
| Debug 配置编译              |  ✅ 完成 | 15 个 .lib 全部生成，零错误                                                           |
| Release 配置编译            |  ✅ 完成 | 15 个 .lib 全部生成，零错误                                                           |
| sqlite3 缺失修复            |  ✅ 完成 | 创建 `external/sqlite3/CMakeLists.txt`，复制 `sqlite3.c` 源码，注册到根 `CMakeLists.txt` |
| storage 模块 include 路径修复 |  ✅ 完成 | 修复 `cocos/storage/CMakeLists.txt`，为非 OHOS 平台添加 sqlite3 include 路径            |
| cpp-tests 跳过            | ⚠️ 已知 | cpp-tests 需要 curl.lib（非核心库，暂不处理）                                             |
| ~~audio.lib~~           | ❌ 未生成 | 文档 v1.3.0 列出 audio.lib 为编译产物，实际 Debug/Release 均未生成此文件；已从产物清单移除               |

**Debug 输出**（`build/lib/Debug/`，15 个 .lib，2026-07-26/27）：

| 库文件              | 大小      |
| ---------------- | ------- |
| cocos2d.lib      | 28.2 MB |
| cocostudio.lib   | 12.2 MB |
| cocosbuilder.lib | 8.3 MB  |
| extensions.lib   | 4.3 MB  |
| cocosbase.lib    | 3.9 MB  |
| ui.lib           | 2.8 MB  |
| network.lib      | 2.2 MB  |
| sqlite3.lib      | 937 KB  |
| box2d.lib        | 841 KB  |
| spine.lib        | 396 KB  |
| chipmunk.lib     | 380 KB  |
| tinyxml2.lib     | 151 KB  |
| storage.lib      | 57 KB   |
| unzip.lib        | 29 KB   |
| xxhash.lib       | 5 KB    |

**Release 输出**（`build/lib/Release/`，15 个 .lib，2026-07-27）：同 Debug，大小略小。

### 阶段 2 详细进度 — CEGUI 0.7.9-r5 独立编译

| 任务           |  状态  | 结果                               |
| ------------ | :--: | -------------------------------- |
| Debug 配置编译   | ✅ 完成 | `cegui-0.7.9_d.lib`（约 80 MB），零错误 |
| Release 配置编译 | ✅ 完成 | `cegui-0.7.9.lib`（约 66 MB），零错误   |
| 工程配置         | ✅ 完成 | v120 PlatformToolset，直接可用        |

**关键修复**：无需修复，CEGUI 0.7.9-r5 的 VS2013 (v120) 工程直接可用。

> **注意**：2026-07-27 执行 CppClean 后，`Debug.win32/` 和 `Release.win32/` 下的 .lib 文件已被清理，仅保留 .obj 中间文件。后续需重新编译生成 .lib。

### 阶段 4 详细进度 — Nuclear 引擎封装层适配

> **开始日期**：2026-07-27
> **完成日期**：2026-07-27
> **当前状态**：✅ 完成 — Debug/Release 双配置编译通过，M3 里程碑达成

#### 适配范围

阶段 4 的目标是将 Nuclear 引擎的 Cocos2d-x 封装层（`engine/`）从 Cocos2d-x 2.2.6 API 适配到 3.0-oh API。主要涉及以下模块：

| 模块     | 文件                                    | 适配内容                                              |
| ------ | ------------------------------------- | ------------------------------------------------- |
| 引擎封装核心 | `nucocos2d_wraper.h/.cpp`             | `EngineApp`、`EngineLayer`、`EngineTicker` 类，触摸事件系统 |
| 渲染封装   | `nucocos2d_render.h/.cpp`             | `Cocos2dRenderTarget`、`Cocos2dRenderer`，纹理/渲染目标管理 |
| 引擎核心   | `nuengine.cpp`                        | 引擎初始化，`Image::SetTotalPhysMemory`                 |
| 日志/断言  | `nulog.h`                             | `XPASSERT` 宏中的 `MessageBox` 调用                    |
| 音频接口   | `SimpleAudioEngineCompat.cpp`         | MT3 定制音频方法                                        |
| 资源管理   | `nustatemanager.cpp`、`nurenderer.cpp` | 渲染状态管理，着色器缓存                                      |
| 粒子/特效  | `nuparticleeffect.cpp` 等              | 粒子系统等特效模块                                         |
| 精灵/地图  | `nusprite.cpp`、`nupmap.cpp` 等         | 精灵和地图渲染                                           |

#### 已完成工作

| 任务                                   |  状态  | 结果                                                                                                                                          |
| ------------------------------------ | :--: | ------------------------------------------------------------------------------------------------------------------------------------------- |
| 更新 `engine.win32.vcxproj` Include 路径 | ✅ 完成 | 添加 Cocos2d-x 3.0-oh 全部依赖路径（cocos/2d、base、kazmath、physics、glfw3、glew、freetype2、editor-support 等）                                             |
| 修复 `nucocos2d_wraper.h` 基类适配         | ✅ 完成 | `CCApplication` → `Application`，`CCLayer` → `Layer`，`CCAction` → `Action`                                                                   |
| 触摸事件系统迁移                             | ✅ 完成 | `ccTouchesBegan` → `onTouchesBegan`，`CCSet*` → `std::vector<Touch*>&`                                                                       |
| 修复 `draw()` 方法签名                     | ✅ 完成 | `draw(void)` → `draw(Renderer*, const kmMat4&, bool)`                                                                                       |
| API 全局替换                             | ✅ 完成 | `CCDirector::sharedDirector()` → `Director::getInstance()` 等 20+ 处 API 替换                                                                   |
| 修复 `nucocos2d_render.cpp` 编译错误       | ✅ 完成 | DDS\_HEADER 命名空间、Image::Format::DDS、TextAlign 等 5 类错误                                                                                       |
| 移植 MT3 定制 Cocos2d-x API              | ✅ 完成 | `SimpleAudioEngine` 扩展、`ShaderCache` 扩展、`Texture2D` 扩展、`Image::initWithString`、`GLProgram::setUniformPartParam`、`ccGLEnableVertexAttribs` 等 |
| Spine API 适配                         | ✅ 完成 | `PathToTextureMap` 未声明修复，`Skeleton::draw` 签名                                                                                                |
| Debug 配置编译                           | ✅ 完成 | `engine.lib`（114.22 MB），88 个 .obj，零错误                                                                                                        |
| Release 配置编译                         | ✅ 完成 | `engine.lib`（82.97 MB），88 个 .obj，零错误                                                                                                         |

#### 关键 API 适配清单

| 2.2.6 API                            | 3.0-oh API                                         | 影响文件                      |
| ------------------------------------ | -------------------------------------------------- | ------------------------- |
| `cocos2d::CCApplication`             | `cocos2d::Application`                             | `nucocos2d_wraper.h`      |
| `cocos2d::CCLayer`                   | `cocos2d::Layer`                                   | `nucocos2d_wraper.h/.cpp` |
| `cocos2d::CCAction`                  | `cocos2d::Action`                                  | `nucocos2d_wraper.h/.cpp` |
| `CCDirector::sharedDirector()`       | `Director::getInstance()`                          | 全局 20+ 处                  |
| `CCEGLView::sharedOpenGLView()`      | `Director::getInstance()->getOpenGLView()`         | `nucocos2d_wraper.cpp`    |
| `CCShaderCache::sharedShaderCache()` | `ShaderCache::getInstance()`                       | `nucocos2d_wraper.cpp`    |
| `ccTouchesBegan(CCSet*, CCEvent*)`   | `onTouchesBegan(std::vector<Touch*>&, Event*)`     | `nucocos2d_wraper.h/.cpp` |
| `draw(void)`                         | `draw(Renderer*, const kmMat4&, bool)`             | `nucocos2d_wraper.h/.cpp` |
| `registerWithTouchDispatcher()`      | 移除（`final` 方法）                                     | `nucocos2d_wraper.cpp`    |
| `CC_CONTENT_SCALE_FACTOR()`          | `Director::getInstance()->getContentScaleFactor()` | `nucocos2d_wraper.cpp`    |
| `kCCShader_PositionTextureColor`     | `GLProgram::SHADER_NAME_POSITION_TEXTURE_COLOR`    | `nucocos2d_wraper.cpp`    |
| `kCCVertexAttrib_*`                  | `GLProgram::VERTEX_ATTRIB_*`                       | `nucocos2d_wraper.cpp`    |
| `ccGLBlendFunc`                      | `GL::blendFunc`                                    | `nucocos2d_wraper.cpp`    |
| `ccGLBindTexture2D`                  | `GL::bindTexture2D`                                | `nucocos2d_wraper.cpp`    |
| `ccGLActiveTexture`                  | `GL::activeTexture`                                | `nucocos2d_render.cpp`    |
| `CCTexture2D`                        | `Texture2D`                                        | `nucocos2d_render.h/.cpp` |
| `CCRenderTexture`                    | `RenderTexture`                                    | `nucocos2d_render.h/.cpp` |
| `CCImage`                            | `Image`                                            | `nucocos2d_render.h/.cpp` |
| `CCSize`                             | `Size`                                             | 全局                        |
| `CCPoint` / `Vec2`                   | `Point`                                            | `nucocos2d_wraper.h/.cpp` |
| `Point::distance()`                  | `Point::getDistance()`                             | `nucocos2d_wraper.cpp`    |

#### MT3 定制 Cocos2d-x API 移植

| 模块                  | 方法/常量                                                                             | 移植方式                      | 影响文件                       |
| ------------------- | --------------------------------------------------------------------------------- | ------------------------- | -------------------------- |
| `SimpleAudioEngine` | `hasEffect`、`isEffectPlaying`、`setCurEffectPriority`、`testPriority`               | 从 2.2.6 移植完整实现            | `SimpleAudioEngine.h/.cpp` |
| `ShaderCache`       | `pushShader`、`popShader`、`getSaderStackDepth`、`kCCShader_PositionTextureColorX` 等 | 从 2.2.6 移植 + 适配 3.0-oh 接口 | `CCShaderCache.h/.cpp`     |
| `Texture2D`         | `isEtcTexture`、`getAlphaName`、`initWithPVRTCData`、`initWithATCData`、`DataFileUri` | 添加成员变量 + 存根实现             | `CCTexture2D.h/.cpp`       |
| `Image`             | `initWithString`、`initWithStringShadowStroke`、`SetTotalPhysMemory`、`ETextAlign`   | 添加方法声明 + 存根实现             | `CCImage.h/.cpp`           |
| `GLProgram`         | `setUniformPartParam`、`kCCUniformFloatY`、`kCCUniformFloatRed`                     | 添加方法 + 存根实现               | `CCGLProgram.h/.cpp`       |
| `ccGLStateCache`    | `ccGLEnableVertexAttribs`                                                         | 添加函数 + 存根实现               | `ccGLStateCache.h/.cpp`    |
| `ccTypes.h`         | `DDS_PIXELFORMAT`、`DDS_HEADER`                                                    | 从 2.2.6 移植结构体             | `ccTypes.h`                |
| `CCDeprecated.h`    | `kCCShader_*` 常量冲突                                                                | 用 `#if 0` 注释冲突声明          | `CCDeprecated.h`           |
| OgreDDSCodec        | `OgreDDSCodec.h/.cpp`                                                             | 从 2.2.6 复制到 3.0-oh        | `support/image_support/`   |

#### 修复的编译错误

| 错误类型                                                | 数量   | 修复方式                                                       |
| --------------------------------------------------- | ---- | ---------------------------------------------------------- |
| 头文件路径缺失（kazmath、glew、glfw3、freetype2、spine、physics） | 6 处  | 更新 `engine.win32.vcxproj` 的 `AdditionalIncludeDirectories` |
| `DDS_HEADER` 未声明（命名空间问题）                            | 1 处  | 添加 `cocos2d::` 前缀                                          |
| `Image::Format::DDS` 不存在                            | 2 处  | 替换为 `Image::Format::PNG`（3.0-oh 不支持 DDS）                   |
| `Image::TextAlign::CENTER` 不存在                      | 2 处  | 替换为 `Image::kAlignCenter`（使用 MT3 定制 `ETextAlign`）          |
| `cocos2d::MessageBox` 未找到（Debug）                    | 10 处 | 改用 `::MessageBoxA`（Win32 API），移除 `CCCommon.h` 依赖           |
| 抽象类实例化（`EngineTicker`）                              | 1 处  | 实现 `clone()` 和 `reverse()` 纯虚方法                            |
| `Point::distance()` 不存在                             | 多处   | 替换为 `Point::getDistance()`                                 |
| `Draw` 方法 `final`                                   | 1 处  | 改用重载 `draw(Renderer*, const kmMat4&, bool)`                |
| `registerWithTouchDispatcher` 为 `final`             | 1 处  | 移除方法，依赖 `init()` 中 `setTouchEnabled(true)`                 |
| `CCDeprecated.h` 常量冲突                               | 多处   | 用 `#if 0` 注释冲突的外部声明                                        |

#### vcxproj 关键变更

| 变更项                      | 内容                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| ------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Include 路径新增             | `../cocos2d-x-3.0-oh/cocos/2d/`；`../cocos2d-x-3.0-oh/cocos/base/`；`../cocos2d-x-3.0-oh/cocos/math/kazmath/`；`../cocos2d-x-3.0-oh/cocos/physics/`；`../cocos2d-x-3.0-oh/cocos/2d/platform/`；`../cocos2d-x-3.0-oh/cocos/2d/platform/win32/`；`../cocos2d-x-3.0-oh/cocos/2d/platform/desktop/`；`../cocos2d-x-3.0-oh/cocos/2d/renderer/`；`../cocos2d-x-3.0-oh/cocos/ui/`；`../cocos2d-x-3.0-oh/external/glfw3/include/win32/`；`../cocos2d-x-3.0-oh/external/win32-specific/gles/include/OGLES/`；`../cocos2d-x-3.0-oh/cocos/audio/include/`；`../cocos2d-x-3.0-oh/cocos/deprecated/`；`../cocos2d-x-3.0-oh/external/zlib/include/`；`../cocos2d-x-3.0-oh/external/webp/include/`；`../cocos2d-x-3.0-oh/external/png/include/win32/`；`../cocos2d-x-3.0-oh/external/tiff/include/win32/`；`../cocos2d-x-3.0-oh/external/freetype/include/`；`../cocos2d-x-3.0-oh/extensions/`；`../cocos2d-x-3.0-oh/cocos/editor-support/`；`../cocos2d-x-3.0-oh/external/freetype2/include/win32/`；`../common/platform`；`../common/platform/utils`；`../common/ljfm/code/include`；`../dependencies/LJXML/Include`；`../dependencies/glew-1.7.0/include`；`./engine`；`./common` |
| 兼容层头文件                   | 创建 `cocos2d-x-3.0-oh/cocos/platform/platform.h`（兼容层）                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| Cocos2d-x 3.0-oh 源码修改    | `CCImage.h/.cpp`、`CCTexture2D.h/.cpp`、`CCGLProgram.h/.cpp`、`CCShaderCache.h/.cpp`、`ccGLStateCache.h/.cpp`、`ccTypes.h`、`SimpleAudioEngine.h/.cpp`、`CCSkeletonAnimation.h`、`CCDeprecated.h`、`OgreDDSCodec.h/.cpp`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| nulog.h 修复               | `#include "CCCommon.h"` → `::MessageBoxA`（解决 Debug 下 `MessageBox` 头文件路径问题）                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| nucocos2d\_render.cpp 修复 | 5 类错误修复（DDS\_HEADER、Format::DDS、TextAlign、ccGLActiveTexture、initWithData 参数）                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |

#### 构建产物

| 配置      | obj 数量 | lib 文件       | 大小       |
| ------- | ------ | ------------ | -------- |
| Debug   | 88     | `engine.lib` | 114.22 MB |
| Release | 88     | `engine.lib` | 82.97 MB  |

***

### 阶段 5 详细进度 — CEGUI 定制模块移植

> **开始日期**：2026-07-27
> **完成日期**：2026-07-27
> **当前状态**：✅ 完成 — Debug/Release 双配置编译通过，M3 里程碑达成

#### 移植范围

阶段 5 的目标是将 MT3 在 CEGUI 0.7.1 上扩展的全部定制控件和 Falagard 渲染器移植到 CEGUI 0.7.9-r5，确保编译通过。

| 类别                  | 数量  | 说明                                                                                                                   |
| ------------------- | --- | -------------------------------------------------------------------------------------------------------------------- |
| MT3 定制 Elements     | 25+ | AnimationButton、GroupButton、IrregularButton、RichEditbox（含 \~15 个子组件）、ItemTable、ItemCell、LinkText、MessageTip、Switch 等 |
| MT3 定制 Falagard 渲染器 | 5+  | FalAnimationButton、FalIrregularButton、FalRichEditbox、FalGroupBtnTree 等                                               |
| Cocos2D Renderer    | 6   | 已在阶段 3 完成                                                                                                            |

#### 修复的编译错误（11 大类）

| 类别                               | 错误描述                                                                   | 修复文件数 | 修复方式                                                                                                            |
| -------------------------------- | ---------------------------------------------------------------------- | ----- | --------------------------------------------------------------------------------------------------------------- |
| 1. WindowRenderer 基类接口变更         | 默认构造函数和 `clone()` 不存在                                                  | 4     | 移除默认构造函数，移除 `clone()` 方法                                                                                        |
| 2. Image::draw() 参数类型变更          | `GeometryBuffer*` → `GeometryBuffer&`                                  | 6     | 指针解引用：`draw(buffer, ...)` → `draw(*buffer, ...)`                                                                |
| 3. Font::drawText() 参数变更         | 缺少 underline/border 参数                                                 | 3     | 在 CEGUIFont 中添加默认参数 `bool bIsUnderLine=false, bool bBorder=false, const ColourRect& BorderColours=ColourRect()` |
| 4. CentredRenderedString::draw() | 指针→引用                                                                  | 1     | `draw(*buffer, ...)`                                                                                            |
| 5. MT3 定制 System API 缺失          | 20+ 个回调函数和成员变量                                                         | 3     | 在 CEGUISystem.h 添加 typedef/成员/方法，在 CEGUISystem.cpp 初始化                                                          |
| 6. MT3 定制 Scrollbar API 缺失       | `onMouseSlide`、`isThumbOnEnd`                                          | 2     | 在 CEGUIScrollbar.h 添加方法声明，在 FalScrollbar 实现 isThumbOnEnd                                                        |
| 7. MT3 定制 String API 缺失          | `GetCharLength`                                                        | 1     | 在 CEGUIString.h 添加方法                                                                                            |
| 8. MT3 定制宏/函数缺失                  | `CEGUI_LOGERR`、`SetCanEdit`、`EnbaleSlide`、`getCloneWindowFromTemplate` | 4     | 在 CEGUILogger.h 添加宏，在 CEGUIWindow\.h 添加方法                                                                       |
| 9. ButtonBase 构造函数变更             | 缺少双参数构造函数                                                              | 1     | `ButtonBase(type)` → `ButtonBase(type, "")`                                                                     |
| 10. GestureRecognizer 头文件缺失      | 未使用的头文件引用                                                              | 1     | 移除 `#include "gesture/CEGUILongPressGestureRecognizer.h"`                                                       |
| 11. FalRichEditbox 编码问题          | GBK 编码的 UTF-8 无 BOM 文件                                                 | 1     | 添加 UTF-8 BOM                                                                                                    |

#### 新增的 MT3 定制 API（CEGUI 0.7.9-r5 中）

| 模块                     | 新增 API                                                                                                                                                                                                                                                                                                                    | 说明                       |
| ---------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------ |
| CEGUISystem.h          | `GoToFunction`、`LinkHttpFunction`、`ShowItemTips`、`OnChangelImageClick`、`ShowCompnentTips`、`OnPasteFromClipBord`、`OnCopyToClipBord`、`OnNameLinkClick`、`OnFamilyRecruitClick`、`JoinTeamLinkClicked`、`RequestTeamLinkClicked`、`AnswerQuestionLinkClicked`、`CommonLinkLinkClicked`、`OpenDialog`、`RequestOtherQuest` 等 typedef | 从 0.7.1 移植全部回调函数类型       |
| CEGUISystem.h          | 20+ 个 getter/setter 方法                                                                                                                                                                                                                                                                                                    | 表情、链接、剪贴板、组件提示、物品提示等回调管理 |
| CEGUISystem.h          | `d_defaultCompnenttip`、`d_EmotionNum`、`d_CellImage` 等 10+ 个成员变量                                                                                                                                                                                                                                                           | MT3 定制状态管理               |
| CEGUIScrollbar.h       | `onMouseSlide()`、`isThumbOnEnd()`                                                                                                                                                                                                                                                                                         | 滚动条滑动和终点检测               |
| CEGUIString.h          | `GetCharLength()`                                                                                                                                                                                                                                                                                                         | 字符长度计算                   |
| CEGUIWindow\.h         | `SetCanEdit()`、`EnbaleSlide()`、`getCloneWindowFromTemplate()`                                                                                                                                                                                                                                                             | 窗口编辑和克隆功能                |
| CEGUILogger.h          | `CEGUI_LOGERR` 宏                                                                                                                                                                                                                                                                                                          | 错误日志便捷宏                  |
| CEGUIXMLSerializer.h   | `convertEntityInText()` 改为 public                                                                                                                                                                                                                                                                                         | XML 实体转换公开访问             |
| CEGUIForwardRefs.h     | `CompnentTip`、`RichEditboxComponent` 前向声明                                                                                                                                                                                                                                                                                 | 类型前向声明                   |
| CEGUIButtonBase.h      | `EnableClickAni()`、`isClickAniEnable()` 改为 public                                                                                                                                                                                                                                                                         | 按钮点击动画访问                 |
| CEGUIWindow\.h         | `EnableDrag()`、`GetScreenPos()`、`CheckGuideEnd()`、`onSetTemplateLookNFeel()`                                                                                                                                                                                                                                              | 窗口拖拽和屏幕坐标                |
| CEGUIImagesetManager.h | `getImage(const String& imageset, const String& image)`                                                                                                                                                                                                                                                                   | 便捷图片获取                   |
| CEGUIString.h          | `String(const wchar_t*)` 构造函数                                                                                                                                                                                                                                                                                             | 宽字符串支持                   |
| CEGUIFont.h            | `drawText()` 添加 underline/border 默认参数                                                                                                                                                                                                                                                                                     | 文本渲染兼容                   |

#### 关键文件修改清单

| 文件                                            | 修改类型     | 说明                                                                |
| --------------------------------------------- | -------- | ----------------------------------------------------------------- |
| `CEGUISystem.h`                               | 新增 50+ 行 | 添加 20+ 个 MT3 回调 typedef、成员变量、getter/setter                        |
| `CEGUISystem.cpp`                             | 新增 10 行  | 构造函数初始化新增成员                                                       |
| `CEGUIWindow.h`                               | 新增 20+ 行 | 添加 EnableDrag、SetCanEdit、EnbaleSlide、getCloneWindowFromTemplate 等 |
| `CEGUIWindow.cpp`                             | 新增 40+ 行 | 实现新增方法                                                            |
| `CEGUIScrollbar.h`                            | 新增 10 行  | 添加 onMouseSlide、isThumbOnEnd 声明                                   |
| `CEGUIScrollbar.cpp`                          | 新增 10 行  | 实现 onMouseSlide、isThumbOnEnd                                      |
| `CEGUIString.h`                               | 新增 25 行  | 添加 GetCharLength、wchar\_t 构造函数                                    |
| `CEGUIForwardRefs.h`                          | 新增 2 行   | 添加 CompnentTip、RichEditboxComponent 前向声明                          |
| `CEGUILogger.h`                               | 新增 1 行   | 添加 CEGUI\_LOGERR 宏                                                |
| `CEGUIXMLSerializer.h`                        | 移动 5 行   | convertEntityInText 从 private 移至 public                           |
| `CEGUIButtonBase.h`                           | 移动 2 行   | EnableClickAni/isClickAniEnable 从 protected 移至 public             |
| `CEGUIImagesetManager.h/.cpp`                 | 新增 15 行  | 添加 getImage 便捷方法                                                  |
| `CEGUIBase.h/.cpp`                            | 新增 2 行   | g\_bIsTextLoading 全局变量                                            |
| `CEGUIFont.h/.cpp`                            | 修改 2 行   | drawText 添加默认参数                                                   |
| `FalScrollbar.h/.cpp`                         | 新增 40 行  | 实现 isThumbOnEnd 方法                                                |
| `FalRichEditbox.cpp`                          | 编码修复     | 添加 UTF-8 BOM                                                      |
| `FalAnimationButton.h`、`FalIrregularButton.h` | 删除 4 行   | 移除默认构造函数和 clone()                                                 |
| `CEGUICompnentTip.h`                          | 删除 2 行   | 移除默认构造函数和 clone()                                                 |
| `CEGUIGroupButton.cpp`                        | 修改 1 行   | ButtonBase 构造函数适配                                                 |
| `CEGUIRichEditbox.cpp`                        | 删除 1 行   | 移除不存在的 d\_recognizerManager 调用                                    |
| `CEGUIItemTable.cpp`                          | 删除 1 行   | 移除未使用的 GestureRecognizer 头文件                                      |
| `CEGUIGroupBtnItem.cpp`                       | 修改 6 行   | Image::draw 和 CentredRenderedString::draw 指针→引用                   |
| `CEGUIRichEditboxImageComponent.cpp`          | 修改 3 行   | Image::draw 指针→引用                                                 |
| `CEGUIRichEditboxHttpComponent.cpp`           | 修改 1 行   | Font::drawText 参数适配                                               |
| `CEGUIRichEditboxGoToComponent.cpp`           | 修改 1 行   | Font::drawText 参数适配                                               |
| `CEGUIRichEditboxTextComponent.cpp`           | 修改 2 行   | Image::draw 和 Font::drawText 适配                                   |
| `CEGUIRichEditboxEmotionComponent.cpp`        | 修改 1 行   | Image::draw 指针→引用                                                 |
| `CEGUIRichEditboxButtonImageComponent.cpp`    | 修改 3 行   | Image::draw 指针→引用                                                 |
| `CEGUIRichEditboxLinkTextComponent.cpp`       | 修改 1 行   | Font::drawText 指针→引用                                              |

#### 构建产物

| 配置      | 文件                  | 大小      |
| ------- | ------------------- | ------- |
| Debug   | `cegui-0.7.9_d.lib` | 98.9 MB |
| Release | `cegui-0.7.9.lib`   | 79.6 MB |

#### 后续注意事项

1. **运行时验证尚未进行**：阶段 5 仅完成编译通过，自定义控件的渲染正确性和功能正确性需要在阶段 11（测试验证）中进行。
2. **部分方法为空实现**：`onMouseSlide`、`CheckGuideEnd`、`onSetTemplateLookNFeel` 等方法当前为空实现或存根实现，需要在后续阶段根据实际运行时需求补充。
3. **API 差异可能影响运行时行为**：如 `Font::drawText` 新增的默认参数（underline/border）与 0.7.1 行为可能存在差异，需在集成测试中验证。
4. **编码问题**：`FalRichEditbox.cpp` 等文件中的 GBK 注释在添加 UTF-8 BOM 后可能出现乱码，但不影响编译和功能。

***

### 阶段 6 详细进度 — FireClient 业务代码适配

> **开始日期**：2026-07-27
> **完成日期**：2026-07-28
> **编译配置**：Debug | Win32 | v120
> **编译结果**：零错误，FireClient.lib（约 167MB）生成

#### 任务清单

| 任务                              |  状态  | 结果                                                                                 |
| ------------------------------- | :--: | ---------------------------------------------------------------------------------- |
| FireClient.win32.vcxproj 工程配置更新 | ✅ 完成 | Include 路径、Library 路径全部切换至 3.0-oh + CEGUI 0.7.9-r5                                 |
| tolua++ 接口适配（tolua++.h）         | ✅ 完成 | 补充 tolua\_isfunction、tolua\_ref\_function、tolua\_isluaobj、tolua\_ref\_luaobj 等内联函数 |
| tolua\_fix.cpp 编译集成             | ✅ 完成 | 添加到 FireClient.win32.vcxproj 的 ClCompile 列表                                        |
| HTTP 模块 API 适配                  | ✅ 完成 | CCHttpClient→HttpClient、CCHttpResponse→HttpResponse、kHttpPost→Type::POST           |
| 类型转换修复                          | ✅ 完成 | PlayNPCSound 中 std::wstring→CEGUI::String 转换                                       |
| LuaFireClientWin32.cpp 适配       | ✅ 完成 | 4.3MB 超大文件编译通过（含大量 tolua 绑定代码）                                                     |
| Debug 配置编译验证                    | ✅ 完成 | 零错误，约 5262 个警告（均为 deprecation/macro 重定义）                                           |
| Release 配置编译验证                  | ✅ 完成 | 零错误，FireClient.lib（约 122MB）生成                                                      |

#### 关键适配工作

##### 1. tolua++ 接口适配

Cocos2d-x 3.0-oh 的 `tolua++.h` 缺少 MT3 在 2.2.6 中新增的内联包装函数。在 `cocos2d-x-3.0-oh/external/lua/tolua/tolua++.h` 中添加：

| 新增函数                             | 用途                                            |
| -------------------------------- | --------------------------------------------- |
| `tolua_ref_function`             | 包装 `toluafix_ref_function`，管理 Lua 函数引用        |
| `tolua_remove_function_by_refid` | 包装 `toluafix_remove_function_by_refid`，移除函数引用 |
| `tolua_isfunction`               | 检查栈位置是否为 Lua 函数                               |
| `tolua_ref_luaobj`               | 通过 `luaL_ref` 管理 Lua 对象引用                     |
| `tolua_isluaobj`                 | 检查是否为 Lua 对象（始终返回 true，兼容现有逻辑）                |

##### 2. 工程配置更新

`FireClient.win32.vcxproj` 关键变更：

| 变更项                | 旧值                                                  | 新值                                                                      |
| ------------------ | --------------------------------------------------- | ----------------------------------------------------------------------- |
| CEGUI Include      | `dependencies/cegui/CEGUI/include`                  | `tools/CEGUI-0.7.9-r5/cegui/include`                                    |
| Cocos Include      | `cocos2d-x-2.2.6/cocos2dx`                          | `cocos2d-x-3.0-oh/cocos`                                                |
| Cocos Library      | `cocos2d-x-2.2.6/Debug.win32`                       | `cocos2d-x-3.0-oh/build/lib/Debug`                                      |
| CEGUI Library      | `dependencies/cegui/lib`                            | `tools/CEGUI-0.7.9-r5/cegui-0.7.9/Debug.win32`                          |
| HttpClient.cpp 源路径 | `cocos2d-x-2.2.6/extensions/network/HttpClient.cpp` | `cocos2d-x-3.0-oh/cocos/network/HttpClient.cpp`                         |
| tolua\_fix.cpp     | 未包含                                                 | 新增 `cocos2d-x-3.0-oh/cocos/scripting/lua-bindings/manual/tolua_fix.cpp` |

##### 3. HTTP 模块 API 适配

Cocos2d-x 3.0-oh 将 HTTP 模块从 `cocos2d::extension` 命名空间迁移至 `cocos2d::network`：

| 旧 API                                       | 新 API                            |
| ------------------------------------------- | -------------------------------- |
| `cocos2d::extension::CCHttpClient`          | `cocos2d::network::HttpClient`   |
| `cocos2d::extension::CCHttpResponse`        | `cocos2d::network::HttpResponse` |
| `CCHttpRequest::HttpRequestType::kHttpPost` | `(int)HttpRequest::Type::POST`   |

##### 4. 类型转换修复

`PlayNPCSound` 方法需要 `std::wstring` 到 `CEGUI::String` 的显式转换：

```cpp
const std::wstring soundRes = tolua_tocppwstring(tolua_S, 2, 0);
CEGUI::String ceguiSoundRes(soundRes.c_str());
self->PlayNPCSound(ceguiSoundRes, iNpcId, bForcePlay);
```

##### 5. 已知警告（无需修复）

- **C4996 deprecation 警告**（约 5000+ 条）：Cocos2d-x 3.0-oh 中 `CCImage`、`CCLayer`、`CCArray`、`CCUserDefault`、`ScriptEngineManager::sharedManager` 等标记为 deprecated，但通过 `ccdeprecated.h` 提供向后兼容 typedef
- **C4005 宏重定义**：`POLLIN`/`POLLOUT`/`POLLERR` 在 `pollio.h` 和 `winsock2.h` 中重复定义
- **C4190 C 链接警告**：`tolua_tocppwstring` 返回 UDT 类型

#### 构建产物

| 配置      | 文件             | 大小       |
| ------- | -------------- | -------- |
| Debug   | FireClient.lib | 169.18 MB |
| Release | FireClient.lib | 约 122 MB |

#### 后续注意事项

1. **Release 编译已验证通过**：零错误，FireClient.lib（约 122MB）生成
2. **链接阶段未验证**：阶段 6 仅生成 FireClient.lib（静态库），尚未进行 MT3.exe 链接，链接阶段可能发现新的符号缺失问题
3. **运行时验证尚未进行**：编译通过不代表功能正确，需在阶段 11 进行集成测试
4. **LuaFireClientWin32.cpp 为生成文件**：该文件由 tolua++ 生成，后续若修改 .pkg 定义需重新生成

***

### 阶段 7 详细进度 — Lua 脚本 + tolua++ 适配

> **日期**：2026-07-28
> **编译**：Debug + Release | Win32 | v120，零错误

#### 任务清单

| 任务                |  状态 | 结果                                |
| ----------------- | :-: | --------------------------------- |
| .pkg 文件 API 适配    |  OK | 3 个文件，11 处旧 API 引用全部更新            |
| nuiengine.h 修复    |  OK | CCLayer→Layer                     |
| tolua++ 绑定重新生成    |  跳过 | 现有绑定通过 deprecated typedef 兼容      |
| Lua 脚本分析（2560 文件） |  OK | 仅 2 处 CCUserDefault，CEGUI API 全兼容 |
| Debug 编译验证        |  OK | 零错误，FireClient.lib（169.18 MB）       |
| Release 编译验证      |  OK | 零错误，FireClient.lib（\~122MB）       |

#### 关键发现

1. .pkg 文件旧 API 引用（11 处）全部更新为 3.0-oh API
2. 3.0-oh CCDeprecated.h 提供 typedef Image CCImage / typedef Layer CCLayer 向后兼容
3. 2560 个 Lua 文件仅 2 处 CCUserDefault 引用，CEGUI API 全兼容，无需适配
4. tolua++.exe 不在工作区，.pkg 文件已更新供后续使用

### 阶段 8 详细进度 — 资源文件兼容性处理

> **日期**：2026-07-28
> **方式**：静态验证（运行时验证在阶段 11）

#### 资源统计

**CEGUI 资源**（`client/resource/res/ui/`）：

| 资源类型                  | 数量    | 兼容性  | 说明                                                 |
| --------------------- | ----- | ---- | -------------------------------------------------- |
| `.scheme`             | 2     | 格式兼容 | 所有 FalagardMapping 的 TargetType/Renderer 已在阶段 5 移植 |
| `.layout`             | 857   | 格式兼容 | 标准 CEGUI XML，WindowType 映射存在即可加载                   |
| `.imageset`           | 631   | 格式兼容 | XML 格式在 0.7.1→0.7.9-r5 之间完全一致                      |
| `.font`               | 87    | 格式兼容 | FreeType 格式完全一致，可直接复用                              |
| `.looknfeel`          | 2     | 格式兼容 | Falagard XML 格式稳定，阶段 5 已移植全部自定义 WidgetLook         |
| 图片资源 (.png/.tga/.jpg) | \~625 | 完全兼容 | 二进制图片无需修改                                          |

**Cocos2d-x 资源**（`client/resource/res/`）：

| 资源类型     | 数量    | 兼容性  | 说明                                     |
| -------- | ----- | ---- | -------------------------------------- |
| `.plist` | 1     | 格式兼容 | plist 纹理图集格式在 2.2.6→3.0-oh 之间完全兼容      |
| `.png`   | 32748 | 格式兼容 | PNG 纹理直接兼容，3.0-oh 的 Texture2D 加载逻辑向后兼容 |

#### 验证方法

1. **scheme 文件完整性**：逐项检查 2 个 .scheme 文件中引用的所有 Imageset、Font、LookNFeel 文件是否存在，所有 FalagardMapping 的 WindowType 对应的 TargetType 和 Renderer 是否已在阶段 5 移植
2. **layout 文件格式**：抽样检查 layout 文件的 XML 结构，确认 WindowType 均在 scheme 的 FalagardMapping 中定义
3. **imageset 引用完整性**：验证 imageset 中引用的 Imagefile（.png/.tga/.jpg）是否存在
4. **font 引用完整性**：验证 font 中引用的 Filename（.ttf）是否存在
5. **Cocos2d-x 资源兼容性**：确认 plist 和 png 格式在 3.0-oh 的 TextureCache/SpriteFrameCache 中可正常加载

#### 关键结论

1. **CEGUI 资源格式在 0.7.1→0.7.9-r5 之间高度兼容**：.scheme/.layout/.imageset/.font/.looknfeel 的 XML 格式完全一致，无需任何格式转换
2. **Cocos2d-x 资源格式在 2.2.6→3.0-oh 之间完全兼容**：plist/png 纹理资源在 3.0-oh 的 Texture2D/TextureCache 中可正常加载，无需修改
3. **资源加载的关键依赖是阶段 5 的定制模块移植**：只要 CEGUI 的 Cocos2DRenderer、Cocos2DImageCodec 和自定义控件移植成功，资源文件即可正常加载
4. **运行时验证将在阶段 11 进行**：当前仅完成静态验证，实际加载行为需在阶段 11（集成测试）中通过运行时验证

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

| 经验                      | 说明                                           |
| ----------------------- | -------------------------------------------- |
| 产物验证必须以文件系统为准           | 不能仅凭 CMakeLists.txt 或构建日志推断，必须在磁盘上验证每个产物     |
| Debug 和 Release 必须分别验证  | Debug 通过不代表 Release 通过，反之亦然                  |
| 双引擎升级的耦合点集中在 Renderer 层 | CEGUI 的 Renderer 和 Cocos2d-x 的渲染 API 是最高风险区域 |
| 增量构建后建议做 CppClean       | 旧的 .obj 可能掩盖新代码的编译错误                         |
| include 路径需要全量添加        | 3.0-oh 的分层结构要求每个子目录单独添加，不能只加根目录              |

### D.5 阶段 5：CEGUI 定制模块移植

#### 坑 6：CEGUI 0.7.9-r5 缺失 MT3 大量定制 API

- **现象**：编译时出现 \~200 个错误，涉及 `CompnentTip` 未定义、`GoToFunction` 等回调类型未声明、`onMouseSlide`/`isThumbOnEnd` 不存在、`CEGUI_LOGERR` 宏未定义等
- **根因**：MT3 在 CEGUI 0.7.1 上深度定制了 System、Window、Scrollbar、String 等核心类，添加了 50+ 个定制 API。这些 API 在 0.7.9-r5 中不存在
- **修复**：
  1. 在 CEGUISystem.h 中添加 20+ 个回调 typedef 和对应的 getter/setter 方法
  2. 在 CEGUIWindow\.h 中添加 `EnableDrag`、`SetCanEdit`、`EnbaleSlide`、`getCloneWindowFromTemplate` 等方法
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

### D.6 阶段 6：FireClient 业务代码适配

#### 坑 10：tolua++ 接口缺失导致 LuaFireClientWin32.cpp 编译失败

- **现象**：编译 `LuaFireClientWin32.cpp` 时出现 `C3861`（找不到标识符）错误，涉及 `tolua_isfunction`、`tolua_ref_function`、`tolua_isluaobj`、`tolua_ref_luaobj`
- **根因**：Cocos2d-x 3.0-oh 的 `tolua++.h` 只包含标准 tolua 接口，缺少 MT3 在 2.2.6 中新增的内联包装函数。`tolua_isfunction` 和 `tolua_isluaobj` 是 `LuaFireClientWin32.cpp`（4.3MB 生成文件）中被大量使用的类型检查函数
- **修复**：在 `cocos2d-x-3.0-oh/external/lua/tolua/tolua++.h` 中添加 5 个内联函数实现：
  - `tolua_ref_function`：包装 `toluafix_ref_function`
  - `tolua_remove_function_by_refid`：包装 `toluafix_remove_function_by_refid`
  - `tolua_isfunction`：基于 `lua_isfunction` 实现
  - `tolua_ref_luaobj`：基于 `luaL_ref` 实现
  - `tolua_isluaobj`：始终返回 1（兼容现有逻辑）
- **教训**：tolua++ 绑定代码的依赖链很深，需要同时适配 tolua++.h 头文件和 tolua\_fix.cpp 编译单元

#### 坑 11：tolua\_fix.cpp 未包含在工程中

- **现象**：链接阶段缺少 `toluafix_ref_function` 和 `toluafix_remove_function_by_refid` 符号
- **根因**：`tolua_fix.cpp` 在 Cocos2d-x 3.0-oh 中路径为 `cocos/scripting/lua-bindings/manual/tolua_fix.cpp`，未包含在 `FireClient.win32.vcxproj` 的 ClCompile 列表中
- **修复**：在 `FireClient.win32.vcxproj` 中添加 `<ClCompile Include="..\..\cocos2d-x-3.0-oh\cocos\scripting\lua-bindings\manual\tolua_fix.cpp">`，并设置 `PrecompiledHeader` 为 `NotUsing`
- **教训**：tolua++ 的运行时实现分散在多个文件中，迁移时需要确保所有依赖的编译单元都包含在工程中

#### 坑 12：HTTP 模块 API 命名空间变更

- **现象**：编译 `LuaFireClientWin32.cpp` 时出现 `C2065`（未声明标识符）错误，涉及 `cocos2d::extension::CCHttpClient`、`cocos2d::extension::CCHttpResponse`、`kHttpPost`
- **根因**：Cocos2d-x 3.0-oh 将 HTTP 模块从 `cocos2d::extension` 命名空间迁移至 `cocos2d::network`，类名也去掉了 `CC` 前缀
- **修复**：
  - `CCHttpClient` → `HttpClient`（含命名空间变更）
  - `CCHttpResponse` → `HttpResponse`
  - `CCHttpRequest::HttpRequestType::kHttpPost` → `(int)HttpRequest::Type::POST`（枚举类型也变更）
- **教训**：Cocos2d-x 3.0 的命名空间重构影响面广，HTTP、网络、音频等模块都需要关注

#### 坑 13：wstring 到 CEGUI::String 的类型转换

- **现象**：`PlayNPCSound` 调用处出现 `C2664`（参数类型转换失败）错误
- **根因**：`tolua_tocppwstring` 返回 `std::wstring`，但 `PlayNPCSound` 需要 `CEGUI::String` 参数，两者之间没有隐式转换。Cocos2d-x 3.0-oh 的 CEGUI String 类与 2.2.6 版本不兼容
- **修复**：添加显式转换 `CEGUI::String ceguiSoundRes(soundRes.c_str());`
- **教训**：跨引擎边界的类型转换需要显式处理，不能依赖隐式转换

#### 坑 14：编译日志文件路径中的分号导致 PowerShell 语法错误

- **现象**：MSBuild 的 `/flp` 参数中 `;Verbosity=minimal` 被 PowerShell 解析为独立语句，报 `The term 'Verbosity=minimal' is not recognized`
- **根因**：PowerShell 中分号 `;` 是语句分隔符，MSBuild 的 `/flp:logfile=xxx;Verbosity=minimal` 在 PowerShell 中需要转义或使用引号包裹
- **修复**：将整个 `/flp:` 参数值用引号包裹，或移除 `;Verbosity=minimal` 部分（MSBuild 默认输出 minimal 级别）
- **教训**：在 PowerShell 中调用 MSBuild 时，注意分号、逗号等特殊字符的转义

***

## 附录 E：19:00 初次产物核查（已由 §8 取代）

> **核查方式**：逐项检查磁盘产物存在性、时间戳、文件大小，交叉验证文档记载与实际状态
> **核查范围**：阶段 0-8 全部构建产物、工程配置、.lib 文件、canonical 脚本
>
> **时效说明**：本附录是 19:00 时点的初查快照；其 Cocos 产物结论已于 19:25 复核确认。初查仍使用“编译即完成”的旧口径，当前状态、百分比、风险、责任和排期统一以 §8 为准。

### E.1 磁盘产物逐项核查

#### E.1.1 Cocos2d-x 3.0-oh（阶段 1）

| 核查项 | 文档记载 | 实际状态 | 结论 |
|--------|---------|---------|------|
| `build/Cocos2dx.sln` | 存在 | ✅ 存在，v120 | 一致 |
| Debug .lib 数量 | 15 个 | **16 个**（新增 tolua.lib，98 KB） | 文档未记载 tolua.lib |
| Debug .lib 最新时间戳 | 2026-07-26/27 | 2026-07-28（cocos2d.lib 225.53 MB） | lib 已重新编译更新 |
| Release .lib | 15 个 | 15 个（Release 无 tolua.lib） | 一致 |

#### E.1.2 CEGUI 0.7.9-r5（阶段 2+5）

| 核查项 | 文档记载 | 实际状态 | 结论 |
|--------|---------|---------|------|
| Debug lib | 95.1 MB | **98.9 MB**（2026-07-28 18:23） | 文档偏低 |
| Release lib | 78.6 MB | **79.6 MB**（2026-07-28 11:19） | 文档偏低 |
| 构建日志验证 | 曾报告 152 错误 | **构建日志确认"生成成功"，零错误**（2026-07-28 11:09） | ✅ 152 错误已全部修复 |
| CppClean 后恢复 | 标记"需重新编译" | 已重新编译，lib 已恢复 | 已修复 |

#### E.1.3 Nuclear 引擎（阶段 4）

| 核查项 | 文档记载 | 实际状态 | 结论 |
|--------|---------|---------|------|
| `engine.lib` Debug | 119.8 MB | **114.22 MB**（2026-07-28 17:57） | 文档偏高 5.6 MB |
| `engine.lib` Release | 87.0 MB | **82.97 MB**（2026-07-28 07:46） | 文档偏高 4.0 MB |

#### E.1.4 FireClient 业务层（阶段 6+7）

| 核查项 | 文档记载 | 实际状态 | 结论 |
|--------|---------|---------|------|
| `FireClient.lib` Debug | ~167 MB | **169.18 MB**（2026-07-28 18:37） | 文档偏低 2.2 MB |
| `FireClient.lib` Release | ~122 MB | **122.11 MB**（2026-07-28 07:51） | 基本一致 |
| Release 编译状态 | 先标注"待执行"后标注"已通过" | ✅ 已验证通过 | 文档矛盾已修正 |

#### E.1.5 MT3.exe 链接（阶段 6 未覆盖）

| 核查项 | 状态 | 说明 |
|--------|------|------|
| `MT3.lib` | ✅ 存在（23 KB，2026-07-28 18:39） | MT3 壳层工程编译产物 |
| `MT3.exe` 链接 | ❌ **未执行** | 尚未执行完整的 MT3.exe 链接 |
| `mt3.win32.vcxproj` Include 路径 | ✅ 已更新至 3.0-oh | 全部切换至 `cocos2d-x-3.0-oh/cocos/...` 和 `tools/CEGUI-0.7.9-r5/cegui/include/...` |
| `mt3.win32.vcxproj` Library 依赖 | ✅ 已更新至 3.0-oh | 使用 `cocos2d.lib`、`cocosbase.lib`、`cegui-0.7.9_d.lib` 等新名称 |
| `mt3.win32.vcxproj` Library 目录 | ⚠️ 部分残留旧路径 | 已含 3.0-oh 路径，但仍保留 `cocos2d-x-2.2.6/...` 和 `dependencies/...` 旧路径 |
| 遗留问题 | ⚠️ 1 处旧 CEGUI 0.7.1 路径 | Include 路径中仍含 `../../dependencies/cegui/CEGUI/include/XMLParserModules/XMLIOParser` |

> **结论**：`mt3.win32.vcxproj` 已基本完成路径切换。MT3.exe 链接就绪，可立即执行。

#### E.1.6 Canonical 构建脚本（阶段 0 回归）

| 核查项 | 状态 | 说明 |
|--------|------|------|
| `Build-MT3-Exe-Canonical.ps1` | ❌ 仍指向 2.2.6 | canonical 脚本未更新，仍引用 `cocos2d-x-2.2.6/` 和 `dependencies/cegui/` |
| 脚本适配 | 🔴 阻塞 | 需在 MT3.exe 链接验证前或同步更新 canonical 脚本路径 |

### E.2 进度偏差分析

| 阶段 | 预估工期 | 实际耗时 | 偏差 | 分析 |
|------|---------|---------|------|------|
| 阶段 0 | 1 周 | 0.5 天 | -93% | 环境就绪 |
| 阶段 1 | 2 周 | 0.5 天 | -96% | CMake 生成顺利 |
| 阶段 2 | 1.5 周 | <0.5 天 | -97% | v120 工程直接可用 |
| 阶段 3 | 3 周 | 1.5 天 | -93% | Renderer 移植比预期简单 |
| 阶段 4 | 2 周 | 1.5 天 | -89% | API 适配模式明确 |
| 阶段 5 | 3 周 | 1.5 天 | -93% | 11 类错误系统性修复 |
| 阶段 6 | 4 周 | 1 天 | -94% | tolua++ 和 HTTP 适配集中处理 |
| 阶段 7 | 2 周 | 0.5 天 | -96% | Lua 脚本几乎无需适配 |
| 阶段 8 | 1 周 | 0.5 天 | -93% | 静态验证（45 个 layout 失败待修复） |
| **累计** | **19.5 周** | **~6.5 天** | **-95%** | — |

**偏差原因**：1) 预估值基于保守假设；2) `CCDeprecated.h` 提供了大量向后兼容 typedef；3) VS2013 (v120) 无需升级；4) CEGUI XML 格式高度兼容；5) AI 辅助工具大幅加速适配。

### E.3 已完成工作质量评估

| 阶段 | 评级 | 关键评估 |
|------|------|---------|
| 阶段 0-2（基础设施） | A | 环境配置一次通过，CEGUI 0.7.9-r5 独立编译零修复 |
| 阶段 3-5（引擎层适配） | A- | 三项编译全部通过，152 错误已全部修复；部分 API 为存根实现 |
| 阶段 6-7（业务层适配） | B+ | FireClient 31 文件编译通过；~5262 deprecation 警告；MT3.exe 链接未验证 |
| 阶段 8（资源验证） | B | 静态验证覆盖全面；45 个 layout 加载失败；零运行时验证 |

**降低评级的主要因素**：存根实现（DDS→PNG 降级、空实现回调）、MT3.exe 链接未验证、运行时验证零覆盖、layout 加载失败。

### E.4 未完成任务的阻碍因素

| 未完成任务 | 当前阻碍 | 解决进展 | 预计可开始 |
|-----------|---------|---------|-----------|
| MT3.exe 链接 | canonical 脚本未更新 + 1 处旧 CEGUI 路径 | ✅ 工程路径已确认切换 | 立即可执行 |
| 阶段 8 修复 | 45 个 layout 加载失败 | 待分析根因 | MT3.exe 链接后 |
| 阶段 9 平台适配 | 依赖 MT3.exe 链接通过 | 未开始 | MT3.exe 链接通过后 |
| 阶段 10 MT3 补丁移植 | 部分依赖阶段 9 验证 | 补丁清单已明确 | 阶段 9 后期可并行 |
| 阶段 11 测试验证 | 依赖阶段 9-10 | 未开始 | 阶段 10 完成后 |

### E.5 更新后的风险矩阵

| 风险编号 | 风险描述 | 原等级 | 当前状态 | 更新说明 |
|---------|---------|--------|---------|---------|
| **R1** | Cocos2DRenderer 双端适配 | 致命 | 🟡 编译通过，运行时未验证 | 阶段 3 编译通过 |
| **R2** | CEGUI 自定义控件移植 | 致命 | 🟡 编译通过，运行时未验证 | 阶段 5 编译通过，152 错误已修复 |
| **R3** | Nuclear 封装层适配 | 致命 | 🟡 编译通过，运行时未验证 | 阶段 4 编译通过 |
| **R4** | tolua++ 绑定不兼容 | 严重 | 🟢 已缓解 | deprecated typedef 兼容，.pkg 已更新 |
| **R5** | CEGUI Lua 绑定 API 变更 | 严重 | 🟢 已缓解 | 2560 .lua 分析确认兼容 |
| **R6** | 渲染结果不一致 | 严重 | 🔴 未验证 | 阶段 11 才能验证 |
| **R7** | MT3 补丁移植遗漏 | 严重 | 🟡 部分存根 | 阶段 10 需完整实现 |
| **R8** | 性能退化 | 严重 | 🔴 未验证 | 阶段 11 才能验证 |
| **R9** | 构建系统迁移耗时 | 中等 | 🟢 已缓解 | vcxproj 保留 |
| **R10** | 第三方依赖版本冲突 | 中等 | 🟢 未发现 | 阶段 0-8 无冲突 |
| **R11** | CEGUI 资源格式不兼容 | 中等 | 🟡 45 个 layout 失败 | 阶段 8 待修复 |
| **R12** | OHOS 平台不稳定 | 低 | ⬜ 未开始 | 阶段 9 开始 |
| **R13** | 预编译 .lib 重编译失败 | 已解决 | ✅ 已解决 | VS2013 工具链兼容 |

### E.6 后续工作建议

#### E.6.1 立即执行（P0）

1. **MT3.exe 链接验证**：更新 canonical 脚本或直接使用 `mt3.win32.vcxproj` 执行 Debug 链接，验证符号完整性
2. **清理残留旧 CEGUI 路径**：移除 `mt3.win32.vcxproj` 中 `../../dependencies/cegui/CEGUI/include/XMLParserModules/XMLIOParser`

#### E.6.2 短期（P1）

3. **阶段 8 修复**：分析 45 个 layout 加载失败根因
4. **阶段 9 平台适配启动**：MT3.exe 链接通过后立即开始
5. **canonical 脚本更新**：同步更新 `Build-MT3-Exe-Canonical.ps1` 路径

#### E.6.3 中期（P2）

6. **阶段 10 补丁移植准备**：梳理存根实现，制定完整实现计划
7. **阶段 11 测试验证规划**：制定渲染对比、功能回归、性能基准测试方案
8. **Android/iOS 构建环境准备**：提前确认 NDK/Xcode 工具链可用性
