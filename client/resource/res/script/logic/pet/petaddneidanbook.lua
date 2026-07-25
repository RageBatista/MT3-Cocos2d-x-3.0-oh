------------------------------------------------------------------
-- 宠物内丹学习界面
------------------------------------------------------------------
require "logic.dialog"

local function getInternalSkillType(skillid)
	if not skillid or skillid <= 0 then
		return 0
	end
	return math.floor(skillid / 10000)
end

local function isInternalSkillMatchSlot(skillid, idx)
	local skillType = getInternalSkillType(skillid)
	if skillType == 26 then
		return idx >= 1 and idx <= 4
	elseif skillType == 27 then
		return idx == 6
	elseif skillType == 28 then
		return idx == 5
	end
	return false
end

local function getInternalMismatchTipId(idx)
	if idx == 5 then
		return 201088
	elseif idx == 6 then
		return 201089
	end
	return 201090
end

local function getExclusiveNeidanNeedTip(exclusiveSkillId)
	if not exclusiveSkillId or exclusiveSkillId <= 0 then
		return "当前宠物未配置专属内丹"
	end

	local skillName = tostring(exclusiveSkillId)
	local skillCfg = BeanConfigManager.getInstance():GetTableByName("skill.cpetskillconfig"):getRecorder(exclusiveSkillId)
	if skillCfg and skillCfg.skillname and skillCfg.skillname ~= "" then
		skillName = skillCfg.skillname
	end

	local upgradeCfg = BeanConfigManager.getInstance():GetTableByName("skill.cpetskillupgrade"):getRecorder(exclusiveSkillId)
	if upgradeCfg and upgradeCfg.book and upgradeCfg.book > 0 then
		local itemCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(upgradeCfg.book)
		if itemCfg and itemCfg.name and itemCfg.name ~= "" then
			return string.format("当前宠物需要专属内丹：%s（道具：%s）", skillName, itemCfg.name)
		end
	end

	return string.format("当前宠物需要专属内丹：%s", skillName)
end

local function showExclusiveNeidanNeedTip(dlg)
	if not dlg then
		return
	end

	local tip = dlg.requiredExclusiveTip or getExclusiveNeidanNeedTip(dlg.only)
	if tip and tip ~= "" then
		GetCTipsManager():AddMessageTip(tip)
	else
		GetCTipsManager():AddMessageTipById(201088)
	end
end

PetAddNeiDanBook = {
	booktype = 50,	--内丹书类型(d物品类型表.xlsx)
	petkey=0,
	idx=0,
	books = {},
	bookItems = {},
	lastSelectedBtn = nil
}
setmetatable(PetAddNeiDanBook, Dialog)
PetAddNeiDanBook.__index = PetAddNeiDanBook

local _instance
function PetAddNeiDanBook.getInstance()
	if not _instance then
		_instance = PetAddNeiDanBook:new()
		_instance:OnCreate()
	end
	return _instance
end

function PetAddNeiDanBook.getInstanceAndShow(_petkey_,_idx_)
	if not _instance then
		_instance = PetAddNeiDanBook:new()
		if _petkey_ ~= nil and _idx_~=nil then
			_instance.petkey = _petkey_
			_instance.idx = _idx_
			_instance.cellid = _idx_
		end
		_instance:OnCreate()
	else
		if _petkey_ ~= nil and _idx_~=nil then
			_instance.petkey = _petkey_
			_instance.idx = _idx_
			_instance.cellid = _idx_
		end
		_instance:SetVisible(true)
	end
	return _instance
end

function PetAddNeiDanBook.getInstanceNotCreate()
	return _instance
end

function PetAddNeiDanBook.DestroyDialog()
	if _instance then
		gGetRoleItemManager():RemoveLuaItemNumChangeNotify(_instance.eventItemNumChange)
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function PetAddNeiDanBook.CloseIfExist()
	if _instance then
		PetAddNeiDanBook.DestroyDialog()
	end
end

function PetAddNeiDanBook.GetLayoutFileName()
	return "petneidanadd.layout"
end

function PetAddNeiDanBook:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, PetAddNeiDanBook)
	return self
end

