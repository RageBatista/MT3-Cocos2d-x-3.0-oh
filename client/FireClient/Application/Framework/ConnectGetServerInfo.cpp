#include "stdafx.h"
#include "ConnectGetServerInfo.h"
#include "GameApplication.h"
#include "LoginManager.h"
#include "MessageManager.h"
#include "VoiceManager.h"
#include <spine/Json.h>
#include <cstdlib>

#ifdef ANDROID
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

namespace
{
std::string GetJsonValueAsString(Json* json)
{
	if (!json)
	{
		return "";
	}

	if (json->type == Json_String && json->valueString)
	{
		return json->valueString;
	}

	if (json->type == Json_Number)
	{
		return StringCover::intToString(json->valueInt);
	}

	return "";
}

std::string GetJsonFieldAsString(Json* parent, const char* name)
{
	return GetJsonValueAsString(Json_getItem(parent, name));
}

int GetJsonFieldAsInt(Json* parent, const char* name, int defaultValue)
{
	Json* json = Json_getItem(parent, name);
	if (!json)
	{
		return defaultValue;
	}

	if (json->type == Json_Number)
	{
		return json->valueInt;
	}

	if (json->type == Json_String && json->valueString && json->valueString[0] != '\0')
	{
		return std::atoi(json->valueString);
	}

	return defaultValue;
}

bool IsValidServerInfo(const std::string& serverid, const std::string& serverArea, const std::string& serverName,
	const std::string& serverIp, const std::string& serverPort)
{
	return !serverid.empty() && !serverArea.empty() && !serverName.empty() && !serverIp.empty() && !serverPort.empty();
}
}
void ConnectGetServerInfo::connetGetServerlist()
{
	conState = enumGetServerState(eNumNotConnect);
	std::string strUrl = gGetGameApplication()->getServerListAddress();
	if (strUrl.empty())
	{
		strUrl = gGetGameApplication()->getPlatformAddress();
		strUrl += ws2s(GameApplication::GetVersionBaseCaption());
		strUrl += "/";
		strUrl += StringCover::intToString(GameApplication::GetChannel());
		strUrl += "/index.html";
	}

	CCLOG("[ServerList] Request url=%s", strUrl.c_str());
#ifdef ANDROID
	LOGE("[ServerList] Request url=%s", strUrl.c_str());
#endif

	cocos2d::network::HttpRequest* request = new cocos2d::network::HttpRequest;

	request->setUrl(strUrl.c_str());
	request->setRequestType(cocos2d::network::HttpRequest::Type::GET);
	request->setResponseCallback(this, httpresponse_selector(ConnectGetServerInfo::onGetServerlist));

	cocos2d::network::HttpClient* client = cocos2d::network::HttpClient::getInstance();
	client->setTimeoutForConnect(10);
	client->send(request);
	request->release();
}

void ConnectGetServerInfo::connetGetUserInfo()
{
	if (isGetUserInfoSuccessful) return;
	std::string strAccount = ws2s(gGetLoginManager()->GetAccount());
	size_t pos = strAccount.find_first_of(",");
	std::string strUserid = "";
	if (pos != std::wstring::npos)
	{
		strUserid = strAccount.substr(0, pos);
	}
	std::string strUrl = "http://";
#if defined(_LOCOJOY_SDK_) || defined(_YJ_SDK_)
	strUrl += getHttpAdressByEnum(enumServerHttpAdress(eHttpInfoUrl));
	strUrl += "/role/get?gameid=";
	strUrl += StringCover::intToString(cocos2d::gGetScriptEngine()->executeGlobalFunctionWithStringData("GetNumberValueForStrKey", "GET_GAME_ID"));
	strUrl += "&userid=";
	strUrl += strUserid.c_str();
#else
	
	strUrl += getHttpAdressByEnum(enumServerHttpAdress(eHttpInfoUrl));
	strUrl += "/user/api/index.php/role/get?gameid=";
	strUrl += StringCover::intToString(cocos2d::gGetScriptEngine()->executeGlobalFunctionWithStringData("GetNumberValueForStrKey", "GET_GAME_ID"));
	strUrl += "&userid=";
	strUrl += ws2s(gGetLoginManager()->GetAccount());
#endif


	cocos2d::network::HttpRequest* request = new cocos2d::network::HttpRequest;

	request->setUrl(strUrl.c_str());
	//request->setRequestData(data.c_str(), data.length());
	request->setRequestType(cocos2d::network::HttpRequest::Type::GET);
	request->setResponseCallback(this, httpresponse_selector(ConnectGetServerInfo::onGetUserInfo));

	cocos2d::network::HttpClient* client = cocos2d::network::HttpClient::getInstance();
	client->setTimeoutForConnect(10);
	client->send(request);
	request->release();
}

