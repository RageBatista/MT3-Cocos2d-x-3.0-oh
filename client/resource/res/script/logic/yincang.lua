require "logic.dialog"

YinCang = {}
setmetatable(YinCang, Dialog)
YinCang.__index = YinCang

local _instance
function YinCang.getInstance()
	if not _instance then
		_instance = YinCang:new()
		_instance:OnCreate()
	end
	return _instance
end

function YinCang.getInstanceAndShow()
	if not _instance then
		_instance = YinCang:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function YinCang.getInstanceNotCreate()
	return _instance
end

function YinCang.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function YinCang.ToggleOpenClose()
	if not _instance then
		_instance = YinCang:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function YinCang.GetLayoutFileName()
	return "yincang_mtg.layout"
end

function YinCang:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, YinCang)
	return self
end

function YinCang:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

	self.m_pReturn = CEGUI.toPushButton(winMgr:getWindow("yincang_mtg/anniu"))

	self.m_pReturn:subscribeEvent("Clicked", YinCang.HandleReturnClicked, self)
	
	self:SetState(1)
	
	self:Init()
	
end
function YinCang:Init()
	local winMgr = CEGUI.WindowManager:getSingleton()
	self.m_WindowArr = {}
	self.m_WindowCount = 9
	for i = 1, self.m_WindowCount do
		local WindowOne = {}
		WindowOne.Window = nil
		WindowOne.OX = 0
		WindowOne.CX = 0
		WindowOne.NX = 0
		WindowOne.OY = 0
		WindowOne.CY = 0
		WindowOne.NY = 0
		WindowOne.State = 1
		WindowOne.Type = 1
		self.m_WindowArr[i] = WindowOne
	end

    if not winMgr:isWindowPresent("LogoInfo/backImage") then
	    LogErr("YinCang Init Failed: " .. debug.traceback())
	end

	self.m_WindowArr[1].Window = winMgr:getWindow("LogoInfo/backImage")
	self.m_WindowArr[1].OY = self.m_WindowArr[1].Window:getYPosition():asAbsolute(0)
	self.m_WindowArr[1].CY = self.m_WindowArr[1].OY
	self.m_WindowArr[1].NY = self.m_WindowArr[1].OY - 120
	
	self.m_WindowArr[2].Window = winMgr:getWindow("LogoInfo/1")
	self.m_WindowArr[2].OX = self.m_WindowArr[2].Window:getXPosition():asAbsolute(0)
	self.m_WindowArr[2].CX = self.m_WindowArr[2].OX
	self.m_WindowArr[2].NX = self.m_WindowArr[2].OX - 120

	self.m_WindowArr[3].Window = winMgr:getWindow("UserPeticon")
	self.m_WindowArr[3].OY = self.m_WindowArr[3].Window:getYPosition():asAbsolute(0)
	self.m_WindowArr[3].CY = self.m_WindowArr[3].OY
	self.m_WindowArr[3].NY = self.m_WindowArr[3].OY - 260
	
	self.m_WindowArr[4].Window = winMgr:getWindow("chatoutsimple/mainback/1")
	self.m_WindowArr[4].OY = self.m_WindowArr[4].Window:getYPosition():asAbsolute(0)
	self.m_WindowArr[4].CY = self.m_WindowArr[4].OY
	self.m_WindowArr[4].NY = self.m_WindowArr[4].OY + 500
	
	self.m_WindowArr[5].Window = winMgr:getWindow("LogoInfo/dianchiheti")
	self.m_WindowArr[5].OY = self.m_WindowArr[5].Window:getYPosition():asAbsolute(0)
	self.m_WindowArr[5].CY = self.m_WindowArr[5].OY
	self.m_WindowArr[5].NY = self.m_WindowArr[5].OY - 120
	
	self.m_WindowArr[6].Window = winMgr:getWindow("MainControlDlg/right")
	self.m_WindowArr[6].OX = self.m_WindowArr[6].Window:getXPosition():asAbsolute(0)
	self.m_WindowArr[6].CX = self.m_WindowArr[6].OX
	self.m_WindowArr[6].NX = self.m_WindowArr[6].OX + 300
	
	self.m_WindowArr[7].Window = winMgr:getWindow("MainControlDlg/control")
	self.m_WindowArr[7].OX = self.m_WindowArr[7].Window:getXPosition():asAbsolute(0)
	self.m_WindowArr[7].CX = self.m_WindowArr[7].OX
	self.m_WindowArr[7].NX = self.m_WindowArr[7].OX + 300
	
	self.m_WindowArr[8].Window = winMgr:getWindow("MainControlDlg/teamporarybackpack")
	self.m_WindowArr[8].OX = self.m_WindowArr[8].Window:getXPosition():asAbsolute(0)
	self.m_WindowArr[8].CX = self.m_WindowArr[8].OX
	self.m_WindowArr[8].NX = self.m_WindowArr[8].OX + 300
	
	self.m_WindowArr[9].Window = winMgr:getWindow("MainControlDlg/back/system")
	self.m_WindowArr[9].OX = self.m_WindowArr[9].Window:getXPosition():asAbsolute(0)
	self.m_WindowArr[9].CX = self.m_WindowArr[9].OX
	self.m_WindowArr[9].NX = self.m_WindowArr[9].OX + 300
	
	
