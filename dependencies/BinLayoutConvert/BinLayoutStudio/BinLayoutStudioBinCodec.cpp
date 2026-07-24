#include "BinLayoutStudioBinCodec.h"

#include "BinLayoutStudioXmlWriter.h"

#include <cstdio>
#include <cstring>
#include <sstream>
#include <vector>

#include "BinLayout/CEGUIBinLayoutFileDefine.h"
#include "BinLayout/CEGUIBinLayoutFileSerializer.h"
#include "BinLayout/CEGUIFileStream.h"
#include "BinLayout/CEGUIPropertyIds.h"
#include "BinLayout/CEGUIXMLToBin.h"
#include "BinLayout/v1/CEGUIRegSerializers_v1.h"
#include "CEGUIExceptions.h"
#include "CEGUIPropertyHelper.h"
#include "XMLParserModules/LJXMLParser/CEGUILJXMLParser.h"

#include "CEGUIWindow.h"
#include "falagard/CEGUIFalEnums.h"

#include "elements/CEGUIItemCell.h"
#include "elements/CEGUIItemListBase.h"
#include "elements/CEGUIListHeaderSegment.h"
#include "elements/CEGUIMultiColumnList.h"
#include "elements/CEGUIPushButton.h"
#include "elements/CEGUISpinner.h"
#include "elements/CEGUITabControl.h"

namespace BinLayoutStudio
{
	namespace Core
	{
		namespace
		{
			//////////////////////////////////////////////////////////////////////////
			// Safe stream reading: detect stream errors and EOF
			//////////////////////////////////////////////////////////////////////////
			template<typename T>
			static bool safeRead(CEGUI::BinLayout::Stream& stream, T& value, std::string& outError)
			{
				if (stream.isEOF())
				{
					outError = "Stream read error: unexpected end of file";
					return false;
				}
				// Use operator >> which handles both POD types (via readT) and
				// complex types (String, ColourRect, etc.) with specialized overloads
				stream >> value;
				// Check for EOF after read (indicates incomplete read)
				if (stream.isEOF())
				{
					outError = "Stream read error: incomplete data read";
					return false;
				}
				return true;
			}

			// Specialized version: read fixed-size char array (e.g. magic)
			static bool safeReadMagic(CEGUI::BinLayout::Stream& stream, char* magic, size_t size, std::string& outError)
			{
				if (stream.isEOF())
				{
					outError = "Stream read error: unexpected end of file";
					return false;
				}
				if (!stream.read(magic, static_cast<int>(size)))
				{
					outError = "Stream read error: failed to read file magic";
					return false;
				}
				return true;
			}

			// Helper macros: simplify error checking (used within functions)
#define SAFE_READ(stream, value) do { if (!safeRead(stream, value, outError)) { return false; } } while (0)

#define SAFE_READ_CLEANUP(stream, value, cleanup) do { if (!safeRead(stream, value, outError)) { cleanup; return false; } } while (0)

			enum class PayloadKind
			{
				Unknown = 0,
				Bool,
				Int,
				UInt,
				Float,
				Int64,
				String,
				Size,
				Point,
				Vector3,
				Rect,
				Colour,
				ColourRect,
				UDim,
				UVector2,
				URect,
				Range2Float,
				SortMode,
				SortDirection,
				SelectionMode,
				SizeType,
				TextInputMode,
				TabPanePosition,
				HorzFormatting,
				VertFormatting,
				VerticalAlignment,
				HorizontalAlignment,
				CreateEffectType,
				CloseEffectType,
				ItemCellStyle,
				PropertyDefinition,
			};

			struct PropertyTypeEntry
			{
				int propId;
				PayloadKind kind;
			};

			static const PropertyTypeEntry kPropertyTypeEntries[] =
			{
				// This list is derived from g_RegSerializers_v1() + v1 PropertySerializer impls.
				// It intentionally excludes PI_LuaForDialog / PI_LuaUsed (no payload in non-editor builds).
#include "BinLayoutStudioPropTypes_v1.inc"
			};

