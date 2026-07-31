require "logic.dialog"

ItemUnit = 
{
    pCell = nil,
    pNameText = nil,
    pUseBtn = nil,
    pCloseBtn = nil
}
ItemUnit.__index = ItemUnit

function ItemUnit:new()
	local self = {}
	setmetatable(self, ItemUnit)
	return self
end

function ItemUnit:Reset()
	if self.pCell ~= nil then
		self.pCell:Clear()
    end

	if self.pNameText ~= nil then
		self.pNameText:setText("")
    end

	if self.pUseBtn ~= nil then
		self.pUseBtn:setID(0)
    end
end

function ItemUnit:SetItem(baseid)
	if self.pCell == nil or self.pNameText == nil or self.pCell:getID() == baseid then
		return
    end

	local itemattr = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(baseid)
	if not itemattr then
		return
    end

	self.pCell:setID(baseid)
	self.pCell:SetImage(gGetIconManager():GetItemIconByID(itemattr.icon))
    self.pUseBtn:setID(baseid)
    SetItemCellBoundColorByQulityItemWithId(self.pCell, baseid)
	self.pNameText:setText(itemattr.name)
end

function ItemUnit:SetUnitInfo(totalnum)
	if totalnum == 0 then
        self:Reset()
		return
	end

	if totalnum > 1 then
		self.pCell:SetTextUnitText(CEGUI.PropertyHelper:intToString(totalnum))
	else
		self.pCell:SetTextUnitText("")
    end
end


RemindUseItemDlg = {}
setmetatable(RemindUseItemDlg, Dialog)
RemindUseItemDlg.__index = RemindUseItemDlg

function RemindUseItemDlg.GetLayoutFileName()
	return "usetoremindcard.layout"
end

function RemindUseItemDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, RemindUseItemDlg)
	return self
end

local count = 0
function RemindUseItemDlg:OnCreate()
	local name_prefix = CEGUI.PropertyHelper:intToString(count)
    count = count + 1
	Dialog.OnCreate(self, nil, name_prefix)

	local winMgr = CEGUI.WindowManager:getSingleton()

    self.m_FirstUnit = ItemUnit:new()

	self.m_FirstUnit.pNameText = winMgr:getWindow(name_prefix .. "UseToRemindcard/name")
    self.m_FirstUnit.pNameText:setMousePassThroughEnabled(true)
	self.m_FirstUnit.pCell = CEGUI.toItemCell(winMgr:getWindow(name_prefix .. "UseToRemindcard/item"))
	self.m_FirstUnit.pCell:subscribeEvent("TableClick", RemindUseItemDlg.HandleShowTooltips, self)  -- CEGUI.ItemCell.EventMouseClick
	self.m_FirstUnit.pUseBtn = CEGUI.toPushButton(winMgr:getWindow(name_prefix .. "UseToRemindcard/ok"))
	self.m_FirstUnit.pUseBtn:subscribeEvent(CEGUI.PushButton.EventClicked, RemindUseItemDlg.HandleUseItem, self)
	self.m_FirstUnit.pCloseBtn = CEGUI.toPushButton(winMgr:getWindow(name_prefix .. "UseToRemindcard/closed"))
	self.m_FirstUnit.pCloseBtn:subscribeEvent(CEGUI.PushButton.EventClicked, RemindUseItemDlg.HandleCloseBtnClick, self)

	self.m_hItemNumChangeNotify = gGetRoleItemManager():InsertLuaItemNumChangeNotify(RemindUseItemDlg.OnItemNumChangeNotify)

    if GetBattleManager() ~= nil then
        self.m_hBattleBegin = GetBattleManager().EventBeginBattle:InsertScriptFunctor(function() self:OnBattleBegin() end)
        self.m_hBattleEnd = GetBattleManager().EventEndBattle:InsertScriptFunctor(function() self:OnBattleEnd() end)
    end

    if NewRoleGuideManager.getInstance() then
        NewRoleGuideManager.getInstance():AddParticalToWnd(self.m_FirstUnit.pUseBtn)
    end
end

function RemindUseItemDlg:OnClose()
	gGetRoleItemManager():RemoveLuaItemNumChangeNotify(self.m_hItemNumChangeNotify)

	if GetBattleManager() ~= nil then
		GetBattleManager().EventBeginBattle:RemoveScriptFunctor(self.m_hBattleBegin)
		GetBattleManager().EventEndBattle:RemoveScriptFunctor(self.m_hBattleEnd)
	end

	if gGetMessageManager() ~= nil then
		gGetMessageManager():CloseConfirmBox(eConfirmCloseRemindUseItemTip)
		gGetMessageManager():CloseConfirmBox(eConfirmLevel3Drug)
	end

    Dialog.OnClose(self)
end

function RemindUseItemDlg:HandleCloseBtnClick(e)
    self:OnClose()
    return true
end

