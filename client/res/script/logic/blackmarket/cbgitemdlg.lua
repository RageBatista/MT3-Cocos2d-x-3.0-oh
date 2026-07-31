require "logic.dialog"
local pet = require("protodef.rpcgen.fire.pb.pet")
local item = require("protodef.rpcgen.fire.pb.item")

CBGItemDlg = {}
setmetatable(CBGItemDlg, Dialog)
CBGItemDlg.__index = CBGItemDlg

local _instance
local itemprefix = 1
local equipprefix = 1
local petprefix = 1
local GROUPID = {
	PAGE         = 1,
	STALL        = 2,
	BUYCATALOG1  = 3,
	SHOWCATALOG1 = 4,
	PET          = 5,
	BUYGOODS     = 6,
	SHOWGOODS    = 7
}
function CBGItemDlg.getInstance()
	if not _instance then
		_instance = CBGItemDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function CBGItemDlg.getInstanceAndShow()
	if not _instance then
		_instance = CBGItemDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function CBGItemDlg.getInstanceNotCreate()
	return _instance
end

function CBGItemDlg.DestroyDialog()
	if _instance then
		if _instance.currencyRegistered and _instance.haveDJQ then
			CurrencyManager.unregisterTextWidget(_instance.haveDJQ)
		end
		_instance.currencyRegistered = nil
		if _instance.m_hItemNumChangeNotify then
			gGetRoleItemManager():RemoveLuaItemNumChangeNotify(_instance.m_hItemNumChangeNotify)
			_instance.m_hItemNumChangeNotify = nil
		end
		if _instance.eventPetNumChange then
			gGetDataManager().m_EventPetNumChange:RemoveScriptFunctor(_instance.eventPetNumChange)
			_instance.eventPetNumChange = nil
		end
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function CBGItemDlg.ToggleOpenClose()
	if not _instance then
		_instance = CBGItemDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function CBGItemDlg.GetLayoutFileName()
	return "cbgitemdlg.layout"
end

function CBGItemDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, CBGItemDlg)
	return self
end