			static PayloadKind g_kindByPropId[CEGUI::BinLayout::PI_COUNT];
			static bool g_kindByPropIdInited = false;

			static void initKindByPropId()
			{
				if (g_kindByPropIdInited)
				{
					return;
				}

				for (int i = 0; i < CEGUI::BinLayout::PI_COUNT; ++i)
				{
					g_kindByPropId[i] = PayloadKind::Unknown;
				}

				const int count = static_cast<int>(sizeof(kPropertyTypeEntries) / sizeof(kPropertyTypeEntries[0]));
				for (int i = 0; i < count; ++i)
				{
					const PropertyTypeEntry& e = kPropertyTypeEntries[i];
					if (0 <= e.propId && e.propId < CEGUI::BinLayout::PI_COUNT)
					{
						g_kindByPropId[e.propId] = e.kind;
					}
				}

				g_kindByPropIdInited = true;
			}

			static CEGUI::String toStringSortMode(CEGUI::ItemListBase::SortMode v)
			{
				if (v == CEGUI::ItemListBase::Descending)
					return "Descending";
				if (v == CEGUI::ItemListBase::UserSort)
					return "UserSort";
				return "Ascending";
			}

			static CEGUI::String toStringSortDirection(CEGUI::ListHeaderSegment::SortDirection v)
			{
				if (v == CEGUI::ListHeaderSegment::Ascending)
					return "Ascending";
				if (v == CEGUI::ListHeaderSegment::Descending)
					return "Descending";
				return "None";
			}

			static CEGUI::String toStringSelectionMode(CEGUI::MultiColumnList::SelectionMode v)
			{
				using CEGUI::MultiColumnList;

				switch (v)
				{
				case MultiColumnList::RowMultiple: return "RowMultiple";
				case MultiColumnList::ColumnSingle: return "ColumnSingle";
				case MultiColumnList::ColumnMultiple: return "ColumnMultiple";
				case MultiColumnList::CellSingle: return "CellSingle";
				case MultiColumnList::CellMultiple: return "CellMultiple";
				case MultiColumnList::NominatedColumnSingle: return "NominatedColumnSingle";
				case MultiColumnList::NominatedColumnMultiple: return "NominatedColumnMultiple";
				case MultiColumnList::NominatedRowSingle: return "NominatedRowSingle";
				case MultiColumnList::NominatedRowMultiple: return "NominatedRowMultiple";
				default: return "RowSingle";
				}
			}

			static CEGUI::String toStringSizeType(CEGUI::PushButtonSizeType v)
			{
				switch (v)
				{
				case CEGUI::ePushButtonSizeType_Small: return "Small";
				case CEGUI::ePushButtonSizeType_Normal: return "Normal";
				case CEGUI::ePushButtonSizeType_Big: return "Big";
				case CEGUI::ePushButtonSizeType_Image: return "Image";
				default: return "Auto";
				}
			}

			static CEGUI::String toStringTextInputMode(CEGUI::Spinner::TextInputMode v)
			{
				using CEGUI::Spinner;
				switch (v)
				{
				case Spinner::FloatingPoint: return "FloatingPoint";
				case Spinner::Hexadecimal: return "Hexadecimal";
				case Spinner::Octal: return "Octal";
				default: return "Integer";
				}
			}

			static CEGUI::String toStringTabPanePosition(CEGUI::TabControl::TabPanePosition v)
			{
				using CEGUI::TabControl;
				switch (v)
				{
				case TabControl::Bottom: return "Bottom";
				case TabControl::Left: return "Left";
				default: return "Top";
				}
			}

