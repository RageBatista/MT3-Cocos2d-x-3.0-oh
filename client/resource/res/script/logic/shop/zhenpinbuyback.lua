------------------------------------------------------------------
-- 珍品找回
------------------------------------------------------------------
require "logic.dialog"
require "logic.shop.zhenpinbuybackcell"

ZhenPinBuyBackDlg = {}
setmetatable(ZhenPinBuyBackDlg, Dialog)
ZhenPinBuyBackDlg.__index = ZhenPinBuyBackDlg

local ITEM = 1
local PET = 2

local _instance
function ZhenPinBuyBackDlg.getInstance()
	if not _instance then
		_instance = ZhenPinBuyBackDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function ZhenPinBuyBackDlg.getInstanceAndShow()
	if not _instance then
		_instance = ZhenPinBuyBackDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function ZhenPinBuyBackDlg.getInstanceNotCreate()
	return _instance
end

function ZhenPinBuyBackDlg.DestroyDialog()
	if _instance then
		if not _instance.m_bCloseIsHide then
            CurrencyManager.unregisterTextWidget(_instance.ownMoneyText)
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function ZhenPinBuyBackDlg.ToggleOpenClose()
	if not _instance then
		_instance = ZhenPinBuyBackDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function ZhenPinBuyBackDlg.GetLayoutFileName()
	return "npcshopbuyback.layout"
end

function ZhenPinBuyBackDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, ZhenPinBuyBackDlg)
	return self
end

