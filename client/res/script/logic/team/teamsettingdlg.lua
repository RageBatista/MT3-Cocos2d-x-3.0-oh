require "logic.dialog"
require "utils.commonutil"
require "utils.mhsdutils"

TeamSettingDlg = { }
setmetatable(TeamSettingDlg, Dialog)
TeamSettingDlg.__index = TeamSettingDlg

local ROW_H = 50
local NO_TARGET = 0		-- 不选择目标

local MAIN_FONT_SIZE = 13 
local SUB_FONT_SIZE = 12

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance
function TeamSettingDlg.getInstance()
    if not _instance then
        _instance = TeamSettingDlg:new()
        _instance:OnCreate()
    end

    return _instance
end

function TeamSettingDlg.getInstanceAndShow()
    if not _instance then
        _instance = TeamSettingDlg:new()
        _instance:OnCreate()
    else
        _instance:SetVisible(true)
    end

    return _instance
end

function TeamSettingDlg.getInstanceNotCreate()
    return _instance
end


function TeamSettingDlg.DestroyDialog()
    if _instance then
        if not _instance.m_bCloseIsHide then
            _instance:OnClose()
            _instance = nil
        else
            _instance:ToggleOpenClose()
        end
    end
end

function TeamSettingDlg.ToggleOpenClose()
    if not _instance then
        _instance = TeamSettingDlg:new()
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function TeamSettingDlg.GetLayoutFileName()
    return "teamshezhi.layout"
end

function TeamSettingDlg:new()
    local self = { }
    self = Dialog:new()
    setmetatable(self, TeamSettingDlg)
    return self
end

function TeamSettingDlg:SetGroupBtnTreeItemStyle(item, isParent)
    if not item then
        return
    end

    local fontSize = SUB_FONT_SIZE  
    if isParent then
        fontSize = MAIN_FONT_SIZE   
    end
    
    local text = item:getText()
    text = CEGUI.String(string.format("[font='simhei-%d'][colour='ffffffff']%s[/colour][/font]", fontSize, text))
    item:setText(text)
end

function TeamSettingDlg:OnCreate()
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    self.winMgr = winMgr
	
	self.m_ccteamck = winMgr:getWindow("teamshezhi/team/shezhi")
    local aniMan = CEGUI.AnimationManager:getSingleton()
    local animationOpen = aniMan:getAnimation("FrameWindow3ani") 
    self.animationInstance = aniMan:instantiateAnimation(animationOpen) 
    self.animationInstance:setTargetWindow(self.m_ccteamck)
    self.animationInstance:start()

    self.minLevelList = winMgr:getWindow('teamshezhi/team/shezhi/listcontainer1')
    self.maxLevelList = winMgr:getWindow('teamshezhi/team/shezhi/listcontainer2')
    self.closeBtn = CEGUI.toPushButton(winMgr:getWindow('teamshezhi/team/shezhi/close'))
    self.btntree = CEGUI.toGroupBtnTree(winMgr:getWindow('teamshezhi/team/shezhi/xingdongmubiao'))
    self.autoBtn = CEGUI.toCheckbox(winMgr:getWindow('teamshezhi/team/shezhi/autobtn'))
    self.okBtn = CEGUI.toPushButton(winMgr:getWindow('teamshezhi/team/OK'))
    self.joinRequest = CEGUI.toRichEditbox(winMgr:getWindow('teamshezhi/team/dibang/tiaojianwenben'))
    self.openTime = CEGUI.toRichEditbox(winMgr:getWindow('teamshezhi/team/dibang/shijianwenben'))
    self.focusBar = winMgr:getWindow('teamshezhi/team/shezhi/focusbox')

    self.closeBtn:subscribeEvent('Clicked', self.handleCloseClicked, self)
    self.okBtn:subscribeEvent('Clicked', self.handleOkClicked, self)
    self.btntree:subscribeEvent("ItemSelectionChanged", self.handleItemSelectionChanged, self)

    self.alldata = nil
    -- 所有的活动数据， val:CTeamListInfo
    local matchInfo = GetTeamManager():GetTeamMatchInfo()
    self.selectedActID = matchInfo.targetid
    -- NO_TARGET
    self.autoBtn:setVisible(self.selectedActID ~= NO_TARGET)

    self.emptyCellCount = math.ceil((self.minLevelList:getPixelSize().height-ROW_H)*0.5 / ROW_H)
    self.halfLength = self.minLevelList:getPixelSize().height*0.5

    self.cellWidth = self.minLevelList:getPixelSize().width - 20
    self.minLevelList:setID(1)
    self.maxLevelList:setID(2)
    self.tableviews = { }

    self:showTree()
    self:showLevelList()
