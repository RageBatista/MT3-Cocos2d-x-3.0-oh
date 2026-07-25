require "logic.dialog"
require "protodef.fire.pb.ranklist.crequestranklist"
require "protodef.rpcgen.fire.pb.ranklist.clanfighthistroyrank"
require "logic.family.familyduizhencell"
 

local FIRST_COLOR = "[colrect='tl:FFFFFEF1 tr:FFFFFEF1 bl:FFF4D751 br:FFF4D751']"

FamilyRankType = {
    FamilyRankType_DunZhen = 1,
    FamilyRankType_Rank = 2,
    FamilyRankType_History = 3
}

familyfight = {}
setmetatable(familyfight, Dialog)
familyfight.__index = familyfight

local _instance
function familyfight.getInstance()
	if not _instance then
		_instance = familyfight:new()
		_instance:OnCreate()
	end
	return _instance
end

function familyfight.getInstanceAndShow()
	if not _instance then
		_instance = familyfight:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function familyfight.getInstanceNotCreate()
	return _instance
end

function familyfight.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
		
		    if _instance.m_dunZhenTable then
                _instance.m_dunZhenTable:destroyCells()
            end 
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function familyfight.ToggleOpenClose()
	if not _instance then
		_instance = familyfight:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function familyfight.GetLayoutFileName()
	return "gongzhanpaiming_mtg.layout"
end

function familyfight:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, familyfight)
	return self
end

