require "logic.dialog"
debugrequire "logic.leitai.leitaicell"
debugrequire "logic.leitai.leitaicell1"
debugrequire "logic.leitai.leitaiguanzhan"
debugrequire "logic.leitai.leitaiunder"
debugrequire "logic.leitai.leitaiunder1"
LeiTaiDialog = { }
setmetatable(LeiTaiDialog, Dialog)
LeiTaiDialog.__index = LeiTaiDialog

local _instance
function LeiTaiDialog.getInstance()
    if not _instance then
        _instance = LeiTaiDialog:new()
        _instance:OnCreate()
    end
    return _instance
end

function LeiTaiDialog.getInstanceAndShow()
    if not _instance then
        _instance = LeiTaiDialog:new()
        _instance:OnCreate()
    else
        _instance:SetVisible(true)
    end
    return _instance
end

function LeiTaiDialog.getInstanceNotCreate()
    return _instance
end

function LeiTaiDialog.DestroyDialog()
    if _instance then
        if not _instance.m_bCloseIsHide then
            if _instance.m_Entrys1 then
                _instance.m_Entrys1:destroyCells()
            end
            if _instance.m_Entrys2 then
                _instance.m_Entrys2:destroyCells()
            end
            if _instance.m_Entrys3 then
                _instance.m_Entrys3:destroyCells()
            end
            _instance:OnClose()
            _instance = nil
        else
            _instance:ToggleOpenClose()
        end
    end
end

function LeiTaiDialog.ToggleOpenClose()
    if not _instance then
        _instance = LeiTaiDialog:new()
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function LeiTaiDialog.GetLayoutFileName()
    return "leitai_mtg.layout"
end

function LeiTaiDialog:new()
    local self = { }
    self = Dialog:new()
    setmetatable(self, LeiTaiDialog)
    return self
end

function LeiTaiDialog:OnCreate()
    Dialog.OnCreate(self)
    local winMgr = CEGUI.WindowManager:getSingleton()

    -- 标签页
    self.m_GroupButton1 = CEGUI.toGroupButton(winMgr:getWindow("leitai_mtg/grpbtn1"))
    self.m_GroupButton2 = CEGUI.toGroupButton(winMgr:getWindow("leitai_mtg/grpbtn2"))
    self.m_GroupButton3 = CEGUI.toGroupButton(winMgr:getWindow("leitai_mtg/grpbtn3"))
    
    -- 注册标签页消息
    self.m_GroupButton1:subscribeEvent("MouseButtonUp", LeiTaiDialog.OnClickedTabButton, self)
    self.m_GroupButton2:subscribeEvent("MouseButtonUp", LeiTaiDialog.OnClickedTabButton, self)
    self.m_GroupButton3:subscribeEvent("MouseButtonUp", LeiTaiDialog.OnClickedTabButton, self)
    self.m_GroupButton1:setID(1)
    self.m_GroupButton2:setID(2)
    self.m_GroupButton3:setID(3)
    self.m_Up1 = winMgr:getWindow("leitai_mtg/dengjibtn/up")
    self.m_Down1 = winMgr:getWindow("leitai_mtg/dengjibtn/down")
    self.m_Up = winMgr:getWindow("leitai_mtg/btn1/up")
    self.m_Down = winMgr:getWindow("leitai_mtg/btn1/down")
    self.m_NoEntrysImage = winMgr:getWindow("leitai_mtg/wuren")
    self.m_NoEntrysTips = winMgr:getWindow("leitai_mtg/wuren/dikuang/text")
    self.m_AllButton = CEGUI.toPushButton(winMgr:getWindow("leitai_mtg/dengjibtn"))
    self.m_AllButton:subscribeEvent("Clicked", LeiTaiDialog.OnClickedAllButton, self)
    self.m_GroupUnder1 = winMgr:getWindow("leitai_mtg/textbg")
    self.m_GroupUnder2 = winMgr:getWindow("leitai_mtg/textbg1")
    self.m_GroupUnder3 = winMgr:getWindow("leitai_mtg/textbg2")
    self.m_ShuaXinButton = CEGUI.toPushButton(winMgr:getWindow("leitai_mtg/btnshuaxin"))
    self.m_ShuaXinButton:subscribeEvent("Clicked", LeiTaiDialog.OnClickedRefresh, self)

    self.m_ZhiYeShaiXuanBtn = CEGUI.toPushButton(winMgr:getWindow("leitai_mtg/btn1"))
    self.m_ZhiYeShaiXuanBtn:subscribeEvent("Clicked", LeiTaiDialog.OnClickedZhiYeShaiXuan, self)
    --[[
0 --不筛选
11	战士
12	圣骑
13	猎人
14	德鲁伊
15	法师
16	牧师
17	盗贼
18	萨满
19	术士
]]

    -- 默认当前标签页为第一页
    self.m_PageIndex = 0
    self.m_FilterMode = -1
    self.ZhiYeFilter = 0
    -- 1 打开 2 关闭
    self.m_Entrys1 = nil
    self.m_Entrys2 = nil
    self.m_Entrys3 = nil
    -- self:SetPage(1)
    self:SetUpAndDown()
    self:SetUpAndDown2()
