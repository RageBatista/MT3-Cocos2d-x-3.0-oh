#include "UpdateManagerEx.h"
#include "UpdateCommon.h"
#include "UpdateManagerEx_Helper.h"

#include "UpdateEngine.h"
#include "FileDownloader.h"

#include "../ljfm/code/include/ljfsfile.h"
#include "../ljfm/code/include/ljfszipfile.h"

#include "unistd.h"
#include <vector>

#include "../platform/utils/UpdateUtil.h"

const std::wstring g_VerFileName = L"ver.ljvi";
const std::wstring g_PackInfoFileName = L"fl.ljpi";
const std::wstring g_PackInfoZipFileName = L"fl.ljzip";
const std::wstring g_VerFileNameRoot = L"verroot.ljvi";

//const std::wstring g_JsonSite = L"http://59.151.73.76:50000/88/";
const std::wstring g_JsonSite = L"http://193.112.65.157:88/test/abcdefghijkl/88/";
const std::wstring g_JsonSiteLegacy = L"http://mt3.cn.serverlist.locojoy.com:50000/88/";

#if defined(MT3_RUNTIME_DIAG_ENABLE)
#define MT3_DIAG_UPDATE_LOG(...) LOGD(__VA_ARGS__)
#else
#define MT3_DIAG_UPDATE_LOG(...)
#endif

static std::wstring EnsureTrailingSlash(const std::wstring& site)
{
	if (site.empty())
	{
		return site;
	}
	if (site[site.length() - 1] == L'/')
	{
		return site;
	}
	return site + L"/";
}

static void AppendJsonSiteCandidate(std::vector<std::wstring>& candidates, const std::wstring& site)
{
	if (site.empty())
	{
		return;
	}
	std::wstring normalized = EnsureTrailingSlash(site);
	for (size_t i = 0; i < candidates.size(); ++i)
	{
		if (candidates[i] == normalized)
		{
			return;
		}
	}
	candidates.push_back(normalized);
}

static std::vector<std::wstring> BuildJsonSiteCandidates()
{
	std::vector<std::wstring> candidates;

	// 当前 122.152.* 配置入口在部分环境会长时间超时；先使用已验证的版本 JSON 入口。
	AppendJsonSiteCandidate(candidates, g_JsonSite);

	// 兼容旧方案读取本地配置（Java 侧从 2863654426 读取）
	std::wstring resourceUpdateUrl = getResourceUpdateUrl();
	if (!resourceUpdateUrl.empty())
	{
		std::wstring base = EnsureTrailingSlash(resourceUpdateUrl);
		AppendJsonSiteCandidate(candidates, base);
		AppendJsonSiteCandidate(candidates, base + L"test/abcdefghijkl/88/");
		AppendJsonSiteCandidate(candidates, base + L"88/");
	}

	// 兼容历史硬编码入口
	AppendJsonSiteCandidate(candidates, g_JsonSiteLegacy);
	return candidates;
}

static const char* UpdateStateName(int iState)
{
	switch (iState)
	{
	case 0: return "WaitFormResult";
	case 1: return "Init";
	case 2: return "LoadVersion";
	case 3: return "CheckVersion";
	case 4: return "LoadPackInfo";
	case 5: return "CheckPackInfo";
	case 6: return "DownloadPackInfo";
	case 7: return "UpdatePackInfo";
	default: return "Unknown";
	}
}

void UpdateManagerEx::SetDownloadSite(std::wstring DownloadSite, std::wstring AppSite, std::wstring WGSite)
{
	UpdateManagerEx::GetInstance()->m_DownloadSite = DownloadSite;
	UpdateManagerEx::GetInstance()->m_AppSite = AppSite;
	
	LOGD("SetDownloadSite wg=%s download=%s app=%s",
		ws2s(WGSite).c_str(),
		ws2s(DownloadSite).c_str(),
		ws2s(AppSite).c_str());
	UpdateEngine::g_WGAdressStr = WGSite;
	UpdateManagerEx::GetInstance()->m_DownloadSiteIsBack = 1;
}

std::wstring UpdateManagerEx::GetDownloadSite()
{
	return m_DownloadSite;
}

