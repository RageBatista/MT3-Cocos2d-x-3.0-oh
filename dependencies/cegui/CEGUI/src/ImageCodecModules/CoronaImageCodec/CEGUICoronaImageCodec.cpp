/***********************************************************************
	filename: 	CEGUICoronaImageCodec.cpp
	created:	07/06/2006
	author:		Olivier Delannoy 
	
	purpose:	This codec provide Corona based image loading 
*************************************************************************/
/***************************************************************************
 *   Copyright (C) 2004 - 2009 Paul D Turner & The CEGUI Development Team
 *
 *   Permission is hereby granted, free of charge, to any person obtaining
 *   a copy of this software and associated documentation files (the
 *   "Software"), to deal in the Software without restriction, including
 *   without limitation the rights to use, copy, modify, merge, publish,
 *   distribute, sublicense, and/or sell copies of the Software, and to
 *   permit persons to whom the Software is furnished to do so, subject to
 *   the following conditions:
 *
 *   The above copyright notice and this permission notice shall be
 *   included in all copies or substantial portions of the Software.
 *
 *   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 *   EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 *   MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 *   IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
 *   OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
 *   ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 *   OTHER DEALINGS IN THE SOFTWARE.
 ***************************************************************************/
#include "ImageCodecModules/CoronaImageCodec/CEGUICoronaImageCodec.h"
#include "CEGUILogger.h" 
#include "CEGUISize.h"

#include <corona.h> 
#include <stdlib.h>
#include <string.h>

// Start of CEGUI namespace section
namespace CEGUI
{
namespace
{
class CodecPrivateDataCorona : public CodecPrivateData
{
public:
    CodecPrivateDataCorona()
        : d_pixels(0)
        , d_width(0)
        , d_height(0)
        , d_format(Texture::PF_RGBA)
    {
    }

    virtual ~CodecPrivateDataCorona()
    {
        free(d_pixels);
    }

    virtual void* GetDataPtr()
    {
        return d_pixels;
    }

    virtual int GetWidth()
    {
        return d_width;
    }

    virtual int GetHeight()
    {
        return d_height;
    }

    virtual Texture::PixelFormat GetFmt()
    {
        return d_format;
    }

    void setImageData(corona::Image& image, Texture::PixelFormat format, bool keepPixels)
    {
        d_width = image.getWidth();
        d_height = image.getHeight();
        d_format = format;

        if (keepPixels)
        {
            const int pixelSize = corona::GetPixelSize(corona::PF_R8G8B8A8);
            const size_t pixelBytes = static_cast<size_t>(d_width) * static_cast<size_t>(d_height) *
                                      static_cast<size_t>(pixelSize);
            d_pixels = malloc(pixelBytes);
            if (d_pixels)
            {
                memcpy(d_pixels, image.getPixels(), pixelBytes);
            }
        }
    }

private:
    void* d_pixels;
    int d_width;
    int d_height;
    Texture::PixelFormat d_format;
};

Texture* loadCoronaImageFromMemory(const void* data, size_t size, Texture* result,
                                   bool bSyn, CodecPrivateDataCorona* privateData)
{
    corona::File* texFile = corona::CreateMemoryFile(data, static_cast<int>(size));
    if (texFile == 0)
    {
        Logger::getSingleton().logEvent("Unable to create corona::File object", Errors);
        return 0;
    }

    corona::Image* texImg = corona::OpenImage(texFile, corona::PF_R8G8B8A8);
    delete texFile;

    if (texImg == 0)
    {
        Logger::getSingleton().logEvent("Unable to load image, corona::OpenImage failed", Errors);
        return 0;
    }

    result->loadFromMemory(texImg->getPixels(),
                           Size(texImg->getWidth(),
                                texImg->getHeight()),
                           Texture::PF_RGBA,
                           bSyn);

    if (privateData)
    {
        privateData->setImageData(*texImg, Texture::PF_RGBA, bSyn);
    }

    delete texImg;
    return result;
}
}

CoronaImageCodec::CoronaImageCodec()
    : ImageCodec("CoronaImageCodec - Official Corona based image codec")
{
    corona::FileFormatDesc** formats = corona::GetSupportedReadFormats();
    for (size_t i = 0 ; formats[i] ; ++i)
    {
        for (size_t j = 0 ; j < formats[i]->getExtensionCount() ; ++j)
        {
            if (!d_supportedFormat.empty())
            {
                d_supportedFormat += " ";
            }
            d_supportedFormat += formats[i]->getExtension(j);
        }
    }
}

CoronaImageCodec::~CoronaImageCodec()
{
}

Texture* CoronaImageCodec::load(const RawDataContainer& data, Texture* result, bool bSyn)
{
    return loadCoronaImageFromMemory(data.getDataPtr(), data.getSize(), result, bSyn, 0);
}

#if (defined PUBLISHED_VERSION) && !(defined FORCEGUIEDITOR)
Texture* CoronaImageCodec::load(const LJFM::LJFMID& data, Texture* result,
                                CodecPrivateData** aPrivate, bool bSyn)
{
    CodecPrivateDataCorona* privateData = new CodecPrivateDataCorona;
    *aPrivate = privateData;

    Texture* loaded = loadCoronaImageFromMemory(data.GetData(), data.GetSize(), result, bSyn, privateData);
    if (!loaded)
    {
        delete privateData;
        *aPrivate = 0;
    }

    return loaded;
}
#endif


} // End of CEGUI namespace section 