function familyfight:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
    self.m_mainTitle = CEGUI.toFrameWindow(winMgr:getWindow("gongzhanpaiming_mtg"))
    self.m_pTree = CEGUI.toGroupBtnTree(winMgr:getWindow("gongzhanpaiming_mtg/btntree"))
    self.m_pMainHistory = CEGUI.toMultiColumnList(winMgr:getWindow("gongzhanpaiming_mtg/3/di3/mu3"))

    self.m_dunZhenBtn = CEGUI.toGroupButton(winMgr:getWindow("gongzhanpaiming_mtg/g1"))
    self.m_rankBtn = CEGUI.toGroupButton(winMgr:getWindow("gongzhanpaiming_mtg/g2"))
    self.m_historyBtn = CEGUI.toGroupButton(winMgr:getWindow("gongzhanpaiming_mtg/g3"))

    self.m_infoBtn = CEGUI.toPushButton(winMgr:getWindow("gongzhanpaiming_mtg/btnzhiyin"))
    self.m_enterBtn = CEGUI.toPushButton(winMgr:getWindow("gongzhanpaiming_mtg/1/enter"))

    self.m_textinfo = winMgr:getWindow("gongzhanpaiming_mtg/text")
    self.m_textinfo2 = CEGUI.toRichEditbox(winMgr:getWindow("gongzhanpaiming_mtg/text2"))

    self.m_win1 = winMgr:getWindow("gongzhanpaiming_mtg/1")
    self.m_win2 = winMgr:getWindow("gongzhanpaiming_mtg/2")

    local frameWnd = CEGUI.toFrameWindow(winMgr:getWindow("gongzhanpaiming_mtg"))
    self.m_CloseBtn = CEGUI.toPushButton(frameWnd:getCloseButton())
	self.m_CloseBtn:subscribeEvent("MouseClick", familyfight.OnCloseBtnEx, self)

    self.m_pTree:subscribeEvent("ItemSelectionChanged", familyfight.HandleSelectRank, self)
    self.m_dunZhenBtn:subscribeEvent("MouseClick", familyfight.OndunZhenBtnEx, self)
    self.m_rankBtn:subscribeEvent("MouseClick", familyfight.OnRankBtnEx, self)
    self.m_historyBtn:subscribeEvent("MouseClick", familyfight.OnHistoryBtnEx, self)
    self.m_infoBtn:subscribeEvent("MouseClick", familyfight.OnInfoBtnEx, self)
    self.m_enterBtn:subscribeEvent("MouseClick", familyfight.OnEnterBtnEx, self)

    self.m_pMainRankBg = winMgr:getWindow("gongzhanpaiming_mtg/2/di2")
    self.m_pMainDunZhenBg = winMgr:getWindow("gongzhanpaiming_mtg/1/di3")
    self.m_pMainHistoryBg =  winMgr:getWindow("gongzhanpaiming_mtg/3/di3")
    self.m_pMainDunZhen = CEGUI.Window.toMultiColumnList(winMgr:getWindow("gongzhanpaiming_mtg/1/di3/mu1"))
    self.m_pMainRank = CEGUI.Window.toMultiColumnList(winMgr:getWindow("gongzhanpaiming_mtg/2/di2/mu2"))
    self.m_pMainRankEnded = CEGUI.Window.toMultiColumnList(winMgr:getWindow("gongzhanpaiming_mtg/2/di2/mu21"))
    

    self.m_pMainRank:setUserSortControlEnabled(false)
    self.m_pMainRankEnded:setUserSortControlEnabled(false)
    self.m_pMainDunZhen:setUserSortControlEnabled(false)
    self.m_pMainHistory:setUserSortControlEnabled(false)
    --self.m_pMainDunZhen:subscribeEvent("NextPage", familyfight.HandleNextPage, self)
    self.m_pMainHistory:subscribeEvent("NextPage", familyfight.HandleNextPage, self)
    self.m_pMainRank:subscribeEvent("NextPage", familyfight.HandleNextPage, self)
    self.m_pMainRankEnded:subscribeEvent("NextPage", familyfight.HandleNextPage, self)
    --self.m_pMainHistory:subscribeEvent("SelectionChanged", RankingList.HandleListMemberSelected, self)
    self.m_item1Btn = CEGUI.toGroupButton(winMgr:getWindow("gongzhanpaiming_mtg/btntree/item1"))
    self.m_item1Btn:subscribeEvent("MouseClick", familyfight.OnItem1BtnEx, self)
    self.m_item1BtnImg = winMgr:getWindow("gongzhanpaiming_mtg/btntree/item1/img1")
    self.m_item1BtnImg:setProperty("Image","set:shopui image:yiwancheng")
    self.m_item1BtnImg:setVisible(false)

    self.m_item2Btn = CEGUI.toGroupButton(winMgr:getWindow("gongzhanpaiming_mtg/btntree/item2"))
    self.m_item2Btn:subscribeEvent("MouseClick", familyfight.OnItem2BtnEx, self)
    self.m_item2BtnImg = winMgr:getWindow("gongzhanpaiming_mtg/btntree/item2/img2")
    self.m_item2BtnImg:setProperty("Image","set:shopui image:yiwancheng")
    self.m_item2BtnImg:setVisible(false)

    self.m_itemCurBtn = CEGUI.toPushButton(winMgr:getWindow("gongzhanpaiming_mtg/btntree/item3"))
    self.m_itemCurBtn:subscribeEvent("MouseClick", familyfight.OnCurBtnEx, self)
    self.m_itemCurBtn:setVisible(false)

    self.m_rankBangWai = winMgr:getWindow("gongzhanpaiming_mtg/mu2/bangwai")
    self.m_rankBangWaiWidth = self.m_rankBangWai:getWidth().offset
    self.m_rankBangWaiParams = { };
    self.m_rankBangWaiParams[1] = winMgr:getWindow("gongzhanpaiming_mtg/mu2/bangwai/canshu1")
    self.m_rankBangWaiParams[2] = winMgr:getWindow("gongzhanpaiming_mtg/mu2/bangwai/canshu2")
    self.m_rankBangWaiParams[3] = winMgr:getWindow("gongzhanpaiming_mtg/mu2/bangwai/canshu3")
    self.m_rankBangWaiParams[4] = winMgr:getWindow("gongzhanpaiming_mtg/mu2/bangwai/canshu4")
    self.m_rankBangWaiParams[5] = winMgr:getWindow("gongzhanpaiming_mtg/mu2/bangwai/canshu5")

    self.m_rankBangWaiEnded = winMgr:getWindow("gongzhanpaiming_mtg/mu2/bangwai1")
    self.m_rankBangWaiWidthEnded = self.m_rankBangWaiEnded:getWidth().offset
    self.m_rankBangWaiParamsEnded = { };
    self.m_rankBangWaiParamsEnded[1] = winMgr:getWindow("gongzhanpaiming_mtg/mu2/bangwai/canshu11")
    self.m_rankBangWaiParamsEnded[2] = winMgr:getWindow("gongzhanpaiming_mtg/mu2/bangwai/canshu21")
    self.m_rankBangWaiParamsEnded[3] = winMgr:getWindow("gongzhanpaiming_mtg/mu2/bangwai/canshu31")
    self.m_rankBangWaiParamsEnded[4] = winMgr:getWindow("gongzhanpaiming_mtg/mu2/bangwai/canshu41")

    self.m_historyBangWai = winMgr:getWindow("gongzhanpaiming_mtg/mu3/historybangwai")
    self.m_historyBangWaiWidth = self.m_historyBangWai:getWidth().offset
    self.m_historyBangWaiParams = { };
    self.m_historyBangWaiParams[1] = winMgr:getWindow("gongzhanpaiming_mtg/mu3/historybangwai/hcanshu1")
    self.m_historyBangWaiParams[2] = winMgr:getWindow("gongzhanpaiming_mtg/mu3/historybangwai/hcanshu2")
    self.m_historyBangWaiParams[3] = winMgr:getWindow("gongzhanpaiming_mtg/mu3/historybangwai/hcanshu3")
    self.m_historyBangWaiParams[4] = winMgr:getWindow("gongzhanpaiming_mtg/mu3/historybangwai/hcanshu4")
    self.m_historyBangWaiParams[5] = winMgr:getWindow("gongzhanpaiming_mtg/mu3/historybangwai/hcanshu5")
    self.m_historyBangWaiParams[6] = winMgr:getWindow("gongzhanpaiming_mtg/mu3/historybangwai/hcanshu6")
	
	
	self.m_historyRankClearTip     = winMgr:getWindow("gongzhanpaiming_mtg/3/di3/qingling")
	self.m_historyRankClearTip    :setVisible(false) 

    self.m_dunzhenImg = winMgr:getWindow("gongzhanpaiming_mtg/1/di3/mu1/wujilu")
    self.m_rankImg = winMgr:getWindow("gongzhanpaiming_mtg/1/di3/mu1/wujilu1")
    self.m_rankCurImg = winMgr:getWindow("gongzhanpaiming_mtg/1/di3/mu1/wujilu2")
    self.m_historyImg = winMgr:getWindow("gongzhanpaiming_mtg/1/di3/mu1/wujilu21")
    self.m_dunzhenImg:setVisible(false)
    self.m_rankImg:setVisible(false)
    self.m_rankCurImg:setVisible(false)
    self.m_historyImg:setVisible(false)

    self.m_curType = FamilyRankType.FamilyRankType_DunZhen
    self:InitInterface()
    self.m_pTree:invalidate()
    self.m_FontText = "simhei-12"
    self.m_dunZhenBtn:setSelected(true)
    self.m_iCurPage = 0
    self.m_bHasMore = false
    self.m_iCurRankType = 0
    self:InitTimeInfo()
    self.m_curTime = nil
    self.m_isover = 0

    self.m_curWeek = nil  --当前轮数
	--当前时间
	local time = StringCover.getTimeStruct(gGetServerTime() / 1000)
	--计算星期
	local curWeekDay = time.tm_wday
	if curWeekDay <= 2 then
		self.m_curSubType = RankType.CLAN_FIGHT_2
	else
		self.m_curSubType = RankType.CLAN_FIGHT_4
	end
    self.m_SelectEntryIndex = 0
    self.m_dunZhenTable = nil
    self.m_dunZhenList = nil
	
	
	
	--清理榜时间
	local p = require "protodef.fire.pb.clan.fight.cgetcleartime":new()   
    require "manager.luaprotocolmanager":send(p)
