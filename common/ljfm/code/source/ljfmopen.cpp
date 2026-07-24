#include "../include/common.h"
#include "../include/ljfmopen.h"
#include "../include/ljfileinfo.h"
#include "../platform/utils/Utils.h"
#include "../platform/utils/StringUtil.h"
#include "utils/FileUtil.h"
#include "../platform/log/CoreLog.h"
#include <set>
#include <map>
#include <vector>
#include <fstream>
#include <cstdarg>

#ifdef FORCEGUIEDITOR
#include <direct.h>
#endif

namespace LJFM
{
	LJFM_STATIC_ASSERT(sizeof(fsize_t) == 8);
}

namespace
{
	LJFM::CMutex g_missingFileCacheMutex;
	std::set<std::wstring> g_missingFileCache;
	const size_t kMissingFileCacheLimit = 8192;
	const std::wstring kPngPartSuffix = L".pngpart";
	const std::wstring kPngSuffix = L".png";
	LJFM::CMutex g_looseFallbackCacheMutex;
	std::map<std::wstring, LJFP_FileInfo*> g_looseFallbackFileInfoCache;
	std::set<std::wstring> g_looseFallbackLogOnce;
	std::set<std::wstring> g_loosePreferredLogOnce;

	void StartupBootstrapTraceLJFM(const char* fmt, ...)
	{
#if defined(_WIN32)
		char message[2048] = { 0 };
		va_list args;
		va_start(args, fmt);
#if _MSC_VER >= 1400
		_vsnprintf_s(message, sizeof(message), _TRUNCATE, fmt, args);
#else
		_vsnprintf(message, sizeof(message) - 1, fmt, args);
#endif
		va_end(args);

		SYSTEMTIME st;
		GetLocalTime(&st);

		char line[2400] = { 0 };
#if _MSC_VER >= 1400
		_snprintf_s(
			line,
			sizeof(line),
			_TRUNCATE,
			"[%04d-%02d-%02d %02d:%02d:%02d.%03d] [LJFM] %s\r\n",
			st.wYear,
			st.wMonth,
			st.wDay,
			st.wHour,
			st.wMinute,
			st.wSecond,
			st.wMilliseconds,
			message);
#else
		_snprintf(
			line,
			sizeof(line) - 1,
			"[%04d-%02d-%02d %02d:%02d:%02d.%03d] [LJFM] %s\r\n",
			st.wYear,
			st.wMonth,
			st.wDay,
			st.wHour,
			st.wMinute,
			st.wSecond,
			st.wMilliseconds,
			message);
#endif

		std::string root = ws2s(MHSD_UTILS::GetRootDir());
		if (!root.empty() && root[root.size() - 1] != '/' && root[root.size() - 1] != '\\')
		{
			root += "/";
		}
		std::ofstream ofs((root + "startup_bootstrap.log").c_str(), std::ios::out | std::ios::app | std::ios::binary);
		if (ofs.is_open())
		{
			ofs << line;
			ofs.close();
		}
#else
		(void)fmt;
#endif
	}

	bool IsKnownMissingFile(const std::wstring& filename)
	{
		LJFM::CMutex::CScoped lock(g_missingFileCacheMutex);
		return g_missingFileCache.find(filename) != g_missingFileCache.end();
	}

	void RememberMissingFile(const std::wstring& filename)
	{
		LJFM::CMutex::CScoped lock(g_missingFileCacheMutex);
		if (g_missingFileCache.size() >= kMissingFileCacheLimit)
		{
			g_missingFileCache.clear();
		}
		g_missingFileCache.insert(filename);
	}

	void ForgetMissingFile(const std::wstring& filename)
	{
		LJFM::CMutex::CScoped lock(g_missingFileCacheMutex);
		g_missingFileCache.erase(filename);
	}

	void ClearMissingFileCache()
	{
		LJFM::CMutex::CScoped lock(g_missingFileCacheMutex);
		g_missingFileCache.clear();
	}

	bool TrimPrefixIfPresent(std::wstring& value, const std::wstring& prefix)
	{
		if (value.find(prefix) != 0)
		{
			return false;
		}

		value = value.substr(prefix.size(), value.size());
		return true;
	}

	bool IsLooseResFallbackCandidate(const std::wstring& filename)
	{
		// 只对模型资源开放回退，避免扩大运行时资源来源范围。
		return filename.compare(0, 6, L"model/") == 0;
	}

