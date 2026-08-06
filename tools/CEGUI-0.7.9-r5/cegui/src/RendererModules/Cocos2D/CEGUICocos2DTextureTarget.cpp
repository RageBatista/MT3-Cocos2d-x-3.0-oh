#define NOMINMAX
#include "CEGUICocos2DTextureTarget.h"

#include "CEGUIExceptions.h"
#include "CEGUISystem.h"

#include "CEGUICocos2DRenderer.h"
#include "CEGUICocos2DTexture.h"

#include "2d/CCRenderTexture.h"
#include "2d/CCSprite.h"
#include "2d/platform/CCImage.h"
#include "RendererModules/Cocos2D/CEGUICocos2DGL.h"

#include <cstring>

namespace CEGUI
{
const float Cocos2DTextureTarget::DEFAULT_SIZE = 128.0f;

Cocos2DTextureTarget::Cocos2DTextureTarget(Cocos2DRenderer& owner) :
    Cocos2DRenderTarget(owner),
    d_surface(0),
    d_texture(0)
{
    declareRenderSize(Size(DEFAULT_SIZE, DEFAULT_SIZE));
}

Cocos2DTextureTarget::~Cocos2DTextureTarget()
{
    cleanupRenderTexture();
}

void Cocos2DTextureTarget::declareRenderSize(const Size& sz)
{
    // exit if current size is enough
    if ((d_area.getWidth() >= sz.d_width) && (d_area.getHeight() >= sz.d_height))
        return;

    setArea(Rect(d_area.getPosition(), sz));
    resizeRenderTexture();
    clear();
}

bool Cocos2DTextureTarget::isImageryCache() const
{
    return true;
}

void Cocos2DTextureTarget::activate()
{
    d_surface->begin();
    Cocos2DRenderTarget::activate();
    glViewport(0, 0,
        static_cast<GLsizei>(d_area.getWidth()),
        static_cast<GLsizei>(d_area.getHeight()));
}

void Cocos2DTextureTarget::deactivate()
{
    Cocos2DRenderTarget::deactivate();
    d_surface->end();
}

void Cocos2DTextureTarget::clear()
{
    if (d_surface)
    {
        d_surface->beginWithClear(0, 0, 0, 0);
        d_surface->end();
    }
}

Texture& Cocos2DTextureTarget::getTexture() const
{
    return *d_texture;
}

void Cocos2DTextureTarget::initialiseRenderTexture()
{
    Size tex_sz(d_owner.getAdjustedSize(d_area.getSize()));

    d_surface = cocos2d::RenderTexture::create(
        static_cast<int>(tex_sz.d_width),
        static_cast<int>(tex_sz.d_height));

    if (d_surface)
        d_surface->retain();

    if (d_surface && d_surface->getSprite())
    {
        cocos2d::Texture2D* tex2D = d_surface->getSprite()->getTexture();
        d_texture = &static_cast<Cocos2DTexture&>(
            d_owner.createTexture(tex2D));
        d_texture->setOriginalDataSize(d_area.getSize());
    }
}

void Cocos2DTextureTarget::resizeRenderTexture()
{
    cleanupRenderTexture();
    initialiseRenderTexture();
}

void Cocos2DTextureTarget::cleanupRenderTexture()
{
    if (d_surface)
    {
        d_surface->release();
        d_surface = 0;
    }

    if (d_texture)
    {
        d_owner.destroyTexture(*d_texture);
        d_texture = 0;
    }
}

bool Cocos2DTextureTarget::isRenderingInverted() const
{
    return true;
}

bool Cocos2DTextureTarget::saveToFile(const String& filename)
{
    if (d_surface)
    {
        cocos2d::Image* pImage = d_surface->newImage();
        if (pImage)
        {
            int areaWidth = static_cast<int>(d_area.getWidth());
            int areaHeight = static_cast<int>(d_area.getHeight());

            // If the render texture is larger than the declared area,
            // clamp the image data to the area size.
            if (pImage->getWidth() > areaWidth || pImage->getHeight() > areaHeight)
            {
                unsigned char* pClampedData = new unsigned char[areaWidth * areaHeight * 4];
                if (pClampedData)
                {
                    const unsigned char* pSrcData = pImage->getData();
                    for (int r = 0; r < areaHeight; ++r)
                    {
                        int srcR = pImage->getHeight() - areaHeight + r;
                        const unsigned char* pSrcLine = pSrcData + srcR * pImage->getWidth() * 4;
                        unsigned char* pDstLine = pClampedData + r * areaWidth * 4;
                        int copyBytes = areaWidth * 4;
                        std::memcpy(pDstLine, pSrcLine, copyBytes);
                    }

                    cocos2d::Image* pClampedImage = new cocos2d::Image();
                    if (pClampedImage)
                    {
                        if (pClampedImage->initWithRawData(pClampedData,
                            areaWidth * areaHeight * 4, areaWidth, areaHeight, 8))
                        {
                            delete pImage;
                            pImage = pClampedImage;
                        }
                        else
                        {
                            delete pClampedImage;
                        }
                    }

                    delete[] pClampedData;
                }
            }

            bool bRet = pImage->saveToFile(filename.c_str(), false);
            delete pImage;
            return bRet;
        }
    }
    return false;
}

void Cocos2DTextureTarget::preD3DReset()
{
    if (d_surface)
    {
        d_surface->release();
        d_surface = 0;
    }

    if (d_texture)
    {
        d_owner.destroyTexture(*d_texture);
        d_texture = 0;
    }
}

void Cocos2DTextureTarget::postD3DReset()
{
    assert("post reset not implement" && false);
}

} // End of  CEGUI namespace section