void ConnectGetServerInfo::connetCreateRoleInfo(int serverid, int headid)
{
	std::string strAccount = ws2s(gGetLoginManager()->GetAccount());
	size_t pos = strAccount.find_first_of(",");
	std::string strUserid = "";
	if (pos != std::wstring::npos)
	{
		strUserid = strAccount.substr(0, pos);
	}
	std::string toMD5 = StringCover::intToString(cocos2d::gGetScriptEngine()->executeGlobalFunctionWithStringData("GetNumberValueForStrKey", "GET_GAME_ID")) + "|";
#if defined(_LOCOJOY_SDK_) || defined(_YJ_SDK_)
	toMD5 += strUserid.c_str();
#else
	toMD5 += ws2s(gGetLoginManager()->GetAccount());
#endif

	toMD5 += "|";
	toMD5 += StringCover::intToString(serverid);
	
#ifdef _WIN32
	SECURITY_WIN32::MD5Hash md5;
#else
	SECURITY_LINUX::MD5Hash md5;
#endif

	md5.UpdateSelf((const unsigned char*)toMD5.c_str(), (unsigned int)toMD5.length());
	const unsigned char* dest = md5.Final();

	char szmd5[64] = { 0 };
	for (int i = 0; i < 16; i++)
	{
		snprintf(szmd5, sizeof(szmd5), "%s%02x", szmd5, dest[i]);
	}

	std::string md5Str = szmd5;
	std::string strUrl = "http://";
#if defined(_LOCOJOY_SDK_) || defined(_YJ_SDK_)
	strUrl += getHttpAdressByEnum(enumServerHttpAdress(eHttpInfoUrl));
	strUrl += "/role/set?gameid=";
	strUrl += StringCover::intToString(cocos2d::gGetScriptEngine()->executeGlobalFunctionWithStringData("GetNumberValueForStrKey", "GET_GAME_ID"));
	strUrl += "&userid=";
	strUrl += strUserid.c_str();

#else
	strUrl += getHttpAdressByEnum(enumServerHttpAdress(eHttpInfoUrl));
	strUrl += "/user/api/index.php/role/set?gameid=";
	strUrl += StringCover::intToString(cocos2d::gGetScriptEngine()->executeGlobalFunctionWithStringData("GetNumberValueForStrKey", "GET_GAME_ID"));
	strUrl += "&userid=";
	strUrl += ws2s(gGetLoginManager()->GetAccount());
#endif

	strUrl += "&serverid=";
	strUrl += StringCover::intToString(serverid);
	strUrl += "&icon=";
	strUrl += StringCover::intToString(headid);
	strUrl += "&sign=";
	strUrl += md5Str;

	cocos2d::network::HttpRequest* request = new cocos2d::network::HttpRequest;

	request->setUrl(strUrl.c_str());
	request->setRequestType(cocos2d::network::HttpRequest::Type::GET);
	request->setResponseCallback(this, httpresponse_selector(ConnectGetServerInfo::onSerUserInfo));

	cocos2d::network::HttpClient* client = cocos2d::network::HttpClient::getInstance();
	client->setTimeoutForConnect(10);
	client->send(request);
	request->release();
}

void ConnectGetServerInfo::onGetUserInfo(cocos2d::network::HttpClient* client, cocos2d::network::HttpResponse* response)
{
	int rcode = response->getResponseCode();
	std::string jsonStr;
	bool isSuccess = false;
	if (rcode == 200)
	{
		isGetUserInfoSuccessful = true;
		isSuccess = true;
		std::vector<char>* data = response->getResponseData();
		std::vector<char>::iterator it;
		for (it = data->begin(); it != data->end(); it++)
		{
			jsonStr += *it;
		}
	}

	if (isSuccess)
	{
		Json* root = Json_create(jsonStr.c_str());
		if (root)
		{
			Json* list = Json_getItem(root, "data");
			if (list && list->type == Json_Array)
			{
				Json* child = list->child;
				while (child)
				{
					const char* serverid = "0";
					Json* _serverID = Json_getItem(child, "serverid");
					if (_serverID && _serverID->type == Json_String)
					{
						serverid = _serverID->valueString;
					}

					const char* iconid = "0";
					Json* _iconID = Json_getItem(child, "icon");
					if (_iconID && _iconID->type == Json_String)
					{
						iconid = _iconID->valueString;
					}

					setServerRoleInfoMap(atoi(serverid), atoi(iconid));

					child = child->next;
				}
			}
			Json_dispose(root);
		}
		cocos2d::CCScriptEngineManager::sharedManager()->getScriptEngine()->executeGlobalFunction("SelectServerEntry.setLoadHeadSuccess");
	}
	else
	{
		if (!isRetryGetUserInfo)
		{
			isRetryGetUserInfo = true;
			connetGetUserInfo();
		}
		else
		{
			cocos2d::CCScriptEngineManager::sharedManager()->getScriptEngine()->executeGlobalFunction("SelectServerEntry.setLoadHeadSuccess");
		}
	}
}

