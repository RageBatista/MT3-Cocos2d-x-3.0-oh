
local super = require "logic.singletondialog"
require "logic.item.depotmenubtn"

local pagenum = 25
local Depot = { }
setmetatable(Depot, super)
Depot.__index = Depot

local function onClickButton()
	local dlg = require "logic.tips.commontipdlg".getInstanceNotCreate()
	if dlg then
		dlg:DestroyDialog()
	end

	local self = Depot:getInstanceOrNot()
	if not self then
		return true
	end
	if not self.m_pLastSelected then
		return true
	end
	local cell = self.m_pLastSelected.Cell
	local bagid = self.m_pLastSelected.Bagid
	local pos = self.m_pLastSelected.Pos
	if cell:getID() ~= 0 then
        local roleItemManager = require("logic.item.roleitemmanager").getInstance()
        if bagid == fire.pb.item.BagTypes.BAG then
			local itemkey = cell:getID()
			local roleItem = roleItemManager:GetBagItem(itemkey)
			if roleItem:GetItemTypeID() == ITEM_TYPE.HORSE then
				local rideItemId = RoleItemManager.getInstance():getRideItemId()
				if rideItemId ~= 0 and rideItemId == roleItem:GetObjectID() then
					local num = roleItemManager:GetItemNumByBaseID(rideItemId)
					if num == 1 then
						GetCTipsManager():AddMessageTipById(180000) --请先下坐骑
						self.m_pLastSelected = nil
						return false
					end
				end
			end
		end

		require "protodef.fire.pb.item.ctransitem"
		local p = CTransItem.Create()
		p.srcpackid = bagid
		p.srckey = cell:getID()
		p.number = -1
		p.dstpackid = bagid == fire.pb.item.BagTypes.BAG and fire.pb.item.BagTypes.DEPOT or
		(bagid == fire.pb.item.BagTypes.DEPOT and fire.pb.item.BagTypes.BAG or nil)

		p.dstpos = -1
		if self.m_pLastSelected.Bagid == fire.pb.item.BagTypes.DEPOT then
			p.page = -1
		elseif self.m_pLastSelected.Bagid == fire.pb.item.BagTypes.BAG then
			p.page = self.m_pageDepotSelect
		end

		p.npcid = self.m_npckey or -1
		if p.dstpackid then
            LuaProtocolManager.getInstance():send(p)
			self.m_pLastSelected = nil
		end
	end
end

function Depot.onInternetReconnected()
	local dlg = Depot:getInstanceOrNot()
	if dlg then
		dlg:RefreshItemsBag(fire.pb.item.BagTypes.BAG)
		dlg:RefreshItemsDepot(fire.pb.item.BagTypes.DEPOT, dlg.m_pageDepotSelect)
	end
end

function Depot:GetItemSelectCellNew()
	return self.m_pSelectCellNew
end

function Depot:SetItemSelectCellNew(n)
	self.m_pSelectCellNew = n
end

function Depot:HandleBagShowSelect(e)

	local pCellOld = self:GetItemSelectCellNew()
	if pCellOld ~= nil then
		pCellOld:SetSelected(false);
	end



	local winArgs = CEGUI.toMouseEventArgs(e)

	local pCell = winArgs.window

	if pCell == nil then
		return false;
	else
		if not pCell:IsLock() then

			pCell:SetSelected(true)
			self:SetItemSelectCellNew(pCell)
		end
	end

	return true

end


function Depot:HandleDepotShowSelect(e)


	if e == nil then
		local depotold = self:GetItemSelectCellNew()
		if depotold ~= nil then
			depotold:SetSelected(false)
		end
		return false
	end

	local pCellOld = self:GetItemSelectCellNew()
	if pCellOld ~= nil then
		pCellOld:SetSelected(false);
	end

	local winArgs = CEGUI.toMouseEventArgs(e)

	local pCell = winArgs.window

	if pCell == nil then
		return false;
	else
		pCell:SetSelected(true)
		self:SetItemSelectCellNew(pCell)
	end

end

function Depot:clear()
	if DepotMenuBtn.getInstanceNotCreate() then
		DepotMenuBtn.DestroyDialog()
	end

end


function Depot:SetBtnMianFeiText()
	local strbuilder = StringBuilder:new()
	local strDepotWord = ""
	if self.m_pageDepotSelect <= 2 then
		strbuilder:Set("parameter1", self.m_pageDepotSelect)
		strDepotWord = strbuilder:GetString(MHSD_UTILS.get_resstring(11152))
	else
		strbuilder:Set("parameter1", self.m_pageDepotSelect - 2)
		strDepotWord = strbuilder:GetString(MHSD_UTILS.get_resstring(11153))
	end
    strbuilder:delete()
    if RoleItemManager.getInstance():getDepotNamesByIndex(self.m_pageDepotSelect) then
        strDepotWord = RoleItemManager.getInstance():getDepotNamesByIndex(self.m_pageDepotSelect)
    end
	self.m_btnMianfei:setText(strDepotWord)
