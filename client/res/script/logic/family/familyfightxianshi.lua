require "logic.dialog"
require "logic.family.familyfightcell"
require "logic.family.familyfightgraycell"

FamilyFightXianshi = {}
setmetatable(FamilyFightXianshi, Dialog)
FamilyFightXianshi.__index = FamilyFightXianshi

local _instance
function FamilyFightXianshi.getInstance()
	if not _instance then
		_instance = FamilyFightXianshi:new()
		_instance:OnCreate()
	end
	return _instance
end

function FamilyFightXianshi.getInstanceAndShow()
	if not _instance then
		_instance = FamilyFightXianshi:new()
		_instance:OnCreate()
        _instance:resetData()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function FamilyFightXianshi.getInstanceNotCreate()
	return _instance
end

function FamilyFightXianshi.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
		   local duizhandlg = require"logic.family.familyduizhanzudui".getInstanceNotCreate()
			if duizhandlg then
				duizhandlg.DestroyDialog()
		    end 
			_instance:OnClose()
			_instance = nil
			
		else
			_instance:ToggleOpenClose()
		end
	end
end

function FamilyFightXianshi.ToggleOpenClose()
	if not _instance then
		_instance = FamilyFightXianshi:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function FamilyFightXianshi.GetLayoutFileName()
	return "bangzhanxianshi.layout"
end

function FamilyFightXianshi:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, FamilyFightXianshi)
	return self
end

function FamilyFightXianshi:resetData()

    self.m_eFlyType = eFlyNull
    self.m_fTaskElapsedTimeFadein = 0
	self.m_fTeamElapsedTimeFadeout = 0
    
end

