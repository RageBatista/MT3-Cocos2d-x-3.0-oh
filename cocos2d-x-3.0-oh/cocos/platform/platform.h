//  Compatibility shim for Cocos2d-x 3.0-oh
//  Maps platform/platform.h to 3.0-oh equivalents

#ifndef __PLATFORM_H__
#define __PLATFORM_H__

#include "base/CCPlatformMacros.h"
#include "2d/platform/CCThread.h"

NS_CC_BEGIN

struct cc_timeval
{
    long    tv_sec;     // seconds
    int     tv_usec;    // microSeconds
};

class CC_DLL CCTime
{
public:
    static int gettimeofdayCocos2d(struct cc_timeval *tp, void *tzp);
    static double timersubCocos2d(struct cc_timeval *start, struct cc_timeval *end);
};

NS_CC_END

#endif // __PLATFORM_H__