function CBGItemDlg:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
	self.winMgr = winMgr
	self.closeBtn = CEGUI.toPushButton(winMgr:getWindow("cbgitemdlg/close"))
	self.buyitem = CEGUI.toScrollablePane(winMgr:getWindow("cbgitemdlg/list/scorllableitem"))
	self.buyequip = CEGUI.toScrollablePane(winMgr:getWindow("cbgitemdlg/list/scorllableequip"))
	self.buypet = CEGUI.toScrollablePane(winMgr:getWindow("cbgitemdlg/list/scorllablepet"))
	self.haveDJQ = winMgr:getWindow("cbgitemdlg/top/unit1/di/text3")
	self.needDJQ = winMgr:getWindow("cbgitemdlg/top/unit1/di/text31")
	self.BuyItemButton = CEGUI.toPushButton(winMgr:getWindow("cbgitemdlg/buy/buyinfo/buybutton"))
	self.ItemTab = CEGUI.toGroupButton(winMgr:getWindow("cbgitemdlg/buy/item"))
	self.EquipTab = CEGUI.toGroupButton(winMgr:getWindow("cbgitemdlg/buy/equip"))
	self.PetTab = CEGUI.toGroupButton(winMgr:getWindow("cbgitemdlg/buy/pet"))
	self.SearchText = winMgr:getWindow("cbgitemdlg/top/unit1/di/text312")
	self.notip = winMgr:getWindow("cbgitemdlg/sell/sellinfo/di/notip")
	self.total = winMgr:getWindow("cbgitemdlg/buy/total")
	self.SearchButton = CEGUI.toPushButton(winMgr:getWindow("cbgitemdlg/top/searchbtn"))
	self.BuyTab = CEGUI.toGroupButton(winMgr:getWindow("cbgitemdlg/groupbtn/buybtn"))
	self.SellTab = CEGUI.toGroupButton(winMgr:getWindow("cbgitemdlg/groupbtn/buybtn1"))
	self.RecordTab = CEGUI.toGroupButton(winMgr:getWindow("cbgitemdlg/groupbtn/buybtn3"))
	self.ItemScorllable = CEGUI.toScrollablePane(winMgr:getWindow("cbgitemdlg/sell/sellbg/selllist"))
	self.PetScorllable = CEGUI.toScrollablePane(winMgr:getWindow("cbgitemdlg/sell/sellbg/selllist1"))
	self.ItemItemTable = CEGUI.toItemTable(winMgr:getWindow("cbgitemdlg/sell/sellinfo/di/scrollable/itemtable"))
	self.PetItemTable = CEGUI.toScrollablePane(winMgr:getWindow("cbgitemdlg/sell/sellinfo/di/scrollable/pettable"))
	self.SwitchItemButton = CEGUI.toGroupButton(winMgr:getWindow("cbgitemdlg/sell/sellinfo/di/itembutton"))
	self.SwitchPetButton = CEGUI.toGroupButton(winMgr:getWindow("cbgitemdlg/sell/sellinfo/di/petbutton"))
	self.SellList = CEGUI.toScrollablePane(winMgr:getWindow("cbgitemdlg/b3/baibg/list"))
	self.BuyList = CEGUI.toScrollablePane(winMgr:getWindow("cbgitemdlg/b3/baibg/list1"))
	self.sellscrollable = CEGUI.toScrollablePane(winMgr:getWindow("cbgitemdlg/sell/sellinfo/di/scrollable"))
	self.closeBtn:subscribeEvent("Clicked", CBGItemDlg.HandleCloseButtonClick, self)
	self.BuyItemButton:subscribeEvent("Clicked", CBGItemDlg.BuyItemButtonClick, self)
	self.ItemTab:subscribeEvent("SelectStateChanged", CBGItemDlg.HandleSelectTab, self)
	self.EquipTab:subscribeEvent("SelectStateChanged", CBGItemDlg.HandleSelectTab, self)
	self.PetTab:subscribeEvent("SelectStateChanged", CBGItemDlg.HandleSelectTab, self)
	self.SearchButton:subscribeEvent("Clicked", CBGItemDlg.OnSearchButtonClick, self)
	self.BuyTab:subscribeEvent("SelectStateChanged", CBGItemDlg.OnTableSelected, self)
	self.SellTab:subscribeEvent("SelectStateChanged", CBGItemDlg.OnTableSelected, self)
	self.RecordTab:subscribeEvent("SelectStateChanged", CBGItemDlg.OnTableSelected, self)
	self.SwitchItemButton:subscribeEvent("SelectStateChanged", CBGItemDlg.HandleSwitchClicked, self)
	self.SwitchPetButton:subscribeEvent("SelectStateChanged", CBGItemDlg.HandleSwitchClicked, self)
	self.ItemItemTable:subscribeEvent("TableClick", CBGItemDlg.handleBagItemClicked, self)
	self.buycontainer = winMgr:getWindow("cbgitemdlg/buy")
	self.sellcontainer = winMgr:getWindow("cbgitemdlg/sell")
	self.recordcontainer = winMgr:getWindow("cbgitemdlg/record")
	self.loadtip = winMgr:getWindow("cbgitemdlg/list/scorllable/tips")

	self.buyitem:subscribeEvent("NextPage", CBGItemDlg.querySallItems, self)
	self.buyequip:subscribeEvent("NextPage", CBGItemDlg.querySallEquips, self)
	self.buypet:subscribeEvent("NextPage", CBGItemDlg.querySallPets, self)


	self.PetItemTable:EnableAllChildDrag(self.PetItemTable)
	self.buttons = {}
	for i = 1, 3 do
		self.buttons[i] = CEGUI.toPushButton(winMgr:getWindow("cbgitemdlg/button" .. tostring(i)))
		self.buttons[i]:setID(i)
		self.buttons[i]:subscribeEvent("Clicked", CBGItemDlg.handleTabBtnClicked, self)
	end
	self.buttons[2]:SetPushState(true)
	self.bagPetCells = {}
	self.djq = 0
	CurrencyManager.registerTextWidget(fire.pb.game.MoneyType.MoneyType_EreditPoint, self.haveDJQ)
	self.currencyRegistered = true
	self:updateDjq(CurrencyManager.getOwnCurrencyMount(fire.pb.game.MoneyType.MoneyType_EreditPoint))
	self.itemcount = 0
	self.petcount = 0
	self.selectedSellItemkey = 0

	self.mysellItem = {}
	self.mysellPet = {}
	self:getMySell(0) --出售
	self.itempage = 1
	self.petpage = 1
	self.equippage = 1

	self.itemhasmore = -1
	self.equiphasmore = -1
	self.pethasmore = -1
	itemprefix = 1
	equipprefix = 1
	petprefix = 1

	self.itemdatacount = 0
	self.equipdatacount = 0
	self.petdatacount = 0
	self.itemscell = {}
	self.equipscell = {}
	self.petscell = {}
	self:querySallItems()
	self:querySallEquips()
	self:querySallPets()
	self:getMySell(1) --交易记录
	self:refreshBagPetTable()
	self:refreshBagItemTable()
	self.sellcells = {}
	self.buycells = {}
	self.selectedData = nil
	self.m_hItemNumChangeNotify = gGetRoleItemManager():InsertLuaItemNumChangeNotify(CBGItemDlg.OnItemNumChangeNotify)
	self.eventPetNumChange = gGetDataManager().m_EventPetNumChange:InsertScriptFunctor(CBGItemDlg.onEventPetNumChange)
end

--返回记录
function CBGItemDlg:clearSellList()
	for _, v in pairs(self.sellcells) do
		CEGUI.WindowManager:getSingleton():destroyWindow(v)
		self.SellList:removeChildWindow(v)
	end
	self.SellList:cleanupNonAutoChildren()
	self.sellcells = {}
end

function CBGItemDlg:clearBuyList()
	for _, v in pairs(self.buycells) do
		CEGUI.WindowManager:getSingleton():destroyWindow(v)
		self.BuyList:removeChildWindow(v)
	end
	self.BuyList:cleanupNonAutoChildren()
	self.buycells = {}
end

