require "logic.dialog"
require "utils.mhsdutils"

LoginQueueDlg = {}
setmetatable(LoginQueueDlg, Dialog)
LoginQueueDlg.__index = LoginQueueDlg

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function LoginQueueDlg.getInstance()
	print("enter get yaoqianshu dialog instance")
    if not _instance then
        _instance = LoginQueueDlg:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function LoginQueueDlg.getInstanceAndShow()
	print("enter yaoqianshu dialog instance show")
    if not _instance then
        _instance = LoginQueueDlg:new()
        _instance:OnCreate()
	else
		LogInfo("set loginqueue dialog visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function LoginQueueDlg.getInstanceNotCreate()
    return _instance
end

function LoginQueueDlg.DestroyDialog1()
	if _instance then 
		if not _instance.m_bCloseIsHide then
            local p = require("protodef.fire.pb.cuseroffline"):new()
	        LuaProtocolManager:send(p)
			LogInfo("destroy loginqueue dialog")
			_instance:OnClose()
			_instance = nil
            SelectServerEntry.getInstanceAndShow()
		else
			self:ToggleOpenClose()
		end
	end
end

function LoginQueueDlg.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			self:ToggleOpenClose()
		end
	end
end

function LoginQueueDlg.ToggleOpenClose()
	if not _instance then 
		_instance = LoginQueueDlg:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function LoginQueueDlg:calculateTime()
    local str = ""
    if self._hour > 0 then
        str = tostring(self._hour)..BeanConfigManager.getInstance():GetTableByName("message.cstringres"):getRecorder(318).msg
        if self._minute > 0 then
            str = str..tostring(self._minute)..BeanConfigManager.getInstance():GetTableByName("message.cstringres"):getRecorder(71).msg
        end
        str = str..tostring(self._second)..BeanConfigManager.getInstance():GetTableByName("message.cstringres"):getRecorder(10015).msg
    else
        if self._minute > 0 then
            str = str..tostring(self._minute)..BeanConfigManager.getInstance():GetTableByName("message.cstringres"):getRecorder(71).msg
        end
        str = str..tostring(self._second)..BeanConfigManager.getInstance():GetTableByName("message.cstringres"):getRecorder(10015).msg
    end
    return str
end

function LoginQueueDlg:RefreshInfo(order, queuelength, second)
    
    self._hour = math.floor(second / 3600)
    self._minute = math.floor((second - self._hour*3600) / 60)
    self._second = second - self._hour*3600 - self._minute*60

    local str = self:calculateTime()
	if order == -1 then
		self.m_pQueueTitle:setText(BeanConfigManager.getInstance():GetTableByName("message.cstringres"):getRecorder(11368).msg)
		self.m_pQueueWaitingTip:setVisible(false)
        self.m_pRank:setVisible(false)
        self.m_pTxt1:setVisible(false)
        self.m_pTxt2:setVisible(false)
        self.m_pRemainingMinutes:setVisible(false)
	else 
		if order == 0 then
			self.m_pQueueTitle:setVisible(false)
			self.m_pQueueWaitingTip:setVisible(true)
			self.m_pRank:setText(tostring(order)..BeanConfigManager.getInstance():GetTableByName("message.cstringres"):getRecorder(11570).msg)
			self.m_pRemainingMinutes:setText(str)
		else
			-- normal
			self.m_pQueueTitle:setVisible(true)
			self.m_pQueueWaitingTip:setVisible(true)
			self.m_pRank:setText(tostring(order)..BeanConfigManager.getInstance():GetTableByName("message.cstringres"):getRecorder(11570).msg)
			self.m_pRemainingMinutes:setText(str)
		end
	end
end



function LoginQueueDlg:RefreshInfo1(order, queuelength, second)
    self.m_pCancelBtn:setEnabled(true)
    self:GetCloseBtn():setEnabled(true)
    self._hour = nil
    self._minute = nil
    self._second = second
	if order == -1 then
		self.m_pQueueTitle:setText(BeanConfigManager.getInstance():GetTableByName("message.cstringres"):getRecorder(11368).msg)
		self.m_pQueueWaitingTip:setVisible(false)
	else 
		if order == 0 then
			self.m_pQueueTitle:setVisible(false)
			self.m_pQueueWaitingTip:setVisible(true)
			self.m_pRank:setText(tostring(order)..BeanConfigManager.getInstance():GetTableByName("message.cstringres"):getRecorder(11570).msg)
			self.m_pRemainingMinutes:setText(tostring(self._second)..BeanConfigManager.getInstance():GetTableByName("message.cstringres"):getRecorder(71).msg)
		else
			self.m_pQueueTitle:setVisible(true)
			self.m_pQueueWaitingTip:setVisible(true)
			self.m_pRank:setText(tostring(order)..BeanConfigManager.getInstance():GetTableByName("message.cstringres"):getRecorder(11570).msg)
			self.m_pRemainingMinutes:setText(tostring(self._second)..BeanConfigManager.getInstance():GetTableByName("message.cstringres"):getRecorder(71).msg)
		end
	end
    self.elapse = 0
    self.isUpdate = true
end

----/////////////////////////////////////////------

function LoginQueueDlg.GetLayoutFileName()
    return "signindlg.layout"
end

function LoginQueueDlg:OnCreate()
	print("login queue dialog oncreate begin")
	if gGetLoginManager() then
		gGetLoginManager():ClearConnections()
	end
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    self.m_pQueueTitle = winMgr:getWindow("SignInDlg/title")
    self.m_pMainFrame:subscribeEvent("WindowUpdate", LoginQueueDlg.HandleWindowUpdate, self)
	self.m_pQueueWaitingTip = winMgr:getWindow("SignInDlg/main") 
	self.m_pRank = winMgr:getWindow("SignInDlg/num1")
	self.m_pRemainingMinutes = winMgr:getWindow("SignInDlg/num2")
	self.m_pCancelBtn = winMgr:getWindow("SignInDlg/cancel")
    self.m_pServerName = winMgr:getWindow("SignInDlg/fuwuqi1")
    self.m_pTxt1 = winMgr:getWindow("SignInDlg/main/txt") 
    self.m_pTxt2 = winMgr:getWindow("SignInDlg/main/txt1")
    local selectservername = gGetLoginManager():GetSelectServer()
    self.m_pServerName:setText(selectservername)

    local serverName = gGetLoginManager():GetSelectServer()
    local pos = string.find(serverName, "-")
    if pos then
        self.m_pServerName:setText(string.sub(serverName, 1, pos - 1))
    else
        self.m_pServerName:setText(serverName)
    end


    -- subscribe event
    self.m_pCancelBtn:subscribeEvent("Clicked", LoginQueueDlg.HandleCancelBtnClicked, self)
    self:GetCloseBtn():removeEvent("Clicked")
	self:GetCloseBtn():subscribeEvent("Clicked", LoginQueueDlg.HandleCancelBtnClicked, self)
    self.isUpdate = false

    self.elapse = 0
end

------------------- private: -----------------------------------


function LoginQueueDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, LoginQueueDlg)
    return self