end
function LeiTaiDialog:OnClickedRefresh(args)
    local datamanager = require "logic.leitai.leitaidatamanager"
    local send = require "protodef.fire.pb.battle.cplaypkfightview":new()
    send.modeltype = datamanager.ModularType
    send.levelindex = datamanager.m_LevelArea
    send.school = datamanager.m_FilterMode

    require "manager.luaprotocolmanager":send(send)

end
function LeiTaiDialog:OnClickedZhiYeShaiXuan(args)
    local dlg = LeiTaiUnder.getInstanceNotCreate()
    if dlg then
        dlg.DestroyDialog()
        self:SetUpAndDown()
    else
        local dlg1 = LeiTaiUnder.getInstanceAndShow(self:GetWindow())
        local posx = self.m_ZhiYeShaiXuanBtn:getPosition().x.offset
        local posy = self.m_ZhiYeShaiXuanBtn:getPosition().y.offset

        local height =  dlg1.m_Under:getHeight().offset
        dlg1:GetWindow():setXPosition(CEGUI.UDim(0, posx + 1 ))
	    dlg1:GetWindow():setYPosition(CEGUI.UDim(0, posy - height + 1))
        self:SetUpAndDown()
    end
end
function LeiTaiDialog:ClickedZhiYe(args)

end
-- 房间筛选 1 打开 2 关闭
function LeiTaiDialog:OnClickedAllButton(args)
    local dlg = LeiTaiUnder1.getInstanceNotCreate()
    if dlg then
        LeiTaiUnder1.DestroyDialog()
        self:SetUpAndDown2()
    else
        local dlg1 =  LeiTaiUnder1.getInstanceAndShow(self:GetWindow())
        local posx = self.m_AllButton:getPosition().x.offset
        local posy = self.m_AllButton:getPosition().y.offset
        local height =  dlg1.m_Under:getHeight().offset
        dlg1:GetWindow():setXPosition(CEGUI.UDim(0, posx ))
	    dlg1:GetWindow():setYPosition(CEGUI.UDim(0, posy - height))
        self:SetUpAndDown2()
    end
end
-- 箭头筛选
function LeiTaiDialog:SetUpAndDown()
    local dlg = LeiTaiUnder.getInstanceNotCreate()
    self.m_Up:setVisible(dlg == nil)
    self.m_Down:setVisible(dlg ~= nil)
end
-- 箭头筛选2
function LeiTaiDialog:SetUpAndDown2()
    local dlg = LeiTaiUnder1.getInstanceNotCreate()
    self.m_Up1:setVisible(dlg == nil)
    self.m_Down1:setVisible(dlg ~= nil)
end
function LeiTaiDialog:ResetGroupUnder()
    self.m_GroupUnder1:setVisible(false)
    self.m_GroupUnder2:setVisible(false)
    self.m_GroupUnder3:setVisible(false)
