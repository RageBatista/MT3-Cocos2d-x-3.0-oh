require "logic.dialog"

CNpcNameList = {}
setmetatable(CNpcNameList, Dialog)
CNpcNameList.__index = CNpcNameList

local _instance
local _idx = 0
function CNpcNameList.getInstance()
	if not _instance then
		_instance = CNpcNameList:new()
		_instance:OnCreate()
	end
	return _instance
end

function CNpcNameList.getInstanceAndShow()
	if not _instance then
		_instance = CNpcNameList:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function CNpcNameList.getInstanceNotCreate()
	return _instance
end

function CNpcNameList.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end

		_idx = 0
	end
end

function CNpcNameList.ToggleOpenClose()
	if not _instance then
		_instance = CNpcNameList:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function CNpcNameList.GetLayoutFileName()
	return "npcnamelist.layout"
end

function CNpcNameList:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, CNpcNameList)
	return self
end

function CNpcNameList:OnCreate()
	Dialog.OnCreate(self)

	local winMgr = CEGUI.WindowManager:getSingleton()
	self.winMgr =winMgr

	local winbg = winMgr:getWindow("npcnamelist")
--	winbg:subscribeEvent("MouseClick", CNpcNameList.DestroyDialog, self) 
	self.panel = winMgr:getWindow("npcnamelist/panel")
	self.list = CEGUI.toScrollablePane(winMgr:getWindow("npcnamelist/panel/list"))



end

function CNpcNameList.AddNpc(id, name)

	if _instance then
		_instance:AddCell(id, name)
	end
end

function CNpcNameList:AddCell(id, name)

	local prefix = id

	local button = CEGUI.toPushButton(self.winMgr:loadWindowLayout("chongdiecell_mtg.layout", prefix))
	--local richBox = CEGUI.toRichEditbox(self.winMgr:getWindow(prefix.."insetchatcell/main"))

	local color = CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("FF693F00"))

	button:setText(name)

--	richBox:AppendText(CEGUI.String(name), color)
--	richBox:Refresh()
--	richBox:setMousePassThroughEnabled(true)
--	richBox:setReadOnly(true)

	self.list:addChildWindow(button)

	button:setID(_idx)

	button:setUserString(tostring(_idx), prefix)
	button:setPosition(CEGUI.UVector2(CEGUI.UDim(0, 0), CEGUI.UDim(0, 0 + _idx * button:getHeight():asAbsolute(0))))
	button:subscribeEvent("Clicked", CNpcNameList.ClickNpc, self)

	_idx = _idx + 1
end

function CNpcNameList:ClickNpc(args)
	local e = CEGUI.toWindowEventArgs(args)
	local idx = e.window:getID()
	local value = e.window:getUserString(tostring(idx))

	local npcid = tonumber(value)

	GetMainCharacter():VisitNpcFormList(npcid)

	CNpcNameList.DestroyDialog()
end


return CNpcNameList
