#define NOMINMAX

#include "CEGUICocos2DRenderer.h"

#include "CEGUIRenderingRoot.h"
#include "CEGUIExceptions.h"
#include "CEGUISystem.h"
#include "CEGUIDefaultResourceProvider.h"

#include "CEGUICocos2DTexture.h"
#include "CEGUICocos2DGeometryBuffer.h"
#include "CEGUICocos2DRenderTarget.h"
#include "CEGUICocos2DViewportTarget.h"
#include "CEGUICocos2DTextureTarget.h"

#include "CEGUIImageCodec.h"

#include "2d/CCGLProgram.h"
#include "2d/CCShaderCache.h"
#include "2d/CCConfiguration.h"
#include "2d/CCDirector.h"
#include "2d/platform/win32/CCGL.h"
#include "math/kazmath/kazmath/kazmath.h"
#include "math/kazmath/kazmath/GL/matrix.h"

#include <algorithm>

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
    d_displayDPI(384, 384),
    d_defaultRoot(0),
    d_defaultTarget(0),
    d_SeparateAlphaBlendCap(false),
    m_program(NULL),
    d_pDebugTexture(NULL),
    d_pParent(0)
{
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
    Cocos2DTexture* tex = new Cocos2DTexture(*this);
    d_textures.push_back(tex);

    // Synchronous texture loading
    tex->loadFromFile(filename, resourceGroup);

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
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    glEnable(GL_SCISSOR_TEST);

    m_program = cocos2d::ShaderCache::getInstance()->getProgram(
        cocos2d::GLProgram::SHADER_NAME_POSITION_TEXTURE_COLOR);
    if (m_program)
    {
        m_program->use();

        // CEGUI 2D UI needs orthographic projection; EngineLayer::draw() sets 3D perspective.
        // Save current projection and switch to 2D ortho so UI is visible.
        kmGLMatrixMode(KM_GL_PROJECTION);
        kmGLPushMatrix();
        kmGLLoadIdentity();

        const Size& displaySize = getDisplaySize();
        kmMat4 ortho;
        kmMat4OrthographicProjection(&ortho,
            0.0f, displaySize.d_width,
            displaySize.d_height, 0.0f,
            -1.0f, 1.0f);
        kmGLMultMatrix(&ortho);

        m_program->setUniformsForBuiltins();

        glEnableVertexAttribArray(cocos2d::GLProgram::VERTEX_ATTRIB_POSITION);
        glEnableVertexAttribArray(cocos2d::GLProgram::VERTEX_ATTRIB_COLOR);
        glEnableVertexAttribArray(cocos2d::GLProgram::VERTEX_ATTRIB_TEX_COORDS);
    }
}

//----------------------------------------------------------------------------//
void Cocos2DRenderer::endRendering()
{
    // Restore the projection matrix saved in beginRendering() only when a
    // valid program was set (otherwise beginRendering did not push).
    if (m_program)
    {
        kmGLMatrixMode(KM_GL_PROJECTION);
        kmGLPopMatrix();
    }

    glDisable(GL_SCISSOR_TEST);
    glDisable(GL_BLEND);
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
    // TODO: Implement state save/restore for XP rendering interop.
    // In the simplified 3.0-oh path, the Cocos2d-x engine manages
    // its own GL state around CEGUI rendering.
}

//----------------------------------------------------------------------------//
void Cocos2DRenderer::SaveUIRenderState()
{
    // TODO: Implement state save/restore for UI rendering interop.
}

//----------------------------------------------------------------------------//
void Cocos2DRenderer::RestoreXPRenderState()
{
    // TODO: Implement state save/restore for XP rendering interop.
}

//----------------------------------------------------------------------------//
void Cocos2DRenderer::RestorUIRenderState()
{
    // TODO: Implement state save/restore for UI rendering interop.
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
void Cocos2DRenderer::OnFrameEnd()
{
    // Simplified OnFrameEnd for 3.0-oh.
    // In the original MT3 implementation, this handled async texture
    // loading completion, pending texture deletion, and loading state
    // management.  These are not needed in the synchronous 3.0-oh path.
}

//----------------------------------------------------------------------------//
void Cocos2DRenderer::CheckLoadingTexture(Cocos2DTexture* /*aPTexture*/)
{
    // Simplified for 3.0-oh: synchronous loading means no in-flight
    // texture loads to check.  This stub exists for ABI compatibility
    // with GeometryBuffer code that calls this method.
}

} // End of  CEGUI namespace section