end

function TeamSettingDlg:showTree()
    local setting = GetTeamManager():GetTeamMatchInfo()
    self.selectedActID = setting.targetid
    self.alldata = { }
    local tmpdata = { }
    local groupdatas = { }
    local teamListInfo = BeanConfigManager.getInstance():GetTableByName(CheckTableName("team.cteamlistinfo"))
    local roleLevel = gGetDataManager():GetMainCharacterLevel()
    local ids = teamListInfo:getAllID()
    for i = 1, #ids  do
        local conf = teamListInfo:getRecorder(ids[i])
        if conf.content ~= "" and conf.minlevel <= roleLevel and conf.maxlevel >= roleLevel then
            self.alldata[conf.id] = conf
            if tmpdata[conf.type] == nil then
                tmpdata[conf.type] = { }
                tmpdata[conf.type].childs = { }
                tmpdata[conf.type].content = conf.content
                tmpdata[conf.type].type = conf.type
                table.insert(groupdatas, tmpdata[conf.type])
            end
            table.insert(tmpdata[conf.type].childs, conf)
        end
    end
    ids = nil

    -- 无目标
    local noneBtn = self.btntree:addItem(CEGUI.String(MHSD_UTILS.get_resstring(3148)), NO_TARGET)
    SetGroupBtnTreeFirstIcon2(noneBtn)
	self:SetGroupBtnTreeItemStyle(noneBtn, true) 
    if self.selectedActID == NO_TARGET then
        self.btntree:SetLastSelectItem(noneBtn)
        self.btntree:SetLastOpenItem(noneBtn)
    end
    self.lv1Btns = { }
    self.lv2Btns = { }

    for k, v in pairs(groupdatas) do
        local firstBtn = self.btntree:addItem(CEGUI.String(v.content), -1)
        SetGroupBtnTreeFirstIcon2(firstBtn)
		self:SetGroupBtnTreeItemStyle(firstBtn, true)
        self.lv1Btns[v.type] = firstBtn
        for _, conf in pairs(v.childs) do
            local secondBtn = firstBtn:addItem(CEGUI.String(conf.target), conf.id)
            self.lv2Btns[conf.id] = secondBtn
            SetGroupBtnTreeSecondIcon2(secondBtn)
			self:SetGroupBtnTreeItemStyle(secondBtn, false)
            if conf.id == self.selectedActID then
                self.btntree:SetLastSelectItem(secondBtn)
                self.btntree:SetLastOpenItem(firstBtn)

                if conf.id ~= NO_TARGET and GetTeamManager():IsMatching() then
                    self.autoBtn:setSelected(true)
                end
            end
        end
    end
end

function TeamSettingDlg:addRows(wnd, minlevel, maxlevel, showlevel)
    local id = wnd:getID()
    local s = wnd:getPixelSize()
    if not self.tableviews[id] then
        local t = TableView.create(wnd)
        t:setViewSize(self.cellWidth, s.height)
        t:setPosition(0, 0)
        t:setDataSourceFunc(self, TeamSettingDlg.tableViewGetCellAtIndex)
        t.scroll:getVertScrollbar():subscribeEvent("SlideStopped", TeamSettingDlg.handleScrollMoveStoped, self)
        t.scroll:subscribeEvent("ContentPaneScrolled", TeamSettingDlg.handleContentScrolled, self)
        t.scroll:setID(id)
        t.scroll:getVertScrollbar():setID(id)
        self.tableviews[id] = t
    end
    self.tableviews[id].minlevel = minlevel
    self.tableviews[id]:setCellCount(maxlevel - minlevel + 1 + 2*self.emptyCellCount)
    local offset = (self.emptyCellCount + showlevel - minlevel) * ROW_H - self.halfLength
    self.tableviews[id]:setContentOffset(self:getFinalOffset(offset))
    self.tableviews[id]:reloadData()
