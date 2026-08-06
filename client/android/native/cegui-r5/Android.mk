LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := cegui_static
LOCAL_MODULE_FILENAME := libcegui

CEGUI_ROOT := ../../../../tools/CEGUI-0.7.9-r5/cegui
CEGUI_SRC := $(CEGUI_ROOT)/src

define cegui_cpp_files
$(patsubst $(LOCAL_PATH)/%,%,$(wildcard $(LOCAL_PATH)/$(1)/*.cpp))
endef

LOCAL_SRC_FILES := \
    $(call cegui_cpp_files,$(CEGUI_SRC)) \
    $(call cegui_cpp_files,$(CEGUI_SRC)/elements) \
    $(call cegui_cpp_files,$(CEGUI_SRC)/gesture) \
    $(call cegui_cpp_files,$(CEGUI_SRC)/falagard) \
    $(call cegui_cpp_files,$(CEGUI_SRC)/WindowRendererSets/Falagard) \
    $(call cegui_cpp_files,$(CEGUI_SRC)/ScriptingModules/LuaScriptModule) \
    $(call cegui_cpp_files,$(CEGUI_SRC)/ImageCodecModules/SILLYImageCodec) \
    $(call cegui_cpp_files,$(CEGUI_SRC)/XMLParserModules/LJXMLParser) \
    $(call cegui_cpp_files,$(CEGUI_SRC)/RendererModules/Cocos2D) \
    $(CEGUI_SRC)/minizip/ioapi.cpp \
    $(CEGUI_SRC)/minizip/unzip.cpp \
    ../../../../dependencies/pcre-8.31/pcre_compile.c \
    ../../../../dependencies/pcre-8.31/pcre_config.c \
    ../../../../dependencies/pcre-8.31/pcre_dfa_exec.c \
    ../../../../dependencies/pcre-8.31/pcre_exec.c \
    ../../../../dependencies/pcre-8.31/pcre_fullinfo.c \
    ../../../../dependencies/pcre-8.31/pcre_get.c \
    ../../../../dependencies/pcre-8.31/pcre_globals.c \
    ../../../../dependencies/pcre-8.31/pcre_newline.c \
    ../../../../dependencies/pcre-8.31/pcre_ord2utf8.c \
    ../../../../dependencies/pcre-8.31/pcre_refcount.c \
    ../../../../dependencies/pcre-8.31/pcre_study.c \
    ../../../../dependencies/pcre-8.31/pcre_tables.c \
    ../../../../dependencies/pcre-8.31/pcre_ucd.c \
    ../../../../dependencies/pcre-8.31/pcre_valid_utf8.c \
    ../../../../dependencies/pcre-8.31/pcre_version.c \
    ../../../../dependencies/pcre-8.31/pcre_xclass.c \
    ../../../../dependencies/pcre-8.31/pcreposix.c \
    ../../../../dependencies/pcre-8.31/prj2/pcre_chartables.c \
    $(call cegui_cpp_files,../../../../dependencies/SILLY-0.1.0/src) \
    $(call cegui_cpp_files,../../../../dependencies/SILLY-0.1.0/src/loaders)

LOCAL_C_INCLUDES := \
    $(LOCAL_PATH)/$(CEGUI_ROOT)/include \
    $(LOCAL_PATH)/$(CEGUI_ROOT)/include/elements \
    $(LOCAL_PATH)/$(CEGUI_ROOT)/include/WindowRendererSets/Falagard \
    $(LOCAL_PATH)/$(CEGUI_ROOT)/include/RendererModules/Cocos2D \
    $(LOCAL_PATH)/$(CEGUI_ROOT)/include/ScriptingModules/LuaScriptModule \
    $(LOCAL_PATH)/$(CEGUI_ROOT)/include/ImageCodecModules/SILLYImageCodec \
    $(LOCAL_PATH)/$(CEGUI_ROOT)/include/XMLParserModules/LJXMLParser \
    $(LOCAL_PATH)/$(CEGUI_ROOT)/include/BinLayout \
    $(LOCAL_PATH)/../../../../dependencies/pcre-8.31 \
    $(LOCAL_PATH)/../../../../dependencies/pcre-8.31/prj2 \
    $(LOCAL_PATH)/../../../../dependencies/SILLY-0.1.0/include \
    $(LOCAL_PATH)/../../../../dependencies/SILLY-0.1.0/include/loaders \
    $(LOCAL_PATH)/../../../../dependencies/LJXML/Include \
    $(LOCAL_PATH)/../../../../cocos2d-x-3.0-oh/cocos \
    $(LOCAL_PATH)/../../../../cocos2d-x-3.0-oh/cocos/2d \
    $(LOCAL_PATH)/../../../../cocos2d-x-3.0-oh/cocos/2d/platform/android \
    $(LOCAL_PATH)/../../../../cocos2d-x-3.0-oh/cocos/base \
    $(LOCAL_PATH)/../../../../cocos2d-x-3.0-oh/cocos/math/kazmath \
    $(LOCAL_PATH)/../../../../cocos2d-x-3.0-oh/external \
    $(LOCAL_PATH)/../../../../cocos2d-x-3.0-oh/external/lua/lua \
    $(LOCAL_PATH)/../../../../cocos2d-x-3.0-oh/external/lua/tolua \
    $(LOCAL_PATH)/../../../../common \
    $(LOCAL_PATH)/../../../../common/platform \
    $(LOCAL_PATH)/../../../../common/ljfm/code/include

LOCAL_LDLIBS := -llog
LOCAL_CFLAGS := -DPUBLISHED_VERSION -DUSE_FILE32API -D_OS_ANDROID -DHAVE_CONFIG_H -DCEGUI_STATIC -DANDROID -DCC_SUPPORT_PVRTC
LOCAL_CPPFLAGS := -fexceptions -frtti -fpermissive

LOCAL_STATIC_LIBRARIES := cocos2dx_static cocos_freetype2_static cocos_png_static cocos_jpeg_static

include $(BUILD_STATIC_LIBRARY)

$(call import-module,freetype2/prebuilt/android)
$(call import-module,png/prebuilt/android)
$(call import-module,jpeg/prebuilt/android)
