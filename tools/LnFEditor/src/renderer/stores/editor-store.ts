import { create } from 'zustand';
import { enableMapSet } from 'immer';
import { immer } from 'zustand/middleware/immer';
import type {
  WidgetLook,
  FileIndex,
  CanvasViewport,
  HistoryEntry,
  DimEvaluationContext,
  ImagesetResource,
  SubImageDef,
} from '@shared/model';
import { DEFAULT_VIEWPORT, HISTORY_MAX_DEPTH } from '@shared/constants';

enableMapSet();

/** 编辑器文件状态（与 shared/model 中的 FileState 区分） */
export interface EditorFileState {
  filePath: string;
  fileIndex: FileIndex | null;
  loadedWidgetLooks: Map<string, WidgetLook>;
  dirty: boolean;
  /** 已加载的 imageset 资源（从 scheme 自动发现或手动加载） */
  imagesets: Map<string, ImagesetResource>;
  /** 关联的 scheme 文件路径 */
  schemePath: string | null;
}

interface EditorStore {
  files: {
    activeFilePath: string | null;
    openedFiles: Map<string, EditorFileState>;
  };
  selection: {
    widgetLookName: string | null;
    selectedNodeIds: string[];
    hoveredNodeId: string | null;
  };
  canvas: CanvasViewport;
  preview: {
    activeStates: string[];
    parentWidth: number;
    parentHeight: number;
    /** 视口渲染模式：composite=叠加所有激活状态，isolate=仅渲染单个状态 */
    viewMode: 'composite' | 'isolate';
    /** Section 着色高亮：选中的 ImagerySection 名称 */
    highlightedSection: string | null;
  };
  history: {
    undoStack: HistoryEntry[];
    redoStack: HistoryEntry[];
  };
  dirty: boolean;

  // 文件管理
  openFile: (filePath: string, fileIndex: FileIndex, widgetLooks: WidgetLook[]) => void;
  closeFile: (filePath: string) => void;
  setActiveFile: (filePath: string) => void;

  // 资源管理
  registerImagesets: (filePath: string, imagesets: Record<string, {
    name: string;
    textureFileName: string;
    textureFilePath: string;
    nativeHorzRes: number;
    nativeVertRes: number;
    autoScaled: boolean;
    subImages: Record<string, SubImageDef>;
  }>) => void;
  setSchemePath: (filePath: string, schemePath: string) => void;

  // 选择管理
  selectWidgetLook: (name: string) => void;
  selectNode: (nodeId: string, multiSelect: boolean) => void;
  hoverNode: (nodeId: string | null) => void;

  // 数据修改
  updateWidgetLook: (name: string, wl: WidgetLook) => void;

  // 视口/预览控制
  setViewport: (viewport: Partial<CanvasViewport>) => void;
  setActiveStates: (states: string[]) => void;
  setParentSize: (width: number, height: number) => void;
  setViewMode: (mode: 'composite' | 'isolate') => void;
  setHighlightedSection: (sectionName: string | null) => void;

  // 历史记录
  pushHistory: (entry: Omit<HistoryEntry, 'timestamp' | 'filePath'>) => void;
  undo: () => HistoryEntry | null;
  redo: () => HistoryEntry | null;

  // 脏标记
  markDirty: (dirty: boolean) => void;
}

function getFirstWidgetLookName(fileState: EditorFileState | undefined): string | null {
  if (!fileState) {
    return null;
  }

  const iterator = fileState.loadedWidgetLooks.keys().next();
  return iterator.done ? null : iterator.value;
}

