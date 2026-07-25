# Cocos2DRenderer 集成（CEGUI 0.7.9-r5）

**版本**: v1.0.0  
**最后更新**: 2026-01-28  
**维护者**: CEGUI 文档团队

---

## 📋 目录

1. [概述](#概述)
2. [编译配置](#编译配置)
3. [初始化流程](#初始化流程)
4. [渲染集成](#渲染集成)
5. [输入处理](#输入处理)
6. [资源管理](#资源管理)
7. [示例代码](#示例代码)
8. [常见问题](#常见问题)

---

## 概述

### 什么是 Cocos2DRenderer

Cocos2DRenderer 是 CEGUI 的一个自定义渲染器，专门为 Cocos2D 引擎设计。它允许在 Cocos2D 应用程序中使用 CEGUI 的 GUI 系统。

### 主要特性

- **无缝集成**: 与 Cocos2D 渲染管线完美集成
- **高性能**: 优化的渲染性能，不影响游戏帧率
- **灵活配置**: 支持多种渲染配置选项
- **完整功能**: 支持 CEGUI 的所有核心功能

### 应用场景

- **游戏 UI**: 游戏主菜单、设置界面、HUD 等
- **编辑器工具**: Cocos2D 编辑器的 GUI 界面
- **可视化应用**: 数据可视化、监控面板等

---

## 编译配置

### 编译状态

| 配置 | 输出文件 | 大小 | 状态 |
|------|----------|------|------|
| Release | `CEGUICocos2DRenderer.lib` | 2.1 MB | ✅ 成功 |
| Debug | `CEGUICocos2DRenderer_d.lib` | 2.8 MB | ✅ 成功 |

**输出路径**: `projects/win32/lib/$(Configuration).win32/`

### 关键配置

#### 预处理器宏

在项目属性中添加以下预处理器宏：

```
PUBLISHED_VERSION
HAVE_CONFIG_H
```

#### Include 路径

添加以下 Include 路径：

```
common/ljfm/code/include
cegui/include/ImageCodecModules/Cocos2DImageCodec
```

#### 依赖库

链接以下库：

```
CEGUIBase.lib
```

---

## 初始化流程

### 步骤 1: 包含头文件

```cpp
#include "CEGUI/CEGUI.h"
#include "CEGUI/RendererModules/Cocos2D/CEGUICocos2DRenderer.h"
```

### 步骤 2: 创建渲染器

```cpp
// 创建 Cocos2D 渲染器
CEGUI::Cocos2DRenderer& renderer = CEGUI::Cocos2DRenderer::create();

// 设置渲染目标大小
renderer.setDisplaySize(CEGUI::Sizef(director->getWinSize().width, director->getWinSize().height));
```

### 步骤 3: 初始化 CEGUI 系统

```cpp
// 初始化 CEGUI 系统
CEGUI::System::create(renderer);

// 设置资源提供者
CEGUI::DefaultResourceProvider* rp = 
    static_cast<CEGUI::DefaultResourceProvider*>(
        CEGUI::System::getSingleton().getResourceProvider()
    );
```

### 步骤 4: 配置资源路径

```cpp
// 配置资源路径
rp->setResourceGroupDirectory("schemes", "datafiles/schemes/");
rp->setResourceGroupDirectory("imagesets", "datafiles/imagesets/");
rp->setResourceGroupDirectory("fonts", "datafiles/fonts/");
rp->setResourceGroupDirectory("layouts", "datafiles/layouts/");
rp->setResourceGroupDirectory("looknfeels", "datafiles/looknfeel/");
rp->setResourceGroupDirectory("lua_scripts", "datafiles/lua_scripts/");
```

### 步骤 5: 加载资源

```cpp
// 加载字体
CEGUI::FontManager::getSingleton().createFromFile("DejaVuSans-10.font");

// 加载方案
CEGUI::SchemeManager::getSingleton().createFromFile("TaharezLook.scheme");

// 设置默认字体
CEGUI::System::getSingleton().getDefaultGUIContext().setDefaultFont(
    CEGUI::FontManager::getSingleton().get("DejaVuSans-10")
);

// 设置默认鼠标光标
CEGUI::System::getSingleton().getDefaultGUIContext().getMouseCursor().setDefaultImage("TaharezLook/MouseArrow");
```

### 步骤 6: 创建根窗口

```cpp
// 创建根窗口
CEGUI::Window* root = CEGUI::WindowManager::getSingleton().createWindow("DefaultWindow", "Root");
CEGUI::System::getSingleton().getDefaultGUIContext().setRootWindow(root);
```

---

## 渲染集成

### 在 Cocos2D 场景中渲染

#### 创建 GUI 层

```cpp
class GUILayer : public cocos2d::Layer {
public:
    static cocos2d::Layer* createLayer() {
        auto layer = new GUILayer();
        if (layer && layer->init()) {
            layer->autorelease();
            return layer;
        }
        CC_SAFE_DELETE(layer);
        return nullptr;
    }
    
    virtual void draw(cocos2d::Renderer* renderer, const cocos2d::Mat4& transform, uint32_t flags) override {
        Layer::draw(renderer, transform, flags);
        
        // 渲染 CEGUI
        CEGUI::System::getSingleton().renderAllGUIContexts();
    }
};
```

#### 添加到场景

```cpp
// 在场景中添加 GUI 层
auto guiLayer = GUILayer::createLayer();
this->addChild(guiLayer, 100);  // 添加到最上层
```

### 渲染循环

```cpp
// 在 update 方法中注入时间脉冲
void HelloWorld::update(float delta) {
    // 注入时间脉冲
    CEGUI::System::getSingleton().injectTimePulse(delta);
    
    // 更新 Cocos2D
    Layer::update(delta);
}
```

### 渲染优化

#### 批量渲染

```cpp
// 启用批量渲染
renderer.enableExtraStateSettings(true);
```

#### 视锥剔除

```cpp
// 设置视口
renderer.setDisplaySize(CEGUI::Sizef(width, height));
```

---

## 输入处理

### 鼠标/触摸输入

#### 单点触摸

```cpp
// 触摸开始
bool HelloWorld::onTouchBegan(cocos2d::Touch* touch, cocos2d::Event* event) {
    auto location = touch->getLocation();
    
    // 注入鼠标位置
    CEGUI::System::getSingleton().getDefaultGUIContext().injectMousePosition(location.x, location.y);
    
    // 注入鼠标按钮按下
    CEGUI::System::getSingleton().getDefaultGUIContext().injectMouseButtonDown(CEGUI::LeftButton);
    
    return true;
}

// 触摸移动
void HelloWorld::onTouchMoved(cocos2d::Touch* touch, cocos2d::Event* event) {
    auto location = touch->getLocation();
    
    // 注入鼠标位置
    CEGUI::System::getSingleton().getDefaultGUIContext().injectMousePosition(location.x, location.y);
}

// 触摸结束
void HelloWorld::onTouchEnded(cocos2d::Touch* touch, cocos2d::Event* event) {
    auto location = touch->getLocation();
    
    // 注入鼠标位置
    CEGUI::System::getSingleton().getDefaultGUIContext().injectMousePosition(location.x, location.y);
    
    // 注入鼠标按钮释放
    CEGUI::System::getSingleton().getDefaultGUIContext().injectMouseButtonUp(CEGUI::LeftButton);
}

// 触摸取消
void HelloWorld::onTouchCancelled(cocos2d::Touch* touch, cocos2d::Event* event) {
    auto location = touch->getLocation();
    
    // 注入鼠标位置
    CEGUI::System::getSingleton().getDefaultGUIContext().injectMousePosition(location.x, location.y);
    
    // 注入鼠标按钮释放
    CEGUI::System::getSingleton().getDefaultGUIContext().injectMouseButtonUp(CEGUI::LeftButton);
}
```

#### 注册触摸事件

```cpp
// 创建触摸监听器
auto touchListener = cocos2d::EventListenerTouchOneByOne::create();

touchListener->onTouchBegan = CC_CALLBACK_2(HelloWorld::onTouchBegan, this);
touchListener->onTouchMoved = CC_CALLBACK_2(HelloWorld::onTouchMoved, this);
touchListener->onTouchEnded = CC_CALLBACK_2(HelloWorld::onTouchEnded, this);
touchListener->onTouchCancelled = CC_CALLBACK_2(HelloWorld::onTouchCancelled, this);

touchListener->setSwallowTouches(true);

// 添加触摸监听器
this->getEventDispatcher()->addEventListenerWithFixedPriority(touchListener, 1);
```

### 键盘输入

#### 键盘事件

```cpp
// 按键按下
void HelloWorld::onKeyPressed(cocos2d::EventKeyboard::KeyCode keyCode, cocos2d::Event* event) {
    // 转换为 CEGUI 键码
    CEGUI::Key::Scan ceguiKey = convertToCEGUIKey(keyCode);
    
    // 注入按键按下
    CEGUI::System::getSingleton().getDefaultGUIContext().injectKeyDown(ceguiKey);
}

// 按键释放
void HelloWorld::onKeyReleased(cocos2d::EventKeyboard::KeyCode keyCode, cocos2d::Event* event) {
    // 转换为 CEGUI 键码
    CEGUI::Key::Scan ceguiKey = convertToCEGUIKey(keyCode);
    
    // 注入按键释放
    CEGUI::System::getSingleton().getDefaultGUIContext().injectKeyUp(ceguiKey);
}
```

#### 键码转换

```cpp
CEGUI::Key::Scan convertToCEGUIKey(cocos2d::EventKeyboard::KeyCode keyCode) {
    switch (keyCode) {
        case cocos2d::EventKeyboard::KeyCode::KEY_A:
            return CEGUI::Key::A;
        case cocos2d::EventKeyboard::KeyCode::KEY_B:
            return CEGUI::Key::B;
        case cocos2d::EventKeyboard::KeyCode::KEY_C:
            return CEGUI::Key::C;
        // ... 其他键码
        case cocos2d::EventKeyboard::KeyCode::KEY_ENTER:
            return CEGUI::Key::Return;
        case cocos2d::EventKeyboard::KeyCode::KEY_SPACE:
            return CEGUI::Key::Space;
        case cocos2d::EventKeyboard::KeyCode::KEY_ESCAPE:
            return CEGUI::Key::Escape;
        default:
            return CEGUI::Key::Unknown;
    }
}
```

#### 注册键盘事件

```cpp
// 创建键盘监听器
auto keyboardListener = cocos2d::EventListenerKeyboard::create();

keyboardListener->onKeyPressed = CC_CALLBACK_2(HelloWorld::onKeyPressed, this);
keyboardListener->onKeyReleased = CC_CALLBACK_2(HelloWorld::onKeyReleased, this);

// 添加键盘监听器
this->getEventDispatcher()->addEventListenerWithFixedPriority(keyboardListener, 1);
```

---

## 资源管理

### 资源加载

#### 加载 Scheme

```cpp
// 加载 Scheme
CEGUI::SchemeManager::getSingleton().createFromFile("TaharezLook.scheme");
```

#### 加载 Layout

```cpp
// 加载 Layout
CEGUI::Window* layout = CEGUI::WindowManager::getSingleton().loadLayoutFromFile("MyLayout.layout");

// 添加到根窗口
CEGUI::System::getSingleton().getDefaultGUIContext().getRootWindow()->addChild(layout);
```

#### 加载 Font

```cpp
// 加载 Font
CEGUI::FontManager::getSingleton().createFromFile("DejaVuSans-10.font");
```

### 资源路径配置

#### 使用 Cocos2D 资源路径

```cpp
// 获取 Cocos2D 资源路径
std::string getCEGUIResourcePath(const std::string& filename) {
    auto fullPath = cocos2d::FileUtils::getInstance()->fullPathForFilename(filename);
    return cocos2d::FileUtils::getInstance()->fullPathFromRelativeFile(filename, fullPath);
}

// 配置资源路径
CEGUI::DefaultResourceProvider* rp = 
    static_cast<CEGUI::DefaultResourceProvider*>(
        CEGUI::System::getSingleton().getResourceProvider()
    );

rp->setResourceGroupDirectory("schemes", getCEGUIResourcePath("datafiles/schemes/"));
rp->setResourceGroupDirectory("imagesets", getCEGUIResourcePath("datafiles/imagesets/"));
rp->setResourceGroupDirectory("fonts", getCEGUIResourcePath("datafiles/fonts/"));
rp->setResourceGroupDirectory("layouts", getCEGUIResourcePath("datafiles/layouts/"));
rp->setResourceGroupDirectory("looknfeels", getCEGUIResourcePath("datafiles/looknfeel/"));
```

---

## 示例代码

### 完整示例：HelloWorld

```cpp
#include "cocos2d.h"
#include "CEGUI/CEGUI.h"
#include "CEGUI/RendererModules/Cocos2D/CEGUICocos2DRenderer.h"

USING_NS_CC;

class HelloWorld : public Layer {
private:
    CEGUI::Cocos2DRenderer* renderer;
    
public:
    static Scene* createScene() {
        auto scene = Scene::create();
        auto layer = HelloWorld::create();
        scene->addChild(layer);
        return scene;
    }
    
    virtual bool init() override {
        if (!Layer::init()) {
            return false;
        }
        
        // 初始化 CEGUI
        initializeCEGUI();
        
        // 创建 GUI
        createGUI();
        
        // 注册输入事件
        registerInputEvents();
        
        // 启用更新
        scheduleUpdate();
        
        return true;
    }
    
    void initializeCEGUI() {
        try {
            // 创建渲染器
            renderer = &CEGUI::Cocos2DRenderer::create();
            
            // 设置显示大小
            auto director = Director::getInstance();
            renderer->setDisplaySize(CEGUI::Sizef(director->getWinSize().width, director->getWinSize().height));
            
            // 创建系统
            CEGUI::System::create(*renderer);
            
            // 配置资源路径
            CEGUI::DefaultResourceProvider* rp = 
                static_cast<CEGUI::DefaultResourceProvider*>(
                    CEGUI::System::getSingleton().getResourceProvider()
                );
            
            rp->setResourceGroupDirectory("schemes", "datafiles/schemes/");
            rp->setResourceGroupDirectory("imagesets", "datafiles/imagesets/");
            rp->setResourceGroupDirectory("fonts", "datafiles/fonts/");
            rp->setResourceGroupDirectory("layouts", "datafiles/layouts/");
            rp->setResourceGroupDirectory("looknfeels", "datafiles/looknfeel/");
            
            // 加载资源
            CEGUI::FontManager::getSingleton().createFromFile("DejaVuSans-10.font");
            CEGUI::SchemeManager::getSingleton().createFromFile("TaharezLook.scheme");
            
            // 设置默认字体和鼠标光标
            CEGUI::System::getSingleton().getDefaultGUIContext().setDefaultFont(
                CEGUI::FontManager::getSingleton().get("DejaVuSans-10")
            );
            CEGUI::System::getSingleton().getDefaultGUIContext().getMouseCursor().setDefaultImage("TaharezLook/MouseArrow");
            
            // 创建根窗口
            CEGUI::Window* root = CEGUI::WindowManager::getSingleton().createWindow("DefaultWindow", "Root");
            CEGUI::System::getSingleton().getDefaultGUIContext().setRootWindow(root);
            
        } catch (const CEGUI::Exception& e) {
            CCLOG("CEGUI Exception: %s", e.what().c_str());
        }
    }
    
    void createGUI() {
        // 创建按钮
        CEGUI::Window* button = CEGUI::WindowManager::getSingleton().createWindow("TaharezLook/Button", "QuitButton");
        button->setText("Quit");
        button->setSize(CEGUI::USize(CEGUI::UDim(0.15f, 0), CEGUI::UDim(0.05f, 0)));
        button->setPosition(CEGUI::UVector2(CEGUI::UDim(0.425f, 0), CEGUI::UDim(0.475f, 0)));
        
        // 订阅事件
        button->subscribeEvent(
            CEGUI::PushButton::EventClicked,
            CEGUI::Event::Subscriber([](const CEGUI::EventArgs& args) {
                Director::getInstance()->end();
                return true;
            })
        );
        
        // 添加到根窗口
        CEGUI::System::getSingleton().getDefaultGUIContext().getRootWindow()->addChild(button);
    }
    
    void registerInputEvents() {
        // 触摸事件
        auto touchListener = EventListenerTouchOneByOne::create();
        touchListener->onTouchBegan = CC_CALLBACK_2(HelloWorld::onTouchBegan, this);
        touchListener->onTouchMoved = CC_CALLBACK_2(HelloWorld::onTouchMoved, this);
        touchListener->onTouchEnded = CC_CALLBACK_2(HelloWorld::onTouchEnded, this);
        touchListener->onTouchCancelled = CC_CALLBACK_2(HelloWorld::onTouchCancelled, this);
        touchListener->setSwallowTouches(true);
        this->getEventDispatcher()->addEventListenerWithFixedPriority(touchListener, 1);
        
        // 键盘事件
        auto keyboardListener = EventListenerKeyboard::create();
        keyboardListener->onKeyPressed = CC_CALLBACK_2(HelloWorld::onKeyPressed, this);
        keyboardListener->onKeyReleased = CC_CALLBACK_2(HelloWorld::onKeyReleased, this);
        this->getEventDispatcher()->addEventListenerWithFixedPriority(keyboardListener, 1);
    }
    
    void update(float delta) override {
        // 注入时间脉冲
        CEGUI::System::getSingleton().injectTimePulse(delta);
    }
    
    void draw(Renderer* renderer, const Mat4& transform, uint32_t flags) override {
        Layer::draw(renderer, transform, flags);
        
        // 渲染 CEGUI
        CEGUI::System::getSingleton().renderAllGUIContexts();
    }
    
    // 触摸事件处理
    bool onTouchBegan(Touch* touch, Event* event) {
        auto location = touch->getLocation();
        CEGUI::System::getSingleton().getDefaultGUIContext().injectMousePosition(location.x, location.y);
        CEGUI::System::getSingleton().getDefaultGUIContext().injectMouseButtonDown(CEGUI::LeftButton);
        return true;
    }
    
    void onTouchMoved(Touch* touch, Event* event) {
        auto location = touch->getLocation();
        CEGUI::System::getSingleton().getDefaultGUIContext().injectMousePosition(location.x, location.y);
    }
    
    void onTouchEnded(Touch* touch, Event* event) {
        auto location = touch->getLocation();
        CEGUI::System::getSingleton().getDefaultGUIContext().injectMousePosition(location.x, location.y);
        CEGUI::System::getSingleton().getDefaultGUIContext().injectMouseButtonUp(CEGUI::LeftButton);
    }
    
    void onTouchCancelled(Touch* touch, Event* event) {
        auto location = touch->getLocation();
        CEGUI::System::getSingleton().getDefaultGUIContext().injectMousePosition(location.x, location.y);
        CEGUI::System::getSingleton().getDefaultGUIContext().injectMouseButtonUp(CEGUI::LeftButton);
    }
    
    // 键盘事件处理
    void onKeyPressed(EventKeyboard::KeyCode keyCode, Event* event) {
        CEGUI::Key::Scan ceguiKey = convertToCEGUIKey(keyCode);
        CEGUI::System::getSingleton().getDefaultGUIContext().injectKeyDown(ceguiKey);
    }
    
    void onKeyReleased(EventKeyboard::KeyCode keyCode, Event* event) {
        CEGUI::Key::Scan ceguiKey = convertToCEGUIKey(keyCode);
        CEGUI::System::getSingleton().getDefaultGUIContext().injectKeyUp(ceguiKey);
    }
    
    CEGUI::Key::Scan convertToCEGUIKey(EventKeyboard::KeyCode keyCode) {
        switch (keyCode) {
            case EventKeyboard::KeyCode::KEY_A: return CEGUI::Key::A;
            case EventKeyboard::KeyCode::KEY_B: return CEGUI::Key::B;
            case EventKeyboard::KeyCode::KEY_C: return CEGUI::Key::C;
            case EventKeyboard::KeyCode::KEY_ENTER: return CEGUI::Key::Return;
            case EventKeyboard::KeyCode::KEY_SPACE: return CEGUI::Key::Space;
            case EventKeyboard::KeyCode::KEY_ESCAPE: return CEGUI::Key::Escape;
            default: return CEGUI::Key::Unknown;
        }
    }
    
    virtual ~HelloWorld() {
        // 清理 CEGUI
        CEGUI::WindowManager::getSingleton().destroyAllWindows();
        CEGUI::System::destroy();
        CEGUI::Cocos2DRenderer::destroy(*renderer);
    }
};

int main(int argc, char** argv) {
    auto director = Director::getInstance();
    auto glview = GLViewImpl::create("CEGUI Cocos2D Integration");
    director->setOpenGLView(glview);
    
    auto scene = HelloWorld::createScene();
    director->runWithScene(scene);
    
    return Application::getInstance()->run();
}
```

---

## 常见问题

### Q1: 编译错误：找不到头文件

**问题**: 编译时提示找不到 CEGUI 或 Cocos2D 头文件。

**解决方案**:
1. 确保已正确设置 Include 路径
2. 检查预处理器宏是否正确设置
3. 确认 CEGUI 和 Cocos2D 版本兼容

### Q2: 链接错误：找不到 CEGUICocos2DRenderer.lib

**问题**: 链接时提示找不到 CEGUICocos2DRenderer.lib。

**解决方案**:
1. 确认已成功编译 CEGUICocos2DRenderer 项目
2. 检查库文件路径是否正确
3. 确认库文件名称匹配（Debug 版本带 `_d` 后缀）

### Q3: 运行时崩溃：渲染器未初始化

**问题**: 运行时崩溃，提示渲染器未初始化。

**解决方案**:
1. 确保在创建 CEGUI 系统前先创建渲染器
2. 检查渲染器是否正确创建
3. 确认渲染器指针有效

### Q4: 输入事件不响应

**问题**: 点击或触摸 GUI 控件没有响应。

**解决方案**:
1. 确认已正确注册触摸/键盘事件监听器
2. 检查事件监听器优先级设置
3. 确认事件监听器已添加到事件分发器
4. 检查触摸事件是否被其他层拦截

### Q5: GUI 不显示

**问题**: CEGUI GUI 不显示。

**解决方案**:
1. 确认已在 draw 方法中调用 `CEGUI::System::getSingleton().renderAllGUIContexts()`
2. 检查根窗口是否已设置
3. 确认窗口可见性和透明度设置
4. 检查渲染顺序（GUI 层应该在最上层）

### Q6: 性能问题：帧率下降

**问题**: 集成 CEGUI 后游戏帧率明显下降。

**解决方案**:
1. 启用批量渲染：`renderer->enableExtraStateSettings(true)`
2. 减少不必要的窗口和控件
3. 优化资源加载和缓存
4. 使用简单的皮肤和图像

---

## 相关文档

- [`03-项目综述-Project-Overview.md`](03-项目综述-Project-Overview.md): 项目概述
- [`09-快速入门-Quick-Start.md`](09-快速入门-Quick-Start.md): 快速入门指南
- [`10-核心概念-Core-Concepts.md`](10-核心概念-Core-Concepts.md): 核心概念讲解
- [`06-编译构建流程-CEGUI-Build-Workflow.md`](06-编译构建流程-CEGUI-Build-Workflow.md): 编译流程说明
- [`07-从零构建-From-Scratch-Build.md`](07-从零构建-From-Scratch-Build.md): 从零构建指南

---

## 版本历史

| 版本 | 日期 | 变更类型 | 变更说明 | 作者 |
| --- | --- | --- | --- | --- |
| v1.0.0 | 2026-01-28 | 初始 | 初始版本发布 | CEGUI 文档团队 |

---

**Cocos2DRenderer 集成结束**
