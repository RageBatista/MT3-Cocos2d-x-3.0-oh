import type {
  WidgetLook,
  FrameComponent,
  ImageryComponent,
  TextComponent,
  StateLayer,
  DimNode,
  AreaDef,
  ColourRect,
  SerializationOptions,
} from '@shared/model';
import { DEFAULT_SERIALIZATION_OPTIONS } from '@shared/model';

/** 将 WidgetLook 序列化为 XML 字符串 */
export function serializeWidgetLook(
  wl: WidgetLook,
  options: SerializationOptions = DEFAULT_SERIALIZATION_OPTIONS,
): string {
  const indent = options.indentString;
  const lines: string[] = [];

  lines.push(`<WidgetLook name="${escapeXml(wl.name)}">`);

  for (const pd of wl.propertyDefinitions) {
    const attrs = [
      `name="${escapeXml(pd.name)}"`,
      `initialValue="${escapeXml(pd.initialValue)}"`,
    ];
    if (pd.redrawOnWrite) attrs.push('redrawOnWrite="true"');
    if (pd.layoutOnWrite) attrs.push('layoutOnWrite="true"');
    if (pd.type) attrs.push(`type="${escapeXml(pd.type)}"`);
    if (pd.help) attrs.push(`help="${escapeXml(pd.help)}"`);
    lines.push(`${indent}<PropertyDefinition ${attrs.join(' ')} />`);
  }

  for (const pld of wl.propertyLinkDefinitions) {
    const attrs = [
      `name="${escapeXml(pld.name)}"`,
      `widget="${escapeXml(pld.widget)}"`,
      `targetProperty="${escapeXml(pld.targetProperty)}"`,
    ];
    if (pld.initialValue !== undefined) attrs.push(`initialValue="${escapeXml(pld.initialValue)}"`);
    if (pld.type) attrs.push(`type="${escapeXml(pld.type)}"`);
    lines.push(`${indent}<PropertyLinkDefinition ${attrs.join(' ')} />`);
  }

  for (const p of wl.properties) {
    lines.push(`${indent}<Property name="${escapeXml(p.name)}" value="${escapeXml(p.value)}" />`);
  }

  for (const na of wl.namedAreas) {
    lines.push(`${indent}<NamedArea name="${escapeXml(na.name)}">`);
    lines.push(serializeArea(na.area, indent + indent, options));
    lines.push(`${indent}</NamedArea>`);
  }

  for (const child of wl.children) {
    const childAttrs = [
      `type="${escapeXml(child.type)}"`,
      `nameSuffix="${escapeXml(child.nameSuffix)}"`,
    ];
    if (child.autoWindow !== undefined) {
      childAttrs.push(`autoWindow="${child.autoWindow ? 'true' : 'false'}"`);
    }
    lines.push(`${indent}<Child ${childAttrs.join(' ')}>`);
    lines.push(serializeArea(child.area, indent + indent, options));
    for (const p of child.properties) {
      lines.push(`${indent}${indent}<Property name="${escapeXml(p.name)}" value="${escapeXml(p.value)}" />`);
    }
    lines.push(`${indent}</Child>`);
  }

  for (const section of wl.imagerySections) {
    lines.push(`${indent}<ImagerySection name="${escapeXml(section.name)}">`);
    for (const fc of section.frameComponents) {
      lines.push(serializeFrameComponent(fc, indent + indent, options));
    }
    for (const ic of section.imageryComponents) {
      lines.push(serializeImageryComponent(ic, indent + indent, options));
    }
    for (const tc of section.textComponents) {
      lines.push(serializeTextComponent(tc, indent + indent, options));
    }
    lines.push(`${indent}</ImagerySection>`);
  }

  for (const si of wl.stateImagerys) {
    lines.push(`${indent}<StateImagery name="${escapeXml(si.name)}">`);
    for (const layer of si.layers) {
      lines.push(serializeStateLayer(layer, indent + indent, options));
    }
    lines.push(`${indent}</StateImagery>`);
  }

  lines.push(`</WidgetLook>`);
  return lines.join('\n');
}