void ConnectGetServerInfo::onGetServerlist(cocos2d::network::HttpClient* client, cocos2d::network::HttpResponse* response)
{
	int rcode = response->getResponseCode();
	std::string jsonStr;
	mServers.clear();
	bool isSuccess = false;
	if (rcode == 200)
	{
		isSuccess = true;
		std::vector<char>* data = response->getResponseData();
		std::vector<char>::iterator it;
		for (it = data->begin(); it != data->end(); it++)
		{
			jsonStr += *it;
		}
	}

	if (isSuccess)
	{
		Json* root = Json_create(jsonStr.c_str());
		if (root)
		{
			Json* gameConfig = Json_getItem(root, "GameConfigInfo");
			if (gameConfig && gameConfig->type == Json_Object)
			{
				Json* _pathchUrl = Json_getItem(gameConfig, "PatchUrl");
				if (_pathchUrl && _pathchUrl->type == Json_String)
				{
					setHttpAdressMap(enumServerHttpAdress(eHttpPatchUrl), _pathchUrl->valueString);
				}

				Json* _updateUrl = Json_getItem(gameConfig, "UpdateUrl");
				if (_updateUrl && _updateUrl->type == Json_String)
				{
					setHttpAdressMap(enumServerHttpAdress(eHttpUpdateUrl), _updateUrl->valueString);
				}

				Json* _shareUrl = Json_getItem(gameConfig, "ShareUrl");
				if (_shareUrl && _shareUrl->type == Json_String)
				{
					setHttpAdressMap(enumServerHttpAdress(eHttpShareUrl), _shareUrl->valueString);
				}

				Json* _playerInfoUrl = Json_getItem(gameConfig, "PlayerInfoUrl");
				if (_playerInfoUrl && _playerInfoUrl->type == Json_String)
				{
					setHttpAdressMap(enumServerHttpAdress(eHttpInfoUrl), _playerInfoUrl->valueString);
				}

				Json* _chatUrl = Json_getItem(gameConfig, "ChatUrl");
				if (_chatUrl && _chatUrl->type == Json_String)
				{
					setHttpAdressMap(enumServerHttpAdress(eHttpChatUrl), _chatUrl->valueString);
				}

				Json* _communityUrl = Json_getItem(gameConfig, "CommunityUrl");
				if (_communityUrl && _communityUrl->type == Json_String)
				{
					setHttpAdressMap(enumServerHttpAdress(eHttpCommunityUrl), _communityUrl->valueString);
				}

				Json* _noticeUrl = Json_getItem(gameConfig, "NoticeUrl");
				if (_noticeUrl && _noticeUrl->type == Json_String)
				{
					setHttpAdressMap(enumServerHttpAdress(eHttpNoticeUrl), _noticeUrl->valueString);
				}

				Json* _configUrl = Json_getItem(gameConfig, "ConfigUrl");
				if (_configUrl && _configUrl->type == Json_String)
				{
					setHttpAdressMap(enumServerHttpAdress(eHttpConfigUrl), _configUrl->valueString);
				}

				Json* _serverInfoUrl = Json_getItem(gameConfig, "ServerInfoUrl");
				if (_serverInfoUrl && _serverInfoUrl->type == Json_String)
				{
					setHttpAdressMap(enumServerHttpAdress(eHttpServerInfoUrl), _serverInfoUrl->valueString);
				}

				Json* _xunfeiUrl = Json_getItem(gameConfig, "XunFeiUrl");
				if (_xunfeiUrl && _xunfeiUrl->type == Json_String)
				{
					setHttpAdressMap(enumServerHttpAdress(eHttpXunFeiServerUrl), _xunfeiUrl->valueString);
				}

				Json* _horseUrl = Json_getItem(gameConfig, "HorseRaceUrl");
				if (_horseUrl && _horseUrl->type == Json_String)
				{
					setHttpAdressMap(enumServerHttpAdress(eHttpHorseRunUrl), _horseUrl->valueString);
				}

				Json* _jinglingUrl = Json_getItem(gameConfig, "JingLingUrl");
				if (_jinglingUrl && _jinglingUrl->type == Json_String)
				{
					setHttpAdressMap(enumServerHttpAdress(eHttpJinglingUrl), _jinglingUrl->valueString);
				}

				Json* _kongjianUrl = Json_getItem(gameConfig, "KongJianUrl");
				if (_kongjianUrl && _kongjianUrl->type == Json_String)
				{
					setHttpAdressMap(enumServerHttpAdress(eHttpKongjianUrl), _kongjianUrl->valueString);
				}
			}

			Json* gameAdInfo = Json_getItem(root, "GameAdInfo");
			if (gameAdInfo && gameAdInfo->type == Json_Array)
			{
				Json* child = gameAdInfo->child;
				while (child)
				{
					child = child->next;
				}
			}

			Json* gameServerInfo = Json_getItem(root, "GameServerInfo");
			if (gameServerInfo && gameServerInfo->type == Json_Array)
			{
				Json* child = gameServerInfo->child;
				int skipped = 0;
				while (child)
				{
					int bianhao = GetJsonFieldAsInt(child, "I", -1);
					std::string serverid = GetJsonFieldAsString(child, "D");
					std::string serverArea = GetJsonFieldAsString(child, "A");
					std::string serverName = GetJsonFieldAsString(child, "N");
					std::string serverIp = GetJsonFieldAsString(child, "P");
					std::string serverPort = GetJsonFieldAsString(child, "T");
					std::string serverState = GetJsonFieldAsString(child, "S");
					std::string serverStandby = GetJsonFieldAsString(child, "B");
					std::string serverType = GetJsonFieldAsString(child, "C");
					std::string serverOpenTime = GetJsonFieldAsString(child, "KS");
					std::string serverFlag = GetJsonFieldAsString(child, "NS");

					if (IsValidServerInfo(serverid, serverArea, serverName, serverIp, serverPort))
					{
						stServerINFO serverInfo;
						serverInfo.areaID = bianhao;
						serverInfo.serverid = s2ws(serverid);
						serverInfo.serverArea = s2ws(serverArea);
						serverInfo.serverName = s2ws(serverName);
						serverInfo.serverIp = s2ws(serverIp);
						serverInfo.serverPort = s2ws(serverPort);
						serverInfo.serverState = s2ws(serverState);
						serverInfo.serverStandby = s2ws(serverStandby.empty() ? "1" : serverStandby);
						serverInfo.serverType = s2ws(serverType);
						serverInfo.serverOpenTime = s2ws(serverOpenTime);
						serverInfo.serverFlag = s2ws(serverFlag);

						mServers.push_back(serverInfo);
					}
					else
					{
						++skipped;
#ifdef ANDROID
						LOGE("[ServerList] Skip invalid server id=%s area=%s name=%s ip=%s port=%s", serverid.c_str(), serverArea.c_str(), serverName.c_str(), serverIp.c_str(), serverPort.c_str());
#endif
					}

					child = child->next;
				}
#ifdef ANDROID
				LOGE("[ServerList] Parsed servers=%d skipped=%d", static_cast<int>(mServers.size()), skipped);
#endif
			}

			Json_dispose(root);
		}
		if (mServers.empty())
		{
			isSuccess = false;
			conState = enumGetServerState(eNumConnectFailed);
		}
		else
		{
			conState = enumGetServerState(eNumConnectSuccess);
		}
	}
	else //����ʧ��
	{
		conState = enumGetServerState(eNumConnectFailed);
	}

#ifdef ANDROID
	LOGE("ConnectGetServerInfo::onGetServerlist code=%d bytes=%d isSuccess=%d servers=%d", rcode, static_cast<int>(jsonStr.size()), isSuccess ? 1 : 0, static_cast<int>(mServers.size()));
#endif

#if CC_TARGET_PLATFORM == CC_PLATFORM_IOS
	gGetGameApplication()->saveQuincyServerAddress(s2ws(getHttpAdressByEnum(eHttpConfigUrl)));
#endif

	doAfterGetServerListData();
}

void ConnectGetServerInfo::doAfterGetServerListData()
{
	if (isLoginConnecting)
	{
		if (conState == eNumConnectSuccess)
		{
			cocos2d::CCScriptEngineManager::sharedManager()->getScriptEngine()->executeGlobalFunctionWithIntegerData("SelectServerEntry.SetGetServerResult", 1);

			// ��������Ѷ�ɵ�Token
			gGetGetTextManager()->tryRequestToken();

// upload Android dump files
#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
			MT3::JniMethodInfo methodInfo;
			if (MT3::JniHelper::getStaticMethodInfo(methodInfo,
				"com/locojoy/mini/mt3/GameApp", "uploadDumpFile", "()V"))
			{
				methodInfo.env->CallStaticVoidMethod(methodInfo.classID, methodInfo.methodID);
				methodInfo.env->DeleteLocalRef(methodInfo.classID);
			}
#endif
		}
		else if (conState == eNumConnectFailed)
		{
			cocos2d::CCScriptEngineManager::sharedManager()->getScriptEngine()->executeGlobalFunctionWithIntegerData("SelectServerEntry.SetGetServerResult", 0);
			std::wstring strMsg(MHSD_UTILS::GETSTRING(11311).c_str());
			gGetMessageManager()->AddConfirmBox(eConfirmOK, strMsg, CEGUI::Event::Subscriber(&MessageManager::HandleDefaultCancelEvent), CEGUI::Event::Subscriber(&MessageManager::HandleDefaultCancelEvent));
		}
	}
}

