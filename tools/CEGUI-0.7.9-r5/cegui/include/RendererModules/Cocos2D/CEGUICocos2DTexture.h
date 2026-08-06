#ifndef _CEGUICocos2DTexture_h_
#define _CEGUICocos2DTexture_h_

#include "../../CEGUIBase.h"
#include "../../CEGUIRenderer.h"
#include "../../CEGUITexture.h"
#include "CEGUICocos2DRenderer.h"

#include "RendererModules/Cocos2D/CEGUICocos2DGL.h"
#include "2d/CCTexture2D.h"

namespace CEGUI
{

class COCOS2D_GUIRENDERER_API Cocos2DTexture : public Texture
{
public:
    bool m_bIsLoadFromFile;
    bool m_bIsLoading;
    bool m_bLoadFailed;
    bool m_bDestroyPending;

    bool isEtc() const { return false; /* TODO: MT3 compressed texture - isEtcTexture() not available in 3.0-oh Texture2D */ }
    GLuint getAlphaName() const { return 0; /* TODO: MT3 compressed texture - getAlphaName() not available in 3.0-oh Texture2D */ }
    bool hasTexture() const { return d_texture != NULL; }
    GLuint       getTextureName() const;
    String       getFileName() const;
    void         setOriginalDataSize(const Size& sz);
    void         preD3DReset();
    void         postD3DReset();

    // implements Texture Interface (CEGUI 0.7.9-r5)
    virtual const Size&     getSize() const;
    virtual const Size&     getOriginalDataSize() const;
    virtual const Vector2&  getTexelScaling() const;
    virtual void            loadFromFile(const String& filename, const String& resourceGroup);
    virtual void            loadFromMemory(const void* buffer, const Size& buffer_size, PixelFormat pixel_format);
    virtual void            saveToMemory(void* buffer);

    // MT3 extensions (not in 0.7.9 base)
    virtual void loadFromBuffer(const void* buffer, const Size& buffer_size, PixelFormat pixel_format);
    virtual void updataFromMemory(const void* buffer, const Size& buffer_size,
        const Rect& rect, PixelFormat pixel_format);

    virtual void setImageSet(const Imageset* pImageset) { d_pImageset = const_cast<Imageset*>(pImageset); }

    virtual ~Cocos2DTexture();

protected:
    friend Texture& Cocos2DRenderer::createTexture(void);
    friend Texture& Cocos2DRenderer::createTexture(const String&, const String&);
    friend Texture& Cocos2DRenderer::createTexture(const Size&);
    friend Texture& Cocos2DRenderer::createTexture(cocos2d::Texture2D* pTexture);
    friend void Cocos2DRenderer::destroyTexture(Texture& texture);
    friend void Cocos2DRenderer::OnFrameEnd();

    Cocos2DTexture(Cocos2DRenderer& owner);
    Cocos2DTexture(Cocos2DRenderer& owner, const String& filename, const String& resourceGroup);
    Cocos2DTexture(Cocos2DRenderer& owner, const Size& sz);
    Cocos2DTexture(Cocos2DRenderer& owner, cocos2d::Texture2D* tex);

    void cleanupCocos2DTexture();
    void updateCachedScaleValues();
    void updateTextureSize();
    void setCocos2DTexture(cocos2d::Texture2D* tex);

    Cocos2DRenderer& d_owner;
    cocos2d::Texture2D* d_texture;
    Size d_size;
    Size d_dataSize;
    Vector2 d_texelScaling;
    bool d_savedSurfaceDescValid;
    Imageset* d_pImageset;
    String d_filename;
};

} // End of  CEGUI namespace section

#endif // end of guard _CEGUICocos2DTexture_h_