end

function Depot:setDepotName(name)
    self.m_btnMianfei:setText(name)
end


function Depot:SwitchToDepotPage(id)
	print("SwitchToDepotPage" .. id)

	self:RefreshItemsDepot(fire.pb.item.BagTypes.DEPOT, id)
	self:RefreshPageBtn()
	self:RefreshDepotMianfeiBtn()
	self:SetBtnMianFeiText()


end

function Depot:RefreshItemsDepot(bagtype, page)
	print("Depot:RefreshItemsDepot")
	if page ~= self.m_pageDepotSelect then
		self:HandleDepotShowSelect(nil)
	end

	self.m_pageDepotSelect = page

    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local capacity = roleItemManager:GetBagCapacity(bagtype)
	for i = 1, pagenum do
		local pos = pagenum *(page - 1) + i - 1
		local pCell = self.m_pCells[bagtype][i]
		if pos >= capacity then
			local pItem = roleItemManager:FindItemByBagIDAndPos(bagtype, pos)
			pCell:SetStyle(CEGUI.ItemCellStyle_IconInside)
			pCell:SetImage(nil)

			pCell:SetCornerImageAtPos(nil, 0, 1)

			pCell:SetLockState(true)
			pCell:SetTextUnit("")
			pCell:setID(0)
		else
			pCell:SetLockState(false)
			local pItem = roleItemManager:FindItemByBagIDAndPos(bagtype, pos)
			if pItem then
				local image = gGetIconManager():GetItemIconByID(pItem:GetBaseObject().icon)
                pCell:setID2(pItem:GetThisID())
				if pItem:GetItemTypeID() == GetNumberValueForStrKey("ITEM_TYPE_HUOBAN") then
					pCell:SetStyle(CEGUI.ItemCellStyle_IconExtend)
				end
				pCell:SetImage(image)
				SetItemCellBoundColorByQulityItem(pCell, pItem:GetBaseObject().nquality)

				local nBagId = pItem:GetObject().loc.tableType
				local nItemKey = pItem:GetThisID()
				refreshItemCellBind(pCell, nBagId, nItemKey)

				if pItem:isTreasure() then
					pCell:SetCornerImageAtPos("ccui1", "newzp", 0, 1)
				else
					pCell:ClearCornerImage(0)
				end

                g_refreshItemCellEquipEndureFlag(pCell, nBagId, nItemKey)

				if pItem:GetNum() > 1 then
					pCell:SetTextUnit(pItem:GetNum())
				else
					pCell:SetTextUnit("")
				end
				pCell:setID(pItem:GetThisID())
			else
				pCell:SetStyle(CEGUI.ItemCellStyle_IconInside)
				pCell:SetImage(nil)
				SetItemCellBoundColorByQulityItem(pCell, 0)

				refreshItemCellBind(pCell, -1, -1)

				pCell:SetCornerImageAtPos(nil, 0, 1)

				pCell:SetTextUnit("")
				pCell:setID(0)
			end
		end
	end
end

function Depot:HandleCloseClick()
	LogInfo("Depot:HandleCloseClick")
	if Depot:getInstance() then
		Depot:getInstance():DestroyDialog()

	end
end

function Depot:OnClose()

	if DepotMenuBtn.getInstanceNotCreate() then
		DepotMenuBtn.DestroyDialog()
	end

	super.OnClose(self);
	self.m_npckey = nil;
end

function Depot:RefreshDepotCapacity(capacity)

	self:RefreshPageBtn()

	local page = self:GetCurPage(fire.pb.item.BagTypes.DEPOT)
	if not page then
		return
	end

	local cells = self.m_pCells[fire.pb.item.BagTypes.DEPOT]

	for i = 1, #cells do
		local idx =(page - 1) * pagenum +(i - 1)
		if idx >= capacity then
			break
		end
		local pCell = cells[i]
		if cells[i]:IsLock() then
			cells[i]:SetLockState(false)
		end
	end

	if DepotMenuBtn.getInstanceNotCreate() then
		DepotMenuBtn.getInstanceNotCreate():RefreshLockStat()
		DepotMenuBtn.getInstanceNotCreate():RefreshBgSize()
	end


end

