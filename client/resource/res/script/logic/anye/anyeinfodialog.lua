require "logic.dialog"
require "logic.chat.chatcommon"

require "protodef.rpcgen.fire.pb.circletask.specialqueststate"
local spcQuestState = SpecialQuestState:new()

Anyeinfodialog = {}
setmetatable(Anyeinfodialog, Dialog)
Anyeinfodialog.__index = Anyeinfodialog
local _instance;


--//===============================
function Anyeinfodialog:OnCreate()
    Dialog.OnCreate(self)
    SetPositionScreenCenter(self:GetWindow())
    local winMgr = CEGUI.WindowManager:getSingleton()

    self.nodeBg = winMgr:getWindow("anyemaxituan/bg")
    self.labelTaskName = winMgr:getWindow("anyemaxituanrenwuxiangqing/di1/mingzi") 
    self.richBoxDesc = CEGUI.toRichEditbox(winMgr:getWindow("anyemaxituanrenwuxiangqing/renwuxiangqing"))
    self.richBoxDesc:setReadOnly(true)

    self.btnDo = CEGUI.toPushButton(winMgr:getWindow("anyemaxituanrenwuxiangqing/wanchengrenwu"))
    self.btnDo:subscribeEvent("MouseClick", Anyeinfodialog.clickDoTask, self) --MouseClick MouseButtonUp --Clicked

    self.btnRenxing = CEGUI.toPushButton(winMgr:getWindow("anyemaxituanrenwuxiangqing/renxingyixia"))
    self.btnRenxing:subscribeEvent("MouseClick", Anyeinfodialog.clickRenxing, self) 
    self.btnRenxing:setVisible(false)
    self.btnShijie = CEGUI.toPushButton(winMgr:getWindow("anyemaxituanrenwuxiangqing/shijieqiuzhu"))
    self.btnShijie:subscribeEvent("MouseClick", Anyeinfodialog.clickShiqie, self) 

    self.btnGonghui = CEGUI.toPushButton(winMgr:getWindow("anyemaxituanrenwuxiangqing/gonghuiqiuzhu"))
    self.btnGonghui:subscribeEvent("MouseClick", Anyeinfodialog.clickGonghui, self) 

    self.btnClose = CEGUI.toPushButton(winMgr:getWindow("anyemaxituanrenwuxiangqing/guanbianniu"))
    self.btnClose:subscribeEvent("MouseClick", Anyeinfodialog.clickClose, self) 

    self.btnFushi = CEGUI.toPushButton(winMgr:getWindow("anyemaxituanrenwuxiangqing/renxingyixia/renxingyixia2"))
    self.btnFushi:subscribeEvent("MouseClick", Anyeinfodialog.clickRenxingFushi, self) 

    self.btnShengwang = CEGUI.toPushButton(winMgr:getWindow("anyemaxituanrenwuxiangqing/renxingyixia/renxingyixia1"))
    self.btnShengwang:subscribeEvent("MouseClick", Anyeinfodialog.clickRenxingShengwang, self)    

end

function Anyeinfodialog:refreshRenxingBtn()
     self.btnFushi:setVisible(false)
     self.btnShengwang:setVisible(self.bRencingShow)
