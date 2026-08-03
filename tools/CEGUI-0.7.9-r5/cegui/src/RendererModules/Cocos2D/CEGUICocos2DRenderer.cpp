#define NOMINMAX

#include "CEGUICocos2DRenderer.h"

#include "CEGUIRenderingRoot.h"
#include "CEGUIExceptions.h"
#include "CEGUILogger.h"
#include "CEGUISystem.h"
#include "CEGUIDefaultResourceProvider.h"

#include "CEGUICocos2DTexture.h"
#include "CEGUICocos2DGeometryBuffer.h"
#include "CEGUICocos2DRenderTarget.h"
#include "CEGUICocos2DViewportTarget.h"
#include "CEGUICocos2DTextureTarget.h"

#include "math/kazmath/kazmath/GL/matrix.h"

#include "CEGUIImageCodec.h"

#include "2d/CCGLProgram.h"
#include "2d/ccGLStateCache.h"
#include "2d/CCShaderCache.h"
#include "2d/CCConfiguration.h"
#include "2d/CCDirector.h"
#include "2d/platform/win32/CCGL.h"
#include "math/kazmath/kazmath/kazmath.h"
#include "math/kazmath/kazmath/GL/matrix.h"

#include <algorithm>
#include <stdio.h>

// Start of CEGUI namespace section
namespace CEGUI
{
//----------------------------------------------------------------------------//
String Cocos2DRenderer::d_rendererID(
    "CEGUI::Cocos2DRenderer - Cocos2D renderer module for Cocos2d-x 3.0-oh.");

//----------------------------------------------------------------------------//
Cocos2DRenderer& Cocos2DRenderer::bootstrapSystem(cocos2d::Node* parent)
{
    if (System::getSingletonPtr())
        CEGUI_THROW(InvalidRequestException("Cocos2DRenderer::bootstrapSystem: "
            "CEGUI::System object is already initialised."));

    Cocos2DRenderer& renderer(create());
    renderer.d_pParent = parent;

    return renderer;
}

//----------------------------------------------------------------------------//
void Cocos2DRenderer::destroySystem()
{
    System* sys;
    if (!(sys = System::getSingletonPtr()))
        CEGUI_THROW(InvalidRequestException("Cocos2DRenderer::destroySystem: "
            "CEGUI::System object is not created or was already destroyed."));

    Cocos2DRenderer* renderer = static_cast<Cocos2DRenderer*>(sys->getRenderer());
    DefaultResourceProvider* rp =
        static_cast<DefaultResourceProvider*>(sys->getResourceProvider());

    System::destroy();
    delete rp;
    destroy(*renderer);
}

//----------------------------------------------------------------------------//
Cocos2DRenderer& Cocos2DRenderer::create()
{
    return *new Cocos2DRenderer();
}

//----------------------------------------------------------------------------//
void Cocos2DRenderer::destroy(Cocos2DRenderer& renderer)
{
    delete &renderer;
}

//----------------------------------------------------------------------------//
Cocos2DRenderer::Cocos2DRenderer() :
    d_displaySize(getViewportSize()),
    d_displayDPI(96, 96),
    d_defaultRoot(0),
    d_defaultTarget(0),
    d_SeparateAlphaBlendCap(false),
    m_program(NULL),
    d_pDebugTexture(NULL),
    d_pParent(0),
    d_externalPassDepth(0)
{
    d_renderStateStack.reserve(2);
    d_externalStateStack.reserve(2);
    d_uiStateStack.reserve(2);

    GLint max_tex_size;
    glGetIntegerv(GL_MAX_TEXTURE_SIZE, &max_tex_size);
    d_maxTextureSize = max_tex_size;

    d_supportNonSquareTex = false;
    d_supportNPOTTex = cocos2d::Configuration::getInstance()->supportsNPOT();

    d_defaultTarget = new Cocos2DViewportTarget(*this);
    d_defaultRoot = new RenderingRoot(*d_defaultTarget);
}

//----------------------------------------------------------------------------//
Cocos2DRenderer::~Cocos2DRenderer()
{
    destroyAllGeometryBuffers();
    destroyAllTextureTargets();
    destroyAllTextures();

    delete d_defaultRoot;
    delete d_defaultTarget;
}

//----------------------------------------------------------------------------//
Size Cocos2DRenderer::getViewportSize()
{
    GLint vp[4];
    glGetIntegerv(GL_VIEWPORT, vp);
    return Size(static_cast<float>(vp[2]), static_cast<float>(vp[3]));
}

//----------------------------------------------------------------------------//
RenderingRoot& Cocos2DRenderer::getDefaultRenderingRoot()
{
    return *d_defaultRoot;
}

//----------------------------------------------------------------------------//
GeometryBuffer& Cocos2DRenderer::createGeometryBuffer()
{
    Cocos2DGeometryBuffer* b = new Cocos2DGeometryBuffer();
    d_geometryBuffers.push_back(b);
    return *b;
}

//----------------------------------------------------------------------------//
void Cocos2DRenderer::destroyGeometryBuffer(const GeometryBuffer& buffer)
{
    GeometryBufferList::iterator i = std::find(d_geometryBuffers.begin(),
        d_geometryBuffers.end(),
        &buffer);

    if (d_geometryBuffers.end() != i)
    {
        d_geometryBuffers.erase(i);

        // Ensure the GeometryBuffer has been removed from the RenderQueue
        getDefaultRenderingRoot().removeGeometryBuffer(RQ_BASE, buffer);

        delete &buffer;
    }
}

//----------------------------------------------------------------------------//
void Cocos2DRenderer::destroyAllGeometryBuffers()
{
    while (!d_geometryBuffers.empty())
        destroyGeometryBuffer(*d_geometryBuffers.front());
}

//----------------------------------------------------------------------------//
TextureTarget* Cocos2DRenderer::createTextureTarget()
{
    TextureTarget* t = new Cocos2DTextureTarget(*this);
    d_textureTargets.push_back(t);
    return t;
}

//----------------------------------------------------------------------------//
void Cocos2DRenderer::destroyTextureTarget(TextureTarget* target)
{
    TextureTargetList::iterator i = std::find(d_textureTargets.begin(),
        d_textureTargets.end(),
        target);

    if (d_textureTargets.end() != i)
    {
        d_textureTargets.erase(i);
        delete target;
    }
}

//----------------------------------------------------------------------------//
void Cocos2DRenderer::destroyAllTextureTargets()
{
    while (!d_textureTargets.empty())
        destroyTextureTarget(*d_textureTargets.begin());
}

//----------------------------------------------------------------------------//
Texture& Cocos2DRenderer::createTexture()
{
    Cocos2DTexture* tex = new Cocos2DTexture(*this);
    d_textures.push_back(tex);
    return *tex;
}

//----------------------------------------------------------------------------//
Texture& Cocos2DRenderer::createTexture(const String& filename, const String& resourceGroup)
{
    Cocos2DTexture* tex = new Cocos2DTexture(*this, filename, resourceGroup);
    d_textures.push_back(tex);
    tex->m_bIsLoading = true;
    d_pendingTextureLoads.push_back(
        PendingTextureLoad(tex, filename, resourceGroup));

    return *tex;
}

//----------------------------------------------------------------------------//
Texture& Cocos2DRenderer::createTexture(const Size& size)
{
    Cocos2DTexture* tex = new Cocos2DTexture(*this, size);
    d_textures.push_back(tex);
    return *tex;
}

//----------------------------------------------------------------------------//
Texture& Cocos2DRenderer::createTexture(cocos2d::Texture2D* pTexture)
{
    Cocos2DTexture* tex = new Cocos2DTexture(*this, pTexture);
    d_textures.push_back(tex);
    return *tex;
}

//----------------------------------------------------------------------------//
void Cocos2DRenderer::destroyTexture(Texture& texture)
{
    TextureList::iterator i = std::find(d_textures.begin(),
        d_textures.end(),
        &texture);

    if (d_textures.end() != i)
    {
        for (PendingTextureLoadList::iterator pending = d_pendingTextureLoads.begin();
             pending != d_pendingTextureLoads.end();)
        {
            if (pending->texture == &texture)
                pending = d_pendingTextureLoads.erase(pending);
            else
                ++pending;
        }

        static_cast<Cocos2DTexture&>(texture).m_bIsLoading = false;
        d_textures.erase(i);

        // Remove from render textures list if present
        RenderTextureList::iterator rit = std::find(d_RenderTextures.begin(),
            d_RenderTextures.end(), &texture);
        if (rit != d_RenderTextures.end())
        {
            d_RenderTextures.erase(rit);
        }

        delete &texture;
    }
}

//----------------------------------------------------------------------------//
void Cocos2DRenderer::destroyAllTextures()
{
    while (!d_textures.empty())
        destroyTexture(*d_textures.front());
}

//----------------------------------------------------------------------------//
void Cocos2DRenderer::beginRendering()
{
    RenderStateSnapshot state;
    captureRenderState(state);
    d_renderStateStack.push_back(state);
    applyUIRenderState();
}

//----------------------------------------------------------------------------//
void Cocos2DRenderer::endRendering()
{
    if (d_renderStateStack.empty())
        return;

    const RenderStateSnapshot state = d_renderStateStack.back();
    d_renderStateStack.pop_back();
    restoreRenderState(state);

    if (d_renderStateStack.empty())
    {
        d_externalStateStack.clear();
        d_externalPassDepth = 0;
        m_program = NULL;
    }
}

//----------------------------------------------------------------------------//
void Cocos2DRenderer::setDisplaySize(const Size& sz)
{
    if (sz != d_displaySize)
    {
        d_displaySize = sz;

        Rect area(d_defaultTarget->getArea());
        area.setSize(sz);
        d_defaultTarget->setArea(area);
    }
}

//----------------------------------------------------------------------------//
const Size& Cocos2DRenderer::getDisplaySize() const
{
    return d_displaySize;
}

//----------------------------------------------------------------------------//
const Vector2& Cocos2DRenderer::getDisplayDPI() const
{
    return d_displayDPI;
}

//----------------------------------------------------------------------------//
uint Cocos2DRenderer::getMaxTextureSize() const
{
    return d_maxTextureSize;
}

//----------------------------------------------------------------------------//
const String& Cocos2DRenderer::getIdentifierString() const
{
    return d_rendererID;
}

//----------------------------------------------------------------------------//
void Cocos2DRenderer::preD3DReset()
{
    // No D3D resources to release in OpenGL/Cocos2d-x renderer.
    // Texture targets handle their own pre-reset logic.
}

//----------------------------------------------------------------------------//
void Cocos2DRenderer::postD3DReset()
{
    // No D3D resources to restore in OpenGL/Cocos2d-x renderer.
    // Texture targets handle their own post-reset logic.
}

//----------------------------------------------------------------------------//
bool Cocos2DRenderer::supportsNonSquareTexture()
{
    return d_supportNonSquareTex;
}

//----------------------------------------------------------------------------//
bool Cocos2DRenderer::supportsNPOTTextures()
{
    return d_supportNPOTTex;
}

//----------------------------------------------------------------------------//
Size Cocos2DRenderer::getAdjustedSize(const Size& sz)
{
    Size s(sz);

    if (!d_supportNPOTTex)
    {
        s.d_width = getSizeNextPOT(sz.d_width);
        s.d_height = getSizeNextPOT(sz.d_height);
    }
    if (!d_supportNonSquareTex)
        s.d_width = s.d_height =
            ceguimax(s.d_width, s.d_height);

    return s;
}

//----------------------------------------------------------------------------//
float Cocos2DRenderer::getSizeNextPOT(float sz) const
{
    uint size = static_cast<uint>(sz);

    // if not power of 2
    if ((size & (size - 1)) || !size)
    {
        int log = 0;

        // get integer log of 'size' to base 2
        while (size >>= 1)
            ++log;

        // use log to calculate value to use as size.
        size = (2 << log);
    }

    return static_cast<float>(size);
}

//----------------------------------------------------------------------------//
void Cocos2DRenderer::DisableSeparateAlphaBlend()
{
    d_SeparateAlphaBlendCap = false;
}

//----------------------------------------------------------------------------//
void Cocos2DRenderer::SaveXPRenderState()
{
    if (d_renderStateStack.empty())
        return;

    ++d_externalPassDepth;
    if (d_externalPassDepth != 1)
        return;

    RenderStateSnapshot state;
    captureRenderState(state);
    d_externalStateStack.push_back(state);
    restoreRenderState(d_renderStateStack.back());
}

//----------------------------------------------------------------------------//
void Cocos2DRenderer::SaveUIRenderState()
{
    RenderStateSnapshot state;
    captureRenderState(state);
    d_uiStateStack.push_back(state);
}

//----------------------------------------------------------------------------//
void Cocos2DRenderer::RestoreXPRenderState()
{
    if (d_externalPassDepth == 0)
        return;

    --d_externalPassDepth;
    if (d_externalPassDepth != 0 || d_externalStateStack.empty())
        return;

    const RenderStateSnapshot state = d_externalStateStack.back();
    d_externalStateStack.pop_back();
    restoreRenderState(state);
}

//----------------------------------------------------------------------------//
void Cocos2DRenderer::RestorUIRenderState()
{
    if (d_uiStateStack.empty())
        return;

    const RenderStateSnapshot state = d_uiStateStack.back();
    d_uiStateStack.pop_back();
    restoreRenderState(state);
}

//----------------------------------------------------------------------------//
void Cocos2DRenderer::captureRenderState(RenderStateSnapshot& state) const
{
    state.scissorEnabled = glIsEnabled(GL_SCISSOR_TEST) == GL_TRUE;
    state.blendEnabled = glIsEnabled(GL_BLEND) == GL_TRUE;
    state.depthEnabled = glIsEnabled(GL_DEPTH_TEST) == GL_TRUE;
    state.stencilEnabled = glIsEnabled(GL_STENCIL_TEST) == GL_TRUE;
    state.cullEnabled = glIsEnabled(GL_CULL_FACE) == GL_TRUE;

    GLboolean value = GL_FALSE;
    glGetBooleanv(GL_DEPTH_WRITEMASK, &value);
    state.depthWriteEnabled = value == GL_TRUE;
    GLboolean colourMask[4];
    glGetBooleanv(GL_COLOR_WRITEMASK, colourMask);
    for (int i = 0; i < 4; ++i)
        state.colourMask[i] = colourMask[i] == GL_TRUE;

    glGetIntegerv(GL_SCISSOR_BOX, state.scissorBox);
    glGetIntegerv(GL_VIEWPORT, state.viewport);
    glGetIntegerv(GL_CURRENT_PROGRAM, &state.currentProgram);
    glGetIntegerv(GL_ACTIVE_TEXTURE, &state.activeTexture);
    glGetIntegerv(GL_BLEND_SRC_RGB, &state.blendSrcRGB);
    glGetIntegerv(GL_BLEND_DST_RGB, &state.blendDstRGB);
    glGetIntegerv(GL_BLEND_SRC_ALPHA, &state.blendSrcAlpha);
    glGetIntegerv(GL_BLEND_DST_ALPHA, &state.blendDstAlpha);
    glGetIntegerv(GL_BLEND_EQUATION_RGB, &state.blendEquationRGB);
    glGetIntegerv(GL_BLEND_EQUATION_ALPHA, &state.blendEquationAlpha);
    glGetIntegerv(GL_FRAMEBUFFER_BINDING, &state.framebuffer);
    glGetIntegerv(GL_RENDERBUFFER_BINDING, &state.renderbuffer);
    glGetIntegerv(GL_ARRAY_BUFFER_BINDING, &state.arrayBuffer);
    glGetIntegerv(GL_ELEMENT_ARRAY_BUFFER_BINDING, &state.elementArrayBuffer);

    for (int unit = 0; unit < 2; ++unit)
    {
        glActiveTexture(GL_TEXTURE0 + unit);
        glGetIntegerv(GL_TEXTURE_BINDING_2D, &state.textureBindings[unit]);
    }
    glActiveTexture(static_cast<GLenum>(state.activeTexture));

    state.hasVertexArray = cocos2d::Configuration::getInstance()->supportsShareableVAO();
    state.vertexArray = 0;
    if (state.hasVertexArray)
        glGetIntegerv(GL_VERTEX_ARRAY_BINDING, &state.vertexArray);

    const GLuint attributes[3] =
    {
        cocos2d::GLProgram::VERTEX_ATTRIB_POSITION,
        cocos2d::GLProgram::VERTEX_ATTRIB_COLOR,
        cocos2d::GLProgram::VERTEX_ATTRIB_TEX_COORDS
    };
    for (int i = 0; i < 3; ++i)
    {
        GLint enabled = GL_FALSE;
        glGetVertexAttribiv(attributes[i], GL_VERTEX_ATTRIB_ARRAY_ENABLED, &enabled);
        state.vertexAttribEnabled[i] = enabled == GL_TRUE;
        glGetVertexAttribiv(attributes[i], GL_VERTEX_ATTRIB_ARRAY_SIZE, &state.vertexAttribSize[i]);
        glGetVertexAttribiv(attributes[i], GL_VERTEX_ATTRIB_ARRAY_TYPE, &state.vertexAttribType[i]);
        glGetVertexAttribiv(attributes[i], GL_VERTEX_ATTRIB_ARRAY_NORMALIZED, &state.vertexAttribNormalised[i]);
        glGetVertexAttribiv(attributes[i], GL_VERTEX_ATTRIB_ARRAY_STRIDE, &state.vertexAttribStride[i]);
        glGetVertexAttribiv(attributes[i], GL_VERTEX_ATTRIB_ARRAY_BUFFER_BINDING, &state.vertexAttribBuffer[i]);
        glGetVertexAttribPointerv(attributes[i], GL_VERTEX_ATTRIB_ARRAY_POINTER,
            &state.vertexAttribPointer[i]);
    }

    state.matrixMode = kmGLGetCurrentMatrixMode();
    kmGLGetMatrix(KM_GL_PROJECTION, &state.projectionMatrix);
    kmGLGetMatrix(KM_GL_MODELVIEW, &state.modelViewMatrix);
}

//----------------------------------------------------------------------------//
void Cocos2DRenderer::restoreRenderState(const RenderStateSnapshot& state) const
{
    glBindFramebuffer(GL_FRAMEBUFFER, static_cast<GLuint>(state.framebuffer));
    glBindRenderbuffer(GL_RENDERBUFFER, static_cast<GLuint>(state.renderbuffer));
    glViewport(state.viewport[0], state.viewport[1], state.viewport[2], state.viewport[3]);
    glScissor(state.scissorBox[0], state.scissorBox[1], state.scissorBox[2], state.scissorBox[3]);
    glColorMask(state.colourMask[0], state.colourMask[1],
        state.colourMask[2], state.colourMask[3]);
    glDepthMask(state.depthWriteEnabled ? GL_TRUE : GL_FALSE);
    glBlendEquationSeparate(static_cast<GLenum>(state.blendEquationRGB),
        static_cast<GLenum>(state.blendEquationAlpha));
    glBlendFuncSeparate(static_cast<GLenum>(state.blendSrcRGB),
        static_cast<GLenum>(state.blendDstRGB),
        static_cast<GLenum>(state.blendSrcAlpha),
        static_cast<GLenum>(state.blendDstAlpha));

    const GLenum capabilities[5] =
    {
        GL_SCISSOR_TEST, GL_BLEND, GL_DEPTH_TEST, GL_STENCIL_TEST, GL_CULL_FACE
    };
    const bool enabled[5] =
    {
        state.scissorEnabled, state.blendEnabled, state.depthEnabled,
        state.stencilEnabled, state.cullEnabled
    };
    for (int i = 0; i < 5; ++i)
    {
        if (enabled[i])
            glEnable(capabilities[i]);
        else
            glDisable(capabilities[i]);
    }

    for (int unit = 0; unit < 2; ++unit)
    {
        glActiveTexture(GL_TEXTURE0 + unit);
        glBindTexture(GL_TEXTURE_2D, static_cast<GLuint>(state.textureBindings[unit]));
    }
    glActiveTexture(static_cast<GLenum>(state.activeTexture));
    glUseProgram(static_cast<GLuint>(state.currentProgram));

    if (state.hasVertexArray)
        glBindVertexArray(static_cast<GLuint>(state.vertexArray));

    const GLuint attributes[3] =
    {
        cocos2d::GLProgram::VERTEX_ATTRIB_POSITION,
        cocos2d::GLProgram::VERTEX_ATTRIB_COLOR,
        cocos2d::GLProgram::VERTEX_ATTRIB_TEX_COORDS
    };
    for (int i = 0; i < 3; ++i)
    {
        glBindBuffer(GL_ARRAY_BUFFER, static_cast<GLuint>(state.vertexAttribBuffer[i]));
        glVertexAttribPointer(attributes[i], state.vertexAttribSize[i],
            static_cast<GLenum>(state.vertexAttribType[i]),
            state.vertexAttribNormalised[i] ? GL_TRUE : GL_FALSE,
            state.vertexAttribStride[i], state.vertexAttribPointer[i]);
        if (state.vertexAttribEnabled[i])
            glEnableVertexAttribArray(attributes[i]);
        else
            glDisableVertexAttribArray(attributes[i]);
    }
    glBindBuffer(GL_ARRAY_BUFFER, static_cast<GLuint>(state.arrayBuffer));
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, static_cast<GLuint>(state.elementArrayBuffer));

