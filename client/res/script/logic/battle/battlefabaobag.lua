require "logic.dialog"
require "utils.temputil"

BattleFaBaoBag = {}
BattleFaBaoBag.useCount = 0
setmetatable(BattleFaBaoBag, Dialog)
BattleFaBaoBag.__index = BattleFaBaoBag

local _instance
function BattleFaBaoBag.getInstance()
    if not _instance then
        _instance = BattleFaBaoBag:new()
        _instance:OnCreate()
    end
    return _instance
end

function BattleFaBaoBag.getInstanceAndShow()
    if not _instance then
        _instance = BattleFaBaoBag:new()
        _instance:OnCreate()
    else
        _instance:SetVisible(true)
    end
    return _instance
end

function BattleFaBaoBag.getInstanceNotShow()
    if not _instance then
        _instance = BattleFaBaoBag:new()
        _instance:OnCreate()
    end
    _instance:SetVisible(false)
    return _instance
end

function BattleFaBaoBag.getInstanceNotCreate()
    return _instance
end

function BattleFaBaoBag.DestroyDialog()
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
    --self.m_pCancelBtn:setVisible(false)
end

function BattleFaBaoBag.ToggleOpenClose()
    if not _instance then
        _instance = BattleFaBaoBag:new()
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function BattleFaBaoBag.GetLayoutFileName()
    return "battlebag_mtg1.layout"
end

function BattleFaBaoBag:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, BattleFaBaoBag)
    return self
end

function BattleFaBaoBag:OnCreate()
    Dialog.OnCreate(self)
    local winMgr = CEGUI.WindowManager:getSingleton()

    self:GetWindow():setMousePassThroughEnabled(true)
    self:GetWindow():SetHandleDragMove(true)

    self.m_pBack = CEGUI.toFrameWindow(winMgr:getWindow("battledialog_back"))

    self.m_pFrameWindow = CEGUI.toFrameWindow(winMgr:getWindow("battlebag_mtg1"))
    self.m_pFrameWindow:getCloseButton():subscribeEvent("Clicked", BattleFaBaoBag.DestroyDialog, nil)
    --背包表格
    self.petScroll = CEGUI.toScrollablePane(winMgr:getWindow("battlebag_mtg1/textbg/list"))
    self.m_pItemTable = CEGUI.toItemTable(winMgr:getWindow("battlebag_mtg1/textbg/list/table"))
    --剩余使用次数
    self.m_pUseCountLast = winMgr:getWindow("battlebag_mtg1/text")
    --使用按钮
    self.m_pUseBtn = CEGUI.toPushButton(winMgr:getWindow("battlebag_mtg1/btnshiyong"))
    --取消按钮
    self.m_pCancelBtn = CEGUI.toPushButton(winMgr:getWindow("battledialog/cancel"))
    --表格上按钮
    self.m_pGroupBtn_All = CEGUI.toGroupButton(winMgr:getWindow("battlebag_mtg1/btn1"))
    --self.m_pGroupBtn_HuiFu = CEGUI.toGroupButton(winMgr:getWindow("battlebag_mtg/btn2"))
    --self.m_pGroupBtn_JieKong = CEGUI.toGroupButton(winMgr:getWindow("battlebag_mtg/btn3"))
    --self.m_pGroupBtn_FuHuo = CEGUI.toGroupButton(winMgr:getWindow("battlebag_mtg/btn4"))
    --self.m_pGroupBtn_XianYing = CEGUI.toGroupButton(winMgr:getWindow("battlebag_mtg/btn21"))
    --self.m_pGroupBtn_NuQi = CEGUI.toGroupButton(winMgr:getWindow("battlebag_mtg/btn31"))
    self.m_pGroupBtn_All:subscribeEvent("MouseButtonUp", BattleFaBaoBag.HandleGroupBtnClicked, self)
    --self.m_pGroupBtn_HuiFu:subscribeEvent("MouseButtonUp", BattleFaBaoBag.HandleGroupBtnClicked, self)
    --self.m_pGroupBtn_JieKong:subscribeEvent("MouseButtonUp", BattleFaBaoBag.HandleGroupBtnClicked, self)
    --self.m_pGroupBtn_FuHuo:subscribeEvent("MouseButtonUp", BattleFaBaoBag.HandleGroupBtnClicked, self)
    --self.m_pGroupBtn_XianYing:subscribeEvent("MouseButtonUp", BattleFaBaoBag.HandleGroupBtnClicked, self)
    --self.m_pGroupBtn_NuQi:subscribeEvent("MouseButtonUp", BattleFaBaoBag.HandleGroupBtnClicked, self)

    self.m_pGroupBtn_All:setID(0)
    --self.m_pGroupBtn_HuiFu:setID(1)
    --self.m_pGroupBtn_JieKong:setID(2)
    --self.m_pGroupBtn_FuHuo:setID(3)
    --self.m_pGroupBtn_XianYing:setID(4)
    --self.m_pGroupBtn_NuQi:setID(5)

    self.m_pGroupBtn_All:setSelected(true);

    self.petScroll:EnableAllChildDrag(self.petScroll)
    self.m_pItemTable:setMousePassThroughEnabled(true)
    self.m_pItemTable:SetType(1)
    self.m_pItemTable:SetMulitySelect(false)
    self.m_pItemTable:subscribeEvent("TableClick", BattleFaBaoBag.HandleItemTableClicked, self)

    self.m_pUseBtn:subscribeEvent("Clicked", BattleFaBaoBag.HandleUseBtnClicked, self)
    self.m_pCancelBtn:subscribeEvent("Clicked", BattleFaBaoBag.HandleCancelBtnClicked, self)

    self.m_pCurItemCell = nil
    self.m_pCurItemData = nil

    self:Show(true)
    self:ShowItemInfo(self.m_pCurItemData)

    self.m_PlayerOrPet = 0
    self.m_TypeID = 0

    self.frameCount = 0
    self:GetWindow():subscribeEvent("WindowUpdate", BattleFaBaoBag.HandleWindowUpdate, self)

