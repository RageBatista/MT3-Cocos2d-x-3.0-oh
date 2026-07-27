#ifndef __CONNECTGETSERVERINFO_H
#define __CONNECTGETSERVERINFO_H

#include "Singleton.hpp"
#include "network/HttpClient.h"
#include "network/HttpRequest.h"
#include "network/HttpResponse.h"

enum enumServerHttpAdress
{
	eHttpPatchUrl,
	eHttpUpdateUrl,
	eHttpShareUrl,
	eHttpInfoUrl,
	eHttpChatUrl,
	eHttpCommunityUrl,
	eHttpNoticeUrl,
	eHttpConfigUrl,
	eHttpServerInfoUrl,
	eHttpXunFeiServerUrl,
	eHttpHorseRunUrl,
	eHttpJinglingUrl,
	eHttpKongjianUrl
};

enum enumGetServerState
{
	eNumNotConnect,
	eNumConnectSuccess,
	eNumConnectFailed,
};

struct stServerINFO
{
	int areaID;
	std::wstring serverid;
	std::wstring serverArea;
	std::wstring serverName;
	std::wstring serverIp;
	std::wstring serverPort;
	std::wstring serverState;
	std::wstring serverStandby;
	std::wstring serverType;
	std::wstring serverOpenTime;
	std::wstring serverFlag;
};

struct stJinglingINFO
{
	std::string jl_faqid;
	std::string jl_categoryid;
	std::string jl_title;
	std::string jl_style;
	std::string jl_sort;
	std::string jl_status;
	std::string jl_content;
};

struct stQuestTitleID
{
	std::string qid;
	std::string qtitle;
};
struct stRecruitList
{
	std::string roleid;
	std::string name;
	std::string avatar;
	std::string level;
	std::string servername;
	std::string serverid;
};
struct stRecruitOneRoleData
{
	std::string serverid;
	std::string roleid;
	std::string new_serverid;
	std::string new_roleid;
	std::string prize_type;
	std::string amount;
};
struct stRecruitData
{
	int total;
	std::string times_item;
};
class ConnectGetServerInfo : public cocos2d::CCObject, public CSingleton<ConnectGetServerInfo>
{
public:
	void connetGetServerlist();
	void connetGetUserInfo();
	void connetCreateRoleInfo(int serverid, int headid);
	void connetGetRecruitInfo(char* url, int index);
	//0:�ӿ�3.У����ļ���Ǵ���, ��У�鱻��ļ  http://mt3.pengyouquan001.locojoy.com:8830/enlist/check_code?code=7956261002
	//1:�ӿ�4.У����ļ��, ͬʱУ�鱻��ļ��    http://mt3.pengyouquan001.locojoy.com:8830/enlist/check?code=7956261002&new_serverid=1101011002&new_roleid=795626
	//2:�ӿ�5.��ļ���ύ��ļ�� http ://mt3.pengyouquan001.locojoy.com:8830/enlist/submit_code?code=7956261002&new_serverid=1101011002&new_roleid=795626
	//3:�ӿ�6.��ļ�˻�ȡ����ļ���б� http://mt3.pengyouquan001.locojoy.com:8830/enlist/get_enlist_list?serverid=1101011002&roleid=795626
	//4:�ӿ�8.��ȡĳ����ļ�˵Ľ�������״̬http ://mt3.pengyouquan001.locojoy.com:8830/enlist/get_prize_list?serverid=1101011002&roleid=795626&new_serverid=123&new_roleid=123
	//��ȡ��ļ����ļ����,������ȡ�Ĵ�������
	//http://mt3.pengyouquan001.locojoy.com:8830/enlist/get_times_prize?serverid=1101011002&roleid=795626
	void HandleCheckRecruit(cocos2d::network::HttpClient* client, cocos2d::network::HttpResponse* response);
	void HandleCheckRecruitAndRole(cocos2d::network::HttpClient* client, cocos2d::network::HttpResponse* response);
	void HandleSendRecruitCode(cocos2d::network::HttpClient* client, cocos2d::network::HttpResponse* response);
	void HandleGetRecruitList(cocos2d::network::HttpClient* client, cocos2d::network::HttpResponse* response);
	void HandleCheckRecruitOneRole(cocos2d::network::HttpClient* client, cocos2d::network::HttpResponse* response);
	void HandlegetRecruitInfo(cocos2d::network::HttpClient* client, cocos2d::network::HttpResponse* response);

