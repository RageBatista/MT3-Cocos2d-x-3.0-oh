local scgctType
local mCGChange = require "protodef.fire.pb.npc.swinnerchangetask"
local function cmChangeTask()
	if scgctType then 
		gGetMessageManager():CloseConfirmBox(scgctType, false)
		scgctType = nil
	end
	local p = require "protodef.fire.pb.npc.cwinnerchangetask":new()
	p.acceptflag = 1
	require "manager.luaprotocolmanager":send(p)
end
local function cancelChangeTask()
	if scgctType then 
		gGetMessageManager():CloseConfirmBox(scgctType, false)
		scgctType = nil
	end
	local p = require "protodef.fire.pb.npc.cwinnerchangetask":new()
	p.acceptflag = 0
	require "manager.luaprotocolmanager":send(p)
end
function mCGChange:process()
    local strMsg = GameTable.message.GetCMessageTipTableInstance():getRecorder(160395).msg
    scgctType = eConfirmNormal
    gGetMessageManager():AddConfirmBox(scgctType, strMsg, cmChangeTask, 0, cancelChangeTask,0,0,0,nil,"","")
end

local confirmtype, curtime
local endtime = 10
local function confirm()
	if confirmtype then
		gGetMessageManager():CloseConfirmBox(confirmtype, false)
		confirmtype = nil
	end
	local p = require "protodef.fire.pb.npc.ctgbdvote":new()
	p.result = 0
	require "manager.luaprotocolmanager":send(p)
end
local function reject()
	if confirmtype then
		gGetMessageManager():CloseConfirmBox(confirmtype, false)
		confirmtype = nil
	end
	local p = require "protodef.fire.pb.npc.ctgbdvote":new()
	p.result = 1
	require "manager.luaprotocolmanager":send(p)
end
local function tryCloseBox(eslaped)
	if not confirmtype then
		return
	end
	curtime = curtime and curtime + eslaped or eslaped
	if curtime >= endtime then
		gGetMessageManager():CloseConfirmBox(confirmtype, false)
		confirmtype = nil
		local p = require "protodef.fire.pb.npc.ctgbdvote":new()
		p.result = 0
		require "manager.luaprotocolmanager":send(p)
	end
end

local sreqfortunewheel = require "protodef.fire.pb.npc.sreqfortunewheel"
function sreqfortunewheel:process()
    LogInfo("____sreqfortunewheel:process")
    require "logic.jingying.jingyingenddlg"
    require "logic.lottery.lotterycarddlg"

    print("____self.flag: " .. self.flag)

    if self.flag == 0 then
        LotteryCardDlg.getInstanceAndShow():initdlg(self.itemids, self.index, self.npckey, self.serviceid)
    elseif self.flag == 1 then
        local jingyingendlg = Jingyingenddlg.getInstanceAndShow()
        if jingyingendlg then
            jingyingendlg:addAllItems(self.itemids, self.index, self.npckey, self.serviceid)
        else
        end
    else
    end
end

local spingji = require "protodef.fire.pb.npc.spingji"
function spingji:process()
    LogInfo("____spingji:process")
    require "logic.jingying.jingyingenddlg"

    local jingyingenddlg = Jingyingenddlg.getInstanceAndShow()
    if jingyingenddlg then
        jingyingenddlg:InitScore(self.grade, self.exp)
    else
    end
end

local sinvitationtomarry = require "protodef.fire.pb.npc.sinvitationtomarry"
function sinvitationtomarry:process()
    require "manager.npcservicemanager":AskIfAcceptToMarry(self.invitername,self.inviterlevel)
end

local ssubmit2npc = require "protodef.fire.pb.npc.ssubmit2npc"
function ssubmit2npc:process()
	local taskHelper = require "logic.task.taskhelper"
	taskHelper.ssubmit2npc_process(self)
end

local ssendnpcservice = require "protodef.fire.pb.npc.ssendnpcservice"
function ssendnpcservice:process()
	require "logic.task.taskhelperprotocol".ssendnpcservice_process(self)
end

