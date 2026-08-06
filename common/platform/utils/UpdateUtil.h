#ifndef UpdateUtil_H
#define UpdateUtil_H

#include "Singleton.hpp"
#include "base/CCRef.h"
#include "network/HttpClient.h"
#include "network/HttpRequest.h"
#include "network/HttpResponse.h"

#include "JsonUtil.h"
#include "StringCover.h"

//#include "Framework/ConnectGetServerInfo.h"

typedef void(*SetDownloadSite_Func)(std::wstring DownloadSite, std::wstring AppSite, std::wstring WGSite);

class UpdateJson : public cocos2d::Ref, public CSingleton < UpdateJson >
{
public:
	SetDownloadSite_Func m_SetDownloadSite_Func;
	std::wstring m_RequestUrlRoot;
	bool m_HasRetriedRequest;

	UpdateJson()
	{
		m_SetDownloadSite_Func = NULL;
		m_HasRetriedRequest = false;
	}

	~UpdateJson()
	{
		m_SetDownloadSite_Func = NULL;
	}

	void SetCB_SetDownloadSite_Func(SetDownloadSite_Func ASetDownloadSite_Func)
	{
		m_SetDownloadSite_Func = ASetDownloadSite_Func;
	}

	void SendUpdateJsonRequest(const std::wstring& wsURLFull)
	{
		std::string strUrl = StringCover::to_string(wsURLFull);

		cocos2d::network::HttpRequest* request = new cocos2d::network::HttpRequest;
		request->setUrl(strUrl.c_str());
		request->setRequestType(cocos2d::network::HttpRequest::Type::GET);
		request->setResponseCallback(this, httpresponse_selector(UpdateJson::onGetUpdateJson));

		cocos2d::network::HttpClient* client = cocos2d::network::HttpClient::getInstance();
		client->setTimeoutForConnect(10);
		client->send(request);
		request->release();
	}

	bool RetryWithFallbackIfNeeded()
	{
		if (m_HasRetriedRequest || m_RequestUrlRoot.empty())
		{
			return false;
		}
		m_HasRetriedRequest = true;
		SendUpdateJsonRequest(m_RequestUrlRoot + L"index.html");
		return true;
	}

	void onGetUpdateJson(cocos2d::network::HttpClient* client, cocos2d::network::HttpResponse* response)
	{
		if (!response)
		{
			if (RetryWithFallbackIfNeeded())
			{
				return;
			}
		}
		int rcode = response ? response->getResponseCode() : -1;
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

		std::string sDownloadSite;
		std::string sAppSite;
		std::string sWGSite;

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
						sDownloadSite = _pathchUrl->valueString;
					}

					Json* _updateUrl = Json_getItem(gameConfig, "UpdateUrl");
					if (_updateUrl && _updateUrl->type == Json_String)
					{
						sAppSite = _updateUrl->valueString;
					}
					Json* _chatUrl = Json_getItem(gameConfig, "ChatUrl");
					if (_chatUrl && _chatUrl->type == Json_String)
					{
						sWGSite = _chatUrl->valueString;
					}
				}

				Json_dispose(root);
			}

		}
		else //连接失败
		{

		}
		if (sDownloadSite.empty() && RetryWithFallbackIfNeeded())
		{
			return;
		}
		if (m_SetDownloadSite_Func)
		{
			std::wstring wsDownloadSite = s2ws(sDownloadSite);
			std::wstring wsAppSite = s2ws(sAppSite);
			std::wstring wsWGSite = s2ws(sWGSite);
			m_SetDownloadSite_Func(wsDownloadSite, wsAppSite, wsWGSite);
		}
	}

	void RequestUpdateJson(std::wstring wsURL, std::wstring wsVersionCaption, std::wstring wsChannelCaption)
	{
		m_RequestUrlRoot = wsURL;
		if (!m_RequestUrlRoot.empty() && m_RequestUrlRoot[m_RequestUrlRoot.length() - 1] != L'/')
		{
			m_RequestUrlRoot += L"/";
		}
		m_HasRetriedRequest = false;

		std::wstring wsURLFull = wsURL + wsVersionCaption + L"/" + wsChannelCaption + L"/index.html";
		
		//"http://59.151.73.76:50000/1000/0.0.1/100/index.html"
		//"http://192.168.32.2:8080/6688/0.0.1/100/index.html"
		SendUpdateJsonRequest(wsURLFull);
	}


	std::wstring  ms_wsChannelName;

	static void SetChannelNameInt(int iChannelName)
	{
		NewInstance()->ms_wsChannelName = StringCover::intTowstring(iChannelName);
	}

	static void SetChannelNameWStr(std::wstring wsChannelName)
	{
		NewInstance()->ms_wsChannelName = wsChannelName;
	}

	static int GetChannelNameInt()
	{
		return StringCover::WStrToNum<int>(GetChannelNameWStr());
	}

	static std::wstring GetChannelNameWStr()
	{
#ifdef WIN7_32
		NewInstance()->ms_wsChannelName = L"100";
#elif defined ANDROID
		int nChannelId = 0;
		MT3::JniMethodInfo methodInfo;
		if (MT3::JniHelper::getStaticMethodInfo(methodInfo,
			"com/locojoy/mini/mt3/GameApp",
			"GetChannelId",
			"()I"))
		{
			nChannelId = methodInfo.env->CallStaticIntMethod(methodInfo.classID, methodInfo.methodID);
			methodInfo.env->DeleteLocalRef(methodInfo.classID);
			NewInstance()->ms_wsChannelName = StringCover::intTowstring(nChannelId);
		}
#else//IOS

#endif
		return NewInstance()->ms_wsChannelName;
	}

	static void SetChannelNameStr(std::string sChannelName)
	{
		SetChannelNameWStr(StringCover::to_wstring(sChannelName));
	}

	static std::string GetChannelNameStr()
	{
		return StringCover::to_string(GetChannelNameWStr());
	}

	static void ExitApp()
	{
#ifdef WIN7_32
		exit(0);
#elif defined ANDROID
		MT3::JniMethodInfo t;
		if (MT3::JniHelper::getStaticMethodInfo(t, "com/locojoy/mini/mt3/GameApp", "ExitGame", "()V"))
		{
			t.env->CallStaticVoidMethod(t.classID, t.methodID);
			t.env->DeleteLocalRef(t.classID);
		}
#else//IOS
		exit(0);
#endif
	}

};

#endif
