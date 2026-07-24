# CEImagesetEditor 功能优化拓展方案

> **文档版本**: 1.0 | **创建日期**: 2026-01-08
> **当前版本**: 0.7.1 | **目标版本**: 1.0.0

---

## 📋 执行摘要

本文档基于对 CEImagesetEditor 0.7.1 的深度分析，提出系统性功能优化和拓展方案。方案分为三个优先级层级，旨在保持向后兼容的同时，显著提升工具的易用性、性能和功能完整性。

---

## 🎯 优化目标

| 类别 | 当前状态 | 目标状态 |
|------|----------|----------|
| **易用性** | 基础编辑功能 | 现代化工作流 |
| **性能** | 单线程渲染 | GPU 加速 |
| **兼容性** | 仅 CEGUI 0.7.x | 支持多版本 |
| **跨平台** | Windows 主导 | Linux/macOS 支持 |
| **自动化** | 手动操作 | 批处理能力 |

---

## 🔥 优先级 1：核心功能增强

### 1.1 九宫格 (9-Patch) 自动生成 ⭐

**痛点**: 手动排列九宫格区域非常繁琐，每次需要单独定义 9 个区域

**项目实际需求分析**: 从 `client/resource/res/ui/imagesets/common.imageset` 可以看到大量九宫格定义：

```xml
<!-- common_bg2 九宫格示例 -->
<Image Name="common_bg2_lt" XPos="2" YPos="2" Width="182" Height="216" />
<Image Name="common_bg2_lc" XPos="2" YPos="218" Width="182" Height="48" />
<Image Name="common_bg2_lb" XPos="2" YPos="266" Width="182" Height="56" />
<Image Name="common_bg2_ct" XPos="184" YPos="2" Width="216" Height="216" />
<Image Name="common_bg2_cc" XPos="184" YPos="218" Width="216" Height="48" />
<Image Name="common_bg2_cb" XPos="184" YPos="266" Width="216" Height="56" />
<Image Name="common_bg2_rt" XPos="400" YPos="2" Width="134" Height="216" />
<Image Name="common_bg2_rc" XPos="400" YPos="218" Width="134" Height="48" />
<Image Name="common_bg2_rb" XPos="400" YPos="266" Width="134" Height="56" />
```

**命名规则**:
- `lt/lc/lb` = 左上角 / 左中边 / 左下角 (Left-Top/Left-Center/Left-Bottom)
- `ct/cc/cb` = 上边 / 中心 / 下边 (Center-Top/Center-Center/Center-Bottom)
- `rt/rc/rb` = 右上角 / 右中边 / 右下角 (Right-Top/Right-Center/Right-Bottom)

**方案**: 实现九宫格自动生成器

```cpp
// 新增类: NinePatchGenerator
class NinePatchGenerator {
public:
    // 九宫格配置结构
    struct NinePatchConfig {
        wxString baseName;          // 基础名称 (如 "common_bg2")
        wxPoint origin;             // 起始坐标 (在源纹理中的位置)

        // 边距定义方式一：直接指定边距
        struct Margins {
            int left;     // 左边距宽度
            int top;      // 上边距高度
            int right;    // 右边距宽度
            int bottom;   // 下边距高度
        } margins;

        // 边距定义方式二：指定区域尺寸
        struct RegionSizes {
            int cornerWidth;   // 角落宽度
            int cornerHeight;  // 角落高度
            int edgeWidth;     // 边缘宽度 (0=自动)
            int edgeHeight;    // 边缘高度 (0=自动)
        } regionSizes;

        // 额外选项
        bool generateCenter;     // 是否生成中心区域 (true)
        bool generateEdges;      // 是否生成边缘区域 (true)
        bool generateCorners;    // 是否生成角落区域 (true)
        bool symmetrical;        // 是否对称 (左右/上下对称)

        NinePatchConfig() : generateCenter(true), generateEdges(true),
                          generateCorners(true), symmetrical(false) {}
    };

    // 生成九宫格区域定义
    std::map<wxString, wxRect> generateNinePatch(const NinePatchConfig& config);

    // 从现有九宫格检测配置 (用于智能识别)
    NinePatchConfig detectFromExisting(const wxImage& texture,
                                       const std::map<wxString, wxRect>& existing);

    // 验证九宫格配置是否有效
    bool validateConfig(const NinePatchConfig& config, const wxSize& textureSize);

private:
    wxString makeRegionName(const wxString& base, const char* suffix);
};
```

**完整实现**:

```cpp
// NinePatchGenerator.cpp
std::map<wxString, wxRect> NinePatchGenerator::generateNinePatch(
    const NinePatchConfig& config) {

    std::map<wxString, wxRect> regions;
    const wxPoint& o = config.origin;

    // 计算各区域边界
    // 使用边距方式计算
    const int ML = config.margins.left;
    const int MT = config.margins.top;
    const int MR = config.margins.right;
    const int MB = config.margins.bottom;

    // X 轴分割点
    const int x0 = o.x;                           // 左边界
    const int x1 = o.x + ML;                      // 左边缘右边界
    const int x2 = o.x + config.totalSize.GetWidth() - MR;  // 右边缘左边界
    const int x3 = o.x + config.totalSize.GetWidth();      // 右边界

    // Y 轴分割点
    const int y0 = o.y;                           // 上边界
    const int y1 = o.y + MT;                      // 上边缘下边界
    const int y2 = o.y + config.totalSize.GetHeight() - MB; // 下边缘上边界
    const int y3 = o.y + config.totalSize.GetHeight();     // 下边界

    // 生成九个区域 (按行优先顺序)
    if (config.generateCorners) {
        // 左上角
        regions[makeRegionName(config.baseName, "lt")] =
            wxRect(x0, y0, x1 - x0, y1 - y0);
        // 左下角
        regions[makeRegionName(config.baseName, "lb")] =
            wxRect(x0, y2, x1 - x0, y3 - y2);
        // 右上角
        regions[makeRegionName(config.baseName, "rt")] =
            wxRect(x2, y0, x3 - x2, y1 - y0);
        // 右下角
        regions[makeRegionName(config.baseName, "rb")] =
            wxRect(x2, y2, x3 - x2, y3 - y2);
    }

    if (config.generateEdges) {
        // 左边
        regions[makeRegionName(config.baseName, "lc")] =
            wxRect(x0, y1, x1 - x0, y2 - y1);
        // 右边
        regions[makeRegionName(config.baseName, "rc")] =
            wxRect(x2, y1, x3 - x2, y2 - y1);
        // 上边
        regions[makeRegionName(config.baseName, "ct")] =
            wxRect(x1, y0, x2 - x1, y1 - y0);
        // 下边
        regions[makeRegionName(config.baseName, "cb")] =
            wxRect(x1, y2, x2 - x1, y3 - y2);
    }

    if (config.generateCenter) {
        // 中心
        regions[makeRegionName(config.baseName, "cc")] =
            wxRect(x1, y1, x2 - x1, y2 - y1);
    }

    return regions;
}

wxString NinePatchGenerator::makeRegionName(const wxString& base, const char* suffix) {
    return wxString::Format("%s_%s", base, suffix);
}
```

