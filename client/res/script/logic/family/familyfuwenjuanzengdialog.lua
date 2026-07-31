require "logic.dialog"
require "logic.family.familyfuwenbeibaocell"
Familyfuwenjuanzengdialog = { }
setmetatable(Familyfuwenjuanzengdialog, Dialog)
Familyfuwenjuanzengdialog.__index = Familyfuwenjuanzengdialog

local _instance
function Familyfuwenjuanzengdialog.getInstance()
    if not _instance then
        _instance = Familyfuwenjuanzengdialog:new()
        _instance:OnCreate()
    end
    return _instance
end

function Familyfuwenjuanzengdialog.getInstanceAndShow()
    if not _instance then
        _instance = Familyfuwenjuanzengdialog:new()
        _instance:OnCreate()
    else
        _instance:SetVisible(true)
    end
    return _instance
end

function Familyfuwenjuanzengdialog.getInstanceNotCreate()
    return _instance
end

function Familyfuwenjuanzengdialog.DestroyDialog()
    if _instance then
        if not _instance.m_bCloseIsHide then
            _instance.m_CellsCollection = { }
            if _instance and _instance.m_ItemPanel then
                _instance.m_ItemPanel:DestroyAllCell()
            end
            _instance:OnClose()
            _instance = nil
        else
            _instance:ToggleOpenClose()
        end
    end
end

function Familyfuwenjuanzengdialog.ToggleOpenClose()
    if not _instance then
        _instance = Familyfuwenjuanzengdialog:new()
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function Familyfuwenjuanzengdialog.GetLayoutFileName()
    return "familyfuwenjuanzengdialog.layout"
end

function Familyfuwenjuanzengdialog:new()
    local self = { }
    self = Dialog:new()
    setmetatable(self, Familyfuwenjuanzengdialog)
    return self
end

function Familyfuwenjuanzengdialog:OnCreate()
    Dialog.OnCreate(self)
    local winMgr = CEGUI.WindowManager:getSingleton()

    self.m_JuanZengBtn = CEGUI.toPushButton(winMgr:getWindow("familyfuwenjuanzengdialog/btn"))
    self.m_CheckBox_1 = CEGUI.toCheckbox(winMgr:getWindow("familyfuwenjuanzengdialog/xuanze"))
    self.m_CheckBox_2 = CEGUI.toCheckbox(winMgr:getWindow("familyfuwenjuanzengdialog/xuanze1"))
    self.m_CheckBox_1:setID(1)
    self.m_CheckBox_2:setID(0)
    self.m_CheckBox_1:subscribeEvent("MouseButtonUp", Familyfuwenjuanzengdialog.OnCheckBoxSelected, self)
    self.m_CheckBox_2:subscribeEvent("MouseButtonUp", Familyfuwenjuanzengdialog.OnCheckBoxSelected, self)
    self.m_ItemPanel = CEGUI.toItemTable(winMgr:getWindow("familyfuwenjuanzengdialog/diban/huadong/ItemPanel"))
    self.m_ScrollPanel = CEGUI.toScrollablePane(winMgr:getWindow("familyfuwenjuanzengdialog/diban/huadong"))
    self.m_ScrollPanel:EnableAllChildDrag(self.m_ScrollPanel)
    self.m_ScrollPanel:EnableHorzScrollBar(true)
    self.m_CloseBtnEx = CEGUI.toPushButton(winMgr:getWindow("familyfuwenjuanzengdialog/close"))
    self.m_HuoLiTipsText = winMgr:getWindow("familyfuwenjuanzengdialog/tishi1")
    self.m_HuoLiText = winMgr:getWindow("familyfuwenjuanzengdialog/tishi1/huolizhi")


    self.m_JuanZengBtn:subscribeEvent("Clicked", Familyfuwenjuanzengdialog.OnclickedJuanzengOkBtn, self)

    self.m_CloseBtnEx:subscribeEvent("Clicked", Familyfuwenjuanzengdialog.OnCloseBtnEx, self)
    self.m_Type = 1
    -- 捐赠类型  0活力  1道具
    self.m_CheckBox_1:setSelected(true)
    self.m_Filters = { }
    -- 背包筛选结果
    self.m_ItemID = 0
    -- 当前物品ID
    self.m_RoleID = 0
    -- 当前捐赠角色ID
    self.m_SendID = 0
    -- 发送物品的ID
    self.m_BagType = 0
    -- 被吧类型

end

function Familyfuwenjuanzengdialog:SetItemIDAndRoleID(id, roleid)
    -- 保存物品ID
    self.m_ItemID = id
    self.m_RoleID = roleid
    self:Filterids()
end

function Familyfuwenjuanzengdialog:Filterids()
    local roleItemManager = require("logic.item.roleitemmanager").getInstance()

    -- 清除筛选数据
    self.m_Filters = { }
    local itemkeys = {}

    --------------------------------------筛选背包
    itemkeys = roleItemManager:GetItemKeyListByBag(1)
    local len = itemkeys:size()
    for i = 0,(len - 1) do
        local item = roleItemManager:FindItemByBagAndThisID(itemkeys[i], 1)
        if item then
            if item:GetObjectID() == self.m_ItemID and (not item:isBind()) then
                local single = { }
                single.first = item
                single.second = 1
                table.insert(self.m_Filters, single)
            end
        end

    end
    --------------------------------------筛选背包

    --------------------------------------筛选临时背包
    itemkeys = roleItemManager:GetItemKeyListByBag(5)
    len = itemkeys:size()
    for i = 0,(len - 1) do
        local item = roleItemManager:FindItemByBagAndThisID(itemkeys[i], 5)
        if item then
            if item:GetObjectID() == self.m_ItemID and (not item:isBind()) then
                local single = { }
                single.first = item
                single.second = 5
                table.insert(self.m_Filters, single)
            end
        end
    end
    --------------------------------------筛选临时背包
    -- 处理画图
    self:RefreshTableView()