	bool IsLooseResPreferredCandidate(const std::wstring& filename)
	{
		(void)filename;
		// 发布态要求优先使用打包资源索引，不再做“强制优先 loose res”。
		return false;
	}

	std::wstring JoinRootAndRelative(const std::wstring& rootDir, const std::wstring& relativePath)
	{
		std::wstring root = rootDir;
		if (!root.empty() && root[root.size() - 1] != L'/' && root[root.size() - 1] != L'\\')
		{
			root += L"/";
		}
		return root + relativePath;
	}

	bool NeedsUpdateEntryOverride(const LJFP_FileInfo* baseFileInfo, const LJFP_FileInfo* updateFileInfo)
	{
		if (updateFileInfo == NULL)
		{
			return false;
		}
		if (baseFileInfo == NULL)
		{
			return true;
		}
		return baseFileInfo->m_CRC32 != updateFileInfo->m_CRC32 ||
			baseFileInfo->m_Size != updateFileInfo->m_Size;
	}

	bool IsUpdateOverlayDataAvailable(
		LJFP_PackInfo* basePackInfo,
		LJFP_PackInfo* updatePackInfo,
		unsigned int& changedEntryCount,
		unsigned int& missingContainerCount,
		std::wstring& sampleMissingName,
		std::wstring& sampleMissingSource)
	{
		changedEntryCount = 0;
		missingContainerCount = 0;
		sampleMissingName.clear();
		sampleMissingSource.clear();
		if (updatePackInfo == NULL)
		{
			return true;
		}

		std::set<std::wstring> missingSources;
		for (unsigned int i = 0; i < updatePackInfo->GetFileCount(); ++i)
		{
			LJFP_FileInfo* updateFileInfo = updatePackInfo->GetFileInfo(i);
			LJFP_FileInfo* baseFileInfo = NULL;
			if (basePackInfo != NULL && updateFileInfo != NULL)
			{
				baseFileInfo = basePackInfo->FindFileInfo(updateFileInfo->m_PathFileNameCRC32);
			}
			if (!NeedsUpdateEntryOverride(baseFileInfo, updateFileInfo))
			{
				continue;
			}

			++changedEntryCount;
			const std::wstring sourcePath = updateFileInfo->GetFullPathFileName();
			if (!MHSD_UTILS::ExistFile(sourcePath))
			{
				missingSources.insert(sourcePath);
				if (sampleMissingName.empty())
				{
					sampleMissingName = updateFileInfo->m_PathFileName;
					sampleMissingSource = sourcePath;
				}
			}
		}

		missingContainerCount = (unsigned int)missingSources.size();
		return missingContainerCount == 0;
	}

	std::wstring GetLooseResFallbackRoot()
	{
#ifdef WIN7_32
		return StringCover::to_wstring(CFileUtil::GetWin32LooseResourceRoot()) + L"/";
#else
		return JoinRootAndRelative(MHSD_UTILS::GetRootDir(), L"res/");
#endif
	}

	LJFP_FileInfo* GetOrCreateLooseFallbackFileInfo(const std::wstring& filename)
	{
		if (!IsLooseResFallbackCandidate(filename))
		{
			return NULL;
		}

		const std::wstring fallbackRoot = GetLooseResFallbackRoot();
		if (!MHSD_UTILS::ExistFile(fallbackRoot + filename))
		{
			return NULL;
		}

		LJFM::CMutex::CScoped lock(g_looseFallbackCacheMutex);
		std::map<std::wstring, LJFP_FileInfo*>::iterator it = g_looseFallbackFileInfoCache.find(filename);
		if (it != g_looseFallbackFileInfoCache.end())
		{
			return it->second;
		}

		LJFP_FileInfo* fallbackInfo = new LJFP_FileInfo();
		fallbackInfo->m_FileArea = 1;
		fallbackInfo->m_PackIndex = 0;
		fallbackInfo->m_CompressType = 0;
		fallbackInfo->m_CodeType = 0;
		fallbackInfo->m_RootPathName = fallbackRoot;
		fallbackInfo->m_PathFileName = filename;
		g_looseFallbackFileInfoCache[filename] = fallbackInfo;
		return fallbackInfo;
	}

