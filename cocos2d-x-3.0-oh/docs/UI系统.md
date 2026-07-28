# cocos2d-x 3.0-oh UI系统 (UI System)

## 1. 概述

**文件位置**: `cocos/ui/`

UI系统是 cocos2d-x 3.0 引入的完整UI控件库，基于 Node 构建，提供丰富的交互控件。

### 1.1 UI类层次结构
```
Node
└── ProtectedNode
    └── UIWidget (UI基类)
        ├── UIButton (按钮)
        ├── UICheckBox (复选框)
        ├── UIImageView (图片视图)
        ├── UIText (文本)
        ├── UITextAtlas (字符图集文本)
        ├── UITextBMFont (位图字体文本)
        ├── UITextField (输入框)
        ├── UILoadingBar (加载条)
        ├── UISlider (滑块)
        ├── UILayout (布局容器)
        │   ├── UIHBox (水平盒子)
        │   ├── UIVBox (垂直盒子)
        │   └── UIRelativeBox (相对盒子)
        ├── UIScrollView (滚动视图)
        │   ├── UIListView (列表视图)
        │   └── UIPageView (页面视图)
        ├── UIRichText (富文本)
        ├── UIWebView (Web视图)
        └── UIVideoPlayer (视频播放器)
```

## 2. UIWidget - UI控件基类

**文件**: `cocos/ui/UIWidget.h`

### 2.1 核心属性系统
```cpp
class UIWidget : public ProtectedNode {
public:
    // 尺寸类型
    enum class SizeType { ABSOLUTE, PERCENT };
    // 位置类型
    enum class PositionType { ABSOLUTE, PERCENT };
    // 触摸事件
    enum class TouchEventType { BEGAN, MOVED, ENDED, CANCELED };
    // 纹理资源类型
    enum class TextureResType { LOCAL, PLIST };
    // 亮度风格
    enum class BrightStyle { NONE, NORMAL, HIGHLIGHT };
    
    // 属性设置
    void setSizeType(SizeType type);
    void setSizePercent(const Point& percent);
    void setPositionType(PositionType type);
    void setPositionPercent(const Point& percent);
    
    // 尺寸
    virtual void setSize(const Size& size);
    void setSizePercent(float percentX, float percentY);
    const Size& getSize() const;
    const Size& getCustomSize() const;
    
    // 布局
    virtual void setLayoutParameter(LayoutParameter* parameter);
    LayoutParameter* getLayoutParameter() const;
    
    // 锚点
    void setAnchorPoint(const Point& pt);
    
    // 亮度
    void setBright(bool bright);
    bool isBright() const;
    void setBrightStyle(BrightStyle style);
    
    // 启用状态
    virtual void setEnabled(bool enabled);
    bool isEnabled() const;
    
    // 触摸事件
    void setTouchEnabled(bool enabled);
    bool isTouchEnabled() const;
    
    // 焦点
    void setFocused(bool focus);
    bool isFocused() const;
    
    // 层级
    void setZOrder(int z);
    int getZOrder() const;
    
    // 翻转
    bool isFlippedX() const;
    void setFlippedX(bool);
    bool isFlippedY() const;
    void setFlippedY(bool);
    
    // 回调
    void addTouchEventListener(const std::function<void(Ref*, TouchEventType)>& callback);
    void addClickEventListener(const std::function<void(Ref*)>& callback);
    
    // 名称/标签
    void setName(const std::string& name);
    const std::string& getName() const;
    void setActionTag(int tag);
    int getActionTag() const;
    
    // 更新
    virtual void updateSizeAndPosition();
    virtual void updateSizeAndPosition(const Size& parentSize);
};
```

### 2.2 九宫格支持
```cpp
void setScale9Enabled(bool enabled);
bool isScale9Enabled() const;
void setScale9Size(const Size& size);
```

## 3. 具体控件

