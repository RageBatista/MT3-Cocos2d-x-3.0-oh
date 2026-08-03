require "logic.dialog"
require "logic.selectserversdialog"
require "utils.commonutil"
require "logic.newswarndlg"
require "logic.loginwaitingdialog"

SelectServerEntry = {}
setmetatable(SelectServerEntry, Dialog)
SelectServerEntry.__index = SelectServerEntry

local UPDATE_TEXT_SHOW = 0
local loadServerSuccess = false
local loadHeadInfoSuccess = false
local autoOpenServersDialog = false

local function LoginFlowLog(msg)
    msg = "[LoginFlow][SelectServerEntryDiag] " .. tostring(msg)
    if LogInfo then
        LogInfo(msg)
    end
    print(msg)
end
------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function SelectServerEntry.getInstance()
	if gGetScene() then --如果在游戏中没有先退出游戏就到这了则先退回
		LogErr("(SelectServerEntry) game exit not in right way")
		gGetGameApplication():ExitGame(eExitType_ToLogin)
		return
	end

    if not _instance then
        _instance = SelectServerEntry:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function SelectServerEntry.getInstanceAndShow(autoOpenServerList)
	if gGetScene() then --如果在游戏中没有先退出游戏就到这了则先退回
		LogErr("(SelectServerEntry) game exit not in right way")
		gGetGameApplication():ExitGame(eExitType_ToLogin)
		return
	end

    LoginFlowLog(string.format("getInstanceAndShow autoArg=%s currentAuto=%s loadServerSuccess=%s hasInstance=%s", tostring(autoOpenServerList), tostring(autoOpenServersDialog), tostring(loadServerSuccess), tostring(_instance ~= nil)))
    if autoOpenServerList then
        autoOpenServersDialog = true
    end

	print("enter instance show")
    if not _instance then
        _instance = SelectServerEntry:new()
        _instance:OnCreate()
	else
		print("set visible")
		_instance:SetVisible(true)
    end

    if _instance and autoOpenServersDialog and loadServerSuccess then
        LoginFlowLog("getInstanceAndShow auto opening select servers dialog")
        _instance:OpenSelectServersDialog()
    end
    
    return _instance
end

function SelectServerEntry.getInstanceNotCreate()
    return _instance
end

function SelectServerEntry.DestroyDialog()
	if _instance then
        if gGetLoginManager() then
        	gGetLoginManager():ClearConnections()
        end
        loadServerSuccess = false
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function SelectServerEntry.ToggleOpenClose()
	if not _instance then 
		_instance = SelectServerEntry:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end
----/////////////////////////////////////////------

function SelectServerEntry.GetLayoutFileName()
    return "selectserverentry.layout"
end

function SelectServerEntry:OnCreate()

    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
    self.m_LoginBtn = CEGUI.Window.toPushButton(winMgr:getWindow("SelectServerEntry/LoginBtn"));
    self.m_pSelectServers = CEGUI.Window.toPushButton(winMgr:getWindow("SelectServerEntry/servername"));
	self.switchBtn = CEGUI.Window.toPushButton(winMgr:getWindow("SelectServerEntry/switchBtn"));
	self.announceBtn = CEGUI.Window.toPushButton(winMgr:getWindow("SelectServerEntry/announceBtn"))
	self.cgBtn = CEGUI.toPushButton(winMgr:getWindow("SelectServerEntry/playcgBtn"))
	self.serverStatus = winMgr:getWindow("SelectServerEntry/dian")
	self.version = winMgr:getWindow("SelectServerEntry/root/version")
    self.rootWin = winMgr:getWindow("SelectServerEntry/root");
 
    self.chooseServer = winMgr:getWindow("SelectServerEntry/back/pic3");
    
    self.tengxun = winMgr:getWindow("SelectServerEntry/root/tengxun")
    self.wxBtn = CEGUI.toPushButton(winMgr:getWindow("SelectServerEntry/LoginBtn2"))
    self.qqBtn = CEGUI.toPushButton(winMgr:getWindow("SelectServerEntry/LoginBtn3"))
	
