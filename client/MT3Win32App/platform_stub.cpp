// Stub for CCTime::gettimeofdayCocos2d - required by engine.lib (Nuclear)
// This function is from cocos2d-x-3.0-oh/cocos/2d/platform/platform.cpp
// but cannot be compiled directly due to include path issues

#include "platform/platform.h"
#include "platform/CCPlatformConfig.h"

#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32
#include <WinSock2.h>  // for struct timeval

NS_CC_BEGIN

int CCTime::gettimeofdayCocos2d(struct cc_timeval *tp, void *tzp)
{
    CC_UNUSED_PARAM(tzp);
    if (tp)
    {
        gettimeofday((struct timeval *)tp, 0);
    }
    return 0;
}

double CCTime::timersubCocos2d(struct cc_timeval *start, struct cc_timeval *end)
{
    if (!start || !end)
    {
        return 0;
    }
    return ((end->tv_sec * 1000.0 + end->tv_usec / 1000.0) - (start->tv_sec * 1000.0 + start->tv_usec / 1000.0));
}

NS_CC_END
#endif