import React, { useCallback, useEffect, useRef, useState } from 'react';
import { parseComponentNodeId, type CanvasViewport, type DimEvaluationContext, type PixelRect, type DragMode, type WidgetLook, type StateImagery } from '@shared/model';
import { evaluateArea } from '@shared/services/dim-evaluator';
import { useEditorStore } from '../stores/editor-store';
import { renderWidgetLook, renderSelectionHandles } from './renderer';
import { hitTestDragMode, applyDrag, zoomViewport } from './interaction';
import { textureCache } from '../services/texture-cache';
import { applyDragWriteback, type DragEndPayload } from '../services/dim-writeback';
import { resolveImagerySection } from '../services/widgetlook-lookup';

interface DragRuntimeState {
  active: boolean;
  mode: DragMode | null;
  startX: number;
  startY: number;
  startArea: PixelRect | null;
  currentArea: PixelRect | null;
  lookName: string | null;
  sectionName: string | null;
  componentType: 'frame' | 'imagery' | 'text' | null;
  componentIndex: number;
}

interface RenderableComponentRef {
  id: string;
  area: PixelRect;
  lookName: string | null;
  sectionName: string;
  componentType: 'frame' | 'imagery' | 'text';
  componentIndex: number;
}

const EMPTY_DRAG_STATE: DragRuntimeState = {
  active: false,
  mode: null,
  startX: 0,
  startY: 0,
  startArea: null,
  currentArea: null,
  lookName: null,
  sectionName: null,
  componentType: null,
  componentIndex: -1,
};

