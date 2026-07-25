require "logic.dialog"
require "logic.family.familyfuwenjuanzengdialog"
require "logic.family.familyfuwendiacell"
require "logic.family.familyfuwenqingqiudiacell"
require "logic.family.familyfuwentongjidiacell"

Familyfuwendialog = { }
setmetatable(Familyfuwendialog, Dialog)
Familyfuwendialog.__index = Familyfuwendialog

local _instance
function Familyfuwendialog.getInstance()
    if not _instance then
        _instance = Familyfuwendialog:new()
        _instance:OnCreate()
    end
    return _instance
end

function Familyfuwendialog.getInstanceAndShow()
    if not _instance then
        _instance = Familyfuwendialog:new()
        _instance:OnCreate()
    else
        _instance:SetVisible(true)
    end
    return _instance
end

function Familyfuwendialog.getInstanceNotCreate()
    return _instance
end

function Familyfuwendialog.DestroyDialog()
    if _instance then
        if not _instance.m_bCloseIsHide then
            -- 关闭tableview
            if _instance.m_Entrys_1 then
                _instance.m_Entrys_1:destroyCells()
            end
            if _instance.m_Entrys_2 then
                _instance.m_Entrys_2:destroyCells()
            end
            if _instance.m_Entrys_3 then
                _instance.m_Entrys_3:destroyCells()
            end
            _instance:OnClose()
            _instance = nil
        else
            _instance:ToggleOpenClose()
        end
    end
end

function Familyfuwendialog.ToggleOpenClose()
    if not _instance then
        _instance = Familyfuwendialog:new()
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function Familyfuwendialog.GetLayoutFileName()
    return "familyfuwendialog.layout"
end

function Familyfuwendialog:new()
    local self = { }
    self = Dialog:new()
    setmetatable(self, Familyfuwendialog)
    return self
end

function Familyfuwendialog:OnCreate()
    Dialog.OnCreate(self)
    local winMgr = CEGUI.WindowManager:getSingleton()
    self.m_IDCollection = { }
    self.SelectIDCollection = { }
    -- 当前页索引
    -- 1 2 3
    self.m_TabIndex = 1
    -- self.m_Entrys_1 = {}
    -- self.m_Entrys_2 = {}
    -- self.m_Entrys_3 = {}
    -- 标签页分组按钮
    self.m_GroupButton_1 = CEGUI.toGroupButton(winMgr:getWindow("familyfuwendialog/qingqiuxinxi"))
    self.m_GroupButton_2 = CEGUI.toGroupButton(winMgr:getWindow("familyfuwendialog/faqiqingqiu"))
    self.m_GroupButton_3 = CEGUI.toGroupButton(winMgr:getWindow("familyfuwendialog/dafutongji"))
    self.m_GroupButton_1:setID(1)
    self.m_GroupButton_2:setID(2)
    self.m_GroupButton_3:setID(3)
    self.m_GroupButton_1:setSelected(true)
    -- 三个列表页
    self.m_Column_1 = CEGUI.toMultiColumnList(winMgr:getWindow("familyfuwendialog/diban/xinxi"))
    self.m_Column_2 = CEGUI.toMultiColumnList(winMgr:getWindow("familyfuwendialog/diban/faqi"))
    self.m_Column_3 = CEGUI.toMultiColumnList(winMgr:getWindow("familyfuwendialog/diban/tongji"))
    -- 三个列底板
    self.m_Columnbg_1 = winMgr:getWindow("familyfuwendialog/xinxidiban")
    self.m_Columnbg_2 = winMgr:getWindow("familyfuwendialog/faqidiban1")
    self.m_Columnbg_3 = winMgr:getWindow("familyfuwendialog/tongjidiban")
    -- 符文活力分子
    self.m_HuoLiText1 = winMgr:getWindow("familyfuwendialog/yeqian/huoli/dangqian")
    -- 符文活力分母
    self.m_HuoLiText2 = winMgr:getWindow("familyfuwendialog/yeqian/huoli/max")
    -- 发起请求按钮
    self.m_SendApply = CEGUI.toPushButton(winMgr:getWindow("familyfuwendialog/qingqiu"))
    -- 请求次数文本提示
    self.m_TimeTipText = winMgr:getWindow("familyfuwendialog/diban/tishi")
    -- 次数文本
    self.m_TimeText = winMgr:getWindow("familyfuwendialog/diban/tishi/number")
    self.m_SumTimes = winMgr:getWindow("familyfuwendialog/diban/tishi/number1")
	
	self.c_fuwentips = CEGUI.toRichEditbox(winMgr:getWindow("familyfuwendialog/tishi/tishick"))
    -- 注册事件
    self.m_SendApply:subscribeEvent("Clicked", Familyfuwendialog.OnClikedSendApply, self)
    self.m_GroupButton_1:subscribeEvent("SelectStateChanged", Familyfuwendialog.OnSelectChangedGroupBtn, self)
    self.m_GroupButton_2:subscribeEvent("SelectStateChanged", Familyfuwendialog.OnSelectChangedGroupBtn, self)
    self.m_GroupButton_3:subscribeEvent("SelectStateChanged", Familyfuwendialog.OnSelectChangedGroupBtn, self)
    self.m_QingQiuImageTips = winMgr:getWindow("familyfuwendialog/diban/xinxi/tupian")

    -- 刷新列表显示
    local send = require "protodef.fire.pb.clan.crequestruneinfo":new()
    require "manager.luaprotocolmanager":send(send)
    --  self:RefreshTab1()
    -- 刷新列表显示
    self:RefreshColumnListVisible()
    self.m_TimeTipText:setVisible(self.m_TabIndex == 2)
    self.m_SendApply:setVisible(self.m_TabIndex == 2)
    self:RefreshHuoLi()
