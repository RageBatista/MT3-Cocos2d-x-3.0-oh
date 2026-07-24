#----------------------------------------------------------------
# Generated CMake target import file for configuration "RelWithDebInfo".
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "png14_static" for configuration "RelWithDebInfo"
set_property(TARGET png14_static APPEND PROPERTY IMPORTED_CONFIGURATIONS RELWITHDEBINFO)
set_target_properties(png14_static PROPERTIES
  IMPORTED_LINK_INTERFACE_LANGUAGES_RELWITHDEBINFO "C"
  IMPORTED_LINK_INTERFACE_LIBRARIES_RELWITHDEBINFO "E:/MT3/cocos2d-2.0-rc2-x-2.0.1/cocos2dx/platform/third_party/win32/libraries/zlib1.lib"
  IMPORTED_LOCATION_RELWITHDEBINFO "C:/Program Files (x86)/libpng/lib/libpng14_static.lib"
  )

list(APPEND _IMPORT_CHECK_TARGETS png14_static )
list(APPEND _IMPORT_CHECK_FILES_FOR_png14_static "C:/Program Files (x86)/libpng/lib/libpng14_static.lib" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
