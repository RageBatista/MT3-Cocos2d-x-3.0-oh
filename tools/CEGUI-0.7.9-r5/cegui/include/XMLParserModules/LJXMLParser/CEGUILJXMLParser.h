#ifndef _CEGUILJXMLPARSER_H_
#define _CEGUILJXMLPARSER_H_

#include "CEGUIXMLParser.h"
#include <cstddef>

namespace CEGUI
{
class LJXMLParser : public XMLParser
{
public:
    LJXMLParser();
    ~LJXMLParser();

    void parseXMLFile(XMLHandler& handler, const String& filename,
                      const String& schemaName, const String& resourceGroup);
    void parseXMLContent(XMLHandler& handler, const String& content);

protected:
    bool initialiseImpl();
    void cleanupImpl();

private:
    void parseXMLBuffer(XMLHandler& handler, const unsigned char* data,
                        size_t size, const String& sourceName);
};
}

#endif