export function Canvas(): React.ReactElement {
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const containerRef = useRef<HTMLDivElement>(null);
  const [canvasSize, setCanvasSize] = useState({ w: 800, h: 600 });
  const [dragState, setDragState] = useState<DragRuntimeState>(EMPTY_DRAG_STATE);
  const [texturesReady, setTexturesReady] = useState(false);

  const viewport = useEditorStore(s => s.canvas);
  const setViewport = useEditorStore(s => s.setViewport);
  const wlName = useEditorStore(s => s.selection.widgetLookName);
  const activeFile = useEditorStore(s => s.files.activeFilePath);
  const openedFiles = useEditorStore(s => s.files.openedFiles);
  const activeStates = useEditorStore(s => s.preview.activeStates);
  const parentWidth = useEditorStore(s => s.preview.parentWidth);
  const parentHeight = useEditorStore(s => s.preview.parentHeight);
  const selectedNodeIds = useEditorStore(s => s.selection.selectedNodeIds);
  const selectNode = useEditorStore(s => s.selectNode);
  const updateWidgetLook = useEditorStore(s => s.updateWidgetLook);
  const pushHistory = useEditorStore(s => s.pushHistory);

  const currentWl = React.useMemo((): WidgetLook | null => {
    if (!activeFile || !wlName) return null;
    const fileState = openedFiles.get(activeFile);
    if (!fileState) return null;
    return fileState.loadedWidgetLooks.get(wlName) || null;
  }, [activeFile, wlName, openedFiles]);
  const availableLooks = React.useMemo(() => (
    activeFile ? openedFiles.get(activeFile)?.loadedWidgetLooks : undefined
  ), [activeFile, openedFiles]);

  useEffect(() => {
    if (!currentWl) {
      setTexturesReady(false);
      return;
    }

    let cancelled = false;
    setTexturesReady(false);

    textureCache.loadRequiredTextures(currentWl, availableLooks).then(() => {
      if (!cancelled) {
        setTexturesReady(true);
      }
    });

    return () => {
      cancelled = true;
    };
  }, [currentWl, availableLooks]);

  useEffect(() => {
    const container = containerRef.current;
    if (!container) return;

    const observer = new ResizeObserver(entries => {
      for (const entry of entries) {
        setCanvasSize({
          w: Math.floor(entry.contentRect.width),
          h: Math.floor(entry.contentRect.height),
        });
      }
    });
    observer.observe(container);
    return () => observer.disconnect();
  }, []);

  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;

    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    ctx.clearRect(0, 0, canvasSize.w, canvasSize.h);
    drawGrid(ctx, canvasSize, viewport);

    if (!currentWl) {
      return;
    }

    const evalCtx = buildEvaluationContext(currentWl, availableLooks, parentWidth, parentHeight);
    const matchedStates = resolveMatchedStates(currentWl, activeStates);

    renderWidgetLook(
      ctx,
      currentWl.imagerySections,
      matchedStates,
      evalCtx,
      textureCache,
      { offsetX: viewport.offsetX, offsetY: viewport.offsetY, scale: viewport.scale },
      currentWl.name,
      availableLooks,
    );

    const selectedArea = dragState.active && dragState.currentArea
      ? dragState.currentArea
      : selectedNodeIds.length > 0
        ? findSelectedArea(currentWl, selectedNodeIds[0], evalCtx, availableLooks)
        : null;

    if (selectedArea) {
      renderSelectionHandles(ctx, selectedArea, {
        offsetX: viewport.offsetX,
        offsetY: viewport.offsetY,
        scale: viewport.scale,
      });
    }

    if (!texturesReady) {
      ctx.save();
      ctx.fillStyle = 'rgba(0,0,0,0.5)';
      ctx.fillRect(0, 0, canvasSize.w, 30);
      ctx.fillStyle = '#f9e2af';
      ctx.font = '12px monospace';
      ctx.textAlign = 'center';
      ctx.fillText('Loading textures...', canvasSize.w / 2, 20);
      ctx.restore();
    }
  }, [
    canvasSize,
    viewport,
    currentWl,
    activeStates,
    parentWidth,
    parentHeight,
    selectedNodeIds,
    texturesReady,
    dragState.active,
    dragState.currentArea,
    availableLooks,
  ]);

  const handleWheel = useCallback((e: React.WheelEvent) => {
    e.preventDefault();
    const newViewport = zoomViewport(viewport, e.deltaY, e.nativeEvent.offsetX, e.nativeEvent.offsetY);
    setViewport(newViewport);
  }, [viewport, setViewport]);

  const handleMouseDown = useCallback((e: React.MouseEvent) => {
    if (!currentWl) return;

    const evalCtx = buildEvaluationContext(currentWl, availableLooks, parentWidth, parentHeight);
    const matchedStates = resolveMatchedStates(currentWl, activeStates);
    const renderTargets = collectRenderableComponents(currentWl, matchedStates, evalCtx, availableLooks);
    const selectedTarget = selectedNodeIds.length > 0
      ? renderTargets.find(target => target.id === selectedNodeIds[0]) ??
        buildTargetFromNodeId(currentWl, selectedNodeIds[0], evalCtx, availableLooks)
      : null;

    const selectedHitMode = selectedTarget
      ? hitTestDragMode(e.nativeEvent.offsetX, e.nativeEvent.offsetY, selectedTarget.area, viewport)
      : null;

    const hitTarget = selectedHitMode
      ? selectedTarget
      : renderTargets
          .slice()
          .reverse()
          .find(target => hitTestDragMode(e.nativeEvent.offsetX, e.nativeEvent.offsetY, target.area, viewport));

    if (!hitTarget) {
      return;
    }

    const dragMode = hitTarget === selectedTarget && selectedHitMode
      ? selectedHitMode
      : hitTestDragMode(e.nativeEvent.offsetX, e.nativeEvent.offsetY, hitTarget.area, viewport);

    if (!dragMode) {
      return;
    }

    if (selectedNodeIds[0] !== hitTarget.id) {
      selectNode(hitTarget.id, false);
    }

    setDragState({
      active: true,
      mode: dragMode,
      startX: e.nativeEvent.offsetX,
      startY: e.nativeEvent.offsetY,
      startArea: hitTarget.area,
      currentArea: hitTarget.area,
      lookName: hitTarget.lookName,
      sectionName: hitTarget.sectionName,
      componentType: hitTarget.componentType,
      componentIndex: hitTarget.componentIndex,
    });
  }, [currentWl, availableLooks, parentWidth, parentHeight, activeStates, selectedNodeIds, viewport, selectNode]);

  const handleMouseMove = useCallback((e: React.MouseEvent) => {
    if (!dragState.active || !dragState.mode || !dragState.startArea || !currentWl) return;

    const dx = (e.nativeEvent.offsetX - dragState.startX) / viewport.scale;
    const dy = (e.nativeEvent.offsetY - dragState.startY) / viewport.scale;
    const newArea = applyDrag(dragState.mode, dx, dy, dragState.startArea);

    setDragState(prev => ({ ...prev, currentArea: newArea }));
  }, [dragState.active, dragState.mode, dragState.startArea, dragState.startX, dragState.startY, viewport.scale, currentWl]);

  const handleMouseUp = useCallback(() => {
    if (
      dragState.active &&
      dragState.mode &&
      dragState.currentArea &&
      dragState.sectionName &&
      dragState.componentType &&
      currentWl &&
      wlName
    ) {
      const dx = Math.abs(dragState.currentArea.x - (dragState.startArea?.x ?? 0));
      const dy = Math.abs(dragState.currentArea.y - (dragState.startArea?.y ?? 0));
      const dw = Math.abs(dragState.currentArea.w - (dragState.startArea?.w ?? 0));
      const dh = Math.abs(dragState.currentArea.h - (dragState.startArea?.h ?? 0));

      if (dx > 1 || dy > 1 || dw > 1 || dh > 1) {
        const targetWidgetLook = dragState.lookName
          ? availableLooks?.get(dragState.lookName)
          : currentWl;
        const targetWidgetLookName = dragState.lookName ?? wlName;
        if (!targetWidgetLook) {
          setDragState(EMPTY_DRAG_STATE);
          return;
        }

        const evalCtx = buildEvaluationContext(targetWidgetLook, availableLooks, parentWidth, parentHeight);
        const payload: DragEndPayload = {
          finalRect: dragState.currentArea,
          mode: dragState.mode,
          sectionName: dragState.sectionName,
          componentType: dragState.componentType,
          componentIndex: dragState.componentIndex,
        };

        pushHistory({
          description: `Drag ${payload.mode}: ${payload.sectionName}/${payload.componentType}#${payload.componentIndex}`,
          widgetLookName: targetWidgetLookName,
          snapshot: JSON.stringify(targetWidgetLook),
          affectedPaths: [`${payload.sectionName}.${payload.componentType}[${payload.componentIndex}].area`],
        });

        const newWl = applyDragWriteback(targetWidgetLook, payload, evalCtx);
        updateWidgetLook(targetWidgetLookName, newWl);
      }
    }

    setDragState(EMPTY_DRAG_STATE);
  }, [dragState, currentWl, availableLooks, wlName, parentWidth, parentHeight, pushHistory, updateWidgetLook]);

  useEffect(() => {
    if (!dragState.active) return;

    const handleWindowMouseUp = () => {
      handleMouseUp();
    };

    window.addEventListener('mouseup', handleWindowMouseUp);
    return () => {
      window.removeEventListener('mouseup', handleWindowMouseUp);
    };
  }, [dragState.active, handleMouseUp]);

  return (
    <div ref={containerRef} className="canvas-container">
      <canvas
        ref={canvasRef}
        width={canvasSize.w}
        height={canvasSize.h}
        onWheel={handleWheel}
        onMouseDown={handleMouseDown}
        onMouseMove={handleMouseMove}
        onMouseUp={handleMouseUp}
      />
    </div>
  );
}