--[[	self.smokeBg = winMgr:getWindow("SelectServerEntry/root/ccdh")-----动画1
	local s = self.smokeBg:getPixelSize()
	local flagSmoke = gGetGameUIManager():AddUIEffect(self.smokeBg, "geffect/ui/mt_shengqishi/mt_denglu", true, s.width*0.5, s.height)
	
	self.smokeBg1 = winMgr:getWindow("SelectServerEntry/root/ccdh1")
	local s = self.smokeBg1:getPixelSize()
	local flagSmoke = gGetGameUIManager():AddUIEffect(self.smokeBg1, "geffect/ui/mt_shengqishi/mt_zitidh", true, s.width*0.5, s.height)]]

    self.selectPlatform = CEGUI.toPushButton(winMgr:getWindow("SelectServerEntry/switchBtn2"))
    if DeviceInfo:sGetDeviceType()==4 then --WIN7_32
        self.selectPlatform:setVisible(true)
    end
    self.selectPlatform:subscribeEvent("Clicked", SelectServerEntry.selectPlatformBtnClick, self)
	self.wxBtn:subscribeEvent("Clicked", SelectServerEntry.wxBtnClick, self)
	self.qqBtn:subscribeEvent("Clicked", SelectServerEntry.qqBtnClick, self)

    local strVer = GameApplication:GetVersionCaption()
    if DeviceInfo:sGetDeviceType()==4 then --WIN7_32
    	self.version:setText("")
    else
    	self.version:setText("V " .. strVer)
    end

    -- subscribe event
	self.m_LoginBtn:subscribeEvent("Clicked", SelectServerEntry.HandleLoginBtnClick, self) 
    self.m_pSelectServers:subscribeEvent("Clicked", SelectServerEntry.HandleSelectServersBtnClick, self) 
	self.switchBtn:subscribeEvent("Clicked", SelectServerEntry.HandleSwitchBtnClick, self)
	self.announceBtn:subscribeEvent("Clicked", SelectServerEntry.HandleAnnounceBtnClick, self)
	self.cgBtn:subscribeEvent("Clicked", SelectServerEntry.HandlePlayCGClicked, self);
    self:enableClick(true)

    -- 部分安卓渠道不支持切换账号，所以不显示
    if gGetLoginManager() and gGetLoginManager():isSDKFuncSupported("logout") == 0 then
        self.switchBtn:setVisible(false)
    end

    --官方渠道显示切换Android
    if MT3.ChannelManager:IsAndroid() == 1 then
         if Config.IsLocojoy() then
            self.switchBtn:setVisible(true)
         end
    end

    self.serverLoad = -99

    self:connetGetServerInfo()

    self.loadStatusServerKey = nil
    self.loadStatusServerState = nil

    self.existHero = false

    TableDataManager:instance():releaseAllTable()
    --清除点卡服标记
    require("logic.pointcardserver.pointcardservermanager").Destroy()
end

--设置应用宝是否可见
function SelectServerEntry:SetYingyongBaoVisible(isvisible)
    self.tengxun:setVisible(isvisible)
end

--设置进入游戏是否可见
function SelectServerEntry:SetEnterGameVisible(isvisible)
    self.m_LoginBtn:setVisible(isvisible)
    self.chooseServer:setVisible(isvisible)
    -- 切换账号按钮必须一直有效，因此注释掉以下代码
    --self.switchBtn:setVisible(false)
    --if gGetLoginManager() and gGetLoginManager():isSDKFuncSupported("logout") == 1 and isvisible then
    --    self.switchBtn:setVisible(true)
    --end
	self.announceBtn:setVisible(isvisible)
	self.cgBtn:setVisible(isvisible)

end

function SelectServerEntry:DestroyDialogc()
	if self._instance then
        if self.sprite then
            self.sprite:delete()
            self.sprite = nil
        end
		if self.smokeBg then
		    gGetGameUIManager():RemoveUIEffect(self.smokeBg)
		end
		if self.smokeBg1 then
		    gGetGameUIManager():RemoveUIEffect(self.smokeBg1)
		end
		if self.roleEffectBg then
		    gGetGameUIManager():RemoveUIEffect(self.roleEffectBg)
		end
		self:OnClose()
		getmetatable(self)._instance = nil
        _instance = nil
	end
