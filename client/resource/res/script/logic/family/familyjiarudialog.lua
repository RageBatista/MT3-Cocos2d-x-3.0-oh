-- 加入公会（公会列表）界面

require "logic.dialog"
debugrequire "logic.family.familyjiarudiacell"
debugrequire "logic.family.familychuangjiandialog"

Familyjiarudialog = { }
setmetatable(Familyjiarudialog, Dialog)
Familyjiarudialog.__index = Familyjiarudialog

local _instance

function Familyjiarudialog.getInstance()
    if not _instance then
        _instance = Familyjiarudialog:new()
        _instance:OnCreate()
    end
    return _instance
end

function Familyjiarudialog.getInstanceAndShow()
    if not _instance then
        _instance = Familyjiarudialog:new()
        _instance:OnCreate()
    else
        _instance:SetVisible(true)
    end
    return _instance
end

function Familyjiarudialog.getInstanceNotCreate()
    return _instance
end

function Familyjiarudialog:new()
    local self = { }
    self = Dialog:new()
    setmetatable(self, Familyjiarudialog)
    return self
end

function Familyjiarudialog.DestroyDialog()

    if _instance then
	_instance.ApplyJoinBtn.animation:stop()
	_instance.m_BtnCreate.animation:stop()
	_instance.ConnectHostBtn.animation:stop()
	_instance.m_SearchBtn.animation:stop()
	_instance.m_CancelInputBtn.animation:stop()
	_instance.m_CloseBtnEx.animation:stop()
        if not _instance.m_bCloseIsHide then
            -- 关闭tableview
            if _instance.m_Entrys then
                _instance.m_Entrys:destroyCells()
            end
            _instance:OnClose()
            _instance = nil
        else
            _instance:ToggleOpenClose()
        end
    end
end

function Familyjiarudialog.ToggleOpenClose()
    if not _instance then
        _instance = Familyjiarudialog:new()
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function Familyjiarudialog.GetLayoutFileName()
    return "familyjiarudialog.layout"
end

function Familyjiarudialog:addButtonAnimation(button, animationName)
    local animationDef = CEGUI.AnimationManager:getSingleton():getAnimation(animationName)
    if animationDef then
        local animation = CEGUI.AnimationManager:getSingleton():instantiateAnimation(animationDef)
        animation:setTargetWindow(button)
        animation:setSpeed(0.5)
        button.animation = animation
        button:subscribeEvent("MouseButtonDown", function()
            animation:start()
        end, self)
    end
end

function Familyjiarudialog:OnCreate()
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()

    self.m_CurPage = 1
    self.m_FactionData = { }

    -- 加入公会标题
    self.m_JaiRuText = winMgr:getWindow("familyjiarudialog/jiarugonghui")

    -- 公会列表标题
    self.m_GongHuiText = winMgr:getWindow("familyjiarudialog/gonghuiliebiao")

    -- 是否正在搜索
    self.Searched = false
    -- 搜索取消按钮
    self.m_CancelInputBtn = CEGUI.toPushButton(winMgr:getWindow("familyjiarudialog/shurukuang/InputtextBox/X"))
	self:addButtonAnimation(self.m_CancelInputBtn, "xstudyBtnPress")
    self.m_CancelInputBtn:setVisible(false) -- 默认不显示取消按钮
    self.m_CancelInputBtn:subscribeEvent("Clicked", Familyjiarudialog.OnCancelInputBtnHandler, self)
    -- 搜索公会按钮
    self.m_SearchBtn = CEGUI.toPushButton(winMgr:getWindow("familyjiarudialog/chazhao"))
	self:addButtonAnimation(self.m_SearchBtn, "xstudyBtnPress")
    self.m_SearchBtn:subscribeEvent("Clicked", Familyjiarudialog.OnClickSearchBtnHandler, self)
    -- 输入文本控件
    self.m_IDNumberInputText = CEGUI.toEditbox(winMgr:getWindow("familyjiarudialog/shurukuang/InputtextBox"))
	self.m_IDNumberInputText:SetNormalColourRect(0xFF8C5E2A);
    self.m_IDNumberInputText:subscribeEvent("MouseButtonDown", Familyjiarudialog.IDNumberInputTextClicked, self)
    -- ID提示
    self.m_IDTip = winMgr:getWindow("familyjiarudialog/shurukuang/InputtextBox/tishi")
    -- 未搜索到公会的情况下显示的搜索结果
    self.m_LingSui = winMgr:getWindow("familyjiarudialog/liebiao/yindaojieguo")

