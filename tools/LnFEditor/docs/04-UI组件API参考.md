# 04 — UI 组件 API 参考

> **文档版本**: 0.1.0  
> **最后更新**: 2026-04-18  
> **适用范围**: LnFEditor React 组件

---

## 1. 组件总览

LnF Editor 的 UI 组件分为三层：

| 层级 | 目录 | 组件 |
|------|------|------|
| 根组件 | [`App.tsx`](../src/renderer/App.tsx) | `App`, `Toolbar`, `StatusBar` |
| 通用组件 | [`components/`](../src/renderer/components) | `ColourPicker`, `ContextMenu`, `DimEditor`, `VirtualList` |
| 面板组件 | [`panels/`](../src/renderer/panels) | `ExplorerPanel`, `InspectorPanel` |
| 画布组件 | [`canvas/`](../src/renderer/canvas) | `Canvas`, `LiveViewport`, `StateBar` |

---

## 2. 根组件

### 2.1 [`App`](../src/renderer/App.tsx:18)

应用根组件，组装全局快捷键、工具栏、三栏面板布局和状态栏。

```typescript
export function App(): React.ReactElement
```

**内部结构**：

```
<div className="app-layout">
  <div className="top-bar"><Toolbar /></div>
  <div className="main-content">
    <div className="left-panel">
      <ExplorerPanel />
    </div>
    <div className="center-panel"><LiveViewport /></div>
    <div className="right-panel">
      <InspectorPanel />
    </div>
  </div>
  <StatusBar />
</div>
```

**全局快捷键**（[行 27–68](../src/renderer/App.tsx:27)）：

| 快捷键 | 功能 |
|--------|------|
| Ctrl+Z | 撤销 |
| Ctrl+Y / Ctrl+Shift+Z | 重做 |
| Ctrl+S | 保存 |
| Ctrl+0 | 适应窗口（offset=0, scale=1） |
| Ctrl+1 | 100% 缩放 |

### 2.2 [`Toolbar`](../src/renderer/App.tsx:112)

工具栏组件，提供文件操作和视图控制按钮。

```typescript
function Toolbar(): React.ReactElement
```

**Props**：无（直接从 store 读取状态）

**Store 订阅**：

| 状态 | 用途 |
|------|------|
| `dirty` | 控制保存按钮的 disabled 状态 |
| `canvas.scale` | 显示当前缩放百分比 |

**按钮操作**：

| 按钮 | 回调 | 说明 |
|------|------|------|
| 📂 打开 | `openFile()` | 调用 `lnfAPI.openLookNFeel()` + 自动发现资源 |
| 💾 保存 | `saveFile()` | 调用 `saveCurrentFile()` |
| ↩ 撤销 | `handleUndo()` | `store.undo()` |
| ↪ 重做 | `handleRedo()` | `store.redo()` |
| − 缩小 | `zoomOut()` | scale /= 1.2（最小 0.1） |
| + 放大 | `zoomIn()` | scale *= 1.2（最大 10） |
| ⊡ 重置 | `resetZoom()` | scale=1, offset=0 |

### 2.3 [`StatusBar`](../src/renderer/App.tsx:221)

状态栏组件，显示当前编辑状态。

```typescript
function StatusBar(): React.ReactElement
```

**显示信息**：

| 位置 | 内容 | Store 字段 |
|------|------|-----------|
| 左1 | 文件名 | `files.activeFilePath` |
| 左2 | 选中项 | `selection.widgetLookName` |
| 中 | 修改标记 | `dirty` |
| 右1 | 撤销/重做数 | `history.undoStack.length`, `history.redoStack.length` |
| 右2 | 纹理缓存 | `textureCache.getStats()` |

---

## 3. 通用组件

### 3.1 [`ColourPicker`](../src/renderer/components/ColourPicker.tsx:48)

ARGB 颜色选择器，支持四通道滑块和十六进制输入。

```typescript
interface ColourPickerProps {
  /** ARGB 十六进制字符串（如 "FFFFFFFF"） */
  value: string;
  /** 值变更回调 */
  onChange: (newValue: string) => void;
  /** 可选标签 */
  label?: string;
}

export function ColourPicker({ value, onChange, label }: ColourPickerProps): React.ReactElement
```

**辅助函数**：

| 函数 | 签名 | 说明 |
|------|------|------|
| [`parseARGB()`](../src/renderer/components/ColourPicker.tsx:18) | `(argb: string) → ColourValue` | 解析 "FFFFFFFF" → {a:255, r:255, g:255, b:255} |
| [`toARGBString()`](../src/renderer/components/ColourPicker.tsx:32) | `(c: ColourValue) → string` | ColourValue → "FFFFFFFF" |
| [`toCSSRGBA()`](../src/renderer/components/ColourPicker.tsx:38) | `(c: ColourValue) → string` | ColourValue → "rgba(255, 255, 255, 1.00)" |

**交互**：
- 点击色块展开/收起通道编辑器
- 每个通道（A/R/G/B）提供 range 滑块 + number 输入
- 支持直接输入 8 位十六进制

