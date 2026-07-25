/**
 * format-preserving-serializer — 格式保留序列化器
 *
 * 在将 WidgetLook AST 序列化回 XML 时，尽可能保留原始文件的格式：
 * - 缩进风格（空格/Tab、宽度）
 * - 注释（XML 注释块）
 * - 空行
 * - 属性顺序
 * - 自闭合标签风格
 * - 原始 XML 声明
 *
 * 工作原理：
 * 1. 在首次解析时，parser 收集 FormatPreservingNode 信息
 * 2. 序列化时，将 AST 数据与格式信息合并
 * 3. 对于新增的节点，使用默认格式
 */

import type {
  WidgetLook,
  PropertyDefinition,
  Property,
  ImagerySection,
  FrameComponent,
  ImageryComponent,
  TextComponent,
  StateImagery,
  DimNode,
  AreaDef,
  SerializationOptions,
} from '@shared/model';
import type {
  FormatPreservingNode,
  FormattedWidgetLook,
} from '@shared/model/serialization';
import { DEFAULT_SERIALIZATION_OPTIONS } from '@shared/model/serialization';
import { serializeWidgetLook, serializeFalagardDocument, escapeXml, serializeColours } from './serializer';

// ─── 格式保留序列化 ──────────────────────────────────────────────

/**
 * 将 WidgetLook 与格式信息合并序列化
 *
 * 如果有格式信息，则使用格式保留模式；
 * 否则回退到标准序列化器。
 */
export function serializeWidgetLookPreserving(
  wl: WidgetLook,
  formatInfo?: FormattedWidgetLook,
  options: SerializationOptions = DEFAULT_SERIALIZATION_OPTIONS,
): string {
  if (!formatInfo) {
    return serializeWidgetLook(wl, options);
  }

  const lines: string[] = [];
  const indent = options.indentString;

  // WidgetLook 开始标签
  const wlLeadingComments = formatInfo.format.leadingComments || [];
  for (const comment of wlLeadingComments) {
    lines.push(comment);
  }

  lines.push(`<WidgetLook name="${escapeXml(wl.name)}">`);

  // PropertyDefinitions
  for (let i = 0; i < wl.propertyDefinitions.length; i++) {
    const pd = wl.propertyDefinitions[i];
    const key = `propertyDefinition_${pd.name}`;
    const pdFormat = formatInfo.childFormats.get(key);

    if (pdFormat?.leadingComments) {
      for (const c of pdFormat.leadingComments) {
        lines.push(`${indent}${c.trimStart()}`);
      }
    }

    const attrs = buildAttributeString(
      { name: pd.name, initialValue: pd.initialValue },
      pdFormat,
      [
        ['name', pd.name],
        ['initialValue', pd.initialValue],
      ],
    );
    const extraAttrs: string[] = [];
    if (pd.redrawOnWrite) extraAttrs.push('redrawOnWrite="true"');
    if (pd.layoutOnWrite) extraAttrs.push('layoutOnWrite="true"');

    lines.push(`${indent}<PropertyDefinition ${attrs}${extraAttrs.length ? ' ' + extraAttrs.join(' ') : ''} />`);
  }

  // Properties
  for (let i = 0; i < wl.properties.length; i++) {
    const p = wl.properties[i];
    lines.push(`${indent}<Property name="${p.name}" value="${escapeXml(p.value)}" />`);
  }

  // NamedAreas
  for (const na of wl.namedAreas) {
    lines.push(`${indent}<NamedArea name="${na.name}">`);
    lines.push(serializeAreaPreserving(na.area, indent + indent, options));
    lines.push(`${indent}</NamedArea>`);
  }

  // ImagerySections
  for (const section of wl.imagerySections) {
    const secFormat = formatInfo.sectionFormats.get(section.name);
    if (secFormat?.leadingComments) {
      for (const c of secFormat.leadingComments) {
        lines.push(`${indent}${c.trimStart()}`);
      }
    }

    // 保留空行
    if (secFormat?.rawContent?.includes('\n\n')) {
      lines.push('');
    }

    lines.push(`${indent}<ImagerySection name="${section.name}">`);

    for (const fc of section.frameComponents) {
      lines.push(serializeFrameComponentPreserving(fc, indent + indent, options));
    }
    for (const ic of section.imageryComponents) {
      lines.push(serializeImageryComponentPreserving(ic, indent + indent, options));
    }
    for (const tc of section.textComponents) {
      lines.push(serializeTextComponentPreserving(tc, indent + indent, options));
    }

    lines.push(`${indent}</ImagerySection>`);
  }

  // StateImagerys
  for (const si of wl.stateImagerys) {
    const stateFormat = formatInfo.stateFormats.get(si.name);
    if (stateFormat?.leadingComments) {
      for (const c of stateFormat.leadingComments) {
        lines.push(`${indent}${c.trimStart()}`);
      }
    }

    lines.push(`${indent}<StateImagery name="${si.name}">`);
    for (const layer of si.layers) {
      lines.push(`${indent}${indent}<Layer>`);
      for (const sec of layer.sections) {
        const attrs = [`section="${sec.sectionName}"`];
        if (sec.look) {
          attrs.push(`look="${sec.look}"`);
        }
        if (sec.colourProperty) {
          lines.push(`${indent}${indent}${indent}<Section ${attrs.join(' ')} >`);
          lines.push(`${indent}${indent}${indent}${indent}<ColourProperty name="${sec.colourProperty}" />`);
          lines.push(`${indent}${indent}${indent}</Section>`);
        } else if (sec.colourRectProperty) {
          lines.push(`${indent}${indent}${indent}<Section ${attrs.join(' ')} >`);
          lines.push(`${indent}${indent}${indent}${indent}<ColourRectProperty name="${sec.colourRectProperty}" />`);
          lines.push(`${indent}${indent}${indent}</Section>`);
        } else if (sec.colours) {
          lines.push(`${indent}${indent}${indent}<Section ${attrs.join(' ')} >`);
          lines.push(serializeColours(sec.colours, indent + indent + indent + indent));
          lines.push(`${indent}${indent}${indent}</Section>`);
        } else {
          lines.push(`${indent}${indent}${indent}<Section ${attrs.join(' ')} />`);
        }
      }
      lines.push(`${indent}${indent}</Layer>`);
    }
    lines.push(`${indent}</StateImagery>`);
  }

  lines.push(`</WidgetLook>`);
  return lines.join('\n');
}

