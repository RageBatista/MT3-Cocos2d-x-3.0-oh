/**
 * search-replace — 搜索替换服务
 *
 * 在 WidgetLook 集合中搜索文本内容，支持：
 * - 属性名/值搜索
 * - 图像引用搜索（imageset/image）
 * - Section 名称搜索
 * - State 名称搜索
 * - 正则表达式模式
 * - 批量替换
 */

import type {
  WidgetLook,
  ImagerySection,
  FrameComponent,
  ImageryComponent,
  TextComponent,
  StateImagery,
  PropertyDefinition,
  Property,
  ImageRef,
  DimNode,
} from '@shared/model';

// ─── 搜索类型 ────────────────────────────────────────────────────

export type SearchTarget =
  | 'all'           // 搜索所有文本
  | 'property'      // 属性名/值
  | 'imageset'      // imageset 名称
  | 'image'         // image 名称
  | 'section'       // ImagerySection 名称
  | 'state'         // StateImagery 名称
  | 'dim'           // Dim 表达式中的文本
  ;

export interface SearchOptions {
  /** 搜索目标类型 */
  target: SearchTarget;
  /** 是否区分大小写 */
  caseSensitive: boolean;
  /** 是否使用正则表达式 */
  regex: boolean;
  /** 最大结果数 */
  maxResults: number;
}

export interface SearchResult {
  /** WidgetLook 名称 */
  widgetLookName: string;
  /** 结果路径（如 "imagerySections[0].frameComponents[1].images.TopEdge.imageset"） */
  path: string;
  /** 匹配的文本 */
  matchedText: string;
  /** 匹配在文本中的起始位置 */
  matchStart: number;
  /** 匹配在文本中的结束位置 */
  matchEnd: number;
  /** 上下文描述 */
  context: string;
}

export interface ReplaceResult {
  /** 替换的 WidgetLook */
  widgetLookName: string;
  /** 替换路径 */
  path: string;
  /** 旧值 */
  oldValue: string;
  /** 新值 */
  newValue: string;
}

// ─── 搜索引擎 ────────────────────────────────────────────────────

/**
 * 在 WidgetLook 集合中搜索
 */
export function searchInWidgetLooks(
  widgetLooks: WidgetLook[],
  query: string,
  options: SearchOptions,
): SearchResult[] {
  if (!query) return [];

  const results: SearchResult[] = [];
  const pattern = buildPattern(query, options);

  for (const wl of widgetLooks) {
    if (results.length >= options.maxResults) break;

    searchInWidgetLook(wl, pattern, options, results);
  }

  return results;
}

/**
 * 执行批量替换
 */
export function executeReplace(
  widgetLooks: WidgetLook[],
  query: string,
  replacement: string,
  options: SearchOptions,
): Map<string, WidgetLook> {
  const modified = new Map<string, WidgetLook>();
  const results = searchInWidgetLooks(widgetLooks, query, { ...options, maxResults: Infinity });

  // 按 WidgetLook 分组
  const byWidgetLook = new Map<string, SearchResult[]>();
  for (const r of results) {
    let arr = byWidgetLook.get(r.widgetLookName);
    if (!arr) {
      arr = [];
      byWidgetLook.set(r.widgetLookName, arr);
    }
    arr.push(r);
  }

  // 对每个 WidgetLook 执行替换
  for (const [wlName, matches] of byWidgetLook) {
    const wl = widgetLooks.find(w => w.name === wlName);
    if (!wl) continue;

    const newWl = JSON.parse(JSON.stringify(wl)) as WidgetLook;

    for (const match of matches) {
      applyReplacement(newWl, match.path, query, replacement, options);
    }

    modified.set(wlName, newWl);
  }

  return modified;
}

// ─── 内部实现 ────────────────────────────────────────────────────

function buildPattern(query: string, options: SearchOptions): RegExp {
  const flags = options.caseSensitive ? 'g' : 'gi';
  if (options.regex) {
    return new RegExp(query, flags);
  }
  return new RegExp(escapeRegex(query), flags);
}

function escapeRegex(str: string): string {
  return str.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}