end

function familyfight:NoRank()
    self.m_rankBangWai:setVisible(false)
    self.m_rankBangWaiParams[1]:setText("")
    self.m_rankBangWaiParams[2]:setText("")
    self.m_rankBangWaiParams[3]:setText("")
    self.m_rankBangWaiParams[4]:setText("")
    self.m_rankBangWaiParams[5]:setText("")

    self.m_historyBangWai:setVisible(false)
    self.m_historyBangWaiParams[1]:setText("")
    self.m_historyBangWaiParams[2]:setText("")
    self.m_historyBangWaiParams[3]:setText("")
    self.m_historyBangWaiParams[4]:setText("")
    self.m_historyBangWaiParams[5]:setText("")
    self.m_historyBangWaiParams[6]:setText("")

    self.m_rankBangWaiEnded:setVisible(false)
    self.m_rankBangWaiParamsEnded[1]:setText("")
    self.m_rankBangWaiParamsEnded[2]:setText("")
    self.m_rankBangWaiParamsEnded[3]:setText("")
    self.m_rankBangWaiParamsEnded[4]:setText("")

end


--初始化时间显示
function familyfight:InitTimeInfo()
    --当前时间
	local time = StringCover.getTimeStruct(gGetServerTime() / 1000)

    local yearCur = time.tm_year + 1900
	local monthCur = time.tm_mon + 1
	local dayCur = tonumber(time.tm_mday)
    local darWeek =tonumber(time.tm_wday)
    local hour =  tonumber(time.tm_hour)
    local minute = tonumber(time.tm_min)  
	
    local dateTime,dateTime1 = self:GetDateByWeek(darWeek)
    self.m_item1Btn:setText(tostring(dateTime1))
    self.m_item2Btn:setText(tostring(dateTime))
	
    if darWeek <= 2 then
        self.m_item1Btn:setSelected(true)
		self.m_curSubType = RankType.CLAN_FIGHT_2
    else
        self.m_item2Btn:setSelected(true)
		self.m_curSubType = RankType.CLAN_FIGHT_4
    end
	
	local actendtimehour = 22
	local actendtimemin  = 0
	local actScheculed = BeanConfigManager.getInstance():GetTableByName("timer.cscheculedactivity"):getRecorder(281001)
    if actScheculed~= nil then
		local phour, pmin = string.match(actScheculed.endTime, "(%d+):(%d+):(%d+)")
		actendtimehour =tonumber(phour)  
		actendtimemin =tonumber(pmin)  
	end
	
	if darWeek > 2 then
		self.m_item1BtnImg:setVisible(true)
	elseif  darWeek == 2  and hour >= actendtimehour and minute > actendtimemin then
		self.m_item1BtnImg:setVisible(true)
	else 
	    self.m_item1BtnImg:setVisible( false )
	end
	if darWeek > 4 then
		self.m_item2BtnImg:setVisible(true)
 	elseif darWeek == 4 and  hour >= actendtimehour and minute > actendtimemin then
		self.m_item2BtnImg:setVisible(true)
	else 
	    self.m_item2BtnImg:setVisible( false )
	end
end


function familyfight:InitInterface()
    if self.m_curType == FamilyRankType.FamilyRankType_Rank then
        self.m_pMainRankBg:setVisible(true)
        self.m_pMainDunZhenBg:setVisible(false)
        self.m_pMainHistoryBg:setVisible(false)
    elseif self.m_curType == FamilyRankType.FamilyRankType_DunZhen then
        self.m_pMainRankBg:setVisible(false)
        self.m_pMainDunZhenBg:setVisible(true)
        self.m_pMainHistoryBg:setVisible(false)
    elseif self.m_curType == FamilyRankType.FamilyRankType_History then
        self.m_pMainRankBg:setVisible(false)
        self.m_pMainDunZhenBg:setVisible(false)
        self.m_pMainHistoryBg:setVisible(true)
    else
        --
    end
    self.m_textinfo:setVisible(true)
    self.m_textinfo2:setVisible(false)
end

