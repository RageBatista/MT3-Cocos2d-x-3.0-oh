import * as fs from 'fs';
import * as path from 'path';
import { XMLParser } from 'fast-xml-parser';
import type {
  FileIndex,
  WidgetLookIndex,
  WidgetLook,
  PropertyDefinition,
  PropertyLinkDefinition,
  Property,
  NamedArea,
  ChildWidget,
  ImagerySection,
  FrameComponent,
  ImageryComponent,
  TextComponent,
  StateImagery,
  StateLayer,
  StateSectionRef,
  DimNode,
  AreaDef,
  ImageRef,
  ColourRect,
  DimType,
  OperatorType,
  FrameImageType,
  VertFormat,
  HorzFormat,
  FontMetricType,
} from '@shared/model';

const ARRAY_OPTIONS = {
  isArray: (name: string) => [
    'WidgetLook', 'PropertyDefinition', 'PropertyLinkDefinition', 'Property',
    'NamedArea', 'Child', 'ImagerySection', 'StateImagery', 'Layer',
    'Section', 'FrameComponent', 'ImageryComponent', 'TextComponent',
    'Dim', 'Image',
  ].includes(name),
};

/** 构建文件级索引 — 用于大文件延迟加载 */
export function buildFileIndex(filePath: string): FileIndex {
  const content = fs.readFileSync(filePath, 'utf-8');
  const lines = content.split('\n');
  const indices: WidgetLookIndex[] = [];

  let currentWL: Partial<WidgetLookIndex> | null = null;
  let byteOffset = 0;
  for (let lineIdx = 0; lineIdx < lines.length; lineIdx++) {
    const line = lines[lineIdx];
    const trimmed = line.trim();

    if (trimmed.startsWith('<WidgetLook') && trimmed.includes('name=')) {
      const nameMatch = trimmed.match(/name="([^"]+)"/);
      if (nameMatch) {
        currentWL = {
          name: nameMatch[1],
          lineStart: lineIdx + 1,
          byteStart: byteOffset,
          propertyDefinitionCount: 0,
          imagerySectionCount: 0,
          stateImageryCount: 0,
          childCount: 0,
          namedAreaCount: 0,
        };
      }
    } else if (currentWL) {
      if (trimmed.startsWith('</WidgetLook')) {
        currentWL.lineEnd = lineIdx + 1;
        currentWL.byteEnd = byteOffset + line.length;
        indices.push(currentWL as WidgetLookIndex);
        currentWL = null;
      } else {
        if (trimmed.startsWith('<PropertyDefinition')) currentWL.propertyDefinitionCount!++;
        if (trimmed.startsWith('<ImagerySection')) currentWL.imagerySectionCount!++;
        if (trimmed.startsWith('<StateImagery')) currentWL.stateImageryCount!++;
        if (trimmed.startsWith('<Child')) currentWL.childCount!++;
        if (trimmed.startsWith('<NamedArea')) currentWL.namedAreaCount!++;
      }
    }

    byteOffset += Buffer.byteLength(line + '\n', 'utf-8');
  }

  return {
    filePath,
    totalWidgetLooks: indices.length,
    widgetLookIndices: indices,
  };
}

/** 按索引范围精确解析单个 WidgetLook */
export function parseWidgetLookByIndex(filePath: string, index: WidgetLookIndex): WidgetLook {
  const content = fs.readFileSync(filePath, 'utf-8');
  const lines = content.split('\n');
  const slice = lines.slice(index.lineStart - 1, index.lineEnd).join('\n');
  const wrapper = `<?xml version="1.0" ?><Falagard>${slice}</Falagard>`;
  return parseWidgetLookXml(wrapper);
}

/** 解析完整 looknfeel 文件 */
export function parseLookNFeelFile(filePath: string): WidgetLook[] {
  const content = fs.readFileSync(filePath, 'utf-8');
  return parseLookNFeelXml(content);
}

