/**
 * InspectorPanel — 合并属性面板、状态控制与资源浏览器的统一面板
 *
 * 三个可折叠分区：
 * 1. Properties — 当前选中元素的属性编辑器
 * 2. State Control — 状态切换与父控件尺寸
 * 3. Resources — 图像资源浏览器
 *
 * 数据联动：选中层级树节点 → Properties 自动切换编辑器
 *          Resources 拖拽 → Properties ImageRef 字段更新
 */

import React, { useCallback, useMemo, useState } from 'react';
import { useEditorStore } from '../stores/editor-store';
import { AreaEditor } from '../components/DimEditor';
import { textureCache } from '../services/texture-cache';
import { useTranslation } from '../services/i18n';
import { parseComponentNodeId } from '@shared/model';
import type {
  WidgetLook,
  AreaDef,
  FrameComponent,
  ImageryComponent,
  TextComponent,
  ImagesetResource,
  SubImageDef,
} from '@shared/model';

export function InspectorPanel(): React.ReactElement {
  const { t } = useTranslation();
  const [activeTab, setActiveTab] = useState<'properties' | 'resources'>('properties');

  return (
    <div className="inspector-panel">
      <div className="inspector-tabs">
        <button
          className={`inspector-tab ${activeTab === 'properties' ? 'active' : ''}`}
          onClick={() => setActiveTab('properties')}
        >
          {t('panel.properties')}
        </button>
        <button
          className={`inspector-tab ${activeTab === 'resources' ? 'active' : ''}`}
          onClick={() => setActiveTab('resources')}
        >
          {t('panel.images')}
        </button>
      </div>
      <div className="inspector-content">
        {activeTab === 'properties' ? <PropertiesSection /> : <ResourcesSection />}
      </div>
    </div>
  );
}