function CBGItemDlg:onMyRecord(data)
	self:clearSellList()
	self:clearBuyList()

	local winMgr = CEGUI.WindowManager:getSingleton()
	local sellidx = 1
	local buyidx = 1
	for k, v in pairs(data.goodslist) do
		if v.key == 1 then
			local c = (sellidx % 2 == 1 and "[colour='FF50321A']" or "")
			local prefixName = "itemselllist" .. tostring(sellidx)
			local layout = CEGUI.WindowManager:getSingleton():loadWindowLayout("itemsellcell.layout", prefixName)
			self.SellList:addChildWindow(layout)
			layout.date = winMgr:getWindow(prefixName .. "itemsellcell/date")
			layout.price = winMgr:getWindow(prefixName .. "itemsellcell/jiage")
			layout.name = winMgr:getWindow(prefixName .. "itemsellcell/itemname")
			layout.buyname = winMgr:getWindow(prefixName .. "itemsellcell/sallname")
			layout.buyname:setText(c .. tostring(v.buyrolename))
			layout.price:setText(c .. tostring(v.price))
			if v.itemtype == 1 or v.itemtype == 2 then
				local itemData = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(v.itemid)
				if itemData then
					layout.name:setText(c .. itemData.name)
				end
			else
				local petAttr = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(v.itemid)
				if petAttr then
					layout.name:setText(c .. petAttr.name)
				end
			end
			layout.date:setText(c .. os.date("%y-%m-%d", math.floor(v.uptime * 0.001)))
			layout:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0, -1), CEGUI.UDim(0.0, (k - 1) * 40)))
			self.sellcells[v.id] = layout
			sellidx = sellidx + 1
		else
			local c = (buyidx % 2 == 1 and "[colour='FF50321A']" or "")
			local prefixName = "itembuylist" .. tostring(buyidx)
			local layout = CEGUI.WindowManager:getSingleton():loadWindowLayout("itembuycell.layout", prefixName)
			self.BuyList:addChildWindow(layout)
			layout.buyname = winMgr:getWindow(prefixName .. "itembuycell/buyname")
			layout.price = winMgr:getWindow(prefixName .. "itembuycell/price")
			layout.name = winMgr:getWindow(prefixName .. "itembuycell/name")
			layout.date = winMgr:getWindow(prefixName .. "itembuycell/date")
			layout.price:setText(c .. tostring(v.price))
			layout.buyname:setText(c .. tostring(v.sellrolename))
			if v.itemtype == 1 or v.itemtype == 2 then
				local itemData = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(v.itemid)
				if itemData then
					layout.name:setText(c .. itemData.name)
				end
			else
				local petAttr = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(v.itemid)
				if petAttr then
					layout.name:setText(c .. petAttr.name)
				end
			end
			layout.date:setText(c .. os.date("%y-%m-%d", math.floor(v.uptime * 0.001)))
			layout:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0, -1), CEGUI.UDim(0.0, (k - 1) * 40)))
			self.buycells[v.id] = layout
			buyidx = buyidx + 1
		end
	end
end

function CBGItemDlg:querySallItems()
	if self.itemhasmore == 0 then
		GetCTipsManager():AddMessageTip('没有更多物品了')
		return
	end
	if self.itempage == 1 then
		for k, v in pairs(self.itemscell) do
			self.buyitem:removeChildWindow(v.window)
			CEGUI.WindowManager:getSingleton():destroyWindow(v.window)
		end
		self.itemscell = {}
	end
	self.loadtip:setVisible(true)
	local req = require "protodef.fire.pb.shop.cblackmarketitembrowse".Create()
	req.itemtype = 1
	req.page = self.itempage

	req.name = self.SearchText:getText()
	LuaProtocolManager.getInstance():send(req)
	self.itempage = self.itempage + 1
end

function CBGItemDlg:querySallEquips()
	if self.equiphasmore == 0 then
		GetCTipsManager():AddMessageTip('没有更多装备了')
		return
	end
	if self.equippage == 1 then
		for k, v in pairs(self.equipscell) do
			self.buyequip:removeChildWindow(v.window)
			CEGUI.WindowManager:getSingleton():destroyWindow(v.window)
		end
		self.equipscell = {}
	end
	self.loadtip:setVisible(true)
	local req = require "protodef.fire.pb.shop.cblackmarketitembrowse".Create()
	req.itemtype = 2
	req.page = self.equippage

	req.name = self.SearchText:getText()
	LuaProtocolManager.getInstance():send(req)
	self.equippage = self.equippage + 1
end

function CBGItemDlg:querySallPets()
	if self.pethasmore == 0 then
		GetCTipsManager():AddMessageTip('没有更多宠物了')
		return
	end
	if self.petpage == 1 then
		for k, v in pairs(self.petscell) do
			self.buypet:removeChildWindow(v.window)
			CEGUI.WindowManager:getSingleton():destroyWindow(v.window)
		end
		self.petscell = {}
	end
	self.loadtip:setVisible(true)
	local req = require "protodef.fire.pb.shop.cblackmarketitembrowse".Create()
	req.itemtype = 3
	req.page = self.petpage

	req.name = self.SearchText:getText()
	LuaProtocolManager.getInstance():send(req)
	self.petpage = self.petpage + 1
end

