# CEImagesetEditor LookNFeel 功能扩展架构设计方案

> **版本**: 1.0
> **创建日期**: 2026-01-09
> **状态**: 实施完成，持续优化中
> **作者**: AI Architecture Assistant

---

## 1. 项目概述

### 1.1 目标

在 CEImagesetEditor-0.7.1 工具集中扩展功能，实现对 `client\resource\res\ui\looknfeel` 目录下 LookNFeel 文件的读取，并将相关图片资源在 GUI 界面中进行可视化展示。

### 1.2 技术环境

| 组件 | 版本 | 说明 |
|------|------|------|
| 编译器 | Visual C++ 9.0 (VS2008) / VS2013 v120 | Windows 平台编译 |
| GUI 框架 | wxWidgets 3.0.5 | 跨平台 GUI |
| 图形 API | OpenGL 2.1 | 纹理渲染 |
| XML 解析 | wxXmlDocument | LookNFeel 文件解析 |
| 图像库 | wxImage | 图像加载与处理 |

### 1.3 核心功能

1. **LookNFeel 文件解析**: 解析 CEGUI Falagard 格式的 `.looknfeel` XML 文件
2. **图片资源加载**: 通过 Imageset 缓存系统加载关联的纹理资源
3. **可视化渲染**: 使用 OpenGL 渲染 WidgetLook 的各种状态
4. **九宫格支持**: 完整支持 FrameComponent 的九宫格渲染
5. **GUI 集成**: 提供浏览器面板和对话框界面

---

## 2. 系统架构

### 2.1 整体架构图

```
┌─────────────────────────────────────────────────────────────────┐
│                        GUI 层                                   │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │ EditorFrame     │  │ DialogLookNFeel │  │ LookNFeelBrowser│ │
│  │ (主窗口)         │  │ Browser         │  │ (浏览器面板)     │ │
│  └────────┬────────┘  └────────┬────────┘  └────────┬────────┘ │
└───────────┼─────────────────────┼─────────────────────┼─────────┘
            │                     │                     │
            ▼                     ▼                     ▼
┌─────────────────────────────────────────────────────────────────┐
│                       渲染层                                    │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                  LookNFeelViewer                          │  │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐   │  │
│  │  │ 九宫格渲染   │  │ 三段式渲染  │  │ ImageryComponent │   │  │
│  │  │ NinePatch   │  │ ThreePiece  │  │ 渲染             │   │  │
│  │  └─────────────┘  └─────────────┘  └─────────────────┘   │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
            │                     │                     │
            ▼                     ▼                     ▼
┌─────────────────────────────────────────────────────────────────┐
│                       数据层                                    │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │ LookNFeelParser │  │ ImagesetCache   │  │ ResourcePath    │ │
│  │ (XML 解析器)     │  │ (图集缓存)       │  │ Manager         │ │
│  └────────┬────────┘  └────────┬────────┘  └────────┬────────┘ │
└───────────┼─────────────────────┼─────────────────────┼─────────┘
            │                     │                     │
            ▼                     ▼                     ▼
┌─────────────────────────────────────────────────────────────────┐
│                       存储层                                    │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │ .looknfeel 文件 │  │ .imageset 文件  │  │ 纹理文件         │ │
│  │ (XML)           │  │ (XML)           │  │ (PNG/TGA)       │ │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

### 2.2 模块职责

| 模块 | 文件 | 职责 |
|------|------|------|
| LookNFeelData | `inc/LookNFeelData.h` | 数据结构定义 |
| LookNFeelParser | `inc/LookNFeelParser.h`, `src/LookNFeelParser.cpp` | XML 解析 |
| ImagesetCache | `inc/ImagesetCache.h`, `src/ImagesetCache.cpp` | 图集缓存管理 |
| ResourcePathManager | `inc/ResourcePathManager.h`, `src/ResourcePathManager.cpp` | 资源路径解析 |
| LookNFeelViewer | `inc/LookNFeelViewer.h`, `src/LookNFeelViewer.cpp` | OpenGL 渲染 |
| LookNFeelBrowser | `inc/LookNFeelBrowser.h`, `src/LookNFeelBrowser.cpp` | 浏览器面板 |
| DialogLookNFeelBrowser | `inc/DialogLookNFeelBrowser.h`, `src/DialogLookNFeelBrowser.cpp` | 浏览对话框 |

---

## 3. 数据结构设计

### 3.1 核心数据结构

```cpp
namespace LookNFeel {

// 颜色矩形 - 四角颜色
struct ColourRect {
    wxColour topLeft, topRight, bottomLeft, bottomRight;
};

// 维度类型
enum DimType {
    DIM_ABSOLUTE,   // 绝对像素值
    DIM_UNIFIED,    // 统一值 (scale + offset)
    DIM_IMAGE       // 图像维度引用
};

// 维度值
struct Dim {
    DimType type;
    float absoluteValue;
    float scale, offset;
    wxString imageset, image, dimension;
};

// 区域定义
struct Area {
    Dim leftEdge, topEdge, width, height;
    Dim rightEdge, bottomEdge;
    bool hasWidth, hasHeight;
};

// 图片引用
struct ImageRef {
    wxString imageset;
    wxString image;
    wxString type;  // Background, LeftEdge, TopLeftCorner, etc.
};

// 框架组件 (九宫格)
struct FrameComponent {
    Area area;
    ImageRef background;
    ImageRef leftEdge, rightEdge, topEdge, bottomEdge;
    ImageRef topLeftCorner, topRightCorner;
    ImageRef bottomLeftCorner, bottomRightCorner;
    ColourRect colours;
    