function familyfight:HandleNextPage(args)
    LogInfo("RankingList handle next page")
    if self.m_bHasMore then

        self.m_iCurPage = self.m_iCurPage + 1

        local curlistview =nil
        if self.m_curType == FamilyRankType.FamilyRankType_Rank then
            if self.m_curSubType ~= RankType.CLAN_FIGHT_WEEK then
                curlistview = self.m_pMainRankEnded
            else
                curlistview = self.m_pMainRank
            end
        elseif self.m_curType == FamilyRankType.FamilyRankType_DunZhen then
            --curlistview = self.m_pMainDunZhen
        elseif self.m_curType == FamilyRankType.FamilyRankType_History then
            curlistview = self.m_pMainHistory
        end

        local BarPos = curlistview:getVertScrollbar():getScrollPosition()
        curlistview:getVertScrollbar():Stop()
        curlistview:getVertScrollbar():setScrollPosition(BarPos)

        local req = CRequestRankList.Create()
        req.ranktype = self.m_iRankType
        req.page = self.m_iCurPage
        LuaProtocolManager.getInstance():send(req)
    end
    return true
end

function familyfight:OnItem1BtnEx(args)
    if self.m_curSubType ~= RankType.CLAN_FIGHT_2 then
        self:SendRankReq(RankType.CLAN_FIGHT_2) --周二场次
        self.m_curSubType = RankType.CLAN_FIGHT_2
        self.m_iRankType = RankType.CLAN_FIGHT_2
        self.m_item1Btn:setSelected(true)
        if self.m_curType == FamilyRankType.FamilyRankType_Rank then
            self.m_pMainRank:setVisible(false)
            self.m_pMainRankEnded:setVisible(true)
			self.m_dunzhenImg:setVisible(false)	
		else
            self.m_dunzhenImg:setVisible(true)		
        end
    end
end

function familyfight:OnItem2BtnEx(args)
    if self.m_curSubType ~= RankType.CLAN_FIGHT_4 then
        self:SendRankReq(RankType.CLAN_FIGHT_4) --周四场次
        self.m_curSubType = RankType.CLAN_FIGHT_4
        self.m_iRankType = RankType.CLAN_FIGHT_4
        self.m_item2Btn:setSelected(true)
        if self.m_curType == FamilyRankType.FamilyRankType_Rank then
            self.m_pMainRank:setVisible(false)
            self.m_pMainRankEnded:setVisible(true)
        	self.m_dunzhenImg:setVisible(false)	
		else
            self.m_dunzhenImg:setVisible(true)		
        end
    end
end

function familyfight:OnCurBtnEx(args)
    if self.m_curSubType ~= RankType.CLAN_FIGHT_WEEK then
        self:SendRankReq(RankType.CLAN_FIGHT_WEEK) --本轮统计
        self.m_curSubType = RankType.CLAN_FIGHT_WEEK
        self.m_iRankType = RankType.CLAN_FIGHT_WEEK
        if self.m_curType == FamilyRankType.FamilyRankType_Rank then
            self.m_pMainRank:setVisible(true)
            self.m_pMainRankEnded:setVisible(false)
        end
    end
end

function familyfight:SendRankReq(ranktype)
    if self.m_curType == FamilyRankType.FamilyRankType_DunZhen then
         local p = require "protodef.fire.pb.clan.fight.cgetclanfightlist":new()
         p.whichweek = -1
         if ranktype == RankType.CLAN_FIGHT_2 then
            p.which = 0
         elseif ranktype == RankType.CLAN_FIGHT_4 then
            p.which = 1
         else
            p.which = -1
         end
         require "manager.luaprotocolmanager":send(p)
         if self.m_dunZhenTable then
            self.m_dunZhenList = {}
            self.m_dunZhenTable:setCellCount(0)
            self.m_dunZhenTable:reloadData()
         end
    else
        local req = CRequestRankList.Create()
        req.ranktype = ranktype     --本轮统计
        req.page = 0
	    require "manager.luaprotocolmanager":send(req)
        self.m_iCurPage = 0
         if self.m_curSubType == RankType.CLAN_FIGHT_WEEK then
            self.m_pMainRank:resetList()
         else
            self.m_pMainRankEnded:resetList()
         end
    end

end

function familyfight:HandleSelectRank(args)
    local item = self.m_pTree:getSelectedItem()
    if item == nil then
        return true
    end
    local id = item:getID()
    --发送协议
    local req = CRequestRankList.Create()
    if id == 1 then
        req.ranktype = RankType.CLAN_FIGHT_2        --周二场次
    elseif id == 2 then
        req.ranktype = RankType.CLAN_FIGHT_4        --周四场次
    elseif id == 3 then
        req.ranktype = RankType.CLAN_FIGHT_WEEK     --本轮统计
    else
    end
    req.page = 0
	require "manager.luaprotocolmanager":send(req)

    self.m_iCurPage = 0
end