--    -- 公会学徒Tips按钮
--    self.m_BtnXueTuTips = CEGUI.toPushButton(winMgr:getWindow("familyjiarudialog/xuetushuoming/text"))
--    self.m_BtnXueTuTips:subscribeEvent("Clicked", Familyjiarudialog.BtnXueTuTipsClicked, self)

    -- 公会宗旨Text
    self.m_ZongZhiText = CEGUI.toRichEditbox(winMgr:getWindow("familyjiarudialog/gonghuixinxi/zongzhi"))
	self.m_ZongZhiText:SetForceHideVerscroll(true)
    self.m_OldNameText = winMgr:getWindow("familyjiarudialog/gonghuixinxi/gaiming")

--    -- 一键申请按钮
--    self.OneKeyApplyJoinBtn = CEGUI.toPushButton(winMgr:getWindow("familyjiarudialog/anniu/yijianshenqing"))
--    self.OneKeyApplyJoinBtn:subscribeEvent("MouseClick", Familyjiarudialog.OneKeyApplyJoinBtnClicked, self)

    -- 申请加入按钮
    self.ApplyJoinBtn = CEGUI.toPushButton(winMgr:getWindow("familyjiarudialog/anniu/shenqingjiaru"))
	self:addButtonAnimation(self.ApplyJoinBtn, "studyBtnPress")
    self.ApplyJoinBtn:subscribeEvent("Clicked", Familyjiarudialog.ApplyJoinBtnClicked, self)

    -- 创建公会按钮
    self.m_BtnCreate = CEGUI.toPushButton(winMgr:getWindow("familyjiarudialog/anniu/chuangjiangonghui"))
	self:addButtonAnimation(self.m_BtnCreate, "studyBtnPress")
    self.m_BtnCreate:subscribeEvent("MouseClick", Familyjiarudialog.BtnCreateClicked, self)

    -- 联系会长按钮
    self.ConnectHostBtn = CEGUI.toPushButton(winMgr:getWindow("familyjiarudialog/anniu/lianxihuizhang"))
	self:addButtonAnimation(self.ConnectHostBtn, "studyBtnPress")
    self.ConnectHostBtn:subscribeEvent("Clicked", Familyjiarudialog.ConnectHostBtnClicked, self)

    -- 关闭按钮
    self.m_CloseBtnEx = CEGUI.toPushButton(winMgr:getWindow("familyjiarudialog/close"))
	self:addButtonAnimation(self.m_CloseBtnEx, "xstudyBtnPress")
    self.m_CloseBtnEx:subscribeEvent("Clicked", Familyjiarudialog.OnCloseBtnEx, self)

    -- 公会条目ListView父容器
    self.m_EntryCollection = CEGUI.toMultiColumnList(winMgr:getWindow("familyjiarudialog/liebiao"))

    -- 清空公会列表信息
    local datamanager = require "logic.faction.factiondatamanager"
    if datamanager then
        datamanager.m_FamilyList.m_Curpage = 0
        datamanager.m_FamilyList.m_FactionList = { }
    end

    -- 申请一份最新的公会列表信息
    local p = require "protodef.fire.pb.clan.copenclanlist":new()
    p.currpage = 1
    require "manager.luaprotocolmanager".getInstance():send(p)

    -- 初始化当前选中公会列表中的条目索引
    self.m_CurSelectEntryIndex = 0
    self.ApplyJoinBtn:setEnabled(false)
    self.ConnectHostBtn:setEnabled(false)
    self:RefreshMode()
    SetPositionScreenCenter(self:GetWindow())
end