function RemindUseItemDlg.OnItemNumChangeNotify(bagid, itemkey, itembaseid)
    local pDlg = RemindUseItemDlg.GetInstance(itembaseid)
    if pDlg == nil then
        return
    end

	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    local totalnum = 0
    if itembaseid == HONG_QIAO_MING_YUE_YE or itembaseid == B_HONG_QIAO_MING_YUE_YE then
		if pDlg.m_FirstUnit.pCell:getID() == HONG_QIAO_MING_YUE_YE or pDlg.m_FirstUnit.pCell:getID() == B_HONG_QIAO_MING_YUE_YE then
            local num = roleItemManager:GetItemTotalNumByBaseID(HONG_QIAO_MING_YUE_YE)
            local bnum = roleItemManager:GetItemTotalNumByBaseID(B_HONG_QIAO_MING_YUE_YE)
            totalnum = num + bnum
            if num > 0 then
                pDlg.m_FirstUnit:SetItem(HONG_QIAO_MING_YUE_YE)
            elseif bnum > 0 then
                pDlg.m_FirstUnit:SetItem(B_HONG_QIAO_MING_YUE_YE)
            end
            pDlg.m_FirstUnit:SetUnitInfo(totalnum)
        end
    elseif itembaseid == YU_DI_TING_LUO_MEI or itembaseid == B_YU_DI_TING_LUO_MEI then
		if pDlg.m_FirstUnit.pCell:getID() == YU_DI_TING_LUO_MEI or pDlg.m_FirstUnit.pCell:getID() == B_YU_DI_TING_LUO_MEI then
            local num = roleItemManager:GetItemTotalNumByBaseID(YU_DI_TING_LUO_MEI)
            local bnum = roleItemManager:GetItemTotalNumByBaseID(B_YU_DI_TING_LUO_MEI)
            totalnum = num + bnum
            if num > 0 then
                pDlg.m_FirstUnit:SetItem(YU_DI_TING_LUO_MEI)
            elseif bnum > 0 then
                pDlg.m_FirstUnit.SetItem(B_YU_DI_TING_LUO_MEI)
            end
            pDlg.m_FirstUnit:SetUnitInfo(totalnum)
        end
    else
        if pDlg.m_FirstUnit.pCell:getID() == itembaseid then
            totalnum = roleItemManager:GetItemTotalNumByBaseID(itembaseid)
            pDlg.m_FirstUnit:SetUnitInfo(totalnum)
        end
    end
end

function RemindUseItemDlg:AddRemindItem(itembaseid)
	if GetBattleManager() and GetBattleManager():IsInBattle() then
		self:SetVisible(false)
	end

	self.m_FirstUnit:SetItem(itembaseid)
	return
end

function RemindUseItemDlg:HandleUseItem(e)
	local pBtn = self.m_FirstUnit.pUseBtn
	local itemid = pBtn:getID()
	if itemid == 0 then
		GetCTipsManager():AddMessageTip(GameTable.message.GetCMessageTipTableInstance():getRecorder(144004).msg)
		return true
    end

	local roleItemManager = require("logic.item.roleitemmanager").getInstance()

	if roleItemManager:GetItemByBaseID(itemid) ~= nil then
		if roleItemManager:GetItemByBaseID(itemid):GetItemTypeID() == 166 then
			self:OnClose()
		end
	end
	 
	local itemkey = roleItemManager:GetItemKeyByBaseID(itemid)
	if itemkey == 0 then
		return true
    end
	
    local pItem = roleItemManager:GetBagItem(itemkey)
	if pItem ~= nil then
        local typeid = pItem:GetItemTypeID()

	    --坐骑道具
	    if typeid == ITEM_TYPE.HORSE then
			self:OnClose()
	    end

	    local ret = _HandleUseItem(fire.pb.item.BagTypes.BAG, typeid, itemid, itemkey)
		if ret == 1 then --ret is 1 means won't use this item. by lg
			return true
		end

		roleItemManager:UseItem(pItem)
	end

	return true
end

function RemindUseItemDlg:HandleConfirmUseItem(e)
	local windowargs = CEGUI.toWindowEventArgs(e)
	local pConfirmBoxInfo = tostConfirmBoxInfo(windowargs.window:getUserData())
	if pConfirmBoxInfo ~= nil then
		local itemkey = pConfirmBoxInfo.userID
	    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
        local pItem = roleItemManager:GetBagItem(itemkey)
        if pItem ~= nil then
            roleItemManager:UseItem(pItem)
        end
	end
	gGetMessageManager():RemoveConfirmBox(pConfirmBoxInfo)
	return true
end

function RemindUseItemDlg:HandleShowTooltips(e)
	local windowargs = CEGUI.toWindowEventArgs(e)
	local pCell = CEGUI.toItemCell(windowargs.window)
	if pCell ~= nil then
		local id = pCell:getID()
        local mouseArgs = CEGUI.toMouseEventArgs(e)
		local Pos = mouseArgs.position
        LuaShowItemTipWithBaseId(id, Pos.x, Pos.y, 0)
	end
	return true
end

function RemindUseItemDlg:HandleHideTooltips(e)
	return true
end

