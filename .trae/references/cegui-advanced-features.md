# CEGUI 高级特性文档

> MT3 项目 CEGUI 高级特性文档

## 文档信息

- **文档版本**: v1.0
- **创建日期**: 2026-01-27
- **最后更新**: 2026-01-27
- **维护人员**: 架构师

---

## 一、自定义控件

### 1.1 创建自定义控件

```cpp
// 自定义控件基类
class MyCustomWindow : public CEGUI::Window {
public:
    static const CEGUI::String WidgetTypeName;

    MyCustomWindow(const CEGUI::String& type, const CEGUI::String& name) : CEGUI::Window(type, name) {
        // 初始化
    }

    virtual ~MyCustomWindow() {}

    // 重写绘制方法
    virtual void drawSelf(const CEGUI::RenderingContext& ctx) {
        // 自定义绘制
    }
};

const CEGUI::String MyCustomWindow::WidgetTypeName = "MyCustomWindow";

// 注册自定义控件
CEGUI::WindowFactoryManager::getSingleton().addFactory<CEGUI::TplWindowFactory<MyCustomWindow> >();

// 创建自定义控件
CEGUI::Window* window = CEGUI::WindowManager::getSingleton().createWindow("MyCustomWindow", "MyWindow");
```

### 1.2 自定义控件属性

```cpp
// 添加自定义属性
class MyCustomWindow : public CEGUI::Window {
public:
    static CEGUI::String PropertyCustomValue;

    void setCustomValue(float value) {
        m_customValue = value;
    }

    float getCustomValue() const {
        return m_customValue;
    }

private:
    float m_customValue;
};

// 定义属性类
class CustomValueProperty : public CEGUI::Property {
public:
    CustomValueProperty() : CEGUI::Property("CustomValue", "Custom value property", "float") {}

    CEGUI::String get(const CEGUI::PropertyReceiver* receiver) const {
        return CEGUI::PropertyHelper::floatToString(static_cast<const MyCustomWindow*>(receiver)->getCustomValue());
    }

    void set(CEGUI::PropertyReceiver* receiver, const CEGUI::String& value) {
        static_cast<MyCustomWindow*>(receiver)->setCustomValue(CEGUI::PropertyHelper::stringToFloat(value));
    }
};

// 注册属性
CEGUI::PropertyManager::getSingleton().addProperty(&CustomValueProperty());
```

---

## 二、自定义外观

### 2.1 创建自定义外观

```xml
<!-- 自定义外观定义 -->
<FalagardMapping>
    <WindowMapping>
        <WindowAlias>MyCustomWindow</WindowAlias>
        <TargetType>DefaultWindow</TargetType>
        <RendererLook>MyCustomLook</RendererLook>
    </WindowMapping>
</FalagardMapping>
```

### 2.2 自定义渲染器

```cpp
// 自定义渲染器
class MyCustomLook : public CEGUI::FalagardBase {
public:
    MyCustomLook(const CEGUI::String& type) : CEGUI::FalagardBase(type) {}

    virtual void render() {
        // 自定义渲染逻辑
    }

    virtual CEGUI::Size getPixelSize() const {
        // 返回控件尺寸
    }
};

// 注册自定义渲染器
CEGUI::WindowRendererManager::getSingleton().addFactory<CEGUI::TplWindowRendererFactory<MyCustomLook> >();
```

---

## 三、自定义动画

### 3.1 创建自定义动画

```xml
<!-- 自定义动画定义 -->
<Animations>
    <AnimationDefinition name="MyAnimation" duration="1.0" replayMode="loop">
        <Affector property="Alpha" interpolator="float">
            <KeyFrame position="0.0" value="0.0" progression="linear"/>
            <KeyFrame position="0.5" value="1.0" progression="linear"/>
            <KeyFrame position="1.0" value="0.0" progression="linear"/>
        </Affector>
    </AnimationDefinition>
</Animations>
```

### 3.2 播放自定义动画

```cpp
// 播放动画
CEGUI::AnimationInstance* animation = CEGUI::AnimationManager::getSingleton().instantiateAnimation("MyAnimation");
animation->setTargetWindow(window);
animation->start();
```

---

## 四、自定义事件

### 4.1 定义自定义事件

```cpp
// 定义自定义事件
namespace CEGUI {
    const String EventMyCustomEvent = "MyCustomEvent";
}

// 触发自定义事件
CEGUI::WindowEventArgs args(window);
window->fireEvent(CEGUI::EventMyCustomEvent, args);

// 监听自定义事件
window->subscribeEvent(CEGUI::EventMyCustomEvent, CEGUI::Event::Subscriber(&MyClass::onMyCustomEvent, this));
```

### 4.2 自定义事件参数

```cpp
// 自定义事件参数
class MyCustomEventArgs : public CEGUI::EventArgs {
public:
    MyCustomEventArgs(CEGUI::Window* window, int customData) : CEGUI::EventArgs(window), m_customData(customData) {}

    int getCustomData() const { return m_customData; }

private:
    int m_customData;
};

// 触发自定义事件
MyCustomEventArgs args(window, 123);
window->fireEvent(CEGUI::EventMyCustomEvent, args);
```

---

## 五、性能优化

### 5.1 控件优化

- 减少控件数量
- 使用控件池
- 优化控件层次
- 使用虚拟化列表

### 5.2 渲染优化

- 减少绘制调用
- 使用批处理
- 优化纹理使用
- 使用脏矩形

### 5.3 事件优化

- 减少事件监听器
- 优化事件处理
- 使用事件节流
- 使用事件委托

---

## 六、最佳实践

### 6.1 自定义控件最佳实践

- 继承合适的基类
- 重写必要的方法
- 实现属性系统
- 提供良好的文档

### 6.2 自定义外观最佳实践

- 使用 Falagard 系统
- 复用现有外观
- 优化渲染性能
- 提供良好的文档

### 6.3 自定义动画最佳实践

- 使用动画定义文件
- 复用动画定义
- 优化动画性能
- 提供良好的文档

---

## 七、参考资料

- [CEGUI 技能](../skills/cegui/SKILL.md)
- [CEGUI 工具使用指南](../references/cegui-tools.md)
- [性能优化指南](../references/performance-guide.md)