end
-- 添加选择打符的ID
function Familyfuwendialog:AddSelectID(id)
    if not self:IsExistSelectID(id) then
        table.insert(self.SelectIDCollection, id)
    end
end
-- 移除选择打符的ID
function Familyfuwendialog:RemoveSelectID(id)
    for k, v in pairs(self.SelectIDCollection) do
        if v == id then
            table.remove(self.SelectIDCollection, k)
        end
    end
end
-- 是否存在打符的ID
function Familyfuwendialog:IsExistSelectID(id)
    for k, v in pairs(self.SelectIDCollection) do
        if v == id then
            return true
        end
    end
    return false
end
-- 刷新列表页
function Familyfuwendialog:RefreshColumnListVisible()
    self.m_Column_1:setVisible(self.m_TabIndex == 1)
    self.m_Column_2:setVisible(self.m_TabIndex == 2)
    self.m_Column_3:setVisible(self.m_TabIndex == 3)
    self.m_Columnbg_1:setVisible(self.m_TabIndex == 1)
    self.m_Columnbg_2:setVisible(self.m_TabIndex == 2)
    self.m_Columnbg_3:setVisible(self.m_TabIndex == 3)
end
-- 标签页切换回调
function Familyfuwendialog:OnSelectChangedGroupBtn(args)
    local ID = CEGUI.toWindowEventArgs(args).window:getID()
    self.m_TabIndex = ID
    if ID == 1 then
        -- 请求符文请求信息
        local send = require "protodef.fire.pb.clan.crequestruneinfo":new()
        require "manager.luaprotocolmanager":send(send)
        self:ResetSelectBox()
        self.m_QingQiuImageTips:setVisible(false)
    elseif ID == 2 then
        local send = require "protodef.fire.pb.clan.crunerequestview":new()
        require "manager.luaprotocolmanager":send(send)
    elseif ID == 3 then
        local send = require "protodef.fire.pb.clan.crequestrunecount":new()
        require "manager.luaprotocolmanager":send(send)
        self:ResetSelectBox()
    end
    -- 刷新列表显示
    self:RefreshColumnListVisible()
    self.m_TimeTipText:setVisible(self.m_TabIndex == 2)
    self.m_SendApply:setVisible(self.m_TabIndex == 2)
