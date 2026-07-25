  # CEGUI LookNFeel 可视化编辑器 — 可执行落地文档

> **版本**: 1.0.0  
> **日期**: 2026-04-18  
> **项目代号**: LnFEditor  
> **代码位置**: `tools/LnFEditor/`

---

## 一、项目概述

### 1.1 目标

为 MT3 项目中 `client/resource/res/ui/looknfeel` 目录下的 CEGUI LookNFeel 配置文件提供一款桌面级可视化编辑工具，实现：

- **解析引擎**：读取并编译 `.looknfeel`、`.imageset`、`.scheme` 文件
- **可视化画布**：Canvas 2D 渲染 CEGUI 控件外观，支持九宫格/三段式框架渲染
- **交互编辑**：鼠标拖拽、缩放、对齐吸附、属性修改
- **层级管理**：树形结构浏览 WidgetLook → ImagerySection → Component 层级
- **实时预览**：切换 StateImagery 状态即时预览
- **属性检查**：动态属性面板，支持 Dim 表达式编辑
- **序列化回写**：格式保持的 XML 序列化，精准回写原始文件

### 1.2 技术栈

| 层 | 技术 | 版本 |
|---|---|---|
| 桌面框架 | Electron | ^33.2.0 |
| 构建工具 | electron-vite | ^2.3.0 |
| 前端框架 | React | ^19.0.0 |
| 类型系统 | TypeScript | ^5.7.2 |
| 状态管理 | Zustand + Immer | ^5.0.2 / ^10.1.1 |
| XML 解析 | fast-xml-parser | ^4.5.0 |
| 图像处理 | Sharp | ^0.33.2 |
| 测试框架 | Vitest | ^2.1.8 |
| 样式方案 | 原生 CSS (Catppuccin Mocha 色系) | — |

### 1.3 约束

- 目标平台：Windows 10+
- 文件编码：UTF-8（looknfeel/imageset/scheme）
- 不修改 CEGUI 运行时，仅编辑配置文件
- 不引入 OpenGL/DirectX，全部使用 Canvas 2D 模拟渲染
- 遵循 MT3 项目工具链约束（v120/NDK r10e 不适用于本工具）

---

## 二、系统架构

### 2.1 整体架构图

