# CEGUI 0.7.1 架构事实基线

## 审计边界

- 本文仅审计 [`tools/CEGUI-0.7.1/cegui`](../tools/CEGUI-0.7.1/cegui) 及其渲染模块入口源码，不纳入 [`tools/CEGUI-0.7.1/Samples`](../tools/CEGUI-0.7.1/Samples) 作为事实来源。
- 目标是为后续文档重构提供可交叉验证的代码事实，不包含实现修改，也不处理 [`docs/`](../docs) 修复。
- 证据格式统一为 源码文件 + 关键符号 + 行号。

---

## 模块图 文字版

### 1. 顶层协调层

- 全局协调器是 [`System`](../tools/CEGUI-0.7.1/cegui/include/CEGUISystem.h:107)，它同时继承 `Singleton<System>` 与 `EventSet`，对外暴露创建、销毁、输入注入、渲染和默认资源配置入口。
- 初始化时会启动异步资源线程 [`CEGUIResLoadThread`](../tools/CEGUI-0.7.1/cegui/include/CEGUIResLoadThread.h:13)，并在销毁时由 [`System::destroy()`](../tools/CEGUI-0.7.1/cegui/src/CEGUISystem.cpp:2429) 统一回收。

### 2. 渲染抽象层

- 抽象接口是 [`Renderer`](../tools/CEGUI-0.7.1/cegui/include/CEGUIRenderer.h:63)，负责：
  - 几何缓存创建与销毁 [`Renderer::createGeometryBuffer()`](../tools/CEGUI-0.7.1/cegui/include/CEGUIRenderer.h:87)
  - 纹理与纹理目标创建 [`Renderer::createTexture()`](../tools/CEGUI-0.7.1/cegui/include/CEGUIRenderer.h:168)
  - 帧级 begin/end [`Renderer::beginRendering()`](../tools/CEGUI-0.7.1/cegui/include/CEGUIRenderer.h:210) / [`Renderer::endRendering()`](../tools/CEGUI-0.7.1/cegui/include/CEGUIRenderer.h:216)
  - 显示尺寸更新 [`Renderer::setDisplaySize()`](../tools/CEGUI-0.7.1/cegui/include/CEGUIRenderer.h:242)
  - MT3 分叉扩展的纹理生命周期接口 [`Renderer::ResetRenderTextures()`](../tools/CEGUI-0.7.1/cegui/include/CEGUIRenderer.h:286) 与 [`Renderer::OnFrameEnd()`](../tools/CEGUI-0.7.1/cegui/include/CEGUIRenderer.h:292)
- 默认渲染根是 [`RenderingRoot`](../tools/CEGUI-0.7.1/cegui/include/CEGUIRenderingRoot.h:36)，它继承 [`RenderingSurface`](../tools/CEGUI-0.7.1/cegui/include/CEGUIRenderingSurface.h:126)。
- 离屏缓存窗口是 [`RenderingWindow`](../tools/CEGUI-0.7.1/cegui/include/CEGUIRenderingWindow.h:44)，同样继承 [`RenderingSurface`](../tools/CEGUI-0.7.1/cegui/include/CEGUIRenderingSurface.h:126)，再把自身几何回挂到 owner surface。
- 几何提交队列由 [`RenderQueue`](../tools/CEGUI-0.7.1/cegui/include/CEGUIRenderQueue.h:53) 负责。

### 3. 窗口对象层

- 核心窗口对象是 [`Window`](../tools/CEGUI-0.7.1/cegui/include/CEGUIWindow.h:166)，继承 `PropertySet` 与 `EventSet`。
- 窗口生命周期管理者是 [`WindowManager`](../tools/CEGUI-0.7.1/cegui/include/CEGUIWindowManager.h:63)，负责创建、销毁、布局加载、死池清理与全局窗口注册。
- 类型工厂表由 [`WindowFactoryManager`](../tools/CEGUI-0.7.1/cegui/include/CEGUIWindowFactoryManager.h:61) 管理；LookNFeel/Falagard 映射也在此层完成。
- 可分配窗口渲染器由 [`WindowRenderer`](../tools/CEGUI-0.7.1/cegui/include/CEGUIWindowRenderer.h:50) 与 [`WindowRendererManager`](../tools/CEGUI-0.7.1/cegui/include/CEGUIWindowRendererManager.h:48) 负责。

### 4. 资源管理层

- 抽象资源入口是 [`ResourceProvider`](../tools/CEGUI-0.7.1/cegui/include/CEGUIResourceProvider.h:48)。
- 默认文件系统实现是 [`DefaultResourceProvider`](../tools/CEGUI-0.7.1/cegui/include/CEGUIDefaultResourceProvider.h:46)。
- XML 命名资源统一复用模板 [`NamedXMLResourceManager`](../tools/CEGUI-0.7.1/cegui/include/CEGUINamedXMLResourceManager.h:94)。
- 其上层具体管理器包括：
  - [`ImagesetManager`](../tools/CEGUI-0.7.1/cegui/include/CEGUIImagesetManager.h:57)
  - [`FontManager`](../tools/CEGUI-0.7.1/cegui/include/CEGUIFontManager.h:58)
  - [`SchemeManager`](../tools/CEGUI-0.7.1/cegui/include/CEGUISchemeManager.h:52)

### 5. XML 与配置层

- 解析抽象是 [`XMLParser`](../tools/CEGUI-0.7.1/cegui/include/CEGUIXMLParser.h:42)，SAX 风格处理器基类是 [`XMLHandler`](../tools/CEGUI-0.7.1/cegui/include/CEGUIXMLHandler.h:37)。
- 配置装配处理器是 [`Config_xmlHandler`](../tools/CEGUI-0.7.1/cegui/include/CEGUIConfig_xmlHandler.h:46)。
- 布局装配处理器是 [`GUILayout_xmlHandler`](../tools/CEGUI-0.7.1/cegui/include/CEGUIGUILayout_xmlHandler.h:47)。
- 资源定义处理器包括 [`Imageset_xmlHandler`](../tools/CEGUI-0.7.1/cegui/include/CEGUIImageset_xmlHandler.h:37)、[`Font_xmlHandler`](../tools/CEGUI-0.7.1/cegui/include/CEGUIFont_xmlHandler.h:37)、[`Scheme_xmlHandler`](../tools/CEGUI-0.7.1/cegui/include/CEGUIScheme_xmlHandler.h:38)。

### 6. 脚本层

