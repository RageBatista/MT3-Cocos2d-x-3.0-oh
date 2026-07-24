---
name: cegui-usage
version: 1.4.0
priority: high
category: client
description: |
  MT3客户端CEGUI 0.7.1 UI开发技能。涵盖UI管理、事件处理、资源管理、布局文件、Scheme配置、LookNFeel皮肤、Imageset图片集。
  触发词: CEGUI, UI, 窗口, 事件, 布局, SchemeManager, WindowManager, Falagard, LookNFeel, Imageset, .layout, .scheme, .looknfeel, .imageset, CEGUI_STATIC
dependencies:
  - cpp-development
allowed-tools:
  - Bash
  - Read
  - Edit
recommended-model: claude-3.5-sonnet
estimated-tokens: 12000
---

# CEGUI UI 框架使用指南

**版本**: v1.4.0
**最后更新**: 2026-04-11

---

## 📋 概述

MT3 使用 CEGUI 0.7.1 (CEGUI 0.7.9-r5 分支) 作为 UI 框架，与 Cocos2d-x 2.0 集成。

### 技术栈

```yaml
CEGUI 版本: 0.7.1 (基于 0.7.9-r5)
渲染器: OpenGL 2.0 (Win32) / OpenGL ES (Android/iOS) (CocosCEGUIRenderer)
工具集: v120 (Visual Studio 2013)
编码: Unicode (UTF-8)
```

### 核心模块

| 模块 | 库文件 | 功能 |
|-----|-------|------|
| CEGUIBase | CEGUIBase.lib | 核心框架 |
| CEGUIFalagardWRBase | CEGUIFalagardWRBase.lib | 皮肤渲染 |
| CEGUIExpatParser | CEGUIExpatParser.lib | XML 解析 |
| CEGUITinyXMLParser | CEGUITinyXMLParser.lib | 备用 XML 解析 |
| CEGUISILLYImageCodec | CEGUISILLYImageCodec.lib | 图像编解码 |

---

## 🏗️ 架构集成

### Cocos2d-x 与 CEGUI 集成层

```
┌─────────────────────────────────────────────────────────────┐
│  Lua 脚本层 (UI 控制逻辑)                                    │
│  - CEGUI.Window:setVisible(), setText()                     │
│  - 事件绑定: subscribeEvent()                                │
└─────────────────────────────────────────────────────────────┘
                    ↓ tolua++ 绑定
┌─────────────────────────────────────────────────────────────┐
│  FireClient 业务层 (UI 管理器)                               │
│  - UIManager::getInstance()                                  │
│  - 窗口生命周期管理                                          │
└─────────────────────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────────────────────┐
│  CEGUI 0.7.1 框架                                            │
│  - WindowManager, SchemeManager, ImagesetManager             │
│  - Falagard 皮肤系统                                         │
└─────────────────────────────────────────────────────────────┘
                    ↓ CocosCEGUIRenderer
┌─────────────────────────────────────────────────────────────┐
│  Cocos2d-x 2.0 渲染层                                        │
│  - CCGLProgram, CCTexture2D                                  │
│  - OpenGL 2.0 (Win32) / OpenGL ES (Android/iOS)              │
└─────────────────────────────────────────────────────────────┘
```

---

## 📁 资源文件结构

```
client/resource/res/ui/
├── schemes/                    # 皮肤方案定义
│   ├── taharezlook2.scheme     # 主皮肤方案
│   └── ...
├── looknfeel/                  # 外观定义
│   ├── taharezlook2.looknfeel  # 控件外观
│   └── ...
├── imagesets/                  # 图像集
│   ├── taharezlook2.imageset   # 皮肤图像
│   ├── allnumber.imageset      # 数字图像集
│   └── ...
├── fonts/                      # 字体定义
│   ├── simhei-12.font          # 黑体 12px
│   └── ...
└── layouts/                    # 布局文件
    ├── login.layout            # 登录界面
    ├── main.layout             # 主界面
    └── ...
```

---

## 🔧 核心 API

