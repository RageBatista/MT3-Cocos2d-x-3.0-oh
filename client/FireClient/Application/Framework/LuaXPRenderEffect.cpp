#include "LuaXPRenderEffect.h"
#include "CCScriptSupport.h"
#include "CEGUI.h"
#include <stdarg.h>
#include <stdio.h>

#if defined(WIN32) && (defined(_DEBUG) || defined(DEBUG))
static void MT3LoginRenderTraceToFile(const char* fmt, ...)
{
    FILE* fp = NULL;
    if (fopen_s(&fp, "startup_bootstrap.log", "ab") != 0 || !fp)
    {
        return;
    }

    fputs("[MT3_LOGIN_RENDER] ", fp);
    va_list args;
    va_start(args, fmt);
    vfprintf(fp, fmt, args);
    va_end(args);
    fputs("\r\n", fp);
    fclose(fp);
}
#define MT3_LOGIN_RENDER_TRACE(...) MT3LoginRenderTraceToFile(__VA_ARGS__)
#else
#define MT3_LOGIN_RENDER_TRACE(...)
#endif

LuaXPRenderEffect::LuaXPRenderEffect(int userid, int handler):
m_iID(userid),m_iHandler(handler)
{ }

LuaXPRenderEffect::~LuaXPRenderEffect()
{ }

void LuaXPRenderEffect::performPostRenderFunctions()
{
    static int sCallCount = 0;
    ++sCallCount;
    if (sCallCount <= 20 || sCallCount == 60 || sCallCount == 180 || sCallCount == 600)
    {
        MT3_LOGIN_RENDER_TRACE("LuaXPRenderEffect::performPostRenderFunctions #%d this=%p id=%d handler=%d clip=%d scissor=%d,%d,%d,%d",
            sCallCount,
            this,
            m_iID,
            m_iHandler,
            m_bClip ? 1 : 0,
            scissor_x,
            scissor_y,
            scissor_w,
            scissor_h);
    }

    CEGUI::System::getSingleton().getRenderer()->endRendering();
    cocos2d::CCScriptEngineManager::sharedManager()->getScriptEngine()->executeFunctionWithIntegerData(m_iHandler, m_iID);
    CEGUI::System::getSingleton().getRenderer()->beginRendering();
}