end

-- 设置按钮是否有效
function SelectServerEntry:enableClick(enable)
	self.m_LoginBtn:setEnabled(enable)
    self.m_pSelectServers:setEnabled(enable)
	--self.switchBtn:setEnabled(enable) -- 切换账号按钮必须一直有效，因此注释掉
	self.announceBtn:setEnabled(enable)
	self.cgBtn:setEnabled(enable)
end

function SelectServerEntry:connetGetServerInfo()
    local servers = GetServerInfo():getAllServers()
	local serverCount = servers:size()
    LoginFlowLog(string.format("connetGetServerInfo serverCount=%s loadServerSuccess=%s autoOpen=%s", tostring(serverCount), tostring(loadServerSuccess), tostring(autoOpenServersDialog)))
    if serverCount == 0 then
        --如果没有列表联网去获取服务器列表
        GetServerInfo():setConnectFromLogin(true)
        GetServerInfo():connetGetServerlist()
    else
        loadServerSuccess = true
        self:TryGetFastLoginServer()
    end
end

function SelectServerEntry.SetGetServerResult(result)
    print("result = "..result)
    LoginFlowLog(string.format("SetGetServerResult result=%s autoOpen=%s hasInstance=%s", tostring(result), tostring(autoOpenServersDialog), tostring(_instance ~= nil)))
    --LoginWaitingDialog.DestroyDialog()
    if result == 0 then
        loadServerSuccess = false
    --获取服务器列表失败
    elseif result == 1 then
		--获取列表成功， 检测链接状态

        if UPDATE_TEXT_SHOW == 0 then
            if not gGetLoginManager():isShortcutLaunched() then
                NewsWarnDlg.getInstanceAndShow()
                UPDATE_TEXT_SHOW = 1 
            end
        end

		loadServerSuccess = true
        if _instance then
            _instance:TryGetFastLoginServer()
            if autoOpenServersDialog then
                _instance:OpenSelectServersDialog()
            end
        end
    end
end

function SelectServerEntry.setLoadHeadSuccess()
    loadHeadInfoSuccess = true
    if _instance then
        _instance:checkLoadStatus()
    end
end

function SelectServerEntry:checkLoadStatus()
    if loadHeadInfoSuccess and self.loadStatusServerKey and self.loadStatusServerState then
        local headID = - 1
        if self.server then
            headID = GetServerInfo():getRoleHeadInfoByServerID(tonumber(self.server["serverid"]))
        end
        if headID ~= -1 then
            self.existHero = true
        end
        self:setServerStatus()
    end
end

