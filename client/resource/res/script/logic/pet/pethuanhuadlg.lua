------------------------------------------------------------------
-- 宠物幻化
------------------------------------------------------------------
require "logic.dialog"
require "logic.multimenuset"
require "logic.pet.petyzm"

local RANDOM_ACT = {
eActionRun,
eActionAttack,
eActionMagic1
}

PetHuanHuaDlg = {
	selectedPetID = 0
}
setmetatable(PetHuanHuaDlg, Dialog)
PetHuanHuaDlg.__index = PetHuanHuaDlg

local _instance
function PetHuanHuaDlg.getInstance()
	if not _instance then
		_instance = PetHuanHuaDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function PetHuanHuaDlg.getInstanceAndShow()
	if not _instance then
		_instance = PetHuanHuaDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function PetHuanHuaDlg.getInstanceNotCreate()
	return _instance
end

function PetHuanHuaDlg.DestroyDialog()
	if _instance then 
		Dialog.OnClose(_instance)
		if not _instance.m_bCloseIsHide then
			_instance = nil
		end
	end
end

function PetHuanHuaDlg.ToggleOpenClose()
	if not _instance then
		_instance = PetHuanHuaDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function PetHuanHuaDlg.GetLayoutFileName()
	return "pethuanhua.layout"
end

function PetHuanHuaDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, PetHuanHuaDlg)
	return self
end

function PetHuanHuaDlg:OnCreate()
	Dialog.OnCreate(self)
	SetPositionOfWindowWithLabel(self:GetWindow())
	local winMgr = CEGUI.WindowManager:getSingleton()

	self.nameText = winMgr:getWindow("pethuanhua/Left/Page8")
	self.profileIcon = winMgr:getWindow("pethuanhua/Left/Item")
	self.filterBtn = CEGUI.toGroupButton(winMgr:getWindow("pethuanhua/left/btnquanbu"))
	self.lingshouBtn = CEGUI.toGroupButton(winMgr:getWindow("pethuanhua/left/btnquanbu1"))
	self.shenshouBtn = CEGUI.toGroupButton(winMgr:getWindow("pethuanhua/left/btnquanbu2"))
	self.babyGroupBtn = CEGUI.toGroupButton(winMgr:getWindow("pethuanhua/Left1/groupbtnbb"))
	self.bianyiGroupBtn = CEGUI.toGroupButton(winMgr:getWindow("pethuanhua/Left1/groupbtnbianyi"))
	self.ItemCellNeedItem = CEGUI.toItemCell(winMgr:getWindow("pethuanhua/textbg1/needitem"))
    self.filterBtn:setSelected(true)
	self.bianyiGroupBtn:setVisible(false)
	self.babyGroupBtn:setVisible(false)
	self.petScroll = CEGUI.toScrollablePane(winMgr:getWindow("pethuanhua/left/list"))
	self.petTable = CEGUI.toItemTable(winMgr:getWindow("pethuanhua/left/list/petTable"))
	self.huanhua = CEGUI.toPushButton(winMgr:getWindow("pethuanhua/Left1/textbg1/btnditu"))
	self.filterBtn:subscribeEvent("SelectStateChanged", PetHuanHuaDlg.handleFilterClicked, self)
	self.lingshouBtn:subscribeEvent("SelectStateChanged", PetHuanHuaDlg.handleLingShouClicked, self)
	self.ItemCellNeedItem:subscribeEvent("TableClick", PetHuanHuaDlg.HandleClickItemCell, self)
	self.huanhua:subscribeEvent("Clicked", PetHuanHuaDlg.handleHuanhuaClicked, self)
	self.petScroll:EnableAllChildDrag(self.petScroll)
	self.petTable:subscribeEvent("TableClick", PetHuanHuaDlg.handlePetClicked, self)
	self.babyGroupBtn:setID(fire.pb.pet.PetTypeEnum.BABY)
	self.bianyiGroupBtn:setID(fire.pb.pet.PetTypeEnum.VARIATION)
	self.bianyiGroupBtn:subscribeEvent("SelectStateChanged", PetHuanHuaDlg.handleGroupBtnClicked, self)
	self.babyGroupBtn:subscribeEvent("SelectStateChanged", PetHuanHuaDlg.handleGroupBtnClicked, self)
	self.shenshouBtn:subscribeEvent("SelectStateChanged", PetHuanHuaDlg.handleShenShouClicked, self)
	self.showPropType = 1	
	self.PetAttr={}
	self.Petkeyid=0
	self:loadAllPetData()
	self:refreshPetTable()
