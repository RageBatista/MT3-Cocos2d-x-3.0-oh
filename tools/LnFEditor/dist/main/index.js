"use strict";
const electron = require("electron");
const fs = require("fs");
const path = require("path");
const sharp = require("sharp");
const fastXmlParser = require("fast-xml-parser");
function _interopNamespaceDefault(e) {
  const n = Object.create(null, { [Symbol.toStringTag]: { value: "Module" } });
  if (e) {
    for (const k in e) {
      if (k !== "default") {
        const d = Object.getOwnPropertyDescriptor(e, k);
        Object.defineProperty(n, k, d.get ? d : {
          enumerable: true,
          get: () => e[k]
        });
      }
    }
  }
  n.default = e;
  return Object.freeze(n);
}
const fs__namespace = /* @__PURE__ */ _interopNamespaceDefault(fs);
const path__namespace = /* @__PURE__ */ _interopNamespaceDefault(path);
const ARRAY_OPTIONS = {
  isArray: (name) => [
    "WidgetLook",
    "PropertyDefinition",
    "PropertyLinkDefinition",
    "Property",
    "NamedArea",
    "Child",
    "ImagerySection",
    "StateImagery",
    "Layer",
    "Section",
    "FrameComponent",
    "ImageryComponent",
    "TextComponent",
    "Dim",
    "Image"
  ].includes(name)
};
function buildFileIndex(filePath) {
  const content = fs__namespace.readFileSync(filePath, "utf-8");
  const lines = content.split("\n");
  const indices = [];
  let currentWL = null;
  let byteOffset = 0;
  for (let lineIdx = 0; lineIdx < lines.length; lineIdx++) {
    const line = lines[lineIdx];
    const trimmed = line.trim();
    if (trimmed.startsWith("<WidgetLook") && trimmed.includes("name=")) {
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
          namedAreaCount: 0
        };
      }
    } else if (currentWL) {
      if (trimmed.startsWith("</WidgetLook")) {
        currentWL.lineEnd = lineIdx + 1;
        currentWL.byteEnd = byteOffset + line.length;
        indices.push(currentWL);
        currentWL = null;
      } else {
        if (trimmed.startsWith("<PropertyDefinition")) currentWL.propertyDefinitionCount++;
        if (trimmed.startsWith("<ImagerySection")) currentWL.imagerySectionCount++;
        if (trimmed.startsWith("<StateImagery")) currentWL.stateImageryCount++;
        if (trimmed.startsWith("<Child")) currentWL.childCount++;
        if (trimmed.startsWith("<NamedArea")) currentWL.namedAreaCount++;
      }
    }
    byteOffset += Buffer.byteLength(line + "\n", "utf-8");
  }
  return {
    filePath,
    totalWidgetLooks: indices.length,
    widgetLookIndices: indices
  };
}
function parseWidgetLookByIndex(filePath, index) {
  const content = fs__namespace.readFileSync(filePath, "utf-8");
  const lines = content.split("\n");
  const slice = lines.slice(index.lineStart - 1, index.lineEnd).join("\n");
  const wrapper = `<?xml version="1.0" ?><Falagard>${slice}</Falagard>`;
  return parseWidgetLookXml(wrapper);
}
function parseLookNFeelFile(filePath) {
  const content = fs__namespace.readFileSync(filePath, "utf-8");
  return parseLookNFeelXml(content);
}
function parseLookNFeelXml(xmlContent) {
  const parser = new fastXmlParser.XMLParser({
    ignoreAttributes: false,
    attributeNamePrefix: "@_",
    preserveOrder: false,
    commentPropName: "#comment",
    ...ARRAY_OPTIONS
  });
  const parsed = parser.parse(xmlContent);
  const falagard = parsed.Falagard;
  if (!falagard || !falagard.WidgetLook) return [];
  const wls = Array.isArray(falagard.WidgetLook) ? falagard.WidgetLook : [falagard.WidgetLook];
  return wls.map((wl) => parseWidgetLookObj(wl));
}
function parseWidgetLookXml(wrapperXml) {
  const parser = new fastXmlParser.XMLParser({
    ignoreAttributes: false,
    attributeNamePrefix: "@_",
    preserveOrder: false,
    ...ARRAY_OPTIONS
  });
  const parsed = parser.parse(wrapperXml);
  const falagard = parsed.Falagard;
  if (!falagard || !falagard.WidgetLook) {
    throw new Error("Invalid WidgetLook XML wrapper");
  }
  const wlArr = Array.isArray(falagard.WidgetLook) ? falagard.WidgetLook : [falagard.WidgetLook];
  return parseWidgetLookObj(wlArr[0]);
}
function parseWidgetLookObj(obj) {
  return {
    name: obj["@_name"] || "",
    propertyDefinitions: parseArray(obj.PropertyDefinition).map(parsePropertyDefinition),
    propertyLinkDefinitions: parseArray(obj.PropertyLinkDefinition).map(parsePropertyLinkDefinition),
    properties: parseArray(obj.Property).map(parseProperty),
    namedAreas: parseArray(obj.NamedArea).map(parseNamedArea),
    children: parseArray(obj.Child).map(parseChildWidget),
    imagerySections: parseArray(obj.ImagerySection).map(parseImagerySection),
    stateImagerys: parseArray(obj.StateImagery).map(parseStateImagery)
  };
}
function parsePropertyDefinition(obj) {
  return {
    name: obj["@_name"] || "",
    initialValue: obj["@_initialValue"] || "",
    redrawOnWrite: obj["@_redrawOnWrite"] === "true",
    layoutOnWrite: obj["@_layoutOnWrite"] === "true",
    type: obj["@_type"],
    help: obj["@_help"]
  };
}
function parsePropertyLinkDefinition(obj) {
  return {
    name: obj["@_name"] || "",
    widget: obj["@_widget"] || "",
    targetProperty: obj["@_targetProperty"] || "",
    initialValue: obj["@_initialValue"],
    type: obj["@_type"]
  };
}
function parseProperty(obj) {
  return {
    name: obj["@_name"] || "",
    value: obj["@_value"] || ""
  };
}
function parseNamedArea(obj) {
  return {
    name: obj["@_name"] || "",
    area: parseArea(obj.Area)
  };
}
function parseChildWidget(obj) {
  return {
    type: obj["@_type"] || "",
    nameSuffix: obj["@_nameSuffix"] || "",
    autoWindow: obj["@_autoWindow"] === "true",
    area: parseArea(obj.Area),
    properties: parseArray(obj.Property).map(parseProperty)
  };
}
function parseImagerySection(obj) {
  return {
    name: obj["@_name"] || "",
    frameComponents: parseArray(obj.FrameComponent).map(parseFrameComponent),
    imageryComponents: parseArray(obj.ImageryComponent).map(parseImageryComponent),
    textComponents: parseArray(obj.TextComponent).map(parseTextComponent)
  };
}
function parseFrameComponent(obj) {
  const images = {};
  const imageProperties = {};
  const imageObjs = parseArray(obj.Image);
  for (const img of imageObjs) {
    const imgType = img["@_type"];
    if (imgType) {
      images[imgType] = {
        imageset: img["@_imageset"] || "",
        image: img["@_image"] || ""
      };
    }
  }
  for (const imgProp of parseArray(obj.ImageProperty)) {
    const imgType = imgProp["@_type"];
    const propertyName = imgProp["@_name"];
    if (imgType && propertyName) {
      imageProperties[imgType] = propertyName;
    }
  }
  return {
    area: parseArea(obj.Area),
    images,
    imageProperties: Object.keys(imageProperties).length > 0 ? imageProperties : void 0,
    vertFormat: parseVertFormat(obj.VertFormat),
    horzFormat: parseHorzFormat(obj.HorzFormat),
    colours: parseColours(obj.Colours),
    colourRectProperty: parsePropertyName(obj.ColourRectProperty)
  };
}
function parseImageryComponent(obj) {
  const result = {
    area: parseArea(obj.Area)
  };
  if (obj.Image) {
    const img = Array.isArray(obj.Image) ? obj.Image[0] : obj.Image;
    if (img["@_imageset"] && img["@_image"]) {
      result.image = { imageset: img["@_imageset"], image: img["@_image"] };
    }
  }
  if (obj.ImageProperty) {
    result.imageProperty = toRecord(obj.ImageProperty)["@_name"] || void 0;
  }
  if (obj.VertFormat) {
    result.vertFormat = parseVertFormat(obj.VertFormat);
  }
  if (obj.HorzFormat) {
    result.horzFormat = parseHorzFormat(obj.HorzFormat);
  }
  if (obj.VertFormatProperty) {
    result.vertFormatProperty = obj.VertFormatProperty["@_name"];
  }
  if (obj.HorzFormatProperty) {
    result.horzFormatProperty = obj.HorzFormatProperty["@_name"];
  }
  result.colours = parseColours(obj.Colours);
  if (obj.ColourProperty) {
    result.colourProperty = obj.ColourProperty["@_name"];
  }
  if (obj.ColourRectProperty) {
    result.colourRectProperty = obj.ColourRectProperty["@_name"];
  }
  return result;
}
function parseTextComponent(obj) {
  const result = {
    area: parseArea(obj.Area)
  };
  if (obj.Text) {
    const textEl = toRecord(obj.Text);
    result.font = textEl["@_font"];
    result.text = textEl["@_string"];
  }
  if (obj.VertFormat) result.vertFormat = parseVertFormat(obj.VertFormat);
  if (obj.HorzFormat) result.horzFormat = parseHorzFormat(obj.HorzFormat);
  if (obj.VertFormatProperty) result.vertFormatProperty = obj.VertFormatProperty["@_name"];
  if (obj.HorzFormatProperty) result.horzFormatProperty = obj.HorzFormatProperty["@_name"];
  result.colours = parseColours(obj.Colours);
  if (obj.ColourProperty) result.colourProperty = obj.ColourProperty["@_name"];
  if (obj.ColourRectProperty) result.colourRectProperty = obj.ColourRectProperty["@_name"];
  if (obj.BorderEnableProperty) result.borderEnableProperty = obj.BorderEnableProperty["@_name"];
  if (obj.BorderColourProperty) result.borderColourProperty = obj.BorderColourProperty["@_name"];
  if (obj.DefaultColourEnableProperty) result.defaultColourEnableProperty = obj.DefaultColourEnableProperty["@_name"];
  if (obj.DefaultBorderEnableProperty) result.defaultBorderEnableProperty = obj.DefaultBorderEnableProperty["@_name"];
  return result;
}
function parseStateImagery(obj) {
  return {
    name: obj["@_name"] || "",
    layers: parseArray(obj.Layer).map(parseStateLayer)
  };
}
function parseStateLayer(obj) {
  return {
    sections: parseArray(obj.Section).map(parseStateSectionRef),
    colourProperty: parsePropertyName(obj.ColourProperty),
    colourRectProperty: parsePropertyName(obj.ColourRectProperty),
    colours: parseColours(obj.Colours)
  };
}
function parseStateSectionRef(obj) {
  const result = {
    sectionName: obj["@_section"] || "",
    look: obj["@_look"]
  };
  if (obj.ColourProperty) {
    result.colourProperty = obj.ColourProperty["@_name"];
  }
  if (obj.ColourRectProperty) {
    result.colourRectProperty = obj.ColourRectProperty["@_name"];
  }
  result.colours = parseColours(obj.Colours);
  return result;
}
function parseArea(obj) {
  if (!obj) return { left: { type: "AbsoluteDim", value: 0 }, top: { type: "AbsoluteDim", value: 0 } };
  const dims = parseArray(obj.Dim);
  const dimMap = /* @__PURE__ */ new Map();
  for (const dim of dims) {
    const dimType = dim["@_type"];
    if (dimType) {
      dimMap.set(dimType, parseDimNode(dim));
    }
  }
  const area = {
    left: dimMap.get("LeftEdge") || { type: "AbsoluteDim", value: 0 },
    top: dimMap.get("TopEdge") || { type: "AbsoluteDim", value: 0 }
  };
  if (dimMap.has("RightEdge")) area.right = dimMap.get("RightEdge");
  if (dimMap.has("BottomEdge")) area.bottom = dimMap.get("BottomEdge");
  if (dimMap.has("Width")) area.width = dimMap.get("Width");
  if (dimMap.has("Height")) area.height = dimMap.get("Height");
  return area;
}
function parseDimNode(obj) {
  const direct = parseDimExpressionContainer(obj);
  return direct ?? { type: "AbsoluteDim", value: 0 };
}
function parseDimExpressionContainer(container) {
  for (const type of DIM_NODE_KEYS) {
    const rawNode = container[type];
    if (rawNode === void 0) {
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
function appendOperatorChain(left, operatorSource) {
  const operators = parseArray(operatorSource);
  let current = left;
  for (const operatorNode of operators) {
    current = {
      type: "DimOperator",
      op: operatorNode["@_op"] || "Add",
      left: current,
      right: parseDimExpressionContainer(operatorNode) || { type: "AbsoluteDim", value: 0 }
    };
  }
  return current;
}
const DIM_NODE_KEYS = [
  "AbsoluteDim",
  "UnifiedDim",
  "ImageDim",
  "WidgetDim",
  "FontDim",
  "PropertyDim"
];
function createDimNode(type, obj) {
  switch (type) {
    case "AbsoluteDim":
      return { type, value: parseFloat(obj["@_value"] || "0") };
    case "UnifiedDim":
      return {
        type,
        scale: parseFloat(obj["@_scale"] || "0"),
        offset: parseFloat(obj["@_offset"] || "0"),
        dimType: obj["@_type"] || "Width"
      };
    case "ImageDim":
      return {
        type,
        imageset: obj["@_imageset"] || "",
        image: obj["@_image"] || "",
        dimType: obj["@_dimension"] || "Width"
      };
    case "WidgetDim":
      return {
        type,
        widget: obj["@_widget"],
        dimType: obj["@_dimension"] || "Width"
      };
    case "FontDim":
      return {
        type,
        font: obj["@_font"],
        metric: obj["@_metric"] || "LineSpacing",
        padding: obj["@_padding"] ? parseFloat(obj["@_padding"]) : void 0
      };
    case "PropertyDim":
      return {
        type,
        name: obj["@_name"] || ""
      };
  }
}
function parseColours(obj) {
  if (!obj) return void 0;
  return {
    topLeft: obj["@_topLeft"] || "FFFFFFFF",
    topRight: obj["@_topRight"] || "FFFFFFFF",
    bottomLeft: obj["@_bottomLeft"] || "FFFFFFFF",
    bottomRight: obj["@_bottomRight"] || "FFFFFFFF"
  };
}
function parseVertFormat(val) {
  const type = parseTypeAttribute(val);
  return type;
}
function parseHorzFormat(val) {
  const type = parseTypeAttribute(val);
  return type;
}
function parseTypeAttribute(val) {
  return toRecord(val)["@_type"];
}
function parsePropertyName(val) {
  return toRecord(val)["@_name"];
}
function toRecord(val) {
  if (Array.isArray(val)) {
    return toRecord(val[0]);
  }
  if (!val || typeof val !== "object") {
    return {};
  }
  return val;
}
function parseArray(val) {
  if (!val) return [];
  if (Array.isArray(val)) return val;
  return [val];
}
function parseImageset(filePath) {
  const content = fs__namespace.readFileSync(filePath, "utf-8");
  const parser = new fastXmlParser.XMLParser({
    ignoreAttributes: false,
    attributeNamePrefix: "@_",
    isArray: (name) => name === "Image"
  });
  const parsed = parser.parse(content);
  const is = parsed.Imageset;
  if (!is) throw new Error(`Invalid imageset file: ${filePath}`);
  const dir = path__namespace.dirname(filePath);
  const textureFileName = is["@_Imagefile"];
  const subImages = /* @__PURE__ */ new Map();
  const images = is.Image || [];
  for (const img of images) {
    const name = img["@_Name"];
    subImages.set(name, {
      name,
      xPos: parseInt(img["@_XPos"], 10) || 0,
      yPos: parseInt(img["@_YPos"], 10) || 0,
      width: parseInt(img["@_Width"], 10) || 0,
      height: parseInt(img["@_Height"], 10) || 0
    });
  }
  return {
    name: is["@_Name"],
    textureFileName,
    textureFilePath: path__namespace.resolve(dir, textureFileName),
    nativeHorzRes: parseInt(is["@_NativeHorzRes"], 10) || 1024,
    nativeVertRes: parseInt(is["@_NativeVertRes"], 10) || 1024,
    autoScaled: is["@_AutoScaled"] === "true",
    subImages
  };
}
function parseScheme(filePath) {
  const content = fs__namespace.readFileSync(filePath, "utf-8");
  const parser = new fastXmlParser.XMLParser({
    ignoreAttributes: false,
    attributeNamePrefix: "@_",
    isArray: (name) => ["Imageset", "Font", "WindowSet", "WindowAlias"].includes(name)
  });
  const parsed = parser.parse(content);
  const scheme = parsed.GUIScheme;
  if (!scheme) throw new Error(`Invalid scheme file: ${filePath}`);
  const dir = path__namespace.dirname(filePath);
  const imagesetFiles = [];
  if (scheme.Imageset) {
    for (const is of scheme.Imageset) {
      const filename = is["@_Filename"];
      if (filename) imagesetFiles.push(path__namespace.resolve(dir, filename));
    }
  }
  const fontFiles = [];
  if (scheme.Font) {
    for (const f of scheme.Font) {
      const filename = f["@_Filename"];
      if (filename) fontFiles.push(path__namespace.resolve(dir, filename));
    }
  }
  let lookNFeelFile = "";
  if (scheme.LookNFeel) {
    const lnf = Array.isArray(scheme.LookNFeel) ? scheme.LookNFeel[0] : scheme.LookNFeel;
    const filename = lnf["@_Filename"];
    if (filename) lookNFeelFile = path__namespace.resolve(dir, filename);
  }
  return {
    name: scheme["@_Name"],
    imagesetFiles,
    fontFiles,
    lookNFeelFile,
    windowSetFiles: []
  };
}
function loadImagesetsFromScheme(scheme) {
  const result = /* @__PURE__ */ new Map();
  for (const isPath of scheme.imagesetFiles) {
    try {
      const is = parseImageset(isPath);
      result.set(is.name, is);
    } catch (e) {
      console.warn(`Failed to load imageset: ${isPath}`, e);
    }
  }
  return result;
}
function scanImagesetDir(dirPath) {
  if (!fs__namespace.existsSync(dirPath)) return [];
  return fs__namespace.readdirSync(dirPath).filter((f) => f.endsWith(".imageset")).map((f) => path__namespace.resolve(dirPath, f));
}
const DEFAULT_SERIALIZATION_OPTIONS = {
  preserveIndent: true,
  preserveComments: true,
  preserveAttributeOrder: true,
  preserveBlankLines: true,
  encoding: "utf-8",
  indentString: "    "
};
function serializeWidgetLook(wl, options = DEFAULT_SERIALIZATION_OPTIONS) {
  const indent = options.indentString;
  const lines = [];
  lines.push(`<WidgetLook name="${escapeXml(wl.name)}">`);
  for (const pd of wl.propertyDefinitions) {
    const attrs = [
      `name="${escapeXml(pd.name)}"`,
      `initialValue="${escapeXml(pd.initialValue)}"`
    ];
    if (pd.redrawOnWrite) attrs.push('redrawOnWrite="true"');
    if (pd.layoutOnWrite) attrs.push('layoutOnWrite="true"');
    if (pd.type) attrs.push(`type="${escapeXml(pd.type)}"`);
    if (pd.help) attrs.push(`help="${escapeXml(pd.help)}"`);
    lines.push(`${indent}<PropertyDefinition ${attrs.join(" ")} />`);
  }
  for (const pld of wl.propertyLinkDefinitions) {
    const attrs = [
      `name="${escapeXml(pld.name)}"`,
      `widget="${escapeXml(pld.widget)}"`,
      `targetProperty="${escapeXml(pld.targetProperty)}"`
    ];
    if (pld.initialValue !== void 0) attrs.push(`initialValue="${escapeXml(pld.initialValue)}"`);
    if (pld.type) attrs.push(`type="${escapeXml(pld.type)}"`);
    lines.push(`${indent}<PropertyLinkDefinition ${attrs.join(" ")} />`);
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
      `nameSuffix="${escapeXml(child.nameSuffix)}"`
    ];
    if (child.autoWindow !== void 0) {
      childAttrs.push(`autoWindow="${child.autoWindow ? "true" : "false"}"`);
    }
    lines.push(`${indent}<Child ${childAttrs.join(" ")}>`);
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
  return lines.join("\n");
}
function serializeArea(area, indent, options) {
  const lines = [];
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
  return lines.join("\n");
}
function serializeDimInline(node) {
  const flattened = flattenDimOperator(node);
  return serializeDimLeaf(flattened.base, flattened.chain);
}
function serializeFrameComponent(fc, indent, options) {
  const lines = [];
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
  return lines.join("\n");
}
function serializeImageryComponent(ic, indent, options) {
  const lines = [];
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
  return lines.join("\n");
}
function serializeTextComponent(tc, indent, options) {
  const lines = [];
  lines.push(`${indent}<TextComponent>`);
  lines.push(serializeArea(tc.area, indent + options.indentString, options));
  if (tc.font !== void 0 || tc.text !== void 0) {
    const attrs = [];
    if (tc.font !== void 0) attrs.push(`font="${escapeXml(tc.font)}"`);
    if (tc.text !== void 0) attrs.push(`string="${escapeXml(tc.text)}"`);
    lines.push(`${indent}${options.indentString}<Text ${attrs.join(" ")} />`);
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
  return lines.join("\n");
}
function serializeStateLayer(layer, indent, options) {
  const lines = [];
  lines.push(`${indent}<Layer>`);
  for (const sec of layer.sections) {
    const attrs = [`section="${escapeXml(sec.sectionName)}"`];
    if (sec.look) {
      attrs.push(`look="${escapeXml(sec.look)}"`);
    }
    if (sec.colourProperty) {
      lines.push(`${indent}${options.indentString}<Section ${attrs.join(" ")} >`);
      lines.push(`${indent}${options.indentString}${options.indentString}<ColourProperty name="${escapeXml(sec.colourProperty)}" />`);
      lines.push(`${indent}${options.indentString}</Section>`);
    } else if (sec.colourRectProperty) {
      lines.push(`${indent}${options.indentString}<Section ${attrs.join(" ")} >`);
      lines.push(`${indent}${options.indentString}${options.indentString}<ColourRectProperty name="${escapeXml(sec.colourRectProperty)}" />`);
      lines.push(`${indent}${options.indentString}</Section>`);
    } else if (sec.colours) {
      lines.push(`${indent}${options.indentString}<Section ${attrs.join(" ")} >`);
      lines.push(serializeColours(sec.colours, indent + options.indentString + options.indentString));
      lines.push(`${indent}${options.indentString}</Section>`);
    } else {
      lines.push(`${indent}${options.indentString}<Section ${attrs.join(" ")} />`);
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
  return lines.join("\n");
}
function serializeColours(colours, indent) {
  return `${indent}<Colours topLeft="${escapeXml(colours.topLeft)}" topRight="${escapeXml(colours.topRight)}" bottomLeft="${escapeXml(colours.bottomLeft)}" bottomRight="${escapeXml(colours.bottomRight)}" />`;
}
function serializeFalagardDocument(widgetLooks, options = DEFAULT_SERIALIZATION_OPTIONS) {
  const parts = [];
  parts.push('<?xml version="1.0" ?>');
  parts.push("<Falagard>");
  for (const wl of widgetLooks) {
    const xml = serializeWidgetLook(wl, options);
    for (const line of xml.split("\n")) {
      parts.push(`${options.indentString}${line}`);
    }
  }
  parts.push("</Falagard>");
  return parts.join("\n");
}
function flattenDimOperator(node) {
  if (node.type !== "DimOperator") {
    return {
      base: node,
      chain: []
    };
  }
  const flattenedLeft = flattenDimOperator(node.left);
  return {
    base: flattenedLeft.base,
    chain: [...flattenedLeft.chain, { op: node.op, right: node.right }]
  };
}
function serializeDimLeaf(node, chain) {
  if (chain.length === 0) {
    return serializeSelfClosingLeaf(node);
  }
  const content = serializeDimOperatorChain(chain);
  switch (node.type) {
    case "AbsoluteDim":
      return `<AbsoluteDim value="${node.value}">${content}</AbsoluteDim>`;
    case "UnifiedDim":
      return `<UnifiedDim scale="${node.scale}" offset="${node.offset}" type="${node.dimType}">${content}</UnifiedDim>`;
    case "ImageDim":
      return `<ImageDim imageset="${escapeXml(node.imageset)}" image="${escapeXml(node.image)}" dimension="${node.dimType}">${content}</ImageDim>`;
    case "WidgetDim": {
      const widgetAttr = node.widget ? ` widget="${escapeXml(node.widget)}"` : "";
      return `<WidgetDim${widgetAttr} dimension="${node.dimType}">${content}</WidgetDim>`;
    }
    case "FontDim": {
      const fontAttr = node.font ? ` font="${escapeXml(node.font)}"` : "";
      const padAttr = node.padding !== void 0 ? ` padding="${node.padding}"` : "";
      return `<FontDim${fontAttr} metric="${node.metric}"${padAttr}>${content}</FontDim>`;
    }
    case "PropertyDim":
      return `<PropertyDim name="${escapeXml(node.name)}">${content}</PropertyDim>`;
  }
}
function serializeDimOperatorChain(chain) {
  const [head, ...rest] = chain;
  if (!head) {
    return "";
  }
  const rightXml = serializeDimInline(head.right);
  return `<DimOperator op="${head.op}">${rightXml}${serializeDimOperatorChain(rest)}</DimOperator>`;
}
function serializeSelfClosingLeaf(node) {
  switch (node.type) {
    case "AbsoluteDim":
      return `<AbsoluteDim value="${node.value}" />`;
    case "UnifiedDim":
      return `<UnifiedDim scale="${node.scale}" offset="${node.offset}" type="${node.dimType}" />`;
    case "ImageDim":
      return `<ImageDim imageset="${escapeXml(node.imageset)}" image="${escapeXml(node.image)}" dimension="${node.dimType}" />`;
    case "WidgetDim": {
      const widgetAttr = node.widget ? ` widget="${escapeXml(node.widget)}"` : "";
      return `<WidgetDim${widgetAttr} dimension="${node.dimType}" />`;
    }
    case "FontDim": {
      const fontAttr = node.font ? ` font="${escapeXml(node.font)}"` : "";
      const padAttr = node.padding !== void 0 ? ` padding="${node.padding}"` : "";
      return `<FontDim${fontAttr} metric="${node.metric}"${padAttr} />`;
    }
    case "PropertyDim":
      return `<PropertyDim name="${escapeXml(node.name)}" />`;
  }
}
function escapeXml(value) {
  return value.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;").replace(/'/g, "&apos;");
}
let mainWindow = null;
const trustedRoots = /* @__PURE__ */ new Set();
const LOOKNFEEL_EXTENSIONS = /* @__PURE__ */ new Set([".looknfeel"]);
const SCHEME_EXTENSIONS = /* @__PURE__ */ new Set([".scheme"]);
const IMAGESET_EXTENSIONS = /* @__PURE__ */ new Set([".imageset"]);
const IMAGE_EXTENSIONS = /* @__PURE__ */ new Set([".png", ".jpg", ".jpeg", ".bmp", ".tga"]);
function createWindow() {
  mainWindow = new electron.BrowserWindow({
    width: 1440,
    height: 900,
    minWidth: 1024,
    minHeight: 680,
    title: "LnF Editor — CEGUI LookNFeel Visual Editor",
    webPreferences: {
      preload: path__namespace.join(__dirname, "../preload/index.js"),
      contextIsolation: true,
      nodeIntegration: false,
      sandbox: true,
      webSecurity: true
    }
  });
  if (process.env.ELECTRON_RENDERER_URL) {
    mainWindow.loadURL(process.env.ELECTRON_RENDERER_URL);
  } else {
    mainWindow.loadFile(path__namespace.join(__dirname, "../renderer/index.html"));
  }
  mainWindow.on("closed", () => {
    mainWindow = null;
  });
}
electron.app.whenReady().then(createWindow);
electron.app.on("window-all-closed", () => {
  electron.app.quit();
});
electron.app.on("activate", () => {
  if (!mainWindow) createWindow();
});
function parseJson(raw, label) {
  try {
    return JSON.parse(raw);
  } catch {
    throw new Error(`Invalid ${label} payload`);
  }
}
function addTrustedRoot(rootPath) {
  trustedRoots.add(path__namespace.resolve(rootPath));
}
function registerTrustedFile(filePath) {
  const resolved = path__namespace.resolve(filePath);
  addTrustedRoot(path__namespace.dirname(resolved));
  return resolved;
}
function isPathWithin(rootPath, targetPath) {
  const relative = path__namespace.relative(rootPath, targetPath);
  return relative === "" || !relative.startsWith("..") && !path__namespace.isAbsolute(relative);
}
function isTrustedPath(targetPath) {
  const resolved = path__namespace.resolve(targetPath);
  return Array.from(trustedRoots).some((rootPath) => isPathWithin(rootPath, resolved));
}
function assertTrustedFilePath(filePath, allowedExtensions, label) {
  const resolved = path__namespace.resolve(filePath);
  if (!isTrustedPath(resolved)) {
    throw new Error(`${label} is outside the trusted resource roots`);
  }
  if (!fs__namespace.existsSync(resolved) || !fs__namespace.statSync(resolved).isFile()) {
    throw new Error(`${label} not found`);
  }
  const extension = path__namespace.extname(resolved).toLowerCase();
  if (!allowedExtensions.has(extension)) {
    throw new Error(`Unsupported ${label} extension: ${extension}`);
  }
  return resolved;
}
function assertTrustedDirectoryPath(dirPath, label) {
  const resolved = path__namespace.resolve(dirPath);
  if (!isTrustedPath(resolved)) {
    throw new Error(`${label} is outside the trusted resource roots`);
  }
  if (!fs__namespace.existsSync(resolved) || !fs__namespace.statSync(resolved).isDirectory()) {
    throw new Error(`${label} not found`);
  }
  return resolved;
}
function parseWidgetLookIndexPayload(indexJson) {
  const index = parseJson(indexJson, "WidgetLook index");
  const requiredNumberFields = [
    "lineStart",
    "lineEnd",
    "byteStart",
    "byteEnd",
    "propertyDefinitionCount",
    "imagerySectionCount",
    "stateImageryCount",
    "childCount",
    "namedAreaCount"
  ];
  if (!index.name || typeof index.name !== "string") {
    throw new Error("Invalid WidgetLook index name");
  }
  for (const field of requiredNumberFields) {
    if (typeof index[field] !== "number" || Number.isNaN(index[field])) {
      throw new Error(`Invalid WidgetLook index field: ${field}`);
    }
  }
  return index;
}
function registerSchemeDependencies(schemePath, imagesets) {
  const safeSchemePath = registerTrustedFile(schemePath);
  const scheme = parseScheme(safeSchemePath);
  if (scheme.lookNFeelFile) {
    registerTrustedFile(scheme.lookNFeelFile);
  }
  for (const imagesetFile of scheme.imagesetFiles) {
    registerTrustedFile(imagesetFile);
  }
  if (imagesets) {
    for (const imageset of imagesets.values()) {
      registerTrustedFile(imageset.textureFilePath);
    }
  }
}
function serializeImagesets(imagesets) {
  const result = {};
  for (const [name, imageset] of imagesets) {
    registerTrustedFile(imageset.textureFilePath);
    result[name] = {
      name: imageset.name,
      textureFileName: imageset.textureFileName,
      textureFilePath: imageset.textureFilePath,
      nativeHorzRes: imageset.nativeHorzRes,
      nativeVertRes: imageset.nativeVertRes,
      autoScaled: imageset.autoScaled,
      subImages: Object.fromEntries(imageset.subImages)
    };
  }
  return result;
}
electron.ipcMain.handle("open-looknfeel", async () => {
  const result = await electron.dialog.showOpenDialog(mainWindow, {
    title: "Open LookNFeel File",
    filters: [{ name: "LookNFeel", extensions: ["looknfeel"] }],
    properties: ["openFile"]
  });
  if (result.canceled || result.filePaths.length === 0) return null;
  const filePath = registerTrustedFile(result.filePaths[0]);
  return {
    filePath,
    fileIndex: buildFileIndex(filePath),
    widgetLooks: parseLookNFeelFile(filePath)
  };
});
electron.ipcMain.handle("load-widgetlook", async (_event, filePath, indexJson) => {
  const safeFilePath = assertTrustedFilePath(filePath, LOOKNFEEL_EXTENSIONS, "LookNFeel file");
  const index = parseWidgetLookIndexPayload(indexJson);
  return parseWidgetLookByIndex(safeFilePath, index);
});
electron.ipcMain.handle("open-scheme", async () => {
  const result = await electron.dialog.showOpenDialog(mainWindow, {
    title: "Open Scheme File",
    filters: [{ name: "Scheme", extensions: ["scheme"] }],
    properties: ["openFile"]
  });
  if (result.canceled || result.filePaths.length === 0) return null;
  const schemePath = registerTrustedFile(result.filePaths[0]);
  const scheme = parseScheme(schemePath);
  const imagesets = loadImagesetsFromScheme(scheme);
  registerSchemeDependencies(schemePath, imagesets);
  return {
    scheme: {
      name: scheme.name,
      imagesetFiles: scheme.imagesetFiles,
      lookNFeelFile: scheme.lookNFeelFile
    },
    imagesets: serializeImagesets(imagesets)
  };
});
electron.ipcMain.handle("read-image-base64", async (_event, filePath) => {
  const safeFilePath = assertTrustedFilePath(filePath, IMAGE_EXTENSIONS, "image file");
  const ext = path__namespace.extname(safeFilePath).toLowerCase();
  if (ext === ".tga" || ext === ".bmp") {
    try {
      const pngBuf = await sharp(safeFilePath).png().toBuffer();
      return `data:image/png;base64,${pngBuf.toString("base64")}`;
    } catch (error) {
      console.warn(`Failed to convert ${safeFilePath} via sharp:`, error);
      return null;
    }
  }
  const buf = fs__namespace.readFileSync(safeFilePath);
  const mime = ext === ".jpg" || ext === ".jpeg" ? "image/jpeg" : "image/png";
  return `data:${mime};base64,${buf.toString("base64")}`;
});
electron.ipcMain.handle("load-imagesets", async (_event, filePathsJson) => {
  const filePaths = parseJson(filePathsJson, "imageset file list");
  const result = {};
  for (const filePath of filePaths) {
    try {
      const safePath = assertTrustedFilePath(filePath, IMAGESET_EXTENSIONS, "imageset file");
      const imageset = parseImageset(safePath);
      registerTrustedFile(safePath);
      registerTrustedFile(imageset.textureFilePath);
      result[imageset.name] = {
        name: imageset.name,
        textureFileName: imageset.textureFileName,
        textureFilePath: imageset.textureFilePath,
        nativeHorzRes: imageset.nativeHorzRes,
        nativeVertRes: imageset.nativeVertRes,
        autoScaled: imageset.autoScaled,
        subImages: Object.fromEntries(imageset.subImages)
      };
    } catch (error) {
      console.warn(`Failed to load imageset: ${filePath}`, error);
    }
  }
  return result;
});
electron.ipcMain.handle("discover-resources", async (_event, looknfeelPath) => {
  const safeLooknfeelPath = assertTrustedFilePath(looknfeelPath, LOOKNFEEL_EXTENSIONS, "LookNFeel file");
  const dir = path__namespace.dirname(safeLooknfeelPath);
  const schemeFiles = fs__namespace.readdirSync(dir).filter((file) => file.endsWith(".scheme")).map((file) => path__namespace.resolve(dir, file));
  if (schemeFiles.length === 0) {
    return { imagesets: {} };
  }
  const schemePath = registerTrustedFile(schemeFiles[0]);
  const scheme = parseScheme(schemePath);
  const imagesets = loadImagesetsFromScheme(scheme);
  registerSchemeDependencies(schemePath, imagesets);
  return {
    schemePath,
    scheme: {
      name: scheme.name,
      imagesetFiles: scheme.imagesetFiles,
      lookNFeelFile: scheme.lookNFeelFile
    },
    imagesets: serializeImagesets(imagesets)
  };
});
electron.ipcMain.handle("save-looknfeel", async (_event, filePath, widgetLooksJson) => {
  try {
    const safeFilePath = assertTrustedFilePath(filePath, LOOKNFEEL_EXTENSIONS, "LookNFeel file");
    const widgetLooks = parseJson(widgetLooksJson, "WidgetLook list");
    const xml = serializeFalagardDocument(widgetLooks);
    if (fs__namespace.existsSync(safeFilePath)) {
      createBackup(safeFilePath);
    }
    fs__namespace.writeFileSync(safeFilePath, xml, "utf-8");
    return { success: true };
  } catch (error) {
    return { success: false, error: error.message };
  }
});
electron.ipcMain.handle("scan-imagesets", async (_event, dirPath) => {
  const safeDirPath = assertTrustedDirectoryPath(dirPath, "imageset directory");
  return scanImagesetDir(safeDirPath);
});
electron.ipcMain.handle("sync-scheme-mappings", async (_event, schemePath, widgetLookNamesJson) => {
  try {
    const safeSchemePath = assertTrustedFilePath(schemePath, SCHEME_EXTENSIONS, "Scheme file");
    const widgetLookNames = parseJson(widgetLookNamesJson, "WidgetLook names");
    const content = fs__namespace.readFileSync(safeSchemePath, "utf-8");
    const existingMappings = /* @__PURE__ */ new Set();
    const mappingRegex = /<FalagardMapping[^>]*LookNFeel="([^"]*)"[^>]*\/>/g;
    let match;
    while ((match = mappingRegex.exec(content)) !== null) {
      existingMappings.add(match[1]);
    }
    const newMappings = widgetLookNames.filter((name) => !existingMappings.has(name));
    if (newMappings.length === 0) {
      return { success: true, added: 0, message: "No new mappings needed" };
    }
    const insertPoint = content.lastIndexOf("</GUIScheme>");
    if (insertPoint === -1) {
      return { success: false, error: "Invalid scheme file: no </GUIScheme> closing tag" };
    }
    const newEntries = newMappings.map((name) => {
      let targetType = "CEGUI/DefaultWindow";
      let renderer = "Falagard/Default";
      if (name.includes("Button") || name.includes("button") || name.includes("lananniu")) {
        targetType = "CEGUI/PushButton";
        renderer = "Falagard/Button";
      } else if (name.includes("FrameWindow") || name.includes("framewnd")) {
        targetType = "CEGUI/FrameWindow";
        renderer = "Falagard/FrameWindow";
      } else if (name.includes("ProgressBar") || name.includes("progress")) {
        targetType = "CEGUI/ProgressBar";
        renderer = "Falagard/ProgressBar";
      } else if (name.includes("ItemCell") || name.includes("itemcell")) {
        targetType = "CEGUI/ItemCell";
        renderer = "Falagard/ItemCell";
      } else if (name.includes("Checkbox") || name.includes("GroupButton")) {
        targetType = "CEGUI/GroupButton";
        renderer = "Falagard/ToggleButton";
      } else if (name.includes("Scrollbar") || name.includes("scrollbar")) {
        targetType = "CEGUI/Scrollbar";
        renderer = "Falagard/Scrollbar";
      } else if (name.includes("SkillBox")) {
        targetType = "CEGUI/SkillBox";
        renderer = "Falagard/SkillBox";
      }
      return `    <FalagardMapping WindowType="${name}" TargetType="${targetType}" Renderer="${renderer}" LookNFeel="${name}" />`;
    }).join("\n");
    const newContent = content.slice(0, insertPoint) + newEntries + "\n" + content.slice(insertPoint);
    createBackup(safeSchemePath);
    fs__namespace.writeFileSync(safeSchemePath, newContent, "utf-8");
    return { success: true, added: newMappings.length, names: newMappings };
  } catch (error) {
    return { success: false, error: error.message };
  }
});
electron.ipcMain.handle("validate-references", async (_event, widgetLooksJson, imagesetsJson) => {
  try {
    const widgetLooks = parseJson(widgetLooksJson, "WidgetLook list");
    const imagesetsData = parseJson(imagesetsJson, "imageset data");
    const errors = [];
    for (const widgetLook of widgetLooks) {
      for (const section of widgetLook.imagerySections || []) {
        for (const frame of section.frameComponents || []) {
          for (const ref of Object.values(frame.images || {})) {
            if (!ref) continue;
            const imageset = imagesetsData[ref.imageset];
            if (!imageset) {
              errors.push({ level: "error", message: `Missing imageset "${ref.imageset}" in WidgetLook "${widgetLook.name}"` });
            } else if (!imageset.subImages[ref.image]) {
              errors.push({ level: "warning", message: `Missing sub-image "${ref.image}" in "${ref.imageset}" (WL: "${widgetLook.name}")` });
            }
          }
        }
        for (const imagery of section.imageryComponents || []) {
          if (!imagery.image) continue;
          const imageset = imagesetsData[imagery.image.imageset];
          if (!imageset) {
            errors.push({ level: "error", message: `Missing imageset "${imagery.image.imageset}" in WidgetLook "${widgetLook.name}"` });
          } else if (!imageset.subImages[imagery.image.image]) {
            errors.push({ level: "warning", message: `Missing sub-image "${imagery.image.image}" in "${imagery.image.imageset}" (WL: "${widgetLook.name}")` });
          }
        }
      }
    }
    return {
      valid: errors.filter((error) => error.level === "error").length === 0,
      errors
    };
  } catch (error) {
    return {
      valid: false,
      errors: [{ level: "error", message: error.message }]
    };
  }
});
electron.ipcMain.handle("save-png", async (_event, dataUrlJson, defaultName) => {
  try {
    const { canceled, filePath } = await electron.dialog.showSaveDialog({
      title: "Export PNG",
      defaultPath: defaultName,
      filters: [{ name: "PNG Image", extensions: ["png"] }]
    });
    if (canceled || !filePath) return { success: false };
    const dataUrl = parseJson(dataUrlJson, "PNG data URL");
    const base64Data = dataUrl.replace(/^data:image\/png;base64,/, "");
    const buffer = Buffer.from(base64Data, "base64");
    fs__namespace.writeFileSync(filePath, buffer);
    return { success: true, filePath };
  } catch (error) {
    return { success: false, error: error.message };
  }
});
electron.ipcMain.handle("get-app-version", async () => electron.app.getVersion());
electron.ipcMain.handle("get-locale", async () => electron.app.getLocale());
function createBackup(filePath) {
  if (!fs__namespace.existsSync(filePath)) return;
  for (let i = 3; i >= 1; i--) {
    const older = `${filePath}.bak.${i}`;
    const newer = i === 1 ? `${filePath}.bak` : `${filePath}.bak.${i - 1}`;
    if (fs__namespace.existsSync(newer)) {
      if (fs__namespace.existsSync(older)) fs__namespace.unlinkSync(older);
      fs__namespace.copyFileSync(newer, older);
    }
  }
  fs__namespace.copyFileSync(filePath, `${filePath}.bak`);
}