function searchInWidgetLook(
  wl: WidgetLook,
  pattern: RegExp,
  options: SearchOptions,
  results: SearchResult[],
): void {
  const target = options.target;

  // 属性定义
  if (target === 'all' || target === 'property') {
    for (let i = 0; i < wl.propertyDefinitions.length; i++) {
      const pd = wl.propertyDefinitions[i];
      addMatches(results, wl.name, `propertyDefinitions[${i}].name`, pd.name, pattern, `PropertyDefinition name`);
      addMatches(results, wl.name, `propertyDefinitions[${i}].initialValue`, pd.initialValue, pattern, `PropertyDefinition "${pd.name}" value`);
    }
  }

  // 静态属性
  if (target === 'all' || target === 'property') {
    for (let i = 0; i < wl.properties.length; i++) {
      const p = wl.properties[i];
      addMatches(results, wl.name, `properties[${i}].name`, p.name, pattern, `Property name`);
      addMatches(results, wl.name, `properties[${i}].value`, p.value, pattern, `Property "${p.name}" value`);
    }
  }

  // ImagerySections
  for (let si = 0; si < wl.imagerySections.length; si++) {
    const section = wl.imagerySections[si];

    // Section 名称
    if (target === 'all' || target === 'section') {
      addMatches(results, wl.name, `imagerySections[${si}].name`, section.name, pattern, `ImagerySection name`);
    }

    // FrameComponents
    for (let fi = 0; fi < section.frameComponents.length; fi++) {
      searchInFrameComponent(
        results, wl.name, `imagerySections[${si}].frameComponents[${fi}]`,
        section.frameComponents[fi], pattern, options,
      );
    }

    // ImageryComponents
    for (let ii = 0; ii < section.imageryComponents.length; ii++) {
      searchInImageryComponent(
        results, wl.name, `imagerySections[${si}].imageryComponents[${ii}]`,
        section.imageryComponents[ii], pattern, options,
      );
    }

    // TextComponents
    for (let ti = 0; ti < section.textComponents.length; ti++) {
      searchInTextComponent(
        results, wl.name, `imagerySections[${si}].textComponents[${ti}]`,
        section.textComponents[ti], pattern, options,
      );
    }
  }

  // StateImagerys
  if (target === 'all' || target === 'state') {
    for (let si = 0; si < wl.stateImagerys.length; si++) {
      const state = wl.stateImagerys[si];
      addMatches(results, wl.name, `stateImagerys[${si}].name`, state.name, pattern, `StateImagery name`);
    }
  }
}

function searchInFrameComponent(
  results: SearchResult[],
  wlName: string,
  basePath: string,
  fc: FrameComponent,
  pattern: RegExp,
  options: SearchOptions,
): void {
  // 图像引用
  if (options.target === 'all' || options.target === 'imageset' || options.target === 'image') {
    for (const [type, ref] of Object.entries(fc.images)) {
      if (ref) {
        if (options.target !== 'image') {
          addMatches(results, wlName, `${basePath}.images.${type}.imageset`, ref.imageset, pattern, `Frame ${type} imageset`);
        }
        if (options.target !== 'imageset') {
          addMatches(results, wlName, `${basePath}.images.${type}.image`, ref.image, pattern, `Frame ${type} image`);
        }
      }
    }
  }

  // Dim 表达式
  if (options.target === 'all' || options.target === 'dim') {
    searchInArea(results, wlName, `${basePath}.area`, fc.area, pattern);
  }
}

function searchInImageryComponent(
  results: SearchResult[],
  wlName: string,
  basePath: string,
  ic: ImageryComponent,
  pattern: RegExp,
  options: SearchOptions,
): void {
  if (ic.image) {
    if (options.target === 'all' || options.target === 'imageset') {
      addMatches(results, wlName, `${basePath}.image.imageset`, ic.image.imageset, pattern, `Imagery imageset`);
    }
    if (options.target === 'all' || options.target === 'image') {
      addMatches(results, wlName, `${basePath}.image.image`, ic.image.image, pattern, `Imagery image`);
    }
  }

  if (options.target === 'all' || options.target === 'dim') {
    searchInArea(results, wlName, `${basePath}.area`, ic.area, pattern);
  }
}

