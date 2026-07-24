# CEImagesetEditor LookNFeel 可视化功能设计方案

> **文档版本**: 1.0 | **创建日期**: 2026-01-09
> **作者**: 高级C++软件架构师
> **状态**: 设计阶段

---

## 📋 执行摘要

本方案详细描述在 CEImagesetEditor-0.7.1 工具集中拓展 LookNFeel 文件可视化功能的完整架构设计。目标是实现对 `client/resource/res/ui/looknfeel` 目录下文件的读取、解析，并将相关图片资源在 GUI 界面中进行可视化展示。

---

## 🎯 需求分析

### 1.1 目标文件分析

目标目录 `client/resource/res/ui/looknfeel` 包含以下文件：
- `taharezlook.looknfeel` (1356行 XML)
- `taharezlook2.looknfeel`

### 1.2 LookNFeel 文件结构

通过分析 `taharezlook.looknfeel`，其核心结构如下：

```xml
<?xml version="1.0" ?>
<Falagard>
    <WidgetLook name="TaharezLook/Button">
        <PropertyDefinition name="NormalImage" initialValue="" />
        <ImagerySection name="normal">
            <FrameComponent>
                <Image type="Background" imageset="common" image="common_buttonlan67" />
            </FrameComponent>
            <ImageryComponent>
                <ImageProperty name="NormalImage" />
            </ImageryComponent>
        </ImagerySection>
        <StateImagery name="Normal">
            <Layer>
                <Section section="normal" />
            </Layer>
        </StateImagery>
    </WidgetLook>
</Falagard>
```

### 1.3 关键元素分析

| 元素 | 说明 | 可视化需求 |
|------|------|------------|
| `WidgetLook` | 控件外观定义 | 树形结构展示 |
| `PropertyDefinition` | 属性定义 | 属性面板展示 |
| `ImagerySection` | 图像区段定义 | 图片预览 |
| `FrameComponent` | 框架组件（九宫格等） | 可视化渲染 |
| `ImageryComponent` | 图像组件 | 单图片预览 |
| `Image` | 图片引用 | **关键：需要解析 imageset 和 image** |
| `StateImagery` | 状态图像 | 状态切换预览 |

### 1.4 图像引用关系

```
LookNFeel 文件
    └─→ 引用 Imageset 名称 (如 "common")
           └─→ 对应 Imageset 文件 (如 common.imageset)
                  └─→ 定义 Image 区域 (如 "common_buttonlan67")
                         └─→ 实际纹理文件 (如 common.tga)
```

---

## 🏗️ 系统架构设计

### 2.1 整体架构图

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    CEImagesetEditor LookNFeel 扩展                        │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  ┌─────────────────────────────────────────────────────────────────────┐  │
│  │                         GUI 界面层                                   │  │
│  │  ┌─────────────┐  ┌─────────────────┐  ┌─────────────────────────┐  │  │
│  │  │ LookNFeel   │  │ WidgetLook      │  │ StateImagery 预览       │  │  │
│  │  │ 浏览器面板  │  │ 属性面板        │  │ Canvas                  │  │  │
│  │  └──────┬──────┘  └────────┬────────┘  └────────────┬────────────┘  │  │
│  └─────────┼──────────────────┼────────────────────────┼───────────────┘  │
│            │                  │                        │                  │
│  ┌─────────▼──────────────────▼────────────────────────▼───────────────┐  │
│  │                         业务逻辑层                                   │  │
│  │  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────────┐  │  │
│  │  │ LookNFeelParser │  │ ImagesetResolver│  │ StateRenderer       │  │  │
│  │  │ (XML 解析)      │  │ (图集解析)      │  │ (状态渲染器)        │  │  │
│  │  └────────┬────────┘  └────────┬────────┘  └──────────┬──────────┘  │  │
│  └───────────┼────────────────────┼──────────────────────┼─────────────┘  │
│              │                    │                      │                │
│  ┌───────────▼────────────────────▼──────────────────────▼─────────────┐  │
│  │                         数据模型层                                   │  │
│  │  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────────┐  │  │
│  │  │ LookNFeelData   │  │ ImagesetCache   │  │ TextureCache        │  │  │
│  │  │ (数据结构)      │  │ (图集缓存)      │  │ (纹理缓存)          │  │  │
│  │  └─────────────────┘  └─────────────────┘  └─────────────────────┘  │  │
│  └─────────────────────────────────────────────────────────────────────┘  │
│                                                                          │
│  ┌─────────────────────────────────────────────────────────────────────┐  │
│  │                         基础设施层                                   │  │
│  │  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────────┐  │  │
│  │  │ AsyncTexture    │  │ TiledTexture    │  │ EditorGLCanvas      │  │  │
│  │  │ Loader          │  │ Manager         │  │ (OpenGL 渲染)       │  │  │
│  │  └─────────────────┘  └─────────────────┘  └─────────────────────┘  │  │
│  └─────────────────────────────────────────────────────────────────────┘  │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### 2.2 模块职责划分

