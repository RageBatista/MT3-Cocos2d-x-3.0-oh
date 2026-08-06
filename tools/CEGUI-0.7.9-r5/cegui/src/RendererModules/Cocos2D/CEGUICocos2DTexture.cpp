#define NOMINMAX
#include "CEGUICocos2DTexture.h"

#include "CEGUIExceptions.h"
#include "CEGUISystem.h"
#include "CEGUIImageCodec.h"
#include "CEGUIImageset.h"
#include "CEGUILogger.h"

#include "RendererModules/Cocos2D/CEGUICocos2DGL.h"
#include "2d/ccGLStateCache.h"

#include <limits>
#include <vector>

using cocos2d::Texture2D;

#ifdef _MSC_VER
#pragma pack(push,1)
#endif
    typedef struct {
        uint32_t version;
        uint32_t flags;
        uint64_t pixelFormat;
        uint32_t colorSpace;
        uint32_t channelType;
        uint32_t height;
        uint32_t width;
        uint32_t depth;
        uint32_t numberOfSurfaces;
        uint32_t numberOfFaces;
        uint32_t numberOfMipmaps;
        uint32_t metadataLength;
#ifdef _MSC_VER
    } ccPVRv3TexHeader;
#pragma pack(pop)
#else
} __attribute__((packed)) ccPVRv3TexHeader;
#endif