function CBGItemDlg:onSellItemResult(data)
	self.loadtip:setVisible(false)
	self.total:setText("总计商品数：" .. tostring(data.total) .. "条")
	if data.itemtype == 1 then
		self.itemdatacount = data.total
		self.itemhasmore = data.hasmore
		if data.reload == 1 then
			for k, v in pairs(self.itemscell) do
				self.buyitem:removeChildWindow(v.window)
				CEGUI.WindowManager:getSingleton():destroyWindow(v.window)
			end
		end
	elseif data.itemtype == 2 then
		self.equipdatacount = data.total
		self.equiphasmore = data.hasmore
		if data.reload == 1 then
			for k, v in pairs(self.equipscell) do
				self.buyequip:removeChildWindow(v.window)
				CEGUI.WindowManager:getSingleton():destroyWindow(v.window)
			end
			self.equipscell = {}
		end
	elseif data.itemtype == 3 then
		if data.reload == 1 then
			for k, v in pairs(self.petscell) do
				self.buypet:removeChildWindow(v.window)
				CEGUI.WindowManager:getSingleton():destroyWindow(v.window)
			end
			self.petscell = {}
		end
		self.petdatacount = data.total
		self.pethasmore = data.hasmore
	end

	if data.itemtype == 1 then
		for k, v in pairs(data.itemlist) do
			local prefix = "buyitemcell" .. tostring(itemprefix)
			local cell = {}
			cell.window = CEGUI.toGroupButton(self.winMgr:loadWindowLayout("blackmarkettemcell.layout", prefix))
			cell.window:setID(v.id)
			cell.window:setID2(v.itemid)
			cell.window:EnableClickAni(false)
			cell.itemcell = CEGUI.toItemCell(self.winMgr:getWindow(prefix .. "blackmarkettemcell/daoju"))
			cell.itemcell:subscribeEvent("TableClick", CBGItemDlg.handleGoodsCellItemClicked, self)
			cell.itemcell.data = v
			cell.nameText = self.winMgr:getWindow(prefix .. "blackmarkettemcell/mingzi")
			cell.price = self.winMgr:getWindow(prefix .. "blackmarkettemcell/jiage")
			cell.sellname = self.winMgr:getWindow(prefix .. "blackmarkettemcell/sallname")
			cell.window:subscribeEvent("MouseClick", CBGItemDlg.handleBuyItemClicked, self)
			self.buyitem:addChildWindow(cell.window)
			local sx = math.floor((itemprefix - 1) % 3) * cell.window:getWidth().offset
			local sy = math.floor((itemprefix - 1) / 3) * cell.window:getHeight().offset + 10
			cell.window:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0, sx), CEGUI.UDim(0.0, sy)))
			self.itemscell[v.id] = cell
			local itemData = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(v.itemid)
			local image = gGetIconManager():GetImageByID(itemData.icon)
			cell.itemcell:SetImage(image)
			cell.itemcell:setID2(v.key)
			cell.itemcell:setID(v.itemid)
			cell.itemcell:SetTextUnit(tostring(v.num))
			cell.price:setText(tostring(v.price))
			cell.nameText:setText(itemData.name)
			cell.sellname:setText("出售人:" .. v.sellrolename)
			cell.window.data = v
			itemprefix = itemprefix + 1
		end
	elseif data.itemtype == 2 then
		for k, v in pairs(data.itemlist) do
			local prefix = "buyequipcell" .. tostring(equipprefix)
			local cell = {}
			cell.window = CEGUI.toGroupButton(self.winMgr:loadWindowLayout("blackmarkettemcell.layout", prefix))
			cell.window:setID(v.id)
			cell.window:setID2(v.itemid)
			cell.window:EnableClickAni(false)
			cell.itemcell = CEGUI.toItemCell(self.winMgr:getWindow(prefix .. "blackmarkettemcell/daoju"))
			cell.itemcell:subscribeEvent("TableClick", CBGItemDlg.handleGoodsCellItemClicked, self)
			cell.itemcell.data = v
			cell.nameText = self.winMgr:getWindow(prefix .. "blackmarkettemcell/mingzi")
			cell.price = self.winMgr:getWindow(prefix .. "blackmarkettemcell/jiage")
			cell.sellname = self.winMgr:getWindow(prefix .. "blackmarkettemcell/sallname")
			cell.window:subscribeEvent("MouseClick", CBGItemDlg.handleBuyItemClicked, self)
			self.buyequip:addChildWindow(cell.window)
			local sx = math.floor((equipprefix - 1) % 3) * cell.window:getWidth().offset
			local sy = math.floor((equipprefix - 1) / 3) * cell.window:getHeight().offset + 10
			cell.window:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0, sx), CEGUI.UDim(0.0, sy)))
			self.equipscell[v.id] = cell
			local itemData = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(v.itemid)
			local image = gGetIconManager():GetImageByID(itemData.icon)
			cell.itemcell:SetImage(image)
			cell.itemcell:setID2(v.key)
			cell.itemcell:setID(v.itemid)
			cell.price:setText(tostring(v.price))
			cell.nameText:setText(itemData.name)
			cell.sellname:setText("出售人:" .. v.sellrolename)
			cell.window.data = v
			equipprefix = equipprefix + 1
		end
	elseif data.itemtype == 3 then
		for k, v in pairs(data.itemlist) do
			local prefix = "buypetcell" .. tostring(petprefix)
			local cell = {}
			cell.window = CEGUI.toGroupButton(self.winMgr:loadWindowLayout("blackmarketpetcell.layout", prefix))
			cell.window:setID(v.id)
			cell.window:EnableClickAni(false)
			cell.itemcell = CEGUI.toItemCell(self.winMgr:getWindow(prefix .. "blackmarketpetcell/daoju"))
			cell.itemcell:subscribeEvent("TableClick", CBGItemDlg.handlePetsCellItemClicked, self)
			cell.itemcell.data = v
			cell.nameText = self.winMgr:getWindow(prefix .. "blackmarketpetcell/mingzi")
			cell.price = self.winMgr:getWindow(prefix .. "blackmarketpetcell/jiage")
			cell.level = self.winMgr:getWindow(prefix .. "blackmarketpetcell/dengji")
			cell.sellname = self.winMgr:getWindow(prefix .. "blackmarketpetcell/sallname")
			cell.window:subscribeEvent("MouseClick", CBGItemDlg.handleBuyItemClicked, self)
			self.buypet:addChildWindow(cell.window)
			local sx = math.floor((petprefix - 1) % 3) * cell.window:getWidth().offset
			local sy = math.floor((petprefix - 1) / 3) * cell.window:getHeight().offset + 1
			cell.window:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0, sx), CEGUI.UDim(0.0, sy)))
			self.petscell[v.id] = cell
			local petAttr = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(v.itemid)
			if petAttr then
				cell.nameText:setProperty("TextColours", "ff743a0f")
				cell.nameText:setText(petAttr.name)
				local shapeData = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(petAttr
					.modelid)
				SetItemCellBoundColorByQulityPet(cell.itemcell, petAttr.quality)
				local image = gGetIconManager():GetImageByID(shapeData.littleheadID)
				cell.itemcell:SetStyle(CEGUI.ItemCellStyle_IconExtend)
				cell.itemcell:SetImage(image)
			end
			cell.level:setText(tostring(v.petlevel) .. "级")
			cell.price:setText(tostring(v.price))
			cell.sellname:setText("出售人:" .. v.sellrolename)
			cell.window.data = v
			petprefix = petprefix + 1
		end
	end