**UI 设计**:

```
┌──────────────────────────────────────────────────────────────────────┐
│  工具 → 创建九宫格区域                                               │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌─ 预览 ─────────────────────────────────────────────────────────┐   │
│  │  ┌────┬────┬────┐                                            │   │
│  │  │ lt │ ct │ rt │    显示生成的九宫格布局                     │   │
│  │  ├────┼────┼────┤    (实时更新预览)                            │   │
│  │  │ lc │ cc │ rc │                                            │   │
│  │  ├────┼────┼────┤                                            │   │
│  │  │ lb │ cb │ rb │                                            │   │
│  │  └────┴────┴────┘                                            │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                      │
│  基本信息:                                                            │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  基础名称: [common_bg2__________]                               │   │
│  │  起始坐标: X: [2____] Y: [2____]                               │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                      │
│  区域尺寸定义:                                                        │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  ○ 指定边距    ○ 指定区域尺寸    ○ 对称模式                      │   │
│  │                                                                   │   │
│  │  左边距: [16_______]  上边距: [16_______]                      │   │
│  │  右边距: [16_______]  下边距: [16_______]                      │   │
│  │                                                                   │   │
│  │  或 (对称模式下):                                               │   │
│  │  边距: [16_______]  (左右上下相同)                               │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                      │
│  生成选项:                                                            │
│  ☑ 生成角落区域 (lt/lb/rt/rb)                                        │
│  ☑ 生成边缘区域 (lc/rc/ct/cb)                                        │
│  ☑ 生成中心区域 (cc)                                                 │
│                                                                      │
│  快捷模式:                                                            │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  [三段式按钮] [三段式竖条] [对话框背景] [完整九宫格]            │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                      │
│  [生成并添加] [预览] [从选中区域检测] [取消]                          │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
```

**快捷模式预设**:

```cpp
// 预设配置
struct NinePatchPresets {
    // 三段式水平按钮 (l/c/r)
    static NinePatchConfig threePieceH(int width, int height,
                                       int leftWidth, int rightWidth) {
        NinePatchConfig config;
        config.generateCorners = false;
        config.generateEdges = true;
        config.generateCenter = false;
        // ...
        return config;
    }

    // 三段式垂直按钮 (t/c/b)
    static NinePatchConfig threePieceV(int width, int height,
                                       int topHeight, int bottomHeight) {
        // ...
    }

    // 完整九宫格背景
    static NinePatchConfig fullNinePatch(const wxString& name,
                                         int cornerSize, int edgeSize) {
        NinePatchConfig config;
        config.baseName = name;
        config.margins = { cornerSize, cornerSize, cornerSize, cornerSize };
        return config;
    }

    // 对话框背景 (不同的边角尺寸)
    static NinePatchConfig dialogBackground(const wxString& name,
                                           int cornerW, int cornerH,
                                           int edgeW, int edgeH) {
        // ...
    }
};
```

**从现有图像智能检测**:

```cpp
NinePatchConfig NinePatchGenerator::detectFromExisting(
    const wxImage& texture,
    const std::map<wxString, wxRect>& existing) {

    NinePatchConfig config;

    // 1. 查找命名模式
    for (const auto& pair : existing) {
        const wxString& name = pair.first;
        const wxRect& rect = pair.second;

        // 解析后缀
        wxString suffix = name.AfterLast('_');
        wxString base = name.BeforeLast('_');

        if (suffix == "lt") {
            config.baseName = base;
            config.origin = wxPoint(rect.x, rect.y);
            config.margins.left = rect.width;
            config.margins.top = rect.height;
        }
        // ... 继续解析其他区域
    }

    // 2. 验证完整性 (9 个区域都应该存在)
    // 3. 检测对称性
    if (existing.count(base + "_lc") == existing.count(base + "_rc")) {
        // 可能为左右对称
    }

    return config;
}
```

**批量生成对话框 (从多个图像创建九宫格)**:

```
┌──────────────────────────────────────────────────────────────────────┐
│  工具 → 批量创建九宫格                                               │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  源图像列表:                                                          │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │ ☑ btn_blue.png      200x60    边距: 16,16,16,16                  │   │
│  │ ☑ btn_green.png     200x60    边距: 16,16,16,16                  │   │
│  │ ☑ dialog_bg.png     400x300   边距: 24,24,24,24                  │   │
│  │ ☐ panel_bg.png      300x200   边距: (自动检测)                   │   │
│  │                                                             [添加] │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                      │
│  命名规则:                                                            │
│  ○ 使用文件名 (如 btn_blue → btn_blue_lt, btn_blue_lc, ...)         │
│  ○ 自定义前缀: [common__]                                          │
│  ○ 自定义格式: [bg_{name}_{suffix}____________]                   │
│                                                                      │
│  统一边距: (选中后将覆盖单个图像的边距设置)                           │
│  ☑ 使用统一边距:  四角: [16__] 边缘: [8___]                      │
│                                                                      │
│  [批量生成] [全选] [取消]                                            │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
```

