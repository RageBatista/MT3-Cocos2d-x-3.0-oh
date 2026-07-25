#include "stdafx.h"
#include "LoginManager.h"
#include "../ProtoDef/fire/pb/CRoleList.hpp"
#include "../ProtoDef/fire/pb/CEnterWorld.hpp"
#include "GameStateManager.h"
#include "GameUIManager.h"
#include "GameTable/message/CMessageTip.h"
#include "GameApplication.h"
#include "UISprite.h"
#include <engine/nucocos2d_wraper.h>
#include "SimpleAudioEngine.h"
#include "IniManager.h"
#include "ConfigManager.h"
#include "CCDirector.h"
#include "MessageManager.h"
#include "ConnectGetServerInfo.h"
#include "SystemInfo.h"
#include "MainRoleDataManager.h"
#include "utils/StringCover.h"
#include <cstdlib>
#include <cstring>
#include <stdarg.h>
#include <stdio.h>

#if defined(WIN32) && (defined(_DEBUG) || defined(DEBUG))
static void MT3LoginTraceToFile(const char* fmt, ...)
{
	FILE* fp = NULL;
	if (fopen_s(&fp, "startup_bootstrap.log", "ab") != 0 || !fp)
	{
		return;
	}
	fputs("[MT3_LOGIN] ", fp);
	va_list args;
	va_start(args, fmt);
	vfprintf(fp, fmt, args);
	va_end(args);
	fputs("\r\n", fp);
	fclose(fp);
}
#define MT3_LOGIN_TRACE(...) MT3LoginTraceToFile(__VA_ARGS__)
#else
#define MT3_LOGIN_TRACE(...)
#endif

#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32
#include "WinWebBrowser/WinSDK.h"
#endif

#include <spine/Json.h>

#include "CallLuaUtil.h"


#ifdef _LOCOJOY_SDK_
#include "GameSdk.h"
#include "ChannelManager.h"
#endif

#ifdef _YJ_SDK_
#include "ChannelManager.h"
#endif

#ifdef ANDROID
#include "../../androidcommon/ChannelPlatformUtil.h"
#include "../../common/platform/android/SDJniHelper.h"
#include <jni.h>
#endif

#ifdef ANDROID
#include <android/log.h>
#define  LOG_TAG    "mt3"
#define  LOGI(...)  __android_log_print(ANDROID_LOG_INFO,LOG_TAG,__VA_ARGS__)
#define  LOGE(...)  __android_log_print(ANDROID_LOG_ERROR,LOG_TAG,__VA_ARGS__)
#define  LOGD(...)  __android_log_print(ANDROID_LOG_DEBUG,LOG_TAG,__VA_ARGS__)
#else
#define LOGI(...)
#define LOGE(...)
#define LOGD(...)
#endif

#ifdef ANDROID
static bool TrySelectFirstAndroidServer(LoginManager* manager)
{
	if (manager == NULL)
	{
		return false;
	}

	std::vector<stServerINFO>& servers = GetServerInfo()->getAllServers();
	LOGE("[SelectServerDiag] TrySelectFirstAndroidServer inspect serverCount=%d", static_cast<int>(servers.size()));
	for (std::vector<stServerINFO>::size_type i = 0; i < servers.size(); ++i)
	{
		const stServerINFO& info = servers[i];
		LOGE("[SelectServerDiag] fallback candidate index=%d idLen=%d areaLen=%d nameLen=%d ipLen=%d portLen=%d stateLen=%d flagLen=%d",
			static_cast<int>(i),
			static_cast<int>(info.serverid.length()),
			static_cast<int>(info.serverArea.length()),
			static_cast<int>(info.serverName.length()),
			static_cast<int>(info.serverIp.length()),
			static_cast<int>(info.serverPort.length()),
			static_cast<int>(info.serverState.length()),
			static_cast<int>(info.serverFlag.length()));
		if (info.serverArea.empty() || info.serverName.empty() || info.serverIp.empty() || info.serverPort.empty())
		{
			continue;
		}

		manager->SetSelectServerInfo(info.serverArea, info.serverName, info.serverIp, info.serverPort, 0);
		LOGE("[LoginFlow] ToServerChoose fallback selected index=%d areaLen=%d serverLen=%d hostLen=%d port=%s",
			static_cast<int>(i),
			static_cast<int>(info.serverArea.length()),
			static_cast<int>(info.serverName.length()),
			static_cast<int>(info.serverIp.length()),
			ws2s(info.serverPort).c_str());
		return true;
	}

	LOGE("[LoginFlow] ToServerChoose fallback failed: no valid server in serverCount=%d", static_cast<int>(servers.size()));
	return false;
}

static void DestroyAndroidSelectServersDialogIfLoaded()
{
	cocos2d::CCScriptEngineProtocol* pScriptEngine = cocos2d::CCScriptEngineManager::sharedManager()->getScriptEngine();
	if (pScriptEngine == NULL)
	{
		return;
	}

	LOGE("[SelectServerDiag] DestroyAndroidSelectServersDialogIfLoaded execute lua destroy");
	pScriptEngine->executeString("local ok,dlg=pcall(require,'logic.selectserversdialog'); if ok and dlg and dlg.DestroyDialog then dlg.DestroyDialog() end");
}
#endif

#if (defined WINAPI_FAMILY && WINAPI_FAMILY == WINAPI_FAMILY_PHONE_APP)
#include "ICSharpCallback.h"
#endif

const int c_SinPeriod = 12000;
const float c_fFrontBackWidth = 5120.0f;

static std::wstring g_msdeviceid;
static std::wstring g_ip;

namespace
{
bool IsWindowsExitInProgress()
{
	GameApplication* application = gGetGameApplication();
	return application != NULL && application->IsWindowsExitInProgress();
}

struct AccountHttpContext
{
	AccountHttpContext(bool registerRequest, const std::string& userAccount, const std::string& userPassword,
		const std::string& userInviteCode, const std::string& userCaptcha)
		: isRegister(registerRequest)
		, account(userAccount)
		, password(userPassword)
		, invitecode(userInviteCode)
		, captcha(userCaptcha)
	{
	}

