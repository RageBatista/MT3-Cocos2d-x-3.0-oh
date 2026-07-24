/****************************************************************************
 Copyright (c) 2011 cocos2d-x.org

 http://www.cocos2d-x.org

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 ****************************************************************************/

#include "CCLuaEngine.h"
#include "cocos2d.h"
#include "cocoa/CCArray.h"
#include "CCScheduler.h"
#include "cocos-ext.h"

extern "C" {
#include "tolua++.h"
#include "tolua_fix.h"
}

NS_CC_BEGIN

namespace {

static bool pushNamedLuaFunction(lua_State* L, const char* functionName)
{
    if (!L || !functionName || functionName[0] == '\0')
    {
        CCLOG("[LUA ERROR] empty function name");
        return false;
    }

    int top = lua_gettop(L);
    std::string name(functionName);
    std::string::size_type dot = name.find('.');
    if (dot == std::string::npos)
    {
        lua_getglobal(L, name.c_str());
    }
    else
    {
        lua_getglobal(L, name.substr(0, dot).c_str());
        if (!lua_istable(L, -1))
        {
            lua_settop(L, top);
            CCLOG("[LUA ERROR] name '%s' does not start with a Lua table", functionName);
            return false;
        }

        std::string::size_type start = dot + 1;
        while (true)
        {
            dot = name.find('.', start);
            std::string part = (dot == std::string::npos)
                ? name.substr(start)
                : name.substr(start, dot - start);
            lua_pushstring(L, part.c_str());
            lua_gettable(L, -2);
            lua_remove(L, -2);

            if (dot == std::string::npos)
            {
                break;
            }

            if (!lua_istable(L, -1))
            {
                lua_settop(L, top);
                CCLOG("[LUA ERROR] name '%s' has a non-table component '%s'", functionName, part.c_str());
                return false;
            }
            start = dot + 1;
        }
    }

    if (!lua_isfunction(L, -1))
    {
        lua_settop(L, top);
        CCLOG("[LUA ERROR] name '%s' does not represent a Lua function", functionName);
        return false;
    }

    return true;
}

} // namespace

CCLuaEngine* CCLuaEngine::m_defaultEngine = NULL;

CCLuaEngine* CCLuaEngine::defaultEngine(void)
{
    if (!m_defaultEngine)
    {
        m_defaultEngine = new CCLuaEngine();
        m_defaultEngine->init();
    }
    return m_defaultEngine;
}

CCLuaEngine* CCLuaEngine::engine(void)
{
    return defaultEngine();
}

CCLuaEngine::~CCLuaEngine(void)
{
    CC_SAFE_RELEASE(m_stack);
    m_defaultEngine = NULL;
}

bool CCLuaEngine::init(void)
{
    m_stack = CCLuaStack::create();
    m_stack->retain();
    return true;
}

lua_State* CCLuaEngine::getLuaState(void)
{
    return m_stack ? m_stack->getLuaState() : NULL;
}

void CCLuaEngine::addSearchPath(const char* path)
{
    m_stack->addSearchPath(path);
}

void CCLuaEngine::addLuaLoader(lua_CFunction func)
{
    m_stack->addLuaLoader(func);
}

void CCLuaEngine::removeScriptObjectByCCObject(CCObject* pObj)
{
    m_stack->removeScriptObjectByCCObject(pObj);
}

void CCLuaEngine::removeCCObjectByID(int nLuaID)
{
    toluafix_remove_ccobject_by_refid(getLuaState(), nLuaID);
}

void CCLuaEngine::removeScriptHandler(int nHandler)
{
    m_stack->removeScriptHandler(nHandler);
}

void CCLuaEngine::removeLuaHandler(int nHandler)
{
    removeScriptHandler(nHandler);
}

int CCLuaEngine::executeString(const char *codes)
{
    int ret = m_stack->executeString(codes);
    m_stack->clean();
    return ret;
}

int CCLuaEngine::executeString(const char *codes, bool bGC)
{
    int ret = executeString(codes);
    if (bGC)
    {
        collectMemory();
    }
    return ret;
}

int CCLuaEngine::executeScriptFile(const char* filename)
{
    int ret = m_stack->executeScriptFile(filename);
    m_stack->clean();
    return ret;
}

int CCLuaEngine::executeGlobalFunction(const char* functionName)
{
    return executeGlobalFunction(functionName, 0);
}