			static CEGUI::String toStringHorzFormatting(CEGUI::HorizontalTextFormatting v)
			{
				using namespace CEGUI;

				switch (v)
				{
				case HTF_RIGHT_ALIGNED: return "RightAligned";
				case HTF_CENTRE_ALIGNED: return "HorzCentred";
				case HTF_JUSTIFIED: return "HorzJustified";
				case HTF_WORDWRAP_LEFT_ALIGNED: return "WordWrapLeftAligned";
				case HTF_WORDWRAP_RIGHT_ALIGNED: return "WordWrapRightAligned";
				case HTF_WORDWRAP_CENTRE_ALIGNED: return "WordWrapCentred";
				case HTF_WORDWRAP_JUSTIFIED: return "WordWrapJustified";
				default: return "LeftAligned";
				}
			}

			static CEGUI::String toStringVertFormatting(CEGUI::VerticalTextFormatting v)
			{
				using namespace CEGUI;

				switch (v)
				{
				case VTF_BOTTOM_ALIGNED: return "BottomAligned";
				case VTF_CENTRE_ALIGNED: return "VertCentred";
				default: return "TopAligned";
				}
			}

			static CEGUI::String toStringVerticalAlignment(CEGUI::VerticalAlignment v)
			{
				switch (v)
				{
				case CEGUI::VA_CENTRE: return "Centre";
				case CEGUI::VA_BOTTOM: return "Bottom";
				default: return "Top";
				}
			}

			static CEGUI::String toStringHorizontalAlignment(CEGUI::HorizontalAlignment v)
			{
				switch (v)
				{
				case CEGUI::HA_CENTRE: return "Centre";
				case CEGUI::HA_RIGHT: return "Right";
				default: return "Left";
				}
			}

			static CEGUI::String toStringCreateEffectType(CEGUI::CreateWindowEffect v)
			{
				switch (v)
				{
				case CEGUI::CreateWndEffect_Drop: return "Drop";
				case CEGUI::CreateWndEffect_FlyFromLeft: return "Left";
				case CEGUI::CreateWndEffect_FlyFromRight: return "Right";
				case CEGUI::CreateWndEffect_ZoomOut: return "ZoomOut";
				default: return "";
				}
			}

			static CEGUI::String toStringCloseEffectType(CEGUI::CloseWndEffect v)
			{
				switch (v)
				{
				case CEGUI::CloseWndEffect_FlyUp: return "Up";
				case CEGUI::CloseWndEffect_FlyDown: return "Down";
				case CEGUI::CloseWndEffect_FlyLeft: return "Left";
				case CEGUI::CloseWndEffect_FlyRight: return "Right";
				case CEGUI::CloseWndEffect_ZoomIn: return "ZoomIn";
				default: return "";
				}
			}

			static CEGUI::String toStringItemCellStyle(CEGUI::ItemCellStyle v)
			{
				switch (v)
				{
				case CEGUI::ItemCellStyle_IconExtend: return "IconExtend";
				default: return "IconInside";
				}
			}