end
--[[
<protocol name="CRenXingAnYeTask" type="21024" maxsize="65535" prior="1" tolua="3">���԰�ҹ��Ϸ������
			<variable name="taskpos" type="int" />������λ
			<variable name="moneytype" type="int" />�������� MoneyTypeö�ٶ��� 3��ʯ 7����
		</protocol>
--]]
function Anyeinfodialog:sendRenxing(nMoneyType)
     local taskManager = require("logic.task.taskmanager").getInstance()
    local oneTaskData =  taskManager.vAnyeTask[self.nIndex]
    if not oneTaskData then
        return nil
    end

    local nTaskId = oneTaskData.id

    if nMoneyType==3 then
        local nCurCount = taskManager.nRenxingNum + 1
        local strValue = GameTable.common.GetCCommonTableInstance():getRecorder(311).value
        local nAllNum = tonumber(strValue)
        if nCurCount > nAllNum then
            nCurCount = nAllNum
        end
	    local needMoneyTable = BeanConfigManager.getInstance():GetTableByName("circletask.crenxingcirctaskcost"):getRecorder(nCurCount)
	    local nNeedStone = 0
        if needMoneyTable and needMoneyTable.id ~= -1 then
		     nNeedStone =  needMoneyTable.stonecost
        end
        local curStone = CurrencyManager.getOwnCurrencyMount(fire.pb.game.MoneyType.MoneyType_HearthStone)
        if curStone < nNeedStone then
            CurrencyManager.handleCurrencyNotEnough(fire.pb.game.MoneyType.MoneyType_HearthStone)
            Anyeinfodialog.DestroyDialog()
            return 
        end

    end

    local crenxinganyetask = require "protodef.fire.pb.circletask.anye.crenxinganyetask":new()
    crenxinganyetask.taskpos = oneTaskData.pos
    crenxinganyetask.moneytype = nMoneyType
	require "manager.luaprotocolmanager":send(crenxinganyetask)

    Anyeinfodialog.DestroyDialog()

end

function Anyeinfodialog:clickRenxingFushi(args)
    self:sendRenxing(3) 
    
end


function Anyeinfodialog:clickRenxingShengwang(args)
   self:sendRenxing(7) 
end

function Anyeinfodialog:clickClose(args)
    Anyeinfodialog.DestroyDialog()
end

function Anyeinfodialog:refreshUI(nIndex)
    self.nIndex = nIndex
    local taskManager = require("logic.task.taskmanager").getInstance()
    local oneTaskData =  taskManager.vAnyeTask[self.nIndex]
    if not oneTaskData then
        return nil
    end

    local nTaskId = oneTaskData.id

    local anyeTable = BeanConfigManager.getInstance():GetTableByName("circletask.canyemaxituanconf"):getRecorder(nTaskId)
	if anyeTable == nil then
		return 
	end

    self.labelTaskName:setText(anyeTable.strtaskname)
    local nLevel = GetMainCharacter():GetLevel()
	local nSchoolId =  gGetDataManager():GetMainCharacterSchoolID()
    local stTaskName = anyeTable.strtaskname
    local strTaskDesc = anyeTable.strtaskdesc
    local nGroupId = anyeTable.group

    local nQuality = require("logic.task.taskhelpertable").GetQuality(nSchoolId,nGroupId,nLevel)
    oneTaskData.nQuality = nQuality

    local sb = StringBuilder:new()
    require("logic.task.taskmanager").getInstance():getTaskInfoCorrectSb(oneTaskData,sb)
    strTaskDesc = sb:GetString(strTaskDesc)
    sb:delete()

    self.richBoxDesc:Clear()
	self.richBoxDesc:AppendParseText(CEGUI.String(strTaskDesc))
	self.richBoxDesc:Refresh()
	self.richBoxDesc:getVertScrollbar():setScrollPosition(0)

    local taskManager = require("logic.task.taskmanager").getInstance()
    local nCurCount = taskManager.nRenxingNum + 1
    local strValue = GameTable.common.GetCCommonTableInstance():getRecorder(311).value
    local nAllNum = tonumber(strValue)
    if nCurCount > nAllNum then
        nCurCount = nAllNum
    end
	local needMoneyTable = BeanConfigManager.getInstance():GetTableByName("circletask.crenxingcirctaskcost"):getRecorder(nCurCount)
	if needMoneyTable and needMoneyTable.id ~= -1 then
		local nStoneNum =  needMoneyTable.stonecost
		local nShengwangNum = needMoneyTable.xiayicost
        

        local strFushizi = require("utils.mhsdutils").get_msgtipstring(166074) --stone
        local strShengwangzi = require("utils.mhsdutils").get_msgtipstring(166075) --stone

        local sb = StringBuilder.new()
		sb:Set("parameter1",tostring(nStoneNum))
	    strFushizi = sb:GetString(strFushizi)

        sb:Set("parameter1",tostring(nShengwangNum))
	    strShengwangzi = sb:GetString(strShengwangzi)

		sb:delete()

        self.btnFushi:setText(strFushizi)
        self.btnShengwang:setText(strShengwangzi)
	end