function Depot:ModItemPos(p)
    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local cells = self.m_pCells[p.bagid]
	local pItem = roleItemManager:FindItemByBagAndThisID(p.itemkey, p.bagid)
	for i = 1, #cells do
		local pCell = cells[i]
		if cells[i]:getID() == p.itemkey then
			pCell:SetStyle(CEGUI.ItemCellStyle_IconInside)
			pCell:SetImage(nil)
			SetItemCellBoundColorByQulityItem(pCell, 0)
			local nBagId = -1
			local nItemKey = -1
			refreshItemCellBind(pCell, nBagId, nItemKey)


			pCell:SetTextUnit("")
			pCell:setID(0)
			break
		end
	end
	local newCell = cells[p.pos + 1]
	if newCell and pItem then
		local image = gGetIconManager():GetItemIconByID(pItem:GetBaseObject().icon)
		if pItem:GetItemTypeID() == GetNumberValueForStrKey("ITEM_TYPE_HUOBAN") then
			newCell:SetStyle(CEGUI.ItemCellStyle_IconExtend)
		end

		newCell:SetImage(image)
		SetItemCellBoundColorByQulityItem(newCell, pItem:GetBaseObject().nquality)

		local nBagId = pItem:GetObject().loc.tableType
		local nItemKey = pItem:GetThisID()
		refreshItemCellBind(newCell, nBagId, nItemKey)
       

		if pItem:isTreasure() then
			newCell:SetCornerImageAtPos("ccui1", "newzp", 0, 1)
		else
			newCell:ClearCornerImage(0)
		end

        g_refreshItemCellEquipEndureFlag(newCell, nBagId, nItemKey)
		if pItem:GetNum() > 1 then
			newCell:SetTextUnit(pItem:GetNum())
		else
			newCell:SetTextUnit("")
		end
		newCell:setID(pItem:GetThisID())
	end
	return true
end

function Depot:ModItemNum(p)
	local cells = self.m_pCells[p.bagid]
	for i = 1, #cells do
		local pCell = cells[i]
		if cells[i]:getID() == p.itemkey then
			pCell:SetTextUnit(p.curnum)
			break
		end
	end
	return true
end

function Depot:RemoveItem(p)
	local cells = self.m_pCells[p.bagid]
	for i = 1, #cells do
		local pCell = cells[i]
		if cells[i]:getID() == p.itemkey then
			pCell:SetStyle(CEGUI.ItemCellStyle_IconInside)
			pCell:SetImage(nil)
			SetItemCellBoundColorByQulityItem(pCell, 0)
			local nBagId = -1
			local nItemKey = -1
			refreshItemCellBind(pCell, nBagId, nItemKey)


			pCell:SetTextUnit("")
			pCell:setID(0)
			pCell:Clear()
			break
		end
	end

end

function Depot:AddItem(p)
    local roleItemManager = require("logic.item.roleitemmanager").getInstance()

	local curPageNum = p.bagid == fire.pb.item.BagTypes.BAG and roleItemManager:GetBagCapacity(p.bagid) or
	(p.bagid == fire.pb.item.BagTypes.DEPOT and pagenum or nil)


	local page = self:GetCurPage(p.bagid)
	if not page then
		return
	end
	local cells = self.m_pCells[p.bagid]
	for i = 0, p.data:size() -1 do
		local item = p.data[i]
		if item.position >=(page - 1) * curPageNum and item.position < page * curPageNum then
			local pItem = roleItemManager:FindItemByBagIDAndPos(p.bagid, item.position)
			local posNN = item.position
			local pCell = cells[item.position % curPageNum + 1]
            pCell:setID2(pItem:GetThisID())
			pCell:SetHaveSelectedState(true)
			local attr = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(item.id)
            if attr then
			    local image = gGetIconManager():GetItemIconByID(attr.icon)
			    if pItem:GetItemTypeID() == GetNumberValueForStrKey("ITEM_TYPE_HUOBAN") then
				    pCell:SetStyle(CEGUI.ItemCellStyle_IconExtend)
			    end
			    pCell:SetImage(image)
			    SetItemCellBoundColorByQulityItem(pCell, attr.nquality)
            end

			local nBagId = pItem:GetObject().loc.tableType
			local nItemKey = pItem:GetThisID()
			refreshItemCellBind(pCell, nBagId, nItemKey)
            g_refreshItemCellEquipEndureFlag(pCell, nBagId, nItemKey)

			if item.number > 1 then
				pCell:SetTextUnit(item.number)
			else
				pCell:SetTextUnit("")
			end
			pCell:setID(item.key)
		end
	end

end

function Depot:RefreshBag(p)

	self:RefreshPageBtn()

	local cells = self.m_pCells[p.bagid]
	local capacity = p.baginfo.capacity
	local function hasItem(pos)
		for i = 0, p.baginfo.items:size() -1 do
			local item = p.baginfo.items[i]
			if item.position == pos then
				return p.baginfo.items[i]
			end
		end
		return false
	end
	local page = self:GetCurPage(p.bagid)

	if not page then
		return
	end

	for i = 1, pagenum do
		local pos = pagenum *(page - 1) + i - 1
		local pCell = cells[i]
		if pos >= capacity then
			pCell:SetStyle(CEGUI.ItemCellStyle_IconInside)
			pCell:SetImage(nil)


			if pCell:getTreasureShow() then
				pCell:SetCornerImageAtPos(nil, 0, 1)
			end
			pCell:SetLockState(true)
			pCell:SetTextUnit("")
			pCell:setID(0)
		else
			pCell:SetLockState(false)

			local item = hasItem(pos)
			if item then
				local attr = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(item.id)
                if attr then
				    local image = gGetIconManager():GetItemIconByID(attr.icon)
				    if item:GetItemTypeID() == GetNumberValueForStrKey("ITEM_TYPE_HUOBAN") then
					    pCell:SetStyle(CEGUI.ItemCellStyle_IconExtend)
				    end
				    pCell:SetImage(image)
				    SetItemCellBoundColorByQulityItem(pCell, attr.nquality)
                end

				if item.number > 1 then
					pCell:SetTextUnit(item.number)
				else
					pCell:SetTextUnit("")
				end
				pCell:setID(item.key)
			else
				pCell:SetStyle(CEGUI.ItemCellStyle_IconInside)
				pCell:SetImage(nil)
				SetItemCellBoundColorByQulityItem(pCell, 0)
				local nBagId = -1
				local nItemKey = -1
				refreshItemCellBind(pCell, nBagId, nItemKey)


				pCell:SetTextUnit("")
				pCell:setID(0)
			end
		end
	end

