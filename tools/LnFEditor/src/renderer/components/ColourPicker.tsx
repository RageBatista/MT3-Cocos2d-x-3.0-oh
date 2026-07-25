/**
 * Colour 选择器组件 — ARGB 输入 + 可视化预览
 *
 * CEGUI 使用 ARGB 格式（如 FFFFFFFF = 不透明白色），
 * 本组件提供 ARGB 各通道输入和颜色预览。
 */

import React, { useCallback, useState } from 'react';

export interface ColourValue {
  a: number; // 0-255
  r: number; // 0-255
  g: number; // 0-255
  b: number; // 0-255
}

/** 解析 ARGB 十六进制字符串（如 "FFFFFFFF"）为 ColourValue */
export function parseARGB(argb: string): ColourValue {
  const clean = argb.replace(/^#/, '');
  if (clean.length < 8) {
    return { a: 255, r: 255, g: 255, b: 255 };
  }
  return {
    a: parseInt(clean.slice(0, 2), 16),
    r: parseInt(clean.slice(2, 4), 16),
    g: parseInt(clean.slice(4, 6), 16),
    b: parseInt(clean.slice(6, 8), 16),
  };
}

/** 将 ColourValue 转换为 ARGB 十六进制字符串 */
export function toARGBString(c: ColourValue): string {
  const hex = (v: number) => Math.max(0, Math.min(255, Math.round(v))).toString(16).padStart(2, '0').toUpperCase();
  return `${hex(c.a)}${hex(c.r)}${hex(c.g)}${hex(c.b)}`;
}

/** 将 ColourValue 转换为 CSS rgba() */
export function toCSSRGBA(c: ColourValue): string {
  return `rgba(${c.r}, ${c.g}, ${c.b}, ${(c.a / 255).toFixed(2)})`;
}

interface ColourPickerProps {
  value: string; // ARGB hex string like "FFFFFFFF"
  onChange: (newValue: string) => void;
  label?: string;
}

export function ColourPicker({ value, onChange, label }: ColourPickerProps): React.ReactElement {
  const colour = parseARGB(value);
  const [expanded, setExpanded] = useState(false);

  const handleChannelChange = useCallback((channel: keyof ColourValue, newVal: number) => {
    const updated = { ...colour, [channel]: newVal };
    onChange(toARGBString(updated));
  }, [colour, onChange]);

  const handleHexInput = useCallback((hex: string) => {
    const clean = hex.replace(/[^0-9A-Fa-f]/g, '').slice(0, 8);
    if (clean.length === 8) {
      onChange(clean.toUpperCase());
    }
  }, [onChange]);

  const cssColour = toCSSRGBA(colour);

  return (
    <div className="colour-picker">
      {label && <span className="property-label">{label}</span>}

      <div className="colour-preview-row" onClick={() => setExpanded(!expanded)}>
        <div
          className="colour-swatch"
          style={{
            backgroundColor: cssColour,
            border: '1px solid rgba(128,128,128,0.3)',
            width: 24,
            height: 16,
            borderRadius: 2,
          }}
        />
        <span className="colour-hex">{value}</span>
        <span className="collapse-icon">{expanded ? '▼' : '▶'}</span>
      </div>

      {expanded && (
        <div className="colour-channels">
          <div className="colour-channel">
            <label>A</label>
            <input
              type="range" min={0} max={255} value={colour.a}
              onChange={e => handleChannelChange('a', parseInt(e.target.value, 10))}
            />
            <input
              type="number" min={0} max={255} value={colour.a}
              onChange={e => handleChannelChange('a', parseInt(e.target.value, 10) || 0)}
              className="channel-input"
            />
          </div>
          <div className="colour-channel">
            <label>R</label>
            <input
              type="range" min={0} max={255} value={colour.r}
              onChange={e => handleChannelChange('r', parseInt(e.target.value, 10))}
              style={{ accentColor: '#f38ba8' }}
            />
            <input
              type="number" min={0} max={255} value={colour.r}
              onChange={e => handleChannelChange('r', parseInt(e.target.value, 10) || 0)}
              className="channel-input"
            />
          </div>
          <div className="colour-channel">
            <label>G</label>
            <input
              type="range" min={0} max={255} value={colour.g}
              onChange={e => handleChannelChange('g', parseInt(e.target.value, 10))}
              style={{ accentColor: '#a6e3a1' }}
            />
            <input
              type="number" min={0} max={255} value={colour.g}
              onChange={e => handleChannelChange('g', parseInt(e.target.value, 10) || 0)}
              className="channel-input"
            />
          </div>
          <div className="colour-channel">
            <label>B</label>
            <input
              type="range" min={0} max={255} value={colour.b}
              onChange={e => handleChannelChange('b', parseInt(e.target.value, 10))}
              style={{ accentColor: '#89b4fa' }}
            />
            <input
              type="number" min={0} max={255} value={colour.b}
              onChange={e => handleChannelChange('b', parseInt(e.target.value, 10) || 0)}
              className="channel-input"
            />
          </div>

          <div className="colour-hex-input">
            <label>ARGB:</label>
            <input
              type="text"
              value={value}
              onChange={e => handleHexInput(e.target.value)}
              className="hex-input"
              maxLength={8}
            />
          </div>

          {/* 预设颜色 */}
          <div className="colour-presets">
            {COLOUR_PRESETS.map(preset => (
              <button
                key={preset.value}
                className="colour-preset-btn"
                title={preset.name}
                onClick={() => onChange(preset.value)}
                style={{ backgroundColor: preset.css }}
              />
            ))}
          </div>
        </div>
      )}
    </div>
  );
}

/** 常用颜色预设 */
const COLOUR_PRESETS = [
  { name: 'White', value: 'FFFFFFFF', css: 'rgba(255,255,255,1)' },
  { name: 'Black', value: 'FF000000', css: 'rgba(0,0,0,1)' },
  { name: 'Red', value: 'FFFF0000', css: 'rgba(255,0,0,1)' },
  { name: 'Green', value: 'FF00FF00', css: 'rgba(0,255,0,1)' },
  { name: 'Blue', value: 'FF0000FF', css: 'rgba(0,0,255,1)' },
  { name: 'Yellow', value: 'FFFFFF00', css: 'rgba(255,255,0,1)' },
  { name: 'Transparent', value: '00000000', css: 'rgba(0,0,0,0)' },
  { name: 'Semi-transparent White', value: '80FFFFFF', css: 'rgba(255,255,255,0.5)' },
];