end

function CBGItemDlg:handleGoodsCellItemClicked(args)
	local itemcell = CEGUI.toWindowEventArgs(args).window
	local goods = itemcell.data
	if goods then
		local p = require("protodef.fire.pb.item.cotheritemtips"):new()
		p.roleid = goods.saleroleid
		p.packid = 7
		p.keyinpack = goods.key

		LuaProtocolManager:send(p)

		local pos = itemcell:GetScreenPosOfCenter()
		local roleItem = RoleItem:new()
		roleItem:SetItemBaseData(goods.itemid, 0)
		roleItem:SetObjectID(goods.itemid)
		local tip = Commontiphelper.showItemTip(goods.itemid, roleItem:GetObject(), true, false, pos.x, pos.y)
		tip:showSwitchPageArrow(false)
		tip.isStallTip = true
		tip.roleid = goods.saleroleid
		tip.roleItem = roleItem
		tip.itemkey = goods.key

		--switch item tips
		if  roleItem:GetFirstType() == eItemType_EQUIP then
			tip.enableSwitch = true
			tip:setSwitchPageCallFunc(StallDlg.handleSwitchItemTips, self)
			tip:setCloseCallFunc(function()
				self.switchTipsState = nil
			end)
		end

		if require("logic.tips.equipcomparetipdlg").getInstanceNotCreate() then
			return
		end

		local winH = GetScreenSize().height
		local tipH = tip:GetWindow():getPixelSize().height
		if itemcell:getID2() % 2 == 0 then --左列
			local x = itemcell:getParent():GetScreenPos().x + itemcell:getParent():getPixelSize().width
			local y = (winH - tipH) * 0.5
			tip:GetWindow():setPosition(NewVector2(x, y))
		else
			local x = itemcell:getParent():GetScreenPos().x - tip:GetWindow():getPixelSize().width
			local y = (winH - tipH) * 0.5
			tip:GetWindow():setPosition(NewVector2(x, y))
		end
	end
end

function CBGItemDlg:handlePetsCellItemClicked(args)
	local itemcell = CEGUI.toWindowEventArgs(args).window
	local goods = itemcell.data
	if goods then
		local dlg = PetDetailDlg.getInstanceAndShow()
		dlg:setPetBlackMarket(goods.itemid, goods.key, goods.saleroleid, 6) --6表示黑市宠物
		dlg:GetWindow():setVisible(false)                             --先隐藏，收到详细数据后再显示
	end
end

function CBGItemDlg:handleBuyItemClicked(args)
	local win = CEGUI.toWindowEventArgs(args).window
	local goods = win.data
	if goods then
		self.needDJQ:setText(tostring(goods.price))
		self.selectedData = goods
	end
end

function CBGItemDlg.onEventPetNumChange()
	if _instance then
		_instance:refreshBagPetTable()
	end
end

function CBGItemDlg.OnItemNumChangeNotify(bagid, itemkey, itembaseid)
	if _instance then
		_instance:refreshBagItemTable()
	end
end

function CBGItemDlg:getMySell(state)
	local req = require "protodef.fire.pb.shop.cblackmarketcontainerbrowse".Create()
	req.state = state
	LuaProtocolManager.getInstance():send(req)
end

function CBGItemDlg:onMySell(data)
	self:refreshBagPetTable()
	self:refreshBagItemTable()
	local itemTab = {}
	local petTab = {}
	for k, v in pairs(data.goodslist) do
		if v.itemtype == 1 or v.itemtype == 2 then
			table.insert(itemTab, v)
		else
			table.insert(petTab, v)
		end
	end
	self:onMySellItem(itemTab)
	self:onMySellPet(petTab)
end

function CBGItemDlg:ClaerMySellItem()
	for _, v in pairs(self.mysellItem) do
		self.ItemScorllable:removeChildWindow(v.window)
		CEGUI.WindowManager:getSingleton():destroyWindow(v.window)
	end
	self.ItemScorllable:cleanupNonAutoChildren()
	self.mysellItem = {}
end

function CBGItemDlg:onMySellItem(data)
	self:ClaerMySellItem()
	local bar = self.ItemScorllable:getVertScrollbar()
	bar:Stop()
	bar:setScrollPosition(0)
	for k, v in pairs(data) do
		local prefix = "mysellitem" .. tostring(k)
		local cell = {}
		cell.window = CEGUI.toGroupButton(self.winMgr:loadWindowLayout("blackmarketmyitemcell.layout", prefix))
		cell.window:setID(v.id)
		cell.window:setID2(v.key)
		cell.window:EnableClickAni(false)
		cell.itemcell = CEGUI.toItemCell(self.winMgr:getWindow(prefix .. "blackmarketmyitemcell/daoju"))
		cell.itemcell:subscribeEvent("TableClick", CBGItemDlg.handleGoodsCellItemClicked, self)
		cell.itemcell.data = v
		cell.nameText = self.winMgr:getWindow(prefix .. "blackmarketmyitemcell/mingzi")
		cell.price = self.winMgr:getWindow(prefix .. "blackmarketmyitemcell/jiage")
		cell.window:subscribeEvent("MouseClick", CBGItemDlg.handleMyBagItemClicked, self)
		self.ItemScorllable:addChildWindow(cell.window)
		local sx = math.floor((k - 1) % 2) * cell.window:getWidth().offset
		local sy = math.floor((k - 1) / 2) * cell.window:getHeight().offset + 1
		cell.window:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0, sx), CEGUI.UDim(0.0, sy)))
		self.mysellItem[v.id] = cell
		local itemData = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(v.itemid)
		local image = gGetIconManager():GetImageByID(itemData.icon)
		cell.itemcell:SetImage(image)
		cell.itemcell:SetTextUnit(tostring(v.num))
		cell.price:setText(tostring(v.price))
		cell.nameText:setText(itemData.name)
		cell.window.data = v
	end