end

function Familyfuwenjuanzengdialog:HandleClicked(args)
    local id = CEGUI.toWindowEventArgs(args).window:getID()
    -- 清除选中状态
    for k, v in pairs(self.m_CellsCollection) do
        if v then
            v:SetSelected(false)
        end
        -- 设置点击
        if id == v:getID() then
            v:SetSelected(true)
            self.m_SendID = self.m_Filters[k].first:GetThisID()
            local level = self.m_Filters[k].first:GetItemLevel()
            self.m_BagType = self.m_Filters[k].second
            local pos = v:GetScreenPos()
            -- 弹出tips
            local commontipdlg = Commontipdlg.getInstanceAndShow()
            commontipdlg:RefreshItemWithObjectNormal(self.m_ItemID, self.m_Filters[k].first:GetObject(), pos.x, pos.x, false)
            commontipdlg:DisableBtn()
            local bHaveBtn = false
            commontipdlg:RefreshSize(bHaveBtn)
        end
    end
end

function Familyfuwenjuanzengdialog:RefreshTableView()
    self.m_CellsCollection = { }
    local len = #(self.m_Filters)
    self.m_ItemPanel:setProperty("LimitWindowSize", "False")
    local size = 92.0
    local row = 2
    -- local col = 3
    local spacex = 10
    local spacey = 10
    local colcount = math.ceil(len / row)
    self.m_ItemPanel:SetCellWidth(size)
    self.m_ItemPanel:SetCellHeight(size)
    self.m_ItemPanel:SetColCount(colcount)
    self.m_ItemPanel:SetSpaceX(spacex)
    self.m_ItemPanel:SetSpaceY(spacey)
    self.m_ItemPanel:DestroyAllCell()

    for i = 1, len do
        local cell = self.m_ItemPanel:AddCell(i - 1)
        if i == 1 then
            -- 当前捐赠角色ID
            self.m_SendID = self.m_Filters[i].first:GetThisID()
            -- 发送物品的ID
            self.m_BagType = self.m_Filters[i].second
            -- 设置选中
            if cell then
                cell:SetSelected(true)
            end
        end
        cell:SetEnableMaskClick(true)
        -- 设置信息
        local data = self.m_Filters[i]
        local Type = data.second
        local data = data.first
        local icon = gGetIconManager():GetItemIconByID(data:GetBaseObject().icon)
        cell:SetImage(icon)
        cell:setID(i)
        cell:setID2(Type)
        cell:subscribeEvent("MouseButtonUp", self.HandleClicked, self)
        table.insert(self.m_CellsCollection, cell)
        self.m_ScrollPanel:EnableChildDrag(cell)
    end
    -- 判断长度设置
    self.m_ItemPanel:setWidth(CEGUI.UDim(0,(colcount) * size +(colcount) * spacex))
    self.m_ItemPanel:setHeight(CEGUI.UDim(0, 280))

    -- 判断背包中没有可以捐献的物品时默认选中
    local len = #self.m_Filters
    if len == 0 then
        self:SetType(0)
    end

    local datamanager = require "logic.faction.factiondatamanager"
    self.m_HuoLiText:setText(tostring(datamanager.m_XiaoHaoHuoLi))
    if datamanager.m_XiaoHaoHuoLi == -1 then
        self.m_HuoLiTipsText:setVisible(false)
        self.m_CheckBox_2:setVisible(false)
        self:SetType(1)
    end
end


function Familyfuwenjuanzengdialog:OnCheckBoxSelected(args)
    local id = CEGUI.toWindowEventArgs(args).window:getID()
    self:SetType(id)
end

function Familyfuwenjuanzengdialog:OnclickedJuanzengOkBtn(args)
    local len = #self.m_CellsCollection
    if len == 0 and self.m_Type then
        if self.m_Type == 1 then
            GetCTipsManager():AddMessageTipById(160252)
            return
        end
    end
    local send = require "protodef.fire.pb.clan.crunegive":new()
    send.roleid = self.m_RoleID
    send.givetype = self.m_Type
    send.givevalue = self.m_ItemID
    send.itemkey = self.m_SendID
    send.bagtype = self.m_BagType
    require "manager.luaprotocolmanager":send(send)
    self:DestroyDialog()
end

-- 刷新列表
-- 刷新背包
function Familyfuwenjuanzengdialog:RefreshBackPack()

end

function Familyfuwenjuanzengdialog:OnCloseBtnEx(args)
    self:DestroyDialog()
end

-- 捐赠类型  0活力  1道具
function Familyfuwenjuanzengdialog:SetType(Type)
    self.m_Type = Type
    self.m_CheckBox_1:setSelected(Type == 1)
    self.m_CheckBox_2:setSelected(Type == 0)
end

return Familyfuwenjuanzengdialog
