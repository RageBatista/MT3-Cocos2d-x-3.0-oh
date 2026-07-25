/**
 * dim-writeback — 拖拽结束后将像素坐标回写为 Dim 表达式
 *
 * 当用户在 Canvas 上拖拽组件（移动/缩放）后，需要将新的像素位置
 * 转换回 DimNode 表达式并更新到对应的 AreaDef 中。
 *
 * 策略：
 * 1. 尽量保持原始 Dim 类型（UnifiedDim 保持 UnifiedDim）
 * 2. 仅在类型不兼容时降级为 AbsoluteDim
 * 3. UnifiedDim 的 scale/offset 根据新像素值重新计算
 * 4. DimOperator 表达式尝试保留结构，仅更新叶子节点
 */

import type {
  DimNode,
  AreaDef,
  PixelRect,
  DimType,
  DragMode,
  DimEvaluationContext,
} from '@shared/model';
import { evaluateDim, pixelToDim, type DimGenerationStrategy } from '@shared/services/dim-evaluator';

// ─── 公共接口 ────────────────────────────────────────────────────

export interface WritebackResult {
  /** 更新后的 AreaDef */
  newArea: AreaDef;
  /** 被修改的 Dim 字段列表 */
  changedFields: string[];
  /** 描述变更的文本 */
  description: string;
}

/**
 * 根据拖拽结果计算新的 AreaDef
 *
 * @param originalArea  原始 AreaDef
 * @param newPixelRect  拖拽后的像素矩形
 * @param dragMode      拖拽模式
 * @param ctx           Dim 求值上下文
 * @param strategy      Dim 生成策略
 * @returns 回写结果
 */
export function computeWriteback(
  originalArea: AreaDef,
  newPixelRect: PixelRect,
  dragMode: DragMode,
  ctx: DimEvaluationContext,
  strategy: DimGenerationStrategy = 'hybrid',
): WritebackResult {
  const changedFields: string[] = [];
  const newArea: AreaDef = { ...originalArea };

  // 判断原始 Area 的模式
  const usesWidth = originalArea.width !== undefined;
  const usesHeight = originalArea.height !== undefined;
  const usesRight = originalArea.right !== undefined;
  const usesBottom = originalArea.bottom !== undefined;

  // ── 水平方向 ──
  if (dragMode === 'move' || dragMode.includes('l') || dragMode === 'resize-tl' || dragMode === 'resize-bl') {
    // Left 边改变
    newArea.left = writebackDim(
      originalArea.left,
      newPixelRect.x,
      'LeftEdge',
      ctx.parentWidth,
      strategy,
    );
    changedFields.push('left');
  }

  if (usesWidth && (dragMode === 'move' || isWidthChanging(dragMode))) {
    // Width 改变
    newArea.width = writebackDim(
      originalArea.width!,
      newPixelRect.w,
      'Width',
      ctx.parentWidth,
      strategy,
    );
    changedFields.push('width');
  } else if (usesRight && (dragMode === 'move' || isRightChanging(dragMode))) {
    // Right 边改变
    newArea.right = writebackDim(
      originalArea.right!,
      newPixelRect.x + newPixelRect.w,
      'RightEdge',
      ctx.parentWidth,
      strategy,
    );
    changedFields.push('right');
  }

  // ── 垂直方向 ──
  if (dragMode === 'move' || dragMode.includes('t') || dragMode === 'resize-tl' || dragMode === 'resize-tr') {
    // Top 边改变
    newArea.top = writebackDim(
      originalArea.top,
      newPixelRect.y,
      'TopEdge',
      ctx.parentHeight,
      strategy,
    );
    changedFields.push('top');
  }

  if (usesHeight && (dragMode === 'move' || isHeightChanging(dragMode))) {
    // Height 改变
    newArea.height = writebackDim(
      originalArea.height!,
      newPixelRect.h,
      'Height',
      ctx.parentHeight,
      strategy,
    );
    changedFields.push('height');
  } else if (usesBottom && (dragMode === 'move' || isBottomChanging(dragMode))) {
    // Bottom 边改变
    newArea.bottom = writebackDim(
      originalArea.bottom!,
      newPixelRect.y + newPixelRect.h,
      'BottomEdge',
      ctx.parentHeight,
      strategy,
    );
    changedFields.push('bottom');
  }

  const description = buildDescription(dragMode, changedFields, originalArea, newArea);

  return { newArea, changedFields, description };
}

// ─── 核心：单个 Dim 回写 ────────────────────────────────────────

/**
 * 将像素值回写到 DimNode，尽量保留原始 Dim 类型结构
 */
function writebackDim(
  originalDim: DimNode,
  newPixelValue: number,
  dimType: DimType,
  parentSize: number,
  strategy: DimGenerationStrategy,
): DimNode {
  switch (originalDim.type) {
    case 'AbsoluteDim':
      return { type: 'AbsoluteDim', value: Math.round(newPixelValue) };

    case 'UnifiedDim':
      return writebackUnifiedDim(originalDim, newPixelValue, dimType, parentSize);

    case 'ImageDim':
    case 'WidgetDim':
    case 'FontDim':
    case 'PropertyDim':
      // 这些类型无法直接从像素值回写，降级为 pixelToDim
      return pixelToDim(newPixelValue, dimType, parentSize, strategy);

    case 'DimOperator':
      return writebackDimOperator(originalDim, newPixelValue, dimType, parentSize, strategy);
  }
}

