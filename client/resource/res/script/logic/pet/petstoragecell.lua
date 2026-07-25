petstoragecell = {}

setmetatable(petstoragecell, Dialog)
petstoragecell.__index = petstoragecell
local prefix = 0

function petstoragecell.CreateNewDlg(parent)
	local newDlg = petstoragecell:new()
	newDlg:OnCreate(parent)
	return newDlg
end

function petstoragecell.GetLayoutFileName()
	return "petdepotcell_mtg.layout"
end

function petstoragecell:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, petstoragecell)
	return self
end

function petstoragecell:OnCreate(parent)
	prefix = prefix + 1
	Dialog.OnCreate(self, parent, prefix)

	local winMgr = CEGUI.WindowManager:getSingleton()
	local prefixstr = tostring(prefix)

	self.window = CEGUI.toGroupButton(winMgr:getWindow(prefixstr .. "petdepotcell_mtg"))
	self.petCell = CEGUI.toItemCell(winMgr:getWindow(prefixstr .. "petdepotcell_mtg/itemcell"))
	self.name = winMgr:getWindow(prefixstr .. "petdepotcell_mtg/name")
	self.level = winMgr:getWindow(prefixstr .. "petdepotcell_mtg/level")
	self.scorce = winMgr:getWindow(prefixstr .. "petdepotcell_mtg/pingfennumber")
	self.type = winMgr:getWindow(prefixstr .. "petdepotcell_mtg/jinengshu")
	self.skill = winMgr:getWindow(prefixstr .. "petdepotcell_mtg/jineng")
	self.lock = winMgr:getWindow(prefixstr .. "petdepotcell_mtg/suo")
	self.pingfen = winMgr:getWindow(prefixstr .. "petdepotcell_mtg/pingfen")
	self.leixing = winMgr:getWindow(prefixstr .. "petdepotcell_mtg/leixing")
	self.pinzhi = winMgr:getWindow(prefixstr .. "petdepotcell_mtg/pinzhi")
end

function petstoragecell:setAllWeightVisible( enable )
	self.name:setVisible(enable)
	self.level:setVisible(enable)
	self.scorce:setVisible(enable)
	self.type:setVisible(enable)
	self.pingfen:setVisible(enable)
	self.leixing:setVisible(enable)
	self.skill:setVisible(enable)
	self.pinzhi:setVisible(enable)
	--self.petCell:setVisible(enbale)
end

function petstoragecell:HandleCellClicked( args )
	local petInfo = self.petInfo
	local dlg = require("logic.pet.petdetaildlg").getInstanceAndShow()
	dlg:refreshPetData(petInfo)
end

function petstoragecell:reloadData( petInfo, columnid)
    self.petInfo = petInfo
    SetPetItemCellInfock(self.petCell, petInfo)
    self.petCell:subscribeEvent("MouseClick", petstoragecell.HandleCellClicked, self)

    
    local petAttr = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(petInfo.baseid) 
    local qualityText = GetPetQualityText(petInfo.kind, petAttr.unusualid)  -- ∂¡»° petAttr.unusualid
    self.pinzhi:setText(qualityText) 

    local imgPath = GetPetKindImageRes(petInfo.kind, petInfo.unusualid)
	self.leixing:setProperty("Image", imgPath)
	if petInfo.iszhenshou ==1 then
		self.leixing:setProperty("Image", "set:cc25410 image:zhenshou")
			imgpath="set:cc25410 image:zhenshou"
	end
    UseImageSourceSize(self.leixing, imgPath)
    self.name:setText(petInfo.name)
    self.level:setText(MainPetDataManager.getInstance():GetPetLevel(petInfo.key, columnid)..BeanConfigManager.getInstance():GetTableByName("message.cstringres"):getRecorder(3).msg)
    self.scorce:setText(tostring(petInfo.score))
    self.type:setText(tostring(MainPetDataManager.getInstance():GetPetSkillNum(petInfo)))
end

return petstoragecell