- 脚本抽象接口是 [`ScriptModule`](../tools/CEGUI-0.7.1/cegui/include/CEGUIScriptModule.h:46)。
- 当前源码内置脚本实现是 [`LuaScriptModule`](../tools/CEGUI-0.7.1/cegui/include/ScriptingModules/LuaScriptModule/CEGUILua.h:60)。
- 布局文件中的脚本事件绑定最终通过 [`EventSet::subscribeScriptedEvent()`](../tools/CEGUI-0.7.1/cegui/include/CEGUIEventSet.h:187) 转交 [`ScriptModule::subscribeEvent()`](../tools/CEGUI-0.7.1/cegui/include/CEGUIScriptModule.h:178)。

---

## 顶层设计与启动 初始化主链路

### 1. 外部 bootstrap 入口

1. OGRE 路径：[`OgreRenderer::bootstrapSystem()`](../tools/CEGUI-0.7.1/cegui/src/RendererModules/Ogre/CEGUIOgreRenderer.cpp:69)
   - 创建 renderer [`OgreRenderer::create()`](../tools/CEGUI-0.7.1/cegui/src/RendererModules/Ogre/CEGUIOgreRenderer.cpp:119)
   - 创建 resource provider [`createOgreResourceProvider()`](../tools/CEGUI-0.7.1/cegui/src/RendererModules/Ogre/CEGUIOgreRenderer.cpp:137)
   - 创建 image codec [`createOgreImageCodec()`](../tools/CEGUI-0.7.1/cegui/src/RendererModules/Ogre/CEGUIOgreRenderer.cpp:77)
   - 调用 [`System::create()`](../tools/CEGUI-0.7.1/cegui/src/CEGUISystem.cpp:2419)
2. Irrlicht 路径：[`IrrlichtRenderer::bootstrapSystem()`](../tools/CEGUI-0.7.1/cegui/src/RendererModules/Irrlicht/CEGUIIrrlichtRenderer.cpp:48)
   - 同样创建 renderer、resource provider、image codec 后调用 [`System::create()`](../tools/CEGUI-0.7.1/cegui/src/CEGUISystem.cpp:2419)
3. Cocos2D 路径：[`Cocos2DRenderer::bootstrapSystem()`](../tools/CEGUI-0.7.1/cegui/src/RendererModules/Cocos2D/CEGUICocos2DRenderer.cpp:292)
   - 仅创建 renderer 并记录 parent [`renderer.d_pParent = parent`](../tools/CEGUI-0.7.1/cegui/src/RendererModules/Cocos2D/CEGUICocos2DRenderer.cpp:299)
   - **未在该函数内调用 [`System::create()`](../tools/CEGUI-0.7.1/cegui/src/CEGUISystem.cpp:2419)**
   - 但 [`Cocos2DRenderer::destroySystem()`](../tools/CEGUI-0.7.1/cegui/src/RendererModules/Cocos2D/CEGUICocos2DRenderer.cpp:305) 又要求 [`System::getSingletonPtr()`](../tools/CEGUI-0.7.1/cegui/src/RendererModules/Cocos2D/CEGUICocos2DRenderer.cpp:308) 已存在

### 2. [`System`](../tools/CEGUI-0.7.1/cegui/include/CEGUISystem.h:107) 构造主链

[`System::System()`](../tools/CEGUI-0.7.1/cegui/src/CEGUISystem.cpp:227) 的关键顺序如下：

1. 固定数值 locale 为 C [`setlocale(LC_NUMERIC, "C")`](../tools/CEGUI-0.7.1/cegui/src/CEGUISystem.cpp:297)
2. 启动异步资源线程 [`CEGUIResLoadThread::GetPtr()->Start()`](../tools/CEGUI-0.7.1/cegui/src/CEGUISystem.cpp:299)
3. 初始化 logger，必要时构造 [`DefaultLogger`](../tools/CEGUI-0.7.1/cegui/src/CEGUISystem.cpp:308)
4. 如未注入资源提供器，则创建 [`DefaultResourceProvider`](../tools/CEGUI-0.7.1/cegui/src/CEGUISystem.cpp:317)
5. 建立 XML 解析器 [`System::setupXMLParser()`](../tools/CEGUI-0.7.1/cegui/src/CEGUISystem.cpp:322)
6. 若存在配置文件，则用 [`XMLParser::parseXMLFile()`](../tools/CEGUI-0.7.1/cegui/include/CEGUIXMLParser.h:103) + [`Config_xmlHandler`](../tools/CEGUI-0.7.1/cegui/include/CEGUIConfig_xmlHandler.h:46) 解析配置 [`d_xmlParser->parseXMLFile(config, configFile, ...)`](../tools/CEGUI-0.7.1/cegui/src/CEGUISystem.cpp:330)
7. 根据配置初始化 logger、resource group、XML parser、image codec、默认资源组 [`Config_xmlHandler::initialiseLogger()`](../tools/CEGUI-0.7.1/cegui/src/CEGUIConfig_xmlHandler.cpp:236)、[`Config_xmlHandler::initialiseResourceGroupDirectories()`](../tools/CEGUI-0.7.1/cegui/src/CEGUIConfig_xmlHandler.cpp:244)、[`Config_xmlHandler::initialiseDefaultResourceGroups()`](../tools/CEGUI-0.7.1/cegui/src/CEGUIConfig_xmlHandler.cpp:257)
8. 创建核心单例管理器 [`System::createSingletons()`](../tools/CEGUI-0.7.1/cegui/src/CEGUISystem.cpp:2055)
9. 注册标准窗口工厂 [`addStandardWindowFactories()`](../tools/CEGUI-0.7.1/cegui/src/CEGUISystem.cpp:373)
10. 注册 `DefaultGUISheet` 类型别名 [`WindowFactoryManager::addWindowTypeAlias()`](../tools/CEGUI-0.7.1/cegui/src/CEGUISystem.cpp:376)
11. 自动加载资源 [`Config_xmlHandler::loadAutoResources()`](../tools/CEGUI-0.7.1/cegui/src/CEGUIConfig_xmlHandler.cpp:306)
12. 应用默认字体、鼠标、Tooltip、GUISheet [`Config_xmlHandler::initialiseDefaultFont()`](../tools/CEGUI-0.7.1/cegui/src/CEGUIConfig_xmlHandler.cpp:343)、[`Config_xmlHandler::initialiseDefaultGUISheet()`](../tools/CEGUI-0.7.1/cegui/src/CEGUIConfig_xmlHandler.cpp:365)
13. 若存在脚本模块，则创建绑定并执行初始化脚本 [`d_scriptModule->createBindings()`](../tools/CEGUI-0.7.1/cegui/src/CEGUISystem.cpp:396)、[`Config_xmlHandler::executeInitScript()`](../tools/CEGUI-0.7.1/cegui/src/CEGUIConfig_xmlHandler.cpp:373)
14. 注册 BinLayout 序列化器 [`BinLayout::g_RegSerializers_v1()`](../tools/CEGUI-0.7.1/cegui/src/CEGUISystem.cpp:410)