end

function BattleFaBaoBag:initUseCount(count)
    BattleFaBaoBag.useCount = count
end

function BattleFaBaoBag:HandleItemTableClicked(args)
    local e = CEGUI.toMouseEventArgs(args)
    self.m_pCurItemCell = e.window
    if self.m_pCurItemCell ~= nil then

        if self.m_pCurItemCell:getID2() == 10000 then
            self:HandleOpenDrugShop()
            return
        end

        local roleItemManager = require("logic.item.roleitemmanager").getInstance()
        self.m_pCurItemData = roleItemManager:getItem(self.m_pCurItemCell:getID2(), fire.pb.item.BagTypes.QUEST)
        if self.m_pCurItemData then
            local pos = self.m_pCurItemCell:GetScreenPosOfCenter()
            local commontipdlg = Commontipdlg.getInstanceAndShow()
            local nType = Commontipdlg.eType.eNormal
            commontipdlg:RefreshItem(nType, self.m_pCurItemCell:getID(), pos.x, pos.y, self.m_pCurItemData.m_pObject)

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
function BattleFaBaoBag:HandleOpenDrugShop(args)
    -- ��ҩƷ�̵꣬���ٹ���ҩƷ
    self:GetWindow():setProperty("AllowModalStateClick", "False")
    local dlg = require("logic.shop.npcshop").getInstanceAndShow()
    dlg:setShopType(SHOP_TYPE.MEDICINE)
    self:GetWindow():setProperty("AllowModalStateClick", "True")
    self.m_bOpenDrugShop = true
end
--使用法宝
function BattleFaBaoBag:HandleUseBtnClicked(args)
    self:Show(false)
    gGetGameOperateState():ChangeGameCursorType(eGameCursorType_BattleItem)
    BattleTiShi.getInstance().CSetText(self.m_pCurItemData:GetName())
end
function BattleFaBaoBag:HandleCancelBtnClicked(args)
    self:Show(true)
    gGetGameOperateState():ChangeGameCursorType(eGameCursorType_BattleNormal)
    BattleTiShi.getInstance().CSetText("")
end
function BattleFaBaoBag:HandleGroupBtnClicked(args)
    local e = CEGUI.toMouseEventArgs(args)
    local CurTyepBtn = e.window
    if CurTyepBtn ~= nil then
        local tyID = CurTyepBtn:getID()
        self:InitBag(self.m_PlayerOrPet, tyID)
    end
end
function BattleFaBaoBag:Show(bMode)
    self.m_pBack:setVisible(bMode)
    self.m_pCancelBtn:setVisible(not bMode)
    self.m_pFrameWindow:setVisible(bMode)
end

function BattleFaBaoBag:getItemQuality(pRoleItem)
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

    if nFirstType == eItemType_FOOD then
        nQuality = require("logic.tips.commontiphelper").getFoodQuality(pObj)
        if nQuality > 0 then
            return nQuality
        end
        --//===================================== --yao pin
    elseif nFirstType == eItemType_DRUG then
        nQuality = require("logic.tips.commontiphelper").getDrugQuality(pObj)
        if nQuality > 0 then
            return nQuality
        end
    end
    return nQuality
end

