------------------------------------------------------------------
-- ��������
-- �Ȳ��Է�����״̬�����û��Ӧ��ÿ2s����һ�Σ���������ˣ���������,
-- �������ʧ���ˣ�ÿ2s����һ�Σ�����10s�����δ�ɹ�������ʧ����ʾ��
------------------------------------------------------------------
require "logic.dialog"


ReConnectDlg = {}
setmetatable(ReConnectDlg, Dialog)
ReConnectDlg.__index = ReConnectDlg

local ConnectState = {
	NotConnect = 0, -- δ����
	stCheckServer = 1, -- ��������״̬,״̬ʧ��ʱC++����û��֪ͨ�ű�,������tick�ĳ�ʱ�������˴���
	ServerLoaded = 2, -- ���״̬�ɹ�,���Խ���
	Connecting = 3, -- ������
}

local _instance
function ReConnectDlg.getInstance()
	if not _instance then
		_instance = ReConnectDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function ReConnectDlg.getInstanceAndShow()
	if not _instance then
		_instance = ReConnectDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
		_instance:resetState()
	end
	return _instance
end

function ReConnectDlg.getInstanceNotCreate()
	return _instance
end

function ReConnectDlg.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose(false, false)
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function ReConnectDlg.ToggleOpenClose()
	if not _instance then
		_instance = ReConnectDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function ReConnectDlg.GetLayoutFileName()
	return "reconnectdlg.layout"
end

function ReConnectDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, ReConnectDlg)
	return self
end

function ReConnectDlg:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
	local effectPos = winMgr:getWindow("reconnectdlg/background/touxiang")
	gGetGameUIManager():AddUIEffect(effectPos, "geffect/ui/mt_duanxian/mt_duanxian", true)
	self:initServerInfo()
end

function ReConnectDlg:initServerInfo()

	self.pause = false
	self.elapsed = 0
	self.init = false

	local serverdlg = require('logic.selectserversdialog')
	serverdlg:OnInit()

	if serverdlg.m_AreaServersMap == nil then
		LogErr("[ReConnectDlg:initServerInfo] serverdlg.m_AreaServersMap == nil")
		return
	end

	local area = nil
	for _, v in pairs(serverdlg.m_AreaServersMap) do
		if v.name == gGetLoginManager():GetSelectArea() then
			area = v
		end
	end

	if area == nil then
		LogErr("[ReConnectDlg:initServerInfo] area == nil")
		return
	end

	local servername = gGetLoginManager():GetSelectServer()
	local server = nil
	for _, v in pairs(area.servers) do
		if v.servername == servername then
			server = v
		end
	end

	if server == nil then
		LogErr("[ReConnectDlg:initServerInfo] server == nil")
		return
	end

	self.serverKey = tonumber(server["serverid"])
     local lowport = tonumber(server.port)
	 local highport = lowport + tonumber(server.standby) - 1
	 highport = math.max(lowport, highport)
	 self.port = tostring(StringCover.randBetween(lowport, highport))
	 self.ip = server.ip
--	self.cmode = server["cmode"] or 0
--	self.gip = server["gip"] or ""
--	self.gport = port or ""

	self.init = true

	-- self.connecting = false
	-- self.serverLoaded = false
	self.connectState = ConnectState.NotConnect
	self.checkTimes = 1
	--self:checkServerState()

    --LogWar(string.format("[ReConnectDlg:initServerInfo] serverKey:%d ip:%s port:%d", self.serverKey, self.ip, self.port))
end

function ReConnectDlg:resetState()
	self.pause = false
	self.elapsed = 0
	--self.connecting = false
	--self.serverLoaded = false
	self.connectState = ConnectState.NotConnect
	self.checkTimes = 1
end

function ReConnectDlg:checkServerState()
    gGetLoginManager():ClearConnections()
--    if self.cmode == 0 then
        gGetLoginManager():CheckLoad(self.ip, self.port, self.serverKey)
--	else
--		gGetLoginManager():CheckLoad(self.ip, self.port, self.serverKey, self.cmode, self.gip, self.gport)
--	end

	self.connectState = ConnectState.stCheckServer

	--LogWar(string.format("[ReConnectDlg:checkServerState] serverKey:%d ip:%s port:%d", self.serverKey, self.ip, self.port))
end

function ReConnectDlg:doConnect()

	
	local account = gGetLoginManager():GetAccount()
	--新家的
	--新家的
    local key = gGetLoginManager():GetPassword()
    
    local serverid = gGetLoginManager():getServerID()
    local channelid = gGetLoginManager():GetChannelId();
	
	if account == "" and key == "" then
		GetCTipsManager():AddMessageTipById(144784)
        return true
	end
	
	local servername = gGetLoginManager():GetSelectServer()
	local area = gGetLoginManager():GetSelectArea()
	if servername == "" or area == "" then
		return true
	end
    local sign_key = key
	
	local account1 = account

    local host = gGetLoginManager():GetHost()
    local port = gGetLoginManager():GetPort()
    
	gGetLoginManager():ClearConnections()
    gGetGameApplication():CreateConnection(account1, sign_key, host, port, true, servername, area, serverid, channelid)
    if gGetNetConnection() then
        gGetNetConnection():setSecurityType(FireNet.enumSECURITY_ARCFOUR, FireNet.enumSECURITY_ARCFOUR)
    end

	self.connectState = ConnectState.Connecting