	void ClearLooseFallbackFileInfoCache()
	{
		LJFM::CMutex::CScoped lock(g_looseFallbackCacheMutex);
		for (std::map<std::wstring, LJFP_FileInfo*>::iterator it = g_looseFallbackFileInfoCache.begin();
			it != g_looseFallbackFileInfoCache.end();
			++it)
		{
			delete it->second;
		}
		g_looseFallbackFileInfoCache.clear();
		g_looseFallbackLogOnce.clear();
		g_loosePreferredLogOnce.clear();
	}

	void LogLooseFallbackOnce(const std::wstring& filename)
	{
		LJFM::CMutex::CScoped lock(g_looseFallbackCacheMutex);
		if (g_looseFallbackLogOnce.find(filename) != g_looseFallbackLogOnce.end())
		{
			return;
		}
		g_looseFallbackLogOnce.insert(filename);
		LJFM::LJFMOpen::GetOutLogInstance()->Print(L"WARN: LJFMOpen fallback to loose res for %s\n", filename.c_str());
		if (core::Logger::GetInstance())
		{
			SDLOG_WARN(L"WARN: LJFMOpen fallback to loose res for %s", ws2s(filename).c_str());
		}
	}

	void LogLoosePreferredOnce(const std::wstring& filename)
	{
		LJFM::CMutex::CScoped lock(g_looseFallbackCacheMutex);
		if (g_loosePreferredLogOnce.find(filename) != g_loosePreferredLogOnce.end())
		{
			return;
		}
		g_loosePreferredLogOnce.insert(filename);
		LJFM::LJFMOpen::GetOutLogInstance()->Print(L"WARN: LJFMOpen prefer loose res for %s\n", filename.c_str());
		if (core::Logger::GetInstance())
		{
			SDLOG_WARN(L"WARN: LJFMOpen prefer loose res for %s", ws2s(filename).c_str());
		}
	}

	bool BuildPngPartFallbackName(const std::wstring& filename, std::wstring& fallbackName)
	{
		if (filename.size() <= kPngPartSuffix.size())
		{
			return false;
		}
		const size_t suffixPos = filename.size() - kPngPartSuffix.size();
		if (filename.compare(suffixPos, kPngPartSuffix.size(), kPngPartSuffix) != 0)
		{
			return false;
		}
		fallbackName = filename.substr(0, suffixPos) + kPngSuffix;
		return true;
	}
}

namespace LJFM
{
	namespace LJFMHLP
	{
		static class LJFMDOL : public COutLog
		{
		public:
			LJFMDOL() {}
			virtual ~LJFMDOL() {}
		public:
			virtual void VPrint(const wchar_t* info, va_list vl)
			{
#if (defined WIN32) && _DEBUG
				wchar_t wbuff[2048];
				_vsnwprintf(wbuff, 2048, info, vl);
				OutputDebugStringW(wbuff);
				OutputDebugStringW(L"\n");
#endif
			}
		} g_DummyOutLog;

		COutLog* g_OutLog = &g_DummyOutLog;

	}
}

int LJFM::LJFMOpen::m_nLastError = 0;
bool LJFM::LJFMOpen::m_bLoadFromPak = false;
bool LJFM::LJFMOpen::m_bVersionDonotCheck = false;

namespace LJFM
{

	bool g_bInitLJFP = false;
	LJFP_PackInfo* g_pPackInfo = NULL;