end
function LeiTaiDialog:OnClickedTabButton(args)
    local e = CEGUI.toWindowEventArgs(args)
    local id = e.window:getID()
    self:SetPage(id)
end
function LeiTaiDialog:ResetTabButton()
    self.m_GroupButton1:setSelected(false)
    self.m_GroupButton2:setSelected(false)
    self.m_GroupButton3:setSelected(false)
end
function LeiTaiDialog:SetSelectTabButton(index)
    if index == 1 then
        self.m_GroupButton1:setSelected(true)
    elseif index == 2 then
        self.m_GroupButton2:setSelected(true)
    elseif index == 3 then
        self.m_GroupButton3:setSelected(true)
    end
end
-- 设置显示标签页
function LeiTaiDialog:SetPage(index)
    if self.m_PageIndex == index then
        return
    end
    self:ResetTabButton()
    self.m_PageIndex = index
    self:SetSelectTabButton(self.m_PageIndex)
    local send = require "protodef.fire.pb.battle.cplaypkfightview":new()
    send.modeltype = self.m_PageIndex
    send.school = self.m_FilterMode
    send.levelindex = 0
    require "manager.luaprotocolmanager":send(send)
end
-- 刷新标签页函数1
function LeiTaiDialog:RefreshTab1()
    self:ResetGroupUnder()
    self.m_GroupUnder1:setVisible(true)
    self:RefreshListView1()
    self:SetTipsImageVisile()
end
-- 刷新标签页函数1
function LeiTaiDialog:RefreshTab2()
    self:ResetGroupUnder()
    self.m_GroupUnder2:setVisible(true)
    self:RefreshListView2()
    self:SetTipsImageVisile()
end
-- 刷新标签页函数1
function LeiTaiDialog:RefreshTab3()
    self:ResetGroupUnder()
    self.m_GroupUnder3:setVisible(true)
    self:RefreshListView3()
    self:SetTipsImageVisile()
end
--------------------------------------------------------------------
-- 刷新列表
function LeiTaiDialog:RefreshListView1()
    local datamanager = require "logic.leitai.leitaidatamanager"
    local len = #datamanager.m_EntryList
    -- 清空容器
    if self.m_Entrys1 then

    else
        local s = self.m_GroupUnder1:getPixelSize()
        self.m_Entrys1 = TableView.create(self.m_GroupUnder1)
        self.m_Entrys1:setViewSize(s.width - 20, s.height)
        self.m_Entrys1:setPosition(8, 7)
        self.m_Entrys1:setDataSourceFunc(self, LeiTaiDialog.tableViewGetCellAtIndex1)
        self.m_Entrys1:setContentOffset(0)
    end
    self.m_Entrys1:setColumCount(2)
    self.m_Entrys1:setCellCountAndSize(len, 462 - 10, 112)
    self.m_Entrys1:reloadData()
end
function LeiTaiDialog:tableViewGetCellAtIndex1(tableView, idx, cell)
    idx = idx + 1
    if not cell then
        cell = LeiTaiCell.CreateNewDlg(tableView.container, idx)
        if cell.m_FightButton then
            cell.m_FightButton:subscribeEvent("Clicked", LeiTaiDialog.OnclikcedFightButton, self)
        end
    end
    local datamanager = require "logic.leitai.leitaidatamanager"
    local infor = datamanager.m_EntryList[idx]
    cell:SetInfor(infor)
    
    return cell
end
function LeiTaiDialog:OnclikcedFightButton(args)
    local ID = CEGUI.toWindowEventArgs(args).window:getID()
    local invitePKAction = require "protodef.fire.pb.battle.csendinviteplaypk".Create()
    invitePKAction.guestroleid = ID
    LuaProtocolManager.getInstance():send(invitePKAction)
    self:DestroyDialog()
end