void ConnectGetServerInfo::onSerUserInfo(cocos2d::network::HttpClient* client, cocos2d::network::HttpResponse* response)
{

}

void ConnectGetServerInfo::setHttpAdressMap(enumServerHttpAdress em, std::string value)
{
	httpAdressMap[em] = value;
}

int ConnectGetServerInfo::getRoleHeadInfoByServerID(int serverID)
{
	if (roleServerInfoMap.count(serverID) > 0)
		return roleServerInfoMap[serverID];
	else
		return -1;
}

void ConnectGetServerInfo::setServerRoleInfoMap(int key, int value)
{
	roleServerInfoMap[key] = value;
}

std::string ConnectGetServerInfo::getHttpAdressByEnum(enumServerHttpAdress em)
{
	std::string address;
	if (httpAdressMap.count(em) > 0)
	{
		address = httpAdressMap[em];
	}

	if (address.length() > 0)
	{
		return address;
	}

	switch (em)
	{
	case eHttpShareUrl:
		address = gGetGameApplication()->getAndroidDumpAddress();
		break;
	case eHttpInfoUrl:
		address = gGetGameApplication()->getUserHeadAddress();
		break;
	case eHttpChatUrl:
		address = gGetGameApplication()->getVoiceAddress();
		break;
	case eHttpCommunityUrl:
		address = gGetGameApplication()->getBBSAdress();
		break;
	case eHttpNoticeUrl:
		address = gGetGameApplication()->getNewswarnAddress();
		break;
	case eHttpConfigUrl:
		address = gGetGameApplication()->getIOSDumpAddress();
		break;
	case eHttpServerInfoUrl:
		address = gGetGameApplication()->getChatAcessAddress();
		break;
	case eHttpHorseRunUrl:
		address = gGetGameApplication()->getJubaoAddress();
		break;
	case eHttpJinglingUrl:
		address = gGetGameApplication()->getDashiAddress();
		break;
	case eHttpKongjianUrl:
		address = gGetGameApplication()->getSpaceAddress();
		break;
	}

	return address;
}

/*
http://bbs.locojoy.com/gameloginatserver.php?username=xwtest100201&date=20160321&rand=2323&sign=62e8094b603c9807b4b2c0c559b0cce2
�ֶ�˵����
�ֶ���	˵��	��ע
username	�û���	ȷ��Ψһ��
date	����	��ʽ��20160321
rand	�������	�����4λ��
sign	��ϼ��ܺ���ַ���	MD5 32λ��Сд��
sign �ֶμ���˵����md5(username + date + rand);*/

void ConnectGetServerInfo::doEnterBBS(){
	std::string bbsUrl = getHttpAdressByEnum(enumServerHttpAdress(eHttpCommunityUrl));
	std::string toMd5Str = "";

	bbsUrl += "username=";
//--------------username----------------------------
	std::string strAccount = ws2s(gGetLoginManager()->GetAccount());
	size_t pos = strAccount.find_first_of("@");
	std::string strUserName = "";
	if (pos != std::wstring::npos)
	{
		strUserName = strAccount.substr(0, pos);
	}

	toMd5Str += strUserName;
	bbsUrl += strUserName;

	//--------------date----------------------------
	std::wstring strTime(L"");
	time_t et = gGetServerTime() / 1000;
	struct tm times;
	localtime_s(&times, &et);
	StringCover::FormatString(strTime, L"%04d%02d%02d", times.tm_year + 1900, times.tm_mon + 1, times.tm_mday);
	std::string date = ws2s(strTime);

	toMd5Str += date;
	bbsUrl += "&date=";
	bbsUrl += date;
	//--------------rand----------------------------
	int ranNum = StringCover::randBetween(1000, 9999);
	std::string randStr = StringCover::intToString(ranNum);

	toMd5Str += randStr;
	bbsUrl += "&rand=";
	bbsUrl += randStr;

	//------------sign--md5----------------------
#ifdef _WIN32
	SECURITY_WIN32::MD5Hash md5;
#else
	SECURITY_LINUX::MD5Hash md5;
#endif

	md5.UpdateSelf((const unsigned char*)toMd5Str.c_str(), (unsigned int)toMd5Str.length());
	const unsigned char* dest = md5.Final();

	char szmd5[64] = { 0 };
	for (int i = 0; i < 16; i++)
	{
		snprintf(szmd5, sizeof(szmd5), "%s%02x", szmd5, dest[i]);
	}

	std::string md5Str = szmd5;
	bbsUrl += "&sign=";
	bbsUrl += md5Str;

	IOS_MHSD_UTILS::OpenURL(bbsUrl);
}

void ConnectGetServerInfo::doRequestJingLingQuest(int id) 
{
	std::string strUrl = "";
	//id > 1000 �Ǿ����������id 
	if (id > 1000)
	{
		strUrl = getHttpAdressByEnum(eHttpJinglingUrl) + "/faq/detail?faq_id=" + StringCover::intToString(id);
	}
	else
	{
		strUrl = getHttpAdressByEnum(eHttpJinglingUrl) + "/faq/getListByColumn?column_id=" + StringCover::intToString(id);
	}

	if (strUrl != "")
	{
		cocos2d::network::HttpRequest* request = new cocos2d::network::HttpRequest;

		request->setUrl(strUrl.c_str());
		request->setRequestType(cocos2d::network::HttpRequest::Type::GET);
		if (id > 1000)
		{
			request->setResponseCallback(this, httpresponse_selector(ConnectGetServerInfo::onGetSingelAnswer));
		}
		else
		{
			request->setResponseCallback(this, httpresponse_selector(ConnectGetServerInfo::onGetJingLingData));
		}

		cocos2d::network::HttpClient* client = cocos2d::network::HttpClient::getInstance();
		client->setTimeoutForConnect(10);
		client->send(request);
		request->release();

		m_currentRequestID = id;
	}

}