	void connetCheckRecruitCode(char* url);
	void connetCheckRecruitCodeAndRoleid(char* url);
	void connetGetOneRoleInfo(char* url);
	void onGetServerlist(cocos2d::network::HttpClient* client, cocos2d::network::HttpResponse* response);
	void onGetUserInfo(cocos2d::network::HttpClient* client, cocos2d::network::HttpResponse* response);
	void onSerUserInfo(cocos2d::network::HttpClient* client, cocos2d::network::HttpResponse* response);

	void setHttpAdressMap(enumServerHttpAdress em, std::string value);
	std::string getHttpAdressByEnum(enumServerHttpAdress em);

	std::vector<stServerINFO>& getAllServers(){ return mServers; }

	enumGetServerState getConnectState(){ return conState; }

	int getRoleHeadInfoByServerID(int serverID);
	void setServerRoleInfoMap(int key, int value);

	void setConnectFromLogin(bool isInLogin){ isLoginConnecting = isInLogin; }

	void clearHeadInfo();

	void doEnterBBS();

	//�������
	void doRequestJingLingQuest(int id);
	void doRequestSearchData(std::string keyWord);
	void onGetJingLingData(cocos2d::network::HttpClient* client, cocos2d::network::HttpResponse* response);
	void onGetSingelAnswer(cocos2d::network::HttpClient* client, cocos2d::network::HttpResponse* response);
	void onGetSearchData(cocos2d::network::HttpClient* client, cocos2d::network::HttpResponse* response);
	void getRedianIds(std::vector<int>& ids);  //ȡ���ȵ�ids
	void getTuijianIds(std::vector<int>& ids);  //ȡ���Ƽ�ids
	void getKefuIds(std::vector<int>& ids);  //ȡ�ÿͷ�ids
	void getSearchResultList(std::string q, std::vector<stQuestTitleID>& ids);
	stJinglingINFO getJinglingDataByID(int id); //for lua
	void clearJinglingData();
	//��ļ
	stRecruitData getRecruitData(){ return m_RecruitData;}
	std::vector<stRecruitList> getRecruitList(){ return m_RecruitList; }
	std::vector<stRecruitOneRoleData> getRecruitOneRole(){ return m_RecruitRoleList; }
private:
	bool isLoginConnecting;
	bool isGetUserInfoSuccessful;
	bool isRetryGetUserInfo;
	std::vector<stServerINFO> mServers;
	enumGetServerState conState;
	std::map<enumServerHttpAdress, std::string> httpAdressMap;
	std::map<int, int> roleServerInfoMap;

	//�����ʴ����
	int m_currentRequestID;
	std::map<int, stJinglingINFO> jinglingDataMap;
	std::map<std::string, std::vector<stQuestTitleID> > questWidthoutContent;
	std::vector<int> redianIds;
	std::vector<int> tuijianIds;
	std::vector<int> kefuIds;

	//��ļ�������
	stRecruitData m_RecruitData; //��ļ�����ͽ���
	std::vector<stRecruitList> m_RecruitList;//��ļ�б�
	std::vector<stRecruitOneRoleData>m_RecruitRoleList;//ĳ��������
	void checkVectorContainsAndInsert(std::vector<int>& vec, int value);

	void doAfterGetServerListData(); 
public:
	ConnectGetServerInfo();
	~ConnectGetServerInfo();
};

inline ConnectGetServerInfo* GetServerInfo()
{
	return ConnectGetServerInfo::NewInstance();
}

inline void destroyServerInfo()
{
	ConnectGetServerInfo::RemoveInstance();
}

#endif

