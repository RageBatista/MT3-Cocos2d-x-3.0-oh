import type { PixelRect, DragMode, DragState, SnapLine, CanvasViewport } from '@shared/model';

/** 检测鼠标位置对应的拖拽模式 */
export function hitTestDragMode(
  mouseX: number,
  mouseY: number,
  rect: PixelRect,
  viewport: CanvasViewport,
  handleRadius: number = 6,
): DragMode | null {
  const { offsetX, offsetY, scale } = viewport;
  const sx = (mouseX - offsetX) / scale;
  const sy = (mouseY - offsetY) / scale;

  const r = handleRadius / scale;
  const cx = rect.x + rect.w / 2;
  const cy = rect.y + rect.h / 2;

  if (dist(sx, sy, rect.x, rect.y) <= r) return 'resize-tl';
  if (dist(sx, sy, rect.x + rect.w, rect.y) <= r) return 'resize-tr';
  if (dist(sx, sy, rect.x, rect.y + rect.h) <= r) return 'resize-bl';
  if (dist(sx, sy, rect.x + rect.w, rect.y + rect.h) <= r) return 'resize-br';
  if (dist(sx, sy, cx, rect.y) <= r) return 'resize-t';
  if (dist(sx, sy, cx, rect.y + rect.h) <= r) return 'resize-b';
  if (dist(sx, sy, rect.x, cy) <= r) return 'resize-l';
  if (dist(sx, sy, rect.x + rect.w, cy) <= r) return 'resize-r';

  if (sx >= rect.x && sx <= rect.x + rect.w && sy >= rect.y && sy <= rect.y + rect.h) {
    return 'move';
  }

  return null;
}

/** 根据拖拽模式计算新的矩形 */
export function applyDrag(
  mode: DragMode,
  dx: number,
  dy: number,
  original: PixelRect,
  minSize: number = 4,
): PixelRect {
  const result = { ...original };

  switch (mode) {
    case 'move':
      result.x += dx;
      result.y += dy;
      break;
    case 'resize-tl':
      result.x += dx;
      result.y += dy;
      result.w -= dx;
      result.h -= dy;
      break;
    case 'resize-tr':
      result.y += dy;
      result.w += dx;
      result.h -= dy;
      break;
    case 'resize-bl':
      result.x += dx;
      result.w -= dx;
      result.h += dy;
      break;
    case 'resize-br':
      result.w += dx;
      result.h += dy;
      break;
    case 'resize-t':
      result.y += dy;
      result.h -= dy;
      break;
    case 'resize-b':
      result.h += dy;
      break;
    case 'resize-l':
      result.x += dx;
      result.w -= dx;
      break;
    case 'resize-r':
      result.w += dx;
      break;
  }

  if (result.w < minSize) {
    if (mode.includes('l') || mode === 'resize-tl' || mode === 'resize-bl') {
      result.x = original.x + original.w - minSize;
    }
    result.w = minSize;
  }
  if (result.h < minSize) {
    if (mode.includes('t') || mode === 'resize-tl' || mode === 'resize-tr') {
      result.y = original.y + original.h - minSize;
    }
    result.h = minSize;
  }

  return result;
}