--更新对阵表数据
function familyfight:RefreshFamilyFightList(listdata,curweek,isover)    --curweek:当前轮数  isover:0是没结束1是已结束
    _instance.m_isover = isover
	--self:InitTimeInfo()
    self.m_dunzhenImg:setVisible(false)
    if listdata ~= nil and #listdata > 0 then
        local s = self.m_pMainDunZhen:getPixelSize()
        self.m_dunZhenList = listdata
        local cellcount = #listdata
        if not self.m_dunZhenTable then
	        self.m_dunZhenTable = TableView.create(self.m_pMainDunZhen)
            self.m_dunZhenTable:setViewSize(s.width-1, s.height-52)
	        self.m_dunZhenTable:setPosition(6, 40)
        end
        self.m_dunZhenTable:setDataSourceFunc(self, familyfight.tableViewGetCellAtIndex)
        self.m_dunZhenTable:setCellCount(cellcount)
        self.m_dunZhenTable:reloadData()
    else
        if self.m_iCurPage == 0 then
            self.m_dunzhenImg:setVisible(true)
        end
    end
    --[[ if self.m_curSubType == RankType.CLAN_FIGHT_2 then
        self.m_item1Btn:setSelected(true)
     elseif  self.m_curSubType == RankType.CLAN_FIGHT_4 then
        self.m_item2Btn:setSelected(true)
     else
        --
     end
	 --]]
end



function familyfight:tableViewGetCellAtIndex(tableView, idx, cell)
    if idx == nil then
        return
    end
    if tableView == nil then
        return
    end
    idx = idx + 1
    if not cell then
        cell = familyduizhencell.CreateNewDlg(tableView.container, tableView:genCellPrefix())
        cell.m_Btn:setGroupID(56)
        cell.m_Btn:subscribeEvent("MouseButtonUp", familyfight.HandleDuiZhencellClicked, self)
        cell.m_Btn:subscribeEvent("MouseButtonDown", familyfight.HandleDuiZhencellClicked2, self)
    end
  
     if self.m_dunZhenList then
        cell:SetMyZhanRankData(self.m_dunZhenList[idx],idx)
    end
    if idx % 2 == 1 then
        cell.m_Btn:SetStateImageExtendID(1)
    else
        cell.m_Btn:SetStateImageExtendID(0)
    end
    cell.m_Btn:setID(idx)
    return cell
end

-- 列表项触摸事件回调（触摸按下）
function familyfight:HandleDuiZhencellClicked2(args)
    local e = CEGUI.toWindowEventArgs(args)
    self.m_SelectButtonBtn = e.window:getID()
    self:ResetDuiZhencellClicked()
end

-- 列表项触摸事件回调（触摸抬起）
function familyfight:HandleDuiZhencellClicked(args)
    local e = CEGUI.toWindowEventArgs(args)
    self.m_SelectEntryIndex = e.window:getID()
    if self.m_SelectButtonBtn ~= nil then
        if self.m_SelectButtonBtn ~= self.m_SelectEntryIndex then
            return
        end
    end
    self.m_dunZhenTable.visibleCells[self.m_SelectEntryIndex - 1].m_Btn:setSelected(true)
end

-- 重置所有点选
function familyfight:ResetDuiZhencellClicked()
    self.m_SelectEntryIndex = 0
    if not self.m_dunZhenTable then
        return
    end
    if not self.m_dunZhenTable.visibleCells then
        return
    end
    for _, v in pairs(self.m_dunZhenTable.visibleCells) do
        v.m_Btn:setSelected(false)
    end
end
 
--[[ 当前轮
extdata  积分
extdata1 战斗次数
extdata2 胜利次数
extdata3 公会等级

周1周三
extdata  积分
extdata1 战斗次数
extdata2 公会等级
extdata3 当前轮数
--]]
--更新公会战排行数据
function familyfight:RefreshFamilyRankList(ranktype,myrank,list,page,hasmore,extdata,extdata1,extdata2,extdata3)
    _instance.m_iCurPage = page
    _instance.m_bHasMore = hasmore
    _instance.m_iCurRankType = ranktype

    if _instance.m_curSubType ~= RankType.CLAN_FIGHT_WEEK then
            _instance.m_curWeek = extdata3
    end  

    local sizeof_recordlist = #list
    if list ~= nil and sizeof_recordlist > 0 then
        _instance.m_rankImg:setVisible(false)
        _instance.m_rankCurImg:setVisible(false)
        _instance.m_historyImg:setVisible(false)
        for index = 1, sizeof_recordlist do 
             if _instance.m_curType == FamilyRankType.FamilyRankType_Rank then
                 local row = ClanFightRaceRank:new()
                 local _os_ = FireNet.Marshal.OctetsStream:new(list[index])
                 row:unmarshal(_os_)
                 _os_:delete()
                 local percent = nil
                 if row.fightcount == 0 then
                    percent = "0%"
                 else
                    percent = string.format("%.2f",(row.wincount/row.fightcount) * 100) .. "%"
                 end
                 if _instance.m_curSubType ~= RankType.CLAN_FIGHT_WEEK then
					 _instance:AddRow(_instance.m_curType,row.rank-1,tostring(row.rank), row.clanname, tostring(row.clanlevel),percent,tostring(row.scroe))
                 else
                     _instance:AddRow(_instance.m_curType,row.rank-1,tostring(row.rank), row.clanname, tostring(row.fightcount),percent,tostring(row.scroe))
                 end 
               
             elseif _instance.m_curType == FamilyRankType.FamilyRankType_History then
                 local row = ClanFightHistroyRank:new()
                 local _os_ = FireNet.Marshal.OctetsStream:new(list[index])
                 row:unmarshal(_os_)
                 _os_:delete()
                 local percent = nil
                 if row.fightcount == 0 then
                    percent = "0%"
                 else
                    percent = string.format("%.2f",(row.wincount/row.fightcount) * 100) .. "%"
                 end
                 _instance:AddRow(_instance.m_curType,row.rank-1,tostring(row.rank), row.clanname, tostring(row.clanlevel),tostring(row.fightcount),tostring(row.wincount),percent)
             else
                --other
             end
        end
    else
        if _instance.m_iCurPage == 0 then
            _instance.m_rankImg:setVisible(true)
            _instance.m_rankCurImg:setVisible(true)
            _instance.m_historyImg:setVisible(true)
        end
    end
    local datamanager = require "logic.faction.factiondatamanager"
    if datamanager then
        if datamanager:IsHasFaction() then
             _instance:UpdateMyRank(_instance.m_curType,tostring(myrank), datamanager.factionname, tostring(datamanager.factionlevel), extdata,extdata1,extdata2);
        else
            _instance:NoRank()
        end
    else
        _instance:NoRank()
    end
    if _instance.m_curType == FamilyRankType.FamilyRankType_Rank then
          _instance:SetWeekText()
    end