| 模块 | 职责 | 依赖 |
|------|------|------|
| **LookNFeelParser** | 解析 .looknfeel XML 文件 | TinyXML / wxXML |
| **ImagesetResolver** | 解析 .imageset 文件并关联纹理 | 现有 ImagesetHandler |
| **LookNFeelData** | 存储解析后的数据结构 | 无 |
| **LookNFeelBrowser** | 树形浏览 WidgetLook 定义 | wxTreeCtrl |
| **LookNFeelViewer** | 可视化渲染 WidgetLook | EditorGLCanvas |
| **StateRenderer** | 渲染不同状态的图像 | OpenGL |

---

## 📊 数据结构设计

### 3.1 核心数据结构

```cpp
// LookNFeelData.h - LookNFeel 数据结构

#ifndef LOOKNFEEL_DATA_H
#define LOOKNFEEL_DATA_H

#include <wx/wx.h>
#include <vector>
#include <map>

namespace LookNFeel {

// 颜色矩形
struct ColourRect {
    wxColour topLeft;
    wxColour topRight;
    wxColour bottomLeft;
    wxColour bottomRight;
    
    ColourRect() 
        : topLeft(255,255,255,255)
        , topRight(255,255,255,255)
        , bottomLeft(255,255,255,255)
        , bottomRight(255,255,255,255) {}
};

// 区域定义
struct Area {
    float leftEdge;
    float topEdge;
    float width;
    float height;
    bool useScale;      // 是否使用比例
    
    Area() : leftEdge(0), topEdge(0), width(0), height(0), useScale(false) {}
};

// 图片引用
struct ImageRef {
    wxString imageset;   // 图集名称
    wxString image;      // 图片名称
    wxString type;       // 类型 (Background, LeftEdge, etc.)
    
    bool isValid() const { return !imageset.IsEmpty() && !image.IsEmpty(); }
};

// 框架组件 (九宫格)
struct FrameComponent {
    Area area;
    ImageRef background;
    ImageRef leftEdge;
    ImageRef rightEdge;
    ImageRef topEdge;
    ImageRef bottomEdge;
    ImageRef topLeftCorner;
    ImageRef topRightCorner;
    ImageRef bottomLeftCorner;
    ImageRef bottomRightCorner;
    ColourRect colours;
    
    bool hasNinePatch() const {
        return topLeftCorner.isValid() && topRightCorner.isValid() &&
               bottomLeftCorner.isValid() && bottomRightCorner.isValid();
    }
    
    bool hasThreePieceH() const {
        return leftEdge.isValid() && rightEdge.isValid() && background.isValid();
    }
    
    bool hasThreePieceV() const {
        return topEdge.isValid() && bottomEdge.isValid() && background.isValid();
    }
};

// 图像组件
struct ImageryComponent {
    Area area;
    ImageRef image;
    wxString imageProperty;  // 动态图片属性名
    ColourRect colours;
    wxString vertFormat;
    wxString horzFormat;
};

// 文本组件
struct TextComponent {
    Area area;
    wxString vertFormat;
    wxString horzFormat;
    ColourRect colours;
    wxString fontProperty;
    wxString colourProperty;
};

// 图像区段
struct ImagerySection {
    wxString name;
    std::vector<FrameComponent> frameComponents;
    std::vector<ImageryComponent> imageryComponents;
    std::vector<TextComponent> textComponents;
};

// 层
struct Layer {
    struct SectionRef {
        wxString sectionName;
        wxString lookName;      // 引用其他 WidgetLook 的 section
        ColourRect colours;
        wxString colourProperty;
    };
    std::vector<SectionRef> sections;
};

// 状态图像
struct StateImagery {
    wxString name;
    std::vector<Layer> layers;
};

// 属性定义
struct PropertyDefinition {
    wxString name;
    wxString initialValue;
    bool redrawOnWrite;
    
    PropertyDefinition() : redrawOnWrite(false) {}
};

// 命名区域
struct NamedArea {
    wxString name;
    Area area;
};

// WidgetLook 定义
struct WidgetLook {
    wxString name;
    std::vector<PropertyDefinition> propertyDefinitions;
    std::map<wxString, ImagerySection> imagerySections;
    std::map<wxString, StateImagery> stateImageries;
    std::vector<NamedArea> namedAreas;
    
    // 获取状态图像
    const StateImagery* getStateImagery(const wxString& stateName) const {
        auto it = stateImageries.find(stateName);
        return it != stateImageries.end() ? &it->second : nullptr;
    }
    
    // 获取图像区段
    const ImagerySection* getImagerySection(const wxString& sectionName) const {
        auto it = imagerySections.find(sectionName);
        return it != imagerySections.end() ? &it->second : nullptr;
    }
};

// LookNFeel 文档
struct LookNFeelDocument {
    wxString filePath;
    std::map<wxString, WidgetLook> widgetLooks;
    
    const WidgetLook* getWidgetLook(const wxString& name) const {
        auto it = widgetLooks.find(name);
        return it != widgetLooks.end() ? &it->second : nullptr;
    }
    
    void getWidgetLookNames(wxArrayString& names) const {
        for (const auto& pair : widgetLooks) {
            names.Add(pair.first);
        }
    }
};

} // namespace LookNFeel

#endif // LOOKNFEEL_DATA_H
```

