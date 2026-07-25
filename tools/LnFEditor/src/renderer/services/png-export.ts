/**
 * png-export — Canvas PNG 导出服务
 *
 * 将当前 Canvas 渲染结果导出为 PNG 文件。
 * 支持导出当前视图、单个 WidgetLook、单个 ImagerySection。
 */

import type { WidgetLook, ImagerySection, StateImagery, DimEvaluationContext } from '@shared/model';
import type { SubImageCache } from '../canvas/renderer';
import { renderWidgetLook } from '../canvas/renderer';

/** 导出范围 */
export type ExportScope = 'viewport' | 'widgetlook' | 'section';

/** 导出选项 */
export interface ExportOptions {
  /** 导出范围 */
  scope: ExportScope;
  /** 目标 section 名称（scope=section 时使用） */
  sectionName?: string;
  /** 输出宽度（像素），默认使用 parentWidth */
  width?: number;
  /** 输出高度（像素），默认使用 parentHeight */
  height?: number;
  /** 背景色（ARGB 字符串），默认透明 */
  background?: string;
  /** 缩放比例 */
  scale?: number;
}

/** 导出结果 */
export interface ExportResult {
  /** PNG Data URL */
  dataUrl: string;
  /** 实际宽度 */
  width: number;
  /** 实际高度 */
  height: number;
}

/**
 * 导出 Canvas 内容为 PNG
 */
export function exportToPng(
  canvas: HTMLCanvasElement,
  options?: Partial<ExportOptions>,
): ExportResult {
  const scale = options?.scale || 1;
  const width = options?.width || canvas.width;
  const height = options?.height || canvas.height;

  const exportCanvas = document.createElement('canvas');
  exportCanvas.width = Math.round(width * scale);
  exportCanvas.height = Math.round(height * scale);

  const ctx = exportCanvas.getContext('2d');
  if (!ctx) {
    throw new Error('Failed to create export canvas context');
  }

  // 绘制背景
  if (options?.background) {
    ctx.fillStyle = argbToCss(options.background);
    ctx.fillRect(0, 0, exportCanvas.width, exportCanvas.height);
  }

  // 从源 canvas 复制
  ctx.drawImage(canvas, 0, 0, exportCanvas.width, exportCanvas.height);

  const dataUrl = exportCanvas.toDataURL('image/png');

  return {
    dataUrl,
    width: exportCanvas.width,
    height: exportCanvas.height,
  };
}

/**
 * 将 WidgetLook 渲染到离屏 Canvas 并导出为 PNG
 */
export function exportWidgetLookToPng(
  widgetLook: WidgetLook,
  matchedStates: StateImagery[],
  evalCtx: DimEvaluationContext,
  textureCache: SubImageCache,
  options?: Partial<ExportOptions>,
): ExportResult {
  const width = options?.width || evalCtx.parentWidth;
  const height = options?.height || evalCtx.parentHeight;
  const scale = options?.scale || 1;

  const exportCanvas = document.createElement('canvas');
  exportCanvas.width = Math.round(width * scale);
  exportCanvas.height = Math.round(height * scale);

  const ctx = exportCanvas.getContext('2d');
  if (!ctx) {
    throw new Error('Failed to create export canvas context');
  }

  // 背景
  if (options?.background) {
    ctx.fillStyle = argbToCss(options.background);
    ctx.fillRect(0, 0, exportCanvas.width, exportCanvas.height);
  }

  // 渲染
  ctx.save();
  if (scale !== 1) {
    ctx.scale(scale, scale);
  }

  renderWidgetLook(
    ctx,
    widgetLook.imagerySections,
    matchedStates,
    evalCtx,
    textureCache,
    { offsetX: 0, offsetY: 0, scale: 1 },
  );

  ctx.restore();

  const dataUrl = exportCanvas.toDataURL('image/png');

  return {
    dataUrl,
    width: exportCanvas.width,
    height: exportCanvas.height,
  };
}

/**
 * 触发浏览器下载 PNG
 */
export function downloadPng(dataUrl: string, filename: string): void {
  const link = document.createElement('a');
  link.href = dataUrl;
  link.download = filename;
  link.click();
}

// ─── 辅助函数 ────────────────────────────────────────────────────

function argbToCss(argb: string): string {
  if (argb.startsWith('#')) return argb;

  const normalized = argb.trim().replace(/^0x/i, '').toUpperCase();
  if (normalized.length === 8) {
    const a = parseInt(normalized.slice(0, 2), 16) / 255;
    const r = parseInt(normalized.slice(2, 4), 16);
    const g = parseInt(normalized.slice(4, 6), 16);
    const b = parseInt(normalized.slice(6, 8), 16);
    return `rgba(${r},${g},${b},${a})`;
  }
  if (normalized.length === 6) {
    return `#${normalized}`;
  }
  return argb;
}
