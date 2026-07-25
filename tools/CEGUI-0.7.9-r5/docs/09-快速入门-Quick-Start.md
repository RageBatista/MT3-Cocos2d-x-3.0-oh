# 快速入门（CEGUI 0.7.9-r5）

**版本**: v1.0.0  
**最后更新**: 2026-01-28  
**维护者**: CEGUI 文档团队

---

## 📋 目录

1. [快速开始](#快速开始)
2. [第一个 CEGUI 程序](#第一个-cegui-程序)
3. [基本概念](#基本概念)
4. [常见任务](#常见任务)
5. [示例代码](#示例代码)
6. [下一步](#下一步)

---

## 快速开始

### 前置条件

在开始之前，请确保：

1. **已完成编译**: 按照 [`07-从零构建-From-Scratch-Build.md`](07-从零构建-From-Scratch-Build.md) 完成编译
2. **环境已配置**: 按照 [`04-环境准备-Environment-Setup.md`](04-环境准备-Environment-Setup.md) 配置环境
3. **依赖已部署**: 将 `dependencies/bin/*.dll` 拷贝到 `bin/` 目录

### 5 分钟快速体验

#### 步骤 1: 创建基本窗口

```cpp
#include "CEGUI/CEGUI.h"
#include "CEGUI/RendererModules/OpenGL/CEGUIOpenGLRenderer.h"

void initializeCEGUI() {
    // 初始化渲染器
    CEGUI::OpenGLRenderer& myRenderer = 
        CEGUI::OpenGLRenderer::create();
    
    // 初始化 CEGUI 系统
    CEGUI::System::create(myRenderer);
    
    // 设置默认资源组
    CEGUI::DefaultResourceProvider* rp = 
        static_cast<CEGUI::DefaultResourceProvider*>
        (CEGUI::System::getSingleton().getResourceProvider());
    
    rp->setResourceGroupDirectory("schemes", "../datafiles/schemes/");
    rp->setResourceGroupDirectory("imagesets", "../datafiles/imagesets/");
    rp->setResourceGroupDirectory("fonts", "../datafiles/fonts/");
    rp->setResourceGroupDirectory("layouts", "../datafiles/layouts/");
    rp->setResourceGroupDirectory("looknfeels", "../datafiles/looknfeel/");
    rp->setResourceGroupDirectory("lua_scripts", "../datafiles/lua_scripts/");
    
    // 加载默认字体
    CEGUI::FontManager::getSingleton().createFromFile("DejaVuSans-10.font");
    
    // 设置默认鼠标光标
    CEGUI::SchemeManager::getSingleton().createFromFile("TaharezLook.scheme");
    CEGUI::System::getSingleton().getDefaultGUIContext().getMouseCursor().setDefaultImage("TaharezLook/MouseArrow");
}
```

#### 步骤 2: 创建窗口

```cpp
void createMainWindow() {
    // 获取默认 GUI 上下文
    CEGUI::GUIContext& guiContext = 
        CEGUI::System::getSingleton().getDefaultGUIContext();
    
    // 加载布局文件
    CEGUI::Window* root = 
        CEGUI::WindowManager::getSingleton().loadLayoutFromFile("HelloWorld.layout");
    
    // 设置根窗口
    guiContext.setRootWindow(root);
}
```

#### 步骤 3: 处理输入

```cpp
void injectTimePulse(float elapsed) {
    CEGUI::System::getSingleton().injectTimePulse(elapsed);
}

void injectMousePosition(float x, float y) {
    CEGUI::System::getSingleton().getDefaultGUIContext().injectMousePosition(x, y);
}

void injectMouseButtonDown(CEGUI::MouseButton button) {
    CEGUI::System::getSingleton().getDefaultGUIContext().injectMouseButtonDown(button);
}

void injectMouseButtonUp(CEGUI::MouseButton button) {
    CEGUI::System::getSingleton().getDefaultGUIContext().injectMouseButtonUp(button);
}

void injectKeyDown(CEGUI::Key::Scan key) {
    CEGUI::System::getSingleton().getDefaultGUIContext().injectKeyDown(key);
}

void injectKeyUp(CEGUI::Key::Scan key) {
    CEGUI::System::getSingleton().getDefaultGUIContext().injectKeyUp(key);
}
```

#### 步骤 4: 渲染

```cpp
void renderGUI() {
    // 渲染 CEGUI
    CEGUI::System::getSingleton().renderAllGUIContexts();
}
```

---

## 第一个 CEGUI 程序

### 完整示例

```cpp
#include <GL/glew.h>
#include <GLFW/glfw3.h>
#include "CEGUI/CEGUI.h"
#include "CEGUI/RendererModules/OpenGL/CEGUIOpenGLRenderer.h"

// 全局变量
CEGUI::OpenGLRenderer* g_renderer = nullptr;
CEGUI::Window* g_rootWindow = nullptr;

// 初始化 CEGUI
bool initializeCEGUI() {
    try {
        // 创建渲染器
        g_renderer = &CEGUI::OpenGLRenderer::create();
        
        // 创建系统
        CEGUI::System::create(*g_renderer);
        
        // 设置资源路径
        CEGUI::DefaultResourceProvider* rp = 
            static_cast<CEGUI::DefaultResourceProvider*>
            (CEGUI::System::getSingleton().getResourceProvider());
        
        rp->setResourceGroupDirectory("schemes", "../datafiles/schemes/");
        rp->setResourceGroupDirectory("imagesets", "../datafiles/imagesets/");
        rp->setResourceGroupDirectory("fonts", "../datafiles/fonts/");
        rp->setResourceGroupDirectory("layouts", "../datafiles/layouts/");
        rp->setResourceGroupDirectory("looknfeels", "../datafiles/looknfeel/");
        
        // 加载字体和方案
        CEGUI::FontManager::getSingleton().createFromFile("DejaVuSans-10.font");
        CEGUI::SchemeManager::getSingleton().createFromFile("TaharezLook.scheme");
        
        // 设置鼠标光标
        CEGUI::System::getSingleton().getDefaultGUIContext().getMouseCursor().setDefaultImage("TaharezLook/MouseArrow");
        
        // 创建主窗口
        g_rootWindow = CEGUI::WindowManager::getSingleton().createWindow("DefaultWindow", "Root");
        CEGUI::System::getSingleton().getDefaultGUIContext().setRootWindow(g_rootWindow);
        
        // 添加一个按钮
        CEGUI::Window* button = CEGUI::WindowManager::getSingleton().createWindow("TaharezLook/Button", "QuitButton");
        button->setSize(CEGUI::USize(CEGUI::UDim(0.15f, 0), CEGUI::UDim(0.05f, 0)));
        button->setPosition(CEGUI::UVector2(CEGUI::UDim(0.425f, 0), CEGUI::UDim(0.475f, 0)));
        button->setText("Quit");
        g_rootWindow->addChild(button);
        
        return true;
    }
    catch (const CEGUI::Exception& e) {
        std::cerr << "CEGUI Exception: " << e.what() << std::endl;
        return false;
    }
}

// 清理 CEGUI
void cleanupCEGUI() {
    CEGUI::WindowManager::getSingleton().destroyAllWindows();
    CEGUI::System::destroy();
    CEGUI::OpenGLRenderer::destroy(*g_renderer);
}

// 主函数
int main() {
    // 初始化 GLFW
    if (!glfwInit()) {
        return -1;
    }
    
    // 创建窗口
    GLFWwindow* window = glfwCreateWindow(800, 600, "CEGUI Quick Start", NULL, NULL);
    if (!window) {
        glfwTerminate();
        return -1;
    }
    
    glfwMakeContextCurrent(window);
    
    // 初始化 GLEW
    glewInit();
    
    // 初始化 CEGUI
    if (!initializeCEGUI()) {
        glfwTerminate();
        return -1;
    }
    
    // 主循环
    while (!glfwWindowShouldClose(window)) {
        // 清屏
        glClear(GL_COLOR_BUFFER_BIT);
        
        // 渲染 CEGUI
        CEGUI::System::getSingleton().renderAllGUIContexts();
        
        // 交换缓冲区
        glfwSwapBuffers(window);
        
        // 处理事件
        glfwPollEvents();
    }
    
    // 清理
    cleanupCEGUI();
    glfwTerminate();
    
    return 0;
}
```

---

## 基本概念

### 窗口层次结构

CEGUI 使用树状层次结构来管理窗口：

```
Root Window (根窗口)
├── FrameWindow (框架窗口)
│   ├── Button (按钮)
│   └── Editbox (编辑框)
└── Listbox (列表框)
    └── ListboxItem (列表项)
```

### 资源类型

CEGUI 使用多种资源类型：

- **Scheme (.scheme)**: 定义皮肤和资源集合
- **Layout (.layout)**: 定义窗口布局
- **Imageset (.imageset)**: 定义图像资源
- **Font (.font)**: 定义字体
- **LookNFeel (.looknfeel)**: 定义控件外观和行为

### 事件系统

CEGUI 的事件系统基于订阅/发布模式：

```cpp
// 订阅事件
window->subscribeEvent(
    CEGUI::PushButton::EventClicked,
    CEGUI::Event::Subscriber(&onButtonClicked, this)
);

// 事件处理函数
bool onButtonClicked(const CEGUI::EventArgs& args) {
    // 处理按钮点击
    return true;
}
```

---

## 常见任务

### 创建按钮

```cpp
// 创建按钮
CEGUI::Window* button = CEGUI::WindowManager::getSingleton().createWindow("TaharezLook/Button", "MyButton");
button->setText("Click Me");
button->setSize(CEGUI::USize(CEGUI::UDim(0.2f, 0), CEGUI::UDim(0.05f, 0)));
button->setPosition(CEGUI::UVector2(CEGUI::UDim(0.4f, 0), CEGUI::UDim(0.475f, 0)));

// 添加到父窗口
parentWindow->addChild(button);

// 订阅点击事件
button->subscribeEvent(
    CEGUI::PushButton::EventClicked,
    CEGUI::Event::Subscriber(&onButtonClicked, this)
);
```

### 创建编辑框

```cpp
// 创建编辑框
CEGUI::Window* editbox = CEGUI::WindowManager::getSingleton().createWindow("TaharezLook/Editbox", "MyEditbox");
editbox->setSize(CEGUI::USize(CEGUI::UDim(0.3f, 0), CEGUI::UDim(0.05f, 0)));
editbox->setPosition(CEGUI::UVector2(CEGUI::UDim(0.35f, 0), CEGUI::UDim(0.475f, 0)));
editbox->setText("Enter text here...");

// 添加到父窗口
parentWindow->addChild(editbox);
```

### 创建列表框

```cpp
// 创建列表框
CEGUI::Window* listbox = CEGUI::WindowManager::getSingleton().createWindow("TaharezLook/Listbox", "MyListbox");
listbox->setSize(CEGUI::USize(CEGUI::UDim(0.3f, 0), CEGUI::UDim(0.3f, 0)));
listbox->setPosition(CEGUI::UVector2(CEGUI::UDim(0.35f, 0), CEGUI::UDim(0.35f, 0)));

// 添加列表项
for (int i = 0; i < 10; ++i) {
    CEGUI::ListboxTextItem* item = new CEGUI::ListboxTextItem("Item " + CEGUI::PropertyHelper<int>::toString(i));
    static_cast<CEGUI::Listbox*>(listbox)->addItem(item);
}

// 添加到父窗口
parentWindow->addChild(listbox);
```

### 加载布局文件

```cpp
// 加载布局文件
CEGUI::Window* layout = CEGUI::WindowManager::getSingleton().loadLayoutFromFile("MyLayout.layout");

// 设置为根窗口
CEGUI::System::getSingleton().getDefaultGUIContext().setRootWindow(layout);

// 获取布局中的窗口
CEGUI::Window* button = layout->getChild("MyButton");
```

---

## 示例代码

### 示例 1: 简单按钮

```cpp
// 创建简单按钮
CEGUI::Window* button = CEGUI::WindowManager::getSingleton().createWindow("TaharezLook/Button", "SimpleButton");
button->setText("Hello CEGUI!");
button->setSize(CEGUI::USize(CEGUI::UDim(0.2f, 0), CEGUI::UDim(0.05f, 0)));
button->setPosition(CEGUI::UVector2(CEGUI::UDim(0.4f, 0), CEGUI::UDim(0.475f, 0)));

g_rootWindow->addChild(button);

// 事件处理
button->subscribeEvent(
    CEGUI::PushButton::EventClicked,
    CEGUI::Event::Subscriber([](const CEGUI::EventArgs& args) {
        CEGUI::Window* btn = static_cast<CEGUI::Window*>(static_cast<const CEGUI::WindowEventArgs&>(args).window);
        btn->setText("Clicked!");
        return true;
    })
);
```

### 示例 2: 动态创建窗口

```cpp
// 动态创建窗口
void createDynamicWindow(const CEGUI::String& name, const CEGUI::String& text) {
    CEGUI::FrameWindow* frame = static_cast<CEGUI::FrameWindow*>(
        CEGUI::WindowManager::getSingleton().createWindow("TaharezLook/FrameWindow", name)
    );
    
    frame->setText(text);
    frame->setSize(CEGUI::USize(CEGUI::UDim(0.3f, 0), CEGUI::UDim(0.2f, 0)));
    frame->setPosition(CEGUI::UVector2(CEGUI::UDim(0.35f, 0), CEGUI::UDim(0.4f, 0)));
    frame->setCloseButtonEnabled(true);
    
    g_rootWindow->addChild(frame);
    
    // 订阅关闭事件
    frame->subscribeEvent(
        CEGUI::FrameWindow::EventCloseClicked,
        CEGUI::Event::Subscriber([frame](const CEGUI::EventArgs& args) {
            CEGUI::WindowManager::getSingleton().destroyWindow(frame);
            return true;
        })
    );
}
```

### 示例 3: 使用 Lua 脚本

```lua
-- Lua 脚本示例
function onButtonClick(args)
    local button = CEGUI.toWindow(args.window)
    button:setText("Clicked from Lua!")
    return true
end

-- 创建按钮
local button = CEGUI.WindowManager:getSingleton():createWindow("TaharezLook/Button", "LuaButton")
button:setText("Click Me (Lua)")
button:setSize(CEGUI.USize(CEGUI.UDim(0.2, 0), CEGUI.UDim(0.05, 0)))
button:setPosition(CEGUI.UVector2(CEGUI.UDim(0.4, 0), CEGUI.UDim(0.5, 0)))

-- 订阅事件
button:subscribeEvent("Clicked", onButtonClick)

-- 添加到根窗口
CEGUI.System:getSingleton():getDefaultGUIContext():getRootWindow():addChild(button)
```

---

## 下一步

### 学习路径

1. **阅读核心概念**: [`10-核心概念-Core-Concepts.md`](10-核心概念-Core-Concepts.md)
2. **了解渲染器集成**: [`11-Cocos2DRenderer集成-Cocos2DRenderer-Integration.md`](11-Cocos2DRenderer集成-Cocos2DRenderer-Integration.md)
3. **查看示例代码**: `Samples/` 目录下的示例项目
4. **阅读 API 文档**: [`api/00-API参考索引.md`](api/00-API参考索引.md)

### 进阶主题

- **Falagard 皮肤系统**: 自定义控件外观
- **XML 布局**: 使用 XML 定义界面
- **动画系统**: 创建控件动画
- **多线程**: 在多线程环境中使用 CEGUI
- **性能优化**: 优化 GUI 渲染性能

### 获取帮助

- **文档索引**: [`01-文档索引-Documentation-Index.md`](01-文档索引-Documentation-Index.md)
- **常见问题**: [`07-从零构建-From-Scratch-Build.md`](07-从零构建-From-Scratch-Build.md) 中的常见问题章节
- **API 参考**: [`api/00-API参考索引.md`](api/00-API参考索引.md)

---

## 版本历史

| 版本 | 日期 | 变更类型 | 变更说明 | 作者 |
| --- | --- | --- | --- | --- |
| v1.0.0 | 2026-01-28 | 初始 | 初始版本发布 | CEGUI 文档团队 |

---

**快速入门结束**