    kmGLMatrixMode(KM_GL_PROJECTION);
    kmGLLoadMatrix(&state.projectionMatrix);
    kmGLMatrixMode(KM_GL_MODELVIEW);
    kmGLLoadMatrix(&state.modelViewMatrix);
    kmGLMatrixMode(state.matrixMode);

    cocos2d::GL::invalidateStateCachePreserveMatrices();
}

//----------------------------------------------------------------------------//
void Cocos2DRenderer::applyUIRenderState()
{
    glDisable(GL_DEPTH_TEST);
    glDepthMask(GL_FALSE);
    glDisable(GL_CULL_FACE);
    glEnable(GL_BLEND);
    glBlendEquation(GL_FUNC_ADD);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_SCISSOR_TEST);

    m_program = cocos2d::ShaderCache::getInstance()->getProgram(
        cocos2d::GLProgram::SHADER_NAME_POSITION_TEXTURE_COLOR);

    kmGLMatrixMode(KM_GL_PROJECTION);
    kmGLLoadIdentity();
    const Size& displaySize = getDisplaySize();
    kmMat4 ortho;
    kmMat4OrthographicProjection(&ortho,
        0.0f, displaySize.d_width,
        displaySize.d_height, 0.0f,
        -1.0f, 1.0f);
    kmGLMultMatrix(&ortho);
    kmGLMatrixMode(KM_GL_MODELVIEW);

    if (!m_program)
        return;

    m_program->use();
    m_program->setUniformsForBuiltins();
    cocos2d::GL::enableVertexAttribs(cocos2d::GL::VERTEX_ATTRIB_FLAG_POS_COLOR_TEX);
}