end



--[[
self.pos = 0
	self.id = 0
	self.kind = 0
	self.state = 0
	self.dstitemid = 0
	self.dstitemnum = 0
	self.dstnpckey = 0
	self.dstnpcid = 0

--]]


function Anyeinfodialog:clickCommitItem(commitDlg)
    local taskManager = require("logic.task.taskmanager").getInstance()
    local oneTaskData =  taskManager.vAnyeTask[self.nIndex]
    if not oneTaskData then
        return nil
    end

    if not gGetDataManager() then
        return
    end
    local nTaskId = oneTaskData.id
    local anyeTable = BeanConfigManager.getInstance():GetTableByName("circletask.canyemaxituanconf"):getRecorder(nTaskId)
	if anyeTable == nil then
		return 
	end

    local submitUnit  = require "protodef.rpcgen.fire.pb.circletask.anye.submitthing":new()
	local nItemKey = commitDlg.nCurItemKey
	submitUnit.key = nItemKey
	submitUnit.num = oneTaskData.dstitemnum

    local csubmitthings = require "protodef.fire.pb.circletask.anye.csubmitthings":new()
	csubmitthings.taskpos = oneTaskData.pos
    csubmitthings.taskid = anyeTable.nactivetype
    csubmitthings.taskrole = gGetDataManager():GetMainCharacterID()
    csubmitthings.submittype = 1 --�ύ������ 1���� 2���� 3��Ǯ
    csubmitthings.things[1] = submitUnit
	require "manager.luaprotocolmanager":send(csubmitthings)

    commitDlg:DestroyDialog()

end

function Anyeinfodialog:clickCommitPet(commitDlg)
    local taskManager = require("logic.task.taskmanager").getInstance()
    local oneTaskData =  taskManager.vAnyeTask[self.nIndex]
    if not oneTaskData then
        return nil
    end

    if not gGetDataManager() then
        return
    end
    local nTaskId = oneTaskData.id
    local anyeTable = BeanConfigManager.getInstance():GetTableByName("circletask.canyemaxituanconf"):getRecorder(nTaskId)
	if anyeTable == nil then
		return 
	end

    local submitUnit  = require "protodef.rpcgen.fire.pb.circletask.anye.submitthing":new()
	local nItemKey = commitDlg.nCurItemKey
	submitUnit.key = nItemKey
	submitUnit.num = oneTaskData.dstitemnum
    local csubmitthings = require "protodef.fire.pb.circletask.anye.csubmitthings":new()
	csubmitthings.taskpos = oneTaskData.pos
    csubmitthings.taskid = anyeTable.nactivetype
    csubmitthings.taskrole = gGetDataManager():GetMainCharacterID()
    csubmitthings.submittype = 2 --�ύ������ 1���� 2���� 3��Ǯ
    csubmitthings.things[1] = submitUnit
	require "manager.luaprotocolmanager":send(csubmitthings)
end

function Anyeinfodialog:commitTask(oneTaskData)
    local nTaskDetailType = oneTaskData.kind
    local nTaskTypeId = oneTaskData.id
    local nNpcKey = 0

		if nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_ItemFind then 
			local nItemId = oneTaskData.dstitemid
			local vItemKey = {}
			require("logic.task.taskhelperprotocol").GetItemKeyWithTableIdUseToItemTable(nItemId,vItemKey)
            local Taskcommititemdialog = require "logic.task.taskcommititemdialog" 
	        local eType = 0--Taskcommititemdialog.eCommitType.eAnye
			local commitItemDlg = require "logic.task.taskcommititemdialog".getInstance()
			commitItemDlg:SetCommitItemId(vItemKey,nNpcKey,eType,nTaskTypeId)
            commitItemDlg:setDelegateTarget(self,Anyeinfodialog.clickCommitItem)
		elseif nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_PetCatch then
			local nPetId = oneTaskData.dstitemid
			local vPetKey = {}
			require("logic.task.taskhelperprotocol").GetHavePetWithIdUseToItemTable(nPetId,vPetKey)
			local commitItemDlg = require "logic.task.taskcommitpetdialog".getInstance()
			commitItemDlg:SetCommitItemId(vPetKey,nNpcKey,nTaskTypeId)
            commitItemDlg:setDelegateTarget(self,Anyeinfodialog.clickCommitPet)
		end
