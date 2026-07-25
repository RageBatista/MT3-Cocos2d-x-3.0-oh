/**
 * widgetlook-templates — WidgetLook 模板系统
 *
 * 提供常见控件类型的 WidgetLook 模板，用户可基于模板快速创建新控件外观。
 * 模板包含基本的 PropertyDefinition、ImagerySection、StateImagery 结构。
 */

import type {
  WidgetLook,
  PropertyDefinition,
  ImagerySection,
  StateImagery,
  StateLayer,
  StateSectionRef,
  FrameComponent,
  AreaDef,
  DimNode,
} from '@shared/model';

// ─── 模板定义 ────────────────────────────────────────────────────

export interface WidgetLookTemplate {
  /** 模板唯一标识 */
  id: string;
  /** 显示名称 */
  name: string;
  /** 描述 */
  description: string;
  /** 图标 */
  icon: string;
  /** 生成函数 */
  create: (name: string) => WidgetLook;
}

/** 标准九宫格区域 */
function fullArea(): AreaDef {
  return {
    left: { type: 'AbsoluteDim', value: 0 },
    top: { type: 'AbsoluteDim', value: 0 },
    right: { type: 'UnifiedDim', scale: 1, offset: 0, dimType: 'RightEdge' },
    bottom: { type: 'UnifiedDim', scale: 1, offset: 0, dimType: 'BottomEdge' },
  };
}

/** 空 FrameComponent */
function emptyFrame(): FrameComponent {
  return {
    area: fullArea(),
    images: {},
    vertFormat: 'Stretched',
    horzFormat: 'Stretched',
  };
}

/** 基本属性定义 */
function commonPropertyDefs(): PropertyDefinition[] {
  return [
    { name: 'NormalTextColour', initialValue: 'FFFFFFFF', redrawOnWrite: true },
    { name: 'HoverTextColour', initialValue: 'FFFFFFFF', redrawOnWrite: true },
    { name: 'PushedTextColour', initialValue: 'FFFFFFFF', redrawOnWrite: true },
    { name: 'DisabledTextColour', initialValue: 'FF777777', redrawOnWrite: true },
  ];
}

// ─── 内置模板 ────────────────────────────────────────────────────

/** 通用按钮模板 */
const ButtonTemplate: WidgetLookTemplate = {
  id: 'button',
  name: 'Button',
  description: 'Standard button with Normal/Hovered/Pushed/Disabled states',
  icon: '🔘',
  create: (name: string): WidgetLook => ({
    name,
    propertyDefinitions: [
      ...commonPropertyDefs(),
      { name: 'NormalImage', initialValue: '', redrawOnWrite: true },
      { name: 'HoverImage', initialValue: '', redrawOnWrite: true },
      { name: 'PushedImage', initialValue: '', redrawOnWrite: true },
      { name: 'DisabledImage', initialValue: '', redrawOnWrite: true },
    ],
    propertyLinkDefinitions: [],
    properties: [],
    namedAreas: [],
    children: [],
    imagerySections: [
      {
        name: 'normal',
        frameComponents: [emptyFrame()],
        imageryComponents: [],
        textComponents: [],
      },
      {
        name: 'hover',
        frameComponents: [emptyFrame()],
        imageryComponents: [],
        textComponents: [],
      },
      {
        name: 'pushed',
        frameComponents: [emptyFrame()],
        imageryComponents: [],
        textComponents: [],
      },
      {
        name: 'disabled',
        frameComponents: [emptyFrame()],
        imageryComponents: [],
        textComponents: [],
      },
    ],
    stateImagerys: [
      { name: 'Enabled', layers: [{ sections: [{ sectionName: 'normal' }] }] },
      { name: 'Hovered', layers: [{ sections: [{ sectionName: 'hover' }] }] },
      { name: 'Pushed', layers: [{ sections: [{ sectionName: 'pushed' }] }] },
      { name: 'Disabled', layers: [{ sections: [{ sectionName: 'disabled' }] }] },
      { name: 'PushedOff', layers: [{ sections: [{ sectionName: 'normal' }] }] },
    ],
  }),
};

