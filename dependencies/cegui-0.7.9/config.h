// config.h - CEGUI 0.7.9-r5 build configuration for MT3
// Adapted from original premake-generated config.h
// Uses TinyXML instead of Expat for XML parsing

#ifndef CEGUI_CONFIG_H
#define CEGUI_CONFIG_H

#define CEGUI_WITH_TINYXML 1
#define CEGUI_HAS_MINIZIP_RESOURCE_PROVIDER 
#define CEGUI_HAS_DEFAULT_LOGGER 
#define CEGUI_HAS_PCRE_REGEX 
#define CEGUI_HAS_FREETYPE 
#define CEGUI_DEFAULT_IMAGE_CODEC SILLYImageCodec
#define CEGUI_TINYXML_NAMESPACE CEGUITinyXML
#define CEGUI_FALAGARD_RENDERER 
#define CEGUI_TINYXML_H "ceguitinyxml/tinyxml.h"
#ifndef CEGUI_DEFAULT_XMLPARSER
#define CEGUI_DEFAULT_XMLPARSER TinyXMLParser
#endif
#define CEGUI_LUA_VER 51
#define CEGUI_CODEC_SILLY 1

#if defined(_DEBUG) || defined(DEBUG)
#   define CEGUI_HAS_BUILD_SUFFIX
#   define CEGUI_BUILD_SUFFIX "_d"
#endif

#endif // CEGUI_CONFIG_H