end

function CBGItemDlg:ClaerMySellPet()
	for _, v in pairs(self.mysellPet) do
		self.PetScorllable:removeChildWindow(v.window)
		CEGUI.WindowManager:getSingleton():destroyWindow(v.window)
	end
	self.PetScorllable:cleanupNonAutoChildren()
	self.mysellPet = {}
end

function CBGItemDlg:onMySellPet(data)
	self:ClaerMySellPet()
	local bar = self.PetScorllable:getVertScrollbar()
	bar:Stop()
	bar:setScrollPosition(0)
	for k, v in pairs(data) do
		local prefix = "mysellpet" .. tostring(k)
		local cell = {}
		cell.window = CEGUI.toGroupButton(self.winMgr:loadWindowLayout("blackmarketmypetcell.layout", prefix))
		cell.window:setID(v.id)
		cell.window:EnableClickAni(false)
		cell.itemcell = CEGUI.toItemCell(self.winMgr:getWindow(prefix .. "blackmarketmypetcell/daoju"))
		cell.itemcell:subscribeEvent("TableClick", CBGItemDlg.handlePetsCellItemClicked, self)
		cell.itemcell.data = v
		cell.nameText = self.winMgr:getWindow(prefix .. "blackmarketmypetcell/mingzi")
		cell.price = self.winMgr:getWindow(prefix .. "blackmarketmypetcell/jiage")
		cell.level = self.winMgr:getWindow(prefix .. "blackmarketmypetcell/dengji")
		cell.window:subscribeEvent("MouseClick", CBGItemDlg.handleMyBagItemClicked, self)
		self.PetScorllable:addChildWindow(cell.window)
		local sx = math.floor((k - 1) % 2) * cell.window:getWidth().offset
		local sy = math.floor((k - 1) / 2) * cell.window:getHeight().offset + 1
		cell.window:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0, sx), CEGUI.UDim(0.0, sy)))
		self.mysellPet[v.id] = cell
		local petAttr = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(v.itemid)
		if petAttr then
			cell.nameText:setProperty("TextColours", "ff743a0f")
			cell.nameText:setText(petAttr.name)
			local shapeData = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(petAttr
				.modelid)
			SetItemCellBoundColorByQulityPet(cell.itemcell, petAttr.quality)
			local image = gGetIconManager():GetImageByID(shapeData.littleheadID)
			cell.itemcell:SetStyle(CEGUI.ItemCellStyle_IconExtend)
			cell.itemcell:SetImage(image)
		end
		cell.level:setText(tostring(v.petlevel) .. "级")
		cell.price:setText(tostring(v.price))
		cell.window.data = v
	end
end

function CBGItemDlg:HandleCloseButtonClick(args)
	self:DestroyDialog()
end

--------------------------------------获取可出售内容----------------------------------------
function CBGItemDlg:FiterPet(petData)
	if not petData or not petData.score or petData.score <= 0 then
		return false
	end
	return isPetTreasure(petData)
end

function CBGItemDlg:handleBagPetClicked(args)
	local btn = CEGUI.toWindowEventArgs(args).window
	local cell = self.bagPetCells[btn:getID()]
	local conf = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(cell.petData.baseid)
	if not conf then return end
	local lvLimit = 35 --珍品宠物出售等级限制
	if conf.uselevel < lvLimit and conf.kind ~= fire.pb.pet.PetTypeEnum.SACREDANIMAL then
		local str = MHSD_UTILS.get_msgtipstring(150511)
		str = string.gsub(str, "%$parameter1%$", lvLimit)
		GetCTipsManager():AddMessageTip(str) --参战等级低于35级的宠物不能上架
		return
	end

	if cell.petData.key == gGetDataManager():GetBattlePetID() then
		GetCTipsManager():AddMessageTipById(150509) --参战宠物不能上架
		return
	end

	local serverTime = gGetServerTime()
	if cell.petData.marketfreezeexpire > serverTime then
		local leftDay = math.ceil((cell.petData.marketfreezeexpire - serverTime) / (24 * 60 * 60 * 1000))
		leftDay = math.min(leftDay, conf.marketfreezetime)
		local str = MHSD_UTILS.get_msgtipstring(190021) --您购买的宠物有x天冻结期，x天后才可再次出售
		str = str:gsub("%$parameter1%$(.*)%$parameter2%$", conf.marketfreezetime .. "%1" .. leftDay)
		GetCTipsManager():AddMessageTip(str)
		return
	end

	local dlg = require "logic.shop.blackmarketuppet".getInstanceAndShow()
	dlg:setPetData(cell.petData)
end

function CBGItemDlg:clearList()
	for _, v in pairs(self.bagPetCells) do
		self.PetItemTable:removeChildWindow(v.window)
		CEGUI.WindowManager:getSingleton():destroyWindow(v.window)
	end
	self.PetItemTable:cleanupNonAutoChildren()
	self.bagPetCells = {}
end