/** 属性编辑区 */
function PropertiesSection(): React.ReactElement {
  const { t } = useTranslation();
  const wlName = useEditorStore(s => s.selection.widgetLookName);
  const activeFile = useEditorStore(s => s.files.activeFilePath);
  const openedFiles = useEditorStore(s => s.files.openedFiles);
  const selectedNodeIds = useEditorStore(s => s.selection.selectedNodeIds);
  const parentWidth = useEditorStore(s => s.preview.parentWidth);
  const parentHeight = useEditorStore(s => s.preview.parentHeight);

  const fileState = useMemo(() => (
    activeFile ? openedFiles.get(activeFile) ?? null : null
  ), [activeFile, openedFiles]);

  const wl = useMemo((): WidgetLook | null => {
    if (!fileState || !wlName) return null;
    return fileState.loadedWidgetLooks.get(wlName) || null;
  }, [fileState, wlName]);

  const selectedComponent = useMemo(() => {
    if (!fileState || !wl || selectedNodeIds.length === 0) return null;
    const componentRef = parseComponentNodeId(selectedNodeIds[0]);
    if (!componentRef) return null;

    const targetWidgetLook = componentRef.look
      ? fileState.loadedWidgetLooks.get(componentRef.look)
      : wl;
    if (!targetWidgetLook) return null;

    const section = targetWidgetLook.imagerySections.find(s => s.name === componentRef.sectionName);
    if (!section) return null;

    if (componentRef.componentType === 'frame') {
      return {
        type: 'frame' as const,
        widgetLook: targetWidgetLook,
        section,
        index: componentRef.componentIndex,
        component: section.frameComponents[componentRef.componentIndex],
      };
    }
    if (componentRef.componentType === 'imagery') {
      return {
        type: 'imagery' as const,
        widgetLook: targetWidgetLook,
        section,
        index: componentRef.componentIndex,
        component: section.imageryComponents[componentRef.componentIndex],
      };
    }
    if (componentRef.componentType === 'text') {
      return {
        type: 'text' as const,
        widgetLook: targetWidgetLook,
        section,
        index: componentRef.componentIndex,
        component: section.textComponents[componentRef.componentIndex],
      };
    }

    return null;
  }, [fileState, wl, selectedNodeIds]);

  if (!wl) {
    return (
      <div className="panel-content empty-hint">{t('panel.selectWidgetLook')}</div>
    );
  }

  return (
    <div className="properties-content">
      <PropertySection title={t('property.widgetLook')}>
        <EditableProperty
          label={t('property.name')}
          value={wl.name}
          readOnly
        />
      </PropertySection>

      {wl.propertyDefinitions.length > 0 && (
        <PropertySection title={t('property.propertyDefinitions')}>
          {wl.propertyDefinitions.map((pd, i) => (
            <EditableProperty
              key={`pd-${i}`}
              label={pd.name}
              value={pd.initialValue}
              onChange={(newVal) => updatePropertyDefinition(wl, wlName!, i, newVal)}
            />
          ))}
        </PropertySection>
      )}

      {wl.properties.length > 0 && (
        <PropertySection title={t('property.properties')}>
          {wl.properties.map((p, i) => (
            <EditableProperty
              key={`p-${i}`}
              label={p.name}
              value={p.value}
              onChange={(newVal) => updateProperty(wl, wlName!, i, newVal)}
            />
          ))}
        </PropertySection>
      )}

      {selectedComponent && selectedComponent.type === 'frame' && selectedComponent.component && (
        <FrameComponentProperties
          wl={selectedComponent.widgetLook}
          wlName={selectedComponent.widgetLook.name}
          sectionName={selectedComponent.section.name}
          index={selectedComponent.index}
          component={selectedComponent.component}
          parentWidth={parentWidth}
          parentHeight={parentHeight}
        />
      )}

      {selectedComponent && selectedComponent.type === 'imagery' && selectedComponent.component && (
        <ImageryComponentProperties
          wl={selectedComponent.widgetLook}
          wlName={selectedComponent.widgetLook.name}
          sectionName={selectedComponent.section.name}
          index={selectedComponent.index}
          component={selectedComponent.component}
          parentWidth={parentWidth}
          parentHeight={parentHeight}
        />
      )}

      {selectedComponent && selectedComponent.type === 'text' && selectedComponent.component && (
        <TextComponentProperties
          wl={selectedComponent.widgetLook}
          wlName={selectedComponent.widgetLook.name}
          sectionName={selectedComponent.section.name}
          index={selectedComponent.index}
          component={selectedComponent.component}
          parentWidth={parentWidth}
          parentHeight={parentHeight}
        />
      )}

      {wl.imagerySections.length > 0 && (
        <PropertySection title={t('property.imagerySections')}>
          {wl.imagerySections.map((sec, i) => (
            <div key={`sec-${i}`} className="property-row">
              <span className="property-label">🎨 {sec.name}</span>
              <span className="property-value-readonly">
                {sec.frameComponents.length}{t('property.frame')} {sec.imageryComponents.length}{t('property.imagery')} {sec.textComponents.length}{t('property.textComp')}
              </span>
            </div>
          ))}
        </PropertySection>
      )}

      {wl.stateImagerys.length > 0 && (
        <PropertySection title={t('property.stateImagery')}>
          {wl.stateImagerys.map((si, i) => (
            <div key={`si-${i}`} className="property-row">
              <span className="property-label">⚡ {si.name}</span>
              <span className="property-value-readonly">{si.layers.length} {t('property.layers')}</span>
            </div>
          ))}
        </PropertySection>
      )}
    </div>
  );
}

/** FrameComponent 属性编辑器 */
function FrameComponentProperties({
  wl, wlName, sectionName, index, component, parentWidth, parentHeight,
}: {
  wl: WidgetLook;
  wlName: string;
  sectionName: string;
  index: number;
  component: FrameComponent;
  parentWidth: number;
  parentHeight: number;
}): React.ReactElement {
  const handleAreaChange = useCallback((newArea: AreaDef) => {
    updateComponentArea(wl, wlName!, sectionName, 'frame', index, newArea);
  }, [wl, wlName, sectionName, index]);

  return (
    <PropertySection title={`Frame #${index} (${sectionName})`}>
      <AreaEditor
        area={component.area}
        onChange={handleAreaChange}
        parentWidth={parentWidth}
        parentHeight={parentHeight}
      />
      {component.vertFormat && (
        <div className="property-row">
          <span className="property-label">VertFormat</span>
          <span className="property-value-readonly">{component.vertFormat}</span>
        </div>
      )}
      {component.horzFormat && (
        <div className="property-row">
          <span className="property-label">HorzFormat</span>
          <span className="property-value-readonly">{component.horzFormat}</span>
        </div>
      )}
      {Object.entries(component.images).map(([type, ref]) => {
        if (!ref) return null;
        return (
          <div key={type} className="property-row image-ref">
            <span className="property-label">{type}</span>
            <span className="property-value-readonly">{ref.imageset}/{ref.image}</span>
          </div>
        );
      })}
      {Object.entries(component.imageProperties ?? {}).map(([type, propertyName]) => (
        <div key={`prop-${type}`} className="property-row">
          <span className="property-label">{type} ImageProperty</span>
          <span className="property-value-readonly">{propertyName}</span>
        </div>
      ))}
      {component.colourRectProperty && (
        <div className="property-row">
          <span className="property-label">ColourRectProperty</span>
          <span className="property-value-readonly">{component.colourRectProperty}</span>
        </div>
      )}
    </PropertySection>
  );
}

