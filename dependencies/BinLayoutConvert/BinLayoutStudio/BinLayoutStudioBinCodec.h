#pragma once

#include <stdint.h>
#include <string>

#include "BinLayout/CEGUIXMLFileData.h"

namespace BinLayoutStudio
{
	namespace Core
	{
		enum LayoutInputFormat
		{
			LayoutInputFormat_Unknown = 0,
			LayoutInputFormat_Xml,
			LayoutInputFormat_Bin,
		};

		LayoutInputFormat DetectLayoutInputFormat(const char* path);

		bool LoadBinLayoutToXmlData(
			const char* srcBinPath,
			CEGUI::BinLayout::XMLFileData::NodeData** outRoot,
			std::string& outError);

		bool LoadXmlLayoutToXmlData(
			const char* srcXmlPath,
			CEGUI::BinLayout::XMLFileData::NodeData** outRoot,
			std::string& outError);

		bool LoadLayoutToXmlData(
			const char* srcPath,
			CEGUI::BinLayout::XMLFileData::NodeData** outRoot,
			std::string& outError);

		bool ConvertBinToXmlFile(
			const char* srcBinPath,
			const char* dstXmlPath,
			std::string& outError);

		bool ConvertXmlToBinFile(
			const char* srcXmlPath,
			const char* dstBinPath,
			std::string& outError);

		bool WriteXmlDataToBinFile(
			const char* dstBinPath,
			CEGUI::BinLayout::XMLFileData::NodeData* root,
			std::string& outError);

		void FreeXmlData(CEGUI::BinLayout::XMLFileData::NodeData* root);
	}
}
