require "protodef.rpcgen.fire.pb.circletask.activequestdata"

local SRefreshActivityListFinishTimes = require "protodef.fire.pb.mission.activelist.srefreshactivitylistfinishtimes"
function SRefreshActivityListFinishTimes:process()
    getHuodongDlg().createDlg(self.activities, self.activevalue, self.chests,self.recommend, self.closeids)
	--gGetNetConnection():send(fire.pb.mission.CGetActivityInfo())
	local xlDlg3 = require "logic.guaji.guajidia"
	xlDlg3.createDlg(self.activities, self.activevalue, self.chests,self.recommend, self.closeids)
end

local SActivityOpen = require "protodef.fire.pb.mission.activelist.sactivityopen"
function SActivityOpen:process()
	LogInfo("enter sactivityopen process")
    local manager = require"logic.huodong.huodongmanager".getInstanceNotCreate()
    if manager then
        manager:getOpenActivity(self.activityid)
    end
	--ActivityManager.openActivity(self.activityid)	
end



local scopydestroytime = require "protodef.fire.pb.mission.scopydestroytime"
function scopydestroytime:process()
 
end


local susetreasuremap = require "protodef.fire.pb.mission.susetreasuremap"
function susetreasuremap:process()
	print("susetreasuremap:process()")
	--local dlg = require "logic.treasureMap.treasureChosedDlg".getInstanceAndShow()
	--dlg:initTreasureInfo(self.maptype, self.awardid, self.itemids)
    --�ر�ͼ
    local time = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(310).value) -- ���������ٶ�
    local str = MHSD_UTILS.get_resstring(11457)
    ReadTimeProgressDlg.Start(str, 10, time * 1000, 0, 0)
    ReadTimeProgressDlg.setTreasureData(self.maptype, self.awardid)

end

local sgetinstancestate = require("protodef.fire.pb.mission.sgetinstancestate")
function sgetinstancestate:process()
	LogInfo("sgetinstancestate:process()")
	local fubenManager = require("logic.fuben.fubenmanager").getInstance()
	fubenManager:sgetinstancestate_process(self)
end

local sgetactivityinfo = require "protodef.fire.pb.mission.sgetactivityinfo"
function sgetactivityinfo:process()
	LogInfo("enter SGetActivityInfo process")
    if HuoDongManager.getInstanceNotCreate() then
		local huodongManager = HuoDongManager.getInstanceNotCreate()
        huodongManager.m_activityinfos = self.activityinfos
        getHuodongDlg().HasOpenActicity()
        huodongManager:getHasActivity()
        local  dlgInstance = getHuodongDlg().getInstanceNotCreate()
        if dlgInstance then 
            dlgInstance:refreshActiveGift()
            dlgInstance:refreshlist(dlgInstance.m_type)
            dlgInstance:SortTable()
        end
    end
end

local saskintoinstance = require("protodef.fire.pb.mission.saskintoinstance")
function saskintoinstance:process()
	LogInfo("saskintoinstance:process()")
	require("logic.task.taskhelperprotocol").saskintoinstance_process(self)

end

local sgetarchiveinfo = require("protodef.fire.pb.mission.sgetarchiveinfo")
function sgetarchiveinfo:process()
    local guidemanager = require("logic.guide.guidemanager").getInstance()
	LogInfo("sgetarchiveinfo:process()")
    
    for i,v in pairs (self.archiveinfos) do
        guidemanager.m_CellStatus[v.archiveid] = v.state
    end
    guidemanager:HasHongdian()
	if LogoInfoDialog.getInstanceNotCreate() then
		LogoInfoDialog.getInstanceNotCreate():RefreshBtnZhiyin()
	end 
    local zhandouanniu = require"logic.battle.zhandouanniu".getInstanceNotCreate()
    if zhandouanniu then
        zhandouanniu:refreshZhiyinBtn()
    end
    local dlg = require("logic.guide.guidecoursedlg").getInstanceNotCreate()
    if dlg then 
        dlg:refresh()
    end
    
end
local swaitrolltime = require("protodef.fire.pb.mission.swaitrolltime")
function swaitrolltime:process()
    require("logic.task.taskhelperprotocol").swaitrolltime_process(self)
end
local senterbingfengland = require("protodef.fire.pb.instancezone.bingfeng.senterbingfengland")
function senterbingfengland:process()
    local info = {}
    info.instzoneid = self.landid
    info.stage = self.stage
    info.autogo = self.autogo
    info.finishstage = self.finishstage
    require("logic.bingfengwangzuo.bingfengwangzuomanager"):setBingfengInfo(info)
    local dlg = require("logic.bingfengwangzuo.bingfengwangzuoTaskTips").getInstanceNotCreate()
    if dlg then
        dlg:updateInfo( self.landid, self.stage, self.autogo, self.finishstage)
    end
    require("logic.bingfengwangzuo.bingfengwangzuoTips").DestroyDialog()
    require "logic.bingfengwangzuo.bingfengwangzuodlg"
    bingfengwangzuoDlg.DestroyDialog()