    bool hasNinePatch() const;
    bool hasThreePieceH() const;
    bool hasThreePieceV() const;
};

// 图像组件
struct ImageryComponent {
    Area area;
    ImageRef image;
    wxString imageProperty;
    ColourRect colours;
};

// 图像区段
struct ImagerySection {
    wxString name;
    std::vector<FrameComponent> frameComponents;
    std::vector<ImageryComponent> imageryComponents;
};

// 状态图像
struct StateImagery {
    wxString name;
    std::vector<Layer> layers;
};

// WidgetLook 定义
struct WidgetLook {
    wxString name;
    std::map<wxString, ImagerySection> imagerySections;
    std::map<wxString, StateImagery> stateImageries;
};

// LookNFeel 文档
struct LookNFeelDocument {
    wxString filePath;
    std::map<wxString, WidgetLook> widgetLooks;
};

} // namespace LookNFeel
```

### 3.2 Imageset 缓存结构

```cpp
class ImagesetCache {
public:
    struct ImageRegion {
        wxString name;
        int x, y, width, height;
        wxPoint nativeHorzRes, nativeVertRes;
    };
    
    struct ImagesetInfo {
        wxString name;
        wxString textureFile;
        wxString textureFullPath;
        int nativeHorzRes, nativeVertRes;
        std::map<wxString, ImageRegion> images;
    };
    
private:
    std::map<wxString, ImagesetInfo> m_imagesets;
    std::vector<wxString> m_searchPaths;
};
```

---

## 4. TaharezLook/FrameWindow 深度分析

### 4.1 结构分析

`TaharezLook/FrameWindow` 是一个复杂的 WidgetLook，其九宫格渲染采用**分离式定义**：

```xml
<WidgetLook name="TaharezLook/FrameWindow">
    <!-- 每个部分独立定义 -->
    <ImagerySection name="TopLeftCorner">
        <ImageryComponent>
            <Image imageset="common" image="NewWindowTopLeftCorner"/>
        </ImageryComponent>
    </ImagerySection>
    
    <ImagerySection name="TopEdge">
        <ImageryComponent>
            <Image imageset="common" image="NewWindowTopEdge"/>
        </ImageryComponent>
    </ImagerySection>
    
    <!-- ... 其他 8 个部分 ... -->
    
    <!-- 状态组合所有部分 -->
    <StateImagery name="EnabledActive">
        <Layer>
            <Section section="TopLeftCorner"/>
            <Section section="TopEdge"/>
            <Section section="TopRightCorner"/>
            <Section section="LeftEdge"/>
            <Section section="Background"/>
            <Section section="RightEdge"/>
            <Section section="BottomLeftCorner"/>
            <Section section="BottomEdge"/>
            <Section section="BottomRightCorner"/>
        </Layer>
    </StateImagery>
</WidgetLook>
```

### 4.2 渲染挑战

1. **分离式九宫格**: 每个部分是独立的 `ImagerySection`，不是单一 `FrameComponent`
2. **区域计算**: 每个部分的 Area 可能使用 `UnifiedDim` 或 `ImageDim`
3. **层级叠加**: `StateImagery` 通过 `Layer` 和 `Section` 引用组合渲染

### 4.3 解决方案

#### 方案 A: 智能九宫格检测 (推荐)

在 `LookNFeelViewer::renderStateImagery()` 中增加九宫格检测逻辑：

```cpp
void LookNFeelViewer::renderStateImagery(const StateImagery& state)
{
    // 检测是否为分离式九宫格
    if (detectSeparatedNinePatch(state)) {
        renderSeparatedNinePatch(state);
        return;
    }
    
    // 常规渲染
    for (const Layer& layer : state.layers) {
        renderLayer(layer);
    }
}