	bool isRegister;
	std::string account;
	std::string password;
	std::string invitecode;
	std::string captcha;
};

std::string UrlEncode(const std::string& value)
{
	static const char hex[] = "0123456789ABCDEF";
	std::string encoded;
	encoded.reserve(value.length() * 3);
	for (std::string::const_iterator it = value.begin(); it != value.end(); ++it)
	{
		const unsigned char ch = static_cast<unsigned char>(*it);
		if ((ch >= 'A' && ch <= 'Z') || (ch >= 'a' && ch <= 'z') || (ch >= '0' && ch <= '9') ||
			ch == '-' || ch == '_' || ch == '.' || ch == '~')
		{
			encoded += static_cast<char>(ch);
		}
		else if (ch == ' ')
		{
			encoded += '+';
		}
		else
		{
			encoded += '%';
			encoded += hex[ch >> 4];
			encoded += hex[ch & 0x0F];
		}
	}
	return encoded;
}

std::string GetAccountPlatformName()
{
#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
	return "android";
#elif CC_TARGET_PLATFORM == CC_PLATFORM_IOS
	return "ios";
#elif CC_TARGET_PLATFORM == CC_PLATFORM_WIN32
	return "windows";
#else
	return "unknown";
#endif
}

std::string BuildAccountPostData(bool isRegister, const AccountHttpContext& context)
{
	std::string data = "account=" + UrlEncode(context.account);
	data += "&password=" + UrlEncode(context.password);
	data += "&platform=" + UrlEncode(GetAccountPlatformName());
	if (isRegister)
	{
		data += "&invitecode=" + UrlEncode(context.invitecode);
		data += "&captcha=" + UrlEncode(context.captcha);
	}
	return data;
}

std::string GetHttpResponseBody(cocos2d::extension::CCHttpResponse* response)
{
	std::string body;
	if (response == NULL || response->getResponseData() == NULL)
	{
		return body;
	}
	std::vector<char>* data = response->getResponseData();
	body.assign(data->begin(), data->end());
	return body;
}

std::string GetJsonStringSafe(Json* json, const char* key)
{
	if (json == NULL || key == NULL)
	{
		return "";
	}
	Json* item = Json_getItem(json, key);
	if (item == NULL)
	{
		return "";
	}
	if (item->type == Json_String && item->valueString != NULL)
	{
		return item->valueString;
	}
	if (item->type == Json_Number)
	{
		return StringCover::intToString(item->valueInt);
	}
	if (item->type == Json_True)
	{
		return "1";
	}
	if (item->type == Json_False)
	{
		return "0";
	}
	return "";
}

std::string GetJsonStringSafe(Json* root, Json* data, const char* key)
{
	std::string value = GetJsonStringSafe(root, key);
	if (value.empty() && data != NULL)
	{
		value = GetJsonStringSafe(data, key);
	}
	return value;
}

std::string GetJsonFirstString(Json* root, Json* data, const char** keys, int keyCount)
{
	for (int i = 0; i < keyCount; ++i)
	{
		std::string value = GetJsonStringSafe(root, data, keys[i]);
		if (!value.empty())
		{
			return value;
		}
	}
	return "";
}

int GetJsonIntSafe(Json* root, Json* data, const char* key, int defaultValue)
{
	std::string value = GetJsonStringSafe(root, data, key);
	if (value.empty())
	{
		return defaultValue;
	}
	return atoi(value.c_str());
}

void ShowAccountLoginError(const std::string& message, bool isRegister)
{
	std::string text = message;
	if (text.empty())
	{
		text = isRegister ? "注册失败，请稍后重试" : "登录失败，请稍后重试";
	}
	gGetGameUIManager()->AddMessageTip(StringCover::to_wstring(text), false);
}
}

LoginManager::LoginManager()
: m_eLoginState(eLoginState_Null)
, m_RoleNum(0)
, m_dwPreLoginID(0)
, m_CurtainPictureHandle(Nuclear::INVALID_PICTURE_HANDLE)
, m_iBackPictureOffset(0.0f)
, m_iMiddlePictureOffset(0.0f)
, m_iFrontPictureOffset(0.0f)
, m_iBackPictureSpeed(30.0f)
, m_iMiddlePictureSpeed(0.008f)
, m_iFrontPictureSpeed(0.012f)
, m_iEaglePictureSpeed(0.04f)
, m_iEagleXPosition(350.0f)
, m_iAnimationIndex(0)
, m_iTimeCount(EACH_PLAY_TIME)
, m_pEagleEffect(NULL)
, m_pParticleLizi1(NULL)
, m_pParticleLizi2(NULL)
, m_pParticleShuye(NULL)
, m_iLoginBackMusicHandle(Nuclear::INVALID_SOUND_HANDLE)
, m_isAutoLogin(false)
,m_bNeedToReload(false)
, m_accountHttpRequesting(false)
, mShortcutItemLaunchedBy(eShortcutItem_None)
, mbShortcutItemHandled(false)
{
	MT3_LOGIN_TRACE("LoginManager::ctor enter");
	// 不知道为什么需要重新设置一下音量才好用 add by yangjiafan
#if (defined WINAPI_FAMILY && WINAPI_FAMILY == WINAPI_FAMILY_PHONE_APP)
	std::string strDocuments=CFileUtil::GetDocDir();
	std::wstring iniW = SHARE_String2Wstring(strDocuments + "/" + LASTACCOUNT_SERVER_INI);
	std::wstring oriW = SHARE_String2Wstring(strDocuments + "/" + LASTACCOUNT_SERVER_INI_ORI);
	Platform::String^ ini = ref new Platform::String(iniW.c_str());
	Platform::String^ ori = ref new Platform::String(oriW.c_str());
	PhoneDirect3DXamlAppComponent::CheckInifileClass::callCSharp(ini, ori);
#endif

    //初始化默认帐户信息
    std::string strIniPath(LASTACCOUNT_SERVER_INI);
	MT3_LOGIN_TRACE("LoginManager::ctor before IniManager path=%s", strIniPath.c_str());
	IniManager IniMgr(strIniPath);
	MT3_LOGIN_TRACE("LoginManager::ctor after IniManager");

    std::string     strLastAccount;
	std::string     strLastChannelId;
    std::string     host;
	std::string     port;
    std::string     servername;
    std::string     area;
    std::string     strLastPassword;
    IniMgr.GetValueByName("Account", "LastAccount", strLastAccount);
    IniMgr.GetValueByName("Password", "LastPassword", strLastPassword);
	IniMgr.GetValueByName("ChannelId", "LastChannelId", strLastChannelId);

    IniMgr.GetValueByName("Host", "host", host);
    IniMgr.GetValueByName("Port", "port", port);
    IniMgr.GetValueByName("Server", "server", servername);
    IniMgr.GetValueByName("ServerArea", "area", area);

	//将保存的账号填入账号列表
	for(int i = 0; i < 10; i++)
	{
        stHistoryAccountInfo accountInfo;

        std::wstring account;
		if(IniMgr.GetValueByName(L"AccountList", L"user" + StringCover::intTowstring(i), account))
        {
            std::wstring password;
            IniMgr.GetValueByName(L"AccountList", L"password" + StringCover::intTowstring(i), password);
            accountInfo.m_sName = account;
            accountInfo.m_sPassword = password;
            m_lHistoryAccount.push_back(accountInfo);
        }
        else
            break;
    }

    if (servername != "" && area != "" && host != "" && port != "")    //没有默认服务器信息,选中列表中的第一项作为服务器
	{
		MT3_LOGIN_TRACE("LoginManager::ctor before SetSelectServerInfo hostLen=%d port=%s serverLen=%d areaLen=%d", (int)host.length(), port.c_str(), (int)servername.length(), (int)area.length());
		SetSelectServerInfo(StringCover::to_wstring(area), StringCover::to_wstring(servername), StringCover::to_wstring(host), StringCover::to_wstring(port), 0);
		MT3_LOGIN_TRACE("LoginManager::ctor after SetSelectServerInfo");
    }

    MT3_LOGIN_TRACE("LoginManager::ctor before SetAccountInfo accountLen=%d channelLen=%d history=%d", (int)strLastAccount.length(), (int)strLastChannelId.length(), (int)m_lHistoryAccount.size());
    SetAccountInfo(StringCover::to_wstring(strLastAccount));
    m_savedPassword = StringCover::to_wstring(strLastPassword);
    SetSessionKey(L"");
	SetChannelId(StringCover::to_wstring(strLastChannelId));
	MT3_LOGIN_TRACE("LoginManager::ctor leave");
}