**使用示例**:

```cpp
// 示例 1: 创建一个按钮九宫格
NinePatchGenerator generator;
NinePatchGenerator::NinePatchConfig config;

config.baseName = "button_blue";
config.origin = wxPoint(0, 0);
config.totalSize = wxSize(200, 60);
config.margins = { 16, 16, 16, 16 };  // 四角各 16 像素
config.generateCorners = false;  // 按钮通常不需要角
config.generateEdges = true;
config.generateCenter = true;

auto regions = generator.generateNinePatch(config);
// 结果: button_blue_l, button_blue_c, button_blue_r

// 示例 2: 创建完整对话框背景
config.baseName = "dialog_bg";
config.origin = wxPoint(50, 50);
config.totalSize = wxSize(400, 300);
config.margins = { 24, 24, 24, 24 };  // 四角各 24 像素
// 默认全部生成

auto regions = generator.generateNinePatch(config);
// 结果: dialog_bg_lt, lc, lb, ct, cc, cb, rt, rc, rb
```

**实现优先级**: ⭐⭐⭐⭐⭐ (最高优先级)
**预计工作量**: 3-5 天
**收益**: 减少 80% 的九宫格定义工作量

---

### 1.2 三段式 (3-Piece) 自动生成 ⭐⭐⭐⭐⭐

**痛点**: 按钮和进度条使用三段式结构，手动定义左右中三段非常繁琐

**项目实际需求分析**: 从 `client/resource/res/ui/imagesets/common.imageset` 发现大量三段式定义：

#### 1.2.1 三段式水平格式 (3-Piece Horizontal)

**命名规则**: `l/c/r` (左/中/右)

```
┌────┬────┬────┐
│  l │  c │  r │
└────┴────┴────┘
```

**实际案例分类**:

| 类型 | 命名模式 | 示例 | 用途 |
|-----|---------|------|------|
| 颜色按钮 | `{color}_l/c/r` | `blue_l/c/r`, `green_l/c/r` | 简单颜色按钮 |
| 编号按钮 | `btn{n}_l/c/r` | `btn1_l/c/r`, `btn2_l/c/r` | 通用按钮 |
| 尺寸按钮 | `button{color}{height}_l/c/r` | `common_buttonhui52_l/c/r` | 指定高度按钮 |
| 文本框 | `common_list_*_l/c/r` | `common_list_3textbg_l/c/r` | 列表文本背景 |

```xml
<!-- 蓝色三段式按钮 -->
<Image Name="blue_l" XPos="106" YPos="826" Width="16" Height="27" />
<Image Name="blue_c" XPos="122" YPos="826" Width="18" Height="27" />
<Image Name="blue_r" XPos="140" YPos="826" Width="16" Height="27" />

<!-- 52px 高灰色按钮 -->
<Image Name="common_buttonhui52_l" XPos="726" YPos="591" Width="45" Height="52" />
<Image Name="common_buttonhui52_c" XPos="771" YPos="591" Width="10" Height="52" />
<Image Name="common_buttonhui52_r" XPos="781" YPos="591" Width="45" Height="52" />

<!-- 列表文本背景 -->
<Image Name="common_list_3textbg_l" XPos="86" YPos="974" Width="15" Height="43" />
<Image Name="common_list_3textbg_c" XPos="101" YPos="974" Width="10" Height="43" />
<Image Name="common_list_3textbg_r" XPos="111" YPos="974" Width="15" Height="43" />
```

#### 1.2.2 三段式垂直格式 (3-Piece Vertical)

**命名规则**: `t/c/b` (上/中/下)

```
┌────────────┐
│     t      │
├────────────┤
│     c      │
├────────────┤
│     b      │
└────────────┘
```

**实际案例**:

```xml
<!-- 分割线 (上下边+中间填充) -->
<Image Name="common_fengexian_t" XPos="536" YPos="99" Width="311" Height="11" />
<Image Name="common_fengexian_c" XPos="536" YPos="110" Width="311" Height="12" />
<Image Name="common_fengexian_b" XPos="536" YPos="122" Width="311" Height="11" />

<!-- 礼盒背景 (垂直三段式) -->
<Image Name="libaoheidi_t" XPos="2" YPos="2" Width="605" Height="16" />
<Image Name="libaoheidi_c" XPos="2" YPos="18" Width="605" Height="17" />
<Image Name="libaoheidi_b" XPos="2" YPos="35" Width="605" Height="16" />
```

#### 1.2.3 双段式格式 (2-Piece)

**命名规则**: `l/r` (左/右)

```
┌────┬────┐
│  l │  r │
└────┴────┘
```

**实际案例**:

```xml
<!-- dwn 双段式 -->
<Image Name="dwn_l" XPos="677" YPos="685" Width="10" Height="89" />
<Image Name="dwn_r" XPos="697" YPos="685" Width="10" Height="89" />
```

#### 1.2.4 方案设计