```
┌─────────────────────────────────────────────────────────────────┐
│                        Electron 主进程                           │
│  ┌──────────────┐  ┌──────────────┐  ┌───────────────────────┐ │
│  │  Parser       │  │ Resource     │  │ Serializer            │ │
│  │  Service      │  │ Loader       │  │ Service               │ │
│  │              │  │              │  │                       │ │
│  │ - buildFile  │  │ - parseImage │  │ - serializeWidgetLook │ │
│  │   Index()    │  │   set()      │  │ - serializeFalagard   │ │
│  │ - parseLook  │  │ - parseScheme│  │   Document()          │ │
│  │   NFeel()    │  │ - loadImage  │  │ - serializeArea()     │ │
│  │ - parseWidget│  │   setsFrom   │  │ - serializeDimInline()│ │
│  │   LookBy     │  │   Scheme()   │  │                       │ │
│  │   Index()    │  │              │  │                       │ │
│  └──────┬───────┘  └──────┬───────┘  └───────────┬───────────┘ │
│         │                 │                      │             │
│         └─────────┬───────┘──────────────────────┘             │
│                   │ IPC (contextBridge)                         │
├───────────────────┼─────────────────────────────────────────────┤
│                   │              渲染进程                         │
│  ┌────────────────┴────────────────────────────────────────┐   │
│  │                    Zustand Store                         │   │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌───────────┐ │   │
│  │  │ Files    │ │Selection │ │ Canvas   │ │ History   │ │   │
│  │  │ State    │ │ State    │ │ Viewport │ │ Stack     │ │   │
│  │  └──────────┘ └──────────┘ └──────────┘ └───────────┘ │   │
│  └────────────────────────┬───────────────────────────────┘   │
│                           │                                    │
│  ┌────────────────────────┴───────────────────────────────┐   │
│  │                    UI 组件层                             │   │
│  │  ┌─────────┐ ┌──────────┐ ┌─────────┐ ┌────────────┐ │   │
│  │  │Navigator│ │LayerTree │ │Property │ │ Preview    │ │   │
│  │  │Panel    │ │Panel     │ │Panel    │ │ Panel      │ │   │
│  │  └─────────┘ └──────────┘ └─────────┘ └────────────┘ │   │
│  │  ┌──────────────────────────────────────────────────┐  │   │
│  │  │              Canvas (2D 渲染 + 交互)              │  │   │
│  │  │  ┌──────────┐ ┌──────────┐ ┌──────────────────┐ │  │   │
│  │  │  │ Renderer │ │Interact  │ │ Dim Evaluator    │ │  │   │
│  │  │  │ Engine   │ │Controller│ │ (shared)         │ │  │   │
│  │  │  └──────────┘ └──────────┘ └──────────────────┘ │  │   │
│  │  └──────────────────────────────────────────────────┘  │   │
│  └────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

### 2.2 进程间通信

| 通道 | 方向 | 用途 |
|------|------|------|
| `open-looknfeel` | R→M→R | 打开 .looknfeel 文件，返回 FileIndex + WidgetLook[] |
| `load-widgetlook` | R→M→R | 按索引延迟加载单个 WidgetLook |
| `open-scheme` | R→M→R | 打开 .scheme 文件，加载关联 imageset |
| `read-image-base64` | R→M→R | 读取纹理图片为 Base64 DataURL |
| `save-looknfeel` | R→M→R | 序列化并保存 WidgetLook[] 到文件 |
| `scan-imagesets` | R→M→R | 扫描目录下 .imageset 文件列表 |

---

## 三、核心数据模型

### 3.1 类型层次

```
FalagardDocument
  └── WidgetLook[]                    ← 顶层控件外观定义
       ├── PropertyDefinition[]       ← 属性定义（含默认值）
       ├── PropertyLinkDefinition[]   ← 属性链接定义
       ├── Property[]                 ← 静态属性
       ├── NamedArea[]                ← 命名区域
       │    └── AreaDef               ← 4个 Dim 表达式
       ├── ChildWidget[]              ← 子控件
       │    ├── AreaDef
       │    └── Property[]
       ├── ImagerySection[]           ← 可视化段落
       │    ├── FrameComponent[]      ← 九宫格框架
       │    │    ├── AreaDef
       │    │    ├── ImageRef[]       ← 9个位置的图像引用
       │    │    └── VertFormat/HorzFormat
       │    ├── ImageryComponent[]    ← 单图像组件
       │    │    ├── AreaDef
       │    │    └── ImageRef
       │    └── TextComponent[]       ← 文本组件
       │         └── AreaDef
       └── StateImagery[]             ← 状态图像组合
            └── StateLayer[]
                 └── StateSectionRef[] ← 引用 ImagerySection
```

### 3.2 Dim 表达式 AST

```
DimNode (递归联合类型):
  ├── AbsoluteDim      { value: number }
  ├── UnifiedDim       { scale, offset, dimType }
  ├── ImageDim         { imageset, image, dimType }
  ├── WidgetDim        { widget?, dimType }
  ├── FontDim          { font?, metric, padding? }
  ├── PropertyDim      { name }
  └── DimOperator      { op, left: DimNode, right: DimNode }