function drawGrid(
  ctx: CanvasRenderingContext2D,
  size: { w: number; h: number },
  viewport: CanvasViewport,
): void {
  if (!viewport.showGrid) return;

  const gridSize = viewport.gridSize * viewport.scale;
  if (gridSize < 4) return;

  ctx.save();
  ctx.strokeStyle = 'rgba(128, 128, 128, 0.15)';
  ctx.lineWidth = 0.5;

  const startX = viewport.offsetX % gridSize;
  const startY = viewport.offsetY % gridSize;

  for (let x = startX; x < size.w; x += gridSize) {
    ctx.beginPath();
    ctx.moveTo(x, 0);
    ctx.lineTo(x, size.h);
    ctx.stroke();
  }
  for (let y = startY; y < size.h; y += gridSize) {
    ctx.beginPath();
    ctx.moveTo(0, y);
    ctx.lineTo(size.w, y);
    ctx.stroke();
  }

  ctx.restore();
}

function findSelectedArea(
  wl: WidgetLook,
  nodeId: string,
  evalCtx: DimEvaluationContext,
  availableLooks?: Map<string, WidgetLook>,
): PixelRect | null {
  const target = buildTargetFromNodeId(wl, nodeId, evalCtx, availableLooks);
  if (target) {
    return target.area;
  }
  return findFirstVisibleArea(wl, resolveMatchedStates(wl, []), evalCtx, availableLooks);
}

