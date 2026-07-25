/** CEGUI 标准 StateImagery 状态名 */
export const CEGUI_STATES = {
  NORMAL: 'Normal',
  HOVER: 'Hover',
  PUSHED: 'Pushed',
  PUSHED_OFF: 'PushedOff',
  DISABLED: 'Disabled',
  SELECTED_NORMAL: 'SelectedNormal',
  SELECTED_HOVER: 'SelectedHover',
  SELECTED_PUSHED: 'SelectedPushed',
  ACTIVE_WITH_TITLE_FRAME: 'ActiveWithTitleWithFrame',
  INACTIVE_WITH_TITLE_FRAME: 'InactiveWithTitleWithFrame',
  DISABLED_WITH_TITLE_FRAME: 'DisabledWithTitleWithFrame',
  ACTIVE_WITH_TITLE_NO_FRAME: 'ActiveWithTitleNoFrame',
  INACTIVE_WITH_TITLE_NO_FRAME: 'InactiveWithTitleNoFrame',
  DISABLED_WITH_TITLE_NO_FRAME: 'DisabledWithTitleNoFrame',
  ACTIVE_NO_TITLE_FRAME: 'ActiveNoTitleWithFrame',
  INACTIVE_NO_TITLE_FRAME: 'InactiveNoTitleWithFrame',
  DISABLED_NO_TITLE_FRAME: 'DisabledNoTitleWithFrame',
  ACTIVE_NO_TITLE_NO_FRAME: 'ActiveNoTitleNoFrame',
  INACTIVE_NO_TITLE_NO_FRAME: 'InactiveNoTitleNoFrame',
  DISABLED_NO_TITLE_NO_FRAME: 'DisabledNoTitleNoFrame',
  ENABLED: 'Enabled',
} as const;

/** 按钮类控件常用状态组 */
export const BUTTON_STATES = [
  CEGUI_STATES.NORMAL,
  CEGUI_STATES.HOVER,
  CEGUI_STATES.PUSHED,
  CEGUI_STATES.PUSHED_OFF,
  CEGUI_STATES.DISABLED,
] as const;

/** 窗口类控件常用状态组 */
export const FRAME_WINDOW_STATES = [
  CEGUI_STATES.ACTIVE_WITH_TITLE_FRAME,
  CEGUI_STATES.INACTIVE_WITH_TITLE_FRAME,
  CEGUI_STATES.DISABLED_WITH_TITLE_FRAME,
  CEGUI_STATES.ACTIVE_WITH_TITLE_NO_FRAME,
  CEGUI_STATES.INACTIVE_WITH_TITLE_NO_FRAME,
  CEGUI_STATES.DISABLED_WITH_TITLE_NO_FRAME,
  CEGUI_STATES.ACTIVE_NO_TITLE_FRAME,
  CEGUI_STATES.INACTIVE_NO_TITLE_FRAME,
  CEGUI_STATES.DISABLED_NO_TITLE_FRAME,
  CEGUI_STATES.ACTIVE_NO_TITLE_NO_FRAME,
  CEGUI_STATES.INACTIVE_NO_TITLE_NO_FRAME,
  CEGUI_STATES.DISABLED_NO_TITLE_NO_FRAME,
] as const;

/** 默认画布视口参数 */
export const DEFAULT_VIEWPORT = {
  offsetX: 0,
  offsetY: 0,
  scale: 1.0,
  gridSize: 10,
  showGrid: true,
  showRulers: true,
  snapEnabled: true,
  snapThreshold: 5,
} as const;

/** 默认模拟父控件尺寸 */
export const DEFAULT_PARENT_SIZE = {
  width: 1136,
  height: 640,
} as const;

/** 纹理缓存 LRU 最大容量 */
export const TEXTURE_CACHE_MAX_SIZE = 200;

/** 历史记录最大深度 */
export const HISTORY_MAX_DEPTH = 50;

/** MT3 项目 UI 资源根路径（相对于项目根目录） */
export const MT3_UI_RESOURCE_RELATIVE_PATH = 'client/resource/res/ui';

/** 支持的图像文件扩展名 */
export const SUPPORTED_IMAGE_EXTENSIONS = ['.png', '.jpg', '.jpeg', '.tga', '.bmp'];