/** 从 XML 字符串解析所有 WidgetLook */
export function parseLookNFeelXml(xmlContent: string): WidgetLook[] {
  const parser = new XMLParser({
    ignoreAttributes: false,
    attributeNamePrefix: '@_',
    preserveOrder: false,
    commentPropName: '#comment',
    ...ARRAY_OPTIONS,
  });

  const parsed = parser.parse(xmlContent);
  const falagard = parsed.Falagard;
  if (!falagard || !falagard.WidgetLook) return [];

  const wls = Array.isArray(falagard.WidgetLook) ? falagard.WidgetLook : [falagard.WidgetLook];
  return wls.map((wl: Record<string, unknown>) => parseWidgetLookObj(wl));
}

/** 从被包裹的 XML 解析单个 WidgetLook */
function parseWidgetLookXml(wrapperXml: string): WidgetLook {
  const parser = new XMLParser({
    ignoreAttributes: false,
    attributeNamePrefix: '@_',
    preserveOrder: false,
    ...ARRAY_OPTIONS,
  });

  const parsed = parser.parse(wrapperXml);
  const falagard = parsed.Falagard;
  if (!falagard || !falagard.WidgetLook) {
    throw new Error('Invalid WidgetLook XML wrapper');
  }
  const wlArr = Array.isArray(falagard.WidgetLook) ? falagard.WidgetLook : [falagard.WidgetLook];
  return parseWidgetLookObj(wlArr[0] as Record<string, unknown>);
}

/** 将 fast-xml-parser 的 JS 对象转换为 WidgetLook 模型 */
function parseWidgetLookObj(obj: Record<string, unknown>): WidgetLook {
  return {
    name: (obj['@_name'] as string) || '',
    propertyDefinitions: parseArray(obj.PropertyDefinition).map(parsePropertyDefinition),
    propertyLinkDefinitions: parseArray(obj.PropertyLinkDefinition).map(parsePropertyLinkDefinition),
    properties: parseArray(obj.Property).map(parseProperty),
    namedAreas: parseArray(obj.NamedArea).map(parseNamedArea),
    children: parseArray(obj.Child).map(parseChildWidget),
    imagerySections: parseArray(obj.ImagerySection).map(parseImagerySection),
    stateImagerys: parseArray(obj.StateImagery).map(parseStateImagery),
  };
}

/** 解析 PropertyDefinition */
function parsePropertyDefinition(obj: Record<string, unknown>): PropertyDefinition {
  return {
    name: (obj['@_name'] as string) || '',
    initialValue: (obj['@_initialValue'] as string) || '',
    redrawOnWrite: (obj['@_redrawOnWrite'] as string) === 'true',
    layoutOnWrite: (obj['@_layoutOnWrite'] as string) === 'true',
    type: obj['@_type'] as string | undefined,
    help: obj['@_help'] as string | undefined,
  };
}

/** 解析 PropertyLinkDefinition */
function parsePropertyLinkDefinition(obj: Record<string, unknown>): PropertyLinkDefinition {
  return {
    name: (obj['@_name'] as string) || '',
    widget: (obj['@_widget'] as string) || '',
    targetProperty: (obj['@_targetProperty'] as string) || '',
    initialValue: obj['@_initialValue'] as string | undefined,
    type: obj['@_type'] as string | undefined,
  };
}

/** 解析 Property */
function parseProperty(obj: Record<string, unknown>): Property {
  return {
    name: (obj['@_name'] as string) || '',
    value: (obj['@_value'] as string) || '',
  };
}

/** 解析 NamedArea */
function parseNamedArea(obj: Record<string, unknown>): NamedArea {
  return {
    name: (obj['@_name'] as string) || '',
    area: parseArea(obj.Area as Record<string, unknown>),
  };
}

/** 解析 ChildWidget */
function parseChildWidget(obj: Record<string, unknown>): ChildWidget {
  return {
    type: (obj['@_type'] as string) || '',
    nameSuffix: (obj['@_nameSuffix'] as string) || '',
    autoWindow: (obj['@_autoWindow'] as string) === 'true',
    area: parseArea(obj.Area as Record<string, unknown>),
    properties: parseArray(obj.Property).map(parseProperty),
  };
}