function findFirstVisibleArea(
  wl: WidgetLook,
  matchedStates: StateImagery[],
  evalCtx: DimEvaluationContext,
  availableLooks?: Map<string, WidgetLook>,
): PixelRect | null {
  const renderTargets = collectRenderableComponents(wl, matchedStates, evalCtx, availableLooks);
  if (renderTargets.length > 0) {
    return renderTargets[0].area;
  }

  for (const section of wl.imagerySections) {
    if (section.frameComponents[0]) return evaluateArea(section.frameComponents[0].area, evalCtx);
    if (section.imageryComponents[0]) return evaluateArea(section.imageryComponents[0].area, evalCtx);
    if (section.textComponents[0]) return evaluateArea(section.textComponents[0].area, evalCtx);
  }

  return null;
}

function buildEvaluationContext(
  wl: WidgetLook,
  availableLooks: Map<string, WidgetLook> | undefined,
  parentWidth: number,
  parentHeight: number,
): DimEvaluationContext {
  const evalCtx: DimEvaluationContext = {
    parentWidth,
    parentHeight,
    widgetDimensions: new Map([
      ['__self__', { x: 0, y: 0, w: parentWidth, h: parentHeight }],
    ]),
    imageDimensions: new Map(),
    fontMetrics: new Map(),
  };

  const looksToScan = availableLooks ? Array.from(availableLooks.values()) : [wl];
  for (const look of looksToScan) {
    for (const section of look.imagerySections) {
      for (const frame of section.frameComponents) {
        for (const ref of Object.values(frame.images)) {
          if (!ref) continue;
          const size = textureCache.getSubImageSize(ref.imageset, ref.image);
          if (size) {
            evalCtx.imageDimensions.set(`${ref.imageset}/${ref.image}`, size);
          }
        }
      }

      for (const imagery of section.imageryComponents) {
        if (!imagery.image) continue;
        const size = textureCache.getSubImageSize(imagery.image.imageset, imagery.image.image);
        if (size) {
          evalCtx.imageDimensions.set(`${imagery.image.imageset}/${imagery.image.image}`, size);
        }
      }
    }
  }

  for (const child of wl.children) {
    if (!child.nameSuffix) continue;
    evalCtx.widgetDimensions.set(child.nameSuffix, evaluateArea(child.area, evalCtx));
  }

  return evalCtx;
}

function resolveMatchedStates(
  wl: WidgetLook,
  activeStates: string[],
): StateImagery[] {
  const matchedStates = wl.stateImagerys.filter(state => activeStates.includes(state.name));
  if (matchedStates.length === 0 && wl.stateImagerys.length > 0) {
    return [wl.stateImagerys[0]];
  }
  return matchedStates;
}

