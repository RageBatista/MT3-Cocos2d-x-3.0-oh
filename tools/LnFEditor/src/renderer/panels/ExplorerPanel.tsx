/**
 * ExplorerPanel — 合并导航器与层级树的统一面板
 *
 * 上半部分：WidgetLook 列表（搜索 + 虚拟滚动）
 * 下半部分：选中 WL 的层级树（含状态勾选）
 * 两者通过 store.selection.widgetLookName 联动
 */

import React, { useMemo, useState } from 'react';
import { useEditorStore } from '../stores/editor-store';
import { buildLayerTree } from '../services/layer-tree-builder';
import { VirtualList, type VirtualListItem } from '../components/VirtualList';
import { useTranslation } from '../services/i18n';
import type { LayerTreeNode } from '@shared/model';

export function ExplorerPanel(): React.ReactElement {
  const { t } = useTranslation();
  const [treeSearch, setTreeSearch] = useState('');

  return (
    <div className="explorer-panel">
      <div className="explorer-section explorer-wl-list">
        <div className="panel-header">{t('panel.widgetLooks')}</div>
        <WidgetLookList />
      </div>
      <div className="explorer-divider" />
      <div className="explorer-section explorer-tree">
        <div className="panel-header">
          <span>{t('panel.layerTree')}</span>
        </div>
        <div className="tree-search-bar">
          <input
            type="text"
            className="tree-search-input"
            value={treeSearch}
            onChange={e => setTreeSearch(e.target.value)}
            placeholder={t('panel.searchWidgetLook')}
          />
        </div>
        <LayerTree searchQuery={treeSearch} />
      </div>
    </div>
  );
}

/** WidgetLook 列表子组件 */
function WidgetLookList(): React.ReactElement {
  const { t } = useTranslation();
  const activeFile = useEditorStore(s => s.files.activeFilePath);
  const openedFiles = useEditorStore(s => s.files.openedFiles);
  const selectWidgetLook = useEditorStore(s => s.selectWidgetLook);
  const wlName = useEditorStore(s => s.selection.widgetLookName);

  const fileState = activeFile ? openedFiles.get(activeFile) : null;
  const widgetLookNames = fileState ? Array.from(fileState.loadedWidgetLooks.keys()) : [];

  const items: VirtualListItem[] = useMemo(() =>
    widgetLookNames.map(name => ({
      key: name,
      label: name,
      icon: '📦',
      data: null,
    })),
    [widgetLookNames]
  );

  return (
    <VirtualList
      items={items}
      selectedItemKey={wlName}
      onSelect={selectWidgetLook}
      searchable
      searchPlaceholder={t('panel.searchWidgetLook')}
      emptyHint={t('panel.noFileOpened')}
    />
  );
}

/** 层级树子组件 */
function LayerTree({ searchQuery }: { searchQuery: string }): React.ReactElement {
  const { t } = useTranslation();
  const wlName = useEditorStore(s => s.selection.widgetLookName);
  const activeFile = useEditorStore(s => s.files.activeFilePath);
  const openedFiles = useEditorStore(s => s.files.openedFiles);
  const selectNode = useEditorStore(s => s.selectNode);
  const selectedNodeIds = useEditorStore(s => s.selection.selectedNodeIds);
  const activeStates = useEditorStore(s => s.preview.activeStates);
  const setActiveStates = useEditorStore(s => s.setActiveStates);

  const tree = useMemo(() => {
    if (!activeFile || !wlName) return null;
    const fileState = openedFiles.get(activeFile);
    if (!fileState) return null;
    const wl = fileState.loadedWidgetLooks.get(wlName);
    if (!wl) return null;
    return buildLayerTree(wl, activeStates, fileState.loadedWidgetLooks);
  }, [activeFile, wlName, openedFiles, activeStates]);

  if (!tree) {
    return (
      <div className="panel-content empty-hint">{t('panel.selectWidgetLook')}</div>
    );
  }

  return (
    <div className="panel-content layer-tree-content">
      <TreeNode
        node={tree}
        selectedIds={selectedNodeIds}
        onSelect={selectNode}
        depth={0}
        searchQuery={searchQuery}
        activeStates={activeStates}
        onToggleState={(stateName) => {
          const idx = activeStates.indexOf(stateName);
          if (idx >= 0) {
            setActiveStates(activeStates.filter(s => s !== stateName));
          } else {
            setActiveStates([...activeStates, stateName]);
          }
        }}
      />
    </div>
  );
}

/** 树节点渲染组件 */
function TreeNode({
  node,
  selectedIds,
  onSelect,
  depth,
  searchQuery,
  activeStates,
  onToggleState,
}: {
  node: LayerTreeNode;
  selectedIds: string[];
  onSelect: (id: string, multi: boolean) => void;
  depth: number;
  searchQuery: string;
  activeStates: string[];
  onToggleState: (stateName: string) => void;
}): React.ReactElement | null {
  const [expanded, setExpanded] = useState(depth < 2);
  const isSelected = selectedIds.includes(node.id);
  const hasChildren = node.children.length > 0;

  const isStateNode = node.id.startsWith('state:');
  const stateName = isStateNode ? node.id.replace('state:', '') : null;
  const isStateActive = stateName ? activeStates.includes(stateName) : false;

  if (searchQuery && depth > 0) {
    const matchesSelf = node.name.toLowerCase().includes(searchQuery.toLowerCase());
    const hasMatchingChild = node.children.some(child =>
      child.name.toLowerCase().includes(searchQuery.toLowerCase())
    );
    if (!matchesSelf && !hasMatchingChild) return null;
  }

  return (
    <div className="tree-node">
      <div
        className={`tree-node-header ${isSelected ? 'selected' : ''}`}
        style={{ paddingLeft: depth * 16 + 4 }}
        onClick={(e) => {
          onSelect(node.id, e.ctrlKey || e.metaKey);
          if (hasChildren) setExpanded(!expanded);
        }}
      >
        {hasChildren ? (expanded ? '▼' : '▶') : '·'}
        {isStateNode && stateName ? (
          <input
            type="checkbox"
            className="state-checkbox"
            checked={isStateActive}
            onChange={(e) => {
              e.stopPropagation();
              onToggleState(stateName);
            }}
            onClick={(e) => e.stopPropagation()}
          />
        ) : (
          <span className="tree-icon">{node.icon}</span>
        )}
        <span className="tree-label">{node.name}</span>
      </div>
      {expanded && hasChildren && (
        <div className="tree-children">
          {node.children.map(child => (
            <TreeNode
              key={child.id}
              node={child}
              selectedIds={selectedIds}
              onSelect={onSelect}
              depth={depth + 1}
              searchQuery={searchQuery}
              activeStates={activeStates}
              onToggleState={onToggleState}
            />
          ))}
        </div>
      )}
    </div>
  );
}