bool LookNFeelViewer::detectSeparatedNinePatch(const StateImagery& state)
{
    // 检查是否包含九宫格的标准命名部分
    static const wxString ninePatchNames[] = {
        "TopLeftCorner", "TopEdge", "TopRightCorner",
        "LeftEdge", "Background", "RightEdge",
        "BottomLeftCorner", "BottomEdge", "BottomRightCorner"
    };
    
    int matchCount = 0;
    for (const Layer& layer : state.layers) {
        for (const SectionRef& ref : layer.sections) {
            for (const wxString& name : ninePatchNames) {
                if (ref.sectionName.Contains(name)) {
                    matchCount++;
                    break;
                }
            }
        }
    }
    
    return matchCount >= 5;  // 至少匹配 5 个部分
}
```

#### 方案 B: 区域感知渲染

根据每个 `ImagerySection` 的 `Area` 定义确定其在九宫格中的位置：

```cpp
void LookNFeelViewer::renderSeparatedNinePatch(const StateImagery& state)
{
    // 收集所有部分
    std::map<wxString, const ImagerySection*> parts;
    for (const Layer& layer : state.layers) {
        for (const SectionRef& ref : layer.sections) {
            const ImagerySection* section = m_widgetLook->getImagerySection(ref.sectionName);
            if (section) {
                parts[ref.sectionName] = section;
            }
        }
    }
    
    // 计算九宫格尺寸
    float cornerW = 0, cornerH = 0;
    if (parts.count("TopLeftCorner")) {
        // 从图片尺寸获取角落大小
        const ImageryComponent& comp = parts["TopLeftCorner"]->imageryComponents[0];
        const ImageRegion* region = ImagesetCache::getInstance()
            .getImageRegion(comp.image.imageset, comp.image.image);
        if (region) {
            cornerW = region->width;
            cornerH = region->height;
        }
    }
    
    // 渲染九个区域
    renderNinePatchPart(parts, "TopLeftCorner", 0, 0, cornerW, cornerH);
    renderNinePatchPart(parts, "TopEdge", cornerW, 0, m_previewWidth - 2*cornerW, cornerH);
    // ... 其他部分
}
```

---

## 5. 文件系统交互

### 5.1 资源路径解析

```cpp
class ResourcePathManager {
public:
    // 搜索路径优先级
    void addSearchPath(const wxString& path);
    
    // 查找文件
    wxString findImagesetFile(const wxString& name);
    wxString findTextureFile(const wxString& name);
    wxString findLookNFeelFile(const wxString& name);
    
private:
    std::vector<wxString> m_searchPaths;
    std::map<wxString, wxString> m_fileCache;
};
```

### 5.2 推荐搜索路径配置

```cpp
// 初始化搜索路径
ResourcePathManager& rpm = ResourcePathManager::getInstance();

// 资源根目录
rpm.addSearchPath("client/resource/res/ui");

// Imageset 目录
rpm.addSearchPath("client/resource/res/ui/imagesets");

// LookNFeel 目录
rpm.addSearchPath("client/resource/res/ui/looknfeel");

// 纹理目录
rpm.addSearchPath("client/resource/res/ui/imagesets");
rpm.addSearchPath("client/resource/res/ui/images");
```

---

## 6. 图片解析逻辑

### 6.1 Imageset 解析流程

```
1. 加载 .imageset XML 文件
2. 解析 <Imageset> 根节点
   - 获取 name, Imagefile 属性
3. 解析每个 <Image> 子节点
   - 获取 name, XPos, YPos, Width, Height
4. 缓存解析结果
```

### 6.2 纹理加载流程

```
1. 从 ImagesetCache 获取纹理文件路径
2. 使用 wxImage 加载图像
3. 检查纹理尺寸是否超过 GL_MAX_TEXTURE_SIZE
   - 如超过，自动缩放到允许的最大尺寸