LoginManager::~LoginManager()
{
    Clear();

	destroyServerInfo();
}

void LoginManager::Clear()
{
    GameConfigManager::sSetPlayBackMusicBootState(true);

    CocosDenshion::SimpleAudioEngine::sharedEngine()->stopBackgroundMusic(true);
	cocos2d::CCScriptEngineManager::sharedManager()->getScriptEngine()->executeGlobalFunction("loginBg.DestroyDialog");
	m_eLoginState = eLoginState_Null;
	m_RoleNum = 0;

    m_bNeedToReload = false;

    ClearConnections();
    m_mServerInfoMap.clear();
}

void LoginManager::Exit()
{
	m_eLoginState = eLoginState_Null;
}

void LoginManager::Init()
{
	MT3_LOGIN_TRACE("LoginManager::Init enter");
    m_bNeedToReload = true;
	m_RoleNum = 0;
	m_RoleList.clear();
	m_eLoginState = eLoginState_Enter;
	MT3_LOGIN_TRACE("LoginManager::Init before loginBg.getInstanceAndShow");
	int loginBgResult = cocos2d::CCScriptEngineManager::sharedManager()->getScriptEngine()->executeGlobalFunction("loginBg.getInstanceAndShow");
	MT3_LOGIN_TRACE("LoginManager::Init after loginBg.getInstanceAndShow result=%d", loginBgResult);
}

bool LoginManager::isFirstEnter()
{
	stHistoryAccountInfo lastAccount;
	lastAccount.m_sName = GetAccount();
	lastAccount.m_sPassword = L"";
	for (std::list<stHistoryAccountInfo>::iterator itor = m_lHistoryAccount.begin(); itor != m_lHistoryAccount.end(); itor++)
	{
		if ((*itor).m_sName == GetAccount())
		{
			return false;
		}
	}
	return true;
}


static std::wstring m_channelid;
void LoginManager::SetChannelId(const std::wstring& channelid)
{
	m_channelid = channelid;
}
const std::wstring& LoginManager::GetChannelId()
{
	return m_channelid;
}

void LoginManager::SetCurChannelId(const std::wstring& channelId)
{
	std::string strIniPath(LASTACCOUNT_SERVER_INI);
	IniManager IniMgr(strIniPath);

	std::wstring accountnum(L"");
	bool bExistLast = IniMgr.GetValueByName(L"AccountInfo", L"num", accountnum);
	bool exist_user_already = false;
	if (bExistLast)
	{
		int unum = StringCover::WStrToNum<int>(accountnum);
		unum = (unum < 10) ? unum : 10;
		for (int user_i = 1; user_i <= unum; user_i++)
		{
			std::wstring username(L"");
			IniMgr.GetValueByName(L"Account" + StringCover::intTowstring(user_i), L"username", username);
			if (username == gGetLoginManager()->GetAccount())
			{
				IniMgr.WriteValueByName(L"Account" + StringCover::intTowstring(user_i),
					L"channelid", channelId);
				exist_user_already = true;
			}
		}
	}
	if ( exist_user_already == false )
    {
		IniMgr.WriteValueByName("ChannelId", "LastChannelId", StringCover::to_string(channelId));
    }

}

const std::wstring& LoginManager::GetCurChannelId()
{
	std::string strIniPath(LASTACCOUNT_SERVER_INI);
	IniManager IniMgr(strIniPath);

	std::wstring accountnum(L"");
	bool bExistLast = IniMgr.GetValueByName(L"AccountInfo", L"num", accountnum);
	//
	if (bExistLast)
	{
		int unum = StringCover::WStrToNum<int>(accountnum);
		unum = (unum < 10) ? unum : 10;
		bool exist_user_already = false;
		for (int user_i = 1; user_i <= unum; user_i++)
		{
			std::wstring username(L"");
			IniMgr.GetValueByName(L"Account" + StringCover::intTowstring(user_i), L"username", username);
			if (username == gGetLoginManager()->GetAccount())
			{
				std::wstring channelId(L"");
				IniMgr.GetValueByName(L"Account" + StringCover::intTowstring(user_i), L"channelid", channelId);
				m_channelid = channelId;
				return m_channelid;
			}
		}
	}
	return m_channelid;
}



static unsigned char EnterMainStatus = eEnterMainStatus_None;
void LoginManager::setEnterMainStatus(unsigned char status)
{
	EnterMainStatus = status;
}
unsigned char LoginManager::getEnterMainStatus()
{
	return EnterMainStatus;
}


void LoginManager::SetNeedToReloadPicture(bool flag)
{
	m_bNeedToReload = flag;
}