/** 解析 ImagerySection */
function parseImagerySection(obj: Record<string, unknown>): ImagerySection {
  return {
    name: (obj['@_name'] as string) || '',
    frameComponents: parseArray(obj.FrameComponent).map(parseFrameComponent),
    imageryComponents: parseArray(obj.ImageryComponent).map(parseImageryComponent),
    textComponents: parseArray(obj.TextComponent).map(parseTextComponent),
  };
}

/** 解析 FrameComponent */
function parseFrameComponent(obj: Record<string, unknown>): FrameComponent {
  const images: Partial<Record<FrameImageType, ImageRef>> = {};
  const imageProperties: Partial<Record<FrameImageType, string>> = {};
  const imageObjs = parseArray(obj.Image);
  for (const img of imageObjs) {
    const imgType = img['@_type'] as FrameImageType;
    if (imgType) {
      images[imgType] = {
        imageset: (img['@_imageset'] as string) || '',
        image: (img['@_image'] as string) || '',
      };
    }
  }
  for (const imgProp of parseArray(obj.ImageProperty)) {
    const imgType = imgProp['@_type'] as FrameImageType;
    const propertyName = imgProp['@_name'] as string | undefined;
    if (imgType && propertyName) {
      imageProperties[imgType] = propertyName;
    }
  }

  return {
    area: parseArea(obj.Area as Record<string, unknown>),
    images,
    imageProperties: Object.keys(imageProperties).length > 0 ? imageProperties : undefined,
    vertFormat: parseVertFormat(obj.VertFormat),
    horzFormat: parseHorzFormat(obj.HorzFormat),
    colours: parseColours(obj.Colours as Record<string, unknown> | undefined),
    colourRectProperty: parsePropertyName(obj.ColourRectProperty),
  };
}

/** 解析 ImageryComponent */
function parseImageryComponent(obj: Record<string, unknown>): ImageryComponent {
  const result: ImageryComponent = {
    area: parseArea(obj.Area as Record<string, unknown>),
  };

  if (obj.Image) {
    const img = Array.isArray(obj.Image) ? obj.Image[0] : obj.Image;
    if (img['@_imageset'] && img['@_image']) {
      result.image = { imageset: img['@_imageset'], image: img['@_image'] };
    }
  }
  if (obj.ImageProperty) {
    result.imageProperty = (toRecord(obj.ImageProperty)['@_name'] as string) || undefined;
  }

  if (obj.VertFormat) {
    result.vertFormat = parseVertFormat(obj.VertFormat);
  }
  if (obj.HorzFormat) {
    result.horzFormat = parseHorzFormat(obj.HorzFormat);
  }
  if (obj.VertFormatProperty) {
    result.vertFormatProperty = (obj.VertFormatProperty as Record<string, unknown>)['@_name'] as string;
  }
  if (obj.HorzFormatProperty) {
    result.horzFormatProperty = (obj.HorzFormatProperty as Record<string, unknown>)['@_name'] as string;
  }

  result.colours = parseColours(obj.Colours as Record<string, unknown> | undefined);
  if (obj.ColourProperty) {
    result.colourProperty = (obj.ColourProperty as Record<string, unknown>)['@_name'] as string;
  }
  if (obj.ColourRectProperty) {
    result.colourRectProperty = (obj.ColourRectProperty as Record<string, unknown>)['@_name'] as string;
  }

  return result;
}

