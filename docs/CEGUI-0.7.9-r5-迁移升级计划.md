# CEGUI 0.7.1 → 0.7.9-r5 迁移升级计划

> **版本**：1.0.0
> **制定日期**：2026-07-25
> **适用范围**：MT3 全平台（Win32 / Android / iOS）UI 框架迁移
> **源版本**：CEGUI 0.7.1（`dependencies/cegui/`，含大量 MT3 定制扩展）
> **目标版本**：CEGUI 0.7.9-r5（`tools/CEGUI-0.7.9-r5/`，上游标准发行版）

---

## 目录

1. [现状分析与差异评估](#1-现状分析与差异评估)
2. [迁移前准备工作](#2-迁移前准备工作)
3. [迁移实施步骤](#3-迁移实施步骤)
4. [测试验证计划](#4-测试验证计划)
5. [回滚机制](#5-回滚机制)
6. [文档更新](#6-文档更新)
7. [时间节点与交付物](#7-时间节点与交付物)

---

## 1. 现状分析与差异评估

### 1.1 当前 CEGUI 0.7.1 使用全景

| 维度 | 统计数据 |
|------|---------|
| C++ 源文件引用 CEGUI | **31 个** `.cpp` 文件，共 **1614 处** `CEGUI::` 调用 |
| Lua 脚本文件引用 CEGUI | **100+ 个** `.lua` 文件 |
| 核心引用入口 | [GameUIManager.h](file:///e:/MT3/client/FireClient/Application/Manager/GameUIManager.h)（490 处 CEGUI:: 调用） |
| 第二引用入口 | [LuaFireClient.cpp](file:///e:/MT3/client/FireClient/Application/Framework/LuaFireClient.cpp) / [LuaFireClientWin32.cpp](file:///e:/MT3/client/FireClient/Application/Framework/LuaFireClientWin32.cpp)（各 297 处） |
| 构建系统引用 | 3 个 `.vcxproj` 工程（mt3.win32 / FireClient.win32 / engine.win32） |
| 链接库 | Debug: `cegui_d.lib` / Release: `cegui.lib` |
| 预处理器宏 | `CEGUI_STATIC`（全平台静态链接） |

### 1.2 MT3 对 CEGUI 0.7.1 的定制扩展清单

以下为 `dependencies/cegui/` 中相对于上游 CEGUI 0.7.1 的 MT3 定制内容，**必须在迁移时逐项移植到 0.7.9-r5**：

#### 1.2.1 自定义渲染器模块

| 模块 | 路径 | 说明 |
|------|------|------|
| Cocos2DRenderer | `RendererModules/Cocos2D/` | 核心渲染器，桥接 CEGUI 与 Cocos2d-x 渲染管线 |

#### 1.2.2 自定义图像编解码器

| 模块 | 路径 | 说明 |
|------|------|------|
| Cocos2DImageCodec | `ImageCodecModules/Cocos2DImageCodec/` | 基于 Cocos2d-x 的图像加载 |
| SILLYImageCodec | `ImageCodecModules/SILLYImageCodec/` | SILLY 库图像编解码 |

#### 1.2.3 自定义 XML 解析器

| 模块 | 路径 | 说明 |
|------|------|------|
| XMLIOParser | `XMLParserModules/XMLIOParser/` | MT3 自研 XML 解析器 |
| LJXMLParser | `XMLParserModules/LJXMLParser/` | Locojoy XML 解析器 |
| IosBuildInParser | `XMLParserModules/IosBuildInParser/` | iOS 内置解析器 |

#### 1.2.4 自定义 Lua 脚本模块

| 模块 | 路径 | 说明 |
|------|------|------|
| LuaScriptModule | `ScriptingModules/LuaScriptModule/` | CEGUI-Lua 绑定桥接 |

#### 1.2.5 自定义 Falagard 窗口渲染器（MT3 扩展）

以下为 MT3 在 Falagard 中新增的窗口渲染器，**在 0.7.9-r5 中不存在**：

| 文件 | 对应控件 |
|------|---------|
| `FalAnimateText.h` | 动画文本 |
| `FalAnimationButton.h` | 动画按钮 |
| `FalCompnenttip.h` | 组件提示 |
| `FalGroupBtnTree.h` | 分组按钮树 |
| `FalIrregularButton.h` | 不规则按钮 |
| `FalIrregularFigure.h` | 不规则图形 |
| `FalItemCell.h` | 物品格子 |
| `FalItemCellGeneral.h` | 通用物品格子 |
| `FalItemTable.h` | 物品表格 |
| `FalLinkText.h` | 链接文本 |
| `FalRichEditbox.h` | 富文本编辑框 |
| `FalSkillBox.h` | 技能框 |
| `FalSpecialTree.h` | 特殊树控件 |
| `FalSwitch.h` | 开关控件 |
| `FalProgressBarTwoValue.h` | 双值进度条 |
| `FalToggleButtonExtStateImagery.h` | 扩展状态切换按钮 |

#### 1.2.6 自定义元素/控件（核心 Widget）

以下为 MT3 在 `elements/` 中新增的 CEGUI 控件类型，**在 0.7.9-r5 中不存在**：

| 文件 | 控件类型 |
|------|---------|
| `CEGUIAnimateText.h` | AnimateText |
| `CEGUIAnimationButton.h` | AnimationButton |
| `CEGUICompnentTip.h` | CompnentTip |
| `CEGUIGroupBtnItem.h` / `CEGUIGroupBtnTree.h` / `CEGUIGroupButton.h` | GroupBtnTree 系列 |
| `CEGUIIrregularButton.h` | IrregularButton |
| `CEGUIIrregularFigure.h` | IrregularFigure |
| `CEGUIItemCell.h` / `CEGUIItemCellGeneral.h` | ItemCell 系列 |
| `CEGUIItemTable.h` | ItemTable |
| `CEGUILinkText.h` | LinkText |
| `CEGUIMessageTip.h` | MessageTip |
| `CEGUIPanelChengJiuItem.h` / `CEGUIPanelChengWeiItem.h` / `CEGUIPanelItem.h` / `CEGUIPanelQiYuanItem.h` / `CEGUIPanelbox.h` | Panel 系列 |
| `CEGUIProgressBarTwoValue.h` | ProgressBarTwoValue |
| `CEGUIRichEditbox.h` + 14 个 Component 子类 | RichEditbox 生态系统 |
| `CEGUISkillBox.h` | SkillBox |
| `CEGUISpecialTree.h` / `CEGUISpecialTreeItem.h` | SpecialTree |
| `CEGUISwitch.h` | Switch |

#### 1.2.7 其他定制模块

| 模块 | 说明 |
|------|------|
| `BinLayout/` | 二进制布局序列化系统 |
| `CEGUIPfsResourceProvider.h` | PFS 资源包提供器 |
| `CEGUIResLoadThread.h` / `CEGUILoadingTaskManager.h` | 异步资源加载 |
| `CEGUIEditboxStringParser.h` | 编辑框字符串解析 |
| `CEGUIAdapter.h` | 适配器层 |
| `Nuclear.h` | Nuclear 引擎集成头 |
| `gesture/` | 手势识别系统 |
| `CEGUIAnimation*.h` 系列 | 动画系统 |
| `CEGUIFreeTypeFont.h` | FreeType 字体支持 |

### 1.3 CEGUI 0.7.9-r5 与 0.7.1 的核心差异

| 差异维度 | 0.7.1（当前） | 0.7.9-r5（目标） | 影响 |
|---------|-------------|-----------------|------|
| 版本号 | `CEGUI_VERSION_PATCH 1` | `CEGUI_VERSION_PATCH 9` | 8 个小版本迭代 |
| 渲染器 | 含 Cocos2D 自定义 | 不含 Cocos2D（需移植） | **高** |
| 图像编解码 | 含 Cocos2D/SILLY | 不含 Cocos2D（需移植） | **高** |
| XML 解析器 | 含 XMLIO/LJXML/IosBuildIn | 不含（需移植） | **高** |
| Falagard 控件 | 含 16+ MT3 自定义 | 仅标准 Falagard | **高** |
| 核心控件 | 含 20+ MT3 自定义 | 仅标准控件 | **高** |
| 布局容器 | 无 | 新增 LayoutContainer 系列 | 低（新功能） |
| 渲染特效管理 | 无 | 新增 RenderEffectManager | 低（新功能） |
| 资源提供器 | 含 PFS | 含 Minizip（新） | 中 |
| STB 图像编解码 | 无 | 新增 STBImageCodec | 低（新功能） |
| RapidXML 解析器 | 无 | 新增 RapidXMLParser | 低（新功能） |
| 平台宏定义 | `WIN7_32` 等 | 标准 CEGUI 宏 | 中 |

---

### 1.4 UI 资源目录 `client/resource/res/ui/` 现状分析

#### 1.4.1 目录结构总览

```
client/resource/res/ui/
├── animations/          # 动画配置文件（1 个 sample.xml）
├── fonts/               # 字体定义文件（~90 个 .font + .ttf）
├── imagesets/           # 图像集定义文件（200+ 个 .imageset + 对应 .png/.tga/.jpg）
├── layouts/             # 布局文件（200+ 个 .layout）
├── looknfeel/           # 外观定义文件（2 个 .looknfeel）
└── schemes/             # 方案文件（2 个 .scheme）
```

#### 1.4.2 资源加载机制

在 [GameUIManager.cpp](file:///e:/MT3/client/FireClient/Application/Manager/GameUIManager.cpp) 中，CEGUI 资源通过以下机制加载：

**资源组目录映射**（`initialiseResourceGroupDirectories()`，第 1747-1775 行）：

| 资源组 | 发布版路径（PFS） | 调试版路径（文件系统） |
|--------|------------------|---------------------|
| `schemes` | `/ui/schemes/` | `{root}/res/ui/schemes/` |
| `imagesets` | `/ui/imagesets/` | `{root}/res/ui/imagesets/` |
| `fonts` | `/ui/fonts/` | `{root}/res/ui/fonts/` |
| `layouts` | `/ui/layouts/` | `{root}/res/ui/layouts/` |
| `looknfeel` | `/ui/looknfeel/` | `{root}/res/ui/looknfeel/` |
| `lua_scripts` | `/lua_scripts/` | `{root}/scripts/` |
| `animations` | `/ui/animations/` | `{root}/animations/` |

**方案加载**（`InitGameUI()` 第 2474 行，`InitGameUIPostInit()` 第 2339 行）：
```cpp
CEGUI::SchemeManager::getSingleton().create("taharezlook.scheme");   // 主方案
CEGUI::SchemeManager::getSingleton().append("taharezlook2.scheme");  // 扩展方案
```

#### 1.4.3 方案文件（.scheme）解析

**taharezlook.scheme** 定义了：
- **100+ 个 Imageset 引用**（如 `ccui.imageset`、`common.imageset`、`mainui.imageset` 等）
- **80+ 个 Font 引用**（mhsy 系列、tahoma 系列、simhei 系列、hycyj 系列等）
- **1 个 LookNFeel 文件**：`TaharezLook.looknfeel`
- **1 个 WindowRendererSet**：`CEGUIFalagardWRBase`
- **~20 个 FalagardMapping 条目**（标准控件映射）

**taharezlook2.scheme** 定义了：
- **200+ 个 Imageset 引用**（包括 itemicon、skillicon、roleandmonster、emotionicon 等系列）
- **7 个 Font 引用**（num-count、num-lvse 等数字字体）
- **1 个 LookNFeel 文件**：`TaharezLook2.looknfeel`
- **400+ 个 FalagardMapping 条目**（全部 MT3 自定义控件映射）

#### 1.4.4 方案文件中的自定义控件类型引用

taharezlook2.scheme 引用了以下 MT3 自定义控件类型（这些在 0.7.9-r5 标准版中不存在）：

| 自定义 TargetType | 对应 Falagard Renderer | 用途 |
|-------------------|----------------------|------|
| `CEGUI/ItemCell` | `Falagard/ItemCell` | 物品格子（30+ 映射变体） |
| `CEGUI/ItemCellGeneral` | `Falagard/ItemCellGeneral` | 通用物品格子 |
| `CEGUI/ItemTable` | `Falagard/ItemTable` | 物品表格 |
| `CEGUI/ItemListbox` | `Falagard/ItemListbox` | 物品列表框 |
| `CEGUI/GroupButton` | `Falagard/ToggleButton` | 分组按钮（80+ 映射变体） |
| `CEGUI/GroupBtnTree` | `Falagard/GroupBtnTree` | 分组按钮树 |
| `CEGUI/ProgressBarTwoValue` | `Falagard/ProgressBarTwoValue` | 双值进度条（血条） |
| `CEGUI/RichEditbox` | `Falagard/RichEditbox` | 富文本编辑框（4 个映射变体） |
| `CEGUI/SkillBox` | `Falagard/SkillBox` | 技能框（20+ 映射变体） |
| `CEGUI/MessageTip` | `Falagard/Default` | 消息提示 |
| `CEGUI/Switch` | `Falagard/Switch` | 开关控件 |
| `CEGUI/AnimateText` | `Falagard/AnimateText` | 动画文本 |
| `CEGUI/IrregularFigure` | `Falagard/IrregularFigure` | 不规则图形 |
| `CEGUI/IrregularButton` | `Falagard/IrregularButton` | 不规则按钮 |
| `CEGUI/CompnentTip` | `Falagard/CompnentTip` | 组件提示 |

#### 1.4.5 布局文件（.layout）格式分析

布局文件使用标准 CEGUI XML 格式，以 `GUILayout` 为根元素。示例（[chatdialog.layout](file:///e:/MT3/client/resource/res/ui/layouts/chatdialog.layout)）：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<GUILayout>
    <Window Type="TaharezLook/FrameWindow3" Name="ChatOutput/ChatOutputBox/Back">
        <Property Name="UnifiedAreaRect" Value="{{0,-15},{0,0},{0,550},{1,-13}}" />
        <Window Type="TaharezLook/common_text2bg" Name="...">
            <Window Type="TaharezLook/ScrollablePane" Name="...">
                ...
```

**关键发现**：
- 布局文件使用 `TaharezLook/` 前缀的 WindowType，这些类型在 .scheme 文件的 `FalagardMapping` 中定义
- 布局文件本身不直接引用 C++ 类名，而是通过 WindowType → TargetType 映射间接关联
- **只要 FalagardMapping 中定义的所有 WindowType 在 0.7.9-r5 中都有对应的 TargetType 和 Renderer，布局文件即可正常加载**

#### 1.4.6 字体文件（.font）格式分析

字体文件使用标准 CEGUI 格式，全部使用 FreeType 渲染（[mhsy-10.font](file:///e:/MT3/client/resource/res/ui/fonts/mhsy-10.font)）：

```xml
<?xml version="1.0" ?>
<Font Name="mhsy-10" Filename="mhsy.ttf" Type="FreeType" Size="10"
      NativeHorzRes="1024" NativeVertRes="768" AutoScaled="false"/>
```

**兼容性评估**：0.7.1 和 0.7.9-r5 的 FreeType 字体格式一致，且 0.7.9-r5 新增了 `PixmapFont` 支持，**字体文件可直接复用**。

#### 1.4.7 图像集文件（.imageset）格式分析

图像集文件使用标准 CEGUI XML 格式（[common.imageset](file:///e:/MT3/client/resource/res/ui/imagesets/common.imageset)）：

```xml
<Imageset Name="common" Imagefile="common.png" NativeHorzRes="1024"
          NativeVertRes="1024" AutoScaled="false">
    <Image Name="bainiu" XPos="709" YPos="761" Width="131" Height="63" />
    ...
```

**兼容性评估**：0.7.1 和 0.7.9-r5 的 Imageset XML 格式一致，**图像集文件可直接复用**。对应的 .png/.tga/.jpg 图片资源也无需修改。

#### 1.4.8 外观文件（.looknfeel）分析

外观文件定义了各个 WidgetLook 的具体渲染方式（`TaharezLook.looknfeel` 和 `TaharezLook2.looknfeel`）。这些文件中的 WidgetLook 名称与 .scheme 中 `FalagardMapping` 的 `LookNFeel` 属性对应。

**兼容性评估**：Falagard 系统的 XML 格式在 0.7.1 到 0.7.9-r5 之间基本稳定，但需要验证：
1. 自定义的 Falagard 组件（如 `Falagard/ItemCell`、`Falagard/SkillBox` 等）在移植后是否仍能正确解析
2. 新增的 Falagard 特性（如 0.7.9-r5 的 `LayoutContainer` 系列）是否与现有 looknfeel 冲突

#### 1.4.9 资源兼容性总结

| 资源类型 | 数量 | 格式兼容性 | 迁移难度 | 说明 |
|---------|------|-----------|---------|------|
| `.scheme` | 2 个 | **需修改** | 中 | 需验证所有 FalagardMapping 的 TargetType 和 Renderer 在移植后存在 |
| `.looknfeel` | 2 个 | 基本兼容 | 低 | Falagard XML 格式稳定，但需逐项验证 |
| `.layout` | 200+ 个 | 基本兼容 | 低 | 只要 WindowType 映射存在即可加载 |
| `.imageset` | 200+ 个 | 完全兼容 | 无 | XML 格式完全一致 |
| `.font` | ~90 个 | 完全兼容 | 无 | FreeType 格式完全一致 |
| 图片资源 | 500+ 个 | 完全兼容 | 无 | .png/.tga/.jpg 无需修改 |
| `.ttf` | 6 个 | 完全兼容 | 无 | 字体文件直接复用 |

**结论**：UI 资源文件（`client/resource/res/ui/`）的主体格式在 0.7.1 到 0.7.9-r5 之间高度兼容。迁移的核心挑战不在于资源文件格式本身，而在于确保所有自定义控件类型（~20 个 TargetType）和自定义 Falagard 渲染器（~16 个）全部成功移植到 0.7.9-r5，使得 .scheme 文件中的 FalagardMapping 能够正确解析。

---

## 2. 迁移前准备工作

### 2.1 环境搭建与配置

| 序号 | 工作项 | 详细说明 | 责任人 | 预计耗时 |
|------|--------|---------|--------|---------|
| 2.1.1 | 创建迁移分支 | `git checkout -b feature/cegui-0.7.9-r5-migration` | 技术负责人 | 0.5h |
| 2.1.2 | 提取 0.7.9-r5 源码 | 将 `tools/CEGUI-0.7.9-r5/cegui/` 复制到 `dependencies/cegui-0.7.9/` 作为新基线 | 构建工程师 | 1h |
| 2.1.3 | 分析 0.7.9-r5 构建系统 | 阅读 `tools/CEGUI-0.7.9-r5/projects/premake/` 和 `Makefile.in`，理解官方构建方式 | 构建工程师 | 4h |
| 2.1.4 | 创建 VS2013 工程 | 基于 0.7.9-r5 源码创建 `dependencies/cegui-0.7.9/project/win32/CEGUI.vcxproj`，配置 `v120` 工具集 | 构建工程师 | 8h |
| 2.1.5 | 编译验证 0.7.9-r5 基础库 | 在 VS2013 + Windows SDK 8.1 下编译 0.7.9-r5 核心库（不含 MT3 定制），确保 `cegui.lib` 可生成 | 构建工程师 | 4h |

### 2.2 原项目代码备份与版本控制

| 序号 | 工作项 | 详细说明 | 责任人 | 预计耗时 |
|------|--------|---------|--------|---------|
| 2.2.1 | 全量备份现有依赖 | `git tag archive/cegui-0.7.1-before-migration`，保留 `dependencies/cegui/` 完整历史 | 技术负责人 | 0.5h |
| 2.2.2 | 备份构建产物 | 备份 `dependencies/cegui/lib/cegui.lib`、`cegui_d.lib` 及中间产物 | 构建工程师 | 0.5h |
| 2.2.3 | 备份资源文件 | 确认 `client/resource/res/ui/` 下所有 `.layout`、`.looknfeel`、`.scheme`、`.imageset`、`.font` 已纳入版本控制 | 资源工程师 | 1h |
| 2.2.4 | 创建差异对比基线 | 导出 `dependencies/cegui/` 中所有 MT3 定制文件的完整清单（见 1.2 节） | 技术负责人 | 2h |

### 2.3 迁移风险评估及应对策略

| 风险编号 | 风险描述 | 影响范围 | 严重程度 | 应对策略 |
|---------|---------|---------|---------|---------|
| R1 | Cocos2DRenderer 接口不兼容 | 全部 UI 渲染 | **致命** | 逐接口对比 0.7.9-r5 的 `Renderer` 基类变更，优先适配渲染器 |
| R2 | 自定义控件（20+ 个）移植失败 | 对应 UI 功能不可用 | **致命** | 分批移植，先核心控件（MessageTip、RichEditbox、ItemCell），再辅助控件 |
| R3 | Lua 绑定接口变更 | 100+ Lua 脚本报错 | **严重** | 建立 Lua API 兼容层，逐个脚本回归测试 |
| R4 | 资源文件格式不兼容 | 布局/外观/方案加载失败 | **严重** | 编写 XML Schema 对比工具，自动检测格式差异 |
| R5 | 多平台编译失败（Android/iOS） | 移动端不可用 | **严重** | Win32 先通，再逐平台适配 |
| R6 | 运行时性能退化 | 帧率下降、内存增长 | **中等** | 建立性能基准测试，迁移前后对比 |
| R7 | 第三方依赖版本冲突 | SILLY、pcre、freetype 等 | **中等** | 锁定依赖版本，必要时升级 |
| R8 | ABI 不兼容导致链接错误 | 编译通过但链接失败 | **中等** | 全量重编 engine → FireClient → MT3 |

---

## 3. 迁移实施步骤

### 阶段一：基础设施移植（预计 5 个工作日）

#### 3.1 构建系统适配

| 步骤 | 操作 | 涉及文件 | 验收标准 |
|------|------|---------|---------|
| 3.1.1 | 更新 `mt3.win32.vcxproj` 的 CEGUI 包含路径 | 将 `../../dependencies/cegui/CEGUI/include` 改为 `../../dependencies/cegui-0.7.9/cegui/include` | 编译通过 |
| 3.1.2 | 更新 `FireClient.win32.vcxproj` 的包含路径 | 同上，6 个子目录路径同步更新 | 编译通过 |
| 3.1.3 | 更新 `engine.win32.vcxproj` 的预处理器定义 | 确认 `CEGUI_STATIC` 宏在各配置中保持一致 | 编译通过 |
| 3.1.4 | 更新链接库路径 | 将 `cegui.lib`/`cegui_d.lib` 搜索路径指向 0.7.9-r5 输出目录 | 链接成功 |
| 3.1.5 | 更新 `.clangd` 配置文件 | 同步 CEGUI 头文件路径 | IDE 智能提示正常 |

#### 3.2 CEGUI 核心库编译

| 步骤 | 操作 | 涉及文件 | 验收标准 |
|------|------|---------|---------|
| 3.2.1 | 配置 0.7.9-r5 的 `config.h` | 参考 0.7.1 的 `config.h` 配置，启用 CEGUI_STATIC、禁用动态模块 | `cegui.lib` 编译通过 |
| 3.2.2 | 解决 0.7.9-r5 基础编译问题 | 适配 VS2013 v120 工具集、C++11 特性兼容 | 零编译错误 |
| 3.2.3 | 裁剪不需要的模块 | 排除 Direct3D9/10/11、Ogre、Irrlicht、DirectFB、Null、Corona、DevIL、FreeImage、TGA、Xerces 等 | 精简库体积 |

### 阶段二：MT3 定制模块移植（预计 10 个工作日）

#### 3.3 渲染器移植（最高优先级）

| 步骤 | 操作 | 涉及文件 | 验收标准 |
|------|------|---------|---------|
| 3.3.1 | 对比 `Renderer` 基类差异 | 0.7.1 vs 0.7.9-r5 的 `CEGUIRenderer.h` | 差异清单完成 |
| 3.3.2 | 移植 `Cocos2DRenderer` | `CEGUICocos2DRenderer.h/.cpp`、`CEGUICocos2DGeometryBuffer.h/.cpp`、`CEGUICocos2DTexture.h/.cpp`、`CEGUICocos2DTextureTarget.h/.cpp`、`CEGUICocos2DRenderTarget.h/.cpp`、`CEGUICocos2DViewportTarget.h` | 渲染器编译通过 |
| 3.3.3 | 适配 0.7.9-r5 的 `RenderingSurface`/`RenderingWindow` 变更 | 检查新版本渲染管线 API 变化 | 渲染管线正常工作 |
| 3.3.4 | 移植 `Cocos2DImageCodec` | `CEGUICocos2DImageCodec.h/.cpp` | 图像加载正常 |

#### 3.4 XML 解析器移植

| 步骤 | 操作 | 涉及文件 | 验收标准 |
|------|------|---------|---------|
| 3.4.1 | 对比 `XMLParser` 基类差异 | 0.7.1 vs 0.7.9-r5 的 `CEGUIXMLParser.h` | 差异清单完成 |
| 3.4.2 | 移植 `XMLIOParser` | `CEGUIXMLIOParser.h/.cpp` | 解析器编译通过 |
| 3.4.3 | 移植 `LJXMLParser` | `CEGUILJXMLParser.h/.cpp`、`CEGUILJXMLParserHelper.h` | 解析器编译通过 |
| 3.4.4 | 移植 `IosBuildInParser` | `CEGUIIosBuildInParser.h/.cpp` | iOS 解析器编译通过 |

#### 3.5 Lua 脚本模块移植

| 步骤 | 操作 | 涉及文件 | 验收标准 |
|------|------|---------|---------|
| 3.5.1 | 对比 `ScriptModule` 基类差异 | 0.7.1 vs 0.7.9-r5 的 `CEGUIScriptModule.h` | 差异清单完成 |
| 3.5.2 | 移植 `LuaScriptModule` | `CEGUILua.h`、`CEGUILuaFunctor.h` 及对应 `.cpp` | Lua 绑定编译通过 |
| 3.5.3 | 适配 tolua++ 绑定 | 检查 `support/tolua++/` 是否需要更新 | 绑定生成正常 |

#### 3.6 自定义控件移植（分三批）

**第一批：核心控件（预计 4 个工作日）**

| 控件 | 涉及文件 | 依赖 |
|------|---------|------|
| MessageTip | `CEGUIMessageTip.h`、`FalMessageTip`（如存在） | 无 |
| RichEditbox | `CEGUIRichEditbox.h` + 14 个 Component | 无 |
| ItemCell | `CEGUIItemCell.h`、`CEGUIItemCellGeneral.h`、`FalItemCell.h`、`FalItemCellGeneral.h` | 无 |
| ItemTable | `CEGUIItemTable.h`、`FalItemTable.h` | ItemCell |
| LinkText | `CEGUILinkText.h`、`FalLinkText.h` | 无 |

**第二批：常用控件（预计 3 个工作日）**

| 控件 | 涉及文件 |
|------|---------|
| ItemListbox | `CEGUIItemListbox.h`、`FalItemListbox.h` |
| ItemEntry | `CEGUIItemEntry.h`、`FalItemEntry.h` |
| SkillBox | `CEGUISkillBox.h`、`FalSkillBox.h` |
| ProgressBarTwoValue | `CEGUIProgressBarTwoValue.h`、`FalProgressBarTwoValue.h` |
| Switch | `CEGUISwitch.h`、`FalSwitch.h` |
| AnimateText | `CEGUIAnimateText.h`、`FalAnimateText.h` |
| AnimationButton | `CEGUIAnimationButton.h`、`FalAnimationButton.h` |

**第三批：辅助控件（预计 2 个工作日）**

| 控件 | 涉及文件 |
|------|---------|
| GroupBtnTree | `CEGUIGroupBtnTree.h`、`CEGUIGroupBtnItem.h`、`CEGUIGroupButton.h`、`FalGroupBtnTree.h` |
| IrregularButton | `CEGUIIrregularButton.h`、`FalIrregularButton.h` |
| IrregularFigure | `CEGUIIrregularFigure.h`、`FalIrregularFigure.h` |
| SpecialTree | `CEGUISpecialTree.h`、`CEGUISpecialTreeItem.h`、`FalSpecialTree.h` |
| CompnentTip | `CEGUICompnentTip.h`、`FalCompnenttip.h` |
| Panel 系列 | `CEGUIPanel*.h` |

#### 3.7 其他定制模块移植

| 步骤 | 操作 | 涉及文件 | 优先级 |
|------|------|---------|--------|
| 3.7.1 | 移植 `PfsResourceProvider` | `CEGUIPfsResourceProvider.h/.cpp` | 高 |
| 3.7.2 | 移植 `BinLayout` 序列化系统 | `BinLayout/` 目录下全部文件 | 高 |
| 3.7.3 | 移植 `FreeTypeFont` | `CEGUIFreeTypeFont.h/.cpp` | 中 |
| 3.7.4 | 移植 `gesture` 手势系统 | `gesture/` 目录下全部文件 | 中 |
| 3.7.5 | 移植 `Animation` 动画系统 | `CEGUIAnimation*.h/.cpp` | 中 |
| 3.7.6 | 移植 `ResLoadThread`/`LoadingTaskManager` | `CEGUIResLoadThread.h`、`CEGUILoadingTaskManager.h` | 低 |
| 3.7.7 | 移植 `Nuclear.h` 集成头 | `Nuclear.h` | 低 |
| 3.7.8 | 移植 `CEGUIAdapter.h` | `CEGUIAdapter.h` | 低 |
| 3.7.9 | 移植 `CEGUIEditboxStringParser` | `CEGUIEditboxStringParser.h/.cpp` | 低 |

### 阶段三：API 适配与代码修改（预计 5 个工作日）

#### 3.8 C++ 代码适配

| 步骤 | 操作 | 涉及文件（约 31 个） | 验收标准 |
|------|------|---------------------|---------|
| 3.8.1 | 编译 FireClient 工程，收集所有编译错误 | 全部 31 个 C++ 文件 | 错误清单完成 |
| 3.8.2 | 修复 API 签名变更 | 重点检查 `GameUIManager.cpp`（490 处）、`LuaFireClient.cpp`（297 处）、`Battler.cpp`（92 处） | 编译零错误 |
| 3.8.3 | 修复头文件包含路径 | `UICommonHeader.h`、`GameUIManager.h`、`Dialog.h` 等 | 编译零错误 |
| 3.8.4 | 适配 `CEGUI::String` 变更（如有） | 全项目范围 | 编译零错误 |
| 3.8.5 | 适配事件系统变更（如有） | `CEGUI::EventArgs`、`CEGUI::EventSet` 相关 | 编译零错误 |
| 3.8.6 | 适配窗口管理器变更（如有） | `CEGUI::WindowManager`、`CEGUI::System` 相关 | 编译零错误 |

#### 3.9 Lua 代码适配

| 步骤 | 操作 | 涉及文件（100+ 个） | 验收标准 |
|------|------|---------------------|---------|
| 3.9.1 | 编写 Lua API 兼容性检查脚本 | 自动扫描 `CEGUI::` 相关 Lua 调用 | 差异报告完成 |
| 3.9.2 | 修复 Lua 侧 API 调用 | 逐文件检查和修复 | 脚本加载无报错 |
| 3.9.3 | 验证 tolua++ 生成的绑定 | 确认 `LuaFireClient.cpp` 绑定兼容 | 绑定调用正常 |

### 阶段四：资源文件兼容性处理（预计 3 个工作日）

#### 3.10 资源文件适配

| 步骤 | 操作 | 涉及文件 | 验收标准 |
|------|------|---------|---------|
| 3.10.1 | 扫描所有 `.layout` 文件 | 全部 layout 文件 | 清单和版本号统计 |
| 3.10.2 | 扫描所有 `.looknfeel` 文件 | 全部 looknfeel 文件 | 清单和格式差异 |
| 3.10.3 | 扫描所有 `.scheme` 文件 | 全部 scheme 文件 | 清单和格式差异 |
| 3.10.4 | 扫描所有 `.imageset` 文件 | 全部 imageset 文件 | 清单和格式差异 |
| 3.10.5 | 扫描所有 `.font` 文件 | 全部 font 文件 | 清单和格式差异 |
| 3.10.6 | 更新方案文件中的模块引用 | `.scheme` 文件中 Falagard 模块名 | 资源加载成功 |
| 3.10.7 | 更新外观文件中自定义控件的映射 | `.looknfeel` 中 `Renderer` 属性 | 外观渲染正确 |
| 3.10.8 | 验证布局文件加载 | 关键 UI 布局逐张加载验证 | 无 XML 解析错误 |

### 阶段五：平台适配（预计 5 个工作日）

#### 3.11 Android 平台适配

| 步骤 | 操作 | 涉及文件 | 验收标准 |
|------|------|---------|---------|
| 3.11.1 | 更新 `Android.mk` 中的 CEGUI 包含路径 | `client/android/LocojoyProject/jni/Android.mk` | NDK 编译通过 |
| 3.11.2 | 更新 `Application.mk` 中 CEGUI 相关配置 | 确认 `c++_shared`、`arm64-v8a` 兼容 | 编译通过 |
| 3.11.3 | 处理 Android 平台特定 API 差异 | Android 平台条件编译代码 | 编译通过 |

#### 3.12 iOS 平台适配

| 步骤 | 操作 | 涉及文件 | 验收标准 |
|------|------|---------|---------|
| 3.12.1 | 更新 Xcode 工程中的 CEGUI 头文件搜索路径 | `client/FireClient/FireClient.xcodeproj` | 编译通过 |
| 3.12.2 | 更新 `engine.xcodeproj` 中的 CEGUI 引用 | `engine/engine.xcodeproj` | 编译通过 |
| 3.12.3 | 处理 iOS 平台特定 API 差异 | `IosBuildInParser`、`CCEditBoxImpl` 等 | 编译通过 |

---

## 4. 测试验证计划

### 4.1 单元测试

| 测试项 | 测试内容 | 验证方法 | 通过标准 |
|--------|---------|---------|---------|
| UT-1 | CEGUI 核心库初始化/销毁 | 自动化测试 | 无内存泄漏、无崩溃 |
| UT-2 | 自定义控件创建/销毁 | 逐个控件创建并销毁 | 无内存泄漏、无崩溃 |
| UT-3 | XML 解析器加载测试 | 加载各类资源文件 | 解析成功，无异常 |
| UT-4 | Cocos2DRenderer 渲染管线 | 渲染测试场景 | 无 GL 错误、无崩溃 |
| UT-5 | Lua 脚本模块绑定 | 关键 Lua API 调用 | 返回值正确 |
| UT-6 | 资源提供器加载 | PFS 资源加载 | 加载成功 |

### 4.2 集成测试

| 测试项 | 测试内容 | 验证方法 | 通过标准 |
|--------|---------|---------|---------|
| IT-1 | 游戏启动 → CEGUI 初始化 | 完整启动流程 | 启动无崩溃、UI 正常显示 |
| IT-2 | 登录界面完整流程 | 手动操作 | 输入、按钮、转场正常 |
| IT-3 | 角色选择界面 | 手动操作 | 角色列表、按钮正常 |
| IT-4 | 主界面 HUD 加载 | 自动截图对比 | 界面元素位置、大小一致 |
| IT-5 | UI 打开/关闭流程 | 逐个打开所有 Dialog | 无崩溃、无内存泄漏 |

### 4.3 UI 功能测试

| 测试项 | 测试内容 | 涉及控件 | 通过标准 |
|--------|---------|---------|---------|
| FT-1 | 聊天系统 | RichEditbox、Emotion、LinkText | 发送/接收/表情/链接正常 |
| FT-2 | 背包系统 | ItemCell、ItemTable、ItemListbox | 物品显示/拖拽/排序正常 |
| FT-3 | 技能系统 | SkillBox、ProgressBarTwoValue | 技能图标/冷却显示正常 |
| FT-4 | 商店系统 | ItemCell、Panelbox、ScrollablePane | 商品列表/购买流程正常 |
| FT-5 | 任务系统 | LinkText、RichEditbox、SpecialTree | 任务追踪/对话正常 |
| FT-6 | 战斗 UI | AnimationButton、ProgressBarTwoValue | 技能按钮/血条/状态正常 |
| FT-7 | 坐骑系统 | ItemCell、Switch | 坐骑展示/切换正常 |
| FT-8 | 设置界面 | Switch、Slider、Editbox | 各项设置功能正常 |
| FT-9 | 消息提示 | MessageTip | 提示显示/消失/排队正常 |
| FT-10 | 输入法交互 | IME 代理 | 中英文输入/光标/选字正常 |

### 4.4 性能测试

| 测试项 | 测试内容 | 基准值（0.7.1） | 允许偏差 | 测试方法 |
|--------|---------|----------------|---------|---------|
| PT-1 | UI 渲染帧率 | 当前 Release 帧率 | 下降 < 5% | 同场景 FPS 对比 |
| PT-2 | UI 内存占用 | 当前内存占用 | 增长 < 10% | 内存分析工具 |
| PT-3 | 界面打开耗时 | 当前耗时 | 增长 < 20% | 计时打点 |
| PT-4 | 资源加载耗时 | 当前加载耗时 | 增长 < 15% | 计时打点 |
| PT-5 | DrawCall 数量 | 当前 DrawCall | 增长 < 10% | 渲染调试工具 |

### 4.5 回归测试

| 测试项 | 测试内容 | 验证方法 | 通过标准 |
|--------|---------|---------|---------|
| RT-1 | Lua 脚本全量加载 | 遍历所有 Lua 文件 | 无脚本错误 |
| RT-2 | 关键业务流程 | 登录→选角→入世界→战斗→退出 | 无崩溃、无异常 |
| RT-3 | 多分辨率适配 | 800x600 / 1024x768 / 1920x1080 | UI 布局正确 |

---

## 5. 回滚机制

### 5.1 回滚触发条件

| 条件编号 | 触发条件 | 严重程度 |
|---------|---------|---------|
| RB-1 | 核心渲染器（Cocos2DRenderer）移植后连续 3 天无法达到编译通过 | **致命** |
| RB-2 | 编译通过后，游戏启动崩溃率 > 50% | **致命** |
| RB-3 | 核心 UI 功能（聊天/背包/战斗）无法正常工作 | **致命** |
| RB-4 | 性能退化超过 30% | **严重** |
| RB-5 | 迁移总耗时超过计划 150%（即超过 45 个工作日） | **严重** |

### 5.2 回滚操作流程

```text
1. 确认回滚决策
   ├── 技术负责人评估回滚条件是否满足
   └── 项目经理审批回滚

2. 代码回滚
   ├── git checkout 原分支（master 或 develop）
   ├── 或 git revert feature/cegui-0.7.9-r5-migration 的所有提交
   └── 验证 git status 干净

3. 依赖回滚
   ├── 恢复 dependencies/cegui/ 目录（从 archive/cegui-0.7.1-before-migration tag）
   ├── 恢复 cegui.lib / cegui_d.lib 预编译库
   └── 恢复 .vcxproj 中的原始路径

4. 构建验证
   ├── 执行 Build-MT3-Exe-Canonical.ps1 -Configuration Release
   └── 验证 MT3.exe 可正常启动

5. 资源验证
   └── 确认资源文件未被修改（git diff 原资源目录）

6. 回滚完成通知
   └── 通知全体相关人员，记录回滚原因和经验教训
```

### 5.3 增量回滚策略

对于部分模块迁移失败的情况，采用**增量回滚**策略：

| 场景 | 回滚范围 | 操作 |
|------|---------|------|
| 单个自定义控件移植失败 | 仅回滚该控件 | 该控件暂时使用旧版实现，其他继续使用新版 |
| 单个平台编译失败 | 仅回滚该平台 | 其他平台继续推进，失败平台记录阻塞项 |
| XML 解析器移植失败 | 回滚解析器 | 暂时保留旧版解析器，先推进其他模块 |

---

## 6. 文档更新

### 6.1 需更新的文档清单

| 文档 | 路径 | 更新内容 | 责任人 |
|------|------|---------|--------|
| 根 AGENTS.md | `AGENTS.md` | 更新 CEGUI 版本引用为 0.7.9-r5 | 技术负责人 |
| 项目规则 | `.trae/rules/project_rules.md` | 更新 CEGUI 运行时版本说明 | 技术负责人 |
| FireClient AGENTS | `client/FireClient/Application/AGENTS.md` | 更新 CEGUI 头文件路径和版本 | 技术负责人 |
| 构建指南 | `.claude/BUILD_GUIDE.md` | 更新 CEGUI 库编译命令和路径 | 构建工程师 |
| 项目架构 | `docs/02-技术架构/02-项目架构.md` | 更新 CEGUI 版本号 | 技术负责人 |
| API 变更说明 | `docs/CEGUI-0.7.9-r5-API变更说明.md`（新建） | 逐条记录 API 变更 | 开发工程师 |
| 迁移说明 | `docs/CEGUI-0.7.9-r5-迁移说明.md`（新建） | 迁移过程记录、经验总结 | 技术负责人 |

### 6.2 待创建的技术文档

| 文档 | 内容 | 完成时间 |
|------|------|---------|
| CEGUI 0.7.9-r5 自定义控件开发指南 | 如何在 0.7.9-r5 中新增自定义控件 | 迁移完成后 |
| CEGUI 0.7.9-r5 API 使用手册 | 新版本 API 参考（聚焦 MT3 使用部分） | 迁移完成后 |
| CEGUI 0.7.9-r5 构建指南 | 新版 CEGUI 库在各平台的编译步骤 | 迁移完成后 |

---

## 7. 时间节点与交付物

### 7.1 总体时间线

```text
Phase 0: 迁移前准备                        ██░░░░░░░░░░░░░░░░░░  2 个工作日
Phase 1: 基础设施移植（构建系统 + 核心库）    ░░████░░░░░░░░░░░░░░  5 个工作日
Phase 2: MT3 定制模块移植                   ░░░░░░████████████░░ 10 个工作日
Phase 3: API 适配与代码修改                 ░░░░░░░░░░░░░░░░██░░  5 个工作日
Phase 4: 资源文件兼容性处理                  ░░░░░░░░░░░░░░░░░███  3 个工作日
Phase 5: 平台适配（Android/iOS）            ░░░░░░░░░░░░░░░░░░██  5 个工作日
Phase 6: 测试验证                          ░░░░░░░░░░░░░░░░░░███  5 个工作日
Phase 7: 文档更新与交付                     ░░░░░░░░░░░░░░░░░░░░█  2 个工作日
---------------------------------------------------------------------------
总计：约 37 个工作日（含缓冲约 7 周）
```

### 7.2 各阶段交付物

| 阶段 | 交付物 | 验收标准 |
|------|--------|---------|
| 阶段 0 | 迁移分支、差异分析报告、备份 Tag | 分支创建成功，差异清单完整 |
| 阶段 1 | `cegui-0.7.9` 基础库、更新的 `.vcxproj` 文件 | 空白工程编译通过 |
| 阶段 2 | 移植后的全部 MT3 定制模块源码 | 各模块编译通过 |
| 阶段 3 | 修改后的全部 C++/Lua 源码 | 全量编译通过，零错误 |
| 阶段 4 | 兼容性处理后的资源文件 | 所有资源文件加载成功 |
| 阶段 5 | Android/iOS 编译通过的工程 | 各平台编译通过 |
| 阶段 6 | 测试报告 | 所有测试项通过 |
| 阶段 7 | 更新后的文档 | 文档评审通过 |

### 7.3 人员配置建议

| 角色 | 人数 | 职责 |
|------|------|------|
| 技术负责人 | 1 | 方案制定、架构决策、代码审查 |
| C++ 开发工程师 | 2 | CEGUI 定制模块移植、C++ 代码适配 |
| Lua 开发工程师 | 1 | Lua 脚本适配、绑定验证 |
| 构建工程师 | 1 | 构建系统配置、多平台编译、CI/CD |
| 资源工程师 | 1 | 资源文件兼容性处理、UI 布局验证 |
| QA 工程师 | 1 | 测试用例编写、功能/性能测试 |
| 项目经理 | 1 | 进度跟踪、风险管控、资源协调 |

---

## 附录

### A. 关键文件清单

- [CEGUI 0.7.1 版本头文件](file:///e:/MT3/dependencies/cegui/CEGUI/include/CEGUIVersion.h)
- [CEGUI 0.7.9-r5 版本头文件](file:///e:/MT3/tools/CEGUI-0.7.9-r5/cegui/include/CEGUIVersion.h)
- [GameUIManager.h（核心 UI 管理类）](file:///e:/MT3/client/FireClient/Application/Manager/GameUIManager.h)
- [UICommonHeader.h（UI 通用头文件）](file:///e:/MT3/client/FireClient/Application/Common/UICommonHeader.h)
- [mt3.win32.vcxproj（Win32 最终链接工程）](file:///e:/MT3/client/MT3Win32App/mt3.win32.vcxproj)
- [FireClient.win32.vcxproj（FireClient 工程）](file:///e:/MT3/client/MT3Win32App/FireClient.win32.vcxproj)
- [engine.win32.vcxproj（引擎工程）](file:///e:/MT3/engine/engine.win32.vcxproj)

### B. 术语说明

| 术语 | 说明 |
|------|------|
| CEGUI | Crazy Eddie's GUI System，开源 GUI 库 |
| Falagard | CEGUI 的窗口渲染器集合，实现控件外观 |
| tolua++ | C++ 到 Lua 的自动绑定工具 |
| Cocos2d-x | MT3 使用的 2D 游戏引擎基础层 |
| PFS | MT3 自研资源打包格式 |
| v120 | Visual Studio 2013 的平台工具集版本号 |