//----------------------------------------------------------------------------//
void Cocos2DRenderer::Reset()
{
    // Reset the default target area
    if (d_defaultTarget)
    {
        d_defaultTarget->setArea(Rect(Point(0, 0), d_displaySize));
    }
}

//----------------------------------------------------------------------------//
void Cocos2DRenderer::ResetRenderTextures()
{
    d_RenderTextures.clear();
}

//----------------------------------------------------------------------------//
void Cocos2DRenderer::MarkRenderTexture(Texture* pTexture)
{
    RenderTextureList::iterator it = std::find(d_RenderTextures.begin(),
        d_RenderTextures.end(), pTexture);
    if (it == d_RenderTextures.end())
    {
        d_RenderTextures.push_back(static_cast<Cocos2DTexture*>(pTexture));
    }
}

//----------------------------------------------------------------------------//
bool Cocos2DRenderer::isTextureRender(Texture& texture)
{
    RenderTextureList::iterator it = std::find(d_RenderTextures.begin(),
        d_RenderTextures.end(), &texture);
    return it != d_RenderTextures.end();
}

//----------------------------------------------------------------------------//
void Cocos2DRenderer::ReleaseTexture(Texture* texture)
{
    RenderTextureList::iterator it = std::find(d_RenderTextures.begin(),
        d_RenderTextures.end(), texture);
    if (it != d_RenderTextures.end())
    {
        d_RenderTextures.erase(it);
    }
    if (texture)
    {
        destroyTexture(*texture);
    }
}