end

function familyfight:UpdateMyRank(curtype,col0, col1, col2, col3, col4, col5) 
     if _instance.m_curType == FamilyRankType.FamilyRankType_Rank then  --col3积分 col4参战次数  col5胜利次数
            if self.m_curSubType ~= RankType.CLAN_FIGHT_WEEK then
                self.m_rankBangWaiEnded:setVisible(true)
                self.m_rankBangWai:setVisible(false)
                if tonumber(col0) == 0 then
                    local strMyRank =  require "utils.mhsdutils".get_resstring(11204) 
                    self.m_rankBangWaiParamsEnded[1]:setText(strMyRank)    
                else
                    self.m_rankBangWaiParamsEnded[1]:setText(col0)    
                end
                self.m_rankBangWaiParamsEnded[2]:setText(col1)
                self.m_rankBangWaiParamsEnded[3]:setText(col5)
                self.m_rankBangWaiParamsEnded[4]:setText(col3)
            else
                self.m_rankBangWai:setVisible(true)
                self.m_rankBangWaiEnded:setVisible(false)
                if tonumber(col0) == 0 then
                    local strMyRank =  require "utils.mhsdutils".get_resstring(11204) 
                    self.m_rankBangWaiParams[1]:setText(strMyRank)    
                else
                    self.m_rankBangWaiParams[1]:setText(col0)    
                end
                self.m_rankBangWaiParams[2]:setText(col1);
                self.m_rankBangWaiParams[3]:setText(col4);
                if col4 == 0 then
                    self.m_rankBangWaiParams[4]:setText("0");
                else
                    self.m_rankBangWaiParams[4]:setText(string.format("%.2f",(col5/col4) * 100) .. "%");
                end
                self.m_rankBangWaiParams[5]:setText(col3);              
            end

     elseif _instance.m_curType == FamilyRankType.FamilyRankType_History then   --col3参战次数 col4胜利次数  col5公会等级
            self.m_historyBangWai:setVisible(true)
            if tonumber(col0) == 0 then
               local strMyRank =  require "utils.mhsdutils".get_resstring(11204) 
               self.m_historyBangWaiParams[1]:setText(strMyRank)    
            else
                self.m_historyBangWaiParams[1]:setText(col0);
            end
            self.m_historyBangWaiParams[2]:setText(col1);
            self.m_historyBangWaiParams[3]:setText(col5);
            self.m_historyBangWaiParams[4]:setText(col3);
            self.m_historyBangWaiParams[5]:setText(col4);
            if col3 == 0 then
                self.m_historyBangWaiParams[6]:setText("0");
            else
                self.m_historyBangWaiParams[6]:setText(string.format("%.2f",(col4/col3) * 100) .. "%");
            end
     else
        --
     end
end

function familyfight:OnRankBtnEx()
    if self.m_curType ~= FamilyRankType.FamilyRankType_Rank then
        self.m_curType = FamilyRankType.FamilyRankType_Rank
        self.m_mainTitle:setText( self.m_rankBtn:getText() )
        self.m_pMainHistoryBg:setVisible(false)
        self.m_enterBtn:setVisible(false)
        self.m_textinfo:setVisible(false)
        self.m_textinfo2:setVisible(true)
        self.m_pTree:setVisible(true)
        self.m_itemCurBtn:setVisible(true)
        self.m_pMainRankBg:setVisible(true)
        self.m_pMainDunZhenBg:setVisible(false)
		self.m_historyRankClearTip:setVisible(false)
        local req = CRequestRankList.Create()
        req.ranktype = self.m_curSubType
        req.page = 0
        LuaProtocolManager.getInstance():send(req)
        self.m_iRankType = self.m_curSubType
        self.m_iCurPage = 0
        self:InitTimeInfo()
         if self.m_curSubType == RankType.CLAN_FIGHT_WEEK then
            self.m_pMainRank:resetList()
         else
            self.m_pMainRankEnded:resetList()
         end
    end
end

function familyfight:SetWeekText()
    local text = require("utils.mhsdutils").get_resstring(11606)
    if text and self.m_curWeek then
        local sb = StringBuilder.new()
        sb:Set("parameter1",tostring(8))
        sb:Set("parameter2",tostring((self.m_curWeek+1) .. "/8"))
        text = sb:GetString(text)
        sb:delete()
        self.m_textinfo2:Clear()
        self.m_textinfo2:AppendParseText(CEGUI.String(text))
        self.m_textinfo2:Refresh()
    end 
end