			static bool decodePropertyPayload(
				CEGUI::BinLayout::Stream& stream,
				int propId,
				CEGUI::String& outName,
				CEGUI::String& outValue,
				std::string& outError)
			{
				using namespace CEGUI;
				using namespace CEGUI::BinLayout;

				if (propId < 0 || propId >= PI_COUNT)
				{
					outError = "decodePropertyPayload: invalid propId.";
					return false;
				}

				// Non-editor builds: these properties are stored as (propId) with no payload.
				if (propId == PI_LuaForDialog || propId == PI_LuaUsed)
				{
					outName = PropertyIdUtil::getPropNameById(propId);
					outValue = "True";
					return true;
				}

				initKindByPropId();
				const PayloadKind kind = g_kindByPropId[propId];

				if (kind == PayloadKind::Unknown)
				{
					std::ostringstream oss;
					oss << "decodePropertyPayload: unknown payload kind for propId=" << propId;
					outError = oss.str();
					return false;
				}

				outName = PropertyIdUtil::getPropNameById(propId);

				switch (kind)
				{
				case PayloadKind::Bool:
				{
					bool v = false;
					SAFE_READ(stream, v);
					outValue = PropertyHelper::boolToString(v);
					return true;
				}
				case PayloadKind::Int:
				{
					int v = 0;
					SAFE_READ(stream, v);
					outValue = PropertyHelper::intToString(v);
					return true;
				}
				case PayloadKind::UInt:
				{
					uint v = 0;
					SAFE_READ(stream, v);
					outValue = PropertyHelper::uintToString(v);
					return true;
				}
				case PayloadKind::Float:
				{
					float v = 0.0f;
					SAFE_READ(stream, v);
					outValue = PropertyHelper::floatToString(v);
					return true;
				}
				case PayloadKind::Int64:
				{
					int64_t v = 0;
					SAFE_READ(stream, v);
					outValue = PropertyHelper::int64_tToString(v);
					return true;
				}
				case PayloadKind::String:
				{
					String v;
					SAFE_READ(stream, v);
					outValue = v;
					return true;
				}
				case PayloadKind::Size:
				{
					Size v;
					SAFE_READ(stream, v);
					outValue = PropertyHelper::sizeToString(v);
					return true;
				}
				case PayloadKind::Point:
				{
					Point v;
					SAFE_READ(stream, v);
					outValue = PropertyHelper::pointToString(v);
					return true;
				}
				case PayloadKind::Vector3:
				{
					Vector3 v;
					SAFE_READ(stream, v);
					outValue = PropertyHelper::vector3ToString(v);
					return true;
				}
				case PayloadKind::Rect:
				{
					Rect v;
					SAFE_READ(stream, v);
					outValue = PropertyHelper::rectToString(v);
					return true;
				}
				case PayloadKind::Colour:
				{
					colour v;
					SAFE_READ(stream, v);
					outValue = PropertyHelper::colourToString(v);
					return true;
				}
				case PayloadKind::ColourRect:
				{
					ColourRect v;
					SAFE_READ(stream, v);
					outValue = PropertyHelper::colourRectToString(v);
					return true;
				}
				case PayloadKind::UDim:
				{
					UDim v;
					SAFE_READ(stream, v);
					outValue = PropertyHelper::udimToString(v);
					return true;
				}
				case PayloadKind::UVector2:
				{
					UVector2 v;
					SAFE_READ(stream, v);
					outValue = PropertyHelper::uvector2ToString(v);
					return true;
				}
				case PayloadKind::URect:
				{
					URect v;
					SAFE_READ(stream, v);
					outValue = PropertyHelper::urectToString(v);
					return true;
				}
				case PayloadKind::Range2Float:
				{
					float rangeMin = 0.0f;
					float rangeMax = 0.0f;
					SAFE_READ(stream, rangeMin);
					SAFE_READ(stream, rangeMax);

					char buf[128];
					sprintf_s(buf, "min:%g max:%g", rangeMin, rangeMax);
					outValue = buf;
					return true;
				}
				case PayloadKind::SortMode:
				{
					ItemListBase::SortMode v;
					SAFE_READ(stream, v);
					outValue = toStringSortMode(v);
					return true;
				}
				case PayloadKind::SortDirection:
				{
					ListHeaderSegment::SortDirection v;
					SAFE_READ(stream, v);
					outValue = toStringSortDirection(v);
					return true;
				}
				case PayloadKind::SelectionMode:
				{
					MultiColumnList::SelectionMode v;
					SAFE_READ(stream, v);
					outValue = toStringSelectionMode(v);
					return true;
				}
				case PayloadKind::SizeType:
				{
					PushButtonSizeType v;
					SAFE_READ(stream, v);
					outValue = toStringSizeType(v);
					return true;
				}
				case PayloadKind::TextInputMode:
				{
					Spinner::TextInputMode v;
					SAFE_READ(stream, v);
					outValue = toStringTextInputMode(v);
					return true;
				}
				case PayloadKind::TabPanePosition:
				{
					TabControl::TabPanePosition v;
					SAFE_READ(stream, v);
					outValue = toStringTabPanePosition(v);
					return true;
				}
				case PayloadKind::HorzFormatting:
				{
					HorizontalTextFormatting v;
					SAFE_READ(stream, v);
					outValue = toStringHorzFormatting(v);
					return true;
				}
				case PayloadKind::VertFormatting:
				{
					VerticalTextFormatting v;
					SAFE_READ(stream, v);
					outValue = toStringVertFormatting(v);
					return true;
				}
				case PayloadKind::VerticalAlignment:
				{
					VerticalAlignment v;
					SAFE_READ(stream, v);
					outValue = toStringVerticalAlignment(v);
					return true;
				}
				case PayloadKind::HorizontalAlignment:
				{
					HorizontalAlignment v;
					SAFE_READ(stream, v);
					outValue = toStringHorizontalAlignment(v);
					return true;
				}
				case PayloadKind::CreateEffectType:
				{
					CreateWindowEffect v;
					SAFE_READ(stream, v);
					outValue = toStringCreateEffectType(v);
					return true;
				}
				case PayloadKind::CloseEffectType:
				{
					CloseWndEffect v;
					SAFE_READ(stream, v);
					outValue = toStringCloseEffectType(v);
					return true;
				}
				case PayloadKind::ItemCellStyle:
				{
					ItemCellStyle v;
					SAFE_READ(stream, v);
					outValue = toStringItemCellStyle(v);
					return true;
				}
				case PayloadKind::PropertyDefinition:
				{
					String name;
					String value;
					SAFE_READ(stream, name);
					SAFE_READ(stream, value);
					outName = name;
					outValue = value;
					return true;
				}
				default:
					outError = "decodePropertyPayload: unhandled payload kind.";
					return false;
				}
			}

