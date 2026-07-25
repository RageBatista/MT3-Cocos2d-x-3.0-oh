import {
  makeComponentNodeId,
  type WidgetLook,
  type ImagerySection,
  type StateImagery,
  type LayerTreeNode,
} from '@shared/model';
import { formatSectionRefName, resolveImagerySection } from './widgetlook-lookup';

const ICON_MAP: Record<LayerTreeNode['type'], string> = {
  widgetlook: '📦',
  section: '🎨',
  component: '🖼️',
  state: '⚡',
  layer: '📑',
  property: '⚙️',
  namedarea: '📐',
  child: '🧩',
};

/** 从 WidgetLook 生成层级树 */
export function buildLayerTree(
  wl: WidgetLook,
  activeStateNames: string[] = [],
  availableLooks?: Map<string, WidgetLook>,
): LayerTreeNode {
  const activeStates = new Set(activeStateNames);
  const sectionMap = new Map(wl.imagerySections.map(section => [section.name, section]));
  const root: LayerTreeNode = {
    id: `wl-${wl.name}`,
    type: 'widgetlook',
    name: wl.name,
    icon: ICON_MAP.widgetlook,
    visible: true,
    locked: false,
    selected: false,
    children: [],
    dataRef: wl,
  };

  if (wl.propertyDefinitions.length > 0 || wl.properties.length > 0) {
    const propNode: LayerTreeNode = {
      id: `wl-${wl.name}-props`,
      type: 'property',
      name: 'Properties',
      icon: ICON_MAP.property,
      visible: true,
      locked: false,
      selected: false,
      children: [
        ...wl.propertyDefinitions.map((pd, i) => ({
          id: `wl-${wl.name}-pd-${i}`,
          type: 'property' as const,
          name: `${pd.name} = ${pd.initialValue}`,
          icon: '⚙️',
          visible: true,
          locked: false,
          selected: false,
          children: [],
          dataRef: pd,
        })),
        ...wl.properties.map((p, i) => ({
          id: `wl-${wl.name}-p-${i}`,
          type: 'property' as const,
          name: `${p.name} = ${p.value}`,
          icon: '⚙️',
          visible: true,
          locked: false,
          selected: false,
          children: [],
          dataRef: p,
        })),
      ],
      dataRef: null,
    };
    root.children.push(propNode);
  }

  if (wl.namedAreas.length > 0) {
    const naNode: LayerTreeNode = {
      id: `wl-${wl.name}-areas`,
      type: 'namedarea',
      name: 'Named Areas',
      icon: ICON_MAP.namedarea,
      visible: true,
      locked: false,
      selected: false,
      children: wl.namedAreas.map((na, i) => ({
        id: `wl-${wl.name}-na-${i}`,
        type: 'namedarea' as const,
        name: na.name,
        icon: '📐',
        visible: true,
        locked: false,
        selected: false,
        children: [],
        dataRef: na,
      })),
      dataRef: null,
    };
    root.children.push(naNode);
  }

  if (wl.children.length > 0) {
    const childNode: LayerTreeNode = {
      id: `wl-${wl.name}-children`,
      type: 'child',
      name: 'Children',
      icon: ICON_MAP.child,
      visible: true,
      locked: false,
      selected: false,
      children: wl.children.map((c, i) => ({
        id: `wl-${wl.name}-child-${i}`,
        type: 'child' as const,
        name: `${c.type} (${c.nameSuffix})`,
        icon: '🧩',
        visible: true,
        locked: false,
        selected: false,
        children: [],
        dataRef: c,
      })),
      dataRef: null,
    };
    root.children.push(childNode);
  }

  const sectionNode: LayerTreeNode = {
    id: `wl-${wl.name}-sections`,
    type: 'section',
    name: 'Imagery Sections',
    icon: ICON_MAP.section,
    visible: true,
    locked: false,
    selected: false,
    children: wl.imagerySections.map(sec => buildSectionNode(wl.name, sec)),
    dataRef: null,
  };
  root.children.push(sectionNode);

  const stateNode: LayerTreeNode = {
    id: `wl-${wl.name}-states`,
    type: 'state',
    name: 'State Imagery',
    icon: ICON_MAP.state,
    visible: true,
    locked: false,
    selected: false,
    children: wl.stateImagerys.map((si, i) => buildStateNode(wl.name, si, i, sectionMap, activeStates, availableLooks)),
    dataRef: null,
  };
  root.children.push(stateNode);

  return root;
}

/** 构建 ImagerySection 层级节点 */
function buildSectionNode(wlName: string, section: ImagerySection): LayerTreeNode {
  return {
    id: `wl-${wlName}-section-${section.name}`,
    type: 'section',
    name: section.name,
    icon: ICON_MAP.section,
    visible: true,
    locked: false,
    selected: false,
    children: buildSectionComponentNodes(section),
    dataRef: section,
  };
}

/** 构建 StateImagery 层级节点 */
function buildStateNode(
  wlName: string,
  state: StateImagery,
  index: number,
  sectionMap: Map<string, ImagerySection>,
  activeStates: Set<string>,
  availableLooks?: Map<string, WidgetLook>,
): LayerTreeNode {
  const children: LayerTreeNode[] = [];

  state.layers.forEach((layer, li) => {
    const layerChildren: LayerTreeNode[] = layer.sections.map((sec, si) => {
      const resolvedSection = resolveImagerySection(sec, wlName, sectionMap, availableLooks);
      return {
        id: `wl-${wlName}-state-${index}-layer-${li}-sec-${si}`,
        type: 'section' as const,
        name: formatSectionRefName(sec),
        icon: '🎨',
        visible: true,
        locked: false,
        selected: false,
        children: buildSectionComponentNodes(resolvedSection, sec.look),
        dataRef: resolvedSection ?? sec,
      };
    });

    children.push({
      id: `wl-${wlName}-state-${index}-layer-${li}`,
      type: 'layer',
      name: `Layer ${li}`,
      icon: ICON_MAP.layer,
      visible: true,
      locked: false,
      selected: false,
      children: layerChildren,
      dataRef: layer,
    });
  });

  return {
    id: `state:${state.name}`,
    type: 'state',
    name: state.name,
    icon: ICON_MAP.state,
    visible: true,
    locked: false,
    selected: activeStates.size > 0 && activeStates.has(state.name),
    children,
    dataRef: state,
  };
}

function buildSectionComponentNodes(
  section: ImagerySection | undefined,
  lookName?: string,
): LayerTreeNode[] {
  if (!section) {
    return [];
  }

  return [
    ...section.frameComponents.map((component, index) => ({
      id: makeComponentNodeId(section.name, 'frame', index, lookName),
      type: 'component' as const,
      name: 'FrameComponent',
      icon: '🖼️',
      visible: true,
      locked: false,
      selected: false,
      children: [],
      dataRef: component,
    })),
    ...section.imageryComponents.map((component, index) => ({
      id: makeComponentNodeId(section.name, 'imagery', index, lookName),
      type: 'component' as const,
      name: 'ImageryComponent',
      icon: '🖼️',
      visible: true,
      locked: false,
      selected: false,
      children: [],
      dataRef: component,
    })),
    ...section.textComponents.map((component, index) => ({
      id: makeComponentNodeId(section.name, 'text', index, lookName),
      type: 'component' as const,
      name: 'TextComponent',
      icon: '🖼️',
      visible: true,
      locked: false,
      selected: false,
      children: [],
      dataRef: component,
    })),
  ];
}
