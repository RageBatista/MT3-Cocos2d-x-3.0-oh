/**
 * DimEditor — Dim 表达式可视化编辑器
 *
 * 提供对 DimNode AST 的可视化编辑能力：
 * - AbsoluteDim: 直接数值输入
 * - UnifiedDim: scale + offset + dimType 三元组
 * - ImageDim: imageset/image 选择 + dimType
 * - WidgetDim: widget 名称 + dimType
 * - FontDim: font + metric + padding
 * - PropertyDim: 属性名输入
 * - DimOperator: 递归左右子表达式 + 运算符选择
 *
 * 支持类型切换、嵌套编辑、AST 预览。
 */

import React, { useCallback, useMemo, useState } from 'react';
import type { DimNode, DimType, OperatorType, FontMetricType } from '@shared/model';
import { formatDimExpr } from '@shared/services/dim-evaluator';
import { useTranslation } from '../services/i18n';

// ─── Dim 类型选项 ───────────────────────────────────────────────
const DIM_TYPES: DimType[] = [
  'LeftEdge', 'TopEdge', 'RightEdge', 'BottomEdge',
  'Width', 'Height', 'XPosition', 'YPosition',
];

const OPERATOR_TYPES: OperatorType[] = ['Add', 'Subtract', 'Multiply', 'Divide'];

const FONT_METRICS: FontMetricType[] = ['LineSpacing', 'Baseline', 'HorzExtent'];

const DIM_NODE_TYPES = [
  'AbsoluteDim', 'UnifiedDim', 'ImageDim', 'WidgetDim',
  'FontDim', 'PropertyDim', 'DimOperator',
] as const;

// ─── Props ──────────────────────────────────────────────────────
interface DimEditorProps {
  /** 当前 Dim 表达式 */
  value: DimNode;
  /** 变更回调 */
  onChange: (newDim: DimNode) => void;
  /** 可选标签（如 "Left", "Top", "Width"） */
  label?: string;
  /** 是否禁用 */
  disabled?: boolean;
  /** 父容器尺寸（用于 UnifiedDim 预览） */
  parentSize?: number;
}

// ─── 主组件 ──────────────────────────────────────────────────────
export function DimEditor({
  value,
  onChange,
  label,
  disabled = false,
  parentSize,
}: DimEditorProps): React.ReactElement {
  const { t } = useTranslation();
  const [expanded, setExpanded] = useState(false);

  const exprPreview = useMemo(() => formatDimExpr(value), [value]);

  return (
    <div className="dim-editor">
      <div className="dim-editor-header" onClick={() => !disabled && setExpanded(!expanded)}>
        <span className="dim-collapse-icon">{expanded ? '▼' : '▶'}</span>
        {label && <span className="dim-label">{label}</span>}
        <span className="dim-expr-preview" title={exprPreview}>
          {exprPreview.length > 40 ? exprPreview.slice(0, 37) + '...' : exprPreview}
        </span>
        {!disabled && (
          <span className="dim-type-badge">{value.type}</span>
        )}
      </div>

      {expanded && !disabled && (
        <div className="dim-editor-body">
          <DimNodeTypeSwitcher value={value} onChange={onChange} parentSize={parentSize} />
        </div>
      )}
    </div>
  );
}