UpdateManagerEx::UpdateManagerEx()
{
	m_pVerRoot = NULL;
	m_pVerCache = NULL;
	m_pVerUpdate = NULL;

	m_pPIRoot = NULL;
	m_pPICache = NULL;
	m_pPIUpdate = NULL;

	m_pPIAdd = NULL;
	m_pPIMod = NULL;
	m_pPIDel = NULL;

    m_FormResult = 0;
}
UpdateManagerEx::~UpdateManagerEx()
{
	if (m_pVerRoot)
	{
		delete (LJFP_Version*)m_pVerRoot;
	}
	if (m_pVerCache)
	{
		delete (LJFP_Version*)m_pVerCache;
	}
	if (m_pVerUpdate)
	{
		delete (LJFP_Version*)m_pVerUpdate;
	}

	if (m_pPIRoot)
	{
		delete (LJFP_PackInfo*)m_pPIRoot;
	}
	if (m_pPICache)
	{
		delete (LJFP_PackInfo*)m_pPICache;
	}
	if (m_pPIUpdate)
	{
		delete (LJFP_PackInfo*)m_pPIUpdate;
	}

	if (m_pPIAdd)
	{
		delete (LJFP_PackInfo*)m_pPIAdd;
	}
	if (m_pPIMod)
	{
		delete (LJFP_PackInfo*)m_pPIMod;
	}
	if (m_pPIDel)
	{
		delete (LJFP_PackInfo*)m_pPIDel;
	}

	m_pVerRoot = NULL;
	m_pVerCache = NULL;
	m_pVerUpdate = NULL;

	m_pPIRoot = NULL;
	m_pPICache = NULL;
	m_pPIUpdate = NULL;

	m_pPIAdd = NULL;
	m_pPIMod = NULL;
	m_pPIDel = NULL;
}
int UpdateManagerEx::DelOldResFile()
{
#ifdef WIN7_32
	std::string clientIniName = "cfg/clientsetting_win.ini";
#elif defined ANDROID
	std::string clientIniName = "cfg/clientsetting_android.ini";
#else//IOS
	std::string clientIniName = "cfg/clientsetting_ios.ini";
#endif
	unsigned int FNCRC32 = LJCRC32Func(0, (unsigned char*)(clientIniName.c_str()), clientIniName.size() * sizeof(char));
	std::wstring clientIniNameWS = L"";
	clientIniNameWS = GetStringUtil().UI2WS(FNCRC32);
	UpdateUtil::DelFile(m_CacheResPath + clientIniNameWS);
	return 0;
}
int UpdateManagerEx::StepInit()
{
#ifdef WIN7_32
	m_SystemType = L"ios";
	m_NetworkType = L"lan";
#elif defined ANDROID
	m_SystemType = L"android";
	m_NetworkType = L"lan";
#else//IOS
	m_SystemType = L"ios";
	m_NetworkType = L"lan";
#endif

	StepInitPath();

	return 0;
}
int UpdateManagerEx::StepInitPath()
{
#ifdef WIN7_32
	m_RootPath = SHARE_String2Wstring(CFileUtil::GetRootDir() + "/");
	m_RootResPath = SHARE_String2Wstring(CFileUtil::GetRootDir() + "../../res/");
	m_CacheResPath = SHARE_String2Wstring(CFileUtil::GetRootDir() + "../../cacheres/");
	m_CacheUpdatePath = SHARE_String2Wstring(CFileUtil::GetRootDir() + "../../cacheupdate/");
#else
	m_RootPath = SHARE_String2Wstring(CFileUtil::GetRootDir() + "/");
	m_RootResPath = SHARE_String2Wstring(CFileUtil::GetRootDir() + "/res/");
	m_CacheResPath = SHARE_String2Wstring(CFileUtil::GetCacheDir() + "/res/");
	m_CacheUpdatePath = SHARE_String2Wstring(CFileUtil::GetCacheDir() + "/update/");
#endif
	UpdateUtil::CreateDir(m_RootResPath);
	UpdateUtil::CreateDir(m_CacheResPath);
	UpdateUtil::CreateDir(m_CacheUpdatePath);
#if defined ANDROID
	UpdateUtil::CreateDir(SHARE_String2Wstring(CFileUtil::GetTempDir() + "/"));
#endif

	return 0;
}
int UpdateManagerEx::StepLoadVersion()
{
	bool bResult = true;
	int iResult = 0;
	m_pVerRoot = new LJFP_Version();
	iResult = ((LJFP_Version*)m_pVerRoot)->LoadFromFile(m_RootResPath + g_VerFileName);
	if (iResult != 0){ return -1; }
	if (((LJFP_Version*)m_pVerRoot)->GetVersionDonotCheck() != 0)
	{
		UpdateUtil::DelFile(m_CacheResPath + g_VerFileName);
		UpdateUtil::CopyFile(m_RootResPath + g_VerFileName, m_CacheResPath + g_VerFileName);
		UpdateUtil::DelFile(m_CacheResPath + g_PackInfoFileName);
		UpdateUtil::CopyFile(m_RootResPath + g_PackInfoFileName, m_CacheResPath + g_PackInfoFileName);
		m_VersionOld = ((LJFP_Version*)m_pVerRoot)->GetVersion();
		m_VersionOldCaption = ((LJFP_Version*)m_pVerRoot)->GetVersionCaption();
		m_Version = m_VersionOld;
		m_VersionCaption = m_VersionOldCaption;
		m_VersionBase = ((LJFP_Version*)m_pVerRoot)->GetVersionBase();
		m_VersionBaseCaption = ((LJFP_Version*)m_pVerRoot)->GetVersionCaptionBase();
		//m_Channel = ((LJFP_Version*)m_pVerRoot)->GetChannel();
		//m_ChannelCaption = ((LJFP_Version*)m_pVerRoot)->GetChannelCaption();
		m_Channel = UpdateJson::GetChannelNameInt();
		m_ChannelCaption = UpdateJson::GetChannelNameWStr();
		((LJFP_Version*)m_pVerRoot)->CloneExtendMap(m_ExtendMap);
        m_ExtendMap[L"VersionDonotCheck"] = L"1";
		return 1;
	}
    //UpdateUtil::DelFile(m_CacheResPath + g_VerFileNameRoot);//Temp
    bResult = UpdateUtil::ExistFile(m_CacheResPath + g_VerFileNameRoot);
    if (!bResult)
    {
		UpdateUtil::DelFile(m_CacheResPath + g_VerFileName);
        UpdateUtil::CopyFileEx(m_RootResPath, L"", g_VerFileName, m_CacheResPath, L"", g_VerFileNameRoot);
		DelOldResFile();
    }
    else
    {
        LJFP_Version* pVersion = new LJFP_Version();
		iResult = pVersion->LoadFromFile(m_CacheResPath + g_VerFileNameRoot);
		if (iResult != 0)
		{
			UpdateUtil::DelFile(m_CacheResPath + g_VerFileNameRoot);
			return -1;
		}
        if (((LJFP_Version*)m_pVerRoot)->GetVersion() != pVersion->GetVersion())
        {
			UpdateUtil::DelFile(m_CacheResPath + g_VerFileName);
            UpdateUtil::CopyFileEx(m_RootResPath, L"", g_VerFileName, m_CacheResPath, L"", g_VerFileNameRoot);
			DelOldResFile();
        }
        delete pVersion;
    }
	//UpdateUtil::DelFile(m_CacheResPath + g_VerFileName);//Temp
	bResult = UpdateUtil::ExistFile(m_CacheResPath + g_VerFileName);
	if (!bResult)
	{
		UpdateUtil::CopyFile(m_RootResPath + g_VerFileName, m_CacheResPath + g_VerFileName);
        UpdateUtil::DelFile(m_CacheResPath + g_PackInfoFileName);
        UpdateUtil::CopyFile(m_RootResPath + g_PackInfoFileName, m_CacheResPath + g_PackInfoFileName);
	}
	m_pVerCache = new LJFP_Version();
	iResult = ((LJFP_Version*)m_pVerCache)->LoadFromFile(m_CacheResPath + g_VerFileName);
	if (iResult != 0){ return -1; }
	std::wstring LocalVersionCaption = ((LJFP_Version*)m_pVerCache)->GetVersionCaption();
	GlobalNotifyLocalVersion(LocalVersionCaption);
	m_VersionOld = ((LJFP_Version*)m_pVerCache)->GetVersion();
	m_VersionOldCaption = ((LJFP_Version*)m_pVerCache)->GetVersionCaption();
	
	//m_Channel = ((LJFP_Version*)m_pVerCache)->GetChannel();
	//m_ChannelCaption = ((LJFP_Version*)m_pVerCache)->GetChannelCaption();

	m_VersionBase = ((LJFP_Version*)m_pVerCache)->GetVersionBase();
	m_VersionBaseCaption = ((LJFP_Version*)m_pVerCache)->GetVersionCaptionBase();
	m_Channel = UpdateJson::GetChannelNameInt();
	m_ChannelCaption = UpdateJson::GetChannelNameWStr();

	cocos2d::extension::CCHttpClient* HTTPClient = cocos2d::extension::CCHttpClient::getInstance();
    UpdateJson::NewInstance()->SetCB_SetDownloadSite_Func(UpdateManagerEx::SetDownloadSite);

	std::vector<std::wstring> jsonSiteCandidates = BuildJsonSiteCandidates();
	LOGD("StepLoadVersion json sites count=%d versionBase=%s channel=%s",
		(int)jsonSiteCandidates.size(),
		ws2s(m_VersionBaseCaption).c_str(),
		ws2s(m_ChannelCaption).c_str());

	bool hasDownloadSite = false;
	for (size_t i = 0; i < jsonSiteCandidates.size(); ++i)
	{
		const std::wstring& curJsonSite = jsonSiteCandidates[i];
		m_DownloadSite = L"";
		m_AppSite = L"";
		m_DownloadSiteIsBack = 0;
		LOGD("StepLoadVersion RequestUpdateJson [%d/%d] site=%s",
			(int)(i + 1),
			(int)jsonSiteCandidates.size(),
			ws2s(curJsonSite).c_str());

		UpdateJson::NewInstance()->RequestUpdateJson(curJsonSite, m_VersionBaseCaption, m_ChannelCaption);
		while (m_DownloadSiteIsBack == 0)
		{
			HTTPClient->dispatchResponseCallbacks(0);
			usleep(1000);
		}

		LOGD("StepLoadVersion RequestUpdateJson done site=%s download=%s app=%s",
			ws2s(curJsonSite).c_str(),
			ws2s(m_DownloadSite).c_str(),
			ws2s(m_AppSite).c_str());
		if (m_DownloadSite.compare(L"") != 0)
		{
			hasDownloadSite = true;
			break;
		}
	}
	if (!hasDownloadSite)
	{
		LOGD("StepLoadVersion all json sites failed");
		return -1;
	}

	UpdateUtil::DelFile(m_CacheUpdatePath + g_VerFileName);
	URLInfoArr UIArr = ((LJFP_Version*)m_pVerCache)->GetURLInfoArr();
	std::wstring CacheVersionCaptionBase = ((LJFP_Version*)m_pVerCache)->GetVersionCaptionBase() + L"/";
	//bResult = UpdateUtil::DownloadFileEx(UIArr, m_SystemType, m_NetworkType, CacheVersionCaptionBase, g_VerFileName + UpdateUtil::GetRandomDownloadParam(), m_CacheUpdatePath, L"", g_VerFileName, false);
	bResult = UpdateUtil::DownloadFile(m_DownloadSite, CacheVersionCaptionBase, g_VerFileName + UpdateUtil::GetRandomDownloadParam(), m_CacheUpdatePath, L"", g_VerFileName, false);
	if (bResult != true){ return -1; }
	bResult = UpdateUtil::ExistFile(m_CacheUpdatePath + g_VerFileName);
	if (bResult != true){ return -1; }
	m_pVerUpdate = new LJFP_Version();
	iResult = ((LJFP_Version*)m_pVerUpdate)->LoadFromFile(m_CacheUpdatePath + g_VerFileName);
	if (iResult != 0){ return -1; }
	std::wstring NewVersion = ((LJFP_Version*)m_pVerUpdate)->GetVersionCaption();
	GlobalNotifyNewVersion(NewVersion);
	m_Version = ((LJFP_Version*)m_pVerUpdate)->GetVersion();
	m_VersionCaption = NewVersion;
	m_VersionBase = ((LJFP_Version*)m_pVerUpdate)->GetVersionBase();
	m_VersionBaseCaption = ((LJFP_Version*)m_pVerUpdate)->GetVersionCaptionBase();
	((LJFP_Version*)m_pVerUpdate)->CloneExtendMap(m_ExtendMap);
	m_ExtendMap[L"VersionDonotCheck"] = L"0";
	return 0;
}
int UpdateManagerEx::StepCheckVersion()
{
	if (((LJFP_Version*)m_pVerCache)->GetVersion() < ((LJFP_Version*)m_pVerUpdate)->GetVersion())//褰撳墠鐗堟湰灏忎簬鏈?鏂扮増鏈?
	{
		if (((LJFP_Version*)m_pVerCache)->GetVersion() < ((LJFP_Version*)m_pVerUpdate)->GetVersionMinimum())//褰撳墠鐗堟湰灏忎簬鏈?浣庨渶姹傜増鏈?涓嶈兘鏇存柊,閲嶆柊涓嬭浇
		{
			return -1;
		}
		else//褰撳墠鐗堟湰澶т簬绛変簬鏈?浣庨渶姹傜増鏈?闇?瑕佹洿鏂?
		{
			return 1;
		}
	}
	else//褰撳墠鐗堟湰灏辨槸鏈?鏂扮増鏈?
	{
		return 0;
	}
	return 0;
}
int UpdateManagerEx::StepLoadPackInfo()
{
	bool bResult = true;
	m_pPIRoot = LoadPackInfo(m_RootResPath + g_PackInfoFileName, 0, m_RootResPath);
	if (!m_pPIRoot){ return -1; }
	//UpdateUtil::DelFile(m_CacheResPath + g_PackInfoFileName);//Temp
	bResult = UpdateUtil::ExistFile(m_CacheResPath + g_PackInfoFileName);
	if (!bResult)
	{
		UpdateUtil::CopyFile(m_RootResPath + g_PackInfoFileName, m_CacheResPath + g_PackInfoFileName);
	}
	m_pPICache = LoadPackInfo(m_CacheResPath + g_PackInfoFileName, 1, m_CacheResPath);
	if (!m_pPICache){ return -1; }
	UpdateUtil::DelFile(m_CacheUpdatePath + g_PackInfoZipFileName);
	URLInfoArr UIArr = ((LJFP_Version*)m_pVerCache)->GetURLInfoArr();
	std::wstring NewVersionCaptionBase = ((LJFP_Version*)m_pVerUpdate)->GetVersionCaptionBase() + L"/";
	std::wstring NewVersionCaption = ((LJFP_Version*)m_pVerUpdate)->GetVersionCaption() + L"/";
	//bResult = UpdateUtil::DownloadFileEx(UIArr, m_SystemType, m_NetworkType, NewVersionCaptionBase + NewVersionCaption, g_PackInfoZipFileName, m_CacheUpdatePath, L"", g_PackInfoZipFileName, false);
	bResult = UpdateUtil::DownloadFile(m_DownloadSite, NewVersionCaptionBase + NewVersionCaption, g_PackInfoZipFileName, m_CacheUpdatePath, L"", g_PackInfoZipFileName, false);
	if (bResult != true){ return -1; }
	bResult = UpdateUtil::ExistFile(m_CacheUpdatePath + g_PackInfoZipFileName);
	if (bResult != true){ return -1; }
	UpdateUtil::DelFile(m_CacheUpdatePath + g_PackInfoFileName);
	LJFP_ZipFile ZF(9999, LJCRC32Func, LJZipFunc, LJUnZipFunc, LJSMS4Func, LJDeSMS4Func, "locojoy123456789");
	int iResult = ZF.UnZipFile(m_CacheUpdatePath + g_PackInfoZipFileName, m_CacheUpdatePath + g_PackInfoFileName);
	if (iResult != 0){ return -1; }
	bResult = UpdateUtil::ExistFile(m_CacheUpdatePath + g_PackInfoFileName);
	if (bResult != true){ return -1; }
	m_pPIUpdate = LoadPackInfo(m_CacheUpdatePath + g_PackInfoFileName, 1, m_CacheUpdatePath);
	if (!m_pPIUpdate){ return -1; }
	return 0;
}
int UpdateManagerEx::StepCheckPackInfo()
{
	int iResult = ParsePackInfo((LJFP_PackInfo*)m_pPICache, (LJFP_PackInfo*)m_pPIUpdate, (LJFP_PackInfo*&)m_pPIAdd, (LJFP_PackInfo*&)m_pPIMod, (LJFP_PackInfo*&)m_pPIDel);
	if (iResult != 0)
	{
		MT3_DIAG_UPDATE_LOG("MT3_DIAG_UPDATE event=parse_packinfo result=%d", iResult);
		return -1;
	}
	MT3_DIAG_UPDATE_LOG("MT3_DIAG_UPDATE event=parse_packinfo result=0 add=%u mod=%u del=%u",
		((LJFP_PackInfo*)m_pPIAdd)->GetFileCount(),
		((LJFP_PackInfo*)m_pPIMod)->GetFileCount(),
		((LJFP_PackInfo*)m_pPIDel)->GetFileCount());
	return 0;
}
int UpdateManagerEx::StepDownloadPackInfo()
{
	bool bResult = true;
	URLInfoArr UIArr = ((LJFP_Version*)m_pVerCache)->GetURLInfoArr();
    unsigned int FileCountAdd = ((LJFP_PackInfo*)m_pPIAdd)->GetFileCount();
    unsigned int FileCountMod = ((LJFP_PackInfo*)m_pPIMod)->GetFileCount();
    unsigned int FileCount = FileCountAdd + FileCountMod;
	MT3_DIAG_UPDATE_LOG("MT3_DIAG_UPDATE event=download_packinfo_begin add=%u mod=%u total=%u",
		FileCountAdd,
		FileCountMod,
		FileCount);
	std::wstring NewVersionCaptionBase = ((LJFP_Version*)m_pVerUpdate)->GetVersionCaptionBase() + L"/";
	std::wstring NewVersionCaption = ((LJFP_Version*)m_pVerUpdate)->GetVersionCaption() + L"/";
	for (unsigned int i = 0; i < ((LJFP_PackInfo*)m_pPIAdd)->GetFileCount(); i++)
	{
		std::wstring CurPathFileNameFull = ((LJFP_PackInfo*)m_pPIAdd)->GetFileInfo(i)->m_PathFileName;
		std::wstring CurPathName = UpdateUtil::GetFilePath(CurPathFileNameFull, L"");
		std::wstring CurFileNameFull = UpdateUtil::GetFileNameFull(CurPathFileNameFull);
		unsigned int CurSize = ((LJFP_PackInfo*)m_pPIAdd)->GetFileInfo(i)->m_Size;
		unsigned int CurCRC32 = ((LJFP_PackInfo*)m_pPIAdd)->GetFileInfo(i)->m_CRC32;
		bool bCacheOK = UpdateUtil::ExistFileEx(m_CacheUpdatePath + CurPathName + CurFileNameFull, CurSize, CurCRC32);
		MT3_DIAG_UPDATE_LOG("MT3_DIAG_UPDATE event=file_check kind=add index=%u size=%u crc=%u cacheHit=%d",
			i,
			CurSize,
			CurCRC32,
			bCacheOK ? 1 : 0);
		if (!bCacheOK)//濡傛灉鏈湴鏂囦欢涓嶅瓨鍦ㄦ垨鑰呭瓨鍦ㄤ絾鏍￠獙涓嶉?氳繃鎵嶄笅杞?
		{
			bool bDownloadOK = false;
			for (unsigned int i2 = 0; i2 < 3; i2++)
			{
				MT3_DIAG_UPDATE_LOG("MT3_DIAG_UPDATE event=file_attempt kind=add index=%u attempt=%u size=%u",
					i,
					i2 + 1,
					CurSize);
				//bResult = UpdateUtil::DownloadFileEx(UIArr, m_SystemType, m_NetworkType, 
				//	NewVersionCaptionBase + NewVersionCaption + CurPathName, CurFileNameFull,
				//	m_CacheUpdatePath, CurPathName, CurFileNameFull, true);
				bResult = UpdateUtil::DownloadFile(m_DownloadSite, NewVersionCaptionBase + NewVersionCaption + CurPathName, CurFileNameFull,
					m_CacheUpdatePath, CurPathName, CurFileNameFull, true);
				MT3_DIAG_UPDATE_LOG("MT3_DIAG_UPDATE event=file_attempt_download kind=add index=%u attempt=%u result=%d",
					i,
					i2 + 1,
					bResult ? 1 : 0);
				if (bResult != true){ continue; }
				bResult = UpdateUtil::ExistFileEx(m_CacheUpdatePath + CurPathName + CurFileNameFull, CurSize, CurCRC32);
				MT3_DIAG_UPDATE_LOG("MT3_DIAG_UPDATE event=file_attempt_verify kind=add index=%u attempt=%u result=%d",
					i,
					i2 + 1,
					bResult ? 1 : 0);
				if (bResult != true){ continue; }
				bDownloadOK = true;
				break;
			}
			if (bDownloadOK != true)
			{
				MT3_DIAG_UPDATE_LOG("MT3_DIAG_UPDATE event=file_failed kind=add index=%u size=%u crc=%u", i, CurSize, CurCRC32);
				return -1;
			}
		}
        GlobalNotifyStep(((i + 1) * 1.0 / FileCount) * 80);
	}
	for (unsigned int i = 0; i < ((LJFP_PackInfo*)m_pPIMod)->GetFileCount(); i++)
	{
		std::wstring CurPathFileNameFull = ((LJFP_PackInfo*)m_pPIMod)->GetFileInfo(i)->m_PathFileName;
		std::wstring CurPathName = UpdateUtil::GetFilePath(CurPathFileNameFull, L"");
		std::wstring CurFileNameFull = UpdateUtil::GetFileNameFull(CurPathFileNameFull);
		unsigned int CurSize = ((LJFP_PackInfo*)m_pPIMod)->GetFileInfo(i)->m_Size;
		unsigned int CurCRC32 = ((LJFP_PackInfo*)m_pPIMod)->GetFileInfo(i)->m_CRC32;
		bool bCacheOK = UpdateUtil::ExistFileEx(m_CacheUpdatePath + CurPathName + CurFileNameFull, CurSize, CurCRC32);
		MT3_DIAG_UPDATE_LOG("MT3_DIAG_UPDATE event=file_check kind=mod index=%u size=%u crc=%u cacheHit=%d",
			i,
			CurSize,
			CurCRC32,
			bCacheOK ? 1 : 0);
		if (!bCacheOK)//濡傛灉鏈湴鏂囦欢涓嶅瓨鍦ㄦ垨鑰呭瓨鍦ㄤ絾鏍￠獙涓嶉?氳繃鎵嶄笅杞?
		{
			bool bDownloadOK = false;
			for (unsigned int i2 = 0; i2 < 3; i2++)
			{
				MT3_DIAG_UPDATE_LOG("MT3_DIAG_UPDATE event=file_attempt kind=mod index=%u attempt=%u size=%u",
					i,
					i2 + 1,
					CurSize);
				//bResult = UpdateUtil::DownloadFileEx(UIArr, m_SystemType, m_NetworkType, 
				//	NewVersionCaptionBase + NewVersionCaption + CurPathName, CurFileNameFull,
				//	m_CacheUpdatePath, CurPathName, CurFileNameFull, true);
				bResult = UpdateUtil::DownloadFile(m_DownloadSite, NewVersionCaptionBase + NewVersionCaption + CurPathName, CurFileNameFull,
					m_CacheUpdatePath, CurPathName, CurFileNameFull, true);
				MT3_DIAG_UPDATE_LOG("MT3_DIAG_UPDATE event=file_attempt_download kind=mod index=%u attempt=%u result=%d",
					i,
					i2 + 1,
					bResult ? 1 : 0);
				if (bResult != true){ continue; }
				bResult = UpdateUtil::ExistFileEx(m_CacheUpdatePath + CurPathName + CurFileNameFull, CurSize, CurCRC32);
				MT3_DIAG_UPDATE_LOG("MT3_DIAG_UPDATE event=file_attempt_verify kind=mod index=%u attempt=%u result=%d",
					i,
					i2 + 1,
					bResult ? 1 : 0);
				if (bResult != true){ continue; }
				bDownloadOK = true;
				break;
			}
			if (bDownloadOK != true)
			{
				MT3_DIAG_UPDATE_LOG("MT3_DIAG_UPDATE event=file_failed kind=mod index=%u size=%u crc=%u", i, CurSize, CurCRC32);
				return -1;
			}
		}
        GlobalNotifyStep(((i + 1 + FileCountAdd) * 1.0 / FileCount) * 80);
	}
    GlobalNotifyStep(80);
	return 0;
}
int UpdateManagerEx::StepUpdatePackInfo()
{
	int iResult = 0;
    unsigned int FileCountAdd = ((LJFP_PackInfo*)m_pPIAdd)->GetFileCount();
    unsigned int FileCountMod = ((LJFP_PackInfo*)m_pPIMod)->GetFileCount();
    unsigned int FileCount = FileCountAdd + FileCountMod;
	for (unsigned int i = 0; i < ((LJFP_PackInfo*)m_pPIAdd)->GetFileCount(); i++)
	{
		std::wstring CurPathFileNameFull = ((LJFP_PackInfo*)m_pPIAdd)->GetFileInfo(i)->m_PathFileName;
		std::wstring CurPathName = UpdateUtil::GetFilePath(CurPathFileNameFull, L"");
		std::wstring CurFileNameFull = UpdateUtil::GetFileNameFull(CurPathFileNameFull);
		iResult = UpdateUtil::CopyFileEx(m_CacheUpdatePath, CurPathName, CurFileNameFull, m_CacheResPath, CurPathName, CurFileNameFull);
		if (iResult != 0){ return -1; }
        GlobalNotifyStep(80 + ((i + 1) * 1.0 / FileCount) * 10);
	}
	for (unsigned int i = 0; i < ((LJFP_PackInfo*)m_pPIMod)->GetFileCount(); i++)
	{
		std::wstring CurPathFileNameFull = ((LJFP_PackInfo*)m_pPIMod)->GetFileInfo(i)->m_PathFileName;
		std::wstring CurPathName = UpdateUtil::GetFilePath(CurPathFileNameFull, L"");
		std::wstring CurFileNameFull = UpdateUtil::GetFileNameFull(CurPathFileNameFull);
		iResult = UpdateUtil::CopyFileEx(m_CacheUpdatePath, CurPathName, CurFileNameFull, m_CacheResPath, CurPathName, CurFileNameFull);
		if (iResult != 0){ return -2; }
        GlobalNotifyStep(80 + ((i + 1 + FileCountAdd) * 1.0 / FileCount) * 10);
	}
	iResult = UpdateUtil::CopyFileEx(m_CacheUpdatePath, L"", g_PackInfoFileName, m_CacheResPath, L"", g_PackInfoFileName);
	if (iResult != 0){ return -3; }
	iResult = UpdateUtil::CopyFileEx(m_CacheUpdatePath, L"", g_VerFileName, m_CacheResPath, L"", g_VerFileName);
	if (iResult != 0){ return -4; }
    GlobalNotifyStep(90);
	return 0;
}
int UpdateManagerEx::StepClearPackInfo()
{
	bool bResult = true;
	for (unsigned int i = 0; i < ((LJFP_PackInfo*)m_pPIAdd)->GetFileCount(); i++)
	{
		std::wstring CurPathFileNameFull = ((LJFP_PackInfo*)m_pPIAdd)->GetFileInfo(i)->m_PathFileName;
		std::wstring CurPathName = UpdateUtil::GetFilePath(CurPathFileNameFull, L"");
		std::wstring CurFileNameFull = UpdateUtil::GetFileNameFull(CurPathFileNameFull);
		bResult = UpdateUtil::DelFile(m_CacheUpdatePath + CurPathName + CurFileNameFull);
	}
    GlobalNotifyStep(93);
	for (unsigned int i = 0; i < ((LJFP_PackInfo*)m_pPIMod)->GetFileCount(); i++)
	{
		std::wstring CurPathFileNameFull = ((LJFP_PackInfo*)m_pPIMod)->GetFileInfo(i)->m_PathFileName;
		std::wstring CurPathName = UpdateUtil::GetFilePath(CurPathFileNameFull, L"");
		std::wstring CurFileNameFull = UpdateUtil::GetFileNameFull(CurPathFileNameFull);
		bResult = UpdateUtil::DelFile(m_CacheUpdatePath + CurPathName + CurFileNameFull);
	}
    GlobalNotifyStep(96);
	for (unsigned int i = 0; i < ((LJFP_PackInfo*)m_pPIDel)->GetFileCount(); i++)
	{
		std::wstring CurPathFileNameFull = ((LJFP_PackInfo*)m_pPIDel)->GetFileInfo(i)->m_PathFileName;
		std::wstring CurPathName = UpdateUtil::GetFilePath(CurPathFileNameFull, L"");
		std::wstring CurFileNameFull = UpdateUtil::GetFileNameFull(CurPathFileNameFull);
		bResult = UpdateUtil::DelFile(m_CacheResPath + CurPathName + CurFileNameFull);
	}
    GlobalNotifyStep(99);
	bResult = UpdateUtil::DelFile(m_CacheUpdatePath + g_PackInfoFileName);
	bResult = UpdateUtil::DelFile(m_CacheUpdatePath + g_VerFileName);
	if (bResult != true){ return -1; }
    GlobalNotifyStep(100);
	return 0;
}
bool UpdateManagerEx::Run()
{
#ifdef WIN7_32
	return true;
#endif
    int iState = 1;
    int iResult = 0;
	LOGD("Run enter");
    
    while (iState >= 0)
    {
		LOGD("Run loop state=%d(%s) formResult=%d", iState, UpdateStateName(iState), m_FormResult);
        if (iState == 0)
        {
            if (m_FormResult < 0)
            {
				LOGD("Run got negative form result=%d, call ExitApp", m_FormResult);
				UpdateJson::ExitApp();
                return false;
            }
            else
            {
                iState = m_FormResult;
				LOGD("Run continue with form result, next state=%d(%s)", iState, UpdateStateName(iState));
            }
        }
        else if (iState == 1)
        {
            GlobalNotifyMsg(L"");
            GlobalNotifyStep(0);
            GlobalNotifyMsgByKey(L"upmgrstr11");//姝ｅ湪杩炴帴鏈嶅姟鍣?..
            iResult = StepInit();
			LOGD("Run StepInit result=%d", iResult);
            if (iResult != 0){ return false; }
            iState = 2;
        }
        else if (iState == 2)
        {
            iResult = StepLoadVersion();
			LOGD("Run StepLoadVersion result=%d", iResult);
            if (iResult > 0)
            {
                GlobalNotifyMsgByKey(L"upmgrstr21");//鏇存柊瀹屾垚
                GlobalNotifyStep(100);
                return true;
            }
            else if (iResult == 0)
            {
                iState = 3;
            }
            else if (iResult < 0)
            {
                m_FormResult = 0;
                iState = 0;
				LOGD("Run StepLoadVersion failed, show form type=1");
                GlobalNotifyShowForm(1, 0, L"");
            }
        }
        else if (iState == 3)
        {
            GlobalNotifyMsgByKey(L"upmgrstr31");//鐗堟湰妫?娴嬩腑...
            iResult = StepCheckVersion();
			LOGD("Run StepCheckVersion result=%d", iResult);
            if (iResult == 0)
            {
                GlobalNotifyMsgByKey(L"upmgrstr32");//鏇存柊瀹屾垚
                GlobalNotifyStep(100);
                return true;
            }
            else if (iResult > 0)
            {
                iState = 4;
            }
            else if (iResult < 0)
            {
                m_FormResult = 0;
                iState = 0;
                //std::wstring AppURL = ((LJFP_Version*)m_pVerUpdate)->GetAppURL();
				std::wstring AppURL = m_AppSite;
				LOGD("Run StepCheckVersion requires app update, show form type=2 url=%s", ws2s(AppURL).c_str());
                GlobalNotifyShowForm(2, 0, AppURL);
            }
        }
        else if (iState == 4)
        {
            iResult = StepLoadPackInfo();
			LOGD("Run StepLoadPackInfo result=%d", iResult);
            if (iResult == 0)
            {
                iState = 5;
            }
            else if (iResult < 0)
            {
                m_FormResult = 0;
                iState = 0;
				LOGD("Run StepLoadPackInfo failed, show form type=3");
                GlobalNotifyShowForm(3, 0, L"");
            }
        }
        else if (iState == 5)
        {
            iResult = StepCheckPackInfo();
			LOGD("Run StepCheckPackInfo result=%d", iResult);
            if (iResult == 0)
            {
                int iDownloadSize = 0;
                
                for (unsigned int i = 0; i < ((LJFP_PackInfo*)m_pPIAdd)->GetFileCount(); i++)
                {
					iDownloadSize = iDownloadSize + ((LJFP_PackInfo*)m_pPIAdd)->GetFileInfo(i)->m_Size;
                }
                for (unsigned int i = 0; i < ((LJFP_PackInfo*)m_pPIMod)->GetFileCount(); i++)
                {
					iDownloadSize = iDownloadSize + ((LJFP_PackInfo*)m_pPIMod)->GetFileInfo(i)->m_Size;
                }
                m_FormResult = 0;
                iState = 0;
                iDownloadSize = iDownloadSize / 1024;
                //iDownloadSize = iDownloadSize / 1024;
				LOGD("Run StepCheckPackInfo needs download, show form type=4 sizeKB=%d", iDownloadSize);
                GlobalNotifyShowForm(4, iDownloadSize, L"");
            }
            else if (iResult < 0)
            {
				LOGD("Run StepCheckPackInfo failed");
                return false;
            }
        }
        else if (iState == 6)
        {
            GlobalNotifyMsgByKey(L"upmgrstr61");//鑷姩鏇存柊涓?..
            iResult = StepDownloadPackInfo();
			LOGD("Run StepDownloadPackInfo result=%d", iResult);
            if (iResult == 0)
            {
                iState = 7;
                GlobalNotifyStep(80);
            }
            else if (iResult < 0)
            {
                m_FormResult = 0;
                iState = 0;
				LOGD("Run StepDownloadPackInfo failed, show form type=5");
                GlobalNotifyShowForm(5, 0, L"");
            }
        }
        else if (iState == 7)
        {
            iResult = StepUpdatePackInfo(); GlobalNotifyStep(90);
			LOGD("Run StepUpdatePackInfo result=%d", iResult);
            if (iResult != 0){ return false; }
            iResult = StepClearPackInfo(); GlobalNotifyStep(100);
			LOGD("Run StepClearPackInfo result=%d", iResult);
            //if (iResult != 0){ return false; }//涓嶇鏄棫璧勬簮鍚﹀叏閮ㄥ垹闄ゆ垚鍔?鍙鏂板鍜屼慨鏀圭殑鏂囦欢閮芥嫹璐濆畬鎴愬氨绠楁洿鏂版垚鍔?
            GlobalNotifyMsgByKey(L"upmgrstr71");//鏇存柊瀹屾垚
            return true;
        }
#if (defined WIN7_32) || (defined WINAPI_FAMILY && WINAPI_FAMILY == WINAPI_FAMILY_PHONE_APP)
        //std::this_thread::sleep_for(std::chrono::seconds(100));
#else
        //sleep(100);
#endif
    }
	return true;
}
int UpdateManagerEx::StepLoadVersionNoPack()
{
	int iResult = 0;
	m_pVerRoot = new LJFP_Version();
	iResult = ((LJFP_Version*)m_pVerRoot)->LoadFromFile(m_RootResPath + g_VerFileName);
	if (iResult != 0){ return -1; }
	UpdateUtil::DelFile(m_CacheResPath + g_VerFileName);
	UpdateUtil::CopyFile(m_RootResPath + g_VerFileName, m_CacheResPath + g_VerFileName);
	UpdateUtil::DelFile(m_CacheResPath + g_PackInfoFileName);
	UpdateUtil::CopyFile(m_RootResPath + g_PackInfoFileName, m_CacheResPath + g_PackInfoFileName);
	m_VersionOld = ((LJFP_Version*)m_pVerRoot)->GetVersion();
	m_VersionOldCaption = ((LJFP_Version*)m_pVerRoot)->GetVersionCaption();
	m_Version = m_VersionOld;
	m_VersionCaption = m_VersionOldCaption;
	m_VersionBase = ((LJFP_Version*)m_pVerRoot)->GetVersionBase();
	m_VersionBaseCaption = ((LJFP_Version*)m_pVerRoot)->GetVersionCaptionBase();
	m_Channel = ((LJFP_Version*)m_pVerRoot)->GetChannel();
	m_ChannelCaption = ((LJFP_Version*)m_pVerRoot)->GetChannelCaption();
	((LJFP_Version*)m_pVerRoot)->CloneExtendMap(m_ExtendMap);
	m_ExtendMap[L"VersionDonotCheck"] = L"1";
	return 0;
}
bool UpdateManagerEx::RunNoPack()
{
	int iResult = 0;
	iResult = StepInit();
	LOGD("RunNoPack StepInit result=%d", iResult);
	if (iResult != 0){ return false; }
	iResult = StepLoadVersionNoPack();
	LOGD("RunNoPack StepLoadVersionNoPack result=%d", iResult);
	if (iResult != 0){ return false; }
	return true;
}
void UpdateManagerEx::Continue(int iResult)
{
	LOGD("Continue set form result=%d", iResult);
    m_FormResult = iResult;
}
void UpdateManagerEx::CloneExtendMap(std::map<std::wstring, std::wstring>& ExtendMap)
{
	ExtendMap.clear();
	std::map<std::wstring, std::wstring>::iterator it = m_ExtendMap.begin();
	while (it != m_ExtendMap.end())
	{
		ExtendMap[it->first] = it->second;
		it++;
	}
}
