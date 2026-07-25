require "logic.dialog"

ShareDlg = {}
setmetatable(ShareDlg, Dialog)
ShareDlg.__index = ShareDlg

SHARE_TYPE_CHARACTOR = 0
SHARE_TYPE_PET = 1
SHARE_TYPE_5V5 = 2

SHARE_FUNC_CAPTURE = 0
SHARE_FUNC_URL = 1
SHARE_FUNC_URL_IMG = 2 --网络资源图片
SHARE_FUNC_RECRUIT = 3 --招募分享

SHARE_URL = "http://mt3.pengyouquan001.locojoy.com:8840/share/get?key="

local _instance
local shareType  --区分分享人物还是宠物
local shareFunc  --区分分享的种类， 分享url，还是截图
local isFromActivity  --是否来自活动的分享

--分享到社交软件，具体软件待定  --微信好友, 微信朋友圈, 新浪微博
local shareChannel = {eShareSDK_Wechat, eShareSDK_WechatMoments, eShareSDK_SinaWeibo} 
local curShareChannel
local ShareCode --招募吗
local ShareCodetext --招募信息
function ShareDlg.getInstance()
	if not _instance then
		_instance = ShareDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function ShareDlg.getInstanceAndShow()
	if not _instance then
		_instance = ShareDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function ShareDlg.getInstanceNotCreate()
	return _instance
end

function ShareDlg.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
            isFromActivity = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function ShareDlg.ToggleOpenClose()
	if not _instance then
		_instance = ShareDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function ShareDlg.GetLayoutFileName()
	return "fenxiang.layout"
end

function ShareDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, ShareDlg)
	return self
end

function ShareDlg:OnCreate()
	Dialog.OnCreate(self)

    SetPositionScreenCenter(self:GetWindow())

	local winMgr = CEGUI.WindowManager:getSingleton()

    local shareChange1 = CEGUI.toPushButton(winMgr:getWindow("fenxiang/tongdao1"))
    shareChange1:setID(1)
    local shareChange2 = CEGUI.toPushButton(winMgr:getWindow("fenxiang/tongdao2"))
     shareChange2:setID(2)
    local shareChange3 = CEGUI.toPushButton(winMgr:getWindow("fenxiang/tongdao3"))
     shareChange3:setID(3)
    local shareChange4 = CEGUI.toPushButton(winMgr:getWindow("fenxiang/tongdao4"))
     shareChange4:setID(4)
    local shareChange5 = CEGUI.toPushButton(winMgr:getWindow("fenxiang/tongdao5"))
     shareChange5:setID(5)
    shareChange1:subscribeEvent("Clicked", ShareDlg.handleShareWeChat, self)
    shareChange2:subscribeEvent("Clicked", ShareDlg.handleShareWeChat, self)
    shareChange3:subscribeEvent("Clicked", ShareDlg.handleShareWeChat, self)
    shareChange4:subscribeEvent("Clicked", ShareDlg.handleShareWeChat, self)
    shareChange5:subscribeEvent("Clicked", ShareDlg.handleShareWeChat, self)

    if isFromActivity then
        shareChange1:setVisible(false)
        shareChange3:setVisible(false)
    end

    self.m_frame = winMgr:getWindow("fenxiang")
    self.m_doCapture = false

    self.m_code = ""
    self.m_codetext =""
end
function ShareDlg:SetRecruitData(code, text)
    self.m_code = code
    self.m_codetext = text
    ShareCode = code
    ShareCodetext = text
end
function ShareDlg.SetShareType(sType)
    shareType = sType
end

function ShareDlg.SetShareFunc(sFunc)
    shareFunc = sFunc
end

function ShareDlg.SetShareIsActivity(isActivity)
    isFromActivity = isActivity
end