end
function YinCang:HandleReturnClicked(args)
	self:ShowAll()
end
function YinCang:SetState(State)
	self.m_State = State
	if self.m_State == 1 then
		self.m_pReturn:setVisible(false)
		
	elseif self.m_State == 2 then
		for i = 1, self.m_WindowCount do
			local WindowOne = self.m_WindowArr[i]
			if WindowOne.Type == 2 then
				
			end
		end
		if MainControl.getInstanceNotCreate() ~= nil then
			MainControl.getInstanceNotCreate():FoldButton()
			MainControl.getInstanceNotCreate():PlaySwitchFoldBtnOpenClose(2)
		end
		if Renwulistdialog.getSingleton() ~= nil then
			Renwulistdialog.getSingleton():HideAllDialogEx()
		end
	elseif self.m_State == 3 then
		self.m_pReturn:setVisible(true)	
	elseif self.m_State == 4 then
		for i = 1, self.m_WindowCount do
			local WindowOne = self.m_WindowArr[i]
			if WindowOne.Type == 2 then
				
			end
		end
		if Renwulistdialog.getSingleton() ~= nil then
			Renwulistdialog.getSingleton():ShowDialogEx()
		end
	end
end
function YinCang:Run(delta)
	local TimeSecond = delta / 1000
	local MoveOffset = TimeSecond * 300
	if self.m_State == 2 then
		local WindowState = 0
		for i = 1, self.m_WindowCount do
			local WindowOne = self.m_WindowArr[i]
			if WindowOne.Type == 1 then
				MoveOffset = math.abs(WindowOne.OX - WindowOne.NX) * 0.1
				if WindowOne.CX ~= WindowOne.NX then
					if WindowOne.NX < WindowOne.OX then
						WindowOne.CX = WindowOne.CX - MoveOffset
						if WindowOne.CX < WindowOne.NX then
							WindowOne.CX = WindowOne.NX
						end
					elseif WindowOne.NX > WindowOne.OX then
						WindowOne.CX = WindowOne.CX + MoveOffset
						if WindowOne.CX > WindowOne.NX then
							WindowOne.CX = WindowOne.NX
						end
					end
					WindowOne.Window:setXPosition(CEGUI.UDim(0, WindowOne.CX))
				end
				if WindowOne.CY ~= WindowOne.NY then
					MoveOffset = math.abs(WindowOne.OY - WindowOne.NY) * 0.1
					if WindowOne.NY < WindowOne.OY then
						WindowOne.CY = WindowOne.CY - MoveOffset
						if WindowOne.CY < WindowOne.NY then
							WindowOne.CY = WindowOne.NY
						end
					elseif WindowOne.NY > WindowOne.OY then
						WindowOne.CY = WindowOne.CY + MoveOffset
						if WindowOne.CY > WindowOne.NY then
							WindowOne.CY = WindowOne.NY
						end
					end
					WindowOne.Window:setYPosition(CEGUI.UDim(0, WindowOne.CY))
				end
				if WindowOne.CX == WindowOne.NX and WindowOne.CY == WindowOne.NY then
					WindowOne.State = 3
					WindowState = WindowState + 1
				end
			elseif WindowOne.Type == 2 then
				WindowState = WindowState + 1
			end
		end
		if WindowState == self.m_WindowCount then
			self:SetState(3)
		end
	elseif self.m_State == 4 then
		local WindowState = 0
		for i = 1, self.m_WindowCount do
			local WindowOne = self.m_WindowArr[i]
			if WindowOne.Type == 1 then
				if WindowOne.CX ~= WindowOne.OX then
					MoveOffset = math.abs(WindowOne.OX - WindowOne.NX) * 0.1
					if WindowOne.NX < WindowOne.OX then
						WindowOne.CX = WindowOne.CX + MoveOffset
						if WindowOne.CX > WindowOne.OX then
							WindowOne.CX = WindowOne.OX
						end
					elseif WindowOne.NX > WindowOne.OX then
						WindowOne.CX = WindowOne.CX - MoveOffset
						if WindowOne.CX < WindowOne.OX then
							WindowOne.CX = WindowOne.OX
						end
					end
					WindowOne.Window:setXPosition(CEGUI.UDim(0, WindowOne.CX))
				end
				if WindowOne.CY ~= WindowOne.OY then
					MoveOffset = math.abs(WindowOne.OY - WindowOne.NY) * 0.1
					if WindowOne.NY < WindowOne.OY then
						WindowOne.CY = WindowOne.CY + MoveOffset
						if WindowOne.CY > WindowOne.OY then
							WindowOne.CY = WindowOne.OY
						end
					elseif WindowOne.NY > WindowOne.OY then
						WindowOne.CY = WindowOne.CY - MoveOffset
						if WindowOne.CY < WindowOne.OY then
							WindowOne.CY = WindowOne.OY
						end
					end
					WindowOne.Window:setYPosition(CEGUI.UDim(0, WindowOne.CY))
				end
				if WindowOne.CX == WindowOne.OX and WindowOne.CY == WindowOne.OY then
					WindowOne.State = 1
					WindowState = WindowState + 1
				end
			elseif WindowOne.Type == 2 then
				WindowState = WindowState + 1
			end
		end
		if WindowState == self.m_WindowCount then
			self:SetState(1)
			if MainControl.getInstanceNotCreate() ~= nil then
                MainControl.getInstanceNotCreate():InitBtnShowStat()
			end
		end
	end