/** 序列化 Area */
function serializeArea(area: AreaDef, indent: string, options: SerializationOptions): string {
  const lines: string[] = [];
  lines.push(`${indent}<Area>`);
  lines.push(`${indent}${options.indentString}<Dim type="LeftEdge" >${serializeDimInline(area.left)}</Dim>`);
  lines.push(`${indent}${options.indentString}<Dim type="TopEdge" >${serializeDimInline(area.top)}</Dim>`);
  if (area.right) {
    lines.push(`${indent}${options.indentString}<Dim type="RightEdge" >${serializeDimInline(area.right)}</Dim>`);
  }
  if (area.bottom) {
    lines.push(`${indent}${options.indentString}<Dim type="BottomEdge" >${serializeDimInline(area.bottom)}</Dim>`);
  }
  if (area.width) {
    lines.push(`${indent}${options.indentString}<Dim type="Width" >${serializeDimInline(area.width)}</Dim>`);
  }
  if (area.height) {
    lines.push(`${indent}${options.indentString}<Dim type="Height" >${serializeDimInline(area.height)}</Dim>`);
  }
  lines.push(`${indent}</Area>`);
  return lines.join('\n');
}

/** 序列化 Dim 节点（内联格式） */
function serializeDimInline(node: DimNode): string {
  const flattened = flattenDimOperator(node);
  return serializeDimLeaf(flattened.base, flattened.chain);
}

