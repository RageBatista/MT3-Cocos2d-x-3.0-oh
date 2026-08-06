LOCAL_PATH := $(call my-dir)
 
#add baidu location sdk -s
include $(CLEAR_VARS)
LOCAL_MODULE := locSDK6a
LOCAL_SRC_FILES :=../../../3rdplatform/BaiduLBS_AndroidSDK_Lib/libs/$(TARGET_ARCH_ABI)/liblocSDK6a.so
include $(PREBUILT_SHARED_LIBRARY)
#add baidu location sdk -e

#add libdu location sdk -s
include $(CLEAR_VARS)
LOCAL_MODULE := libdu
LOCAL_SRC_FILES :=../../../3rdplatform/duClient_SDK_Lib/libs/$(TARGET_ARCH_ABI)/libdu.so
include $(PREBUILT_SHARED_LIBRARY)
#add libdu location sdk -e

include $(CLEAR_VARS)

LOCAL_MODULE := game_shared

LOCAL_MODULE_FILENAME := libgame

GAME_ROOT := $(LOCAL_PATH)/../../../..

$(call import-add-path,${GAME_ROOT}/)
$(call import-add-path,${GAME_ROOT}/client/)
$(call import-add-path,${GAME_ROOT}/common/)
$(call import-add-path,${GAME_ROOT}/cocos2d-x-3.0-oh/)
$(call import-add-path,${GAME_ROOT}/cocos2d-x-3.0-oh/cocos/)
$(call import-add-path,${GAME_ROOT}/cocos2d-x-3.0-oh/external/)
$(call import-add-path,${GAME_ROOT}/dependencies/)

LOCAL_SRC_FILES := \
	main.cpp \
	luajit_stdio_compat.c


ifneq ($(TARGET_ARCH_ABI),arm64-v8a)
LOCAL_C_INCLUDES := \
	$(LOCAL_PATH)/../../../../dependencies/google-breakpad/src \
	$(LOCAL_PATH)/../../../../dependencies/google-breakpad/src/common/android/include
endif

LOCAL_CFLAGS += -DCC_ARM64=1 -fPIC
LOCAL_CPPFLAGS += -fexceptions -frtti -fpermissive
LOCAL_LDFLAGS += -Wl,--no-undefined -Wl,--gc-sections

LOCAL_WHOLE_STATIC_LIBRARIES := cocos2dx_static
LOCAL_WHOLE_STATIC_LIBRARIES += cocosdenshion_static
ifneq ($(TARGET_ARCH_ABI),arm64-v8a)
LOCAL_WHOLE_STATIC_LIBRARIES += breakpad_client
endif
LOCAL_WHOLE_STATIC_LIBRARIES += cegui_static
LOCAL_WHOLE_STATIC_LIBRARIES += platform_static
LOCAL_WHOLE_STATIC_LIBRARIES += ljfm_static
LOCAL_WHOLE_STATIC_LIBRARIES += engine_static
LOCAL_WHOLE_STATIC_LIBRARIES += FireClient_static
LOCAL_WHOLE_STATIC_LIBRARIES += cauthc_static
LOCAL_WHOLE_STATIC_LIBRARIES += updateengine_static
LOCAL_WHOLE_STATIC_LIBRARIES += cocos_extension_static
LOCAL_WHOLE_STATIC_LIBRARIES += cocos_network_static
LOCAL_WHOLE_STATIC_LIBRARIES += cocos_lua_static

#add baidu location SDK -s
LOCAL_SHARED_LIBRARIES += locSDK6a
#add baidu location SDK -e

#add libdu location SDK -s
LOCAL_SHARED_LIBRARIES += du
#add libdu location SDK -e

include $(BUILD_SHARED_LIBRARY)

$(call import-module,audio/android)
ifneq ($(TARGET_ARCH_ABI),arm64-v8a)
$(call import-module,google-breakpad/android/google_breakpad)
endif
$(call import-module,2d)
$(call import-module,android/native/cegui-r5)
$(call import-module,cauthc/projects/android)
$(call import-module,platform)
$(call import-module,ljfm)
$(call import-module,updateengine)
$(call import-module,engine)
$(call import-module,FireClient)
$(call import-module,extensions)
$(call import-module,network)
$(call import-module,scripting/lua-bindings)
$(call import-module,png/prebuilt/android)
$(call import-module,jpeg/prebuilt/android)