void LoginManager::ToServerChoose(const std::wstring& area, const std::wstring& server)
{
#ifdef ANDROID
	const int serverCount = static_cast<int>(GetServerInfo()->getAllServers().size());
	LOGE("[LoginFlow] ToServerChoose areaLen=%d serverLen=%d serverCount=%d",
		static_cast<int>(area.length()), static_cast<int>(server.length()), serverCount);
	LOGE("[SelectServerDiag] ToServerChoose input areaLen=%d serverLen=%d currentAreaLen=%d currentServerLen=%d hostLen=%d portLen=%d serverCount=%d",
		static_cast<int>(area.length()),
		static_cast<int>(server.length()),
		static_cast<int>(GetSelectArea().length()),
		static_cast<int>(GetSelectServer().length()),
		static_cast<int>(GetHost().length()),
		static_cast<int>(GetPort().length()),
		serverCount);
	if ((area.empty() || server.empty()) && serverCount > 0)
	{
		if (TrySelectFirstAndroidServer(this))
		{
			DestroyAndroidSelectServersDialogIfLoaded();
			LOGE("[LoginFlow] ToServerChoose recovered selected areaLen=%d serverLen=%d",
				static_cast<int>(GetSelectArea().length()), static_cast<int>(GetSelectServer().length()));
		}
	}

	if (GetSelectArea().empty() || GetSelectServer().empty() || serverCount == 0)
	{
		LOGE("[LoginFlow] ToServerChoose redirects to SelectServerEntry because selected area/server is empty or server list is empty");
		LOGE("[SelectServerDiag] ToServerChoose open SelectServerEntry selectedAreaLen=%d selectedServerLen=%d serverCount=%d",
			static_cast<int>(GetSelectArea().length()),
			static_cast<int>(GetSelectServer().length()),
			serverCount);
		OpenSelectServerEntry();
		return;
	}
	LOGE("[SelectServerDiag] ToServerChoose continue to ServersChoose selectedAreaLen=%d selectedServerLen=%d hostLen=%d portLen=%d",
		static_cast<int>(GetSelectArea().length()),
		static_cast<int>(GetSelectServer().length()),
		static_cast<int>(GetHost().length()),
		static_cast<int>(GetPort().length()));
#endif
	m_eLoginState = eLoginState_ServersChoose;
	gGetStateManager()->setGameState(eGameStateNull);

    m_bNeedToReload = false;

    gGetGameUIManager()->InitGameUIPostInit();
}

bool LoginManager::NeedToReloadPicture()
{
	return m_bNeedToReload;
}

RoleList::size_type LoginManager::GetRoleListNum()
{
	return m_RoleList.size();
}

void LoginManager::LoginIn()
{
	SDLOG_INFO(L"[LoginFlow] LoginManager::LoginIn send CRoleList accountLen=%d", static_cast<int>(ws2s(m_account).length()));
	fire::pb::CRoleList LoginInCmd;
	gGetNetConnection()->send(LoginInCmd);

#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID || CC_TARGET_PLATFORM == CC_PLATFORM_WIN32
	MT3SystemInfo::sSendSystemInfo();
#elif CC_TARGET_PLATFORM == CC_PLATFORM_IOS
	MT3SystemInfo::sSendSystemInfo();
#endif
}


void LoginManager::Run(int now, int delta)
{
	if (IsWindowsExitInProgress())
	{
		return;
	}

    for (std::map<int, stCheckServer>::iterator itor = m_mCheckLoadTimeMap.begin(); itor != m_mCheckLoadTimeMap.end(); itor++)
    {
        itor->second.time -= delta;
        if (itor->second.time < 0 )
        {
            if (!itor->second.hasReturn)
            {
                FireNet::ServerInfo info;
                info.load = -1;
                SetServerLoad(itor->first, info);
            }
			CheckLoad(itor->second.host, itor->second.port, itor->second.key, CONNECT_TYPE_NORMAL, "", "", itor->second.checkTime);
            break;
        }
    }

	m_iTimeCount -= delta;
	if (m_iTimeCount < 0)
	{
		m_iTimeCount = EACH_PLAY_TIME;
		m_iAnimationIndex++;
		if (m_iAnimationIndex >= ANIMATION_NUM)
		{
			m_iAnimationIndex = 0;
		}
	}

	m_iBackPictureOffset += PixelAligned(m_iBackPictureSpeed*delta/1000.0f);

    float picWidth=(float)m_Picinfo.m_nPicWidth;

	if (m_iBackPictureOffset >picWidth)
	{
		m_iBackPictureOffset = 0.0f;
	}
    EnterLuaMain();
}

void LoginManager::UpdateRoleList()
{
	if (IsWindowsExitInProgress())
	{
		return;
	}
	SDLOG_INFO(L"[LoginFlow] LoginManager::UpdateRoleList roleNum=%d preRole=%lld", static_cast<int>(m_RoleList.size()), m_dwPreLoginID);

	cocos2d::CCScriptEngineManager::sharedManager()->getScriptEngine()->executeGlobalFunction("LoginQuickDialog.DestroyDialog");

    //帐号只有一个角色
    if (m_RoleList.size() == 1)
    {
        gGetGameApplication()->BeginDrawServantIntro();
        if(gGetGameApplication()->GetXmlBeanReady())
        {
            gGetGameApplication()->DrawLoginBar(20);
            m_eLoginState = eLoginState_Null;
            int numMaxShowNum = cocos2d::CCScriptEngineManager::sharedManager()->getScriptEngine()->executeGlobalFunction("SystemSettingNewDlg.GetMaxDisplayPlayerNum");
            fire::pb::CEnterWorld EnterWorldCmd(gGetLoginManager()->GetPreLoginRoleID(), numMaxShowNum);
            gGetNetConnection()->send(EnterWorldCmd);
        }
        else
        {
            gGetGameApplication()->DrawLoginBar(10);
            m_eLoginState = eLoginState_Null;
            gGetGameApplication()->SetWaitToEnterWorld(true);
            gGetGameApplication()->SetEnterWorldRoleID(gGetLoginManager()->GetPreLoginRoleID());
        }

        gGetGameApplication()->SetWaitForEnterWorldState(true);
    }
	else if (m_RoleList.size() > 1)
	{
		ShowSelectRoleDialog();
	}
	else
	{
		if (gGetGameApplication()->isReconnecting())
		{
			// 重连时,如果服务器删库,则退到登陆界面.
			GameApplication::GetInstance().ExitGame(eExitType_ToLogin);
		}
		else
		{
			ShowCreateRoleDialog();
		}
	}
}

const fire::pb::RoleInfo* LoginManager::GetRoleInfoByID(int64_t roleid)
{
	RoleList::iterator roleiter = m_RoleList.begin();
	for(; roleiter != m_RoleList.end(); roleiter++)
	{
		if((*roleiter).roleid == roleid)
		{
			return &(*roleiter);
		}
	}

	return NULL;
}

RoleList& LoginManager::GetRoleList()
{
	return m_RoleList;
}