function BattleFaBaoBag:ShowItemInfo(ItemData)
    local UseCountLast = 0
    if ItemData ~= nil then
        local defaultColor = CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("ff693f00"))

        local nItemId = ItemData:GetBaseObject().id
        local pObj = ItemData:GetObject()
        local nQuality = self:getItemQuality(ItemData)

        --法宝可使用次数
        local ItemTypeID = ItemData:GetItemTypeID()
        if ItemTypeID == 25 then
            --UseCountLast = GetBattleManager():GetUseItemCount(10086)
            UseCountLast = BattleFaBaoBag.useCount
        end

        if UseCountLast > 0 then
            self.m_pUseBtn:setEnabled(true)
        else
            self.m_pUseBtn:setEnabled(false)
        end
        GetBattleManager():SetCurSelectedItem(stRoleItem(ItemData:GetBaseObject().battleuse, ItemData:GetThisID() .. "10086"))
    else
        self.m_pUseBtn:setEnabled(false)
    end
    self.m_pUseCountLast:setText(tostring(UseCountLast))
end
--初始化战斗内道具
function BattleFaBaoBag.CInitBag(PlayerOrPet)
    --0:Player,1:Pet
    BattleFaBaoBag.getInstanceAndShow():InitBag(PlayerOrPet, 0)
end
function BattleFaBaoBag:InitBag(PlayerOrPet, typeID)
    local roleItemManager = require("logic.item.roleitemmanager").getInstance()

    self.m_PlayerOrPet = PlayerOrPet
    self.m_TypeID = typeID

    local oldRow = self.m_pItemTable:GetRowCount()
    local oCount = oldRow * 6
    --清除
    for i = 0, oCount - 1 do
        local ItemCell2 = self.m_pItemTable:GetCell(i)
        CEGUI.toItemCell(ItemCell2):Clear()
    end
    --拿到背包内道具
    --public final static int QUEST = 5; // 任务背包
    local itemlist = roleItemManager:GetItemListByBag(5)
    local showitemcount = 0
    for i = 1, itemlist._size do
        local BaseData = itemlist[i - 1]:GetBaseObject()
        --battleuser:战斗中可以使用该物品的对象，0表示不可使用，1表示是主角，2表示宠物，3是主角和宠物
        if PlayerOrPet == 0 then
            --道具类型必须为法宝 itemtypeid=25 主动法宝
            if BaseData.itemtypeid == 25 then
                showitemcount = showitemcount + 1
            end
        end
    end

    local row = math.ceil(showitemcount / 6)
    if row < 3 then
        row = 3
    end
    self.m_pItemTable:SetRowCount(row)
    local h = self.m_pItemTable:GetCellHeight()
    local spaceY = self.m_pItemTable:GetSpaceY()
    self.m_pItemTable:setHeight(CEGUI.UDim(0, (h + spaceY) * row))

    local tCount = row * 6
    for i = 0, tCount - 1 do
        local ItemCell2 = self.m_pItemTable:GetCell(i)
        CEGUI.toItemCell(ItemCell2):SetHaveSelectedState(true)
    end

    --任务背包容量
    local ItemCount = roleItemManager:GetBagCapacity(5)
    local GridIndex = 0
    for i = 0, ItemCount - 1 do
        local ItemCell = self.m_pItemTable:GetCell(GridIndex)
        local ItemData = roleItemManager:FindItemByBagIDAndPos(5, i)
        if ItemData ~= nil then
            local BaseData = ItemData:GetBaseObject()
            local CheckBattleUser = false
            if PlayerOrPet == 0 then
                --道具类型必须为法宝 itemtypeid=25 主动法宝
                if BaseData.itemtypeid == 25 then
                    CheckBattleUser = true
                end
            end
            if CheckBattleUser == true then
                ItemCell:SetImage(gGetIconManager():GetItemIconByID(BaseData.icon))
                local itemAttr = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(BaseData.id)
                --if ItemData:GetNum() > 1 then
                --	ItemCell:SetTextUnitText(CEGUI.String(tostring(ItemData:GetNum())))
                --end
                local level = Commontiphelper.getItemLevelValue(ItemData:GetObjectID(), ItemData:GetObject())
                if itemAttr.maxNum > 1 then
                    --�ɶѵ�����Ʒ
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
    --local LastCell = self.m_pItemTable:GetCell(showitemcount - 1)
    --LastCell:SetImage("chongwuui", "chongwu_jiahao")
    --LastCell:setID(10000)
    --LastCell:setID2(10000)
    self.m_bOpenDrugShop = false
end
function BattleFaBaoBag:InitBagPlayer()

end
function BattleFaBaoBag:InitBagPet()

end

function BattleFaBaoBag:HandleWindowUpdate(args)
    if self.frameCount < -90 and self.frameCount >= -99 then
        self:InitBag(self.m_PlayerOrPet, self.m_TypeID)
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

return BattleFaBaoBag