end

function Depot:GetCurPage(bagid)
	print("Depot:GetCurPage" .. self.m_pageDepotSelect)
	local page = bagid == fire.pb.item.BagTypes.BAG and 1 or
	(bagid == fire.pb.item.BagTypes.DEPOT and self.m_pageDepotSelect or nil)

	return page

end

function Depot:HandleTidyBagBtnClicked(e)

	local now = os.time()
	if (os.time() - self.m_secClickTidyDepot) > 3 then
		self.m_secClickTidyDepot = os.time()

		require "protodef.fire.pb.item.clistpack";
		local tidy = CListPack.Create();
		tidy.packid = fire.pb.item.BagTypes.BAG
		tidy.npcid = 0
		LuaProtocolManager.getInstance():send(tidy)
		os.time()
	else
		GetCTipsManager():AddMessageTip(GameTable.message.GetCMessageTipTableInstance():getRecorder(142109).msg)
	end



end

function Depot:HandleTidyDepotBtnClicked(e)



	local now = os.time()
	if (os.time() - self.m_secClickTidyDepot) > 3 then
		self.m_secClickTidyDepot = os.time()

		require "protodef.fire.pb.item.clistdepot";
		local tidy = CListDepot.Create();
		tidy.pageid = self.m_pageDepotSelect
		LuaProtocolManager.getInstance():send(tidy)
		os.time()
	else
		GetCTipsManager():AddMessageTip(GameTable.message.GetCMessageTipTableInstance():getRecorder(142109).msg)
	end



end

function Depot:RefreshItemsBag(bagtype)
    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    
	local capacity = roleItemManager:GetBagCapacity(bagtype)

	local total = roleItemManager:GetBagShowNum(bagtype)

	local tableSize = CalTableSize(self.m_itemTableBag, total);
	self.m_itemTableBag:setSize(tableSize);

	for i = 1, total do

		local pos = i - 1
		local pCell = self.m_pCells[bagtype][i]
		pCell:setID2(0);
		if pos >= capacity then
			local pItem = roleItemManager:FindItemByBagIDAndPos(bagtype, pos)
			pCell:SetStyle(CEGUI.ItemCellStyle_IconInside)
			pCell:SetImage(nil)

			pCell:SetCornerImageAtPos(nil, 0, 1)

			pCell:SetLockState(true)
			pCell:SetTextUnit("")
			pCell:setID(0)
		else
			pCell:SetLockState(false)
			local pItem = roleItemManager:FindItemByBagIDAndPos(bagtype, pos)
			if pItem then
				local image = gGetIconManager():GetItemIconByID(pItem:GetBaseObject().icon)
                pCell:setID2(pItem:GetThisID())
				if pItem:GetItemTypeID() == GetNumberValueForStrKey("ITEM_TYPE_HUOBAN") then
					pCell:SetStyle(CEGUI.ItemCellStyle_IconExtend)
				end
				pCell:SetImage(image)

				SetItemCellBoundColorByQulityItem(pCell, pItem:GetBaseObject().nquality)

				local nBagId = pItem:GetObject().loc.tableType
				local nItemKey = pItem:GetThisID()
				refreshItemCellBind(pCell, nBagId, nItemKey)

				if pItem:isTreasure() then
					pCell:SetCornerImageAtPos("ccui1", "newzp", 0, 1)
				else
					pCell:ClearCornerImage(0)
				end

                g_refreshItemCellEquipEndureFlag(pCell, nBagId, nItemKey)

				if pItem:GetNum() > 1 then
					pCell:SetTextUnit(pItem:GetNum())
				else
					pCell:SetTextUnit("")
				end
				pCell:setID(pItem:GetThisID())
			else
				pCell:SetStyle(CEGUI.ItemCellStyle_IconInside)
				pCell:SetImage(nil)
				SetItemCellBoundColorByQulityItem(pCell, 0)

				local nBagId = -1
				local nItemKey = -1
				refreshItemCellBind(pCell, nBagId, nItemKey)

				pCell:SetCornerImageAtPos(nil, 0, 1)

				pCell:SetTextUnit("")
				pCell:setID(0)
			end
		end
	end