end

function TeamSettingDlg:tableViewGetCellAtIndex(tableView, idx, cell)
    if not cell then
        cell = { }
        cell.window = self.winMgr:createWindow("TaharezLook/StaticText")
        cell.window:setSize(CEGUI.UVector2(CEGUI.UDim(0, self.cellWidth), CEGUI.UDim(0, ROW_H)))
        cell.window:setFont("simhei-12")
        cell.window:setProperty("BackgroundEnabled", "False")
        cell.window:setProperty("FrameEnabled", "False")
        cell.window:setProperty("HorzFormatting", "HorzCentred")
        cell.window:setProperty("VertFormatting", "VertCentred")
        cell.window:setProperty("MousePassThroughEnabled", "True")
        cell.window:setProperty("AlwaysOnTop", "True")
        cell.window:setProperty("TextColours", "ff553923")
    end

    if idx < self.emptyCellCount or idx >= tableView.cellCount - self.emptyCellCount then
        cell.window:setText("")
    else
        cell.window:setText(tableView.minlevel + idx - self.emptyCellCount)
    end
    return cell
end

function TeamSettingDlg:getFinalOffset(curOffset)
    curOffset = math.max(self.minOffset, math.min(self.maxOffset, curOffset))

    local p = curOffset + self.halfLength
    if p % ROW_H <= ROW_H * 0.5 then
        p = p + (ROW_H * 0.5 - p % ROW_H)
    else
        p = p - (p % ROW_H - ROW_H * 0.5)
    end
    return math.floor(p - self.halfLength)
end

function TeamSettingDlg:handleScrollMoveStoped(args)
    local bar = CEGUI.toScrollbar(CEGUI.toWindowEventArgs(args).window)
    local p = bar:getScrollPosition()
    bar:setScrollPosition(self:getFinalOffset(p))
end

function TeamSettingDlg:updateNumbersAlpha(numTableView)
    local baseY = self.minLevelList:GetScreenPos().y
    local centerTop = self.minLevelList:getPixelSize().height * 0.5 - ROW_H * 0.5
    local centerBottom = centerTop + ROW_H
    local distance = centerTop
    local numbers = numTableView.visibleCells
    for _, v in pairs(numbers) do
        local y = v.window:GetScreenPosOfCenter().y - baseY
        if y < centerTop then
            local a = ((y+ROW_H*0.5) / distance)^2
            v.window:setAlpha(math.min(1, a))
        elseif y > centerBottom then
            local a = ((distance -(y - centerBottom)+ROW_H*0.5) / distance)^2
            v.window:setAlpha(math.min(1, a))
        else
            v.window:setAlpha(1)
        end
    end
end

function TeamSettingDlg:handleContentScrolled(args)
    local id = CEGUI.toWindowEventArgs(args).window:getID()
    self:updateNumbersAlpha(self.tableviews[id])
end

function TeamSettingDlg:selecteActById(actId)
    if not actId then
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
    bar:Stop()
    bar:setScrollPosition(offset)

    self.selectedActID = actId
    self:showLevelList()
    self.autoBtn:setVisible(self.selectedActID ~= NO_TARGET)
    self.autoBtn:setSelected(self.selectedActID ~= NO_TARGET)
end