function FamilyFightXianshi:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

    self.m_bgxingdong = winMgr:getWindow("bangzhanxianshi")
    self.m_xingdongli = winMgr:getWindow("bangzhanxianshi/xingdonglizhi")
	
    self.m_showBtn = CEGUI.Window.toPushButton(winMgr:getWindow("bangzhanxianshi/btntanchu"))
    self.m_showBtn:subscribeEvent("MouseClick",FamilyFightXianshi.showBtnClicked,self)
    self.m_showBtn:setVisible(false)

    self.m_hideBtn = CEGUI.Window.toPushButton(winMgr:getWindow("bangzhanxianshi/btnfanhui"))
    self.m_hideBtn:subscribeEvent("MouseClick",FamilyFightXianshi.hideBtnClicked,self)
	
	self.m_AddTeamBtn = CEGUI.Window.toPushButton(winMgr:getWindow("bangzhanxianshi/btnzudui"))  --组队
    self.m_AddTeamBtn:subscribeEvent("MouseClick",FamilyFightXianshi.addTeamBtnClicked,self)
  
	
	
    self.m_myFactionJiFen =  winMgr:getWindow("bangzhanxianshi/mask/diban/jifen1")
    self.m_enmryFactionJiFen =  winMgr:getWindow("bangzhanxianshi/mask/diban/jifen2")

    self.m_heidi =  winMgr:getWindow("bangzhanxianshi/mask/heidi")
    self.m_dibian =  winMgr:getWindow("bangzhanxianshi/mask/diban")

    self.m_shijiandi = winMgr:getWindow("bangzhanxianshi/mask/shijiandi")
    self.m_willbeign = winMgr:getWindow("bangzhanxianshi/mask/shijiandi/jijiangkaishi") --即将开始
    self.m_leftZhunBeiTime =  winMgr:getWindow("bangzhanxianshi/mask/shijiandi/shengyushijian") --剩余准备时间
    self.m_leftTime = winMgr:getWindow("bangzhanxianshi/mask/shijiandi/shengyushijian1")

    --我的积分
    self.m_myjifen = winMgr:getWindow("bangzhanxianshi/mask/heidi/wodejifen")
    self.m_myjifenvalue = winMgr:getWindow("bangzhanxianshi/mask/heidi/jifen")
    self.m_myjifenrank = winMgr:getWindow("bangzhanxianshi/mask/heidi/paiming")
    self.m_myjifenvalue1 = winMgr:getWindow("bangzhanxianshi/mask/heidi/jifen1")
    self.m_myjifenrank1 = winMgr:getWindow("bangzhanxianshi/mask/heidi/paiming1")
	

    --帮派积分
    self.m_myfactionjifen = winMgr:getWindow("bangzhanxianshi/mask/diban/jifen1")
    self.m_emeryfactionjifen = winMgr:getWindow("bangzhanxianshi/mask/diban/jifen2")
   
    self.m_scroll = CEGUI.toScrollablePane(winMgr:getWindow("bangzhanxianshi/mask/five/list"))
	
    self.m_downBtn = CEGUI.Window.toPushButton(winMgr:getWindow("bangzhanxianshi/mask/xiajiantou"))
    self.m_downBtn:subscribeEvent("MouseClick",FamilyFightXianshi.DownBtnClicked,self)
    self.m_upBtn = CEGUI.Window.toPushButton(winMgr:getWindow("bangzhanxianshi/mask/shangjiantou"))
    self.m_upBtn:subscribeEvent("MouseClick",FamilyFightXianshi.UpBtnClicked,self)

    self.m_infoBtn = CEGUI.Window.toPushButton(winMgr:getWindow("bangzhanxianshi/btnzhiyin"))
    self.m_infoBtn:subscribeEvent("MouseClick",FamilyFightXianshi.InfoBtnClicked,self)
	
    --积分帮会名字 
    self.m_clanName1 = winMgr:getWindow("bangzhanxianshi/mask/heidi/cell/bangpai11")
    self.m_clanName2 = winMgr:getWindow("bangzhanxianshi/mask/heidi/cell/bangpai21")
    self.m_clanImg1 = winMgr:getWindow("bangzhanxianshi/mask/heidi/cell/image11")
    self.m_clanImg2 = winMgr:getWindow("bangzhanxianshi/mask/heidi/cell/image21")
	
	--积分信息列表
	self.m_ShowJifeiBg = winMgr:getWindow("bangzhanxianshi/mask/five")
	self.m_ShowJifeiBg:setVisible(false) 
 
	
    self.m_heidi:setVisible(false)
    self.m_dibian:setVisible(false)
    self.m_willbeign:setVisible(false)
   
     self.m_timeCount = 0
     self.m_needUpdateLeftTime = true
     
     self.m_issendreq = false
     self.m_sendTimeCount = 0
     self.m_sendTimeCount1 = 0

     self.m_myList = {}
     self.m_emnyList = {}
     self.rankTable = {} --self.rankTable = nil

     self.m_isOver = false          --帮战是否结束
     self.m_winer = -1              --胜利者
	 
	self.m_beginBattleTime = "21:00:00"
	local actScheculed = BeanConfigManager.getInstance():GetTableByName("timer.cscheculedactivity"):getRecorder(281001)
    if actScheculed~= nil then
		 self.m_beginBattleTime = actScheculed.startTime2
	end

     self:UpdateRoleAct(FamilyFightManager.Data.m_isCurXingdongli)
     local logodlg = require("logic.logo.logoinfodlg").getInstanceNotCreate()
     if logodlg then
        logodlg:IsShowAllBtn(false)
     end

end


 
function FamilyFightXianshi:UpdateBattleInfo(name1,name2,clanid1,clanid2)
    if name1 then
        self.m_clanName1:setText(name1)
        self.m_clanName1:SetTextColor(0xff33ff33)
    else
        self.m_clanName1:setText("")
	end
	
    if name2 then	
        self.m_clanName2:setText(name2)
        self.m_clanName2:SetTextColor(0xff3333ff)
    else
        self.m_clanName2:setText("")
    end
	
	require "mainticker"
    local setMaxShowNumAction = require ("protodef.fire.pb.csetmaxscreenshownum").Create()
    setMaxShowNumAction.maxscreenshownum = PlayerCountByFPS
    LuaProtocolManager.getInstance():send(setMaxShowNumAction)
end