int CCLuaEngine::executeGlobalFunction(const char* functionName, int numArgs)
{
    lua_State* L = getLuaState();
    if (!pushNamedLuaFunction(L, functionName))
    {
        m_stack->clean();
        return 0;
    }

    if (numArgs > 0)
    {
        lua_insert(L, -(numArgs + 1));
    }

    int ret = m_stack->executeFunction(numArgs);
    m_stack->clean();
    return ret;
}

std::string CCLuaEngine::executeGlobalFunctionBackString(const char* functionName, int numArgs)
{
    lua_State* L = getLuaState();
    std::string ret;

    if (!pushNamedLuaFunction(L, functionName))
    {
        m_stack->clean();
        return ret;
    }

    if (numArgs > 0)
    {
        lua_insert(L, -(numArgs + 1));
    }

    int functionIndex = -(numArgs + 1);
    int traceback = 0;
    lua_getglobal(L, "__G__TRACKBACK__");
    if (!lua_isfunction(L, -1))
    {
        lua_pop(L, 1);
    }
    else
    {
        lua_insert(L, functionIndex - 1);
        traceback = functionIndex - 1;
    }

    int error = lua_pcall(L, numArgs, 1, traceback);
    if (error)
    {
        CCLOG("[LUA ERROR] %s", lua_tostring(L, -1));
        m_stack->clean();
        return ret;
    }

    if (lua_isstring(L, -1))
    {
        ret = lua_tostring(L, -1);
    }

    m_stack->clean();
    return ret;
}

int CCLuaEngine::executeGlobalFunctionWithIntegerData(const char* functionName, int data)
{
    pushIntegerToLuaStack(data);
    return executeGlobalFunction(functionName, 1);
}

int CCLuaEngine::executeGlobalFunctionWithDoubleData(const char* functionName, double data)
{
    lua_pushnumber(getLuaState(), data);
    return executeGlobalFunction(functionName, 1);
}

int CCLuaEngine::executeGlobalFunctionWithBooleanData(const char* functionName, bool data)
{
    m_stack->pushBoolean(data);
    return executeGlobalFunction(functionName, 1);
}

int CCLuaEngine::executeGlobalFunctionWithStringData(const char* functionName, const char* data)
{
    m_stack->pushString(data ? data : "");
    return executeGlobalFunction(functionName, 1);
}

int CCLuaEngine::executeGlobalFunctionWithParamsData(const char* functionName, double param0, double param1, double param2, double param3)
{
    lua_State* L = getLuaState();
    lua_pushnumber(L, param0);
    lua_pushnumber(L, param1);
    lua_pushnumber(L, param2);
    lua_pushnumber(L, param3);
    return executeGlobalFunction(functionName, 4);
}

int CCLuaEngine::executeGlobalFunctionWithParamsData(const char* functionName, double param0, double param1, double param2, double param3, double param4)
{
    lua_State* L = getLuaState();
    lua_pushnumber(L, param0);
    lua_pushnumber(L, param1);
    lua_pushnumber(L, param2);
    lua_pushnumber(L, param3);
    lua_pushnumber(L, param4);
    return executeGlobalFunction(functionName, 5);
}

int CCLuaEngine::executeGlobalFunctionWithParamsData(const char* functionName, void* param0, double param1, double param2, double param3)
{
    lua_State* L = getLuaState();
    lua_pushlightuserdata(L, param0);
    lua_pushnumber(L, param1);
    lua_pushnumber(L, param2);
    lua_pushnumber(L, param3);
    return executeGlobalFunction(functionName, 4);
}

int CCLuaEngine::executeGlobalFunctionWithParamsData(const char* functionName, void* param0, void* param1, double param2, double param3)
{
    lua_State* L = getLuaState();
    lua_pushlightuserdata(L, param0);
    lua_pushlightuserdata(L, param1);
    lua_pushnumber(L, param2);
    lua_pushnumber(L, param3);
    return executeGlobalFunction(functionName, 4);
}

int CCLuaEngine::executeGlobalFunctionWithParamsData(const char* functionName, int param0, int param1, int param2, int param3)
{
    pushIntegerToLuaStack(param0);
    pushIntegerToLuaStack(param1);
    pushIntegerToLuaStack(param2);
    pushIntegerToLuaStack(param3);
    return executeGlobalFunction(functionName, 4);
}