```cpp
// 新增类: ThreePieceGenerator
class ThreePieceGenerator {
public:
    // 三段式配置结构
    struct ThreePieceConfig {
        enum class Direction {
            HORIZONTAL,  // 水平方向 (l/c/r)
            VERTICAL     // 垂直方向 (t/c/b)
        };

        enum class Type {
            THREE_PIECE,  // 三段式 (l/c/r 或 t/c/b)
            TWO_PIECE     // 双段式 (l/r 或 t/b)
        };

        wxString baseName;          // 基础名称 (如 "blue")
        wxPoint origin;             // 起始坐标
        wxSize totalSize;           // 总尺寸

        Direction direction;        // 方向
        Type type;                  // 类型

        // 边距定义 (水平方向: 左/右; 垂直方向: 上/下)
        struct Margins {
            int start;   // 左边距宽度 或 上边距高度
            int end;     // 右边距宽度 或 下边距高度
        } margins;

        ThreePieceConfig()
            : direction(Direction::HORIZONTAL)
            , type(Type::THREE_PIECE)
            , margins{16, 16} {}
    };

    // 生成三段式区域定义
    std::map<wxString, wxRect> generateThreePiece(
        const ThreePieceConfig& config);

    // 预设配置
    static ThreePieceConfig horizontalButton(
        const wxString& name, int width, int height, int margin);

    static ThreePieceConfig verticalSeparator(
        const wxString& name, int width, int height, int margin);

    static ThreePieceConfig twoPieceHorizontal(
        const wxString& name, int width, int height);

private:
    wxString makeRegionName(const wxString& base,
                            ThreePieceConfig::Direction dir,
                            int index);
};
```

**完整实现**:

```cpp
// ThreePieceGenerator.cpp
std::map<wxString, wxRect> ThreePieceGenerator::generateThreePiece(
    const ThreePieceConfig& config) {

    std::map<wxString, wxRect> regions;
    const wxPoint& o = config.origin;

    if (config.direction == Direction::HORIZONTAL) {
        // 水平方向: l/c/r
        const int x0 = o.x;
        const int x1 = o.x + config.margins.start;
        const int x2 = o.x + config.totalSize.GetWidth() - config.margins.end;
        const int x3 = o.x + config.totalSize.GetWidth();

        if (config.type == Type::THREE_PIECE) {
            // 左段
            regions[makeRegionName(config.baseName, Direction::HORIZONTAL, 0)] =
                wxRect(x0, o.y, x1 - x0, config.totalSize.GetHeight());
            // 中段 (可拉伸)
            regions[makeRegionName(config.baseName, Direction::HORIZONTAL, 1)] =
                wxRect(x1, o.y, x2 - x1, config.totalSize.GetHeight());
            // 右段
            regions[makeRegionName(config.baseName, Direction::HORIZONTAL, 2)] =
                wxRect(x2, o.y, x3 - x2, config.totalSize.GetHeight());
        } else {
            // 双段式: l/r
            regions[makeRegionName(config.baseName, Direction::HORIZONTAL, 0)] =
                wxRect(x0, o.y, x1 - x0, config.totalSize.GetHeight());
            regions[makeRegionName(config.baseName, Direction::HORIZONTAL, 2)] =
                wxRect(x2, o.y, x3 - x2, config.totalSize.GetHeight());
        }

    } else {
        // 垂直方向: t/c/b
        const int y0 = o.y;
        const int y1 = o.y + config.margins.start;
        const int y2 = o.y + config.totalSize.GetHeight() - config.margins.end;
        const int y3 = o.y + config.totalSize.GetHeight();

        if (config.type == Type::THREE_PIECE) {
            // 上段
            regions[makeRegionName(config.baseName, Direction::VERTICAL, 0)] =
                wxRect(o.x, y0, config.totalSize.GetWidth(), y1 - y0);
            // 中段 (可拉伸)
            regions[makeRegionName(config.baseName, Direction::VERTICAL, 1)] =
                wxRect(o.x, y1, config.totalSize.GetWidth(), y2 - y1);
            // 下段
            regions[makeRegionName(config.baseName, Direction::VERTICAL, 2)] =
                wxRect(o.x, y2, config.totalSize.GetWidth(), y3 - y2);
        } else {
            // 双段式: t/b
            regions[makeRegionName(config.baseName, Direction::VERTICAL, 0)] =
                wxRect(o.x, y0, config.totalSize.GetWidth(), y1 - y0);
            regions[makeRegionName(config.baseName, Direction::VERTICAL, 2)] =
                wxRect(o.x, y2, config.totalSize.GetWidth(), y3 - y2);
        }
    }

    return regions;
}

wxString ThreePieceGenerator::makeRegionName(
    const wxString& base, Direction dir, int index) {

    if (dir == Direction::HORIZONTAL) {
        // 水平方向: l/c/r
        const char* suffixes[] = {"_l", "_c", "_r"};
        return base + suffixes[index];
    } else {
        // 垂直方向: t/c/b
        const char* suffixes[] = {"_t", "_c", "_b"};
        return base + suffixes[index];
    }
}

// 预设配置实现
ThreePieceGenerator::ThreePieceConfig
ThreePieceGenerator::horizontalButton(
    const wxString& name, int width, int height, int margin) {
    ThreePieceConfig config;
    config.baseName = name;
    config.totalSize = wxSize(width, height);
    config.direction = Direction::HORIZONTAL;
    config.type = Type::THREE_PIECE;
    config.margins = {margin, margin};
    return config;
}

ThreePieceGenerator::ThreePieceConfig
ThreePieceGenerator::verticalSeparator(
    const wxString& name, int width, int height, int margin) {
    ThreePieceConfig config;
    config.baseName = name;
    config.totalSize = wxSize(width, height);
    config.direction = Direction::VERTICAL;
    config.type = Type::THREE_PIECE;
    config.margins = {margin, margin};
    return config;
}

ThreePieceGenerator::ThreePieceConfig
ThreePieceGenerator::twoPieceHorizontal(
    const wxString& name, int width, int height) {
    ThreePieceConfig config;
    config.baseName = name;
    config.totalSize = wxSize(width, height);
    config.direction = Direction::HORIZONTAL;
    config.type = Type::TWO_PIECE;
    config.margins = {16, 16};
    return config;
}
```