/**
 * 格式保留的完整文档序列化
 */
export function serializeFalagardDocumentPreserving(
  widgetLooks: WidgetLook[],
  formatInfos: Map<string, FormattedWidgetLook>,
  options: SerializationOptions = DEFAULT_SERIALIZATION_OPTIONS,
  originalHeader?: string,
): string {
  const parts: string[] = [];

  // 保留原始 XML 声明或使用默认
  if (originalHeader) {
    parts.push(originalHeader);
  } else {
    parts.push('<?xml version="1.0" ?>');
  }

  parts.push('<Falagard>');

  for (const wl of widgetLooks) {
    const formatInfo = formatInfos.get(wl.name);
    const xml = serializeWidgetLookPreserving(wl, formatInfo, options);
    for (const line of xml.split('\n')) {
      parts.push(`${options.indentString}${line}`);
    }
  }

  parts.push('</Falagard>');
  return parts.join('\n');
}

// ─── 辅助函数 ────────────────────────────────────────────────────

function serializeAreaPreserving(
  area: AreaDef,
  indent: string,
  options: SerializationOptions,
): string {
  const lines: string[] = [];
  lines.push(`${indent}<Area>`);
  lines.push(`${indent}${options.indentString}<Dim type="LeftEdge" >${serializeDimInline(area.left)}</Dim>`);
  lines.push(`${indent}${options.indentString}<Dim type="TopEdge" >${serializeDimInline(area.top)}</Dim>`);
  if (area.width) {
    lines.push(`${indent}${options.indentString}<Dim type="Width" >${serializeDimInline(area.width)}</Dim>`);
  }
  if (area.height) {
    lines.push(`${indent}${options.indentString}<Dim type="Height" >${serializeDimInline(area.height)}</Dim>`);
  }
  if (area.right) {
    lines.push(`${indent}${options.indentString}<Dim type="RightEdge" >${serializeDimInline(area.right)}</Dim>`);
  }
  if (area.bottom) {
    lines.push(`${indent}${options.indentString}<Dim type="BottomEdge" >${serializeDimInline(area.bottom)}</Dim>`);
  }
  lines.push(`${indent}</Area>`);
  return lines.join('\n');
}