local sgrabactivityreward = require "protodef.fire.pb.npc.sgrabactivityreward"
function sgrabactivityreward:process()
    local answerQuestionDlg = require("logic.answerquestion.answerquestiondlg").getInstanceNotCreate()
    if answerQuestionDlg then
        answerQuestionDlg:rewardFinish()
    end
end

local SAskQuestion = require "protodef.fire.pb.npc.saskquestion"
function SAskQuestion:process()
    if self.questiontype == self.ACTIVITY_ANSWER then
        local answerQuestionDlg = require("logic.answerquestion.answerquestiondlg").getInstance()
        answerQuestionDlg:AnswerQuestionProcess(self)
    else
        require "logic.npc.npcdialog".setStartAnswerQuestion(self.lastresult, self.questionid, self.questiontype, self.npckey, self.xiangguanid, self.lasttime)
    end
end

local sactivityanswerquestionhelp = require "protodef.fire.pb.npc.sactivityanswerquestionhelp"
function sactivityanswerquestionhelp:process()
    local answerQuestionDlg = require("logic.answerquestion.answerquestiondlg").getInstanceNotCreate()
    if answerQuestionDlg then
        answerQuestionDlg:refreshHelp(self.helpnum)
    end
end
local simpexamhelp = require "protodef.fire.pb.npc.simpexamhelp"
function simpexamhelp:process()
    local answerQuestionDlg = require("logic.wisdomtrialdlg.wisdomtrialdlg").getInstanceNotCreate()
    if answerQuestionDlg then
        answerQuestionDlg:refreshHelp(self.helpcnt)
    end
end
local svisitnpc = require "protodef.fire.pb.npc.svisitnpc"
function svisitnpc:process()
    if GetBattleManager() == nil or GetMainCharacter() == nil then return end

    if GetBattleManager():IsInBattle() then return end
    
    if GetMainCharacter():GetMoveState() ~= eMove_Pacing and not GetMainCharacter():IsPathEmpty() then
        GetMainCharacter():StopMove()
    end

    local pNpc = gGetScene():FindNpcByID(self.npckey)
    if pNpc then
        if pNpc:GetNpcTypeID() == 29 then
            local dlg = require("logic.fuyuanbox.fuyuanboxdlg").getInstanceAndShow()
            if pNpc:GetNpcBaseID() == tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(282).value) then --∞µ‘¬…Ã»À
                dlg:InitDlg(2,self.npckey)
            elseif pNpc:GetNpcBaseID() == tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(283).value) then --—™∑´–°∑∑
                dlg:InitDlg(3,self.npckey)
            end
            GetMainCharacter():clearGoTo()
            return
        end
        if not pNpc:IsAction(eActionDeath) then
            pNpc:SavePrevDirection()
            pNpc:TurnTo(GetMainCharacter())
        end

        GetMainCharacter():clearGoTo()

        local npcBaseId = pNpc:GetNpcBaseID()

        local speakDlg = require "logic.npc.npcscenespeakdialog".getInstanceNotCreate()
        if speakDlg and speakDlg:IsVisible() then return end

        if require "manager.npcservicemanager".ReceiveServiceId(self.npckey, self.services, self.scenarioquests, npcBaseId) then
            require "logic.npc.npcdialog".getInstance():showDialog(self.npckey, self.services, self.scenarioquests)
            require "logic.jingling.jinglingdlg".DestroyDialog()
            require "logic.friend.friendmaillabel".DestroyDialog()
        end

    end
end

local sgeneralsummoncommand = require "protodef.fire.pb.npc.sgeneralsummoncommand"
function sgeneralsummoncommand:process()
    require("logic.task.taskhelpernpc").sgeneralsummoncommand_process(self)
end

