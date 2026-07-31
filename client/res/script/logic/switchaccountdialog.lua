require "logic.dialog"
require "logic.selectserverentry"
require "utils.commonutil"
--require "logic.logintipdlg"
debugrequire "logic.accountlistdlg"

SwitchAccountDialog = {}
setmetatable(SwitchAccountDialog, Dialog)
SwitchAccountDialog.__index = SwitchAccountDialog

local function _boolText(v)
    if v then
        return "true"
    end
    return "false"
end

local function _wndName(wnd)
    if wnd then
        return wnd:getName()
    end
    return "nil"
end

local function _safeLen(text)
    if text then
        return string.len(text)
    end
    return 0
end

local INPUT_TEXT_COLOUR = 0xff50321a

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function SwitchAccountDialog.getInstance()

    if not _instance then
        _instance = SwitchAccountDialog:new()

        _instance:OnCreate()
    end

    return _instance
end

function SwitchAccountDialog.getInstanceAndShow()
	print("SwitchAccountDialog show")
    if not _instance then
        _instance = SwitchAccountDialog:new()
        _instance:OnCreate()
	else
		print("set visible")
		_instance:SetVisible(true)
		_instance:ActivateCurrentInput()
    end

    return _instance
end

function SwitchAccountDialog.getInstanceNotCreate()
    return _instance
end

function SwitchAccountDialog.DestroyDialog()
	if _instance then
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function SwitchAccountDialog.ToggleOpenClose()
	if not _instance then
		_instance = SwitchAccountDialog:new()
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

function SwitchAccountDialog.GetLayoutFileName()
    return "switchaccountdialog.layout"
end


function SwitchAccountDialog:OnCreate()
    Dialog.OnCreate(self)
    local winMgr = CEGUI.WindowManager:getSingleton()

    --登陆分页
    self.loginFybtn = CEGUI.Window.toPushButton(winMgr:getWindow("switchaccount/loginFyAN"));
    self.loginFybtn:subscribeEvent("Clicked", SwitchAccountDialog.HandleLoginAccountBtnClick, self)
    self.loginbtn = CEGUI.Window.toPushButton(winMgr:getWindow("switchaccount/loginbtn"));
    self.loginbtn:subscribeEvent("Clicked", SwitchAccountDialog.HandleLoginLoginBtnClick, self)



    local loginFybtnStatus = true

	self.loginFy = winMgr:getWindow("switchaccount/logi")
	self.regFy = winMgr:getWindow("switchaccount/regi")
    self.loginFy:setVisible(true)
    self.regFy:setVisible(false)



    -- get 登录输入
    self.m_Account = CEGUI.Window.toEditbox(winMgr:getWindow("switchaccount/accountbox"))
    self.m_KeyEdit = CEGUI.Window.toEditbox(winMgr:getWindow("switchaccount/pwdbox"))
    self.m_KeyEdit:setTextMasked(true);
    self.m_KeyEdit:setMaxTextLength(self.MAX_LENGTH_PASSWORD)
	self:ApplyInputVisualStyle(self.m_Account)
	self:ApplyInputVisualStyle(self.m_KeyEdit)
    self.m_LoginBtn = CEGUI.Window.toPushButton(winMgr:getWindow("switchaccount/login"));
    self.m_LoginBtn:subscribeEvent("Clicked", SwitchAccountDialog.HandleLoginBtnClick, self)


    -- get 注册输入
    self.mRegAccount = CEGUI.Window.toEditbox(winMgr:getWindow("switchaccount/regAccount"))
    self.mRegPassword = CEGUI.Window.toEditbox(winMgr:getWindow("switchaccount/regPassword"))
    self.mRegPassword:setTextMasked(true);
    self.mRegPassword:setMaxTextLength(self.MAX_LENGTH_PASSWORD)
    self.mRegPasswordAgain = CEGUI.Window.toEditbox(winMgr:getWindow("switchaccount/regPasswordAgain"))
    self.mRegPasswordAgain:setTextMasked(true);
    self.mRegPasswordAgain:setMaxTextLength(self.MAX_LENGTH_PASSWORD)

    self.mRegInvite = CEGUI.Window.toEditbox(winMgr:getWindow("switchaccount/regInvite"))
	self:ApplyInputVisualStyle(self.mRegAccount)
	self:ApplyInputVisualStyle(self.mRegPassword)
	self:ApplyInputVisualStyle(self.mRegPasswordAgain)
	self:ApplyInputVisualStyle(self.mRegInvite)
    self.mRegbtn = CEGUI.Window.toPushButton(winMgr:getWindow("switchaccount/regBtn"));
    self.mRegbtn:subscribeEvent("Clicked", SwitchAccountDialog.HandleRegBtnClick, self)
    -- subscribe event

    _instance.jieguo=0

     self.goreg = CEGUI.Window.toPushButton(winMgr:getWindow("switchaccount/regi/backlogin1"));
    self.goreg:subscribeEvent("Clicked", SwitchAccountDialog.HandleLoginAccountBtnClick, self)

     self.gologin = CEGUI.Window.toPushButton(winMgr:getWindow("switchaccount/regi/backlogin"));
    self.gologin:subscribeEvent("Clicked", SwitchAccountDialog.HandleLoginLoginBtnClick, self)
 self.gologin:setVisible(false)
    --gGetGameUIManager():showGameCaptchaView()
	self:InitAccountList()
	self:BindInputProbe(self.m_Account)
	self:BindInputProbe(self.m_KeyEdit)
	self:BindInputProbe(self.mRegAccount)
	self:BindInputProbe(self.mRegPassword)
	self:BindInputProbe(self.mRegPasswordAgain)
	self:BindInputProbe(self.mRegInvite)
	self:FocusLoginInput()