-- 向前翻页
function Familyjiarudialog:HandlePrePage(args)
    self.m_CurPage = self.m_CurPage - 1
    if self.m_CurPage < 1 then
        self.m_CurPage = 1
    end
end

-- 向后翻页
function Familyjiarudialog:HandleNextPage(args)
    self.m_CurPage = self.m_CurPage + 1
    if self.m_CurPage > self.m_FactionData.m_FamilyList.m_Curpage then
        local p = require "protodef.fire.pb.clan.copenclanlist":new()
        p.currpage = self.m_CurPage
        require "manager.luaprotocolmanager".getInstance():send(p)
    end

end

-- 点击关闭按钮
function Familyjiarudialog:OnCloseBtnEx(args)
    self.DestroyDialog()
end

-- 刷新显示模式
function Familyjiarudialog:RefreshMode()
    local datamanager = require "logic.faction.factiondatamanager"
    if datamanager then
        self.m_GongHuiText:setVisible(datamanager:IsHasFaction())
        self.m_JaiRuText:setVisible(not datamanager:IsHasFaction())
--        self.OneKeyApplyJoinBtn:setVisible(not datamanager:IsHasFaction()) -- 一键申请按钮
        self.ApplyJoinBtn:setVisible(not datamanager:IsHasFaction())
        self.m_BtnCreate:setVisible(not datamanager:IsHasFaction())
    end
end

-- 刷新申请状态
function Familyjiarudialog:RefreshApplyState()
    if self.m_Entrys then
        for k, v in pairs(self.m_Entrys.visibleCells) do
            if v then
                v:RefreshApplyState()
            end
        end
    end

end

-- 点击搜索取消按钮
function Familyjiarudialog:OnCancelInputBtnHandler(args)
    -- 删除文字
    self.m_IDNumberInputText:setText("")
    -- 不显示取消输入x按钮
    self.m_CancelInputBtn:setVisible(false)
    -- 还原刷新列表
    local datamanager = require "logic.faction.factiondatamanager"
    local len = #(datamanager.m_FamilyList.m_FactionList)
    if self.Searched then
        if datamanager.m_SearchIsNull == false then
            table.remove(datamanager.m_FamilyList.m_FactionList, 1)
        end
        self.Searched = false
    end
    self.m_FactionData.m_FamilyList.m_FactionList = datamanager.m_FamilyList.m_FactionList
    self:ReFreshFamilyListView()
end

-- 点击搜索按钮
function Familyjiarudialog:OnClickSearchBtnHandler(args)
    if self.m_CancelInputBtn:isVisible() then
        return
    end
    local text = self.m_IDNumberInputText:getText()
    if text ~= "" then
        local id = tonumber(text)

        -- 发送搜索工会的ID
        local p = require "protodef.fire.pb.clan.csearchclan":new()
        p.clanid = id
        require "manager.luaprotocolmanager":send(p)

        -- 显示取消按钮
        self.m_CancelInputBtn:setVisible(true)
        self.Searched = false
    else
        local str = MHSD_UTILS.get_msgtipstring(160312)

        GetCTipsManager():AddMessageTip(str)
    end

end

-- 点击申请加入
function Familyjiarudialog:ApplyJoinBtnClicked(args)
    -- 保存当前点击公会信息
    local cell = self.m_Entrys:getCellAtIdx(self.m_CurSelectEntryIndex - 1)
    if cell then
        local id = cell.m_ID
        local send = require "protodef.fire.pb.clan.capplyclan":new()
        send.clanid = id
        LuaProtocolManager.getInstance():send(send)
        -- self.DestroyDialog()
    end

end

-- 点击查找公会输入框
function Familyjiarudialog:IDNumberInputTextClicked(args)
    if self.m_CancelInputBtn:isVisible() then
        return
    end
    NumKeyboardDlg.DestroyDialog()
    local dlg = NumKeyboardDlg.getInstanceAndShow()
    dlg:setMaxLength(13)
    SetPositionOffset(dlg:GetWindow(), 395, 600, 0.5, 1)
    dlg:setInputChangeCallFunc(Familyjiarudialog.onInputChanged, self)
