/**
 * 虚拟滚动列表组件 — 仅渲染可见区域的列表项
 *
 * 用于 ExplorerPanel 显示 500+ WidgetLook 名称时保持流畅滚动。
 * 支持搜索过滤、键盘导航。
 */

import React, { useCallback, useEffect, useMemo, useRef, useState } from 'react';

export interface VirtualListItem {
  key: string;
  label: string;
  icon?: string;
  data: unknown;
}

interface VirtualListProps {
  items: VirtualListItem[];
  selectedItemKey: string | null;
  onSelect: (key: string) => void;
  itemHeight?: number;
  overscan?: number;
  searchable?: boolean;
  searchPlaceholder?: string;
  emptyHint?: string;
}

export function VirtualList({
  items,
  selectedItemKey,
  onSelect,
  itemHeight = 28,
  overscan = 10,
  searchable = true,
  searchPlaceholder = '搜索...',
  emptyHint = '无项目',
}: VirtualListProps): React.ReactElement {
  const [scrollTop, setScrollTop] = useState(0);
  const [containerHeight, setContainerHeight] = useState(400);
  const [searchQuery, setSearchQuery] = useState('');
  const containerRef = useRef<HTMLDivElement>(null);

  // 搜索过滤
  const filteredItems = useMemo(() => {
    if (!searchQuery.trim()) return items;
    const q = searchQuery.toLowerCase();
    return items.filter(item => item.label.toLowerCase().includes(q));
  }, [items, searchQuery]);

  // 计算可见范围
  const totalHeight = filteredItems.length * itemHeight;
  const startIndex = Math.max(0, Math.floor(scrollTop / itemHeight) - overscan);
  const endIndex = Math.min(
    filteredItems.length,
    Math.ceil((scrollTop + containerHeight) / itemHeight) + overscan,
  );

  const visibleItems = filteredItems.slice(startIndex, endIndex);

  // 监听容器大小
  useEffect(() => {
    const container = containerRef.current;
    if (!container) return;

    const observer = new ResizeObserver(entries => {
      for (const entry of entries) {
        setContainerHeight(Math.floor(entry.contentRect.height));
      }
    });
    observer.observe(container);
    return () => observer.disconnect();
  }, []);

  const handleScroll = useCallback((e: React.UIEvent<HTMLDivElement>) => {
    setScrollTop(e.currentTarget.scrollTop);
  }, []);

  const handleKeyDown = useCallback((e: React.KeyboardEvent) => {
    if (!filteredItems.length) return;

    const currentIdx = selectedItemKey
      ? filteredItems.findIndex(item => item.key === selectedItemKey)
      : -1;

    if (e.key === 'ArrowDown') {
      e.preventDefault();
      const nextIdx = Math.min(currentIdx + 1, filteredItems.length - 1);
      if (nextIdx >= 0) onSelect(filteredItems[nextIdx].key);
    } else if (e.key === 'ArrowUp') {
      e.preventDefault();
      const prevIdx = Math.max(currentIdx - 1, 0);
      onSelect(filteredItems[prevIdx].key);
    }
  }, [filteredItems, selectedItemKey, onSelect]);

  return (
    <div className="virtual-list-container">
      {searchable && (
        <div className="virtual-list-search">
          <input
            type="text"
            value={searchQuery}
            onChange={e => setSearchQuery(e.target.value)}
            placeholder={searchPlaceholder}
            className="search-input"
          />
          {searchQuery && (
            <button className="search-clear" onClick={() => setSearchQuery('')}>✕</button>
          )}
        </div>
      )}

      <div className="virtual-list-stats">
        {filteredItems.length !== items.length
          ? `${filteredItems.length} / ${items.length}`
          : `${items.length} 项`}
      </div>

      <div
        ref={containerRef}
        className="virtual-list-scroll"
        onScroll={handleScroll}
        onKeyDown={handleKeyDown}
        tabIndex={0}
      >
        <div style={{ height: totalHeight, position: 'relative' }}>
          {visibleItems.map((item, i) => {
            const actualIndex = startIndex + i;
            const isSelected = item.key === selectedItemKey;

            return (
              <div
                key={item.key}
                className={`virtual-list-item ${isSelected ? 'selected' : ''}`}
                style={{
                  position: 'absolute',
                  top: actualIndex * itemHeight,
                  height: itemHeight,
                  left: 0,
                  right: 0,
                }}
                onClick={() => onSelect(item.key)}
              >
                {item.icon && <span className="item-icon">{item.icon}</span>}
                <span className="item-label" title={item.label}>
                  {item.label}
                </span>
              </div>
            );
          })}
        </div>

        {filteredItems.length === 0 && (
          <div className="virtual-list-empty">{emptyHint}</div>
        )}
      </div>
    </div>
  );
}