int CCLuaEngine::executeGlobalFunctionWithParamsData(const char* functionName, const char* param0, const char* param1, const char* param2, const char* param3)
{
    m_stack->pushString(param0 ? param0 : "");
    m_stack->pushString(param1 ? param1 : "");
    m_stack->pushString(param2 ? param2 : "");
    m_stack->pushString(param3 ? param3 : "");
    return executeGlobalFunction(functionName, 4);
}

int CCLuaEngine::executeGlobalFunctionWithParamsData(const char* functionName, const char* param0, int param1, int param2, int param3, int param4)
{
    m_stack->pushString(param0 ? param0 : "");
    pushIntegerToLuaStack(param1);
    pushIntegerToLuaStack(param2);
    pushIntegerToLuaStack(param3);
    pushIntegerToLuaStack(param4);
    return executeGlobalFunction(functionName, 5);
}

int CCLuaEngine::executeGlobalFunctionWithData(const char* functionName, void* param0, int param1)
{
    lua_pushlightuserdata(getLuaState(), param0);
    pushIntegerToLuaStack(param1);
    return executeGlobalFunction(functionName, 2);
}

int CCLuaEngine::executeGlobalFunctionWith2Int(const char* functionName, int param0, int param1)
{
    pushIntegerToLuaStack(param0);
    pushIntegerToLuaStack(param1);
    return executeGlobalFunction(functionName, 2);
}

int CCLuaEngine::executeNodeEvent(CCNode* pNode, int nAction)
{
    int nHandler = pNode->getScriptHandler();
    if (!nHandler) return 0;
    
    switch (nAction)
    {
        case kCCNodeOnEnter:
            m_stack->pushString("enter");
            break;
            
        case kCCNodeOnExit:
            m_stack->pushString("exit");
            break;
            
        case kCCNodeOnEnterTransitionDidFinish:
            m_stack->pushString("enterTransitionFinish");
            break;
            
        case kCCNodeOnExitTransitionDidStart:
            m_stack->pushString("exitTransitionStart");
            break;
            
        case kCCNodeOnCleanup:
            m_stack->pushString("cleanup");
            break;
            
        default:
            return 0;
    }
    int ret = m_stack->executeFunctionByHandler(nHandler, 1);
    m_stack->clean();
    return ret;
}

int CCLuaEngine::executeMenuItemEvent(CCMenuItem* pMenuItem)
{
    int nHandler = pMenuItem->getScriptTapHandler();
    if (!nHandler) return 0;
    
    m_stack->pushInt(pMenuItem->getTag());
    m_stack->pushCCObject(pMenuItem, "CCMenuItem");
    int ret = m_stack->executeFunctionByHandler(nHandler, 2);
    m_stack->clean();
    return ret;
}

int CCLuaEngine::executeNotificationEvent(CCNotificationCenter* pNotificationCenter, const char* pszName)
{
    int nHandler = pNotificationCenter->getObserverHandlerByName(pszName);
    if (!nHandler) return 0;
    
    m_stack->pushString(pszName);
    int ret = m_stack->executeFunctionByHandler(nHandler, 1);
    m_stack->clean();
    return ret;
}

int CCLuaEngine::executeCallFuncActionEvent(CCCallFunc* pAction, CCObject* pTarget/* = NULL*/)
{
    int nHandler = pAction->getScriptHandler();
    if (!nHandler) return 0;
    
    if (pTarget)
    {
        m_stack->pushCCObject(pTarget, "CCNode");
    }
    int ret = m_stack->executeFunctionByHandler(nHandler, pTarget ? 1 : 0);
    m_stack->clean();
    return ret;
}

int CCLuaEngine::executeSchedule(int nHandler, float dt, CCNode* pNode/* = NULL*/)
{
    if (!nHandler) return 0;
    m_stack->pushFloat(dt);
    int ret = m_stack->executeFunctionByHandler(nHandler, 1);
    m_stack->clean();
    return ret;
}