			static bool readProperties(
				CEGUI::BinLayout::Stream& stream,
				CEGUI::BinLayout::XMLFileData::NodeData* parent,
				std::string& outError)
			{
				using namespace CEGUI::BinLayout;

				int propCount = 0;
				SAFE_READ(stream, propCount);

				for (int i = 0; i < propCount; ++i)
				{
					int propId = -1;
					SAFE_READ(stream, propId);

					CEGUI::String name;
					CEGUI::String value;
					if (!decodePropertyPayload(stream, propId, name, value, outError))
					{
						return false;
					}

					XMLFileData::PropertyData* p = new XMLFileData::PropertyData();
					p->mName = name;
					p->mValue = value;
					parent->addChild(p);
				}

				return true;
			}

			static bool readNode(
				CEGUI::BinLayout::Stream& stream,
				CEGUI::BinLayout::XMLFileData::NodeData*& outNode,
				std::string& outError)
			{
				using namespace CEGUI;
				using namespace CEGUI::BinLayout;

				int nodeTypeInt = -1;
				SAFE_READ(stream, nodeTypeInt);

				const NodeType nodeType = static_cast<NodeType>(nodeTypeInt);
				switch (nodeType)
				{
				case NT_Window:
				{
					XMLFileData::WindowData* w = new XMLFileData::WindowData();
					SAFE_READ_CLEANUP(stream, w->mType, delete w);
					SAFE_READ_CLEANUP(stream, w->mName, delete w);

					if (!readProperties(stream, w, outError))
					{
						delete w;
						return false;
					}

					int childCount = 0;
					SAFE_READ_CLEANUP(stream, childCount, delete w);
					for (int i = 0; i < childCount; ++i)
					{
						XMLFileData::NodeData* child = NULL;
						if (!readNode(stream, child, outError))
						{
							delete w;
							return false;
						}
						w->addChild(child);
					}

					outNode = w;
					return true;
				}
				case NT_AutoWindow:
				{
					XMLFileData::AutoWindowData* w = new XMLFileData::AutoWindowData();
					SAFE_READ_CLEANUP(stream, w->mNameSuffix, delete w);

					if (!readProperties(stream, w, outError))
					{
						delete w;
						return false;
					}

					int childCount = 0;
					SAFE_READ_CLEANUP(stream, childCount, delete w);
					for (int i = 0; i < childCount; ++i)
					{
						XMLFileData::NodeData* child = NULL;
						if (!readNode(stream, child, outError))
						{
							delete w;
							return false;
						}
						w->addChild(child);
					}

					outNode = w;
					return true;
				}
				case NT_LayoutImport:
				{
					XMLFileData::LayoutImportData* li = new XMLFileData::LayoutImportData();
					SAFE_READ_CLEANUP(stream, li->mPrefix, delete li);
					SAFE_READ_CLEANUP(stream, li->mFilename, delete li);
					SAFE_READ_CLEANUP(stream, li->mResourceGroup, delete li);
					outNode = li;
					return true;
				}
				case NT_Event:
				{
					XMLFileData::EventData* e = new XMLFileData::EventData();
					SAFE_READ_CLEANUP(stream, e->mName, delete e);
					SAFE_READ_CLEANUP(stream, e->mFunction, delete e);
					outNode = e;
					return true;
				}
				default:
					outError = "readNode: invalid/unsupported node type in binary layout.";
					return false;
				}
			}

