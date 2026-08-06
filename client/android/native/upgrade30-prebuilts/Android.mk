ifndef MT3_UPGRADE30_DEPS_ROOT
$(error MT3_UPGRADE30_DEPS_ROOT must point to the extracted Upgrade30 dependency sources)
endif

MT3_UPGRADE30_BUILD_ROOT := $(call my-dir)

LOCAL_PATH := $(MT3_UPGRADE30_DEPS_ROOT)/freetype-VER-2-5-0
include $(CLEAR_VARS)
LOCAL_MODULE := mt3_freetype_upgrade30
LOCAL_MODULE_FILENAME := freetype
LOCAL_SRC_FILES := \
    src/base/ftsystem.c \
    src/base/ftbase.c \
    src/base/ftstroke.c \
    src/base/ftinit.c \
    src/base/ftglyph.c \
    src/base/ftfstype.c \
    src/base/ftgasp.c \
    src/base/ftdebug.c \
    src/base/ftbitmap.c \
    src/base/ftbbox.c \
    src/base/ftgxval.c \
    src/base/ftlcdfil.c \
    src/base/ftmm.c \
    src/base/ftotval.c \
    src/base/ftpatent.c \
    src/base/ftpfr.c \
    src/base/ftsynth.c \
    src/base/fttype1.c \
    src/base/ftwinfnt.c \
    src/base/ftxf86.c \
    src/cff/cff.c \
    src/bdf/bdf.c \
    src/lzw/ftlzw.c \
    src/gzip/ftgzip.c \
    src/autofit/autofit.c \
    src/smooth/smooth.c \
    src/winfonts/winfnt.c \
    src/type42/type42.c \
    src/cid/type1cid.c \
    src/type1/type1.c \
    src/truetype/truetype.c \
    src/sfnt/sfnt.c \
    src/raster/raster.c \
    src/psnames/psmodule.c \
    src/pshinter/pshinter.c \
    src/psaux/psaux.c \
    src/pfr/pfr.c \
    src/pcf/pcf.c
LOCAL_C_INCLUDES := $(LOCAL_PATH)/include $(LOCAL_PATH)/src
LOCAL_CFLAGS := -DFT2_BUILD_LIBRARY -fPIC
include $(BUILD_STATIC_LIBRARY)

LOCAL_PATH := $(MT3_UPGRADE30_DEPS_ROOT)/jpeg-9
include $(CLEAR_VARS)
LOCAL_MODULE := mt3_jpeg_upgrade30
LOCAL_MODULE_FILENAME := jpeg
LOCAL_SRC_FILES := \
    jaricom.c jcapimin.c jcapistd.c jcarith.c jccoefct.c jccolor.c \
    jcdctmgr.c jchuff.c jcinit.c jcmainct.c jcmarker.c jcmaster.c \
    jcomapi.c jcparam.c jcprepct.c jcsample.c jctrans.c jdapimin.c \
    jdapistd.c jdarith.c jdatadst.c jdatasrc.c jdcoefct.c jdcolor.c \
    jddctmgr.c jdhuff.c jdinput.c jdmainct.c jdmarker.c jdmaster.c \
    jdmerge.c jdpostct.c jdsample.c jdtrans.c jerror.c jfdctflt.c \
    jfdctfst.c jfdctint.c jidctflt.c jidctfst.c jidctint.c jmemmgr.c \
    jmemnobs.c jquant1.c jquant2.c jutils.c
LOCAL_C_INCLUDES := $(LOCAL_PATH) $(MT3_UPGRADE30_BUILD_ROOT)/jpeg-config
LOCAL_CFLAGS := -fPIC
include $(BUILD_STATIC_LIBRARY)

LOCAL_PATH := $(MT3_UPGRADE30_DEPS_ROOT)/libpng-1.6.2
include $(CLEAR_VARS)
LOCAL_MODULE := mt3_png_upgrade30
LOCAL_MODULE_FILENAME := png
LOCAL_SRC_FILES := \
    png.c pngerror.c pngget.c pngmem.c pngpread.c pngread.c pngrio.c \
    pngrtran.c pngrutil.c pngset.c pngtrans.c pngwio.c pngwrite.c \
    pngwtran.c pngwutil.c
LOCAL_C_INCLUDES := $(LOCAL_PATH) $(LOCAL_PATH)/scripts
LOCAL_CFLAGS := -fPIC
include $(BUILD_STATIC_LIBRARY)

LOCAL_PATH := $(MT3_UPGRADE30_DEPS_ROOT)/tiff-4.0.3/libtiff
include $(CLEAR_VARS)
LOCAL_MODULE := mt3_tiff_upgrade30
LOCAL_MODULE_FILENAME := tiff
LOCAL_SRC_FILES := \
    tif_aux.c tif_close.c tif_codec.c tif_color.c tif_compress.c tif_dir.c \
    tif_dirinfo.c tif_dirread.c tif_dirwrite.c tif_dumpmode.c tif_error.c \
    tif_extension.c tif_fax3.c tif_fax3sm.c tif_flush.c tif_getimage.c \
    tif_luv.c tif_lzw.c tif_next.c tif_open.c tif_packbits.c tif_pixarlog.c \
    tif_predict.c tif_print.c tif_read.c tif_strip.c tif_swab.c tif_thunder.c \
    tif_tile.c tif_unix.c tif_version.c tif_warning.c tif_write.c tif_zip.c
LOCAL_C_INCLUDES := \
    $(MT3_UPGRADE30_BUILD_ROOT)/tiff-config \
    $(MT3_UPGRADE30_DEPS_ROOT)/tiff-4.0.3/libtiff \
    $(MT3_UPGRADE30_BUILD_ROOT)/../../../..//cocos2d-x-3.0-oh/external/tiff/include/android
LOCAL_CFLAGS := -fPIC
include $(BUILD_STATIC_LIBRARY)

include $(MT3_UPGRADE30_DEPS_ROOT)/libwebp-0.2.1/Android.mk