```

### 3.3 关键文件清单

| 文件路径 | 职责 |
|----------|------|
| `src/shared/model/types.ts` | 核心类型定义（WidgetLook, DimNode, AreaDef 等） |
| `src/shared/model/resource.ts` | 资源类型定义（ImagesetResource, SchemeResource） |
| `src/shared/model/serialization.ts` | 序列化格式保持类型 |
| `src/shared/model/editor.ts` | 编辑器状态类型（EditorState, DragState, CanvasViewport） |
| `src/shared/constants/index.ts` | 常量定义（CEGUI 状态名、默认视口参数） |
| `src/shared/services/dim-evaluator.ts` | Dim 表达式求值器（共享于主进程和渲染进程） |

---

## 四、功能模块详细设计

### 4.1 XML 解析引擎

**文件**: `src/main/services/parser.ts`

**两阶段解析策略**：

1. **SAX 索引阶段**（`buildFileIndex`）
   - 逐行扫描 `.looknfeel` 文件
   - 记录每个 `<WidgetLook>` 的行号范围、字节偏移、子元素计数
   - 输出 `FileIndex` 结构，用于大文件导航

2. **DOM 精确解析阶段**（`parseWidgetLookByIndex` / `parseLookNFeelFile`）
   - 使用 `fast-xml-parser` 将 XML 转为 JS 对象
   - 递归转换 `parseWidgetLookObj` → 强类型 `WidgetLook` 模型
   - 支持按索引切片解析单个 WidgetLook（延迟加载）

**关键设计**：
- `ARRAY_OPTIONS` 配置确保所有可能的重复元素始终解析为数组
- `parseDimNode` 递归处理 DimOperator 嵌套
- Area 解析支持 `LeftEdge+Width` 和 `LeftEdge+RightEdge` 两种模式

### 4.2 资源加载器

**文件**: `src/main/services/resource-loader.ts`

**功能**：
- `parseImageset()`: 解析 `.imageset` 文件，构建 `ImagesetResource`（含 SubImage Map）
- `parseScheme()`: 解析 `.scheme` 文件，提取 imageset/font/looknfeel 文件路径
- `loadImagesetsFromScheme()`: 批量加载 scheme 引用的所有 imageset
- `scanImagesetDir()`: 扫描目录下所有 `.imageset` 文件

**纹理加载流程**：
```
.scheme → imagesetFiles[] → .imageset → textureFilePath
                                         ↓
                                    fs.readFileSync → Base64 → Canvas Image
```

### 4.3 Dim 表达式求值器

**文件**: `src/shared/services/dim-evaluator.ts`

**核心函数**：

| 函数 | 功能 |
|------|------|
| `evaluateDim(node, ctx)` | 递归求值 DimNode → 像素值 |
| `evaluateArea(area, ctx)` | 求值 AreaDef → PixelRect |
| `pixelToDim(pixel, dimType, parentSize, strategy)` | 像素值 → DimNode（4种策略） |
| `formatDimExpr(node)` | DimNode → 可读字符串 |

**求值上下文** (`DimEvaluationContext`)：
- `parentWidth/Height`: 父控件尺寸
- `widgetDimensions`: 子控件矩形 Map
- `imageDimensions`: 图像尺寸 Map
- `fontMetrics`: 字体度量 Map

**像素→Dim 生成策略**：
- `absolute`: 纯绝对值 `{0, 100, Width}`
- `unified-relative`: 纯比例 `{0.5, 0, Width}`
- `unified-offset`: 纯偏移 `{0, 100, Width}`
- `hybrid`: 混合（默认）`{0.3, 20, Width}`

### 4.4 Canvas 渲染引擎

**文件**: `src/renderer/canvas/renderer.ts`

**渲染流水线**：
```
renderWidgetLook()
  → 遍历 activeStates → layers → sectionRefs
    → 查找 ImagerySection
      → renderImagerySection()
        → renderFrameComponent()    ← 九宫格渲染
        → renderImageryComponent()  ← 单图像渲染
        → renderTextComponent()     ← 文本占位渲染