//----------------------------------------------------------------------------//
void Cocos2DRenderer::MarkRenderTexture(Cocos2DTexture* pCocos2DTexture)
{
    if (isTextureValid(pCocos2DTexture))
    {
        MarkRenderTexture(static_cast<Texture*>(pCocos2DTexture));
    }
}

//----------------------------------------------------------------------------//
bool Cocos2DRenderer::isTextureValid(Cocos2DTexture* pCocos2DTexture)
{
    TextureList::iterator it = std::find(d_textures.begin(), d_textures.end(),
        pCocos2DTexture);
    return it != d_textures.end();
}

//----------------------------------------------------------------------------//
void Cocos2DRenderer::SetPointMode(bool b)
{
    // Point mode is not applicable in the simplified 3.0-oh renderer.
    // Reserved for future use.
}

//----------------------------------------------------------------------------//
void Cocos2DRenderer::ProcessPendingTextures(unsigned int maxLoadsPerFrame)
{
    unsigned int processedCount = 0;

    while (!d_pendingTextureLoads.empty() && processedCount < maxLoadsPerFrame)
    {
        const PendingTextureLoad request = d_pendingTextureLoads.front();
        d_pendingTextureLoads.erase(d_pendingTextureLoads.begin());

        Cocos2DTexture* texture = request.texture;
        if (!isTextureValid(texture) || texture->m_bDestroyPending)
            continue;

        try
        {
            texture->loadFromFile(request.filename, request.resourceGroup);
            texture->m_bLoadFailed = !texture->hasTexture();
        }
        catch (const Exception& e)
        {
            Logger::getSingleton().logEvent(
                "Cocos2DRenderer::ProcessPendingTextures - Failed to load image '" +
                request.filename + "': " + e.getMessage(), Errors);
            texture->m_bLoadFailed = true;
        }
        catch (...)
        {
            Logger::getSingleton().logEvent(
                "Cocos2DRenderer::ProcessPendingTextures - Unknown failure loading image '" +
                request.filename + "'.", Errors);
            texture->m_bLoadFailed = true;
        }

        texture->m_bIsLoading = false;
        ++processedCount;
    }

    if (processedCount && System::getSingletonPtr())
    {
        System::getSingleton().invalidateAllCachedRendering();
        System::getSingleton().signalRedraw();
    }
}

//----------------------------------------------------------------------------//
void Cocos2DRenderer::OnFrameEnd()
{
    // Pending uploads are processed by GameUImanager immediately before the
    // next CEGUI render pass, outside geometry construction.
}

//----------------------------------------------------------------------------//
void Cocos2DRenderer::CheckLoadingTexture(Cocos2DTexture* /*aPTexture*/)
{
    // Simplified for 3.0-oh: synchronous loading means no in-flight
    // texture loads to check.  This stub exists for ABI compatibility
    // with GeometryBuffer code that calls this method.
}

} // End of  CEGUI namespace section
