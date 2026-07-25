require "logic.dialog"

LockScreenDlg = {}
setmetatable(LockScreenDlg, Dialog)
LockScreenDlg.__index = LockScreenDlg

local _instance
function LockScreenDlg.getInstance()
	if not _instance then
		_instance = LockScreenDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function LockScreenDlg.getInstanceAndShow()
	if not _instance then
		_instance = LockScreenDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function LockScreenDlg.getInstanceNotCreate()
	return _instance
end

function LockScreenDlg.DestroyDialog()
	if _instance then
        setLocked(0)
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function LockScreenDlg.ToggleOpenClose()
	if not _instance then
		_instance = LockScreenDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function LockScreenDlg.GetLayoutFileName()
	return "pingmusuo.layout"
end

function LockScreenDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, LockScreenDlg)
	return self
end

function LockScreenDlg:OnCreate()
	Dialog.OnCreate(self)
	setLocked(1)
	SetPositionScreenCenter(self:GetWindow())
	
	local winMgr = CEGUI.WindowManager:getSingleton()
	
	local baseWindow = winMgr:getWindow("pingmusuo")
	self.m_moveButton = CEGUI.toPushButton(winMgr:getWindow("pingmusuo/pingmusuoanniu"))

	self.m_moveButton:subscribeEvent("MouseMove", LockScreenDlg.HandleButtonMove, self)
	self.m_moveButton:subscribeEvent("MouseLeave", LockScreenDlg.HandleButtonUp, self)
    self.m_moveButton:subscribeEvent("MouseButtonUp", LockScreenDlg.HandleButtonUp, self)

	
	self.m_baseprogress = winMgr:getWindow("pingmusuo/ditu")
	
	self.m_text = winMgr:getWindow("pingmusuo/wenzi")
	
	local buttonsize = self.m_moveButton:getPixelSize().width
	self.orgOffsetX = self.m_moveButton:getPosition().x.offset
	self.maxOffsetX = self.m_baseprogress:getPixelSize().width - buttonsize
	
	
	
	self.state = "normal"
    self:GetWindow():setTopMost(true)
end

function LockScreenDlg:HandleButtonUp(arg)
	if self.state ~= "normal" then
		return
	end
	
	self.m_text:setVisible(true)
	
	local pos = self.m_moveButton:getPosition()
	if math.abs(pos.x.offset - self.orgOffsetX - self.maxOffsetX) < 30 then
		self.state = "success"
	else
		self.state = "moveback"
	end
end



function LockScreenDlg:HandleButtonMove(arg)
    if self.state ~= "normal" then
        return
    end

    -- 先获取滑动按钮的位置
    local pos = self.m_moveButton:getPosition()

    local alpha = (pos.x.offset - self.orgOffsetX) / self.maxOffsetX
    alpha = math.max(0, math.min(1, alpha))
    self.m_baseprogress:setAlpha(1 - alpha)

    local eventargs = CEGUI.toWindowEventArgs(arg)
    local moveEvent = CEGUI.toMouseEventArgs(arg)
    local delta = moveEvent.moveDelta --移动偏移量
    local id = eventargs.window:getID()

    
    local size = self.m_moveButton:getSize()
    
    pos.x.offset = pos.x.offset+delta.x
    
    if pos.x.offset < self.orgOffsetX then
        pos.x.offset = self.orgOffsetX
    end
    
    if pos.x.offset - self.orgOffsetX > self.maxOffsetX then
        pos.x.offset = self.orgOffsetX + self.maxOffsetX
    end
    
    self.m_moveButton:setPosition(pos)
    self.m_moveButton:setSize(size)
end

function LockScreenDlg:run(delta)
	if _instance == nil then
		return
	end
	
	if self.state=="moveback" then
		local pos = self.m_moveButton:getPosition()
		local size = self.m_moveButton:getSize()
		
		pos.x.offset = pos.x.offset - 10
--[[		print("self org offset = "..self.orgOffsetX)
		print("current offset = "..pos.x.offset)--]]
		
		if pos.x.offset < self.orgOffsetX then
			pos.x.offset = self.orgOffsetX
			self.state="normal"
		end
		self.m_moveButton:setPosition(pos)
		self.m_moveButton:setSize(size)
	elseif self.state=="success" then
		self:DestroyDialog()
		self.state="quit"
	end
end

return LockScreenDlg