function PetAddNeiDanBook:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
	
	self.scroll = CEGUI.toScrollablePane(winMgr:getWindow("petneidanadd_mtg/main/scroll"))
	self.addBtn = CEGUI.toGroupButton(winMgr:getWindow("petneidanadd_mtg/xuexi"))
	self.addBtn:subscribeEvent("MouseClick", PetPropertyDlgNew.handleAddNeiDanClicked, self)
	local petData = MainPetDataManager.getInstance():FindMyPetByID(self.petkey)
	local petAttr = petData and BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(petData.baseid) or nil
	self.only = petAttr and petAttr.zmzsnd or 0
	self.requiredExclusiveTip = getExclusiveNeidanNeedTip(self.only)
	if self.idx ==5 then
		self:loadBookListzhuanshu()
		if #self.bookItems == 0 then
			showExclusiveNeidanNeedTip(self)
		end
	else
		self:loadBookList()
	end
	self.eventItemNumChange = gGetRoleItemManager():InsertLuaItemNumChangeNotify(PetAddNeiDanBook.onEventItemNumChange)
	self.itemid=0
	self.skillid=0
end
function PetPropertyDlgNew:handleAddNeiDanClicked(args)
	if self.petkey~=0 and self.itemid~=0 then
		if not isInternalSkillMatchSlot(self.skillid, self.idx) then
			GetCTipsManager():AddMessageTipById(getInternalMismatchTipId(self.idx))
			return
		end
		self.neidankey = self.itemid
		self.neidanskill = self.skillid
		local p = require("protodef.fire.pb.pet.cpetlearninternalbybook"):new()
		p.petkey = self.petkey
		p.bookkey = self.itemid
		p.idx = self.idx
		LuaProtocolManager:send(p)
	else
		if self.idx == 5 then
			showExclusiveNeidanNeedTip(self)
		else
			GetCTipsManager():AddMessageTipById(193536)
		end
		return
	end
	self.DestroyDialog()
end
function PetAddNeiDanBook:loadBookListzhuanshu()
	self.books = {}
    self.bookItems = {}
    self.lastSelectedBtn = nil
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	self.books = roleItemManager:GetItemKeyListByType(self.books, self.booktype)
	local index =0
	for i = 0, self.books:size() - 1 do
		local item = roleItemManager:FindItemByBagAndThisID(self.books[i], fire.pb.item.BagTypes.BAG)
		if item ~= nil then
			local skillid = BeanConfigManager.getInstance():GetTableByName("item.cpetitemeffect"):getRecorder(item:GetObjectID())
			if skillid and skillid.petskillid and self.only == skillid.petskillid and isInternalSkillMatchSlot(skillid.petskillid, self.idx) then
				local idx = index+1
				local cell = self:createCell(self.books[i], idx)
				local height = cell.window:getHeight():asAbsolute(0)
				local offset = (height+5) * index or 1
				cell.window:setPosition(CEGUI.UVector2(CEGUI.UDim(0, 1), CEGUI.UDim(0, offset)))
				self.bookItems[idx] = cell
				index =index+1
			end
		end
	end
end

function PetAddNeiDanBook:loadBookList()
	self.books = {}
    self.bookItems = {}
    self.lastSelectedBtn = nil
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	self.books = roleItemManager:GetItemKeyListByType(self.books, self.booktype)
	local index = 0
	for i = 0, self.books:size() - 1 do
		local item = roleItemManager:FindItemByBagAndThisID(self.books[i], fire.pb.item.BagTypes.BAG)
		if item ~= nil then
			local itemEffectData = BeanConfigManager.getInstance():GetTableByName("item.cpetitemeffect"):getRecorder(item:GetObjectID())
			if itemEffectData and isInternalSkillMatchSlot(itemEffectData.petskillid, self.idx) then
				index = index + 1
				local cell = self:createCell(self.books[i], index)
				local height = cell.window:getHeight():asAbsolute(0)
				local offset = (height+5) * (index - 1) or 1
				cell.window:setPosition(CEGUI.UVector2(CEGUI.UDim(0, 1), CEGUI.UDim(0, offset)))
				self.bookItems[index] = cell
			end
		end
	end
end

function PetAddNeiDanBook:onNeidanSuccess()
	local petDlg = PetPropertyDlgNew.getInstanceNotCreate and PetPropertyDlgNew.getInstanceNotCreate()
	if petDlg and self.idx and self.neidankey and self.neidanskill then
		petDlg:choosedSkillBookItem(self.idx, self.neidankey, self.neidanskill)
	end
	self:DestroyDialog()
