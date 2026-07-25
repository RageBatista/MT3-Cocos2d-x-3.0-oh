/** Dim 维度类型枚举 */
export type DimType =
  | 'LeftEdge'
  | 'TopEdge'
  | 'RightEdge'
  | 'BottomEdge'
  | 'Width'
  | 'Height'
  | 'XPosition'
  | 'YPosition';

/** Dim 运算符类型 */
export type OperatorType = 'Add' | 'Subtract' | 'Multiply' | 'Divide';

/** 垂直格式化类型 */
export type VertFormat = 'TopAligned' | 'CentreAligned' | 'BottomAligned' | 'Stretched' | 'Tiled';

/** 水平格式化类型 */
export type HorzFormat = 'LeftAligned' | 'CentreAligned' | 'RightAligned' | 'Stretched' | 'Tiled';

/** 字体度量类型 */
export type FontMetricType = 'LineSpacing' | 'Baseline' | 'HorzExtent';

/** Frame 图像位置类型 */
export type FrameImageType =
  | 'LeftEdge'
  | 'RightEdge'
  | 'TopEdge'
  | 'BottomEdge'
  | 'Background'
  | 'TopLeftCorner'
  | 'TopRightCorner'
  | 'BottomLeftCorner'
  | 'BottomRightCorner';

/** CEGUI 颜色矩形（四角 ARGB） */
export interface ColourRect {
  topLeft: string;
  topRight: string;
  bottomLeft: string;
  bottomRight: string;
}

/** 图像引用 */
export interface ImageRef {
  imageset: string;
  image: string;
}

/** Dim 表达式 AST 节点 — 递归联合类型 */
export type DimNode =
  | { type: 'AbsoluteDim'; value: number }
  | { type: 'UnifiedDim'; scale: number; offset: number; dimType: DimType }
  | { type: 'ImageDim'; imageset: string; image: string; dimType: DimType }
  | { type: 'WidgetDim'; widget?: string; dimType: DimType }
  | { type: 'FontDim'; font?: string; metric: FontMetricType; padding?: number }
  | { type: 'PropertyDim'; name: string }
  | {
      type: 'DimOperator';
      op: OperatorType;
      left: DimNode;
      right: DimNode;
    };

/** Area 定义 — 4个Dim表达式确定一个矩形 */
export interface AreaDef {
  left: DimNode;
  top: DimNode;
  right?: DimNode;
  bottom?: DimNode;
  width?: DimNode;
  height?: DimNode;
}

/** FrameComponent — 九宫格/三段式框架组件 */
export interface FrameComponent {
  area: AreaDef;
  images: Partial<Record<FrameImageType, ImageRef>>;
  imageProperties?: Partial<Record<FrameImageType, string>>;
  vertFormat?: VertFormat;
  horzFormat?: HorzFormat;
  colours?: ColourRect;
  colourRectProperty?: string;
}

/** ImageryComponent — 单图像组件 */
export interface ImageryComponent {
  area: AreaDef;
  image?: ImageRef;
  imageProperty?: string;
  vertFormat?: VertFormat;
  horzFormat?: HorzFormat;
  vertFormatProperty?: string;
  horzFormatProperty?: string;
  colours?: ColourRect;
  colourProperty?: string;
  colourRectProperty?: string;
}

/** TextComponent — 文本组件 */
export interface TextComponent {
  area: AreaDef;
  font?: string;
  text?: string;
  vertFormat?: VertFormat;
  horzFormat?: HorzFormat;
  vertFormatProperty?: string;
  horzFormatProperty?: string;
  colours?: ColourRect;
  colourProperty?: string;
  colourRectProperty?: string;
  borderEnableProperty?: string;
  borderColourProperty?: string;
  defaultColourEnableProperty?: string;
  defaultBorderEnableProperty?: string;
}

/** ImagerySection — 可视化段落 */
export interface ImagerySection {
  name: string;
  frameComponents: FrameComponent[];
  imageryComponents: ImageryComponent[];
  textComponents: TextComponent[];
}

/** StateImagery Layer Section 引用 */
export interface StateSectionRef {
  sectionName: string;
  look?: string;
  colourProperty?: string;
  colourRectProperty?: string;
  colours?: ColourRect;
}

/** StateImagery Layer */
export interface StateLayer {
  sections: StateSectionRef[];
  colourProperty?: string;
  colourRectProperty?: string;
  colours?: ColourRect;
}

/** StateImagery — 状态图像组合 */
export interface StateImagery {
  name: string;
  layers: StateLayer[];
}

/** PropertyDefinition — 属性定义 */
export interface PropertyDefinition {
  name: string;
  initialValue: string;
  redrawOnWrite: boolean;
  layoutOnWrite?: boolean;
  type?: string;
  help?: string;
}

/** PropertyLinkDefinition — 属性链接定义 */
export interface PropertyLinkDefinition {
  name: string;
  widget: string;
  targetProperty: string;
  initialValue?: string;
  type?: string;
}

/** Property — 静态属性 */
export interface Property {
  name: string;
  value: string;
}

/** NamedArea — 命名区域 */
export interface NamedArea {
  name: string;
  area: AreaDef;
}

/** ChildWidget — 子控件定义 */
export interface ChildWidget {
  type: string;
  nameSuffix: string;
  autoWindow?: boolean;
  area: AreaDef;
  properties: Property[];
}

/** WidgetLook — 完整控件外观定义 */
export interface WidgetLook {
  name: string;
  propertyDefinitions: PropertyDefinition[];
  propertyLinkDefinitions: PropertyLinkDefinition[];
  properties: Property[];
  namedAreas: NamedArea[];
  children: ChildWidget[];
  imagerySections: ImagerySection[];
  stateImagerys: StateImagery[];
}

/** Falagard 文档 — 顶层根节点 */
export interface FalagardDocument {
  sourceFilePath: string;
  widgetLooks: WidgetLook[];
}

/** WidgetLook 索引条目 — 用于大文件延迟加载 */
export interface WidgetLookIndex {
  name: string;
  lineStart: number;
  lineEnd: number;
  byteStart: number;
  byteEnd: number;
  propertyDefinitionCount: number;
  imagerySectionCount: number;
  stateImageryCount: number;
  childCount: number;
  namedAreaCount: number;
}

/** 文件级索引 — 大文件快速导航 */
export interface FileIndex {
  filePath: string;
  totalWidgetLooks: number;
  widgetLookIndices: WidgetLookIndex[];
}