/** 计算对齐吸附线 */
export function computeSnapLines(
  movingRect: PixelRect,
  staticRects: PixelRect[],
  threshold: number = 5,
): SnapLine[] {
  const lines: SnapLine[] = [];

  const movingEdges = {
    left: movingRect.x,
    right: movingRect.x + movingRect.w,
    top: movingRect.y,
    bottom: movingRect.y + movingRect.h,
    centerX: movingRect.x + movingRect.w / 2,
    centerY: movingRect.y + movingRect.h / 2,
  };

  for (const sr of staticRects) {
    const staticEdges = {
      left: sr.x,
      right: sr.x + sr.w,
      top: sr.y,
      bottom: sr.y + sr.h,
      centerX: sr.x + sr.w / 2,
      centerY: sr.y + sr.h / 2,
    };

    checkSnapPair(movingEdges.left, staticEdges.left, 'vertical', sr, threshold, lines);
    checkSnapPair(movingEdges.left, staticEdges.right, 'vertical', sr, threshold, lines);
    checkSnapPair(movingEdges.right, staticEdges.left, 'vertical', sr, threshold, lines);
    checkSnapPair(movingEdges.right, staticEdges.right, 'vertical', sr, threshold, lines);
    checkSnapPair(movingEdges.centerX, staticEdges.centerX, 'vertical', sr, threshold, lines);

    checkSnapPair(movingEdges.top, staticEdges.top, 'horizontal', sr, threshold, lines);
    checkSnapPair(movingEdges.top, staticEdges.bottom, 'horizontal', sr, threshold, lines);
    checkSnapPair(movingEdges.bottom, staticEdges.top, 'horizontal', sr, threshold, lines);
    checkSnapPair(movingEdges.bottom, staticEdges.bottom, 'horizontal', sr, threshold, lines);
    checkSnapPair(movingEdges.centerY, staticEdges.centerY, 'horizontal', sr, threshold, lines);
  }

  return lines;
}

/** 吸附到最近的吸附线位置 */
export function snapPosition(
  rect: PixelRect,
  snapLines: SnapLine[],
): { x: number; y: number } {
  let bestDx = Infinity;
  let bestDy = Infinity;

  for (const line of snapLines) {
    if (line.orientation === 'vertical') {
      const dx = line.position - rect.x;
      if (Math.abs(dx) < Math.abs(bestDx)) bestDx = dx;
    } else {
      const dy = line.position - rect.y;
      if (Math.abs(dy) < Math.abs(bestDy)) bestDy = dy;
    }
  }

  return {
    x: Math.abs(bestDx) < Infinity ? rect.x + bestDx : rect.x,
    y: Math.abs(bestDy) < Infinity ? rect.y + bestDy : rect.y,
  };
}

/** 画布坐标 → 屏幕坐标 */
export function canvasToScreen(
  cx: number,
  cy: number,
  viewport: CanvasViewport,
): { x: number; y: number } {
  return {
    x: cx * viewport.scale + viewport.offsetX,
    y: cy * viewport.scale + viewport.offsetY,
  };
}

/** 屏幕坐标 → 画布坐标 */
export function screenToCanvas(
  sx: number,
  sy: number,
  viewport: CanvasViewport,
): { x: number; y: number } {
  return {
    x: (sx - viewport.offsetX) / viewport.scale,
    y: (sy - viewport.offsetY) / viewport.scale,
  };
}

/** 缩放视口以鼠标位置为中心 */
export function zoomViewport(
  viewport: CanvasViewport,
  delta: number,
  pivotX: number,
  pivotY: number,
  minScale: number = 0.1,
  maxScale: number = 10,
): CanvasViewport {
  const factor = delta > 0 ? 0.9 : 1.1;
  const newScale = Math.min(maxScale, Math.max(minScale, viewport.scale * factor));

  const ratio = newScale / viewport.scale;
  const newOffsetX = pivotX - (pivotX - viewport.offsetX) * ratio;
  const newOffsetY = pivotY - (pivotY - viewport.offsetY) * ratio;

  return {
    ...viewport,
    scale: newScale,
    offsetX: newOffsetX,
    offsetY: newOffsetY,
  };
}

function dist(x1: number, y1: number, x2: number, y2: number): number {
  return Math.sqrt((x1 - x2) ** 2 + (y1 - y2) ** 2);
}

function checkSnapPair(
  movingPos: number,
  staticPos: number,
  orientation: 'horizontal' | 'vertical',
  sourceRect: PixelRect,
  threshold: number,
  lines: SnapLine[],
): void {
  const diff = Math.abs(movingPos - staticPos);
  if (diff <= threshold && diff > 0) {
    lines.push({
      orientation,
      position: staticPos,
      sourceRect,
      threshold,
    });
  }
}