/** 解析 TextComponent */
function parseTextComponent(obj: Record<string, unknown>): TextComponent {
  const result: TextComponent = {
    area: parseArea(obj.Area as Record<string, unknown>),
  };

  if (obj.Text) {
    const textEl = toRecord(obj.Text);
    result.font = textEl['@_font'] as string | undefined;
    result.text = textEl['@_string'] as string | undefined;
  }

  if (obj.VertFormat) result.vertFormat = parseVertFormat(obj.VertFormat);
  if (obj.HorzFormat) result.horzFormat = parseHorzFormat(obj.HorzFormat);
  if (obj.VertFormatProperty) result.vertFormatProperty = (obj.VertFormatProperty as Record<string, unknown>)['@_name'] as string;
  if (obj.HorzFormatProperty) result.horzFormatProperty = (obj.HorzFormatProperty as Record<string, unknown>)['@_name'] as string;

  result.colours = parseColours(obj.Colours as Record<string, unknown> | undefined);
  if (obj.ColourProperty) result.colourProperty = (obj.ColourProperty as Record<string, unknown>)['@_name'] as string;
  if (obj.ColourRectProperty) result.colourRectProperty = (obj.ColourRectProperty as Record<string, unknown>)['@_name'] as string;
  if (obj.BorderEnableProperty) result.borderEnableProperty = (obj.BorderEnableProperty as Record<string, unknown>)['@_name'] as string;
  if (obj.BorderColourProperty) result.borderColourProperty = (obj.BorderColourProperty as Record<string, unknown>)['@_name'] as string;
  if (obj.DefaultColourEnableProperty) result.defaultColourEnableProperty = (obj.DefaultColourEnableProperty as Record<string, unknown>)['@_name'] as string;
  if (obj.DefaultBorderEnableProperty) result.defaultBorderEnableProperty = (obj.DefaultBorderEnableProperty as Record<string, unknown>)['@_name'] as string;

  return result;
}

/** 解析 StateImagery */
function parseStateImagery(obj: Record<string, unknown>): StateImagery {
  return {
    name: (obj['@_name'] as string) || '',
    layers: parseArray(obj.Layer).map(parseStateLayer),
  };
}

/** 解析 StateLayer */
function parseStateLayer(obj: Record<string, unknown>): StateLayer {
  return {
    sections: parseArray(obj.Section).map(parseStateSectionRef),
    colourProperty: parsePropertyName(obj.ColourProperty),
    colourRectProperty: parsePropertyName(obj.ColourRectProperty),
    colours: parseColours(obj.Colours as Record<string, unknown> | undefined),
  };
}

/** 解析 StateSectionRef */
function parseStateSectionRef(obj: Record<string, unknown>): StateSectionRef {
  const result: StateSectionRef = {
    sectionName: (obj['@_section'] as string) || '',
    look: obj['@_look'] as string | undefined,
  };

  if (obj.ColourProperty) {
    result.colourProperty = (obj.ColourProperty as Record<string, unknown>)['@_name'] as string;
  }
  if (obj.ColourRectProperty) {
    result.colourRectProperty = (obj.ColourRectProperty as Record<string, unknown>)['@_name'] as string;
  }
  result.colours = parseColours(obj.Colours as Record<string, unknown> | undefined);

  return result;
}

/** 解析 Area — 4个Dim表达式 */
function parseArea(obj: Record<string, unknown> | undefined): AreaDef {
  if (!obj) return { left: { type: 'AbsoluteDim', value: 0 }, top: { type: 'AbsoluteDim', value: 0 } };

  const dims = parseArray(obj.Dim);
  const dimMap = new Map<string, DimNode>();
  for (const dim of dims) {
    const dimType = dim['@_type'] as string;
    if (dimType) {
      dimMap.set(dimType, parseDimNode(dim));
    }
  }

  const area: AreaDef = {
    left: dimMap.get('LeftEdge') || { type: 'AbsoluteDim', value: 0 },
    top: dimMap.get('TopEdge') || { type: 'AbsoluteDim', value: 0 },
  };

  if (dimMap.has('RightEdge')) area.right = dimMap.get('RightEdge');
  if (dimMap.has('BottomEdge')) area.bottom = dimMap.get('BottomEdge');
  if (dimMap.has('Width')) area.width = dimMap.get('Width');
  if (dimMap.has('Height')) area.height = dimMap.get('Height');

  return area;
}

/** 递归解析 Dim 表达式节点 */
function parseDimNode(obj: Record<string, unknown>): DimNode {
  const direct = parseDimExpressionContainer(obj);
  return direct ?? { type: 'AbsoluteDim', value: 0 };
}

