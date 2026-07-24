#include "CEGUILJXMLParser.h"
#include "CEGUILJXMLParserHelper.h"
#include "CEGUIResourceProvider.h"
#include "CEGUISystem.h"
#include "CEGUIXMLHandler.h"
#include "CEGUIXMLAttributes.h"
#include "CEGUILogger.h"
#include "CEGUIExceptions.h"
#include "CEGUIPfsResourceProvider.h"
#include "nuclear.h"
#include "../../../../common/ljfm/code/include/common.h"
#include "../../../../common/ljfm/code/include/ljfmbase.h"
#include "../../../../dependencies/LJXML/Include/LJXML.hpp"
#include <sstream>
#include <iomanip>

namespace CEGUI
{
    enum
    {
        EC_SUCCESS = 0,
        EC_CREATE_XML_DOCUMENT = -3000,
        EC_PARSE_XML_CONTEXT,
        EC_FILE_SIZE_LACK,
        EC_GET_ROOT_ELEMENT,
        EC_XML_ENCODE,
        EC_XML_DECODE,
        EC_BAD_OCTETS_XML_DATA,
        EC_X2O_TRANSLATE_FAILED,
        EC_O2X_TRANSLATE_FAILED,
        EC_NOT_SUPPORT_WRITER,
    };

    namespace
    {
        bool looksLikeUtf16LeWithoutBom(const unsigned char* data, std::streamsize size)
        {
            if (data == NULL || size < 8)
            {
                return false;
            }

            const std::streamsize sampleLimit = (size < 128) ? size : 128;
            int oddCount = 0;
            int oddZeroCount = 0;
            for (std::streamsize i = 1; i < sampleLimit; i += 2)
            {
                ++oddCount;
                if (data[i] == 0)
                {
                    ++oddZeroCount;
                }
            }

            if (oddCount < 4)
            {
                return false;
            }

            const bool highZeroRatio = (oddZeroCount * 100 / oddCount) >= 80;
            const bool xmlLeadingByte =
                (data[0] == '<') || (data[0] == ' ') || (data[0] == '\t') ||
                (data[0] == '\r') || (data[0] == '\n');
            return highZeroRatio && xmlLeadingByte;
        }

        std::wstring decodeUtf16LeWithoutBom(const unsigned char* data, std::streamsize size)
        {
            std::wstring out;
            if (data == NULL || size <= 0)
            {
                return out;
            }

            const size_t charCount = static_cast<size_t>(size / 2);
            out.resize(charCount);
            const unsigned char* p = data;
            for (size_t i = 0; i < charCount; ++i, p += 2)
            {
                out[i] = static_cast<wchar_t>(p[0] | (static_cast<unsigned short>(p[1]) << 8));
            }

            size_t firstZero = out.find(L'\0');
            if (firstZero != std::wstring::npos)
            {
                out.resize(firstZero);
            }
            return out;
        }

        String dumpPrefixHex(const unsigned char* data, std::streamsize size, size_t maxBytes = 24)
        {
            std::ostringstream oss;
            oss << "hex[";
            if (data != NULL && size > 0)
            {
                const size_t count = (static_cast<size_t>(size) < maxBytes) ? static_cast<size_t>(size) : maxBytes;
                for (size_t i = 0; i < count; ++i)
                {
                    if (i > 0)
                    {
                        oss << ' ';
                    }
                    oss << std::hex << std::uppercase << std::setw(2)
                        << std::setfill('0') << static_cast<int>(data[i]);
                }
                if (static_cast<size_t>(size) > count)
                {
                    oss << " ...";
                }
            }
            oss << ']';
            return String(oss.str().c_str());
        }

        String toString(std::streamsize value)
        {
            std::ostringstream oss;
            oss << value;
            return String(oss.str().c_str());
        }
    }

    void ProcessNode(XMLHandler& handler, LJXML::LJXML_Node<LJXML::Char>* XMLNode, LJXMLStringHelper::EncodeLJ CodeType)
    {
        XMLAttributes attrs;
        LJXML::LJXML_AttrList SubAttrList;
        XMLNode->GetSubAttrList(SubAttrList);
        for (size_t i = 0; i < SubAttrList.size(); i++)
        {
            std::wstring StrAttrName = SubAttrList[i]->name();
            std::wstring StrAttrValue = SubAttrList[i]->value();
            String AttrName(StrAttrName);
            String AttrValue(StrAttrValue);
            attrs.add(AttrName, AttrValue);
        }

        std::wstring strNodeName = XMLNode->name();
        String NodeName = strNodeName;
        (&handler)->elementStart(NodeName, attrs);

        LJXML::LJXML_NodeList SubNodeList;
        XMLNode->GetSubNodeList(SubNodeList);
        for (size_t i = 0; i < SubNodeList.size(); i++)
        {
            ProcessNode(handler, SubNodeList[i], CodeType);
        }

        (&handler)->elementEnd(NodeName);
    }

    void ProcessDoc(XMLHandler& handler, LJXML::LJXML_Doc<LJXML::Char>* XMLDoc, LJXMLStringHelper::EncodeLJ CodeType)
    {
        LJXML::LJXML_Node<LJXML::Char>* FirstNode =
            (LJXML::LJXML_Node<LJXML::Char>*)XMLDoc->first_node();

        while (FirstNode != NULL && FirstNode->type() != rapidxml::node_element)
        {
            FirstNode = (LJXML::LJXML_Node<LJXML::Char>*)FirstNode->next_sibling();
        }

        if (FirstNode == NULL)
        {
            return;
        }

        ProcessNode(handler, FirstNode, CodeType);
    }