end


------------------- private: -----------------------------------

function SwitchAccountDialog:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, SwitchAccountDialog)

    self.MAX_LENGTH_PASSWORD = 16

    return self
end

function SwitchAccountDialog:DumpInputState(tag, wnd)
	local target = nil
	if CEGUI.System and CEGUI.System:getSingleton() then
		target = CEGUI.System:getSingleton():getKeyboardTargetWindow()
	end

	local info = string.format(
		"[SwitchAccountDialog][%s] wnd=%s target=%s canEdit=%s focus=%s visible=%s disabled=%s parentPass=%s textLen=%d",
		tag,
		_wndName(wnd),
		_wndName(target),
		_boolText(wnd and wnd:IsCanEdit() or false),
		_boolText(wnd and wnd:hasInputFocus() or false),
		_boolText(wnd and wnd:isVisible() or false),
		_boolText(wnd and wnd:isDisabled() or false),
		_boolText(wnd and wnd:isParentMousePassThroughEnabled() or false),
		wnd and string.len(wnd:getText()) or -1
	)
	print(info)
end

function SwitchAccountDialog:HandleInputMouseDown(args)
	local mouseArgs = CEGUI.toMouseEventArgs(args)
	self:DumpInputState("MouseButtonDown", mouseArgs and mouseArgs.window or nil)
	return false
end

function SwitchAccountDialog:HandleInputMouseUp(args)
	local mouseArgs = CEGUI.toMouseEventArgs(args)
	if self:IsLoginButtonHit(mouseArgs) then
		print(string.format("[SwitchAccountDialog][InputMouseUpLoginHit] accountLen=%d passwordLen=%d",
			self.m_Account and _safeLen(self.m_Account:getText()) or 0,
			self.m_KeyEdit and _safeLen(self.m_KeyEdit:getText()) or 0))
		return self:HandleLoginBtnClick(args)
	end

	return false
end

function SwitchAccountDialog:HandleInputKeyboardTargetWndChanged(args)
	local wnd = CEGUI.toWindowEventArgs(args).window
	self:DumpInputState("KeyboardTargetWndChanged", wnd)
	return false
end

function SwitchAccountDialog:HandleInputTextChanged(args)
	local wnd = CEGUI.toWindowEventArgs(args).window
	self:DumpInputState("TextChanged", wnd)
	return false
end

function SwitchAccountDialog:BindInputProbe(wnd)
	if not wnd then
		return
	end

	wnd:subscribeEvent("MouseButtonDown", SwitchAccountDialog.HandleInputMouseDown, self)
	wnd:subscribeEvent("MouseButtonUp", SwitchAccountDialog.HandleInputMouseUp, self)
	wnd:subscribeEvent("KeyboardTargetWndChanged", SwitchAccountDialog.HandleInputKeyboardTargetWndChanged, self)
	wnd:subscribeEvent("TextChanged", SwitchAccountDialog.HandleInputTextChanged, self)