end
function PetHuanHuaDlg:handleGroupBtnClicked(args)
	local selectedBtn = self.babyGroupBtn:getSelectedButtonInGroup()
	local kind = selectedBtn:getID()
	self.curPetKind = kind
	local conf = self.petConfs[kind]
    --self.nameText:setProperty("TextColours", GetPetNameColour(conf.id))
	self.nameText:setProperty("TextColours", "FF50321A")
	self.nameText:setText(conf.name)
	self:refreshPetSprite(conf)
end
function PetHuanHuaDlg:loadAllPetData()
	self.allPetData = {}
	local ids = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getAllID()
	for i = 1, #ids do
		local conf = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(ids[i])
		if  conf.huanhuashow == 1 then
			table.insert(self.allPetData, conf)
		end
	end

	table.sort(self.allPetData, function(v1,v2)
		if v1.uselevel < v2.uselevel then
			return true
		end
		if v1.uselevel == v2.uselevel and v1.id < v2.id then
			return true
		end
		return false
	end)
end
function PetHuanHuaDlg:setPetAttr(PetAttr,petkeyid)
	self.PetAttr=PetAttr
	self.Petkeyid=petkeyid
end


function PetHuanHuaDlg:refreshPetTable(levelmin, levelmax)
	local filterData = {}
local levelmin, levelmax = 10000, 10000 -- 这里可以根据实际需求修改levelmin和levelmax的值

if levelmin == nil or (levelmin == 0 and levelmax == 0) then
    for _,v in pairs(self.allPetData) do
        if v.unusualid~=1 then
            table.insert(filterData, v)
        end
    end
elseif levelmin == 10000 and levelmax == 10000 then 
    for _,v in pairs(self.allPetData) do
        if v.unusualid == 1 then
            table.insert(filterData, v)
        end
    end
elseif levelmin == 20000 and levelmax == 20000 then 
    for _,v in pairs(self.allPetData) do
        table.insert(filterData, v)
    end
else
    for _,v in pairs(self.allPetData) do
        if  v.uselevel >= levelmin and v.uselevel <= levelmax and v.unusualid~=1 then
            table.insert(filterData, v)
        end
    end
end

if #filterData > 0 then
    self.selectedPetID = filterData[1].id
end
	self.selectedPetID = self.selectedPetID or 0
	
	
	local num = #filterData
	local row = math.ceil(num/3)
	if self.petTable:GetRowCount() ~= row then
		self.petTable:SetRowCount(row)
		local h = self.petTable:GetCellHeight()
		local spaceY = self.petTable:GetSpaceY()
		self.petTable:setHeight(CEGUI.UDim(0, (h+spaceY)*row))
	end

	for i=1, row*3 do
		local cell = self.petTable:GetCell(i-1)
		cell:Clear()
		cell:SetHaveSelectedState(true)
		if i <= num then
			local conf = filterData[i]
			local shapeData = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(conf.modelid)
			local image = gGetIconManager():GetImageByID(shapeData.littleheadID)
			cell:SetImage(image)
			cell:setID(conf.id)
            SetItemCellBoundColorByQulityPet(cell, conf.quality)
            self.petScroll:EnableChildDrag(cell)
			if conf.id == self.selectedPetID then
				cell:SetSelected(true)
			end
		else
			cell:setVisible(false)
		end
	end
	
	
	self:refreshSelectedPet()
end

function PetHuanHuaDlg:loadNeedItem()
	local petid=self.selectedPetID
	local conf = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(petid)
    if not conf then
        return
    end
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local needItemCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(conf.needitemid)
	if not needItemCfg then
		return
	end
	self.ItemCellNeedItem:SetImage(gGetIconManager():GetItemIconByID(needItemCfg.icon))
    SetItemCellBoundColorByQulityItemWithId(self.ItemCellNeedItem,needItemCfg.id)
	self.ItemCellNeedItem:setID(needItemCfg.id)
	local nOwnItemNum,nNeedItemNum = roleItemManager:GetItemNumByBaseID(needItemCfg.id),conf.needitemnum
	local strNumNeed_own = nOwnItemNum.."/"..nNeedItemNum
	self.ItemCellNeedItem:SetTextUnit(strNumNeed_own)
	if nOwnItemNum >= nNeedItemNum then
		self.ItemCellNeedItem:SetTextUnitColor(MHSD_UTILS.get_greencolor())
	else
		self.ItemCellNeedItem:SetTextUnitColor(MHSD_UTILS.get_redcolor())
	end
end
function PetHuanHuaDlg:getConsumptionNum(petid)
	local conf = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(petid)
    if not conf then
        return
    end
	return conf.needitemid,conf.needitemnum
end