function familyfight:OndunZhenBtnEx()
    if self.m_curType ~= FamilyRankType.FamilyRankType_DunZhen then
        self.m_curType = FamilyRankType.FamilyRankType_DunZhen
        self.m_mainTitle:setText( self.m_dunZhenBtn:getText() )
        self.m_pMainHistoryBg:setVisible(false)
        self.m_enterBtn:setVisible(true)
        self.m_textinfo:setVisible(true)
        self.m_textinfo2:setVisible(false)
        self.m_pTree:setVisible(true)
        self.m_itemCurBtn:setVisible(false)
		self.m_historyRankClearTip:setVisible(false)
        self:InitTimeInfo()
        self.m_pMainDunZhen:resetList()
        self.m_pMainDunZhenBg:setVisible(true)
        self.m_pMainRankBg:setVisible(false)
        local p = require "protodef.fire.pb.clan.fight.cgetclanfightlist":new()
        --当前时间
	    local time = StringCover.getTimeStruct(gGetServerTime() / 1000)
        --计算星期
	    local curWeekDay = time.tm_wday
	    if curWeekDay <= 2 then
		    p.which = 0    
        else
            p.which = 1    
	    end
        p.whichweek = -1
		require "manager.luaprotocolmanager":send(p)
    end
end

function familyfight:OnHistoryBtnEx()
    if self.m_curType ~= FamilyRankType.FamilyRankType_History then
        self.m_curType = FamilyRankType.FamilyRankType_History
        self.m_mainTitle:setText( self.m_historyBtn:getText() )
        self.m_pMainHistoryBg:setVisible(true)
		self.m_historyRankClearTip:setVisible(true)
        self.m_enterBtn:setVisible(false)
        self.m_textinfo:setVisible(false)
        self.m_textinfo2:setVisible(false)
        self.m_pTree:setVisible(false)
        self.m_pMainRankBg:setVisible(false)
        self.m_pMainDunZhenBg:setVisible(false)
        local req = CRequestRankList.Create()
        req.ranktype = RankType.CLAN_FIGHT_HISTROY
        req.page = 0
        self.m_iRankType = RankType.CLAN_FIGHT_HISTROY
        self.m_iCurPage = 0
        LuaProtocolManager.getInstance():send(req)
        self:InitTimeInfo()
        self.m_pMainHistory:resetList()
    end
end


function familyfight:OnInfoBtnEx()
    local dlg = require ("logic.family.familyfightinfo")
	local text = {}
          text[1] = require("utils.mhsdutils").get_resstring(11605)
	      text[2] = require("utils.mhsdutils").get_resstring(11668)
		  
    if dlg then
        dlg.getInstanceAndShow(text)
    end
end

function familyfight:OnEnterBtnEx()
    require "manager.npcservicemanager".SendNpcService(139, 910030)
    self.DestroyDialog()
end

-- 添加一个数据行
function familyfight:AddRow(curtype,rownum, col0, col1, col2, col3, col4, col5,clo6)
    if curtype == FamilyRankType.FamilyRankType_Rank then
        if self.m_curSubType ~= RankType.CLAN_FIGHT_WEEK then
            self:AddRowByType(self.m_pMainRankEnded,rownum, col0, col1, col2, col3, col4, col5,clo6)
        else
            self:AddRowByType(self.m_pMainRank,rownum, col0, col1, col2, col3, col4, col5,clo6)
        end
    elseif curtype == FamilyRankType.FamilyRankType_DunZhen then
        --self:AddRowByType(self.m_pMainDunZhen,rownum, col0, col1, col2, col3, col4, col5)
    elseif curtype == FamilyRankType.FamilyRankType_History then
        self:AddRowByType(self.m_pMainHistory,rownum, col0, col1, col2, col3, col4, col5)
    end
end

function familyfight:AddRowByType(curlistview,rownum, col0, col1, col2, col3, col4, col5)
    curlistview:addRow(rownum)
    -- 获得字体颜色
    local color = self:GetRowColor(rownum)

    local pItem0 = self:CreateColumnItem(curlistview,col0, color, rownum, 0)
    local pItem1 = self:CreateColumnItem(curlistview, col1, color, rownum, 1)
    local pItem2 = self:CreateColumnItem(curlistview, col2, color, rownum, 2)

    if self.m_curType == FamilyRankType.FamilyRankType_Rank then
        if self.m_curSubType == RankType.CLAN_FIGHT_WEEK then
           local pItem3 = self:CreateColumnItem(curlistview, col3, color, rownum, 3)
           local pItem4 = self:CreateColumnItem(curlistview, col4, color, rownum, 4)
        else
            local pItem3 = self:CreateColumnItem(curlistview, col4, color, rownum, 3)
        end    
    else
            local pItem3 = self:CreateColumnItem(curlistview, col3, color, rownum, 3)
            local pItem4 = self:CreateColumnItem(curlistview, col4, color, rownum, 4)
    end

    if self.m_curType ~= FamilyRankType.FamilyRankType_DunZhen then
        if pItem0 then
            if rownum == 0 then
                pItem0:setStaticImage("set:cc25412 image:no1")
                pItem0:setText("");
            elseif rownum == 1 then
                pItem0:setStaticImage("set:cc25412 image:no2")
                pItem0:setText("");
            elseif rownum == 2 then
                pItem0:setStaticImage("set:cc25412 image:no3")
                pItem0:setText("");
            end
            pItem0:setStaticImageWidthAndHeight(40.0, 40.0)
        end
        local pItem5 = self:CreateColumnItem(curlistview, col5, color, rownum, 5)
    else
          pItem2:setStaticImage("set:huobanui image:vs")
          pItem2:setText("");
    end