### 3.2 图集解析缓存

```cpp
// ImagesetCache.h - 图集缓存管理

#ifndef IMAGESET_CACHE_H
#define IMAGESET_CACHE_H

#include <wx/wx.h>
#include <map>

class ImagesetCache {
public:
    // 单例访问
    static ImagesetCache& getInstance();
    
    // 图像区域信息
    struct ImageRegion {
        wxString name;
        int x, y, width, height;
        int xOffset, yOffset;
    };
    
    // 图集信息
    struct ImagesetInfo {
        wxString name;
        wxString textureFile;
        int nativeHorzRes;
        int nativeVertRes;
        bool autoScaled;
        std::map<wxString, ImageRegion> images;
    };
    
    // 加载图集文件
    bool loadImageset(const wxString& imagesetPath);
    
    // 获取图集信息
    const ImagesetInfo* getImageset(const wxString& name) const;
    
    // 获取图像区域
    const ImageRegion* getImageRegion(const wxString& imagesetName, 
                                       const wxString& imageName) const;
    
    // 设置基础资源路径
    void setResourcePath(const wxString& path);
    
    // 清空缓存
    void clearCache();
    
    // 预加载目录下所有图集
    void preloadDirectory(const wxString& directory);
    
private:
    ImagesetCache();
    ~ImagesetCache();
    
    wxString m_resourcePath;
    std::map<wxString, ImagesetInfo> m_imagesets;
    mutable wxCriticalSection m_lock;
};

#endif // IMAGESET_CACHE_H
```

---

## 🔧 模块实现设计

### 4.1 LookNFeel 解析器

