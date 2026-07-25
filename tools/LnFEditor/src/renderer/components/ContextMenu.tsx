/**
 * ContextMenu — 右键上下文菜单组件
 *
 * 提供可复用的右键菜单，支持：
 * - 分隔线
 * - 子菜单
 * - 图标
 * - 快捷键提示
 * - 禁用状态
 */

import React, { useCallback, useEffect, useRef, useState } from 'react';

// ─── 类型定义 ────────────────────────────────────────────────────

export interface MenuItemDef {
  /** 唯一标识 */
  id: string;
  /** 显示文本 */
  label: string;
  /** 可选图标 */
  icon?: string;
  /** 快捷键提示 */
  shortcut?: string;
  /** 是否禁用 */
  disabled?: boolean;
  /** 点击回调 */
  onClick?: () => void;
  /** 子菜单 */
  submenu?: MenuItemDef[];
}

export interface ContextMenuProps {
  /** 菜单项 */
  items: MenuItemDef[];
  /** 菜单位置 X（屏幕坐标） */
  x: number;
  /** 菜单位置 Y（屏幕坐标） */
  y: number;
  /** 关闭回调 */
  onClose: () => void;
}

// ─── 主组件 ──────────────────────────────────────────────────────

export function ContextMenu({ items, x, y, onClose }: ContextMenuProps): React.ReactElement {
  const menuRef = useRef<HTMLDivElement>(null);

  // 点击外部关闭
  useEffect(() => {
    const handleClickOutside = (e: MouseEvent) => {
      if (menuRef.current && !menuRef.current.contains(e.target as Node)) {
        onClose();
      }
    };

    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === 'Escape') onClose();
    };

    // 延迟绑定，避免当前右键事件立即关闭
    const timer = setTimeout(() => {
      document.addEventListener('mousedown', handleClickOutside);
      document.addEventListener('keydown', handleKeyDown);
    }, 0);

    return () => {
      clearTimeout(timer);
      document.removeEventListener('mousedown', handleClickOutside);
      document.removeEventListener('keydown', handleKeyDown);
    };
  }, [onClose]);

  // 调整位置确保不超出视口
  const adjustedPos = useAdjustedPosition(x, y, menuRef);

  return (
    <div
      ref={menuRef}
      className="context-menu"
      style={{ left: adjustedPos.x, top: adjustedPos.y }}
    >
      {items.map((item, i) => (
        <MenuItem key={item.id} item={item} onClose={onClose} />
      ))}
    </div>
  );
}

// ─── 菜单项 ──────────────────────────────────────────────────────

function MenuItem({ item, onClose }: { item: MenuItemDef; onClose: () => void }): React.ReactElement {
  const [showSubmenu, setShowSubmenu] = useState(false);
  const itemRef = useRef<HTMLDivElement>(null);

  const handleClick = useCallback(() => {
    if (item.disabled) return;
    if (item.submenu) {
      setShowSubmenu(!showSubmenu);
      return;
    }
    item.onClick?.();
    onClose();
  }, [item, onClose, showSubmenu]);

  if (item.id === '---') {
    return <div className="context-menu-separator" />;
  }

  return (
    <div
      ref={itemRef}
      className={`context-menu-item ${item.disabled ? 'disabled' : ''} ${showSubmenu ? 'active' : ''}`}
      onClick={handleClick}
      onMouseEnter={() => item.submenu && setShowSubmenu(true)}
      onMouseLeave={() => item.submenu && setShowSubmenu(false)}
    >
      <span className="menu-item-icon">{item.icon || ''}</span>
      <span className="menu-item-label">{item.label}</span>
      {item.shortcut && <span className="menu-item-shortcut">{item.shortcut}</span>}
      {item.submenu && <span className="menu-item-arrow">▶</span>}

      {showSubmenu && item.submenu && (
        <div className="context-submenu">
          {item.submenu.map(sub => (
            <MenuItem key={sub.id} item={sub} onClose={onClose} />
          ))}
        </div>
      )}
    </div>
  );
}

// ─── 位置调整 Hook ───────────────────────────────────────────────