function ShareDlg:handleShareWeChat(arg)
	local e = CEGUI.toWindowEventArgs(arg)
	local id = e.window:getID()

    if shareFunc == SHARE_FUNC_CAPTURE then  --分享截图
        self:GetWindow():setVisible(false)
        local wnd = nil
        local changePosCenter = false
        if shareType == SHARE_TYPE_CHARACTOR then
            require "logic.characterinfo.characterlabel".DestroyDialog()
            wnd = require "logic.characterinfo.characterprodlg".getInstance()
            wnd:adjustForCapture()
            changePosCenter = true
        elseif shareType == SHARE_TYPE_PET then
            require "logic.pet.petlabel".hide()
            wnd = require "logic.pet.petdetaildlg".getInstance()
            wnd:showCapturePet()
        elseif shareType == SHARE_TYPE_5V5 then
            wnd = require "logic.jingji.jingjidialog5".getInstance()
            changePosCenter = true
        end

        wnd:GetWindow():SeModalStateDrawEffect(false)

        local shareIcon, shareTile, shareDescrib, url = self:getShareArgs(id)
        local dlg = require "logic.capturedlg".getInstanceAndShow()
        dlg:createSharePic(wnd, shareType, shareChannel[id])
        dlg:setParameters(shareIcon, shareTile, shareDescrib, url)

        if changePosCenter then
            local s0 = dlg:GetWindow():getPixelSize()
            local s1 = wnd:GetWindow():getPixelSize()
            wnd:GetWindow():setPosition(NewVector2((s0.width-s1.width*0.8)*0.5, (s0.height-s1.height*0.8)*0.5))
        end
    elseif shareFunc == SHARE_FUNC_URL then --分享制定url站点
        LogInfo("SHARE_FUNC_URL")
        curShareChannel = shareChannel[id]
        self:SendShareParamUrl()
        ShareDlg.DestroyDialog()
    elseif shareFunc ==  SHARE_FUNC_URL_IMG then    --分享网络资源图片
        LogInfo("SHARE_FUNC_URL_IMG")
        curShareChannel = shareChannel[id]
        self:SendShareParamUrl()
        ShareDlg.DestroyDialog()
    elseif shareFunc == SHARE_FUNC_RECRUIT then --招募
        curShareChannel = shareChannel[id]
        self:SendShareParamUrlRecruit()
        ShareDlg.DestroyDialog()
    end

    return true
end

function ShareDlg:SendShareParamUrl()
        local Spaceprotocol = require("logic.space.spaceprotocol")
        local nProtocolId = Spaceprotocol.eProId.getShareParams
        local strProtocolParam = tostring(nProtocolId)

        local strUrl
        local nHttpType = 0 
        local nTimeout = Spaceprotocol.nTimeout
        if IsPointCardServer() then
            strUrl = SHARE_URL .. "1"
        else
            strUrl = SHARE_URL .. "0"
        end
        gGetSpaceManager():SendRequest(strProtocolParam,strUrl,"",nHttpType,nTimeout)
end
function ShareDlg:SendShareParamUrlRecruit()
        local Spaceprotocol = require("logic.space.spaceprotocol")
        local nProtocolId = Spaceprotocol.eProId.getShareParams
        local strProtocolParam = tostring(nProtocolId)

        local strUrl
        local nHttpType = 0 
        local nTimeout = Spaceprotocol.nTimeout
        if IsPointCardServer() then
            strUrl = SHARE_URL .. "3"
        else
            strUrl = SHARE_URL .. "2"
        end
        gGetSpaceManager():SendRequest(strProtocolParam,strUrl,"",nHttpType,nTimeout)
end
function ShareDlg:getShareArgs(id)
    local isAndroid = false
    if Config.MOBILE_ANDROID == 1 then
        isAndroid = true
    end

    local icon = ""
    local title = ""
    local describ = ""
    local url = ""
    local allIdCount =  BeanConfigManager.getInstance():GetTableByName(CheckTableName("game.cshareconfig")):getSize()
    local record = BeanConfigManager.getInstance():GetTableByName(CheckTableName("game.cshareconfig")):getRecorder(math.random(1, allIdCount - 2))
    if id == 1 then --微信
        icon = record.iconWechat
        title = record.titleWechat
        describ = record.describWechat
        if isAndroid then
            url = record.androidUrlWechat
        else
            url = record.iosUrlWechat
        end
    elseif id == 2 then --朋友圈
        icon = record.iconMonents
        title = record.titleMonents
        describ = record.describMonents
        if isAndroid then
            url = record.androidUrlMonents
        else
            url = record.iosUrlMonents
        end
    elseif id == 3 then --微博
        icon = record.iconWeibo
        title = record.titleWeibo
        describ = record.describWeibo
        url = record.urlWeibo
        if isAndroid then
            url = record.androidUrlWeibo
        else
            url = record.iosUrlWeibo
        end
    end
    return icon, title, describ, url
