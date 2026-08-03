#ifndef _CEGUICocos2DRenderer_h_
#define _CEGUICocos2DRenderer_h_

#include "../../CEGUIBase.h"
#include "../../CEGUIRenderer.h"
#include "../../CEGUISize.h"
#include "../../CEGUIString.h"
#include "../../CEGUIVector.h"

#include "base/CCPlatformMacros.h"
#include "2d/CCNode.h"
#include "math/kazmath/kazmath/kazmath.h"
#include "math/kazmath/kazmath/GL/matrix.h"

#include <vector>
#include <map>

#if (defined( __WIN32__ ) || defined( _WIN32 )) && !defined(CEGUI_STATIC)
#   ifdef CEGUICOCOS2DRENDER_EXPORTS
#       define COCOS2D_GUIRENDERER_API __declspec(dllexport)
#   else
#       define COCOS2D_GUIRENDERER_API __declspec(dllimport)
#   endif
#else
#   define COCOS2D_GUIRENDERER_API
#endif

#if defined(_MSC_VER)
#   pragma warning(push)
#   pragma warning(disable : 4251)
#endif

namespace CEGUI
{
class Cocos2DTexture;
class Cocos2DGeometryBuffer;

class COCOS2D_GUIRENDERER_API Cocos2DRenderer : public Renderer
{
public:
    static Cocos2DRenderer& bootstrapSystem(cocos2d::Node* parent);
    static void destroySystem();
    static Cocos2DRenderer& create();
    static void destroy(Cocos2DRenderer& renderer);

    cocos2d::GLProgram* m_program;

    void preD3DReset();
    void postD3DReset();

    bool supportsNonSquareTexture();
    bool supportsNPOTTextures();

    Size getAdjustedSize(const Size& sz);

    // implement Renderer interface
    virtual RenderingRoot&      getDefaultRenderingRoot();
    virtual GeometryBuffer&     createGeometryBuffer();
    virtual void                destroyGeometryBuffer(const GeometryBuffer& buffer);
    virtual void                destroyAllGeometryBuffers();

    virtual TextureTarget*      createTextureTarget();
    virtual void                destroyTextureTarget(TextureTarget* target);
    virtual void                destroyAllTextureTargets();

    virtual Texture&            createTexture();
    virtual Texture&            createTexture(const String& filename, const String& resourceGroup);
    virtual Texture&            createTexture(const Size& size);
    virtual void                destroyTexture(Texture& texture);
    virtual void                destroyAllTextures();

    virtual void                beginRendering();
    virtual void                endRendering();
    virtual void                setDisplaySize(const Size& sz);
    virtual const Size&         getDisplaySize() const;
    virtual const Vector2&      getDisplayDPI() const;
    virtual uint                getMaxTextureSize() const;
    virtual const String&       getIdentifierString() const;

    Texture&                    createTexture(cocos2d::Texture2D* pTexture);

    void DisableSeparateAlphaBlend();

    void SaveXPRenderState();
    void SaveUIRenderState();
    void RestoreXPRenderState();
    void RestorUIRenderState();
    void Reset();

    // MT3 texture management
    void ResetRenderTextures();
    void MarkRenderTexture(Texture* pTexture);
    bool isTextureRender(Texture& texture);
    void ReleaseTexture(Texture* texture);

    void MarkRenderTexture(Cocos2DTexture* pCocos2DTexture);
    bool isTextureValid(Cocos2DTexture* pCocos2DTexture);

    void SetPointMode(bool b);

    void ProcessPendingTextures(unsigned int maxLoadsPerFrame = 1);
    virtual void OnFrameEnd();

    void CheckLoadingTexture(Cocos2DTexture* aPTexture);

    Cocos2DTexture*     d_pDebugTexture;
    cocos2d::Node*      d_pParent;

private:
    struct RenderStateSnapshot
    {
        bool scissorEnabled;
        bool blendEnabled;
        bool depthEnabled;
        bool stencilEnabled;
        bool cullEnabled;
        bool depthWriteEnabled;
        bool colourMask[4];
        bool vertexAttribEnabled[3];
        bool hasVertexArray;
        int scissorBox[4];
        int viewport[4];
        int currentProgram;
        int activeTexture;
        int textureBindings[2];
        int blendSrcRGB;
        int blendDstRGB;
        int blendSrcAlpha;
        int blendDstAlpha;
        int blendEquationRGB;
        int blendEquationAlpha;
        int framebuffer;
        int renderbuffer;
        int arrayBuffer;
        int elementArrayBuffer;
        int vertexArray;
        int vertexAttribSize[3];
        int vertexAttribType[3];
        int vertexAttribNormalised[3];
        int vertexAttribStride[3];
        int vertexAttribBuffer[3];
        void* vertexAttribPointer[3];
        kmMat4 projectionMatrix;
        kmMat4 modelViewMatrix;
        kmGLEnum matrixMode;
    };

    Cocos2DRenderer();
    virtual ~Cocos2DRenderer();

    Size getViewportSize();
    float getSizeNextPOT(float sz) const;
    void captureRenderState(RenderStateSnapshot& state) const;
    void restoreRenderState(const RenderStateSnapshot& state) const;
    void applyUIRenderState();

    static String d_rendererID;
    Size d_displaySize;
    Vector2 d_displayDPI;
    RenderingRoot* d_defaultRoot;
    RenderTarget* d_defaultTarget;

    typedef std::vector<TextureTarget*> TextureTargetList;
    TextureTargetList d_textureTargets;

    typedef std::vector<Cocos2DGeometryBuffer*> GeometryBufferList;
    GeometryBufferList d_geometryBuffers;

    typedef std::vector<Cocos2DTexture*> TextureList;
    TextureList d_textures;

    struct PendingTextureLoad
    {
        PendingTextureLoad(Cocos2DTexture* texture, const String& filename,
            const String& resourceGroup) :
            texture(texture),
            filename(filename),
            resourceGroup(resourceGroup)
        {
        }

        Cocos2DTexture* texture;
        String filename;
        String resourceGroup;
    };
    typedef std::vector<PendingTextureLoad> PendingTextureLoadList;
    PendingTextureLoadList d_pendingTextureLoads;

    uint d_maxTextureSize;
    bool d_supportNPOTTex;
    bool d_supportNonSquareTex;
    bool d_SeparateAlphaBlendCap;

    typedef std::vector<RenderStateSnapshot> RenderStateStack;
    RenderStateStack d_renderStateStack;
    RenderStateStack d_externalStateStack;
    RenderStateStack d_uiStateStack;
    unsigned int d_externalPassDepth;

    typedef std::vector<Cocos2DTexture*> RenderTextureList;
    RenderTextureList d_RenderTextures;
};

} // End of  CEGUI namespace section

#if defined(_MSC_VER)
#   pragma warning(pop)
#endif

#endif // end of guard _CEGUICocos2DRenderer_h_