end



function Depot:HandleCellClicked(e)
	local winArgs = CEGUI.toMouseEventArgs(e)

	local touchPos = winArgs.position
	local nPosX = touchPos.x
	local nPosY = touchPos.y

	local bagid, pos
	for k, v in pairs(self.m_pCells) do
		if bagid then
			break
		end
		for i = 1, #v do
			if v[i] == winArgs.window then
				bagid = k
				pos = i - 1
				break
			end
		end
	end
	if not bagid then
		return true
	end

	local cell = self.m_pCells[bagid][pos + 1]
	if bagid == fire.pb.item.BagTypes.DEPOT then
		if cell:IsLock() then
			local p = require "protodef.fire.pb.item.cbuypackmoney":new()
			require "manager.luaprotocolmanager":send(p)
			self.m_pLastSelected = nil
			return true
		end
	end

	self.m_pLastSelected = { }
	self.m_pLastSelected.Cell = cell
	self.m_pLastSelected.Bagid = bagid
	self.m_pLastSelected.Pos = pos

	local btnstr = bagid == fire.pb.item.BagTypes.BAG and
	require "utils.mhsdutils".get_resstring(3079) or
	require "utils.mhsdutils".get_resstring(3080)
	if bagid == fire.pb.item.BagTypes.DEPOT then
		pos = pos + 25 *(self.m_pageDepotSelect - 1)
	end
    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local pItem = roleItemManager:FindItemByBagIDAndPos(bagid, pos)
	if pItem then
		local nFirstType = pItem:GetFirstType()

		local id = pItem:GetObjectID()
		local nObj = pItem:GetObject()
		local dlg = require "logic.tips.commontipdlg".getInstanceAndShow()

		if nPosX > Nuclear.GetEngine():GetLogicWidth() / 2 then
			nPosX = Nuclear.GetEngine():GetLogicWidth() / 8
		else
			nPosX = Nuclear.GetEngine():GetLogicWidth() - Nuclear.GetEngine():GetLogicWidth() / 8
		end
		dlg:RefreshItemWithObjForCangKu(id, nObj, nPosX + 2, nPosY + 2, btnstr, onClickButton)

	end

	return true
end

function Depot:HandleTableDoubleClick(e)
	print("Depot:HandleTableDoubleClick")
	local winArgs = CEGUI.toMouseEventArgs(e)
	local bagid, pos
	for k, v in pairs(self.m_pCells) do
		if bagid then
			break
		end
		for i = 1, #v do
			if v[i] == winArgs.window then
				bagid = k
				pos = i - 1
				break
			end
		end
	end
	if not bagid then
		return true
	end
	local cell = self.m_pCells[bagid][pos + 1]


	self.m_pLastSelected = { }
	self.m_pLastSelected.Cell = cell
	self.m_pLastSelected.Bagid = bagid
	self.m_pLastSelected.Pos = pos

	onClickButton()

	return true

end

function Depot:HandleCellLockClicked(e)

	local roleItemManager = require("logic.item.roleitemmanager").getInstance();
	local needMoney = roleItemManager:getUnlockBagNeedMoney();

	local okfunction = function(self)

		if DepotMenuBtn.getInstanceNotCreate() then
			DepotMenuBtn.DestroyDialog()
		end

		require "protodef.fire.pb.item.cextpacksize";
		gGetMessageManager():CloseConfirmBox(eConfirmNormal, false)
		local totalSilver = CurrencyManager.getOwnCurrencyMount(fire.pb.game.MoneyType.MoneyType_SilverCoin)

		if totalSilver < needMoney then
			local p = CExtPackSize.Create();
			p.packid = fire.pb.item.BagTypes.BAG

			CurrencyManager.handleCurrencyNotEnough(fire.pb.game.MoneyType.MoneyType_SilverCoin, needMoney - totalSilver, needMoney, p)

		else
			local p = CExtPackSize.Create();
			p.packid = fire.pb.item.BagTypes.BAG
			LuaProtocolManager.getInstance():send(p)

		end
	end

	local formatstr = GameTable.message.GetCMessageTipTableInstance():getRecorder(150144).msg
	local sb = require "utils.stringbuilder":new()
	sb:Set("Parameter1", needMoney)
	local msg = sb:GetString(formatstr)
	sb:delete()

	gGetMessageManager():AddConfirmBox(eConfirmNormal, msg, okfunction, self, MessageManager.HandleDefaultCancelEvent, MessageManager)

	return true

end


-- 背包也需要调用银币兑换界面
function Depot.ShowSilverCurrency(nNeed, pProtocol, pWidget)
	local totalSilver = CurrencyManager.getOwnCurrencyMount(fire.pb.game.MoneyType.MoneyType_SilverCoin);
	CurrencyManager.handleCurrencyNotEnough(fire.pb.game.MoneyType.MoneyType_SilverCoin, nNeed - totalSilver, nNeed, pProtocol, pWidget);