function FamilyFightXianshi:showBtnClicked(args)
    self.m_xingdongli:setVisible(true)
    self.m_bgxingdong:setVisible(true)
    if not self.m_needUpdateLeftTime then
        self.m_dibian:setVisible(true)
        if not self.m_issendreq then
			self.m_heidi:setVisible(true)
			self.m_ShowJifeiBg:setVisible(false)
        else
			self.m_heidi:setVisible(false)
			self.m_ShowJifeiBg:setVisible(true)
        end
    else
        self.m_shijiandi:setVisible(true) 
		self.m_ShowJifeiBg:setVisible(false)
    end
    self.m_showBtn:setVisible(false)
    self.m_hideBtn:setVisible(true)
end

function FamilyFightXianshi:hideBtnClicked(args)
    self.m_ShowJifeiBg:setVisible(false)

    self.m_xingdongli:setVisible(false)
    self.m_heidi:setVisible(false)
    self.m_dibian:setVisible(false)
    self.m_shijiandi:setVisible(false)
    self.m_showBtn:setVisible(true)
    self.m_hideBtn:setVisible(false)
    self.m_bgxingdong:setVisible(false)
end

--组队信息
function FamilyFightXianshi:addTeamBtnClicked(args)
	require"logic.family.familyduizhanzudui".getInstanceAndShow()
end

function FamilyFightXianshi:InfoBtnClicked(args)
    local dlg = require ("logic.family.familyfightinfo")
	local text = {}
          text[1] = require("utils.mhsdutils").get_resstring(11605)
	      text[2] = require("utils.mhsdutils").get_resstring(11668)
	
    if dlg then
        dlg.getInstanceAndShow(text)
    end
end

function FamilyFightXianshi:DownBtnClicked(args)
	self.m_ShowJifeiBg:setVisible(true)
	self.m_heidi:setVisible(false)
     
    self.m_issendreq = true
	
	local req = require"protodef.fire.pb.clan.fight.cbattlefieldranklist".Create()
    LuaProtocolManager.getInstance():send(req)
    self.m_sendTimeCount = gGetServerTime() 
end

function FamilyFightXianshi:UpBtnClicked(args)
	self.m_ShowJifeiBg:setVisible(false)
	self.m_heidi:setVisible(true)
    self.m_issendreq = false
end

function FamilyFightXianshi:update(delta)
    if not GetIsInFamilyFight() then return end
    if gGetServerTime() - self.m_timeCount > 1000 then
        self:UpdateLeftTime()
        self.m_timeCount = gGetServerTime()
    end

    if self.m_issendreq then
        if gGetServerTime() - self.m_sendTimeCount > (1000 * 60 * 1) then   --1分钟请求一下排行积分
            local req = require"protodef.fire.pb.clan.fight.cbattlefieldranklist".Create()
            LuaProtocolManager.getInstance():send(req)
            self.m_sendTimeCount = gGetServerTime() 
        end
    end

    if gGetServerTime() - self.m_sendTimeCount1 > (1000 * 30 * 1 ) then     --20秒更新一下公会积分
        local req = require"protodef.fire.pb.clan.fight.cbattlefieldscore".Create()
        LuaProtocolManager.getInstance():send(req)
        self.m_sendTimeCount1 = gGetServerTime() 
    end
end

--更新倒计时显示
function FamilyFightXianshi:UpdateLeftTime()
   if self.m_needUpdateLeftTime  then
        local stime = StringCover.getTimeStruct(gGetServerTime() / 1000) 
        local shour = tonumber(stime.tm_hour)
        local smin  = tonumber(stime.tm_min)
        --local nhour, nmin, nsec = string.match(FamilyFightManager.Data.m_beginTime, "(%d+):(%d+):(%d+)") 
		local nhour, nmin, nsec = string.match(self.m_beginBattleTime, "(%d+):(%d+):(%d+)") 
        local beginhour = tonumber(nhour)
        local beginmin 	= tonumber(nmin)
        local leftmin 	= (beginhour - shour ) * 60 + (beginmin - smin)
        if leftmin == 1 then
             self.m_leftTime:setVisible(false)
             self.m_leftZhunBeiTime:setVisible(false)
             self.m_willbeign:setVisible(true)
             self.m_willbeign:SetTextColor(0xff33ff33)    --red
        elseif leftmin <= 0 then
            self.m_shijiandi:setVisible(false)
            self.m_dibian:setVisible(true)
            self.m_heidi:setVisible(true)
            self.m_needUpdateLeftTime  = false
        else
            local strLeftTime = require("utils.mhsdutils").get_resstring(1241)
	        strLeftTime = string.format(strLeftTime,leftmin)
            self.m_leftTime:setText(strLeftTime)
            self.m_leftTime:SetTextColor(0xff33ff33)    --red
            self.m_leftTime:setVisible(true)
            self.m_leftZhunBeiTime:setVisible(true)
            self.m_willbeign:setVisible(false)
        end
    end
