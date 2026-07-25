/**
 * plugin-system — 插件系统
 *
 * 提供扩展点（Extension Points），允许第三方插件扩展编辑器功能：
 * - 自定义 Dim 类型渲染
 * - 自定义属性编辑器
 * - 自定义导出格式
 * - 自定义验证规则
 * - 自定义工具栏按钮
 *
 * 插件通过 JavaScript 模块加载，遵循安全沙箱约束。
 */

// ─── 插件类型定义 ────────────────────────────────────────────────

export interface PluginManifest {
  /** 插件唯一标识 */
  id: string;
  /** 插件名称 */
  name: string;
  /** 版本 */
  version: string;
  /** 描述 */
  description: string;
  /** 作者 */
  author: string;
  /** 入口模块 */
  main: string;
  /** 依赖的其他插件 */
  dependencies?: string[];
  /** 最小编辑器版本 */
  minEditorVersion?: string;
}

export interface Plugin {
  /** 插件清单 */
  manifest: PluginManifest;
  /** 初始化函数 */
  activate?: (context: PluginContext) => void;
  /** 销毁函数 */
  deactivate?: () => void;
}

// ─── 扩展点类型 ──────────────────────────────────────────────────

/** 自定义属性编辑器 */
export interface CustomPropertyEditor {
  /** 匹配的属性名模式 */
  pattern: string | RegExp;
  /** 创建编辑器组件 */
  createEditor: (props: PropertyEditorProps) => React.ReactElement | null;
}

/** 自定义导出格式 */
export interface CustomExporter {
  /** 导出格式名称 */
  name: string;
  /** 文件扩展名 */
  extension: string;
  /** 导出函数 */
  export: (data: ExportData) => Promise<Blob>;
}

/** 自定义验证规则 */
export interface CustomValidator {
  /** 规则名称 */
  name: string;
  /** 验证函数 */
  validate: (widgetLook: import('@shared/model').WidgetLook) => import('@shared/model').ValidationError[];
}

/** 自定义工具栏按钮 */
export interface CustomToolbarAction {
  /** 按钮标识 */
  id: string;
  /** 显示文本 */
  label: string;
  /** 图标 */
  icon?: string;
  /** 点击回调 */
  onClick: () => void;
  /** 是否启用 */
  enabled?: boolean;
}

/** 自定义渲染器（用于特殊 Dim 类型或效果） */
export interface CustomRenderer {
  /** 匹配的组件类型 */
  componentType: string;
  /** 渲染函数 */
  render: (
    ctx: CanvasRenderingContext2D,
    area: import('@shared/model').PixelRect,
    data: unknown,
    viewport: { offsetX: number; offsetY: number; scale: number },
  ) => void;
}

// ─── 属性编辑器 Props ────────────────────────────────────────────

export interface PropertyEditorProps {
  /** 属性名 */
  name: string;
  /** 当前值 */
  value: string;
  /** 变更回调 */
  onChange: (newValue: string) => void;
  /** 是否禁用 */
  disabled?: boolean;
}

// ─── 导出数据 ────────────────────────────────────────────────────

export interface ExportData {
  /** WidgetLook 数据 */
  widgetLooks: import('@shared/model').WidgetLook[];
  /** XML 文本 */
  xmlContent: string;
  /** Canvas 截图 Data URL */
  screenshotDataUrl?: string;
}

// ─── 插件上下文（暴露给插件的 API） ──────────────────────────────

export interface PluginContext {
  /** 注册自定义属性编辑器 */
  registerPropertyEditor: (editor: CustomPropertyEditor) => void;
  /** 注册自定义导出格式 */
  registerExporter: (exporter: CustomExporter) => void;
  /** 注册自定义验证规则 */
  registerValidator: (validator: CustomValidator) => void;
  /** 注册自定义工具栏按钮 */
  registerToolbarAction: (action: CustomToolbarAction) => void;
  /** 注册自定义渲染器 */
  registerRenderer: (renderer: CustomRenderer) => void;