/** 序列化 FrameComponent */
function serializeFrameComponent(fc: FrameComponent, indent: string, options: SerializationOptions): string {
  const lines: string[] = [];
  lines.push(`${indent}<FrameComponent>`);
  lines.push(serializeArea(fc.area, indent + options.indentString, options));

  for (const [imgType, imgRef] of Object.entries(fc.images)) {
    if (imgRef) {
      lines.push(`${indent}${options.indentString}<Image type="${imgType}" imageset="${escapeXml(imgRef.imageset)}" image="${escapeXml(imgRef.image)}" />`);
    }
  }
  for (const [imgType, propertyName] of Object.entries(fc.imageProperties ?? {})) {
    if (propertyName) {
      lines.push(`${indent}${options.indentString}<ImageProperty type="${imgType}" name="${escapeXml(propertyName)}" />`);
    }
  }
  if (fc.colourRectProperty) {
    lines.push(`${indent}${options.indentString}<ColourRectProperty name="${escapeXml(fc.colourRectProperty)}" />`);
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

/** 序列化 ImageryComponent */
function serializeImageryComponent(ic: ImageryComponent, indent: string, options: SerializationOptions): string {
  const lines: string[] = [];
  lines.push(`${indent}<ImageryComponent>`);
  lines.push(serializeArea(ic.area, indent + options.indentString, options));

  if (ic.image) {
    lines.push(`${indent}${options.indentString}<Image imageset="${escapeXml(ic.image.imageset)}" image="${escapeXml(ic.image.image)}" />`);
  }
  if (ic.imageProperty) {
    lines.push(`${indent}${options.indentString}<ImageProperty name="${escapeXml(ic.imageProperty)}" />`);
  }
  if (ic.vertFormat) {
    lines.push(`${indent}${options.indentString}<VertFormat type="${ic.vertFormat}" />`);
  }
  if (ic.horzFormat) {
    lines.push(`${indent}${options.indentString}<HorzFormat type="${ic.horzFormat}" />`);
  }
  if (ic.vertFormatProperty) {
    lines.push(`${indent}${options.indentString}<VertFormatProperty name="${escapeXml(ic.vertFormatProperty)}" />`);
  }
  if (ic.horzFormatProperty) {
    lines.push(`${indent}${options.indentString}<HorzFormatProperty name="${escapeXml(ic.horzFormatProperty)}" />`);
  }
  if (ic.colours) {
    lines.push(serializeColours(ic.colours, indent + options.indentString));
  }
  if (ic.colourProperty) {
    lines.push(`${indent}${options.indentString}<ColourProperty name="${escapeXml(ic.colourProperty)}" />`);
  }
  if (ic.colourRectProperty) {
    lines.push(`${indent}${options.indentString}<ColourRectProperty name="${escapeXml(ic.colourRectProperty)}" />`);
  }

  lines.push(`${indent}</ImageryComponent>`);
  return lines.join('\n');
}

/** 序列化 TextComponent */
function serializeTextComponent(tc: TextComponent, indent: string, options: SerializationOptions): string {
  const lines: string[] = [];
  lines.push(`${indent}<TextComponent>`);
  lines.push(serializeArea(tc.area, indent + options.indentString, options));

  if (tc.font !== undefined || tc.text !== undefined) {
    const attrs: string[] = [];
    if (tc.font !== undefined) attrs.push(`font="${escapeXml(tc.font)}"`);
    if (tc.text !== undefined) attrs.push(`string="${escapeXml(tc.text)}"`);
    lines.push(`${indent}${options.indentString}<Text ${attrs.join(' ')} />`);
  }

  if (tc.vertFormatProperty) {
    lines.push(`${indent}${options.indentString}<VertFormatProperty name="${escapeXml(tc.vertFormatProperty)}" />`);
  }
  if (tc.horzFormatProperty) {
    lines.push(`${indent}${options.indentString}<HorzFormatProperty name="${escapeXml(tc.horzFormatProperty)}" />`);
  }
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
    lines.push(`${indent}${options.indentString}<ColourProperty name="${escapeXml(tc.colourProperty)}" />`);
  }
  if (tc.colourRectProperty) {
    lines.push(`${indent}${options.indentString}<ColourRectProperty name="${escapeXml(tc.colourRectProperty)}" />`);
  }
  if (tc.borderEnableProperty) {
    lines.push(`${indent}${options.indentString}<BorderEnableProperty name="${escapeXml(tc.borderEnableProperty)}" />`);
  }
  if (tc.borderColourProperty) {
    lines.push(`${indent}${options.indentString}<BorderColourProperty name="${escapeXml(tc.borderColourProperty)}" />`);
  }
  if (tc.defaultColourEnableProperty) {
    lines.push(`${indent}${options.indentString}<DefaultColourEnableProperty name="${escapeXml(tc.defaultColourEnableProperty)}" />`);
  }
  if (tc.defaultBorderEnableProperty) {
    lines.push(`${indent}${options.indentString}<DefaultBorderEnableProperty name="${escapeXml(tc.defaultBorderEnableProperty)}" />`);
  }

  lines.push(`${indent}</TextComponent>`);
  return lines.join('\n');
}

/** 序列化 StateLayer */
function serializeStateLayer(layer: StateLayer, indent: string, options: SerializationOptions): string {
  const lines: string[] = [];
  lines.push(`${indent}<Layer>`);
  for (const sec of layer.sections) {
    const attrs = [`section="${escapeXml(sec.sectionName)}"`];
    if (sec.look) {
      attrs.push(`look="${escapeXml(sec.look)}"`);
    }
    if (sec.colourProperty) {
      lines.push(`${indent}${options.indentString}<Section ${attrs.join(' ')} >`);
      lines.push(`${indent}${options.indentString}${options.indentString}<ColourProperty name="${escapeXml(sec.colourProperty)}" />`);
      lines.push(`${indent}${options.indentString}</Section>`);
    } else if (sec.colourRectProperty) {
      lines.push(`${indent}${options.indentString}<Section ${attrs.join(' ')} >`);
      lines.push(`${indent}${options.indentString}${options.indentString}<ColourRectProperty name="${escapeXml(sec.colourRectProperty)}" />`);
      lines.push(`${indent}${options.indentString}</Section>`);
    } else if (sec.colours) {
      lines.push(`${indent}${options.indentString}<Section ${attrs.join(' ')} >`);
      lines.push(serializeColours(sec.colours, indent + options.indentString + options.indentString));
      lines.push(`${indent}${options.indentString}</Section>`);
    } else {
      lines.push(`${indent}${options.indentString}<Section ${attrs.join(' ')} />`);
    }
  }
  if (layer.colourProperty) {
    lines.push(`${indent}${options.indentString}<ColourProperty name="${escapeXml(layer.colourProperty)}" />`);
  } else if (layer.colourRectProperty) {
    lines.push(`${indent}${options.indentString}<ColourRectProperty name="${escapeXml(layer.colourRectProperty)}" />`);
  } else if (layer.colours) {
    lines.push(serializeColours(layer.colours, indent + options.indentString));
  }
  lines.push(`${indent}</Layer>`);
  return lines.join('\n');
}

/** 序列化 Colours（共享工具函数，供 format-preserving-serializer 复用） */
export function serializeColours(colours: ColourRect, indent: string): string {
  return `${indent}<Colours topLeft="${escapeXml(colours.topLeft)}" topRight="${escapeXml(colours.topRight)}" bottomLeft="${escapeXml(colours.bottomLeft)}" bottomRight="${escapeXml(colours.bottomRight)}" />`;
}

/** 将完整 Falagard 文档序列化为文件内容 */
export function serializeFalagardDocument(
  widgetLooks: WidgetLook[],
  options: SerializationOptions = DEFAULT_SERIALIZATION_OPTIONS,
): string {
  const parts: string[] = [];
  parts.push('<?xml version="1.0" ?>');
  parts.push('<Falagard>');

  for (const wl of widgetLooks) {
    const xml = serializeWidgetLook(wl, options);
    for (const line of xml.split('\n')) {
      parts.push(`${options.indentString}${line}`);
    }
  }

  parts.push('</Falagard>');
  return parts.join('\n');
}

function flattenDimOperator(node: DimNode): {
  base: Exclude<DimNode, { type: 'DimOperator' }>;
  chain: Array<{ op: Extract<DimNode, { type: 'DimOperator' }>['op']; right: DimNode }>;
} {
  if (node.type !== 'DimOperator') {
    return {
      base: node,
      chain: [],
    };
  }

  const flattenedLeft = flattenDimOperator(node.left);
  return {
    base: flattenedLeft.base,
    chain: [...flattenedLeft.chain, { op: node.op, right: node.right }],
  };
}

function serializeDimLeaf(
  node: Exclude<DimNode, { type: 'DimOperator' }>,
  chain: Array<{ op: Extract<DimNode, { type: 'DimOperator' }>['op']; right: DimNode }>,
): string {
  if (chain.length === 0) {
    return serializeSelfClosingLeaf(node);
  }

  const content = serializeDimOperatorChain(chain);
  switch (node.type) {
    case 'AbsoluteDim':
      return `<AbsoluteDim value="${node.value}">${content}</AbsoluteDim>`;
    case 'UnifiedDim':
      return `<UnifiedDim scale="${node.scale}" offset="${node.offset}" type="${node.dimType}">${content}</UnifiedDim>`;
    case 'ImageDim':
      return `<ImageDim imageset="${escapeXml(node.imageset)}" image="${escapeXml(node.image)}" dimension="${node.dimType}">${content}</ImageDim>`;
    case 'WidgetDim': {
      const widgetAttr = node.widget ? ` widget="${escapeXml(node.widget)}"` : '';
      return `<WidgetDim${widgetAttr} dimension="${node.dimType}">${content}</WidgetDim>`;
    }
    case 'FontDim': {
      const fontAttr = node.font ? ` font="${escapeXml(node.font)}"` : '';
      const padAttr = node.padding !== undefined ? ` padding="${node.padding}"` : '';
      return `<FontDim${fontAttr} metric="${node.metric}"${padAttr}>${content}</FontDim>`;
    }
    case 'PropertyDim':
      return `<PropertyDim name="${escapeXml(node.name)}">${content}</PropertyDim>`;
  }
}

function serializeDimOperatorChain(
  chain: Array<{ op: Extract<DimNode, { type: 'DimOperator' }>['op']; right: DimNode }>,
): string {
  const [head, ...rest] = chain;
  if (!head) {
    return '';
  }

  const rightXml = serializeDimInline(head.right);
  return `<DimOperator op="${head.op}">${rightXml}${serializeDimOperatorChain(rest)}</DimOperator>`;
}

function serializeSelfClosingLeaf(node: Exclude<DimNode, { type: 'DimOperator' }>): string {
  switch (node.type) {
    case 'AbsoluteDim':
      return `<AbsoluteDim value="${node.value}" />`;
    case 'UnifiedDim':
      return `<UnifiedDim scale="${node.scale}" offset="${node.offset}" type="${node.dimType}" />`;
    case 'ImageDim':
      return `<ImageDim imageset="${escapeXml(node.imageset)}" image="${escapeXml(node.image)}" dimension="${node.dimType}" />`;
    case 'WidgetDim': {
      const widgetAttr = node.widget ? ` widget="${escapeXml(node.widget)}"` : '';
      return `<WidgetDim${widgetAttr} dimension="${node.dimType}" />`;
    }
    case 'FontDim': {
      const fontAttr = node.font ? ` font="${escapeXml(node.font)}"` : '';
      const padAttr = node.padding !== undefined ? ` padding="${node.padding}"` : '';
      return `<FontDim${fontAttr} metric="${node.metric}"${padAttr} />`;
    }
    case 'PropertyDim':
      return `<PropertyDim name="${escapeXml(node.name)}" />`;
  }
}

export function escapeXml(value: string): string {
  return value
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&apos;');
}