/** ImageryComponent 属性编辑器 */
function ImageryComponentProperties({
  wl, wlName, sectionName, index, component, parentWidth, parentHeight,
}: {
  wl: WidgetLook;
  wlName: string;
  sectionName: string;
  index: number;
  component: ImageryComponent;
  parentWidth: number;
  parentHeight: number;
}): React.ReactElement {
  const handleAreaChange = useCallback((newArea: AreaDef) => {
    updateComponentArea(wl, wlName!, sectionName, 'imagery', index, newArea);
  }, [wl, wlName, sectionName, index]);

  return (
    <PropertySection title={`Imagery #${index} (${sectionName})`}>
      <AreaEditor
        area={component.area}
        onChange={handleAreaChange}
        parentWidth={parentWidth}
        parentHeight={parentHeight}
      />
      {component.image && (
        <div className="property-row image-ref">
          <span className="property-label">Image</span>
          <span className="property-value-readonly">{component.image.imageset}/{component.image.image}</span>
        </div>
      )}
      {component.imageProperty && (
        <div className="property-row">
          <span className="property-label">ImageProperty</span>
          <span className="property-value-readonly">{component.imageProperty}</span>
        </div>
      )}
      {component.colourRectProperty && (
        <div className="property-row">
          <span className="property-label">ColourRectProperty</span>
          <span className="property-value-readonly">{component.colourRectProperty}</span>
        </div>
      )}
      {component.vertFormat && (
        <div className="property-row">
          <span className="property-label">VertFormat</span>
          <span className="property-value-readonly">{component.vertFormat}</span>
        </div>
      )}
      {component.horzFormat && (
        <div className="property-row">
          <span className="property-label">HorzFormat</span>
          <span className="property-value-readonly">{component.horzFormat}</span>
        </div>
      )}
    </PropertySection>
  );
}

/** TextComponent 属性编辑器 */
function TextComponentProperties({
  wl, wlName, sectionName, index, component, parentWidth, parentHeight,
}: {
  wl: WidgetLook;
  wlName: string;
  sectionName: string;
  index: number;
  component: TextComponent;
  parentWidth: number;
  parentHeight: number;
}): React.ReactElement {
  const handleAreaChange = useCallback((newArea: AreaDef) => {
    updateComponentArea(wl, wlName!, sectionName, 'text', index, newArea);
  }, [wl, wlName, sectionName, index]);

  return (
    <PropertySection title={`Text #${index} (${sectionName})`}>
      <AreaEditor
        area={component.area}
        onChange={handleAreaChange}
        parentWidth={parentWidth}
        parentHeight={parentHeight}
      />
      {component.font && (
        <div className="property-row">
          <span className="property-label">Font</span>
          <span className="property-value-readonly">{component.font}</span>
        </div>
      )}
      {component.text && (
        <div className="property-row">
          <span className="property-label">Text</span>
          <span className="property-value-readonly">{component.text}</span>
        </div>
      )}
      {component.borderEnableProperty && (
        <div className="property-row">
          <span className="property-label">BorderEnable</span>
          <span className="property-value-readonly">{component.borderEnableProperty}</span>
        </div>
      )}
      {component.borderColourProperty && (
        <div className="property-row">
          <span className="property-label">BorderColour</span>
          <span className="property-value-readonly">{component.borderColourProperty}</span>
        </div>
      )}
      {component.colourRectProperty && (
        <div className="property-row">
          <span className="property-label">ColourRectProperty</span>
          <span className="property-value-readonly">{component.colourRectProperty}</span>
        </div>
      )}
    </PropertySection>
  );
}