end

local confirmtype
local function confirmAddBagCapacity()
	if confirmtype then
		gGetMessageManager():CloseConfirmBox(confirmtype, false)
		confirmtype = nil
	end
	local dlg = require "logic.item.depot":getInstanceOrNot()
	if not dlg then
		return
	end
	local p = require "protodef.fire.pb.item.cextpacksize":new()
	require "manager.luaprotocolmanager":send(p)
end


local function getItemFirstType(itemtypeid)
	return itemtypeid % 0x10
end

function Depot:initBag(parent, bagtype)
    local roleItemManager = require("logic.item.roleitemmanager").getInstance()

	local itemkeys = roleItemManager:GetItemKeyListByBag(bagtype)
	for i = 0, itemkeys:size() -1 do
		local pItem = roleItemManager:FindItemByBagAndThisID(itemkeys[i], bagtype)
	end
	local winMgr = CEGUI.WindowManager:getSingleton()

	local width = parent:GetColCount()
	local height = parent:GetRowCount()


	local d_CellWide = 94
	local d_CellHeight = 94
	local d_offset = 5
	local capacity = roleItemManager:GetBagCapacity(bagtype)
	if capacity == 0 then
		require "protodef.fire.pb.item.cgetpackinfo";
		local request = CGetPackInfo.Create();
		request.packid = bagtype
		request.npcid = 0
		LuaProtocolManager.getInstance():send(request)
	end
	self.m_pCells[bagtype] = { }
	print("Depot:initBag" .. d_CellWide .. d_CellHeight .. d_offset)
	local index = 0;
	for i = 1, height do
		for j = 1, width do
			print("" .. index);
			local name = string.format("%s_ItemCell_%d%d", parent:getName(), i, j)


			local pCell = parent:GetCell(index)

			pCell:subscribeEvent("MouseClick", self.HandleCellClicked, self)


			if bagtype == fire.pb.item.BagTypes.BAG then
				pCell:subscribeEvent("LockCellClick", self.HandleCellLockClicked, self)
				pCell:subscribeEvent("MouseClick", self.HandleBagShowSelect, self)
			else
				pCell:subscribeEvent("MouseClick", self.HandleDepotShowSelect, self)
			end
			table.insert(self.m_pCells[bagtype], pCell)

			index = index + 1
		end
	end

end

function Depot:HandleBtnMianfeiClicked()

	print("Depot:HandleBtnMianfeiClicked")
	if DepotMenuBtn.getInstanceNotCreate() then
		DepotMenuBtn.DestroyDialog()
		self:RefreshPageBtn()
		self:RefreshDepotMianfeiBtn()
		return
	end

	local dlg = DepotMenuBtn.getInstanceAndShow()

	local pos = self.m_btnMianfei:GetScreenPos()

	dlg:GetWindow():setPosition(CEGUI.UVector2(CEGUI.UDim(0, pos.x - 121), CEGUI.UDim(0, pos.y + 60)))
	local pos = dlg:GetWindow():getPosition()
	local size = dlg:GetWindow():getSize()

	dlg:GetWindow():setAlwaysOnTop(true)

	self:RefreshPageBtn()
	self:RefreshDepotMianfeiBtn()
end

function Depot:RefreshDepotMianfeiBtn()

	if DepotMenuBtn.getInstanceNotCreate() then
		self.upImg:setVisible(true)
		self.downImg:setVisible(false)
	
		DepotMenuBtn.getInstanceNotCreate():deployAccountList()
		DepotMenuBtn.getInstanceNotCreate():RefreshBgSize()
		DepotMenuBtn.getInstanceNotCreate():RefreshLockStat()
	else
		self.upImg:setVisible(false)
		self.downImg:setVisible(true)
	end
end

function Depot:RefreshPageBtn()
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    local capacity = roleItemManager:GetBagCapacity(fire.pb.item.BagTypes.DEPOT)
	local openNum =(capacity / 25) +((capacity % 25) > 0 and 1 or 0)
	local openLine = math.floor(capacity / 75) +((capacity % 75) > 0 and 1 or 0)


	self.m_textpage:setText("" .. self.m_pageDepotSelect .. "/" .. openNum)
end



function Depot:RefreshPageAndItem(bNoSend)
    if not bNoSend then
        bNoSend = false
    end

	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local capacity = roleItemManager:GetBagCapacity(fire.pb.item.BagTypes.DEPOT)
	local pagenum = math.floor(capacity / 25) +((capacity % 25) > 0 and 1 or 0)
	if self.m_pageDepotSelect < 1 then
		self.m_pageDepotSelect = pagenum
	end

	if self.m_pageDepotSelect > pagenum then
		self.m_pageDepotSelect = 1
	end
    if bNoSend then
    	self:RefreshItemsDepot(fire.pb.item.BagTypes.DEPOT, self.m_pageDepotSelect)
    else
        self:reqPageInfo(self.m_pageDepotSelect)
    end
	self:RefreshPageBtn()