// ─── 类型切换器 ──────────────────────────────────────────────────
function DimNodeTypeSwitcher({
  value,
  onChange,
  parentSize,
}: {
  value: DimNode;
  onChange: (dim: DimNode) => void;
  parentSize?: number;
}): React.ReactElement {
  const { t } = useTranslation();
  const [switchingType, setSwitchingType] = useState<DimNode['type'] | null>(null);

  const handleTypeSwitch = useCallback((newType: typeof DIM_NODE_TYPES[number]) => {
    if (newType === value.type) {
      setSwitchingType(null);
      return;
    }

    let newDim: DimNode;
    switch (newType) {
      case 'AbsoluteDim':
        newDim = { type: 'AbsoluteDim', value: 0 };
        break;
      case 'UnifiedDim':
        newDim = { type: 'UnifiedDim', scale: 0, offset: 0, dimType: 'LeftEdge' };
        break;
      case 'ImageDim':
        newDim = { type: 'ImageDim', imageset: '', image: '', dimType: 'Width' };
        break;
      case 'WidgetDim':
        newDim = { type: 'WidgetDim', dimType: 'Width' };
        break;
      case 'FontDim':
        newDim = { type: 'FontDim', metric: 'LineSpacing' };
        break;
      case 'PropertyDim':
        newDim = { type: 'PropertyDim', name: '' };
        break;
      case 'DimOperator':
        newDim = {
          type: 'DimOperator',
          op: 'Add',
          left: { type: 'AbsoluteDim', value: 0 },
          right: { type: 'AbsoluteDim', value: 0 },
        };
        break;
      default:
        return;
    }
    onChange(newDim);
    setSwitchingType(null);
  }, [value.type, onChange]);

  return (
    <div className="dim-type-switcher">
      {/* 类型切换按钮 */}
      <div className="dim-type-buttons">
        {DIM_NODE_TYPES.map(dt => (
          <button
            key={dt}
            className={`dim-type-btn ${dt === value.type ? 'active' : ''}`}
            onClick={() => handleTypeSwitch(dt)}
            title={t('dim.switchTo', { type: dt })}
          >
            {dt.replace('Dim', '')}
          </button>
        ))}
      </div>

      {/* 类型特定编辑器 */}
      <div className="dim-type-editor">
        {value.type === 'AbsoluteDim' && (
          <AbsoluteDimEditor value={value} onChange={onChange} />
        )}
        {value.type === 'UnifiedDim' && (
          <UnifiedDimEditor value={value} onChange={onChange} parentSize={parentSize} />
        )}
        {value.type === 'ImageDim' && (
          <ImageDimEditor value={value} onChange={onChange} />
        )}
        {value.type === 'WidgetDim' && (
          <WidgetDimEditor value={value} onChange={onChange} />
        )}
        {value.type === 'FontDim' && (
          <FontDimEditor value={value} onChange={onChange} />
        )}
        {value.type === 'PropertyDim' && (
          <PropertyDimEditor value={value} onChange={onChange} />
        )}
        {value.type === 'DimOperator' && (
          <DimOperatorEditor value={value} onChange={onChange} parentSize={parentSize} />
        )}
      </div>
    </div>
  );
}

// ─── AbsoluteDim 编辑器 ──────────────────────────────────────────
function AbsoluteDimEditor({
  value,
  onChange,
}: {
  value: Extract<DimNode, { type: 'AbsoluteDim' }>;
  onChange: (dim: DimNode) => void;
}): React.ReactElement {
  const { t } = useTranslation();
  return (
    <div className="dim-fields">
      <div className="dim-field">
        <label>{t('dim.value')}</label>
        <input
          type="number"
          value={value.value}
          onChange={e => onChange({ ...value, value: Number(e.target.value) })}
          step={1}
        />
      </div>
    </div>
  );
}

// ─── UnifiedDim 编辑器 ──────────────────────────────────────────
function UnifiedDimEditor({
  value,
  onChange,
  parentSize,
}: {
  value: Extract<DimNode, { type: 'UnifiedDim' }>;
  onChange: (dim: DimNode) => void;
  parentSize?: number;
}): React.ReactElement {
  const { t } = useTranslation();
  const computedValue = parentSize !== undefined
    ? value.scale * parentSize + value.offset
    : null;

  return (
    <div className="dim-fields">
      <div className="dim-field">
        <label>{t('dim.scale')}</label>
        <input
          type="number"
          value={value.scale}
          onChange={e => onChange({ ...value, scale: Number(e.target.value) })}
          step={0.01}
        />
      </div>
      <div className="dim-field">
        <label>{t('dim.offset')}</label>
        <input
          type="number"
          value={value.offset}
          onChange={e => onChange({ ...value, offset: Number(e.target.value) })}
          step={1}
        />
      </div>
      <div className="dim-field">
        <label>{t('dim.dimType')}</label>
        <select
          value={value.dimType}
          onChange={e => onChange({ ...value, dimType: e.target.value as DimType })}
        >
          {DIM_TYPES.map(dt => (
            <option key={dt} value={dt}>{dt}</option>
          ))}
        </select>
      </div>
      {computedValue !== null && (
        <div className="dim-computed">
          ≈ {Math.round(computedValue)}px (parent: {parentSize}px)
        </div>
      )}
    </div>
  );
}