/** 静态图像模板 */
const StaticTemplate: WidgetLookTemplate = {
  id: 'static',
  name: 'Static Image',
  description: 'Static image display with optional frame',
  icon: '🖼',
  create: (name: string): WidgetLook => ({
    name,
    propertyDefinitions: [
      { name: 'Image', initialValue: '', redrawOnWrite: true },
      { name: 'FrameEnabled', initialValue: 'True', redrawOnWrite: true },
    ],
    propertyLinkDefinitions: [],
    properties: [],
    namedAreas: [],
    children: [],
    imagerySections: [
      {
        name: 'frame',
        frameComponents: [emptyFrame()],
        imageryComponents: [],
        textComponents: [],
      },
      {
        name: 'background',
        frameComponents: [],
        imageryComponents: [{
          area: fullArea(),
          vertFormat: 'Stretched',
          horzFormat: 'Stretched',
        }],
        textComponents: [],
      },
    ],
    stateImagerys: [
      { name: 'Enabled', layers: [
        { sections: [{ sectionName: 'frame' }] },
        { sections: [{ sectionName: 'background' }] },
      ] },
      { name: 'Disabled', layers: [
        { sections: [{ sectionName: 'frame' }] },
        { sections: [{ sectionName: 'background' }] },
      ] },
    ],
  }),
};

/** 文本标签模板 */
const LabelTemplate: WidgetLookTemplate = {
  id: 'label',
  name: 'Label',
  description: 'Text label with font and colour properties',
  icon: '🏷',
  create: (name: string): WidgetLook => ({
    name,
    propertyDefinitions: [
      { name: 'TextColour', initialValue: 'FFFFFFFF', redrawOnWrite: true },
      { name: 'Font', initialValue: '', redrawOnWrite: true, layoutOnWrite: true },
    ],
    propertyLinkDefinitions: [],
    properties: [],
    namedAreas: [],
    children: [],
    imagerySections: [
      {
        name: 'text',
        frameComponents: [],
        imageryComponents: [],
        textComponents: [{
          area: fullArea(),
          vertFormat: 'CentreAligned',
          horzFormat: 'CentreAligned',
        }],
      },
    ],
    stateImagerys: [
      { name: 'Enabled', layers: [{ sections: [{ sectionName: 'text' }] }] },
      { name: 'Disabled', layers: [{ sections: [{ sectionName: 'text' }] }] },
    ],
  }),
};

/** 滑块模板 */
const SliderTemplate: WidgetLookTemplate = {
  id: 'slider',
  name: 'Slider',
  description: 'Horizontal/Vertical slider with track and thumb',
  icon: '↔',
  create: (name: string): WidgetLook => ({
    name,
    propertyDefinitions: [
      { name: 'CurrentValue', initialValue: '0', redrawOnWrite: true },
      { name: 'MaximumValue', initialValue: '100', redrawOnWrite: true },
    ],
    propertyLinkDefinitions: [],
    properties: [],
    namedAreas: [],
    children: [],
    imagerySections: [
      {
        name: 'track',
        frameComponents: [emptyFrame()],
        imageryComponents: [],
        textComponents: [],
      },
      {
        name: 'thumb',
        frameComponents: [emptyFrame()],
        imageryComponents: [],
        textComponents: [],
      },
    ],
    stateImagerys: [
      { name: 'Enabled', layers: [
        { sections: [{ sectionName: 'track' }] },
        { sections: [{ sectionName: 'thumb' }] },
      ] },
      { name: 'Disabled', layers: [
        { sections: [{ sectionName: 'track' }] },
      ] },
    ],
  }),
};

