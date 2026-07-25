TipGuajiImgCell = {}

setmetatable(TipGuajiImgCell, Dialog)
TipGuajiImgCell.__index = TipGuajiImgCell
local prefix = 0

function TipGuajiImgCell.CreateNewDlg(parent)
	local newDlg = TipGuajiImgCell:new()
	newDlg:OnCreate(parent)
	return newDlg
end

function TipGuajiImgCell.GetLayoutFileName()
	return "mapchoosetouxiangcell.layout"
end

function TipGuajiImgCell:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, TipGuajiImgCell)
	return self
end

function TipGuajiImgCell:OnCreate(parent)
	prefix = prefix + 1
	Dialog.OnCreate(self, parent, prefix)

	local winMgr = CEGUI.WindowManager:getSingleton()
	local prefixstr = tostring(prefix)

	self.m_itemcellImg = CEGUI.toItemCell(winMgr:getWindow(prefixstr .. "mapchoosetouxiangcell"))
	self.m_txtName = winMgr:getWindow(prefixstr .. "mapchoosetouxiangcell/text")
	self.m_txtXiyou = winMgr:getWindow(prefixstr .."mapchoosetouxiangcell/hanjian")
	--self.m_itemcellImg:SetBackGroundEnable(false)
	self.m_nRoleID = 0
	
end


function TipGuajiImgCell:SetRoleID( configID )
	self.m_nRoleID = configID
end

function TipGuajiImgCell:Refresh()

	local monsterData = GameTable.npc.GetCMonsterConfigTableInstance():getRecorder(self.m_nRoleID)
	local petID = monsterData.petid
	local petAttrCfg = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(monsterData.petid)
    if not petAttrCfg then return end

	local  modelID =  petAttrCfg.modelid
	local shapeData = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(petAttrCfg.modelid)

	local image = gGetIconManager():GetImageByID(shapeData.littleheadID)
	self.m_itemcellImg:SetImage(image)
	local text = shapeData.name
	self.m_txtName:setText(shapeData.name)
	if petAttrCfg.unusualid == 1 then		
		self.m_txtXiyou:setVisible(true)
	else
		self.m_txtXiyou:setVisible(false)
	end

end

return TipGuajiImgCell