function PetHuanHuaDlg:HandleClickItemCell(args)
	
	local e = CEGUI.toWindowEventArgs(args)
	local nItemId = e.window:getID()
	local e = CEGUI.toMouseEventArgs(args)
	local touchPos = e.position
	
	local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
	if not itemAttrCfg then
		return
	end
	local nPosX = touchPos.x
	local nPosY = touchPos.y
	local Commontipdlg = require "logic.tips.commontipdlg"
	local commontipdlg = Commontipdlg.getInstanceAndShow()
	local nType = Commontipdlg.eType.eComeFrom
	commontipdlg:RefreshItem(nType,nItemId,nPosX,nPosY)
end

function PetHuanHuaDlg:refreshSelectedPet()
	local conf = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(self.selectedPetID)
    if not conf then
        return
    end
	self.petConfs = {}
	self.petConfs[conf.kind] = conf
	if conf.kind ~= fire.pb.pet.PetTypeEnum.BABY and conf.thebabyid ~= 0 then 
		self.petConfs[fire.pb.pet.PetTypeEnum.BABY] = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(conf.thebabyid)
	end
	if conf.kind ~= fire.pb.pet.PetTypeEnum.VARIATION and conf.thebianyiid ~= 0 then 
		self.petConfs[fire.pb.pet.PetTypeEnum.VARIATION] = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(conf.thebianyiid)
	end
    if conf.kind ~= fire.pb.pet.PetTypeEnum.WILD and conf.thewildid ~= 0 then 
        self.petConfs[fire.pb.pet.PetTypeEnum.WILD] = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(conf.thewildid)
    end
    if conf.kind == fire.pb.pet.PetTypeEnum.SACREDANIMAL then 
	    self.curUpKind = 1
        self.showPropType = 2
    else
        self.showPropType = 1
	end
	
    local babyconf =  self.petConfs[fire.pb.pet.PetTypeEnum.BABY] or conf
	self.curPetKind = babyconf.kind
	
    --self.nameText:setProperty("TextColours", babyconf.colour)
	self.nameText:setProperty("TextColours", "FF50321A")
	self.nameText:setText(babyconf.name)
	self.babyGroupBtn:setSelected(true, false)
	self:refreshPetSprite(babyconf)
	self:loadNeedItem()
	
end

function PetHuanHuaDlg:refreshPetSprite(petConf)
	if not self.sprite then
		local s = self.profileIcon:getPixelSize()
		self.sprite = gGetGameUIManager():AddWindowSprite(self.profileIcon, petConf.modelid, Nuclear.XPDIR_BOTTOMRIGHT, s.width*0.5, s.height*0.5+50, false)
	else
		self.sprite:SetModel(petConf.modelid)
		self.sprite:SetUIDirection(Nuclear.XPDIR_BOTTOMRIGHT)
	end
    self.sprite:SetDyePartIndex(0,petConf.area1colour)
    self.sprite:SetDyePartIndex(1,petConf.area2colour)
	self.elapse = 0
	self.defaultActCurTimes = 0
	self.defaultActRepeatTimes = 3
	self.actType = eActionStand
end
function PetHuanHuaDlg:update(dt)
	if not self.sprite then
		return
	end
	self.elapse = self.elapse+dt
	if self.elapse >= self.sprite:GetCurActDuration() then
		self.elapse = 0
		if self.actType == eActionStand then
			self.defaultActCurTimes = self.defaultActCurTimes+1
			if self.defaultActCurTimes == self.defaultActRepeatTimes then
				self.defaultActCurTimes = 0
				local idx = math.random(1, #RANDOM_ACT)
				self.actType = RANDOM_ACT[idx]
				self.sprite:PlayAction(self.actType)
			end
		else
			self.actType = eActionStand
			self.sprite:PlayAction(self.actType)
		end
	end
end
function PetHuanHuaDlg:handlePetClicked(args)
	local id = CEGUI.toWindowEventArgs(args).window:getID()
	if self.selectedPetID ~= id then
		self.selectedPetID = id
		self:refreshSelectedPet()
	end
end

function PetHuanHuaDlg:handleFilterClicked(args)
	self:refreshPetTable(20000, 20000)
end
function PetHuanHuaDlg:handleLingShouClicked(args)
	self:refreshPetTable(10000, 10000)

end
function PetHuanHuaDlg:handleShenShouClicked(args)
	self:refreshPetTable(0, 0)

end
function PetHuanHuaDlg:handleHuanhuaClicked(args)--幻化预留方法
	local petid=self.selectedPetID
	local needitem,needitemnum = self:getConsumptionNum(petid)
	local roleitemmanager= require("logic.item.roleitemmanager").getInstance()
	local haveitemnum = roleitemmanager:GetItemNumByBaseID(needitem)
	if haveitemnum < needitemnum then
		GetCTipsManager():AddMessageTipById(192820)
		return
	end
	local conf = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(petid)
    if not conf then
        return
    end
	local dlg = Petyzm.getInstanceAndShow()
	dlg:setData(self.Petkeyid,petid)
end

return PetHuanHuaDlg