```

**九宫格渲染逻辑** (`renderFrameComponent`)：
1. 求值 FrameComponent 的 Area → PixelRect
2. 获取 9 个位置的图像纹理（LeftEdge/RightEdge/TopEdge/BottomEdge/Background/4角）
3. 计算内区矩形（去掉边框后的中心区域）
4. 按九宫格规则绘制：4角原尺寸、4边拉伸/平铺、中心背景拉伸/平铺
5. 应用颜色覆盖（ARGB → CSS rgba）

**辅助功能**：
- `drawStretched()`: 拉伸绘制
- `drawTiled()`: 平铺绘制（水平/垂直/双向）
- `renderSelectionHandles()`: 绘制选中元素的 8 个控制手柄

### 4.5 交互控制层

**文件**: `src/renderer/canvas/interaction.ts`

**功能矩阵**：

| 函数 | 功能 |
|------|------|
| `hitTestDragMode()` | 鼠标位置 → 拖拽模式（move/8方向resize/null） |
| `applyDrag()` | 根据拖拽模式计算新矩形，含最小尺寸约束 |
| `computeSnapLines()` | 计算对齐吸附线（6边+2中心×2方向） |
| `snapPosition()` | 吸附到最近吸附线位置 |
| `canvasToScreen()` / `screenToCanvas()` | 坐标系转换 |
| `zoomViewport()` | 以鼠标位置为中心缩放视口 |

**拖拽模式检测**：
- 8 个控制手柄（4角 + 4边中点），半径 6px
- 内部区域 → move 模式
- 外部 → null（不响应）

**吸附算法**：
- 遍历所有静态矩形的 6 条参考线（left/right/top/bottom/centerX/centerY）
- 与移动矩形的对应边比较，差值 ≤ threshold 时生成吸附线
- 吸附到差值最小的吸附线

### 4.6 序列化引擎

**文件**: `src/main/services/serializer.ts`

**核心函数**：
- `serializeWidgetLook()`: WidgetLook → XML 字符串
- `serializeFalagardDocument()`: WidgetLook[] → 完整 .looknfeel 文件内容
- `serializeArea()`: AreaDef → XML Area 块
- `serializeDimInline()`: DimNode → 内联 XML（支持 DimOperator 嵌套）

**格式保持策略**：
- `SerializationOptions` 控制缩进、注释、属性顺序、空行保留
- 默认 4 空格缩进，与 MT3 现有文件一致
- 自闭合标签使用 `/>` 短格式

### 4.7 状态管理

**文件**: `src/renderer/stores/editor-store.ts`

**Zustand + Immer 架构**：

```
EditorStore
├── files
│   ├── activeFilePath: string | null
│   └── openedFiles: Map<string, FileState>
├── selection
│   ├── widgetLookName: string | null
│   ├── selectedNodeIds: string[]
│   └── hoveredNodeId: string | null
├── canvas: CanvasViewport
├── preview
│   ├── activeStates: string[]
│   ├── parentWidth: number
│   └── parentHeight: number
├── history
│   ├── undoStack: HistoryEntry[]
│   └── redoStack: HistoryEntry[]
└── dirty: boolean
```

**关键 Actions**：
- `openFile/closeFile/setActiveFile`: 文件管理
- `selectWidgetLook/selectNode/hoverNode`: 选择管理
- `updateWidgetLook`: 更新 WidgetLook 数据（触发 dirty）
- `setViewport/setActiveStates/setParentSize`: 视口/预览控制
- `pushHistory/undo/redo`: 历史记录（最大 50 层）

---

## 五、前端界面布局

### 5.1 整体布局

```
┌──────────────────────────────────────────────────────────────┐
│  Toolbar: [📂 Open] [💾 Save]                                │
├──────────┬──────────────────────────────────┬────────────────┤
│          │                                  │                │
│ Navigator│                                  │  Property      │
│  Panel   │                                  │  Panel         │
│ (240px)  │       Canvas (2D 渲染区)          │  (280px)       │
│──────────│                                  │────────────────│
│ Layer    │                                  │  Preview       │
│ Tree     │                                  │  Panel         │
│ Panel    │                                  │  (280px)       │
│          │                                  │                │
├──────────┴──────────────────────────────────┴────────────────┤
│  Status: [文件名] [选中项] [修改状态]                           │
└──────────────────────────────────────────────────────────────┘
```

### 5.2 面板功能

| 面板 | 组件文件 | 功能 |
|------|----------|------|
| Navigator | `NavigatorPanel.tsx` | WidgetLook 列表导航，点击切换选中 |
| Layer Tree | `LayerTreePanel.tsx` | 层级树（WidgetLook → Section → Component），支持展开/折叠/多选 |
| Canvas | `Canvas.tsx` | 2D 渲染画布，支持缩放/平移/拖拽/吸附 |
| Property | `PropertyPanel.tsx` | 属性检查器，显示/编辑选中元素的属性和 Dim 表达式 |
| Preview | `PreviewPanel.tsx` | 预览设置：父控件尺寸、StateImagery 状态切换 |
| Toolbar | `App.tsx` (内联) | 文件操作：打开/保存 |
| Status Bar | `App.tsx` (内联) | 状态信息：文件名/选中项/修改标记 |

### 5.3 层级树结构

```
📦 TaharezLook/Button
├── ⚙️ Properties
│   ├── ⚙️ NormalTextColour = FFFFFFFF
│   └── ⚙️ HoverTextColour = FFEFEFEF
├── 📐 Named Areas
│   └── 📐 TextArea
├── 🧩 Children
│   └── 🧩 TaharezLook/StaticImage (__auto_titlebar__)
├── 🎨 Imagery Sections
│   ├── 🎨 normal
│   │   ├── 🖼️ FrameComponent
│   │   └── 🖼️ TextComponent
│   ├── 🎨 hover
│   └── 🎨 pushed
└── ⚡ State Imagery
    ├── ⚡ Normal
    │   └── 📑 Layer 0
    │       └── 🎨 normal
    ├── ⚡ Hover
    └── ⚡ Pushed
