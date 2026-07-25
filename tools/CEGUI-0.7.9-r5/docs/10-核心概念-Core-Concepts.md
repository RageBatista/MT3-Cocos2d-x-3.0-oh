# 核心概念（CEGUI 0.7.9-r5）

**版本**: v1.0.0  
**最后更新**: 2026-01-28  
**维护者**: CEGUI 文档团队

---

## 📋 目录

1. [架构概述](#架构概述)
2. [窗口系统](#窗口系统)
3. [事件系统](#事件系统)
4. [渲染系统](#渲染系统)
5. [资源管理](#资源管理)
6. [输入处理](#输入处理)
7. [Falagard 皮肤系统](#falagard-皮肤系统)
8. [脚本系统](#脚本系统)

---

## 架构概述

### 核心组件

CEGUI 由以下核心组件组成：

```
CEGUI System (核心系统)
├── Renderer (渲染器)
│   ├── OpenGLRenderer
│   ├── Direct3D9Renderer
│   └── Cocos2DRenderer
├── WindowManager (窗口管理器)
├── ResourceProvider (资源提供者)
├── ImageCodec (图像编解码器)
├── XMLParser (XML 解析器)
└── ScriptModule (脚本模块)
```

### 初始化流程

```cpp
// 1. 创建渲染器
CEGUI::Renderer& renderer = CEGUI::OpenGLRenderer::create();

// 2. 创建系统
CEGUI::System::create(renderer);

// 3. 设置资源提供者
CEGUI::DefaultResourceProvider* rp = 
    static_cast<CEGUI::DefaultResourceProvider*>(
        CEGUI::System::getSingleton().getResourceProvider()
    );

// 4. 配置资源路径
rp->setResourceGroupDirectory("schemes", "path/to/schemes/");
rp->setResourceGroupDirectory("imagesets", "path/to/imagesets/");
rp->setResourceGroupDirectory("fonts", "path/to/fonts/");
rp->setResourceGroupDirectory("layouts", "path/to/layouts/");
rp->setResourceGroupDirectory("looknfeels", "path/to/looknfeel/");

// 5. 加载资源
CEGUI::FontManager::getSingleton().createFromFile("DejaVuSans-10.font");
CEGUI::SchemeManager::getSingleton().createFromFile("TaharezLook.scheme");

// 6. 创建根窗口
CEGUI::Window* root = CEGUI::WindowManager::getSingleton().createWindow("DefaultWindow", "Root");
CEGUI::System::getSingleton().getDefaultGUIContext().setRootWindow(root);
```

---

## 窗口系统

### 窗口层次结构

CEGUI 使用树状层次结构管理窗口：

```
Root Window (根窗口)
├── FrameWindow (框架窗口)
│   ├── Button (按钮)
│   └── Editbox (编辑框)
└── Listbox (列表框)
    └── ListboxItem (列表项)
```

### 窗口类型

#### 基础窗口 (Window)

所有窗口的基类，提供基本功能：

```cpp
// 创建基础窗口
CEGUI::Window* window = CEGUI::WindowManager::getSingleton().createWindow("DefaultWindow", "MyWindow");

// 设置属性
window->setText("Hello World");
window->setSize(CEGUI::USize(CEGUI::UDim(0.5f, 0), CEGUI::UDim(0.5f, 0)));
window->setPosition(CEGUI::UVector2(CEGUI::UDim(0.25f, 0), CEGUI::UDim(0.25f, 0)));
window->setVisible(true);
window->setEnabled(true);
```

#### 框架窗口 (FrameWindow)

带有标题栏和关闭按钮的窗口：

```cpp
// 创建框架窗口
CEGUI::FrameWindow* frame = static_cast<CEGUI::FrameWindow*>(
    CEGUI::WindowManager::getSingleton().createWindow("TaharezLook/FrameWindow", "MyFrame")
);

// 设置属性
frame->setText("Frame Window");
frame->setSize(CEGUI::USize(CEGUI::UDim(0.4f, 0), CEGUI::UDim(0.3f, 0)));
frame->setPosition(CEGUI::UVector2(CEGUI::UDim(0.3f, 0), CEGUI::UDim(0.35f, 0)));
frame->setCloseButtonEnabled(true);
frame->setDragMovingEnabled(true);
frame->setSizingEnabled(true);
```

#### 按钮 (PushButton)

可点击的按钮控件：

```cpp
// 创建按钮
CEGUI::PushButton* button = static_cast<CEGUI::PushButton*>(
    CEGUI::WindowManager::getSingleton().createWindow("TaharezLook/Button", "MyButton")
);

// 设置属性
button->setText("Click Me");
button->setSize(CEGUI::USize(CEGUI::UDim(0.15f, 0), CEGUI::UDim(0.05f, 0)));
button->setPosition(CEGUI::UVector2(CEGUI::UDim(0.425f, 0), CEGUI::UDim(0.475f, 0)));

// 订阅事件
button->subscribeEvent(
    CEGUI::PushButton::EventClicked,
    CEGUI::Event::Subscriber(&onButtonClicked, this)
);
```

### 窗口坐标系统

CEGUI 使用两种坐标系统：

#### 绝对坐标 (Absolute)

以像素为单位的固定坐标：

```cpp
// 使用绝对坐标
window->setPosition(CEGUI::UVector2(
    CEGUI::UDim(0, 100),  // x: 100 像素
    CEGUI::UDim(0, 50)    // y: 50 像素
));

window->setSize(CEGUI::USize(
    CEGUI::UDim(0, 200),  // width: 200 像素
    CEGUI::UDim(0, 100)   // height: 100 像素
));
```

#### 相对坐标 (Relative)

相对于父窗口的比例坐标：

```cpp
// 使用相对坐标
window->setPosition(CEGUI::UVector2(
    CEGUI::UDim(0.5f, 0),  // x: 父窗口宽度的 50%
    CEGUI::UDim(0.5f, 0)   // y: 父窗口高度的 50%
));

window->setSize(CEGUI::USize(
    CEGUI::UDim(0.5f, 0),  // width: 父窗口宽度的 50%
    CEGUI::UDim(0.5f, 0)   // height: 父窗口高度的 50%
));
```

#### 混合坐标

结合绝对和相对坐标：

```cpp
// 混合坐标
window->setPosition(CEGUI::UVector2(
    CEGUI::UDim(0.5f, -100),  // x: 父窗口宽度的 50% 减去 100 像素
    CEGUI::UDim(0.5f, -50)    // y: 父窗口高度的 50% 减去 50 像素
));

window->setSize(CEGUI::USize(
    CEGUI::UDim(0.5f, 100),   // width: 父窗口宽度的 50% 加上 100 像素
    CEGUI::UDim(0.5f, 50)     // height: 父窗口高度的 50% 加上 50 像素
));
```

### 窗口属性

#### 通用属性

```cpp
// 设置文本
window->setText("Window Text");

// 设置大小
window->setSize(CEGUI::USize(CEGUI::UDim(0.5f, 0), CEGUI::UDim(0.5f, 0)));

// 设置位置
window->setPosition(CEGUI::UVector2(CEGUI::UDim(0.25f, 0), CEGUI::UDim(0.25f, 0)));

// 设置可见性
window->setVisible(true);

// 设置启用状态
window->setEnabled(true);

// 设置透明度
window->setAlpha(0.8f);

// 设置 Z 顺序
window->setZOrderingEnabled(true);
```

#### 特定控件属性

```cpp
// 按钮
button->setText("Button Text");
button->setHoverText("Hover Text");
button->setPushedText("Pushed Text");

// 编辑框
editbox->setText("Initial Text");
editbox->setMaxTextLength(100);
editbox->setReadOnly(false);
editbox->setMaskText('*');  // 密码模式

// 列表框
listbox->setMultiselectEnabled(true);
listbox->setSortingEnabled(true);
listbox->setShowVertScrollbar(true);
```

---

## 事件系统

### 事件类型

CEGUI 提供多种事件类型：

#### 鼠标事件

```cpp
// 鼠标移动
CEGUI::Window::EventMouseEnters
CEGUI::Window::EventMouseLeaves
CEGUI::Window::EventMouseMove

// 鼠标点击
CEGUI::PushButton::EventClicked
CEGUI::Window::EventMouseButtonDown
CEGUI::Window::EventMouseButtonUp
CEGUI::Window::EventMouseDoubleClick

// 鼠标滚轮
CEGUI::Window::EventMouseWheel
```

#### 键盘事件

```cpp
// 键盘按键
CEGUI::Window::EventKeyDown
CEGUI::Window::EventKeyUp
CEGUI::Window::EventCharacterKey

// 编辑框事件
CEGUI::Editbox::EventTextAccepted
CEGUI::Editbox::EventTextChanged
```

#### 窗口事件

```cpp
// 窗口生命周期
CEGUI::Window::EventActivated
CEGUI::Window::EventDeactivated
CEGUI::Window::EventShown
CEGUI::Window::EventHidden

// 窗口大小和位置
CEGUI::Window::EventSized
CEGUI::Window::EventMoved

// 框架窗口事件
CEGUI::FrameWindow::EventCloseClicked
CEGUI::FrameWindow::EventDragStarted
CEGUI::FrameWindow::EventDragEnded
```

### 事件订阅

#### 订阅事件

```cpp
// 方法 1: 使用成员函数
window->subscribeEvent(
    CEGUI::PushButton::EventClicked,
    CEGUI::Event::Subscriber(&MyClass::onButtonClicked, this)
);

// 方法 2: 使用静态函数
window->subscribeEvent(
    CEGUI::PushButton::EventClicked,
    CEGUI::Event::Subscriber(onButtonClickedStatic)
);

// 方法 3: 使用 lambda (C++11)
window->subscribeEvent(
    CEGUI::PushButton::EventClicked,
    CEGUI::Event::Subscriber([](const CEGUI::EventArgs& args) {
        // 处理事件
        return true;
    })
);
```

#### 事件处理函数

```cpp
// 成员函数
bool MyClass::onButtonClicked(const CEGUI::EventArgs& args) {
    const CEGUI::WindowEventArgs& windowArgs = static_cast<const CEGUI::WindowEventArgs&>(args);
    CEGUI::Window* button = windowArgs.window;
    
    // 处理按钮点击
    button->setText("Clicked!");
    
    return true;  // 返回 true 表示事件已处理
}

// 静态函数
bool onButtonClickedStatic(const CEGUI::EventArgs& args) {
    const CEGUI::WindowEventArgs& windowArgs = static_cast<const CEGUI::WindowEventArgs&>(args);
    CEGUI::Window* button = windowArgs.window;
    
    // 处理按钮点击
    button->setText("Clicked!");
    
    return true;
}
```

### 事件参数

#### 获取事件参数

```cpp
bool onButtonClicked(const CEGUI::EventArgs& args) {
    // 转换为具体的事件参数类型
    const CEGUI::WindowEventArgs& windowArgs = static_cast<const CEGUI::WindowEventArgs&>(args);
    
    // 获取触发事件的窗口
    CEGUI::Window* window = windowArgs.window;
    
    // 获取鼠标位置
    const CEGUI::MouseEventArgs& mouseArgs = static_cast<const CEGUI::MouseEventArgs&>(args);
    CEGUI::Vector2f position = mouseArgs.position;
    
    // 获取键盘按键
    const CEGUI::KeyEventArgs& keyArgs = static_cast<const CEGUI::KeyEventArgs&>(args);
    CEGUI::Key::Scan key = keyArgs.scancode;
    
    return true;
}
```

### 事件传播

CEGUI 的事件传播机制：

```
事件触发
    ↓
目标窗口
    ↓
事件处理
    ↓
    ├─ 返回 true → 事件停止传播
    └─ 返回 false → 事件继续传播到父窗口
```

---

## 渲染系统

### 渲染流程

CEGUI 的渲染流程：

```cpp
// 主渲染循环
void renderGUI() {
    // 1. 注入时间脉冲
    CEGUI::System::getSingleton().injectTimePulse(deltaTime);
    
    // 2. 渲染所有 GUI 上下文
    CEGUI::System::getSingleton().renderAllGUIContexts();
}
```

### 渲染器

#### OpenGL 渲染器

```cpp
// 创建 OpenGL 渲染器
CEGUI::OpenGLRenderer& renderer = CEGUI::OpenGLRenderer::create();

// 设置渲染目标大小
renderer->setDisplaySize(CEGUI::Sizef(800.0f, 600.0f));

// 启用纹理目标
renderer->enableExtraStateSettings(true);
```

#### Direct3D9 渲染器

```cpp
// 创建 Direct3D9 渲染器
LPDIRECT3DDEVICE9 d3dDevice = ...;  // Direct3D 设备
CEGUI::Direct3D9Renderer& renderer = CEGUI::Direct3D9Renderer::create(d3dDevice);

// 设置渲染目标大小
renderer->setDisplaySize(CEGUI::Sizef(800.0f, 600.0f));
```

#### Cocos2D 渲染器

```cpp
// 创建 Cocos2D 渲染器
CEGUI::Cocos2DRenderer& renderer = CEGUI::Cocos2DRenderer::create();

// 设置渲染目标大小
renderer->setDisplaySize(CEGUI::Sizef(800.0f, 600.0f));
```

### 渲染优化

#### 批量渲染

CEGUI 自动批量渲染相同材质的窗口：

```cpp
// 启用批量渲染
renderer->enableExtraStateSettings(true);
```

#### 视锥剔除

CEGUI 自动剔除不可见的窗口：

```cpp
// 设置视口
renderer->setDisplaySize(CEGUI::Sizef(800.0f, 600.0f));
```

---

## 资源管理

### 资源类型

CEGUI 管理多种资源类型：

#### Scheme (.scheme)

定义皮肤和资源集合：

```xml
<?xml version="1.0" ?>
<GUIScheme name="TaharezLook">
    <Imageset filename="TaharezLook.imageset" />
    <LookNFeel filename="TaharezLook.looknfeel" />
    <WindowSet filename="TaharezLook.widgets" />
    <Font filename="Commonwealth-10.font" />
</GUIScheme>
```

#### Layout (.layout)

定义窗口布局：

```xml
<?xml version="1.0" ?>
<GUILayout>
    <Window Type="DefaultWindow" Name="Root">
        <Window Type="TaharezLook/Button" Name="QuitButton">
            <Property Name="Text" Value="Quit" />
            <Property Name="Position" Value="{{0.425,0},{0.475,0}}" />
            <Property Name="Size" Value="{{0.15,0},{0.05,0}}" />
        </Window>
    </Window>
</GUILayout>
```

#### Imageset (.imageset)

定义图像资源：

```xml
<?xml version="1.0" ?>
<Imageset name="TaharezLook" imagefile="TaharezLook.tga" nativeHorzRes="800" nativeVertRes="600">
    <Image name="MouseArrow" xPos="0" yPos="0" width="32" height="32" />
    <Image name="ButtonNormal" xPos="32" yPos="0" width="64" height="32" />
    <Image name="ButtonHover" xPos="96" yPos="0" width="64" height="32" />
</Imageset>
```

#### Font (.font)

定义字体：

```xml
<?xml version="1.0" ?>
<Font name="DejaVuSans-10" filename="DejaVuSans.ttf" size="10" />
```

#### LookNFeel (.looknfeel)

定义控件外观和行为：

```xml
<?xml version="1.0" ?>
<Falagard>
    <WidgetLook name="TaharezLook/Button">
        <PropertyDefinition name="NormalTextColour" initialValue="FFFFFFFF" redrawOnWrite="true" />
        <Property name="VertAlignment" value="CentreAligned" />
        <Property name="HorzAlignment" value="CentreAligned" />
        
        <ImagerySection name="normal">
            <FrameComponent>
                <Area>
                    <Dim type="LeftEdge"><AbsoluteDim value="0" /></Dim>
                    <Dim type="TopEdge"><AbsoluteDim value="0" /></Dim>
                    <Dim type="Width"><UnifiedDim scale="1" type="Width" /></Dim>
                    <Dim type="Height"><UnifiedDim scale="1" type="Height" /></Dim>
                </Area>
                <Image type="LeftEdge" imageset="TaharezLook" image="ButtonLeftNormal" />
                <Image type="RightEdge" imageset="TaharezLook" image="ButtonRightNormal" />
                <Image type="Background" imageset="TaharezLook" image="ButtonMiddleNormal" />
            </FrameComponent>
        </ImagerySection>
        
        <StateImagery name="Normal">
            <Layer>
                <Section section="normal" />
            </Layer>
        </StateImagery>
    </WidgetLook>
</Falagard>
```

### 资源加载

#### 加载 Scheme

```cpp
// 加载 Scheme
CEGUI::SchemeManager::getSingleton().createFromFile("TaharezLook.scheme");

// 卸载 Scheme
CEGUI::SchemeManager::getSingleton().destroy("TaharezLook");
```

#### 加载 Layout

```cpp
// 加载 Layout
CEGUI::Window* layout = CEGUI::WindowManager::getSingleton().loadLayoutFromFile("MyLayout.layout");

// 设置为根窗口
CEGUI::System::getSingleton().getDefaultGUIContext().setRootWindow(layout);
```

#### 加载 Font

```cpp
// 加载 Font
CEGUI::FontManager::getSingleton().createFromFile("DejaVuSans-10.font");

// 设置默认字体
CEGUI::System::getSingleton().getDefaultGUIContext().setDefaultFont(
    CEGUI::FontManager::getSingleton().get("DejaVuSans-10")
);
```

---

## 输入处理

### 鼠标输入

#### 注入鼠标位置

```cpp
// 注入鼠标位置
void injectMousePosition(float x, float y) {
    CEGUI::System::getSingleton().getDefaultGUIContext().injectMousePosition(x, y);
}
```

#### 注入鼠标按钮

```cpp
// 注入鼠标按钮按下
void injectMouseButtonDown(CEGUI::MouseButton button) {
    CEGUI::System::getSingleton().getDefaultGUIContext().injectMouseButtonDown(button);
}

// 注入鼠标按钮释放
void injectMouseButtonUp(CEGUI::MouseButton button) {
    CEGUI::System::getSingleton().getDefaultGUIContext().injectMouseButtonUp(button);
}

// 鼠标按钮枚举
enum MouseButton {
    LeftButton,
    RightButton,
    MiddleButton,
    X1Button,
    X2Button
};
```

#### 注入鼠标滚轮

```cpp
// 注入鼠标滚轮
void injectMouseWheel(float delta) {
    CEGUI::System::getSingleton().getDefaultGUIContext().injectMouseWheelChange(delta);
}
```

### 键盘输入

#### 注入键盘按键

```cpp
// 注入按键按下
void injectKeyDown(CEGUI::Key::Scan key) {
    CEGUI::System::getSingleton().getDefaultGUIContext().injectKeyDown(key);
}

// 注入按键释放
void injectKeyUp(CEGUI::Key::Scan key) {
    CEGUI::System::getSingleton().getDefaultGUIContext().injectKeyUp(key);
}

// 注入字符
void injectChar(CEGUI::utf32 codePoint) {
    CEGUI::System::getSingleton().getDefaultGUIContext().injectChar(codePoint);
}
```

### 时间脉冲

#### 注入时间脉冲

```cpp
// 注入时间脉冲
void injectTimePulse(float elapsed) {
    CEGUI::System::getSingleton().injectTimePulse(elapsed);
}
```

---

## Falagard 皮肤系统

### Falagard 概述

Falagard 是 CEGUI 的皮肤系统，允许完全自定义控件的外观和行为。

### Falagard 结构

```xml
<Falagard>
    <WidgetLook name="WidgetName">
        <PropertyDefinition name="PropertyName" initialValue="Value" />
        <Property name="PropertyName" value="Value" />
        <ImagerySection name="SectionName">
            <FrameComponent>
                <Area>...</Area>
                <Image type="..." imageset="..." image="..." />
            </FrameComponent>
        </ImagerySection>
        <StateImagery name="StateName">
            <Layer>
                <Section section="SectionName" />
            </Layer>
        </StateImagery>
    </WidgetLook>
</Falagard>
```

### 创建自定义控件外观

```xml
<?xml version="1.0" ?>
<Falagard>
    <WidgetLook name="MyLook/Button">
        <!-- 定义属性 -->
        <PropertyDefinition name="NormalTextColour" initialValue="FFFFFFFF" redrawOnWrite="true" />
        
        <!-- 定义图像区域 -->
        <ImagerySection name="normal">
            <FrameComponent>
                <Area>
                    <Dim type="LeftEdge"><AbsoluteDim value="0" /></Dim>
                    <Dim type="TopEdge"><AbsoluteDim value="0" /></Dim>
                    <Dim type="Width"><UnifiedDim scale="1" type="Width" /></Dim>
                    <Dim type="Height"><UnifiedDim scale="1" type="Height" /></Dim>
                </Area>
                <Image type="LeftEdge" imageset="MyImages" image="ButtonLeft" />
                <Image type="RightEdge" imageset="MyImages" image="ButtonRight" />
                <Image type="Background" imageset="MyImages" image="ButtonMiddle" />
            </FrameComponent>
        </ImagerySection>
        
        <!-- 定义状态 -->
        <StateImagery name="Normal">
            <Layer>
                <Section section="normal" />
            </Layer>
        </StateImagery>
    </WidgetLook>
</Falagard>
```

---

## 脚本系统

### Lua 脚本模块

CEGUI 内置 Lua 5.1 脚本支持。

#### 初始化 Lua 脚本模块

```cpp
// 创建 Lua 脚本模块
CEGUI::LuaScriptModule* scriptModule = new CEGUI::LuaScriptModule();

// 设置为默认脚本模块
CEGUI::System::getSingleton().setScriptingModule(scriptModule);
```

#### 从 C++ 调用 Lua

```cpp
// 执行 Lua 脚本文件
CEGUI::System::getSingleton().executeScriptFile("script.lua");

// 执行 Lua 代码
CEGUI::System::getSingleton().executeScript("print('Hello from C++')");
```

#### 从 Lua 调用 C++

```lua
-- Lua 脚本
function onButtonClick(args)
    local button = CEGUI.toWindow(args.window)
    button:setText("Clicked from Lua!")
    return true
end

-- 订阅事件
local button = CEGUI.WindowManager:getSingleton():getWindow("MyButton")
button:subscribeEvent("Clicked", onButtonClick)
```

---

## 版本历史

| 版本 | 日期 | 变更类型 | 变更说明 | 作者 |
| --- | --- | --- | --- | --- |
| v1.0.0 | 2026-01-28 | 初始 | 初始版本发布 | CEGUI 文档团队 |

---

**核心概念结束**