	int LJFMOpen::InitFileList()
	{
		ClearMissingFileCache();
		ClearLooseFallbackFileInfoCache();
		int iResult = 0;
		StartupBootstrapTraceLJFM(
			"InitFileList begin loadFromPak=%d versionDonotCheck=%d rootDir=%s runDir=%s",
			GetLoadFromPak() ? 1 : 0,
			GetVersionDonotCheck() ? 1 : 0,
			ws2s(MHSD_UTILS::GetRootDir()).c_str(),
			ws2s(MHSD_UTILS::GetRunDir()).c_str());
		if (GetLoadFromPak() == false)
		{
			StartupBootstrapTraceLJFM("InitFileList skip because loadFromPak=false");
			return iResult;
		}
#ifdef WIN7_32
		std::vector<std::wstring> rootResCandidates;
	#ifdef NoPack
		rootResCandidates.push_back(StringCover::to_wstring(CFileUtil::GetWin32LooseResourceRoot()) + L"/");
		rootResCandidates.push_back(JoinRootAndRelative(MHSD_UTILS::GetRootDir(), L"..\\..\\res\\"));
		rootResCandidates.push_back(JoinRootAndRelative(MHSD_UTILS::GetRootDir(), L"..\\..\\resource\\res\\"));
	#else
		// Windows Release：优先走发布目录 client/res_win/res（打包资源）。
		rootResCandidates.push_back(StringCover::to_wstring(CFileUtil::GetWin32PackedResourceRoot()) + L"/");
		rootResCandidates.push_back(JoinRootAndRelative(MHSD_UTILS::GetRootDir(), L"..\\..\\..\\res_win\\res\\"));
		rootResCandidates.push_back(JoinRootAndRelative(MHSD_UTILS::GetRootDir(), L"..\\..\\res_win\\res\\"));
		// 兼容历史目录。
		rootResCandidates.push_back(JoinRootAndRelative(MHSD_UTILS::GetRootDir(), L"..\\..\\res1\\"));
		rootResCandidates.push_back(JoinRootAndRelative(MHSD_UTILS::GetRootDir(), L"..\\..\\res\\"));
	#endif
		std::wstring FLFName = L"fl.ljpi";
		std::wstring RootResPathBase = rootResCandidates[0];
		bool foundPackRoot = false;
		for (size_t i = 0; i < rootResCandidates.size(); ++i)
		{
			std::wstring candidate = rootResCandidates[i];
			std::replace(candidate.begin(), candidate.end(), L'\\', L'/');
			StartupBootstrapTraceLJFM(
				"InitFileList candidate[%u]=%s exists=%d",
				(unsigned int)i,
				ws2s(candidate + FLFName).c_str(),
				MHSD_UTILS::ExistFile(candidate + FLFName) ? 1 : 0);
			if (MHSD_UTILS::ExistFile(candidate + FLFName))
			{
				RootResPathBase = candidate;
				foundPackRoot = true;
				break;
			}
		}
		if (!foundPackRoot)
		{
			std::replace(RootResPathBase.begin(), RootResPathBase.end(), L'\\', L'/');
		}
		StartupBootstrapTraceLJFM(
			"InitFileList selectedBase=%s foundPackRoot=%d",
			ws2s(RootResPathBase).c_str(),
			foundPackRoot ? 1 : 0);
#else
		std::wstring RootResPathBase = JoinRootAndRelative(MHSD_UTILS::GetRootDir(), L"res/");
		std::replace(RootResPathBase.begin(), RootResPathBase.end(), L'\\', L'/');
		std::wstring FLFName = L"fl.ljpi";
#endif
		LJFMOpen::GetOutLogInstance()->Print(L"WARN: LJFMOpen pack root = %s\n", RootResPathBase.c_str());
		if (core::Logger::GetInstance())
		{
			SDLOG_WARN(L"WARN: LJFMOpen pack root = %s", ws2s(RootResPathBase).c_str());
		}
//#ifdef WIN7_32
//		g_pPackInfo = LoadPackInfo(RootResPathBase + FLFName, 0, RootResPathBase);
//		if (g_pPackInfo != NULL)
//		{
//			g_bInitLJFP = true;
//			return 0;
//		}
//#endif
		if (GetVersionDonotCheck())
		{
			g_pPackInfo = LoadPackInfo(RootResPathBase + FLFName, 0, RootResPathBase);
			StartupBootstrapTraceLJFM(
				"InitFileList versionDonotCheck probe base=%s loadResult=%d",
				ws2s(RootResPathBase + FLFName).c_str(),
				g_pPackInfo ? 1 : 0);
			if (g_pPackInfo != NULL)
			{
				g_bInitLJFP = true;
				StartupBootstrapTraceLJFM("InitFileList success(versionDonotCheck)");
				return 0;
			}
		}

		std::wstring RootResPathUp = MHSD_UTILS::GetRunDir() + L"/";
		std::replace(RootResPathUp.begin(), RootResPathUp.end(), L'\\', L'/');

		LJFP_PackInfo* probeBase = LoadPackInfo(RootResPathBase + FLFName, 0, RootResPathBase);
		StartupBootstrapTraceLJFM(
			"InitFileList probe LoadPackInfo(base) path=%s result=%d",
			ws2s(RootResPathBase + FLFName).c_str(),
			probeBase ? 1 : 0);

		LJFP_PackInfo* probeUp = LoadPackInfo(RootResPathUp + FLFName, 1, RootResPathUp);
		StartupBootstrapTraceLJFM(
			"InitFileList probe LoadPackInfo(update) path=%s result=%d",
			ws2s(RootResPathUp + FLFName).c_str(),
			probeUp ? 1 : 0);
		bool ignoreBrokenUpdatePack = false;
		if (probeBase != NULL && probeUp != NULL)
		{
			unsigned int changedEntryCount = 0;
			unsigned int missingContainerCount = 0;
			std::wstring sampleMissingName;
			std::wstring sampleMissingSource;
			ignoreBrokenUpdatePack = !IsUpdateOverlayDataAvailable(
				probeBase,
				probeUp,
				changedEntryCount,
				missingContainerCount,
				sampleMissingName,
				sampleMissingSource);
			if (ignoreBrokenUpdatePack)
			{
				StartupBootstrapTraceLJFM(
					"InitFileList ignore broken update pack changedEntries=%u missingContainers=%u sampleName=%s sampleSource=%s",
					changedEntryCount,
					missingContainerCount,
					ws2s(sampleMissingName).c_str(),
					ws2s(sampleMissingSource).c_str());
			}
		}
		if (probeUp)
		{
			delete probeUp;
			probeUp = NULL;
		}
		if (probeBase)
		{
			delete probeBase;
			probeBase = NULL;
		}

		if (ignoreBrokenUpdatePack)
		{
			g_pPackInfo = LoadPackInfo(RootResPathBase + FLFName, 0, RootResPathBase);
			StartupBootstrapTraceLJFM(
				"InitFileList fallback base-only load path=%s result=%d",
				ws2s(RootResPathBase + FLFName).c_str(),
				g_pPackInfo ? 1 : 0);
			if (g_pPackInfo != NULL)
			{
				g_bInitLJFP = true;
				StartupBootstrapTraceLJFM("InitFileList success(base-only fallback)");
				return 0;
			}
			StartupBootstrapTraceLJFM("InitFileList fail: base-only fallback load failed");
			return -1;
		}

		bool bResult = MergerPackInfo(RootResPathBase + FLFName, 0, RootResPathBase, RootResPathUp + FLFName, 1, RootResPathUp, g_pPackInfo);
		StartupBootstrapTraceLJFM(
			"InitFileList merger result=%d g_pPackInfo=%d base=%s update=%s",
			bResult ? 1 : 0,
			g_pPackInfo ? 1 : 0,
			ws2s(RootResPathBase + FLFName).c_str(),
			ws2s(RootResPathUp + FLFName).c_str());
		if (!bResult)
		{
			StartupBootstrapTraceLJFM("InitFileList fail: merger returned false");
			return -1;
		}
		if (g_pPackInfo != NULL)
		{
			g_bInitLJFP = true;
			StartupBootstrapTraceLJFM("InitFileList success(merger)");
			return 0;
		}
		StartupBootstrapTraceLJFM("InitFileList fail: g_pPackInfo null after merger");
		return -1;
	}
	int LJFMOpen::UnInitFileList()
	{
		ClearMissingFileCache();
		ClearLooseFallbackFileInfoCache();
		if (g_pPackInfo)
		{
			delete g_pPackInfo;
		}
		return 0;
	}
	std::wstring TidyFileName(std::wstring strFileName)
	{
		std::wstring strResult;
		int iResult = 0;
		iResult = strFileName.find(L"/");
		if (iResult == 0)
		{
			strResult = strFileName.substr(1, strFileName.size());
		}
		iResult = strResult.find(L"mt3/");
		if (iResult == 0)
		{
			strResult = strResult.substr(4, strResult.size());
		}
		else
		{
			iResult = strResult.find(L"root/");
			if (iResult == 0)
			{
				strResult = strResult.substr(5, strResult.size());
			}
			else
			{
#ifdef NoPack
				if (TrimPrefixIfPresent(strResult, L"resource/res/") || TrimPrefixIfPresent(strResult, L"res/"))
#else
				if (TrimPrefixIfPresent(strResult, L"res_win/res/") || TrimPrefixIfPresent(strResult, L"res1/") || TrimPrefixIfPresent(strResult, L"res/"))
#endif
				{
					;
				}
			}
		}
		return strResult;
	}
	void* LJFMOpen::GetFileInfo(std::wstring wstrFileName)
	{
		wstrFileName = TidyFileName(wstrFileName);
		if (GetLoadFromPak() == true && g_pPackInfo)
		{
			if (IsLooseResPreferredCandidate(wstrFileName))
			{
				LJFP_FileInfo* preferredFI = GetOrCreateLooseFallbackFileInfo(wstrFileName);
				if (preferredFI)
				{
					LogLoosePreferredOnce(wstrFileName);
					return preferredFI;
				}
			}

			LJFP_FileInfo* pFI = g_pPackInfo->GetFileInfo(wstrFileName);
			if (!pFI)
			{
				pFI = GetOrCreateLooseFallbackFileInfo(wstrFileName);
				if (pFI)
				{
					LogLooseFallbackOnce(wstrFileName);
				}
			}
			return pFI;
		}
		else
		{
#ifdef WIN7_32
#ifdef FORCEGUIEDITOR
			char cwdBuf[512];
			memset(cwdBuf, 0, sizeof(cwdBuf));
			getcwd(cwdBuf, sizeof(cwdBuf));
			std::wstring path = s2ws(cwdBuf) + L'/';

			std::wstring RootResPath(path);
			std::wstring CacheResPath(path);
			if (wstrFileName.find(L"../res") == std::wstring::npos)
			{
				RootResPath += L"../res/";
				CacheResPath += L"../res/";
			}
			
#else
	#ifdef NoPack
			std::wstring RootResPath = StringCover::to_wstring(CFileUtil::GetWin32LooseResourceRoot()) + L"/";
			std::wstring CacheResPath = RootResPath;
	#else
			std::wstring RootResPath = StringCover::to_wstring(CFileUtil::GetWin32PackedResourceRoot()) + L"/";
			std::wstring CacheResPath = MHSD_UTILS::GetRunDir() + L"/";
	#endif
#endif //end of FORCEGUIEDITOR
			//size_t length = RootResPath.size();
			//wchar_t* buffer = new wchar_t[length + 1];
			//::PathCanonicalizeW(buffer, RootResPath.c_str());
			//RootResPath = buffer;
			//CacheResPath = RootResPath;
			//delete[] buffer;
#else
			std::wstring RootResPath = JoinRootAndRelative(MHSD_UTILS::GetRootDir(), L"res/");
			std::wstring CacheResPath = MHSD_UTILS::GetRunDir() + L"/";
#endif //end of WIN7_32
			if (MHSD_UTILS::ExistFile(CacheResPath + wstrFileName))
			{
				LJFP_FileInfo* FI = new LJFP_FileInfo();
				FI->m_RootPathName = CacheResPath;
				FI->m_PathFileName = wstrFileName;
				return FI;
			}
			else if (MHSD_UTILS::ExistFile(RootResPath + wstrFileName))
			{
				LJFP_FileInfo* FI = new LJFP_FileInfo();
				FI->m_RootPathName = RootResPath;
				FI->m_PathFileName = wstrFileName;
				return FI;
			}
			return NULL;
		}
	}
	std::wstring LJFMOpen::GetFullPathFileName(const std::wstring& filename)
	{
		// filenameNew将变为filename的全小写
		std::wstring filenameNew;
		if (!CheckDirFileStringFormatEx(filename, filenameNew))
		{
			_LJFM_ERROR((L"不合法的文件名格式!" + filename).c_str());
			return NULL;
		}
		LJFP_FileInfo* FI = NULL;
		FI = (LJFP_FileInfo*)GetFileInfo(filenameNew);
		if (!FI)
		{
			std::wstring fallbackName;
			if (BuildPngPartFallbackName(filenameNew, fallbackName))
			{
				FI = (LJFP_FileInfo*)GetFileInfo(fallbackName);
				if (FI)
				{
					filenameNew = fallbackName;
				}
			}
		}
		if (FI)
		{
			ForgetMissingFile(filenameNew);
			filenameNew = FI->GetFullPathFileName();
			if (GetLoadFromPak() == false)
			{
				delete FI;
			}
		}
		else
		{
			bool isFirstMissing = !IsKnownMissingFile(filenameNew);
			if (isFirstMissing)
			{
				RememberMissingFile(filenameNew);
			}
#ifdef WIN32
			if (isFirstMissing)
			{
				LJFMOpen::GetOutLogInstance()->Print(L"ERROR: LJFMOpen::GetFullPathFileName(name:%s))\n", filename.c_str());
				if (core::Logger::GetInstance())
				{
					SDLOG_ERR(L"ERROR: LJFMOpen::GetFullPathFileName(name:%s))\n", ws2s(filename).c_str());
				}
			}
#endif
			return L"";
		}
		return filenameNew;
	}
	LJFMBF* LJFMOpen::OpenFile(const std::wstring& filename, FILE_MODE fm, FILE_ACCESS fa)
	{
		// filenameNew将变为filename的全小写
		std::wstring filenameNew;
		if (!CheckDirFileStringFormatEx(filename, filenameNew))
		{
			_LJFM_ERROR((L"不合法的文件名格式!" + filename).c_str());
			return NULL;
		}
		LJFP_FileInfo* FI = NULL;
		FI = (LJFP_FileInfo*)GetFileInfo(filenameNew);
		if (!FI)
		{
			std::wstring fallbackName;
			if (BuildPngPartFallbackName(filenameNew, fallbackName))
			{
				FI = (LJFP_FileInfo*)GetFileInfo(fallbackName);
				if (FI)
				{
					filenameNew = fallbackName;
				}
			}
		}
		if (FI)
		{
			//filenameNew = FI->GetFullPathFileName();
			ForgetMissingFile(filenameNew);
		}
		else
		{
			bool isFirstMissing = !IsKnownMissingFile(filenameNew);
			if (isFirstMissing)
			{
				RememberMissingFile(filenameNew);
			}
#ifdef WIN32
			if (isFirstMissing)
			{
				LJFMOpen::GetOutLogInstance()->Print(L"ERROR: LJFMOpen::OpenFile(name:%s))\n", filename.c_str());
				if (core::Logger::GetInstance())
				{
					SDLOG_ERR(L"ERROR: LJFMOpen::OpenFile(name:%s))\n", ws2s(filename).c_str());
				}
			}
#endif
			return NULL;
		}
		bool bResult = false;
		if (FI->m_CompressType == 0 && FI->m_CodeType == 0)
		{
#ifdef ANDROID
			LJFMX::CLJFSZipFile* pLJFSZipFile = new LJFMX::CLJFSZipFile();
			bResult = pLJFSZipFile->Open(FI);
			if (GetLoadFromPak() == false)
			{
				delete FI;
			}
			if (bResult)
			{
				return pLJFSZipFile;
			}
#else
			LJFMX::CLJFSFile* pLJFSFile = new LJFMX::CLJFSFile();
			bResult = pLJFSFile->Open(FI);
			if (GetLoadFromPak() == false)
			{
				delete FI;
			}
			if (bResult)
			{
				return pLJFSFile;
			}
#endif
		}
		else
		{
			LJFMX::CLJFSZipFile* pLJFSZipFile = new LJFMX::CLJFSZipFile();
			bResult = pLJFSZipFile->Open(FI);
			if (GetLoadFromPak() == false)
			{
				delete FI;
			}
			if (bResult)
			{
				return pLJFSZipFile;
			}
		}
		return NULL;
	}
	bool LJFMOpen::CloseFile(LJFMBF* file)
	{
		if (file == NULL)
		{
			return false;
		}
		file->Delete();
		return true;
	}
	bool LJFMOpen::IsFileExisting(const std::wstring& filename)
	{
		std::wstring filenameNew;
		if (!CheckDirFileStringFormatEx(filename, filenameNew))
		{
			_LJFM_ERROR((L"不合法的文件名格式!" + filename).c_str());
			return false;
		}
		LJFP_FileInfo* FI = NULL;
		FI = (LJFP_FileInfo*)GetFileInfo(filenameNew);
		if (!FI)
		{
			std::wstring fallbackName;
			if (BuildPngPartFallbackName(filenameNew, fallbackName))
			{
				FI = (LJFP_FileInfo*)GetFileInfo(fallbackName);
				if (FI)
				{
					filenameNew = fallbackName;
				}
			}
		}
		if (FI)
		{
			ForgetMissingFile(filenameNew);
			if (GetLoadFromPak() == false)
			{
				delete FI;
			}
			return true;
		}
		// IsFileExisting 作为探测接口，不写入缺失缓存，避免瞬时 miss 被长期放大。
		return false;
	}
	int LJFMOpen::GetLastError()
	{
		return m_nLastError;
	}
	void LJFMOpen::SetLastError(int nErrorCode)
	{
		m_nLastError = nErrorCode;
	}
	void LJFMOpen::SetOutLogInstance(COutLog* log)
	{
		LJFMHLP::g_OutLog = log;
		if (NULL == LJFMHLP::g_OutLog)
		{
			LJFMHLP::g_OutLog = &LJFMHLP::g_DummyOutLog;
		}
	}
	COutLog* LJFMOpen::GetOutLogInstance()
	{
		return LJFMHLP::g_OutLog;
	}
}