end

function Anyeinfodialog:clickDoTask(args)
    local taskManager = require("logic.task.taskmanager").getInstance()
    local oneTaskData =  taskManager.vAnyeTask[self.nIndex]
    if not oneTaskData then
        return nil
    end

    local eTaskState = oneTaskData.state
    if eTaskState == spcQuestState.DONE then
        self:commitTask(oneTaskData)
        Anyeinfodialog.DestroyDialog()
        return
    elseif eTaskState == spcQuestState.SUCCESS then
        GetCTipsManager():AddMessageTipById(166081)
        return
    end

    local nTaskDetailType = oneTaskData.kind
    local nItemId = oneTaskData.dstitemid
    local nNpcId  =  oneTaskData.dstnpcid

    if nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_ItemFind then
        local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
	    if itemAttrCfg then
		    nNpcId = itemAttrCfg.npcid2
	    end
        self:gotoNpc(nNpcId,oneTaskData.id)
	--//ְҵ-�������
    elseif nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_PetCatch then
        local petAttrCfg = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(nItemId)
		if petAttrCfg then
			nNpcId = petAttrCfg.nshopnpcid
		end
        self:gotoNpc(nNpcId,oneTaskData.id)
    elseif nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_ChallengeNpc then
        require("logic.task.taskhelper").gotoNpc(nNpcId)
        
    elseif nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_Patrol then
        self:gotoTaskAutoBattle(oneTaskData)
        
    end

    require("logic.anye.anyemaxituandialog").DestroyDialog()
    Anyeinfodialog.DestroyDialog()
end

function Anyeinfodialog:gotoNpc(nNpcId,nTaskTypeId)
    	local flyWalkData = {}
	 require("logic.task.taskhelpergoto").GetInitedFlyWalkData(flyWalkData)
	--//-======================================
	flyWalkData.nTaskTypeId = nTaskTypeId
	flyWalkData.nNpcId = nNpcId
	--//-======================================
	require("logic.task.taskhelpergoto").FlyOrWalkTo(flyWalkData)
end

function Anyeinfodialog:gotoTaskAutoBattle(anyeTaskData)
	if not anyeTaskData then
        return
    end
    local nMapId = anyeTaskData.dstnpcid
		
		local nRandX = 0
		local nRandY = 0
		nRandX,nRandY = require("logic.task.taskhelper").GetRandPosWithMapId(nMapId)
		local nCurMapId = gGetScene():GetMapID()
		--//=======================================
		local nTargetPosX = nRandX
		local nTargetPosY = nRandY
		--//=======================================
		
		local flyWalkData = {}
		require("logic.task.taskhelpergoto").GetInitedFlyWalkData(flyWalkData)
		--//-======================================
		flyWalkData.nMapId = nMapId
		--flyWalkData.nNpcId = nNpcId
		flyWalkData.nRandX = nRandX
		flyWalkData.nRandY = nRandY
		flyWalkData.bXunLuo = 1
		flyWalkData.nTargetPosX = nTargetPosX
		flyWalkData.nTargetPosY = nTargetPosY
		--//-======================================
		require("logic.task.taskhelpergoto").FlyOrWalkTo(flyWalkData)
end

function Anyeinfodialog:clickRenxing(args)
    local taskManager = require("logic.task.taskmanager").getInstance()

    local oneTaskData =  taskManager.vAnyeTask[self.nIndex]
    if not oneTaskData then
        return nil
    end
    local nTaskDetailType = oneTaskData.kind
    if  nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_ChallengeNpc or
         nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_Patrol then

        if GetBattleManager() and GetBattleManager():IsInBattle() then
            GetCTipsManager():AddMessageTipById(166094)
			return
	    end
    end

    self.bRencingShow = not self.bRencingShow
    self:refreshRenxingBtn()
     