/** 标题窗口模板 */
const TitleWindowTemplate: WidgetLookTemplate = {
  id: 'titlewindow',
  name: 'Title Window',
  description: 'Window with title bar and close button',
  icon: '🪟',
  create: (name: string): WidgetLook => ({
    name,
    propertyDefinitions: [
      { name: 'CaptionColour', initialValue: 'FFFFFFFF', redrawOnWrite: true },
      { name: 'TitlebarFont', initialValue: '', redrawOnWrite: true },
    ],
    propertyLinkDefinitions: [],
    properties: [],
    namedAreas: [],
    children: [],
    imagerySections: [
      {
        name: 'titlebar',
        frameComponents: [emptyFrame()],
        imageryComponents: [],
        textComponents: [{
          area: {
            left: { type: 'AbsoluteDim', value: 8 },
            top: { type: 'AbsoluteDim', value: 0 },
            right: { type: 'UnifiedDim', scale: 1, offset: -40, dimType: 'RightEdge' },
            bottom: { type: 'UnifiedDim', scale: 1, offset: 0, dimType: 'BottomEdge' },
          },
          vertFormat: 'CentreAligned',
          horzFormat: 'LeftAligned',
        }],
      },
      {
        name: 'closebtn',
        frameComponents: [emptyFrame()],
        imageryComponents: [],
        textComponents: [],
      },
      {
        name: 'body',
        frameComponents: [emptyFrame()],
        imageryComponents: [],
        textComponents: [],
      },
    ],
    stateImagerys: [
      { name: 'Active', layers: [
        { sections: [{ sectionName: 'titlebar' }, { sectionName: 'closebtn' }] },
        { sections: [{ sectionName: 'body' }] },
      ] },
      { name: 'Inactive', layers: [
        { sections: [{ sectionName: 'titlebar' }, { sectionName: 'closebtn' }] },
        { sections: [{ sectionName: 'body' }] },
      ] },
    ],
  }),
};

/** 滚动条模板 */
const ScrollbarTemplate: WidgetLookTemplate = {
  id: 'scrollbar',
  name: 'Scrollbar',
  description: 'Vertical or horizontal scrollbar',
  icon: '↕',
  create: (name: string): WidgetLook => ({
    name,
    propertyDefinitions: [
      { name: 'ScrollPosition', initialValue: '0', redrawOnWrite: true },
    ],
    propertyLinkDefinitions: [],
    properties: [],
    namedAreas: [],
    children: [],
    imagerySections: [
      {
        name: 'track',
        frameComponents: [emptyFrame()],
        imageryComponents: [],
        textComponents: [],
      },
      {
        name: 'thumb',
        frameComponents: [emptyFrame()],
        imageryComponents: [],
        textComponents: [],
      },
      {
        name: 'upbtn',
        frameComponents: [emptyFrame()],
        imageryComponents: [],
        textComponents: [],
      },
      {
        name: 'downbtn',
        frameComponents: [emptyFrame()],
        imageryComponents: [],
        textComponents: [],
      },
    ],
    stateImagerys: [
      { name: 'Enabled', layers: [
        { sections: [{ sectionName: 'track' }, { sectionName: 'upbtn' }, { sectionName: 'downbtn' }] },
        { sections: [{ sectionName: 'thumb' }] },
      ] },
      { name: 'Disabled', layers: [
        { sections: [{ sectionName: 'track' }] },
      ] },
    ],
  }),
};

// ─── 模板注册表 ──────────────────────────────────────────────────

/** 所有内置模板 */
export const BUILTIN_TEMPLATES: WidgetLookTemplate[] = [
  ButtonTemplate,
  StaticTemplate,
  LabelTemplate,
  SliderTemplate,
  TitleWindowTemplate,
  ScrollbarTemplate,
];

/**
 * 根据 ID 获取模板
 */
export function getTemplateById(id: string): WidgetLookTemplate | undefined {
  return BUILTIN_TEMPLATES.find(t => t.id === id);
}

/**
 * 从模板创建 WidgetLook
 */
export function createFromTemplate(templateId: string, widgetLookName: string): WidgetLook | null {
  const template = getTemplateById(templateId);
  if (!template) return null;
  return template.create(widgetLookName);
}

/**
 * 获取所有模板的摘要信息
 */
export function getTemplateSummaries(): Array<{
  id: string;
  name: string;
  description: string;
  icon: string;
}> {
  return BUILTIN_TEMPLATES.map(t => ({
    id: t.id,
    name: t.name,
    description: t.description,
    icon: t.icon,
  }));
}