end

function SwitchAccountDialog:IsLoginButtonHit(mouseArgs)
	if not mouseArgs or not self.m_LoginBtn or not self.loginFy or not self.loginFy:isVisible() then
		return false
	end

	return self.m_LoginBtn:isVisible()
		and not self.m_LoginBtn:isDisabled()
		and self.m_LoginBtn:isHit(mouseArgs.position)
end

function SwitchAccountDialog:ApplyInputVisualStyle(wnd)
	if wnd then
		wnd:SetNormalColourRect(INPUT_TEXT_COLOUR)
	end
end

function SwitchAccountDialog:FocusLoginInput()
	if self.m_Account then
		self.m_Account:SetCanEdit(true)
		self.m_Account:activate()
		gGetGameUIManager():AttachIME(CEGUI.String(self.m_Account:getText()))
		self.m_Account:setCaratIndex(string.len(self.m_Account:getText()))
		self:DumpInputState("FocusLoginInput", self.m_Account)
	end
end

function SwitchAccountDialog:FocusRegisterInput()
	if self.mRegAccount then
		self.mRegAccount:SetCanEdit(true)
		self.mRegAccount:activate()
		gGetGameUIManager():AttachIME(CEGUI.String(self.mRegAccount:getText()))
		self.mRegAccount:setCaratIndex(string.len(self.mRegAccount:getText()))
		self:DumpInputState("FocusRegisterInput", self.mRegAccount)
	end
end

function SwitchAccountDialog:ActivateCurrentInput()
	if self.regFy and self.regFy:isVisible() then
		self:FocusRegisterInput()
	else
		self:FocusLoginInput()
	end
end

