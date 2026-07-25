import { describe, expect, it } from 'vitest';
import type { WidgetLook } from '@shared/model';
import { buildLayerTree } from './layer-tree-builder';

const widgetLook: WidgetLook = {
  name: 'Demo/Button',
  propertyDefinitions: [],
  propertyLinkDefinitions: [],
  properties: [],
  namedAreas: [],
  children: [],
  imagerySections: [
    {
      name: 'chrome',
      frameComponents: [
        {
          area: {
            left: { type: 'AbsoluteDim', value: 0 },
            top: { type: 'AbsoluteDim', value: 0 },
            width: { type: 'AbsoluteDim', value: 100 },
            height: { type: 'AbsoluteDim', value: 40 },
          },
          images: {},
        },
      ],
      imageryComponents: [
        {
          area: {
            left: { type: 'AbsoluteDim', value: 4 },
            top: { type: 'AbsoluteDim', value: 4 },
            width: { type: 'AbsoluteDim', value: 92 },
            height: { type: 'AbsoluteDim', value: 32 },
          },
          image: { imageset: 'Demo', image: 'ButtonBg' },
        },
      ],
      textComponents: [],
    },
    {
      name: 'label',
      frameComponents: [],
      imageryComponents: [],
      textComponents: [
        {
          area: {
            left: { type: 'AbsoluteDim', value: 8 },
            top: { type: 'AbsoluteDim', value: 8 },
            width: { type: 'AbsoluteDim', value: 84 },
            height: { type: 'AbsoluteDim', value: 24 },
          },
        },
      ],
    },
  ],
  stateImagerys: [
    {
      name: 'Normal',
      layers: [
        {
          sections: [{ sectionName: 'chrome' }, { sectionName: 'label' }],
        },
      ],
    },
  ],
};

const sharedLook: WidgetLook = {
  name: 'Demo/Shared',
  propertyDefinitions: [],
  propertyLinkDefinitions: [],
  properties: [],
  namedAreas: [],
  children: [],
  imagerySections: [
    {
      name: 'shared-frame',
      frameComponents: [],
      imageryComponents: [
        {
          area: {
            left: { type: 'AbsoluteDim', value: 1 },
            top: { type: 'AbsoluteDim', value: 2 },
            width: { type: 'AbsoluteDim', value: 30 },
            height: { type: 'AbsoluteDim', value: 12 },
          },
          image: { imageset: 'Shared', image: 'Frame' },
        },
      ],
      textComponents: [],
    },
  ],
  stateImagerys: [],
};

describe('buildLayerTree', () => {
  it('uses component ids that match Canvas/InspectorPanel selection protocol', () => {
    const tree = buildLayerTree(widgetLook, ['Normal']);
    const ids = flattenTree(tree).map(node => node.id);

    expect(ids).toContain('section:chrome:frame:0');
    expect(ids).toContain('section:chrome:imagery:0');
    expect(ids).toContain('section:label:text:0');
  });

  it('expands state layers in render order so section stacking is inspectable', () => {
    const tree = buildLayerTree(widgetLook, ['Normal']);
    const stateGroup = tree.children.find(node => node.id === 'wl-Demo/Button-states');
    expect(stateGroup).toBeDefined();

    const renderState = stateGroup?.children[0];
    const layer = renderState?.children[0];
    expect(layer?.children.map(node => node.name)).toEqual(['chrome', 'label']);
    expect(layer?.children[0].children.map(node => node.id)).toEqual([
      'section:chrome:frame:0',
      'section:chrome:imagery:0',
    ]);
  });

  it('assigns stable state ids and resolves external look section references', () => {
    const tree = buildLayerTree(
      {
        ...widgetLook,
        stateImagerys: [
          {
            name: 'Normal',
            layers: [
              {
                sections: [{ sectionName: 'shared-frame', look: 'Demo/Shared' }],
              },
            ],
          },
        ],
      },
      ['Normal'],
      new Map([
        [widgetLook.name, widgetLook],
        [sharedLook.name, sharedLook],
      ]),
    );

    const stateGroup = tree.children.find(node => node.id === 'wl-Demo/Button-states');
    const renderState = stateGroup?.children[0];
    expect(renderState?.id).toBe('state:Normal');
    expect(renderState?.children[0].children[0].name).toBe('Demo/Shared:shared-frame');
    expect(renderState?.children[0].children[0].children.map(node => node.id)).toEqual([
      'section:Demo/Shared:shared-frame:imagery:0',
    ]);
  });
});

function flattenTree(node: ReturnType<typeof buildLayerTree>): Array<{ id: string }> {
  return [node, ...node.children.flatMap(child => flattenTree(child as ReturnType<typeof buildLayerTree>))];
}