--------------------------------------------------------------------
function LeiTaiDialog:RefreshListView2()
    local datamanager = require "logic.leitai.leitaidatamanager"
    local len = #datamanager.m_EntryList
    -- 清空容器
    if self.m_Entrys2 then

    else
        local s = self.m_GroupUnder2:getPixelSize()
        self.m_Entrys2 = TableView.create(self.m_GroupUnder2)
        self.m_Entrys2:setViewSize(s.width - 20, s.height)
        self.m_Entrys2:setPosition(8, 7)
        self.m_Entrys2:setDataSourceFunc(self, LeiTaiDialog.tableViewGetCellAtIndex2)
        self.m_Entrys2:setContentOffset(0)
    end
    self.m_Entrys2:setColumCount(2)
    self.m_Entrys2:setCellCountAndSize(len, 462 - 10, 112)
    self.m_Entrys2:reloadData()
end
function LeiTaiDialog:tableViewGetCellAtIndex2(tableView, idx, cell)
    idx = idx + 1
    if not cell then
        cell = LeiTaiCell1.CreateNewDlg(tableView.container, idx)
        if cell.m_FightButton then
            cell.m_FightButton:subscribeEvent("Clicked", LeiTaiDialog.OnclikcedFightButton, self)
        end
    end
    local datamanager = require "logic.leitai.leitaidatamanager"
    local infor = datamanager.m_EntryList[idx]
    cell:SetInfor(infor)
    
    return cell
end
--------------------------------------------------------------------
function LeiTaiDialog:RefreshListView3()
    local datamanager = require "logic.leitai.leitaidatamanager"
    local len = #datamanager.m_EntryList2
    -- 清空容器
    if self.m_Entrys3 then

    else
        local s = self.m_GroupUnder3:getPixelSize()
        self.m_Entrys3 = TableView.create(self.m_GroupUnder3)
        self.m_Entrys3:setViewSize(s.width, s.height)
        self.m_Entrys3:setPosition(8, 10)
        self.m_Entrys3:setDataSourceFunc(self, LeiTaiDialog.tableViewGetCellAtIndex3)
        self.m_Entrys3:setContentOffset(0)
    end
    self.m_Entrys3:setCellCountAndSize(len, 681, 113)
    self.m_Entrys3:reloadData()
end
function LeiTaiDialog:tableViewGetCellAtIndex3(tableView, idx, cell)
    idx = idx + 1
    if not cell then
        cell = LeiTaiGuanZhan.CreateNewDlg(tableView.container, idx)
        if cell.m_LookFightButton then
            cell.m_LookFightButton:subscribeEvent("Clicked", LeiTaiDialog.OnclikcedLookFightButton, self)
        end
    end
    local datamanager = require "logic.leitai.leitaidatamanager"
    local infor = datamanager.m_EntryList2[idx]
    cell:SetInfor(infor)
    
    return cell
end
function LeiTaiDialog:OnclikcedLookFightButton(args)
    local ID = CEGUI.toWindowEventArgs(args).window:getID()
    local p = require("protodef.fire.pb.battle.csendwatchbattle"):new()
    p.roleid = ID
	LuaProtocolManager:send(p)
end
--------------------------------------------------------------------
function LeiTaiDialog:SetTipsImageVisile()
    local Table = 
    {
        [1] = MHSD_UTILS.get_resstring(11363),
        [2] = MHSD_UTILS.get_resstring(11374),
        [3] = MHSD_UTILS.get_resstring(11364)
    }

    local datamanager = require "logic.leitai.leitaidatamanager"
    local text = Table[datamanager.ModularType]
    if not text then
    return
    end
    if datamanager.ModularType == 1 or datamanager.ModularType == 2 then
        local len = #datamanager.m_EntryList
        self.m_NoEntrysImage:setVisible(len == 0)
    else
        local len = #datamanager.m_EntryList2
        self.m_NoEntrysImage:setVisible(len == 0)
    end
    if self.m_NoEntrysTips then
        self.m_NoEntrysTips:setText(text)
    end
end
-- 刷新当前筛选模式
function LeiTaiDialog:RefreshFilter()

end
return LeiTaiDialog