// ─── ImageDim 编辑器 ────────────────────────────────────────────
function ImageDimEditor({
  value,
  onChange,
}: {
  value: Extract<DimNode, { type: 'ImageDim' }>;
  onChange: (dim: DimNode) => void;
}): React.ReactElement {
  const { t } = useTranslation();
  return (
    <div className="dim-fields">
      <div className="dim-field">
        <label>{t('dim.imageset')}</label>
        <input
          type="text"
          value={value.imageset}
          onChange={e => onChange({ ...value, imageset: e.target.value })}
          placeholder={t('dim.placeholderImageset')}
        />
      </div>
      <div className="dim-field">
        <label>{t('dim.image')}</label>
        <input
          type="text"
          value={value.image}
          onChange={e => onChange({ ...value, image: e.target.value })}
          placeholder={t('dim.placeholderImage')}
        />
      </div>
      <div className="dim-field">
        <label>{t('dim.dimType')}</label>
        <select
          value={value.dimType}
          onChange={e => onChange({ ...value, dimType: e.target.value as DimType })}
        >
          {DIM_TYPES.map(dt => (
            <option key={dt} value={dt}>{dt}</option>
          ))}
        </select>
      </div>
    </div>
  );
}

// ─── WidgetDim 编辑器 ────────────────────────────────────────────
function WidgetDimEditor({
  value,
  onChange,
}: {
  value: Extract<DimNode, { type: 'WidgetDim' }>;
  onChange: (dim: DimNode) => void;
}): React.ReactElement {
  const { t } = useTranslation();
  return (
    <div className="dim-fields">
      <div className="dim-field">
        <label>{t('dim.widget')}</label>
        <input
          type="text"
          value={value.widget || ''}
          onChange={e => {
            const newWidget = e.target.value || undefined;
            onChange({ ...value, widget: newWidget });
          }}
          placeholder={t('dim.selfEmpty')}
        />
      </div>
      <div className="dim-field">
        <label>{t('dim.dimType')}</label>
        <select
          value={value.dimType}
          onChange={e => onChange({ ...value, dimType: e.target.value as DimType })}
        >
          {DIM_TYPES.map(dt => (
            <option key={dt} value={dt}>{dt}</option>
          ))}
        </select>
      </div>
    </div>
  );
}

// ─── FontDim 编辑器 ──────────────────────────────────────────────
function FontDimEditor({
  value,
  onChange,
}: {
  value: Extract<DimNode, { type: 'FontDim' }>;
  onChange: (dim: DimNode) => void;
}): React.ReactElement {
  const { t } = useTranslation();
  return (
    <div className="dim-fields">
      <div className="dim-field">
        <label>{t('dim.fontDim')}</label>
        <input
          type="text"
          value={value.font || ''}
          onChange={e => {
            const newFont = e.target.value || undefined;
            onChange({ ...value, font: newFont });
          }}
          placeholder={t('dim.placeholderFont')}
        />
      </div>
      <div className="dim-field">
        <label>{t('dim.metric')}</label>
        <select
          value={value.metric}
          onChange={e => onChange({ ...value, metric: e.target.value as FontMetricType })}
        >
          {FONT_METRICS.map(fm => (
            <option key={fm} value={fm}>{fm}</option>
          ))}
        </select>
      </div>
      <div className="dim-field">
        <label>{t('dim.padding')}</label>
        <input
          type="number"
          value={value.padding || 0}
          onChange={e => onChange({ ...value, padding: Number(e.target.value) })}
          step={1}
        />
      </div>
    </div>
  );
}

// ─── PropertyDim 编辑器 ──────────────────────────────────────────
function PropertyDimEditor({
  value,
  onChange,
}: {
  value: Extract<DimNode, { type: 'PropertyDim' }>;
  onChange: (dim: DimNode) => void;
}): React.ReactElement {
  const { t } = useTranslation();
  return (
    <div className="dim-fields">
      <div className="dim-field">
        <label>{t('dim.propertyName')}</label>
        <input
          type="text"
          value={value.name}
          onChange={e => onChange({ ...value, name: e.target.value })}
          placeholder={t('dim.placeholderProperty')}
        />
      </div>
    </div>
  );
}

