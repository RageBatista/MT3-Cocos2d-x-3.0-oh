/** 编辑器画布矩形（像素坐标） */
export interface PixelRect {
  x: number;
  y: number;
  w: number;
  h: number;
}

/** 拖拽操作类型 */
export type DragMode =
  | 'move'
  | 'resize-tl'
  | 'resize-tr'
  | 'resize-bl'
  | 'resize-br'
  | 'resize-t'
  | 'resize-b'
  | 'resize-l'
  | 'resize-r';

/** 对齐吸附线 */
export interface SnapLine {
  orientation: 'horizontal' | 'vertical';
  position: number;
  sourceRect: PixelRect;
  threshold: number;
}

/** 拖拽状态 */
export interface DragState {
  active: boolean;
  mode: DragMode;
  startX: number;
  startY: number;
  startArea: PixelRect;
  targetSectionName: string;
  targetComponentType: 'frame' | 'imagery' | 'text';
  targetComponentIndex: number;
  snapLines: SnapLine[];
}

/** 画布视口状态 */
export interface CanvasViewport {
  offsetX: number;
  offsetY: number;
  scale: number;
  gridSize: number;
  showGrid: boolean;
  showRulers: boolean;
  snapEnabled: boolean;
  snapThreshold: number;
}

/** 层级树节点 */
export interface LayerTreeNode {
  id: string;
  type: 'widgetlook' | 'section' | 'component' | 'state' | 'layer' | 'property' | 'namedarea' | 'child';
  name: string;
  icon: string;
  visible: boolean;
  locked: boolean;
  selected: boolean;
  children: LayerTreeNode[];
  dataRef: unknown;
}

/** 历史记录条目 */
export interface HistoryEntry {
  timestamp: number;
  description: string;
  filePath: string;
  widgetLookName: string;
  snapshot: string;
  affectedPaths: string[];
}

/** 验证错误 */
export interface ValidationError {
  level: 'error' | 'warning' | 'info';
  message: string;
  sourcePath?: string;
}

/** 验证结果 */
export interface ValidationResult {
  valid: boolean;
  errors: ValidationError[];
}

/** Dim 求值上下文 */
export interface DimEvaluationContext {
  parentWidth: number;
  parentHeight: number;
  widgetDimensions: Map<string, PixelRect>;
  imageDimensions: Map<string, { width: number; height: number }>;
  fontMetrics: Map<string, { lineSpacing: number; baseline: number; horzExtent: number }>;
}

/** 编辑器全局状态 */
export interface EditorState {
  files: {
    activeFilePath: string | null;
    openedFiles: Map<string, FileState>;
  };
  selection: {
    widgetLookName: string | null;
    selectedNodeIds: string[];
    hoveredNodeId: string | null;
  };
  canvas: CanvasViewport;
  preview: {
    activeStates: string[];
    parentWidth: number;
    parentHeight: number;
  };
  history: {
    undoStack: HistoryEntry[];
    redoStack: HistoryEntry[];
    maxDepth: number;
  };
  dirty: boolean;
}

/** 单文件状态 */
export interface FileState {
  filePath: string;
  fileIndex: import('./types').FileIndex;
  loadedWidgetLooks: Map<string, import('./types').WidgetLook>;
  formatInfos: Map<string, import('./serialization').FormatPreservingNode>;
  dirty: boolean;
}
