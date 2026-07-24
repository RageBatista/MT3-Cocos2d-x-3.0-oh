#include "BinLayoutStudioBatchConvert.h"

#include <windows.h>
#include <Shlwapi.h>

#include <algorithm>
#include <cstdio>
#include <cstring>
#include <map>
#include <set>
#include <sstream>

namespace BinLayoutStudio
{
	namespace Batch
	{
		namespace
		{
			static std::string normalizePath(const std::string& path)
			{
				std::string out = path;
				std::replace(out.begin(), out.end(), '/', '\\');
				while (!out.empty() && (out[out.size() - 1] == '\\' || out[out.size() - 1] == '/'))
				{
					if (out.size() == 3 && out[1] == ':')
					{
						break;
					}
					out.erase(out.size() - 1);
				}
				return out;
			}

			static std::string toComparablePath(const std::string& path)
			{
				std::string out = normalizePath(path);
				std::transform(out.begin(), out.end(), out.begin(), ::tolower);
				return out;
			}

			static std::string joinPath(const std::string& a, const std::string& b)
			{
				if (a.empty())
				{
					return normalizePath(b);
				}
				if (b.empty())
				{
					return normalizePath(a);
				}

				std::string left = normalizePath(a);
				if (left[left.size() - 1] != '\\')
				{
					left += "\\";
				}

				std::string right = b;
				while (!right.empty() && (right[0] == '\\' || right[0] == '/'))
				{
					right.erase(right.begin());
				}
				std::replace(right.begin(), right.end(), '/', '\\');
				return left + right;
			}

			static bool directoryExists(const std::string& path)
			{
				const DWORD attrs = GetFileAttributesA(path.c_str());
				return attrs != INVALID_FILE_ATTRIBUTES && 0 != (attrs & FILE_ATTRIBUTE_DIRECTORY);
			}

			static bool fileExists(const std::string& path)
			{
				const DWORD attrs = GetFileAttributesA(path.c_str());
				return attrs != INVALID_FILE_ATTRIBUTES && 0 == (attrs & FILE_ATTRIBUTE_DIRECTORY);
			}

			static std::string getFileNameOnly(const std::string& path)
			{
				const std::string normalized = normalizePath(path);
				const size_t pos = normalized.find_last_of('\\');
				return pos == std::string::npos ? normalized : normalized.substr(pos + 1);
			}

			static std::string getParentDirectory(const std::string& path)
			{
				const std::string normalized = normalizePath(path);
				const size_t pos = normalized.find_last_of('\\');
				return pos == std::string::npos ? std::string() : normalized.substr(0, pos);
			}

			static std::string getRelativePath(const std::string& root, const std::string& path)
			{
				const std::string rootNormalized = normalizePath(root);
				const std::string pathNormalized = normalizePath(path);
				const std::string rootComparable = toComparablePath(rootNormalized);
				const std::string pathComparable = toComparablePath(pathNormalized);

				if (pathComparable == rootComparable)
				{
					return std::string();
				}

				if (pathComparable.size() > rootComparable.size()
					&& 0 == _strnicmp(pathComparable.c_str(), rootComparable.c_str(), rootComparable.size())
					&& '\\' == pathComparable[rootComparable.size()])
				{
					return pathNormalized.substr(rootNormalized.size() + 1);
				}

				return getFileNameOnly(pathNormalized);
			}

			static std::string getStem(const std::string& fileName)
			{
				const size_t dot = fileName.find_last_of('.');
				if (dot == std::string::npos)
				{
					return fileName;
				}
				return fileName.substr(0, dot);
			}

			static std::string getExtension(const std::string& fileName)
			{
				const size_t dot = fileName.find_last_of('.');
				if (dot == std::string::npos)
				{
					return std::string();
				}
				return fileName.substr(dot);
			}

			static std::string appendSuffixBeforeExtension(const std::string& fileName, const std::string& suffix)
			{
				return getStem(fileName) + suffix + getExtension(fileName);
			}

			static bool isDescendantPath(const std::string& root, const std::string& candidate)
			{
				const std::string rootComparable = toComparablePath(root);
				const std::string candidateComparable = toComparablePath(candidate);
				return candidateComparable.size() > rootComparable.size()
					&& 0 == _strnicmp(candidateComparable.c_str(), rootComparable.c_str(), rootComparable.size())
					&& '\\' == candidateComparable[rootComparable.size()];
			}

			static bool readMagic(const std::string& path, char magic[4], std::string& outError)
			{
				FILE* fp = fopen(path.c_str(), "rb");
				if (!fp)
				{
					outError = "Cannot open file.";
					return false;
				}

				const size_t n = fread(magic, 1, 4, fp);
				fclose(fp);
				if (n == 0)
				{
					outError = "File is empty.";
					return false;
				}
				if (n < 4)
				{
					outError = "File is shorter than 4 bytes.";
					return false;
				}
				return true;
			}