namespace CEGUI
{

Cocos2DTexture::Cocos2DTexture(Cocos2DRenderer& owner) :
    d_owner(owner),
    d_texture(0),
    d_size(0, 0),
    d_dataSize(0, 0),
    d_texelScaling(0, 0),
    d_savedSurfaceDescValid(false),
    m_bIsLoading(false),
    m_bIsLoadFromFile(false),
    m_bLoadFailed(false),
    m_bDestroyPending(false),
    d_pImageset(NULL)
{
}

Cocos2DTexture::Cocos2DTexture(Cocos2DRenderer& owner,
                                   const String& filename,
                                   const String& resourceGroup) :
    d_owner(owner),
    d_texture(0),
    d_size(0, 0),
    d_dataSize(0, 0),
    d_texelScaling(0, 0),
    d_savedSurfaceDescValid(false),
    m_bIsLoading(false),
    m_bIsLoadFromFile(true),
    m_bLoadFailed(false),
    m_bDestroyPending(false),
    d_pImageset(NULL),
    d_filename(filename)
{
    //loadFromFile(filename, resourceGroup);
}

Cocos2DTexture::Cocos2DTexture(Cocos2DRenderer& owner, const Size& sz) :
    d_owner(owner),
    d_texture(0),
    d_size(0, 0),
    d_dataSize(sz),
    d_texelScaling(0, 0),
    d_savedSurfaceDescValid(false),
    m_bIsLoading(false),
    m_bIsLoadFromFile(false),
    m_bLoadFailed(false),
    m_bDestroyPending(false),
    d_pImageset(NULL)
{
    assert("not implemented!" && false);
}

Cocos2DTexture::Cocos2DTexture(Cocos2DRenderer& owner,
                                   cocos2d::Texture2D* tex) :
    d_owner(owner),
    d_texture(0),
    d_size(0, 0),
    d_dataSize(0, 0),
    d_texelScaling(0, 0),
    d_savedSurfaceDescValid(false),
    m_bIsLoading(false),
    m_bIsLoadFromFile(false),
    m_bLoadFailed(tex == NULL),
    m_bDestroyPending(false),
    d_pImageset(NULL)
{
    setCocos2DTexture(tex);
}

Cocos2DTexture::~Cocos2DTexture()
{
    cleanupCocos2DTexture();

    // Never touch Imageset objects here. During shutdown, Imageset lifetime
    // may already be invalid and cross-object cleanup can crash.
    d_pImageset = NULL;
}

GLuint Cocos2DTexture::getTextureName() const
{
    return d_texture ? d_texture->getName() : 0;
}

String Cocos2DTexture::getFileName() const
{
    return d_filename;
}

const Size& Cocos2DTexture::getSize() const
{
    return d_size;
}

const Size& Cocos2DTexture::getOriginalDataSize() const
{
    return d_dataSize;
}

const Vector2& Cocos2DTexture::getTexelScaling() const
{
    return d_texelScaling;
}

void Cocos2DTexture::loadFromFile(const String& filename,
                                  const String& resourceGroup)
{
    // get and check existence of CEGUI::System (needed to access ImageCodec)
    System* sys = System::getSingletonPtr();
    if (!sys)
        CEGUI_THROW(RendererException("Cocos2DTexture::loadFromFile - "
                                      "CEGUI::System object has not been created: "
                                      "unable to access ImageCodec."));

    RawDataContainer texFile;
    System::getSingleton().getResourceProvider()->loadRawDataContainer(filename, texFile, resourceGroup);

    if (!texFile.getDataPtr() || texFile.getSize() == 0)
    {
        Logger::getSingleton().logEvent(
            "Cocos2DTexture::loadFromFile - Resource provider returned no data for image '" +
            filename + "' in group '" + resourceGroup + "'.",
            Errors);
        m_bLoadFailed = true;
        return;
    }

    Texture* res = sys->getImageCodec().load(texFile, this);

    if (!res)
        // It's an error
        CEGUI_THROW(RendererException("Cocos2DTexture::loadFromFile - " +
                                      sys->getImageCodec().getIdentifierString() +
                                      " failed to load image '" + filename + "'."));
}

//----------------------------------------------------------------------------//
void Cocos2DTexture::loadFromMemory(const void* buffer,
                                      const Size& buffer_size,
                                      PixelFormat pixel_format)
{
    if (!buffer || buffer_size.d_width <= 0.0f || buffer_size.d_height <= 0.0f)
    {
        throw RendererException("Cocos2DTexture::loadFromMemory failed: invalid buffer or size.");
    }

    cleanupCocos2DTexture();
    m_bLoadFailed = true;

    Texture2D::PixelFormat pixfmt;
    switch (pixel_format)
    {
    case PF_RGB:
        pixfmt = Texture2D::PixelFormat::RGB888;
        break;
    case PF_RGBA:
        pixfmt = Texture2D::PixelFormat::RGBA8888;
        break;
    default:
        throw RendererException("Cocos2DTexture::loadFromMemory failed: "
                                "Invalid PixelFormat value specified.");
    }

    d_texture = new Texture2D();
    const int width = static_cast<int>(buffer_size.d_width);
    const int height = static_cast<int>(buffer_size.d_height);
    const ssize_t dataLen = width * height * ((pixel_format == PF_RGBA) ? 4 : 3);

    bool initSucceeded = d_texture->initWithData(buffer, dataLen, pixfmt,
        width, height, cocos2d::Size(buffer_size.d_width, buffer_size.d_height));

    if (!initSucceeded)
    {
        delete d_texture;
        d_texture = NULL;
        return;
    }

    d_dataSize = buffer_size;
    updateTextureSize();
    updateCachedScaleValues();
    m_bLoadFailed = false;
}

//----------------------------------------------------------------------------//
void Cocos2DTexture::loadFromBuffer(const void* buffer, const Size& buffer_size, PixelFormat pixel_format)
{
    if (!buffer || buffer_size.d_width <= 0.0f || buffer_size.d_height <= 0.0f)
    {
        throw RendererException("Cocos2DTexture::loadFromBuffer failed: invalid buffer or size.");
    }

    cleanupCocos2DTexture();
    m_bLoadFailed = true;

    const int width = static_cast<int>(buffer_size.d_width);
    const int height = static_cast<int>(buffer_size.d_height);

    Texture2D::PixelFormat pixfmt;
    switch (pixel_format)
    {
        case PF_RGB:
            pixfmt = Texture2D::PixelFormat::RGB888;
            break;
        case PF_RGBA:
            pixfmt = Texture2D::PixelFormat::RGBA8888;
            break;
        case PF_PVR2:
            pixfmt = Texture2D::PixelFormat::PVRTC2;
            break;
        case PF_PVR4:
            pixfmt = Texture2D::PixelFormat::PVRTC4;
            break;
        case PF_ATC_Exp:
            pixfmt = Texture2D::PixelFormat::ATC_EXPLICIT_ALPHA;
            break;
        case PF_ATC_Int:
            pixfmt = Texture2D::PixelFormat::ATC_INTERPOLATED_ALPHA;
            break;
        case PF_DXT3:
            pixfmt = Texture2D::PixelFormat::S3TC_DXT3;
            break;
        case PF_DXT5:
            pixfmt = Texture2D::PixelFormat::S3TC_DXT5;
            break;
        case PF_ETC:
            pixfmt = Texture2D::PixelFormat::ETC;
            break;
        default:
            throw RendererException("Cocos2DTexture::loadFromBuffer failed: "
                                    "Invalid PixelFormat value specified.");
    }

    d_texture = new Texture2D();

    bool bRet = false;

    if (pixel_format == PF_PVR2 || pixel_format == PF_PVR4)
    {
#if 0
        // TODO: MT3 compressed texture - need to port custom initWith* methods to 3.0-oh Texture2D
        ccPVRv3TexHeader *header = (ccPVRv3TexHeader *)buffer;
        bRet = d_texture->initWithPVRTCData(((unsigned char *)buffer)+(sizeof(ccPVRv3TexHeader) + header->metadataLength), 0, (pixel_format == PF_PVR2)?2:4, true, buffer_size.d_width, pixfmt);
#else
        ccPVRv3TexHeader *header = (ccPVRv3TexHeader *)buffer;
        const unsigned char* dataPtr = ((unsigned char *)buffer) + (sizeof(ccPVRv3TexHeader) + header->metadataLength);
        const ssize_t dataLen = width * height / ((pixel_format == PF_PVR2) ? 4 : 2);
        bRet = d_texture->initWithData(dataPtr, dataLen, pixfmt, width, height, cocos2d::Size(buffer_size.d_width, buffer_size.d_height));
#endif
    }
    else if (pixel_format == PF_ATC_Exp || pixel_format == PF_ATC_Int)
    {
#if 0
        // TODO: MT3 compressed texture - need to port custom initWith* methods to 3.0-oh Texture2D
        bRet = d_texture->initWithATCData(((unsigned char *)buffer) + 4*sizeof(unsigned int), 0, 8, true, buffer_size.d_width, buffer_size.d_height, pixfmt);
#else
        const unsigned char* dataPtr = ((unsigned char *)buffer) + 4 * sizeof(unsigned int);
        const ssize_t dataLen = width * height;
        bRet = d_texture->initWithData(dataPtr, dataLen, pixfmt, width, height, cocos2d::Size(buffer_size.d_width, buffer_size.d_height));
#endif
    }
    else if (pixel_format == PF_DXT3 || pixel_format == PF_DXT5)
    {
#if 0
        // TODO: MT3 compressed texture - need to port custom initWith* methods to 3.0-oh Texture2D
        bRet = d_texture->initWithDDSCompressData(((unsigned char*)buffer) + 128, 0, 8, true, buffer_size.d_width, buffer_size.d_height, pixfmt);
#else
        const unsigned char* dataPtr = ((unsigned char*)buffer) + 128;
        const ssize_t dataLen = width * height;
        bRet = d_texture->initWithData(dataPtr, dataLen, pixfmt, width, height, cocos2d::Size(buffer_size.d_width, buffer_size.d_height));
#endif
    }
    else if (pixel_format == PF_ETC)
    {
#if 0
        // TODO: MT3 compressed texture - need to port custom initWith* methods to 3.0-oh Texture2D
        unsigned int* pVal = (unsigned int*)buffer;
        //pVal[7];//alpha size
        //pVal[8];//buffer size
        bRet = d_texture->initWithETCData(((unsigned char *)buffer), 0, 8, true, buffer_size.d_width, buffer_size.d_height, Texture2D::PixelFormat::ETC);
#else
        const ssize_t dataLen = width * height / 2;
        bRet = d_texture->initWithData(buffer, dataLen, Texture2D::PixelFormat::ETC, width, height, cocos2d::Size(buffer_size.d_width, buffer_size.d_height));
#endif
    }
    else
    {
        const ssize_t dataLen = width * height * ((pixel_format == PF_RGBA) ? 4 : 3);
        bRet = d_texture->initWithData(buffer, dataLen, pixfmt, width, height, cocos2d::Size(buffer_size.d_width, buffer_size.d_height));
    }

    if (!bRet)
    {
        delete d_texture;
        d_texture = NULL;
        return;
    }

    d_dataSize = buffer_size;
    updateTextureSize();
    updateCachedScaleValues();
    m_bLoadFailed = false;
}

//----------------------------------------------------------------------------//
void Cocos2DTexture::updataFromMemory(const void* buffer,
                                      const Size& buffer_size,
                                      const Rect& srcRect,
                                      PixelFormat pixel_format)
{
    if (!buffer)
    {
        throw RendererException("Cocos2DTexture::updateFromMemory failed: null buffer.");
    }

    const size_t stride = pixel_format == PF_RGBA ? 4 : pixel_format == PF_RGB ? 3 : 0;
    const GLenum format = pixel_format == PF_RGBA ? GL_RGBA : pixel_format == PF_RGB ? GL_RGB : 0;
    if (stride == 0)
    {
        throw RendererException("Cocos2DTexture::updateFromMemory failed: invalid pixel format.");
    }

    const int bufferWidth = static_cast<int>(buffer_size.d_width);
    const int bufferHeight = static_cast<int>(buffer_size.d_height);
    const int left = static_cast<int>(srcRect.d_left);
    const int top = static_cast<int>(srcRect.d_top);
    const int right = static_cast<int>(srcRect.d_right);
    const int bottom = static_cast<int>(srcRect.d_bottom);
    if (bufferWidth <= 0 || bufferHeight <= 0 ||
        buffer_size.d_width != static_cast<float>(bufferWidth) ||
        buffer_size.d_height != static_cast<float>(bufferHeight) ||
        srcRect.d_left != static_cast<float>(left) ||
        srcRect.d_top != static_cast<float>(top) ||
        srcRect.d_right != static_cast<float>(right) ||
        srcRect.d_bottom != static_cast<float>(bottom) ||
        left < 0 || top < 0 || right < left || bottom < top ||
        right > bufferWidth || bottom > bufferHeight)
    {
        throw RendererException("Cocos2DTexture::updateFromMemory failed: invalid source rectangle.");
    }

    if (d_texture &&
        (right > static_cast<int>(d_size.d_width) || bottom > static_cast<int>(d_size.d_height)))
    {
        throw RendererException("Cocos2DTexture::updateFromMemory failed: rectangle exceeds texture size.");
    }

    // FreeType uses zero-area rectangles for whitespace and other empty glyphs.
    // A new texture still needs the complete coverage page, while an existing
    // texture has nothing to upload for an empty sub-rectangle.
    const bool emptyRect = right == left || bottom == top;
    if (d_texture && emptyRect)
    {
        return;
    }

    const int uploadWidth = d_texture ? right - left : bufferWidth;
    const int uploadHeight = d_texture ? bottom - top : bufferHeight;
    const int sourceLeft = d_texture ? left : 0;
    const int sourceTop = d_texture ? top : 0;

    if (static_cast<size_t>(uploadWidth) >
        std::numeric_limits<size_t>::max() / static_cast<size_t>(uploadHeight))
    {
        throw RendererException("Cocos2DTexture::updateFromMemory failed: upload size overflow.");
    }
    const size_t pixelCount = static_cast<size_t>(uploadWidth) * static_cast<size_t>(uploadHeight);
    if (pixelCount > std::numeric_limits<size_t>::max() / stride)
    {
        throw RendererException("Cocos2DTexture::updateFromMemory failed: upload size overflow.");
    }

    std::vector<unsigned char> converted(pixelCount * stride);
    const unsigned char* source = static_cast<const unsigned char*>(buffer);
    for (int row = 0; row < uploadHeight; ++row)
    {
        for (int column = 0; column < uploadWidth; ++column)
        {
            const unsigned char coverage = source[
                static_cast<size_t>(sourceTop + row) * static_cast<size_t>(bufferWidth) +
                static_cast<size_t>(sourceLeft + column)];
            unsigned char* destination = &converted[
                (static_cast<size_t>(row) * static_cast<size_t>(uploadWidth) +
                 static_cast<size_t>(column)) * stride];
            if (pixel_format == PF_RGBA)
            {
                destination[0] = 0xff;
                destination[1] = 0xff;
                destination[2] = 0xff;
                destination[3] = coverage;
            }
            else
            {
                destination[0] = coverage;
                destination[1] = coverage;
                destination[2] = coverage;
            }
        }
    }

    if (!d_texture)
    {
        loadFromMemory(&converted[0], buffer_size, pixel_format);
        return;
    }

    GLint oldActiveTexture = GL_TEXTURE0;
    GLint oldTexture = 0;
    GLint oldUnpackAlignment = 4;
    glGetIntegerv(GL_ACTIVE_TEXTURE, &oldActiveTexture);
    cocos2d::GL::activeTexture(GL_TEXTURE0);
    glGetIntegerv(GL_TEXTURE_BINDING_2D, &oldTexture);
    glGetIntegerv(GL_UNPACK_ALIGNMENT, &oldUnpackAlignment);
    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
    cocos2d::GL::bindTexture2D(d_texture->getName());
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexSubImage2D(GL_TEXTURE_2D, 0, left, top, uploadWidth, uploadHeight,
        format, GL_UNSIGNED_BYTE, &converted[0]);
    glPixelStorei(GL_UNPACK_ALIGNMENT, oldUnpackAlignment);
    cocos2d::GL::bindTexture2D(static_cast<GLuint>(oldTexture));
    cocos2d::GL::activeTexture(static_cast<GLenum>(oldActiveTexture));
}

//----------------------------------------------------------------------------//
void Cocos2DTexture::saveToMemory(void* buffer)
{
    // TODO:
    throw RendererException("Cocos2DTexture::saveToMemory - Unimplemented!");
}

//----------------------------------------------------------------------------//
void Cocos2DTexture::cleanupCocos2DTexture()
{
    if (d_texture)
    {
        d_texture->release();
        d_texture = 0;
    }
}

//----------------------------------------------------------------------------//
void Cocos2DTexture::updateCachedScaleValues()
{
    //
    // calculate what to use for x scale
    //
    const float orgW = d_dataSize.d_width;
    const float texW = d_size.d_width;

    // if texture and original data width are the same, scale is based
    // on the original size.
    // if texture is wider (and source data was not stretched), scale
    // is based on the size of the resulting texture.
    const float scaleWidth = (orgW == texW) ? orgW : texW;
    d_texelScaling.d_x = scaleWidth > 0.0f ? 1.0f / scaleWidth : 0.0f;

    //
    // calculate what to use for y scale
    //
    const float orgH = d_dataSize.d_height;
    const float texH = d_size.d_height;

    // if texture and original data height are the same, scale is based
    // on the original size.
    // if texture is taller (and source data was not stretched), scale
    // is based on the size of the resulting texture.
    const float scaleHeight = (orgH == texH) ? orgH : texH;
    d_texelScaling.d_y = scaleHeight > 0.0f ? 1.0f / scaleHeight : 0.0f;
}

//----------------------------------------------------------------------------//
void Cocos2DTexture::updateTextureSize()
{
    if (d_texture)
    {
        d_size.d_width = d_texture->getPixelsWide();
        d_size.d_height = d_texture->getPixelsHigh();
    }
    // use the original size if query failed.
    // NB: This should probably be an exception.
    else
        d_size = d_dataSize;
}

//----------------------------------------------------------------------------//
void Cocos2DTexture::setOriginalDataSize(const Size& sz)
{
    d_dataSize = sz;
    updateCachedScaleValues();
}

//----------------------------------------------------------------------------//
void Cocos2DTexture::setCocos2DTexture(cocos2d::Texture2D* tex)
{
    if (d_texture != tex)
    {
        cleanupCocos2DTexture();
        d_dataSize.d_width = d_dataSize.d_height = 0;

        d_texture = tex;
        if (d_texture)
            d_texture->retain();
    }

    updateTextureSize();
    d_dataSize = d_size;
    updateCachedScaleValues();
    m_bLoadFailed = d_texture == NULL;
}

//----------------------------------------------------------------------------//
void Cocos2DTexture::preD3DReset()
{
    // if already saved surface info, or we have no texture, do nothing
    if (d_savedSurfaceDescValid || !d_texture)
        return;

    // get info about our texture
    //d_texture->GetLevelDesc(0, &d_savedSurfaceDesc);

    // if texture is managed, we have nothing more to do
    //if (d_savedSurfaceDesc.Pool == D3DPOOL_MANAGED)
    //    return;

    // otherwise release texture.
    //d_texture->Release();
    //d_texture = 0;
    //d_savedSurfaceDescValid = true;
}

//----------------------------------------------------------------------------//
void Cocos2DTexture::postD3DReset()
{
    // if texture has no saved surface info, we do nothing.
    if (!d_savedSurfaceDescValid)
        return;

    // otherwise, create a new texture using saved details.
    //d_owner.getDevice()->
    //   CreateTexture(d_savedSurfaceDesc.Width,
    //                d_savedSurfaceDesc.Height,
    //                1, d_savedSurfaceDesc.Usage, d_savedSurfaceDesc.Format,
    //                d_savedSurfaceDesc.Pool, &d_texture, 0);

    d_savedSurfaceDescValid = false;
}

//----------------------------------------------------------------------------//

} // End of  CEGUI namespace section