### 初始化

```cpp
// CocosCEGUIRenderer 初始化
#include "CEGUICocos2dRenderer.h"

bool initCEGUI() {
    // 创建 Cocos2d-x 渲染器
    CEGUI::CocosCEGUIRenderer& renderer =
        CEGUI::CocosCEGUIRenderer::bootstrapSystem();

    // 加载默认资源
    CEGUI::DefaultResourceProvider* rp =
        static_cast<CEGUI::DefaultResourceProvider*>(
            CEGUI::System::getSingleton().getResourceProvider());

    rp->setResourceGroupDirectory("schemes", "res/ui/schemes/");
    rp->setResourceGroupDirectory("imagesets", "res/ui/imagesets/");
    rp->setResourceGroupDirectory("fonts", "res/ui/fonts/");
    rp->setResourceGroupDirectory("layouts", "res/ui/layouts/");
    rp->setResourceGroupDirectory("looknfeel", "res/ui/looknfeel/");

    // 加载皮肤方案
    CEGUI::SchemeManager::getSingleton().create("taharezlook2.scheme");

    return true;
}
```

### 窗口管理

```cpp
// 加载布局
CEGUI::Window* loadLayout(const std::string& layoutFile) {
    CEGUI::WindowManager& wmgr = CEGUI::WindowManager::getSingleton();
    return wmgr.loadWindowLayout(layoutFile);
}

// 设置根窗口
void setRootWindow(CEGUI::Window* root) {
    CEGUI::System::getSingleton().setGUISheet(root);
}

// 查找子窗口
CEGUI::Window* findWindow(const std::string& name) {
    return CEGUI::WindowManager::getSingleton().getWindow(name);
}
```

### 事件处理

```cpp
// C++ 事件订阅
void subscribeButtonClick(CEGUI::Window* button) {
    button->subscribeEvent(
        CEGUI::PushButton::EventClicked,
        CEGUI::Event::Subscriber(&MyHandler::onButtonClicked, this)
    );
}

bool MyHandler::onButtonClicked(const CEGUI::EventArgs& args) {
    // 处理点击事件
    return true;
}
```

---

## 📜 Lua 脚本接口

### 窗口操作

```lua
-- 获取窗口
local window = CEGUI.WindowManager:getSingleton():getWindow("MainFrame")

-- 设置可见性
window:setVisible(true)
window:show()
window:hide()

-- 设置文本
window:setText("Hello World")

-- 设置位置和大小
window:setPosition(CEGUI.UVector2(
    CEGUI.UDim(0.1, 0),  -- x: 10% 相对 + 0 绝对
    CEGUI.UDim(0.1, 0)   -- y: 10% 相对 + 0 绝对
))

window:setSize(CEGUI.UVector2(
    CEGUI.UDim(0.8, 0),  -- width
    CEGUI.UDim(0.8, 0)   -- height
))
```

### 事件绑定

```lua
-- 按钮点击事件
local button = CEGUI.WindowManager:getSingleton():getWindow("LoginButton")
button:subscribeEvent("Clicked", function(args)
    print("Button clicked!")
    -- 处理登录逻辑
    return true
end)

-- 编辑框文本变化
local editbox = CEGUI.WindowManager:getSingleton():getWindow("UsernameEdit")
editbox:subscribeEvent("TextChanged", function(args)
    local text = editbox:getText()
    print("Text changed to: " .. text)
    return true
end)
```

---

## 🎨 布局文件 (.layout)

### 基本结构

```xml
<?xml version="1.0" encoding="UTF-8"?>
<GUILayout>
    <Window Type="DefaultWindow" Name="Root">
        <Property Name="UnifiedAreaRect" Value="{{0,0},{0,0},{1,0},{1,0}}" />

        <!-- 框架窗口 -->
        <Window Type="TaharezLook2/FrameWindow" Name="MainFrame">
            <Property Name="UnifiedAreaRect" Value="{{0.1,0},{0.1,0},{0.9,0},{0.9,0}}" />
            <Property Name="Text" Value="Main Window" />

            <!-- 按钮 -->
            <Window Type="TaharezLook2/Button" Name="OKButton">
                <Property Name="UnifiedAreaRect" Value="{{0.3,0},{0.8,0},{0.7,0},{0.95,0}}" />
                <Property Name="Text" Value="OK" />
            </Window>
        </Window>
    </Window>
</GUILayout>
```