function RemindUseItemDlg:OnBattleBegin()
	self:SetVisible(false)
	if gGetMessageManager() ~= nil then
		gGetMessageManager():CloseConfirmBox(eConfirmCloseRemindUseItemTip)
		gGetMessageManager():CloseConfirmBox(eConfirmLevel3Drug)
	end
end

function RemindUseItemDlg:OnBattleEnd()
	self:SetVisible(true)
end

local B_HONG_QIAO_MING_YUE_YE = 32024
local HONG_QIAO_MING_YUE_YE = 32014
local B_YU_DI_TING_LUO_MEI = 32025
local YU_DI_TING_LUO_MEI = 32015

local remindDlgs = {}

function RemindUseItemDlg.ClearAllDialog()
    remindDlgs = {}
end

function RemindUseItemDlg.NewInstance(itemid)
    local findindex
    if itemid == B_HONG_QIAO_MING_YUE_YE then
        findindex = HONG_QIAO_MING_YUE_YE
    elseif itemid == B_YU_DI_TING_LUO_MEI then
        findindex = YU_DI_TING_LUO_MEI
    else
        findindex = itemid
    end
    
	local winMgr = CEGUI.WindowManager:getSingleton()
    local winName = remindDlgs[findindex]
    if winName ~= nil then
        if winMgr:isWindowPresent(winName) then
            local window = winMgr:getWindow(winName)
            local pDlg = LuaUIManager:getDialog(window)
            if pDlg ~= nil then
                return pDlg
            else
                remindDlgs[findindex] = nil
            end
        else
            remindDlgs[findindex] = nil
        end
    end

    local pDlg = RemindUseItemDlg:new()
    pDlg:OnCreate()
    remindDlgs[findindex] = pDlg:GetWindow():getName()
    return pDlg
end

function RemindUseItemDlg.GetInstance(itemid)
    local findindex
    if itemid == B_HONG_QIAO_MING_YUE_YE then
        findindex = HONG_QIAO_MING_YUE_YE
    elseif itemid == B_YU_DI_TING_LUO_MEI then
        findindex = YU_DI_TING_LUO_MEI
    else
        findindex = itemid
    end
    
	local winMgr = CEGUI.WindowManager:getSingleton()
    local winName = remindDlgs[findindex]
    if winName ~= nil then
        if winMgr:isWindowPresent(winName) then
            local window = winMgr:getWindow(winName)
            local pDlg = LuaUIManager:getDialog(window)
            if pDlg ~= nil then
                return pDlg
            else
                print("Find remind window = " .. winName .. " not reminduseitemdlg class")
                remindDlgs[findindex] = nil
            end
        else
            print("Find remind window = " .. winName .. " not exist")
            remindDlgs[findindex] = nil
        end
    end

    return nil
end

function RemindUseItemDlg.CheckCloseDialog(itemid)
    local pDlg = RemindUseItemDlg.GetInstance(itemid)
    if pDlg == nil then
        return
    end
    if pDlg.m_FirstUnit.pCell:getID() == 0 then
        pDlg:OnClose()
        local findindex
        if itemid == B_HONG_QIAO_MING_YUE_YE then
            findindex = HONG_QIAO_MING_YUE_YE
        elseif itemid == B_YU_DI_TING_LUO_MEI then
            findindex = YU_DI_TING_LUO_MEI
        else
            findindex = itemid
        end
        remindDlgs[findindex] = nil
    end
end

function RemindUseItemDlg.CheckCloseAllDialogs()
	local winMgr = CEGUI.WindowManager:getSingleton()
    for key, winName in pairs(remindDlgs) do
        if winMgr:isWindowPresent(winName) then
            local window = winMgr:getWindow(winName)
            local pDlg = LuaUIManager:getDialog(window)
            if pDlg ~= nil then
				local baseId = pDlg.m_FirstUnit.pCell:getID()
	            local roleItemManager = require("logic.item.roleitemmanager").getInstance()
				local pItem = roleItemManager:GetItemByBaseID(baseId)
				if pItem == nil then  -- 此物品已不存在了，则快捷使用窗口应关闭
					pDlg:OnClose()
					remindDlgs[key] = nil
				end
            else
                remindDlgs[key] = nil
            end
        else
            remindDlgs[key] = nil
        end
    end
end

function RemindUseItemDlg.IsRemindItem(itembaseid)
	local ids = BeanConfigManager.getInstance():GetTableByName("item.citemusetip"):getAllID()

    local attr = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(itembaseid)
    if not attr then
        return false
    end
    if gGetDataManager():GetMainCharacterLevel() < attr.needLevel then
        return false
    end

    local itemtypeid = attr.itemtypeid

	local num = #ids
	for i = 1, num  do
        local remindconfig = BeanConfigManager.getInstance():GetTableByName("item.citemusetip"):getRecorder(ids[i])
        if remindconfig.kind == 1 then
            if remindconfig.idnum == itemtypeid then
                return true
            end
        elseif remindconfig.kind == 2 then
            if remindconfig.idnum == itembaseid then
                return true
            end
        end
    end

    return false
end

return RemindUseItemDlg