4. 创建 OpenGL 纹理
5. 缓存纹理 ID 和原始/缩放后的尺寸
```

### 6.3 大图像处理

```cpp
unsigned int LookNFeelViewer::loadTextureFromImageset(const wxString& imagesetName)
{
    // ... 加载图像 ...
    
    // 检查纹理尺寸限制
    GLint maxSize;
    glGetIntegerv(GL_MAX_TEXTURE_SIZE, &maxSize);
    
    if (image.GetWidth() > maxSize || image.GetHeight() > maxSize) {
        // 计算缩放比例
        float scale = std::min(
            (float)maxSize / image.GetWidth(),
            (float)maxSize / image.GetHeight()
        );
        
        int newWidth = (int)(image.GetWidth() * scale);
        int newHeight = (int)(image.GetHeight() * scale);
        
        // 缩放图像
        image.Rescale(newWidth, newHeight, wxIMAGE_QUALITY_HIGH);
        
        // 记录缩放因子
        m_textureScaleFactors[imagesetName] = scale;
    }
    
    // 创建 OpenGL 纹理
    // ...
}
```

---

## 7. 界面渲染集成

### 7.1 LookNFeelViewer OpenGL 渲染流程

```cpp
void LookNFeelViewer::OnPaint(wxPaintEvent& event)
{
    wxPaintDC dc(this);
    SetCurrent(*m_glContext);
    
    // 1. 初始化 OpenGL (如果需要)
    if (!m_glInitialized) {
        initGL();
        m_glInitialized = true;
    }
    
    // 2. 设置视口和投影
    wxSize size = GetClientSize();
    glViewport(0, 0, size.x, size.y);
    setup2DProjection();
    
    // 3. 清除背景
    glClearColor(m_backgroundColour);
    glClear(GL_COLOR_BUFFER_BIT);
    
    // 4. 渲染内容
    renderBackground();
    if (m_showGrid) renderGrid();
    renderWidgetLook();
    if (m_showBorder) renderBorder();
    
    // 5. 刷新显示
    glFlush();
    SwapBuffers();
}
```

### 7.2 九宫格渲染

```cpp
void LookNFeelViewer::renderNinePatch(const FrameComponent& frame,
                                       float x, float y, float width, float height)
{
    // 获取角落尺寸
    float cornerW = getCornerWidth(frame);
    float cornerH = getCornerHeight(frame);
    
    // 确保角落不超过总尺寸
    if (cornerW * 2 > width) cornerW = width / 2;
    if (cornerH * 2 > height) cornerH = height / 2;
    
    float centerW = width - cornerW * 2;
    float centerH = height - cornerH * 2;
    
    // 渲染九个区域
    // 左上角
    renderImageRef(frame.topLeftCorner, x, y, cornerW, cornerH);
    // 上边
    renderImageRef(frame.topEdge, x + cornerW, y, centerW, cornerH);
    // 右上角
    renderImageRef(frame.topRightCorner, x + cornerW + centerW, y, cornerW, cornerH);
    // 左边
    renderImageRef(frame.leftEdge, x, y + cornerH, cornerW, centerH);
    // 中心
    renderImageRef(frame.background, x + cornerW, y + cornerH, centerW, centerH);
    // 右边
    renderImageRef(frame.rightEdge, x + cornerW + centerW, y + cornerH, cornerW, centerH);
    // 左下角
    renderImageRef(frame.bottomLeftCorner, x, y + cornerH + centerH, cornerW, cornerH);
    // 下边
    renderImageRef(frame.bottomEdge, x + cornerW, y + cornerH + centerH, centerW, cornerH);
    // 右下角
    renderImageRef(frame.bottomRightCorner, x + cornerW + centerW, y + cornerH + centerH, cornerW, cornerH);
}
```

---

## 8. 与现有组件集成

### 8.1 AsyncTextureLoader 集成

虽然 `AsyncTextureLoader` 是 Nuclear 引擎的异步加载组件，但 CEImagesetEditor 使用独立的 wxWidgets/OpenGL 实现。可以借鉴其设计思想：

```cpp
// 异步加载支持 (可选)
class AsyncImageLoader {
public:
    void loadAsync(const wxString& path, std::function<void(wxImage&)> callback);
    void processQueue();
    
private:
    std::queue<LoadRequest> m_requests;
    wxCriticalSection m_lock;
};
```

### 8.2 TiledTextureManager 参考

对于超大纹理，可以参考 `TiledTextureManager` 的分块加载策略：

```cpp
// 分块纹理管理 (可选优化)
class TiledTexture {
public:
    void load(const wxString& path, int tileSize = 1024);
    void render(float x, float y, float width, float height,
                float srcX, float srcY, float srcW, float srcH);
    
private:
    struct Tile {
        unsigned int textureId;
        int x, y, width, height;
    };
    std::vector<Tile> m_tiles;
};
```

---

## 9. 工程结构更新

### 9.1 新增文件列表

```
tools/CEImagesetEditor-0.7.1/
├── inc/
│   ├── LookNFeelData.h          # 数据结构定义
│   ├── LookNFeelParser.h        # XML 解析器
│   ├── ImagesetCache.h          # 图集缓存
│   ├── ResourcePathManager.h    # 资源路径管理
│   ├── LookNFeelViewer.h        # OpenGL 渲染器
│   ├── LookNFeelBrowser.h       # 浏览器面板
│   └── DialogLookNFeelBrowser.h # 浏览对话框
│
└── src/
    ├── LookNFeelParser.cpp
    ├── ImagesetCache.cpp
    ├── ResourcePathManager.cpp
    ├── LookNFeelViewer.cpp
    ├── LookNFeelBrowser.cpp
    └── DialogLookNFeelBrowser.cpp