function parseDimExpressionContainer(container: Record<string, unknown>): DimNode | null {
  for (const type of DIM_NODE_KEYS) {
    const rawNode = container[type];
    if (rawNode === undefined) {
      continue;
    }

    const nodeRecord = toRecord(rawNode);
    const baseNode = createDimNode(type, nodeRecord);
    if (!baseNode) {
      return null;
    }

    const operatorSource = nodeRecord.DimOperator ?? container.DimOperator;
    return appendOperatorChain(baseNode, operatorSource);
  }

  return null;
}

function appendOperatorChain(
  left: DimNode,
  operatorSource: unknown,
): DimNode {
  const operators = parseArray(operatorSource);
  let current = left;

  for (const operatorNode of operators) {
    current = {
      type: 'DimOperator',
      op: (operatorNode['@_op'] as OperatorType) || 'Add',
      left: current,
      right: parseDimExpressionContainer(operatorNode) || { type: 'AbsoluteDim', value: 0 },
    };
  }

  return current;
}

const DIM_NODE_KEYS = [
  'AbsoluteDim',
  'UnifiedDim',
  'ImageDim',
  'WidgetDim',
  'FontDim',
  'PropertyDim',
] as const;

function createDimNode(
  type: typeof DIM_NODE_KEYS[number],
  obj: Record<string, unknown>,
): DimNode | null {
  switch (type) {
    case 'AbsoluteDim':
      return { type, value: parseFloat((obj['@_value'] as string) || '0') };
    case 'UnifiedDim':
      return {
        type,
        scale: parseFloat((obj['@_scale'] as string) || '0'),
        offset: parseFloat((obj['@_offset'] as string) || '0'),
        dimType: (obj['@_type'] as DimType) || 'Width',
      };
    case 'ImageDim':
      return {
        type,
        imageset: (obj['@_imageset'] as string) || '',
        image: (obj['@_image'] as string) || '',
        dimType: (obj['@_dimension'] as DimType) || 'Width',
      };
    case 'WidgetDim':
      return {
        type,
        widget: obj['@_widget'] as string | undefined,
        dimType: (obj['@_dimension'] as DimType) || 'Width',
      };
    case 'FontDim':
      return {
        type,
        font: obj['@_font'] as string | undefined,
        metric: (obj['@_metric'] as FontMetricType) || 'LineSpacing',
        padding: obj['@_padding'] ? parseFloat(obj['@_padding'] as string) : undefined,
      };
    case 'PropertyDim':
      return {
        type,
        name: (obj['@_name'] as string) || '',
      };
  }
}

/** 解析 Colours 节点 */
function parseColours(obj: Record<string, unknown> | undefined): ColourRect | undefined {
  if (!obj) return undefined;
  return {
    topLeft: (obj['@_topLeft'] as string) || 'FFFFFFFF',
    topRight: (obj['@_topRight'] as string) || 'FFFFFFFF',
    bottomLeft: (obj['@_bottomLeft'] as string) || 'FFFFFFFF',
    bottomRight: (obj['@_bottomRight'] as string) || 'FFFFFFFF',
  };
}

function parseVertFormat(val: unknown): VertFormat | undefined {
  const type = parseTypeAttribute(val);
  return type as VertFormat | undefined;
}

function parseHorzFormat(val: unknown): HorzFormat | undefined {
  const type = parseTypeAttribute(val);
  return type as HorzFormat | undefined;
}

function parseTypeAttribute(val: unknown): string | undefined {
  return toRecord(val)['@_type'] as string | undefined;
}

function parsePropertyName(val: unknown): string | undefined {
  return toRecord(val)['@_name'] as string | undefined;
}

function toRecord(val: unknown): Record<string, unknown> {
  if (Array.isArray(val)) {
    return toRecord(val[0]);
  }
  if (!val || typeof val !== 'object') {
    return {};
  }
  return val as Record<string, unknown>;
}

/** 安全地将值转为数组 */
function parseArray(val: unknown): Record<string, unknown>[] {
  if (!val) return [];
  if (Array.isArray(val)) return val as Record<string, unknown>[];
  return [val] as Record<string, unknown>[];
}