### 常用控件类型

| 类型 | 描述 |
|-----|------|
| `DefaultWindow` | 空白容器 |
| `TaharezLook2/FrameWindow` | 可拖动框架窗口 |
| `TaharezLook2/Button` | 按钮 |
| `TaharezLook2/Editbox` | 单行编辑框 |
| `TaharezLook2/MultiLineEditbox` | 多行编辑框 |
| `TaharezLook2/StaticText` | 静态文本 |
| `TaharezLook2/StaticImage` | 静态图像 |
| `TaharezLook2/Listbox` | 列表框 |
| `TaharezLook2/Combobox` | 下拉框 |
| `TaharezLook2/ProgressBar` | 进度条 |
| `TaharezLook2/Checkbox` | 复选框 |
| `TaharezLook2/RadioButton` | 单选按钮 |
| `TaharezLook2/ScrollablePane` | 可滚动面板 |

---

## ⚠️ 常见问题

### 1. 内存泄漏

```cpp
// ❌ 错误：未正确释放窗口
CEGUI::Window* window = wmgr.createWindow("TaharezLook2/Button", "MyButton");
// 忘记 destroyWindow

// ✅ 正确：使用 destroyWindow 释放
CEGUI::WindowManager::getSingleton().destroyWindow(window);
```

### 2. 中文显示乱码

```xml
<!-- 确保布局文件使用 UTF-8 编码 -->
<?xml version="1.0" encoding="UTF-8"?>

<!-- 确保字体支持中文 -->
<Font Name="SimHei-12" Filename="simhei.ttf" Size="12" Type="FreeType">
    <GlyphRange StartCodepoint="0x4E00" EndCodepoint="0x9FFF" />
</Font>
```

### 3. 事件不响应

```lua
-- ❌ 错误：事件名称错误
button:subscribeEvent("Click", handler)  -- 应该是 "Clicked"

-- ✅ 正确：使用正确的事件名称
button:subscribeEvent("Clicked", handler)
```

### 4. 坐标系统

```
CEGUI 使用 UDim (Unified Dimension) 坐标系统：
- UDim(scale, offset): scale 是相对值 (0-1), offset 是绝对像素值
- 例如: UDim(0.5, 10) = 50% 父窗口宽度 + 10 像素
```

---

## 🔍 调试技巧

### 1. 启用 CEGUI 日志

```cpp
// 设置日志级别
CEGUI::Logger::getSingleton().setLoggingLevel(CEGUI::Standard);
```

### 2. 窗口树调试

```lua
-- 打印窗口层级
function printWindowTree(window, indent)
    indent = indent or ""
    print(indent .. window:getName() .. " [" .. window:getType() .. "]")
    for i = 0, window:getChildCount() - 1 do
        printWindowTree(window:getChildAtIdx(i), indent .. "  ")
    end
end

printWindowTree(CEGUI.System:getSingleton():getGUISheet())
```

### 3. 边界框可视化

```cpp
// 开发模式：显示窗口边界
#ifdef _DEBUG
window->setProperty("FrameEnabled", "true");
#endif
```

---

## 📚 相关文档

- [C++ 开发指南](cpp-development.md)
- [Cocos2d-x 使用指南](cocos2dx-usage.md)
- [tolua++ 绑定开发](tolua-binding.md)
- [CEGUI 构建工作流](../../workflows/cegui-build-workflow.md)
- [CEGUI 错误速查](../../errors/cegui-specific-errors.md)

---

## 📝 更新日志

| 版本 | 日期 | 变更 |
|-----|------|------|
| 1.0.0 | 2026-01-10 | 初始版本 |