end

--结束后 显示宝箱的倒计时
function FamilyFightXianshi:SetLeftTimeAndStatus(status,timestamp)
     if status ~= -1 then
        self.m_isOver = true         --帮战是否结束
        self.m_winer = status       ---1是没结束    0是公会1 1是公会2赢了 
     end
end

function FamilyFightXianshi:UpdateMyScoreAndRank(score1,score2,myrank,myscore)
    self.m_myFactionJiFen:setText(tostring(score1))
    self.m_enmryFactionJiFen:setText(tostring(score2))
    self.m_myjifenvalue:setText(tostring(myscore))
	self.m_myjifenvalue1:setText(tostring(myscore))
    if myrank == -1 then
        self.m_myjifenrank:setVisible(false)
		self.m_myjifenrank1:setVisible(false)
    else
        self.m_myjifenrank:setVisible(true)
		self.m_myjifenrank1:setVisible(true)
        local strbuilder = StringBuilder:new()
        strbuilder:Set("parameter1", (myrank+1))
        local text = strbuilder:GetString(MHSD_UTILS.get_resstring(2899))
        self.m_myjifenrank:setText(text)
		self.m_myjifenrank1:setText(text)
        strbuilder:delete()
    end
end

function FamilyFightXianshi:UpdateFightInfo(score1,score2,myrank,myscore,myList,emnyList)
    self.m_myFactionJiFen:setText(tostring(score1))
    self.m_enmryFactionJiFen:setText(tostring(score2))
    self.m_myjifenvalue:setText(tostring(myscore))
	self.m_myjifenvalue1:setText(tostring(myscore))
    if myrank == -1 then
        self.m_myjifenrank:setVisible(false)
		self.m_myjifenrank1:setVisible(false)
    else
        self.m_myjifenrank:setVisible(true)
		self.m_myjifenrank1:setVisible(true)
        local strbuilder = StringBuilder:new()
        strbuilder:Set("parameter1", (myrank+1))
        local text = strbuilder:GetString(MHSD_UTILS.get_resstring(2899))
        self.m_myjifenrank:setText(text)
		self.m_myjifenrank1:setText(text)
        strbuilder:delete()
    end
	
	if not self.m_scroll then
        return
    end
	
    if myList then
        self.m_myList = myList
    end
    if emnyList then
        self.m_emnyList = emnyList
    end
	
	local cellcount = math.max( #self.m_myList ,#self.m_emnyList)
	if cellcount< 5 then 
		cellcount = 5
	end 
	  
    if  self.rankTable then
		for index in pairs( self.rankTable) do
			local cell = self.rankTable[index]
			if cell then
				cell:OnClose()
			end
		end
	end
	
	for idx =1,cellcount do
	 
		local cell =  nil 
		if math.mod(idx,2) == 0 then
			cell = BangZhanGrayCell.CreateNewDlg(self.m_scroll , idx-1)
		else
			cell = BangZhanCell.CreateNewDlg(self.m_scroll, idx-1)
		end 
		local x = CEGUI.UDim(0, 0)
		local y = CEGUI.UDim(0, 3+(idx -1)*(cell.m_height+3) )
		local pos = CEGUI.UVector2(x,y)
		cell:GetWindow():setPosition(pos)
		cell:SetMyZhanRankData(self.m_myList[idx],self.m_emnyList[idx],idx)
		table.insert(self.rankTable, cell)
	end 
end
		
		
 


--更新玩家行动力
function FamilyFightXianshi:UpdateRoleAct(act)
    self.m_xingdongli:setText(tostring(act))
end

return FamilyFightXianshi