```cpp
// LookNFeelParser.h - LookNFeel 文件解析器

#ifndef LOOKNFEEL_PARSER_H
#define LOOKNFEEL_PARSER_H

#include "LookNFeelData.h"
#include <wx/xml/xml.h>

class LookNFeelParser {
public:
    LookNFeelParser();
    ~LookNFeelParser();
    
    // 解析文件
    bool parseFile(const wxString& filePath, LookNFeel::LookNFeelDocument& doc);
    
    // 解析字符串
    bool parseString(const wxString& xmlContent, LookNFeel::LookNFeelDocument& doc);
    
    // 获取错误信息
    wxString getLastError() const { return m_lastError; }
    
private:
    // 解析 WidgetLook 节点
    bool parseWidgetLook(wxXmlNode* node, LookNFeel::WidgetLook& look);
    
    // 解析 PropertyDefinition 节点
    bool parsePropertyDefinition(wxXmlNode* node, LookNFeel::PropertyDefinition& prop);
    
    // 解析 ImagerySection 节点
    bool parseImagerySection(wxXmlNode* node, LookNFeel::ImagerySection& section);
    
    // 解析 FrameComponent 节点
    bool parseFrameComponent(wxXmlNode* node, LookNFeel::FrameComponent& frame);
    
    // 解析 ImageryComponent 节点
    bool parseImageryComponent(wxXmlNode* node, LookNFeel::ImageryComponent& imagery);
    
    // 解析 TextComponent 节点
    bool parseTextComponent(wxXmlNode* node, LookNFeel::TextComponent& text);
    
    // 解析 StateImagery 节点
    bool parseStateImagery(wxXmlNode* node, LookNFeel::StateImagery& state);
    
    // 解析 Layer 节点
    bool parseLayer(wxXmlNode* node, LookNFeel::Layer& layer);
    
    // 解析 Area 节点
    bool parseArea(wxXmlNode* node, LookNFeel::Area& area);
    
    // 解析 Dim 节点
    float parseDim(wxXmlNode* node);
    
    // 解析 Image 节点
    bool parseImage(wxXmlNode* node, LookNFeel::ImageRef& imageRef);
    
    // 解析 ColourRect
    bool parseColours(wxXmlNode* node, LookNFeel::ColourRect& colours);
    
    // 解析颜色字符串 "AARRGGBB"
    wxColour parseColourString(const wxString& str);
    
    wxString m_lastError;
};

#endif // LOOKNFEEL_PARSER_H
```

### 4.2 LookNFeel 查看器

```cpp
// LookNFeelViewer.h - LookNFeel 可视化查看器

#ifndef LOOKNFEEL_VIEWER_H
#define LOOKNFEEL_VIEWER_H

#include <wx/wx.h>
#include <wx/glcanvas.h>
#include "LookNFeelData.h"

class LookNFeelViewer : public wxGLCanvas {
public:
    LookNFeelViewer(wxWindow* parent, wxWindowID id = wxID_ANY);
    ~LookNFeelViewer();
    
    // 设置要显示的 WidgetLook
    void setWidgetLook(const LookNFeel::WidgetLook* look);
    
    // 设置当前显示的状态
    void setCurrentState(const wxString& stateName);
    
    // 设置预览尺寸
    void setPreviewSize(int width, int height);
    
    // 获取当前状态
    wxString getCurrentState() const { return m_currentState; }
    
    // 刷新渲染
    void refresh();
    
protected:
    void OnPaint(wxPaintEvent& event);
    void OnSize(wxSizeEvent& event);
    void OnEraseBackground(wxEraseEvent& event);
    
private:
    // 初始化 OpenGL
    void initGL();
    
    // 渲染 WidgetLook
    void renderWidgetLook();
    
    // 渲染 ImagerySection
    void renderImagerySection(const LookNFeel::ImagerySection& section);
    
    // 渲染 FrameComponent (九宫格)
    void renderFrameComponent(const LookNFeel::FrameComponent& frame);
    
    // 渲染 ImageryComponent
    void renderImageryComponent(const LookNFeel::ImageryComponent& imagery);
    
    // 渲染单个图片引用
    void renderImageRef(const LookNFeel::ImageRef& imageRef, 
                        float x, float y, float width, float height);
    
    // 加载纹理
    unsigned int loadTexture(const wxString& imagesetName, const wxString& imageName);
    
    // 成员变量
    wxGLContext* m_glContext;
    const LookNFeel::WidgetLook* m_widgetLook;
    wxString m_currentState;
    int m_previewWidth;
    int m_previewHeight;
    bool m_glInitialized;
    
    // 纹理缓存
    std::map<wxString, unsigned int> m_textureCache;
    
    DECLARE_EVENT_TABLE()
};

#endif // LOOKNFEEL_VIEWER_H
```