end
--[[ ================================= ]]
-- 刷新页1
function Familyfuwendialog:RefreshTab1()
    if not self.m_FactionData and self.m_FactionData.m_RuneQuestList then
        return
    end
    local len = #(self.m_FactionData.m_RuneQuestList)
    if not self.m_Entrys_1 then
       -- local s = self.m_Column_1:getPixelSize()
        self.m_Entrys_1 = TableView.create(self.m_Column_1)
        self.m_Entrys_1:setViewSize(1100, 340 + 85+45)
        self.m_Entrys_1:setPosition(10, 4)
        self.m_Entrys_1:setDataSourceFunc(self, Familyfuwendialog.tableViewGetCellAtIndex_1)
    end
    self.m_Entrys_1:setCellCountAndSize(len, 998, 82)
    --self.m_Entrys_1:setContentOffset(0)
    self.m_Entrys_1:reloadData()

    self.m_QingQiuImageTips:setVisible(len == 0 and self.m_TabIndex == 1)
end
function Familyfuwendialog:tableViewGetCellAtIndex_1(tableView, idx, cell)
    idx = idx + 1
    if not cell then
        cell = Familyfuwenqingqiudiacell.CreateNewDlg(tableView.container)
    end
    if self.m_FactionData and self.m_FactionData.m_RuneQuestList then
        local infor = self.m_FactionData.m_RuneQuestList[idx]
        cell:SetInfor(infor)
    end
    cell.m_JuanZengBtn:setID(idx)
    cell.m_JuanZengBtn:subscribeEvent("Clicked", Familyfuwendialog.HandleClickedJuanZeng, self)
    return cell
end
-- 点击捐赠条目按钮
function Familyfuwendialog:HandleClickedJuanZeng(args)
    local ID = CEGUI.toWindowEventArgs(args).window:getID()
    local ItemID = self.m_FactionData.m_RuneQuestList[ID].itemid
    local RoleID = self.m_FactionData.m_RuneQuestList[ID].roleid
    -- 打开符文捐赠界面
    local dlg = Familyfuwenjuanzengdialog.getInstanceAndShow()
    if dlg then
        dlg:SetItemIDAndRoleID(ItemID, RoleID)
    end

end

--[[ ================================= ]]
-- 刷新第二页次数
function Familyfuwendialog:RefreshTab2text()
    if not self.m_FactionData or not self.m_FactionData.m_DaFuTimes then 
        return 
    end

    local costSum = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(207).value)
    local remainTimes = costSum - self.m_FactionData.m_DaFuTimes
	    -- 剩余次数
    self.m_TimeText:setText(tostring(costSum - self.m_FactionData.m_DaFuTimes))
    -- 总共次数
    self.m_SumTimes:setText(tostring(costSum))

    -- 将剩余次数和总次数用富文本的形式设置到 self.c_fuwentips
    local text = string.gsub(MHSD_UTILS.get_resstring(7855), "%$parameter1%$", tostring(remainTimes))
    text = string.gsub(text, "%$parameter2%$", tostring(costSum))
    self.c_fuwentips:Clear()
    self.c_fuwentips:AppendParseText(CEGUI.String(text))
    self.c_fuwentips:Refresh()
end


-- 刷新申请状态
function Familyfuwendialog:RefreshApplyState()
    for k, v in pairs(self.m_Entrys_2.visibleCells) do
        if v then
            v:RefreshApplyState()
        end
    end
end

-- 刷新页2
function Familyfuwendialog:RefreshTab2()
    self.m_IDCollection = BeanConfigManager.getInstance():GetTableByName("clan.cruneset"):getAllID()
    local len = #self.m_IDCollection

    if not self.m_Entrys_2 then
        --local s = self.m_Column_2:getPixelSize()
        self.m_Entrys_2 = TableView.create(self.m_Column_2)
        self.m_Entrys_2:setViewSize(932, 410)
        self.m_Entrys_2:setPosition(9, 5)
        self.m_Entrys_2:setDataSourceFunc(self, Familyfuwendialog.tableViewGetCellAtIndex_2)
    end
    self.m_Entrys_2:setColumCount(2)
    self.m_Entrys_2:setCellCountAndSize(len, 998, 82)
    self.m_Entrys_2:reloadData()
    self:RefreshTab2text()
