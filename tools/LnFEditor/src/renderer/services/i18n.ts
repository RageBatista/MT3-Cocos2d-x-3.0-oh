/**
 * i18n — 国际化支持
 *
 * 简单的 i18n 系统，支持：
 * - 多语言切换（中文/英文）
 * - 嵌套键路径
 * - 插值变量
 * - 运行时切换语言
 */

import React from 'react';

// ─── 类型定义 ────────────────────────────────────────────────────

export type Locale = 'zh-CN' | 'en-US';

export interface TranslationMessages {
  [key: string]: string | TranslationMessages;
}

// ─── 语言包 ──────────────────────────────────────────────────────

const zhCN: TranslationMessages = {
  app: {
    title: 'CEGUI LookNFeel 编辑器',
    loading: '加载中...',
  },
  toolbar: {
    open: '📂 打开',
    save: '💾 保存',
    openTitle: '打开 LookNFeel 文件 (Ctrl+O)',
    saveTitle: '保存 (Ctrl+S)',
    undoTitle: '撤销 (Ctrl+Z)',
    redoTitle: '重做 (Ctrl+Y)',
    zoomOutTitle: '缩小 (Ctrl+-)',
    zoomInTitle: '放大 (Ctrl++)',
    resetZoomTitle: '重置缩放 (Ctrl+0)',
  },
  menu: {
    file: '文件',
    edit: '编辑',
    view: '视图',
    help: '帮助',
    open: '打开',
    save: '保存',
    saveAs: '另存为',
    exportPng: '导出 PNG',
    exit: '退出',
    undo: '撤销',
    redo: '重做',
    copy: '复制',
    paste: '粘贴',
    delete: '删除',
    selectAll: '全选',
    find: '查找',
    replace: '替换',
    resetView: '重置视图',
    zoomIn: '放大',
    zoomOut: '缩小',
  },
  panel: {
    navigator: '导航器',
    properties: '属性',
    layers: '图层',
    preview: '预览',
    images: '图像资源',
    widgetLooks: 'WidgetLook 列表',
    searchWidgetLook: '搜索 WidgetLook...',
    noFileOpened: '未打开文件',
    layerTree: '图层树',
    selectWidgetLook: '请选择一个 WidgetLook',
    previewSettings: '预览设置',
    parentSize: '父容器尺寸',
    buttonStates: '按钮状态',
    windowStates: '窗口状态',
  },
  canvas: {
    noFile: '未打开文件',
    noSelection: '未选中元素',
    loadingTextures: '加载纹理中...',
    dragMove: '移动',
    dragResize: '调整大小',
  },
  property: {
    name: '名称',
    value: '值',
    type: '类型',
    area: '区域',
    position: '位置',
    size: '尺寸',
    left: '左',
    top: '上',
    right: '右',
    bottom: '下',
    width: '宽',
    height: '高',
    font: '字体',
    text: '文本',
    image: '图像',
    imageset: '图像集',
    colour: '颜色',
    format: '格式',
    widgetLook: 'WidgetLook',
    propertyDefinitions: '属性定义',
    properties: '属性',
    imagerySections: '图像段落',
    stateImagery: '状态图像',
    layers: '层',
    frame: '帧',
    imagery: '图像',
    textComp: '文本',
    colourRect: '颜色矩形',
    colours: '颜色',
    topLeft: '左上',
    topRight: '右上',
    bottomLeft: '左下',
    bottomRight: '右下',
    imageRef: '图像引用',
    vertFormatting: '垂直格式',
    horzFormatting: '水平格式',
    fontProp: '字体',
    textProp: '文本',
  },
  dim: {
    absolute: '绝对值',
    unified: '统一维度',
    imageDim: '图像维度',
    widgetDim: '控件维度',
    fontDim: '字体维度',
    propertyDim: '属性维度',
    operator: '运算符',
    scale: '比例',
    offset: '偏移',
    value: '值',
    dimType: '维度类型',
    imageset: '图像集',
    image: '图像',
    widget: '控件',
    metric: '度量',
    padding: '内边距',
    propertyName: '属性名称',
    operatorLabel: '运算符',
    left: '左',
    right: '右',
    position: '位置',
    horizontalSize: '水平尺寸',
    verticalSize: '垂直尺寸',
    noHorizontalSize: '未定义水平尺寸',
    noVerticalSize: '未定义垂直尺寸',
    switchTo: '切换为 {type}',
    computedPx: '≈ {value}px (父容器: {parent}px)',
    selfEmpty: '自身（留空 = 自身）',
    placeholderImageset: '图像集名称',
    placeholderImage: '子图像名称',
    placeholderProperty: '属性名称',
    placeholderFont: '默认',
  },
  template: {
    button: '按钮',
    static: '静态图像',
    label: '文本标签',
    slider: '滑块',
    titlewindow: '标题窗口',
    scrollbar: '滚动条',
    createFromTemplate: '从模板创建',
    selectTemplate: '选择模板',
  },
  search: {
    title: '搜索替换',
    query: '搜索内容',
    replacement: '替换内容',
    caseSensitive: '区分大小写',
    regex: '正则表达式',
    results: '{count} 个结果',
    replaceAll: '全部替换',
    target: {
      all: '全部',
      property: '属性',
      imageset: '图像集',
      image: '图像',
      section: '段落',
      state: '状态',
    },
  },
  contextMenu: {
    undo: '撤销',
    redo: '重做',
    copy: '复制组件',
    paste: '粘贴组件',
    delete: '删除组件',
    selectAll: '全选',
    resetView: '重置视图',
    exportPng: '导出为 PNG',
    addWidgetLook: '添加 WidgetLook',
    rename: '重命名',
    duplicate: '复制',
  },
  status: {
    ready: '就绪',
    modified: '已修改',
    saved: '已保存',
    noFile: '未打开文件',
    noSelection: '未选中',
    undoCount: '撤销: {count}',
    redoCount: '重做: {count}',
    zoom: '缩放: {percent}%',
    textures: '纹理: {cached}/{max}',
  },
  imageBrowser: {
    title: '图像资源',
    stats: '{total} 张图像，{sets} 个图像集',
    searchPlaceholder: '搜索图像...',
    gridView: '网格视图',
    listView: '列表视图',
    all: '全部',
    noImagesets: '未加载图像集',
    noMatch: '无匹配图像',
  },
  virtualList: {
    search: '搜索...',
    noItems: '无项目',
    itemCount: '{count} 项',
    filteredCount: '{filtered} / {total}',
  },
  error: {
    fileOpen: '无法打开文件',
    fileSave: '无法保存文件',
    parse: '解析错误',
    invalidFormat: '无效的文件格式',
    textureLoad: '纹理加载失败',
  },
};