end


function Anyeinfodialog:clickShiqie(args)
   self:sendToChannel(ChannelType.CHANNEL_WORLD)
end

function Anyeinfodialog:clickGonghui(args)
    local datamanager = require "logic.faction.factiondatamanager"
    local bIn = datamanager:IsHasFaction()
    if bIn == false then
        local strNoGonghuizi =   require("utils.mhsdutils").get_resstring(11479)
        GetCTipsManager():AddMessageTip(strNoGonghuizi)
        return 
    end

    local taskManager = require("logic.task.taskmanager").getInstance()
    if taskManager.fFactionHelpCd > 0 then
        
        local nFactionHelpCd = taskManager.fFactionHelpCd/1000
        nFactionHelpCd = math.floor(nFactionHelpCd)
        if nFactionHelpCd ==0 then
            nFactionHelpCd = 1
        end
        --160238
        local strWaitzi =   require("utils.mhsdutils").get_msgtipstring(160238)
        local sb = StringBuilder.new()
        sb:Set("parameter1",tostring(nFactionHelpCd))
        strWaitzi = sb:GetString(strWaitzi)
        sb:delete()
        
        GetCTipsManager():AddMessageTip(strWaitzi)
        return 
    end
    taskManager:startFactionHelpCd()
    self:sendToChannel(ChannelType.CHANNEL_CLAN)
    --GetCTipsManager():AddMessageTipById(166089)
end

function Anyeinfodialog:sendToChannel(nChannel)
     local taskManager = require("logic.task.taskmanager").getInstance()
    local oneTaskData =  taskManager.vAnyeTask[self.nIndex]
    if not oneTaskData then
        return nil
    end

    local eTaskState = oneTaskData.state
    if eTaskState == spcQuestState.SUCCESS then
        return
    end

    local strChatContent = self:getTaskStringToChat(oneTaskData,nChannel)
    self:sendTaskToChat(strChatContent,nChannel)
    self:showChatDialog(nChannel)

     require("logic.anye.anyemaxituandialog").DestroyDialog()
    Anyeinfodialog.DestroyDialog()
end

function Anyeinfodialog:showChatDialog(nChannel)
    local chatDlg =  CChatOutputDialog.getInstanceNotCreate()
    if chatDlg then
           chatDlg:ToShow()
           chatDlg:ChangeOutChannel(nChannel)
           chatDlg:refreshChannelSel(nChannel)
    else
        chatDlg = CChatOutputDialog:GetSingletonDialogAndShowIt() 
        chatDlg:ChangeOutChannel(nChannel)
        chatDlg:refreshChannelSel(nChannel)
    end
end

function Anyeinfodialog:sendTaskToChat(strChatContent,nChannel)
    
    --wstrStrChat = "<P t="[��������]" roleid="225281" type="8" key="1040000" baseid="2" shopid="0" counter="1040001" bind="0" loseefftime="0" TextColor="FF693F00"></P>"
    local chatCmd = require "protodef.fire.pb.talk.ctranschatmessage2serv".Create()
	chatCmd.messagetype = nChannel
	chatCmd.message = strChatContent --
	chatCmd.checkshiedmessage = ""
	local showInfs = {}
	chatCmd.displayinfos = showInfs
    chatCmd.funtype = 1 --call help
	LuaProtocolManager.getInstance():send(chatCmd)
end