/**
 * UnifiedDim 回写：保持 scale/offset 结构，重新计算
 */
function writebackUnifiedDim(
  original: Extract<DimNode, { type: 'UnifiedDim' }>,
  newPixelValue: number,
  dimType: DimType,
  parentSize: number,
): DimNode {
  if (parentSize <= 0) {
    return { type: 'AbsoluteDim', value: Math.round(newPixelValue) };
  }

  // 尝试保持 scale 不变，仅调整 offset
  const newOffset = Math.round(newPixelValue - original.scale * parentSize);

  // 如果 offset 过大（超过 parentSize 的 50%），则重新计算 scale/offset
  if (Math.abs(newOffset) > parentSize * 0.5) {
    const scale = Math.round((newPixelValue / parentSize) * 1000) / 1000;
    const offset = Math.round(newPixelValue - scale * parentSize);
    return { type: 'UnifiedDim', scale, offset, dimType };
  }

  return { type: 'UnifiedDim', scale: original.scale, offset: newOffset, dimType };
}

/**
 * DimOperator 回写：尝试保留运算结构，更新叶子节点
 *
 * 策略：找到最右边的叶子节点并更新它
 */
function writebackDimOperator(
  original: Extract<DimNode, { type: 'DimOperator' }>,
  newPixelValue: number,
  dimType: DimType,
  parentSize: number,
  strategy: DimGenerationStrategy,
): DimNode {
  // 简化策略：将整个表达式替换为 pixelToDim 的结果
  // 复杂的保留结构的回写可以在后续迭代中实现
  return pixelToDim(newPixelValue, dimType, parentSize, strategy);
}

// ─── 辅助判断函数 ────────────────────────────────────────────────

function isWidthChanging(mode: DragMode): boolean {
  return mode === 'resize-tl' || mode === 'resize-tr' ||
         mode === 'resize-bl' || mode === 'resize-br' ||
         mode === 'resize-l' || mode === 'resize-r';
}

function isRightChanging(mode: DragMode): boolean {
  return mode === 'move' || mode === 'resize-tr' || mode === 'resize-br' || mode === 'resize-r';
}

function isHeightChanging(mode: DragMode): boolean {
  return mode === 'resize-tl' || mode === 'resize-tr' ||
         mode === 'resize-bl' || mode === 'resize-br' ||
         mode === 'resize-t' || mode === 'resize-b';
}

function isBottomChanging(mode: DragMode): boolean {
  return mode === 'move' || mode === 'resize-bl' || mode === 'resize-br' || mode === 'resize-b';
}

// ─── 描述生成 ────────────────────────────────────────────────────

function buildDescription(
  mode: DragMode,
  changedFields: string[],
  _originalArea: AreaDef,
  _newArea: AreaDef,
): string {
  const modeLabel: Record<DragMode, string> = {
    'move': 'Move',
    'resize-tl': 'Resize top-left',
    'resize-tr': 'Resize top-right',
    'resize-bl': 'Resize bottom-left',
    'resize-br': 'Resize bottom-right',
    'resize-t': 'Resize top',
    'resize-b': 'Resize bottom',
    'resize-l': 'Resize left',
    'resize-r': 'Resize right',
  };

  return `${modeLabel[mode]}: ${changedFields.join(', ')}`;
}

// ─── 批量回写：将 DragState 转换为 WritebackResult ───────────────

export interface DragEndPayload {
  /** 拖拽结束时的矩形 */
  finalRect: PixelRect;
  /** 拖拽模式 */
  mode: DragMode;
  /** 目标 section 名称 */
  sectionName: string;
  /** 目标组件类型 */
  componentType: 'frame' | 'imagery' | 'text';
  /** 目标组件索引 */
  componentIndex: number;
}

/**
 * 从 DragState 生成完整的回写操作
 */
export function applyDragWriteback(
  widgetLook: import('@shared/model').WidgetLook,
  payload: DragEndPayload,
  ctx: DimEvaluationContext,
  strategy?: DimGenerationStrategy,
): import('@shared/model').WidgetLook {
  const newWl = JSON.parse(JSON.stringify(widgetLook)) as import('@shared/model').WidgetLook;

  // 找到目标 section
  const section = newWl.imagerySections.find(s => s.name === payload.sectionName);
  if (!section) return newWl;

  // 找到目标组件
  let area: AreaDef | undefined;
  switch (payload.componentType) {
    case 'frame':
      area = section.frameComponents[payload.componentIndex]?.area;
      break;
    case 'imagery':
      area = section.imageryComponents[payload.componentIndex]?.area;
      break;
    case 'text':
      area = section.textComponents[payload.componentIndex]?.area;
      break;
  }

  if (!area) return newWl;

  // 计算回写
  const result = computeWriteback(area, payload.finalRect, payload.mode, ctx, strategy);

  // 应用到组件
  switch (payload.componentType) {
    case 'frame':
      section.frameComponents[payload.componentIndex].area = result.newArea;
      break;
    case 'imagery':
      section.imageryComponents[payload.componentIndex].area = result.newArea;
      break;
    case 'text':
      section.textComponents[payload.componentIndex].area = result.newArea;
      break;
  }

  return newWl;
}