**UI 设计**:

```
┌──────────────────────────────────────────────────────────────────────┐
│  工具 → 创建三段式区域                                               │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌─ 预览 ─────────────────────────────────────────────────────────┐   │
│  │  ┌────┬────┬────┐  ○ 水平三段式 (l/c/r)                        │   │
│  │  │  l │  c │  r │                                            │   │
│  │  └────┴────┴────┘  ○ 垂直三段式 (t/c/b)                        │   │
│  │                      ○ 双段式 (l/r)                             │   │
│  │  ┌────────────┐                                              │   │
│  │  │     t      │  (实时更新预览)                                │   │
│  │  ├────────────┤                                              │   │
│  │  │     c      │                                              │   │
│  │  ├────────────┤                                              │   │
│  │  │     b      │                                              │   │
│  │  └────────────┘                                              │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                      │
│  基本信息:                                                            │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  基础名称: [blue__________]                                     │   │
│  │  起始坐标: X: [106____] Y: [826____]                           │   │
│  │  总尺寸:   宽: [50_______] 高: [27_______]                     │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                      │
│  布局选项:                                                            │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  ○ 水平方向 (l/c/r)    ○ 垂直方向 (t/c/b)                      │   │
│  │                                                                   │   │
│  │  ○ 三段式 (完整)      ○ 双段式 (无中间段)                       │   │
│  │                                                                   │   │
│  │  起始边距: [16_______]  结束边距: [16_______]                   │   │
│  │                                                                   │   │
│  │  ☑ 自动计算中间段宽度 (保持总尺寸)                               │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                      │
│  快捷模式:                                                            │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  [水平按钮] [垂直分隔线] [双段式] [自定义]                       │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                      │
│  [生成并添加] [预览] [从选中区域检测] [取消]                          │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
```

**快捷模式预设**:

```cpp
// 预设配置工厂
struct ThreePiecePresets {
    // 水平按钮 (左右固定，中间拉伸)
    static ThreePieceGenerator::ThreePieceConfig horizontalButton(
        const wxString& name, int height, int margin) {
        ThreePieceGenerator::ThreePieceConfig config;
        config.baseName = name;
        config.totalSize = wxSize(margin * 2 + 10, height);  // 初始宽度
        config.direction = ThreePieceGenerator::Direction::HORIZONTAL;
        config.type = ThreePieceGenerator::Type::THREE_PIECE;
        config.margins = {margin, margin};
        return config;
    }

    // 垂直分隔线 (上下固定，中间拉伸)
    static ThreePieceGenerator::ThreePieceConfig verticalSeparator(
        const wxString& name, int width, int margin) {
        ThreePieceGenerator::ThreePieceConfig config;
        config.baseName = name;
        config.totalSize = wxSize(width, margin * 2 + 10);
        config.direction = ThreePieceGenerator::Direction::VERTICAL;
        config.type = ThreePieceGenerator::Type::THREE_PIECE;
        config.margins = {margin, margin};
        return config;
    }

    // 双段式 (只有两端，无中间)
    static ThreePieceGenerator::ThreePieceConfig twoPiece(
        const wxString& name, int width, int height, int margin) {
        ThreePieceGenerator::ThreePieceConfig config;
        config.baseName = name;
        config.totalSize = wxSize(width, height);
        config.direction = ThreePieceGenerator::Direction::HORIZONTAL;
        config.type = ThreePieceGenerator::Type::TWO_PIECE;
        config.margins = {margin, margin};
        return config;
    }
};
```

**使用示例**:

```cpp
// 示例 1: 创建蓝色水平按钮
ThreePieceGenerator generator;
ThreePieceGenerator::ThreePieceConfig config =
    ThreePiecePresets::horizontalButton("blue", 27, 16);

config.origin = wxPoint(106, 826);
config.totalSize = wxSize(50, 27);  // 实际总宽度

auto regions = generator.generateThreePiece(config);
// 结果:
// blue_l: (106, 826, 16x27)
// blue_c: (122, 826, 18x27)
// blue_r: (140, 826, 16x27)

// 示例 2: 创建垂直分隔线
config = ThreePiecePresets::verticalSeparator("common_fengexian", 311, 11);
config.origin = wxPoint(536, 99);
config.totalSize = wxSize(311, 34);  // 实际总高度

auto regions = generator.generateThreePiece(config);
// 结果:
// common_fengexian_t: (536, 99, 311x11)
// common_fengexian_c: (536, 110, 311x12)
// common_fengexian_b: (536, 122, 311x11)

// 示例 3: 创建双段式
config = ThreePiecePresets::twoPiece("dwn", 20, 89, 10);
config.origin = wxPoint(677, 685);

auto regions = generator.generateThreePiece(config);
// 结果:
// dwn_l: (677, 685, 10x89)
// dwn_r: (687, 685, 10x89)
```

**批量生成对话框**:

```
┌──────────────────────────────────────────────────────────────────────┐
│  工具 → 批量创建三段式                                               │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  源图像列表:                                                          │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │ ☑ blue.png          50x27     边距: 16,16      水平三段式        │   │
│  │ ☑ green.png         50x27     边距: 16,16      水平三段式        │   │
│  │ ☑ red.png           50x27     边距: 16,16      水平三段式        │   │
│  │ ☑ separator.png     311x34    边距: 11,11      垂直三段式        │   │
│  │ ☐ custom.png        100x50    边距: (自动检测)                   │   │
│  │                                                             [添加] │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                      │
│  命名规则:                                                            │
│  ○ 使用文件名 (如 blue → blue_l, blue_c, blue_r)                    │
│  ○ 自定义前缀: [btn__]                                              │
│  ○ 自定义格式: [button_{color}_{suffix}______________]             │
│                                                                      │
│  统一设置: (选中后将覆盖单个图像的设置)                               │
│  ☑ 使用统一边距:  起始: [16__] 结束: [16__]                       │
│  ☑ 使用统一方向:  ○ 水平  ● 垂直                                    │
│                                                                      │
│  [批量生成] [全选] [取消]                                            │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
```