### 4.3 LookNFeel 浏览器面板

```cpp
// LookNFeelBrowser.h - LookNFeel 浏览器面板

#ifndef LOOKNFEEL_BROWSER_H
#define LOOKNFEEL_BROWSER_H

#include <wx/wx.h>
#include <wx/treectrl.h>
#include <wx/splitter.h>
#include <wx/listbox.h>
#include "LookNFeelData.h"

class LookNFeelViewer;

class LookNFeelBrowser : public wxPanel {
public:
    LookNFeelBrowser(wxWindow* parent, wxWindowID id = wxID_ANY);
    ~LookNFeelBrowser();
    
    // 打开 LookNFeel 文件
    bool openFile(const wxString& filePath);
    
    // 打开目录
    bool openDirectory(const wxString& dirPath);
    
    // 获取当前选中的 WidgetLook
    const LookNFeel::WidgetLook* getSelectedWidgetLook() const;
    
    // 获取当前文档
    const LookNFeel::LookNFeelDocument* getCurrentDocument() const { return &m_document; }
    
protected:
    // 事件处理
    void OnTreeSelectionChanged(wxTreeEvent& event);
    void OnStateListSelectionChanged(wxCommandEvent& event);
    void OnRefresh(wxCommandEvent& event);
    
private:
    // 创建界面
    void createUI();
    
    // 填充树形控件
    void populateTree();
    
    // 填充状态列表
    void populateStateList(const LookNFeel::WidgetLook* look);
    
    // UI 组件
    wxSplitterWindow* m_splitter;
    wxTreeCtrl* m_treeCtrl;
    wxListBox* m_stateList;
    LookNFeelViewer* m_viewer;
    
    // 数据
    LookNFeel::LookNFeelDocument m_document;
    
    // 树节点到 WidgetLook 映射
    std::map<wxTreeItemId, wxString> m_treeItemMap;
    
    DECLARE_EVENT_TABLE()
};

#endif // LOOKNFEEL_BROWSER_H
```

---

## 🖼️ GUI 界面设计

### 5.1 界面布局

```
┌─────────────────────────────────────────────────────────────────────────┐
│  文件(F)  编辑(E)  视图(V)  工具(T)  [LookNFeel(L)]  帮助(H)             │
├─────────────────────────────────────────────────────────────────────────┤
│  [打开] [保存] [撤销] [重做] | [查看LookNFeel] [刷新]                     │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  ┌──────────────────────────┬─────────────────────────────────────────┐  │
│  │  LookNFeel 浏览器        │                                          │  │
│  │  ┌────────────────────┐  │        预览区域                          │  │
│  │  │ ▼ taharezlook      │  │  ┌─────────────────────────────────────┐  │  │
│  │  │   ├─ Button        │  │  │                                     │  │  │
│  │  │   ├─ dangebutton   │  │  │    [按钮预览 - Normal 状态]          │  │  │
│  │  │   ├─ Tooltip1      │  │  │                                     │  │  │
│  │  │   ├─ StaticImage   │  │  │                                     │  │  │
│  │  │   ├─ StaticText    │  │  │                                     │  │  │
│  │  │   ├─ ImageButton   │  │  └─────────────────────────────────────┘  │  │
│  │  │   └─ ...           │  │                                          │  │
│  │  └────────────────────┘  │  状态选择:                                │  │
│  │                          │  ┌──────────────────────────────────────┐  │  │
│  │  状态列表:                │  │ ○ Normal  ● Hover  ○ Pushed          │  │  │
│  │  ┌────────────────────┐  │  │ ○ Disabled  ○ PushedOff             │  │  │
│  │  │ Normal             │  │  └──────────────────────────────────────┘  │  │
│  │  │ Hover              │  │                                          │  │
│  │  │ Pushed             │  │  属性信息:                                │  │
│  │  │ Disabled           │  │  ┌──────────────────────────────────────┐  │  │
│  │  │ PushedOff          │  │  │ NormalTextColour: ffffffff           │  │  │
│  │  └────────────────────┘  │  │ HoverTextColour: ffffffff            │  │  │
│  │                          │  │ ButtonBorderEnable: True             │  │  │
│  └──────────────────────────┴──┴──────────────────────────────────────┘  │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### 5.2 菜单栏扩展

```cpp
// 在 EditorFrame.cpp 中添加 LookNFeel 菜单