  /** 获取编辑器状态 */
  getEditorState: () => {
    activeFilePath: string | null;
    activeWidgetLookName: string | null;
    dirty: boolean;
  };

  /** 显示通知 */
  showNotification: (message: string, type: 'info' | 'warning' | 'error') => void;

  /** i18n 翻译 */
  t: (key: string, vars?: Record<string, string | number>) => string;
}

// ─── 插件管理器 ──────────────────────────────────────────────────

class PluginManager {
  private plugins = new Map<string, Plugin>();
  private propertyEditors: CustomPropertyEditor[] = [];
  private exporters: CustomExporter[] = [];
  private validators: CustomValidator[] = [];
  private toolbarActions: CustomToolbarAction[] = [];
  private renderers: CustomRenderer[] = [];

  /**
   * 注册插件
   */
  registerPlugin(plugin: Plugin): void {
    if (this.plugins.has(plugin.manifest.id)) {
      console.warn(`Plugin "${plugin.manifest.id}" already registered`);
      return;
    }

    this.plugins.set(plugin.manifest.id, plugin);

    // 创建插件上下文
    const context: PluginContext = {
      registerPropertyEditor: (editor) => this.propertyEditors.push(editor),
      registerExporter: (exporter) => this.exporters.push(exporter),
      registerValidator: (validator) => this.validators.push(validator),
      registerToolbarAction: (action) => this.toolbarActions.push(action),
      registerRenderer: (renderer) => this.renderers.push(renderer),
      getEditorState: () => ({
        activeFilePath: null,
        activeWidgetLookName: null,
        dirty: false,
      }),
      showNotification: (message, type) => {
        console.log(`[${type.toUpperCase()}] ${message}`);
      },
      t: (key, vars) => key,
    };

    plugin.activate?.(context);
  }

  /**
   * 注销插件
   */
  unregisterPlugin(pluginId: string): void {
    const plugin = this.plugins.get(pluginId);
    if (!plugin) return;

    plugin.deactivate?.();
    this.plugins.delete(pluginId);

    // 清除该插件注册的扩展（简化实现）
    // 实际实现中需要跟踪每个插件注册了哪些扩展
  }

  /**
   * 获取所有已注册插件
   */
  getPlugins(): PluginManifest[] {
    return Array.from(this.plugins.values()).map(p => p.manifest);
  }

  /**
   * 查找匹配的属性编辑器
   */
  findPropertyEditor(propertyName: string): CustomPropertyEditor | undefined {
    return this.propertyEditors.find(editor => {
      if (typeof editor.pattern === 'string') {
        return propertyName === editor.pattern;
      }
      return editor.pattern.test(propertyName);
    });
  }

  /**
   * 获取所有导出格式
   */
  getExporters(): CustomExporter[] {
    return [...this.exporters];
  }

  /**
   * 运行所有自定义验证规则
   */
  runCustomValidators(
    widgetLook: import('@shared/model').WidgetLook,
  ): import('@shared/model').ValidationError[] {
    const errors: import('@shared/model').ValidationError[] = [];
    for (const validator of this.validators) {
      try {
        errors.push(...validator.validate(widgetLook));
      } catch (e) {
        console.warn(`Custom validator "${validator.name}" failed:`, e);
      }
    }
    return errors;
  }

  /**
   * 获取所有自定义工具栏按钮
   */
  getToolbarActions(): CustomToolbarAction[] {
    return [...this.toolbarActions];
  }

  /**
   * 获取所有自定义渲染器
   */
  getRenderers(): CustomRenderer[] {
    return [...this.renderers];
  }

  /**
   * 清除所有插件
   */
  clear(): void {
    for (const plugin of this.plugins.values()) {
      plugin.deactivate?.();
    }
    this.plugins.clear();
    this.propertyEditors = [];
    this.exporters = [];
    this.validators = [];
    this.toolbarActions = [];
    this.renderers = [];
  }
}

// ─── 导出 ────────────────────────────────────────────────────────

/** 全局插件管理器实例 */
export const pluginManager = new PluginManager();