function syncSelectionToActiveFile(
  state: {
    files: {
      activeFilePath: string | null;
      openedFiles: Map<string, EditorFileState>;
    };
    selection: {
      widgetLookName: string | null;
      selectedNodeIds: string[];
      hoveredNodeId: string | null;
    };
    preview: {
      highlightedSection: string | null;
    };
  },
  forceReset = false,
): void {
  const activeFile = state.files.activeFilePath
    ? state.files.openedFiles.get(state.files.activeFilePath)
    : undefined;
  const nextWidgetLookName = activeFile && state.selection.widgetLookName
    && activeFile.loadedWidgetLooks.has(state.selection.widgetLookName)
    ? state.selection.widgetLookName
    : getFirstWidgetLookName(activeFile);
  const shouldResetSelection = forceReset || state.selection.widgetLookName !== nextWidgetLookName;

  state.selection.widgetLookName = nextWidgetLookName;
  if (shouldResetSelection) {
    state.selection.selectedNodeIds = [];
    state.selection.hoveredNodeId = null;
    state.preview.highlightedSection = null;
  }
}

export const useEditorStore = create<EditorStore>()(
  immer((set, get) => ({
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
      viewMode: 'composite' as const,
      highlightedSection: null,
    },
    history: {
      undoStack: [],
      redoStack: [],
    },
    dirty: false,

    openFile: (filePath, fileIndex, widgetLooks) => set(state => {
      const wlMap = new Map<string, WidgetLook>();
      for (const wl of widgetLooks) {
        wlMap.set(wl.name, wl);
      }
      state.files.openedFiles.set(filePath, {
        filePath,
        fileIndex,
        loadedWidgetLooks: wlMap,
        dirty: false,
        imagesets: new Map(),
        schemePath: null,
      });
      state.files.activeFilePath = filePath;
      syncSelectionToActiveFile(state, true);
      state.dirty = Array.from(state.files.openedFiles.values()).some(file => file.dirty);
    }),

    closeFile: (filePath) => set(state => {
      const wasActiveFile = state.files.activeFilePath === filePath;
      state.files.openedFiles.delete(filePath);
      if (wasActiveFile) {
        const remaining = Array.from(state.files.openedFiles.keys());
        state.files.activeFilePath = remaining.length > 0 ? remaining[0] : null;
      }
      syncSelectionToActiveFile(state, wasActiveFile);
      state.dirty = Array.from(state.files.openedFiles.values()).some(file => file.dirty);
    }),

    setActiveFile: (filePath) => set(state => {
      if (!state.files.openedFiles.has(filePath)) return;
      const activeFileChanged = state.files.activeFilePath !== filePath;
      state.files.activeFilePath = filePath;
      syncSelectionToActiveFile(state, activeFileChanged);
      const fileState = state.files.openedFiles.get(filePath);
      state.dirty = fileState?.dirty ?? Array.from(state.files.openedFiles.values()).some(file => file.dirty);
    }),

    registerImagesets: (filePath, imagesetsData) => set(state => {
      const fileState = state.files.openedFiles.get(filePath);
      if (!fileState) return;

      for (const [name, data] of Object.entries(imagesetsData)) {
        const subImages = new Map<string, SubImageDef>();
        if (data.subImages) {
          for (const [subName, subDef] of Object.entries(data.subImages)) {
            subImages.set(subName, subDef as SubImageDef);
          }
        }

        fileState.imagesets.set(name, {
          name: data.name,
          textureFileName: data.textureFileName,
          textureFilePath: data.textureFilePath,
          nativeHorzRes: data.nativeHorzRes,
          nativeVertRes: data.nativeVertRes,
          autoScaled: data.autoScaled,
          subImages,
        });
      }
    }),

    setSchemePath: (filePath, schemePath) => set(state => {
      const fileState = state.files.openedFiles.get(filePath);
      if (fileState) {
        fileState.schemePath = schemePath;
      }
    }),

    selectWidgetLook: (name) => set(state => {
      state.selection.widgetLookName = name;
      state.selection.selectedNodeIds = [];
      state.selection.hoveredNodeId = null;
      state.preview.highlightedSection = null;
    }),

    selectNode: (nodeId, multiSelect) => set(state => {
      if (multiSelect) {
        const idx = state.selection.selectedNodeIds.indexOf(nodeId);
        if (idx >= 0) {
          state.selection.selectedNodeIds.splice(idx, 1);
        } else {
          state.selection.selectedNodeIds.push(nodeId);
        }
      } else {
        state.selection.selectedNodeIds = [nodeId];
      }
    }),

    hoverNode: (nodeId) => set(state => {
      state.selection.hoveredNodeId = nodeId;
    }),

    updateWidgetLook: (name, wl) => set(state => {
      const fileState = state.files.openedFiles.get(state.files.activeFilePath!);
      if (fileState) {
        fileState.loadedWidgetLooks.set(name, wl);
        fileState.dirty = true;
        state.dirty = true;
      }
    }),

    setViewport: (partial) => set(state => {
      Object.assign(state.canvas, partial);
    }),

    setActiveStates: (states) => set(state => {
      state.preview.activeStates = states;
    }),

    setParentSize: (width, height) => set(state => {
      state.preview.parentWidth = width;
      state.preview.parentHeight = height;
    }),

    setViewMode: (mode) => set(state => {
      state.preview.viewMode = mode;
    }),

    setHighlightedSection: (sectionName) => set(state => {
      state.preview.highlightedSection = sectionName;
    }),

    pushHistory: (entry) => set(state => {
      const filePath = state.files.activeFilePath ?? '';
      state.history.undoStack.push({ ...entry, timestamp: Date.now(), filePath });
      state.history.redoStack = [];
      if (state.history.undoStack.length > HISTORY_MAX_DEPTH) {
        state.history.undoStack.shift();
      }
    }),

    undo: () => {
      const state = get();
      const entry = state.history.undoStack[state.history.undoStack.length - 1];
      if (!entry) return null;

      const targetFilePath = entry.filePath;
      const currentWlName = entry.widgetLookName;
      const currentFileState = state.files.openedFiles.get(targetFilePath);
      const currentWl = currentFileState?.loadedWidgetLooks.get(currentWlName);

      set(s => {
        s.history.undoStack.pop();
        if (currentWl) {
          s.history.redoStack.push({
            timestamp: Date.now(),
            description: entry.description,
            filePath: targetFilePath,
            widgetLookName: currentWlName,
            snapshot: JSON.stringify(currentWl),
            affectedPaths: entry.affectedPaths,
          });
        }

        if (currentWlName && currentFileState) {
          try {
            const restored = JSON.parse(entry.snapshot) as WidgetLook;
            const fileState = s.files.openedFiles.get(targetFilePath);
            if (fileState) {
              fileState.loadedWidgetLooks.set(currentWlName, restored);
              fileState.dirty = true;
              s.dirty = true;
            }
          } catch (e) {
            console.warn('Undo: Failed to restore snapshot', e);
          }
        }
      });

      return entry;
    },

    redo: () => {
      const state = get();
      const entry = state.history.redoStack[state.history.redoStack.length - 1];
      if (!entry) return null;

      const targetFilePath = entry.filePath;
      const currentWlName = entry.widgetLookName;
      const currentFileState = state.files.openedFiles.get(targetFilePath);
      const currentWl = currentFileState?.loadedWidgetLooks.get(currentWlName);

      set(s => {
        s.history.redoStack.pop();
        if (currentWl) {
          s.history.undoStack.push({
            timestamp: Date.now(),
            description: entry.description,
            filePath: targetFilePath,
            widgetLookName: currentWlName,
            snapshot: JSON.stringify(currentWl),
            affectedPaths: entry.affectedPaths,
          });
        }

        if (currentWlName) {
          try {
            const restored = JSON.parse(entry.snapshot) as WidgetLook;
            const fileState = s.files.openedFiles.get(targetFilePath);
            if (fileState) {
              fileState.loadedWidgetLooks.set(currentWlName, restored);
              fileState.dirty = true;
              s.dirty = true;
            }
          } catch (e) {
            console.warn('Redo: Failed to restore snapshot', e);
          }
        }
      });

      return entry;
    },

    markDirty: (dirty) => set(state => {
      const activeFilePath = state.files.activeFilePath;
      if (activeFilePath) {
        const activeFile = state.files.openedFiles.get(activeFilePath);
        if (activeFile) {
          activeFile.dirty = dirty;
        }
      }
      state.dirty = dirty
        ? true
        : Array.from(state.files.openedFiles.values()).some(file => file.dirty);
    }),
  }))
);