### 3.2 [`ContextMenu`](../src/renderer/components/ContextMenu.tsx:46)

右键上下文菜单组件，支持子菜单、图标、快捷键提示。

```typescript
interface MenuItemDef {
  id: string;
  label: string;
  icon?: string;
  shortcut?: string;
  disabled?: boolean;
  onClick?: () => void;
  submenu?: MenuItemDef[];
}

interface ContextMenuProps {
  /** 菜单项定义 */
  items: MenuItemDef[];
  /** 菜单 X 坐标（屏幕坐标） */
  x: number;
  /** 菜单 Y 坐标（屏幕坐标） */
  y: number;
  /** 关闭回调 */
  onClose: () => void;
}

export function ContextMenu({ items, x, y, onClose }: ContextMenuProps): React.ReactElement
```

**行为**：
- 自动调整位置确保不超出视口（`useAdjustedPosition` hook）
- 点击外部或按 Escape 关闭
- 延迟绑定事件监听器，避免当前右键事件立即关闭
- 支持子菜单悬停展开

### 3.3 [`DimEditor`](../src/renderer/components/DimEditor.tsx:51)

Dim 表达式可视化编辑器，支持 7 种 DimNode 类型的编辑和类型切换。

```typescript
interface DimEditorProps {
  /** 当前 Dim 表达式 */
  value: DimNode;
  /** 变更回调 */
  onChange: (newDim: DimNode) => void;
  /** 可选标签（如 "Left", "Top", "Width"） */
  label?: string;
  /** 是否禁用 */
  disabled?: boolean;
  /** 父容器尺寸（用于 UnifiedDim 预览计算） */
  parentSize?: number;
}

export function DimEditor({
  value, onChange, label, disabled = false, parentSize,
}: DimEditorProps): React.ReactElement
```

**支持的 Dim 类型编辑器**：

| 类型 | 编辑控件 | 说明 |
|------|---------|------|
| AbsoluteDim | number 输入 | 直接数值 |
| UnifiedDim | scale + offset + dimType | 三元组输入 |
| ImageDim | imageset + image 选择 + dimType | 图像引用 |
| WidgetDim | widget 名称 + dimType | 控件引用 |
| FontDim | font + metric + padding | 字体度量 |
| PropertyDim | 属性名输入 | 属性引用 |
| DimOperator | 递归左右子编辑器 + 运算符 | 嵌套表达式 |

**交互**：
- 点击头部展开/收起编辑器
- 显示表达式预览（`formatDimExpr()` 结果，截断 40 字符）
- 类型徽章显示当前 DimNode 类型
- 支持类型切换（`DimNodeTypeSwitcher`）

### 3.4 [`VirtualList`](../src/renderer/components/VirtualList.tsx:28)

虚拟滚动列表，仅渲染可见区域，支持搜索过滤和键盘导航。

```typescript
interface VirtualListItem {
  key: string;
  label: string;
  icon?: string;
  data: unknown;
}

interface VirtualListProps {
  /** 列表项 */
  items: VirtualListItem[];
  /** 当前选中项 key */
  selectedItemKey: string | null;
  /** 选中回调 */
  onSelect: (key: string) => void;
  /** 单项高度（默认 28px） */
  itemHeight?: number;
  /** 超出可见区域的预渲染项数（默认 10） */
  overscan?: number;
  /** 是否显示搜索框（默认 true） */
  searchable?: boolean;
  /** 搜索框占位文本 */
  searchPlaceholder?: string;
  /** 空列表提示文本 */
  emptyHint?: string;
}

export function VirtualList({
  items, selectedItemKey, onSelect,
  itemHeight = 28, overscan = 10,
  searchable = true, searchPlaceholder = '搜索...', emptyHint = '无项目',
}: VirtualListProps): React.ReactElement
```

**性能特性**：
- 基于 `scrollTop` 和 `containerHeight` 计算可见范围
- `overscan` 参数控制预渲染项数，减少快速滚动时的空白
- 搜索过滤使用 `useMemo` 缓存

**键盘导航**：
- ↑/↓ 箭头键在过滤后列表中移动选中项

---

## 4. 面板组件

### 4.1 [`ExplorerPanel`](../src/renderer/panels/ExplorerPanel.tsx)

统一导航面板，合并了原 NavigatorPanel 和 LayerTreePanel 的功能。

**职责**：
- 显示当前文件中所有 WidgetLook 名称（使用 VirtualList）
- 搜索过滤 WidgetLook
- 点击选中 → `store.selectWidgetLook(name)`
- 显示当前 WidgetLook 的结构层级树（Properties / NamedAreas / Children / ImagerySections / StateImagery）
- 点击节点 → `store.selectNode(nodeId, multiSelect)`

### 4.2 [`InspectorPanel`](../src/renderer/panels/InspectorPanel.tsx)

统一检查面板，合并了原 PropertyPanel、PreviewPanel 和 ImageBrowserPanel 的功能。三个可折叠分区：