const enUS: TranslationMessages = {
  app: {
    title: 'CEGUI LookNFeel Editor',
    loading: 'Loading...',
  },
  toolbar: {
    open: '📂 Open',
    save: '💾 Save',
    openTitle: 'Open LookNFeel File (Ctrl+O)',
    saveTitle: 'Save (Ctrl+S)',
    undoTitle: 'Undo (Ctrl+Z)',
    redoTitle: 'Redo (Ctrl+Y)',
    zoomOutTitle: 'Zoom Out (Ctrl+-)',
    zoomInTitle: 'Zoom In (Ctrl++)',
    resetZoomTitle: 'Reset Zoom (Ctrl+0)',
  },
  menu: {
    file: 'File',
    edit: 'Edit',
    view: 'View',
    help: 'Help',
    open: 'Open',
    save: 'Save',
    saveAs: 'Save As',
    exportPng: 'Export PNG',
    exit: 'Exit',
    undo: 'Undo',
    redo: 'Redo',
    copy: 'Copy',
    paste: 'Paste',
    delete: 'Delete',
    selectAll: 'Select All',
    find: 'Find',
    replace: 'Replace',
    resetView: 'Reset View',
    zoomIn: 'Zoom In',
    zoomOut: 'Zoom Out',
  },
  panel: {
    navigator: 'Navigator',
    properties: 'Properties',
    layers: 'Layers',
    preview: 'Preview',
    images: 'Images',
    widgetLooks: 'WidgetLooks',
    searchWidgetLook: 'Search WidgetLook...',
    noFileOpened: 'No file opened',
    layerTree: 'Layer Tree',
    selectWidgetLook: 'Select a WidgetLook',
    previewSettings: 'Preview Settings',
    parentSize: 'Parent Size',
    buttonStates: 'Button States',
    windowStates: 'Window States',
  },
  canvas: {
    noFile: 'No file opened',
    noSelection: 'No selection',
    loadingTextures: 'Loading textures...',
    dragMove: 'Move',
    dragResize: 'Resize',
  },
  property: {
    name: 'Name',
    value: 'Value',
    type: 'Type',
    area: 'Area',
    position: 'Position',
    size: 'Size',
    left: 'Left',
    top: 'Top',
    right: 'Right',
    bottom: 'Bottom',
    width: 'Width',
    height: 'Height',
    font: 'Font',
    text: 'Text',
    image: 'Image',
    imageset: 'Imageset',
    colour: 'Colour',
    format: 'Format',
    widgetLook: 'WidgetLook',
    propertyDefinitions: 'Property Definitions',
    properties: 'Properties',
    imagerySections: 'Imagery Sections',
    stateImagery: 'State Imagery',
    layers: 'layer(s)',
    frame: 'Frame',
    imagery: 'Imagery',
    textComp: 'Text',
    colourRect: 'Colour Rect',
    colours: 'Colours',
    topLeft: 'Top Left',
    topRight: 'Top Right',
    bottomLeft: 'Bottom Left',
    bottomRight: 'Bottom Right',
    imageRef: 'Image Ref',
    vertFormatting: 'Vert Formatting',
    horzFormatting: 'Horz Formatting',
    fontProp: 'Font',
    textProp: 'Text',
  },
  dim: {
    absolute: 'Absolute',
    unified: 'Unified',
    imageDim: 'Image Dim',
    widgetDim: 'Widget Dim',
    fontDim: 'Font Dim',
    propertyDim: 'Property Dim',
    operator: 'Operator',
    scale: 'Scale',
    offset: 'Offset',
    value: 'Value',
    dimType: 'Dim Type',
    imageset: 'Imageset',
    image: 'Image',
    widget: 'Widget',
    metric: 'Metric',
    padding: 'Padding',
    propertyName: 'Property Name',
    operatorLabel: 'Operator',
    left: 'Left',
    right: 'Right',
    position: 'Position',
    horizontalSize: 'Horizontal Size',
    verticalSize: 'Vertical Size',
    noHorizontalSize: 'No horizontal size defined',
    noVerticalSize: 'No vertical size defined',
    switchTo: 'Switch to {type}',
    computedPx: '≈ {value}px (parent: {parent}px)',
    selfEmpty: 'self (empty = self)',
    placeholderImageset: 'imageset name',
    placeholderImage: 'sub-image name',
    placeholderProperty: 'property name',
    placeholderFont: 'default',
  },
  template: {
    button: 'Button',
    static: 'Static Image',
    label: 'Label',
    slider: 'Slider',
    titlewindow: 'Title Window',
    scrollbar: 'Scrollbar',
    createFromTemplate: 'Create from Template',
    selectTemplate: 'Select Template',
  },
  search: {
    title: 'Search & Replace',
    query: 'Search',
    replacement: 'Replacement',
    caseSensitive: 'Case Sensitive',
    regex: 'Regex',
    results: '{count} results',
    replaceAll: 'Replace All',
    target: {
      all: 'All',
      property: 'Property',
      imageset: 'Imageset',
      image: 'Image',
      section: 'Section',
      state: 'State',
    },
  },
  contextMenu: {
    undo: 'Undo',
    redo: 'Redo',
    copy: 'Copy Component',
    paste: 'Paste Component',
    delete: 'Delete Component',
    selectAll: 'Select All',
    resetView: 'Reset View',
    exportPng: 'Export as PNG',
    addWidgetLook: 'Add WidgetLook',
    rename: 'Rename',
    duplicate: 'Duplicate',
  },
  status: {
    ready: 'Ready',
    modified: 'Modified',
    saved: 'Saved',
    noFile: 'No file',
    noSelection: 'No selection',
    undoCount: 'Undo: {count}',
    redoCount: 'Redo: {count}',
    zoom: 'Zoom: {percent}%',
    textures: 'Textures: {cached}/{max}',
  },
  imageBrowser: {
    title: 'Images',
    stats: '{total} images in {sets} sets',
    searchPlaceholder: 'Search images...',
    gridView: 'Grid view',
    listView: 'List view',
    all: 'All',
    noImagesets: 'No imagesets loaded',
    noMatch: 'No images match filter',
  },
  virtualList: {
    search: 'Search...',
    noItems: 'No items',
    itemCount: '{count} items',
    filteredCount: '{filtered} / {total}',
  },
  error: {
    fileOpen: 'Cannot open file',
    fileSave: 'Cannot save file',
    parse: 'Parse error',
    invalidFormat: 'Invalid file format',
    textureLoad: 'Texture load failed',
  },
};

