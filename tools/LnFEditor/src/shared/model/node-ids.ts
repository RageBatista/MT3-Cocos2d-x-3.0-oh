export type ComponentNodeType = 'frame' | 'imagery' | 'text';

export interface ComponentNodeRef {
  look?: string;
  sectionName: string;
  componentType: ComponentNodeType;
  componentIndex: number;
}

export function makeComponentNodeId(
  sectionName: string,
  componentType: ComponentNodeType,
  componentIndex: number,
  look?: string,
): string {
  return look
    ? `section:${look}:${sectionName}:${componentType}:${componentIndex}`
    : `section:${sectionName}:${componentType}:${componentIndex}`;
}

export function parseComponentNodeId(nodeId: string): ComponentNodeRef | null {
  const parts = nodeId.split(':');
  if (parts[0] !== 'section' || (parts.length !== 4 && parts.length !== 5)) {
    return null;
  }

  const [look, sectionName, componentType, componentIndexRaw] = parts.length === 5
    ? [parts[1], parts[2], parts[3], parts[4]]
    : [undefined, parts[1], parts[2], parts[3]];
  if (componentType !== 'frame' && componentType !== 'imagery' && componentType !== 'text') {
    return null;
  }

  const componentIndex = Number.parseInt(componentIndexRaw, 10);
  if (!Number.isFinite(componentIndex) || componentIndex < 0) {
    return null;
  }

  return {
    look,
    sectionName,
    componentType,
    componentIndex,
  };
}