int64_t LoginManager::GetPreLoginRoleID()
{
	return m_dwPreLoginID;
}

void LoginManager::SetPreLoginRoleID(int64_t dwID)
{
	m_dwPreLoginID = dwID;
}

void LoginManager::SetSelectServerInfo(const std::wstring& area, const std::wstring& server, const std::wstring& ip, const std::wstring& port, int hosttype)
{
	m_SelectArea = area;
	m_SelectServer = server;
	m_host = ip;
	m_port = port;
	m_iHostType = hosttype;
}

const std::wstring& LoginManager::GetSelectArea()
{
	return m_SelectArea;
}

const std::wstring& LoginManager::GetSelectServer()
{
	return m_SelectServer;
}

const std::wstring& LoginManager::GetHost()
{
	return m_host;
}

const std::wstring& LoginManager::GetPort()
{
	return m_port;
}

const std::wstring& LoginManager::GetAccount()
{
	return m_account;
}

const std::wstring& LoginManager::GetSessionKey()
{
	return m_sessionKey;
}

const std::wstring& LoginManager::GetPassword()
{
	return GetSessionKey();
}

int LoginManager::GetHostType()
{
	return m_iHostType;
}

void LoginManager::SetAccountInfo(const std::wstring& account)
{
	m_account = account;
}

void LoginManager::SetSessionKey(const std::wstring& sessionKey)
{
	m_sessionKey = sessionKey;
}

void LoginManager::SetPassword(const std::wstring& password)
{
	SetSessionKey(password);
}

void LoginManager::SetSession(const std::wstring& session)
{
	m_Key = session;
	SetSessionKey(session);
}

void LoginManager::SetDeviceid(const std::wstring& session)
{
	g_msdeviceid = session;
}

void LoginManager::SetIp(const std::wstring& ip)
{
	g_ip = ip;
}

std::wstring& LoginManager::GetIp()
{
	return g_ip;
}

std::wstring& LoginManager::GetDeviceid()
{
	if (g_msdeviceid.length() == 0)
	{
		int64_t nRoleId = GetMainRoleDataNumValue<int64_t>("roleid");
		g_msdeviceid = s2ws(StringCover::int64_tToString(nRoleId));
	}

	return g_msdeviceid;
}

void LoginManager::ShowSelectRoleDialog()
{
	m_eLoginState = eLoginState_RoleSelect;
}

void LoginManager::SetLoginState(eLoginState state)
{
	m_eLoginState = state;
}

eLoginState LoginManager::GetLoginState()
{
	return m_eLoginState;
}

void LoginManager::ShowCreateRoleDialog()
{
	m_eLoginState = eLoginState_RoleCreate;
    cocos2d::CCScriptEngineManager::sharedManager()->getScriptEngine()->executeString("require \"logic.createroledialog\":getInstance()");
}

//易接SDK所需参数
static std::wstring m_yjappid;
void LoginManager::SetYJAppId(const std::wstring& yjappid)
{
	m_yjappid = yjappid;
}
const std::wstring&  LoginManager::GetYJAppId()
{
	return m_yjappid;
}
static std::wstring m_yjchannelid;
void LoginManager::SetYJChannelId(const std::wstring& yjchannelid)
{
	m_yjchannelid = yjchannelid;
}
const std::wstring&  LoginManager::GetYJChannelId()
{
	return m_yjchannelid;
}
static std::wstring m_yjuserid;
void LoginManager::SetYJUserId(const std::wstring& yjuserid)
{
	m_yjuserid = yjuserid;
}
const std::wstring&  LoginManager::GetYJUserId()
{
	return m_yjuserid;
}
static std::wstring m_yjtoken;
void LoginManager::SetYJToken(const std::wstring& yjtoken)
{
	m_yjtoken = yjtoken;
}

const std::wstring&  LoginManager::GetYJToken()
{
	return m_yjtoken;
}

void LoginManager::SaveAccount()
{
    IniManager iniMgr = IniManager(LASTACCOUNT_SERVER_INI);

    iniMgr.WriteValueByName("Account", "LastAccount" , StringCover::to_string(GetAccount()));
    iniMgr.WriteValueByName("Password", "LastPassword", StringCover::to_string(m_savedPassword));
	iniMgr.WriteValueByName("ChannelId", "LastChannelId", StringCover::to_string(GetChannelId()));
	iniMgr.WriteValueByName("Host", "host", StringCover::to_string(GetHost()));
	iniMgr.WriteValueByName("Port", "port", StringCover::to_string(GetPort()));
    iniMgr.WriteValueByName("Server", "server" , StringCover::to_string(GetSelectServer()));
    iniMgr.WriteValueByName("ServerArea", "area" , StringCover::to_string(GetSelectArea()));

    stHistoryAccountInfo lastAccount;
    lastAccount.m_sName = GetAccount();
    lastAccount.m_sPassword = m_savedPassword;
    for (std::list<stHistoryAccountInfo>::iterator itor = m_lHistoryAccount.begin(); itor != m_lHistoryAccount.end(); itor++)
    {
        if ((*itor).m_sName == GetAccount())
        {
            m_lHistoryAccount.erase(itor);
            break;
        }
    }

    m_lHistoryAccount.push_front(lastAccount);

	//最多保存10个 by liugeng
	while (m_lHistoryAccount.size() > 10)
	{
		m_lHistoryAccount.pop_back();
	}

    std::list<stHistoryAccountInfo>::iterator itor = m_lHistoryAccount.begin();
    for (int i = 0;i < 10 && itor != m_lHistoryAccount.end(); i++, itor++)
    {
        iniMgr.WriteValueByName(L"AccountList",  L"user" + StringCover::intTowstring(i) , (*itor).m_sName);
        iniMgr.WriteValueByName(L"AccountList", L"password" + StringCover::intTowstring(i), (*itor).m_sPassword);
    }
}

void LoginManager::LoginAccount(const std::string& account, const std::string& password)
{
	if (IsWindowsExitInProgress())
	{
		return;
	}

	m_savedPassword = StringCover::to_wstring(password);
	StartAccountHttpRequest(false, account, password, "", "");
}

void LoginManager::RegisterAccount(const std::string& account, const std::string& password, const std::string& invitecode, const std::string& captcha)
{
	if (IsWindowsExitInProgress())
	{
		return;
	}

	m_savedPassword = StringCover::to_wstring(password);
	StartAccountHttpRequest(true, account, password, invitecode, captcha);
}

