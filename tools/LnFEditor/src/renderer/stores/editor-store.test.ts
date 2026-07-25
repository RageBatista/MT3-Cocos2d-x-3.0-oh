import { beforeEach, describe, expect, it } from 'vitest';
import { DEFAULT_VIEWPORT } from '@shared/constants';
import type { FileIndex, WidgetLook } from '@shared/model';
import { useEditorStore } from './editor-store';

const fileIndex: FileIndex = {
  filePath: 'demo.looknfeel',
  totalWidgetLooks: 1,
  widgetLookIndices: [],
};

const widgetLook: WidgetLook = {
  name: 'Demo/Button',
  propertyDefinitions: [],
  propertyLinkDefinitions: [],
  properties: [],
  namedAreas: [],
  children: [],
  imagerySections: [],
  stateImagerys: [],
};

const widgetLookAlt: WidgetLook = {
  ...widgetLook,
  name: 'Demo/Frame',
};

beforeEach(() => {
  useEditorStore.setState(state => ({
    ...state,
    files: {
      activeFilePath: null,
      openedFiles: new Map(),
    },
    selection: {
      widgetLookName: null,
      selectedNodeIds: [],
      hoveredNodeId: null,
    },
    canvas: { ...DEFAULT_VIEWPORT },
    preview: {
      activeStates: [],
      parentWidth: 1136,
      parentHeight: 640,
      viewMode: 'composite',
      highlightedSection: null,
    },
    history: {
      undoStack: [],
      redoStack: [],
    },
    dirty: false,
  }));
});

describe('editor-store', () => {
  it('can open files backed by Map state without throwing', () => {
    expect(() => {
      useEditorStore.getState().openFile(fileIndex.filePath, fileIndex, [widgetLook]);
    }).not.toThrow();

    const state = useEditorStore.getState();
    expect(state.files.activeFilePath).toBe(fileIndex.filePath);
    expect(state.files.openedFiles.get(fileIndex.filePath)?.loadedWidgetLooks.get(widgetLook.name)?.name).toBe(widgetLook.name);
  });

  it('clears both global and per-file dirty flags when markDirty(false) is called', () => {
    const store = useEditorStore.getState();
    store.openFile(fileIndex.filePath, fileIndex, [widgetLook]);
    store.updateWidgetLook(widgetLook.name, { ...widgetLook, properties: [{ name: 'Caption', value: 'Changed' }] });

    expect(useEditorStore.getState().dirty).toBe(true);
    expect(useEditorStore.getState().files.openedFiles.get(fileIndex.filePath)?.dirty).toBe(true);

    store.markDirty(false);

    expect(useEditorStore.getState().dirty).toBe(false);
    expect(useEditorStore.getState().files.openedFiles.get(fileIndex.filePath)?.dirty).toBe(false);
  });

  it('switches active file with a valid widget look selection and clears stale node state', () => {
    const store = useEditorStore.getState();
    store.openFile('demo-a.looknfeel', { ...fileIndex, filePath: 'demo-a.looknfeel' }, [widgetLook]);
    store.selectWidgetLook(widgetLook.name);
    store.selectNode('section:frame:imagery:0', false);
    store.hoverNode('section:frame:imagery:0');

    store.openFile('demo-b.looknfeel', { ...fileIndex, filePath: 'demo-b.looknfeel' }, [widgetLookAlt]);
    store.setActiveFile('demo-b.looknfeel');

    const state = useEditorStore.getState();
    expect(state.files.activeFilePath).toBe('demo-b.looknfeel');
    expect(state.selection.widgetLookName).toBe(widgetLookAlt.name);
    expect(state.selection.selectedNodeIds).toEqual([]);
    expect(state.selection.hoveredNodeId).toBeNull();
  });

  it('rebinds selection when closing the active file and another file remains open', () => {
    const store = useEditorStore.getState();
    store.openFile('demo-a.looknfeel', { ...fileIndex, filePath: 'demo-a.looknfeel' }, [widgetLook]);
    store.openFile('demo-b.looknfeel', { ...fileIndex, filePath: 'demo-b.looknfeel' }, [widgetLookAlt]);
    store.selectWidgetLook(widgetLookAlt.name);
    store.selectNode('section:shared:text:0', false);

    store.closeFile('demo-b.looknfeel');

    const state = useEditorStore.getState();
    expect(state.files.activeFilePath).toBe('demo-a.looknfeel');
    expect(state.selection.widgetLookName).toBe(widgetLook.name);
    expect(state.selection.selectedNodeIds).toEqual([]);
    expect(state.selection.hoveredNodeId).toBeNull();
  });
});
