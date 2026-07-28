//  FileUtil.cpp
//  share

#include "FileUtil.h"
#include "StringUtil.h"
//#include <sys/param.h>
#include <algorithm>

#ifndef ISEDITOR
#include "cocos2d.h"

// MT3: Compatibility layer for Cocos2d-x 3.0-oh API changes
// 2.2.6 methods that don't exist in 3.0-oh FileUtils
namespace cocos2d {
    // getResDir() → returns the first search path as the resource root
    inline std::string CCFileUtils_getResDir(FileUtils* self) {
        const auto& paths = self->getSearchPaths();
        if (!paths.empty()) {
            return paths.front();
        }
        return "";
    }
    // getCachePath() → construct from writable path
    inline std::string CCFileUtils_getCachePath(FileUtils* self) {
        return self->getWritablePath() + "cache";
    }
    // getTempPath() → construct from writable path
    inline std::string CCFileUtils_getTempPath(FileUtils* self) {
        return self->getWritablePath() + "temp";
    }
}
#endif

#if (defined WIN7_32)
#include <windows.h>
#include <psapi.h>
#pragma comment(lib,"psapi.lib")
#endif

#if defined WIN7_32
namespace
{
	std::string NormalizeWin32Path(const std::string& path)
	{
		if (path.empty())
		{
			return path;
		}

		char fullPath[_MAX_PATH + 1] = { 0 };
		DWORD length = ::GetFullPathNameA(path.c_str(), _MAX_PATH, fullPath, NULL);
		std::string normalized;
		if (length > 0 && length <= _MAX_PATH)
		{
			normalized.assign(fullPath, length);
		}
		else
		{
			normalized = path;
		}

		std::replace(normalized.begin(), normalized.end(), '\\', '/');
		while (!normalized.empty() && normalized[normalized.size() - 1] == '/')
		{
			normalized.erase(normalized.size() - 1);
		}
		return normalized;
	}

	bool IsExistingWin32Directory(const std::string& path)
	{
		std::string normalized = NormalizeWin32Path(path);
		if (normalized.empty())
		{
			return false;
		}

		std::replace(normalized.begin(), normalized.end(), '/', '\\');
		DWORD attrs = ::GetFileAttributesA(normalized.c_str());
		return attrs != INVALID_FILE_ATTRIBUTES && (attrs & FILE_ATTRIBUTE_DIRECTORY) != 0;
	}

	std::string ResolveExistingWin32Directory(const char* fallbackRelative, const std::vector<std::string>& relativeCandidates)
	{
		for (std::vector<std::string>::const_iterator it = relativeCandidates.begin(); it != relativeCandidates.end(); ++it)
		{
			std::string candidate = NormalizeWin32Path(*it);
			if (IsExistingWin32Directory(candidate))
			{
				return candidate;
			}
		}

		return NormalizeWin32Path(fallbackRelative ? fallbackRelative : "");
	}
}
#endif


std::string CFileUtil::GetRootDir()
{
#ifdef ANDROID
    std::string ret = std::string(CCFileUtils_getResDir(cocos2d::CCFileUtils::sharedFileUtils()));
	CCLOG("[Res Path:]%s", ret);
    return ret;
#elif (defined WINAPI_FAMILY && WINAPI_FAMILY == WINAPI_FAMILY_PHONE_APP)
	std::wstring root(Windows::ApplicationModel::Package::Current->InstalledLocation->Path->Data());
	root += L"\\resource";
	return SHARE_Wstring2String(root);
#elif (defined ISEDITOR)
	return "";
#else
    std::string ret = cocos2d::CCFileUtils::sharedFileUtils()->fullPathForFilename("");
    ret = ret.substr(0, ret.rfind("/"));
    return ret;
#endif
}

std::string CFileUtil::GetWin32LooseResourceRoot()
{
#if defined WIN7_32
	std::vector<std::string> candidates;
	candidates.push_back("..\\..\\res");
	candidates.push_back("..\\..\\resource\\res");
	candidates.push_back("..\\resource\\res");
	return ResolveExistingWin32Directory("..\\..\\resource\\res", candidates);
#else
	return GetRootDir();
#endif
}