end

function Depot:reqPageInfo(nPage)
     local creqDepot =  require "protodef.fire.pb.item.cgetdepotinfo".Create()
     creqDepot.pageid = nPage
     LuaProtocolManager.getInstance():send(creqDepot)
end

function Depot:HandleBtnPageDownClicked()
	print("Depot:HandleBtnPageDownClicked")
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	self.m_pageDepotSelect = self.m_pageDepotSelect + 1
	local capacity = roleItemManager:GetBagCapacity(fire.pb.item.BagTypes.DEPOT)

	local openLine = math.floor(capacity / 75) +((capacity % 75) > 0 and 1 or 0)

	self:RefreshPageAndItem()
	self:SetBtnMianFeiText()
end

function Depot:HandleBtnPageUpClicked()
	print("Depot:HandleBtnPageUpClicked")
	self.m_pageDepotSelect = self.m_pageDepotSelect - 1;

	self:RefreshPageAndItem()
	self:SetBtnMianFeiText();
end

function Depot:HandleBtnTestAClicked()
	print("Depot:HandleBtnTestAClicked")

	BagTemp.getInstanceAndShow()

end

function Depot.new()

	local self = { }
	setmetatable(self, Depot)
	function self.GetLayoutFileName()
		return "depot_mtg.layout"
	end
	super.OnCreate(self);
	local winMgr = CEGUI.WindowManager:getSingleton()
	SetPositionOfWindowWithLabel(self:GetWindow())
	self.m_scrollPaneItem = CEGUI.toScrollablePane(winMgr:getWindow("Depot/itemscrollpane"))
	self.m_itemTableBag = CEGUI.toItemTable(winMgr:getWindow("Depot/itemscrollpane/itemtable"))
	self.m_itemTableDepot = CEGUI.toItemTable(winMgr:getWindow("Depot/itemtable2"));

	self.m_btnMianfei = CEGUI.toPushButton(winMgr:getWindow("Depot/btnmianfei"))
	self.m_btnMianfei:subscribeEvent("MouseButtonDown", Depot.HandleBtnMianfeiClicked, self)

	self.m_pTidyDepot = CEGUI.toPushButton(winMgr:getWindow("Depot/TidyBag"))
	local tidyDepotBtnPressAnimationDef = CEGUI.AnimationManager:getSingleton():getAnimation("studyBtnPress") 
    if tidyDepotBtnPressAnimationDef then
        local tidyDepotBtnPressAnimation = CEGUI.AnimationManager:getSingleton():instantiateAnimation(tidyDepotBtnPressAnimationDef)
        tidyDepotBtnPressAnimation:setTargetWindow(self.m_pTidyDepot)
        tidyDepotBtnPressAnimation:setSpeed(0.5)  --  

        self.m_pTidyDepot:subscribeEvent("MouseButtonDown", 
            function()
                tidyDepotBtnPressAnimation:start()  -- 
            end, self)
    end
    self.m_pTidyDepot:subscribeEvent("Clicked", self.HandleTidyDepotBtnClicked, self)
	
	self.m_pTidyBag = CEGUI.toPushButton(winMgr:getWindow("Depot/BagTidy"))
	 local tidyBagBtnPressAnimationDef = CEGUI.AnimationManager:getSingleton():getAnimation("studyBtnPress")
    if tidyBagBtnPressAnimationDef then
        local tidyBagBtnPressAnimation = CEGUI.AnimationManager:getSingleton():instantiateAnimation(tidyBagBtnPressAnimationDef)
        tidyBagBtnPressAnimation:setTargetWindow(self.m_pTidyBag)
        tidyBagBtnPressAnimation:setSpeed(0.5)  --  

        self.m_pTidyBag:subscribeEvent("MouseButtonDown", 
            function()
                tidyBagBtnPressAnimation:start() -- 
            end, self)
    end
    self.m_pTidyBag:subscribeEvent("Clicked", self.HandleTidyBagBtnClicked, self)


	self.m_textpage = CEGUI.toWindow(winMgr:getWindow("Depot/txt1"))
	self.m_btnUp = CEGUI.toPushButton(winMgr:getWindow("Depot/btnleft"))
	local btnUpPressAnimationDef = CEGUI.AnimationManager:getSingleton():getAnimation("studyBtnPress") 
    if btnUpPressAnimationDef then
        local btnUpPressAnimation = CEGUI.AnimationManager:getSingleton():instantiateAnimation(btnUpPressAnimationDef)
        btnUpPressAnimation:setTargetWindow(self.m_btnUp)
        btnUpPressAnimation:setSpeed(0.5)  

        self.m_btnUp:subscribeEvent("MouseButtonDown", 
            function()
                btnUpPressAnimation:start()
            end, self)
    end
    self.m_btnUp:subscribeEvent("Clicked", self.HandleBtnPageUpClicked, self)
	
	self.m_btnDown = CEGUI.toPushButton(winMgr:getWindow("Depot/btnright"))
	local btnDownPressAnimationDef = CEGUI.AnimationManager:getSingleton():getAnimation("studyBtnPress")
    if btnDownPressAnimationDef then
        local btnDownPressAnimation = CEGUI.AnimationManager:getSingleton():instantiateAnimation(btnDownPressAnimationDef)
        btnDownPressAnimation:setTargetWindow(self.m_btnDown)
        btnDownPressAnimation:setSpeed(0.5)  

        self.m_btnDown:subscribeEvent("MouseButtonDown", 
            function()
                btnDownPressAnimation:start() 
            end, self)
    end
    self.m_btnDown:subscribeEvent("Clicked", self.HandleBtnPageDownClicked, self)
	



	self.m_pbtnTestA = CEGUI.toPushButton(winMgr:getWindow("Depot/testA"))
	self.m_pbtnTestA:subscribeEvent("Clicked", self.HandleBtnTestAClicked, self)

    self.m_pbtnChangeName = CEGUI.toPushButton(winMgr:getWindow("Depot/btngai"))
	local btnChangeNamePressAnimationDef = CEGUI.AnimationManager:getSingleton():getAnimation("studyBtnPress")
    if btnChangeNamePressAnimationDef then
        local btnChangeNamePressAnimation = CEGUI.AnimationManager:getSingleton():instantiateAnimation(btnChangeNamePressAnimationDef)
        btnChangeNamePressAnimation:setTargetWindow(self.m_pbtnChangeName)
        btnChangeNamePressAnimation:setSpeed(0.5)

        self.m_pbtnChangeName:subscribeEvent("MouseButtonDown", 
            function()
                btnChangeNamePressAnimation:start() 
            end, self)
    end
    self.m_pbtnChangeName:subscribeEvent("Clicked", self.HandleBtnChangeNameClicked, self)
    

	self.m_secClickTidyBag = 0
	self.m_secClickTidyDepot = 0

	self.upImg = CEGUI.toWindow(winMgr:getWindow("Depot/btnmianfei/imageup"))
	self.downImg = CEGUI.toWindow(winMgr:getWindow("Depot/btnmianfei/imagedown"))

	self.m_pCells = { }

	local frameWnd = CEGUI.toFrameWindow(winMgr:getWindow("Depot"))
	frameWnd:SetLoadedDraw(true)
	self.closeBtn = CEGUI.toPushButton(frameWnd:getCloseButton())
	self.closeBtn:subscribeEvent("MouseClick", Depot.HandleCloseClick, self)

	self.m_pageDepotSelect = 1;

	self.m_pSelectCellNew = nil

	self:initBag(self.m_itemTableBag, fire.pb.item.BagTypes.BAG)
	self.m_itemTableBag:subscribeEvent("TableDoubleClick", self.HandleTableDoubleClick, self)

	self:RefreshItemsBag(fire.pb.item.BagTypes.BAG)


	self:initBag(self.m_itemTableDepot, fire.pb.item.BagTypes.DEPOT)
	--self:RefreshItemsDepot(fire.pb.item.BagTypes.DEPOT, 1)
    self:reqPageInfo(1)
	self.m_itemTableDepot:subscribeEvent("TableDoubleClick", self.HandleTableDoubleClick, self)


	self.m_scrollPaneItem:EnableAllChildDrag(self.m_scrollPaneItem);

	self:RefreshPageBtn()
	self:RefreshDepotMianfeiBtn()
	self:SetBtnMianFeiText()

	QuickBagFunction()

	return self
end

function Depot:getInstanceRefresh()
	local dlg = Depot:getInstanceOrNot()
	if dlg then
        local bNoSend = true
		dlg:RefreshPageAndItem(bNoSend)
		dlg:RefreshDepotMianfeiBtn()

		dlg:RefreshItemsBag(fire.pb.item.BagTypes.BAG)

		print("Depot:getInstanceRefresh")
	end
end

function Depot:SetVisible(bVisible)
	super.SetVisible(self, bVisible);

	if (not bVisible) then
		self:clear();
	end
end

function Depot:getInstanceAndShow()
	local dlg = require "logic.item.depot":getInstanceOrNot()
	if dlg then
		dlg:SetVisible(true)
	end
end

function Depot.isShowing()
	local dlg = require "logic.item.depot":getInstanceOrNot()
	if dlg and dlg:GetWindow() and dlg:GetWindow():isVisible() and dlg:GetWindow():getEffectiveAlpha() > 0.95 then
		return true
	else
		return false
	end
end

function Depot:HandleBtnChangeNameClicked(args)
    require "logic.depotcndialog"
    local dlg = depotcndialog.getInstanceAndShow()
    dlg:setIndex(self.m_pageDepotSelect)   
    return true
end

return Depot


