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
------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function SelectServerEntry.getInstance()
	if gGetScene() then --�������Ϸ��û�����˳���Ϸ�͵����������˻�
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

function SelectServerEntry.getInstanceAndShow()
	if gGetScene() then --�������Ϸ��û�����˳���Ϸ�͵����������˻�
		LogErr("(SelectServerEntry) game exit not in right way")
		gGetGameApplication():ExitGame(eExitType_ToLogin)
		return
	end

	print("enter instance show")
    if not _instance then
        _instance = SelectServerEntry:new()
        _instance:OnCreate()
	else
		print("set visible")
		_instance:SetVisible(true)
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

    -- ���ְ�׿������֧���л��˺ţ����Բ���ʾ
    if gGetLoginManager() and gGetLoginManager():isSDKFuncSupported("logout") == 0 then
        self.switchBtn:setVisible(false)
    end

    --�ٷ�������ʾ�л�Android
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
    --����㿨�����
    require("logic.pointcardserver.pointcardservermanager").Destroy()
end

--����Ӧ�ñ��Ƿ�ɼ�
function SelectServerEntry:SetYingyongBaoVisible(isvisible)
    self.tengxun:setVisible(isvisible)
end

--���ý�����Ϸ�Ƿ�ɼ�
function SelectServerEntry:SetEnterGameVisible(isvisible)
    self.m_LoginBtn:setVisible(isvisible)
    self.chooseServer:setVisible(isvisible)
    -- �л��˺Ű�ť����һֱ��Ч�����ע�͵����´���
    --self.switchBtn:setVisible(false)
    --if gGetLoginManager() and gGetLoginManager():isSDKFuncSupported("logout") == 1 and isvisible then
    --    self.switchBtn:setVisible(true)
    --end
	self.announceBtn:setVisible(isvisible)
	self.cgBtn:setVisible(isvisible)

end

-- ���ð�ť�Ƿ���Ч
function SelectServerEntry:enableClick(enable)
	self.m_LoginBtn:setEnabled(enable)
    self.m_pSelectServers:setEnabled(enable)
	--self.switchBtn:setEnabled(enable) -- �л��˺Ű�ť����һֱ��Ч�����ע�͵�
	self.announceBtn:setEnabled(enable)
	self.cgBtn:setEnabled(enable)
end

function SelectServerEntry:connetGetServerInfo()
    local servers = GetServerInfo():getAllServers()
	local serverCount = servers:size()
    if serverCount == 0 then
        --���û���б�����ȥ��ȡ�������б�
        GetServerInfo():setConnectFromLogin(true)
        GetServerInfo():connetGetServerlist()
    else
        loadServerSuccess = true
        self:TryGetFastLoginServer()
    end
end