### 3. 核心单例创建顺序

[`System::createSingletons()`](../tools/CEGUI-0.7.1/cegui/src/CEGUISystem.cpp:2055) 明确创建：

1. [`ImagesetManager`](../tools/CEGUI-0.7.1/cegui/src/CEGUISystem.cpp:2058)
2. [`FontManager`](../tools/CEGUI-0.7.1/cegui/src/CEGUISystem.cpp:2059)
3. [`WindowFactoryManager`](../tools/CEGUI-0.7.1/cegui/src/CEGUISystem.cpp:2060)
4. [`WindowManager`](../tools/CEGUI-0.7.1/cegui/src/CEGUISystem.cpp:2061)
5. [`SchemeManager`](../tools/CEGUI-0.7.1/cegui/src/CEGUISystem.cpp:2062)
6. [`MouseCursor`](../tools/CEGUI-0.7.1/cegui/src/CEGUISystem.cpp:2063)
7. [`GlobalEventSet`](../tools/CEGUI-0.7.1/cegui/src/CEGUISystem.cpp:2064)
8. [`WidgetLookManager`](../tools/CEGUI-0.7.1/cegui/src/CEGUISystem.cpp:2065)
9. [`WindowRendererManager`](../tools/CEGUI-0.7.1/cegui/src/CEGUISystem.cpp:2066)
10. [`AnimationManager`](../tools/CEGUI-0.7.1/cegui/src/CEGUISystem.cpp:2067)

### 4. 帧运行主链

[`System::renderGUI()`](../tools/CEGUI-0.7.1/cegui/src/CEGUISystem.cpp:483) 的运行顺序：

1. [`Renderer::beginRendering()`](../tools/CEGUI-0.7.1/cegui/include/CEGUIRenderer.h:210)
2. 若需要重绘，则取活动根窗口 [`d_activeSheet`](../tools/CEGUI-0.7.1/cegui/src/CEGUISystem.cpp:491)
3. 清空根目标 surface 的几何 [`rs.clearGeometry()`](../tools/CEGUI-0.7.1/cegui/src/CEGUISystem.cpp:494)
4. 调用根窗口递归渲染 [`Window::render()`](../tools/CEGUI-0.7.1/cegui/src/CEGUIWindow.cpp:2117)
5. 提交默认根 surface 绘制 [`getDefaultRenderingRoot().draw()`](../tools/CEGUI-0.7.1/cegui/src/CEGUISystem.cpp:514)
6. [`Renderer::endRendering()`](../tools/CEGUI-0.7.1/cegui/include/CEGUIRenderer.h:216)
7. 帧尾清理死池窗口 [`WindowManager::cleanDeadPool()`](../tools/CEGUI-0.7.1/cegui/src/CEGUISystem.cpp:519)

### 5. 销毁主链

[`System::~System()`](../tools/CEGUI-0.7.1/cegui/src/CEGUISystem.cpp:417) 的顺序是：

1. 执行终止脚本 [`executeScriptFile(d_termScriptName)`](../tools/CEGUI-0.7.1/cegui/src/CEGUISystem.cpp:426)
2. 清理 image codec [`cleanupImageCodec()`](../tools/CEGUI-0.7.1/cegui/src/CEGUISystem.cpp:432)
3. 清理 XML parser [`cleanupXMLParser()`](../tools/CEGUI-0.7.1/cegui/src/CEGUISystem.cpp:435)
4. 锁定 [`WindowManager`](../tools/CEGUI-0.7.1/cegui/src/CEGUISystem.cpp:443)
5. 销毁全部窗口并清死池 [`destroyAllWindows()`](../tools/CEGUI-0.7.1/cegui/src/CEGUISystem.cpp:445)、[`cleanDeadPool()`](../tools/CEGUI-0.7.1/cegui/src/CEGUISystem.cpp:446)
6. 移除所有窗口工厂 [`WindowFactoryManager::removeAllFactories()`](../tools/CEGUI-0.7.1/cegui/src/CEGUISystem.cpp:449)
7. 销毁脚本绑定 [`d_scriptModule->destroyBindings()`](../tools/CEGUI-0.7.1/cegui/src/CEGUISystem.cpp:453)
8. 逆序销毁单例 [`System::destroySingletons()`](../tools/CEGUI-0.7.1/cegui/src/CEGUISystem.cpp:2070)
9. 释放资源提供器与 logger（若 owned）
10. [`System::destroy()`](../tools/CEGUI-0.7.1/cegui/src/CEGUISystem.cpp:2429) 最后调用 [`CEGUIResLoadThread::Destroy()`](../tools/CEGUI-0.7.1/cegui/src/CEGUIResLoadThread.cpp:54)

---

## 关键类关系表