function SelectServerEntry:TryGetFastLoginServer()
	--如果是第一次登陆，默认选择新开大区的新开服 by lg
	local area = nil

	--加载服务器列表数据
	local function loadAllServers()
		if not area then
			local serverdlg = require('logic.selectserversdialog')
			serverdlg:OnInit()

			for _,v in pairs(serverdlg.m_AreaServersMap) do
				if v.name == gGetLoginManager():GetSelectArea() and require "utils.tableutil".tablelength(v.servers) > 0 then  --本地记录的上次登录的area
					area = v
                    LogInfo("FIND DEFAULT AREA IN LAST SAVED")
					return true
				end

				if (not area or tonumber(area.id) > tonumber(v.id)) and require "utils.tableutil".tablelength(v.servers) > 0 then --如果没有 找到最新的大区id
                    area = v
                    LogInfo("FIND DEFAULT AREA IN NEW AREA")
                    LogInfo("AREA NAME = "..area.name)
				end
			end

			if not area then return false end
		end
		return true
	end

	--第一次打开游戏时取第一个新开服
	local function getNewServer()
		if not loadAllServers() then
			return nil
		end

        local rServer = nil
		for _,v in pairs(area.servers) do
			if  not rServer or 
                (rServer.flag == SERVER_STATUS_TUIJIAN and v.flag == SERVER_STATUS_TUIJIAN and rServer.sort > v.sort) or
                (rServer.flag ~= SERVER_STATUS_TUIJIAN and v.flag == SERVER_STATUS_TUIJIAN) or
                (rServer.flag ~= SERVER_STATUS_TUIJIAN and v.flag ~= SERVER_STATUS_TUIJIAN  and  rServer.sort > v.sort) then	--推荐 排序从小到大， 选择排序最小的服
				rServer = v
			end
		end


        if rServer == nil then
        for _,v in pairs(area.servers) do
			if v ~= nil and v.status == '0' then	--避免所有服务器都是维护状态
				rServer = v
                break
			    end
		    end
        end

		return rServer
	end

	--找到上次登录过的服
	local function getlastServer()
		local selectservername = gGetLoginManager():GetSelectServer() --ini记录的上次登录的serverName

		if not selectservername or selectservername == "" then return nil end --如果本地没有记录则直接返回

		if not loadAllServers() then return nil end    --去读取所有服务器配置，找到上次登录的服务器信息

		for _,v in pairs(area.servers) do
			if v.servername == selectservername then
				return v
			end
		end
		return nil
	end

	--取默认服
	local function getDefaultServer()
		local server = getlastServer()
		if not server then
			server = getNewServer()
			if server then
				gGetLoginManager():SetSelectServerInfo(area.name, server.servername, server.ip, server.port, 0)
			end
		end
		return server
	end

    self.server = getDefaultServer()

	if not self.server then
        LogInfo("NOT FIND DEFAULT SERVER")
        return 
    end

	local server = self.server

    local sName = server["servername"]
    local pos = string.find(sName, "-")
    if pos then
            self.m_pSelectServers:setText(string.sub(sName, 1, pos - 1))
    else
            self.m_pSelectServers:setText(sName)
    end

    if DeviceInfo:sGetDeviceType()==4 then --WIN7_32
        local serverName = sName
        local pos = string.find(serverName, "-")
        if pos then
            serverName = string.sub(serverName, 1, pos - 1)
        end
        gGetGameApplication():SetGameMainWindowTitle(Config.GetGameName(server["type"]) .. "---" .. serverName)
    end

	self.serverLoad = -1

	if server then
		local key = tonumber(server.serverid)
        local lowport = tonumber(server.port)
		local highport = lowport + tonumber(server.standby) - 1
		highport = math.max(lowport, highport)
		local port = StringCover.randBetween(lowport, highport)
		local ip = server.ip

        self.selectedServerData = {
            ip = ip,
            port = tostring(port),
            key = key,
        }

		gCommon.selectedServerKey = key
        gGetLoginManager():SetSelectServerInfo(area.name, server.servername, server.ip, tostring(port), 0)
		self:checkLoad()
	end
end

function SelectServerEntry:checkLoad()
    if not self.selectedServerData then
        LoginFlowLog("checkLoad skipped: selectedServerData=nil")
        return
    end

    --测试服务器状态
	gGetLoginManager():ClearConnections()
    local d = self.selectedServerData
    LoginFlowLog(string.format("checkLoad host=%s port=%s key=%s", tostring(d.ip), tostring(d.port), tostring(d.key)))
	gGetLoginManager():CheckLoad(d.ip, d.port, d.key)
end

------------------- private: -----------------------------------

function SelectServerEntry:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, SelectServerEntry)
    return self
end