    int OpenFromFile(std::wstring fileName, char*& fileBuf, std::streamsize& ss)
    {
        int nError = 0;

        LJFMX::CSyncFile pfsFile;
        if (pfsFile.Open(fileName))
        {
            unsigned int prefix = 0;
            std::size_t readsize = sizeof(unsigned int);
            readsize = pfsFile.Read(&prefix, readsize);
            if (readsize == LJFM::FILE_SIZE_ERROR)
            {
                return LJFM::LJFMOpen::GetLastError();
            }
            if (sizeof(unsigned int) != readsize)
            {
                return -1;
            }
            pfsFile.Seek(0, LJFM::FSM_SET);

            ss = pfsFile.GetSize() + 2;
            fileBuf = new char[ss + 1];
            if (pfsFile.ReadAll(fileBuf, ss))
            {
                fileBuf[ss - 2] = 0;
                fileBuf[ss - 1] = 0;
                fileBuf[ss] = 0;
                return 0;
            }

            delete[] fileBuf;
            return 1;
        }
        else
        {
            nError = LJFM::LJFMOpen::GetLastError();
        }
        return nError;
    }

    LJXMLParser::LJXMLParser(void)
    {
        d_identifierString = "CEGUI::LJXMLParser - RapidXml based parser module for CEGUI";
    }

    LJXMLParser::~LJXMLParser(void)
    {
    }

    void LJXMLParser::parseXMLFile(XMLHandler& handler, const String& filename,
        const String& schemaName, const String& resourceGroup)
    {
        char* fileBuf = NULL;

        try
        {
            CEGUI::PFSResourceProvider* rp = static_cast<CEGUI::PFSResourceProvider*>(
                System::getSingleton().getResourceProvider());
            std::wstring pfsfilename = rp->GetPFSFileName(filename, resourceGroup);
            std::streamsize ss = 0;
            if (OpenFromFile(pfsfilename, fileBuf, ss) != EC_SUCCESS)
            {
                CEGUI_LOGERR("LJXMLParser: an error occurred while opening XML document '" + filename + "'.");
                throw FileIOException("LJXMLParser: an error occurred while opening XML document '" + filename + "'.");
            }

            parseXMLFileBuf(handler, fileBuf, ss);
        }
        catch (const Exception& e)
        {
            CEGUI_LOGERR("LJXMLParser: failed to parse XML file '" + filename +
                "' in group '" + resourceGroup + "'. Details: " + e.getMessage());
            throw;
        }
        catch (...)
        {
            CEGUI_LOGERR("LJXMLParser: failed to parse XML file '" + filename +
                "' in group '" + resourceGroup + "'. Unknown exception.");
            throw;
        }

        if (fileBuf)
        {
            delete[] fileBuf;
            fileBuf = NULL;
        }
    }

    void LJXMLParser::parseXMLFileBuf(XMLHandler& handler, char* fileBuf, std::streamsize ss)
    {
        try
        {
            std::wstring wStr;
            LJXMLStringHelper::EncodeLJ codeType;
            if (!LJXMLStringHelper::reallyLoadFromMemory((unsigned char*)fileBuf, ss, wStr, codeType))
            {
                CEGUI_LOGERR("LJXMLParser: reallyLoadFromMemory failed. " +
                    dumpPrefixHex((unsigned char*)fileBuf, ss));
                throw FileIOException("LJXMLParser: failed to decode XML bytes.");
            }

            if (wStr.empty() && looksLikeUtf16LeWithoutBom((unsigned char*)fileBuf, ss))
            {
                wStr = decodeUtf16LeWithoutBom((unsigned char*)fileBuf, ss);
                codeType = LJXMLStringHelper::LJ_UTF_16;
            }

            if (wStr.empty())
            {
                CEGUI_LOGERR("LJXMLParser: decoded XML text is empty. " +
                    dumpPrefixHex((unsigned char*)fileBuf, ss));
                throw FileIOException("LJXMLParser: decoded XML text is empty.");
            }

            LJXML::LJXML_Doc<LJXML::Char> doc;
            LJXML::Char* charData = doc.LoadFromString(wStr);
            (void)charData;
            if (!doc.first_node())
            {
                CEGUI_LOGERR("LJXMLParser: no XML root node after parsing. decoded chars=" +
                    toString((std::streamsize)wStr.size()) + ", raw bytes=" + toString(ss) + ", " +
                    dumpPrefixHex((unsigned char*)fileBuf, ss));
                throw FileIOException("LJXMLParser: parsed XML has no root node.");
            }

            ProcessDoc(handler, &doc, codeType);
        }
        catch (...)
        {
            throw;
        }
    }

    void LJXMLParser::parseXMLContent(XMLHandler& handler, const String& content)
    {
        LJXML::LJXML_Doc<LJXML::Char> doc;

        try
        {
            LJXML::Char* charData = doc.LoadFromString(
                LJXMLParserHelper::GUIStringToWString(content));
            (void)charData;
        }
        catch (...)
        {
            return;
        }

        try
        {
            ProcessDoc(handler, &doc, LJXMLStringHelper::LJ_ANSI);
        }
        catch (...)
        {
        }
    }

    bool LJXMLParser::initialiseImpl(void)
    {
        return true;
    }

    void LJXMLParser::cleanupImpl(void)
    {
    }
} // End of CEGUI namespace