### 3.1 UIButton - 按钮
```cpp
class UIButton : public UIWidget {
public:
    static UIButton* create();
    
    // 纹理设置
    void loadTextures(const std::string& normal, const std::string& selected,
                      const std::string& disabled = "", TextureResType type = LOCAL);
    void loadTextureNormal(const std::string& normal, TextureResType type = LOCAL);
    void loadTexturePressed(const std::string& selected, TextureResType type = LOCAL);
    void loadTextureDisabled(const std::string& disabled, TextureResType type = LOCAL);
    
    // 标题
    void setTitleText(const std::string& text);
    std::string getTitleText() const;
    void setTitleColor(const Color3B& color);
    void setTitleFontSize(float size);
    void setTitleFontName(const std::string& name);
    
    // 缩放
    void setPressedActionEnabled(bool enabled);
    void setZoomScale(float scale);  // 按下缩放，默认0.9
    
    // 回调
    void addTouchEventListener(const std::function<void(Ref*, TouchEventType)>&);
    void addClickEventListener(const std::function<void(Ref*)>&);
};
```

### 3.2 UICheckBox - 复选框
```cpp
class UICheckBox : public UIWidget {
public:
    static UICheckBox* create();
    
    void loadTextures(const std::string& backGround, const std::string& cross,
                      const std::string& backGroundDisabled, const std::string& frontCrossDisabled,
                      TextureResType type = LOCAL);
    void setSelected(bool selected);
    bool isSelected() const;
    void addEventListener(const std::function<void(Ref*, CheckBoxEventType)>&);
};
```

### 3.3 UIImageView - 图片视图
```cpp
class UIImageView : public UIWidget {
public:
    static UIImageView* create();
    
    void loadTexture(const std::string& fileName, TextureResType type = LOCAL);
    void setTextureRect(const Rect& rect);
    void setScale9Enabled(bool);
    void setScale9Size(const Size&);
};
```

### 3.4 UIText - 文本
```cpp
class UIText : public UIWidget {
public:
    static UIText* create();
    
    void setString(const std::string& text);
    const std::string& getString() const;
    void setFontSize(int size);
    void setFontName(const std::string& name);
    void setTextColor(const Color4B& color);
    void setTextHorizontalAlignment(TextHAlignment hAlignment);
    void setTextVerticalAlignment(TextVAlignment vAlignment);
    void setTextAreaSize(const Size& size);
    void setTouchScaleEnabled(bool enabled);
};
```

### 3.5 UITextField - 输入框
```cpp
class UITextField : public UIWidget {
public:
    static UITextField* create();
    
    void setString(const std::string& text);
    void setPlaceHolder(const std::string& value);
    void setFontSize(int size);
    void setFontName(const std::string& name);
    void setMaxLengthEnabled(bool enable);
    void setMaxLength(int length);
    void setPasswordEnabled(bool enable);
    void setPasswordStyleText(const std::string& styleText);
    void setAttachWithIME(bool attach);
    void setDetachWithIME(bool detach);
    void setInsertText(bool insert);
    void setDeleteBackward(bool deleteBackward);
    
    void addEventListener(const std::function<void(Ref*, EventType)>&);
};
```

### 3.6 UILoadingBar - 加载条
```cpp
class UILoadingBar : public UIWidget {
public:
    static UILoadingBar* create();
    
    enum class Direction { LEFT, RIGHT };
    
    void setDirection(Direction direction);
    void setPercent(int percent);
    int getPercent() const;
    void loadTexture(const std::string& texture, TextureResType type = LOCAL);
    void setScale9Enabled(bool);
};
```

### 3.7 UISlider - 滑块
```cpp
class UISlider : public UIWidget {
public:
    static UISlider* create();
    
    void loadBarTexture(const std::string& fileName, TextureResType type = LOCAL);
    void loadSlidBallTextures(const std::string& normal, const std::string& pressed,
                              const std::string& disabled, TextureResType type = LOCAL);
    void loadProgressBarTexture(const std::string& fileName, TextureResType type = LOCAL);
    void setPercent(int percent);
    int getPercent() const;
    void setScale9Enabled(bool);
    void addEventListener(const std::function<void(Ref*, EventType)>&);
};
```

