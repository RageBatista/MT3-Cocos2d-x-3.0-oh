#define NOMINMAX
#include "CEGUICocos2DGeometryBuffer.h"

#include "CEGUIBase.h"
#include "CEGUISystem.h"
#include "CEGUIVertex.h"
#include "CEGUIRenderEffect.h"

#include "CEGUICocos2DTexture.h"
#include "CEGUICocos2DRenderer.h"

#include "2d/platform/win32/CCGL.h"
#include "2d/CCShaderCache.h"
#include "2d/ccGLStateCache.h"
#include "math/kazmath/kazmath/kazmath.h"
#include "math/kazmath/kazmath/GL/matrix.h"

// Start of CEGUI namespace section
namespace CEGUI
{
//----------------------------------------------------------------------------//
Cocos2DGeometryBuffer::Cocos2DGeometryBuffer() :
    d_activeTexture(0),
    d_translation(0, 0, 0),
    d_rotation(0, 0, 0),
    d_scale(1, 1, 1),
    d_pivot(0, 0, 0),
    d_effect(0),
    d_matrixValid(false),
    d_TargetSurface(0),
    d_WidthClip(1.0f),
    d_RenderSuccess(false),
    d_paterGeomBuffer(0),
    d_vertexBuffer(0),
    d_vertexBufferDirty(false)
{
}

//----------------------------------------------------------------------------//
Cocos2DGeometryBuffer::~Cocos2DGeometryBuffer()
{
    if (d_vertexBuffer)
    {
        glDeleteBuffers(1, &d_vertexBuffer);
        d_vertexBuffer = 0;
    }

    if (d_effect)
    {
        delete d_effect;
    }

    if (d_TargetSurface)
    {
        d_TargetSurface->removeGeometryBuffer(RQ_BASE, *this);
    }
}

//----------------------------------------------------------------------------//
void Cocos2DGeometryBuffer::releaseTexture(const Cocos2DTexture* texture)
{
    if (d_activeTexture == texture)
    {
        d_activeTexture = NULL;
    }
    for (BatchList::iterator it = d_batches.begin(); it != d_batches.end(); ++it)
    {
        if (it->first == texture)
        {
            it->first = NULL;
        }
    }
}

//----------------------------------------------------------------------------//
bool Cocos2DGeometryBuffer::test_draw() const
{
    Cocos2DRenderer* pRender = (Cocos2DRenderer*)System::getSingleton().getRenderer();
    if (!pRender)
        return false;

    d_RenderSuccess = true;
    const int pass_count = d_effect ? d_effect->getPassCount() : 1;
    for (int pass = 0; pass < pass_count; ++pass)
    {
        size_t pos = 0;
        BatchList::const_iterator i = d_batches.begin();
        for (; i != d_batches.end(); ++i)
        {
            const BatchInfo& batchInfo = *i;
            Cocos2DTexture* pTexture = batchInfo.first;

            if (!pRender)
            {
                d_RenderSuccess = false;
                continue;
            }
            if (!pTexture || pTexture->m_bLoadFailed || !pTexture->hasTexture())
            {
                d_RenderSuccess = false;
                continue;
            }
            if (!pRender->isTextureValid((*i).first))
            {
                d_RenderSuccess = false;
                continue;
            }
            if ((*i).first->m_bIsLoading)
            {
                d_RenderSuccess = false;
                continue;
            }
        }
    }

    return d_RenderSuccess;
}

//----------------------------------------------------------------------------//
void Cocos2DGeometryBuffer::draw() const
{
    d_RenderSuccess = true;

    // setup clip region - CEGUI 0.7.9-r5: use Renderer::getDisplaySize()
    Cocos2DRenderer* pRender = (Cocos2DRenderer*)System::getSingleton().getRenderer();
    const Size& displaySize = pRender ? pRender->getDisplaySize() : Size(0, 0);
    const Rect screenArea(Vector2(0, 0), displaySize);
    GLint vp[4];
    glGetIntegerv(GL_VIEWPORT, vp);

    Rect clipRect = d_clipRect;
    clipRect.d_left -= d_translation.d_x;
    clipRect.d_right -= d_translation.d_x;
    clipRect.d_top -= d_translation.d_y;
    clipRect.d_bottom -= d_translation.d_y;
    clipRect.d_left = clipRect.d_left * d_matrix.mat[0] + d_matrix.mat[12];
    clipRect.d_right = clipRect.d_right * d_matrix.mat[0] + d_matrix.mat[12];
    clipRect.d_top = clipRect.d_top * d_matrix.mat[5] + d_matrix.mat[13];
    clipRect.d_bottom = clipRect.d_bottom * d_matrix.mat[5] + d_matrix.mat[13];
    Rect tempRect = screenArea.getIntersection(clipRect);

    int scissor_x = tempRect.d_left;
    int scissor_y = displaySize.d_height - tempRect.d_bottom;
    int scissor_w = tempRect.getWidth();
    int scissor_h = tempRect.getHeight();

    if (!isRotation())
    {
        glScissor(static_cast<GLint>(scissor_x),
            static_cast<GLint>(scissor_y),
            static_cast<GLint>(scissor_w),
            static_cast<GLint>(scissor_h));
    }

    bool bNeedRestoreScissorTest = false;
    if (!d_clipRectNeedConvert)
    {
        if (glIsEnabled(GL_SCISSOR_TEST))
        {
            glDisable(GL_SCISSOR_TEST);
            bNeedRestoreScissorTest = true;
        }
    }

    // apply the transformations we need to use.
    if (!d_matrixValid)
        updateMatrix();

    const kmGLEnum savedMatrixMode = kmGLGetCurrentMatrixMode();
    kmGLMatrixMode(KM_GL_MODELVIEW);
    kmGLLoadMatrix(&d_matrix);

    if (!pRender || !pRender->m_program)
    {
        d_RenderSuccess = false;
        kmGLMatrixMode(savedMatrixMode);
        return;
    }

    cocos2d::GL::bindVAO(0);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    if (!d_vertexBuffer)
        glGenBuffers(1, &d_vertexBuffer);
    if (!d_vertexBuffer)
    {
        d_RenderSuccess = false;
        if (bNeedRestoreScissorTest)
            glEnable(GL_SCISSOR_TEST);
        kmGLMatrixMode(savedMatrixMode);
        return;
    }
    glBindBuffer(GL_ARRAY_BUFFER, d_vertexBuffer);
    if (d_vertexBufferDirty)
    {
        glBufferData(GL_ARRAY_BUFFER,
            static_cast<GLsizeiptr>(d_vertices.size() * sizeof(cocos2d::V3F_C4B_T2F)),
            &d_vertices[0], GL_DYNAMIC_DRAW);
        d_vertexBufferDirty = false;
    }

    pRender->m_program->setUniformsForBuiltins();

    const int pass_count = d_effect ? d_effect->getPassCount() : 1;
    for (int pass = 0; pass < pass_count; ++pass)
    {
        size_t pos = 0;
        BatchList::const_iterator i = d_batches.begin();
        for (; i != d_batches.end(); ++i)
        {
            Cocos2DTexture* pTexture = i->first;
            const uint batchVertexCount = i->second;
            if (!pRender || !pTexture || !pRender->isTextureValid(pTexture))
            {
                pos += batchVertexCount;
                d_RenderSuccess = false;
                continue;
            }

            pRender->MarkRenderTexture(pTexture);
            if (pTexture->m_bIsLoading)
            {
                pRender->CheckLoadingTexture(pTexture);
                if (d_TargetSurface)
                {
                    d_TargetSurface->invalidate();
                }
                pos += batchVertexCount;
                d_RenderSuccess = false;
                continue;
            }
            if (pTexture->m_bLoadFailed || !pTexture->hasTexture())
            {
                pos += batchVertexCount;
                d_RenderSuccess = false;
                continue;
            }
            // Reload textures whose GL object has been invalidated.
            GLuint texId = pTexture->getTextureName();
            if (texId == 0 || GL_FALSE == glIsTexture(texId))
            {
                pos += batchVertexCount;
                pRender->ReleaseTexture(pTexture);
                d_RenderSuccess = false;
                continue;
            }

            const unsigned int kQuadSize = sizeof(cocos2d::V3F_C4B_T2F);

            if (pTexture->isEtc())
            {
                cocos2d::GLProgram* etcProgram = cocos2d::ShaderCache::getInstance()->getProgram("ShaderPositionTextureColorEtc");
                if (!etcProgram)
                {
                    pos += batchVertexCount;
                    d_RenderSuccess = false;
                    continue;
                }
                etcProgram->use();
                etcProgram->setUniformsForBuiltins();
                glEnableVertexAttribArray(cocos2d::GLProgram::VERTEX_ATTRIB_POSITION);
                glEnableVertexAttribArray(cocos2d::GLProgram::VERTEX_ATTRIB_COLOR);
                glEnableVertexAttribArray(cocos2d::GLProgram::VERTEX_ATTRIB_TEX_COORDS);
                cocos2d::GL::bindTexture2DN(0, pTexture->getTextureName());
                cocos2d::GL::bindTexture2DN(1, pTexture->getAlphaName());
            }
            else
            {
                cocos2d::GL::bindTexture2D(pTexture->getTextureName());
            }

            const size_t offset = pos * kQuadSize;

            // vertex
            unsigned int diff = offsetof(cocos2d::V3F_C4B_T2F, vertices);
            glVertexAttribPointer(cocos2d::GLProgram::VERTEX_ATTRIB_POSITION, 3, GL_FLOAT, GL_FALSE, kQuadSize, reinterpret_cast<void*>(offset + diff));

            // color
            diff = offsetof(cocos2d::V3F_C4B_T2F, colors);
            glVertexAttribPointer(cocos2d::GLProgram::VERTEX_ATTRIB_COLOR, 4, GL_UNSIGNED_BYTE, GL_TRUE, kQuadSize, reinterpret_cast<void*>(offset + diff));

            // texture coords
            diff = offsetof(cocos2d::V3F_C4B_T2F, texCoords);
            glVertexAttribPointer(cocos2d::GLProgram::VERTEX_ATTRIB_TEX_COORDS, 2, GL_FLOAT, GL_FALSE, kQuadSize, reinterpret_cast<void*>(offset + diff));

            glDrawArrays(GL_TRIANGLES, 0, batchVertexCount);

            if (pTexture->isEtc())
            {
                cocos2d::GL::bindTexture2DN(1, 0);
                cocos2d::GL::bindTexture2DN(0, 0);
            }
            else
            {
                cocos2d::GL::bindTexture2D(0);
            }

            if (pTexture->isEtc())
            {
                pRender->m_program->use();
                pRender->m_program->setUniformsForBuiltins();
            }

            pos += batchVertexCount;
        }
    }

    // clean up RenderEffect
    if (d_effect)
    {
        d_effect->performPostRenderFunctions();
        if (d_TargetSurface)
        {
            d_TargetSurface->invalidate();
        }
    }

    if (bNeedRestoreScissorTest)
    {
        glEnable(GL_SCISSOR_TEST);
    }

    kmGLMatrixMode(savedMatrixMode);
}

//----------------------------------------------------------------------------//
void Cocos2DGeometryBuffer::setTranslation(const Vector3& t)
{
    d_translation = t;
    d_matrixValid = false;
}

//----------------------------------------------------------------------------//
void Cocos2DGeometryBuffer::setRotation(const Vector3& r)
{
    d_rotation = r;
    d_matrixValid = false;
}

//----------------------------------------------------------------------------//
void Cocos2DGeometryBuffer::setPivot(const Vector3& p)
{
    d_pivot = p;
    d_matrixValid = false;
}

//----------------------------------------------------------------------------//
void Cocos2DGeometryBuffer::setScale(const Vector3& s)
{
    d_scale = s;
    d_matrixValid = false;
}

//----------------------------------------------------------------------------//
void Cocos2DGeometryBuffer::setClippingRegionNeedConvert(bool val)
{
    d_clipRectNeedConvert = val;
}

//----------------------------------------------------------------------------//
void Cocos2DGeometryBuffer::setClippingRegion(const Rect& region)
{
    const Rect screenArea(Vector2(0, 0),
        System::getSingleton().getRenderer()->getDisplaySize());

    Rect tempRect = screenArea.getIntersection(region);

    d_clipRect = tempRect;
}

//----------------------------------------------------------------------------//
void Cocos2DGeometryBuffer::appendVertex(const Vertex& vertex)
{
    appendGeometry(&vertex, 1);
}

//----------------------------------------------------------------------------//
void Cocos2DGeometryBuffer::appendGeometry(const Vertex* const vbuff,
                                             uint vertex_count)
{
    performBatchManagement();

    // update size of current batch
    d_batches.back().second += vertex_count;

    // buffer these vertices
    cocos2d::V3F_C4B_T2F vd;
    const Vertex* vs = vbuff;
    for (uint i = 0; i < vertex_count; ++i, ++vs)
    {
        // copy vertex info the buffer, converting from CEGUI::Vertex to
        // something directly usable by OpenGL as needed.
        vd.vertices.x       = vs->position.d_x;
        vd.vertices.y       = vs->position.d_y;
        vd.vertices.z       = vs->position.d_z;
        vd.colors.a         = (GLubyte)(vs->colour_val.getAlpha() * 255);
        vd.colors.r         = (GLubyte)(vs->colour_val.getRed() * 255);
        vd.colors.g         = (GLubyte)(vs->colour_val.getGreen() * 255);
        vd.colors.b         = (GLubyte)(vs->colour_val.getBlue() * 255);
        vd.texCoords.u      = vs->tex_coords.d_x;
        vd.texCoords.v      = vs->tex_coords.d_y;
        d_vertices.push_back(vd);
    }
    d_vertexBufferDirty = true;
}

//----------------------------------------------------------------------------//
void Cocos2DGeometryBuffer::setActiveTexture(Texture* texture)
{
    d_activeTexture = static_cast<Cocos2DTexture*>(texture);
}

//----------------------------------------------------------------------------//
Texture* Cocos2DGeometryBuffer::getActiveTexture() const
{
    return d_activeTexture;
}

//----------------------------------------------------------------------------//
void Cocos2DGeometryBuffer::reset()
{
    d_batches.clear();
    d_vertices.clear();
    d_activeTexture = 0;
    d_vertexBufferDirty = false;
}

//----------------------------------------------------------------------------//
uint Cocos2DGeometryBuffer::getVertexCount() const
{
    return d_vertices.size();
}

//----------------------------------------------------------------------------//
uint Cocos2DGeometryBuffer::getBatchCount() const
{
    return d_batches.size();
}

//----------------------------------------------------------------------------//
void Cocos2DGeometryBuffer::setRenderEffect(RenderEffect* effect)
{
    if (d_effect != effect)
    {
        if (d_effect)
        {
            delete d_effect;
            d_effect = NULL;
        }
    }

    d_effect = effect;
}

//----------------------------------------------------------------------------//
RenderEffect* Cocos2DGeometryBuffer::getRenderEffect()
{
    return d_effect;
}

//----------------------------------------------------------------------------//
void Cocos2DGeometryBuffer::performBatchManagement()
{
    if (d_batches.empty() || (d_activeTexture != d_batches.back().first))
        d_batches.push_back(BatchInfo(d_activeTexture, 0));
}

//----------------------------------------------------------------------------//
void Cocos2DGeometryBuffer::updateMatrix() const
{
    if (d_matrixValid) return;

    // Use kmGLGetMatrix/kmGLLoadMatrix instead of kmGLPushMatrix/kmGLPopMatrix
    // to avoid matrix stack imbalance with Cocos2d-x 3.0's Node::visit() and
    // Director::drawScene() which also use the modelview stack without explicit
    // matrix mode. Push/pop here previously caused "Cannot pop an empty stack"
    // assertion in mat4stack.c when the stack was already empty.
    const kmGLEnum savedMatrixMode = kmGLGetCurrentMatrixMode();
    kmGLMatrixMode(KM_GL_MODELVIEW);
    kmMat4 savedModelViewMatrix;
    kmGLGetMatrix(KM_GL_MODELVIEW, &savedModelViewMatrix);

    Vector3 trans = this->getLocalTranslation();

    const Vector3 final_trans(trans.d_x + d_pivot.d_x,
        trans.d_y + d_pivot.d_y,
        trans.d_z + d_pivot.d_z);

    kmGLLoadIdentity();
    kmGLTranslatef(final_trans.d_x, final_trans.d_y, final_trans.d_z);
    kmGLScalef(d_scale.d_x, d_scale.d_y, d_scale.d_z);
    kmGLRotatef(d_rotation.d_z, 0.0f, 0.0f, 1.0f);
    kmGLRotatef(d_rotation.d_y, 0.0f, 1.0f, 0.0f);
    kmGLRotatef(d_rotation.d_x, 1.0f, 0.0f, 0.0f);
    kmGLTranslatef(-d_pivot.d_x, -d_pivot.d_y, -d_pivot.d_z);
    kmGLGetMatrix(KM_GL_MODELVIEW, &d_matrix);

    kmGLLoadMatrix(&savedModelViewMatrix);
    kmGLMatrixMode(savedMatrixMode);

    if (d_paterGeomBuffer)
    {
        const kmMat4* paterMatrix = d_paterGeomBuffer->getMatrix();
        kmMat4Multiply(&d_matrix, paterMatrix, &d_matrix);
    }

    d_matrixValid = true;
}

//----------------------------------------------------------------------------//
const kmMat4* Cocos2DGeometryBuffer::getMatrix() const
{
    if (!d_matrixValid)
        updateMatrix();

    return &d_matrix;
}

//----------------------------------------------------------------------------//
RenderingSurface* Cocos2DGeometryBuffer::getTargetSurface()
{
    return d_TargetSurface;
}

//----------------------------------------------------------------------------//
void Cocos2DGeometryBuffer::SetRenderSurface(RenderingSurface* pSurface)
{
    d_TargetSurface = pSurface;
}

//----------------------------------------------------------------------------//
void Cocos2DGeometryBuffer::SetWidthClip(const float& clip)
{
    d_WidthClip = clip;
}

//----------------------------------------------------------------------------//
Vector3 Cocos2DGeometryBuffer::getLocalTranslation() const
{
    if (d_paterGeomBuffer)
    {
        return Vector3(d_translation.d_x - d_paterGeomBuffer->d_translation.d_x,
            d_translation.d_y - d_paterGeomBuffer->d_translation.d_y,
            d_translation.d_z - d_paterGeomBuffer->d_translation.d_z);
    }
    return this->d_translation;
}

//----------------------------------------------------------------------------//
Vector3 Cocos2DGeometryBuffer::getLocalScale() const
{
    if (d_paterGeomBuffer)
    {
        const Vector3& parentScale = d_paterGeomBuffer->getLocalScale();
        return Vector3(d_scale.d_x * parentScale.d_x,
            d_scale.d_y * parentScale.d_y,
            d_scale.d_z * parentScale.d_z);
    }
    return d_scale;
}

//----------------------------------------------------------------------------//
bool Cocos2DGeometryBuffer::isRotation() const
{
    if (this->d_rotation.d_z != 0.0f)
        return true;

    if (d_paterGeomBuffer)
        return d_paterGeomBuffer->isRotation();

    return false;
}

} // End of  CEGUI namespace section
