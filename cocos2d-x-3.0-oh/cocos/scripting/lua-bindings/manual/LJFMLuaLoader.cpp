#include "LJFMLuaLoader.h"

#include <algorithm>
#include <cwctype>
#include <string>

#include "cocos2d.h"
#include "ljfmext.h"
#include "utils/StringUtil.h"
#include "log/CoreLog.h"

#if defined(ANDROID) && defined(LOGCAT)
#include <android/log.h>
#define LOG_TAG "mt3"
#define LOGD(...) __android_log_print(ANDROID_LOG_DEBUG, LOG_TAG, __VA_ARGS__)
#else
#define LOGD(...)
#endif

extern "C"
{
int loader_LJFM(lua_State *L)
{
    std::string filename(luaL_checkstring(L, 1));
    std::replace(filename.begin(), filename.end(), '.', '/');
    filename.append(".lua");

    LOGD("filename:%s", filename.c_str());

    std::wstring packedName = L"/script/" + SHARE_String2Wstring(filename);
#ifndef NoPack
    std::transform(packedName.begin(), packedName.end(), packedName.begin(), ::towlower);
#endif

    LJFM::LJFMF file;
    if (!file.Open(packedName, LJFM::FM_EXCL, LJFM::FA_RDONLY))
    {
        LOGD("can not get file data %s", filename.c_str());
        lua_pushfstring(L, "\n\tpacked Lua module not found: %s", filename.c_str());
        return 1;
    }

    if (file.GetSize() == 0)
    {
        LOGD("file size is zero: %s", filename.c_str());
        lua_pushfstring(L, "\n\tpacked Lua module is empty: %s", filename.c_str());
        return 1;
    }

    LJFM::LJFMID image = file.GetImage();
    luaL_loadbuffer(L,
                    reinterpret_cast<const char*>(image.GetData()),
                    image.GetSize(),
                    filename.c_str());
    return 1;
}
}
