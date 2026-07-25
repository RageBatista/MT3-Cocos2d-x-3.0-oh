/**
 * 引用验证器 — 检查 WidgetLook 中 imageset/image 引用的完整性
 *
 * 验证流程:
 * 1. 收集 WidgetLook 中所有 ImageRef（imageset + image 对）
 * 2. 检查每个 imageset 是否在已加载的资源中存在
 * 3. 检查每个 image 名称是否在对应 imageset 的子图像中存在
 * 4. 输出验证结果（error/warning/info）
 */

import type { WidgetLook, ImagerySection, FrameComponent, ImageryComponent, ValidationError, ValidationResult, ImageRef } from '@shared/model';
import type { ImagesetResource } from '@shared/model';

/** 收集 WidgetLook 中的所有图像引用 */
export function collectImageRefs(wl: WidgetLook): ImageRef[] {
  const refs: ImageRef[] = [];

  for (const section of wl.imagerySections) {
    collectFromSection(section, refs);
  }

  // 去重
  const unique = new Map<string, ImageRef>();
  for (const ref of refs) {
    unique.set(`${ref.imageset}/${ref.image}`, ref);
  }

  return Array.from(unique.values());
}

function collectFromSection(section: ImagerySection, refs: ImageRef[]): void {
  for (const fc of section.frameComponents) {
    for (const ref of Object.values(fc.images)) {
      if (ref) refs.push(ref);
    }
  }
  for (const ic of section.imageryComponents) {
    if (ic.image) refs.push(ic.image);
  }
}

/** 验证单个 WidgetLook 的引用完整性 */
export function validateWidgetLook(
  wl: WidgetLook,
  availableImagesets: Map<string, ImagesetResource>,
): ValidationResult {
  const errors: ValidationError[] = [];
  const refs = collectImageRefs(wl);

  for (const ref of refs) {
    const imageset = availableImagesets.get(ref.imageset);

    if (!imageset) {
      errors.push({
        level: 'error',
        message: `Missing imageset: "${ref.imageset}" (referenced in WidgetLook "${wl.name}")`,
        sourcePath: ref.imageset,
      });
      continue;
    }

    const subImage = imageset.subImages.get(ref.image);
    if (!subImage) {
      errors.push({
        level: 'warning',
        message: `Missing sub-image: "${ref.image}" in imageset "${ref.imageset}" (referenced in WidgetLook "${wl.name}")`,
        sourcePath: `${ref.imageset}/${ref.image}`,
      });
      continue;
    }

    // 检查尺寸是否有效
    if (subImage.width <= 0 || subImage.height <= 0) {
      errors.push({
        level: 'warning',
        message: `Invalid sub-image dimensions: "${ref.image}" in "${ref.imageset}" (${subImage.width}×${subImage.height})`,
        sourcePath: `${ref.imageset}/${ref.image}`,
      });
    }
  }

  // 检查 StateImagery 中引用的 ImagerySection 是否存在
  const sectionNames = new Set(wl.imagerySections.map(s => s.name));
  for (const si of wl.stateImagerys) {
    for (const layer of si.layers) {
      for (const secRef of layer.sections) {
        if (secRef.sectionName && !sectionNames.has(secRef.sectionName)) {
          errors.push({
            level: 'warning',
            message: `StateImagery "${si.name}" references non-existent section "${secRef.sectionName}"`,
            sourcePath: `${wl.name}/StateImagery/${si.name}`,
          });
        }
      }
    }
  }

  // 检查子控件的 type 是否在 scheme 中有对应的 FalagardMapping
  // （这个需要 scheme 数据，暂时跳过）

  return {
    valid: errors.filter(e => e.level === 'error').length === 0,
    errors,
  };
}

/** 批量验证所有 WidgetLook */
export function validateAllWidgetLooks(
  widgetLooks: WidgetLook[],
  availableImagesets: Map<string, ImagesetResource>,
): Map<string, ValidationResult> {
  const results = new Map<string, ValidationResult>();
  for (const wl of widgetLooks) {
    results.set(wl.name, validateWidgetLook(wl, availableImagesets));
  }
  return results;
}

/** 统计验证结果 */
export function summarizeValidationResults(
  results: Map<string, ValidationResult>,
): { total: number; errors: number; warnings: number; infos: number } {
  let errors = 0;
  let warnings = 0;
  let infos = 0;

  for (const result of results.values()) {
    for (const e of result.errors) {
      if (e.level === 'error') errors++;
      else if (e.level === 'warning') warnings++;
      else infos++;
    }
  }

  return { total: results.size, errors, warnings, infos };
}