function SelectServerEntry.SetGetServerResult(result)
    print("result = "..result)
    --LoginWaitingDialog.DestroyDialog()
    if result == 0 then
        loadServerSuccess = false
    --��ȡ�������б�ʧ��
    elseif result == 1 then
		--��ȡ�б��ɹ��� �������״̬

        if UPDATE_TEXT_SHOW == 0 then
            if not gGetLoginManager():isShortcutLaunched() then
                NewsWarnDlg.getInstanceAndShow()
                UPDATE_TEXT_SHOW = 1 
            end
        end

		loadServerSuccess = true
        if _instance then
            _instance:TryGetFastLoginServer()
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
	--����ǵ�һ�ε�½��Ĭ��ѡ���¿��������¿��� by lg
	local area = nil

	--���ط������б�����
	local function loadAllServers()
		if not area then
			local serverdlg = require('logic.selectserversdialog')
			serverdlg:OnInit()

			for _,v in pairs(serverdlg.m_AreaServersMap) do
				if v.name == gGetLoginManager():GetSelectArea() and require "utils.tableutil".tablelength(v.servers) > 0 then  --���ؼ�¼���ϴε�¼��area
					area = v
                    LogInfo("FIND DEFAULT AREA IN LAST SAVED")
					return true
				end

				if (not area or tonumber(area.id) > tonumber(v.id)) and require "utils.tableutil".tablelength(v.servers) > 0 then --���û�� �ҵ����µĴ���id
                    area = v
                    LogInfo("FIND DEFAULT AREA IN NEW AREA")
                    LogInfo("AREA NAME = "..area.name)
				end
			end

			if not area then return false end
		end
		return true
	end

	--��һ�δ���Ϸʱȡ��һ���¿���
	local function getNewServer()
		if not loadAllServers() then
			return nil
		end

        local rServer = nil
		for _,v in pairs(area.servers) do
			if  not rServer or 
                (rServer.flag == SERVER_STATUS_TUIJIAN and v.flag == SERVER_STATUS_TUIJIAN and rServer.sort > v.sort) or
                (rServer.flag ~= SERVER_STATUS_TUIJIAN and v.flag == SERVER_STATUS_TUIJIAN) or
                (rServer.flag ~= SERVER_STATUS_TUIJIAN and v.flag ~= SERVER_STATUS_TUIJIAN  and  rServer.sort > v.sort) then	--�Ƽ� �����С���� ѡ��������С�ķ�
				rServer = v
			end
		end


        if rServer == nil then
        for _,v in pairs(area.servers) do
			if v ~= nil and v.status == '0' then	--�������з���������ά��״̬
				rServer = v
                break
			    end
		    end
        end

		return rServer
	end

	--�ҵ��ϴε�¼���ķ�
	local function getlastServer()
		local selectservername = gGetLoginManager():GetSelectServer() --ini��¼���ϴε�¼��serverName

		if not selectservername or selectservername == "" then return nil end --�������û�м�¼��ֱ�ӷ���

		if not loadAllServers() then return nil end    --ȥ��ȡ���з��������ã��ҵ��ϴε�¼�ķ�������Ϣ

		for _,v in pairs(area.servers) do
			if v.servername == selectservername then
				return v
			end
		end
		return nil
	end

	--ȡĬ�Ϸ�
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
        return
    end

    --���Է�����״̬
	gGetLoginManager():ClearConnections()
    local d = self.selectedServerData
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
    --�����������
    if not DeviceData:sIsNetworkConnected() then
        gGetMessageManager():AddConfirmBox(eConfirmOK, MHSD_UTILS.get_resstring(11310), --������粻����������ȥ���һ�°ɣ�
            MessageManager.HandleDefaultCancelEvent, MessageManager,
            MessageManager.HandleDefaultCancelEvent, MessageManager
        )
        return
    end

	if self.serverLoad > 0 then
        if self.server and self.server["status"] == SERVER_STATUS_BAOMAN and not self.existHero then
            gGetMessageManager():AddConfirmBox(eConfirmNormal, MHSD_UTILS.get_msgtipstring(162175), --��ʾ��ֹ�����½�ɫ
                SelectServerEntry.confirmEnterGame, self,
                MessageManager.HandleDefaultCancelEvent, MessageManager)
         else
            self:DoEnterGame()
        end

	elseif self.serverLoad == 0 or self.serverLoad == -1 then
        gGetMessageManager():AddConfirmBox(eConfirmOK, MHSD_UTILS.get_msgtipstring(144483), --��ǰ��������ά��״̬���޷����루����ڷ�ά��ʱ�����з�������ά��״̬����������Ϸ���ԣ�
            MessageManager.HandleDefaultCancelEvent, MessageManager,
            MessageManager.HandleDefaultCancelEvent, MessageManager
        )
    elseif self.serverLoad == -99 then
        gGetMessageManager():AddConfirmBox(eConfirmNormal, MHSD_UTILS.get_resstring(11311), --��ȡ�������б�ʧ�ܣ���ȷ������˳��������
            SelectServerEntry.checkLoad, self,
            MessageManager.HandleDefaultCancelEvent, MessageManager,
            0,0,nil,MHSD_UTILS.get_resstring(11268) --����
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
    end
end

function SelectServerEntry:HandleSelectServersBtnClick(args)
    if loadServerSuccess then
        self.DestroyDialog()
	    gGetLoginManager():ToServerChoose(gGetLoginManager():GetSelectArea(), gGetLoginManager():GetSelectServer())
        if self.server then
            local serverkey = self.server["serverid"]
            if self.server["orgid"] ~= self.server["serverid"] then
                serverkey = self.server["orgid"]
            end

            SelectServersDialog.setLastSelect(-1)
        end
	    SelectServersDialog.getInstanceAndShow()
    else
        self:connetGetServerInfo()
    end    
    return true
end

function SelectServerEntry:LoginGame()
	
	local account = gGetLoginManager():GetAccount()
	--新家的
    if Config.CUR_3RD_PLATFORM == "app" then
		account= account ..",020000000000"
	end
	--新家的
    local key = gGetLoginManager():GetPassword()
    
    local channelId = gGetLoginManager():GetChannelId()
	
	if account == "" and key == "" then
		GetCTipsManager():AddMessageTipById(144784)
        return true
	end
	
	local servername = gGetLoginManager():GetSelectServer()
	local area = gGetLoginManager():GetSelectArea()
	if servername == "" or area == "" then
		return true
	end
    
    local host = gGetLoginManager():GetHost()
    local port = gGetLoginManager():GetPort()
    
    gGetGameApplication():SetTime(0)
	gGetLoginManager():ClearConnections()
    gGetLoginManager():setServerKey(self.server["serverid"])
    gGetGameApplication():CreateConnection(account, key, host, port, true, servername, area, tonumber(self.server["serverid"]) , channelId)
    if gGetNetConnection() then
        gGetNetConnection():setSecurityType(FireNet.enumSECURITY_ARCFOUR, FireNet.enumSECURITY_ARCFOUR)
    end
	
	self.DestroyDialog()
	LoginWaitingDialog.getInstanceAndShow()

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
            self:enableClick(false) -- ���ð�ť���ɵ��
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

    -- ȡ�ؼ� SelectServerEntry/root ��������Ϊ��Ƶ��ʾ����
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

--�������������ӳɹ�����÷�����״̬�����������ά�����򲻻��յ�����
function SelectServerEntry:SetServerLoad(serverKey, serverLoad)
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
		if self.serverLoad == 1 or self.serverLoad == 2 then	--��ͨ
			self.serverStatus:setProperty("Image", "set:ccui1 image:lvsecc1")
		elseif self.serverLoad == 3 then  --����
			self.serverStatus:setProperty("Image", "set:ccui1 image:hongsecc1")
		else  --ά��
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

--QQ��½
function SelectServerEntry:qqBtnClick(args)
    MT3.ChannelManager:qqLogin()
end

--WX��½
function SelectServerEntry:wxBtnClick(args)
    MT3.ChannelManager:wxLogin()
end

function SelectServerEntry:selectPlatformBtnClick(args)
    local dlg = require"logic.windowsexplain".getInstanceAndShow()
    dlg:GetCloseBtn():setVisible(true)
end

return SelectServerEntry