--[[
        self.DISPLAY_ITEM = 1
		self.DISPLAY_PET = 2
		self.DISPLAY_TASK = 8
		self.DISPLAY_TEAM_APPLY = 9
		self.DISPLAY_ROLL_ITEM = 11
		self.DISPLAY_ACTIVITY_ANSWER = 12
		self.DISPLAY_LIVEDIE = 13
		self.DISPLAY_BATTLE = 14
--]]
function Anyeinfodialog:getTaskStringToChat(oneTaskData,nChannel)
    local DisplayInfoType = require("protodef.rpcgen.fire.pb.talk.displayinfo"):new()

	local roleid = gGetDataManager():GetMainCharacterID()
    local ntype = DisplayInfoType.DISPLAY_TASK --task
    local key = oneTaskData.pos
    local baseid = 3 --anyetype
    local shopid = 0
    local counter = 0 --oneTaskData.id 1=taskinfo 2=help other
    local bind = 0
    

    local anyeTable = BeanConfigManager.getInstance():GetTableByName("circletask.canyemaxituanconf"):getRecorder(oneTaskData.id)
	if anyeTable == nil then
		return 
	end
    local strName = anyeTable.strtaskname

    local nTaskDetailType = oneTaskData.kind
    local nItemId = oneTaskData.dstitemid --itemid or petid
    local nItemNum = oneTaskData.dstitemnum
    --local nNpcId  =  oneTaskData.dstnpcid
    
    ----------------------
    counter = 1 --1==taskinfo
    local strTaskContent = "["..strName.."]"
    strTaskContent = "<P t=\""..strTaskContent.."\" "
    strTaskContent = strTaskContent.."roleid=\""..tostring(roleid).."\" "
    strTaskContent = strTaskContent.."type=\""..tostring(ntype).."\" "
    strTaskContent = strTaskContent.."key=\""..tostring(key).."\" "
    strTaskContent = strTaskContent.."baseid=\""..tostring(baseid).."\" "

    strTaskContent = strTaskContent.."shopid=\""..tostring(shopid).."\" "
    strTaskContent = strTaskContent.."counter=\""..tostring(counter).."\" "
    strTaskContent = strTaskContent.."bind=\""..tostring(bind).."\" "
    strTaskContent = strTaskContent.."loseefftime=\""..tostring(0).."\" "
    strTaskContent = strTaskContent.."TextColor=\"".."FF693F00".."\" "
    strTaskContent = strTaskContent.."/>"


    if nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_ItemFind or
       nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_PetCatch then
        
        local strName =  ""
        if  nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_ItemFind then
             ntype = DisplayInfoType.DISPLAY_ITEM
             local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
	         if itemAttrCfg then
		        strName = itemAttrCfg.name
	        end
            
        elseif nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_PetCatch  then
            ntype = DisplayInfoType.DISPLAY_PET 
            local petAttrCfg = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(nItemId)
		    if petAttrCfg then
			    strName = petAttrCfg.name
		    end
        end
        strName = strName.."x"..tostring(nItemNum)

       local strXuqiuzi = require("utils.mhsdutils").get_msgtipstring(166084)
       strName = "["..strName.."]" 

       local strNeedItem = strXuqiuzi.."<T t=\""..strName.."\" "  --link P
        strNeedItem = strNeedItem.."roleid=\""..tostring(roleid).."\" "
        strNeedItem = strNeedItem.."type=\""..tostring(ntype).."\" "  --DISPLAY_ITEM
        strNeedItem = strNeedItem.."key=\""..tostring(0).."\" "
        strNeedItem = strNeedItem.."baseid=\""..tostring(nItemId).."\" "  --4 =user type 3=anye
        strNeedItem = strNeedItem.."shopid=\""..tostring(0).."\" "
        strNeedItem = strNeedItem.."counter=\""..tostring(0).."\" "
        strNeedItem = strNeedItem.."bind=\""..tostring(0).."\" "
        strNeedItem = strNeedItem.."loseefftime=\""..tostring(0).."\" "
        strNeedItem = strNeedItem.."TextColor=\"".."ff02972c".."\" "
        strNeedItem = strNeedItem.."/>"

       strTaskContent= strTaskContent..strNeedItem --����Ѫ��ʯx3
       ------------------------------
        counter = 2 --1==help other btn
        local strHelpeotherzi = require("utils.mhsdutils").get_msgtipstring(166068) --�������

        local nnNowTime = gGetServerTime() /1000
        local strContent2 = "["..strHelpeotherzi.."]" 
        strContent2 = "<P t=\""..strContent2.."\" "
        strContent2 = strContent2.."roleid=\""..tostring(roleid).."\" "
        strContent2 = strContent2.."type=\""..tostring(DisplayInfoType.DISPLAY_TASK).."\" "
        strContent2 = strContent2.."key=\""..tostring(key).."\" "
        strContent2 = strContent2.."baseid=\""..tostring(baseid).."\" "
        strContent2 = strContent2.."shopid=\""..tostring(shopid).."\" "
        strContent2 = strContent2.."counter=\""..tostring(counter).."\" "
        strContent2 = strContent2.."bind=\""..tostring(bind).."\" "
        strContent2 = strContent2.."loseefftime=\""..tostring(nnNowTime).."\" "
        strContent2 = strContent2.."TextColor=\"".."ff02972c".."\" "
        strContent2 = strContent2.."/>"
        
        strTaskContent = strTaskContent..strContent2
      
    elseif  nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_ChallengeNpc or
            nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_Patrol then
        local nLeaderId =  gGetDataManager():GetMainCharacterID()
        if not GetTeamManager():IsOnTeam()  then
            GetTeamManager():RequestCreateTeam()
        else
                local pMember =  GetTeamManager():GetTeamLeader()
                if pMember then
                    nLeaderId = pMember.id
                end
        end
        local strJoinTeam = require "utils.mhsdutils".get_resstring(11306)--strJoinTeam = "<R t="[�������]" leaderid="$leaderid$" c="ff02972c" />"
        local sb = StringBuilder:new()
	    sb:Set("leaderid", tostring(nLeaderId))
	    strJoinTeam = sb:GetString(strJoinTeam)
	    sb:delete()
        strTaskContent = strTaskContent..strJoinTeam
    end
    
    --local strQiuzhuzi = require "utils.mhsdutils".get_msgtipstring(166065)
    local strUserName = gGetDataManager():GetMainCharacterName()
    
    local strUserToHelpzi = require("utils.mhsdutils").get_msgtipstring(166083)
    local strXuqiuzi = require("utils.mhsdutils").get_msgtipstring(166084)
        strUserName = "["..strUserName.."]" 
        strUserName = "<T t=\""..strUserName.."\" "
        strUserName = strUserName.."roleid=\""..tostring(roleid).."\" "
        strUserName = strUserName.."type=\""..tostring(15).."\" "  --DISPLAY_ITEM  15 =showuser
        strUserName = strUserName.."key=\""..tostring(0).."\" "
        strUserName = strUserName.."baseid=\""..tostring(0).."\" "  --4 =user type 3=anye
        strUserName = strUserName.."shopid=\""..tostring(0).."\" "
        strUserName = strUserName.."counter=\""..tostring(0).."\" "
        strUserName = strUserName.."bind=\""..tostring(0).."\" "
        strUserName = strUserName.."loseefftime=\""..tostring(0).."\" "
        strUserName = strUserName.."TextColor=\"".."ff02972c".."\" "
        strUserName = strUserName.."/>"
    local strContentUser = strUserName..strUserToHelpzi ----mt�������
    strTaskContent = strContentUser..strTaskContent

    DisplayInfoType = nil
    return strTaskContent
end

--//=========================================
function Anyeinfodialog.getInstance()
    if not _instance then
        _instance = Anyeinfodialog:new()
        _instance:OnCreate()
    end
    return _instance
end

function Anyeinfodialog.getInstanceAndShow()
    if not _instance then
        _instance = Anyeinfodialog:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end
    return _instance
end

function Anyeinfodialog.getInstanceNotCreate()
    return _instance
end

function Anyeinfodialog.getInstanceOrNot()
	return _instance
end
	
function Anyeinfodialog.GetLayoutFileName()
    return "anyemaxituanrenwuxiangqing.layout"
end

function Anyeinfodialog:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, Anyeinfodialog)
	self:ClearData()
    return self
end

function Anyeinfodialog.DestroyDialog()
	if not _instance then
		return
	end
	if not _instance.m_bCloseIsHide then
		_instance:OnClose()
		_instance = nil
	else
		_instance:ToggleOpenClose()
	end
end

function Anyeinfodialog:ClearData()
     self.bRencingShow = false
end


function Anyeinfodialog:OnClose()
	self:ClearData()
	Dialog.OnClose(self)
	_instance = nil
end

return Anyeinfodialog