int CCLuaEngine::executeLayerTouchEvent(CCLayer* pLayer, int eventType, CCTouch *pTouch)
{
    CCTouchScriptHandlerEntry* pScriptHandlerEntry = pLayer->getScriptTouchHandlerEntry();
    if (!pScriptHandlerEntry) return 0;
    int nHandler = pScriptHandlerEntry->getHandler();
    if (!nHandler) return 0;
    
    switch (eventType)
    {
        case CCTOUCHBEGAN:
            m_stack->pushString("began");
            break;
            
        case CCTOUCHMOVED:
            m_stack->pushString("moved");
            break;
            
        case CCTOUCHENDED:
            m_stack->pushString("ended");
            break;
            
        case CCTOUCHCANCELLED:
            m_stack->pushString("cancelled");
            break;
            
        default:
            return 0;
    }
    
    const CCPoint pt = CCDirector::sharedDirector()->convertToGL(pTouch->getLocationInView());
    m_stack->pushFloat(pt.x);
    m_stack->pushFloat(pt.y);
    int ret = m_stack->executeFunctionByHandler(nHandler, 3);
    m_stack->clean();
    return ret;
}

int CCLuaEngine::executeLayerTouchesEvent(CCLayer* pLayer, int eventType, CCSet *pTouches)
{
    CCTouchScriptHandlerEntry* pScriptHandlerEntry = pLayer->getScriptTouchHandlerEntry();
    if (!pScriptHandlerEntry) return 0;
    int nHandler = pScriptHandlerEntry->getHandler();
    if (!nHandler) return 0;
    
    switch (eventType)
    {
        case CCTOUCHBEGAN:
            m_stack->pushString("began");
            break;
            
        case CCTOUCHMOVED:
            m_stack->pushString("moved");
            break;
            
        case CCTOUCHENDED:
            m_stack->pushString("ended");
            break;
            
        case CCTOUCHCANCELLED:
            m_stack->pushString("cancelled");
            break;
            
        default:
            return 0;
    }

    CCDirector* pDirector = CCDirector::sharedDirector();
    lua_State *L = m_stack->getLuaState();
    lua_newtable(L);
    int i = 1;
    for (CCSetIterator it = pTouches->begin(); it != pTouches->end(); ++it)
    {
        CCTouch* pTouch = (CCTouch*)*it;
        CCPoint pt = pDirector->convertToGL(pTouch->getLocationInView());
        lua_pushnumber(L, pt.x);
        lua_rawseti(L, -2, i++);
        lua_pushnumber(L, pt.y);
        lua_rawseti(L, -2, i++);
        lua_pushinteger(L, pTouch->getID());
        lua_rawseti(L, -2, i++);
    }
    int ret = m_stack->executeFunctionByHandler(nHandler, 2);
    m_stack->clean();
    return ret;
}

int CCLuaEngine::executeLayerKeypadEvent(CCLayer* pLayer, int eventType)
{
    CCScriptHandlerEntry* pScriptHandlerEntry = pLayer->getScriptKeypadHandlerEntry();
    if (!pScriptHandlerEntry)
        return 0;
    int nHandler = pScriptHandlerEntry->getHandler();
    if (!nHandler) return 0;
    
    switch (eventType)
    {
        case kTypeBackClicked:
            m_stack->pushString("backClicked");
            break;
            
        case kTypeMenuClicked:
            m_stack->pushString("menuClicked");
            break;
            
        default:
            return 0;
    }
    int ret = m_stack->executeFunctionByHandler(nHandler, 1);
    m_stack->clean();
    return ret;
}

int CCLuaEngine::executeAccelerometerEvent(CCLayer* pLayer, CCAcceleration* pAccelerationValue)
{
    CCScriptHandlerEntry* pScriptHandlerEntry = pLayer->getScriptAccelerateHandlerEntry();
    if (!pScriptHandlerEntry)
        return 0;
    int nHandler = pScriptHandlerEntry->getHandler();
    if (!nHandler) return 0;
    
    m_stack->pushFloat(pAccelerationValue->x);
    m_stack->pushFloat(pAccelerationValue->y);
    m_stack->pushFloat(pAccelerationValue->z);
    m_stack->pushFloat(pAccelerationValue->timestamp);
    int ret = m_stack->executeFunctionByHandler(nHandler, 4);
    m_stack->clean();
    return ret;
}

int CCLuaEngine::executeEvent(int nHandler, const char* pEventName, CCObject* pEventSource /* = NULL*/, const char* pEventSourceClassName /* = NULL*/)
{
    m_stack->pushString(pEventName);
    if (pEventSource)
    {
        m_stack->pushCCObject(pEventSource, pEventSourceClassName ? pEventSourceClassName : "CCObject");
    }
    int ret = m_stack->executeFunctionByHandler(nHandler, pEventSource ? 2 : 1);
    m_stack->clean();
    return ret;
}