| 类/接口 | 继承关系 | 组合/依赖关系 | 代码证据 |
|---|---|---|---|
| System | `Singleton<System>` + `EventSet` | 持有 renderer、resource provider、xml parser、image codec、script module、active sheet | [`CEGUISystem.h:107`](../tools/CEGUI-0.7.1/cegui/include/CEGUISystem.h:107), [`CEGUISystem.cpp:235`](../tools/CEGUI-0.7.1/cegui/src/CEGUISystem.cpp:235) |
| Renderer | 抽象基类 | 向上被 System 调用，向下被具体渲染器实现 | [`CEGUIRenderer.h:63`](../tools/CEGUI-0.7.1/cegui/include/CEGUIRenderer.h:63) |
| Cocos2DRenderer | `Renderer` 派生类 | 构造时创建默认 [`RenderingRoot`](../tools/CEGUI-0.7.1/cegui/src/RendererModules/Cocos2D/CEGUICocos2DRenderer.cpp:632) 与 viewport target | [`CEGUICocos2DRenderer.h:47`](../tools/CEGUI-0.7.1/cegui/include/RendererModules/Cocos2D/CEGUICocos2DRenderer.h:47), [`CEGUICocos2DRenderer.cpp:608`](../tools/CEGUI-0.7.1/cegui/src/RendererModules/Cocos2D/CEGUICocos2DRenderer.cpp:608) |
| Window | `PropertySet` + `EventSet` | 持有 parent、children、geometry、optional `WindowRenderer`、optional `RenderingSurface` | [`CEGUIWindow.h:166`](../tools/CEGUI-0.7.1/cegui/include/CEGUIWindow.h:166), [`CEGUIWindow.cpp:2219`](../tools/CEGUI-0.7.1/cegui/src/CEGUIWindow.cpp:2219) |
| WindowManager | `Singleton<WindowManager>` + `EventSet` | 依赖 [`WindowFactoryManager`](../tools/CEGUI-0.7.1/cegui/src/CEGUIWindowManager.cpp:133), [`System`](../tools/CEGUI-0.7.1/cegui/src/CEGUIWindowManager.cpp:218), 管理注册表与死池 | [`CEGUIWindowManager.h:63`](../tools/CEGUI-0.7.1/cegui/include/CEGUIWindowManager.h:63), [`CEGUIWindowManager.cpp:115`](../tools/CEGUI-0.7.1/cegui/src/CEGUIWindowManager.cpp:115) |
| WindowFactoryManager | `Singleton<WindowFactoryManager>` | 管理 `WindowFactory`、类型别名、Falagard 映射 | [`CEGUIWindowFactoryManager.h:61`](../tools/CEGUI-0.7.1/cegui/include/CEGUIWindowFactoryManager.h:61), [`CEGUIWindowFactoryManager.h:280`](../tools/CEGUI-0.7.1/cegui/include/CEGUIWindowFactoryManager.h:280), [`CEGUIWindowFactoryManager.h:330`](../tools/CEGUI-0.7.1/cegui/include/CEGUIWindowFactoryManager.h:330) |
| WindowRenderer | 无公共继承 | 被 [`Window`](../tools/CEGUI-0.7.1/cegui/include/CEGUIWindowRenderer.h:202) 友元接入，负责 widget 渲染与 rendering context 重写 | [`CEGUIWindowRenderer.h:50`](../tools/CEGUI-0.7.1/cegui/include/CEGUIWindowRenderer.h:50), [`CEGUIWindowRenderer.h:132`](../tools/CEGUI-0.7.1/cegui/include/CEGUIWindowRenderer.h:132) |
| WindowRendererManager | `Singleton<WindowRendererManager>` | 管理 `WindowRendererFactory` 并创建/销毁 window renderer 实例 | [`CEGUIWindowRendererManager.h:48`](../tools/CEGUI-0.7.1/cegui/include/CEGUIWindowRendererManager.h:48), [`CEGUIWindowRendererManager.h:93`](../tools/CEGUI-0.7.1/cegui/include/CEGUIWindowRendererManager.h:93) |
| RenderingRoot | `RenderingSurface` | 作为 renderer 默认根 surface | [`CEGUIRenderingRoot.h:36`](../tools/CEGUI-0.7.1/cegui/include/CEGUIRenderingRoot.h:36) |
| RenderingWindow | `RenderingSurface` | 持有 owner surface 与 texture target，绘制后将自身几何回挂 owner | [`CEGUIRenderingWindow.h:44`](../tools/CEGUI-0.7.1/cegui/include/CEGUIRenderingWindow.h:44), [`CEGUIRenderingWindow.cpp:216`](../tools/CEGUI-0.7.1/cegui/src/CEGUIRenderingWindow.cpp:216) |
| ResourceProvider | 抽象基类 | 为 XML、脚本、纹理等加载二进制/文件列表 | [`CEGUIResourceProvider.h:48`](../tools/CEGUI-0.7.1/cegui/include/CEGUIResourceProvider.h:48) |
| DefaultResourceProvider | `ResourceProvider` 派生类 | 维护 resourceGroup 到目录的映射 | [`CEGUIDefaultResourceProvider.h:46`](../tools/CEGUI-0.7.1/cegui/include/CEGUIDefaultResourceProvider.h:46), [`CEGUIDefaultResourceProvider.h:69`](../tools/CEGUI-0.7.1/cegui/include/CEGUIDefaultResourceProvider.h:69) |
| NamedXMLResourceManager<T,U> | `ResourceEventSet` 派生模板 | 创建 XML 资源对象后调用 `doPostObjectAdditionAction`，支持 `createAll` | [`CEGUINamedXMLResourceManager.h:94`](../tools/CEGUI-0.7.1/cegui/include/CEGUINamedXMLResourceManager.h:94), [`CEGUINamedXMLResourceManager.h:317`](../tools/CEGUI-0.7.1/cegui/include/CEGUINamedXMLResourceManager.h:317), [`CEGUINamedXMLResourceManager.h:380`](../tools/CEGUI-0.7.1/cegui/include/CEGUINamedXMLResourceManager.h:380) |
| ImagesetManager | `Singleton` + `NamedXMLResourceManager<Imageset, Imageset_xmlHandler>` | 管理 imageset，并在 display size change 时广播到对象 | [`CEGUIImagesetManager.h:57`](../tools/CEGUI-0.7.1/cegui/include/CEGUIImagesetManager.h:57), [`CEGUIImagesetManager.cpp:92`](../tools/CEGUI-0.7.1/cegui/src/CEGUIImagesetManager.cpp:92) |
| FontManager | `Singleton` + `NamedXMLResourceManager<Font, Font_xmlHandler>` | 管理 font，并在首个 font 创建后回写默认字体 | [`CEGUIFontManager.h:58`](../tools/CEGUI-0.7.1/cegui/include/CEGUIFontManager.h:58), [`CEGUIFontManager.cpp:152`](../tools/CEGUI-0.7.1/cegui/src/CEGUIFontManager.cpp:152) |
| SchemeManager | `Singleton` + `NamedXMLResourceManager<Scheme, Scheme_xmlHandler>` | 创建 scheme 后立刻执行 `loadResources` | [`CEGUISchemeManager.h:52`](../tools/CEGUI-0.7.1/cegui/include/CEGUISchemeManager.h:52), [`CEGUISchemeManager.cpp:69`](../tools/CEGUI-0.7.1/cegui/src/CEGUISchemeManager.cpp:69) |
| ScriptModule | 抽象基类 | 提供脚本执行、事件订阅、绑定创建/销毁 | [`CEGUIScriptModule.h:46`](../tools/CEGUI-0.7.1/cegui/include/CEGUIScriptModule.h:46) |
| LuaScriptModule | `ScriptModule` 派生类 | 提供 Lua 文件执行、Lua 事件订阅、绑定创建/销毁 | [`CEGUILua.h:60`](../tools/CEGUI-0.7.1/cegui/include/ScriptingModules/LuaScriptModule/CEGUILua.h:60), [`CEGUILua.h:95`](../tools/CEGUI-0.7.1/cegui/include/ScriptingModules/LuaScriptModule/CEGUILua.h:95), [`CEGUILua.h:496`](../tools/CEGUI-0.7.1/cegui/include/ScriptingModules/LuaScriptModule/CEGUILua.h:496) |
| CEGUIResLoadThread | `core::Thread` 派生类 | 与 [`CCEGUITaskManager`](../tools/CEGUI-0.7.1/cegui/include/CEGUILoadingTaskManager.h:52) 组成异步加载扩展 | [`CEGUIResLoadThread.h:13`](../tools/CEGUI-0.7.1/cegui/include/CEGUIResLoadThread.h:13), [`CEGUIResLoadThread.cpp:33`](../tools/CEGUI-0.7.1/cegui/src/CEGUIResLoadThread.cpp:33) |

