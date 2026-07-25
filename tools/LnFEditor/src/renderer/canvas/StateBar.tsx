/**
 * StateBar — 实时渲染视口底部的状态切换栏
 *
 * 紧贴画布渲染区，实现状态切换与渲染结果的"所见即所得"联动。
 * 支持状态勾选、父控件尺寸调整、自动循环播放。
 */

import React, { useCallback, useEffect, useRef, useState } from 'react';
import { useEditorStore } from '../stores/editor-store';
import { BUTTON_STATES, FRAME_WINDOW_STATES } from '@shared/constants';
import { useTranslation } from '../services/i18n';

export function StateBar(): React.ReactElement {
  const { t } = useTranslation();
  const activeStates = useEditorStore(s => s.preview.activeStates);
  const setActiveStates = useEditorStore(s => s.setActiveStates);
  const parentWidth = useEditorStore(s => s.preview.parentWidth);
  const parentHeight = useEditorStore(s => s.preview.parentHeight);
  const setParentSize = useEditorStore(s => s.setParentSize);

  const [autoCycling, setAutoCycling] = useState(false);
  const cycleRef = useRef<ReturnType<typeof setInterval> | null>(null);
  const cycleIndexRef = useRef(0);

  const toggleState = useCallback((state: string) => {
    const idx = activeStates.indexOf(state);
    if (idx >= 0) {
      setActiveStates(activeStates.filter(s => s !== state));
    } else {
      setActiveStates([...activeStates, state]);
    }
  }, [activeStates, setActiveStates]);

  const handleAutoCycle = useCallback(() => {
    setAutoCycling(prev => !prev);
  }, []);

  useEffect(() => {
    if (autoCycling) {
      const allStates = [...BUTTON_STATES];
      cycleIndexRef.current = 0;
      setActiveStates([allStates[0]]);

      cycleRef.current = setInterval(() => {
        cycleIndexRef.current = (cycleIndexRef.current + 1) % allStates.length;
        setActiveStates([allStates[cycleIndexRef.current]]);
      }, 800);
    } else {
      if (cycleRef.current) {
        clearInterval(cycleRef.current);
        cycleRef.current = null;
      }
    }

    return () => {
      if (cycleRef.current) {
        clearInterval(cycleRef.current);
        cycleRef.current = null;
      }
    };
  }, [autoCycling, setActiveStates]);

  return (
    <div className="state-bar">
      <div className="state-bar-left">
        <span className="state-bar-label">{t('panel.buttonStates')}:</span>
        {BUTTON_STATES.map(state => (
          <button
            key={state}
            className={`state-toggle ${activeStates.includes(state) ? 'active' : ''}`}
            onClick={() => toggleState(state)}
            title={state}
          >
            {state}
          </button>
        ))}
      </div>
      <div className="state-bar-center">
        <span className="state-bar-label">{t('panel.windowStates')}:</span>
        {FRAME_WINDOW_STATES.slice(0, 4).map(state => (
          <button
            key={state}
            className={`state-toggle state-toggle-sm ${activeStates.includes(state) ? 'active' : ''}`}
            onClick={() => toggleState(state)}
            title={state}
          >
            {abbreviateState(state)}
          </button>
        ))}
      </div>
      <div className="state-bar-right">
        <label className="size-input-group">
          <span className="state-bar-label">W:</span>
          <input
            type="number"
            className="size-input"
            value={parentWidth}
            onChange={e => setParentSize(parseInt(e.target.value, 10) || 800, parentHeight)}
          />
        </label>
        <span className="size-separator">×</span>
        <label className="size-input-group">
          <span className="state-bar-label">H:</span>
          <input
            type="number"
            className="size-input"
            value={parentHeight}
            onChange={e => setParentSize(parentWidth, parseInt(e.target.value, 10) || 600)}
          />
        </label>
        <button
          className={`auto-cycle-btn ${autoCycling ? 'active' : ''}`}
          onClick={handleAutoCycle}
          title={autoCycling ? 'Stop auto-cycle' : 'Auto-cycle states'}
        >
          ▶
        </button>
      </div>
    </div>
  );
}

/** 缩写窗口状态名 */
function abbreviateState(state: string): string {
  return state
    .replace(/Active/g, 'A')
    .replace(/Inactive/g, 'I')
    .replace(/Disabled/g, 'D')
    .replace(/WithTitle/g, 'T')
    .replace(/NoTitle/g, 'NT')
    .replace(/WithFrame/g, 'F')
    .replace(/NoFrame/g, 'NF');
}
