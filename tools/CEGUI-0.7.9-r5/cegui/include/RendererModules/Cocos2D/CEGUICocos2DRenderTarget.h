#ifndef _CEGUICocos2DRenderTarget_h_
#define _CEGUICocos2DRenderTarget_h_

#include "CEGUICocos2DRenderer.h"
#include "../../CEGUIRenderTarget.h"
#include "../../CEGUIRect.h"
#include "kazmath/kazmath.h"
#include "math/kazmath/kazmath/GL/matrix.h"

#if defined(_MSC_VER)
#   pragma warning(push)
#   pragma warning(disable : 4251)
#endif

namespace CEGUI
{
class COCOS2D_GUIRENDERER_API Cocos2DRenderTarget : public virtual RenderTarget
{
public:
    Cocos2DRenderTarget(Cocos2DRenderer& owner);

    // implement RenderTarget interface (CEGUI 0.7.9-r5)
    virtual void        draw(const GeometryBuffer& buffer);
    virtual void        draw(const RenderQueue& queue);
    virtual void        setArea(const Rect& area);
    virtual const Rect& getArea() const;
    virtual void        activate();
    virtual void        deactivate();
    virtual void        unprojectPoint(const GeometryBuffer& buffer,
                                       const Vector2& p_in, Vector2& p_out) const;

    virtual void        Reset();

protected:
    void updateMatrix() const;

    Cocos2DRenderer& d_owner;
    Rect d_area;
    mutable kmMat4 d_matrix;
    mutable bool d_matrixValid;
    mutable float d_viewDistance;
    kmGLEnum d_savedMatrixMode;
};

} // End of  CEGUI namespace section

#if defined(_MSC_VER)
#   pragma warning(pop)
#endif

#endif  // end of guard _CEGUICocos2DRenderTarget_h_
