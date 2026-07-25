import type {
  FrameComponent,
  ImageryComponent,
  TextComponent,
  ImagerySection,
  StateImagery,
  PixelRect,
  ColourRect,
  DimEvaluationContext,
  ImageRef,
  WidgetLook,
} from '@shared/model';
import { evaluateArea } from '@shared/services/dim-evaluator';
import { resolveImagerySection } from '../services/widgetlook-lookup';

/** 子图像纹理缓存接口 */
export interface SubImageCache {
  get(imageset: string, image: string): HTMLCanvasElement | OffscreenCanvas | null;
  has(imageset: string, image: string): boolean;
}

/** 渲染一个完整的 WidgetLook 到 Canvas */
export function renderWidgetLook(
  ctx: CanvasRenderingContext2D,
  sections: ImagerySection[],
  activeStates: StateImagery[],
  evalCtx: DimEvaluationContext,
  textureCache: SubImageCache,
  viewport: { offsetX: number; offsetY: number; scale: number },
  currentWidgetLookName = '',
  availableLooks?: Map<string, WidgetLook>,
): void {
  ctx.save();
  ctx.translate(viewport.offsetX, viewport.offsetY);
  ctx.scale(viewport.scale, viewport.scale);

  const sectionMap = new Map(sections.map(s => [s.name, s]));

  for (const state of activeStates) {
    for (const layer of state.layers) {
      for (const secRef of layer.sections) {
        const section = resolveImagerySection(secRef, currentWidgetLookName, sectionMap, availableLooks);
        if (!section) continue;

        renderImagerySection(
          ctx,
          section,
          evalCtx,
          textureCache,
          mergeColourRects(layer.colours, secRef.colours),
        );
      }
    }
  }

  ctx.restore();
}

/** 渲染单个 ImagerySection */
export function renderImagerySection(
  ctx: CanvasRenderingContext2D,
  section: ImagerySection,
  evalCtx: DimEvaluationContext,
  textureCache: SubImageCache,
  overrideColours?: ColourRect,
): void {
  for (const fc of section.frameComponents) {
    renderFrameComponent(ctx, fc, evalCtx, textureCache, overrideColours);
  }
  for (const ic of section.imageryComponents) {
    renderImageryComponent(ctx, ic, evalCtx, textureCache, overrideColours);
  }
  for (const tc of section.textComponents) {
    renderTextComponent(ctx, tc, evalCtx, overrideColours);
  }
}

/** 渲染 FrameComponent — 九宫格/三段式框架 */
export function renderFrameComponent(
  ctx: CanvasRenderingContext2D,
  frame: FrameComponent,
  evalCtx: DimEvaluationContext,
  textureCache: SubImageCache,
  overrideColours?: ColourRect,
): void {
  const area = evaluateArea(frame.area, evalCtx);
  if (area.w <= 0 || area.h <= 0) return;

  const images = frame.images;
  const hasBorders = images.LeftEdge || images.RightEdge || images.TopEdge || images.BottomEdge
    || images.TopLeftCorner || images.TopRightCorner || images.BottomLeftCorner || images.BottomRightCorner;

  if (!hasBorders) {
    const bgRef = images.Background;
    if (bgRef) {
      const bgCanvas = textureCache.get(bgRef.imageset, bgRef.image);
      if (bgCanvas) {
        applyColours(ctx, frame.colours || overrideColours, area);
        drawStretched(ctx, bgCanvas, area, frame.vertFormat, frame.horzFormat);
        ctx.globalAlpha = 1;
      }
    }
    return;
  }

  const topLeftCanvas = getCanvas(textureCache, images.TopLeftCorner);
  const topRightCanvas = getCanvas(textureCache, images.TopRightCorner);
  const bottomLeftCanvas = getCanvas(textureCache, images.BottomLeftCorner);
  const bottomRightCanvas = getCanvas(textureCache, images.BottomRightCorner);
  const leftCanvas = getCanvas(textureCache, images.LeftEdge);
  const rightCanvas = getCanvas(textureCache, images.RightEdge);
  const topCanvas = getCanvas(textureCache, images.TopEdge);
  const bottomCanvas = getCanvas(textureCache, images.BottomEdge);
  const bgCanvas = getCanvas(textureCache, images.Background);

  const leftW = topLeftCanvas?.width ?? bottomLeftCanvas?.width ?? leftCanvas?.width ?? 0;
  const rightW = topRightCanvas?.width ?? bottomRightCanvas?.width ?? rightCanvas?.width ?? 0;
  const topH = topLeftCanvas?.height ?? topRightCanvas?.height ?? topCanvas?.height ?? 0;
  const bottomH = bottomLeftCanvas?.height ?? bottomRightCanvas?.height ?? bottomCanvas?.height ?? 0;

  const innerX = area.x + leftW;
  const innerY = area.y + topH;
  const innerW = Math.max(0, area.w - leftW - rightW);
  const innerH = Math.max(0, area.h - topH - bottomH);

  applyColours(ctx, frame.colours || overrideColours, area);

  if (topLeftCanvas) ctx.drawImage(topLeftCanvas, area.x, area.y, leftW, topH);
  if (topRightCanvas) ctx.drawImage(topRightCanvas, area.x + area.w - rightW, area.y, rightW, topH);
  if (bottomLeftCanvas) ctx.drawImage(bottomLeftCanvas, area.x, area.y + area.h - bottomH, leftW, bottomH);
  if (bottomRightCanvas) ctx.drawImage(bottomRightCanvas, area.x + area.w - rightW, area.y + area.h - bottomH, rightW, bottomH);

  if (topCanvas) ctx.drawImage(topCanvas, innerX, area.y, innerW, topH);
  if (bottomCanvas) ctx.drawImage(bottomCanvas, innerX, area.y + area.h - bottomH, innerW, bottomH);
  if (leftCanvas) ctx.drawImage(leftCanvas, area.x, innerY, leftW, innerH);
  if (rightCanvas) ctx.drawImage(rightCanvas, area.x + area.w - rightW, innerY, rightW, innerH);

  if (bgCanvas) {
    drawStretched(ctx, bgCanvas, { x: innerX, y: innerY, w: innerW, h: innerH }, frame.vertFormat, frame.horzFormat);
  }

  ctx.globalAlpha = 1;
}