```

---

## 六、构建与运行

### 6.1 环境要求

- Node.js >= 18.0.0
- npm >= 9.0.0

### 6.2 安装依赖

```bash
cd tools/LnFEditor
npm install
```

### 6.3 开发模式

```bash
npm run dev
```

启动 electron-vite 开发服务器，自动热更新渲染进程。

### 6.4 生产构建

```bash
npm run build
```

输出到 `dist/` 目录：
- `dist/main/` — 主进程 JS
- `dist/preload/` — 预加载脚本 JS
- `dist/renderer/` — 渲染进程 HTML/JS/CSS

### 6.5 其他命令

| 命令 | 用途 |
|------|------|
| `npm run typecheck` | TypeScript 类型检查 |
| `npm run lint` | ESLint 代码检查 |
| `npm run test` | Vitest 单元测试 |
| `npm run test:watch` | Vitest 监听模式 |

---

## 七、文件结构

```
tools/LnFEditor/
├── package.json
├── tsconfig.json
├── electron.vite.config.ts
├── src/
│   ├── main/                          ← Electron 主进程
│   │   ├── index.ts                   ← 主进程入口 + IPC 注册
│   │   └── services/
│   │       ├── parser.ts              ← XML 解析引擎
│   │       ├── resource-loader.ts     ← Imageset/Scheme 资源加载
│   │       └── serializer.ts          ← XML 序列化引擎
│   ├── preload/
│   │   └── index.ts                   ← Context Bridge API
│   ├── renderer/                      ← 渲染进程
│   │   ├── index.html
│   │   ├── main.tsx                   ← React 入口
│   │   ├── App.tsx                    ← 根组件 + Toolbar/StatusBar
│   │   ├── styles.css                 ← 全局样式 (Catppuccin Mocha)
│   │   ├── canvas/
│   │   │   ├── Canvas.tsx             ← 画布组件
│   │   │   ├── renderer.ts           ← 渲染引擎
│   │   │   └── interaction.ts        ← 交互控制
│   │   ├── panels/
│   │   │   ├── NavigatorPanel.tsx     ← 导航面板
│   │   │   ├── LayerTreePanel.tsx     ← 层级树面板
│   │   │   ├── PropertyPanel.tsx      ← 属性检查面板
│   │   │   └── PreviewPanel.tsx       ← 预览设置面板
│   │   ├── stores/
│   │   │   └── editor-store.ts        ← Zustand 状态管理
│   │   ├── services/
│   │   │   └── layer-tree-builder.ts  ← 层级树构建器
│   │   └── hooks/                     ← 自定义 Hooks（待扩展）
│   └── shared/                        ← 共享代码
│       ├── model/
│       │   ├── types.ts               ← 核心类型定义
│       │   ├── resource.ts            ← 资源类型定义
│       │   ├── serialization.ts       ← 序列化类型定义
│       │   ├── editor.ts              ← 编辑器状态类型
│       │   └── index.ts               ← 统一导出
│       ├── constants/
│       │   └── index.ts               ← 常量定义
│       └── services/
│           └── dim-evaluator.ts        ← Dim 表达式求值器
```

---

## 八、数据流

### 8.1 文件打开流程

```
用户点击 [Open]
  → IPC: open-looknfeel
    → dialog.showOpenDialog()
    → buildFileIndex(filePath)
    → parseLookNFeelFile(filePath)
  → Store: openFile(filePath, fileIndex, widgetLooks)
  → Store: selectWidgetLook(firstWL.name)
  → Canvas: 重新渲染