end


function LoginQueueDlg:HandleCancelBtnClicked(args)
	self.DestroyDialog1()
	return true
end

function LoginQueueDlg:getIsUpdate()
    return self.isUpdate
end

function LoginQueueDlg:HandleWindowUpdate(e)
	local updateArgs = CEGUI.toUpdateEventArgs(e)
	local elapsed = updateArgs.d_timeSinceLastFrame
    self.elapse = self.elapse+elapsed
    if self:getIsUpdate() then
        if self.elapse >= 1 then
            self.elapse = 0
            self._second = self._second - 1
            if self._second >= 0 then
                self.m_pRemainingMinutes:setText(tostring(self._second)..GameTable.message.GetCMessageTipTableInstance():getRecorder(71).msg)
            end
            if self._second <= 0 then
                self.isUpdate = false
                gGetNetConnection():send(fire.pb.CRoleList())
                self.m_pCancelBtn:setEnabled(false)
                self:GetCloseBtn():setEnabled(false)
            end
        end
    else
        if self.elapse >= 1 then
            self.elapse = 0
            if self._second > 0 then
                self._second = self._second - 1
            else
                if self._minute > 0 then
                    self._minute = self._minute - 1
                    self._second = 59
                else
                    if self._hour > 0 then
                        self._hour = self._hour - 1
                        self._minute = 59
                        self._second = 59
                    end
                end
            end
            local str = self:calculateTime()
            self.m_pRemainingMinutes:setText(str)
        end
    end
end


return LoginQueueDlg