--÷«ª€ ‘¡∂ start
--Ω¯»Î”Œœ∑µƒ ±∫Ú∑¢∆µƒ»∑»œøÚ
local sattendimpexam = require "protodef.fire.pb.npc.sattendimpexam"
function sattendimpexam:process()
    LogInfo("sattendimpexam:process")
    local manager = require "logic.pointcardserver.pointcardservermanager".getInstance()
    if manager.m_isTodayNotFree then
        return
    end
    local huodongmanager = require"logic.huodong.huodongmanager".getInstanceNotCreate()
    if huodongmanager then
        if not huodongmanager:CanPush(2) then
            return
        end
    end
    local function ClickYes(self, args)
        gGetMessageManager():CloseCurrentShowMessageBox()
        local p = require("protodef.fire.pb.npc.capplyimpexam"):new()
        p.impexamtype = self.impexamtype
        p.operate = 0
	    LuaProtocolManager:send(p)
    end
    local function ClickNo(self, args)
        if CEGUI.toWindowEventArgs(args).handled ~= 1 then
            gGetMessageManager():CloseCurrentShowMessageBox()
        end
        return
    end
	local data = gGetDataManager():GetMainCharacterData()
	local nLvl = data:GetValue(fire.pb.attr.AttrType.LEVEL)
    local id = 0
    local strMsg = 0
    if self.impexamtype == 1 then
        id = 214
        strMsg = 11412
    elseif self.impexamtype == 2 then
        id = 215
        strMsg = 11413
    elseif self.impexamtype == 3 then
        id = 216
        strMsg = 11414
        local manager = require"logic.huodong.huodongmanager".getInstanceNotCreate()
        if manager then
            manager.m_boxuezhe = true
        end
    end
    local msg = MHSD_UTILS.get_resstring(strMsg)
    gGetMessageManager():AddMessageBox("",msg,ClickYes,self,ClickNo,self,eMsgType_Normal,30000,0,0,nil,MHSD_UTILS.get_resstring(996),MHSD_UTILS.get_resstring(997))
end
--÷«ª€ ‘¡∂1
local ssendimpexamvill = require "protodef.fire.pb.npc.ssendimpexamvill"
function ssendimpexamvill:process()
    LogInfo("ssendimpexamvill:process")
    local dlg = require"logic.wisdomtrialdlg.wisdomtrialdlg".getInstanceAndShow()
    if dlg then
        dlg:AnswerQuestionvillProcess(self)
    end

end
--÷«ª€ ‘¡∂2
local ssendImpexamprov = require "protodef.fire.pb.npc.ssendimpexamprov"
function ssendImpexamprov:process()
    LogInfo("ssendImpexamprov:process")
     local dlg = require"logic.wisdomtrialdlg.wisdomtrialdlg".getInstanceAndShow()
    if dlg then
        dlg:AnswerQuestionprovProcess(self)
    end
end
--÷«ª€ ‘¡∂3 
local ssendimpexamstate = require "protodef.fire.pb.npc.ssendimpexamstate"
function ssendimpexamstate:process()
    LogInfo("ssendimpexamstate:process")
    local dlg = require"logic.wisdomtrialdlg.wisdomtrialdlg".getInstanceAndShow()
    if dlg then
        dlg:AnswerQuestionstateProcess(self)
    end

    
end
local ssendimpexamstart = require "protodef.fire.pb.npc.ssendimpexamstart"
function ssendimpexamstart:process()
    LogInfo("ssendimpexamstart:process")
    local manager = require "logic.pointcardserver.pointcardservermanager".getInstance()
    if manager.m_isTodayNotFree then
        return
    end
    local function ClickYes(self, args)
        gGetMessageManager():CloseCurrentShowMessageBox()
        local p = require("protodef.fire.pb.npc.capplyimpexam"):new()
        p.impexamtype = self.impexamtype
        p.operate = 1
	    LuaProtocolManager:send(p)
        local dlg = require"logic.wisdomtrialdlg.wisdomtrialdlg".getInstanceNotCreate()
        if dlg then
            dlg.DestroyDialog()
        end
    end
    local function ClickNo(self, args)
        if CEGUI.toWindowEventArgs(args).handled ~= 1 then
            gGetMessageManager():CloseCurrentShowMessageBox()

        end
        return
    end
	local data = gGetDataManager():GetMainCharacterData()
	local nLvl = data:GetValue(fire.pb.attr.AttrType.LEVEL)
    local id = 0
    local strMsg = 0
    id = 216
    strMsg = 11414
    local manager = require"logic.huodong.huodongmanager".getInstanceNotCreate()
    if manager then
        manager.m_boxuezhe = true
    end
    local msg = MHSD_UTILS.get_resstring(strMsg)
    gGetMessageManager():AddMessageBox("",msg,ClickYes,self,ClickNo,self,eMsgType_Normal,30000,0,0,nil,MHSD_UTILS.get_resstring(996),MHSD_UTILS.get_resstring(997))