end

-- 输入回调
function Familyjiarudialog:onInputChanged(args)
    self.m_IDNumberInputText:setText(args)
end

-- 点击联系会长
function Familyjiarudialog:ConnectHostBtnClicked(args)
    -- to do 1.添加联系人(会长)
    -- 2.默认选中会长
    -- FriendDialog.getInstanceAndShow()
    local Curcell = self.m_Entrys:getCellAtIdx(self.m_CurSelectEntryIndex - 1)
    if Curcell then
        local memberid = self.m_FactionData.GetFaction(Curcell.m_ID).clanmasterid
        if not memberid then
            return
        end
        if gGetFriendsManager() then
            gGetFriendsManager():RequestSetChatRoleID(memberid)
        end
        Family.DestroyDialog(true)
        self.DestroyDialog()
    end

end

-- 点击创建公会按钮
function Familyjiarudialog:BtnCreateClicked(args)
    Familychuangjiandialog.getInstanceAndShow()
end

-- 重置所有控件选中状态
function Familyjiarudialog:ResetSelect()
    for _, v in pairs(self.m_Entrys.visibleCells) do
        v.btn:setSelected(false)
    end
end

-- 刷新公会列表
function Familyjiarudialog:ReFreshFamilyListView()
    if self.m_FactionData then
        if not self.m_FactionData.m_FamilyList then
            return
        end
        if not self.m_FactionData.m_FamilyList.m_FactionList then
            return
        end
        local len = #(self.m_FactionData.m_FamilyList.m_FactionList)
        if self.m_Entrys then
        else
            local s = self.m_EntryCollection:getPixelSize()
            self.m_Entrys = TableView.create(self.m_EntryCollection)
            self.m_Entrys:setViewSize(s.width - 0, 410)
            self.m_Entrys:setPosition(0, 48)
            self.m_Entrys:setDataSourceFunc(self, Familyjiarudialog.tableViewGetCellAtIndex)
            self.m_Entrys.scroll:subscribeEvent("NextPage", Familyjiarudialog.HandleNextPage, self)
            self.m_Entrys.scroll:subscribeEvent("PrePage", Familyjiarudialog.HandlePrePage, self)

        end
        if self.m_CancelInputBtn:isVisible() and self.m_FactionData.m_LastSearchResult.clanid ~= 0 then
            self.m_Entrys:setCellCountAndSize(1, 326, 50)
        elseif self.m_CancelInputBtn:isVisible() and self.m_FactionData.m_LastSearchResult.clanid == 0 then
            self.m_Entrys:setCellCountAndSize(0, 326, 50)
        else
            self.m_Entrys:setCellCountAndSize(len, 326, 50)
        end
        self.m_Entrys:reloadData()
    end

end

-- 用于tableview中的cell的刷新，在tableview创建或刷新时回调
function Familyjiarudialog:tableViewGetCellAtIndex(tableView, idx, cell)
    idx = idx + 1
    if not cell then
        if self.m_FactionData then
            cell = Familyjiarudiacell.CreateNewDlg(tableView.container, tableView:genCellPrefix())
            cell.btn:setGroupID(20)
        end
    end
    if idx % 2 == 1 then
        cell.btn:SetStateImageExtendID(1)
    else
        cell.btn:SetStateImageExtendID(0)
    end
    cell.btn:setID(idx)
    cell:SetInfor(self.m_FactionData.m_FamilyList.m_FactionList[idx])
    cell.m_SelectBtn:setID(cell.m_ID)
    cell.btn:subscribeEvent("MouseButtonUp", Familyjiarudialog.HandleFamilyEntryCellClicked, self)
    cell.btn:subscribeEvent("MouseButtonDown", Familyjiarudialog.HandleFamilyEntryCellClickedDown, self)
    cell.m_SelectBtn:subscribeEvent("Clicked", Familyjiarudialog.HandleCancel, self)
    return cell
end


---------------------------------------------------------------

local cancelID = 0
local confirmtype = 0