function SelectServerEntry:HandleLoginBtnClick(args)
    local serverid = self.server and self.server["serverid"] or "nil"
    local status = self.server and self.server["status"] or "nil"
    LoginFlowLog(string.format("HandleLoginBtnClick serverLoad=%s serverid=%s status=%s loadHead=%s loadKey=%s loadState=%s",
        tostring(self.serverLoad), tostring(serverid), tostring(status), tostring(loadHeadInfoSuccess),
        tostring(self.loadStatusServerKey), tostring(self.loadStatusServerState)))

    --检查网络连接
    if not DeviceData:sIsNetworkConnected() then
        LoginFlowLog("HandleLoginBtnClick blocked: network disconnected")
        gGetMessageManager():AddConfirmBox(eConfirmOK, MHSD_UTILS.get_resstring(11310), --你的网络不给力啊，快去检查一下吧！
            MessageManager.HandleDefaultCancelEvent, MessageManager,
            MessageManager.HandleDefaultCancelEvent, MessageManager
        )
        return
    end

	if self.serverLoad > 0 then
        if self.server and self.server["status"] == SERVER_STATUS_BAOMAN and not self.existHero then
            gGetMessageManager():AddConfirmBox(eConfirmNormal, MHSD_UTILS.get_msgtipstring(162175), --提示禁止创建新角色
                SelectServerEntry.confirmEnterGame, self,
                MessageManager.HandleDefaultCancelEvent, MessageManager)
         else
            self:DoEnterGame()
        end

	elseif self.serverLoad == 0 or self.serverLoad == -1 then
        gGetMessageManager():AddConfirmBox(eConfirmOK, MHSD_UTILS.get_msgtipstring(144483), --当前服务器是维护状态，无法进入（如果在非维护时，所有服务器呈维护状态，请重启游戏再试）
            MessageManager.HandleDefaultCancelEvent, MessageManager,
            MessageManager.HandleDefaultCancelEvent, MessageManager
        )
    elseif self.serverLoad == -99 then
        gGetMessageManager():AddConfirmBox(eConfirmNormal, MHSD_UTILS.get_resstring(11311), --获取服务器列表失败，请确认网络顺畅后重试
            SelectServerEntry.checkLoad, self,
            MessageManager.HandleDefaultCancelEvent, MessageManager,
            0,0,nil,MHSD_UTILS.get_resstring(11268) --重试
        )
    end
end

function SelectServerEntry:confirmEnterGame()
    gGetMessageManager():CloseConfirmBox(eConfirmNormal, false)
    self:DoEnterGame()
end

function SelectServerEntry:DoEnterGame()
    if self.server then
        local couldEntry = SelectServersDialog.CheckCouldEnterThreePvp(self.server["serverid"])
        LoginFlowLog(string.format("DoEnterGame serverid=%s couldEntry=%s", tostring(self.server["serverid"]), tostring(couldEntry)))
        if couldEntry then
            GetServerInfo():clearHeadInfo()
            loadHeadInfoSuccess = false
		    self:LoginGame()
        else
            local strMsg = MHSD_UTILS.get_msgtipstring(172039)
            gGetMessageManager():AddConfirmBox(eConfirmOK, strMsg,
                MessageManager.HandleDefaultCancelEvent, MessageManager,
                MessageManager.HandleDefaultCancelEvent, MessageManager)
        end
    else
        LoginFlowLog("DoEnterGame skipped: server=nil")
    end
end

function SelectServerEntry:OpenSelectServersDialog()
    LoginFlowLog(string.format("OpenSelectServersDialog begin loadServerSuccess=%s autoOpen=%s hasServer=%s selectArea=%s selectServer=%s", tostring(loadServerSuccess), tostring(autoOpenServersDialog), tostring(self.server ~= nil), tostring(gGetLoginManager():GetSelectArea()), tostring(gGetLoginManager():GetSelectServer())))
    if loadServerSuccess then
        autoOpenServersDialog = false
        LogInfo("SelectServerEntry OpenSelectServersDialog")
        self.DestroyDialog()
	    LoginFlowLog("OpenSelectServersDialog before ToServerChoose")
	    gGetLoginManager():ToServerChoose(gGetLoginManager():GetSelectArea(), gGetLoginManager():GetSelectServer())
	    LoginFlowLog(string.format("OpenSelectServersDialog after ToServerChoose selectArea=%s selectServer=%s", tostring(gGetLoginManager():GetSelectArea()), tostring(gGetLoginManager():GetSelectServer())))
        if self.server then
            local serverkey = self.server["serverid"]
            if self.server["orgid"] ~= self.server["serverid"] then
                serverkey = self.server["orgid"]
            end

            SelectServersDialog.setLastSelect(-1)
        end
	    LoginFlowLog("OpenSelectServersDialog before SelectServersDialog.getInstanceAndShow")
	    SelectServersDialog.getInstanceAndShow()
	    LoginFlowLog("OpenSelectServersDialog after SelectServersDialog.getInstanceAndShow")
    else
        LoginFlowLog("OpenSelectServersDialog pending: server list not loaded")
        self:connetGetServerInfo()
    end
    return true