void ConnectGetServerInfo::onGetJingLingData(cocos2d::network::HttpClient* client, cocos2d::network::HttpResponse* response)
{
	int rcode = response->getResponseCode();
	std::string jsonStr;
	bool isSuccess = false;
	if (rcode == 200)
	{
		isSuccess = true;
		std::vector<char>* data = response->getResponseData();
		std::vector<char>::iterator it;
		for (it = data->begin(); it != data->end(); it++)
		{
			jsonStr += *it;
		}
	}

	if (isSuccess)
	{
		Json* root = Json_create(jsonStr.c_str());
		if (root)
		{
			Json* list = Json_getItem(root, "data");
			if (list && list->type == Json_Array)
			{
				Json* child = list->child;
				while (child)
				{
					std::string faqrid = "";
					Json* _faqrid = Json_getItem(child, "faq_id");
					if (_faqrid && _faqrid->type == Json_String)
					{
						faqrid = _faqrid->valueString;
					}

					std::string title = "";
					Json* _title = Json_getItem(child, "title");
					if (_title && _title->type == Json_String)
					{
						title = _title->valueString;
					}

					std::string categoryid = "";
					Json* _categoryid = Json_getItem(child, "category_id");
					if (_categoryid && _categoryid->type == Json_String)
					{
						categoryid = _categoryid->valueString;
					}

					std::string style = "";
					Json* _style = Json_getItem(child, "style");
					if (_style && _style->type == Json_String)
					{
						style = _style->valueString;
					}

					std::string sort = "";
					Json* _sort = Json_getItem(child, "sort");
					if (_sort && _sort->type == Json_String)
					{
						sort = _sort->valueString;
					}

					std::string status = "";
					Json* _status = Json_getItem(child, "status");
					if (_status && _status->type == Json_String)
					{
						status = _status->valueString;
					}

					std::string content = "";
					Json* _content = Json_getItem(child, "content");
					if (_content && _content->type == Json_String)
					{
						content = _content->valueString;
					}

					stJinglingINFO jinglingInfo;
					jinglingInfo.jl_faqid = faqrid;
					jinglingInfo.jl_title = title;
					jinglingInfo.jl_categoryid = categoryid;
					jinglingInfo.jl_style = style;
					jinglingInfo.jl_sort = sort;
					jinglingInfo.jl_status = status;
					jinglingInfo.jl_content = content;
					jinglingDataMap[StringCover::StrToNum<int>(faqrid)] = jinglingInfo;
					child = child->next;

					if (m_currentRequestID == cocos2d::CCScriptEngineManager::sharedManager()->getScriptEngine()->executeGlobalFunctionWithStringData("GetNumberValueForStrKey", "JINGLING_COLUM_REDIAN"))
					{
						checkVectorContainsAndInsert(redianIds, StringCover::StrToNum<int>(faqrid));
					}
					else if (m_currentRequestID == cocos2d::CCScriptEngineManager::sharedManager()->getScriptEngine()->executeGlobalFunctionWithStringData("GetNumberValueForStrKey", "JINGLING_COLUM_TUIJIAN"))
					{
						checkVectorContainsAndInsert(tuijianIds, StringCover::StrToNum<int>(faqrid));
					}
					else if (m_currentRequestID == cocos2d::CCScriptEngineManager::sharedManager()->getScriptEngine()->executeGlobalFunctionWithStringData("GetNumberValueForStrKey", "JINGLING_COLUM_KEFU"))
					{
						checkVectorContainsAndInsert(kefuIds, StringCover::StrToNum<int>(faqrid));
					}
				}
			}
			Json_dispose(root);
		}

		cocos2d::CCScriptEngineManager::sharedManager()->getScriptEngine()->executeGlobalFunctionWithIntegerData("JinglingDlg.sendHttpConnectReturned", m_currentRequestID);
	}
}

void ConnectGetServerInfo::onGetSingelAnswer(cocos2d::network::HttpClient* client, cocos2d::network::HttpResponse* response)
{
	int rcode = response->getResponseCode();
	std::string jsonStr;
	bool isSuccess = false;
	if (rcode == 200)
	{
		isSuccess = true;
		std::vector<char>* data = response->getResponseData();
		std::vector<char>::iterator it;
		for (it = data->begin(); it != data->end(); it++)
		{
			jsonStr += *it;
		}
	}

	if (isSuccess)
	{
		Json* root = Json_create(jsonStr.c_str());
		if (root)
		{
			Json* error = Json_getItem(root, "errno");
			if (error && error->type == Json_String)
			{
				std::string errorno = error->valueString;
				if (errorno.length() > 0) //�Ƿ���ڴ����
				{
					cocos2d::CCScriptEngineManager::sharedManager()->getScriptEngine()->executeGlobalFunction("JinglingDlg.doGotResponseNoMatch");
					Json_dispose(root);
					return;
				}
			}

			Json* data = Json_getItem(root, "data");
			if (data && data->type == Json_Object)
			{
				std::string faqrid = "";
				Json* _faqrid = Json_getItem(data, "faq_id");
				if (_faqrid && _faqrid->type == Json_String)
				{
					faqrid = _faqrid->valueString;
				}

				std::string title = "";
				Json* _title = Json_getItem(data, "title");
				if (_title && _title->type == Json_String)
				{
					title = _title->valueString;
				}

				std::string categoryid = "";
				Json* _categoryid = Json_getItem(data, "category_id");
				if (_categoryid && _categoryid->type == Json_String)
				{
					categoryid = _categoryid->valueString;
				}

				std::string style = "";
				Json* _style = Json_getItem(data, "style");
				if (_style && _style->type == Json_String)
				{
					style = _style->valueString;
				}

				std::string sort = "";
				Json* _sort = Json_getItem(data, "sort");
				if (_sort && _sort->type == Json_String)
				{
					sort = _sort->valueString;
				}

				std::string status = "";
				Json* _status = Json_getItem(data, "status");
				if (_status && _status->type == Json_String)
				{
					status = _status->valueString;
				}

				std::string content = "";
				Json* _content = Json_getItem(data, "content");
				if (_content && _content->type == Json_String)
				{
					content = _content->valueString;
				}

				stJinglingINFO jinglingInfo;
				jinglingInfo.jl_faqid = faqrid;
				jinglingInfo.jl_title = title;
				jinglingInfo.jl_categoryid = categoryid;
				jinglingInfo.jl_style = style;
				jinglingInfo.jl_sort = sort;
				jinglingInfo.jl_status = status;
				jinglingInfo.jl_content = content;
				jinglingDataMap[StringCover::StrToNum<int>(faqrid)] = jinglingInfo;
			}
			Json_dispose(root);
		}

		cocos2d::CCScriptEngineManager::sharedManager()->getScriptEngine()->executeGlobalFunctionWithIntegerData("JinglingDlg.sendHttpConnectReturned", m_currentRequestID);
	}
}

