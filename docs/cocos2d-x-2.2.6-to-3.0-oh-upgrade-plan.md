# MT3 项目 Cocos2d-x 引擎升级方案

## 从 Cocos2d-x 2.2.6 迁移至 Cocos2d-x 3.0-oh (OpenHarmony)

> **版本**：1.0.0
>
> **日期**：2026-07-25
>
> **状态**：草案
>
> **目标**：将 MT3 游戏客户端底层引擎从 Cocos2d-x 2.2.6 升级至 Cocos2d-x 3.0-oh（基于 3.17.2-oh），同步支持 OpenHarmony 平台

---

## 目录

1. [项目背景与目标](#1-项目背景与目标)
2. [现状分析](#2-现状分析)
3. [技术调研：2.2.6 → 3.0-oh 核心变更](#3-技术调研226--30-oh-核心变更)
4. [阶段一：前期准备](#4-阶段一前期准备)
5. [阶段二：技术调研与方案设计](#5-阶段二技术调研与方案设计)
6. [阶段三：基础框架层迁移](#6-阶段三基础框架层迁移)
7. [阶段四：业务逻辑层迁移](#7-阶段四业务逻辑层迁移)
8. [阶段五：测试验证](#8-阶段五测试验证)
9. [阶段六：优化与上线](#9-阶段六优化与上线)
10. [风险管理](#10-风险管理)
11. [附录](#11-附录)

---

## 1. 项目背景与目标

### 1.1 背景

MT3 是一款基于 Cocos2d-x 2.2.6 + Nuclear 自研引擎 + FireClient 业务框架的大型多平台游戏项目，当前支持 Win32、Android、iOS 三个平台。Cocos2d-x 2.2.6 发布于 2014 年，已停止官方维护。

### 1.2 升级目标

| 目标 | 说明 |
|------|------|
| 引擎现代化 | 迁移至 Cocos2d-x 3.0-oh（基于 3.17.2-oh），获取 v3 系列全部性能优化和 Bug 修复 |
| OpenHarmony 支持 | 通过 3.0-oh 内置的 OHOS 平台适配层，新增 OpenHarmony/HarmonyOS NEXT 平台支持 |
| 渲染架构升级 | 从 2.x 固定管线升级到 3.x 可编程渲染管线，支持更高效的批处理与渲染状态管理 |
| C++ 标准现代化 | 3.x 支持 C++11/14 特性（lambda、智能指针、auto 等），替代 2.x 的 C++98 风格宏和选择器 |
| 构建系统现代化 | 从 VS2013 v120 工程迁移到 CMake 构建系统，为未来工具链升级铺路 |
| 保持功能完整性 | 确保升级后所有现有功能（渲染、UI、Lua、网络、资源加载等）与原有行为一致 |

### 1.3 升级范围

| 范围 | 影响 |
|------|------|
| 引擎层 | 替换 `cocos2d-x-2.2.6/` 为 `cocos2d-x-3.0-oh/` 作为构建依赖 |
| 平台适配层 | 重写 Nuclear 引擎对 Cocos2d 的封装层 (`nucocos2d_wraper`) |
| 构建系统 | Win32 从 vcxproj 迁移到 CMake + MSBuild；Android 从 Android.mk 迁移到 CMake + Gradle；新增 OHOS 构建 |
| 第三方依赖 | 调整 CEGUI、tolua++、Spine 等与 Cocos2d 的接口 |
| 业务代码 | FireClient 和 Lua 脚本中所有直接使用 Cocos2d API 的代码 |
| 工具链 | 资源打包、协议生成、热更新等工具 |

---

## 2. 现状分析

### 2.1 当前项目架构

```
MT3/
├── cocos2d-x-2.2.6/          # 当前 Cocos2d-x 引擎（125 个 .vcxproj 工程）
│   ├── cocos2dx/             # 核心引擎（CC 前缀命名空间）
│   ├── CocosDenshion/        # 音频引擎（FMOD/MCI 后端）
│   ├── extensions/           # 扩展（Spine、CocosBuilder、Network 等）
│   ├── scripting/            # Lua/JS 绑定
│   └── external/             # 第三方库（Box2D、chipmunk、freetype 等）
│
├── cocos2d-x-3.0-oh/         # 目标引擎（已拉取，52 个 .vcxproj 工程）
│   ├── cocos/                # 核心引擎（无 CC 前缀，cocos2d 命名空间）
│   ├── extensions/           # 扩展（Spine、CocosStudio 等）
│   ├── external/             # 第三方库（含 ohos-specific/）
│   ├── cmake/                # CMake 构建模块
│   └── tools/                # cocos 命令行工具
│
├── engine/                   # Nuclear 自研引擎（核心封装层）
│   ├── engine/               # 引擎核心（nucocos2d_wraper 等）
│   ├── engine.win32.vcxproj  # Win32 工程
│   ├── engine.ios.xcodeproj  # iOS 工程
│   └── Android.mk            # Android 构建
│
├── client/
│   ├── FireClient/Application/  # 共享业务层（C++/Lua）
│   ├── MT3Win32App/             # Win32 壳层
│   ├── android/                 # Android 壳层（LocojoyProject 等）
│   └── FireClient/FireClient/   # iOS 壳层
│
├── common/                   # 公共库
│   ├── platform/             # 平台抽象
│   ├── tolua++-1.0.93/       # tolua++ 绑定生成器
│   ├── lua/                  # Lua 运行时
│   ├── ljfm/                 # 文件系统
│   ├── cauthc/               # 认证
│   └── updateengine/         # 热更新引擎
│
├── dependencies/             # 第三方依赖
│   ├── cegui/                # CEGUI 0.7.1（含 Cocos2D Renderer）
│   ├── freetype-2.4.12/      # 字体渲染
│   ├── libpng-1.4.5/         # PNG 解码
│   ├── zlib/                 # 压缩
│   ├── glew-1.7.0/           # OpenGL 扩展
│   ├── glm-0.9.4.5/          # 数学库
│   └── ... (40+ 个依赖库)
│
├── server/                   # 服务端（Java/Ant）
├── gbeans/                   # 配置源定义
└── tools/                    # 构建工具链
```

### 2.2 Cocos2d-x 2.2.6 当前使用情况统计

| 维度 | 数量/范围 |
|------|-----------|
| `.vcxproj` 引用 Cocos2d 的工程 | 73 个（含引擎内 125 个） |
| `#include <cocos2d.h>` 引用文件 | 100+ 个 .cpp/.h |
| `cocos2d::` 命名空间使用 | 100+ 个文件 |
| Android.mk 引用 | 5+ 个（engine, FireClient, Locojoy, Yijie, Joysdk） |
| Xcode 工程引用 | 126 处（FireClient）+ 14 处（engine） |
| MT3 专属补丁 | 10+ 个类别（shader, texture, Lua, Spine, audio 等） |

### 2.3 MT3 在 Cocos2d-x 2.2.6 上的专属补丁清单

这些补丁在升级时**必须逐一重新评估和移植**：

| 补丁类别 | 涉及文件 | 功能 |
|----------|----------|------|
| Win32 音频 Shim | `SimpleAudioEngine.h/.cpp` | 保留 MT3 遗留音效查询/优先级/启用接口 |
| Shader 兼容 | `CCShaderCache`, `CCGLProgram`, `ccShaders` | 恢复 ETC/HSV/X/Gray shader，多纹理单元 API |
| 纹理压缩兼容 | `CCTexture2D`, `ccTypes.h`, `CCConfiguration` | DDS/ATC/PVRTC/ETC 直接纹理加载 |
| Lua 脚本桥接 | `CCScriptSupport`, `CCLuaEngine` | 恢复 2.0 时代 Lua 桥接助手 |
| Spine JSON 兼容 | `extensions/spine/Json` | 保留全局 Spine C JSON API |
| 视频播放器 Shim | `VideoPlayerEngine.h` | 启动 CG 调用链兼容 |
| 照片选择器 Shim | `PhotoPicker.h` | 照片选择器回调兼容 |
| 2.0 API 兼容 | `CCDirector`, `CCTextureCache`, `HttpClient` | 渲染暂停/后台标志、纹理重载等 |
| FireClient 兼容 | `tolua++.h`, `ljfmtableloader.h`, `CEGUIBase.h` | tolua++ wstring 助手、Lua 函数引用等 |

### 2.4 关键依赖与 Cocos2d 的耦合点

| 依赖组件 | 耦合方式 | 升级影响 |
|----------|----------|----------|
| **Nuclear 引擎** | `EngineApp : CCApplication`, `EngineLayer : CCLayer`, `EngineTicker : CCAction` | 高 - 核心类继承 Cocos2d 基类 |
| **CEGUI** | `CEGUICocos2DTexture`, `CEGUICocos2DImageCodec` | 高 - 直接使用 Cocos2d 纹理和图像接口 |
| **tolua++** | `LuaEngine.cpp`, `LuaFireClient.cpp`（生成代码） | 高 - 绑定代码依赖 Cocos2d 类型 |
| **Spine** | `extensions/spine/` | 中 - 动画系统 |
| **FMOD / 音频** | `CocosDenshion/` | 中 - 音频引擎后端 |
| **LJFM** | 文件系统加载 | 低 - 通过 FileUtils 间接依赖 |
| **网络** | `HttpClient` | 中 - HTTP 请求 |

---

## 3. 技术调研：2.2.6 → 3.0-oh 核心变更

### 3.1 命名空间与类名变更（最高频、最大工作量）

Cocos2d-x 3.0 移除了所有 `CC` 前缀：

| 2.2.6 | 3.0-oh |
|-------|--------|
| `CCNode` | `Node` |
| `CCSprite` | `Sprite` |
| `CCLayer` | `Layer` |
| `CCScene` | `Scene` |
| `CCDirector` | `Director` |
| `CCApplication` | `Application` |
| `CCAction`, `CCCallFunc` 等 | `Action`, `CallFunc` 等 |
| `CCObject` | `Ref` |
| `CCString` | 移除（使用 `std::string`） |
| `CCArray` | `Vector<T>` |
| `CCDictionary` | `Map<K,V>` |
| `CCSet` | `Set<T>`（或 `std::set`） |

### 3.2 单例模式变更

| 2.2.6 | 3.0-oh |
|-------|--------|
| `CCDirector::sharedDirector()` | `Director::getInstance()` |
| `CCSpriteFrameCache::sharedSpriteFrameCache()` | `SpriteFrameCache::getInstance()` |
| `CCTextureCache::sharedTextureCache()` | `TextureCache::getInstance()` |
| `CCFileUtils::sharedFileUtils()` | `FileUtils::getInstance()` |
| 其他 `sharedXXX()` | 统一 `getInstance()` |

### 3.3 基础类型变更

| 2.2.6 | 3.0-oh |
|-------|--------|
| `CCPoint` / `ccp(x,y)` | `Vec2(x,y)` 或 `Point(x,y)` |
| `CCSize` | `Size` |
| `CCRect` | `Rect` |
| `ccpAdd/sub/mult` | 运算符重载 `+` `-` `*` |
| `ccc3(r,g,b)` | `Color3B(r,g,b)` |
| `ccc4(r,g,b,a)` | `Color4B(r,g,b,a)` |
| `CCPointZero` | `Vec2::ZERO` |
| `CCSizeZero` | `Size::ZERO` |

### 3.4 回调机制变更（核心架构变化）

| 2.2.6 | 3.0-oh |
|-------|--------|
| `SEL_CallFunc` / `callfunc_selector()` | `CC_CALLBACK_0/1/2/3()` + `std::function` |
| `SEL_MenuHandler` | `ccMenuCallback` |
| `SEL_SCHEDULE` | `CC_SCHEDULE_SELECTOR()` 或 lambda |

### 3.5 触摸事件系统重构

| 2.2.6 | 3.0-oh |
|-------|--------|
| `CCTouchDispatcher` + `registerWithTouchDispatcher()` | `EventDispatcher` + `EventListenerTouchOneByOne` |
| `ccTouchesBegan/Moved/Ended` | `onTouchBegan/Moved/Ended` |
| `CCTouch` | `Touch` |

### 3.6 渲染架构变更

| 2.2.6 | 3.0-oh |
|-------|--------|
| 固定管线，直接调用 `glXXX()` | `Renderer` 统一管理渲染命令 |
| `CCGLProgram` | `GLProgram` → v4 后 `Program` |
| 手动 `draw()` 覆盖 | `CustomCommand` 或 `RenderCommand` |
| 混合模式在 Node 上 | 通过 `BlendFunc` 和 `PipelineDescriptor` |

### 3.7 内存管理变更

| 2.2.6 | 3.0-oh |
|-------|--------|
| `CCObject` + `retain()/release()/autorelease()` | `Ref` + 相同引用计数机制 |
| `CC_SAFE_RELEASE` 等宏 | 可使用 `std::unique_ptr` / `std::shared_ptr` |
| `create()` 返回 autorelease 对象 | 行为一致，但可用 `std::unique_ptr` 包装 |

### 3.8 标签系统变更

| 2.2.6 | 3.0-oh |
|-------|--------|
| `CCLabelTTF` | `Label`（统一标签系统） |
| `CCLabelBMFont` | `Label::createWithBMFont()` |
| `CCLabelAtlas` | `Label::createWithCharMap()` |

### 3.9 音频系统变更

| 2.2.6 | 3.0-oh |
|-------|--------|
| `CocosDenshion::SimpleAudioEngine` | `AudioEngine`（实验性 → v4 正式） |
| MCI/FMOD 后端 | 统一 `AudioEngine` 接口 |

### 3.10 构建系统变更

| 2.2.6 | 3.0-oh |
|-------|--------|
| 各平台独立工程（vcxproj, Xcode, Android.mk） | CMake 统一构建 |
| VS2013 v120 工具集 | 需要 VS2015+ 或 CMake + Ninja |
| Android NDK r8-r10 | 需要 NDK r16+ |

### 3.11 OpenHarmony 新增特性

3.0-oh 在 3.17.2 基础上新增了 OpenHarmony 平台支持：

| 特性 | 说明 |
|------|------|
| 平台宏 | `#ifdef __OHOS__` / `CC_TARGET_OS_OHOS` |
| NAPI 桥接层 | `external/ohos-specific/` 包含 OHOS 平台适配 |
| ArkUI 集成 | 通过 XComponent 嵌入游戏渲染 |
| EGL/OpenGL ES 绑定 | 对接 OHOS NativeWindow |
| JSVM 支持 | Lua 脚本通过 JSVM 在 OHOS 上运行 |

### 3.12 不兼容点汇总

| 类别 | 2.2.6 行为 | 3.0-oh 变更 | 影响等级 |
|------|------------|-------------|----------|
| CC 前缀 | 全部类带 CC 前缀 | 全部移除 CC 前缀 | **严重** |
| 单例 | `sharedXXX()` | `getInstance()` | **严重** |
| 数据结构 | CCPoint/CCSize/CCRect | Vec2/Size/Rect | **严重** |
| 回调 | SEL 选择器 | std::function + CC_CALLBACK | **严重** |
| 触摸 | CCTouchDispatcher | EventDispatcher | **严重** |
| 容器 | CCArray/CCDictionary/CCSet | Vector/Map/Set | **严重** |
| 渲染 | 直接 gl 调用 | RenderCommand 队列 | **严重** |
| 标签 | CCLabelTTF 等 | 统一 Label | **高** |
| 音频 | SimpleAudioEngine | AudioEngine | **高** |
| 构建 | 平台独立工程 | CMake 统一 | **高** |
| 头文件 | `cocos2d.h` 主头 | `cocos2d.h` 仍存在但内容变化 | **中** |
| 命名空间 | `cocos2d` | `cocos2d`（一致，但细粒度子命名空间） | **中** |
| CCString | 存在 | 移除（用 std::string） | **中** |
| NotificationCenter | `CCNotificationCenter` | `NotificationCenter` | **中** |

---

## 4. 阶段一：前期准备

> **时间预估**：2-3 周
>
> **责任人**：技术负责人 + 架构师
>
> **交付物**：备份仓库、环境就绪、团队培训材料

### 4.1 任务分解

#### 4.1.1 代码备份与分支策略

| 任务 | 说明 | 责任人 |
|------|------|--------|
| 创建升级分支 | `git checkout -b feature/cocos2d-x-3.0-oh-upgrade` | 技术负责人 |
| 全量备份 | 将当前 `master`/`main` 分支打 tag：`pre-upgrade-2.2.6` | 技术负责人 |
| 设置保护分支 | 确保 `master` 不被误推 | 技术负责人 |
| LFS 确认 | 确认 Git LFS 已禁用，所有大文件已正常提交 | 技术负责人 |

#### 4.1.2 环境准备

| 任务 | 说明 | 责任人 |
|------|------|--------|
| 安装 DevEco Studio | 最新 release 版本，用于 OHOS 构建 | 客户端开发 |
| 安装 CMake 3.6.3+（`D:\Program Files\CMake\bin\cmake.exe`） | 3.0-oh 使用 CMake 构建，已安装 CMake 3.6.3 | 客户端开发 |
| 安装 NDK r16b+ | 确认 Android 构建环境 | 客户端开发 |
| 确认 VS2013 (v120) | 3.0-oh 通过 CMake 生成 VS2013 工程，无需升级 VS 版本 | 客户端开发 |
| Python 2.7/3.x | 确认构建脚本兼容性 | 客户端开发 |

#### 4.1.3 基线建立

| 任务 | 说明 | 责任人 |
|------|------|--------|
| 编译基线 | 记录当前 2.2.6 所有平台的编译时间和产物大小 | 客户端开发 |
| 性能基线 | 记录关键场景的 FPS、内存、启动时间 | QA |
| 功能基线 | 录制所有核心功能操作视频/截图 | QA |
| 自动化测试 | 建立现有可通过的测试用例清单 | QA |

#### 4.1.4 团队培训

| 任务 | 说明 | 责任人 |
|------|------|--------|
| 3.0-oh 架构培训 | 讲解 3.0-oh 目录结构、核心变更 | 架构师 |
| API 迁移培训 | 讲解 2.2.6 → 3.0-oh API 对照表 | 架构师 |
| CMake 培训 | 讲解 CMake 构建系统基础 | 客户端 TL |
| OHOS 平台培训 | 讲解 OpenHarmony 平台架构、NAPI 机制 | 架构师 |

#### 4.1.5 回滚策略

| 场景 | 回滚方式 | 恢复时间 |
|------|----------|----------|
| 编译失败无法短期修复 | `git checkout pre-upgrade-2.2.6` tag | 即时 |
| 功能严重退化 | 回退到升级分支上一个稳定 commit | 即时 |
| 性能严重下降 | 保留升级分支，在 2.2.6 分支继续维护 | 1 天 |
| OHOS 平台不稳定 | 仅回退 OHOS 平台代码，保留 Win32/Android/iOS 升级 | 1 天 |

---

## 5. 阶段二：技术调研与方案设计

> **时间预估**：3-4 周
>
> **责任人**：架构师 + 客户端 TL
>
> **交付物**：技术方案文档、API 迁移对照表、兼容层设计文档

### 5.1 任务分解

#### 5.1.1 深入分析 3.0-oh 源码

| 任务 | 说明 | 责任人 |
|------|------|--------|
| 目录结构对比 | 逐模块对比 2.2.6 `cocos2dx/` 和 3.0-oh `cocos/` 的模块映射 | 架构师 |
| 渲染管线分析 | 深入分析 3.0-oh 的 Renderer、Command、Pipeline 机制 | 渲染专家 |
| 音频系统分析 | 分析 AudioEngine 接口与 MT3 现有音频功能的兼容性 | 音频开发 |
| OHOS 适配层分析 | 分析 `external/ohos-specific/` 和 OHOS 平台文件 | 平台开发 |
| 构建系统分析 | 分析 CMake 模块和平台构建配置 | 构建工程师 |

#### 5.1.2 不兼容点详细清单

| 任务 | 说明 | 责任人 |
|------|------|--------|
| API 对照表 | 建立完整的 2.2.6 → 3.0-oh API 迁移对照表 | 架构师 |
| 废弃 API 清单 | 列出在 3.0-oh 中已完全移除的 API | 架构师 |
| 行为变更清单 | 列出 API 签名不变但行为已变更的情况 | 架构师 |
| 渲染行为差异 | 列出渲染结果可能不同的场景 | 渲染专家 |

#### 5.1.3 MT3 补丁移植评估

| 任务 | 说明 | 责任人 |
|------|------|--------|
| Shader 补丁评估 | 评估 3.0-oh 的 Program/ProgramState 是否满足需求 | 渲染专家 |
| 纹理压缩补丁评估 | 评估 3.0-oh 的 Texture2D 是否支持 DDS/ETC/PVRTC | 渲染专家 |
| Lua 桥接补丁评估 | 评估 3.0-oh 的 LuaEngine 是否兼容 | Lua 开发 |
| Spine JSON 补丁评估 | 评估 3.0-oh 内置 Spine 版本 | 动画开发 |
| 音频 Shim 评估 | 评估 AudioEngine 是否满足 MT3 音效需求 | 音频开发 |
| 视频播放器评估 | 评估 3.0-oh 的 VideoPlayer 支持 | 客户端开发 |

#### 5.1.4 兼容层设计方案

| 任务 | 说明 | 责任人 |
|------|------|--------|
| 类型别名层 | 为 `CCSprite` → `Sprite` 等提供过渡别名或宏 | 架构师 |
| Nuclear 封装层改造 | 重新设计 `nucocos2d_wraper.h/.cpp` 的基类继承 | 架构师 |
| CEGUI 适配方案 | 设计 CEGUI Cocos2D Renderer 的 3.0-oh 适配方案 | 渲染专家 |
| tolua++ 适配方案 | 设计 tolua++ 绑定生成对 3.0-oh 类型的适配 | Lua 开发 |
| 平台适配层设计 | 设计 OHOS 平台的 CCApplication 和 GLView 实现 | 平台开发 |

#### 5.1.5 构建系统方案设计

| 任务 | 说明 | 责任人 |
|------|------|--------|
| CMake 顶层设计 | 设计 CMakeLists.txt 层级结构 | 构建工程师 |
| Win32 构建方案 | 决定保留 vcxproj 还是迁移到 CMake + MSBuild | 构建工程师 |
| Android 构建方案 | 从 Android.mk 迁移到 CMake + Gradle 的方案 | 构建工程师 |
| iOS 构建方案 | Xcode 工程迁移方案 | 构建工程师 |
| OHOS 构建方案 | DevEco Studio + CMake 的 OHOS 构建方案 | 平台开发 |

---

## 6. 阶段三：基础框架层迁移

> **时间预估**：6-8 周
>
> **责任人**：客户端 TL + 各模块开发
>
> **交付物**：引擎层编译通过、Nuclear 封装层适配完成、基础 Demo 可运行

### 6.1 模块迁移顺序

按依赖关系从底层到上层：

```
Cocos2d-x 3.0-oh 引擎编译
  → Nuclear 引擎封装层适配
    → CEGUI Cocos2D Renderer 适配
      → 第三方依赖适配 (tolua++, Spine, FMOD)
        → 平台壳层适配 (Win32, Android, iOS, OHOS)
          → FireClient 基础框架 (Application, Framework)
            → Lua 绑定与脚本系统
              → 业务模块逐个迁移
```

### 6.2 任务分解

#### 6.2.1 Cocos2d-x 3.0-oh 引擎编译

| 任务 | 说明 | 优先级 | 责任人 |
|------|------|--------|--------|
| 验证 3.0-oh 独立编译 | 使用 3.0-oh 自带 CMake 编译所有库 | P0 | 构建工程师 |
| Win32 库编译 | 生成 `cocos2d.lib`, `libGUI.lib`, `libExtensions.lib` 等 | P0 | 构建工程师 |
| Android 库编译 | 生成 `libcocos2d.so` 等 Android 库 | P0 | 构建工程师 |
| iOS 库编译 | 生成 iOS 静态库 | P0 | 构建工程师 |
| OHOS 库编译 | 生成 OHOS 平台的 `.so` 库 | P1 | 平台开发 |
| 解决编译警告 | 修复 3.0-oh 自带的编译警告 | P1 | 构建工程师 |

#### 6.2.2 Nuclear 引擎封装层适配（核心任务）

这是整个升级的关键环节。Nuclear 引擎的核心类直接继承 Cocos2d 基类：

| 文件 | 2.2.6 基类 | 3.0-oh 基类 | 关键变更 |
|------|------------|-------------|----------|
| `nucocos2d_wraper.h` | 整体适配 | - | 头文件引用、命名空间、类型 |
| `EngineApp` | `CCApplication` | `Application` | 类名、方法签名 |
| `EngineLayer` | `CCLayer` | `Layer` | 触摸事件系统重写 |
| `EngineTicker` | `CCAction` | `Action` | 动作系统接口 |
| 触摸处理 | `ccTouchesBegan` | `onTouchBegan` | 事件监听器模式 |
| 坐标类型 | `CCPoint` | `Vec2` | 所有坐标计算 |

具体任务：

| 任务 | 说明 | 优先级 | 责任人 |
|------|------|--------|--------|
| `nucocos2d_wraper.h` 适配 | 修改头文件引用、基类名、类型声明 | P0 | 引擎开发 |
| `nucocos2d_wraper.cpp` 适配 | 修改所有实现代码 | P0 | 引擎开发 |
| `EngineApp` 适配 | `CCApplication` → `Application`，生命周期方法签名 | P0 | 引擎开发 |
| `EngineLayer` 适配 | `CCLayer` → `Layer`，触摸事件重写 | P0 | 引擎开发 |
| `EngineTicker` 适配 | `CCAction` → `Action`，`isDone()`/`step()` 接口 | P0 | 引擎开发 |
| 坐标系统适配 | `CCPoint` → `Vec2`，`CCSize` → `Size` | P0 | 引擎开发 |
| 单例调用适配 | 所有 `sharedXXX()` → `getInstance()` | P0 | 引擎开发 |
| 容器类型适配 | `CCArray` → `Vector`，`CCSet` → `Set` | P1 | 引擎开发 |
| 回调机制适配 | `SEL_XXX` → `CC_CALLBACK_XXX` | P1 | 引擎开发 |
| Nuclear 渲染适配 | 3.0-oh 的 Renderer 架构适配 | P0 | 渲染专家 |

#### 6.2.3 CEGUI Cocos2D Renderer 适配

| 任务 | 说明 | 优先级 | 责任人 |
|------|------|--------|--------|
| 纹理接口适配 | `CEGUICocos2DTexture` 适配 3.0-oh 的 `Texture2D` | P0 | 渲染专家 |
| 图像编解码适配 | `CEGUICocos2DImageCodec` 适配 3.0-oh `Image` | P0 | 渲染专家 |
| 渲染器适配 | CEGUI 的 Cocos2D Renderer 适配 3.0-oh 渲染管线 | P0 | 渲染专家 |
| CEGUI 宏冲突修复 | `ceguimin/ceguimax` 与 Win32 `min/max` 宏冲突 | P1 | 渲染专家 |

#### 6.2.4 第三方依赖适配

| 依赖 | 任务 | 优先级 | 责任人 |
|------|------|--------|--------|
| tolua++ | 修改 `.pkg` 绑定定义文件中的 Cocos2d 类型引用 | P0 | Lua 开发 |
| tolua++ | 重新生成 `LuaEngine.cpp`, `LuaFireClient.cpp` | P0 | Lua 开发 |
| tolua++ | 适配 `tolua++.h` 中的 `std::wstring` 助手 | P1 | Lua 开发 |
| Spine | 确认 3.0-oh 内置 Spine 版本与项目兼容性 | P1 | 动画开发 |
| Spine | 如版本不兼容，评估升级 Spine 或回退使用旧版 | P2 | 动画开发 |
| FMOD | 评估 FMOD 与 3.0-oh AudioEngine 的共存方案 | P1 | 音频开发 |
| LJFM | 适配 `FileUtils` 接口变更 | P1 | 客户端开发 |
| libpng | 确认 3.0-oh 内置 libpng 版本兼容性 | P2 | 构建工程师 |
| zlib | 确认 3.0-oh 内置 zlib 版本兼容性 | P2 | 构建工程师 |

#### 6.2.5 平台壳层适配

**Win32 平台：**

| 任务 | 说明 | 优先级 | 责任人 |
|------|------|--------|--------|
| MT3 Win32 工程改造 | 从 2.2.6 引用切换到 3.0-oh 引用 | P0 | 客户端开发 |
| 入口点适配 | `WinMain` → 3.0-oh 的 Application 入口 | P0 | 客户端开发 |
| 窗口创建适配 | `CCEGLView` → `GLView` | P0 | 客户端开发 |
| 平台宏适配 | `CC_TARGET_PLATFORM` → 新的平台宏 | P1 | 客户端开发 |

**Android 平台：**

| 任务 | 说明 | 优先级 | 责任人 |
|------|------|--------|--------|
| Android.mk → CMake | 迁移 Android 构建到 CMake | P0 | 构建工程师 |
| JNI 适配 | 适配 3.0-oh 的 JNI 入口 | P0 | 平台开发 |
| Activity 适配 | `Cocos2dxActivity` → 3.0-oh 的 Activity | P0 | 平台开发 |
| 渠道适配 | Locojoy、Yijie、Joysdk 等渠道构建 | P1 | 平台开发 |

**iOS 平台：**

| 任务 | 说明 | 优先级 | 责任人 |
|------|------|--------|--------|
| Xcode 工程更新 | 从 2.2.6 引用切换到 3.0-oh | P0 | iOS 开发 |
| OpenGL ES 适配 | 确认 3.0-oh 的 GLES 后端 | P0 | iOS 开发 |
| Metal 支持评估 | 3.0-oh 是否支持 Metal 后端 | P2 | iOS 开发 |

**OpenHarmony 平台（新增）：**

| 任务 | 说明 | 优先级 | 责任人 |
|------|------|--------|--------|
| OHOS 工程创建 | 使用 DevEco Studio 创建 OHOS 工程 | P1 | 平台开发 |
| NAPI 桥接 | C++ 与 ArkTS 的 NAPI 桥接层 | P1 | 平台开发 |
| XComponent 集成 | 将游戏渲染嵌入 XComponent | P1 | 平台开发 |
| 生命周期适配 | OHOS Ability 生命周期对接 | P1 | 平台开发 |
| 输入事件适配 | OHOS 触摸事件 → Cocos2d 事件 | P1 | 平台开发 |
| 声音适配 | OHOS 音频系统对接 | P2 | 音频开发 |

#### 6.2.6 FireClient 基础框架适配

| 任务 | 说明 | 优先级 | 责任人 |
|------|------|--------|--------|
| `Application/` 目录编译 | 修复 FireClient 中所有 Cocos2d API 调用 | P0 | 客户端开发 |
| `Framework/` 目录编译 | 修复 Framework 层编译错误 | P0 | 客户端开发 |
| GameApplication 适配 | 启动流程适配 | P0 | 客户端开发 |
| Manager 系列适配 | 各 Manager 类中的 Cocos2d API 适配 | P0 | 客户端开发 |
| 网络层适配 | `HttpClient` 接口适配 | P1 | 客户端开发 |

---

## 7. 阶段四：业务逻辑层迁移

> **时间预估**：8-12 周
>
> **责任人**：各业务模块开发
>
> **交付物**：所有业务模块编译通过、功能可用

### 7.1 迁移策略

采用**渐进式迁移**策略，按模块逐个迁移，每个模块迁移后立即进行功能验证：

1. **优先级排序**：先迁移核心路径（登录、主界面、战斗），再迁移周边功能
2. **增量编译**：每迁移一个模块，立即编译验证
3. **功能回归**：每迁移一个模块，立即在 Win32 上做快速功能回归
4. **并行推进**：独立模块可并行迁移

### 7.2 业务模块迁移清单

#### 7.2.1 核心路径（P0）

| 模块 | 文件范围 | 关键适配点 | 责任人 |
|------|----------|------------|--------|
| 启动与登录 | `Application/` 启动流程 | CCApplication, CCDirector 适配 | 客户端开发 |
| 主界面 UI | `res/ui/` 相关 C++/Lua | CEGUI + Cocos2d 渲染 | UI 开发 |
| 场景管理 | Scene 相关代码 | CCScene → Scene, 生命周期 | 客户端开发 |
| 角色系统 | SceneObj, 角色渲染 | CCSprite → Sprite, 动画 | 游戏逻辑 |
| 战斗系统 | Battle 模块 | 渲染、粒子、动作 | 战斗开发 |
| 地图系统 | TileMap, 地图渲染 | CCTMXTiledMap 适配 | 地图开发 |

#### 7.2.2 功能模块（P1）

| 模块 | 关键适配点 | 责任人 |
|------|------------|--------|
| 背包与物品 | UI 渲染、图标加载 | UI 开发 |
| 任务系统 | UI 交互、事件 | 游戏逻辑 |
| 聊天系统 | UI 文本、输入 | UI 开发 |
| 好友系统 | UI 列表、网络 | 游戏逻辑 |
| 商城系统 | UI 渲染、支付流程 | 游戏逻辑 |
| 技能系统 | 特效、动作 | 战斗开发 |
| 副本系统 | 场景切换、战斗 | 战斗开发 |
| 活动系统 | UI、计时器 | 游戏逻辑 |

#### 7.2.3 周边功能（P2）

| 模块 | 关键适配点 | 责任人 |
|------|------------|--------|
| 设置界面 | UI 控件 | UI 开发 |
| 公告系统 | 文本渲染 | 客户端开发 |
| 引导系统 | 触摸事件、遮罩 | 客户端开发 |
| 邮件系统 | UI 列表 | 客户端开发 |
| 排行榜 | UI 渲染 | 客户端开发 |

### 7.3 常见 API 迁移模式

以下是迁移过程中会反复出现的高频模式，供开发人员参考：

```cpp
// === 单例模式 ===
// 2.2.6
CCDirector::sharedDirector()->getWinSize();
CCSpriteFrameCache::sharedSpriteFrameCache()->addSpriteFramesWithFile("xxx.plist");
// 3.0-oh
Director::getInstance()->getWinSize();
SpriteFrameCache::getInstance()->addSpriteFramesWithFile("xxx.plist");

// === 类型创建 ===
// 2.2.6
CCSprite* sp = CCSprite::create("icon.png");
CCPoint pos = ccp(100, 200);
CCSize size = CCSizeMake(50, 50);
// 3.0-oh
Sprite* sp = Sprite::create("icon.png");
Vec2 pos(100, 200);
Size size(50, 50);

// === 容器操作 ===
// 2.2.6
CCArray* arr = CCArray::create();
arr->addObject(node);
CCObject* obj = nullptr;
CCARRAY_FOREACH(arr, obj) { ... }
// 3.0-oh
Vector<Node*> vec;
vec.pushBack(node);
for (Node* node : vec) { ... }

// === 回调机制 ===
// 2.2.6
CCCallFunc::create(this, callfunc_selector(MyClass::myCallback));
void MyClass::myCallback() { ... }
// 3.0-oh
CallFunc::create(CC_CALLBACK_0(MyClass::myCallback, this));
void MyClass::myCallback() { ... }
// 或使用 lambda
CallFunc::create([this]() { ... });

// === 触摸事件 ===
// 2.2.6
void MyLayer::registerWithTouchDispatcher() {
    CCDirector::sharedDirector()->getTouchDispatcher()->addTargetedDelegate(this, 0, true);
}
bool MyLayer::ccTouchBegan(CCTouch* touch, CCEvent* event) { ... }
// 3.0-oh
bool MyLayer::init() {
    auto listener = EventListenerTouchOneByOne::create();
    listener->onTouchBegan = CC_CALLBACK_2(MyLayer::onTouchBegan, this);
    _eventDispatcher->addEventListenerWithSceneGraphPriority(listener, this);
    return true;
}
bool MyLayer::onTouchBegan(Touch* touch, Event* event) { ... }

// === 调度器 ===
// 2.2.6
schedule(schedule_selector(MyClass::update));
// 3.0-oh
schedule(CC_SCHEDULE_SELECTOR(MyClass::update));
// 或
schedule([this](float dt) { update(dt); }, "update_key");
```

---

## 8. 阶段五：测试验证

> **时间预估**：4-6 周（与阶段四部分重叠）
>
> **责任人**：QA + 各模块开发
>
> **交付物**：测试报告、Bug 清单、性能对比报告

### 8.1 测试策略

采用**分层测试**策略，从底层到上层逐层验证：

```
单元测试 → 模块集成测试 → 功能回归测试 → 性能测试 → 兼容性测试 → 验收测试
```

### 8.2 任务分解

#### 8.2.1 单元测试

| 任务 | 测试范围 | 通过标准 | 责任人 |
|------|----------|----------|--------|
| Nuclear 封装层测试 | `EngineApp`, `EngineLayer`, `EngineTicker` | 所有单元测试通过 | 引擎开发 |
| CEGUI 适配测试 | 纹理加载、渲染、图像编解码 | 所有 UI 控件正常渲染 | 渲染专家 |
| tolua++ 绑定测试 | Lua 调用 C++ 接口 | 所有 Lua API 调用正常 | Lua 开发 |
| 容器类型测试 | Vector, Map, Set 操作 | 增删改查正确 | 客户端开发 |
| 回调机制测试 | CC_CALLBACK, lambda 回调 | 回调正确触发 | 客户端开发 |
| 事件系统测试 | 触摸、键盘、自定义事件 | 事件分发正确 | 客户端开发 |

#### 8.2.2 集成测试

| 任务 | 测试范围 | 通过标准 | 责任人 |
|------|----------|----------|--------|
| 启动流程测试 | 从 App 启动到进入登录界面 | 启动流程完整，无崩溃 | QA |
| 登录流程测试 | 登录、注册、服务器选择 | 登录成功 | QA |
| 场景切换测试 | 各场景间切换 | 切换流畅，无内存泄漏 | QA |
| 资源加载测试 | 纹理、音频、字体、动画 | 加载成功，格式正确 | QA |
| 网络通信测试 | HTTP、Socket | 通信正常 | QA |
| Lua 脚本测试 | 所有 Lua 脚本执行 | 脚本正常执行 | QA |

#### 8.2.3 功能回归测试

| 任务 | 测试范围 | 通过标准 | 责任人 |
|------|----------|----------|--------|
| 核心玩法回归 | 战斗、副本、任务 | 与 2.2.6 行为一致 | QA |
| UI 回归 | 所有界面、弹窗、动画 | 显示正确，交互正常 | QA |
| 音效回归 | 背景音乐、音效 | 播放正常，无杂音 | QA |
| 动画回归 | Spine、帧动画、粒子 | 动画效果一致 | QA |
| 特效回归 | 技能特效、场景特效 | 特效效果一致 | QA |
| 输入回归 | 触摸、键盘、手势 | 输入响应正确 | QA |

#### 8.2.4 性能测试

| 任务 | 测试指标 | 通过标准 | 责任人 |
|------|----------|----------|--------|
| FPS 对比 | 同场景 2.2.6 vs 3.0-oh | 不低于 2.2.6 的 95% | QA |
| 内存对比 | 同场景内存占用 | 不高于 2.2.6 的 110% | QA |
| 启动时间对比 | 冷启动/热启动 | 不慢于 2.2.6 的 120% | QA |
| 资源加载时间 | 纹理、场景加载 | 不慢于 2.2.6 的 120% | QA |
| 渲染批次 | DrawCall 数量 | 不高于 2.2.6 的 110% | QA |
| 包体大小 | APK/IPA 大小 | 不高于 2.2.6 的 120% | QA |

#### 8.2.5 平台兼容性测试

| 平台 | 测试范围 | 通过标准 | 责任人 |
|------|----------|----------|--------|
| Win32 | 全功能回归 | 所有功能正常 | QA |
| Android | 全功能回归 | 所有功能正常 | QA |
| Android 多机型 | 低/中/高端机型 | 各机型无崩溃 | QA |
| iOS | 全功能回归 | 所有功能正常 | QA |
| OHOS | 核心功能 | 启动、登录、基础玩法 | QA |

#### 8.2.6 稳定性测试

| 任务 | 测试方式 | 通过标准 | 责任人 |
|------|----------|----------|--------|
| 长时间运行 | 连续运行 24 小时 | 无崩溃、无内存泄漏 | QA |
| 压力测试 | 高频操作、极限场景 | 无崩溃 | QA |
| 弱网测试 | 网络延迟、断网 | 功能正常降级 | QA |
| 前后台切换 | 反复切换 100 次 | 无崩溃 | QA |

---

## 9. 阶段六：优化与上线

> **时间预估**：4-6 周
>
> **责任人**：全团队
>
> **交付物**：优化报告、上线方案、运维手册

### 9.1 任务分解

#### 9.1.1 性能优化

| 任务 | 优化方向 | 目标 | 责任人 |
|------|----------|------|--------|
| 渲染性能优化 | 利用 3.0-oh 的批处理、RenderCommand 排序 | FPS 达到或超过 2.2.6 | 渲染专家 |
| 内存优化 | 利用智能指针、TextureCache 优化 | 内存降低 10-20% | 客户端开发 |
| 启动优化 | 异步加载、资源预加载 | 启动时间接近 2.2.6 | 客户端开发 |
| 包体优化 | 移除 2.2.6 遗留库、资源压缩 | 包体控制在合理范围 | 构建工程师 |
| OHOS 专属优化 | 方舟编译器、JSVM 优化 | OHOS 平台性能达标 | 平台开发 |

#### 9.1.2 MT3 补丁移植

将 2.2.6 上的 MT3 专属补丁逐个移植到 3.0-oh：

| 补丁 | 移植方式 | 责任人 |
|------|----------|--------|
| Shader 兼容 | 如在 3.0-oh 中不可用，重新实现 | 渲染专家 |
| 纹理压缩兼容 | 如在 3.0-oh 中不可用，重新实现 | 渲染专家 |
| Lua 脚本桥接 | 适配 3.0-oh LuaEngine | Lua 开发 |
| Spine JSON 兼容 | 使用 3.0-oh 内置 Spine 或重新实现 | 动画开发 |
| 音频 Shim | 适配 AudioEngine 或保留 FMOD | 音频开发 |
| 视频播放器 | 使用 3.0-oh VideoPlayer 或重新实现 | 客户端开发 |

#### 9.1.3 最终版本验证

| 任务 | 说明 | 责任人 |
|------|------|--------|
| 全平台全功能回归 | Win32 + Android + iOS + OHOS 完整回归 | QA |
| 性能基准对比 | 与 2.2.6 基线对比 | QA |
| 安全扫描 | 代码安全审计 | 安全工程师 |
| 兼容性矩阵 | 多机型、多系统版本 | QA |
| 灰度发布准备 | 灰度发布方案 | 运维 |

#### 9.1.4 上线部署

| 任务 | 说明 | 责任人 |
|------|------|--------|
| 资源打包适配 | 更新 LJFilePack 打包流程（如有需要） | 工具开发 |
| 热更新适配 | 确认热更新机制在 3.0-oh 上正常 | 客户端开发 |
| 服务端兼容 | 确认协议兼容性 | 服务端开发 |
| 灰度发布 | 先小范围发布，监控数据 | 运维 |
| 全量发布 | 确认灰度无问题后全量 | 运维 |
| 监控告警 | 设置崩溃率、性能监控告警 | 运维 |
| 回滚预案 | 准备快速回滚到 2.2.6 的流程 | 运维 |

---

## 10. 风险管理

### 10.1 风险矩阵

| 风险 | 概率 | 影响 | 风险等级 | 应对措施 |
|------|------|------|----------|----------|
| 渲染结果不一致 | 高 | 严重 | **高** | 建立渲染对比工具，逐场景对比截图 |
| CEGUI 适配失败 | 中 | 严重 | **高** | 提前评估 CEGUI 源码，必要时升级 CEGUI 版本 |
| 性能下降 | 中 | 高 | **高** | 每阶段性能测试，早期发现瓶颈 |
| tolua++ 绑定不兼容 | 中 | 高 | **高** | 提前验证生成链，准备手动修复方案 |
| MT3 补丁移植遗漏 | 高 | 中 | **中** | 建立补丁清单 checklist，逐项验证 |
| 第三方库冲突 | 中 | 中 | **中** | 提前梳理版本依赖，准备符号隔离方案 |
| 团队成员学习曲线 | 高 | 中 | **中** | 提前培训，建立知识库 |
| OHOS 平台不稳定 | 高 | 中 | **中** | OHOS 作为可选目标，不影响主平台 |
| 构建系统迁移耗时过长 | 中 | 中 | **中** | 可先保留 vcxproj 过渡，逐步迁移 CMake |
| 回归测试覆盖率不足 | 中 | 高 | **高** | 建立自动化测试，核心路径 100% 覆盖 |

### 10.2 风险应对措施

#### 10.2.1 渲染一致性保障

- 建立渲染对比工具：同场景、同输入在 2.2.6 和 3.0-oh 上截图对比
- 关键场景：战斗特效、UI 动画、地图渲染
- 差异容忍度：像素级对比，超过 5% 像素差异需人工审核

#### 10.2.2 兼容层策略

- 在第一阶段建立过渡兼容层，避免同时修改所有业务代码
- 兼容层在最终版本中可逐步移除
- 兼容层示例：`using CCSprite = cocos2d::Sprite;`

#### 10.2.3 分阶段交付

- 先交付 Win32 平台，再扩展 Android/iOS
- 先交付核心功能，再扩展周边功能
- 每个阶段有明确的"完成"定义和验收标准

---

## 11. 附录

### 11.1 关键文件清单

#### 必须修改的文件（核心）

| 文件 | 修改类型 | 说明 |
|------|----------|------|
| `engine/engine/nucocos2d_wraper.h` | 重写 | Nuclear 引擎 Cocos2d 封装层头文件 |
| `engine/engine/nucocos2d_wraper.cpp` | 重写 | Nuclear 引擎 Cocos2d 封装层实现 |
| `engine/engine/nuengine.h` | 修改 | 引擎主接口 |
| `engine/engine/nurenderable.h` | 修改 | 可渲染对象 |
| `engine/engine/nucocos2d_type.h` | 修改 | Cocos2d 类型定义 |
| `engine/engine.win32.vcxproj` | 修改 | Win32 工程配置 |
| `engine/Android.mk` | 修改 | Android 构建 |
| `client/FireClient/Application/` | 大量修改 | 所有包含 Cocos2d API 的文件 |
| `client/MT3Win32App/mt3.vcxproj` | 修改 | 主工程配置 |
| `dependencies/cegui/.../CEGUICocos2DTexture.cpp` | 修改 | CEGUI 纹理适配 |
| `dependencies/cegui/.../CEGUICocos2DImageCodec.cpp` | 修改 | CEGUI 图像编解码适配 |

#### 需要重新生成的文件

| 文件 | 生成工具 | 说明 |
|------|----------|------|
| `client/FireClient/Application/Framework/LuaEngine.cpp` | tolua++ | Lua 绑定 |
| `client/FireClient/Application/Framework/LuaFireClient.cpp` | tolua++ | Lua 绑定 |
| `client/FireClient/Application/ProtoDef/**` | genprotocol | 协议定义 |
| `client/resource/res/script/protodef/**` | genprotocol | Lua 协议 |

### 11.2 参考资源

| 资源 | 链接 | 说明 |
|------|------|------|
| Cocos2d-x 3.0 Release Notes | [官方文档](https://fusijie.github.io/Cocos2dx-Release-Note/cocos2d-x_v3.0_release_notes_en.html) | 3.0 核心变更说明 |
| cocos2d-x-3.17.2-oh | [GitHub](https://github.com/cocos2d/cocos2d-x/tree/cocos2d-x-3.17.2-oh) | 官方 OHOS 适配分支 |
| Cocos 2d-x 适配 HarmonyOS NEXT | [论坛](https://forum.cocos.org/t/topic/168748) | 社区适配经验分享 |
| 华为游戏适配指南 | [华为开发者](https://developer.huawei.com/consumer/cn/doc/games-guides/games-adapt-2dx-0000002287068061) | 官方适配文档 |
| 2.x → 3.x 迁移笔记 | [CSDN](https://blog.csdn.net/qq_30392565/article/details/51920291) | 社区迁移经验 |
| V2.2 → V3.2 迁移 | [GitHub](https://github.com/TankTheFrank/FenneX/blob/master/Cocos2d-x%20V2.2%20to%20V3.2%20migration.md) | 迁移 checklist |

### 11.3 时间线总览

```
阶段一：前期准备          ████░░░░░░░░░░░░░░░░░░░░░░░░░░  2-3 周
阶段二：技术调研与方案设计  ░░░░████████░░░░░░░░░░░░░░░░░░  3-4 周
阶段三：基础框架层迁移      ░░░░░░░░░░░░████████████████░░  6-8 周
阶段四：业务逻辑层迁移      ░░░░░░░░░░░░░░░░░░░░░░░░████████  8-12 周
阶段五：测试验证            ░░░░░░░░░░░░░░░░░░░░████████░░  4-6 周（与阶段四重叠）
阶段六：优化与上线          ░░░░░░░░░░░░░░░░░░░░░░░░░░████  4-6 周

总计预估：20-30 周（约 5-7.5 个月）
```

> **注意**：以上时间线基于单人专职估算，实际进度取决于团队规模、并行程度和不可预见的技术障碍。建议以 2-3 人核心团队 + 按需支援的方式推进。

### 11.4 术语对照

| 术语 | 全称 | 说明 |
|------|------|------|
| OHOS | OpenHarmony OS | 开源鸿蒙操作系统 |
| OH | OpenHarmony | 开源鸿蒙缩写 |
| NAPI | Native API | 鸿蒙原生 C++ 接口 |
| ArkUI | Ark UI | 鸿蒙声明式 UI 框架 |
| JSVM | JavaScript Virtual Machine | 鸿蒙 JS 虚拟机 |
| DevEco Studio | - | 鸿蒙官方 IDE |
| HDC | HarmonyOS Device Connector | 鸿蒙设备连接工具 |
| AGC | AppGallery Connect | 华为应用市场连接服务 |

---

> **文档维护**：本文档随项目进展持续更新，最新版本以仓库中的实际文件为准。
>
> **审批流程**：技术负责人审核 → 项目经理确认 → 技术委员会批准 → 启动执行