#pragma once

#include <string>
#include <vector>

namespace BinLayoutStudio
{
	namespace Batch
	{
		enum SourceFormat
		{
			SourceFormat_Unknown = 0,
			SourceFormat_Xml,
			SourceFormat_Bin,
		};

		enum ConvertMode
		{
			ConvertMode_Auto = 0,
			ConvertMode_XmlToBin,
			ConvertMode_BinToXml,
		};

		enum OutputLayout
		{
			OutputLayout_Mirror = 0,
			OutputLayout_Flat,
		};

		enum NamingRule
		{
			NamingRule_KeepName = 0,
			NamingRule_AppendTargetSuffix,
		};

		enum PlannedAction
		{
			PlannedAction_None = 0,
			PlannedAction_XmlToBin,
			PlannedAction_BinToXml,
		};

		struct RuleConfig
		{
			std::string sourceRoot;
			std::string outputRoot;
			std::string includePattern;
			ConvertMode mode;
			OutputLayout outputLayout;
			NamingRule namingRule;
			bool recursive;
			bool overwriteExisting;

			RuleConfig();
		};

		struct PreviewItem
		{
			std::string sourcePath;
			std::string relativePath;
			std::string outputPath;
			SourceFormat sourceFormat;
			PlannedAction action;
			bool actionable;
			std::string note;

			PreviewItem();
		};

		struct PreviewSummary
		{
			int totalFiles;
			int xmlFiles;
			int binFiles;
			int unknownFiles;
			int actionableFiles;
			int skippedFiles;
			int warningFiles;

			PreviewSummary();
		};

		const char* SourceFormatToString(SourceFormat format);
		const char* PlannedActionToString(PlannedAction action);

		bool BuildPreview(
			const RuleConfig& rules,
			std::vector<PreviewItem>& outItems,
			PreviewSummary& outSummary,
			std::string& outError);
	}
}