-- 取消确认按钮的回调
local function acceptCancel()
    gGetMessageManager():CloseConfirmBox(confirmtype, false)
    if not cancelID then
        return
    end
    local p = require "protodef.fire.pb.clan.ccancelapplyclan":new()
    p.clanid = cancelID
    require "manager.luaprotocolmanager":send(p)
end

-- 点击取消发送按钮
function Familyjiarudialog:HandleCancel(args)
    local e = CEGUI.toWindowEventArgs(args)
    cancelID = e.window:getID()
    local temp = self.m_FactionData.GetFaction(cancelID)
    if temp then
        local text = MHSD_UTILS.get_resstring(11308)
        text = string.gsub(text, "%$parameter1%$", temp.clanname)

        confirmtype = MHSD_UTILS.addConfirmDialog(text, acceptCancel)
    end
end

---------------------------------------------------------------


---- 公会学徒Tips按钮
--function Familyjiarudialog:BtnXueTuTipsClicked(args)
--    -- to do 读表
--    local tips1 = require "logic.workshop.tips1"
--    local strTitle = MHSD_UTILS.get_resstring(11284)
--    local strContent = MHSD_UTILS.get_resstring(11175)
--    if tips1.getInstanceNotCreate() == nil then
--        local tips1Instance = tips1.getInstanceAndShow(strContent, strTitle)
--        SetPositionScreenCenter(tips1Instance:GetWindow())
--    else
--        -- 仅仅设置文本就可以了.
--        tips1.getInstanceNotCreate():RefreshData(strContent, strTitle)
--    end
--end

-- 公会列表项鼠标按下
function Familyjiarudialog:HandleFamilyEntryCellClickedDown(args)
    self:ResetSelect()
end

-- 公会列表项鼠标抬起(弹出菜单)
function Familyjiarudialog:HandleFamilyEntryCellClicked(args)
    local e = CEGUI.toWindowEventArgs(args)
    local id = e.window:getID()
    self.m_CurSelectEntryIndex = id
    local Curcell = self.m_Entrys:getCellAtIdx(self.m_CurSelectEntryIndex - 1)
    if Curcell then
        self.ApplyJoinBtn:setEnabled(true)
        self.ConnectHostBtn:setEnabled(true)
        local curRoleID = gGetDataManager():GetMainCharacterID()
        if self.m_FactionData:IsHasFaction() then
            if Curcell.m_ID == self.m_FactionData.factionid and self.m_FactionData.GetMyZhiWu() == 1 then
                self.ConnectHostBtn:setEnabled(false)
            end
        end

        -- 设置按钮状态
        Curcell.btn:setSelected(true)

        -- 发送申请宗旨
        if Curcell then
            local p = require "protodef.fire.pb.clan.crequestclanaim":new()
            p.clanid = Curcell.m_ID
            require "manager.luaprotocolmanager":send(p)
        end
    else
        local sun = 1
    end
end

-- 刷新公会宗旨
function Familyjiarudialog:RefreshZongZhi(text)
    if self.m_ZongZhiText then
		self.m_ZongZhiText:Clear()
        self.m_ZongZhiText:AppendText(CEGUI.String(text), CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("ff472b20")))
		self.m_ZongZhiText:Refresh()
        self.m_ZongZhiText:HandleTop()
    end
end

-- 刷新曾用名
function Familyjiarudialog:RefreshOldName(text)
    if text then
        local msg = MHSD_UTILS.get_resstring(11275)
        msg = string.gsub(msg, "%$parameter1%$", text)
        self.m_OldNameText:setText(msg)
    end
end

-- 刷新ID显示
function Familyjiarudialog:update(args)
    local text = self.m_IDNumberInputText:getText()
    self.m_IDTip:setVisible(text == "")
    if self.m_Entrys then
        if self.m_Entrys.visibleCells then
            local len = 0
            for k, v in pairs(self.m_Entrys.visibleCells) do
                if v then
                    len = len + 1
                end
            end
            if self.m_CancelInputBtn then
                self.m_LingSui:setVisible((len == 0 and self.m_CancelInputBtn:isVisible()))
            end
        end
    end

end

return Familyjiarudialog
