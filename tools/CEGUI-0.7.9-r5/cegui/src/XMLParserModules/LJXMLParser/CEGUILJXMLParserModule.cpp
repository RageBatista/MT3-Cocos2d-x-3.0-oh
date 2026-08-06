#include "CEGUILJXMLParserModule.h"

CEGUI::XMLParser* createParser()
{
    return new CEGUI::LJXMLParser();
}

void destroyParser(CEGUI::XMLParser* parser)
{
    delete parser;
}