			static CEGUI::BinLayout::XMLFileData::NodeData* cloneNode(
				const CEGUI::BinLayout::XMLFileData::NodeData* node,
				std::string& outError)
			{
				using namespace CEGUI::BinLayout;
				if (!node)
				{
					return NULL;
				}

				XMLFileData::NodeData* cloned = NULL;
				switch (node->getType())
				{
				case NT_Window:
				{
					const XMLFileData::WindowData* src = static_cast<const XMLFileData::WindowData*>(node);
					XMLFileData::WindowData* dst = new XMLFileData::WindowData();
					dst->mType = src->mType;
					dst->mName = src->mName;
					cloned = dst;
					break;
				}
				case NT_AutoWindow:
				{
					const XMLFileData::AutoWindowData* src = static_cast<const XMLFileData::AutoWindowData*>(node);
					XMLFileData::AutoWindowData* dst = new XMLFileData::AutoWindowData();
					dst->mNameSuffix = src->mNameSuffix;
					cloned = dst;
					break;
				}
				case NT_LayoutImport:
				{
					const XMLFileData::LayoutImportData* src = static_cast<const XMLFileData::LayoutImportData*>(node);
					XMLFileData::LayoutImportData* dst = new XMLFileData::LayoutImportData();
					dst->mPrefix = src->mPrefix;
					dst->mFilename = src->mFilename;
					dst->mResourceGroup = src->mResourceGroup;
					cloned = dst;
					break;
				}
				case NT_Event:
				{
					const XMLFileData::EventData* src = static_cast<const XMLFileData::EventData*>(node);
					XMLFileData::EventData* dst = new XMLFileData::EventData();
					dst->mName = src->mName;
					dst->mFunction = src->mFunction;
					cloned = dst;
					break;
				}
				case NT_Property:
				{
					const XMLFileData::PropertyData* src = static_cast<const XMLFileData::PropertyData*>(node);
					XMLFileData::PropertyData* dst = new XMLFileData::PropertyData();
					dst->mName = src->mName;
					dst->mValue = src->mValue;
					cloned = dst;
					break;
				}
				default:
					outError = "cloneNode: unsupported node type.";
					return NULL;
				}

				for (int i = 0; i < node->getChildCount(); ++i)
				{
					XMLFileData::NodeData* child = cloneNode(node->getChild(i), outError);
					if (!child)
					{
						delete cloned;
						return NULL;
					}
					cloned->addChild(child);
				}

				return cloned;
			}
		} // namespace