```

### 9.2 vcxproj 更新

```xml
<ItemGroup>
  <!-- 新增头文件 -->
  <ClInclude Include="inc\LookNFeelData.h" />
  <ClInclude Include="inc\LookNFeelParser.h" />
  <ClInclude Include="inc\ImagesetCache.h" />
  <ClInclude Include="inc\ResourcePathManager.h" />
  <ClInclude Include="inc\LookNFeelViewer.h" />
  <ClInclude Include="inc\LookNFeelBrowser.h" />
  <ClInclude Include="inc\DialogLookNFeelBrowser.h" />
</ItemGroup>

<ItemGroup>
  <!-- 新增源文件 -->
  <ClCompile Include="src\LookNFeelParser.cpp" />
  <ClCompile Include="src\ImagesetCache.cpp" />
  <ClCompile Include="src\ResourcePathManager.cpp" />
  <ClCompile Include="src\LookNFeelViewer.cpp" />
  <ClCompile Include="src\LookNFeelBrowser.cpp" />
  <ClCompile Include="src\DialogLookNFeelBrowser.cpp" />
</ItemGroup>
```

---

## 10. 技术债务与优化计划

### 10.1 已解决问题

| 问题 | 状态 | 解决方案 |
|------|------|----------|
| 大图像加载失败 | ✅ 已解决 | 自动缩放到 GL_MAX_TEXTURE_SIZE |
| 资源路径解析 | ✅ 已解决 | 多路径搜索策略 |
| UI 本地化 | ✅ 已解决 | 全面中文翻译 |

### 10.2 待优化项目

| 优先级 | 问题 | 计划方案 |
|--------|------|----------|
| 高 | 分离式九宫格渲染 | 智能检测 + 区域感知渲染 |
| 中 | 外部 WidgetLook 引用 | 跨文档解析支持 |
| 中 | 动态属性渲染 | 属性值模拟系统 |
| 低 | 异步加载 | 线程池 + 队列 |
| 低 | 纹理分块 | 超大纹理分块加载 |

### 10.3 代码质量改进

1. **单元测试**: 为 LookNFeelParser 添加测试用例
2. **错误处理**: 增强 XML 解析错误报告
3. **内存管理**: 优化纹理缓存的 LRU 策略
4. **性能分析**: 添加渲染性能计时

---

## 11. 实施路径

### 阶段 1: 基础框架 (已完成)
- [x] 数据结构定义
- [x] XML 解析器
- [x] Imageset 缓存
- [x] 资源路径管理

### 阶段 2: 渲染引擎 (已完成)
- [x] OpenGL 渲染器
- [x] 基础九宫格支持
- [x] 纹理管理

### 阶段 3: GUI 集成 (已完成)
- [x] 浏览器面板
- [x] 浏览对话框
- [x] 菜单集成

### 阶段 4: 优化增强 (进行中)
- [x] 大图像处理
- [x] UI 本地化
- [ ] 分离式九宫格渲染
- [ ] 外部引用支持

### 阶段 5: 高级功能 (规划中)
- [ ] 编辑功能
- [ ] 导出功能
- [ ] 预设管理

---

## 12. 附录

### A. CEGUI Falagard 格式参考

- [CEGUI Falagard Tutorial](http://cegui.org.uk/wiki/CEGUI_In_Depth_-_Falagard_Skinning)
- [Falagard XML Reference](http://static.cegui.org.uk/docs/0.7.1/xml_falagard.html)

### B. 相关文档

- [CEImagesetEditor-技术债务清单.md](./CEImagesetEditor-技术债务清单.md)
- [CEImagesetEditor-新功能实现方案.md](./CEImagesetEditor-新功能实现方案.md)
- [CEImagesetEditor功能优化拓展方案.md](./CEImagesetEditor功能优化拓展方案.md)

---

**文档版本历史**

| 版本 | 日期 | 修改内容 |
|------|------|----------|
| 1.0 | 2026-01-09 | 初始版本，完整架构设计 |