end

function SelectServerEntry:HandleSelectServersBtnClick(args)
    LogInfo("SelectServerEntry HandleSelectServersBtnClick")
    self:OpenSelectServersDialog()
    return true
end

function SelectServerEntry:LoginGame()
	
	local account = gGetLoginManager():GetAccount()
    local key = gGetLoginManager():GetPassword()
    
    local channelId = gGetLoginManager():GetChannelId()
    LoginFlowLog(string.format("LoginGame begin accountLen=%d keyLen=%d channelLen=%d",
        string.len(account or ""), string.len(key or ""), string.len(channelId or "")))
	
	if account == "" and key == "" then
        LoginFlowLog("LoginGame blocked: account and key empty")
		GetCTipsManager():AddMessageTipById(144784)
        return true
	end
	
	local servername = gGetLoginManager():GetSelectServer()
	local area = gGetLoginManager():GetSelectArea()
	if servername == "" or area == "" then
        LoginFlowLog(string.format("LoginGame blocked: servername=%s area=%s", tostring(servername), tostring(area)))
		return true
	end
    local sign_key = key
	
	local account1 = account

    local host = gGetLoginManager():GetHost()
    local port = gGetLoginManager():GetPort()
    LoginFlowLog(string.format("LoginGame CreateConnection before serverid=%s servername=%s area=%s host=%s port=%s connectAccountLen=%d hasComma=%s",
        tostring(self.server and self.server["serverid"]), tostring(servername), tostring(area), tostring(host), tostring(port),
        string.len(account1 or ""), tostring(string.find(account1 or "", ",") ~= nil)))
    
    gGetGameApplication():SetTime(0)
	gGetLoginManager():ClearConnections()
    gGetLoginManager():setServerKey(self.server["serverid"])
    gGetGameApplication():CreateConnection(account1, sign_key, host, port, true, servername, area, tonumber(self.server["serverid"]) , channelId)
    LoginFlowLog("LoginGame CreateConnection returned")
    if gGetNetConnection() then
        gGetNetConnection():setSecurityType(FireNet.enumSECURITY_ARCFOUR, FireNet.enumSECURITY_ARCFOUR)
        LoginFlowLog("LoginGame security type set")
    else
        LoginFlowLog("LoginGame after CreateConnection: net connection is nil")
    end
	
	self.DestroyDialog()
	LoginWaitingDialog.getInstanceAndShow()
    LoginFlowLog("LoginGame waiting dialog shown")

	local beanTabel = BeanConfigManager.getInstance():GetTableByName("SysConfig.csteploadtexsetting")
	local record = beanTabel:getRecorder(1)
    gGetGameConfigManager():SetStepLoadTextureInMovie(record.stepmovie)
    gGetGameConfigManager():SetStepLoadTextureAlways(record.stepalways)

    Nuclear.GetEngine():SetLimitFireThreadSecond(140)
end

function SelectServerEntry:HandleSwitchBtnClick(args)
    GetServerInfo():clearHeadInfo()
    if false and  Config.CUR_3RD_PLATFORM == "app" then
        if not Config_IsRongHe() then
            self:enableClick(false) -- 设置按钮不可点击
        end
        gGetLoginManager():LoginAgain()
    elseif false and Config.CUR_3RD_PLATFORM == "winapp" then
        local dlg = require("logic.winlogindlg").getInstanceAndShow()
        dlg:setExecMode(ExecMode_LoginAgain)
    else
        print("change account")
        require('logic.switchaccountdialog').getInstanceAndShow()
        self.DestroyDialog()
    end
end

function SelectServerEntry:HandleAnnounceBtnClick(args)
	if not NewsWarnDlg.getInstanceNotCreate() then
		NewsWarnDlg.getInstanceAndShow()
	end