void ConnectGetServerInfo::onGetSearchData(cocos2d::network::HttpClient* client, cocos2d::network::HttpResponse* response)
{
	int rcode = response->getResponseCode();
	std::string jsonStr;
	bool isSuccess = false;
	if (rcode == 200)
	{
		isSuccess = true;
		std::vector<char>* data = response->getResponseData();
		std::vector<char>::iterator it;
		for (it = data->begin(); it != data->end(); it++)
		{
			jsonStr += *it;
		}
	}

	if (isSuccess)
	{
		bool isMatch = false;
		bool isGotList = false;
		Json* root = Json_create(jsonStr.c_str());
		if (root)
		{
			Json* data = Json_getItem(root, "data");
			if (data && data->type == Json_Object)
			{
				int count = 0;
				Json* _count = Json_getItem(data, "count");
				if (_count && _count->type == Json_Number)
				{
					count = _count->valueInt;
				}
				if (count == 0)
				{
					cocos2d::CCScriptEngineManager::sharedManager()->getScriptEngine()->executeGlobalFunction("JinglingDlg.doGotResponseNoMatch");
				}

				if (count != 0)
				{
					Json* _info = Json_getItem(data, "info");
					if (_info && _info->type == Json_Object)
					{
						isMatch = true;
						std::string content = "";
						Json* _content = Json_getItem(_info, "content");
						if (_content && _content->type == Json_String)
						{
							content = _content->valueString;
						}
						cocos2d::CCScriptEngineManager::sharedManager()->getScriptEngine()->executeGlobalFunctionWithStringData("JinglingDlg.doGotResponseMatch", content.c_str());
					}
				}

				if (!isMatch && count != 0) //���û���ҵ�info ˵�����Ǿ�ȷƥ��
				{
					std::string key = "";
					Json* _key = Json_getItem(data, "q");
					if (_key && _key->type == Json_String)
					{
						key = _key->valueString;
					}
					std::vector<stQuestTitleID> rValueVector;

					Json* _list = Json_getItem(data, "list");
					if (_list && _list->type == Json_Array)
					{
						isGotList = true;
						Json* child = _list->child;
						while (child)
						{
							std::string faqrid = "";
							Json* _faqrid = Json_getItem(child, "faq_id");
							if (_faqrid && _faqrid->type == Json_String)
							{
								faqrid = _faqrid->valueString;
							}

							std::string title = "";
							Json* _title = Json_getItem(child, "title");
							if (_title && _title->type == Json_String)
							{
								title = _title->valueString;
							}

							stQuestTitleID qInfo;
							qInfo.qid = faqrid;
							qInfo.qtitle = title;
							rValueVector.push_back(qInfo);

							child = child->next;
						}
						questWidthoutContent[key] = rValueVector;
					}
					cocos2d::CCScriptEngineManager::sharedManager()->getScriptEngine()->executeGlobalFunctionWithStringData("JinglingDlg.doGotResponseList", key.c_str());
				}

			}
			Json_dispose(root);
		}

	}
}

void ConnectGetServerInfo::doRequestSearchData(std::string keyWord)
{
	if (keyWord == "") return;

	std::string strUrl = getHttpAdressByEnum(eHttpJinglingUrl) + "/faq/search?q=" + keyWord;

	cocos2d::network::HttpRequest* request = new cocos2d::network::HttpRequest;
	request->setUrl(strUrl.c_str());
	request->setRequestType(cocos2d::network::HttpRequest::Type::GET);
	request->setResponseCallback(this, httpresponse_selector(ConnectGetServerInfo::onGetSearchData));


	cocos2d::network::HttpClient* client = cocos2d::network::HttpClient::getInstance();
	client->setTimeoutForConnect(10);
	client->send(request);
	request->release();
}


void ConnectGetServerInfo::clearJinglingData()
{
	jinglingDataMap.clear();
	redianIds.clear();
	tuijianIds.clear();
	kefuIds.clear();
	questWidthoutContent.clear();
}

void ConnectGetServerInfo::getRedianIds(std::vector<int>& ids)
{
	for (std::vector<int>::iterator iter = redianIds.begin(); iter != redianIds.end(); iter++)
	{
		ids.push_back((*iter));
	}
}

void ConnectGetServerInfo::getTuijianIds(std::vector<int>& ids)
{
	for (std::vector<int>::iterator iter = tuijianIds.begin(); iter != tuijianIds.end(); iter++)
	{
		ids.push_back((*iter));
	}
}

void ConnectGetServerInfo::getKefuIds(std::vector<int>& ids)
{
	for (std::vector<int>::iterator iter = kefuIds.begin(); iter != kefuIds.end(); iter++)
	{
		ids.push_back((*iter));
	}
}

void ConnectGetServerInfo::getSearchResultList(std::string q, std::vector<stQuestTitleID>& ids)
{
	std::vector<stQuestTitleID> lists = questWidthoutContent.at(q);
	for (std::vector<stQuestTitleID>::iterator iter = lists.begin(); iter != lists.end(); iter++)
	{
		ids.push_back((*iter));
	}
}

stJinglingINFO ConnectGetServerInfo::getJinglingDataByID(int id)
{
	for (std::map<int, stJinglingINFO>::const_iterator iter = jinglingDataMap.begin(); iter != jinglingDataMap.end(); iter++)
	{
		if (iter->first == id)
		{
			return iter->second;
		}
	}
	return stJinglingINFO();
}

void ConnectGetServerInfo::checkVectorContainsAndInsert(std::vector<int>& vec, int value)
{
	bool isContains = false;
	for (std::vector<int>::iterator iter = vec.begin(); iter != vec.end(); iter++)
	{
		if ((*iter) == value)
		{
			isContains = true;
			break;
		}
	}
	if (!isContains)
	{
		vec.push_back(value);
	}
}