---

## 关键数据流表

| 数据流 | 装配/分发路径 | 代码证据 |
|---|---|---|
| 配置 XML → 运行时系统 | [`System::System()`](../tools/CEGUI-0.7.1/cegui/src/CEGUISystem.cpp:227) → [`XMLParser::parseXMLFile()`](../tools/CEGUI-0.7.1/cegui/include/CEGUIXMLParser.h:103) 解析 [`Config_xmlHandler`](../tools/CEGUI-0.7.1/cegui/include/CEGUIConfig_xmlHandler.h:46) → 初始化 logger、resource group、XML parser、image codec、默认资源组、默认 GUI 状态 | [`CEGUISystem.cpp:330`](../tools/CEGUI-0.7.1/cegui/src/CEGUISystem.cpp:330), [`CEGUIConfig_xmlHandler.cpp:236`](../tools/CEGUI-0.7.1/cegui/src/CEGUIConfig_xmlHandler.cpp:236), [`CEGUIConfig_xmlHandler.cpp:306`](../tools/CEGUI-0.7.1/cegui/src/CEGUIConfig_xmlHandler.cpp:306), [`CEGUIConfig_xmlHandler.cpp:365`](../tools/CEGUI-0.7.1/cegui/src/CEGUIConfig_xmlHandler.cpp:365) |
| Scheme XML → 资源注册 | [`NamedXMLResourceManager::create()`](../tools/CEGUI-0.7.1/cegui/include/CEGUINamedXMLResourceManager.h:133) → [`Scheme_xmlHandler`](../tools/CEGUI-0.7.1/cegui/include/CEGUIScheme_xmlHandler.h:38) → [`SchemeManager::doPostObjectAdditionAction()`](../tools/CEGUI-0.7.1/cegui/src/CEGUISchemeManager.cpp:69) → [`Scheme::loadResources()`](../tools/CEGUI-0.7.1/cegui/src/CEGUIScheme.cpp:96) → imageset/font/looknfeel/factory/alias/falagard mapping | [`CEGUINamedXMLResourceManager.h:362`](../tools/CEGUI-0.7.1/cegui/include/CEGUINamedXMLResourceManager.h:362), [`CEGUIScheme.cpp:101`](../tools/CEGUI-0.7.1/cegui/src/CEGUIScheme.cpp:101), [`CEGUIScheme.cpp:271`](../tools/CEGUI-0.7.1/cegui/src/CEGUIScheme.cpp:271), [`CEGUIScheme.cpp:309`](../tools/CEGUI-0.7.1/cegui/src/CEGUIScheme.cpp:309), [`CEGUIScheme.cpp:363`](../tools/CEGUI-0.7.1/cegui/src/CEGUIScheme.cpp:363), [`CEGUIScheme.cpp:397`](../tools/CEGUI-0.7.1/cegui/src/CEGUIScheme.cpp:397) |
| 布局 XML/二进制布局 → 窗口树 | [`WindowManager::loadWindowLayout()`](../tools/CEGUI-0.7.1/cegui/src/CEGUIWindowManager.cpp:311) → [`WindowManager::loadWindowLayoutFromFile()`](../tools/CEGUI-0.7.1/cegui/src/CEGUIWindowManager.cpp:416) → 二进制走 `BinLayoutFileSerializer`，文本走 [`GUILayout_xmlHandler`](../tools/CEGUI-0.7.1/cegui/include/CEGUIGUILayout_xmlHandler.h:47) → 创建 window、设属性、导入子布局、订阅脚本事件 | [`CEGUIWindowManager.cpp:429`](../tools/CEGUI-0.7.1/cegui/src/CEGUIWindowManager.cpp:429), [`CEGUIWindowManager.cpp:444`](../tools/CEGUI-0.7.1/cegui/src/CEGUIWindowManager.cpp:444), [`CEGUIGUILayout_xmlHandler.cpp:292`](../tools/CEGUI-0.7.1/cegui/src/CEGUIGUILayout_xmlHandler.cpp:292), [`CEGUIGUILayout_xmlHandler.cpp:388`](../tools/CEGUI-0.7.1/cegui/src/CEGUIGUILayout_xmlHandler.cpp:388), [`CEGUIGUILayout_xmlHandler.cpp:471`](../tools/CEGUI-0.7.1/cegui/src/CEGUIGUILayout_xmlHandler.cpp:471), [`CEGUIGUILayout_xmlHandler.cpp:514`](../tools/CEGUI-0.7.1/cegui/src/CEGUIGUILayout_xmlHandler.cpp:514) |
| 事件订阅 → 分发 → 回调 | 本地订阅经 [`EventSet::subscribeEvent()`](../tools/CEGUI-0.7.1/cegui/src/CEGUIEventSet.cpp:156)；脚本订阅经 [`EventSet::subscribeScriptedEvent()`](../tools/CEGUI-0.7.1/cegui/src/CEGUIEventSet.cpp:126) 转给 [`ScriptModule::subscribeEvent()`](../tools/CEGUI-0.7.1/cegui/include/CEGUIScriptModule.h:178)；触发时 [`EventSet::fireEvent()`](../tools/CEGUI-0.7.1/cegui/src/CEGUIEventSet.cpp:175) 先发 global，再发 local | [`CEGUIEventSet.cpp:183`](../tools/CEGUI-0.7.1/cegui/src/CEGUIEventSet.cpp:183), [`CEGUIEventSet.cpp:185`](../tools/CEGUI-0.7.1/cegui/src/CEGUIEventSet.cpp:185), [`CEGUIEventSet.cpp:251`](../tools/CEGUI-0.7.1/cegui/src/CEGUIEventSet.cpp:251) |
| 输入注入 → 命中测试 → 窗口回调 | [`System::injectMouseMove()`](../tools/CEGUI-0.7.1/cegui/src/CEGUISystem.cpp:832) / [`System::injectMouseButtonDown()`](../tools/CEGUI-0.7.1/cegui/src/CEGUISystem.cpp:886) / [`System::injectMouseButtonUp()`](../tools/CEGUI-0.7.1/cegui/src/CEGUISystem.cpp:1005) → [`System::getTargetWindow()`](../tools/CEGUI-0.7.1/cegui/src/CEGUISystem.cpp:1463) → [`Window::onMouseMove()`](../tools/CEGUI-0.7.1/cegui/include/CEGUIWindow.h:4305) 等窗口事件 | [`CEGUISystem.cpp:850`](../tools/CEGUI-0.7.1/cegui/src/CEGUISystem.cpp:850), [`CEGUISystem.cpp:950`](../tools/CEGUI-0.7.1/cegui/src/CEGUISystem.cpp:950), [`CEGUISystem.cpp:1042`](../tools/CEGUI-0.7.1/cegui/src/CEGUISystem.cpp:1042) |
| 逻辑窗口 → 渲染 surface → renderer | [`System::renderGUI()`](../tools/CEGUI-0.7.1/cegui/src/CEGUISystem.cpp:483) → [`Window::render()`](../tools/CEGUI-0.7.1/cegui/src/CEGUIWindow.cpp:2117) → [`Window::bufferGeometry()`](../tools/CEGUI-0.7.1/cegui/src/CEGUIWindow.cpp:2199) / [`Window::queueGeometry()`](../tools/CEGUI-0.7.1/cegui/src/CEGUIWindow.cpp:2242) → [`RenderingSurface::draw()`](../tools/CEGUI-0.7.1/cegui/src/CEGUIRenderingSurface.cpp:124) → [`RenderQueue::draw()`](../tools/CEGUI-0.7.1/cegui/src/CEGUIRenderQueue.cpp:36) | [`CEGUIWindow.cpp:2245`](../tools/CEGUI-0.7.1/cegui/src/CEGUIWindow.cpp:2245), [`CEGUIRenderingSurface.cpp:153`](../tools/CEGUI-0.7.1/cegui/src/CEGUIRenderingSurface.cpp:153), [`CEGUIRenderQueue.cpp:41`](../tools/CEGUI-0.7.1/cegui/src/CEGUIRenderQueue.cpp:41) |
| 子 surface / 渲染窗口回灌 | [`Window::getRenderingContext()`](../tools/CEGUI-0.7.1/cegui/src/CEGUIWindow.cpp:5040) 决定命中 surface；[`RenderingWindow::draw()`](../tools/CEGUI-0.7.1/cegui/src/CEGUIRenderingWindow.cpp:216) 在离屏渲染后把 geometry 回加到 owner surface | [`CEGUIWindow.cpp:5077`](../tools/CEGUI-0.7.1/cegui/src/CEGUIWindow.cpp:5077), [`CEGUIRenderingWindow.cpp:231`](../tools/CEGUI-0.7.1/cegui/src/CEGUIRenderingWindow.cpp:231) |
| 显示尺寸变化 → 全局重排 | [`System::notifyDisplaySizeChanged()`](../tools/CEGUI-0.7.1/cegui/src/CEGUISystem.cpp:1831) → renderer、[`ImagesetManager`](../tools/CEGUI-0.7.1/cegui/src/CEGUIImagesetManager.cpp:92)、[`FontManager`](../tools/CEGUI-0.7.1/cegui/src/CEGUIFontManager.cpp:127)、鼠标、activeSheet 逐级更新 | [`CEGUISystem.cpp:1838`](../tools/CEGUI-0.7.1/cegui/src/CEGUISystem.cpp:1838), [`CEGUISystem.cpp:1851`](../tools/CEGUI-0.7.1/cegui/src/CEGUISystem.cpp:1851), [`CEGUISystem.cpp:1862`](../tools/CEGUI-0.7.1/cegui/src/CEGUISystem.cpp:1862) |
| MT3 分叉的异步纹理装配 | [`CEGUIResLoadThread::Run()`](../tools/CEGUI-0.7.1/cegui/src/CEGUIResLoadThread.cpp:33) → [`CCEGUITaskManager::GetTask()`](../tools/CEGUI-0.7.1/cegui/include/CEGUILoadingTaskManager.h:57) → [`ImagesetManager::UpdateTextureState()`](../tools/CEGUI-0.7.1/cegui/src/CEGUIImagesetManager.cpp:116) → [`Renderer::OnFrameEnd()`](../tools/CEGUI-0.7.1/cegui/include/CEGUIRenderer.h:292) | [`CEGUIResLoadThread.cpp:39`](../tools/CEGUI-0.7.1/cegui/src/CEGUIResLoadThread.cpp:39), [`CEGUIImagesetManager.cpp:126`](../tools/CEGUI-0.7.1/cegui/src/CEGUIImagesetManager.cpp:126), [`CEGUICocos2DRenderer.h:78`](../tools/CEGUI-0.7.1/cegui/include/RendererModules/Cocos2D/CEGUICocos2DRenderer.h:78) |