end


function SelectServerEntry:HandlePlayCGClicked(args)

    self:PlayCG();

end

function SelectServerEntry:PlayCG()
    self:StopCG();

    SimpleAudioEngine:sharedEngine():pauseBackgroundMusic();

	_instance.mVideoPlayer = VideoPlayer:create();
    _instance.mVideoPlayer:retain();
    
    local PFN = "/cfg/video/MT3.mp4"

	if DeviceInfo:sGetDeviceType()==4 then --WIN7_32
		PFN = "/cfg/video/MT3.wmv"
	end

	local FPFN = PFN
	FPFN = gGetGameUIManager():GetFullPathFileName(PFN)
    _instance.mVideoPlayer:setFileName(FPFN);

    -- 取控件 SelectServerEntry/root 的区域作为视频显示区域
    local pos = _instance.rootWin:GetScreenPos();
    local size = _instance.rootWin:getPixelSize();
    _instance.mVideoPlayer:setVideoRect(pos.d_x, pos.d_y, size.d_width, size.d_height);

    _instance.mVideoPlayer:setCallback("completed", "SelectServerEntry.getInstance():StopCG()");

    _instance.mVideoPlayer:play();
    _instance.mVideoPlayer:setVisible(true);
end

function SelectServerEntry:StopCG()
    if(_instance.mVideoPlayer) then
        _instance.mVideoPlayer:stop();
        _instance.mVideoPlayer:setVisible(false);
        _instance.mVideoPlayer:release();
        _instance.mVideoPlayer = nil;

    SimpleAudioEngine:sharedEngine():resumeBackgroundMusic();
    end
end

--服务器测试连接成功，获得服务器状态，如果服务器维护，则不会收到反馈
function SelectServerEntry:SetServerLoad(serverKey, serverLoad)
     LoginFlowLog(string.format("SetServerLoad serverKey=%s serverLoad=%s", tostring(serverKey), tostring(serverLoad)))
     self.loadStatusServerKey = serverKey
     self.loadStatusServerState = serverLoad
     self:checkLoadStatus()
end

function SelectServerEntry:setServerStatus()
    local isShortcutLaunched = gGetLoginManager():isShortcutLaunched()

	loadServerSuccess = true
	if self.loadStatusServerKey == tonumber(self.server.serverid) then
        gGetMessageManager():CloseConfirmBox(eConfirmNormal, false)
		self.serverLoad = self.loadStatusServerState
        LoginFlowLog(string.format("setServerStatus matched serverid=%s serverLoad=%s", tostring(self.server.serverid), tostring(self.serverLoad)))
		if self.serverLoad == 1 or self.serverLoad == 2 then	--畅通
			self.serverStatus:setProperty("Image", "set:ccui1 image:lvsecc1")
		elseif self.serverLoad == 3 then  --爆满
			self.serverStatus:setProperty("Image", "set:ccui1 image:hongsecc1")
		else  --维护
			self.serverStatus:setProperty("Image", "set:ccui1 image:huisecc1")
		end
	end

    if self.server["status"] == SERVER_STATUS_BAOMAN and self.serverLoad > 0 then
        self.serverStatus:setProperty("Image", "set:login_2 image:bao")
        return
    elseif self.server["status"] == SERVER_STATUS_YONGDU and self.serverLoad > 0 then
        self.serverStatus:setProperty("Image", "set:login_2 image:du")
    end

	if isShortcutLaunched and not gGetLoginManager():isShortcutItemHandled() then
		self:HandleLoginBtnClick();
	end
end

--QQ登陆
function SelectServerEntry:qqBtnClick(args)
    MT3.ChannelManager:qqLogin()
end

--WX登陆
function SelectServerEntry:wxBtnClick(args)
    MT3.ChannelManager:wxLogin()
end

function SelectServerEntry:selectPlatformBtnClick(args)
    local dlg = require"logic.windowsexplain".getInstanceAndShow()
    dlg:GetCloseBtn():setVisible(true)
end

return SelectServerEntry