end

function PetAddNeiDanBook:createCell(itemkey, idx)
	local cell = {}
	local winMgr = CEGUI.WindowManager:getSingleton()
	local prefix = tostring(itemkey)
	cell.window = CEGUI.toGroupButton(winMgr:loadWindowLayout("petskillbookcell_mtg.layout", prefix))
	cell.item = CEGUI.toItemCell(winMgr:getWindow(prefix .. "petskillbookcell_mtg/item"))
	cell.name = winMgr:getWindow(prefix .. "petskillbookcell_mtg/name")
	self.scroll:addChildWindow(cell.window)
	
	cell.window:setID(idx)
	cell.window:EnableClickAni(false)
	
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local item = roleItemManager:FindItemByBagAndThisID(itemkey, fire.pb.item.BagTypes.BAG)
	if item ~= nil then
		cell.itemData = item
		cell.itemKey = itemkey
		cell.item:SetImage(gGetIconManager():GetItemIconByID(item:GetBaseObject().icon))
		
		cell.name:setText(item:GetBaseObject().name)
		local color = item:GetNameColour()
		cell.name:setProperty("TextColours", color)
		cell.item:setID(item:GetObjectID())
		cell.item:subscribeEvent("TableClick", PetAddNeiDanBook.HandleShowToolTipsWithItemID, self)

		cell.window:subscribeEvent("SelectStateChanged", PetAddNeiDanBook.handleBookItemChoosed, self)
	end
	
	return cell
end

function PetAddNeiDanBook:HandleShowToolTipsWithItemID(args)
	local e = CEGUI.toWindowEventArgs(args)
	local nItemId = e.window:getID()
	local e2 = CEGUI.toMouseEventArgs(args)
	local touchPos = e2.position
	
	local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
	if not itemAttrCfg.id then
		return
	end
	local nPosX = touchPos.x
	local nPosY = touchPos.y
	local Commontipdlg = require "logic.tips.commontipdlg"
	local commontipdlg = Commontipdlg.getInstanceAndShow()
	--local nType = Commontipdlg.eType.eComeFrom
	local nType = Commontipdlg.eType.eNormal 
	commontipdlg:RefreshItem(nType,nItemId,nPosX,nPosY)
end

function PetAddNeiDanBook:handleBookItemChoosed(args)
	local wnd = CEGUI.toWindowEventArgs(args).window
	if self.lastSelectedBtn == wnd then
		return
	end

	self.lastSelectedBtn = wnd

	local idx = wnd:getID()
	local cell = self.bookItems[idx]
	local itemEffectData = BeanConfigManager.getInstance():GetTableByName("item.cpetitemeffect"):getRecorder(cell.itemData:GetObjectID())
	if itemEffectData then
		self.itemid=cell.itemData:GetThisID()
		self.skillid=itemEffectData.petskillid
		self.neidankey = self.itemid
		self.neidanskill = self.skillid
		--PetLianYaoDlg.getInstance():choosedSkillBookItem(cell.itemData:GetThisID(), itemEffectData.petskillid)
	end
end

function PetAddNeiDanBook.onEventItemNumChange(bagid, itemkey, itembaseid)
	if not _instance or not _instance:IsVisible() then
		return
	end
	if bagid ~= fire.pb.item.BagTypes.BAG then
		return
	end
	
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local item = roleItemManager:FindItemByBagAndThisID(itemkey, fire.pb.item.BagTypes.BAG)
	if not item then
		for i=1, #_instance.bookItems do
			local cell = _instance.bookItems[i]
			if cell.itemKey == itemkey then
				if _instance.lastSelectedBtn == cell.window then
					_instance.lastSelectedBtn = nil
				end
				CEGUI.WindowManager:getSingleton():destroyWindow(cell.window)
				table.remove(_instance.bookItems, i)
				for j=i,#_instance.bookItems do
					cell = _instance.bookItems[j]
					local h = cell.window:getPixelSize().height
					local y = cell.window:getYPosition()
					y.offset = y.offset-h-5
					cell.window:setYPosition(y)
					cell.window:setID(cell.window:getID()-1)
					cell.window:setHeight(CEGUI.UDim(0,h))
				end
				break
			end
		end
	end
end

return PetAddNeiDanBook