bool CCLuaEngine::handleAssert(const char *msg)
{
    bool ret = m_stack->handleAssert(msg);
    m_stack->clean();
    return ret;
}

int CCLuaEngine::reallocateScriptHandler(int nHandler)
{    
    int nRet = m_stack->reallocateScriptHandler(nHandler);
    m_stack->clean();
    return nRet;
}

int CCLuaEngine::executeTableViewEvent(int nEventType,cocos2d::extension::CCTableView* pTableView,void* pValue, CCArray* pResultArray)
{
    if (NULL == pTableView)
        return 0;
    
    int nHanlder = pTableView->getScriptHandler(nEventType);
    if (0 == nHanlder)
        return 0;
    
    int nRet = 0;
    switch (nEventType)
    {
        case cocos2d::extension::CCTableView::kTableViewScroll:
        case cocos2d::extension::CCTableView::kTableViewZoom:
            {
                m_stack->pushCCObject(pTableView, "CCTableView");
                nRet = m_stack->executeFunctionByHandler(nHanlder, 1);
            }
            break;
        case cocos2d::extension::CCTableView::kTableCellTouched:
        case cocos2d::extension::CCTableView::kTableCellHighLight:
        case cocos2d::extension::CCTableView::kTableCellUnhighLight:
        case cocos2d::extension::CCTableView::kTableCellWillRecycle:
            {
                m_stack->pushCCObject(pTableView, "CCTableView");
                m_stack->pushCCObject(static_cast<cocos2d::extension::CCTableViewCell*>(pValue), "CCTableViewCell");
                nRet = m_stack->executeFunctionByHandler(nHanlder, 2);
            }
            break;
        case cocos2d::extension::CCTableView::kTableCellSizeForIndex:
            {
                m_stack->pushCCObject(pTableView, "CCTableView");
                m_stack->pushInt(*((int*)pValue));
                nRet = m_stack->executeFunctionReturnArray(nHanlder, 2, 2, pResultArray);
            }
            break;
        case cocos2d::extension::CCTableView::kTableCellSizeAtIndex:
            {
                m_stack->pushCCObject(pTableView, "CCTableView");
                m_stack->pushInt(*((int*)pValue));
                nRet = m_stack->executeFunctionReturnArray(nHanlder, 2, 1, pResultArray);
            }
            break;
        case cocos2d::extension::CCTableView::kNumberOfCellsInTableView:
            {
                m_stack->pushCCObject(pTableView, "CCTableView");
                nRet = m_stack->executeFunctionReturnArray(nHanlder, 1, 1, pResultArray);
            }
            break;
        default:
            break;
    }
    return nRet;
}

int CCLuaEngine::executeEventWithArgs(int nHandler, CCArray* pArgs)
{
    if (NULL == pArgs)
        return 0;
    
    CCObject*   pObject = NULL;
    
    CCInteger*  pIntVal = NULL;
    CCString*   pStrVal = NULL;
    CCDouble*   pDoubleVal = NULL;
    CCFloat*    pFloatVal = NULL;
    CCBool*     pBoolVal = NULL;
   

    int nArgNums = 0;
    for (unsigned int i = 0; i < pArgs->count(); i++)
    {
        pObject = pArgs->objectAtIndex(i);
        if (NULL != (pIntVal = dynamic_cast<CCInteger*>(pObject)))
        {
            m_stack->pushInt(pIntVal->getValue());
            nArgNums++;
        }
        else if (NULL != (pStrVal = dynamic_cast<CCString*>(pObject)))
        {
            m_stack->pushString(pStrVal->getCString());
            nArgNums++;
        }
        else if (NULL != (pDoubleVal = dynamic_cast<CCDouble*>(pObject)))
        {
            m_stack->pushFloat(pDoubleVal->getValue());
            nArgNums++;
        }
        else if (NULL != (pFloatVal = dynamic_cast<CCFloat*>(pObject)))
        {
            m_stack->pushFloat(pFloatVal->getValue());
            nArgNums++;
        }
        else if (NULL != (pBoolVal = dynamic_cast<CCBool*>(pObject)))
        {
            m_stack->pushBoolean(pBoolVal->getValue());
            nArgNums++;
        }
        else if(NULL != pObject)
        {
            m_stack->pushCCObject(pObject, "CCObject");
            nArgNums++;
        }
    }
    
    return  m_stack->executeFunctionByHandler(nHandler, nArgNums);
}