end
function Familyfuwendialog:tableViewGetCellAtIndex_2(tableView, idx, cell)
    if idx == nil then
        return
    end
    if tableView == nil then
        return
    end
    idx = idx + 1
    if not cell then
        cell = Familyfuwendiacell.CreateNewDlg(tableView.container)
        cell.m_SelectBtn:subscribeEvent("CheckStateChanged", self.OnSelectBoxChanged, self)
    end
    if cell and self.m_IDCollection then
        local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(self.m_IDCollection[idx])
        if itemAttrCfg then
            cell:SetInfor(itemAttrCfg)
            cell.m_SelectBtn:setID(cell.m_ID)
        end
    end
    return cell
end
--[[ ================================= ]]
-- 刷新页3
function Familyfuwendialog:RefreshTab3()
    if not self.m_FactionData or not self.m_FactionData.m_FuwenTongjiList then
        return
    end
    local len = #(self.m_FactionData.m_FuwenTongjiList)
    if len == 0 then
        return
    end
    if not self.m_Entrys_3 then
        local s = self.m_Column_3:getPixelSize()
        self.m_Entrys_3 = TableView.create(self.m_Column_3)
        self.m_Entrys_3:setViewSize(s.width - 20, s.height - 45)
        self.m_Entrys_3:setPosition(0, 36)
        self.m_Entrys_3:setDataSourceFunc(self, Familyfuwendialog.tableViewGetCellAtIndex_3)
    end
    self.m_Entrys_3:setCellCountAndSize(len, 1200, 61)
    self.m_Entrys_3:setContentOffset(0)
    self.m_Entrys_3:reloadData()
end
function Familyfuwendialog:tableViewGetCellAtIndex_3(tableView, idx, cell)
    idx = idx + 1
    if not cell then
        cell = Familyfuwentongjidiacell.CreateNewDlg(tableView.container)
    end
    if self.m_FactionData.m_FuwenTongjiList and self.m_FactionData then
        local infor = self.m_FactionData.m_FuwenTongjiList[idx]
        cell:SetInfor(infor)
        if idx % 2 == 1 then
            cell.m_Btn:SetStateImageExtendID(1)
        else
            cell.m_Btn:SetStateImageExtendID(0)
        end
    end
    return cell
end
function Familyfuwendialog:ResetSelectBox()
    if not self.m_Entrys_2 then
        return
    end
    if not self.m_Entrys_2.visibleCells then
        return
    end
    for k, v in pairs(self.m_Entrys_2.visibleCells) do
        if v and v.m_SelectBtn then
            v.m_SelectBtn:setSelectedNoEvent(false)
        end
    end
end
function Familyfuwendialog:OnSelectBoxChanged(args)
    local id = CEGUI.toWindowEventArgs(args).window:getID()
    local check = CEGUI.toCheckbox(CEGUI.toWindowEventArgs(args).window)
    if check then
        if check:isSelected() then
            if self.m_FactionData then
                if not self.m_FactionData.IsInHasBeenRuneQuestList(id) then
                    self:AddSelectID(id)
                else
                    GetCTipsManager():AddMessageTipById(160253)
                    check:setSelectedNoEvent(false)
                end
            end
        else
            self:RemoveSelectID(id)
        end
    end
end
-- 发起请求按钮回调事件
function Familyfuwendialog:OnClikedSendApply(args)
    local len = #self.SelectIDCollection
    if len == 0 then
        GetCTipsManager():AddMessageTipById(160252)
    end
    local send = require "protodef.fire.pb.clan.crunerequest":new()
    for k, v in pairs(self.SelectIDCollection) do
        local single = RuneRequestInfo:new()
        single.itemid = v
        table.insert(send.runerequestinfolist, single)
    end
    require "manager.luaprotocolmanager":send(send)
end

-- 刷新活力分子分母
function Familyfuwendialog:RefreshHuoLi()
    local huoli = gGetDataManager():GetMainCharacterData():GetValue(fire.pb.attr.AttrType.ENERGY)
    local max = gGetDataManager():GetMainCharacterData():GetValue(fire.pb.attr.AttrType.ENLIMIT)
    self.m_HuoLiText1:setText(tostring(huoli))
    self.m_HuoLiText2:setText(tostring(max))
end

return Familyfuwendialog
