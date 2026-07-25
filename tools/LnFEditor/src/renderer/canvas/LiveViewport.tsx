/**
 * LiveViewport — 实时渲染视口组件
 *
 * 融合 Canvas 渲染区与 StateBar 状态控制栏，
 * 实现"所见即所得"的 CEGUI 控件预览体验。
 * 包含标尺渲染、网格、交互层、选择手柄。
 */

import React from 'react';
import { Canvas } from './Canvas';
import { StateBar } from './StateBar';

export function LiveViewport(): React.ReactElement {
  return (
    <div className="live-viewport">
      <div className="viewport-canvas-area">
        <Canvas />
      </div>
      <StateBar />
    </div>
  );
}
