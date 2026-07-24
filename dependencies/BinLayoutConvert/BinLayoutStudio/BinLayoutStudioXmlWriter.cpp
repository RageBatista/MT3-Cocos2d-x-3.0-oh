#include "BinLayoutStudioXmlWriter.h"

#include <sstream>

namespace
{
	static void appendIndent(std::ostringstream& out, int indentLevel)
	{
		for (int i = 0; i < indentLevel; ++i)
		{
			out << "    ";
		}
	}

	static void appendEscapedXmlAttr(std::ostringstream& out, const CEGUI::String& value)
	{
		const char* s = value.c_str();
		for (const char* p = s; p && *p; ++p)
		{
			switch (*p)
			{
			case '&': out << "&amp;"; break;
			case '<': out << "&lt;"; break;
			case '>': out << "&gt;"; break;
			case '"': out << "&quot;"; break;
			case '\'': out << "&apos;"; break;
			default: out << *p; break;
			}
		}
	}

	static void appendAttr(std::ostringstream& out, const char* name, const CEGUI::String& value)
	{
		out << " " << name << "=\"";
		appendEscapedXmlAttr(out, value);
		out << "\"";
	}

	static bool writeNodeXml(
		const CEGUI::BinLayout::XMLFileData::NodeData* node,
		std::ostringstream& out,
		int indentLevel,
		std::string& outError)
	{
		using namespace CEGUI::BinLayout;

		if (!node)
		{
			outError = "writeNodeXml: node is null.";
			return false;
		}

		const NodeType type = node->getType();
		switch (type)
		{
		case NT_Window:
		{
			const XMLFileData::WindowData* w = static_cast<const XMLFileData::WindowData*>(node);

			appendIndent(out, indentLevel);
			out << "<Window";
			appendAttr(out, "Type", w->mType);
			appendAttr(out, "Name", w->mName);
			out << " >\n";

			for (int i = 0; i < node->getChildCount(); ++i)
			{
				const XMLFileData::NodeData* child = node->getChild(i);
				if (child && child->getType() == NT_Property)
				{
					const XMLFileData::PropertyData* p = static_cast<const XMLFileData::PropertyData*>(child);
					appendIndent(out, indentLevel + 1);
					out << "<Property";
					appendAttr(out, "Name", p->mName);
					appendAttr(out, "Value", p->mValue);
					out << " />\n";
				}
			}

			for (int i = 0; i < node->getChildCount(); ++i)
			{
				const XMLFileData::NodeData* child = node->getChild(i);
				if (child && child->getType() != NT_Property)
				{
					if (!writeNodeXml(child, out, indentLevel + 1, outError))
					{
						return false;
					}
				}
			}

			appendIndent(out, indentLevel);
			out << "</Window>\n";
			return true;
		}
		case NT_AutoWindow:
		{
			const XMLFileData::AutoWindowData* w = static_cast<const XMLFileData::AutoWindowData*>(node);

			appendIndent(out, indentLevel);
			out << "<AutoWindow";
			appendAttr(out, "NameSuffix", w->mNameSuffix);
			out << " >\n";

			for (int i = 0; i < node->getChildCount(); ++i)
			{
				const XMLFileData::NodeData* child = node->getChild(i);
				if (child && child->getType() == NT_Property)
				{
					const XMLFileData::PropertyData* p = static_cast<const XMLFileData::PropertyData*>(child);
					appendIndent(out, indentLevel + 1);
					out << "<Property";
					appendAttr(out, "Name", p->mName);
					appendAttr(out, "Value", p->mValue);
					out << " />\n";
				}
			}

			for (int i = 0; i < node->getChildCount(); ++i)
			{
				const XMLFileData::NodeData* child = node->getChild(i);
				if (child && child->getType() != NT_Property)
				{
					if (!writeNodeXml(child, out, indentLevel + 1, outError))
					{
						return false;
					}
				}
			}

			appendIndent(out, indentLevel);
			out << "</AutoWindow>\n";
			return true;
		}
		case NT_LayoutImport:
		{
			const XMLFileData::LayoutImportData* li = static_cast<const XMLFileData::LayoutImportData*>(node);
			appendIndent(out, indentLevel);
			out << "<LayoutImport";
			appendAttr(out, "Prefix", li->mPrefix);
			appendAttr(out, "Filename", li->mFilename);
			appendAttr(out, "ResourceGroup", li->mResourceGroup);
			out << " />\n";
			return true;
		}
		case NT_Event:
		{
			const XMLFileData::EventData* e = static_cast<const XMLFileData::EventData*>(node);
			appendIndent(out, indentLevel);
			out << "<Event";
			appendAttr(out, "Name", e->mName);
			appendAttr(out, "Function", e->mFunction);
			out << " />\n";
			return true;
		}
		case NT_Property:
		{
			outError = "NT_Property should not be emitted directly (expected handled by parent).";
			return false;
		}
		default:
			outError = "Unknown node type encountered when writing XML.";
			return false;
		}
	}
}

namespace BinLayoutStudio
{
	namespace Core
	{
		bool BuildLayoutXml(
			const CEGUI::BinLayout::XMLFileData::NodeData* root,
			std::string& outXml,
			std::string& outError)
		{
			outXml.clear();
			outError.clear();

			if (!root)
			{
				outError = "BuildLayoutXml: root is null.";
				return false;
			}

			std::ostringstream out;
			out << "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n\n";
			out << "<GUILayout >\n";

			if (!writeNodeXml(root, out, 1, outError))
			{
				return false;
			}

			out << "</GUILayout>\n";
			outXml = out.str();
			return true;
		}
	}
}