void ConnectGetServerInfo::clearHeadInfo()
{
	isGetUserInfoSuccessful = false;
	isRetryGetUserInfo = false;
	roleServerInfoMap.clear();
}

ConnectGetServerInfo::ConnectGetServerInfo()
:isLoginConnecting(false)
, isRetryGetUserInfo(false)
, isGetUserInfoSuccessful(false)
{
	conState = enumGetServerState(eNumNotConnect);
}

ConnectGetServerInfo::~ConnectGetServerInfo()
{
}
void ConnectGetServerInfo::HandleCheckRecruit(cocos2d::network::HttpClient* client, cocos2d::network::HttpResponse* response){
	int rcode = response->getResponseCode();
	std::string jsonStr;
	bool isSuccess = false;
	if (rcode == 200)
	{
		isSuccess = true;
		std::vector<char>* data = response->getResponseData();
		std::vector<char>::iterator it;
		for (it = data->begin(); it != data->end(); it++)
		{
			jsonStr += *it;
		}
	}else{
		cocos2d::CCScriptEngineManager::sharedManager()->getScriptEngine()->executeString("require \"logic.createroledialog\":CheckRecruitFail()");
	}

	if (isSuccess)
	{
		Json* root = Json_create(jsonStr.c_str());
		if (root)
		{
			Json* error = Json_getItem(root, "errno");
			if (error && error->type == Json_String)
			{
				std::string errorno = error->valueString;
				if (errorno.length() > 0) //�Ƿ���ڴ����
				{
					cocos2d::CCScriptEngineManager::sharedManager()->getScriptEngine()->executeString("require \"logic.createroledialog\":CheckRecruitFail()");
					Json_dispose(root);
					return;
				}
			}

			Json* data = Json_getItem(root, "data");
			if (data && data->type == Json_True)
			{
				cocos2d::CCScriptEngineManager::sharedManager()->getScriptEngine()->executeString("require \"logic.createroledialog\":CheckRecruitSuccess()");
			}
			Json_dispose(root);
		}
	}
}
void ConnectGetServerInfo::HandleCheckRecruitAndRole(cocos2d::network::HttpClient* client, cocos2d::network::HttpResponse* response){

}
void ConnectGetServerInfo::HandleSendRecruitCode(cocos2d::network::HttpClient* client, cocos2d::network::HttpResponse* response){

}
void ConnectGetServerInfo::HandleGetRecruitList(cocos2d::network::HttpClient* client, cocos2d::network::HttpResponse* response){
	int rcode = response->getResponseCode();
	std::string jsonStr;
	bool isSuccess = false;
	if (rcode == 200)
	{
		isSuccess = true;
		std::vector<char>* data = response->getResponseData();
		std::vector<char>::iterator it;
		for (it = data->begin(); it != data->end(); it++)
		{
			jsonStr += *it;
		}
	}
	else{
		cocos2d::CCScriptEngineManager::sharedManager()->getScriptEngine()->executeString("require \"logic.recruit.recruitdlg\":getRecruitListFail()");
	}

	if (isSuccess)
	{
		Json* root = Json_create(jsonStr.c_str());
		if (root)
		{
			Json* error = Json_getItem(root, "errno");
			if (error && error->type == Json_String)
			{
				std::string errorno = error->valueString;
				if (errorno.length() > 0) //�Ƿ���ڴ����
				{
					cocos2d::CCScriptEngineManager::sharedManager()->getScriptEngine()->executeString("require \"logic.recruit.recruitdlg\":getRecruitListFail()");
					Json_dispose(root);
					return;
				}
			}

			Json* data = Json_getItem(root, "data");
			if (data && data->type == Json_Array)
			{
				m_RecruitList.clear();
				Json* child = data->child;
				while (child)
				{
					std::string roleid = "";
					Json* _roleid = Json_getItem(child, "roleid");
					if (_roleid && _roleid->type == Json_String)
					{
						roleid = _roleid->valueString;
					}

					std::string name = "";
					Json* _name = Json_getItem(child, "name");
					if (_name && _name->type == Json_String)
					{
						name = _name->valueString;
					}
					std::string avatar = "";
					Json* _avatar = Json_getItem(child, "avatar");
					if (_avatar && _avatar->type == Json_String)
					{
						avatar = _avatar->valueString;
					}
					std::string level = "";
					Json* _level = Json_getItem(child, "level");
					if (_level && _level->type == Json_String)
					{
						level = _level->valueString;
					}
					std::string servername = "";
					Json* _servername = Json_getItem(child, "servername");
					if (_servername && _servername->type == Json_String)
					{
						servername = _servername->valueString;
					}
					std::string serverid = "";
					Json* _serverid = Json_getItem(child, "serverid");
					if (_serverid && _serverid->type == Json_String)
					{
						serverid = _serverid->valueString;
					}
					stRecruitList list;
					list.roleid = roleid;
					list.name = name;
					list.avatar = avatar;
					list.level = level;
					list.servername = servername;
					list.serverid = serverid;
					m_RecruitList.push_back(list);
					child = child->next;
				}

			}
			Json_dispose(root);
			cocos2d::CCScriptEngineManager::sharedManager()->getScriptEngine()->executeString("require \"logic.recruit.recruitdlg\":getRecruitListSuccess()");
		}
		else{
			cocos2d::CCScriptEngineManager::sharedManager()->getScriptEngine()->executeString("require \"logic.recruit.recruitdlg\":getRecruitListSuccess()");
		}

	}
}
void ConnectGetServerInfo::HandleCheckRecruitOneRole(cocos2d::network::HttpClient* client, cocos2d::network::HttpResponse* response){
	m_RecruitRoleList.clear();
	int rcode = response->getResponseCode();
	std::string jsonStr;
	bool isSuccess = false;
	if (rcode == 200)
	{
		isSuccess = true;
		std::vector<char>* data = response->getResponseData();
		std::vector<char>::iterator it;
		for (it = data->begin(); it != data->end(); it++)
		{
			jsonStr += *it;
		}
	}
	else{
		cocos2d::CCScriptEngineManager::sharedManager()->getScriptEngine()->executeString("require \"logic.recruit.recruitdlg\":getOneRoleFail()");
	}

	if (isSuccess)
	{
		Json* root = Json_create(jsonStr.c_str());
		if (root)
		{
			Json* error = Json_getItem(root, "errno");
			if (error && error->type == Json_String)
			{
				std::string errorno = error->valueString;
				if (errorno.length() > 0) //�Ƿ���ڴ����
				{
					cocos2d::CCScriptEngineManager::sharedManager()->getScriptEngine()->executeString("require \"logic.recruit.recruitdlg\":getOneRoleFail()");
					Json_dispose(root);
					return;
				}
			}

			Json* data = Json_getItem(root, "data");
			if (data && data->type == Json_Array)
			{
				m_RecruitRoleList.clear();
				Json* child = data->child;
				while (child)
				{
					std::string roleid = "";
					Json* _roleid = Json_getItem(child, "roleid");
					if (_roleid && _roleid->type == Json_String)
					{
						roleid = _roleid->valueString;
					}

					std::string serverid = "";
					Json* _serverid = Json_getItem(child, "serverid");
					if (_serverid && _serverid->type == Json_String)
					{
						serverid = _serverid->valueString;
					}
					std::string new_serverid = "";
					Json* _new_serverid = Json_getItem(child, "new_serverid");
					if (_new_serverid && _new_serverid->type == Json_String)
					{
						new_serverid = _new_serverid->valueString;
					}
					std::string new_roleid = "";
					Json* _new_roleid = Json_getItem(child, "new_roleid");
					if (_new_roleid && _new_roleid->type == Json_String)
					{
						new_roleid = _new_roleid->valueString;
					}
					std::string prize_type = "";
					Json* _prize_type = Json_getItem(child, "prize_type");
					if (_prize_type && _prize_type->type == Json_String)
					{
						prize_type = _prize_type->valueString;
					}
					std::string amount = "";
					Json* _amount = Json_getItem(child, "amount");
					if (_amount && _amount->type == Json_String)
					{
						amount = _amount->valueString;
					}
					stRecruitOneRoleData list;
					list.roleid = roleid;
					list.serverid = serverid;
					list.new_serverid = new_serverid;
					list.new_roleid = new_roleid;
					list.prize_type = prize_type;
					list.amount = amount;
					m_RecruitRoleList.push_back(list);
					child = child->next;
				}

			}
			Json_dispose(root);
			cocos2d::CCScriptEngineManager::sharedManager()->getScriptEngine()->executeString("require \"logic.recruit.recruitdlg\":getRecruitOneSuccess()");
		}
		else{
			cocos2d::CCScriptEngineManager::sharedManager()->getScriptEngine()->executeString("require \"logic.recruit.recruitdlg\":getRecruitOneSuccess()");
		}

	}

}
void ConnectGetServerInfo::HandlegetRecruitInfo(cocos2d::network::HttpClient* client, cocos2d::network::HttpResponse* response){
	int rcode = response->getResponseCode();
	std::string jsonStr;
	bool isSuccess = false;
	if (rcode == 200)
	{
		isSuccess = true;
		std::vector<char>* data = response->getResponseData();
		std::vector<char>::iterator it;
		for (it = data->begin(); it != data->end(); it++)
		{
			jsonStr += *it;
		}
	}
	else{
		cocos2d::CCScriptEngineManager::sharedManager()->getScriptEngine()->executeString("require \"logic.recruit.recruitdlg\":getRecruitFail()");
	}

	if (isSuccess)
	{
		Json* root = Json_create(jsonStr.c_str());
		if (root)
		{
			Json* error = Json_getItem(root, "errno");
			if (error && error->type == Json_String)
			{
				std::string errorno = error->valueString;
				if (errorno.length() > 0) //�Ƿ���ڴ����
				{
					cocos2d::CCScriptEngineManager::sharedManager()->getScriptEngine()->executeString("require \"logic.recruit.recruitdlg\":getRecruitFail()");
					Json_dispose(root);
					return;
				}
			}

			Json* data = Json_getItem(root, "data");
			if (data && data->type == Json_Object)
			{
				int total = 0;
				Json* _total = Json_getItem(data, "total");
				if (_total && _total->type == Json_Number)
				{
					total = _total->valueInt;
				}

				std::string times_item = "";
				Json* _times_item = Json_getItem(data, "times_item");
				if (_times_item && _times_item->type == Json_String)
				{
					times_item = _times_item->valueString;
				}
				stRecruitData data;
				data.total = total;
				data.times_item = times_item;
				m_RecruitData = data;
			}
			Json_dispose(root);
			cocos2d::CCScriptEngineManager::sharedManager()->getScriptEngine()->executeString("require \"logic.recruit.recruitdlg\":getRecruitSuccess()");
		}else{
			stRecruitData data;
			data.total = 0;
			data.times_item = "";
			m_RecruitData = data;
			cocos2d::CCScriptEngineManager::sharedManager()->getScriptEngine()->executeString("require \"logic.recruit.recruitdlg\":getRecruitSuccess()");
		}

	}

}
void ConnectGetServerInfo::connetGetRecruitInfo(char* url, int index){
	cocos2d::network::HttpRequest* request = new cocos2d::network::HttpRequest;

	request->setUrl(url);
	request->setRequestType(cocos2d::network::HttpRequest::Type::GET);
	switch (index)
	{
	case 0:{
		request->setResponseCallback(this, httpresponse_selector(ConnectGetServerInfo::HandleCheckRecruit));
		break;
	}
	case 1:{
		request->setResponseCallback(this, httpresponse_selector(ConnectGetServerInfo::HandleCheckRecruitAndRole));
		break;
	}
	case 2:{
		request->setResponseCallback(this, httpresponse_selector(ConnectGetServerInfo::HandleSendRecruitCode));
		break;
	}
	case 3:{
		request->setResponseCallback(this, httpresponse_selector(ConnectGetServerInfo::HandleGetRecruitList));
		break;
	}
	case 4:{
		request->setResponseCallback(this, httpresponse_selector(ConnectGetServerInfo::HandleCheckRecruitOneRole));
		break;
	}
	case 5:{
		request->setResponseCallback(this, httpresponse_selector(ConnectGetServerInfo::HandlegetRecruitInfo));
		break;
	}
	default:
		return;
		break;
	}
	cocos2d::network::HttpClient* client = cocos2d::network::HttpClient::getInstance();
	client->setTimeoutForConnect(10);
	client->send(request);
	request->release();
}