------------------------------------------------------------------
-- 队伍匹配界面
------------------------------------------------------------------
require "logic.dialog"
require "logic.team.teammatchcell"
require "logic.team.teamsettingdlg"
require "utils.commonutil"

TeamMatchDlg = {}
setmetatable(TeamMatchDlg, Dialog)
TeamMatchDlg.__index = TeamMatchDlg

local _instance
function TeamMatchDlg.getInstance()
    if not _instance then
        _instance = TeamMatchDlg:new()
        _instance:OnCreate()
    end

    return _instance
end

local TASK_FONT_SIZE = 13
local TASK_FONT_COLOR = "fffcc865" 

function TeamMatchDlg:SetGroupBtnTreeItemStyle(item, isParent)
    if not item then
        return
    end
    local fontSize = TASK_FONT_SIZE
    if not isParent then
        fontSize = 12  -- 设置子节点字体大小为 12
    end
    local text = item:getText()
    text = CEGUI.String(string.format("[font='simhei-%d'][colour='%s']%s[/colour][/font]", fontSize, TASK_FONT_COLOR, text))
    item:setText(text)
end

function TeamMatchDlg.getInstanceAndShow()
    if not _instance then
        _instance = TeamMatchDlg:new()
        _instance:OnCreate()
    else
        _instance:SetVisible(true)
    end

    return _instance
end

function TeamMatchDlg.getInstanceNotCreate()
    return _instance
end


function TeamMatchDlg.DestroyDialog()
    if _instance then
        NotificationCenter.removeObserver(Notifi_TeamListChange, TeamMatchDlg.onEventTeamListChange)
        NotificationCenter.removeObserver(Notifi_TeamSettingChange, TeamMatchDlg.onEventSettingChange)
        _instance:clearTeamList()
        gCommon.selectedTeamMatchActId = _instance.selectedActID
        if not _instance.m_bCloseIsHide then
            _instance:OnClose()
            _instance = nil
        else
            _instance:ToggleOpenClose()
        end
    end
end

function TeamMatchDlg.ToggleOpenClose()
    if not _instance then
        _instance = TeamMatchDlg:new()
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function TeamMatchDlg.GetLayoutFileName()
    return "teamshenqing.layout"
end

function TeamMatchDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, TeamMatchDlg)
    self.elapse = 0
    return self
end

function TeamMatchDlg:OnCreate()
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    self.winMgr = winMgr

    self.closeBtn = CEGUI.toPushButton(winMgr:getWindow('zidongpipei/bg/close'))
    self.btntree = CEGUI.toGroupBtnTree(winMgr:getWindow('zidongpipei/bg/tree'))
    self.content = CEGUI.toScrollablePane(winMgr:getWindow('zidongpipei/bg2/content'))
    self.createBtn = CEGUI.toPushButton(winMgr:getWindow('zidongpipei/bg/createbtn'))
    self.autoBtn = CEGUI.toPushButton(winMgr:getWindow('zidongpipei/bg/autobtn'))
    self.refreshBtn = CEGUI.toPushButton(winMgr:getWindow('zidongpipei/bg/refreshbtn'))
    self.matchingCount = winMgr:getWindow("zidongpipei/bg/dengdaipipei")

    self.closeBtn:subscribeEvent('Clicked', self.HandleCloseClicked, self)
    self.createBtn:subscribeEvent('Clicked', self.HandleCreateClicked, self)
    self.autoBtn:subscribeEvent('Clicked', self.HandleAutoClicked, self)
    self.refreshBtn:subscribeEvent('Clicked', self.HandleRefreshClicked, self)
    self.btntree:subscribeEvent("ItemSelectionChanged", TeamMatchDlg.HandleItemSelectionChanged, self)
    self.content:subscribeEvent("Drag", TeamMatchDlg.HandleContentDrag, self)
    self.content:subscribeEvent("ContentPaneScrolled", TeamMatchDlg.HandleContentScrolled, self)

    NotificationCenter.addObserver(Notifi_TeamListChange, TeamMatchDlg.onEventTeamListChange)
    NotificationCenter.addObserver(Notifi_TeamSettingChange, TeamMatchDlg.onEventSettingChange)

    if gCommon.selectedTeamMatchActId ~= 0 then
        self.selectedActID = gCommon.selectedTeamMatchActId
    else
        self.selectedActID =(GetTeamManager():IsMatching() and GetTeamManager():GetTeamMatchInfo().targetid or 0)
    end
    local guideIndex = getTeamGuideIndex()
    if guideIndex ~= 0 then
        self.selectedActID = guideIndex
        setTeamGuideIndex(0)
    end

    --init
    self.matchTeamList = {}
    self.matchTeamListCount = 0
    self.cells = {}
    self.lastTeamId = 0
    self.waitMatchImg = nil

    if GetTeamManager():IsMatching() then
        self.autoBtn:setText(MHSD_UTILS.get_resstring(10002)) --取消匹配
    end

    -- 显示活动树
    self:showTree()

    self:selecteActById(self.selectedActID)

    --请求队伍匹配和个人匹配数量
    local p = require("protodef.fire.pb.team.crequestmatchinfo"):new()
    LuaProtocolManager:send(p)