function serializeDimInline(node: DimNode): string {
  switch (node.type) {
    case 'AbsoluteDim':
      return `<AbsoluteDim value="${node.value}" />`;
    case 'UnifiedDim':
      return `<UnifiedDim scale="${node.scale}" offset="${node.offset}" type="${node.dimType}" />`;
    case 'ImageDim':
      return `<ImageDim imageset="${node.imageset}" image="${node.image}" dimension="${node.dimType}" />`;
    case 'WidgetDim': {
      const w = node.widget ? ` widget="${node.widget}"` : '';
      return `<WidgetDim${w} dimension="${node.dimType}" />`;
    }
    case 'FontDim': {
      const f = node.font ? ` font="${node.font}"` : '';
      const p = node.padding ? ` padding="${node.padding}"` : '';
      return `<FontDim${f} metric="${node.metric}"${p} />`;
    }
    case 'PropertyDim':
      return `<PropertyDim name="${node.name}" />`;
    case 'DimOperator':
      return `${serializeDimInline(node.left)}<DimOperator op="${node.op}">${serializeDimInline(node.right)}</DimOperator>`;
  }
}

function serializeFrameComponentPreserving(
  fc: FrameComponent,
  indent: string,
  options: SerializationOptions,
): string {
  const lines: string[] = [];
  lines.push(`${indent}<FrameComponent>`);
  lines.push(serializeAreaPreserving(fc.area, indent + options.indentString, options));

  for (const [imgType, imgRef] of Object.entries(fc.images)) {
    if (imgRef) {
      lines.push(`${indent}${options.indentString}<Image type="${imgType}" imageset="${imgRef.imageset}" image="${imgRef.image}" />`);
    }
  }
  for (const [imgType, propertyName] of Object.entries(fc.imageProperties ?? {})) {
    if (propertyName) {
      lines.push(`${indent}${options.indentString}<ImageProperty type="${imgType}" name="${propertyName}" />`);
    }
  }
  if (fc.colourRectProperty) {
    lines.push(`${indent}${options.indentString}<ColourRectProperty name="${fc.colourRectProperty}" />`);
  }

  if (fc.vertFormat) {
    lines.push(`${indent}${options.indentString}<VertFormat type="${fc.vertFormat}" />`);
  }
  if (fc.horzFormat) {
    lines.push(`${indent}${options.indentString}<HorzFormat type="${fc.horzFormat}" />`);
  }
  if (fc.colours) {
    lines.push(serializeColours(fc.colours, indent + options.indentString));
  }

  lines.push(`${indent}</FrameComponent>`);
  return lines.join('\n');
}

function serializeImageryComponentPreserving(
  ic: ImageryComponent,
  indent: string,
  options: SerializationOptions,
): string {
  const lines: string[] = [];
  lines.push(`${indent}<ImageryComponent>`);
  lines.push(serializeAreaPreserving(ic.area, indent + options.indentString, options));

  if (ic.image) {
    lines.push(`${indent}${options.indentString}<Image imageset="${ic.image.imageset}" image="${ic.image.image}" />`);
  }
  if (ic.imageProperty) {
    lines.push(`${indent}${options.indentString}<ImageProperty name="${ic.imageProperty}" />`);
  }
  if (ic.vertFormat) {
    lines.push(`${indent}${options.indentString}<VertFormat type="${ic.vertFormat}" />`);
  }
  if (ic.horzFormat) {
    lines.push(`${indent}${options.indentString}<HorzFormat type="${ic.horzFormat}" />`);
  }
  if (ic.vertFormatProperty) {
    lines.push(`${indent}${options.indentString}<VertFormatProperty name="${ic.vertFormatProperty}" />`);
  }
  if (ic.horzFormatProperty) {
    lines.push(`${indent}${options.indentString}<HorzFormatProperty name="${ic.horzFormatProperty}" />`);
  }
  if (ic.colours) {
    lines.push(serializeColours(ic.colours, indent + options.indentString));
  }
  if (ic.colourProperty) {
    lines.push(`${indent}${options.indentString}<ColourProperty name="${ic.colourProperty}" />`);
  }
  if (ic.colourRectProperty) {
    lines.push(`${indent}${options.indentString}<ColourRectProperty name="${ic.colourRectProperty}" />`);
  }

  lines.push(`${indent}</ImageryComponent>`);
  return lines.join('\n');
}