end
local splayxianjingcg = require("protodef.fire.pb.mission.splayxianjingcg")
function splayxianjingcg:process()
    local dlg = require"logic.petandusericon.userandpeticon".getInstanceNotCreate()
    if dlg then
        dlg:SetHpAndMpPro()
    end
end
local saddtreasuremap = require("protodef.fire.pb.mission.saddtreasuremap")
function saddtreasuremap:process()
    local Taskuseitemdialog = require("logic.task.taskuseitemdialog")
    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    Taskuseitemdialog.getInstanceAndLoadData(331301, roleItemManager:getLastAddeditemkey())  -- �߼��ر�ͼ
end
local sbingfenglandinfo = require("protodef.fire.pb.instancezone.bingfeng.sbingfenglandinfo")
function sbingfenglandinfo:process()
    if gGetDataManager() then
        if gGetDataManager():GetMainCharacterLevel() < 40 then -- 秘境降妖等级
            if gGetGameUIManager() then
                local msg = MHSD_UTILS.get_resstring(2952);
                GetCTipsManager():AddMessageTip(msg)
            end
        else
		    bingfengwangzuoDlg.getInstanceAndShow(self.stage, self.yesterdaystage) 
		    bingfengwangzuoDlg.refreshMapInfo(self.landid, self.stage)
		    bingfengwangzuoDlg.refreshLeaveTime(self.entertimes)

        end
    end
end
local scanenterbingfeng = require "protodef.fire.pb.instancezone.bingfeng.scanenterbingfeng"
function scanenterbingfeng:process()
    local huodongmanager = require"logic.huodong.huodongmanager".getInstance()

    if self.finish == 1 then
        huodongmanager.m_bingfengwangzuoFinish = true
    else 
        huodongmanager.m_bingfengwangzuoFinish = false
    end

    local HuodongDlg = getHuodongDlg()
    local  dlgInstance = HuodongDlg.getInstanceNotCreate()
    if dlgInstance then 
         dlgInstance:refreshlist(dlgInstance.m_type)
         dlgInstance:SortTable()
    end
end


local susemissionitemfail = require("protodef.fire.pb.mission.susemissionitemfail")
function susemissionitemfail:process()
    if not gGetGameUIManager() then
        return
    end
    local strTip = require ("utils.mhsdutils").get_msgtipstring(141584)
    GetCTipsManager():AddMessageTip(strTip)

    MainPackDlg_EndUseTaskItem()
end

local strackedmissions = require("protodef.fire.pb.mission.strackedmissions")
function strackedmissions:process()
    require("logic.task.taskhelperprotocol").strackedmissions_process(self)
end

local sacceptmission = require("protodef.fire.pb.mission.sacceptmission")
function sacceptmission:process()
    require("logic.task.taskhelperprotocol").sacceptmission_process(self)
end


local  srefreshmissionstate = require("protodef.fire.pb.mission.srefreshmissionstate")
function srefreshmissionstate:process()
    require("logic.task.taskhelperprotocol").srefreshmissionstate_process(self)
end

local srefreshmissionvalue = require("protodef.fire.pb.mission.srefreshmissionvalue")
function srefreshmissionvalue:process()
    require("logic.task.taskhelperprotocol").srefreshmissionvalue_process(self)
end

local sreqmissioncanaccept = require("protodef.fire.pb.mission.sreqmissioncanaccept")
function sreqmissioncanaccept:process()
    require("logic.task.taskhelperprotocol").sreqmissioncanaccept_process(self)
end

local snpcfollowstart = require("protodef.fire.pb.mission.snpcfollowstart")
function snpcfollowstart:process()
    require("logic.task.taskhelperprotocol").snpcfollowstart_process(self)
end

local snpcfollowend = require("protodef.fire.pb.mission.snpcfollowend")
function snpcfollowend:process()
    require("logic.task.taskhelperprotocol").snpcfollowend_process(self)
end


local snpcfollowend = require("protodef.fire.pb.mission.strackmission")
function snpcfollowend:process()
    
end


local sfairylandstatus = require("protodef.fire.pb.mission.sfairylandstatus")
function sfairylandstatus:process()
    if not gGetScene() then
		return;
	end
	gGetScene():SetDreamStatus(status);
end