function CBGItemDlg:refreshBagPetTable()
	self:clearList()
	self.notip:setVisible(false)
	local num = MainPetDataManager.getInstance():GetPetNum()
	local idx = 1
	self.petcount = 0
	for i = 1, num do
		local petData = MainPetDataManager.getInstance():getPet(i)
		if self:FiterPet(petData) then
			local prefix = "blackpet" .. idx
			local cell = {}
			cell.window = CEGUI.toGroupButton(self.winMgr:loadWindowLayout("blackmarketuppetcell.layout", prefix))
			cell.window:setGroupID(GROUPID.PET)
			cell.window:setID(idx)
			cell.window:EnableClickAni(false)
			cell.itemcell = CEGUI.toItemCell(self.winMgr:getWindow(prefix .. "blackmarketuppetcell/daoju"))
			cell.nameText = self.winMgr:getWindow(prefix .. "blackmarketuppetcell/mingzi")
			cell.levelText = self.winMgr:getWindow(prefix .. "blackmarketuppetcell/dengji")
			cell.lockImg = self.winMgr:getWindow(prefix .. "blackmarketuppetcell/lock")
			cell.window:subscribeEvent("MouseClick", CBGItemDlg.handleBagPetClicked, self)
			self.PetItemTable:addChildWindow(cell.window)

			cell.window:setPosition(CEGUI.UVector2(CEGUI.UDim(0, 0),
				CEGUI.UDim(0, (idx - 1) * (cell.window:getPixelSize().height + 3))))
			--SetPositionOffset(cell.window, 0, (idx - 1) * (cell.window:getPixelSize().height + 3))
			cell.itemcell:SetStyle(CEGUI.ItemCellStyle_IconExtend)
			local shapeData = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(petData
				:GetShapeID())
			local image = gGetIconManager():GetImageByID(shapeData.littleheadID)
			cell.itemcell:SetImage(image)
			cell.levelText:setText(petData:getAttribute(fire.pb.attr.AttrType.LEVEL) .. MHSD_UTILS.get_resstring(3))
			cell.nameText:setText(petData.name)
			local petAttr = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(petData.baseid)
			if petAttr then
				SetItemCellBoundColorByQulityPet(cell.itemcell, petAttr.quality)
			end
			local bTreasure = isPetTreasure(petData)
			if bTreasure then
				cell.itemcell:SetCornerImageAtPos("shopui", "zhenpin", 0, 1)
			else
				cell.levelText:setProperty("TextColours", "FF828282")
				cell.nameText:setProperty("TextColours", "FF828282")
				cell.isNormalPet = true --普通宠物
			end

			if petData.key == gGetDataManager():GetBattlePetID() then --出战
				cell.itemcell:SetCornerImageAtPos("chongwuui", "chongwu_zhan", 1, 0.5)
			end

			if petData.flag == 2 then --绑定
				cell.itemcell:SetCornerImageAtPos("common_equip", "suo", 1, 0.8)
			end

			if petData.marketfreezeexpire > gGetServerTime() then
				cell.lockImg:setVisible(true)
				cell.isLocked = true
			else
				cell.lockImg:setVisible(false)
			end
			cell.petData = petData
			self.bagPetCells[idx] = cell
			idx = idx + 1
			self.petcount = self.petcount + 1
		end
	end
end

function CBGItemDlg:handleBagItemClicked(args)
	local cell = CEGUI.toItemCell(CEGUI.toWindowEventArgs(args).window)

	local dlg = require "logic.shop.blackmarketup".getInstanceAndShow(self)
	dlg:setItemKey(cell:getID2())
end

function CBGItemDlg:handleMyBagItemClicked(args)
	local cell = CEGUI.toWindowEventArgs(args).window
	local id = cell:getID()
	gConfirmBox('您确定要将这个商品下架吗?', '下架', function()
		local req = require "protodef.fire.pb.shop.cblackmarketdown".Create()
		req.id = id
		LuaProtocolManager.getInstance():send(req)
	end)
end

function CBGItemDlg:refreshBagItemTable()
	self.notip:setVisible(false)
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local roleItems = roleItemManager:FilterBagItem(eItemFilterType_CanBlackSale)
	self.itemcount = 0
	local foundLastSelected = false
	if roleItems:size() > 0 then
		local col = self.ItemItemTable:GetColCount()
		local row = math.ceil(roleItems:size() / col)
		if self.ItemItemTable:GetRowCount() ~= row then
			self.ItemItemTable:SetRowCount(row)
			local h = self.ItemItemTable:GetCellHeight()
			local spaceY = self.ItemItemTable:GetSpaceY()
			self.ItemItemTable:setHeight(CEGUI.UDim(0, (h + spaceY) * row))
			self.sellscrollable:EnableAllChildDrag(self.ItemItemTable)
		end

		for i = 0, row * col - 1 do
			local cell = self.ItemItemTable:GetCell(i)
			cell:Clear()
			cell:SetHaveSelectedState(true)
			if i < roleItems:size() then
				cell:setVisible(true)
				local item = roleItems[i]
				local img = gGetIconManager():GetImageByID(item:GetIcon())
				cell:SetImage(img)
				refreshItemCellBind(cell, item:GetObject().loc.tableType, item:GetThisID())
				local itemAttr = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(item
					:GetObjectID())
				if itemAttr then
					SetItemCellBoundColorByQulityItem(cell, itemAttr.nquality, itemAttr.itemtypeid)
					if itemAttr.maxNum > 1 then --可堆叠的物品
						local curNum = item:GetNum()
						cell:SetTextUnit(curNum > 1 and curNum or "")
					else
						local level = Commontiphelper.getItemLevelValue(item:GetObjectID(), item:GetObject())
						cell:SetTextUnit(level > 0 and "Lv." .. level or "")
					end
				end

				--显示珍品角标
				if item.m_bIsTreasure then
					cell:SetCornerImageAtPos("ccui1", "tm", 0, 1)
				end

				cell:setID(item:GetObjectID()) --baseid
				cell:setID2(item:GetThisID()) --itemkey
				if self.selectedSellItemkey == item:GetThisID() then
					foundLastSelected = true
					cell:SetSelected(true)
				end
				self.itemcount = self.itemcount + 1
			else
				cell:setVisible(false)
			end
		end
	end

	if not foundLastSelected then
		self.selectedSellItemkey = 0
	end

	roleItems = nil