/** 资源浏览区 */
function ResourcesSection(): React.ReactElement {
  const { t } = useTranslation();
  const activeFile = useEditorStore(s => s.files.activeFilePath);
  const openedFiles = useEditorStore(s => s.files.openedFiles);
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedImageset, setSelectedImageset] = useState<string | null>(null);
  const [viewMode, setViewMode] = useState<'grid' | 'list'>('grid');

  const fileState = activeFile ? openedFiles.get(activeFile) : null;
  const imagesets = fileState?.imagesets;

  const imagesetNames = useMemo(() =>
    imagesets ? Array.from(imagesets.keys()) : [],
    [imagesets]
  );

  interface ImageEntry {
    imageset: string;
    name: string;
    def: SubImageDef;
    dataUrl: string | null;
  }

  const imageEntries: ImageEntry[] = useMemo(() => {
    const entries: ImageEntry[] = [];
    if (!imagesets) return entries;

    const targetSets = selectedImageset
      ? [[selectedImageset, imagesets.get(selectedImageset) ?? null] as const]
      : Array.from(imagesets.entries()).map(([name, imageset]) => [name, imageset] as const);

    for (const [imagesetName, imageset] of targetSets) {
      if (!imageset) continue;
      for (const [name, def] of imageset.subImages) {
        const dataUrl = textureCache.getSubImageDataUrl(imagesetName, name);
        entries.push({ imageset: imagesetName, name, def, dataUrl });
      }
    }
    return entries;
  }, [imagesets, selectedImageset]);

  const filteredEntries = useMemo(() => {
    if (!searchQuery.trim()) return imageEntries;
    const q = searchQuery.toLowerCase();
    return imageEntries.filter(e =>
      e.name.toLowerCase().includes(q) ||
      e.imageset.toLowerCase().includes(q)
    );
  }, [imageEntries, searchQuery]);

  const totalImages = useMemo(() => {
    if (!imagesets) return 0;
    let count = 0;
    for (const is of imagesets.values()) {
      count += is.subImages.size;
    }
    return count;
  }, [imagesets]);

  const handleSelectImage = useCallback((entry: ImageEntry) => {
    const ref = `${entry.imageset}/${entry.name}`;
    navigator.clipboard.writeText(ref).catch(() => {});
  }, []);

  return (
    <div className="resources-content">
      <div className="resources-toolbar">
        <input
          type="text"
          className="search-input"
          value={searchQuery}
          onChange={e => setSearchQuery(e.target.value)}
          placeholder={t('imageBrowser.searchPlaceholder')}
        />
        <div className="view-mode-toggle">
          <button
            className={viewMode === 'grid' ? 'active' : ''}
            onClick={() => setViewMode('grid')}
            title={t('imageBrowser.gridView')}
          >
            ▦
          </button>
          <button
            className={viewMode === 'list' ? 'active' : ''}
            onClick={() => setViewMode('list')}
            title={t('imageBrowser.listView')}
          >
            ☰
          </button>
        </div>
      </div>

      <div className="imageset-selector compact">
        <div
          className={`imageset-item ${selectedImageset === null ? 'selected' : ''}`}
          onClick={() => setSelectedImageset(null)}
        >
          {t('imageBrowser.all')} ({totalImages})
        </div>
        {imagesetNames.map(name => {
          const is = imagesets!.get(name)!;
          return (
            <div
              key={name}
              className={`imageset-item ${selectedImageset === name ? 'selected' : ''}`}
              onClick={() => setSelectedImageset(name)}
            >
              🖼 {name} ({is.subImages.size})
            </div>
          );
        })}
      </div>

      <div className={`image-list ${viewMode}`}>
        {filteredEntries.length === 0 && (
          <div className="empty-hint">
            {imagesetNames.length === 0
              ? t('imageBrowser.noImagesets')
              : t('imageBrowser.noMatch')}
          </div>
        )}

        {viewMode === 'grid' ? (
          <div className="image-grid">
            {filteredEntries.map(entry => (
              <div
                key={`${entry.imageset}/${entry.name}`}
                className="image-grid-item"
                onClick={() => handleSelectImage(entry)}
                title={`${entry.imageset}/${entry.name}\n${entry.def.width}×${entry.def.height}`}
              >
                <div className="image-thumbnail">
                  {entry.dataUrl ? (
                    <img src={entry.dataUrl} alt={entry.name} />
                  ) : (
                    <div className="image-placeholder">?</div>
                  )}
                </div>
                <div className="image-grid-label" title={entry.name}>
                  {entry.name}
                </div>
              </div>
            ))}
          </div>
        ) : (
          <div className="image-list-view">
            {filteredEntries.map(entry => (
              <div
                key={`${entry.imageset}/${entry.name}`}
                className="image-list-item"
                onClick={() => handleSelectImage(entry)}
              >
                <div className="image-list-thumb">
                  {entry.dataUrl ? (
                    <img src={entry.dataUrl} alt={entry.name} />
                  ) : (
                    <span>?</span>
                  )}
                </div>
                <div className="image-list-info">
                  <span className="image-list-name">{entry.name}</span>
                  <span className="image-list-meta">
                    {entry.def.width}×{entry.def.height} ({entry.imageset})
                  </span>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}

/** 属性分区 */
function PropertySection({
  title,
  children,
}: {
  title: string;
  children: React.ReactNode;
}): React.ReactElement {
  const [collapsed, setCollapsed] = useState(false);

  return (
    <div className="property-section">
      <div className="section-title" onClick={() => setCollapsed(!collapsed)}>
        <span className="collapse-icon">{collapsed ? '▶' : '▼'}</span>
        {title}
      </div>
      {!collapsed && children}
    </div>
  );
}

/** 可编辑属性行 */
function EditableProperty({
  label,
  value,
  readOnly = false,
  onChange,
}: {
  label: string;
  value: string;
  readOnly?: boolean;
  onChange?: (newValue: string) => void;
}): React.ReactElement {
  const [editing, setEditing] = useState(false);
  const [editValue, setEditValue] = useState(value);

  const handleCommit = useCallback(() => {
    setEditing(false);
    if (onChange && editValue !== value) {
      onChange(editValue);
    }
  }, [editValue, value, onChange]);

  const handleKeyDown = useCallback((e: React.KeyboardEvent) => {
    if (e.key === 'Enter') handleCommit();
    if (e.key === 'Escape') {
      setEditValue(value);
      setEditing(false);
    }
  }, [handleCommit, value]);

  if (readOnly || !onChange) {
    return (
      <div className="property-row">
        <span className="property-label">{label}</span>
        <span className="property-value-readonly">{value}</span>
      </div>
    );
  }

  return (
    <div className="property-row">
      <span className="property-label">{label}</span>
      {editing ? (
        <input
          className="property-value editing"
          value={editValue}
          onChange={e => setEditValue(e.target.value)}
          onBlur={handleCommit}
          onKeyDown={handleKeyDown}
          autoFocus
        />
      ) : (
        <input
          className="property-value"
          value={value}
          onFocus={() => {
            setEditValue(value);
            setEditing(true);
          }}
          readOnly
        />
      )}
    </div>
  );
}

/** 更新 PropertyDefinition */
function updatePropertyDefinition(wl: WidgetLook, wlName: string, index: number, newValue: string): void {
  const store = useEditorStore.getState();
  const newWl = JSON.parse(JSON.stringify(wl)) as WidgetLook;
  newWl.propertyDefinitions[index].initialValue = newValue;

  store.pushHistory({
    description: `Change PropertyDefinition "${wl.propertyDefinitions[index].name}"`,
    widgetLookName: wlName,
    snapshot: JSON.stringify(wl),
    affectedPaths: [`propertyDefinitions.${index}.initialValue`],
  });

  store.updateWidgetLook(wlName, newWl);
}

/** 更新 Property */
function updateProperty(wl: WidgetLook, wlName: string, index: number, newValue: string): void {
  const store = useEditorStore.getState();
  const newWl = JSON.parse(JSON.stringify(wl)) as WidgetLook;
  newWl.properties[index].value = newValue;

  store.pushHistory({
    description: `Change Property "${wl.properties[index].name}"`,
    widgetLookName: wlName,
    snapshot: JSON.stringify(wl),
    affectedPaths: [`properties.${index}.value`],
  });

  store.updateWidgetLook(wlName, newWl);
}

/** 更新组件的 Area */
function updateComponentArea(
  wl: WidgetLook,
  wlName: string,
  sectionName: string,
  componentType: 'frame' | 'imagery' | 'text',
  index: number,
  newArea: AreaDef,
): void {
  const store = useEditorStore.getState();
  const newWl = JSON.parse(JSON.stringify(wl)) as WidgetLook;

  const section = newWl.imagerySections.find(s => s.name === sectionName);
  if (!section) return;

  switch (componentType) {
    case 'frame':
      if (section.frameComponents[index]) {
        section.frameComponents[index].area = newArea;
      }
      break;
    case 'imagery':
      if (section.imageryComponents[index]) {
        section.imageryComponents[index].area = newArea;
      }
      break;
    case 'text':
      if (section.textComponents[index]) {
        section.textComponents[index].area = newArea;
      }
      break;
  }

  store.pushHistory({
    description: `Edit Area: ${sectionName}/${componentType}#${index}`,
    widgetLookName: wlName,
    snapshot: JSON.stringify(wl),
    affectedPaths: [`${sectionName}.${componentType}[${index}].area`],
  });

  store.updateWidgetLook(wlName, newWl);
}