/** 渲染 ImageryComponent — 单图像 */
export function renderImageryComponent(
  ctx: CanvasRenderingContext2D,
  comp: ImageryComponent,
  evalCtx: DimEvaluationContext,
  textureCache: SubImageCache,
  overrideColours?: ColourRect,
): void {
  const area = evaluateArea(comp.area, evalCtx);
  if (area.w <= 0 || area.h <= 0) return;

  if (comp.image) {
    const canvas = textureCache.get(comp.image.imageset, comp.image.image);
    if (canvas) {
      applyColours(ctx, comp.colours || overrideColours, area);
      drawStretched(ctx, canvas, area, comp.vertFormat, comp.horzFormat);
      ctx.globalAlpha = 1;
    }
  }
}

/** 渲染 TextComponent — 文本占位 */
export function renderTextComponent(
  ctx: CanvasRenderingContext2D,
  comp: TextComponent,
  evalCtx: DimEvaluationContext,
  overrideColours?: ColourRect,
): void {
  const area = evaluateArea(comp.area, evalCtx);
  if (area.w <= 0 || area.h <= 0) return;

  const colours = comp.colours || overrideColours;
  const colour = colours ? argbToCss(colours.topLeft) : 'rgba(255,255,255,0.3)';

  ctx.save();
  ctx.fillStyle = colour;
  ctx.globalAlpha = 0.3;
  ctx.fillRect(area.x, area.y, area.w, area.h);

  ctx.strokeStyle = 'rgba(255,255,0,0.5)';
  ctx.lineWidth = 1;
  ctx.setLineDash([4, 4]);
  ctx.strokeRect(area.x + 0.5, area.y + 0.5, area.w - 1, area.h - 1);
  ctx.setLineDash([]);

  ctx.fillStyle = 'rgba(255,255,0,0.8)';
  ctx.font = '11px monospace';
  ctx.textAlign = 'center';
  ctx.textBaseline = 'middle';
  ctx.fillText('[Text]', area.x + area.w / 2, area.y + area.h / 2);

  ctx.restore();
}

/** 拉伸绘制图像 */
function drawStretched(
  ctx: CanvasRenderingContext2D,
  src: HTMLCanvasElement | OffscreenCanvas,
  area: PixelRect,
  vertFormat?: string,
  horzFormat?: string,
): void {
  if (vertFormat === 'Tiled' || horzFormat === 'Tiled') {
    drawTiled(ctx, src, area, vertFormat === 'Tiled', horzFormat === 'Tiled');
  } else {
    ctx.drawImage(src, area.x, area.y, area.w, area.h);
  }
}