end

function TeamMatchDlg:selecteActById(actId)
    if not actId then
        return
    end

    self.autoBtn:setVisible(actId ~= 0)
    if actId == 0 then
        self:requestTeamList(actId)
        -- 全部
        return
    end

    local conf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("team.cteamlistinfo")):getRecorder(actId)
    if not conf then
        return
    end
    if not self.lv1Btns[conf.type] or not self.lv2Btns[conf.id] then
        return
    end

    self.btntree:SetLastSelectItem(self.lv2Btns[conf.id])
    self.btntree:SetLastOpenItem(self.lv1Btns[conf.type])
    self.btntree:initialise()

    local bar = self.btntree:getVertScrollbar()
    local offset = self.btntree:getHeightToItem(self.lv2Btns[conf.id])
    print('TeamMatchDlg selcteActById', offset, self.btntree:getPixelSize().height, self.lv2Btns[conf.id]:getItemSize().height)
    bar:Stop()
    if offset > self.btntree:getPixelSize().height - self.lv2Btns[conf.id]:getItemSize().height then
        bar:setScrollPosition(offset)
    end

    self:switchActivity(actId)
end

function TeamMatchDlg:showTree()
    local tmpdata = {}
    local groupdatas = {}
    local teamListInfo = BeanConfigManager.getInstance():GetTableByName(CheckTableName("team.cteamlistinfo"))
    local roleLevel = gGetDataManager():GetMainCharacterLevel()
    
    local ids = teamListInfo:getAllID()

    for i = 1, #ids do
        local conf = teamListInfo:getRecorder(ids[i])
        if conf.content ~= "" and conf.minlevel <= roleLevel and conf.maxlevel >= roleLevel then
            if tmpdata[conf.type] == nil then
                tmpdata[conf.type] = {}
                tmpdata[conf.type].childs = {}
                tmpdata[conf.type].content = conf.content
                tmpdata[conf.type].type = conf.type
                table.insert(groupdatas, tmpdata[conf.type])
            end
            table.insert(tmpdata[conf.type].childs, conf)
        end
    end
    ids = nil

    local allBtn = self.btntree:addItem(CEGUI.String(MHSD_UTILS.get_resstring(406)), 0) -- 全部
    SetGroupBtnTreeFirstIcon2(allBtn) --设置一级菜单样式
    self:SetGroupBtnTreeItemStyle(allBtn, true) 

    if self.selectedActID == 0 then
        self.btntree:SetLastSelectItem(allBtn)
        self.btntree:SetLastOpenItem(allBtn)
    end

    self.lv1Btns = {}
    self.lv2Btns = {}

    for k, v in pairs(groupdatas) do
        local firstBtn = self.btntree:addItem(CEGUI.String(v.content), -1)
        SetGroupBtnTreeFirstIcon2(firstBtn)
        self:SetGroupBtnTreeItemStyle(firstBtn, true)  -- 设置主节点样式
        self.lv1Btns[v.type] = firstBtn
        for _, conf in pairs(v.childs) do
            local secondBtn = firstBtn:addItem(CEGUI.String(conf.target), conf.id)
            SetGroupBtnTreeSecondIcon2(secondBtn)
            self:SetGroupBtnTreeItemStyle(secondBtn, false)  -- 设置子节点样式
            self.lv2Btns[conf.id] = secondBtn
            if conf.id == self.selectedActID then
                -- 默认选中第一个
                self.selectedActID = conf.id
                if not firstBtn:getIsOpen() then
                    firstBtn:toggleIsOpen()
                end
                self.btntree:SetLastSelectItem(secondBtn)
            end
            if GetTeamManager():IsMatching() and GetTeamManager():GetTeamMatchInfo().targetid == conf.id then
                self:addWaitImageToGroupBtnItem(secondBtn)
            end
        end
    end