local ssendactivequestlist = require("protodef.fire.pb.circletask.ssendactivequestlist")
function ssendactivequestlist:process()
	if GetTaskManager() == nil then
		return
	end
    for k,v in pairs(self.memberlist) do
        local questData = ActiveQuestData:new()
        questData.questid = v.questid
	    questData.queststate = v.queststate
	    questData.dstnpckey = v.dstnpckey
	    questData.dstnpcid = v.dstnpcid
	    questData.dstmapid = v.dstmapid
	    questData.dstx = v.dstx
	    questData.dsty = v.dsty
	    questData.dstitemid = v.dstitemid
	    questData.sumnum = v.sumnum
	    questData.npcname = v.npcname
	    questData.rewardexp = v.rewardexp
	    questData.rewardmoney = v.rewardmoney
	    questData.rewardsmoney = v.rewardsmoney
	    for k,v in pairs(v.rewarditems) do
            questData.rewarditems:push_back(v)
        end
        GetTaskManager():AddActiveQuest(questData)
    end
end

local srefreshactivequest = require("protodef.fire.pb.circletask.srefreshactivequest")

function srefreshactivequest:process()
	if GetTaskManager() == nil then
		return
	end
    local questData = ActiveQuestData:new()
    questData.questid = self.questdata.questid
	questData.queststate = self.questdata.queststate
	questData.dstnpckey = self.questdata.dstnpckey
	questData.dstnpcid = self.questdata.dstnpcid
	questData.dstmapid = self.questdata.dstmapid
	questData.dstx = self.questdata.dstx
	questData.dsty = self.questdata.dsty
	questData.dstitemid = self.questdata.dstitemid
	questData.sumnum = self.questdata.sumnum
	questData.npcname = self.questdata.npcname
	questData.rewardexp = self.questdata.rewardexp
	questData.rewardmoney = self.questdata.rewardmoney
	questData.rewardsmoney = self.questdata.rewardsmoney
    for k,v in pairs(self.questdata.rewarditems) do
        questData.rewarditems:push_back(v)
    end
	GetTaskManager():AddActiveQuest(questData)
end

local srefreshspecialquest = require("protodef.fire.pb.circletask.srefreshspecialquest")
function srefreshspecialquest:process()
	if GetTaskManager() == nil then
		return;
	end
    local quest = GetTaskManager():GetSpecialQuest(self.questid)
	if quest == nil then
        require "protodef.rpcgen.fire.pb.circletask.specialqueststate"
        local spcQuestState = SpecialQuestState:new()
		if queststate == spcQuestState.SUCCESS then
			return;
		end
		local quest1 = stSpecialQuest:new()
		quest1.questid = self.questid
		quest1.questtype = self.questtype
		quest1.queststate = self.queststate
		quest1.round = self.round
		quest1.sumnum = self.sumnum
		quest1.dstmapid = self.dstmapid
		quest1.dstnpckey = self.dstnpckey
		quest1.dstnpcname = self.dstnpcname
		quest1.dstnpcid = self.dstnpcid
		quest1.dstitemid = self.dstitemid
		quest1.dstx = self.dstx
		quest1.dsty = self.dsty
		quest1.dstitemnum = self.dstitemnum
		quest1.dstitemid2 = self.dstitemid2
		quest1.dstitemidnum2 = self.dstitemidnum2
		quest1.validtime = self.validtime
		quest1.islogin = self.islogin
		quest1.name = GetNewSpecialQuestName(self.questtype)
		GetTaskManager():AddSpecialQuest(quest1)
		GetTaskManager():AddNewQuestToTraceList(self.questid)
	else
		local npckeyOld = quest.dstnpckey
		local npcidOld = quest.dstnpcid
		local nTaskIdOld = quest.questtype
		if questtype == 0 then
			GetTaskManager():RemoveSpecialQuest(self.questid);
		else
			quest.queststate = self.queststate
			quest.round = self.round
			quest.sumnum = self.sumnum
			quest.dstmapid = self.dstmapid
			quest.dstnpckey = self.dstnpckey
			quest.dstnpcname = self.dstnpcname
			quest.dstnpcid = self.dstnpcid
			quest.dstitemid = self.dstitemid
			quest.dstx = self.dstx
			quest.dsty = self.dsty
			quest.dstitemnum = self.dstitemnum
			quest.dstitemid2 = self.dstitemid2
			quest.dstitemidnum2 = self.dstitemidnum2
			quest.validtime = self.validtime
			quest.islogin = self.islogin
			quest.name = GetNewSpecialQuestName(self.questtype)
			if quest.questtype ~= self.questtype then
				quest.questtype = self.questtype
				GetTaskManager():AddNewQuestToTraceList(self.questid);
			end
		end
		if npckeyOld ~= self.dstnpckey or npcidOld ~= self.dstnpcid then
			GetTaskManager():RefreshNpcState(npckeyOld, npcidOld)
		end
	end
    GetTaskManager():EventUpdateLastQuestFire(self.questid)
	GetTaskManager():RefreshNpcState(self.dstnpckey, self.dstnpcid)
end