		LayoutInputFormat DetectLayoutInputFormat(const char* path)
		{
			if (!path || !path[0])
			{
				return LayoutInputFormat_Unknown;
			}

			FILE* fp = fopen(path, "rb");
			if (!fp)
			{
				return LayoutInputFormat_Unknown;
			}

			char magic[4] = { 0 };
			const size_t n = fread(magic, 1, 4, fp);
			fclose(fp);

			if (n < 4)
			{
				return LayoutInputFormat_Unknown;
			}

			return 0 == memcmp(magic, CEGUI::BinLayout::LAYOUT_BIN_FILE_MAGIC, 4)
				? LayoutInputFormat_Bin
				: LayoutInputFormat_Xml;
		}

		bool LoadBinLayoutToXmlData(
			const char* srcBinPath,
			CEGUI::BinLayout::XMLFileData::NodeData** outRoot,
			std::string& outError)
		{
			outError.clear();
			if (!srcBinPath || !outRoot)
			{
				outError = "LoadBinLayoutToXmlData: invalid args.";
				return false;
			}

			*outRoot = NULL;

			FILE* fp = fopen(srcBinPath, "rb");
			if (!fp)
			{
				outError = "LoadBinLayoutToXmlData: cannot open input file.";
				return false;
			}

			CEGUI::BinLayout::FileStream stream(fp, true);

			char magic[4] = { 0 };
			int version = 0;

			if (!safeReadMagic(stream, magic, 4, outError))
			{
				return false;
			}

			if (!safeRead(stream, version, outError))
			{
				return false;
			}

			if (0 != memcmp(magic, CEGUI::BinLayout::LAYOUT_BIN_FILE_MAGIC, 4))
			{
				outError = "LoadBinLayoutToXmlData: not a BinLayout file (magic mismatch).";
				return false;
			}

			if (version != CEGUI::BinLayout::LAYOUT_BIN_FILE_VERSION)
			{
				std::ostringstream oss;
				oss << "LoadBinLayoutToXmlData: unsupported version " << version << " (expected "
					<< CEGUI::BinLayout::LAYOUT_BIN_FILE_VERSION << ").";
				outError = oss.str();
				return false;
			}

			CEGUI::BinLayout::XMLFileData::NodeData* root = NULL;
			if (!readNode(stream, root, outError))
			{
				if (root)
				{
					delete root;
				}
				return false;
			}

			*outRoot = root;
			return true;
		}

		bool LoadXmlLayoutToXmlData(
			const char* srcXmlPath,
			CEGUI::BinLayout::XMLFileData::NodeData** outRoot,
			std::string& outError)
		{
			outError.clear();
			if (!srcXmlPath || !outRoot)
			{
				outError = "LoadXmlLayoutToXmlData: invalid args.";
				return false;
			}

			*outRoot = NULL;

			FILE* fp = fopen(srcXmlPath, "rb");
			if (!fp)
			{
				outError = "LoadXmlLayoutToXmlData: cannot open input file.";
				return false;
			}

			fseek(fp, 0, SEEK_END);
			const long fileSize = ftell(fp);
			fseek(fp, 0, SEEK_SET);
			if (fileSize <= 0)
			{
				fclose(fp);
				outError = "LoadXmlLayoutToXmlData: input file is empty.";
				return false;
			}

			std::vector<char> fileBuf(static_cast<size_t>(fileSize));
			if (1 != fread(&fileBuf[0], static_cast<size_t>(fileSize), 1, fp))
			{
				fclose(fp);
				outError = "LoadXmlLayoutToXmlData: failed to read input file.";
				return false;
			}
			fclose(fp);

			CEGUI::LJXMLParser parser;
			CEGUI::BinLayout::XMLFileData xmlFileData;

			try
			{
				parser.parseXMLFileBuf(xmlFileData, &fileBuf[0], static_cast<std::streamsize>(fileBuf.size()));
			}
			catch (const CEGUI::Exception& e)
			{
				outError = std::string("LoadXmlLayoutToXmlData: ") + e.getMessage().c_str();
				return false;
			}
			catch (...)
			{
				outError = "LoadXmlLayoutToXmlData: unknown parser exception.";
				return false;
			}

			CEGUI::BinLayout::XMLFileData::NodeData* root = xmlFileData.getRootData();
			if (!root)
			{
				outError = "LoadXmlLayoutToXmlData: parsed XML has no root node.";
				return false;
			}

			CEGUI::BinLayout::XMLFileData::NodeData* cloned = cloneNode(root, outError);
			if (!cloned)
			{
				if (outError.empty())
				{
					outError = "LoadXmlLayoutToXmlData: failed to clone XML tree.";
				}
				return false;
			}

			*outRoot = cloned;
			return true;
		}

