# CEGUI 架构关系

> **定位**：统一说明 CEGUI 源码副本、编译分组、产物、工具和客户端引用关系。
> **合并来源**：本页已吸收旧“CEGUI 编译产物对比分析”中有效的目录/产物角色说明。
> **当前依赖矩阵**：[docs/06-工具链/02-依赖矩阵.md](../06-工具链/02-依赖矩阵.md)。
> **文档索引**：[docs/07-参考文档/02-文档索引.md](../07-参考文档/02-文档索引.md)

## 1. 目录角色

```text
dependencies/cegui/
  └─ 客户端当前 0.7.1 定制源码与三端工程

tools/CEGUI-0.7.1/
  └─ 0.7.1 配套源码/工具研究副本

tools/CEGUI-0.7.1-bulid/
  └─ 历史预构建 lib/bin 产物

tools/CEGUI-0.7.9-r5/
  └─ 0.7.9 可行性研究样本和阶段性产物

tools/CEImagesetEditor-0.7.1/dependencies/
  └─ CEImagesetEditor 自包含 CEGUI 0.7.1 + wxWidgets 3.0.5
```

## 2. 客户端编译关系

| 平台 | 工程/入口 | 引用的 CEGUI 角色 |
| --- | --- | --- |
| Win32 | `dependencies/cegui/project/win32/cegui.win32.vcxproj`、`FireClient.win32.vcxproj`、`mt3.win32.vcxproj` | 直接编译/链接 `dependencies/cegui/`。 |
| Android | `dependencies/cegui/Android.mk`、`client/FireClient/Android.mk` | 编译当前 0.7.1 定制源码和 Cocos2D renderer。 |
| iOS | `dependencies/cegui/CEGUI.xcodeproj`、FireClient Xcode 工程 | 编译当前 0.7.1 定制模块。 |

`tools/CEGUI-0.7.1/` 和 `tools/CEGUI-0.7.9-r5/` 不是客户端当前工程的默认源码根。

## 3. 模块与产物

| 模块角色 | 当前源码/工程分组 | 典型产物类型 |
| --- | --- | --- |
| Base | `CEGUIBase/`、`CEGUI/` 核心 | 静态库或平台库 |
| Cocos2D Renderer | `CEGUICocos2DRender/`、`RendererModules/Cocos2D/` | renderer 库/对象 |
| Falagard | `CEGUIFalagardWRBase/`、`WindowRendererSets/Falagard/` | WindowRendererSet 库/对象 |
| Lua | `CEGUILuaScriptModule/` | Lua ScriptModule 库/对象 |
| Image/XML | `CEGUIImageCodec/`、`CEGUIXmlParser/` | codec/parser 库/对象 |

具体 `.lib`/`.dll` 文件名、Debug 后缀和位置以当前工程的 `AdditionalDependencies`、输出目录和当次构建产物为准，不从历史目录里随机挑选库替换。

## 4. 工具关系

| 工具 | CEGUI 角色 | 构建/技术入口 |
| --- | --- | --- |
| CEImagesetEditor | 自包含 0.7.1 和 wxWidgets 3.0.5 | [构建](../06-工具链/07-CEImagesetEditor编译构建.md) / [手册](09-CEImagesetEditor技术手册.md) |
| CELayoutEditor | 布局可视化和资源加载 | [静态分析](14-CELayoutEditor静态分析.md) |
| BinLayoutStudio | XML/BIN Layout 转换 | [构建](../06-工具链/04-BinLayoutStudio-v120构建.md) / [优化研究](13-BinLayoutStudio优化方案.md) |
| LnFEditor | LookNFeel 可视化解析/回写 | [架构设计](15-LookNFeelEditor架构设计.md) |

## 5. 运行时关系

```text
GameUIManager
  -> CEGUI System + Cocos2DRenderer + ResourceProvider + LuaScriptModule
  -> Scheme / Falagard / Imageset / Font / Layout
  -> root_wnd GUISheet
  -> Lua Dialog and C++ business callbacks

CEGUI System
  -> 启动 CEGUIResLoadThread
  -> CCEGUITaskManager（CEGUILoadingTaskManager.cpp）
     -> file / parse / font / cache queues
  -> Imageset 首次 draw 排入纹理文件任务
  -> Cocos2D renderer 完成解析结果与渲染纹理衔接

GameApplication 帧末
  -> ImagesetManager::UpdateTextureState
  -> task cache pump + Imageset 状态更新 + Renderer::OnFrameEnd
```

## 6. 取用规则

1. 客户端修复从 `dependencies/cegui/` 回源，不直接修历史 `.lib/.dll`。
2. 工具使用自身工程声明的依赖，不因名称相同就替换。
3. 0.7.9 只在独立研究路径中取用，不改写当前 0.7.1 引用。
4. 更换产物前核对工具集、平台、CRT、宏、定制补丁和下游重编范围。
5. 0.7.9 迁移必须为异步资源线程、任务队列、Imageset 排队、渲染线程落地、帧末收束和销毁顺序提供等价实现或明确重构方案。