function ZhenPinBuyBackDlg:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

    --assign window
	self.tree = CEGUI.toGroupBtnTree(winMgr:getWindow("npcshopbuyback/tree"))
	self.listBg = winMgr:getWindow("npcshopbuyback/textbg")
	self.priceText = winMgr:getWindow("npcshopbuyback/textzong")
	self.ownMoneyText = winMgr:getWindow("npcshopbuyback/textdan")
	self.okBtn = CEGUI.toPushButton(winMgr:getWindow("npcshopbuyback/btngoumai"))

	self.okBtn:subscribeEvent("Clicked", ZhenPinBuyBackDlg.handleBuyClicked, self)
    self.tree:subscribeEvent("ItemSelectionChanged", ZhenPinBuyBackDlg.HandleItemSelectionChanged, self)

    CurrencyManager.registerTextWidget(fire.pb.game.MoneyType.MoneyType_GoldCoin, self.ownMoneyText) --显示默认的商城货币类型
                
    --create widget
    local itembtn = self.tree:addItem(CEGUI.String(MHSD_UTILS.get_resstring(679)), ITEM)  --珍品物品
    self.tree:addItem(CEGUI.String(MHSD_UTILS.get_resstring(11626)), PET)   --珍品宠物
    self.tree:SetLastSelectItem(itembtn)

    local s = self.listBg:getPixelSize()
    self.tableView = TableView.create(self.listBg)
	self.tableView:setViewSize(s.width-20, s.height-20)
	self.tableView:setPosition(10, 10)
	self.tableView:setColumCount(2)
	self.tableView:setDataSourceFunc(self, ZhenPinBuyBackDlg.tableViewGetCellAtIndex)

    --init data
    self.curGroupType = ITEM
    self.datas = {{empty=false},{empty=true}}
	self.offsets = {0, 0}
	self.selectedUniqId = -1

    --[[<test
    for i=1,50 do
        local data = {
			uniqid = i,
            name = 'item' .. i,
            day = i%7+1,
            cost = (i+1)*1000,
			itemid = 340000+i,
			remaintime = 0
        }
        table.insert(self.datas[ITEM], data)
    end
    for i=1,32 do
        local data = {
			uniqid = i,
            name = 'pet' .. i,
            day = i%7+1,
            cost = (i+1)*1000,
			petid = 500220+i,
			remaintime = 0
        }
        table.insert(self.datas[PET], data)
    end
    self.tableView:setCellCount(#self.datas[self.curGroupType])
	self.tableView:reloadData()
    -->]]

	--请求物品列表
	local p = require("protodef.fire.pb.item.citemrecoverlist"):new()
	LuaProtocolManager:send(p)
end

function ZhenPinBuyBackDlg:tableViewGetCellAtIndex(tableView, idx, cell)
    if not cell then
        cell = ZhenPinBuyBackCell.CreateNewDlg(tableView.container)
        cell.window:subscribeEvent("SelectStateChanged", ZhenPinBuyBackDlg.handleGoodsCellClicked, self)
		cell.itemcell:subscribeEvent("MouseClick", ZhenPinBuyBackDlg.handleGoodsCellItemClicked, self)
    end

    local data = self.datas[self.curGroupType][idx+1]
	cell.window:setSelected(self.selectedUniqId == data.uniqid, false)
    cell.window:setID(idx)
	cell.itemcell:setID(idx)
    cell:setData(data, self.curGroupType)
    return cell
end

function ZhenPinBuyBackDlg:HandleItemSelectionChanged(args)
    local item = self.tree:getSelectedItem()
    if not item then
        return
    end
    local id = item:getID()
	if self.datas[id].empty then
		if id == PET then
			local p = require("protodef.fire.pb.pet.cpetrecoverlist"):new()
			LuaProtocolManager:send(p)
		end

		self.curGroupType  = id
		self.tableView:setCellCount(0)
		self.tableView:reloadData()
		return
	end

    if self.curGroupType ~= id then
		self.selectedUniqId = -1
		self.offsets[self.curGroupType] = self.tableView:getContentOffset()	
        self.curGroupType  = id
        self.priceText:setText(0)
        self.priceText:setProperty("BorderEnable", "False")

        self.tableView:setCellCount(#self.datas[self.curGroupType])
	    self.tableView:reloadData()
		self.tableView:setContentOffset(self.offsets[self.curGroupType])
    end
end

function ZhenPinBuyBackDlg:handleGoodsCellClicked(args)
    local idx = CEGUI.toWindowEventArgs(args).window:getID()
    local data = self.datas[self.curGroupType][idx+1]
    if data then
		self.selectedUniqId = data.uniqid
        self.priceText:setText(data.cost)
        CurrencyManager.setCompareTextWidget(self.ownMoneyText, self.priceText)
    end
end

function ZhenPinBuyBackDlg:handleGoodsCellItemClicked(args)
	local itemcell = CEGUI.toWindowEventArgs(args).window
	local parent = CEGUI.toGroupButton(itemcell:getParent())
	parent:setSelected(true)

	local idx = itemcell:getID()
	local data = self.datas[self.curGroupType][idx+1]
	if not data then
		return
	end

	if self.curGroupType == ITEM then
		local p = require("protodef.fire.pb.item.crecoveriteminfo"):new()
		p.uniqid = data.uniqid
		LuaProtocolManager:send(p)

		local roleItem = RoleItem:new()
	    roleItem:SetItemBaseData(data.itemid, 0)
        roleItem:SetObjectID(data.uniqid)
		local pos = itemcell:GetScreenPosOfCenter()
        local tip = Commontiphelper.showItemTip(data.itemid, roleItem:GetObject(), true, false, pos.x, pos.y)
		tip:RefreshPosCorrect(pos.x, pos.y)
		tip:showSwitchPageArrow(false)
        tip.isZhenPinBuyBack = true
        tip.roleItem = roleItem
		tip.itemkey = data.uniqid

	elseif self.curGroupType == PET then
		local p = require("protodef.fire.pb.pet.crecoverpetinfo"):new()
		p.uniqid = data.uniqid
		LuaProtocolManager:send(p)

		local dlg = PetDetailDlg.getInstanceAndShow()
		dlg:GetWindow():setVisible(false) --先隐藏，收到详细数据后再显示
	end
end

function ZhenPinBuyBackDlg:handleBuyClicked(args)
	if self.selectedUniqId == -1 then
		return
	end

	if self.curGroupType == ITEM then
		local p = require("protodef.fire.pb.item.citemrecover"):new()
		p.uniqid = self.selectedUniqId
		LuaProtocolManager:send(p)
	else
		local p = require("protodef.fire.pb.pet.cpetrecover"):new()
		p.uniqid = self.selectedUniqId
		LuaProtocolManager:send(p)
	end
end

--goodstype: 1.物品 2.宠物
function ZhenPinBuyBackDlg:recvGoodsList(list, goodstype)
	self.datas[goodstype] = list

	if self.curGroupType == goodstype then
		self.tableView:setCellCount(#list)
		self.tableView:reloadData()
	end
end

function ZhenPinBuyBackDlg:recvGoodsBuyBackResult(id, uid, goodstype)
	for k,v in pairs(self.datas[goodstype]) do
		if v.uniqid == uid then
			table.remove(self.datas[goodstype], k)
			if self.curGroupType == goodstype then
				self.tableView:setCellCount(#self.datas[goodstype])
				self.tableView:reloadData()
			end
			if self.selectedUniqId == uid and goodstype == self.curGroupType then
				self.priceText:setText(0)
				self.selectedUniqId = -1
			end
			break
		end
	end
end

return ZhenPinBuyBackDlg