int CCLuaEngine::executeFunctionByHandler(int nHandler, int numArgs)
{
    return m_stack->executeFunctionByHandler(nHandler, numArgs);
}

int CCLuaEngine::executeFunctionWithIntegerData(int nHandler, int data)
{
    pushIntegerToLuaStack(data);
    return executeFunctionByHandler(nHandler, 1);
}

int CCLuaEngine::executeFunctionWithFloatData(int nHandler, float data)
{
    pushFloatToLuaStack(data);
    return executeFunctionByHandler(nHandler, 1);
}

int CCLuaEngine::executeFunctionWithBooleanData(int nHandler, bool data)
{
    m_stack->pushBoolean(data);
    return executeFunctionByHandler(nHandler, 1);
}

int CCLuaEngine::executeFunctionWithStringData(int nHandler, const char* data)
{
    m_stack->pushString(data ? data : "");
    return executeFunctionByHandler(nHandler, 1);
}

int CCLuaEngine::executeFunctionWithCCObject(int nHandler, CCObject* pObject, const char* typeName)
{
    if (pObject)
    {
        m_stack->pushCCObject(pObject, typeName ? typeName : "CCObject");
    }
    else
    {
        m_stack->pushNil();
    }
    return executeFunctionByHandler(nHandler, 1);
}

int CCLuaEngine::executeFunctionWithParamsData(int nHandler, double param0, double param1, double param2, double param3)
{
    lua_State* L = getLuaState();
    lua_pushnumber(L, param0);
    lua_pushnumber(L, param1);
    lua_pushnumber(L, param2);
    lua_pushnumber(L, param3);
    return executeFunctionByHandler(nHandler, 4);
}

int CCLuaEngine::pushIntegerToLuaStack(int data)
{
    m_stack->pushInt(data);
    return lua_gettop(getLuaState());
}

int CCLuaEngine::pushInt64ToLuaStack(int64_t data)
{
    lua_pushnumber(getLuaState(), static_cast<lua_Number>(data));
    return lua_gettop(getLuaState());
}

int CCLuaEngine::pushFloatToLuaStack(float data)
{
    m_stack->pushFloat(data);
    return lua_gettop(getLuaState());
}

int CCLuaEngine::pushBooleanToLuaStack(int data)
{
    m_stack->pushBoolean(data != 0);
    return lua_gettop(getLuaState());
}

int CCLuaEngine::pushStringToLuaStack(const char* data)
{
    m_stack->pushString(data ? data : "");
    return lua_gettop(getLuaState());
}

int CCLuaEngine::pushUserDataToLuaStack(void* data)
{
    lua_pushlightuserdata(getLuaState(), data);
    return lua_gettop(getLuaState());
}

int CCLuaEngine::pushCCObjectToLuaStack(CCObject* pObject, const char* typeName)
{
    if (pObject)
    {
        m_stack->pushCCObject(pObject, typeName ? typeName : "CCObject");
    }
    else
    {
        m_stack->pushNil();
    }
    return lua_gettop(getLuaState());
}

bool CCLuaEngine::executeProtocolHandler(int nHandler, const aio::Protocol& e)
{
    tolua_pushusertype(getLuaState(), (void*)&e, "const aio::Protocol");
    return executeFunctionByHandler(nHandler, 1) != 0;
}

void CCLuaEngine::executeLuaProtocolHandler(int nHandler, const aio::LuaProtocol& lp)
{
    tolua_pushusertype(getLuaState(), (void*)&lp, "const aio::LuaProtocol");
    executeFunctionByHandler(nHandler, 1);
}

void CCLuaEngine::collectMemory()
{
    lua_gc(getLuaState(), LUA_GCCOLLECT, 0);
}

bool CCLuaEngine::parseConfig(CCScriptEngineProtocol::ConfigType type, const std::string& str)
{
    lua_getglobal(m_stack->getLuaState(), "__onParseConfig");
    if (!lua_isfunction(m_stack->getLuaState(), -1))
    {
        CCLOG("[LUA ERROR] name '%s' does not represent a Lua function", "__onParseConfig");
        lua_pop(m_stack->getLuaState(), 1);
        return false;
    }
    
    m_stack->pushInt((int)type);
    m_stack->pushString(str.c_str());
    
    return m_stack->executeFunction(2);
}

NS_CC_END
