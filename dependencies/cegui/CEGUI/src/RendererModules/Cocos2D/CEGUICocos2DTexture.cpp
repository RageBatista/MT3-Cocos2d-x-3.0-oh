#define NOMINMAX
#include "CEGUICocos2DTexture.h"

#include "CEGUIExceptions.h"
#include "CEGUISystem.h"
#include "CEGUIImageCodec.h"
#include <CEGUIDefaultResourceProvider.h>
#include <CCGL.h>
#include <shaders/ccGLStateCache.h>
#include "CEGUIResLoadThread.h"
#include "CEGUIImageset.h"

#include <limits>
#include <vector>

#if (defined WIN7_32) && (defined _DEBUG)
#include "CEGUIPfsResourceProvider.h"
#endif

#ifdef PUBLISHED_VERSION
#include "Nuclear.h"
//#include "cocos2d_render.h"
#endif

using cocos2d::CCTexture2D;
using cocos2d::CCTextureCache;

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
	assert("not impelemented!" && false);
    /*Size tex_sz(d_owner.getAdjustedSize(sz));

    HRESULT hr = D3DXCreateTexture(d_owner.getDevice(),
                                   static_cast<UINT>(tex_sz.d_width),
                                   static_cast<UINT>(tex_sz.d_height),
                                   1, 0, D3DFMT_A8R8G8B8, D3DPOOL_MANAGED,
                                   &d_texture);

    if (FAILED(hr))
        throw RendererException(
            "Cocos2DTexture - Failed to create texture of specified size: "
            "D3D Texture creation failed.");

    updateTextureSize();
    updateCachedScaleValues();*/
}

Cocos2DTexture::Cocos2DTexture(Cocos2DRenderer& owner,
                                   cocos2d::CCTexture2D* tex) :
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
#if (defined WIN7_32) && (defined _DEBUG)
	std::wstring strFileName = PFSResourceProvider::GUIStringToWString(filename);
#endif
	// get and check existence of CEGUI::System (needed to access ImageCodec)
    System* sys = System::getSingletonPtr();
    if (!sys)
        CEGUI_THROW(RendererException("OpenGLTexture::loadFromFile - "
                                      "CEGUI::System object has not been created: "
                                      "unable to access ImageCodec."));
    timeval t;
    gettimeofday((struct timeval *)&t,  0);
    
    // CEGUIResLoadThread threadd; // yeqing 2015-10-19 �˴�����û�����ã�ע�͵�
#if (defined PUBLISHED_VERSION) && !(defined FORCEGUIEDITOR)
	LJFM::LJFMID texFile;
#else
	CEGUI::RawDataContainer texFile;
#endif
    System::getSingleton().getResourceProvider()->loadRawDataContainer(filename, texFile, resourceGroup);
    timeval t2;
    gettimeofday((struct timeval *)&t2,  0);
    
    printf("tick-loadfile:%ld\n", t2.tv_usec - t.tv_usec);
#if (defined PUBLISHED_VERSION) && !(defined FORCEGUIEDITOR)
    CodecPrivateData* pData = NULL;
    Texture* res = sys->getImageCodec().load(texFile, this, &pData);
    delete pData;
#else
	Texture* res = sys->getImageCodec().load(texFile, this);
#endif

    if (!res)
        // It's an error
        CEGUI_THROW(RendererException("OpenGLTexture::loadFromFile - " +
                                      sys->getImageCodec().getIdentifierString() +
                                      " failed to load image '" + filename + "'."));
}
    
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