end

function TeamMatchDlg:addWaitImageToGroupBtnItem(btnItem)
    if self.matchBtnItem then
        self.matchBtnItem:setOrnamentImage(nil)
    end
    self.matchBtnItem = btnItem
    local btnS = btnItem:getItemSize()
    local imgS = { width = 31, height = 32 }
    btnItem:setOrnamentImage(CEGUI.String("teamui"), CEGUI.String("team_deng"))
    btnItem:setOrnamentPosition(btnS.width - imgS.width - 10,(btnS.height - imgS.height) * 0.5)
end

function TeamMatchDlg:requestTeamList(actID)
    local p = require('protodef.fire.pb.team.crequestteammatchlist').Create()
    p.targetid = actID
    p.startteamid = self.lastTeamId
    p.num = 5 -- 一次请求5个
    LuaProtocolManager:send(p)
    print('request team match list, targetid:', p.targetid, 'startteamid:', p.startteamid, 'num:', p.num)
end

--matchlist: [TeamInfoBasicWithMembers]
function TeamMatchDlg:recvTeamMatchList(matchlist)
    print("recvTeamMatchList", #matchlist.teamlist, matchlist.targetid)
    if matchlist.targetid ~= self.selectedActID then
        return
    end

    for _, v in pairs(matchlist.teamlist) do
        local exist = false
        for i,info in pairs(self.matchTeamList) do
            if info.teaminfobasic.teamid == v.teaminfobasic.teamid then
                exist = true
                local cell = self.cells[i]
                if cell and cell.teaminfo.teaminfobasic.teamid == v.teaminfobasic.teamid then
                    cell:loadData(v)
                    self.matchTeamList[i] = v
                end
            end
        end

        if not exist then
            table.insert(self.matchTeamList, v)
        end
    end
    self:refreshTeamList()
end

-- 切换活动
function TeamMatchDlg:switchActivity(actID)
    print("TeamMatchDlg:switchActivity", actID)
    self.autoBtn:setVisible(actID ~= 0)
    if actID ~= 0 then
        if GetTeamManager():IsMatching() and GetTeamManager():GetTeamMatchInfo().targetid == actID then
            self.autoBtn:setText(MHSD_UTILS.get_resstring(10002)) -- 取消匹配
        else
            self.autoBtn:setText(MHSD_UTILS.get_resstring(10001)) -- 自动匹配
        end
    end

    self.selectedActID = actID
    self:clearTeamList()
    self:requestTeamList(self.selectedActID)
end

function TeamMatchDlg:SelecteItem(actID)
    print("TeamMatchDlg:SelecteItem")
    local teamListInfo = BeanConfigManager.getInstance():GetTableByName(CheckTableName("team.cteamlistinfo"))
    local conf = teamListInfo:getRecorder(actID)
    local firstBtn = self.lv1Btns[conf.type]
    if not firstBtn:getIsOpen() then
        firstBtn:toggleIsOpen()
    end
    self.btntree:SetLastSelectItem(self.lv2Btns[actID])
    self.autoBtn:setVisible(actID ~= 0)

    self.selectedActID = actID
    self:clearTeamList()
    self:requestTeamList(self.selectedActID)
end

function TeamMatchDlg:clearTeamList()
    if self.cells then
        for _, v in pairs(self.cells) do
            v:OnClose()
        end
    end
    self.cells = {}
    self.lastTeamId = 0
    self.matchTeamList = {}
    self.matchTeamListCount = 0
end

function TeamMatchDlg:refreshTeamList()
    if not GetTeamManager() then
        return
    end

    if #self.matchTeamList == 0 then
        return
    end

    -- 从上次的位置开始添加
    --matchlist: [TeamInfoBasicWithMembers]
    for i = self.matchTeamListCount, #self.matchTeamList -1 do
        local teaminfo = self.matchTeamList[i+1]
        local cell = TeamMatchCell.CreateNewDlg(self.content)
        cell:GetWindow():setPosition(CEGUI.UVector2(CEGUI.UDim(0, 1), CEGUI.UDim(0, i *(cell:GetWindow():getPixelSize().height + 5))))
        cell:loadData(teaminfo)
        table.insert(self.cells, cell)
        if i == #self.matchTeamList -1 then
            self.lastTeamId = teaminfo.teaminfobasic.teamid
        end
    end

    self.matchTeamListCount = #self.matchTeamList
end

function TeamMatchDlg:HandleCloseClicked(args)
    self.DestroyDialog()
    if TeamDialogNew.getInstanceNotCreate() then
        TeamDialogNew.getInstanceNotCreate():SetVisible(true)
    end
end

function TeamMatchDlg:HandleCreateClicked(args)
    self.DestroyDialog()
    GetTeamManager():RequestCreateTeam()

    if self.selectedActID ~= 0 then
        local conf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("team.cteamlistinfo")):getRecorder(self.selectedActID)
        if not conf then return end

        local p = require('protodef.fire.pb.team.crequestsetteammatchinfo').Create()
        p.targetid = self.selectedActID
        p.levelmin = conf.minlevel
        p.levelmax = conf.maxlevel
        LuaProtocolManager:send(p)
    end