/** 平铺绘制图像 */
function drawTiled(
  ctx: CanvasRenderingContext2D,
  src: HTMLCanvasElement | OffscreenCanvas,
  area: PixelRect,
  tileVert: boolean,
  tileHorz: boolean,
): void {
  const srcW = src.width;
  const srcH = src.height;

  if (tileHorz && tileVert) {
    for (let y = area.y; y < area.y + area.h; y += srcH) {
      for (let x = area.x; x < area.x + area.w; x += srcW) {
        const drawW = Math.min(srcW, area.x + area.w - x);
        const drawH = Math.min(srcH, area.y + area.h - y);
        ctx.drawImage(src, 0, 0, drawW, drawH, x, y, drawW, drawH);
      }
    }
  } else if (tileHorz) {
    for (let x = area.x; x < area.x + area.w; x += srcW) {
      const drawW = Math.min(srcW, area.x + area.w - x);
      ctx.drawImage(src, 0, 0, drawW, srcH, x, area.y, drawW, area.h);
    }
  } else if (tileVert) {
    for (let y = area.y; y < area.y + area.h; y += srcH) {
      const drawH = Math.min(srcH, area.y + area.h - y);
      ctx.drawImage(src, 0, 0, srcW, drawH, area.x, y, area.w, drawH);
    }
  }
}

/** 应用颜色覆盖 */
function applyColours(ctx: CanvasRenderingContext2D, colours: ColourRect | undefined, area: PixelRect): void {
  if (!colours) return;
  const tl = normalizeArgb(colours.topLeft);
  const alpha = parseInt(tl.slice(0, 2), 16) / 255;
  if (alpha < 1) ctx.globalAlpha = alpha;
}

/** ARGB 字符串 → CSS rgba() */
function argbToCss(argb: string): string {
  const normalized = normalizeArgb(argb);
  const a = parseInt(normalized.slice(0, 2), 16) / 255;
  const r = parseInt(normalized.slice(2, 4), 16);
  const g = parseInt(normalized.slice(4, 6), 16);
  const b = parseInt(normalized.slice(6, 8), 16);
  return `rgba(${r},${g},${b},${a.toFixed(2)})`;
}

function normalizeArgb(argb: string): string {
  const trimmed = argb.trim().replace(/^#/, '').replace(/^0x/i, '');
  if (trimmed.length === 8) {
    return trimmed.toUpperCase();
  }
  if (trimmed.length === 6) {
    return `FF${trimmed.toUpperCase()}`;
  }
  return 'FFFFFFFF';
}

function getCanvas(
  textureCache: SubImageCache,
  ref: ImageRef | undefined,
): HTMLCanvasElement | OffscreenCanvas | null {
  if (!ref) {
    return null;
  }
  return textureCache.get(ref.imageset, ref.image);
}

function mergeColourRects(base?: ColourRect, override?: ColourRect): ColourRect | undefined {
  if (!base) return override;
  if (!override) return base;
  return {
    topLeft: override.topLeft ?? base.topLeft,
    topRight: override.topRight ?? base.topRight,
    bottomLeft: override.bottomLeft ?? base.bottomLeft,
    bottomRight: override.bottomRight ?? base.bottomRight,
  };
}

/** 绘制选中元素的控制手柄 */
export function renderSelectionHandles(
  ctx: CanvasRenderingContext2D,
  rect: PixelRect,
  viewport: { offsetX: number; offsetY: number; scale: number },
): void {
  ctx.save();
  ctx.translate(viewport.offsetX, viewport.offsetY);
  ctx.scale(viewport.scale, viewport.scale);

  ctx.strokeStyle = '#00aaff';
  ctx.lineWidth = 1.5 / viewport.scale;
  ctx.setLineDash([6 / viewport.scale, 3 / viewport.scale]);
  ctx.strokeRect(rect.x, rect.y, rect.w, rect.h);
  ctx.setLineDash([]);

  const handleSize = 8 / viewport.scale;
  const halfHandle = handleSize / 2;
  const handles = [
    { x: rect.x - halfHandle, y: rect.y - halfHandle },
    { x: rect.x + rect.w - halfHandle, y: rect.y - halfHandle },
    { x: rect.x - halfHandle, y: rect.y + rect.h - halfHandle },
    { x: rect.x + rect.w - halfHandle, y: rect.y + rect.h - halfHandle },
    { x: rect.x + rect.w / 2 - halfHandle, y: rect.y - halfHandle },
    { x: rect.x + rect.w / 2 - halfHandle, y: rect.y + rect.h - halfHandle },
    { x: rect.x - halfHandle, y: rect.y + rect.h / 2 - halfHandle },
    { x: rect.x + rect.w - halfHandle, y: rect.y + rect.h / 2 - halfHandle },
  ];

  ctx.fillStyle = '#ffffff';
  ctx.strokeStyle = '#00aaff';
  ctx.lineWidth = 1.5 / viewport.scale;
  for (const h of handles) {
    ctx.fillRect(h.x, h.y, handleSize, handleSize);
    ctx.strokeRect(h.x, h.y, handleSize, handleSize);
  }

  ctx.restore();
}
