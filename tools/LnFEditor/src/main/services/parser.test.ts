import { describe, expect, it } from 'vitest';
import { parseLookNFeelXml } from './parser';
import { serializeFalagardDocument } from './serializer';

const SAMPLE_XML = `<?xml version="1.0" ?>
<Falagard>
    <WidgetLook name="Demo/Frame">
        <PropertyDefinition name="Caption" initialValue="A&amp;B &quot;Title&quot;" redrawOnWrite="true" type="String" help="caption" />
        <Child type="Demo/Titlebar" nameSuffix="__auto_titlebar__" autoWindow="true">
            <Area>
                <Dim type="LeftEdge"><AbsoluteDim value="0" /></Dim>
                <Dim type="TopEdge"><AbsoluteDim value="0" /></Dim>
                <Dim type="Width"><UnifiedDim scale="1" type="Width" /></Dim>
                <Dim type="Height"><AbsoluteDim value="32" /></Dim>
            </Area>
        </Child>
        <ImagerySection name="frame">
            <FrameComponent>
                <Area>
                    <Dim type="LeftEdge"><AbsoluteDim value="0" /></Dim>
                    <Dim type="TopEdge"><AbsoluteDim value="0" /></Dim>
                    <Dim type="Width"><UnifiedDim scale="1" type="Width" /></Dim>
                    <Dim type="Height"><AbsoluteDim value="32" /></Dim>
                </Area>
                <Image type="Background" imageset="Frame" image="Bg" />
                <ImageProperty type="TopEdge" name="TopEdgeImage" />
                <ColourRectProperty name="FrameColours" />
            </FrameComponent>
            <ImageryComponent>
                <Area>
                    <Dim type="LeftEdge"><AbsoluteDim value="0" /></Dim>
                    <Dim type="TopEdge"><WidgetDim widget="__auto_titlebar__" dimension="BottomEdge" /></Dim>
                    <Dim type="RightEdge">
                        <UnifiedDim scale="1" type="RightEdge">
                            <DimOperator op="Subtract">
                                <ImageDim imageset="Frame" image="RightEdge" dimension="Width" />
                            </DimOperator>
                        </UnifiedDim>
                    </Dim>
                    <Dim type="BottomEdge"><WidgetDim dimension="BottomEdge" /></Dim>
                </Area>
                <ImageProperty name="BodyImage" />
                <ColourRectProperty name="BodyColours" />
            </ImageryComponent>
        </ImagerySection>
        <StateImagery name="Disabled">
            <Layer>
                <Section look="Demo/Shared" section="frame">
                    <ColourRectProperty name="SectionColours" />
                </Section>
                <ColourRectProperty name="LayerColours" />
            </Layer>
        </StateImagery>
    </WidgetLook>
    <WidgetLook name="Demo/Shared">
        <ImagerySection name="frame">
            <ImageryComponent>
                <Area>
                    <Dim type="LeftEdge"><AbsoluteDim value="1" /></Dim>
                    <Dim type="TopEdge"><AbsoluteDim value="2" /></Dim>
                    <Dim type="Width"><AbsoluteDim value="3" /></Dim>
                    <Dim type="Height"><AbsoluteDim value="4" /></Dim>
                </Area>
                <Image imageset="Shared" image="Body" />
            </ImageryComponent>
        </ImagerySection>
    </WidgetLook>
</Falagard>`;

describe('parser/serializer round-trip', () => {
  it('parses DimOperator trees, property-backed imagery and external section refs', () => {
    const widgetLook = parseLookNFeelXml(SAMPLE_XML)[0];

    expect(widgetLook.propertyDefinitions[0]).toMatchObject({
      name: 'Caption',
      initialValue: 'A&B "Title"',
      type: 'String',
      help: 'caption',
    });
    expect(widgetLook.children[0].autoWindow).toBe(true);
    expect(widgetLook.imagerySections[0].frameComponents[0]).toMatchObject({
      imageProperties: { TopEdge: 'TopEdgeImage' },
      colourRectProperty: 'FrameColours',
    });
    expect(widgetLook.imagerySections[0].imageryComponents[0].area.right).toEqual({
      type: 'DimOperator',
      op: 'Subtract',
      left: { type: 'UnifiedDim', scale: 1, offset: 0, dimType: 'RightEdge' },
      right: { type: 'ImageDim', imageset: 'Frame', image: 'RightEdge', dimType: 'Width' },
    });
    expect(widgetLook.imagerySections[0].imageryComponents[0].colourRectProperty).toBe('BodyColours');
    expect(widgetLook.stateImagerys[0].layers[0]).toMatchObject({
      colourRectProperty: 'LayerColours',
      sections: [
        {
          look: 'Demo/Shared',
          sectionName: 'frame',
          colourRectProperty: 'SectionColours',
        },
      ],
    });
  });

  it('serializes back without dropping external look refs or property-backed nodes', () => {
    const original = parseLookNFeelXml(SAMPLE_XML);
    const serialized = serializeFalagardDocument(original);
    const reparsed = parseLookNFeelXml(serialized);

    expect(serialized).toContain('autoWindow="true"');
    expect(serialized).toContain('initialValue="A&amp;B &quot;Title&quot;"');
    expect(serialized).toContain('<ImageProperty type="TopEdge" name="TopEdgeImage" />');
    expect(serialized).toContain('<ColourRectProperty name="BodyColours" />');
    expect(serialized).toContain('<Section section="frame" look="Demo/Shared" >');
    expect(serialized).toContain('<ColourRectProperty name="SectionColours" />');
    expect(reparsed).toEqual(original);
  });
});
