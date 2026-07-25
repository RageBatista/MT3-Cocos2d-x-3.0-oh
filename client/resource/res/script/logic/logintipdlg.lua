require "logic.dialog"

LoginTipDlg = {}
setmetatable(LoginTipDlg, Dialog)
LoginTipDlg.__index = LoginTipDlg

local STATE = {
	MOVE_IN		= 1,
	SHOW		= 2,
	MOVE_OUT	= 3
}

local moveInDur = 0.5
local showDur = 1
local moveOutDur = 0.5
local topoffset = 20

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;

function LoginTipDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, LoginTipDlg)
    return self
end

function LoginTipDlg.getInstance()
    if not _instance then
        _instance = LoginTipDlg:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function LoginTipDlg.getInstanceAndShow()
	print("enter instance show")
    if not _instance then
        _instance = LoginTipDlg:new()
        _instance:OnCreate()
	else
		print("set visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function LoginTipDlg.getInstanceNotCreate()
    return _instance
end

function LoginTipDlg.DestroyDialog()
	if _instance then 
		_instance:OnClose()		
		_instance:Release()
		_instance = nil
	end
end

function LoginTipDlg.ToggleOpenClose()
	if not _instance then 
		_instance = LoginTipDlg:new() 
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

function LoginTipDlg.GetLayoutFileName()
    return "logintipdlg.layout"
end

function LoginTipDlg:OnCreate()

    Dialog.OnCreate(self)
	
	self.state = STATE.MOVE_IN
	self.elapsed = 0

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
    self.back = CEGUI.Window.toPushButton(winMgr:getWindow("LoginTipDlg/back"))
	self.m_pMainFrame:subscribeEvent("WindowUpdate", LoginTipDlg.HandleWindowUpdate, self)
	
	local text = self.back:getText()
	text = string.gsub(text, '(.*)(name)(.*)', '%1'..gGetLoginManager():GetAccount()..'%3')
	self.back:setText(text)
	
end

function LoginTipDlg:HandleWindowUpdate(e)
	
	local updateArgs = CEGUI.toUpdateEventArgs(e)
	local elapsed = updateArgs.d_timeSinceLastFrame
	
	self.elapsed = self.elapsed + elapsed
	
	local backheight = self.back:getPixelSize().height
	
	if self.state == STATE.MOVE_IN then
		if self.elapsed >= moveInDur then
			self.elapsed = 0
			self.state = STATE.SHOW
			self.back:setYPosition(CEGUI.UDim(0, topoffset))
			return
		end
		
		self.back:setYPosition(CEGUI.UDim(0, topoffset-(backheight+topoffset)*(moveInDur-self.elapsed)/moveInDur))
		
	elseif self.state == STATE.SHOW then
		if self.elapsed >= showDur then
			self.elapsed = 0
			self.state = STATE.MOVE_OUT
			return
		end
	
	
	elseif self.state == STATE.MOVE_OUT then
		if self.elapsed >= moveOutDur then
			self.DestroyDialog()
			return
		end
		self.back:setYPosition(CEGUI.UDim(0, topoffset-(backheight+topoffset)*self.elapsed/moveOutDur))
	end
	
end

return LoginTipDlg
