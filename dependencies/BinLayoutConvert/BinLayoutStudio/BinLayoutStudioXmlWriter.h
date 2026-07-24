#pragma once

#include <stdint.h>
#include <string>

#include "BinLayout/CEGUIXMLFileData.h"

namespace BinLayoutStudio
{
	namespace Core
	{
		bool BuildLayoutXml(
			const CEGUI::BinLayout::XMLFileData::NodeData* root,
			std::string& outXml,
			std::string& outError);
	}
}