void Cocos2DTexture::loadFromBuffer(const void* buffer, const Size& buffer_size, PixelFormat pixel_format)
    {
        if (!buffer || buffer_size.d_width <= 0.0f || buffer_size.d_height <= 0.0f)
        {
            throw RendererException("Cocos2DTexture::loadFromBuffer failed: invalid buffer or size.");
        }

        cleanupCocos2DTexture();
        m_bLoadFailed = true;
        
        cocos2d::CCTexture2DPixelFormat pixfmt;
        switch (pixel_format)
        {
            case PF_RGB:
                pixfmt = cocos2d::kCCTexture2DPixelFormat_RGB888;
                break;
            case PF_RGBA:
                pixfmt = cocos2d::kCCTexture2DPixelFormat_RGBA8888;
                break;
            case PF_PVR2:
                pixfmt = cocos2d::kCCTexture2DPixelFormat_PVRTC2;
                break;
            case PF_PVR4:
                pixfmt = cocos2d::kCCTexture2DPixelFormat_PVRTC4;
                break;
            case PF_ATC_Exp:
                pixfmt = cocos2d::kCCTexture2DPixelFormat_ATC_Explicit;
                break;
            case PF_ATC_Int:
                pixfmt = cocos2d::kCCTexture2DPixelFormat_ATC_Interpolated;
                break;
            case PF_DXT3:
                pixfmt = cocos2d::kCCTexture2DPixelFormat_DXT3;
                break;
            case PF_DXT5:
                pixfmt = cocos2d::kCCTexture2DPixelFormat_DXT5;
                break;
            case PF_ETC:
                pixfmt = cocos2d::kCCTexture2DPixelFormat_ETC;
                break;
            default:
                throw RendererException("Cocos2DTexture::loadFromMemory failed: "
                                        "Invalid PixelFormat value specified.");
        }
        
        d_texture = new CCTexture2D();
        
        bool bRet = false;

        if (pixel_format == PF_PVR2 || pixel_format == PF_PVR4)
        {
            ccPVRv3TexHeader *header = (ccPVRv3TexHeader *)buffer;
            bRet = d_texture->initWithPVRTCData(((unsigned char *)buffer)+(sizeof(ccPVRv3TexHeader) + header->metadataLength) , 0, (pixel_format == PF_PVR2)?2:4, true, buffer_size.d_width, pixfmt);
		}
		else if(pixel_format == PF_ATC_Exp || pixel_format == PF_ATC_Int)
        {
            bRet = d_texture->initWithATCData(((unsigned char *)buffer) + 4*sizeof(unsigned int), 0, 8, true, buffer_size.d_width, buffer_size.d_height, pixfmt);
        }
		else if(pixel_format == PF_DXT3 || pixel_format == PF_DXT5)
        {
            bRet = d_texture->initWithDDSCompressData(((unsigned char*)buffer) + 128, 0, 8, true, buffer_size.d_width, buffer_size.d_height, pixfmt);
        }
		else if(pixel_format == PF_ETC)
        {
            unsigned int* pVal = (unsigned int*)buffer;
            //pVal[7];//alpha size
            //pVal[8];//buffer size
           bRet = d_texture->initWithETCData(((unsigned char *)buffer), 0, 8, true, buffer_size.d_width, buffer_size.d_height, cocos2d::kCCTexture2DPixelFormat_ETC);
        }
		else
        {
			int iScale = 100;
			if (!cocos2d::CCImage::IsNormal())
			{
				iScale = 50;
			}
			bRet = d_texture->initWithData(buffer, pixfmt, buffer_size.d_width, buffer_size.d_height, cocos2d::CCSize(buffer_size.d_width, buffer_size.d_height), iScale);
        }

        if(!bRet)
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

void Cocos2DTexture::loadFromMemory(const void* buffer,
                                      const Size& buffer_size,
                                      PixelFormat pixel_format, bool async )
{
    if (async) {
        return;
    }
	if (!buffer || buffer_size.d_width <= 0.0f || buffer_size.d_height <= 0.0f)
	{
		throw RendererException("Cocos2DTexture::loadFromMemory failed: invalid buffer or size.");
	}

    cleanupCocos2DTexture();
	m_bLoadFailed = true;

	cocos2d::CCTexture2DPixelFormat pixfmt;
    switch (pixel_format)
    {
    case PF_RGB:
        pixfmt = cocos2d::kCCTexture2DPixelFormat_RGB888;
        break;
    case PF_RGBA:
        pixfmt = cocos2d::kCCTexture2DPixelFormat_RGBA8888;
        break;
    case PF_PVR2:
        pixfmt = cocos2d::kCCTexture2DPixelFormat_PVRTC2;
        break;
    case PF_PVR4:
        pixfmt = cocos2d::kCCTexture2DPixelFormat_PVRTC4;
        break;
    case PF_ATC_Exp:
        pixfmt = cocos2d::kCCTexture2DPixelFormat_ATC_Explicit;
        break;
    case PF_ATC_Int:
        pixfmt = cocos2d::kCCTexture2DPixelFormat_ATC_Interpolated;
        break;
    case PF_DXT3:
        pixfmt = cocos2d::kCCTexture2DPixelFormat_DXT3;
        break;
    case PF_DXT5:
        pixfmt = cocos2d::kCCTexture2DPixelFormat_DXT5;
        break;
    case PF_ETC:
        pixfmt = cocos2d::kCCTexture2DPixelFormat_ETC;
        break;
    default:
        throw RendererException("Cocos2DTexture::loadFromMemory failed: "
                                "Invalid PixelFormat value specified.");
    }
    
	d_texture = new CCTexture2D();
	bool initSucceeded = false;

    if (pixel_format == PF_PVR2 || pixel_format == PF_PVR4)
    {
		initSucceeded = d_texture->initWithPVRTCData(((unsigned char *)buffer), 0, (pixel_format == PF_PVR2)?2:4, true, buffer_size.d_width, pixfmt);
	}
	else if(pixel_format == PF_ATC_Exp || pixel_format == PF_ATC_Int)
    {
		initSucceeded = d_texture->initWithATCData(((unsigned char *)buffer) + 4*sizeof(unsigned int), 0, 8, true, buffer_size.d_width, buffer_size.d_height, pixfmt);
    }
	else if(pixel_format == PF_DXT3 || pixel_format == PF_DXT5)
    {
		initSucceeded = d_texture->initWithDDSCompressData(((unsigned char*)buffer) + 128, 0, 8, true, buffer_size.d_width, buffer_size.d_height, pixfmt);
    }
	else if(pixel_format == PF_ETC)
    {
		initSucceeded = d_texture->initWithETCData(((unsigned char *)buffer), 0, 8, true, buffer_size.d_width, buffer_size.d_height, cocos2d::kCCTexture2DPixelFormat_ETC);
    }
	else
    {
		initSucceeded = d_texture->initWithData(buffer, pixfmt, buffer_size.d_width, buffer_size.d_height, cocos2d::CCSize(buffer_size.d_width, buffer_size.d_height));
    }

	if (!initSucceeded)
	{
		delete d_texture;
		d_texture = NULL;
		return;
	}

//#if CC_ENABLE_CACHE_TEXTURE_DATA
//    void* buffer2 = const_cast<void*>(buffer);
//    const cocos2d::CCSize& s = d_texture->getContentSizeInPixels();
//    cocos2d::VolatileTexture::addDataTexture(d_texture, buffer2, pixfmt, s);    
//#endif
	d_dataSize = buffer_size;
	updateTextureSize();
	updateCachedScaleValues();
	m_bLoadFailed = false;
}

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
		loadFromMemory(&converted[0], buffer_size, pixel_format, false);
		return;
	}

	GLint oldActiveTexture = GL_TEXTURE0;
	GLint oldTexture = 0;
	GLint oldUnpackAlignment = 4;
	glGetIntegerv(GL_ACTIVE_TEXTURE, &oldActiveTexture);
	cocos2d::ccGLActiveTexture(GL_TEXTURE0);
	glGetIntegerv(GL_TEXTURE_BINDING_2D, &oldTexture);
	glGetIntegerv(GL_UNPACK_ALIGNMENT, &oldUnpackAlignment);
	glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
	cocos2d::ccGLBindTexture2D(d_texture->getName());
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	glTexSubImage2D(GL_TEXTURE_2D, 0, left, top, uploadWidth, uploadHeight,
		format, GL_UNSIGNED_BYTE, &converted[0]);
	glPixelStorei(GL_UNPACK_ALIGNMENT, oldUnpackAlignment);
	cocos2d::ccGLBindTexture2D(static_cast<GLuint>(oldTexture));
	cocos2d::ccGLActiveTexture(static_cast<GLenum>(oldActiveTexture));
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

void Cocos2DTexture::setCocos2DTexture(cocos2d::CCTexture2D* tex)
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