function collectRenderableComponents(
  wl: WidgetLook,
  matchedStates: StateImagery[],
  evalCtx: DimEvaluationContext,
  availableLooks?: Map<string, WidgetLook>,
): RenderableComponentRef[] {
  const sectionMap = new Map(wl.imagerySections.map(section => [section.name, section]));
  const targets: RenderableComponentRef[] = [];

  for (const state of matchedStates) {
    for (const layer of state.layers) {
      for (const sectionRef of layer.sections) {
        const section = resolveImagerySection(sectionRef, wl.name, sectionMap, availableLooks);
        if (!section) continue;
        appendSectionTargets(targets, section, evalCtx, sectionRef.look);
      }
    }
  }

  return targets;
}

function appendSectionTargets(
  targets: RenderableComponentRef[],
  section: WidgetLook['imagerySections'][number],
  evalCtx: DimEvaluationContext,
  lookName?: string,
): void {
  section.frameComponents.forEach((component, index) => {
    targets.push({
      id: lookName
        ? `section:${lookName}:${section.name}:frame:${index}`
        : `section:${section.name}:frame:${index}`,
      area: evaluateArea(component.area, evalCtx),
      lookName: lookName ?? null,
      sectionName: section.name,
      componentType: 'frame',
      componentIndex: index,
    });
  });

  section.imageryComponents.forEach((component, index) => {
    targets.push({
      id: lookName
        ? `section:${lookName}:${section.name}:imagery:${index}`
        : `section:${section.name}:imagery:${index}`,
      area: evaluateArea(component.area, evalCtx),
      lookName: lookName ?? null,
      sectionName: section.name,
      componentType: 'imagery',
      componentIndex: index,
    });
  });

  section.textComponents.forEach((component, index) => {
    targets.push({
      id: lookName
        ? `section:${lookName}:${section.name}:text:${index}`
        : `section:${section.name}:text:${index}`,
      area: evaluateArea(component.area, evalCtx),
      lookName: lookName ?? null,
      sectionName: section.name,
      componentType: 'text',
      componentIndex: index,
    });
  });
}

function buildTargetFromNodeId(
  wl: WidgetLook,
  nodeId: string,
  evalCtx: DimEvaluationContext,
  availableLooks?: Map<string, WidgetLook>,
): RenderableComponentRef | null {
  const componentRef = parseComponentNodeId(nodeId);
  if (!componentRef) {
    return null;
  }

  const area = findComponentArea(
    wl,
    componentRef.look,
    componentRef.sectionName,
    componentRef.componentType,
    componentRef.componentIndex,
    evalCtx,
    availableLooks,
  );

  if (!area) {
    return null;
  }

  return {
    id: nodeId,
    area,
    lookName: componentRef.look ?? null,
    sectionName: componentRef.sectionName,
    componentType: componentRef.componentType,
    componentIndex: componentRef.componentIndex,
  };
}

function findComponentArea(
  wl: WidgetLook,
  lookName: string | undefined,
  sectionName: string,
  componentType: 'frame' | 'imagery' | 'text',
  componentIndex: number,
  evalCtx: DimEvaluationContext,
  availableLooks?: Map<string, WidgetLook>,
): PixelRect | null {
  const targetLook = lookName && lookName !== wl.name
    ? availableLooks?.get(lookName)
    : wl;
  const section = targetLook?.imagerySections.find(item => item.name === sectionName);
  if (!section) {
    return null;
  }

  switch (componentType) {
    case 'frame':
      return section.frameComponents[componentIndex]
        ? evaluateArea(section.frameComponents[componentIndex].area, evalCtx)
        : null;
    case 'imagery':
      return section.imageryComponents[componentIndex]
        ? evaluateArea(section.imageryComponents[componentIndex].area, evalCtx)
        : null;
    case 'text':
      return section.textComponents[componentIndex]
        ? evaluateArea(section.textComponents[componentIndex].area, evalCtx)
        : null;
  }
}