			static SourceFormat detectSourceFormat(const std::string& path, std::string& outNote)
			{
				outNote.clear();
				char magic[4] = { 0 };
				if (!readMagic(path, magic, outNote))
				{
					return SourceFormat_Unknown;
				}

				if (0 == memcmp(magic, "LBFM", 4))
				{
					return SourceFormat_Bin;
				}

				return SourceFormat_Xml;
			}

			static PlannedAction planAction(SourceFormat format, ConvertMode mode, std::string& outNote)
			{
				outNote.clear();
				switch (mode)
				{
				case ConvertMode_Auto:
					if (format == SourceFormat_Xml)
					{
						return PlannedAction_XmlToBin;
					}
					if (format == SourceFormat_Bin)
					{
						return PlannedAction_BinToXml;
					}
					outNote = "Cannot detect input format.";
					return PlannedAction_None;

				case ConvertMode_XmlToBin:
					if (format == SourceFormat_Xml)
					{
						return PlannedAction_XmlToBin;
					}
					outNote = format == SourceFormat_Bin ? "Source is already BIN. Skipped." : "Cannot treat source as XML.";
					return PlannedAction_None;

				case ConvertMode_BinToXml:
					if (format == SourceFormat_Bin)
					{
						return PlannedAction_BinToXml;
					}
					outNote = format == SourceFormat_Xml ? "Source is already XML. Skipped." : "Cannot treat source as BIN.";
					return PlannedAction_None;
				}

				outNote = "Unknown convert mode.";
				return PlannedAction_None;
			}

			static std::string buildOutputFileName(const std::string& sourceFileName, PlannedAction action, NamingRule namingRule)
			{
				if (namingRule == NamingRule_AppendTargetSuffix)
				{
					return appendSuffixBeforeExtension(sourceFileName, action == PlannedAction_BinToXml ? "_xml" : "_bin");
				}
				return sourceFileName;
			}

			static std::string buildOutputPath(const RuleConfig& rules, const PreviewItem& item)
			{
				const std::string sourceFileName = getFileNameOnly(item.sourcePath);
				std::string relativePath = item.relativePath;
				if (rules.outputLayout == OutputLayout_Flat)
				{
					relativePath = sourceFileName;
				}
				else
				{
					relativePath = normalizePath(relativePath);
				}

				const std::string finalFileName = buildOutputFileName(getFileNameOnly(relativePath), item.action, rules.namingRule);
				if (rules.outputLayout == OutputLayout_Flat)
				{
					return joinPath(rules.outputRoot, finalFileName);
				}

				const std::string parent = getParentDirectory(relativePath);
				return parent.empty()
					? joinPath(rules.outputRoot, finalFileName)
					: joinPath(joinPath(rules.outputRoot, parent), finalFileName);
			}

			static void enumerateFilesRecursive(
				const std::string& dir,
				const std::string& includePattern,
				bool recursive,
				const std::string& excludedComparableDir,
				std::vector<std::string>& outFiles,
				std::string& outError)
			{
				const std::string query = joinPath(dir, "*");
				WIN32_FIND_DATAA fd;
				HANDLE hFind = FindFirstFileA(query.c_str(), &fd);
				if (hFind == INVALID_HANDLE_VALUE)
				{
					return;
				}

				do
				{
					const char* name = fd.cFileName;
					if (0 == strcmp(name, ".") || 0 == strcmp(name, ".."))
					{
						continue;
					}

					const std::string fullPath = joinPath(dir, name);
					const std::string comparablePath = toComparablePath(fullPath);

					if (0 != (fd.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY))
					{
						if (recursive && (excludedComparableDir.empty() || comparablePath != excludedComparableDir))
						{
							enumerateFilesRecursive(fullPath, includePattern, recursive, excludedComparableDir, outFiles, outError);
							if (!outError.empty())
							{
								FindClose(hFind);
								return;
							}
						}
						continue;
					}

					if (PathMatchSpecA(name, includePattern.c_str()))
					{
						outFiles.push_back(normalizePath(fullPath));
					}
				} while (FindNextFileA(hFind, &fd));

				FindClose(hFind);
			}

			static bool comparePreviewItem(const PreviewItem& left, const PreviewItem& right)
			{
				const std::string lhs = toComparablePath(left.relativePath.empty() ? left.sourcePath : left.relativePath);
				const std::string rhs = toComparablePath(right.relativePath.empty() ? right.sourcePath : right.relativePath);
				if (lhs != rhs)
				{
					return lhs < rhs;
				}
				return toComparablePath(left.outputPath) < toComparablePath(right.outputPath);
			}
		}

		RuleConfig::RuleConfig()
			: includePattern("*.layout")
			, mode(ConvertMode_Auto)
			, outputLayout(OutputLayout_Mirror)
			, namingRule(NamingRule_KeepName)
			, recursive(true)
			, overwriteExisting(false)
		{
		}