end

-- 创建一个列
function familyfight:CreateColumnItem(listview, text, color, rownum,col)
    if not text then
        return nil
    end
    local pItem = CEGUI.createListboxTextItem(text)
    if not pItem then
        return nil
    end
    pItem:setTextColours(CEGUI.PropertyHelper:stringToColour(color))
    pItem:SetTextHorFormat(CEGUI.eListBoxTextItemHorFormat_Center)
    pItem:setID(rownum)
    pItem:SetUserID(rownum)
    pItem:setFont(self.m_FontText)
    if listview then
        listview:setItem(pItem, col, rownum)
    end
    return pItem
end
-- 行颜色
function familyfight:GetRowColor(rownum)
    local color = "FF50321A"
    if rownum == 0 then
        color = "FFCC0000"
    elseif rownum == 1 then
        color = "FF009ddb"
    elseif rownum == 2 then
        color = "FF005B0F"
    end
    return color
end

function familyfight:OnCloseBtnEx()
	if familyfight:getInstance() then
		familyfight:getInstance():DestroyDialog()
	end
end

--初始化月和日期
function familyfight:initMonthDay()
    local monthday = {}
    for k = 1, 12 do
        if k == 1 or k == 3 or k == 5 or k==7 or k==8 or k == 10 or k == 12 then
            monthday [k] = 31
        elseif k ==4 or k== 6 or k == 9 or k == 11 then
            monthday [k] = 30
        elseif k == 2 then
            monthday [k] = 29
        end
    end
    return monthday
end

--通过星期返回日期
function familyfight:GetDateByWeek(day)
    --当前时间
	local time = StringCover.getTimeStruct(gGetServerTime() / 1000)
    local yearCur = time.tm_year + 1900
	local monthCur = time.tm_mon + 1
	local dayCur = time.tm_mday

	local curWeekDay = day
    local thursday = 0
    local tuesday = 0
	if curWeekDay == 0 then
         thursday = dayCur - 3
         tuesday = dayCur - 5
    elseif curWeekDay == 1 then
         thursday = dayCur + 3
         tuesday = dayCur + 1
    elseif curWeekDay == 2 then
         thursday = dayCur + 2
         tuesday = dayCur
    elseif curWeekDay == 3 then
         thursday = dayCur + 1
         tuesday = dayCur - 1
    elseif curWeekDay == 4 then
         thursday = dayCur
         tuesday = dayCur - 2 
    elseif curWeekDay == 5 then
         thursday = dayCur - 1
         tuesday = dayCur  - 3
    elseif curWeekDay == 6 then
         thursday = dayCur - 2
         tuesday = dayCur  - 4
	end
    return self:GetDate(yearCur,monthCur,dayCur,thursday,tuesday)
end

function familyfight:GetDate(curyear, curmonth,curday, tday,tsday)
    local monthandday = self:initMonthDay()
    local desmonthday = {}
    local smonth = 0
    local sday = 0

    if tday < 0 then
         smonth = curmonth - 1
         if smonth == 0 then
            smonth = 1
         end
         sday = monthandday[smonth] + tday
    elseif tday > 0 and tday <= monthandday[curmonth] then
         smonth = curmonth
         sday = tday
    elseif tday == 0 then
          smonth = curmonth - 1
          sday = monthandday[smonth]
    elseif tday > monthandday[curmonth] then
        smonth = curmonth + 1
        if smonth > 12 then
            smonth = 1
        end
        sday = tday - monthandday[curmonth]
    end

    local strTime  = self:GetDateFormat(smonth,sday,11604)

    if tsday < 0 then
         smonth = curmonth - 1
         if smonth == 0 then
            smonth = 1
         end
         sday = monthandday[smonth] + tsday
    elseif tsday > 0 and tsday <= monthandday[curmonth] then
         smonth = curmonth
         sday = tsday
    elseif tsday == 0 then
          smonth = curmonth - 1
          sday = monthandday[smonth]
    elseif tsday > monthandday[curmonth] then
        smonth = curmonth + 1
        if smonth > 12 then
            smonth = 1
        end
        sday = sday - monthandday[curmonth]
    end

    local strTime1 = self:GetDateFormat(smonth,sday,11603)

    return strTime,strTime1

end

function familyfight:GetDateFormat(month,day,id)
    local strTime = require("utils.mhsdutils").get_resstring(id)
    local sb = StringBuilder.new()
    sb:Set("parameter1",tostring(month))
    sb:Set("parameter2",tostring(day))
    strTime = sb:GetString(strTime)
    sb:delete()
    return strTime
end



--清理榜时间
function familyfight:RefreshFamilyRankClearTime( pCleartime )
    local time = StringCover.getTimeStruct(pCleartime / 1000)
	local monthCur = tonumber(time.tm_mon) + 1
	local dayCur = tonumber(time.tm_mday)
	
	local strTime1 = self:GetDateFormat(monthCur,dayCur,11651) --历史战绩每24周清零一次，下次清零时间：$parameter1$月$parameter2$日
	self.m_historyRankClearTip:setText(strTime1)

end




return familyfight