end
--–≠÷˙Œ Ã‚
local ssendimpexamassist = require "protodef.fire.pb.npc.ssendimpexamassist"
function ssendimpexamassist:process()
    LogInfo("ssendimpexamassist:process")
    local dlg = require"logic.wisdomtrialdlg.wisdomtrialdlg".getInstanceAndShow()
    if dlg then
        dlg:AnswerQuestionDelect(self)
    end
end
local squeryimpexamstate = require"protodef.fire.pb.npc.squeryimpexamstate"
function squeryimpexamstate:process()
    if self.isattend == 1 then
        local manager = require"logic.huodong.huodongmanager".getInstanceNotCreate()
        if manager then
            manager.m_boxuezhe = true
        end
    else
        local manager = require"logic.huodong.huodongmanager".getInstanceNotCreate()
        if manager then
            manager.m_boxuezhe = false
        end
    end
end
--÷«ª€ ‘¡∂ end

local scanelect = require "protodef.fire.pb.school.scanelect"
function scanelect:process()
    require "logic.schoolLeader.leaderElectionDlg"
    leaderElectionDlg.getInstanceAndShow()
end

local ssendcandidates = require "protodef.fire.pb.school.ssendcandidates"
function ssendcandidates:process()
    require "logic.schoolLeader.leaderManager":initData(self.candidatelist)
    require "logic.schoolLeader.leaderManager":initOtherInfo(self.alreadyvote, self.shouxikey)
    require "logic.schoolLeader.leaderDlg"
    leaderDlg.getInstanceAndShow()
end

local svotecandidate = require "protodef.fire.pb.school.svotecandidate"
function svotecandidate:process()
    require "logic.schoolLeader.leaderManager":setSelectedInfo(self.candidatelist)
    require "logic.schoolLeader.leaderDlg"
    local dlg = leaderDlg.getInstanceNotCreate()
    if dlg then
        dlg:refreshTickets(self.candidatelist[1].roleid, self.candidatelist[1].tickets)
    end
end

local smyelector = require "protodef.fire.pb.school.smyelector"
function smyelector:process()
    require "logic.schoolLeader.leaderElectionDlg"
    local dlg = leaderElectionDlg.getInstanceAndShow()
    if dlg then
        dlg:setContentText(self.electorwords)
    end
end

local sacceptlivediebattlefirst = require "protodef.fire.pb.battle.livedie.sacceptlivediebattlefirst"
function sacceptlivediebattlefirst:process()
    if self.hostroleid == 0 then    
        require "logic.npc.npcdialog".getInstance():AddTipsMessage(134,161525, MHSD_UTILS.get_msgtipstring(162129))
    else    
	    local strBuild = StringBuilder:new()	
	    strBuild:Set("parameter1", self.hostrolename)
	    local str = strBuild:GetString(MHSD_UTILS.get_msgtipstring(162128))
	    strBuild:delete()
        require "logic.npc.npcdialog".getInstance():showMsgDialog(134,161525,{910105,910108}, str)
    end
end

local p = require "protodef.fire.pb.npc.snpctiaozhan"
function p:process()
	require "logic.npc.npctiaozhan".getInstanceOrNot():refreshList(self.tz1,self.tz2,self.tz3,self.tz4,self.tz5,self.tz6,self.tz7)
	--require "logic.workshop.zuoqi.zuoqi".getInstanceNotCreate():refreshZQTable(self.zuoqix)
end

return tryCloseBox
