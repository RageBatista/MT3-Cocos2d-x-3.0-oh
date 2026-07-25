require "logic.dialog"

BattleBag = {}
setmetatable(BattleBag, Dialog)
BattleBag.__index = BattleBag

local _instance
function BattleBag.getInstance()
	if not _instance then
		_instance = BattleBag:new()
		_instance:OnCreate()
	end
	return _instance
end

function BattleBag.getInstanceAndShow()
	if not _instance then
		_instance = BattleBag:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function BattleBag.getInstanceNotCreate()
	return _instance
end

function BattleBag.DestroyDialog()
	if _instance then
		if _instance.m_PlayerOrPet == 0 then
			if CharacterOperateDlg.getInstanceNotCreate() then
				CharacterOperateDlg.getInstanceAndShow()
			end
		elseif _instance.m_PlayerOrPet == 1 then
			if PetOperateDlg.getInstanceNotCreate() then
				PetOperateDlg.getInstance():SetVisible(true)
			end
		end
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
            CheckTipsWnd.CheckCommontipdlg()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function BattleBag.ToggleOpenClose()
	if not _instance then
		_instance = BattleBag:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function BattleBag.GetLayoutFileName()
	return "battlebag_mtg.layout"
end

function BattleBag:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, BattleBag)
	return self
end

function BattleBag:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
	
	self:GetWindow():setMousePassThroughEnabled(true)
	self:GetWindow():SetHandleDragMove(true)
	
	
	self.m_pBack = CEGUI.toFrameWindow(winMgr:getWindow("battledialog_back"))
	
	self.m_pFrameWindow = CEGUI.toFrameWindow(winMgr:getWindow("battlebag_mtg"))
	self.m_pFrameWindow:getCloseButton():subscribeEvent("Clicked", BattleBag.DestroyDialog, nil)
    
	self.petScroll = CEGUI.toScrollablePane(winMgr:getWindow("battlebag_mtg/textbg/list"))
	self.m_pItemTable = CEGUI.toItemTable(winMgr:getWindow("battlebag_mtg/textbg/list/table"))
	self.m_pUseCountLast = winMgr:getWindow("battlebag_mtg/text")
	self.m_pUseBtn = CEGUI.toPushButton(winMgr:getWindow("battlebag_mtg/btnshiyong"))
	self.m_pCancelBtn = CEGUI.toPushButton(winMgr:getWindow("battledialog/cancel"))	
    
    self.m_pGroupBtn_All     = CEGUI.toGroupButton(winMgr:getWindow("battlebag_mtg/btn1"))	
    self.m_pGroupBtn_HuiFu   = CEGUI.toGroupButton(winMgr:getWindow("battlebag_mtg/btn2"))	
    self.m_pGroupBtn_JieKong = CEGUI.toGroupButton(winMgr:getWindow("battlebag_mtg/btn3"))	
    self.m_pGroupBtn_FuHuo   = CEGUI.toGroupButton(winMgr:getWindow("battlebag_mtg/btn4"))	
    self.m_pGroupBtn_XianYing = CEGUI.toGroupButton(winMgr:getWindow("battlebag_mtg/btn21"))	
    self.m_pGroupBtn_NuQi = CEGUI.toGroupButton(winMgr:getWindow("battlebag_mtg/btn31"))	
	
    self.m_pGroupBtn_All:subscribeEvent("MouseButtonUp", BattleBag.HandleGroupBtnClicked, self)
    self.m_pGroupBtn_HuiFu:subscribeEvent("MouseButtonUp", BattleBag.HandleGroupBtnClicked, self)
    self.m_pGroupBtn_JieKong:subscribeEvent("MouseButtonUp", BattleBag.HandleGroupBtnClicked, self)
    self.m_pGroupBtn_FuHuo:subscribeEvent("MouseButtonUp", BattleBag.HandleGroupBtnClicked, self)
    self.m_pGroupBtn_XianYing:subscribeEvent("MouseButtonUp", BattleBag.HandleGroupBtnClicked, self)
    self.m_pGroupBtn_NuQi:subscribeEvent("MouseButtonUp", BattleBag.HandleGroupBtnClicked, self)

    self.m_pGroupBtn_All:setID(0)
    self.m_pGroupBtn_HuiFu:setID(1)
    self.m_pGroupBtn_JieKong:setID(2)
    self.m_pGroupBtn_FuHuo:setID(3)
    self.m_pGroupBtn_XianYing:setID(4)
    self.m_pGroupBtn_NuQi:setID(5)

    self.m_pGroupBtn_All:setSelected(true);
    
	self.petScroll:EnableAllChildDrag(self.petScroll)
	self.m_pItemTable:setMousePassThroughEnabled(true)
	self.m_pItemTable:SetType(1)
	self.m_pItemTable:SetMulitySelect(false)
	self.m_pItemTable:subscribeEvent("TableClick", BattleBag.HandleItemTableClicked, self)

	self.m_pUseBtn:subscribeEvent("Clicked", BattleBag.HandleUseBtnClicked, self)
	self.m_pCancelBtn:subscribeEvent("Clicked", BattleBag.HandleCancelBtnClicked, self)
	
	self.m_pCurItemCell = nil
	self.m_pCurItemData = nil
		
	self:Show(true)
	self:ShowItemInfo(self.m_pCurItemData)
	
	self.m_PlayerOrPet = 0
	self.m_TypeID = 0
	
    self.frameCount = 0
    self:GetWindow():subscribeEvent("WindowUpdate", BattleBag.HandleWindowUpdate, self) 
