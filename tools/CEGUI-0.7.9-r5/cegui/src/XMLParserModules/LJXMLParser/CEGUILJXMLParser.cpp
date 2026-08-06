#include "CEGUILJXMLParser.h"

#include "CEGUIDataContainer.h"
#include "CEGUIExceptions.h"
#include "CEGUILogger.h"
#include "CEGUIResourceProvider.h"
#include "CEGUISystem.h"
#include "CEGUIXMLAttributes.h"
#include "CEGUIXMLHandler.h"
#include "LJXML.hpp"
#include "LJXMLStringHelper.hpp"

#include <cstring>
#include <sstream>

namespace CEGUI
{
namespace
{
bool looksLikeUtf16LeWithoutBom(const unsigned char* data, size_t size)
{
    if (!data || size < 8)
        return false;

    const size_t sampleLimit = size < 128 ? size : 128;
    size_t oddCount = 0;
    size_t oddZeroCount = 0;
    for (size_t i = 1; i < sampleLimit; i += 2)
    {
        ++oddCount;
        if (data[i] == 0)
            ++oddZeroCount;
    }

    const bool xmlLeadingByte = data[0] == '<' || data[0] == ' ' ||
        data[0] == '\t' || data[0] == '\r' || data[0] == '\n';
    return oddCount >= 4 && oddZeroCount * 100 / oddCount >= 80 &&
        xmlLeadingByte;
}

std::wstring decodeUtf16LeWithoutBom(const unsigned char* data, size_t size)
{
    std::wstring text;
    text.resize(size / 2);
    for (size_t i = 0; i < text.size(); ++i)
    {
        const size_t offset = i * 2;
        text[i] = static_cast<wchar_t>(data[offset] |
            (static_cast<unsigned short>(data[offset + 1]) << 8));
    }

    const size_t terminator = text.find(L'\0');
    if (terminator != std::wstring::npos)
        text.resize(terminator);
    return text;
}

String sizeToString(size_t value)
{
    std::ostringstream stream;
    stream << value;
    return String(stream.str());
}

void processElement(XMLHandler& handler, LJXML::LJXML_Node<LJXML::Char>* node)
{
    XMLAttributes attributes;
    LJXML::LJXML_AttrList sourceAttributes;
    node->GetSubAttrList(sourceAttributes);
    for (size_t i = 0; i < sourceAttributes.size(); ++i)
    {
        attributes.add(String(sourceAttributes[i]->name()),
                       String(sourceAttributes[i]->value()));
    }

    const String nodeName(node->name());
    handler.elementStart(nodeName, attributes);

    LJXML::LJXML_NodeList children;
    node->GetSubNodeList(children);
    for (size_t i = 0; i < children.size(); ++i)
        processElement(handler, children[i]);

    handler.elementEnd(nodeName);
}

void processDocument(XMLHandler& handler, LJXML::LJXML_Doc<LJXML::Char>& document)
{
    LJXML::LJXML_Node<LJXML::Char>* node =
        static_cast<LJXML::LJXML_Node<LJXML::Char>*>(document.first_node());
    while (node && node->type() != rapidxml::node_element)
    {
        node = static_cast<LJXML::LJXML_Node<LJXML::Char>*>(
            node->next_sibling());
    }

    if (!node)
        CEGUI_THROW(FileIOException("LJXMLParser: parsed XML has no root node."));

    processElement(handler, node);
}

std::wstring guiStringToWide(const String& text)
{
    std::wstring result(text.length(), L'\0');
    for (String::size_type i = 0; i < text.length(); ++i)
        result[i] = static_cast<wchar_t>(text[i]);
    return result;
}
}

LJXMLParser::LJXMLParser()
{
    d_identifierString = "CEGUI::LJXMLParser - MT3 RapidXML wide parser";
}

LJXMLParser::~LJXMLParser()
{
}

void LJXMLParser::parseXMLFile(XMLHandler& handler, const String& filename,
                               const String&, const String& resourceGroup)
{
    RawDataContainer rawData;
    ResourceProvider* provider =
        System::getSingleton().getResourceProvider();
    provider->loadRawDataContainer(filename, rawData, resourceGroup);

    try
    {
        parseXMLBuffer(handler, rawData.getDataPtr(), rawData.getSize(), filename);
    }
    catch (...)
    {
        provider->unloadRawDataContainer(rawData);
        CEGUI_LOGERR("LJXMLParser: failed to parse XML file '" + filename +
                     "' in group '" + resourceGroup + "'.");
        CEGUI_RETHROW;
    }

    provider->unloadRawDataContainer(rawData);
}

void LJXMLParser::parseXMLContent(XMLHandler& handler, const String& content)
{
    LJXML::LJXML_Doc<LJXML::Char> document;
    try
    {
        document.LoadFromString(guiStringToWide(content));
        processDocument(handler, document);
    }
    catch (...)
    {
        CEGUI_LOGERR("LJXMLParser: failed to parse in-memory XML content.");
        CEGUI_RETHROW;
    }
}

void LJXMLParser::parseXMLBuffer(XMLHandler& handler,
                                 const unsigned char* data, size_t size,
                                 const String& sourceName)
{
    if (!data || size == 0)
        CEGUI_THROW(FileIOException("LJXMLParser: XML data is empty for '" +
                                    sourceName + "'."));

    std::wstring text;
    if (looksLikeUtf16LeWithoutBom(data, size))
    {
        text = decodeUtf16LeWithoutBom(data, size);
    }
    else
    {
        LJXMLStringHelper::EncodeLJ encoding;
        if (!LJXMLStringHelper::reallyLoadFromMemory(
                const_cast<unsigned char*>(data), size, text, encoding))
        {
            CEGUI_THROW(FileIOException("LJXMLParser: failed to decode XML bytes for '" +
                                        sourceName + "'."));
        }
    }

    while (!text.empty() && text[text.size() - 1] == L'\0')
        text.resize(text.size() - 1);
    if (text.empty())
        CEGUI_THROW(FileIOException("LJXMLParser: decoded XML is empty for '" +
                                    sourceName + "' (bytes=" +
                                    sizeToString(size) + ")."));

    LJXML::LJXML_Doc<LJXML::Char> document;
    document.LoadFromString(text);
    processDocument(handler, document);
}

bool LJXMLParser::initialiseImpl()
{
    return true;
}

void LJXMLParser::cleanupImpl()
{
}
}