end

--------------------------------------------------------------------------------------------


function CBGItemDlg:BuyItemButtonClick(args)
	if self.selectedData == nil then
		GetCTipsManager():AddMessageTip("请您选择要购买的商品") --请选择要购买的商品
		return
	end
	self:updateDjq(CurrencyManager.getOwnCurrencyMount(fire.pb.game.MoneyType.MoneyType_EreditPoint))
	if self.djq < self.selectedData.price then
		GetCTipsManager():AddMessageTip("代金券不足，无法购买该商品") --代金券不足，无法购买该商品
		return
	end
	local myroleid = gGetDataManager():GetMainCharacterID()

	if myroleid == self.selectedData.saleroleid then
		GetCTipsManager():AddMessageTip("不能购买自己出售的商品") --不能购买自己出售的商品
		return
	end
	local name = ""
	local reqtype = 1
	if self.selectedData.itemtype == 1 or self.selectedData.itemtype == 2 then
		local itemData = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(self.selectedData
			.itemid)
		if itemData then
			name = itemData.name
		end
	else
		reqtype = 2
		local petAttr = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(self.selectedData
			.itemid)
		if petAttr then
			name = petAttr.name
		end
	end
	gConfirmBox(
		'您确定要花费' .. tostring(self.selectedData.price) .. '代金券购买 ' .. self.selectedData.sellrolename .. ' 出售的【' .. name ..
		'】吗?', '购买', function()
			local req = require "protodef.fire.pb.shop.cblackmarketitembuy".Create()
			req.id = self.selectedData.id
			req.itemtype = reqtype
			req.sallrole = self.selectedData.saleroleid
			LuaProtocolManager.getInstance():send(req)
		end)
end

function CBGItemDlg:HandleSelectTab(args)
	local eventargs = CEGUI.toWindowEventArgs(args)
	local curr = eventargs.window
	self.buyitem:setVisible(curr == self.ItemTab)
	self.buyequip:setVisible(curr == self.EquipTab)
	self.buypet:setVisible(curr == self.PetTab)
	self.selectedData = nil
	self.needDJQ:setText("0")
	if curr == self.ItemTab then
		self.total:setText("总计商品数：" .. tostring(self.itemdatacount) .. "条")
	elseif curr == self.EquipTab then
		self.total:setText("总计商品数：" .. tostring(self.equipdatacount) .. "条")
	elseif curr == self.PetTab then
		self.total:setText("总计商品数：" .. tostring(self.petdatacount) .. "条")
	end
end

function CBGItemDlg:OnSearchButtonClick(args)
	itemprefix = 1
	equipprefix = 1
	petprefix = 1
	if self.ItemTab:isSelected() then
		self.itempage = 1
		self.itemhasmore = -1
		self.itemdatacount = 0
		self:querySallItems()
	elseif self.EquipTab:isSelected() then
		self.equippage = 1
		self.equiphasmore = -1
		self.equipdatacount = 0
		self:querySallEquips()
	elseif self.PetTab:isSelected() then
		self.petpage = 1
		self.pethasmore = -1
		self.petdatacount = 0
		self:querySallPets()
	end
end

function CBGItemDlg:OnTableSelected(args)
	local eventargs = CEGUI.toWindowEventArgs(args)
	local curr = eventargs.window

	if curr == self.BuyTab then
		self.buycontainer:setVisible(true)
		self.sellcontainer:setVisible(false)
		self.recordcontainer:setVisible(false)
	elseif curr == self.SellTab then
		self.buycontainer:setVisible(false)
		self.sellcontainer:setVisible(true)
		self.recordcontainer:setVisible(false)
	elseif curr == self.RecordTab then
		self.buycontainer:setVisible(false)
		self.sellcontainer:setVisible(false)
		self.recordcontainer:setVisible(true)
	end
end

function CBGItemDlg:HandleSwitchClicked(args)
	local eventargs = CEGUI.toWindowEventArgs(args)
	local win = eventargs.window
	self.notip:setVisible(false)
	if win == self.SwitchItemButton then
		self.sellscrollable:setVisible(true)
		self.PetItemTable:setVisible(false)
		self.ItemScorllable:setVisible(true)
		self.PetScorllable:setVisible(false)
		if self.itemcount == 0 then
			self.notip:setText("暂无可上架道具")
			self.notip:setVisible(true)
			self.sellscrollable:setVisible(false)
		end
	else
		self.PetItemTable:setVisible(true)
		self.sellscrollable:setVisible(false)
		self.ItemScorllable:setVisible(false)
		self.PetScorllable:setVisible(true)
		if self.petcount == 0 then
			self.PetItemTable:setVisible(false)
			self.notip:setText("暂无可上架宠物")
			self.notip:setVisible(true)
		end
	end
end

function CBGItemDlg:updateDjq(djq)
	self.djq = djq
	self.haveDJQ:setText(tostring(djq))
end

function CBGItemDlg:handleTabBtnClicked(args)
	local eventargs = CEGUI.toWindowEventArgs(args)
	local id = eventargs.window:getID()
	if id == 1 then
		self:DestroyDialog()
		require "logic.blackmarket.cbggolddlg".getInstanceAndShow()
		return
	elseif id == 2 then
		self.buttons[2]:SetPushState(true)
		return
	elseif id == 3 then
		self:DestroyDialog()
		require "logic.blackmarket.cbgrole".getInstanceAndShow()
		return
	end
end

return CBGItemDlg