**职责**：
- **Properties** — 显示选中组件的属性编辑器，嵌入 DimEditor 和 ColourPicker
- **State Control** — 切换激活的 StateImagery 状态、调整模拟父容器尺寸
- **Resources** — 图像资源浏览器，网格/列表视图、搜索过滤、缩略图预览

## 5. 画布组件

### 5.1 [`LiveViewport`](../src/renderer/canvas/LiveViewport.tsx)

画布视口组件，组合 Canvas 和 StateBar。

```typescript
export function LiveViewport(): React.ReactElement
```

**内部结构**：Canvas（渲染 + 交互） + StateBar（状态切换栏）

### 5.2 [`StateBar`](../src/renderer/canvas/StateBar.tsx)

实时渲染视口底部的状态切换栏，紧贴画布渲染区。

**职责**：
- 状态勾选切换（Normal, Hover, Pushed 等）
- 父控件尺寸调整（parentWidth/parentHeight）
- 自动循环播放

### 5.3 [`Canvas`](../src/renderer/canvas/Canvas.tsx:10)

主画布组件，整合渲染引擎、交互引擎和纹理缓存。

```typescript
export function Canvas(): React.ReactElement
```

**Props**：无（直接从 store 读取状态）

**Store 订阅**：

| 状态 | 用途 |
|------|------|
| `canvas` | 视口参数（offset, scale, grid） |
| `selection.widgetLookName` | 当前 WidgetLook 名称 |
| `files.activeFilePath` | 活动文件路径 |
| `files.openedFiles` | 获取 WidgetLook 数据 |
| `preview.activeStates` | 预览状态列表 |
| `preview.parentWidth/Height` | 父容器尺寸 |
| `selection.selectedNodeIds` | 选中节点 |

**内部状态**：

| 状态 | 类型 | 说明 |
|------|------|------|
| `canvasSize` | `{w, h}` | 画布像素尺寸（ResizeObserver 监听） |
| `dragState` | 复合对象 | 拖拽状态（active, mode, startArea, currentArea...） |
| `texturesReady` | boolean | 纹理是否加载完成 |

**事件处理**：

| 事件 | Handler | 说明 |
|------|---------|------|
| `onWheel` | `handleWheel` | 缩放视口（以鼠标位置为中心） |
| `onMouseDown` | `handleMouseDown` | 命中测试 + 开始拖拽 |
| `onMouseMove` | `handleMouseMove` | 计算拖拽新矩形 |
| `onMouseUp` | `handleMouseUp` | 结束拖拽 + 回写 Dim |

---

## 6. 渲染引擎 API

### 6.1 [`renderer.ts`](../src/renderer/canvas/renderer.ts)

Canvas 2D 渲染引擎，导出以下函数：

```typescript
/** 子图像缓存接口 */
interface SubImageCache {
  get(imageset: string, image: string): HTMLCanvasElement | OffscreenCanvas | null;
  has(imageset: string, image: string): boolean;
}

/** 渲染完整 WidgetLook */
function renderWidgetLook(
  ctx: CanvasRenderingContext2D,
  sections: ImagerySection[],
  activeStates: StateImagery[],
  evalCtx: DimEvaluationContext,
  textureCache: SubImageCache,
  viewport: { offsetX: number; offsetY: number; scale: number },
): void

/** 渲染选中元素控制手柄（8 个白色方块 + 蓝色虚线框） */
function renderSelectionHandles(
  ctx: CanvasRenderingContext2D,
  rect: PixelRect,
  viewport: { offsetX: number; offsetY: number; scale: number },
): void
```

### 6.2 [`interaction.ts`](../src/renderer/canvas/interaction.ts)

交互引擎，导出以下函数：

```typescript
/** 命中测试 → 返回拖拽模式 */
function hitTestDragMode(
  mouseX: number, mouseY: number,
  rect: PixelRect, viewport: CanvasViewport,
  handleRadius?: number,
): DragMode | null

/** 应用拖拽 → 计算新矩形 */
function applyDrag(
  mode: DragMode, dx: number, dy: number,
  original: PixelRect, minSize?: number,
): PixelRect

/** 计算对齐吸附线 */
function computeSnapLines(
  movingRect: PixelRect, staticRects: PixelRect[],
  threshold?: number,
): SnapLine[]

/** 吸附到最近位置 */
function snapPosition(rect: PixelRect, snapLines: SnapLine[]): { x: number; y: number }

/** 屏幕坐标 → 画布坐标 */
function screenToCanvas(sx: number, sy: number, viewport: CanvasViewport): { x: number; y: number }

/** 画布坐标 → 屏幕坐标 */
function canvasToScreen(cx: number, cy: number, viewport: CanvasViewport): { x: number; y: number }

/** 缩放视口（以指定点为中心） */
function zoomViewport(
  viewport: CanvasViewport, delta: number,
  pivotX: number, pivotY: number,
  minScale?: number, maxScale?: number,
): CanvasViewport
```