end
function ShareDlg:getShareArgsForRecruit(id)
    local isAndroid = false
    if Config.MOBILE_ANDROID == 1 then
        isAndroid = true
    end

    local icon = ""
    local title = ""
    local describ = ""
    local url = ""
    local allIdCount =  BeanConfigManager.getInstance():GetTableByName(CheckTableName("game.cshareconfig")):getSize()
    local record = BeanConfigManager.getInstance():GetTableByName(CheckTableName("game.cshareconfig")):getRecorder(4)
    if id == 1 then --微信
        icon = record.iconWechat
        title = record.titleWechat
        describ = record.describWechat
        if isAndroid then
            url = record.androidUrlWechat
        else
            url = record.iosUrlWechat
        end
    elseif id == 2 then --朋友圈
        icon = record.iconMonents
        title = record.titleMonents
        describ = record.describMonents
        if isAndroid then
            url = record.androidUrlMonents
        else
            url = record.iosUrlMonents
        end
    elseif id == 3 then --微博
        icon = record.iconWeibo
        title = record.titleWeibo
        describ = record.describWeibo
        url = record.urlWeibo
        if isAndroid then
            url = record.androidUrlWeibo
        else
            url = record.iosUrlWeibo
        end
    end

    local strbuilder = StringBuilder:new()
    strbuilder:Set("parameter1", self.m_code)
    local serverName = gGetLoginManager():GetSelectServer()
    local pos = string.find(serverName, "-")
    if pos then
        serverName = string.sub(serverName, 1, pos - 1)
    end
    strbuilder:Set("parameter2", Base64.Encode(serverName, string.len(serverName)))
    strbuilder:Set("parameter3", Base64.Encode(gGetDataManager():GetMainCharacterName(), string.len(gGetDataManager():GetMainCharacterName())))
    strbuilder:Set("parameter4", Base64.Encode(self.m_codetext, string.len(self.m_codetext)))
    local content = strbuilder:GetString(url)
    strbuilder:delete()
    return icon, title, self.m_codetext, content
end
function ShareDlg.SetShareActiveComplete()
    local p = require("protodef.fire.pb.mission.activelist.cshareactivity"):new()
    LuaProtocolManager:send(p)
end

--[[
    {
    "errno": "",
    "message": "",
    "data": {
    "share_id": "1",
    "key": 1,（0是免费服，1是点卡服）
    "title": "我爱MT",
    "content": "国民手游《我叫MT》系列正统作品《我叫MT3》来了！西方魔幻题材诠释经典MMO回合制玩法，开启MT系列手游新时代！不一样的玩法，同样的主角，哀木涕的小伙伴们即将开启全新的冒险！",
    "icon": "http://update2.locojoy.com/web/diankayuyue0519/images/logo_pic.png",
    "pageurl": "http://mt3.locojoy.com/",
    "imgurl": "http://resource.locojoy.com/cms/2016/0630/20160630152509870.jpg",
    "create_time": "1470797618"
        }
    }
]]--
function ShareDlg.process(strData,vstrParam)
    local pJson_root = gGetSpaceManager():SpaceJson_create(strData)
    if not pJson_root then
        return
    end
    local pJson_data = gGetSpaceManager():SpaceJson_getItem(pJson_root,"data")
    if not pJson_data then
         gGetSpaceManager():SpaceJson_dispose(pJson_root)
        return
    end

    local title = gGetSpaceManager():SpaceJson_getString(pJson_data,"title","")
    local content = gGetSpaceManager():SpaceJson_getString(pJson_data,"content","")
    local iconurl = gGetSpaceManager():SpaceJson_getString(pJson_data,"icon","")
    local url = gGetSpaceManager():SpaceJson_getString(pJson_data,"pageurl","")
    local imgurl = gGetSpaceManager():SpaceJson_getString(pJson_data,"imgurl","")

    gGetSpaceManager():SpaceJson_dispose(pJson_root)
    LogInfo("title: " .. title .. "  content: " .. content .. "  iconurl: " .. iconurl.. "  url: " .. url.. "  imgurl: " .. imgurl)
    if shareFunc == SHARE_FUNC_URL then --分享制定url站点
        LogInfo("curShareChannel" .. curShareChannel)
        gGetGameApplication():shareToPlatform(curShareChannel, eShareType_WebUrl,  title,  content,  iconurl, url)
    elseif shareFunc ==  SHARE_FUNC_URL_IMG then    --分享网络资源图片
        LogInfo("curShareChannel111" .. curShareChannel)
        gGetGameApplication():shareToPlatform(curShareChannel, eShareType_Picture,  title,  content,  imgurl, url)
    elseif shareFunc == SHARE_FUNC_RECRUIT then
        local serverName = gGetLoginManager():GetSelectServer()
        local pos = string.find(serverName, "-")
        if pos then
            serverName = string.sub(serverName, 1, pos - 1)
        end
        strbuilder:Set("parameter2", Base64.Encode(serverName, string.len(serverName)))
        local newUrl = url ..
        "?code="..Base64.Encode(ShareCode, string.len(ShareCode))..
        "&servername="..Base64.Encode(serverName, string.len(serverName))..
        "&name="..Base64.Encode(gGetDataManager():GetMainCharacterName(), string.len(gGetDataManager():GetMainCharacterName()))..
        "&text="..Base64.Encode(ShareCodetext, string.len(ShareCodetext))
        gGetGameApplication():shareToPlatform(curShareChannel, eShareType_Picture,  title,  ShareCodetext,  imgurl, newUrl)
    end
end

--cshareconfig

return ShareDlg