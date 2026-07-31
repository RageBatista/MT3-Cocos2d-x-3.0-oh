require "logic.dialog"

BattleTiShi = {}
setmetatable(BattleTiShi, Dialog)
BattleTiShi.__index = BattleTiShi

local _instance
function BattleTiShi.getInstance()
	if not _instance then
		_instance = BattleTiShi:new()
		_instance:OnCreate()
	end
	return _instance
end

function BattleTiShi.getInstanceAndShow()
	if not _instance then
		_instance = BattleTiShi:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function BattleTiShi.getInstanceNotCreate()
	return _instance
end

function BattleTiShi.DestroyDialog()
	if _instance then
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function BattleTiShi.ToggleOpenClose()
	if not _instance then
		_instance = BattleTiShi:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function BattleTiShi.GetLayoutFileName()
	return "battletishi.layout"
end

function BattleTiShi:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, BattleTiShi)
	return self
end

function BattleTiShi:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

	self.m_pText = winMgr:getWindow("battletishi/text1")


end

function BattleTiShi:SetText(Text)
	self.m_pText:setText(Text)
end

function BattleTiShi:SetSkillID(SkillID,PlayerOrPet)
	if SkillID == 0 then
		self.m_pText:setText("")
	else
		if PlayerOrPet == 0 then
			local nconfig = BeanConfigManager.getInstance():GetTableByName("skill.cskillconfig"):getRecorder(SkillID)
			self.m_pText:setText(nconfig.name)
		else
			local nconfig = BeanConfigManager.getInstance():GetTableByName("skill.cpetskillconfig"):getRecorder(SkillID)
			self.m_pText:setText(nconfig.skillname)		
		end
	end
end
function BattleTiShi:SetItemID(ItemID)
	if ItemID == 0 then
		self.m_pText:setText("")
	else
		local itembean = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(ItemID)
        if itembean then
		    self.m_pText:setText(itembean.name)
        end
	end
end

function BattleTiShi.CSetText(Text)
	if Text == "" then
		BattleTiShi.CSetVisible(false)
	else
		BattleTiShi.CSetVisible(true)
	end
	BattleTiShi.getInstance():SetText(Text)
end
function BattleTiShi.CSetSkillID(SkillID,PlayerOrPet)
	if SkillID == 0 then
		BattleTiShi.CSetVisible(false)
	else
		BattleTiShi.CSetVisible(true)
	end
	BattleTiShi.getInstance():SetSkillID(SkillID,PlayerOrPet)
end
function BattleTiShi.CSetItemID(ItemID)
	if ItemID == 0 then
		BattleTiShi.CSetVisible(false)
	else
		BattleTiShi.CSetVisible(true)
	end
	BattleTiShi.getInstance():SetItemID(ItemID)
end
function BattleTiShi.CSetVisible(Visible)
	BattleTiShi.getInstance():SetVisible(Visible)
end

return BattleTiShi