void LoginManager::StartAccountHttpRequest(bool isRegister, const std::string& account, const std::string& password, const std::string& invitecode, const std::string& captcha)
{
	if (m_accountHttpRequesting)
	{
		ShowAccountLoginError("正在登录，请稍候", isRegister);
		return;
	}

	const std::string url = isRegister ? gGetGameApplication()->getSdkRegisterAddress() : gGetGameApplication()->getSdkLoginAddress();
	if (url.empty())
	{
		SDLOG_WARN(L"[LoginHTTP] request skipped: empty url register=%d accountLen=%d", isRegister ? 1 : 0, static_cast<int>(account.length()));
		ShowAccountLoginError("登录接口地址未配置", isRegister);
		return;
	}

	AccountHttpContext* context = new AccountHttpContext(isRegister, account, password, invitecode, captcha);
	const std::string postData = BuildAccountPostData(isRegister, *context);

	cocos2d::extension::CCHttpRequest* request = new cocos2d::extension::CCHttpRequest;
	request->setUrl(url.c_str());
	request->setRequestType(cocos2d::extension::CCHttpRequest::kHttpPost);
	request->setRequestData(postData.c_str(), postData.length());
	request->setUserData(context);
	std::vector<std::string> headers;
	headers.push_back("Content-Type: application/x-www-form-urlencoded");
	request->setHeaders(headers);
	if (isRegister)
	{
		request->setResponseCallback(this, httpresponse_selector(LoginManager::OnRegisterAccountHttpResponse));
	}
	else
	{
		request->setResponseCallback(this, httpresponse_selector(LoginManager::OnLoginAccountHttpResponse));
	}

	m_accountHttpRequesting = true;
	CCLOG("[LoginHTTP] request start register=%d url=%s accountLen=%d postLen=%d",
		isRegister ? 1 : 0, url.c_str(), static_cast<int>(account.length()), static_cast<int>(postData.length()));
	cocos2d::extension::CCHttpClient* httpClient = cocos2d::extension::CCHttpClient::getInstance();
	httpClient->setTimeoutForConnect(10);
	httpClient->send(request);
	request->release();
}

void LoginManager::OnLoginAccountHttpResponse(cocos2d::extension::CCHttpClient* client, cocos2d::extension::CCHttpResponse* response)
{
	CC_UNUSED_PARAM(client);
	HandleAccountHttpResponse(response, false);
}

void LoginManager::OnRegisterAccountHttpResponse(cocos2d::extension::CCHttpClient* client, cocos2d::extension::CCHttpResponse* response)
{
	CC_UNUSED_PARAM(client);
	HandleAccountHttpResponse(response, true);
}

void LoginManager::HandleAccountHttpResponse(cocos2d::extension::CCHttpResponse* response, bool isRegister)
{
	AccountHttpContext* context = NULL;
	if (response != NULL && response->getHttpRequest() != NULL)
	{
		context = static_cast<AccountHttpContext*>(response->getHttpRequest()->getUserData());
		response->getHttpRequest()->setUserData(NULL);
		if (context != NULL)
		{
			isRegister = context->isRegister;
		}
	}

	m_accountHttpRequesting = false;

	const int httpCode = response != NULL ? response->getResponseCode() : 0;
	std::string body = GetHttpResponseBody(response);
	std::string message;
	bool success = false;
	std::string responseAccount;
	std::string session;
	int code = -1;
	bool usedCredentialFallback = false;

	if (response == NULL)
	{
		message = "登录接口无响应";
	}
	else if (!response->isSucceed() || httpCode != 200)
	{
		message = "登录接口请求失败";
		if (response->getErrorBuffer() != NULL && strlen(response->getErrorBuffer()) > 0)
		{
			CCLOG("[LoginHTTP] request error register=%d http=%d error=%s",
				isRegister ? 1 : 0, httpCode, response->getErrorBuffer());
		}
	}
	else if (body.empty())
	{
		message = "登录接口返回为空";
	}
	else
	{
		Json* root = Json_create(body.c_str());
		if (root == NULL)
		{
			message = "登录接口返回格式错误";
		}
		else
		{
			Json* data = Json_getItem(root, "data");
			if (data != NULL && data->type != Json_Object)
			{
				data = NULL;
			}

			code = GetJsonIntSafe(root, data, "code", -1);
			if (code == -1)
			{
				code = GetJsonIntSafe(root, data, "Code", -1);
			}

			const char* messageKeys[] = { "msg", "message", "Message" };
			message = GetJsonFirstString(root, data, messageKeys, sizeof(messageKeys) / sizeof(messageKeys[0]));

			const char* accountKeys[] = { "account", "Account" };
			responseAccount = GetJsonFirstString(root, data, accountKeys, sizeof(accountKeys) / sizeof(accountKeys[0]));

			const char* sessionKeys[] = { "session", "Session", "token", "Token", "sid", "Sid", "password", "Password" };
			session = GetJsonFirstString(root, data, sessionKeys, sizeof(sessionKeys) / sizeof(sessionKeys[0]));

			success = (code == 1 && !session.empty());
			if (code == 1 && session.empty())
			{
				if (context != NULL && !context->password.empty())
				{
					session = context->password;
					success = true;
					usedCredentialFallback = true;
					SDLOG_WARN(L"[LoginHTTP] response missing credential; using submitted credential fallback register=%d accountLen=%d",
						isRegister ? 1 : 0, static_cast<int>(context->account.length()));
				}
				else
				{
					message = "登录接口未返回入服凭证";
				}
			}
			Json_dispose(root);
		}
	}

	if (success && context != NULL)
	{
		if (responseAccount.empty())
		{
			responseAccount = context->account;
		}
		SetAccountInfo(StringCover::to_wstring(responseAccount));
		SetSessionKey(StringCover::to_wstring(session));
		SDLOG_INFO(L"[LoginHTTP] request success register=%d code=%d accountLen=%d sessionLen=%d fallback=%d",
			isRegister ? 1 : 0, code, static_cast<int>(responseAccount.length()), static_cast<int>(session.length()),
			usedCredentialFallback ? 1 : 0);
		OpenSelectServerEntryWithSavedAccount(isRegister ? "account register http" : "account login http");
	}
	else
	{
		SDLOG_WARN(L"[LoginHTTP] request failed register=%d http=%d code=%d bodyLen=%d accountLen=%d",
			isRegister ? 1 : 0, httpCode, code, static_cast<int>(body.length()),
			context != NULL ? static_cast<int>(context->account.length()) : 0);
		ShowAccountLoginError(message, isRegister);
	}

	delete context;
}