---

## API 事实表 可交叉验证

| API | 事实描述 | 证据 |
|---|---|---|
| `System::create` | `static System& create(Renderer& renderer, ResourceProvider* resourceProvider = 0, XMLParser* xmlParser = 0, ImageCodec* imageCodec = 0, ScriptModule* scriptModule = 0, const String& configFile = "", const String& logFile = "log\\UI.log")` | [`CEGUISystem.h:166`](../tools/CEGUI-0.7.1/cegui/include/CEGUISystem.h:166) |
| `System::destroy` | 销毁全局系统，并在实现里额外销毁 [`CEGUIResLoadThread`](../tools/CEGUI-0.7.1/cegui/src/CEGUIResLoadThread.cpp:54) | [`CEGUISystem.h:175`](../tools/CEGUI-0.7.1/cegui/include/CEGUISystem.h:175), [`CEGUISystem.cpp:2429`](../tools/CEGUI-0.7.1/cegui/src/CEGUISystem.cpp:2429) |
| `System::renderGUI` | 帧级渲染入口；负责 `beginRendering`、sheet render、root draw、`endRendering`、死池清理 | [`CEGUISystem.cpp:483`](../tools/CEGUI-0.7.1/cegui/src/CEGUISystem.cpp:483) |
| `WindowManager::createWindow` | `Window* createWindow(const String& type, const String& name = "")`；会查工厂表、应用 Falagard 映射并写入全局注册表 | [`CEGUIWindowManager.h:148`](../tools/CEGUI-0.7.1/cegui/include/CEGUIWindowManager.h:148), [`CEGUIWindowManager.cpp:133`](../tools/CEGUI-0.7.1/cegui/src/CEGUIWindowManager.cpp:133) |
| `WindowManager::loadWindowLayout` | `Window* loadWindowLayout(const String& filename, const String& name_prefix = "", const String& resourceGroup = "", PropertyCallback* callback = 0, void* userdata = 0)` | [`CEGUIWindowManager.h:252`](../tools/CEGUI-0.7.1/cegui/include/CEGUIWindowManager.h:252) |
| `Window::render` | `bool render()`；递归渲染自己与子树，并在 owner surface 上执行最终 draw | [`CEGUIWindow.h:2772`](../tools/CEGUI-0.7.1/cegui/include/CEGUIWindow.h:2772), [`CEGUIWindow.cpp:2117`](../tools/CEGUI-0.7.1/cegui/src/CEGUIWindow.cpp:2117) |
| `Window::getTargetRenderingSurface` | `RenderingSurface& getTargetRenderingSurface() const`；向父链回溯 surface，否则回退 renderer 默认根 | [`CEGUIWindow.h:1464`](../tools/CEGUI-0.7.1/cegui/include/CEGUIWindow.h:1464), [`CEGUIWindow.cpp:5111`](../tools/CEGUI-0.7.1/cegui/src/CEGUIWindow.cpp:5111) |
| `RenderingSurface::draw` | `virtual void draw()`；activate target、遍历 render queues、fire surface/renderqueue 事件、deactivate target | [`CEGUIRenderingSurface.h:234`](../tools/CEGUI-0.7.1/cegui/include/CEGUIRenderingSurface.h:234), [`CEGUIRenderingSurface.cpp:124`](../tools/CEGUI-0.7.1/cegui/src/CEGUIRenderingSurface.cpp:124) |
| `RenderQueue::draw` | 逐个调用 geometry buffer 的 `draw()` | [`CEGUIRenderQueue.cpp:36`](../tools/CEGUI-0.7.1/cegui/src/CEGUIRenderQueue.cpp:36) |
| `EventSet::subscribeEvent` | `Event::Connection subscribeEvent(const String& name, Event::Subscriber subscriber)`；若事件不存在会自动创建 | [`CEGUIEventSet.h:147`](../tools/CEGUI-0.7.1/cegui/include/CEGUIEventSet.h:147), [`CEGUIEventSet.cpp:156`](../tools/CEGUI-0.7.1/cegui/src/CEGUIEventSet.cpp:156) |
| `EventSet::subscribeScriptedEvent` | 通过当前 [`ScriptModule`](../tools/CEGUI-0.7.1/cegui/src/CEGUIEventSet.cpp:129) 完成脚本订阅，无脚本模块时抛异常 | [`CEGUIEventSet.h:187`](../tools/CEGUI-0.7.1/cegui/include/CEGUIEventSet.h:187), [`CEGUIEventSet.cpp:126`](../tools/CEGUI-0.7.1/cegui/src/CEGUIEventSet.cpp:126) |
| `EventSet::fireEvent` | 先向 global event set 分发，再向本地 event set 分发；异常被记录而不是继续向上抛出 | [`CEGUIEventSet.h:233`](../tools/CEGUI-0.7.1/cegui/include/CEGUIEventSet.h:233), [`CEGUIEventSet.cpp:175`](../tools/CEGUI-0.7.1/cegui/src/CEGUIEventSet.cpp:175) |
| `XMLParser::parseXMLFile` | `virtual void parseXMLFile(XMLHandler& handler, const String& filename, const String& schemaName, const String& resourceGroup) = 0` | [`CEGUIXMLParser.h:103`](../tools/CEGUI-0.7.1/cegui/include/CEGUIXMLParser.h:103) |
| `ScriptModule::executeScriptFile` | `virtual void executeScriptFile(const String& filename, const String& resourceGroup = "") = 0` | [`CEGUIScriptModule.h:79`](../tools/CEGUI-0.7.1/cegui/include/CEGUIScriptModule.h:79) |
| `ScriptModule::createBindings` 与 `destroyBindings` | 系统初始化与销毁期间调用的绑定生命周期钩子 | [`CEGUIScriptModule.h:136`](../tools/CEGUI-0.7.1/cegui/include/CEGUIScriptModule.h:136), [`CEGUIScriptModule.h:148`](../tools/CEGUI-0.7.1/cegui/include/CEGUIScriptModule.h:148), [`CEGUISystem.cpp:396`](../tools/CEGUI-0.7.1/cegui/src/CEGUISystem.cpp:396), [`CEGUISystem.cpp:453`](../tools/CEGUI-0.7.1/cegui/src/CEGUISystem.cpp:453) |
| `ResourceProvider::loadRawDataContainer` | 抽象二进制加载入口；具体实现由 provider 决定 | [`CEGUIResourceProvider.h:99`](../tools/CEGUI-0.7.1/cegui/include/CEGUIResourceProvider.h:99) |
| `DefaultResourceProvider::setResourceGroupDirectory` | 维护资源组到目录映射，是配置阶段目录装配的基础 | [`CEGUIDefaultResourceProvider.h:69`](../tools/CEGUI-0.7.1/cegui/include/CEGUIDefaultResourceProvider.h:69), [`CEGUIConfig_xmlHandler.cpp:253`](../tools/CEGUI-0.7.1/cegui/src/CEGUIConfig_xmlHandler.cpp:253) |
| `NamedXMLResourceManager::createAll` | 通过 [`ResourceProvider::getResourceGroupFileNames()`](../tools/CEGUI-0.7.1/cegui/include/CEGUIResourceProvider.h:138) 批量枚举并创建 XML 资源 | [`CEGUINamedXMLResourceManager.h:380`](../tools/CEGUI-0.7.1/cegui/include/CEGUINamedXMLResourceManager.h:380) |
| `SchemeManager::doPostObjectAdditionAction` | 新 scheme 被加入管理器后立刻触发 [`Scheme::loadResources()`](../tools/CEGUI-0.7.1/cegui/src/CEGUIScheme.cpp:96) | [`CEGUISchemeManager.cpp:69`](../tools/CEGUI-0.7.1/cegui/src/CEGUISchemeManager.cpp:69) |
| `Cocos2DRenderer::bootstrapSystem` | 签名为 `static Cocos2DRenderer& bootstrapSystem(cocos2d::CCLayer* parent, const char* logFile)`，但实现内未直接创建 [`System`](../tools/CEGUI-0.7.1/cegui/src/RendererModules/Cocos2D/CEGUICocos2DRenderer.cpp:292) | [`CEGUICocos2DRenderer.h:55`](../tools/CEGUI-0.7.1/cegui/include/RendererModules/Cocos2D/CEGUICocos2DRenderer.h:55), [`CEGUICocos2DRenderer.cpp:292`](../tools/CEGUI-0.7.1/cegui/src/RendererModules/Cocos2D/CEGUICocos2DRenderer.cpp:292) |
| `OgreRenderer::bootstrapSystem` | 会创建 renderer、resource provider、image codec，并调用 [`System::create()`](../tools/CEGUI-0.7.1/cegui/src/CEGUISystem.cpp:2419) | [`CEGUIOgreRenderer.cpp:69`](../tools/CEGUI-0.7.1/cegui/src/RendererModules/Ogre/CEGUIOgreRenderer.cpp:69) |

