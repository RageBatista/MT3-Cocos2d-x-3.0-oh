# CEGUI 0.7.9 API 参考索引

**版本**: 0.7.9-r5
**更新**: 2026-01-02

---

## 使用说明

本文档提供完整的 API 参考索引，支持搜索查找类、函数、文件等。

**搜索方式**: 使用 Ctrl+F 搜索关键字

---

## 核心类索引

### 系统核心

| 类 | 头文件 | 功能描述 |
|---|--------|---------|
| [CEGUISystem](#ceguisystem) | CEGUISystem.h | GUI 系统核心 |
| [CEGUIWindow](#ceguiwindow) | CEGUIWindow.h | 窗口基类 |
| [CEGUIWindowManager](#ceguiwindowmanager) | CEGUIWindowManager.h | 窗口管理器 |
| [CEGUIMouseCursor](#ceguimousecursor) | CEGUIMouseCursor.h | 鼠标光标 |

### 数据结构

| 类 | 头文件 | 功能描述 |
|---|--------|---------|
| [CEGUIVector2](#ceguivector2) | CEGUIVector.h | 2D 向量 |
| [CEGUIRect](#ceguirect) | CEGUIRect.h | 矩形区域 |
| [CEGUISize](#ceguisize) | CEGUISize.h | 尺寸 |
| [CEGUIcolour](#ceguicolour) | CEGUIcolour.h | 颜色 |
| [CEGUIUDim](#ceguiudim) | CEGUIUDim.h | 统一维度 |
| [CEGUIString](#ceguistring) | CEGUIString.h | 字符串封装 |

### 事件系统

| 类 | 头文件 | 功能描述 |
|---|--------|---------|
| [CEGUIEvent](#ceguievent) | CEGUIEvent.h | 事件定义 |
| [CEGUIEventArgs](#ceguieventargs) | CEGUIEventArgs.h | 事件参数 |
| [CEGUIEventSet](#ceguieventset) | CEGUIEventSet.h | 事件集合 |
| [CEGUIBoundSlot](#ceguiboundslot) | CEGUIBoundSlot.h | 事件槽 |

### 资源管理

| 类 | 头文件 | 功能描述 |
|---|--------|---------|
| [CEGUIImage](#ceguiimage) | CEGUIImage.h | 图像 |
| [CEGUIImageset](#ceguiimageset) | CEGUIImageset.h | 图像集 |
| [CEGUIFont](#ceguifont) | CEGUIFont.h | 字体 |
| [CEGUIScheme](#ceguischeme) | CEGUIScheme.h | GUI 方案 |
| [CEGUITexture](#ceguitexture) | CEGUITexture.h | 纹理 |
| [CEGUIResourceProvider](#ceguiresourceprovider) | CEGUIResourceProvider.h | 资源提供者 |

### 渲染系统

| 类 | 头文件 | 功能描述 |
|---|--------|---------|
| [CEGUIRenderer](#ceguirenderer) | CEGUIRenderer.h | 渲染器接口 |
| [CEGUIRenderingContext](#ceguirenderingcontext) | CEGUIRenderingContext.h | 渲染上下文 |
| [CEGUIRenderingSurface](#ceguirenderingsurface) | CEGUIRenderingSurface.h | 渲染表面 |
| [CEGUIRenderEffect](#ceguirendereffect) | CEGUIRenderEffect.h | 渲染效果 |
| [CEGUIGeometryBuffer](#ceguigeometrybuffer) | CEGUIGeometryBuffer.h | 几何缓冲 |

### XML 系统

| 类 | 头文件 | 功能描述 |
|---|--------|---------|
| [CEGUIXMLParser](#ceguixmlparser) | CEGUIXMLParser.h | XML 解析器 |
| [CEGUIXMLHandler](#ceguixmlhandler) | CEGUIXMLHandler.h | XML 处理器 |
| [CEGUIXMLAttributes](#ceguixmlattributes) | CEGUIXMLAttributes.h | XML 属性 |
| [CEGUIXMLSerializer](#ceguixmlserializer) | CEGUIXMLSerializer.h | XML 序列化 |

---

## 核心头文件索引（按字母）

| # | 头文件 | 功能简述 |
|---|--------|---------|
| 1 | CEGUI.h | 主入口文件 |
| 2 | CEGUIAffector.h | 效果器 |
| 3 | CEGUIAnimation.h | 动画系统 |
| 4 | CEGUIAnimationInstance.h | 动画实例 |
| 5 | CEGUIAnimationManager.h | 动画管理器 |
| 6 | CEGUIAnimation_xmlHandler.h | 动画 XML 处理器 |
| 7 | CEGUIBase.h | 基础定义 |
| 8 | CEGUIBasicInterpolators.h | 基础插值器 |
| 9 | CEGUIBasicRenderedStringParser.h | 渲染字符串解析器 |
| 10 | CEGUIBiDiVisualMapping.h | 双向视觉映射 |
| 11 | CEGUIBoundSlot.h | 事件槽绑定 |
| 12 | CEGUICentredRenderedString.h | 居中渲染字符串 |
| 13 | CEGUIChainedXMLHandler.h | 链式 XML 处理器 |
| 14 | CEGUIcolour.h | 颜色类 |
| 15 | CEGUIColourRect.h | 颜色矩形 |
| 16 | CEGUIConfig.h | 配置 |
| 17 | CEGUIConfig_xmlHandler.h | 配置 XML 处理器 |
| 18 | CEGUICoordConverter.h | 坐标转换 |
| 19 | CEGUIDataContainer.h | 数据容器 |
| 20 | CEGUIDefaultLogger.h | 默认日志记录器 |
| 21 | CEGUIDefaultRenderedStringParser.h | 默认字符串解析器 |
| 22 | CEGUIDefaultResourceProvider.h | 默认资源提供者 |
| 23 | CEGUIDynamicModule.h | 动态模块加载 |
| 24 | CEGUIEvent.h | 事件定义 |
| 25 | CEGUIEventArgs.h | 事件参数基类 |
| 26 | CEGUIEventSet.h | 事件集合 |
| 27 | CEGUIExceptions.h | 异常定义 |
| 28 | CEGUIFactoryModule.h | 工厂模块 |
| 29 | CEGUIFont.h | 字体基类 |
| 30 | CEGUIFont_xmlHandler.h | 字体 XML 处理器 |
| 31 | CEGUIFontGlyph.h | 字形 |
| 32 | CEGUIFontManager.h | 字体管理器 |
| 33 | CEGUIFormattedRenderedString.h | 格式化字符串 |
| 34 | CEGUIForwardRefs.h | 前向引用 |
| 35 | CEGUIFreeFunctionSlot.h | 自由函数槽 |
| 36 | CEGUIFreeTypeFont.h | FreeType 字体 |
| 37 | CEGUIFribidiVisualMapping.h | FriBidi 映射 |
| 38 | CEGUIFunctorCopySlot.h | 函数对象槽 |
| 39 | CEGUIFunctorPointerSlot.h | 函数指针槽 |
| 40 | CEGUIFunctorReferenceBinder.h | 引用绑定器 |
| 41 | CEGUIFunctorReferenceSlot.h | 引用槽 |
| 42 | CEGUIGeometryBuffer.h | 几何缓冲 |
| 43 | CEGUIGlobalEventSet.h | 全局事件集 |
| 44 | CEGUIGUILayout_xmlHandler.h | 布局 XML 处理器 |
| 45 | CEGUIImage.h | 图像类 |
| 46 | CEGUIImageCodec.h | 图像编解码器接口 |
| 47 | CEGUIImageset.h | 图像集 |
| 48 | CEGUIImageset_xmlHandler.h | 图像集 XML 处理器 |
| 49 | CEGUIImagesetManager.h | 图像集管理器 |
| 50 | CEGUIInputEvent.h | 输入事件 |
| 51 | CEGUIInterpolator.h | 插值器接口 |
| 52 | CEGUIIteratorBase.h | 迭代器基类 |
| 53 | CEGUIJustifiedRenderedString.h | 两端对齐字符串 |
| 54 | CEGUIKeyFrame.h | 关键帧 |
| 55 | CEGUILeftAlignedRenderedString.h | 左对齐字符串 |
| 56 | CEGUILogger.h | 日志记录器接口 |
| 57 | CEGUIMemberFunctionSlot.h | 成员函数槽 |
| 58 | CEGUIMinibidiVisualMapping.h | Minibidi 映射 |
| 59 | CEGUIMinizipResourceProvider.h | Minizip 资源提供者 |
| 60 | CEGUIMouseCursor.h | 鼠标光标 |
| 61 | CEGUINamedXMLResourceManager.h | 命名 XML 资源管理器 |
| 62 | CEGUIPCRERegexMatcher.h | PCRE 正则匹配器 |
| 63 | CEGUIPixmapFont.h | Pixmap 字体 |
| 64 | CEGUIProperty.h | 属性 |
| 65 | CEGUIPropertyHelper.h | 属性辅助 |
| 66 | CEGUIPropertySet.h | 属性集 |
| 67 | CEGUIRect.h | 矩形 |
| 68 | CEGUIRefCounted.h | 引用计数 |
| 69 | CEGUIRegexMatcher.h | 正则匹配器接口 |
| 70 | CEGUIRenderedString.h | 渲染字符串 |
| 71 | CEGUIRenderedStringComponent.h | 字符串组件 |
| 72 | CEGUIRenderedStringImageComponent.h | 图像组件 |
| 73 | CEGUIRenderedStringParser.h | 字符串解析器接口 |
| 74 | CEGUIRenderedStringTextComponent.h | 文本组件 |
| 75 | CEGUIRenderedStringWidgetComponent.h | 窗口组件 |
| 76 | CEGUIRenderedStringWordWrapper.h | 词包装器 |
| 77 | CEGUIRenderEffect.h | 渲染效果 |
| 78 | CEGUIRenderEffectFactory.h | 效果工厂 |
| 79 | CEGUIRenderEffectManager.h | 效果管理器 |
| 80 | CEGUIRenderer.h | 渲染器接口 |
| 81 | CEGUIRenderingContext.h | 渲染上下文 |
| 82 | CEGUIRenderingRoot.h | 渲染根 |
| 83 | CEGUIRenderingSurface.h | 渲染表面 |
| 84 | CEGUIRenderingWindow.h | 渲染窗口 |
| 85 | CEGUIRenderQueue.h | 渲染队列 |
| 86 | CEGUIRenderTarget.h | 渲染目标 |
| 87 | CEGUIResourceProvider.h | 资源提供者接口 |
| 88 | CEGUIRightAlignedRenderedString.h | 右对齐字符串 |
| 89 | CEGUIScheme.h | GUI 方案 |
| 90 | CEGUIScheme_xmlHandler.h | 方案 XML 处理器 |
| 91 | CEGUISchemeManager.h | 方案管理器 |
| 92 | CEGUIScriptModule.h | 脚本模块接口 |
| 93 | CEGUISingleton.h | 单例模板 |
| 94 | CEGUISize.h | 尺寸 |
| 95 | CEGUISlotFunctorBase.h | 槽函数对象基类 |
| 96 | CEGUIString.h | 字符串类 |
| 97 | CEGUISubscriberSlot.h | 订阅槽 |
| 98 | CEGUISystem.h | 系统核心 |
| 99 | CEGUITexture.h | 纹理 |
| 100 | CEGUITextureTarget.h | 纹理目标 |
| 101 | CEGUITextUtils.h | 文本工具 |
| 102 | CEGUITplWindowFactory.h | 窗口工厂模板 |
| 103 | CEGUITplWindowRendererFactory.h | 渲染器工厂模板 |
| 104 | CEGUITplWRFactoryRegisterer.h | 工厂注册器模板 |
| 105 | CEGUIUDim.h | 统一维度 |
| 106 | CEGUIVector.h | 2D 向量 |
| 107 | CEGUIVersion.h | 版本信息 |
| 108 | CEGUIVertex.h | 顶点 |
| 109 | CEGUIWidgetModule.h | 窗口模块 |
| 110 | CEGUIWindow.h | 窗口基类 |
| 111 | CEGUIWindowFactory.h | 窗口工厂 |
| 112 | CEGUIWindowFactoryManager.h | 窗口工厂管理器 |
| 113 | CEGUIWindowManager.h | 窗口管理器 |
| 114 | CEGUIWindowProperties.h | 窗口属性 |
| 115 | CEGUIWindowRenderer.h | 窗口渲染器 |
| 116 | CEGUIWindowRendererManager.h | 窗口渲染器管理器 |
| 117 | CEGUIWindowRendererModule.h | 渲染器模块 |
| 118 | CEGUIWRFactoryRegisterer.h | 渲染器工厂注册器 |
| 119 | CEGUIXMLAttributes.h | XML 属性 |
| 120 | CEGUIXMLHandler.h | XML 处理器 |
| 121 | CEGUIXMLParser.h | XML 解析器 |
| 122 | CEGUIXMLSerializer.h | XML 序列化器 |

---

## 元素类索引

### 基础控件

| 类 | 功能 |
|---|------|
| CEGUIBase | 基础窗口类 |
| CEGUIPushButton | 按钮 |
| CEGUIRadioButton | 单选按钮 |
| CEGUICheckbox | 复选框 |
| CEGUIEditbox | 单行编辑框 |
| CEGUIMultiLineEditbox | 多行编辑框 |

### 容器控件

| 类 | 功能 |
|---|------|
| CEGUIFrameWindow | 框架窗口 |
| CEGUIScrollablePane | 可滚动面板 |
| CEGUITabControl | 标签页 |
| CEGUIComboDropList | 下拉列表 |
| CEGUIListbox | 列表框 |
| CEGUIMultiColumnList | 多列列表 |

### 进程控件

| 类 | 功能 |
|---|------|
| CEGUISlider | 滑块 |
| CEGUIScrollbar | 滚动条 |
| CEGUIProgressBar | 进度条 |
| CEGUISpinner | 微调器 |

### 菜单控件

| 类 | 功能 |
|---|------|
| CEGUIMenuBar | 菜单栏 |
| CEGUIPopupMenu | 弹出菜单 |
| CEGUIMenuItem | 菜单项 |

### 其他控件

| 类 | 功能 |
|---|------|
| CEGUIThumb | 滑块头 |
| CEGUIDefaultWindow | 默认窗口 |
| CEGUIDragContainer | 拖放容器 |
| CEGUIToolbar | 工具栏 |

---

## 渲染器模块

| 渲染器 | 平台 | 头文件 |
|--------|-----|--------|
| OpenGLRenderer | 跨平台 | RendererModules/OpenGL/CEGUIOpenGLRenderer.h |
| Direct3D9Renderer | Windows | RendererModules/Direct3D9/CEGUIDirect3D9Renderer.h |
| OgreRenderer | Ogre3D | RendererModules/Ogre/CEGUIOgreRenderer.h |

---

## 图像编解码器

| 编解码器 | 格式 | 头文件 |
|---------|-----|--------|
| SILLYImageCodec | PNG, JPG | ImageCodecModules/SILLY/CEGUISILLYImageCodec.h |
| DevILImageCodec | 多格式 | ImageCodecModules/DevIL/CEGUIDevILImageCodec.h |
| FreeImageImageCodec | 多格式 | ImageCodecModules/FreeImage/CEGUIFreeImageImageCodec.h |
| TGAImageCodec | TGA | ImageCodecModules/TGA/CEGUITGAImageCodec.h |

---

## 脚本模块

| 模块 | 语言 | 说明 |
|-----|------|-----|
| LuaScriptModule | Lua 5.1 | 完整支持 |

---

## 函数索引

### 系统管理

```cpp
// 初始化和销毁
CEGUISystem::initialise()
CEGUISystem::destroy()
CEGUISystem::renderGUI()
CEGUISystem::injectTimePacket()
CEGUISystem::injectMouseMove()
CEGUISystem::injectMouseButtons()
CEGUISystem::injectKeyboard()
```

### 系统初始化

```cpp
// 初始化 CEGUI 系统
bool CEGUISystem::initialise(
    const CEGUI::Renderer& renderer,
    const CEGUI::ResourceProvider& resourceProvider,
    const CEGUI::XMLParser& xmlParser,
    const CEGUI::ImageCodec& imageCodec,
    const CEGUI::ScriptModule& scriptModule,
    const CEGUI::String& logFile
);

// 销毁 CEGUI 系统
void CEGUISystem::destroy();
```

### 窗口管理

```cpp
// 创建和销毁
WindowManager::createWindow()
WindowManager::destroyWindow()
WindowManager::getWindow()
WindowManager::loadLayoutFromFile()
WindowManager::saveLayoutToFile()

// 创建窗口
CEGUI::Window* CEGUIWindowManager::createWindow(
    const CEGUI::String& type,
    const CEGUI::String& name = ""
);

// 销毁窗口
void CEGUIWindowManager::destroyWindow(CEGUI::Window* window);

// 获取窗口
CEGUI::Window* CEGUIWindowManager::getWindow(
    const CEGUI::String& name
) const;

// 加载布局
CEGUI::Window* CEGUIWindowManager::loadLayoutFromFile(
    const CEGUI::String& filename,
    const CEGUI::String& name = ""
);
```

### 资源加载

```cpp
// 加载资源
ImagesetManager::createImagesetFromFile()
FontManager::createFontFromFile()
SchemeManager::loadSchemeFromFile()

// 加载图像集
void CEGUIImagesetManager::createImagesetFromFile(
    const CEGUI::String& filename,
    const CEGUI::String& resourceGroup = ""
);

// 加载方案
void CEGUISchemeManager::loadSchemeFromFile(
    const CEGUI::String& filename,
    const CEGUI::String& resourceGroup = ""
);

// 加载字体
void CEGUIFontManager::createFontFromFile(
    const CEGUI::String& filename,
    const CEGUI::String& resourceGroup = ""
);
```

---

**文档版本**: 1.0
**最后更新**: 2026-01-02
