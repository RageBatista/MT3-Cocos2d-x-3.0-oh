BattleTipsCell = {}

setmetatable(BattleTipsCell, Dialog)
BattleTipsCell.__index = BattleTipsCell
local prefix = 0

function BattleTipsCell.CreateNewDlg(parent)
	local newDlg = BattleTipsCell:new()
	newDlg:OnCreate(parent)
	return newDlg
end

function BattleTipsCell.GetLayoutFileName()
	return "battletipscell.layout"
end

function BattleTipsCell:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, BattleTipsCell)
	return self
end

function BattleTipsCell:OnCreate(parent)
	prefix = prefix + 1
	Dialog.OnCreate(self, parent, prefix)

	local winMgr = CEGUI.WindowManager:getSingleton()
	local prefixstr = tostring(prefix)

	self.m_pIco = CEGUI.toSkillBox(winMgr:getWindow(prefixstr .. "battletipscell/skillbox"))
	self.m_pName = winMgr:getWindow(prefixstr .. "battletipscell/name")
	self.m_pDesc = winMgr:getWindow(prefixstr .. "battletipscell/xiaoguo")
	self.m_pDesc1 = winMgr:getWindow(prefixstr .. "battletipscell/xiaoguo1")

end

function BattleTipsCell:SetBuffID(BuffID, BuffLastRound)
	local buffconfig = GameTable.buff.GetCBuffConfigTableInstance():getRecorder(BuffID)	
	local BuffName = buffconfig.name
	local BuffDesc = buffconfig.strshowname
	local BuffDesc1 = buffconfig.discribe
	local BuffIco = buffconfig.shapeid

	if BuffLastRound > 200 then
		BuffName = BuffName .. "  " .. MHSD_UTILS.get_resstring(11399)
	else
		BuffName = BuffName .. "  " .. tostring(BuffLastRound) .. MHSD_UTILS.get_resstring(11182)
	end
	self.m_pName:setText(BuffName)
	self.m_pDesc:setText(BuffDesc)
	self.m_pDesc1:setText(BuffDesc1)
	SkillBoxControl.SetBuffInfo(self.m_pIco, BuffID, 0)
	
end

return BattleTipsCell