--[[
    print('ReConnectDlg:doConnect')
    local account = gGetLoginManager():GetAccount()
    local key = gGetLoginManager():GetPassword()
	local servername = gGetLoginManager():GetSelectServer()
	local area = gGetLoginManager():GetSelectArea()
    local host = gGetLoginManager():GetHost()
    local port = gGetLoginManager():GetPort()
	
    local serverid = gGetLoginManager():getServerID()
    local channelid = gGetLoginManager():GetChannelId();
	gGetLoginManager():ClearConnections()
    gGetGameApplication():CreateConnection(account, key, host, port, true, servername, area, serverid, channelid)
    if gGetNetConnection() then
        gGetNetConnection():setSecurityType(FireNet.enumSECURITY_ARCFOUR, FireNet.enumSECURITY_ARCFOUR)
    end

    --self.connecting = true
	self.connectState = ConnectState.Connecting

	--LogWar(string.format("[ReConnectDlg:doConnect] account:%s host:%s port:%s servername:%s area:%s", account, host, port, servername, area))
]]--

end

--��⵽�������ѿ���
function ReConnectDlg.onServerLoaded()
    if _instance then
        --_instance.serverLoaded = true
        _instance.connectState = ConnectState.ServerLoaded
        _instance:doConnect()
    end
end

function ReConnectDlg.onServerClosed()
    ReConnectDlg.onReConnectFailed()
end

function ReConnectDlg.onConnectFailed()
    if _instance then
        --_instance.connecting = false
        _instance.connectState = ConnectState.NotConnect
    end
end

function ReConnectDlg.onReConnectFailed()
    if _instance then
        _instance.pause = true
        --_instance.connecting = false
        _instance.connectState = ConnectState.NotConnect
        gGetMessageManager():AddConfirmBox(
            eConfirmNormal,
            MHSD_UTILS.get_resstring(11264),
            ReConnectDlg.handleRetryClicked, _instance,
            ReConnectDlg.handleRetrunClicked, _instance,
            0,0,nil,
            MHSD_UTILS.get_resstring(11268),MHSD_UTILS.get_resstring(268)
        )
        --[[gGetMessageManager():AddMessageBox(
            "",MHSD_UTILS.get_resstring(11264),
            ReConnectDlg.handleRetryClicked, _instance,
            ReConnectDlg.handleRetrunClicked, _instance,
            eMsgType_Normal,10000,0,0,nil,
            MHSD_UTILS.get_resstring(11268),MHSD_UTILS.get_resstring(268)
        )--]]
    end
end

function ReConnectDlg:handleRetryClicked(args)
    --gGetMessageManager():CloseCurrentShowMessageBox()
    gGetMessageManager():CloseConfirmBox(eConfirmNormal,false)
    self.pause = false
    self.elapsed = 0
    --self.connecting = false
    --self.serverLoaded = false
	self.connectState = ConnectState.NotConnect
    self.checkTimes = 1
    self:checkServerState()
end

function ReConnectDlg:handleRetrunClicked(args)
    if CEGUI.toWindowEventArgs(args).handled ~= 1 then
        --gGetMessageManager():CloseCurrentShowMessageBox()
        gGetMessageManager():CloseConfirmBox(eConfirmNormal,false)
        gGetGameApplication():ExitGame(eExitType_ToLogin)
        ReConnectDlg.DestroyDialog()
    end
end

function ReConnectDlg:tick(delta)
    if gGetSceneMovieManager() and gGetSceneMovieManager():isOnSceneMovie() then
        return
    end

    -- �����ʼ��ʧ��,��ÿ2��������һ��,ֱ���ɹ�
	if self.init == false then
        self.elapsed = self.elapsed + delta
		if self.elapsed >= 2000 then
			self.elapsed = 0
			self:initServerInfo()
		end
		return
	end

    --����ʧ��ȷ�Ͽ򣬵ȴ��û�ѡ�����Ի�ȡ��
    if self.pause then
        return
    end

--    --�ȴ�������������
--    if not DeviceData:sIsNetworkConnected() then
--        return
--    end

    --���������ϣ���ʼ��������״̬
    if self.connectState == ConnectState.NotConnect then
        self.connectState = ConnectState.stCheckServer
        self:checkServerState()
        self.checkTimes = 1
        return
    end

    --��¼��ʱ
    self.elapsed = self.elapsed + delta

    --��������״̬��ʱ,���ҵ�ǰ����������,��������ѡ���
    if self.elapsed >= 6000 and self.connectState == ConnectState.stCheckServer and self.checkTimes == 1 then
        self:checkServerState()
        self.checkTimes = 2
    end

    if self.elapsed >= 12000 and self.connectState <= ConnectState.stCheckServer then
        ReConnectDlg.onReConnectFailed()
        return
    end

    --���ӳ�ʱ����������ѡ���
    if self.elapsed >= 20000 then
        self:resetState() 
        ReConnectDlg.onReConnectFailed()
        return
    end
end

return ReConnectDlg