function SwitchAccountDialog:InitAccountList()

	local strLastAccount = gGetLoginManager():GetAccount()
	--strLastAccount = strLastAccount:sub(1, -14)
    self.m_Account:setText(strLastAccount)
	self.m_Account:setCaratIndex(#strLastAccount)

    local rememberedPassword = self:GetRememberedPassword(strLastAccount)
    self.m_KeyEdit:setText(rememberedPassword)
	self.m_KeyEdit:setCaratIndex(_safeLen(rememberedPassword))
	print(string.format("[SwitchAccountDialog][RememberPasswordLoaded] accountLen=%d passwordLen=%d",
		_safeLen(strLastAccount), _safeLen(rememberedPassword)))
	self:FocusLoginInput()

    return true

end

function SwitchAccountDialog:GetRememberedPassword(account)
	if not account or account == "" then
		return ""
	end

	local lastAccount = GetServerIniInfo("Account", "LastAccount")
	local lastPassword = GetServerIniInfo("Password", "LastPassword")
	if lastAccount == account and lastPassword then
		return lastPassword
	end

	local idx = 0
	while true do
		local user = GetServerIniInfo("AccountList", "user"..idx)
		if not user then
			break
		end
		if user == account then
			return GetServerIniInfo("AccountList", "password"..idx) or ""
		end
		idx = idx + 1
	end

	return ""
end

function SwitchAccountDialog:SaveRememberedPassword(account, password)
	SetServerIniInfo("Account", "LastAccount", account)
	SetServerIniInfo("Password", "LastPassword", password)

	local idx = 0
	while true do
		local user = GetServerIniInfo("AccountList", "user"..idx)
		if not user then
			break
		end
		if user == account then
			SetServerIniInfo("AccountList", "password"..idx, password)
			break
		end
		idx = idx + 1
	end

	print(string.format("[SwitchAccountDialog][RememberPasswordSaved] accountLen=%d passwordLen=%d",
		_safeLen(account), _safeLen(password)))
end

--登录失败
function SwitchAccountDialog:MessageTip1()
   -- GetCTipsManager():AddMessageTipById(201071)
    GetCTipsManager():AddMessageTipById(144784)
        return true
end
--登录成功
function SwitchAccountDialog:MessageTip2()
    GetCTipsManager():AddMessageTipById(201071)
    return true
end
--注册失败
function SwitchAccountDialog:MessageTip3()
    GetCTipsManager():AddMessageTipById(201071)
    return true
end
--注册失败
function SwitchAccountDialog:MessageTip4()
    GetCTipsManager():AddMessageTipById(201071)
    return true
end


--登陆验证提示
function SwitchAccountDialog:ReturnMessageTip(msg)
    GetCTipsManager():AddMessageTipByMsg(msg)
    return true
end


function SwitchAccountDialog:HandleRegBtnClick(args)

    -- self.mRegAccount = CEGUI.Window.toEditbox(winMgr:getWindow("switchaccount/regAccount"))
    -- self.mRegPassword = CEGUI.Window.toEditbox(winMgr:getWindow("switchaccount/regPassword"))
    -- self.mRegPasswordAgain = CEGUI.Window.toEditbox(winMgr:getWindow("switchaccount/regPasswordAgain"))
    -- self.mRegInvite = CEGUI.Window.toEditbox(winMgr:getWindow("switchaccount/regInvite"))
    local account = self.mRegAccount:getText()
    local password = self.mRegPassword:getText()
    local passwordagain = self.mRegPasswordAgain:getText()
    local invite = self.mRegInvite:getText()

    if account == "" then
        GetCTipsManager():AddMessageTip('请输入账号')
        return true
    end
	if password == "" then
        GetCTipsManager():AddMessageTip('请输入密码')
        return true
    end
	if passwordagain == "" then
        GetCTipsManager():AddMessageTip('请输入确认密码')
        return true
    end
	if password ~= passwordagain then
        GetCTipsManager():AddMessageTip('两次输入的密码不一致')
        return true
    end
	if invite == "" then
        GetCTipsManager():AddMessageTip('请输入邀请码')
        return true
    end

    print(self.jieguo)
	self:SaveRememberedPassword(account, password)
    gGetLoginManager():RegisterAccount(account,password,invite,'123456')

	-- -- print(key)
    -- -- local host = gGetLoginManager():GetHost()
	-- -- print(host)
    -- -- local port = gGetLoginManager():GetPort()
	-- -- print(port)

    -- --gGetLoginManager():SetAccountInfo(account..",020000000000")
    -- gGetLoginManager():SetAccountInfo(account)

	-- SetServerIniInfo("Account", "LastAccount", account)
	-- Do not persist account credentials.

    -- GetCTipsManager():AddMessageTipById(144784)
    --gGetGameUIManager():LoginAccount(account,key)

	 --self.DestroyDialog()
	-- SelectServerEntry.getInstanceAndShow()
end

function SwitchAccountDialog:HandleLoginBtnClick(args)
	print(string.format("[SwitchAccountDialog][HandleLoginBtnClick] accountLen=%d passwordLen=%d",
		self.m_Account and _safeLen(self.m_Account:getText()) or 0,
		self.m_KeyEdit and _safeLen(self.m_KeyEdit:getText()) or 0))
    self:LoginGame()
    return true
end

function SwitchAccountDialog:HandleLoginAccountBtnClick(args)
    print("login page info")
   self.loginbtn:setProperty("NormalImage", "set:logindlginfo image:login1")
   self.loginFybtn:setProperty("NormalImage", "set:logindlginfo image:reg2")
    --print(self.loginFybtnStatus)
    --if self.loginFybtnStatus == true then
		-- self.loginFybtn:setProperty("HoverImage", "set:logindlginfo image:loginbtn")
	    -- self.loginFybtn:setProperty("NormalImage", "set:logindlginfo image:zhuce")
	    -- self.loginFybtn:setProperty("PushedImage", "set:logindlginfo image:zhuce")
    --     self.loginFybtnStatus = false
    --     self.loginFy:setVisible(true)
    --     self.regFy:setVisible(false)
    --     self.loginFybtn:setText("立即注册")
    -- else
		-- self.loginFybtn:setProperty("HoverImage", "set:logindlginfo image:zhuce")
	    -- self.loginFybtn:setProperty("NormalImage", "set:logindlginfo image:loginbtn")
	    -- self.loginFybtn:setProperty("PushedImage", "set:logindlginfo image:loginbtn")
        self.loginFybtnStatus = true
        self.loginFy:setVisible(false)
        self.regFy:setVisible(true)
         self.gologin:setVisible(true)
		self:FocusRegisterInput()
        --self.loginFybtn:setText("返回登录")
    --end
end

function SwitchAccountDialog:HandleLoginLoginBtnClick()
    print("login page info")
    --print(self.loginFybtnStatus)
   -- if self.loginFybtnStatus == true then
		-- self.loginFybtn:setProperty("HoverImage", "set:logindlginfo image:loginbtn")
	    -- self.loginFybtn:setProperty("NormalImage", "set:logindlginfo image:zhuce")
	    -- self.loginFybtn:setProperty("PushedImage", "set:logindlginfo image:zhuce")
        self.loginFybtnStatus = false
        self.loginFy:setVisible(true)
        self.regFy:setVisible(false)
         self.gologin:setVisible(false)
       self.loginbtn:setProperty("NormalImage", "set:logindlginfo image:login2")
       self.loginFybtn:setProperty("NormalImage", "set:logindlginfo image:reg1")
	   self:FocusLoginInput()
       -- self.loginFybtn:setText("立即注册")
   -- else
		-- self.loginFybtn:setProperty("HoverImage", "set:logindlginfo image:zhuce")
	    -- self.loginFybtn:setProperty("NormalImage", "set:logindlginfo image:loginbtn")
	    -- self.loginFybtn:setProperty("PushedImage", "set:logindlginfo image:loginbtn")
    --     self.loginFybtnStatus = true
    --     self.loginFy:setVisible(false)
    --     self.regFy:setVisible(true)
    --     self.loginFybtn:setText("返回登录")
    -- end
end
-- function SwitchAccountDialog:HandleKeyEditActivate(args)
--     return true
-- end

-- function SwitchAccountDialog:HandleKeyEditDeactivate(args)
--     return true
-- end

function SwitchAccountDialog:RegGame()

    local account = self.m_Account1:getText()

    if account == "" then
        GetCTipsManager():AddMessageTipById(144784)
        return true
    end

    local key = self.m_KeyEdit1:getText()
	if key == "" then
        GetCTipsManager():AddMessageTipById(144784)
        return true
    end

	-- print(key)
    -- local host = gGetLoginManager():GetHost()
	-- print(host)
    -- local port = gGetLoginManager():GetPort()
	-- print(port)

    --gGetLoginManager():SetAccountInfo(account..",020000000000")
	gGetLoginManager():SetAccountInfo(account)

	SetServerIniInfo("Account", "LastAccount", account)
	SetServerIniInfo("Password", "LastPassword", key)

    gGetLoginManager():LoginAccount(account,key)

	 --self.DestroyDialog()
	 --SelectServerEntry.getInstanceAndShow()
	-- if  Config.CUR_3RD_PLATFORM == "app" then
	-- 	gGetGameUIManager():sdkLogin()
	-- end
    -- if DeviceInfo:sGetDeviceType()==4 then --WIN7_32
    --     if gGetLoginManager():isFirstEnter() then
    --         windowsexplain.getInstanceAndShow()
    --     end
    -- end
--	if LoginTipDlg.getInstance() then
--		LoginTipDlg.DestroyDialog()
--	end
--	LoginTipDlg.getInstanceAndShow()

end
function SwitchAccountDialog:LoginGame()

    local account = self.m_Account:getText()

    if account == "" then
        GetCTipsManager():AddMessageTipById(144784)
        return true
    end

    local key = self.m_KeyEdit:getText()
	if key == "" then
        GetCTipsManager():AddMessageTipById(144784)
        return true
    end

	-- print(key)
    -- local host = gGetLoginManager():GetHost()
	-- print(host)
    -- local port = gGetLoginManager():GetPort()
	-- print(port)

    --gGetLoginManager():SetAccountInfo(account..",020000000000")
	gGetLoginManager():SetAccountInfo(account)

	self:SaveRememberedPassword(account, key)
	print(string.format("[SwitchAccountDialog][LoginGame] accountLen=%d passwordLen=%d", _safeLen(account), _safeLen(key)))

    gGetLoginManager():LoginAccount(account,key)

	 --self.DestroyDialog()
	 --SelectServerEntry.getInstanceAndShow()
	-- if  Config.CUR_3RD_PLATFORM == "app" then
	-- 	gGetGameUIManager():sdkLogin()
	-- end
    -- if DeviceInfo:sGetDeviceType()==4 then --WIN7_32
    --     if gGetLoginManager():isFirstEnter() then
    --         windowsexplain.getInstanceAndShow()
    --     end
    -- end
--	if LoginTipDlg.getInstance() then
--		LoginTipDlg.DestroyDialog()
--	end
--	LoginTipDlg.getInstanceAndShow()

end

return SwitchAccountDialog