// ─── 语言包注册表 ────────────────────────────────────────────────

const MESSAGE_MAPS: Record<Locale, TranslationMessages> = {
  'zh-CN': zhCN,
  'en-US': enUS,
};

// ─── i18n 管理器 ─────────────────────────────────────────────────

class I18nManager {
  private currentLocale: Locale = 'zh-CN';
  private listeners: Set<() => void> = new Set();

  /** 获取当前语言 */
  getLocale(): Locale {
    return this.currentLocale;
  }

  /** 设置当前语言 */
  setLocale(locale: Locale): void {
    if (this.currentLocale === locale) return;
    this.currentLocale = locale;
    for (const listener of this.listeners) {
      listener();
    }
  }

  /** 翻译键路径 */
  t(key: string, vars?: Record<string, string | number>): string {
    const messages = MESSAGE_MAPS[this.currentLocale];
    const value = resolveKeyPath(messages, key);

    if (value === undefined) {
      // 回退到英文
      const fallback = resolveKeyPath(MESSAGE_MAPS['en-US'], key);
      if (fallback === undefined) return key;
      return interpolate(fallback, vars);
    }

    return interpolate(value, vars);
  }

  /** 监听语言变化 */
  onChange(listener: () => void): () => void {
    this.listeners.add(listener);
    return () => { this.listeners.delete(listener); };
  }