// ─── DimOperator 编辑器 ──────────────────────────────────────────
function DimOperatorEditor({
  value,
  onChange,
  parentSize,
}: {
  value: Extract<DimNode, { type: 'DimOperator' }>;
  onChange: (dim: DimNode) => void;
  parentSize?: number;
}): React.ReactElement {
  const { t } = useTranslation();
  return (
    <div className="dim-operator-editor">
      <div className="dim-field">
        <label>{t('dim.operatorLabel')}</label>
        <select
          value={value.op}
          onChange={e => onChange({ ...value, op: e.target.value as OperatorType })}
        >
          {OPERATOR_TYPES.map(op => (
            <option key={op} value={op}>{op}</option>
          ))}
        </select>
      </div>

      <div className="dim-operator-children">
        <div className="dim-operator-left">
          <div className="dim-operator-label">{t('dim.left')}:</div>
          <DimEditor
            value={value.left}
            onChange={newLeft => onChange({ ...value, left: newLeft })}
            parentSize={parentSize}
          />
        </div>
        <div className="dim-operator-right">
          <div className="dim-operator-label">{t('dim.right')}:</div>
          <DimEditor
            value={value.right}
            onChange={newRight => onChange({ ...value, right: newRight })}
            parentSize={parentSize}
          />
        </div>
      </div>
    </div>
  );
}

// ─── AreaDef 编辑器 — 编辑完整的 Area 定义 ──────────────────────
interface AreaEditorProps {
  area: import('@shared/model').AreaDef;
  onChange: (newArea: import('@shared/model').AreaDef) => void;
  parentWidth?: number;
  parentHeight?: number;
  disabled?: boolean;
}

export function AreaEditor({
  area,
  onChange,
  parentWidth,
  parentHeight,
  disabled = false,
}: AreaEditorProps): React.ReactElement {
  const { t } = useTranslation();
  const handleDimChange = useCallback(
    (field: keyof import('@shared/model').AreaDef, newDim: DimNode) => {
      onChange({ ...area, [field]: newDim });
    },
    [area, onChange],
  );

  // 判断水平方向模式: LeftEdge+Width 或 LeftEdge+RightEdge
  const hasWidth = area.width !== undefined;
  const hasRight = area.right !== undefined;
  const hasHeight = area.height !== undefined;
  const hasBottom = area.bottom !== undefined;

  return (
    <div className="area-editor">
      <div className="area-editor-section">
        <span className="area-section-title">{t('dim.position')}</span>
        <DimEditor
          label="Left"
          value={area.left}
          onChange={d => handleDimChange('left', d)}
          disabled={disabled}
          parentSize={parentWidth}
        />
        <DimEditor
          label="Top"
          value={area.top}
          onChange={d => handleDimChange('top', d)}
          disabled={disabled}
          parentSize={parentHeight}
        />
      </div>

      <div className="area-editor-section">
        <span className="area-section-title">{t('dim.horizontalSize')}</span>
        {hasWidth && (
          <DimEditor
            label="Width"
            value={area.width!}
            onChange={d => handleDimChange('width', d)}
            disabled={disabled}
            parentSize={parentWidth}
          />
        )}
        {hasRight && (
          <DimEditor
            label="Right"
            value={area.right!}
            onChange={d => handleDimChange('right', d)}
            disabled={disabled}
            parentSize={parentWidth}
          />
        )}
        {!hasWidth && !hasRight && (
          <div className="dim-field-empty">{t('dim.noHorizontalSize')}</div>
        )}
      </div>

      <div className="area-editor-section">
        <span className="area-section-title">{t('dim.verticalSize')}</span>
        {hasHeight && (
          <DimEditor
            label="Height"
            value={area.height!}
            onChange={d => handleDimChange('height', d)}
            disabled={disabled}
            parentSize={parentHeight}
          />
        )}
        {hasBottom && (
          <DimEditor
            label="Bottom"
            value={area.bottom!}
            onChange={d => handleDimChange('bottom', d)}
            disabled={disabled}
            parentSize={parentHeight}
          />
        )}
        {!hasHeight && !hasBottom && (
          <div className="dim-field-empty">{t('dim.noVerticalSize')}</div>
        )}
      </div>
    </div>
  );
}