end

function TeamMatchDlg:HandleAutoClicked(args)
    if self.selectedActID == 0 then
        return
    end

    if GetTeamManager():IsMatching() and GetTeamManager():GetTeamMatchInfo().targetid == self.selectedActID then
        self.autoBtn:setText(MHSD_UTILS.get_resstring(10001)) -- 自动匹配
        GetTeamManager():StopTeamMatch()
        if self.matchBtnItem then
            self.matchBtnItem:setOrnamentImage(nil)
            self.matchBtnItem = nil
        end
    else
        self.autoBtn:setText(MHSD_UTILS.get_resstring(10002)) -- 取消匹配
        local conf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("team.cteamlistinfo")):getRecorder(self.selectedActID)
        GetTeamManager():RequestTeamMatch(0, conf.id, conf.minlevel, conf.maxlevel)
    end
end

function TeamMatchDlg:HandleRefreshClicked(args)
    self:clearTeamList()
    self:requestTeamList(self.selectedActID)
end

function TeamMatchDlg:HandleItemSelectionChanged(args)
    local item = self.btntree:getSelectedItem()
    if not item then return end
    if item:getID() ~= self.selectedActID then
        self:switchActivity(item:getID())
    end
end

function TeamMatchDlg:HandleContentScrolled(args)
    if self.dataRequested then
        return
    end
    local bar = self.content:getVertScrollbar()
    local pageH = bar:getPageSize()
    local docH = math.max(bar:getDocumentSize(), pageH)
    if bar:getScrollPosition() > docH - pageH then
        self:requestTeamList(self.selectedActID)
        self.dataRequested = true
        print('request match list')
    end
end

function TeamMatchDlg:HandleContentDrag(args)
    local e = CEGUI.toGestureEventArgs(args)
    local state = e.d_Recognizer:GetState()
    if state == CEGUI.Gesture.GestureRecognizerStateBegan then
        self.dataRequested = false
    end
end

function TeamMatchDlg.onEventTeamListChange()
    if not _instance or not _instance:IsVisible() then
        return
    end
    if GetTeamManager():IsOnTeam() then
        _instance.toClose = true
        TeamDialogNew.getInstanceAndShow()
    end
end

function TeamMatchDlg.onEventSettingChange()
    if not _instance or not _instance:IsVisible() then
        return
    end
    local info = GetTeamManager():GetTeamMatchInfo()
    local groupBtnItem = _instance.lv2Btns[info.targetid]
    if groupBtnItem then
        if _instance.matchBtnItem and groupBtnItem ~= _instance.matchBtnItem then
            _instance.matchBtnItem:setOrnamentImage(nil)
        end
        _instance.matchBtnItem = groupBtnItem
        _instance:addWaitImageToGroupBtnItem(groupBtnItem)
    elseif _instance.matchBtnItem then
        _instance.matchBtnItem:setOrnamentImage(nil)
        _instance.matchBtnItem = nil
    end
end

function TeamMatchDlg:recvMatchingCountInfo(teamcount, playercount)
    local str = self.matchingCount:getText()
    str = string.gsub(str, "(%D*)%d+(%D*)%d+(%D*)", "%1" .. teamcount .. "%2" .. playercount .. "%3")
    self.matchingCount:setText(str)
end

function TeamMatchDlg:update(delta)
    if self.toClose then
        TeamMatchDlg.DestroyDialog()
        return
    end

    self.elapse = self.elapse + delta
    if self.elapse > 10000 then -- 10s
        self.elapse = 0
        local p = require("protodef.fire.pb.team.crequestmatchinfo"):new()
        LuaProtocolManager:send(p)
    end
end

return TeamMatchDlg
