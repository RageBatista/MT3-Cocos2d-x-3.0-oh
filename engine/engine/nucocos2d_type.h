//  cocos2d_type.h
//  engine

#ifndef __Nuclear_cocos2d_type_H__
#define __Nuclear_cocos2d_type_H__
#include "nuxptypes.h"
#include <cocos2d.h>

namespace Nuclear
{
    cocos2d::Texture2D::PixelFormat GetCCPixelFormatFromXP(NuclearPixelFormat aPF);
    cocos2d::Texture2D::PixelFormat GetCCPixelFormatFromXP(NuclearTextureFormat aPTF);
    
}// namespace Nuclear

#endif
