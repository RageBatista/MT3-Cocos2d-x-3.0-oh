/****************************************************************************
 Copyright (c) 2012      cocos2d-x.org
 Copyright (c) 2013-2014 Chukong Technologies Inc.
 
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

#ifndef __CC_LUA_ENGINE_H__
#define __CC_LUA_ENGINE_H__

extern "C" {
#include "lua.h"
}

#include "cocos2d.h"
#include "CCScriptSupport.h"
#include "CCLuaStack.h"
#include "CCLuaValue.h"
#include "LuaScriptHandlerMgr.h"

NS_CC_BEGIN

// Lua support for cocos2d-x
class LuaEngine : public ScriptEngineProtocol
{
public:
    static LuaEngine* getInstance(void);
    CC_DEPRECATED_ATTRIBUTE static LuaEngine* defaultEngine(void) { return LuaEngine::getInstance(); }
    virtual ~LuaEngine(void);
    
    virtual ccScriptType getScriptType() {
        return kScriptTypeLua;
    };

    LuaStack *getLuaStack(void) {
        return _stack;
    }
    
    /**
     @brief Add a path to find lua files in
     @param path to be added to the Lua path
     */
    virtual void addSearchPath(const char* path);
    
    /**
     @brief Add lua loader, now it is used on android
     */
    virtual void addLuaLoader(lua_CFunction func);
    
    /**
     @brief reload script code contained in the given string.
     @param moduleFileName String object holding the filename of the script file that is to be executed
     @return 0 if the string is excuted correctly.
     @return other if the string is excuted wrongly.
     */
    virtual int reload(const char* moduleFileName);
    
    /**
     @brief Remove Object from lua state
     @param object to remove
     */
    virtual void removeScriptObjectByObject(Ref* object);
    
    /**
     @brief Remove Lua function reference
     */
    virtual void removeScriptHandler(int nHandler);
    
    /**
     @brief Reallocate Lua function reference
     */
    virtual int reallocateScriptHandler(int nHandler);
    
    /**
     @brief Execute script code contained in the given string.
     @param codes holding the valid script code that should be executed.
     @return 0 if the string is excuted correctly.
     @return other if the string is excuted wrongly.
     */
    virtual int executeString(const char* codes);
    
    /**
     @brief Execute a script file.
     @param filename String object holding the filename of the script file that is to be executed
     */
    virtual int executeScriptFile(const char* filename);
    
    /**
     @brief Execute a scripted global function.
     @brief The function should not take any parameters and should return an integer.
     @param functionName String object holding the name of the function, in the global script environment, that is to be executed.
     @return The integer value returned from the script function.
     */
    virtual int executeGlobalFunction(const char* functionName);

    virtual int executeNodeEvent(Node* pNode, int nAction);
    virtual int executeMenuItemEvent(MenuItem* pMenuItem);
    virtual int executeNotificationEvent(__NotificationCenter* pNotificationCenter, const char* pszName);
    virtual int executeCallFuncActionEvent(CallFunc* pAction, Ref* pTarget = NULL);
    virtual int executeSchedule(int nHandler, float dt, Node* pNode = NULL);
    virtual int executeLayerTouchesEvent(Layer* pLayer, int eventType, __Set *pTouches);
    virtual int executeLayerTouchEvent(Layer* pLayer, int eventType, Touch *pTouch);
    virtual int executeLayerKeypadEvent(Layer* pLayer, int eventType);
    /** execute a accelerometer event */
    virtual int executeAccelerometerEvent(Layer* pLayer, Acceleration* pAccelerationValue);
    virtual int executeEvent(int nHandler, const char* pEventName, Ref* pEventSource = NULL, const char* pEventSourceClassName = NULL);

    virtual bool handleAssert(const char *msg);
    
    virtual bool parseConfig(ConfigType type, const std::string& str) override;
    virtual int sendEvent(ScriptEvent* message) override;
    virtual int handleEvent(ScriptHandlerMgr::HandlerType type,void* data);
    virtual int handleEvent(ScriptHandlerMgr::HandlerType type, void* data, int numResults, const std::function<void(lua_State*,int)>& func);
    
    // ====== MT3 Custom Lua Bridge Methods ======
    virtual lua_State* getLuaState(void) override;
    
    virtual int pushIntegerToLuaStack(int data) override;
    virtual int pushInt64ToLuaStack(int64_t data) override;
    virtual int pushFloatToLuaStack(float data) override;
    virtual int pushBooleanToLuaStack(int data) override;
    virtual int pushStringToLuaStack(const char* data) override;
    virtual int pushUserDataToLuaStack(void* data) override;
    
    virtual int executeFunctionByHandler(int nHandler, int numArgs = 0) override;
    virtual int executeFunctionWithIntegerData(int nHandler, int data) override;
    virtual int executeFunctionWithFloatData(int nHandler, float data) override;
    virtual int executeFunctionWithBooleanData(int nHandler, bool data) override;
    virtual int executeFunctionWithStringData(int nHandler, const char* data) override;
    virtual int executeFunctionWithParamsData(int nHandler, double param0, double param1, double param2 = 0, double param3 = 0) override;
    
    virtual std::string executeGlobalFunctionBackString(const char* functionName, int numArgs = 0) override;
    virtual int executeGlobalFunctionWithIntegerData(const char* functionName, int data) override;
    virtual int executeGlobalFunctionWithDoubleData(const char* functionName, double data) override;
    virtual int executeGlobalFunctionWithBooleanData(const char* functionName, bool data) override;
    virtual int executeGlobalFunctionWithStringData(const char* functionName, const char* data) override;
    virtual int executeGlobalFunctionWithParamsData(const char* functionName, double param0, double param1, double param2 = 0, double param3 = 0) override;
    virtual int executeGlobalFunctionWithParamsData(const char* functionName, double param0, double param1, double param2, double param3, double param4) override;
    virtual int executeGlobalFunctionWithParamsData(const char* functionName, void* param0, double param1, double param2 = 0, double param3 = 0) override;
    virtual int executeGlobalFunctionWithParamsData(const char* functionName, void* param0, void* param1, double param2 = 0, double param3 = 0) override;
    virtual int executeGlobalFunctionWithParamsData(const char* functionName, int param0, int param1, int param2 = 0, int param3 = 0) override;
    virtual int executeGlobalFunctionWithParamsData(const char* functionName, const char* param0, const char* param1, const char* param2, const char* param3) override;
    virtual int executeGlobalFunctionWithParamsData(const char* functionName, const char* param0, int param1, int param2, int param3, int param4 = 0) override;
    virtual int executeGlobalFunctionWithData(const char* functionName, void* param0, int param1) override;
    virtual int executeGlobalFunctionWith2Int(const char* functionName, int param0, int param1) override;
    
    virtual bool executeProtocolHandler(int nHandler, const aio::Protocol& e) override;
    virtual void executeLuaProtocolHandler(int nHandler, const aio::LuaProtocol& lp) override;
    virtual void collectMemory() override;