void LoginManager::OpenSelectServerEntry()
{
	if (IsWindowsExitInProgress())
	{
		return;
	}

	cocos2d::CCScriptEngineProtocol* pScriptEngine = cocos2d::CCScriptEngineManager::sharedManager()->getScriptEngine();
	if (pScriptEngine == NULL)
	{
		return;
	}

	m_eLoginState = eLoginState_ServersChoose;
#ifdef ANDROID
	LOGE("[SelectServerDiag] OpenSelectServerEntry accountLen=%d selectedAreaLen=%d selectedServerLen=%d",
		static_cast<int>(ws2s(m_account).length()),
		static_cast<int>(GetSelectArea().length()),
		static_cast<int>(GetSelectServer().length()));
#endif
	SDLOG_INFO(L"[LoginFlow] OpenSelectServerEntry accountLen=%d", static_cast<int>(ws2s(m_account).length()));
	pScriptEngine->executeString("require('logic.switchaccountdialog').DestroyDialog()");
	pScriptEngine->executeString("require('logic.selectserverentry').getInstanceAndShow(true)");
}

void LoginManager::OpenSelectServerEntryWithSavedAccount(const char* reason)
{
	CCLOG("[LoginFlow] open select server with saved account reason=%s", reason ? reason : "");
	SaveAccount();
	OpenSelectServerEntry();
}

bool LoginManager::isAutoLogin()
{
	return m_isAutoLogin;
}

std::string LoginManager::GetHistoryAccount(int num)
{
    if ((size_t)num >= m_lHistoryAccount.size())
    {
        return "";
    }

    std::list<stHistoryAccountInfo>::iterator itor = m_lHistoryAccount.begin();
    for (int i = 0; i < num; i++,itor++);
    return StringCover::to_string((*itor).m_sName);
}

std::string LoginManager::GetHistoryPassword(int num)
{
    if ((size_t)num >= m_lHistoryAccount.size())
    {
        return "";
    }

    std::list<stHistoryAccountInfo>::iterator itor = m_lHistoryAccount.begin();
    for (int i = 0; i < num; i++,itor++);
    return StringCover::to_string((*itor).m_sPassword);
}

void LoginManager::CheckLoad(const std::string host, const std::string port, int serverKey, int ct_type, const std::string& gip, const std::string& gport, int checkTime)
{
    if (m_mCheckLoadTimeMap.end() != m_mCheckLoadTimeMap.find(serverKey))
    {
        delete m_mCheckLoadTimeMap.find(serverKey)->second.netConnection;
        m_mCheckLoadTimeMap.erase(m_mCheckLoadTimeMap.find(serverKey));
    }

	std::map<int, stCheckServer> ::iterator it = m_mCheckLoadTimeMap.find(serverKey);
	if (it != m_mCheckLoadTimeMap.end())
	{
		return;
	}

	doGetRoleHeadInfo();

    Game::NetConnection* pNetConnetcor = new Game::NetConnection(host, port, serverKey, ct_type, gip, gport);
    struct stCheckServer check;
    check.host = host;
    check.port = port;
    check.key = serverKey;
	check.time = checkTime * 1000;
	check.checkTime = checkTime;
    check.netConnection = pNetConnetcor;
    check.hasReturn = false;
    m_mCheckLoadTimeMap[serverKey] = check;
}

void LoginManager::ClearConnections()
{
    for (std::map<int, stCheckServer>::iterator itor = m_mCheckLoadTimeMap.begin(); m_mCheckLoadTimeMap.end() != itor; itor++)
    {
        delete itor->second.netConnection;
        itor->second.netConnection = NULL;
    }
    m_mCheckLoadTimeMap.clear();
}

void LoginManager::ClearConnectionByKey(int key)
{
	std::map<int, stCheckServer>::iterator it = m_mCheckLoadTimeMap.begin();
	while (it != m_mCheckLoadTimeMap.end())
	{
		if (it->second.key == key)
		{
			delete it->second.netConnection;
			it->second.netConnection = NULL;
			m_mCheckLoadTimeMap.erase(it);
			break;
		}
		it++;
	}
}

void LoginManager::setShortcutItemLaunchedBy(eShortcutItem item)
{
	mShortcutItemLaunchedBy = item;
	mbShortcutItemHandled = false;
}

void LoginManager::SetServerLoad(int key, FireNet::ServerInfo info)
{
    m_mCheckLoadTimeMap[key].hasReturn = true;
    m_mServerInfoMap[key] = info;
    cocos2d::CCScriptEngineManager::sharedManager()->getScriptEngine()->executeGlobalFunctionWithParamsData("SelectServersDialog.SetServerLoad", key, info.load);
}

void LoginManager::doGetRoleHeadInfo()
{
	GetServerInfo()->connetGetUserInfo();
}

void LoginManager::setServerKey(int id)
{
	m_serverID = id;
}

int LoginManager::getServerID()
{
	return m_serverID;
}

/*
应用宝登陆需要的参数
*/
static std::wstring m_openid = L"";
static std::wstring m_openkey = L"";
static std::wstring m_paytoken = L"";
static std::wstring m_pf = L"";
static std::wstring m_pfkey = L"";
static std::wstring m_zoneid = L"";
static std::wstring m_platformname = L"";

const std::wstring& LoginManager::GetOpenId()
{
	return m_openid;
}

const std::wstring& LoginManager::GetOpenKey()
{
	return m_openkey;
}

const std::wstring& LoginManager::GetPayToken()
{
	return m_paytoken;
}

const std::wstring& LoginManager::GetPf()
{
	return m_pf;
}

const std::wstring& LoginManager::GetPfKey()
{
	return m_pfkey;
}

const std::wstring& LoginManager::GetZoneId()
{
	return m_zoneid;
}

const std::wstring& LoginManager::GetPlatformName()
{
	return m_platformname;
}

void LoginManager::SetOpenId(const std::wstring& openid)
{
	m_openid = openid;
}

void LoginManager::SetOpenKey(const std::wstring& openkey)
{
	m_openkey = openkey;
}

void LoginManager::SetPayToken(const std::wstring& paytoken)
{
	m_paytoken = paytoken;
}

void LoginManager::SetPf(const std::wstring& pf)
{
	m_pf = pf;
}

void LoginManager::SetPfKey(const std::wstring& pfkey)
{
	m_pfkey = pfkey;
}

void LoginManager::SetZoneId(const std::wstring& zoneid)
{
	m_zoneid = zoneid;
}

void LoginManager::SetPlatformName(const std::wstring& platformname)
{
	m_platformname = platformname;
}

static bool m_isYingyongbao = false;
void LoginManager::setIsYingYongBao(bool isyingyongbao)
{
	m_isYingyongbao = isyingyongbao;
}