		PreviewItem::PreviewItem()
			: sourceFormat(SourceFormat_Unknown)
			, action(PlannedAction_None)
			, actionable(false)
		{
		}

		PreviewSummary::PreviewSummary()
			: totalFiles(0)
			, xmlFiles(0)
			, binFiles(0)
			, unknownFiles(0)
			, actionableFiles(0)
			, skippedFiles(0)
			, warningFiles(0)
		{
		}

		const char* SourceFormatToString(SourceFormat format)
		{
			switch (format)
			{
			case SourceFormat_Xml: return "XML";
			case SourceFormat_Bin: return "BIN";
			default: return "Unknown";
			}
		}

		const char* PlannedActionToString(PlannedAction action)
		{
			switch (action)
			{
			case PlannedAction_XmlToBin: return "XML -> BIN";
			case PlannedAction_BinToXml: return "BIN -> XML";
			default: return "Skip";
			}
		}

		bool BuildPreview(
			const RuleConfig& rules,
			std::vector<PreviewItem>& outItems,
			PreviewSummary& outSummary,
			std::string& outError)
		{
			outItems.clear();
			outSummary = PreviewSummary();
			outError.clear();

			const std::string sourceRoot = normalizePath(rules.sourceRoot);
			const std::string outputRoot = normalizePath(rules.outputRoot);
			const std::string includePattern = rules.includePattern.empty() ? "*.layout" : rules.includePattern;

			if (sourceRoot.empty())
			{
				outError = "Source directory is required.";
				return false;
			}

			if (!directoryExists(sourceRoot))
			{
				outError = "Source directory does not exist.";
				return false;
			}

			if (outputRoot.empty())
			{
				outError = "Output directory is required.";
				return false;
			}

			const std::string excludedComparableDir =
				isDescendantPath(sourceRoot, outputRoot) ? toComparablePath(outputRoot) : std::string();

			std::vector<std::string> files;
			enumerateFilesRecursive(sourceRoot, includePattern, rules.recursive, excludedComparableDir, files, outError);
			if (!outError.empty())
			{
				return false;
			}

			std::sort(files.begin(), files.end());
			outSummary.totalFiles = static_cast<int>(files.size());

			std::map<std::string, std::vector<size_t> > outputCollisionMap;

			for (size_t i = 0; i < files.size(); ++i)
			{
				PreviewItem item;
				item.sourcePath = files[i];
				item.relativePath = getRelativePath(sourceRoot, files[i]);

				std::string note;
				item.sourceFormat = detectSourceFormat(item.sourcePath, note);
				switch (item.sourceFormat)
				{
				case SourceFormat_Xml: ++outSummary.xmlFiles; break;
				case SourceFormat_Bin: ++outSummary.binFiles; break;
				default: ++outSummary.unknownFiles; break;
				}

				std::string actionNote;
				item.action = planAction(item.sourceFormat, rules.mode, actionNote);
				item.actionable = item.action != PlannedAction_None;
				item.note = !note.empty() ? note : actionNote;

				if (item.actionable)
				{
					item.outputPath = buildOutputPath(rules, item);
					const std::string comparableSource = toComparablePath(item.sourcePath);
					const std::string comparableOutput = toComparablePath(item.outputPath);

					if (!rules.overwriteExisting && fileExists(item.outputPath))
					{
						item.actionable = false;
						item.note = "Target file exists and overwrite is disabled.";
					}
					else if (comparableSource == comparableOutput)
					{
						item.actionable = false;
						item.note = "Target path matches source. Change output root or enable suffix naming.";
					}
					else if (fileExists(item.outputPath))
					{
						item.note = "Target file exists and will be overwritten.";
					}

					if (!item.outputPath.empty())
					{
						outputCollisionMap[toComparablePath(item.outputPath)].push_back(outItems.size());
					}
				}
				else if (item.outputPath.empty())
				{
					item.outputPath = "-";
				}

				outItems.push_back(item);
			}

			for (std::map<std::string, std::vector<size_t> >::const_iterator it = outputCollisionMap.begin();
				it != outputCollisionMap.end();
				++it)
			{
				if (it->second.size() <= 1)
				{
					continue;
				}

				for (size_t i = 0; i < it->second.size(); ++i)
				{
					PreviewItem& item = outItems[it->second[i]];
					item.actionable = false;
					item.note = "Output collision: multiple sources map to the same target.";
				}
			}

			for (size_t i = 0; i < outItems.size(); ++i)
			{
				if (outItems[i].actionable)
				{
					++outSummary.actionableFiles;
				}
				else
				{
					++outSummary.skippedFiles;
				}

				if (!outItems[i].note.empty())
				{
					++outSummary.warningFiles;
				}

				if (outItems[i].outputPath.empty())
				{
					outItems[i].outputPath = "-";
				}
			}

			std::sort(outItems.begin(), outItems.end(), comparePreviewItem);
			return true;
		}
	}
}
