---
name: cegui
description: MT3 项目中 CEGUI UI 开发技能：编辑布局/皮肤/图片集/字体资源，调整控件层次和属性，连接事件，更新 C++/Lua 集成
---

# CEGUI UI 开发 (MT3)

## 何时使用

- 需要创建或修改 CEGUI UI 布局（`.layout`）
- 需要调整控件样式（`.scheme`, `.looknfeel`）
- 需要处理 UI 事件（C++ 或 Lua）
- 需要集成 CEGUI 与 Nuclear 引擎特效
- 需要优化 UI 渲染性能
- 需要调试 UI 相关问题

## 何时不使用

- 需要创建游戏场景或动画（使用 [cocos2dx](../cocos2dx/SKILL.md) 技能）
- 需要处理 3D 渲染（使用 engine 技能）
- 需要处理网络通信（使用 server 技能）
- 需要处理音频播放（使用 audio 技能）

## 输入要求

- CEGUI 资源文件路径（`.layout`, `.scheme`, `.looknfeel`, `.imageset`, `.font`）
- 控件名称和属性
- 事件处理函数名称
- Nuclear 特效资源（如需要）

## 关键约束

> 详细约束请参考 [公共约束](../../references/common-constraints.md)

- Win32 canonical 使用 `tools/CEGUI-0.7.9-r5`（CEGUI 0.7.9，静态链接 `CEGUI_STATIC`）；`dependencies/cegui`（0.7.1）仅服务历史/未迁移链路，不作 Win32 canonical 运行时
- 保持 toolset v120（VS2013），禁止修改预编译库
- 遵循编码规则：C++/headers UTF-8 with BOM；Lua/MD/XML UTF-8 without BOM
- 静态链接：启用 `CEGUI_STATIC` 宏

## 工作流程

### 1. 定位资源文件

```powershell
# 搜索 CEGUI 资源文件
rg --files -g '*.layout' -g '*.scheme' -g '*.looknfeel' -g '*.imageset' -g '*.font' client
```

### 2. 分析现有代码钩子

```powershell
# 搜索控件名称或 CEGUI 相关代码
rg "CEGUI::|subscribeEvent|getChild" client
```

### 3. 修改布局和样式

- 调整控件层次和属性
- 保持控件名称稳定（避免破坏 Lua/C++ 绑定）
- 验证引用的图片集/字体存在

### 4. 更新事件处理逻辑

- 对齐事件处理函数与重命名后的控件
- 更新 Lua 或 C++ 事件绑定

### 5. 验证资源路径

- 确保资源已打包
- 验证引用路径正确

### 6. 测试和优化

- 测试 UI 功能
- 优化性能（参考 [性能优化指南](../../references/performance-guide.md)）

## 代码示例

### 加载布局文件

```cpp
#include "CEGUI/CEGUI.h"

// 加载布局文件
CEGUI::Window* rootWindow = CEGUI::WindowManager::getSingleton().loadWindowLayout("MyLayout.layout");
CEGUI::System::getSingleton().setGUISheet(rootWindow);
```

### 访问控件

```cpp
// 通过名称获取控件
CEGUI::Window* button = CEGUI::WindowManager::getSingleton().getWindow("MyWindow/MyButton");
button->setText("Click Me");
button->setProperty("NormalTextColour", "tl:FFFFFFFF tr:FFFFFFFF bl:FFFFFFFF br:FFFFFFFF");
```

### C++ 事件订阅

```cpp
// 订阅按钮点击事件
button->subscribeEvent(CEGUI::PushButton::EventClicked,
    CEGUI::Event::Subscriber(&MyClass::onButtonClicked, this));
```

### Lua 事件订阅

```lua
-- Lua 中订阅事件
local button = CEGUI.WindowManager:getSingleton():getWindow("MyWindow/MyButton")
button:subscribeEvent("Clicked", function(args)
    print("Button clicked!")
end)
```

### 修改控件属性

```cpp
// 设置位置和大小
CEGUI::Window* window = CEGUI::WindowManager::getSingleton().getWindow("MyWindow");
window->setPosition(CEGUI::UVector2(CEGUI::UDim(0.5f, 0), CEGUI::UDim(0.5f, 0)));
window->setSize(CEGUI::UVector2(CEGUI::UDim(0.3f, 0), CEGUI::UDim(0.2f, 0)));
window->setVisible(true);
```

### 图片集操作（MT3 特定）

```cpp
// 从图片集获取图片
CEGUI::ImagesetManager& imgMgr = CEGUI::ImagesetManager::getSingleton();
const CEGUI::Image& image = imgMgr.get("common").getImage("common_biaoshi_cc");

// 清理纹理状态
CEGUI::ImagesetManager::getSingleton().CleanUPTextureState();
CEGUI::ImagesetManager::getSingleton().UpdateTextureState();
```

### 字体操作（MT3 特定）

```cpp
// 释放所有字体
CEGUI::FontManager::getSingleton().freeAllFont();

// 更新所有字体
CEGUI::FontManager::getSingleton().updateAllFont();

// 设置下划线图片（MT3 自定义功能）
CEGUI::FontManager::getSingleton().SetUnderLineImage(pUnderLineImage);
```

## Nuclear 引擎集成

> 详细集成指南请参考 [Nuclear 集成指南](../../references/nuclear-integration.md)

### 渲染循环协调

```cpp
// 渲染开始前：清理纹理状态
CEGUI::ImagesetManager::getSingleton().CleanUPTextureState();
CEGUI::System::getSingleton().getRenderer()->ResetRenderTextures();

// 渲染 CEGUI
CEGUI::System::getSingleton().renderGUI();

// 渲染完成后：更新纹理状态
CEGUI::ImagesetManager::getSingleton().UpdateTextureState();
```

