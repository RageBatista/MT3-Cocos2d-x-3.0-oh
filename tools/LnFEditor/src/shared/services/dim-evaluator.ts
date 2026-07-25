import type { DimNode, AreaDef, DimEvaluationContext, PixelRect, DimType } from '@shared/model';

/** 递归求值 Dim 表达式树 */
export function evaluateDim(node: DimNode, ctx: DimEvaluationContext): number {
  switch (node.type) {
    case 'AbsoluteDim':
      return node.value;

    case 'UnifiedDim': {
      const base = resolveDimBase(node.dimType, ctx);
      return node.scale * base + node.offset;
    }

    case 'ImageDim': {
      const key = `${node.imageset}/${node.image}`;
      const dim = ctx.imageDimensions.get(key);
      if (!dim) return 0;
      return resolveDimensionValue(node.dimType, dim.width, dim.height);
    }

    case 'WidgetDim': {
      const rect = node.widget
        ? ctx.widgetDimensions.get(node.widget)
        : ctx.widgetDimensions.get('__self__') || {
            x: 0,
            y: 0,
            w: ctx.parentWidth,
            h: ctx.parentHeight,
          };
      if (!rect) return 0;
      return resolveRectDimValue(node.dimType, rect);
    }

    case 'FontDim': {
      const fontKey = node.font || '__default__';
      const metrics = ctx.fontMetrics.get(fontKey);
      if (!metrics) return 0;
      let value = 0;
      switch (node.metric) {
        case 'LineSpacing': value = metrics.lineSpacing; break;
        case 'Baseline': value = metrics.baseline; break;
        case 'HorzExtent': value = metrics.horzExtent; break;
      }
      return value + (node.padding || 0);
    }

    case 'PropertyDim':
      return 0;

    case 'DimOperator': {
      const left = evaluateDim(node.left, ctx);
      const right = evaluateDim(node.right, ctx);
      switch (node.op) {
        case 'Add': return left + right;
        case 'Subtract': return left - right;
        case 'Multiply': return left * right;
        case 'Divide': return right !== 0 ? left / right : 0;
      }
    }
    default: {
      const _exhaustive: never = node;
      return 0;
    }
  }
}

/** 根据 DimType 获取基础尺寸（宽或高） */
function resolveDimBase(dimType: DimType, ctx: DimEvaluationContext): number {
  switch (dimType) {
    case 'LeftEdge':
    case 'RightEdge':
    case 'Width':
    case 'XPosition':
      return ctx.parentWidth;
    case 'TopEdge':
    case 'BottomEdge':
    case 'Height':
    case 'YPosition':
      return ctx.parentHeight;
    default:
      return ctx.parentWidth;
  }
}

/** 根据宽高和 DimType 返回对应值 */
function resolveDimensionValue(dimType: DimType, width: number, height: number): number {
  switch (dimType) {
    case 'Width':
    case 'LeftEdge':
    case 'RightEdge':
    case 'XPosition':
      return width;
    case 'Height':
    case 'TopEdge':
    case 'BottomEdge':
    case 'YPosition':
      return height;
    default:
      return width;
  }
}

/** 根据 DimType 从 PixelRect 中提取值 */
function resolveRectDimValue(dimType: DimType, rect: PixelRect): number {
  switch (dimType) {
    case 'LeftEdge':
    case 'XPosition':
      return rect.x;
    case 'TopEdge':
    case 'YPosition':
      return rect.y;
    case 'RightEdge':
      return rect.x + rect.w;
    case 'BottomEdge':
      return rect.y + rect.h;
    case 'Width':
      return rect.w;
    case 'Height':
      return rect.h;
    default:
      return rect.w;
  }
}

/** 求值 Area 定义，返回像素矩形 */
export function evaluateArea(area: AreaDef, ctx: DimEvaluationContext): PixelRect {
  const left = evaluateDim(area.left, ctx);
  const top = evaluateDim(area.top, ctx);

  let right: number;
  let bottom: number;

  if (area.width !== undefined) {
    right = left + evaluateDim(area.width, ctx);
  } else if (area.right !== undefined) {
    right = evaluateDim(area.right, ctx);
  } else {
    right = left;
  }

  if (area.height !== undefined) {
    bottom = top + evaluateDim(area.height, ctx);
  } else if (area.bottom !== undefined) {
    bottom = evaluateDim(area.bottom, ctx);
  } else {
    bottom = top;
  }

  return {
    x: Math.round(left),
    y: Math.round(top),
    w: Math.round(Math.max(0, right - left)),
    h: Math.round(Math.max(0, bottom - top)),
  };
}

/** 像素值 → Dim 表达式生成策略 */
export type DimGenerationStrategy = 'absolute' | 'unified-relative' | 'unified-offset' | 'hybrid';

/** 像素值 → Dim 表达式 */
export function pixelToDim(
  pixelValue: number,
  dimType: DimType,
  parentSize: number,
  strategy: DimGenerationStrategy = 'hybrid'
): DimNode {
  switch (strategy) {
    case 'absolute':
      return { type: 'AbsoluteDim', value: Math.round(pixelValue) };

    case 'unified-relative':
      return {
        type: 'UnifiedDim',
        scale: parentSize > 0 ? Math.round((pixelValue / parentSize) * 10000) / 10000 : 0,
        offset: 0,
        dimType,
      };

    case 'unified-offset':
      return {
        type: 'UnifiedDim',
        scale: 0,
        offset: Math.round(pixelValue),
        dimType,
      };

    case 'hybrid': {
      if (parentSize <= 0) return { type: 'AbsoluteDim', value: Math.round(pixelValue) };
      const scale = Math.round((pixelValue / parentSize) * 1000) / 1000;
      const offset = Math.round(pixelValue - scale * parentSize);
      return { type: 'UnifiedDim', scale, offset, dimType };
    }
    default: {
      const _exhaustive: never = strategy;
      return { type: 'AbsoluteDim', value: Math.round(pixelValue) };
    }
  }
}

/** 将 Dim 表达式格式化为可读字符串 */
export function formatDimExpr(node: DimNode): string {
  switch (node.type) {
    case 'AbsoluteDim':
      return `${node.value}`;
    case 'UnifiedDim':
      return `{{${node.scale},${node.offset},${node.dimType}}}`;
    case 'ImageDim':
      return `ImageDim(${node.imageset}/${node.image}, ${node.dimType})`;
    case 'WidgetDim':
      return `WidgetDim(${node.widget || 'self'}, ${node.dimType})`;
    case 'FontDim':
      return `FontDim(${node.font || 'default'}, ${node.metric})`;
    case 'PropertyDim':
      return `PropertyDim(${node.name})`;
    case 'DimOperator':
      return `(${formatDimExpr(node.left)} ${node.op} ${formatDimExpr(node.right)})`;
    default: {
      const _exhaustive: never = node;
      return '';
    }
  }
}
