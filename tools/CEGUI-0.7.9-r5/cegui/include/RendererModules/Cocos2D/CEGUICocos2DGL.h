#ifndef _CEGUI_COCOS2D_GL_H_
#define _CEGUI_COCOS2D_GL_H_

#include "base/CCPlatformConfig.h"

#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
#   include "2d/platform/android/CCGL.h"
#elif CC_TARGET_PLATFORM == CC_PLATFORM_IOS
#   include "2d/platform/ios/CCGL.h"
#elif CC_TARGET_PLATFORM == CC_PLATFORM_WIN32
#   include "2d/platform/win32/CCGL.h"
#else
#   include "2d/platform/CCGL.h"
#endif

#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID || CC_TARGET_PLATFORM == CC_PLATFORM_IOS
#   ifndef GL_VERTEX_ARRAY_BINDING
#       define GL_VERTEX_ARRAY_BINDING GL_VERTEX_ARRAY_BINDING_OES
#   endif
#endif

#endif