end
function BattleBag:HandleItemTableClicked(args)

	local e = CEGUI.toMouseEventArgs(args)
	self.m_pCurItemCell = e.window
	if self.m_pCurItemCell ~= nil then
        
	    if self.m_pCurItemCell:getID2() == 10000 then
		    self:HandleOpenDrugShop()
		    return
	    end

	    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
        self.m_pCurItemData = roleItemManager:getItem(self.m_pCurItemCell:getID2(), fire.pb.item.BagTypes.BAG)
        if self.m_pCurItemData then                       
	        local pos = self.m_pCurItemCell:GetScreenPosOfCenter()            
	        local commontipdlg = Commontipdlg.getInstanceAndShow()
	        local nType = Commontipdlg.eType.eNormal 
	        commontipdlg:RefreshItem(nType,self.m_pCurItemCell:getID(),pos.x, pos.y, self.m_pCurItemData.m_pObject)

            if self.m_pCurItemCell:getID2() > 0 then
                local dlg = require "logic.tips.commontipdlg".getInstanceNotCreate()
                if dlg then
                    dlg:setNum(self.m_pCurItemCell:getID2())
                end
            end

        end
	else
		self.m_pCurItemData = nil
	end
	self:ShowItemInfo(self.m_pCurItemData)
end
function BattleBag:HandleOpenDrugShop(args)
    -- 打开药品商店，快速购买药品
	self:GetWindow():setProperty("AllowModalStateClick", "False")
	local dlg = require("logic.shop.npcshop").getInstanceAndShow()
	dlg:setShopType(SHOP_TYPE.MEDICINE)
	self:GetWindow():setProperty("AllowModalStateClick", "True")
    self.m_bOpenDrugShop = true
end
function BattleBag:HandleUseBtnClicked(args)
	self:Show(false)
	gGetGameOperateState():ChangeGameCursorType(eGameCursorType_BattleItem)
	BattleTiShi.getInstance().CSetText(self.m_pCurItemData:GetName())
end
function BattleBag:HandleCancelBtnClicked(args)
	self:Show(true)
	gGetGameOperateState():ChangeGameCursorType(eGameCursorType_BattleNormal)
	BattleTiShi.getInstance().CSetText("")
end
function BattleBag:HandleGroupBtnClicked(args)
    local e = CEGUI.toMouseEventArgs(args)
	local CurTyepBtn = e.window
	if CurTyepBtn ~= nil then
        local tyID = CurTyepBtn:getID()
        self:InitBag(self.m_PlayerOrPet,tyID)
    end
