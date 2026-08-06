LOCAL_PATH := $(call my-dir)
CURL_ROOT := ../../../../dependencies/third-party-rebuild/curl-7.48.0

include $(LOCAL_PATH)/$(CURL_ROOT)/lib/Makefile.inc
include $(CLEAR_VARS)

LOCAL_MODULE := cocos_curl_static
LOCAL_MODULE_FILENAME := curl

LOCAL_SRC_FILES := $(addprefix $(CURL_ROOT)/lib/,$(CSOURCES))

LOCAL_C_INCLUDES := \
    $(LOCAL_PATH) \
    $(LOCAL_PATH)/$(CURL_ROOT)/include \
    $(LOCAL_PATH)/$(CURL_ROOT)/lib

LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)/$(CURL_ROOT)/include

LOCAL_CFLAGS := \
    -DHAVE_CONFIG_H \
    -DBUILDING_LIBCURL \
    -DCURL_STATICLIB \
    -Wno-unused-parameter \
    -Wno-sign-compare

LOCAL_LDLIBS := -llog -lz

include $(BUILD_STATIC_LIBRARY)
