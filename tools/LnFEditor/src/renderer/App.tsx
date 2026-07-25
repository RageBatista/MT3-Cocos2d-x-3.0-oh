import React, { useCallback, useEffect, useState } from 'react';
import { useEditorStore } from './stores/editor-store';
import { LiveViewport } from './canvas/LiveViewport';
import { ExplorerPanel } from './panels/ExplorerPanel';
import { InspectorPanel } from './panels/InspectorPanel';
import { textureCache } from './services/texture-cache';
import { useTranslation } from './services/i18n';
import type { WidgetLook, ImagesetResource, SubImageDef } from '@shared/model';

declare global {
  interface Window {
    lnfAPI: import('../preload/index').LnfAPI;
  }
}

export function App(): React.ReactElement {
  const { t } = useTranslation();
  const [ready, setReady] = useState(false);

  useEffect(() => {
    setReady(true);
  }, []);

  // 全局快捷键
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      const store = useEditorStore.getState();

      // Ctrl+Z: 撤销
      if ((e.ctrlKey || e.metaKey) && e.key === 'z' && !e.shiftKey) {
        e.preventDefault();
        store.undo();
      }

      // Ctrl+Y / Ctrl+Shift+Z: 重做
      if ((e.ctrlKey || e.metaKey) && (e.key === 'y' || (e.key === 'z' && e.shiftKey))) {
        e.preventDefault();
        store.redo();
      }

      // Ctrl+S: 保存
      if ((e.ctrlKey || e.metaKey) && e.key === 's') {
        e.preventDefault();
        saveCurrentFile(store);
      }

      // Ctrl+0: 适应窗口
      if ((e.ctrlKey || e.metaKey) && e.key === '0') {
        e.preventDefault();
        store.setViewport({
          offsetX: 0,
          offsetY: 0,
          scale: 1.0,
        });
      }

      // Ctrl+1: 100% 缩放
      if ((e.ctrlKey || e.metaKey) && e.key === '1') {
        e.preventDefault();
        store.setViewport({ scale: 1.0 });
      }
    };

    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, []);

  if (!ready) {
    return <div className="loading">{t('app.loading')}</div>;
  }

  return (
    <div className="app-layout">
      <div className="top-bar">
        <Toolbar />
      </div>
      <div className="main-content">
        <div className="left-panel">
          <ExplorerPanel />
        </div>
        <div className="center-panel">
          <LiveViewport />
        </div>
        <div className="right-panel">
          <InspectorPanel />
        </div>
      </div>
      <StatusBar />
    </div>
  );
}

/** 保存当前文件 */
async function saveCurrentFile(store: ReturnType<typeof useEditorStore.getState>): Promise<void> {
  const filePath = store.files.activeFilePath;
  if (!filePath) return;

  const fileState = store.files.openedFiles.get(filePath);
  if (!fileState) return;

  const widgetLooks = Array.from(fileState.loadedWidgetLooks.values());
  const result = await window.lnfAPI.saveLookNFeel(filePath, JSON.stringify(widgetLooks));
  if (result?.success) {
    store.markDirty(false);
  }
}