```

### 8.2 编辑流程

```
用户拖拽组件
  → Canvas: hitTestDragMode() → 模式识别
  → Canvas: applyDrag() → 计算新矩形
  → Store: updateWidgetLook() → 更新数据
  → Store: pushHistory() → 记录历史
  → Canvas: 重新渲染
```

### 8.3 保存流程

```
用户点击 [Save]
  → Store: 获取 activeFilePath + loadedWidgetLooks
  → IPC: save-looknfeel(filePath, widgetLooksJson)
    → serializeFalagardDocument(widgetLooks)
    → fs.writeFileSync(filePath, xml)
  → Store: markDirty(false)
```

---

## 九、测试策略

### 9.1 单元测试

| 模块 | 测试文件 | 覆盖范围 |
|------|----------|----------|
| Dim 求值器 | `dim-evaluator.test.ts` | 所有 DimNode 类型求值、Area 求值、像素→Dim 转换 |
| XML 解析 | `parser.test.ts` | WidgetLook 解析、索引构建、延迟加载 |
| 序列化 | `serializer.test.ts` | WidgetLook → XML 往返一致性 |
| 交互控制 | `interaction.test.ts` | hitTest、applyDrag、snapLines、zoomViewport |

### 9.2 集成测试

- 打开 → 编辑 → 保存 → 重新打开 → 验证数据一致性
- Scheme 加载 → Imageset 加载 → 纹理渲染
- 大文件（599 个 WidgetLook）延迟加载性能

### 9.3 运行测试

```bash
npm run test          # 单次运行
npm run test:watch    # 监听模式
```

---

## 十、性能优化

### 10.1 大文件处理

- **延迟加载**：`buildFileIndex` 仅扫描行号，不解析内容；按需调用 `parseWidgetLookByIndex`
- **虚拟列表**：Navigator 面板对 500+ WidgetLook 使用虚拟滚动
- **增量渲染**：仅重绘当前选中 WidgetLook 的 activeStates

### 10.2 纹理缓存

- LRU 缓存，最大 200 个子图像 Canvas
- 基于 `imageset/image` 双键索引
- 访问时更新 `lastAccessTime`，超容量时淘汰最久未用

### 10.3 画布优化

- 仅在视口可见区域渲染
- 缩放 < 25% 时跳过网格绘制
- 使用 `requestAnimationFrame` 合并渲染请求

---

## 十一、后续迭代计划

### Phase 1（当前）— 基础框架 ✅

- [x] 项目脚手架与构建配置
- [x] 核心数据模型与类型定义
- [x] XML 解析引擎
- [x] Imageset/Scheme 资源加载器
- [x] Dim 表达式求值器
- [x] 九宫格 Canvas 渲染引擎
- [x] 交互控制层
- [x] 前端 UI 面板
- [x] 序列化与回写引擎

### Phase 2 — 功能完善

- [ ] 纹理图片实际加载与渲染（Base64 → Canvas Image）
- [ ] Dim 表达式可视化编辑器（表达式树 → UI 控件）
- [ ] 撤销/重做完整实现
- [ ] 属性修改双向绑定
- [ ] 拖拽修改 Area 后自动更新 Dim 表达式
- [ ] 虚拟滚动列表（大文件导航）

### Phase 3 — 高级功能

- [ ] 多文件标签页
- [ ] 搜索/替换（跨 WidgetLook）
- [ ] Diff 视图（修改前后对比）
- [ ] 导出为 PNG/SVG 截图
- [ ] WidgetLook 模板库
- [ ] 快捷键系统
- [ ] 插件系统

### Phase 4 — 协作与发布

- [ ] 自动更新（electron-updater）
- [ ] 安装包打包（electron-builder）
- [ ] 国际化（i18n）
- [ ] 用户文档