function TeamSettingDlg:showLevelList()
    local minlevel = 109
    local maxlevel = 300
    local showmin = 103
    local showmax = 300

    local teaminfo = self.alldata[self.selectedActID]
    if teaminfo then
        minlevel = teaminfo.minlevel
        maxlevel = teaminfo.maxlevel
        self.joinRequest:setText(teaminfo.requirement)
        self.openTime:setText(teaminfo.opentime)
    end

    local setting = GetTeamManager():GetTeamMatchInfo()
    if setting.targetid == self.selectedActID then
        showmin = setting.minlevel
        showmax = setting.maxlevel
    elseif teaminfo then
        -- 默认等级限制：最低等级=玩家当前等级-5，最高等级=玩家当前等级+5
        local roleLevel = gGetDataManager():GetMainCharacterLevel()
        showmin = math.max(minlevel, roleLevel - 130)
        showmin = math.min(showmin, maxlevel)
        showmax = math.max(showmin, roleLevel + 175)
        showmax = math.min(showmax, maxlevel)
    end

    self.minOffset = (self.emptyCellCount + 0.5) * ROW_H - self.halfLength
    self.maxOffset = (self.emptyCellCount + maxlevel - minlevel + 0.5) * ROW_H - self.halfLength

    self:addRows(self.minLevelList, minlevel, maxlevel, showmin)
    self:addRows(self.maxLevelList, minlevel, maxlevel, showmax)

    self:updateNumbersAlpha(self.tableviews[1])
    self:updateNumbersAlpha(self.tableviews[2])
end

function TeamSettingDlg:getLevelRange()
    local minlevel = math.floor(self.tableviews[1].scroll:getVertScrollbar():getScrollPosition() / ROW_H) + self.tableviews[1].minlevel
    local maxlevel = math.floor(self.tableviews[2].scroll:getVertScrollbar():getScrollPosition() / ROW_H) + self.tableviews[2].minlevel
    return math.min(minlevel, maxlevel), math.max(minlevel, maxlevel)
end

function TeamSettingDlg:handleCloseClicked(args)
    self.DestroyDialog()
    if TeamDialogNew.getInstanceNotCreate() then
        TeamDialogNew.getInstanceAndShow()
    end
end

function TeamSettingDlg:handleOkClicked(args)

    local minlevel, maxlevel = self:getLevelRange()
    print('level range', minlevel, maxlevel)
    if self.selectedActID == NO_TARGET then
        local matchInfo = GetTeamManager():GetTeamMatchInfo()
        matchInfo.targetid = self.selectedActID
        matchInfo.minlevel = minlevel
        matchInfo.maxlevel = maxlevel
        if GetTeamManager():IsMatching() then
            GetTeamManager():StopTeamMatch()
        end

        local p = require('protodef.fire.pb.team.crequestsetteammatchinfo').Create()
        p.targetid = self.selectedActID
        p.levelmin = minlevel
        p.levelmax = maxlevel
        print('team setting:', p.targetid, p.levelmin, p.levelmax)
        LuaProtocolManager:send(p)

        if TeamDialogNew.getInstanceNotCreate() then
            TeamDialogNew.getInstanceNotCreate():refreshTeamSetting()
        end
    else
        if self.autoBtn:isSelected() then
            -- 自动匹配
            GetTeamManager():RequestTeamMatch(1, self.selectedActID, minlevel, maxlevel)
        else
            -- 队伍设置
            if GetTeamManager():IsMatching() then
                GetTeamManager():StopTeamMatch()
            end
            local p = require('protodef.fire.pb.team.crequestsetteammatchinfo').Create()
            p.targetid = self.selectedActID
            p.levelmin = minlevel
            p.levelmax = maxlevel
            print('team setting:', p.targetid, p.levelmin, p.levelmax)
            LuaProtocolManager:send(p)
        end
    end

    self.DestroyDialog()
    if TeamDialogNew.getInstanceNotCreate() then
        TeamDialogNew.getInstanceAndShow()
    end
end

function TeamSettingDlg:handleItemSelectionChanged(args)
    local item = self.btntree:getSelectedItem()
    if not item then return end
    if self.selectedActID ~= item:getID() then
        self.selectedActID = item:getID()
        self:showLevelList()
        self.autoBtn:setVisible(self.selectedActID ~= NO_TARGET)
        self.autoBtn:setSelected(self.selectedActID ~= NO_TARGET)
    end
end

return TeamSettingDlg