std::string CFileUtil::GetWin32PackedResourceRoot()
{
#if defined WIN7_32
	std::vector<std::string> candidates;
	candidates.push_back("..\\..\\..\\res_win\\res");
	candidates.push_back("..\\..\\res_win\\res");
	candidates.push_back("..\\res_win\\res");
	candidates.push_back("..\\..\\res1");
	candidates.push_back("..\\..\\res");
	candidates.push_back("..\\..\\resource\\res");
	return ResolveExistingWin32Directory("..\\..\\res_win\\res", candidates);
#else
	return GetRootDir();
#endif
}

std::string CFileUtil::GetDocDir()
{
#ifdef ANDROID
    std::string ret = std::string(CCFileUtils_getResDir(cocos2d::CCFileUtils::sharedFileUtils()));
    return ret;
#elif (defined WINAPI_FAMILY && WINAPI_FAMILY == WINAPI_FAMILY_PHONE_APP)
	std::wstring root(Windows::Storage::ApplicationData::Current->LocalFolder->Path->Data());
	return SHARE_Wstring2String(root);
#elif (defined ISEDITOR)
	return "";
#elif (defined WIN7_32)
	return GetRootDir();
#else
	std::string ret = std::string(cocos2d::CCFileUtils::sharedFileUtils()->getWritablePath());
	ret = ret.substr(0, ret.rfind("/"));
	return ret;
#endif
}

std::string CFileUtil::MakePath(const char* strPre, const char* strSub)
{
    std::string ret = strPre;
    if (ret.empty())
	{
#ifdef WIN7_32	//by lg
		return strSub;
#else
		return ret;
#endif
    }
    char* sub = (char*)strSub;
    if (strSub[0] == '/') {
        sub++;
    }
    
    if (ret[ret.length() - 1] == '/') {
        ret += sub;
    }else
    {
        ret = ret + '/' + sub;
    }
    
    return ret;
}

std::string CFileUtil::GetCacheDir()
{
#ifdef ANDROID
    std::string ret = std::string(CCFileUtils_getResDir(cocos2d::CCFileUtils::sharedFileUtils()))+"/cache";
    return ret;
#elif (defined WIN7_32) || (defined ISEDITOR)
	return GetRootDir() + "cache";
#else
    std::string ret = std::string(CCFileUtils_getCachePath(cocos2d::CCFileUtils::sharedFileUtils()));
    ret = ret.substr(0, ret.rfind("/"));
    return ret;
#endif
}

std::string CFileUtil::GetTempDir()
{
#ifdef ANDROID
	return std::string(CCFileUtils_getResDir(cocos2d::CCFileUtils::sharedFileUtils())) + "/temp";
#elif (defined WIN7_32)
	return GetRootDir() + "temp";
#else
    std::string ret = std::string(CCFileUtils_getTempPath(cocos2d::CCFileUtils::sharedFileUtils()));
    ret = ret.substr(0, ret.rfind("/"));
    return ret;
#endif
}

std::string CFileUtil::GetLogDir()
{
	return GetDocDir();
}

bool CFileUtil::IsCurLanguageSimpleCh()
{
	return true;
}

double CFileUtil::GetTotalMemory()
{
#if (defined WIN32)
	MEMORYSTATUSEX memstatus = { sizeof(memstatus) };
	::GlobalMemoryStatusEx(&memstatus);
	return memstatus.ullTotalPhys / 1024.0 / 1024.0;
#else
	return 0.0;
#endif
}

double CFileUtil::GetAvailableMemory()
{
#if (defined WIN32)
	MEMORYSTATUSEX memstatus = { sizeof(memstatus) };
	::GlobalMemoryStatusEx(&memstatus);
	return memstatus.ullAvailPhys / 1024.0 / 1024.0;
#else
	return 0.0;
#endif
}

double CFileUtil::GetUsedMemory()
{
#if (defined WIN32)
	HANDLE handle = GetCurrentProcess();
	PROCESS_MEMORY_COUNTERS pmc;
	::GetProcessMemoryInfo(handle, &pmc, sizeof(pmc));
	return pmc.PagefileUsage / 1024.0 / 1024.0;
#else
	return 0.0;
#endif
}

int CFileUtil::GetFileArrOfPath(std::wstring wsBasePath, std::wstring wsFileType, bool bLoop, std::vector<std::wstring>& FileArr)
{
	return 0;
}

int CFileUtil::DelFileArrOfPath(std::wstring wsBasePath, std::wstring wsFileType, bool bLoop)
{
	return 0;
}