function serializeTextComponentPreserving(
  tc: TextComponent,
  indent: string,
  options: SerializationOptions,
): string {
  const lines: string[] = [];
  lines.push(`${indent}<TextComponent>`);
  lines.push(serializeAreaPreserving(tc.area, indent + options.indentString, options));

  if (tc.vertFormat) {
    lines.push(`${indent}${options.indentString}<VertFormat type="${tc.vertFormat}" />`);
  }
  if (tc.horzFormat) {
    lines.push(`${indent}${options.indentString}<HorzFormat type="${tc.horzFormat}" />`);
  }
  if (tc.colours) {
    lines.push(serializeColours(tc.colours, indent + options.indentString));
  }
  if (tc.colourProperty) {
    lines.push(`${indent}${options.indentString}<ColourProperty name="${tc.colourProperty}" />`);
  }
  if (tc.colourRectProperty) {
    lines.push(`${indent}${options.indentString}<ColourRectProperty name="${tc.colourRectProperty}" />`);
  }
  if (tc.borderEnableProperty) {
    lines.push(`${indent}${options.indentString}<BorderEnableProperty name="${tc.borderEnableProperty}" />`);
  }
  if (tc.borderColourProperty) {
    lines.push(`${indent}${options.indentString}<BorderColourProperty name="${tc.borderColourProperty}" />`);
  }
  if (tc.defaultColourEnableProperty) {
    lines.push(`${indent}${options.indentString}<DefaultColourEnableProperty name="${tc.defaultColourEnableProperty}" />`);
  }
  if (tc.defaultBorderEnableProperty) {
    lines.push(`${indent}${options.indentString}<DefaultBorderEnableProperty name="${tc.defaultBorderEnableProperty}" />`);
  }

  lines.push(`${indent}</TextComponent>`);
  return lines.join('\n');
}

/**
 * 根据格式信息构建属性字符串
 * 如果有 attributeOrder，则按原始顺序排列
 */
function buildAttributeString(
  values: Record<string, string>,
  format?: FormatPreservingNode,
  defaultOrder: [string, string][] = [],
): string {
  if (format?.attributeOrder && format.attributeOrder.length > 0) {
    // 按原始属性顺序
    const parts: string[] = [];
    for (const attrName of format.attributeOrder) {
      if (values[attrName] !== undefined) {
        parts.push(`${attrName}="${escapeXml(values[attrName])}"`);
      }
    }
    // 添加新增的属性
    for (const [key, val] of defaultOrder) {
      if (!format.attributeOrder.includes(key)) {
        parts.push(`${key}="${escapeXml(val)}"`);
      }
    }
    return parts.join(' ');
  }

  // 默认顺序
  return defaultOrder.map(([k, v]) => `${k}="${escapeXml(v)}"`).join(' ');
}

// ─── 格式信息提取（从原始 XML 文本） ────────────────────────────

/**
 * 从原始 XML 文本中提取格式信息
 *
 * 这是在首次解析时调用的，用于收集缩进、注释等格式信息。
 */
export function extractFormatInfo(
  xmlContent: string,
  widgetLookNames: string[],
): Map<string, FormattedWidgetLook> {
  const result = new Map<string, FormattedWidgetLook>();
  const lines = xmlContent.split('\n');

  let currentWlName: string | null = null;
  let leadingComments: string[] = [];
  let inWidgetLook = false;

  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];
    const trimmed = line.trim();

    // 检测 WidgetLook 开始标签
    const wlMatch = trimmed.match(/^<WidgetLook\s+name="([^"]+)"/);
    if (wlMatch) {
      currentWlName = wlMatch[1];
      inWidgetLook = true;

      result.set(currentWlName, {
        data: null as unknown as import('@shared/model').WidgetLook,
        format: {
          leadingComments: [...leadingComments],
          indent: detectIndent(line),
        },
        childFormats: new Map(),
        sectionFormats: new Map(),
        stateFormats: new Map(),
      });

      leadingComments = [];
      continue;
    }

    // 检测 WidgetLook 结束标签
    if (trimmed === '</WidgetLook>') {
      currentWlName = null;
      inWidgetLook = false;
      continue;
    }

    // 收集注释
    if (trimmed.startsWith('<!--')) {
      leadingComments.push(line);
      continue;
    }

    // 在 WidgetLook 内部，收集 section/state 格式
    if (inWidgetLook && currentWlName) {
      const info = result.get(currentWlName);

      const secMatch = trimmed.match(/^<ImagerySection\s+name="([^"]+)"/);
      if (secMatch && info) {
        info.sectionFormats.set(secMatch[1], {
          leadingComments: [...leadingComments],
          indent: detectIndent(line),
        });
        leadingComments = [];
      }

      const stateMatch = trimmed.match(/^<StateImagery\s+name="([^"]+)"/);
      if (stateMatch && info) {
        info.stateFormats.set(stateMatch[1], {
          leadingComments: [...leadingComments],
          indent: detectIndent(line),
        });
        leadingComments = [];
      }
    }

    // 非注释、非空行时清空注释缓冲
    if (trimmed && !trimmed.startsWith('<!--')) {
      leadingComments = [];
    }
  }

  return result;
}

/** 检测行的缩进 */
function detectIndent(line: string): string {
  const match = line.match(/^(\s*)/);
  return match ? match[1] : '';
}
