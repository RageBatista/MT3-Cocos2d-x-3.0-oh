/**
 * dim-evaluator 单元测试
 */
import { describe, it, expect } from 'vitest';
import { evaluateDim, evaluateArea, pixelToDim, formatDimExpr } from './dim-evaluator';
import type { DimEvaluationContext } from '../model';

const mockCtx: DimEvaluationContext = {
  parentWidth: 800,
  parentHeight: 600,
  widgetDimensions: new Map([
    ['__self__', { x: 0, y: 0, w: 800, h: 600 }],
    ['titlebar', { x: 0, y: 0, w: 800, h: 30 }],
  ]),
  imageDimensions: new Map([
    ['TaharezLook/ButtonNormal', { width: 256, height: 64 }],
  ]),
  fontMetrics: new Map([
    ['default', { lineSpacing: 16, baseline: 12, horzExtent: 100 }],
  ]),
};

describe('evaluateDim', () => {
  it('AbsoluteDim returns raw value', () => {
    const result = evaluateDim({ type: 'AbsoluteDim', value: 42 }, mockCtx);
    expect(result).toBe(42);
  });

  it('UnifiedDim calculates scale * base + offset', () => {
    const result = evaluateDim(
      { type: 'UnifiedDim', scale: 0.5, offset: 10, dimType: 'Width' },
      mockCtx,
    );
    expect(result).toBe(0.5 * 800 + 10);
  });

  it('ImageDim returns image dimension', () => {
    const result = evaluateDim(
      { type: 'ImageDim', imageset: 'TaharezLook', image: 'ButtonNormal', dimType: 'Width' },
      mockCtx,
    );
    expect(result).toBe(256);
  });

  it('WidgetDim returns widget dimension', () => {
    const result = evaluateDim(
      { type: 'WidgetDim', widget: 'titlebar', dimType: 'Height' },
      mockCtx,
    );
    expect(result).toBe(30);
  });

  it('WidgetDim without widget uses current widget dimensions', () => {
    const result = evaluateDim(
      { type: 'WidgetDim', dimType: 'BottomEdge' },
      mockCtx,
    );
    expect(result).toBe(600);
  });

  it('FontDim returns font metric + padding', () => {
    const result = evaluateDim(
      { type: 'FontDim', font: 'default', metric: 'LineSpacing', padding: 4 },
      mockCtx,
    );
    expect(result).toBe(20);
  });

  it('DimOperator Add', () => {
    const result = evaluateDim(
      {
        type: 'DimOperator',
        op: 'Add',
        left: { type: 'AbsoluteDim', value: 10 },
        right: { type: 'AbsoluteDim', value: 20 },
      },
      mockCtx,
    );
    expect(result).toBe(30);
  });

  it('DimOperator Subtract', () => {
    const result = evaluateDim(
      {
        type: 'DimOperator',
        op: 'Subtract',
        left: { type: 'UnifiedDim', scale: 1, offset: 0, dimType: 'Width' },
        right: { type: 'AbsoluteDim', value: 20 },
      },
      mockCtx,
    );
    expect(result).toBe(780);
  });

  it('DimOperator Multiply/Divide supports nested expressions', () => {
    const result = evaluateDim(
      {
        type: 'DimOperator',
        op: 'Divide',
        left: {
          type: 'DimOperator',
          op: 'Multiply',
          left: { type: 'AbsoluteDim', value: 12 },
          right: { type: 'AbsoluteDim', value: 5 },
        },
        right: { type: 'AbsoluteDim', value: 3 },
      },
      mockCtx,
    );
    expect(result).toBe(20);
  });

  it('PropertyDim returns 0 (not supported)', () => {
    const result = evaluateDim(
      { type: 'PropertyDim', name: 'SomeProp' },
      mockCtx,
    );
    expect(result).toBe(0);
  });
});

describe('evaluateArea', () => {
  it('evaluates Left+Width mode', () => {
    const area = {
      left: { type: 'AbsoluteDim' as const, value: 10 },
      top: { type: 'AbsoluteDim' as const, value: 20 },
      width: { type: 'AbsoluteDim' as const, value: 100 },
      height: { type: 'AbsoluteDim' as const, value: 50 },
    };
    const result = evaluateArea(area, mockCtx);
    expect(result.x).toBe(10);
    expect(result.y).toBe(20);
    expect(result.w).toBe(100);
    expect(result.h).toBe(50);
  });

  it('evaluates Left+Right mode', () => {
    const area = {
      left: { type: 'AbsoluteDim' as const, value: 10 },
      top: { type: 'AbsoluteDim' as const, value: 20 },
      right: { type: 'AbsoluteDim' as const, value: 110 },
      bottom: { type: 'AbsoluteDim' as const, value: 70 },
    };
    const result = evaluateArea(area, mockCtx);
    expect(result.x).toBe(10);
    expect(result.y).toBe(20);
    expect(result.w).toBe(100);
    expect(result.h).toBe(50);
  });
});

describe('pixelToDim', () => {
  it('absolute strategy', () => {
    const result = pixelToDim(100, 'Width', 800, 'absolute');
    expect(result).toEqual({ type: 'AbsoluteDim', value: 100 });
  });

  it('unified-relative strategy', () => {
    const result = pixelToDim(400, 'Width', 800, 'unified-relative');
    expect(result.type).toBe('UnifiedDim');
    if (result.type === 'UnifiedDim') {
      expect(result.scale).toBeCloseTo(0.5, 3);
      expect(result.offset).toBe(0);
    }
  });

  it('hybrid strategy', () => {
    const result = pixelToDim(400, 'Width', 800, 'hybrid');
    expect(result.type).toBe('UnifiedDim');
    if (result.type === 'UnifiedDim') {
      expect(result.scale).toBeCloseTo(0.5, 2);
    }
  });
});

describe('formatDimExpr', () => {
  it('formats AbsoluteDim', () => {
    expect(formatDimExpr({ type: 'AbsoluteDim', value: 42 })).toBe('42');
  });

  it('formats UnifiedDim', () => {
    const result = formatDimExpr({ type: 'UnifiedDim', scale: 0.5, offset: 10, dimType: 'Width' });
    expect(result).toContain('0.5');
    expect(result).toContain('10');
    expect(result).toContain('Width');
  });

  it('formats DimOperator', () => {
    const result = formatDimExpr({
      type: 'DimOperator',
      op: 'Add',
      left: { type: 'AbsoluteDim', value: 10 },
      right: { type: 'AbsoluteDim', value: 20 },
    });
    expect(result).toContain('Add');
    expect(result).toContain('10');
    expect(result).toContain('20');
  });
});