bool LoginManager::getIsYingYongBao()
{
	return m_isYingyongbao;
}

int LoginManager::isSDKFuncSupported(const char *funcName)
{
#ifdef _LOCOJOY_SDK_
#ifdef ANDROID
	return isFunctionSupported(funcName);
#else
	return 1;
#endif
#endif

#ifdef _YJ_SDK_
	return 1;
#endif

	return 1;
}

void LoginManager::CloseWinWebView()
{
#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32
	WinSDK::getInstance()->closeWinWebView();
#endif
}

void LoginManager::WinWebViewUpdate()
{
#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32
	WinSDK::getInstance()->update();
#endif
}

void LoginManager::LoginAgain(){
#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32
	if (gGetGameApplication()->IsUseSDKInWindows()) {
		EnterMainStatus = eEnterMainStatus_SwitchByClickBtn; // 选服界面点击切换账号
		WinSDK::getInstance()->openLoginUrl();
		return;
	}
#endif

#ifdef _LOCOJOY_SDK_
	EnterMainStatus = eEnterMainStatus_SwitchByClickBtn; // 选服界面点击切换账号
#ifdef ANDROID
	if (getIsYingYongBao())
	{
		if (isFunctionSupported("logout"))
		{
			logout();
			cocos2d::CCScriptEngineManager::sharedManager()->getScriptEngine()->executeGlobalFunction("SelectServerEntry_YingYongBaoShow");
		}
	}
	else
	{
		//if (isFunctionSupported("switchAccount"))
		//{
		//	switchAccount();
		//}
		//else
		//{
			if (isFunctionSupported("logout"))
			{
				LOGE("LoginManager::LoginAgain()");
				logout();
				bool is_RongHe = false;
				cocos2d::CCScriptEngineProtocol* pScriptEngine = cocos2d::CCScriptEngineManager::sharedManager()->getScriptEngine();
				if (pScriptEngine)
				{
					CallLuaUtil util;
					if (util.callLua(pScriptEngine->getLuaState(), "Config_IsRongHe"))
					{
						is_RongHe =  util.getRetBool();
					}
				}
				if (!is_RongHe)
				{
					login();
				}
			}
		//}
	}
#else
    SDK::GameSdk::logout();
    SDK::GameSdk::login(false);
#endif

	//关闭暗灯逻辑
	Nuclear::EngineLayer* layer = (Nuclear::EngineLayer*)Nuclear::GetEngine()->GetEngineLayer();
	if (layer)
	{
		layer->m_IsRunBrightNess = false;
		layer->m_bDark = false;
		layer->m_DuraTime = 0;
		layer->m_LastTick = Nuclear::GetMilliSeconds();
	}
#endif

#ifdef _YJ_SDK_
#ifdef ANDROID
	EnterMainStatus = eEnterMainStatus_SwitchByClickBtn; // 选服界面点击切换账号
	LOGE("LoginManager::LoginAgain begin");
	MT3::ChannelManager::yj_sdkLogout();
	LOGE("LoginManager::LoginAgain end");
#else

#endif

	//关闭暗灯逻辑
	Nuclear::EngineLayer* layer = (Nuclear::EngineLayer*)Nuclear::GetEngine()->GetEngineLayer();
	if (layer)
	{
		layer->m_IsRunBrightNess = false;
		layer->m_bDark = false;
		layer->m_DuraTime = 0;
		layer->m_LastTick = Nuclear::GetMilliSeconds();
	}
#endif

}

void LoginManager::EnterLuaMain(){
	if (IsWindowsExitInProgress())
	{
		return;
	}

#ifdef _LOCOJOY_SDK_
#ifdef ANDROID
	if (MT3::ChannelManager::getIsYingYongBao()) {
		if (canDoYYBLoginCallback()) {
			onYYBLoginCb();
		}
	}
#endif
#endif

	if (EnterMainStatus == eEnterMainStatus_LoginSuccess){
		EnterMainStatus = eEnterMainStatus_GamePlaying;

#ifdef _LOCOJOY_SDK_
#ifdef ANDROID
		bool is_LocoJoy = false;
		cocos2d::CCScriptEngineProtocol* pScriptEngine = cocos2d::CCScriptEngineManager::sharedManager()->getScriptEngine();
		if (pScriptEngine)
		{
			CallLuaUtil util;
			if (util.callLua(pScriptEngine->getLuaState(), "Config_IsLocojoy"))
			{
				is_LocoJoy =  util.getRetBool();
			}
		}
		if (!is_LocoJoy)
		{
			if (isFunctionSupported("showToolBar"))
			{
				showToolBar(TopLeft);
			}
		}
#else
		//showToolBar(TopRight);
#endif
#endif

		//开始启动暗灯逻辑
		Nuclear::EngineLayer* layer = (Nuclear::EngineLayer*)Nuclear::GetEngine()->GetEngineLayer();
		if (layer)
		{
			layer->m_IsRunBrightNess = true;
			layer->m_LastTick = Nuclear::GetMilliSeconds();
		}
        cocos2d::CCScriptEngineManager::sharedManager()->getScriptEngine()->executeScriptFile(L"main.lua");
    }
	else if (EnterMainStatus == eEnterMainStatus_SwitchBySdk) {
		EnterMainStatus = eEnterMainStatus_Waiting;
		cocos2d::CCScriptEngineManager::sharedManager()->getScriptEngine()->executeGlobalFunction("Logout_CalledBySdk"); // 触发调用游戏内的“切换账号”
	}
	else if (EnterMainStatus == eEnterMainStatus_ActiveCodeBySdkSwitch) {
		EnterMainStatus = eEnterMainStatus_NeedDisableBtnInUI;
		cocos2d::CCScriptEngineManager::sharedManager()->getScriptEngine()->executeGlobalFunction("Logout_CalledBySdk"); // 触发调用游戏内的“切换账号”
	}
	else if (EnterMainStatus == eEnterMainStatus_NeedDisableBtnInUI) {
		bool disableServerEntryClick = false;
		cocos2d::CCScriptEngineProtocol* pScriptEngine = cocos2d::CCScriptEngineManager::sharedManager()->getScriptEngine();
		if (pScriptEngine) {
			CallLuaUtil util;
			util.addArg(false);
			if (util.callLua(pScriptEngine->getLuaState(), "SelectServerEntry_EnableClick")) {
				disableServerEntryClick = util.getRetBool();
			}
		}
		if (disableServerEntryClick) {
			EnterMainStatus = eEnterMainStatus_Waiting;
		}
	}
}