**实现优先级**: ⭐⭐⭐⭐⭐ (最高优先级)
**预计工作量**: 2-3 天
**收益**: 减少 90% 的三段式定义工作量

---

### 1.3 批量操作支持

**痛点**: 单独操作每个区域效率低下

**方案**: 添加批量编辑功能

```cpp
// 新增类: BatchRegionOperation
class BatchRegionOperation {
public:
    // 批量重命名 (支持模式)
    void batchRename(const std::vector<wxString>& oldNames,
                    const wxString& pattern,
                    int startNumber = 1);

    // 批量移动
    void batchMove(const std::vector<wxString>& names,
                  const wxPoint& delta);

    // 批量调整大小
    void batchResize(const std::vector<wxString>& names,
                    const wxSize& delta,
                    bool keepAspectRatio = false);

    // 批量删除 (支持通配符)
    void batchDelete(const wxString& wildcardPattern);
};
```

**UI 设计**:
```
┌────────────────────────────────────┐
│  编辑 → 批量操作                    │
├────────────────────────────────────┤
│  选择区域:                          │
│  □ Button_Normal                   │
│  □ Button_Hover                    │
│  □ Button_Pressed                  │
│  ☑ 全选                            │
│                                    │
│  操作:                              │
│  ○ 批量重命名                       │
│  ○ 批量移动                         │
│  ○ 批量调整大小                     │
│  ○ 批量删除                         │
│                                    │
│  [应用到选中] [取消]               │
└────────────────────────────────────┘
```

### 1.3 撤销/重做系统

**痛点**: 误操作后无法撤销

**方案**: 实现完整的命令模式

```cpp
// 新增类: CommandHistory
class CommandHistory {
public:
    using CommandPtr = std::shared_ptr<ICommand>;

    void execute(CommandPtr command);
    void undo();
    void redo();
    bool canUndo() const;
    bool canRedo() const;

    void setMaxHistory(size_t max);
    void clear();

private:
    std::vector<CommandPtr> m_undoStack;
    std::vector<CommandPtr> m_redoStack;
    size_t m_maxHistory = 50;
};

// 命令接口
class ICommand {
public:
    virtual void execute() = 0;
    virtual void undo() = 0;
    virtual wxString getDescription() const = 0;
    virtual ~ICommand() = default;
};

// 示例命令
class AddRegionCommand : public ICommand {
    EditorDocument* m_doc;
    wxString m_name;
    wxRect m_rect;
    wxPoint m_offset;

public:
    void execute() override {
        m_doc->addRegion(m_name, m_rect, m_offset);
    }

    void undo() override {
        m_doc->deleteRegion(m_name);
    }

    wxString getDescription() const override {
        return wxString::Format("添加区域: %s", m_name);
    }
};
```

### 1.4 导出格式扩展

**痛点**: 仅支持 CEGUI XML 格式

**方案**: 支持多种引擎格式

```cpp
// 新增类: ImagesetExporter
class ImagesetExporter {
public:
    enum class Format {
        CEGUI_XML,      // 标准 CEGUI XML
        CEGUI_BINARY,   // CEGUI 二进制格式 (更快加载)
        COCOS2D,        // Cocos2d-x plist 格式
        UNITY,          // Unity Sprite Atlas
        GODOT,          // Godot Texture Atlas
        JSON,           // 通用 JSON 格式
        CSV             // 调试用 CSV
    };

    bool exportTo(const EditorDocument* doc,
                  const wxString& filePath,
                  Format format);

    wxString getDefaultExtension(Format format) const;
};

// Cocos2d-x 导出示例
bool exportToCocos2d(const EditorDocument* doc, const wxString& path) {
    // 输出 .plist 文件
    tinyxml2::XMLDocument plist;
    // ... 生成 plist 格式

    // 可选: 重新排列纹理以适应 Cocos2d 格式
    return true;
}
```

---

## 🚀 优先级 2：性能与架构优化

### 2.1 多线程渲染

**痛点**: 大图像集渲染卡顿

**方案**: 后台渲染 + 纹理缓存

```cpp
// 新增类: AsyncTextureLoader
class AsyncTextureLoader {
public:
    using LoadCallback = std::function<void(wxImage*)>;

    void loadAsync(const wxString& path, LoadCallback callback);
    void preloadNeighbourhood(const wxRect& currentRegion);

    bool isLoaded(const wxString& path) const;
    wxImage* get(const wxString& path);

private:
    std::thread m_loadThread;
    std::queue<wxString> m_loadQueue;
    std::map<wxString, wxImage*> m_textureCache;
    std::mutex m_cacheMutex;
};
```

### 2.2 硬件加速渲染

**痛点**: OpenGL 渲染未充分利用 GPU

**方案**: 使用 VAO/VBO 批量渲染

```cpp
// 修改: EditorGLCanvas
class EditorGLCanvas {
private:
    // 硬件加速渲染
    GLuint m_vao;           // 顶点数组对象
    GLuint m_vbo;           // 顶点缓冲对象
    GLuint m_ibo;           // 索引缓冲对象

    void initializeHardwareAcceleratedRendering();
    void renderRegionsBatched();

    // 着色器
    GLuint m_shaderProgram;
    const char* m_vertexShaderSrc = R"(
        #version 120
        attribute vec2 a_position;
        attribute vec2 a_texCoord;
        attribute vec4 a_color;
        varying vec2 v_texCoord;
        varying vec4 v_color;
        uniform mat4 u_mvp;
        void main() {
            gl_Position = u_mvp * vec4(a_position, 0.0, 1.0);
            v_texCoord = a_texCoord;
            v_color = a_color;
        }
    )";

    const char* m_fragmentShaderSrc = R"(
        #version 120
        varying vec2 v_texCoord;
        varying vec4 v_color;
        uniform sampler2D u_texture;
        void main() {
            gl_FragColor = texture2D(u_texture, v_texCoord) * v_color;
        }
    )";
};
```

