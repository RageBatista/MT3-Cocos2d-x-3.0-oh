APP_STL := c++_shared
APP_CPPFLAGS := -frtti -std=c++11
APP_CPPFLAGS += -D__STDC_LIMIT_MACROS -D__STDC_FORMAT_MACROS -D__STDC_CONSTANT_MACROS
APP_ABI := arm64-v8a
APP_PLATFORM := android-21
APP_CFLAGS += -g -fPIC -ffunction-sections -fdata-sections
APP_CPPFLAGS += -fPIC -ffunction-sections -fdata-sections
APP_LDFLAGS += -Wl,--gc-sections -Wl,--no-undefined
APP_LDFLAGS += -Wl,-z,relro -Wl,-z,now

ifeq ($(NDK_DEBUG),1)
  APP_CPPFLAGS += -DCOCOS2D_DEBUG=1 -DXPP_IOS -DNDEBUG -DPUBLISHED_VERSION -DLOGCAT
  APP_OPTIM := debug
else
  APP_CPPFLAGS += -DCOCOS2D_DEBUG=0 -DXPP_IOS -DNDEBUG -DPUBLISHED_VERSION
  APP_OPTIM := release
endif

NDK_TOOLCHAIN_VERSION := clang