## 4. 布局系统

### 4.1 UILayout - 布局容器
```cpp
class UILayout : public UIWidget {
public:
    static UILayout* create();
    
    enum class Type { ABSOLUTE, VERTICAL, HORIZONTAL, RELATIVE };
    enum class ClippingType { STENCIL, SCISSOR };
    
    void setLayoutType(Type type);
    Type getLayoutType() const;
    
    // 裁剪
    void setClippingEnabled(bool enabled);
    bool isClippingEnabled() const;
    void setClippingType(ClippingType type);
    
    // 背景
    void setBackGroundImage(const std::string& fileName, TextureResType type = LOCAL);
    void setBackGroundColor(const Color3B& color);
    void setBackGroundColorOpacity(int opacity);
    void setBackGroundImageScale9Enabled(bool enabled);
    void setBackGroundImageCapInsets(const Rect& rect);
    
    // 子控件管理
    void removeBackGroundImage();
    virtual void addChild(Node* child) override;
    virtual void removeChild(Node* child, bool cleanup = true) override;
};
```

### 4.2 盒子布局
```cpp
// UIHBox - 水平排列
class UIHBox : public UILayout {
    static UIHBox* create(const Size& size);
};

// UIVBox - 垂直排列
class UIVBox : public UILayout {
    static UIVBox* create(const Size& size);
};

// UIRelativeBox - 相对布局
class UIRelativeBox : public UILayout {
    static UIRelativeBox* create(const Size& size);
};
```

## 5. 滚动与列表

### 5.1 UIScrollView - 滚动视图
```cpp
class UIScrollView : public UILayout {
public:
    static UIScrollView* create();
    
    enum class Direction { NONE, VERTICAL, HORIZONTAL, BOTH };
    
    void setDirection(Direction dir);
    Direction getDirection() const;
    void setInnerContainerSize(const Size& size);
    const Size& getInnerContainerSize() const;
    void scrollToTop(float time, bool attenuated);
    void scrollToBottom(float time, bool attenuated);
    void scrollToLeft(float time, bool attenuated);
    void scrollToRight(float time, bool attenuated);
    void scrollToPercentVertical(float percent, float time, bool attenuated);
    void scrollToPercentHorizontal(float percent, float time, bool attenuated);
    void setBounceEnabled(bool enabled);
    void addEventListener(const std::function<void(Ref*, EventType)>&);
};
```

### 5.2 UIListView - 列表视图
```cpp
class UIListView : public UIScrollView {
public:
    static UIListView* create();
    
    enum class Gravity { LEFT, RIGHT, CENTER_HORIZONTAL, TOP, BOTTOM, CENTER_VERTICAL };
    enum class EventType { ON_SELECTED_ITEM_START, ON_SELECTED_ITEM_END };
    
    void setItemModel(UIWidget* model);
    void pushBackDefaultItem();
    void insertDefaultItem(ssize_t index);
    void pushBackCustomItem(UIWidget* item);
    void insertCustomItem(UIWidget* item, ssize_t index);
    void removeItem(ssize_t index);
    void removeLastItem();
    void removeAllItems();
    UIWidget* getItem(ssize_t index) const;
    Vector<UIWidget*>& getItems();
    ssize_t getIndex(UIWidget* item) const;
    void setGravity(Gravity gravity);
    void setItemsMargin(float margin);
    void addEventListener(const std::function<void(Ref*, EventType)>&);
};
```