function searchInTextComponent(
  results: SearchResult[],
  wlName: string,
  basePath: string,
  tc: TextComponent,
  pattern: RegExp,
  options: SearchOptions,
): void {
  if (tc.font && (options.target === 'all' || options.target === 'property')) {
    addMatches(results, wlName, `${basePath}.font`, tc.font, pattern, `TextComponent font`);
  }
  if (tc.text && (options.target === 'all' || options.target === 'property')) {
    addMatches(results, wlName, `${basePath}.text`, tc.text, pattern, `TextComponent text`);
  }

  if (options.target === 'all' || options.target === 'dim') {
    searchInArea(results, wlName, `${basePath}.area`, tc.area, pattern);
  }
}

function searchInArea(
  results: SearchResult[],
  wlName: string,
  basePath: string,
  area: import('@shared/model').AreaDef,
  pattern: RegExp,
): void {
  searchInDim(results, wlName, `${basePath}.left`, area.left, pattern);
  searchInDim(results, wlName, `${basePath}.top`, area.top, pattern);
  if (area.right) searchInDim(results, wlName, `${basePath}.right`, area.right, pattern);
  if (area.bottom) searchInDim(results, wlName, `${basePath}.bottom`, area.bottom, pattern);
  if (area.width) searchInDim(results, wlName, `${basePath}.width`, area.width, pattern);
  if (area.height) searchInDim(results, wlName, `${basePath}.height`, area.height, pattern);
}

function searchInDim(
  results: SearchResult[],
  wlName: string,
  basePath: string,
  dim: DimNode,
  pattern: RegExp,
): void {
  switch (dim.type) {
    case 'ImageDim':
      addMatches(results, wlName, `${basePath}.imageset`, dim.imageset, pattern, `ImageDim imageset`);
      addMatches(results, wlName, `${basePath}.image`, dim.image, pattern, `ImageDim image`);
      break;
    case 'WidgetDim':
      if (dim.widget) {
        addMatches(results, wlName, `${basePath}.widget`, dim.widget, pattern, `WidgetDim widget`);
      }
      break;
    case 'FontDim':
      if (dim.font) {
        addMatches(results, wlName, `${basePath}.font`, dim.font, pattern, `FontDim font`);
      }
      break;
    case 'PropertyDim':
      addMatches(results, wlName, `${basePath}.name`, dim.name, pattern, `PropertyDim name`);
      break;
    case 'DimOperator':
      searchInDim(results, wlName, `${basePath}.left`, dim.left, pattern);
      searchInDim(results, wlName, `${basePath}.right`, dim.right, pattern);
      break;
  }
}

function addMatches(
  results: SearchResult[],
  wlName: string,
  path: string,
  text: string,
  pattern: RegExp,
  context: string,
): void {
  if (!text) return;

  // 重置正则状态
  pattern.lastIndex = 0;

  let match: RegExpExecArray | null;
  while ((match = pattern.exec(text)) !== null) {
    results.push({
      widgetLookName: wlName,
      path,
      matchedText: match[0],
      matchStart: match.index,
      matchEnd: match.index + match[0].length,
      context,
    });
  }
}

// ─── 替换实现 ────────────────────────────────────────────────────

function applyReplacement(
  wl: WidgetLook,
  path: string,
  query: string,
  replacement: string,
  options: SearchOptions,
): void {
  // 使用简单的路径解析来定位并替换
  // 路径格式: "imagerySections[0].frameComponents[0].images.TopEdge.imageset"
  const parts = path.split('.');
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  let current: any = wl;

  for (let i = 0; i < parts.length - 1; i++) {
    current = resolvePathPart(current, parts[i]);
    if (current === undefined) return;
  }

  const lastKey = parts[parts.length - 1];
  if (current && typeof current[lastKey] === 'string') {
    const pattern = buildPattern(query, options);
    current[lastKey] = current[lastKey].replace(pattern, replacement);
  }
}

function resolvePathPart(obj: unknown, part: string): unknown {
  // 数组索引: "name[0]"
  const arrayMatch = part.match(/^(\w+)\[(\d+)\]$/);
  if (arrayMatch) {
    const arr = (obj as Record<string, unknown>)[arrayMatch[1]];
    if (Array.isArray(arr)) {
      return arr[parseInt(arrayMatch[2], 10)];
    }
  }
  return (obj as Record<string, unknown>)[part];
}
