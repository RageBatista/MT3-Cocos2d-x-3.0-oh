#define NOMINMAX
#include "CEGUICocos2DRenderTarget.h"

#include "CEGUIRenderQueue.h"
#include "CEGUIExceptions.h"
#include "RendererModules/Cocos2D/CEGUICocos2DGL.h"
#include "math/kazmath/kazmath/kazmath.h"
#include "math/kazmath/kazmath/GL/matrix.h"

#include "CEGUICocos2DGeometryBuffer.h"
#include "CEGUISystem.h"

namespace CEGUI
{
Cocos2DRenderTarget::Cocos2DRenderTarget(Cocos2DRenderer& owner) :
    d_owner(owner),
    d_area(0, 0, 0, 0),
    d_matrixValid(false),
    d_savedMatrixMode(KM_GL_MODELVIEW)
{
}

void Cocos2DRenderTarget::draw(const GeometryBuffer& buffer)
{
    buffer.draw();
}

void Cocos2DRenderTarget::draw(const RenderQueue& queue)
{
    queue.draw();
}

void Cocos2DRenderTarget::setArea(const Rect& area)
{
    d_area = area;
    d_matrixValid = false;
}

const Rect& Cocos2DRenderTarget::getArea() const
{
    return d_area;
}

void Cocos2DRenderTarget::activate()
{
    if (!d_matrixValid)
        updateMatrix();

    d_savedMatrixMode = kmGLGetCurrentMatrixMode();

    // CEGUI 0.7.9-r5: Use Renderer::getDisplaySize() instead of System::GetAdapter()
    const Size& displaySize = d_owner.getDisplaySize();
    glViewport(0, 0,
              static_cast<GLint>(displaySize.d_width),
              static_cast<GLint>(displaySize.d_height));
    kmGLMatrixMode(KM_GL_PROJECTION);
    kmGLLoadMatrix(&d_matrix);
    return;
}

void Cocos2DRenderTarget::deactivate()
{
    kmGLMatrixMode(d_savedMatrixMode);
}

void Cocos2DRenderTarget::unprojectPoint(const GeometryBuffer& buffer,
                                           const Vector2& p_in,
                                           Vector2& p_out) const
{
    if (!d_matrixValid)
        updateMatrix();

    p_out = p_in;
    return;
}

void Cocos2DRenderTarget::updateMatrix() const
{
    const float w = d_area.getWidth();
    const float h = d_area.getHeight();
    const float aspect = w / h;
    const float midx = w * 0.5;
    const float midy = h * 0.5;
    d_viewDistance = midx / (aspect * 0.267949192431123f);

    // Use kmGLGetMatrix/kmGLLoadMatrix instead of kmGLPushMatrix/kmGLPopMatrix
    // to avoid matrix stack imbalance with Cocos2d-x 3.0's Node::visit() and
    // Director::drawScene() which use the projection stack without explicit
    // matrix mode. Push/pop here previously caused "Cannot pop an empty stack"
    // assertion in mat4stack.c when the stack was already empty.
    const kmGLEnum savedMatrixMode = kmGLGetCurrentMatrixMode();
    kmGLMatrixMode(KM_GL_PROJECTION);
    kmMat4 savedProjectionMatrix;
    kmGLGetMatrix(KM_GL_PROJECTION, &savedProjectionMatrix);

    kmGLLoadIdentity();
    kmMat4 mProj;
    kmMat4PerspectiveProjection(&mProj, 30.0f, aspect, d_viewDistance * 0.5f, d_viewDistance * 2.0f);
    kmGLMultMatrix(&mProj);
    kmVec3 eye, center, up;
    kmVec3Fill(&eye, midx, midy, -d_viewDistance);
    kmVec3Fill(&center, midx, midy, 1.f);
    kmVec3Fill(&up, 0.f, -1.f, 0.f);
    kmMat4LookAt(&mProj, &eye, &center, &up);
    kmGLMultMatrix(&mProj);

    kmGLGetMatrix(KM_GL_PROJECTION, &d_matrix);

    kmGLLoadMatrix(&savedProjectionMatrix);
    kmGLMatrixMode(savedMatrixMode);

    d_matrixValid = true;
}

void Cocos2DRenderTarget::Reset()
{
    d_matrixValid = false;
    activate();
}

} // End of  CEGUI namespace section