end
function BattleBag:Show(bMode)
	self.m_pBack:setVisible(bMode)
	self.m_pCancelBtn:setVisible(not bMode)
	self.m_pFrameWindow:setVisible(bMode)
end

function BattleBag:getItemQuality(pRoleItem)
    local nQuality = 0
    if not pRoleItem then
        return nQuality
    end
    local nItemId = pRoleItem:GetBaseObject().id
    local pObj = pRoleItem:GetObject()
    if not pObj then
        return nQuality
    end

    local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
	if not itemAttrCfg then
		return nQuality
	end
    local nItemType = itemAttrCfg.itemtypeid
    local nFirstType = require "utils.mhsdutils".GetItemFirstType(nItemType)
	
    if nFirstType==eItemType_FOOD then
		 nQuality = require("logic.tips.commontiphelper").getFoodQuality(pObj)
		if nQuality > 0 then
			return nQuality
		end
	--//===================================== --yao pin
	elseif nFirstType==eItemType_DRUG then
		 nQuality = require("logic.tips.commontiphelper").getDrugQuality(pObj)
		if nQuality > 0 then
			return nQuality
		end
    end
    return nQuality
end

function BattleBag:ShowItemInfo(ItemData)
	local UseCountLast = 0
	if ItemData ~= nil then
		local defaultColor = CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("ff693f00"))
        
		local nItemId = ItemData:GetBaseObject().id
		local pObj = ItemData:GetObject()
		local nQuality = self:getItemQuality(ItemData)
		
		--275 323 = 20，290 291 = 10
		local ItemTypeID = ItemData:GetItemTypeID()
		if ItemTypeID == 275 or ItemTypeID == 323 then
			UseCountLast = GetBattleManager():GetUseItemCount(0)
		elseif ItemTypeID == 290 or ItemTypeID == 291 then
			UseCountLast = GetBattleManager():GetUseItemCount(1)
		end
		if UseCountLast > 0 then
			self.m_pUseBtn:setEnabled(true)
		else
			self.m_pUseBtn:setEnabled(false)
		end
		GetBattleManager():SetCurSelectedItem(stRoleItem(ItemData:GetBaseObject().battleuse, ItemData:GetThisID()))
	else
		self.m_pUseBtn:setEnabled(false)
	end
	self.m_pUseCountLast:setText(tostring(UseCountLast))
end
function BattleBag.CInitBag(PlayerOrPet)--0:Player,1:Pet
	BattleBag.getInstanceAndShow():InitBag(PlayerOrPet,0)