// LookNFeel 菜单
wxMenu* menu_looknfeel = new wxMenu;
menu_looknfeel->Append(ID_LOOKNFEEL_OPEN, wxT("打开 LookNFeel 文件(&O)...\tCtrl-Shift-O"),
                       wxT("打开 .looknfeel 文件进行预览"));
menu_looknfeel->Append(ID_LOOKNFEEL_OPEN_DIR, wxT("打开 LookNFeel 目录(&D)..."),
                       wxT("打开包含 .looknfeel 文件的目录"));
menu_looknfeel->AppendSeparator();
menu_looknfeel->Append(ID_LOOKNFEEL_REFRESH, wxT("刷新(&R)\tF5"),
                       wxT("重新加载当前 LookNFeel 文件"));
menu_looknfeel->AppendSeparator();
menu_looknfeel->Append(ID_LOOKNFEEL_EXTRACT_IMAGES, wxT("提取引用图片(&E)..."),
                       wxT("提取 LookNFeel 中引用的所有图片"));
menu_bar->Append(menu_looknfeel, wxT("LookNFeel(&L)"));
```

### 5.3 对话框设计

#### 5.3.1 LookNFeel 浏览对话框

```cpp
// DialogLookNFeelBrowser.h

class DialogLookNFeelBrowser : public wxDialog {
public:
    DialogLookNFeelBrowser(wxWindow* parent);
    ~DialogLookNFeelBrowser();
    
    // 打开文件
    bool openFile(const wxString& filePath);
    
private:
    LookNFeelBrowser* m_browser;
    
    void OnClose(wxCommandEvent& event);
    
    DECLARE_EVENT_TABLE()
};
```

---

## 🔄 与现有组件的集成

### 6.1 AsyncTextureLoader 集成

```cpp
// 利用现有的 AsyncTextureLoader 进行异步纹理加载

class LookNFeelTextureManager {
public:
    // 异步加载 LookNFeel 引用的所有纹理
    void preloadLookNFeelTextures(const LookNFeel::LookNFeelDocument& doc) {
        // 收集所有引用的图集名称
        std::set<wxString> imagesets;
        collectImagesetNames(doc, imagesets);
        
        // 获取图集对应的纹理文件
        for (const auto& imagesetName : imagesets) {
            const auto* info = ImagesetCache::getInstance().getImageset(imagesetName);
            if (info) {
                wxString texturePath = getTextureFullPath(info->textureFile);
                // 使用 AsyncTextureLoader 异步加载
                AsyncTextureLoader::getInstance().loadTexture(texturePath, true);
            }
        }
    }
    
private:
    void collectImagesetNames(const LookNFeel::LookNFeelDocument& doc, 
                               std::set<wxString>& imagesets);
    wxString getTextureFullPath(const wxString& textureFile);
};
```

### 6.2 TiledTextureManager 集成

```cpp
// 对于大型纹理，使用 TiledTextureManager 进行分块渲染

void LookNFeelViewer::renderLargeTexture(const wxString& texturePath, 
                                          float viewportX, float viewportY,
                                          float viewportWidth, float viewportHeight) {
    auto& tiledManager = TiledTextureManager::getInstance();
    
    // 加载大纹理
    if (!tiledManager.hasImage() || tiledManager.getImagePath() != texturePath) {
        tiledManager.loadImage(texturePath);
    }
    
    // 使用分块渲染
    float zoom = calculateZoom();
    tiledManager.render(viewportX, viewportY, viewportWidth, viewportHeight, zoom);
}
```

### 6.3 EditorDocument 扩展

```cpp
// 在 EditorDocument 中添加 LookNFeel 支持

class EditorDocument : public wxDocument {
public:
    // 新增方法
    
    // 加载 LookNFeel 文件
    bool loadLookNFeel(const wxString& filePath);
    