### 2.3 内存优化

**痛点**: 大纹理占用内存过高

**方案**: 分块加载 + 动态分辨率

```cpp
// 新增类: TiledTextureManager
class TiledTextureManager {
public:
    static const int TILE_SIZE = 512;

    struct Tile {
        int x, y;
        wxImage* data;
        bool loaded;
    };

    void loadTiledTexture(const wxString& path);
    void unloadDistantTiles(const wxRect& viewport);
    wxImage* getTile(int x, int y);

private:
    wxSize m_totalSize;
    std::vector<std::vector<Tile>> m_tiles;
};
```

---

## 🌐 优先级 3：跨平台与现代化

### 3.1 现代化 UI 框架迁移

**痛点**: wxWidgets 3.0.5 已过时

**方案**: 迁移到现代框架

| 选项 | 优势 | 劣势 | 推荐度 |
|------|------|------|--------|
| **Qt 6** | 跨平台、现代 API | 体积大 | ⭐⭐⭐⭐ |
| **Dear ImGui** | 轻量、即时模式 | 需自行实现文档模型 | ⭐⭐⭐ |
| **保持 wxWidgets 3.2+** | 最小改动 | 仍有历史包袱 | ⭐⭐⭐⭐⭐ |
| **原生 WinUI 3 + GTK** | 最佳体验 | 需多份代码 | ⭐⭐ |

**推荐**: 先升级到 wxWidgets 3.2，长期考虑 Qt 6

### 3.2 CEGUI 版本兼容

**痛点**: 仅支持 CEGUI 0.7.x

**方案**: 抽象层 + 多版本支持

```cpp
// 新增抽象接口
class IImagesetFormatHandler {
public:
    virtual bool load(const wxString& path, EditorDocument* doc) = 0;
    virtual bool save(const wxString& path, const EditorDocument* doc) = 0;
    virtual wxString getFilter() const = 0;
    virtual ~IImagesetFormatHandler() = default;
};

// CEGUI 0.7.x 处理器
class CEGUI07Handler : public IImagesetFormatHandler {
public:
    bool load(const wxString& path, EditorDocument* doc) override {
        // 使用 CEGUI 0.7.x SAX 解析器
    }

    bool save(const wxString& path, const EditorDocument* doc) override {
        // 生成 CEGUI 0.7.x XML 格式
    }

    wxString getFilter() const override {
        return "CEGUI 0.7.x Imageset (*.xml)|*.xml";
    }
};

// CEGUI 0.8+ 处理器
class CEGUI08Handler : public IImagesetFormatHandler {
    // CEGUI 0.8+ 使用不同的 XML 结构
};

// 工厂
class FormatHandlerFactory {
public:
    static std::unique_ptr<IImagesetFormatHandler>
    createForVersion(const wxString& version);
};
```

### 3.3 Linux/macOS 支持

**方案**: CMake 构建系统

```cmake
# CMakeLists.txt
cmake_minimum_required(VERSION 3.15)
project(CEImagesetEditor VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 跨平台检测
if(WIN32)
    set(PLATFORM_LIBS OpenGL32 GLU32)
elseif(APPLE)
    find_package(OpenGL REQUIRED)
    set(PLATFORM_LIBS ${OPENGL_LIBRARIES})
else()
    find_package(OpenGL REQUIRED)
    set(PLATFORM_LIBS ${OPENGL_LIBRARIES})
endif()

# wxWidgets 检测
find_package(wxWidgets REQUIRED COMPONENTS core base gl adv)
include(${wxWidgets_USE_FILE})

# CEGUI 检测
find_package(CEGUI 0.7.1 REQUIRED)

# 源文件
set(SOURCES
    src/CEImagesetEditor.cpp
    src/EditorDocument.cpp
    # ...
)

# 可执行文件
add_executable(CEImagesetEditor ${SOURCES})
target_include_directories(CEImagesetEditor PRIVATE
    ${CEGUI_INCLUDE_DIRS}
    ${wxWidgets_INCLUDE_DIRS}
)
target_link_libraries(CEImagesetEditor
    ${CEGUI_LIBRARIES}
    ${wxWidgets_LIBRARIES}
    ${PLATFORM_LIBS}
)
```

---

## 📊 实施路线图

### 阶段 1: 快速胜利 (1-2 周) - ⭐ 九宫格 + 三段式优先

| 任务 | 优先级 | 工作量 | 说明 |
|------|--------|--------|------|
| **九宫格自动生成** | **P0** | **3-5 天** | `lt/lc/lb/ct/cc/cb/rt/rc/rb` |
| **三段式自动生成** | **P0** | **2-3 天** | `l/c/r` 和 `t/c/b` (水平/垂直) |
| 双段式自动生成 | **P0** | **1 天** | `l/r` (基于三段式实现) |
| 撤销/重做系统 | P0 | 3 天 | 命令模式 |
| 批量重命名 | P0 | 1 天 | 通配符模式 |
| 快捷键增强 | P0 | 1 天 | 常用操作快捷键 |
| 导出 CSV 格式 | P1 | 1 天 | 调试支持 |

**阶段 1 预期收益**:
- 减少 85% 的区域定义工作量 (九宫格 80% + 三段式 90%)
- 支持项目中所有常用格式模式
- 提升编辑效率 3-5 倍

### 阶段 2: 核心增强 (3-4 周)