### 5.3 UIPageView - 页面视图
```cpp
class UIPageView : public UILayout {
public:
    static UIPageView* create();
    
    enum class EventType { TURNING };
    
    void addPage(UIWidget* page);
    void insertPage(UIWidget* page, int idx);
    void removePage(UIWidget* page);
    void removePageAtIndex(ssize_t index);
    void removeAllPages();
    void scrollToPage(ssize_t idx);
    ssize_t getCurPageIndex() const;
    void addEventListener(const std::function<void(Ref*, EventType)>&);
};
```

## 6. 其他控件

### 6.1 UIRichText - 富文本
```cpp
class UIRichText : public UIWidget {
public:
    static UIRichText* create();
    
    void insertElement(int index, int tag, const std::string& text,
                       const std::string& fontName, float fontSize,
                       const Color3B& color, GLubyte opacity);
    void pushBackElement(int tag, const std::string& text, ...);
    void removeElement(int index);
};
```

### 6.2 UIWebView - Web视图
```cpp
class UIWebView : public UIWidget {
public:
    static UIWebView* create();
    
    void setJavascriptInterfaceScheme(const std::string& scheme);
    void loadURL(const std::string& url);
    void loadFile(const std::string& fileName);
    void loadData(const Data& data, const std::string& MIMEType,
                  const std::string& encoding, const std::string& baseURL);
    void setScalesPageToFit(bool scalesPageToFit);
    bool canGoBack();
    bool canGoForward();
    void goBack();
    void goForward();
    void evaluateJS(const std::string& js);
    void setOnShouldStartLoading(const std::function<bool(const std::string&)>&);
    void setOnDidFinishLoading(const std::function<void(const std::string&)>&);
    void setOnDidFailLoading(const std::function<void(const std::string&)>&);
};
```

### 6.3 UIVideoPlayer - 视频播放器
```cpp
class UIVideoPlayer : public UIWidget {
public:
    static UIVideoPlayer* create();
    
    void setFileName(const std::string& fileName);
    void setURL(const std::string& url);
    void play();
    void pause();
    void resume();
    void stop();
    void seekTo(float sec);
    bool isPlaying() const;
    void setKeepAspectRatioEnabled(bool enable);
    void setFullScreenEnabled(bool);
    void addEventListener(const std::function<void(Ref*, EventType)>&);
};
```

## 7. UIHelper - 辅助工具

**文件**: `cocos/ui/UIHelper.h`

```cpp
class UIHelper {
public:
    static UIWidget* seekWidgetByTag(UIWidget* root, int tag);
    static UIWidget* seekWidgetByName(UIWidget* root, const std::string& name);
    static UIWidget* seekActionWidgetByActionTag(UIWidget* root, int tag);
    static std::string getSubStringOfUTF8String(const std::string& str, ssize_t start, ssize_t length);
};
```

## 8. 使用示例

### 8.1 创建按钮
```cpp
auto button = UIButton::create();
button->loadTextures("button_normal.png", "button_pressed.png");
button->setTitleText("Click Me");
button->setTitleFontSize(24);
button->setPosition(Point(100, 200));
button->addClickEventListener([](Ref* sender) {
    CCLOG("Button clicked!");
});
layer->addChild(button);
```

### 8.2 创建列表
```cpp
auto listView = UIListView::create();
listView->setDirection(UIScrollView::Direction::VERTICAL);
listView->setBounceEnabled(true);
listView->setContentSize(Size(400, 300));
listView->setItemsMargin(5);

auto defaultItem = UIButton::create();
defaultItem->loadTextures("item.png", "item.png");
listView->setItemModel(defaultItem);

for (int i = 0; i < 20; i++) {
    listView->pushBackDefaultItem();
}
layer->addChild(listView);
```

### 8.3 布局管理
```cpp
auto hbox = UIHBox::create(Size(400, 60));
for (int i = 0; i < 3; i++) {
    auto btn = UIButton::create();
    btn->loadTextures("btn.png", "btn.png");
    hbox->addChild(btn);
}
layer->addChild(hbox);
```