    // 获取当前 LookNFeel 文档
    const LookNFeel::LookNFeelDocument* getLookNFeelDocument() const {
        return m_lookNFeelDoc.get();
    }
    
    // 检查是否有加载的 LookNFeel
    bool hasLookNFeel() const { return m_lookNFeelDoc != nullptr; }
    
private:
    std::unique_ptr<LookNFeel::LookNFeelDocument> m_lookNFeelDoc;
};
```

---

## 📁 文件系统交互设计

### 7.1 资源路径管理

```cpp
// ResourcePathManager.h - 资源路径管理器

class ResourcePathManager {
public:
    static ResourcePathManager& getInstance();
    
    // 设置基础资源路径
    void setBasePath(const wxString& path);
    
    // 获取 LookNFeel 文件路径
    wxString getLookNFeelPath() const;
    
    // 获取 Imageset 文件路径
    wxString getImagesetPath() const;
    
    // 获取纹理文件路径
    wxString getTexturePath() const;
    
    // 根据图集名称查找 .imageset 文件
    wxString findImagesetFile(const wxString& imagesetName) const;
    
    // 根据纹理文件名查找纹理文件
    wxString findTextureFile(const wxString& textureFilename) const;
    
    // 设置自定义搜索路径
    void addSearchPath(const wxString& path);
    
private:
    ResourcePathManager();
    
    wxString m_basePath;
    std::vector<wxString> m_searchPaths;
    
    // 默认路径
    static const wxString c_defaultLookNFeelPath;
    static const wxString c_defaultImagesetPath;
    static const wxString c_defaultTexturePath;
};

// ResourcePathManager.cpp
const wxString ResourcePathManager::c_defaultLookNFeelPath = "client/resource/res/ui/looknfeel";
const wxString ResourcePathManager::c_defaultImagesetPath = "client/resource/res/ui/imagesets";
const wxString ResourcePathManager::c_defaultTexturePath = "client/resource/res/ui";
```

### 7.2 文件扫描与监控

```cpp
// FileWatcher.h - 文件监控器

class LookNFeelFileWatcher : public wxThread {
public:
    LookNFeelFileWatcher(const wxString& watchPath, wxEvtHandler* handler);
    
    // 开始监控
    void startWatching();
    
    // 停止监控
    void stopWatching();
    
protected:
    virtual void* Entry() override;
    
private:
    wxString m_watchPath;
    wxEvtHandler* m_handler;
    bool m_running;
};

// 自定义事件
wxDECLARE_EVENT(EVT_LOOKNFEEL_FILE_CHANGED, wxCommandEvent);
wxDECLARE_EVENT(EVT_IMAGESET_FILE_CHANGED, wxCommandEvent);
```

---

## 🔨 编译配置更新

### 8.1 vcxproj 文件更新

需要在 `vc++9/CEImagesetEditor.vcxproj` 中添加新文件：

```xml
<ItemGroup>
  <!-- 现有文件 -->
  
  <!-- LookNFeel 相关新文件 -->
  <ClCompile Include="..\src\LookNFeelParser.cpp" />
  <ClCompile Include="..\src\LookNFeelViewer.cpp" />
  <ClCompile Include="..\src\LookNFeelBrowser.cpp" />
  <ClCompile Include="..\src\ImagesetCache.cpp" />
  <ClCompile Include="..\src\ResourcePathManager.cpp" />
  <ClCompile Include="..\src\DialogLookNFeelBrowser.cpp" />
</ItemGroup>

<ItemGroup>
  <!-- 现有头文件 -->
  
  <!-- LookNFeel 相关新头文件 -->
  <ClInclude Include="..\inc\LookNFeelData.h" />
  <ClInclude Include="..\inc\LookNFeelParser.h" />
  <ClInclude Include="..\inc\LookNFeelViewer.h" />
  <ClInclude Include="..\inc\LookNFeelBrowser.h" />
  <ClInclude Include="..\inc\ImagesetCache.h" />
  <ClInclude Include="..\inc\ResourcePathManager.h" />
  <ClInclude Include="..\inc\DialogLookNFeelBrowser.h" />