private:
    LuaEngine(void)
    : _stack(nullptr)
    {
    }
    bool init(void);
    int handleNodeEvent(void* data);
    int handleMenuClickedEvent(void* data);
    int handleCallFuncActionEvent(void* data);
    int handleScheduler(void* data);
    int handleKeypadEvent(void* data);
    int handleAccelerometerEvent(void* data);
    int handleCommonEvent(void* data);
    int handleTouchEvent(void* data);
    int handleTouchesEvent(void* data);
    int handlerControlEvent(void* data);
    int handleEvenCustom(void* data);
    int handleAssetsManagerEvent(ScriptHandlerMgr::HandlerType type,void* data);
    int handleTableViewEvent(ScriptHandlerMgr::HandlerType type,void* data);
    int handleTableViewEvent(ScriptHandlerMgr::HandlerType type,void* data, int numResults, const std::function<void(lua_State*,int)>& func);
    int handleStudioEventListener(ScriptHandlerMgr::HandlerType type,void* data);
    int handleArmatureWrapper(ScriptHandlerMgr::HandlerType type,void* data);
    int handleEventAcc(void* data);
    int handleEventKeyboard(ScriptHandlerMgr::HandlerType type,void* data);
    int handleEventTouch(ScriptHandlerMgr::HandlerType type, void* data);
    int handleEventTouches(ScriptHandlerMgr::HandlerType type, void* data);
    int handleEventMouse(ScriptHandlerMgr::HandlerType type, void* data);
    
private:
    static LuaEngine* _defaultEngine;
    LuaStack *_stack;
};

NS_CC_END

#endif // __CC_LUA_ENGINE_H__