### Effect-Window 映射

```cpp
// 添加特效到 UI 窗口映射
std::map<Nuclear::IEffect*, CEGUI::Window*> m_mapUIEffect;
m_mapUIEffect[pEffect] = pWindow;

// 移除特效映射
std::map<Nuclear::IEffect*, CEGUI::Window*>::iterator it = m_mapUIEffect.find(pEffect);
if (it != m_mapUIEffect.end()) {
    m_mapUIEffect.erase(it);
}
```

### 输入捕获管理

```cpp
// 释放输入捕获
if (CEGUI::Window::getCaptureWindow()) {
    CEGUI::Window::getCaptureWindow()->releaseInput();
}
```

### 背景模式协调

```cpp
// 设置背景模式（影响 CCDirector）
if (cocos2d::CCDirector::sharedDirector()) {
    cocos2d::CCDirector::sharedDirector()->SetBackgroundMode(s_bIsGameInBackground);
}
```

## 常见错误与解决方案

| 错误 | 原因 | 解决方案 |
|------|------|----------|
| "Failed to load layout file" | 文件未找到或路径错误 | 验证文件存在于 `client/resource`，检查路径匹配 |
| "Unknown widget type" | 控件类型未在 scheme 中注册 | 检查 `.looknfeel` 定义，确保 scheme 已加载 |
| "Event handler not found" | 事件处理函数名不匹配 | 验证函数名完全匹配（区分大小写） |
| "Texture not found" | 图片集文件缺失或纹理未加载 | 验证 `.imageset` 文件存在且有效 |
| "Font not found" | 字体文件未加载或路径错误 | 验证 `.font` 文件存在，加载字体 |
| "Nuclear::IEffect not found" | Nuclear 特效未正确注册 | 验证特效已添加到 `m_mapUIEffect` |
| "getCaptureWindow() returns NULL" | 无窗口捕获输入 | 检查是否有窗口捕获输入 |
| "Texture state inconsistency" | 纹理状态未同步 | 调用 `CleanUPTextureState()` 和 `UpdateTextureState()` |

> 详细错误处理策略请参考 [错误处理指南](../../references/error-handling.md)

## 调试技巧

> 详细调试命令请参考 [调试命令集合](../../references/debugging-commands.md)

### 启用 CEGUI 日志

```cpp
CEGUI::Logger::getSingleton().setLoggingLevel(CEGUI::Informative);
```

### 打印控件树

```cpp
void printWidgetTree(CEGUI::Window* window, int depth = 0) {
    std::string indent(depth * 2, ' ');
    std::cout << indent << window->getName() << " (" << window->getType() << ")" << std::endl;

    for (size_t i = 0; i < window->getChildCount(); ++i) {
        printWidgetTree(window->getChildAtIdx(i), depth + 1);
    }
}
```

### 验证布局文件

- 确保所有标签正确关闭
- 检查控件名称在同一父节点下唯一
- 验证属性名对于控件类型正确

## 性能优化

> 详细优化策略请参考 [性能优化指南](../../references/performance-guide.md)

### UI 渲染优化

- 使用脏矩形技术（只更新变化区域）
- 减少不必要的属性更新
- 批量更新 UI 属性

### 图片集优化

- 合并小图片到大的图片集
- 延迟加载图片集
- 卸载未使用的图片集

### 事件处理优化

- 使用事件委托而非直接订阅
- 避免在事件处理中执行耗时操作

## 注意事项

- 优先使用现有控件名称，重命名会破坏 Lua/C++ 绑定
- CEGUI 0.x 使用 `.imageset`（不是新版 `.texture`），保持属性名与 0.x 一致
- 控件名称区分大小写，必须完全匹配
- 始终在添加子控件前检查父控件存在
- Lua 事件处理函数必须保持存活（不被垃圾回收）
- 坐标系统：UDim 使用相对（0.0-1.0）和绝对（像素）值
- MT3 使用自定义字体功能（如 `SetUnderLineImage`）
- `CleanUPTextureState()` 和 `UpdateTextureState()` 是 MT3 特定方法
- Nuclear 引擎集成需要正确清理特效和窗口
- 渲染循环顺序关键：`CleanUPTextureState` → 渲染 → `UpdateTextureState`

## 资源管理

> 详细资源管理策略请参考 [资源管理指南](../../references/resource-management.md)

### 资源加载顺序

1. 加载方案文件（`.scheme`）
2. 加载图片集（`.imageset`）
3. 加载字体（`.font`）
4. 加载布局文件（`.layout`）

### 资源释放

```cpp
// 释放单个窗口
void releaseWindow(CEGUI::Window* window) {
    if (window) {
        window->removeAllEvents();
        if (window->getParent()) {
            window->getParent()->removeChild(window);
        }
        CEGUI::WindowManager::getSingleton().destroyWindow(window);
    }
}
```

## 相关技能

- [Nuclear 引擎技能](../nuclear/SKILL.md) - Nuclear 引擎集成与开发
- [tolua++ 绑定技能](../tolua/SKILL.md) - C++/Lua 绑定开发
- [公共约束](../../references/common-constraints.md) - 编码规范与代码风格
- [Nuclear 集成指南](../../references/nuclear-integration.md) - Nuclear 引擎集成方法

## 参考资料

- [公共约束](../../references/common-constraints.md)
- [Nuclear 集成指南](../../references/nuclear-integration.md)
- [性能优化指南](../../references/performance-guide.md)
- [资源管理指南](../../references/resource-management.md)
- [错误处理指南](../../references/error-handling.md)
- [调试命令集合](../../references/debugging-commands.md)
- CEGUI 文档：`tools/CEGUI-0.7.9-r5/`（Win32 canonical 运行时树）
- 依赖矩阵：`docs/06-工具链/02-依赖矩阵.md`