</ItemGroup>
```

### 8.2 编译环境约束

根据项目规范 (AGENTS.md)：

| 约束 | 要求 |
|------|------|
| **编译器** | Visual Studio 2013 (v120) |
| **字符集** | Unicode |
| **运行时库** | MultiThreadedDLL (/MD) |
| **源文件编码** | UTF-8 with BOM |
| **依赖库** | CEGUI 0.7.1, wxWidgets 3.0.5 |

---

## 📋 实施路径

### 阶段 1: 基础框架 (3-4天)

```
1.1 创建数据结构 (LookNFeelData.h)
    - 定义所有核心数据类型
    - 实现基础访问方法
    
1.2 实现 LookNFeel 解析器 (LookNFeelParser)
    - XML 解析逻辑
    - 错误处理
    - 单元测试
    
1.3 实现 Imageset 缓存 (ImagesetCache)
    - 复用现有 ImagesetHandler 逻辑
    - 添加缓存机制
```

### 阶段 2: 可视化渲染 (3-4天)

```
2.1 实现 LookNFeel 查看器 (LookNFeelViewer)
    - OpenGL 渲染初始化
    - 九宫格渲染
    - 三段式渲染
    - 状态切换
    
2.2 集成 AsyncTextureLoader
    - 异步纹理预加载
    - 进度反馈
    
2.3 集成 TiledTextureManager
    - 大纹理支持
    - LOD 切换
```

### 阶段 3: GUI 界面 (2-3天)

```
3.1 实现 LookNFeel 浏览器面板 (LookNFeelBrowser)
    - 树形控件
    - 状态列表
    - 属性显示
    
3.2 实现浏览对话框 (DialogLookNFeelBrowser)
    - 文件打开
    - 目录浏览
    
3.3 菜单栏集成
    - 添加 LookNFeel 菜单
    - 工具栏按钮
    - 快捷键
```

### 阶段 4: 优化与测试 (2天)

```
4.1 性能优化
    - 纹理缓存优化
    - 渲染批处理
    
4.2 功能完善
    - 错误处理
    - 用户友好提示
    
4.3 测试验证
    - 功能测试
    - 兼容性测试
```

---

## 📊 技术债务更新

### 新增待办项

| 项目 | 描述 | 优先级 | 状态 |
|------|------|--------|------|
| **LNF-001** | LookNFeel 文件解析功能 | 高 | 待实施 |
| **LNF-002** | LookNFeel 可视化渲染 | 高 | 待实施 |
| **LNF-003** | Imageset 缓存系统 | 高 | 待实施 |
| **LNF-004** | LookNFeel 浏览器面板 | 中 | 待实施 |
| **LNF-005** | 菜单栏与界面集成 | 中 | 待实施 |
| **LNF-006** | 资源路径管理器 | 中 | 待实施 |
| **LNF-007** | 文件监控与热重载 | 低 | 待规划 |
| **LNF-008** | LookNFeel 编辑功能 | 低 | 待规划 |

---

## 🔍 风险评估

| 风险 | 影响 | 可能性 | 缓解措施 |
|------|------|--------|----------|
| XML 解析性能 | 中 | 低 | 使用流式解析，缓存结果 |
| 大纹理内存占用 | 高 | 中 | 使用 TiledTextureManager |
| 图集路径不匹配 | 中 | 中 | 多路径搜索机制 |
| 复杂 WidgetLook 渲染 | 中 | 中 | 分步实现，优先基础功能 |
| VS2013 兼容性 | 高 | 低 | 避免 C++14+ 特性 |

---

## 📚 参考资料

1. [CEGUI 0.7.1 Falagard 规范](http://cegui.org.uk/wiki/Falagard_XML_Reference)
2. [wxWidgets 3.0.5 文档](https://docs.wxwidgets.org/3.0/)
3. [OpenGL 2.1 参考](https://www.khronos.org/registry/OpenGL-Refpages/gl2.1/)
4. [CEImagesetEditor 技术债务清单](./CEImagesetEditor-技术债务清单.md)
5. [CEImagesetEditor 功能优化拓展方案](./CEImagesetEditor功能优化拓展方案.md)

---

**文档版本**: 1.0
**最后更新**: 2026-01-09
**状态**: 待审核与实施
**预计总工作量**: 10-13 天