---

## 待后续文档修复关注点

1. **Cocos2D bootstrap 语义与 Ogre/Irrlicht 不一致**
   - [`Cocos2DRenderer::bootstrapSystem()`](../tools/CEGUI-0.7.1/cegui/src/RendererModules/Cocos2D/CEGUICocos2DRenderer.cpp:292) 未调用 [`System::create()`](../tools/CEGUI-0.7.1/cegui/src/CEGUISystem.cpp:2419)，但 [`Cocos2DRenderer::destroySystem()`](../tools/CEGUI-0.7.1/cegui/src/RendererModules/Cocos2D/CEGUICocos2DRenderer.cpp:305) 假定系统已经存在。后续文档必须把它描述成“渲染器创建入口”而非与 OGRE 完全同义的“一键系统初始化”。

2. **当前仓库中的 CEGUI 0.7.1 已明显带有 MT3 分叉扩展**
   - [`Renderer`](../tools/CEGUI-0.7.1/cegui/include/CEGUIRenderer.h:286) 除标准接口外新增 `ResetRenderTextures`、`MarkRenderTexture`、`isTextureRender`、`ReleaseTexture`、`OnFrameEnd`。
   - [`System`](../tools/CEGUI-0.7.1/cegui/include/CEGUISystem.h:56) 还加入大量业务/平台回调 typedef 与字段。
   - 后续文档不能直接复用上游 0.7.1 叙述。