function Toolbar(): React.ReactElement {
  const { t } = useTranslation();
  const dirty = useEditorStore(s => s.dirty);

  const openFile = useCallback(async () => {
    const result = await window.lnfAPI.openLookNFeel();
    if (!result) return;

    const store = useEditorStore.getState();
    store.openFile(result.filePath, result.fileIndex, result.widgetLooks);

    if (result.widgetLooks.length > 0) {
      store.selectWidgetLook(result.widgetLooks[0].name);
    }

    // 自动发现并加载关联资源
    try {
      const resources = await window.lnfAPI.discoverResources(result.filePath);
      if (resources && resources.imagesets) {
        // 注册 imageset 资源到 store
        store.registerImagesets(result.filePath, resources.imagesets);

        // 注册 imageset 资源到纹理缓存
        const imagesetResources: ImagesetResource[] = [];
        for (const data of Object.values(resources.imagesets) as Array<{
          name: string;
          textureFileName: string;
          textureFilePath: string;
          nativeHorzRes: number;
          nativeVertRes: number;
          autoScaled: boolean;
          subImages: Record<string, SubImageDef>;
        }>) {
          const subImages = new Map<string, SubImageDef>();
          if (data.subImages) {
            for (const [subName, subDef] of Object.entries(data.subImages)) {
              subImages.set(subName, subDef as SubImageDef);
            }
          }
          imagesetResources.push({
            name: data.name,
            textureFileName: data.textureFileName,
            textureFilePath: data.textureFilePath,
            nativeHorzRes: data.nativeHorzRes,
            nativeVertRes: data.nativeVertRes,
            autoScaled: data.autoScaled,
            subImages,
          });
        }
        textureCache.registerImagesets(imagesetResources);
      }

      if (resources?.schemePath) {
        store.setSchemePath(result.filePath, resources.schemePath);
      }
    } catch (e) {
      console.warn('Failed to auto-discover resources:', e);
    }
  }, []);

  const saveFile = useCallback(async () => {
    const store = useEditorStore.getState();
    await saveCurrentFile(store);
  }, []);

  const handleUndo = useCallback(() => {
    useEditorStore.getState().undo();
  }, []);

  const handleRedo = useCallback(() => {
    useEditorStore.getState().redo();
  }, []);

  const zoomIn = useCallback(() => {
    const store = useEditorStore.getState();
    store.setViewport({ scale: Math.min(store.canvas.scale * 1.2, 10) });
  }, []);

  const zoomOut = useCallback(() => {
    const store = useEditorStore.getState();
    store.setViewport({ scale: Math.max(store.canvas.scale / 1.2, 0.1) });
  }, []);

  const resetZoom = useCallback(() => {
    useEditorStore.getState().setViewport({ scale: 1.0, offsetX: 0, offsetY: 0 });
  }, []);

  const scale = useEditorStore(s => s.canvas.scale);

  return (
    <div className="toolbar">
      <div className="toolbar-group">
        <button onClick={openFile} title={t('toolbar.openTitle')}>{t('toolbar.open')}</button>
        <button onClick={saveFile} title={t('toolbar.saveTitle')} disabled={!dirty}>{t('toolbar.save')}</button>
      </div>
      <div className="toolbar-group">
        <button onClick={handleUndo} title={t('toolbar.undoTitle')}>↩</button>
        <button onClick={handleRedo} title={t('toolbar.redoTitle')}>↪</button>
      </div>
      <div className="toolbar-group">
        <button onClick={zoomOut} title={t('toolbar.zoomOutTitle')}>−</button>
        <span className="zoom-label">{Math.round(scale * 100)}%</span>
        <button onClick={zoomIn} title={t('toolbar.zoomInTitle')}>+</button>
        <button onClick={resetZoom} title={t('toolbar.resetZoomTitle')}>⊡</button>
      </div>
    </div>
  );
}

function StatusBar(): React.ReactElement {
  const { t } = useTranslation();
  const dirty = useEditorStore(s => s.dirty);
  const activeFile = useEditorStore(s => s.files.activeFilePath);
  const wlName = useEditorStore(s => s.selection.widgetLookName);
  const undoCount = useEditorStore(s => s.history.undoStack.length);
  const redoCount = useEditorStore(s => s.history.redoStack.length);
  const cacheStats = textureCache.getStats();

  return (
    <div className="status-bar">
      <span>{activeFile ? activeFile.split(/[\\/]/).pop() : t('status.noFile')}</span>
      <span>{wlName || t('status.noSelection')}</span>
      <span>{dirty ? `● ${t('status.modified')}` : `○ ${t('status.saved')}`}</span>
      <span>{t('status.undoCount', { count: undoCount })} | {t('status.redoCount', { count: redoCount })}</span>
      <span>{t('status.textures', { cached: cacheStats.cachedCount, max: cacheStats.maxSize })}</span>
    </div>
  );
}