		bool LoadLayoutToXmlData(
			const char* srcPath,
			CEGUI::BinLayout::XMLFileData::NodeData** outRoot,
			std::string& outError)
		{
			const LayoutInputFormat format = DetectLayoutInputFormat(srcPath);
			if (format == LayoutInputFormat_Bin)
			{
				return LoadBinLayoutToXmlData(srcPath, outRoot, outError);
			}
			if (format == LayoutInputFormat_Xml)
			{
				return LoadXmlLayoutToXmlData(srcPath, outRoot, outError);
			}

			outError = "LoadLayoutToXmlData: unsupported or unreadable input file.";
			return false;
		}

		bool ConvertBinToXmlFile(
			const char* srcBinPath,
			const char* dstXmlPath,
			std::string& outError)
		{
			outError.clear();

			CEGUI::BinLayout::XMLFileData::NodeData* root = NULL;
			if (!LoadBinLayoutToXmlData(srcBinPath, &root, outError))
			{
				return false;
			}

			std::string xml;
			if (!BuildLayoutXml(root, xml, outError))
			{
				delete root;
				return false;
			}

			FILE* fp = fopen(dstXmlPath, "wb");
			if (!fp)
			{
				delete root;
				outError = "ConvertBinToXmlFile: cannot open output file.";
				return false;
			}

			fwrite(xml.data(), 1, xml.size(), fp);
			fclose(fp);

			delete root;
			return true;
		}

		bool ConvertXmlToBinFile(
			const char* srcXmlPath,
			const char* dstBinPath,
			std::string& outError)
		{
			outError.clear();

			CEGUI::BinLayout::g_RegSerializers_v1();

			CEGUI::BinLayout::XMLToBin converter;
			if (!converter.convert(srcXmlPath, dstBinPath))
			{
				outError = "ConvertXmlToBinFile: conversion failed (see console/log for details).";
				return false;
			}

			return true;
		}

		bool WriteXmlDataToBinFile(
			const char* dstBinPath,
			CEGUI::BinLayout::XMLFileData::NodeData* root,
			std::string& outError)
		{
			outError.clear();
			if (!dstBinPath || !root)
			{
				outError = "WriteXmlDataToBinFile: invalid args.";
				return false;
			}

			CEGUI::BinLayout::g_RegSerializers_v1();

			FILE* fp = fopen(dstBinPath, "wb");
			if (!fp)
			{
				outError = "WriteXmlDataToBinFile: cannot open output file.";
				return false;
			}

			CEGUI::BinLayout::BinLayoutFileSerializer serializer;
			CEGUI::BinLayout::FileStream stream(fp, false);
			const bool ok = serializer.write(stream, CEGUI::BinLayout::LAYOUT_BIN_FILE_VERSION, root);

			fclose(fp);

			if (!ok)
			{
				outError = "WriteXmlDataToBinFile: serializer.write failed.";
				return false;
			}

			return true;
		}

		void FreeXmlData(CEGUI::BinLayout::XMLFileData::NodeData* root)
		{
			delete root;
		}
	}
}