  /** 获取所有可用语言 */
  getAvailableLocales(): Locale[] {
    return Object.keys(MESSAGE_MAPS) as Locale[];
  }
}

// ─── 辅助函数 ────────────────────────────────────────────────────

function resolveKeyPath(obj: TranslationMessages, path: string): string | undefined {
  const parts = path.split('.');
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  let current: any = obj;

  for (const part of parts) {
    if (current === undefined || current === null) return undefined;
    current = current[part];
  }

  return typeof current === 'string' ? current : undefined;
}

function interpolate(template: string, vars?: Record<string, string | number>): string {
  if (!vars) return template;

  let result = template;
  for (const [key, val] of Object.entries(vars)) {
    result = result.replace(new RegExp(`\\{${key}\\}`, 'g'), String(val));
  }
  return result;
}

// ─── 导出 ────────────────────────────────────────────────────────

/** 全局 i18n 实例 */
export const i18n = new I18nManager();

/** React Hook: 翻译函数，语言切换时自动触发重渲染 */
export function useTranslation(): {
  t: (key: string, vars?: Record<string, string | number>) => string;
  locale: Locale;
  setLocale: (locale: Locale) => void;
} {
  const [, forceUpdate] = React.useState(0);

  React.useEffect(() => {
    const unsubscribe = i18n.onChange(() => forceUpdate(c => c + 1));
    return unsubscribe;
  }, []);

  return {
    t: (key, vars) => i18n.t(key, vars),
    locale: i18n.getLocale(),
    setLocale: (locale) => i18n.setLocale(locale),
  };
}
