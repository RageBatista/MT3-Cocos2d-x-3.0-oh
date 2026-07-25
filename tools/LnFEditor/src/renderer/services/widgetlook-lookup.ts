import type { ImagerySection, StateSectionRef, WidgetLook } from '@shared/model';

export function resolveImagerySection(
  sectionRef: Pick<StateSectionRef, 'sectionName' | 'look'>,
  currentWidgetLookName: string,
  currentSections: Map<string, ImagerySection>,
  availableLooks?: Map<string, WidgetLook>,
): ImagerySection | undefined {
  if (!sectionRef.look || sectionRef.look === currentWidgetLookName) {
    return currentSections.get(sectionRef.sectionName);
  }

  const targetLook = availableLooks?.get(sectionRef.look);
  return targetLook?.imagerySections.find(section => section.name === sectionRef.sectionName);
}

export function formatSectionRefName(sectionRef: Pick<StateSectionRef, 'sectionName' | 'look'>): string {
  return sectionRef.look
    ? `${sectionRef.look}:${sectionRef.sectionName}`
    : sectionRef.sectionName;
}