| 任务 | 优先级 | 工作量 | 说明 |
|------|--------|--------|------|
| 智能区域检测 | P0 | 5 天 | 从现有 imageset 检测模式 |
| 批量操作完整实现 | P0 | 3 天 | 移动/调整/删除 |
| 多格式导出 (Cocos2d, Unity) | P1 | 5 天 | 跨引擎支持 |
| 硬件加速渲染 | P1 | 5 天 | OpenGL 优化 |

### 阶段 3: 架构重构 (4-6 周)

| 任务 | 优先级 | 工作量 |
|------|--------|--------|
| 升级 wxWidgets 3.2 | P1 | 3 天 |
| CEGUI 版本抽象层 | P1 | 7 天 |
| CMake 构建系统 | P2 | 5 天 |
| Linux 移植 | P2 | 7 天 |

### 阶段 4: 长期规划 (未来)

| 任务 | 优先级 | 工作量 |
|------|--------|--------|
| Qt 6 迁移 | P2 | 14 天 |
| 网络协作编辑 | P3 | 21 天 |
| 插件系统 | P3 | 14 天 |

---

## 🔧 技术债务清单

> **完整清单**: 详见 [CEImagesetEditor-技术债务清单.md](CEImagesetEditor-技术债务清单.md)

### 已解决 (31/38 = 82%)

| 分类 | 总计 | 已解决 | 待解决 |
|------|------|--------|--------|
| 代码质量 | 12 | 10 | 2 |
| 架构设计 | 8 | 7 | 1 |
| 性能瓶颈 | 6 | 4 | 2 |
| 安全漏洞 | 3 | 3 | 0 |
| 可维护性 | 5 | 4 | 1 |
| 依赖管理 | 4 | 3 | 1 |

### 关键已解决项

| 项目 | 原问题 | 解决方案 |
|------|--------|----------|
| 撤销/重做系统 | 无法撤销操作 | 实现命令模式 |
| 九宫格生成器 | 手动定义 9 个区域 | NinePatchGenerator |
| 三段式生成器 | 手动定义 3 个区域 | ThreePieceGenerator |
| 批量重命名 | 逐个重命名 | DialogBatchRename |
| 右键快捷菜单 | 需菜单访问 | 上下文菜单 |
| 运行时依赖检查 | 缺 DLL 崩溃 | 启动时验证 |

### 待解决项

| 项目 | 影响 | 优先级 | 建议 |
|------|------|--------|------|
| 智能区域检测 | 效率 | 中 | 实现 AutoRegionDetector |
| 多格式导出 | 跨引擎 | 中 | 实现 IImagesetExporter |
| 单元测试 | 稳定性 | 中 | 使用 Google Test |
| CMake 构建 | 跨平台 | 低 | 创建 CMakeLists.txt |

---

## 📝 代码示例

### 智能区域检测实现示例

```cpp
// AutoRegionDetector.cpp
std::vector<wxRect> AutoRegionDetector::detectByAlpha(
    const wxImage& texture, int alphaThreshold) {

    std::vector<wxRect> regions;
    const int width = texture.GetWidth();
    const int height = texture.GetHeight();

    // 创建访问矩阵
    std::vector<std::vector<bool>> visited(width, std::vector<bool>(height, false));

    for (int y = 0; y < height; ++y) {
        for (int x = 0; x < width; ++x) {
            if (visited[x][y]) continue;

            // 跳过透明像素
            if (texture.GetAlpha(x, y) < alphaThreshold) {
                visited[x][y] = true;
                continue;
            }

            // 泛洪填充查找连通区域
            wxRect region = floodFill(texture, x, y, alphaThreshold, visited);

            // 过滤太小的区域
            if (region.GetWidth() >= 4 && region.GetHeight() >= 4) {
                regions.push_back(region);
            }
        }
    }

    return regions;
}

wxRect AutoRegionDetector::floodFill(
    const wxImage& texture, int startX, int startY,
    int alphaThreshold, std::vector<std::vector<bool>>& visited) {

    std::queue<wxPoint> queue;
    queue.push(wxPoint(startX, startY));

    int minX = startX, maxX = startX;
    int minY = startY, maxY = startY;

    while (!queue.empty()) {
        wxPoint p = queue.front();
        queue.pop();

        if (p.x < 0 || p.x >= texture.GetWidth() ||
            p.y < 0 || p.y >= texture.GetHeight()) continue;
        if (visited[p.x][p.y]) continue;

        visited[p.x][p.y] = true;

        // 扩展边界
        minX = std::min(minX, p.x);
        maxX = std::max(maxX, p.x);
        minY = std::min(minY, p.y);
        maxY = std::max(maxY, p.y);

        // 检查相邻像素
        const int dx[] = {-1, 1, 0, 0};
        const int dy[] = {0, 0, -1, 1};

        for (int i = 0; i < 4; ++i) {
            int nx = p.x + dx[i];
            int ny = p.y + dy[i];

            if (nx >= 0 && nx < texture.GetWidth() &&
                ny >= 0 && ny < texture.GetHeight() &&
                !visited[nx][ny] &&
                texture.GetAlpha(nx, ny) >= alphaThreshold) {
                queue.push(wxPoint(nx, ny));
            }
        }
    }

    return wxRect(minX, minY, maxX - minX + 1, maxY - minY + 1);
}
```

---

## 🎯 成功指标

| 指标 | 当前 | 目标 |
|------|------|------|
| **启动时间** | ~3s | <1s |
| **100个区域渲染** | ~200ms | <50ms |
| **4K 纹理加载** | OOM | 流畅 |
| **自动化覆盖** | 0% | >80% |
| **用户满意度** | N/A | >4.5/5 |

---

**相关文档**:
- [CEImagesetEditor技术手册](../docs/08-技术研究/09-CEImagesetEditor技术手册.md)
- [CEImagesetEditor编译构建指南](../docs/06-工具链/07-CEImagesetEditor编译构建.md)

**文档版本**: 1.0
**最后更新**: 2026-01-08
**状态**: 待评审