end
function BattleBag:InitBag(PlayerOrPet,typeID)--0:Player,1:Pet
    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    
	self.m_PlayerOrPet = PlayerOrPet
	self.m_TypeID = typeID
    
    local oldRow = self.m_pItemTable:GetRowCount()
    local oCount = oldRow * 6
    for i = 0, oCount - 1 do
		local ItemCell2 = self.m_pItemTable:GetCell(i)
        CEGUI.toItemCell(ItemCell2):Clear()
    end


	local itemlist = roleItemManager:GetItemListByBag(1)
    local showitemcount=0
    for i = 1, itemlist._size do
        local BaseData = itemlist[i-1]:GetBaseObject()
        if PlayerOrPet == 0 then
			if BaseData.battleuser ~= 0 and BaseData.battleuser ~= 2 then                
                local dtype = BeanConfigManager.getInstance():GetTableByName("item.cfightdrugtype"):getRecorder(BaseData.id)
                if self.m_TypeID == 0 or self.m_TypeID == dtype.typeid then
				    showitemcount = showitemcount + 1
                end
			end
		elseif PlayerOrPet == 1 then
			if BaseData.battleuser ~= 0 and BaseData.battleuser ~= 1 then
                local dtype = BeanConfigManager.getInstance():GetTableByName("item.cfightdrugtype"):getRecorder(BaseData.id)
				if self.m_TypeID == 0 or self.m_TypeID == dtype.typeid then
                    showitemcount = showitemcount + 1
                end
			end
		end
    end
	local ItemCount = roleItemManager:GetBagCapacity(1)

    showitemcount = showitemcount + 1

    local row = math.ceil(showitemcount / 6)
    if row < 3 then
        row = 3
    end
	self.m_pItemTable:SetRowCount(row)
	local h = self.m_pItemTable:GetCellHeight()
	local spaceY = self.m_pItemTable:GetSpaceY()
	self.m_pItemTable:setHeight(CEGUI.UDim(0, (h+spaceY)*row))

    local tCount = row * 6
    for i = 0, tCount - 1 do
		local ItemCell2 = self.m_pItemTable:GetCell(i)
		CEGUI.toItemCell(ItemCell2):SetHaveSelectedState(true)
    end

	local GridIndex = 0
	for i = 0, ItemCount - 1 do
		local ItemCell = self.m_pItemTable:GetCell(GridIndex)
		local ItemData = roleItemManager:FindItemByBagIDAndPos(1, i)
		if ItemData ~= nil then
			local BaseData = ItemData:GetBaseObject()
			local CheckBattleUser = false
			if PlayerOrPet == 0 then
				--print(BaseData.battleuser)
				if BaseData.battleuser ~= 0 and BaseData.battleuser ~= 2 then
                    local dtype = BeanConfigManager.getInstance():GetTableByName("item.cfightdrugtype"):getRecorder(BaseData.id)
                    if self.m_TypeID == 0 or self.m_TypeID == dtype.typeid then
					    CheckBattleUser = true
                    end
				end
			elseif PlayerOrPet == 1 then
				if BaseData.battleuser ~= 0 and BaseData.battleuser ~= 1 then
                    local dtype = BeanConfigManager.getInstance():GetTableByName("item.cfightdrugtype"):getRecorder(BaseData.id)
					if self.m_TypeID == 0 or self.m_TypeID == dtype.typeid then
                        CheckBattleUser = true
                    end
				end
			end
			if CheckBattleUser == true then
				ItemCell:SetImage(gGetIconManager():GetItemIconByID(BaseData.icon))
                local itemAttr = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(BaseData.id)
				--if ItemData:GetNum() > 1 then
				--	ItemCell:SetTextUnitText(CEGUI.String(tostring(ItemData:GetNum())))
				--end
                local level = Commontiphelper.getItemLevelValue(ItemData:GetObjectID(), ItemData:GetObject())
                if itemAttr.maxNum > 1 then --可堆叠的物品
                    if ItemData:GetNum() > 1 then
				    	ItemCell:SetTextUnitText(CEGUI.String(tostring(ItemData:GetNum())))
                    else
                        ItemCell:SetTextUnitText("")                        
				    end
				elseif level > 0 then
					ItemCell:SetTextUnitText("Lv." .. level)
                else
                    ItemCell:SetTextUnitText("")
				end
                SetItemCellBoundColorByQulityItem(ItemCell, itemAttr.nquality, itemAttr.itemtypeid)
                self.petScroll:EnableChildDrag(ItemCell)
				ItemCell:setID(BaseData.id)
		        ItemCell:setID2(ItemData:GetThisID())
				GridIndex = GridIndex + 1
			end
		end
	end
    local LastCell = self.m_pItemTable:GetCell(showitemcount-1)
    LastCell:SetImage("chongwuui","chongwu_jiahao")
	LastCell:setID(10000)
	LastCell:setID2(10000)
    self.m_bOpenDrugShop = false
end
function BattleBag:InitBagPlayer()
	
end
function BattleBag:InitBagPet()
	
end

function BattleBag:HandleWindowUpdate(args)
    if self.frameCount < -90 and self.frameCount >= -99 then
        self:InitBag(self.m_PlayerOrPet,self.m_TypeID)
        self.frameCount = 0
    end

    self.frameCount = self.frameCount + 1
    if self.m_bOpenDrugShop == false then
        return
    end

    local drugDlg = require("logic.shop.npcshop").getInstanceNotCreate()
    if not drugDlg or drugDlg:IsVisible() == false then
        self.m_bOpenDrugShop = false
        self.frameCount = -100
    end

end

return BattleBag