3. **布局加载并非 XML-only**
   - [`WindowManager::loadWindowLayoutFromFile()`](../tools/CEGUI-0.7.1/cegui/src/CEGUIWindowManager.cpp:429) 先检查 `BinLayout` 魔数；命中后走二进制反序列化，否则才走 [`GUILayout_xmlHandler`](../tools/CEGUI-0.7.1/cegui/src/CEGUIWindowManager.cpp:444)。

4. **布局加载对资源提供器有具体实现假设**
   - [`WindowManager::loadWindowLayoutFromFile()`](../tools/CEGUI-0.7.1/cegui/src/CEGUIWindowManager.cpp:418) 直接把 [`System::getResourceProvider()`](../tools/CEGUI-0.7.1/cegui/src/CEGUIWindowManager.cpp:418) 下转型为 `PFSResourceProvider`，这不是纯抽象 `ResourceProvider` 语义。
   - 文档应明确这是 MT3 工程环境依赖，而不是上游抽象契约。

5. **事件分发层吞异常**
   - [`EventSet::fireEvent()`](../tools/CEGUI-0.7.1/cegui/src/CEGUIEventSet.cpp:175) 捕获异常后仅记录日志，不向调用方传播。
   - 后续文档若描述“事件失败可外抛”将与代码不符。

6. **资源管理器创建 Scheme 后会立即加载资源**
   - [`SchemeManager::doPostObjectAdditionAction()`](../tools/CEGUI-0.7.1/cegui/src/CEGUISchemeManager.cpp:69) 直接调用 [`Scheme::loadResources()`](../tools/CEGUI-0.7.1/cegui/src/CEGUIScheme.cpp:96)。
   - 因此“Scheme 对象创建”和“Scheme 资源生效”在当前实现里不是两个分离阶段。

7. **存在专门的异步资源线程与任务管理器扩展**
   - [`CEGUIResLoadThread`](../tools/CEGUI-0.7.1/cegui/src/CEGUIResLoadThread.cpp:33) + [`CCEGUITaskManager`](../tools/CEGUI-0.7.1/cegui/include/CEGUILoadingTaskManager.h:52) + [`ImagesetManager::UpdateTextureState()`](../tools/CEGUI-0.7.1/cegui/src/CEGUIImagesetManager.cpp:116) 构成 MT3 的异步纹理装配链。
   - 这应作为后续文档重构时的“仓库特化事实”，不能被遗漏。

---

## 可直接复用的事实基线摘要

- 架构中心是 [`System`](../tools/CEGUI-0.7.1/cegui/include/CEGUISystem.h:107)，它统一拥有渲染、资源、XML、脚本、输入与全局事件入口。
- 资源体系不是散点式实现，而是以 [`NamedXMLResourceManager`](../tools/CEGUI-0.7.1/cegui/include/CEGUINamedXMLResourceManager.h:94) 为模板骨架，上接 [`ImagesetManager`](../tools/CEGUI-0.7.1/cegui/include/CEGUIImagesetManager.h:57)、[`FontManager`](../tools/CEGUI-0.7.1/cegui/include/CEGUIFontManager.h:58)、[`SchemeManager`](../tools/CEGUI-0.7.1/cegui/include/CEGUISchemeManager.h:52)。
- 窗口体系由 [`Window`](../tools/CEGUI-0.7.1/cegui/include/CEGUIWindow.h:166) + [`WindowManager`](../tools/CEGUI-0.7.1/cegui/include/CEGUIWindowManager.h:63) + [`WindowFactoryManager`](../tools/CEGUI-0.7.1/cegui/include/CEGUIWindowFactoryManager.h:61) + [`WindowRendererManager`](../tools/CEGUI-0.7.1/cegui/include/CEGUIWindowRendererManager.h:48) 共同组成。
- 渲染提交链路是：[`System::renderGUI()`](../tools/CEGUI-0.7.1/cegui/src/CEGUISystem.cpp:483) → [`Window::render()`](../tools/CEGUI-0.7.1/cegui/src/CEGUIWindow.cpp:2117) → [`Window::queueGeometry()`](../tools/CEGUI-0.7.1/cegui/src/CEGUIWindow.cpp:2242) → [`RenderingSurface::draw()`](../tools/CEGUI-0.7.1/cegui/src/CEGUIRenderingSurface.cpp:124) → [`RenderQueue::draw()`](../tools/CEGUI-0.7.1/cegui/src/CEGUIRenderQueue.cpp:36)。
- XML 到运行时对象的装配至少分三条主链：
  - 配置链：[`Config_xmlHandler`](../tools/CEGUI-0.7.1/cegui/include/CEGUIConfig_xmlHandler.h:46)
  - Scheme 链：[`Scheme_xmlHandler`](../tools/CEGUI-0.7.1/cegui/include/CEGUIScheme_xmlHandler.h:38)
  - Layout 链：[`GUILayout_xmlHandler`](../tools/CEGUI-0.7.1/cegui/include/CEGUIGUILayout_xmlHandler.h:47)
- 当前仓库中的 CEGUI 0.7.1 不是原样上游，而是带有 MT3 的 `PFS`、`BinLayout`、异步纹理、扩展 renderer API 与业务回调的定制分叉。