end
function YinCang:HideAll()
	if self.m_State ~= 1 then
		return
	end
	self:SetState(2)
end
function YinCang:ShowAll()
	if self.m_State ~= 3 then
		return
	end
	self:SetState(4)
end
function YinCang:ShowAllEx()
	if self.m_State ~= 3 then
		--return
	end
	local WindowState = 0
	for i = 1, self.m_WindowCount do
		local WindowOne = self.m_WindowArr[i]
		if WindowOne.Type == 1 then
			if WindowOne.CX ~= WindowOne.OX then
				WindowOne.CX = WindowOne.OX
				WindowOne.Window:setXPosition(CEGUI.UDim(0, WindowOne.CX))
			end
			if WindowOne.CY ~= WindowOne.OY then
				WindowOne.CY = WindowOne.OY
				WindowOne.Window:setYPosition(CEGUI.UDim(0, WindowOne.CY))
			end
			if WindowOne.CX == WindowOne.OX and WindowOne.CY == WindowOne.OY then
				WindowOne.State = 1
				WindowState = WindowState + 1
			end
		elseif WindowOne.Type == 2 then
			WindowState = WindowState + 1
		end
	end
	if WindowState == self.m_WindowCount then
		self:SetState(1)
		if MainControl.getInstanceNotCreate() ~= nil then
            MainControl.getInstanceNotCreate():InitBtnShowStat()
		end
	end
end
function YinCang.CHideAll()
    if _instance then
        _instance:HideAll()
    end
end
function YinCang.CShowAll()
    if _instance then
        _instance:ShowAll()
    end
end
function YinCang.CShowAllEx()
    if _instance then
        _instance:ShowAllEx()
    end
end

return YinCang
