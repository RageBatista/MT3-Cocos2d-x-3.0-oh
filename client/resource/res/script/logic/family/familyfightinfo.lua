require "logic.dialog"
require "logic.family.familyduizhantext"

FamilyFightInfo = {}
setmetatable(FamilyFightInfo, Dialog)
FamilyFightInfo.__index = FamilyFightInfo

local _instance
function FamilyFightInfo.getInstance()
	if not _instance then
		_instance = FamilyFightInfo:new()
		_instance:OnCreate()
	end
	return _instance
end

function FamilyFightInfo.getInstanceAndShow(contentList)
	if not _instance then
		_instance = FamilyFightInfo:new()
		_instance:OnCreate(contentList)
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function FamilyFightInfo.getInstanceNotCreate()
	return _instance
end

function FamilyFightInfo.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function FamilyFightInfo.ToggleOpenClose()
	if not _instance then
		_instance = FamilyFightInfo:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function FamilyFightInfo.GetLayoutFileName()
	return "babngzhantips_mtg.layout"
end

function FamilyFightInfo:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, FamilyFightInfo)
	return self
end

function FamilyFightInfo:OnCreate(contentList)
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
    self.bg = winMgr:getWindow("babngzhantips_mtg") 
    self.m_scroll = CEGUI.toScrollablePane(winMgr:getWindow("babngzhantips_mtg/list"))
	self.bg:setAlwaysOnTop(true)
	self.rankTable = {} 
	local cellcount = #contentList
	local DYList = {} 
	      DYList[0] = 0
	for idx =1,cellcount do
		local cell =   familyduizhantext.CreateNewDlg(self.m_scroll, idx-1)
		cell:SetShowContent(contentList[idx])
		local x = CEGUI.UDim(0, 0)
		local y = CEGUI.UDim(0, DYList[idx -1])
		local pos = CEGUI.UVector2(x,y)
		cell:GetWindow():setPosition(pos)
		DYList[idx] = DYList[idx -1] + cell.m_height
		table.insert(self.rankTable, cell)
	end 
end

return FamilyFightInfo