function useAdjustedPosition(
  x: number,
  y: number,
  menuRef: React.RefObject<HTMLDivElement | null>,
): { x: number; y: number } {
  const [pos, setPos] = useState({ x, y });

  useEffect(() => {
    const menu = menuRef.current;
    if (!menu) return;

    const rect = menu.getBoundingClientRect();
    const vw = window.innerWidth;
    const vh = window.innerHeight;

    let adjustedX = x;
    let adjustedY = y;

    if (x + rect.width > vw) {
      adjustedX = vw - rect.width - 4;
    }
    if (y + rect.height > vh) {
      adjustedY = vh - rect.height - 4;
    }

    setPos({ x: Math.max(0, adjustedX), y: Math.max(0, adjustedY) });
  }, [x, y, menuRef]);

  return pos;
}

// ─── Hook: 使用右键菜单 ──────────────────────────────────────────

export function useContextMenu(
  menuItemsFactory: (x: number, y: number) => MenuItemDef[],
): {
  contextMenu: React.ReactElement | null;
  onContextMenu: (e: React.MouseEvent) => void;
} {
  const [menuState, setMenuState] = useState<{
    visible: boolean;
    x: number;
    y: number;
    items: MenuItemDef[];
  }>({ visible: false, x: 0, y: 0, items: [] });

  const onContextMenu = useCallback((e: React.MouseEvent) => {
    e.preventDefault();
    const items = menuItemsFactory(e.clientX, e.clientY);
    setMenuState({ visible: true, x: e.clientX, y: e.clientY, items });
  }, [menuItemsFactory]);

  const onClose = useCallback(() => {
    setMenuState(prev => ({ ...prev, visible: false }));
  }, []);

  const contextMenu = menuState.visible ? (
    <ContextMenu
      items={menuState.items}
      x={menuState.x}
      y={menuState.y}
      onClose={onClose}
    />
  ) : null;

  return { contextMenu, onContextMenu };
}

// ─── 预定义菜单项工厂 ────────────────────────────────────────────

/** Canvas 右键菜单 */
export function createCanvasMenuItems(opts: {
  hasSelection: boolean;
  canUndo: boolean;
  canRedo: boolean;
  onUndo: () => void;
  onRedo: () => void;
  onCopy: () => void;
  onPaste: () => void;
  onDelete: () => void;
  onSelectAll: () => void;
  onResetView: () => void;
  onExportPng: () => void;
}): MenuItemDef[] {
  return [
    {
      id: 'undo', label: 'Undo', icon: '↩', shortcut: 'Ctrl+Z',
      disabled: !opts.canUndo, onClick: opts.onUndo,
    },
    {
      id: 'redo', label: 'Redo', icon: '↪', shortcut: 'Ctrl+Y',
      disabled: !opts.canRedo, onClick: opts.onRedo,
    },
    { id: '---', label: '' },
    {
      id: 'copy', label: 'Copy Component', icon: '📋', shortcut: 'Ctrl+C',
      disabled: !opts.hasSelection, onClick: opts.onCopy,
    },
    {
      id: 'paste', label: 'Paste Component', icon: '📎', shortcut: 'Ctrl+V',
      onClick: opts.onPaste,
    },
    {
      id: 'delete', label: 'Delete Component', icon: '🗑', shortcut: 'Del',
      disabled: !opts.hasSelection, onClick: opts.onDelete,
    },
    { id: '---', label: '' },
    {
      id: 'selectall', label: 'Select All', shortcut: 'Ctrl+A',
      onClick: opts.onSelectAll,
    },
    { id: '---', label: '' },
    {
      id: 'resetview', label: 'Reset View', shortcut: 'Ctrl+0',
      onClick: opts.onResetView,
    },
    {
      id: 'exportpng', label: 'Export as PNG', icon: '🖼',
      onClick: opts.onExportPng,
    },
  ];
}

/** Navigator 右键菜单 */
export function createNavigatorMenuItems(opts: {
  widgetLookName: string | null;
  onRename: () => void;
  onDuplicate: () => void;
  onDelete: () => void;
  onAddNew: () => void;
}): MenuItemDef[] {
  return [
    {
      id: 'add', label: 'Add WidgetLook', icon: '➕',
      onClick: opts.onAddNew,
    },
    { id: '---', label: '' },
    {
      id: 'rename', label: 'Rename', icon: '✏', shortcut: 'F2',
      disabled: !opts.widgetLookName, onClick: opts.onRename,
    },
    {
      id: 'duplicate', label: 'Duplicate', icon: '📋', shortcut: 'Ctrl+D',
      disabled: !opts.widgetLookName, onClick: opts.onDuplicate,
    },
    {
      id: 'delete', label: 'Delete', icon: '🗑', shortcut: 'Del',
      disabled: !opts.widgetLookName, onClick: opts.onDelete,
    },
  ];
}
