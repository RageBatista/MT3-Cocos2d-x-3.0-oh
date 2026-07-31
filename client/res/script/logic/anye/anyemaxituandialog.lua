require "utils.mhsdutils"
require "logic.dialog"

require "protodef.rpcgen.fire.pb.circletask.specialqueststate"
local spcQuestState = SpecialQuestState:new()



Anyemaxituandialog = {}
setmetatable(Anyemaxituandialog, Dialog)
Anyemaxituandialog.__index = Anyemaxituandialog
local _instance;


--//===============================
function Anyemaxituandialog:OnCreate()
    Dialog.OnCreate(self)
    SetPositionScreenCenter(self:GetWindow())
    local winMgr = CEGUI.WindowManager:getSingleton()

    self.nodeBg = winMgr:getWindow("anyemaxituan/bg") 
    self.labelTitle = winMgr:getWindow("anyemaxituan/tips")
    self.renwulian = winMgr:getWindow("anyemaxituan/ccziti/cc254")	
    
    self.iamgeBattle = winMgr:getWindow("anyemaxituan/renwuxiangqingbg/renwuleixing")
    self.iamgeBattle:setVisible(true)
    self.labelBattle = winMgr:getWindow("anyemaxituan/renwuxiangqingbg/renwu1")

    self.itemCellInfo =  CEGUI.toItemCell(winMgr:getWindow("anyemaxituan/renwuxiangqingbg/xianshikuang1")) 
    self.itemCellInfo:subscribeEvent("MouseClick", Anyemaxituandialog.clickDoTask, self) 

    self.btnRenxing = CEGUI.toPushButton(winMgr:getWindow("anyemaxituan/renwuxiangqingbg/renxingyixia"))
    self.btnRenxing:subscribeEvent("MouseClick", Anyemaxituandialog.clickRenxing, self) 
    self.btnRenxing:setVisible(false)
    self.btnRenxingStone = CEGUI.toPushButton(winMgr:getWindow("anyemaxituan/renwuxiangqingbg/renxingyixia/fushirenxing"))
    self.btnRenxingShengwang = CEGUI.toPushButton(winMgr:getWindow("anyemaxituan/renwuxiangqingbg/renxingyixia/shengwangrenxing"))

    self.btnRenxingStone:subscribeEvent("MouseClick", Anyemaxituandialog.clickRenxingFushi, self) 
    self.btnRenxingShengwang:subscribeEvent("MouseClick", Anyemaxituandialog.clickRenxingShengwang, self) 

    self.btnCallHelp = CEGUI.toPushButton(winMgr:getWindow("anyemaxituan/renwuxiangqingbg/renxingyixia1"))
    self.btnCallHelp:subscribeEvent("MouseClick", Anyemaxituandialog.clickCallHelp, self) 

    self.btnCallHelpShijie = CEGUI.toPushButton(winMgr:getWindow("anyemaxituan/renwuxiangqingbg/renxingyixia1/shijieqiuzhu")) 
    self.btnCallHelpShijie:subscribeEvent("MouseClick", Anyemaxituandialog.clickShiqie, self) 
    self.btnCallHelpGonghui = CEGUI.toPushButton(winMgr:getWindow("anyemaxituan/renwuxiangqingbg/renxingyixia1/gonghuiqiuzhu")) 
    self.btnCallHelpGonghui:subscribeEvent("MouseClick", Anyemaxituandialog.clickGonghui, self) 

    self:setRenxingVisible(false)
    self:setCallHelpVisible(false)
    --self.btnGonghui = CEGUI.toPushButton(winMgr:getWindow("anyemaxituanrenwuxiangqing/gonghuiqiuzhu"))
    --self.btnGonghui:subscribeEvent("MouseClick", Anyemaxituandialog.clickGonghui, self) 

    self.richBoxDesc = CEGUI.toRichEditbox(winMgr:getWindow("anyemaxituan/renwuxiangqing"))
    self.richBoxDesc:setReadOnly(true)

    self.labelRewardExp = winMgr:getWindow("anyemaxituan/renwuxiangqingbg/jingyan/jingyanjiangli")
    self.labelSliver = winMgr:getWindow("anyemaxituan/renwuxiangqingbg/yinbi/yinbijiangli")
    self.labelGold = winMgr:getWindow("anyemaxituan/renwuxiangqingbg/jinbi/jinbijiangli")

    self.btnDo = CEGUI.toPushButton(winMgr:getWindow("anyemaxituan/renwuxiangqingbg/renxingyixia2"))
    self.btnDo:subscribeEvent("MouseClick", Anyemaxituandialog.clickDoTask, self) 
    self.iamgeTaskSuccess = winMgr:getWindow("anyemaxituan/wanchengbiaoshi")  
    self.iamgeTaskSuccess:setVisible(false)

    for nIndex=1,6 do
        self.vItemCellReward[nIndex] =  CEGUI.toItemCell(winMgr:getWindow("anyemaxituan/renwuxiangqingbg/daojukuang"..nIndex))
        self.vItemCellReward[nIndex]:subscribeEvent("MouseClick",GameItemTable.HandleShowToolTipsWithItemID)
    end

    local sizeBgA = self.nodeBg:getPixelSize()
    self.tabView = TableView.create(self.nodeBg, TableView.VERTICAL)
    self.tabView:setViewSize(sizeBgA.width-20, sizeBgA.height)
    self.tabView:setPosition(10, 10)
    self.tabView:setColumCount(2)
    self.tabView:setDataSourceFunc(self, Anyemaxituandialog.tableViewGetCellAtIndex)
    self.tabView:setScrollEnbale(true)
    local layoutNamegetSize = "anyemaxituancell.layout"
    local strPrefix = "getsize"
	local nodeCell = winMgr:loadWindowLayout(layoutNamegetSize,strPrefix)
    self.nodeCellSize = nodeCell:getPixelSize()
    winMgr:destroyWindow(nodeCell)

    self:refreshAllCell(true)
    self:refreshReward()
end

function Anyemaxituandialog:refreshRenxingTitle()

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
        
        local strFushizi = require("utils.mhsdutils").get_msgtipstring(166105) --stone
        local strShengwangzi = require("utils.mhsdutils").get_msgtipstring(166075) --stone

        local sb = StringBuilder.new()
		sb:Set("parameter1",tostring(nStoneNum))
	    strFushizi = sb:GetString(strFushizi)

        sb:Set("parameter1",tostring(nShengwangNum))
	    strShengwangzi = sb:GetString(strShengwangzi)

		sb:delete()

        self.btnRenxingStone:setText(strFushizi)
        self.btnRenxingShengwang:setText(strShengwangzi)
	end

end

function Anyemaxituandialog:sendTaskToChat(strChatContent,nChannel, TaskID)
    
    --wstrStrChat = "<P t="[��������]" roleid="225281" type="8" key="1040000" baseid="2" shopid="0" counter="1040001" bind="0" loseefftime="0" TextColor="ff50321a"></P>"
    local chatCmd = require "protodef.fire.pb.talk.ctranschatmessage2serv".Create()
	chatCmd.messagetype = nChannel
	chatCmd.message = strChatContent --
	chatCmd.checkshiedmessage = ""
	local showInfs = {}
	chatCmd.displayinfos = showInfs
    chatCmd.funtype = 4 --call help
	chatCmd.taskid = TaskID
	LuaProtocolManager.getInstance():send(chatCmd)
end

function Anyemaxituandialog:callHelpSuccess()
    if not self.nChannel then
        return
    end
     self:showChatDialog(self.nChannel)
     Anyemaxituandialog.DestroyDialog()
     GetCTipsManager():AddMessageTipById(166089)

end

function Anyemaxituandialog:showChatDialog(nChannel)
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

function Anyemaxituandialog:sendToChannel(nChannel)
     local taskManager = require("logic.task.taskmanager").getInstance()
    local oneTaskData =  taskManager.vAnyeTask[self.nIndex]
    if not oneTaskData then
        return nil
    end

    local eTaskState = oneTaskData.state
    if eTaskState == spcQuestState.SUCCESS then
        return
    end

    local strChatContent = self:getTaskStringToChat(oneTaskData, nChannel)
    self:sendTaskToChat(strChatContent, nChannel, oneTaskData.pos)

    self.nChannel = nChannel
end

--anye task
--key=anye pos
--baseid = 3 --anyetype
--counter = 1==taskinfo 2=helper other
--shopid =
--bind=

function Anyemaxituandialog:getTaskStringToChat(oneTaskData,nChannel)

    local taskManager = require("logic.task.taskmanager").getInstance()
    local nCurAnyeTimes = taskManager.nAnyeTimes 

    --nAnyeTimes = math.floor(nAnyeTimes/8) + 1

    local DisplayInfoType = require("protodef.rpcgen.fire.pb.talk.displayinfo"):new()

	local roleid = gGetDataManager():GetMainCharacterID()
    local ntype = DisplayInfoType.DISPLAY_TASK --task
    local key = oneTaskData.pos
    local baseid = 3 --anyetype
    local shopid = 0
    local counter = 0 
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
    bind = nCurAnyeTimes
    local strTaskContent =strName -- "["..strName.."]"
    strTaskContent = "<T t=\""..strTaskContent.."\" "
    strTaskContent = strTaskContent.."roleid=\""..tostring(roleid).."\" "
    strTaskContent = strTaskContent.."type=\""..tostring(ntype).."\" "
    strTaskContent = strTaskContent.."key=\""..tostring(key).."\" "
    strTaskContent = strTaskContent.."baseid=\""..tostring(baseid).."\" "

    strTaskContent = strTaskContent.."shopid=\""..tostring(shopid).."\" "
    strTaskContent = strTaskContent.."counter=\""..tostring(counter).."\" "
    strTaskContent = strTaskContent.."bind=\""..tostring(bind).."\" " --bind = nCurAnyeTimes
    strTaskContent = strTaskContent.."loseefftime=\""..tostring(0).."\" "
	strTaskContent = strTaskContent.."TaskType=\"".."anye".."\" "
    strTaskContent = strTaskContent.."TextColor=\"".."ff00ff00".."\" " --ff00ff00
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
       --strName = "["..strName.."]" 

       local strNeedItem = strXuqiuzi.."<T t=\""..strName.."\" "  --link P
--        strNeedItem = strNeedItem.."roleid=\""..tostring(roleid).."\" "
--        strNeedItem = strNeedItem.."type=\""..tostring(ntype).."\" "  --DISPLAY_ITEM
--        strNeedItem = strNeedItem.."key=\""..tostring(0).."\" "
--        strNeedItem = strNeedItem.."baseid=\""..tostring(nItemId).."\" "  --4 =user type 3=anye
--        strNeedItem = strNeedItem.."shopid=\""..tostring(0).."\" "
--        strNeedItem = strNeedItem.."counter=\""..tostring(0).."\" "
--        strNeedItem = strNeedItem.."bind=\""..tostring(0).."\" "
--        strNeedItem = strNeedItem.."loseefftime=\""..tostring(0).."\" "
        strNeedItem = strNeedItem.."TextColor=\"".."ff00ff00".."\" "
        strNeedItem = strNeedItem.."/>"

       strTaskContent= strTaskContent..strNeedItem --����Ѫ��ʯx3
       ------------------------------
        counter = 2 --2==help other btn
        bind = nCurAnyeTimes
        local strHelpeotherzi = require("utils.mhsdutils").get_msgtipstring(166068) --�������

        local nnNowTime = gGetServerTime() /1000
        local strContent2 = "["..strHelpeotherzi.."]" 
        strContent2 = "<P t=\""..strContent2.."\" "
        strContent2 = strContent2.."roleid=\""..tostring(roleid).."\" "
        strContent2 = strContent2.."type=\""..tostring(DisplayInfoType.DISPLAY_TASK).."\" "
        strContent2 = strContent2.."key=\""..tostring(key).."\" " --key=anye pos
        strContent2 = strContent2.."baseid=\""..tostring(baseid).."\" " --3 --anyetype
        strContent2 = strContent2.."shopid=\""..tostring(shopid).."\" "
        strContent2 = strContent2.."counter=\""..tostring(counter).."\" "--1==taskinfo 2=helper other
        strContent2 = strContent2.."bind=\""..tostring(bind).."\" "--bind = nCurAnyeTimes
        strContent2 = strContent2.."loseefftime=\""..tostring(nnNowTime).."\" "
        strContent2 = strContent2.."TextColor=\"".."ffffff00".."\" "
        strContent2 = strContent2.."/>"
        
        strTaskContent = strTaskContent..strContent2
      
    elseif  nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_ChallengeNpc or
            nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_Patrol then
        return self:getTaskStringToChat_battle(oneTaskData,nChannel)
    end
    
    --local strQiuzhuzi = require "utils.mhsdutils".get_msgtipstring(166065)
    local strUserName = gGetDataManager():GetMainCharacterName()
    
    local strUserToHelpzi = require("utils.mhsdutils").get_msgtipstring(166083)
    local strXuqiuzi = require("utils.mhsdutils").get_msgtipstring(166084)
        --strUserName = "["..strUserName.."]" 
        strUserName = "<T t=\""..strUserName.."\" "
        strUserName = strUserName.."roleid=\""..tostring(roleid).."\" "
--        strUserName = strUserName.."type=\""..tostring(15).."\" "  --DISPLAY_ITEM  15 =showuser
--        strUserName = strUserName.."key=\""..tostring(0).."\" "
--        strUserName = strUserName.."baseid=\""..tostring(0).."\" "  --4 =user type 3=anye
--        strUserName = strUserName.."shopid=\""..tostring(0).."\" "
--        strUserName = strUserName.."counter=\""..tostring(0).."\" "
--        strUserName = strUserName.."bind=\""..tostring(0).."\" "
--        strUserName = strUserName.."loseefftime=\""..tostring(0).."\" "
        strUserName = strUserName.."TextColor=\"".."ffbafff6".."\" "
        strUserName = strUserName.."/>"
    local strContentUser = strUserName..strUserToHelpzi ----mt�������
    strTaskContent = strContentUser..strTaskContent

    DisplayInfoType = nil
    return strTaskContent
end


function Anyemaxituandialog:getTaskStringToChat_battle(oneTaskData,nChannel)
     local taskManager = require("logic.task.taskmanager").getInstance()
    local nCurAnyeTimes = taskManager.nAnyeTimes 

    --nAnyeTimes = math.floor(nAnyeTimes/8) + 1

    local DisplayInfoType = require("protodef.rpcgen.fire.pb.talk.displayinfo"):new()

	local roleid = gGetDataManager():GetMainCharacterID()
    local ntype = DisplayInfoType.DISPLAY_TASK --task
    local key = oneTaskData.pos
    local baseid = 3 --anyetype
    local shopid = 0
    local counter = 0 
    local bind = 0

    local anyeTable = BeanConfigManager.getInstance():GetTableByName("circletask.canyemaxituanconf"):getRecorder(oneTaskData.id)
	if anyeTable == nil then
		return 
	end
    local strName = anyeTable.strtaskname

    local nTaskDetailType = oneTaskData.kind
    local nItemId = oneTaskData.dstitemid --itemid or petid
    local nItemNum = oneTaskData.dstitemnum

    local nLeaderId =  gGetDataManager():GetMainCharacterID()
    if not GetTeamManager():IsOnTeam()  then
            GetTeamManager():RequestCreateTeam()
    else
                local pMember =  GetTeamManager():GetTeamLeader()
                if pMember then
                    nLeaderId = pMember.id
                end
    end

    counter = 1 --1==taskinfo
    bind = nCurAnyeTimes
    local strTaskContent =strName -- "["..strName.."]"
    strTaskContent = "<P t=\""..strTaskContent.."\" "
    strTaskContent = strTaskContent.."roleid=\""..tostring(roleid).."\" "
    strTaskContent = strTaskContent.."type=\""..tostring(ntype).."\" "
    strTaskContent = strTaskContent.."key=\""..tostring(key).."\" "
    strTaskContent = strTaskContent.."baseid=\""..tostring(baseid).."\" "

    strTaskContent = strTaskContent.."shopid=\""..tostring(shopid).."\" "
    strTaskContent = strTaskContent.."counter=\""..tostring(counter).."\" "
    strTaskContent = strTaskContent.."bind=\""..tostring(bind).."\" " --bind = nCurAnyeTimes
    strTaskContent = strTaskContent.."loseefftime=\""..tostring(nLeaderId).."\" "
	strTaskContent = strTaskContent.."TaskType=\"".."anye".."\" "
    strTaskContent = strTaskContent.."TextColor=\"".."ff00ff00".."\" " --ff00ff00
    strTaskContent = strTaskContent.."/>"

    if  nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_ChallengeNpc or
            nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_Patrol then
      
        local strJoinTeam = require "utils.mhsdutils".get_resstring(11306)--strJoinTeam = "<R t="[�������1]" leaderid="$leaderid$" c="ffffff00" />"
        local sb = StringBuilder:new()
	    sb:Set("leaderid", tostring(nLeaderId))
	    strJoinTeam = sb:GetString(strJoinTeam)
	    sb:delete()
        strTaskContent = strTaskContent..strJoinTeam
    end
     local strUserName = gGetDataManager():GetMainCharacterName()     
    local strUserToHelpzi = require("utils.mhsdutils").get_msgtipstring(166083)
    local strXuqiuzi = require("utils.mhsdutils").get_msgtipstring(166084)
        --strUserName = "["..strUserName.."]" 
        strUserName = "<T t=\""..strUserName.."\" "
        strUserName = strUserName.."roleid=\""..tostring(roleid).."\" "
--        strUserName = strUserName.."type=\""..tostring(15).."\" "  --DISPLAY_ITEM  15 =showuser
--        strUserName = strUserName.."key=\""..tostring(0).."\" "
--        strUserName = strUserName.."baseid=\""..tostring(0).."\" "  --4 =user type 3=anye
--        strUserName = strUserName.."shopid=\""..tostring(0).."\" "
--        strUserName = strUserName.."counter=\""..tostring(0).."\" "
--        strUserName = strUserName.."bind=\""..tostring(0).."\" "
--        strUserName = strUserName.."loseefftime=\""..tostring(0).."\" "
        strUserName = strUserName.."TextColor=\"".."ffbafff6".."\" "
        strUserName = strUserName.."/>"
    local strContentUser = strUserName..strUserToHelpzi ----mt�������
    strTaskContent = strContentUser..strTaskContent

    DisplayInfoType = nil
    return strTaskContent
end

function Anyemaxituandialog:clickShiqie(args)
local taskManager = require("logic.task.taskmanager").getInstance()
    local oneTaskData =  taskManager.vAnyeTask[self.nIndex]
    if not oneTaskData then
        return 
    end
    
    if oneTaskData.state  == spcQuestState.SUCCESS then
        GetCTipsManager():AddMessageTipById(166081)
        return
    end

   self:sendToChannel(ChannelType.CHANNEL_TEAM_APPLY) --CHANNEL_TEAM_APPLY

   self:hideTipBtn()
end

function Anyemaxituandialog:clickGonghui(args)

    local taskManager = require("logic.task.taskmanager").getInstance()
    local oneTaskData =  taskManager.vAnyeTask[self.nIndex]
    if not oneTaskData then
        return 
    end
    
    if oneTaskData.state  == spcQuestState.SUCCESS then
        GetCTipsManager():AddMessageTipById(166081)
        return
    end

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

    self:hideTipBtn()
    
end

function Anyemaxituandialog:sendRenxing(nMoneyType)
     local taskManager = require("logic.task.taskmanager").getInstance()
    local oneTaskData =  taskManager.vAnyeTask[self.nIndex]
    if not oneTaskData then
        return nil
    end

    if oneTaskData.state  == spcQuestState.SUCCESS then
        GetCTipsManager():AddMessageTipById(166081)
        return
    end

    local nTaskDetailType = oneTaskData.kind
    if  nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_ChallengeNpc or
         nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_Patrol then

        if GetBattleManager() and GetBattleManager():IsInBattle() then
            GetCTipsManager():AddMessageTipById(166094)
			return
	    end
    end


    local nTaskId = oneTaskData.id

    if nMoneyType==CURRENCY.GOLD then
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
        local curStone = CurrencyManager.getOwnCurrencyMount(fire.pb.game.MoneyType.MoneyType_GoldCoin)
        if curStone < nNeedStone then
            local nNeedNum = nNeedStone-curStone
            CurrencyManager.handleCurrencyNotEnough(fire.pb.game.MoneyType.MoneyType_GoldCoin,nNeedNum)
            return 
        end

    end

    local crenxinganyetask = require "protodef.fire.pb.circletask.anye.crenxinganyetask":new()
    crenxinganyetask.taskpos = oneTaskData.pos
    crenxinganyetask.moneytype = nMoneyType
	require "manager.luaprotocolmanager":send(crenxinganyetask)


end

function Anyemaxituandialog:setCallHelpVisible(bVisible)
    self.btnCallHelpShijie:setVisible(bVisible)
    self.btnCallHelpGonghui:setVisible(bVisible)
end


function Anyemaxituandialog:setRenxingVisible(bVisible)
    self.btnRenxingStone:setVisible(bVisible)
    self.btnRenxingShengwang:setVisible(bVisible)
end


function Anyemaxituandialog:clickCallHelp(args)
    self.bCallHelpShow = not self.bCallHelpShow 
    self.bRenxingShow = false
    self:setRenxingVisible(self.bRenxingShow)
    self:setCallHelpVisible(self.bCallHelpShow)
end

function Anyemaxituandialog:refreshInfo()
    local taskManager = require("logic.task.taskmanager").getInstance()

    local oneTaskData =  taskManager.vAnyeTask[self.nIndex]
    if not oneTaskData then
        return 
    end

    local nTaskId = oneTaskData.id
    local anyeTable = BeanConfigManager.getInstance():GetTableByName("circletask.canyemaxituanconf"):getRecorder(nTaskId)
	if anyeTable == nil then
		return 
	end

    local strTaskDesc = anyeTable.strtaskdesc

    local strTargetName,nQuality,nIconId = self:getTargetName(oneTaskData)
    self.itemCellInfo:SetImage("itemicon32","1524")
    SetItemCellBoundColorByQulityItemWithId(self.itemCellInfo,oneTaskData.dstitemid)
    if anyeTable.tasktype == 5 or anyeTable.tasktype == 9 then
        self.itemCellInfo:SetStyle(CEGUI.ItemCellStyle_IconExtend)
    else
        self.itemCellInfo:SetStyle(CEGUI.ItemCellStyle_IconInside)
    end
    local nLevel = GetMainCharacter():GetLevel()
	local nSchoolId =  gGetDataManager():GetMainCharacterSchoolID()
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
    
    for nIndex=1,6 do
        local nRewardItemId = anyeTable.vrewardid[nIndex-1]
        if nRewardItemId then
            self.vItemCellReward[nIndex]:setVisible(true)
            self.vItemCellReward[nIndex]:setID(nRewardItemId)
            local itemTable = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nRewardItemId)
            if itemTable then
                self.vItemCellReward[nIndex]:SetImage(gGetIconManager():GetItemIconByID(itemTable.icon ))
                  SetItemCellBoundColorByQulityItemWithId(self.vItemCellReward[nIndex],itemTable.id)
            end
        else
            self.vItemCellReward[nIndex]:setVisible(false)
        end
    end
    self:refreshRenxingTitle()
    self:refreshDoTaskBtn(oneTaskData)
    --strtasktypeicon

    self.iamgeBattle:setProperty("Image",anyeTable.strtasktypeicon)
    self.labelBattle:setText(anyeTable.strtasknameui)
    --[[
    local nTaskDetailType = oneTaskData.kind

    if  nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_ChallengeNpc or
        nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_Patrol
    then
        self.iamgeBattle:setVisible(true)
        self.labelBattle:setVisible(true)
    else
        self.iamgeBattle:setVisible(false)
        self.labelBattle:setVisible(false)
    end
    --]]
end

function Anyemaxituandialog:refreshReward(bSuccess)
    local taskManager = require("logic.task.taskmanager").getInstance()

    
    self.labelRewardExp:setText(tostring(taskManager.nAnyeRewardExp))
    self.labelSliver:setText(tostring(taskManager.nAnyeRewardSliver))
    self.labelGold:setText(tostring(taskManager.nAnyeRewardGold))

    if bSuccess then
        self.labelRewardExp:setText(tostring(0))
    end

end

function Anyemaxituandialog:refreshDoTaskBtn(oneTaskData)
    local nTitleId = 0
    local nTaskDetailType = oneTaskData.kind
    
    if oneTaskData.state == spcQuestState.SUCCESS then
        self:refreshReward(true)
        --self.btnDo:setEnabled(false)
        self.btnRenxing:setEnabled(false)
        self.btnCallHelp:setEnabled(false)

        self.btnDo:setVisible(false)
        self.iamgeTaskSuccess:setVisible(true)
    else
        --self.btnDo:setEnabled(true)
        self.btnCallHelp:setEnabled(true)
        self.btnRenxing:setEnabled(true)

        self.btnDo:setVisible(true)
        self.iamgeTaskSuccess:setVisible(false)
    end

    if  nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_ChallengeNpc or
        nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_Patrol then
        
        if oneTaskData.state == spcQuestState.SUCCESS then
            nTitleId = 11498 --wancheng
        else
            nTitleId = 11484 --tiaozhan
        end

    elseif nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_ItemFind or
        nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_PetCatch then

        if oneTaskData.state == spcQuestState.SUCCESS then 
            nTitleId = 11498 --wancheng
        elseif oneTaskData.state == spcQuestState.DONE then
             nTitleId = 11483 --sahngjiao
        else
            nTitleId = 11497
        end

        
    end 
    local strTitle = require "utils.mhsdutils".get_resstring(nTitleId)
    self.btnDo:setText(strTitle)
end
--[[
--�̵��������
CURRENCY = {
	SILVER				= 1,  --����
	GOLD				= 2,  --���
	FUSHI				= 3,  --��ʯ
	CAREER_CONTRIBUTE	= 4,  --ְҵ����
	WUXUN				= 5,  --����ֵ
	GANG_CONTRIBUTE 	= 6,  --���ṱ��
	XIAYI				= 7,  --��ֵ
	HOLIDAY_POINT		= 8,  --���ջ���
	TEACHER_VALUE		= 9   --��ʦֵ
}
--]]
function Anyemaxituandialog:clickRenxingFushi(args)
    self:sendRenxing(CURRENCY.GOLD) 
    self:hideTipBtn()
    
end


function Anyemaxituandialog:clickRenxingShengwang(args)
   self:sendRenxing(CURRENCY.XIAYI) 
   self:hideTipBtn()
end
function Anyemaxituandialog:clickRenxing(args)
    local taskManager = require("logic.task.taskmanager").getInstance()

    local oneTaskData =  taskManager.vAnyeTask[self.nIndex]
    if not oneTaskData then
        return 
    end
    --[[
    local nTaskDetailType = oneTaskData.kind
    if  nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_ChallengeNpc or
         nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_Patrol then

        if GetBattleManager() and GetBattleManager():IsInBattle() then
            GetCTipsManager():AddMessageTipById(166094)
			return
	    end
    end
    --]]

    self.bRenxingShow = not self.bRenxingShow
    self:setRenxingVisible(self.bRenxingShow)

    self.bCallHelpShow = false
    self:setCallHelpVisible(self.bCallHelpShow)
     
end

function Anyemaxituandialog:hideTipBtn()
    self.bRenxingShow = false
    self.bCallHelpShow = false
    self:setRenxingVisible(false)
    self:setCallHelpVisible(false)
end

function Anyemaxituandialog:refreshRenxingBtn()
    self.btnRenxingStone:setVisible(self.bRenxingShow)
    self.btnRenxingShengwang:setVisible(self.bRenxingShow)
end


function Anyemaxituandialog:clickCommitItem(commitDlg)
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


function Anyemaxituandialog:clickCommitPet(commitDlg)
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


function Anyemaxituandialog:commitTask(oneTaskData)
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
            commitItemDlg:setDelegateTarget(self,Anyemaxituandialog.clickCommitItem)
		elseif nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_PetCatch then
			local nPetId = oneTaskData.dstitemid
			local vPetKey = {}
			require("logic.task.taskhelperprotocol").GetHavePetWithIdUseToItemTable(nPetId,vPetKey)
			local commitItemDlg = require "logic.task.taskcommitpetdialog".getInstance()
			commitItemDlg:SetCommitItemId(vPetKey,nNpcKey,nTaskTypeId)
            commitItemDlg:setDelegateTarget(self,Anyemaxituandialog.clickCommitPet)
		end
end


function Anyemaxituandialog:isCommitItem()
    local taskManager = require("logic.task.taskmanager").getInstance()
    local oneTaskData =  taskManager.vAnyeTask[self.nIndex]
    if not oneTaskData then
        return false
    end

    local eTaskState = oneTaskData.state
    local nTaskDetailType = oneTaskData.kind

    if eTaskState == spcQuestState.DONE and nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_ItemFind then
        return true
    end
    return false
end


function Anyemaxituandialog:clickDoTask(args)
    
    if GetBattleManager() and GetBattleManager():IsInBattle() then
        local bCommitItem = self:isCommitItem()
        if not bCommitItem then
            local strNoOperate = require("utils.mhsdutils").get_resstring(11577)
            GetCTipsManager():AddMessageTip(strNoOperate)
            return
        end
    end

    local taskManager = require("logic.task.taskmanager").getInstance()
    local oneTaskData =  taskManager.vAnyeTask[self.nIndex]
    if not oneTaskData then
        return nil
    end

    local eTaskState = oneTaskData.state
    if eTaskState == spcQuestState.DONE then
        self:commitTask(oneTaskData)
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

    --require("logic.anye.anyemaxituandialog").DestroyDialog()
    self:OnClose()
   
end

function Anyemaxituandialog:gotoNpc(nNpcId,nTaskTypeId)
    local flyWalkData = {}
	 require("logic.task.taskhelpergoto").GetInitedFlyWalkData(flyWalkData)
	--//-======================================
	flyWalkData.nTaskTypeId = nTaskTypeId
	flyWalkData.nNpcId = nNpcId
	--//-======================================
	require("logic.task.taskhelpergoto").FlyOrWalkTo(flyWalkData)

    local taskManager = require("logic.task.taskmanager").getInstance()
    taskManager.nAnyeCurSelIndex = self.nIndex
    taskManager.nAnyeTaskGotoIndex = self.nIndex
end

function Anyemaxituandialog:gotoTaskAutoBattle(anyeTaskData)
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

function Anyemaxituandialog:CreateCellWithId(parent,nIndex)
    local taskManager = require("logic.task.taskmanager").getInstance()
    local oneTaskData =  taskManager.vAnyeTask[nIndex]
    if not oneTaskData then
        return nil
    end

    local nTaskId = oneTaskData.nTaskId
	local cell = require("logic.anye.anyemaxituancell").create(parent)
	cell.nodeBg:subscribeEvent("MouseClick", Anyemaxituandialog.clickTaskCell,self)
    cell.btnFindTreasure:subscribeEvent("MouseClick", Anyemaxituandialog.HandleSellCellClicked, self)
    
    return cell
end

function Anyemaxituandialog:clickTaskCell(args)
    local mouseArgs = CEGUI.toMouseEventArgs(args)
	local clickWin = mouseArgs.window
	local nIndex = clickWin.nIndex
    self.nIndex = nIndex
    local taskManager = require("logic.task.taskmanager").getInstance()
    local oneTaskData =  taskManager.vAnyeTask[nIndex]
    if not oneTaskData then
        return nil
    end
   
    
    local bSuccess = false
    if oneTaskData.state  == spcQuestState.SUCCESS then
        --GetCTipsManager():AddMessageTipById(166081)
        --return
        bSuccess = true
    end
    
    self:refreshInfo()
    self:refreshReward(bSuccess)
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

function Anyemaxituandialog:refreshCell(nIndex,cell)
    local taskManager = require("logic.task.taskmanager").getInstance()
    local oneTaskData =  taskManager.vAnyeTask[nIndex]
    if not oneTaskData then
        return nil
    end
    local nTaskId = oneTaskData.id
    local eTaskState = oneTaskData.state


    local anyeTable = BeanConfigManager.getInstance():GetTableByName("circletask.canyemaxituanconf"):getRecorder(nTaskId)
	if anyeTable == nil then
		return 
	end
    local stTaskName = anyeTable.strtasknameui
    local strTaskDesc = anyeTable.strtaskdescui
    local nGroupId = anyeTable.group

    local strTargetName,nQuality,nIconId = self:getTargetName(oneTaskData)
  
    cell.labelTaskName:setText(stTaskName)

    if anyeTable.tasktype == 5 or anyeTable.tasktype == 9 then
        cell.itemcellTaskIcon:SetStyle(CEGUI.ItemCellStyle_IconExtend)
    else
        cell.itemcellTaskIcon:SetStyle(CEGUI.ItemCellStyle_IconInside)
    end
    cell.itemcellTaskIcon:SetImage("itemicon32","1524") --anyeTable.ntaskicon
    SetItemCellBoundColorByQulityItemWithId(cell.itemcellTaskIcon,oneTaskData.dstitemid)


    cell.labelTarget:setText(strTargetName)
    cell.labelNum:setText(tostring(oneTaskData.dstitemnum))
    cell.labelQuality:setText(tostring(nQuality))
    cell.nodeBg.nIndex = nIndex
    
    
    cell.nodeLabelBg:setVisible(false)
    cell.richBoxDesc:setVisible(true)

    local nLevel = GetMainCharacter():GetLevel()
	local nSchoolId =  gGetDataManager():GetMainCharacterSchoolID()
    local nQuality = require("logic.task.taskhelpertable").GetQuality(nSchoolId,nGroupId,nLevel)
    oneTaskData.nQuality = nQuality
    local sb = StringBuilder:new()
    require("logic.task.taskmanager").getInstance():getTaskInfoCorrectSb(oneTaskData,sb)
    strTaskDesc = sb:GetString(strTaskDesc)
    sb:delete()
    cell.richBoxDesc:Clear()
	cell.richBoxDesc:AppendParseText(CEGUI.String(strTaskDesc))
	cell.richBoxDesc:Refresh()
	cell.richBoxDesc:getVertScrollbar():setScrollPosition(0)

    cell.iamgeBattle:setProperty("Image",anyeTable.strtasktypeicon)
    
    if eTaskState == spcQuestState.SUCCESS then
       --cell.nodeBg:setEnabled(false)
       cell.imageSuccess:setVisible(true)
       cell.btnFindTreasure:setVisible(false)
       cell.imgFindTreasureDo:setVisible(false)
       cell.imgFindTreasureFail:setVisible(false)
       cell.imgFindTreasureFinish:setVisible(false)
    else 
        --cell.nodeBg:setEnabled(true)
        cell.imageSuccess:setVisible(false)
        --����
        if oneTaskData.legend == 0 then
           cell.btnFindTreasure:setVisible(false)
           cell.imgFindTreasureDo:setVisible(false)
           cell.imgFindTreasureFail:setVisible(false)
           cell.imgFindTreasureFinish:setVisible(false)
           --���Բμ�
        elseif oneTaskData.legend == 1 then
            cell.btnFindTreasure:setVisible(true)
            cell.imgFindTreasureDo:setVisible(false)
            cell.imgFindTreasureFail:setVisible(false)
            cell.imgFindTreasureFinish:setVisible(false)
            --����
        elseif oneTaskData.legend == 2 then
            cell.btnFindTreasure:setVisible(false)
            cell.imgFindTreasureDo:setVisible(true)
            cell.imgFindTreasureFail:setVisible(false)
            cell.imgFindTreasureFinish:setVisible(false)
            --�ɹ�
        elseif oneTaskData.legend == 3 then
            cell.btnFindTreasure:setVisible(false)
            cell.imgFindTreasureDo:setVisible(false)
            cell.imgFindTreasureFail:setVisible(false)
            cell.imgFindTreasureFinish:setVisible(true)
                    --ʧ��
        elseif oneTaskData.legend == 4 then
            cell.btnFindTreasure:setVisible(false)
            cell.imgFindTreasureDo:setVisible(false)
            cell.imgFindTreasureFail:setVisible(true)
            cell.imgFindTreasureFinish:setVisible(false)
        end 
    end
    
    --[[
    if oneTaskData.kind == fire.pb.circletask.CircTaskClass.CircTask_ChallengeNpc or 
        oneTaskData.kind == fire.pb.circletask.CircTaskClass.CircTask_Patrol
    then
        cell.iamgeBattle:setVisible(true)

    else
        cell.iamgeBattle:setVisible(false)
    end
    --]]
    if self.nIndex == cell.nodeBg.nIndex then
        cell.nodeBg:setSelected(true,false)
    else
        cell.nodeBg:setSelected(false,false)
    end

end


function Anyemaxituandialog:getTargetName(oneTaskData)
    local strTargetName = ""
    local nQuality = 0
    local nTaskDetailType = oneTaskData.kind
    local nIconId = -1
    
    local nTaskId = oneTaskData.id
    local anyeTable = BeanConfigManager.getInstance():GetTableByName("circletask.canyemaxituanconf"):getRecorder(nTaskId)
	if anyeTable then
		nIconId = anyeTable.ntaskicon
	end

    if  nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_ItemFind then
        local itemTable = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(oneTaskData.dstitemid)
	    if itemTable then
            strTargetName = itemTable.name
            nQuality = itemTable.nquality
            nIconId = itemTable.icon
        end
    elseif  nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_PetCatch then
        local petTable = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(oneTaskData.dstitemid)
        if petTable then
            strTargetName = petTable.name
            nQuality = petTable.quality
            local nModelId = petTable.modelid
            local shapeTable = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(nModelId)
            if shapeTable then
               nIconId = shapeTable.littleheadID
            end

        end
    elseif nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_ChallengeNpc then
        local nNpcId = oneTaskData.dstnpcid
        local npcTable = BeanConfigManager.getInstance():GetTableByName("npc.cnpcconfig"):getRecorder(nNpcId)

        if npcTable and npcTable.id ~= -1 then
            strTargetName = npcTable.name
        end
        local nModelId = npcTable.modelID
        local shapeTable = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(nModelId)
            if shapeTable then
               nIconId = shapeTable.littleheadID
            end
    elseif nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_Patrol then
        local nMapId = oneTaskData.dstnpcid
        local mapTable = GameTable.map.GetCMapConfigTableInstance():getRecorder(nMapId)
        if mapTable and mapTable.id ~= -1 then
            strTargetName = mapTable.mapName
        end
    end
    return strTargetName,nQuality,nIconId
end
function Anyemaxituandialog:HandleSellCellClicked(args)
    if GetBattleManager() and GetBattleManager():IsInBattle() then
        local strNoOperate = require("utils.mhsdutils").get_resstring(11577)
        GetCTipsManager():AddMessageTip(strNoOperate)
        return
    end

    local nIndex = CEGUI.toWindowEventArgs(args).window:getID()
    local taskManager = require("logic.task.taskmanager").getInstance()
    local oneTaskData =  taskManager.vAnyeTask[nIndex]
    if not oneTaskData then
        return true
    end
    if taskManager.m_nAnyeFollowIndex >=1 and taskManager.m_nAnyeFollowIndex<=8 then
        if taskManager.vAnyeTask[taskManager.m_nAnyeFollowIndex].legend == 2 then
            local function ClickYes(self, args)
                gGetMessageManager():CloseConfirmBox(eConfirmNormal, false)
                local clengendanyetask = require "protodef.fire.pb.circletask.anye.clengendanyetask":new()
                clengendanyetask.taskpos = oneTaskData.pos
	            require "manager.luaprotocolmanager":send(clengendanyetask)
            end
            local function ClickNo(self, args)
                if CEGUI.toWindowEventArgs(args).handled ~= 1 then
                    gGetMessageManager():CloseConfirmBox(eConfirmNormal, false)
                end
                return
            end
            local msg = MHSD_UTILS.get_msgtipstring(166116)
            local taskManager = require("logic.task.taskmanager").getInstance()
            if taskManager.m_nAnyeFollowIndex >=1 and taskManager.m_nAnyeFollowIndex<=8 then
                msg = MHSD_UTILS.get_msgtipstring(166117)
            end
            gGetMessageManager():AddConfirmBox(eConfirmNormal, msg, ClickYes, 
            self, ClickNo, self,0,0,nil,MHSD_UTILS.get_resstring(2035),MHSD_UTILS.get_resstring(2036))
        else
            local clengendanyetask = require "protodef.fire.pb.circletask.anye.clengendanyetask":new()
            clengendanyetask.taskpos = oneTaskData.pos
	        require "manager.luaprotocolmanager":send(clengendanyetask)       
        end
    else
        local clengendanyetask = require "protodef.fire.pb.circletask.anye.clengendanyetask":new()
        clengendanyetask.taskpos = oneTaskData.pos
	    require "manager.luaprotocolmanager":send(clengendanyetask)  
    end



end
function Anyemaxituandialog:tableViewGetCellAtIndex(tableView, idx, cell) --0--count-1
    local nIndex = idx +1
    if not cell then
        cell = self:CreateCellWithId(tableView.container,nIndex )
        
    end
    self:refreshCell(nIndex,cell)
    cell.btnFindTreasure:setID(nIndex)
    return cell
end



function Anyemaxituandialog:refreshAllCell(bClear)
    
    if not bClear then
        bClear = false
    end
    if bClear then
        self.tabView:destroyCells()
        
    end
    local taskManager = require("logic.task.taskmanager").getInstance()
    local nAllCellNum = require "utils.tableutil".tablelength(taskManager.vAnyeTask) 
    self.tabView:setCellCountAndSize(nAllCellNum, self.nodeCellSize.width, self.nodeCellSize.height)
    self.tabView:reloadData()

    local strValue = GameTable.common.GetCCommonTableInstance():getRecorder(311).value
    local nAllNum = tonumber(strValue)
    nAllNum = nAllNum/8
    local nAnyeTimes = taskManager.nAnyeTimes
    nAnyeTimes = math.floor(nAnyeTimes/8) + 1
    local strTitlezi = require("utils.mhsdutils").get_msgtipstring(166076)
    local sb = StringBuilder:new()
	sb:Set("parameter1", tostring(nAnyeTimes))
    sb:Set("parameter2", tostring(nAllNum))
	strTitlezi = sb:GetString(strTitlezi)
	sb:delete()
    self.labelTitle:setText(strTitlezi)

    local strTitle = require("utils.mhsdutils").get_resstring(11559)  --self:GetWindow():getText()
    strTitle = strTitle.."("..nAnyeTimes.."/"..nAllNum..")"
	self.renwulian:setText(strTitle)
    --self:GetWindow():setText(strTitle)
    --strTitle = strTitle..
    --self.nIndex = 0
    self:refreshInfo()
end





--//=========================================
function Anyemaxituandialog.getInstance()
    if not _instance then
        _instance = Anyemaxituandialog:new()
        _instance:OnCreate()
    end
    return _instance
end

function Anyemaxituandialog.getInstanceAndShow(nIndex)
    if not _instance then
        _instance = Anyemaxituandialog:new()
        if not nIndex then
            nIndex = 1
        end
        _instance.nIndex = nIndex
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end
    return _instance
end

function Anyemaxituandialog.getInstanceNotCreate()
    return _instance
end

function Anyemaxituandialog.getInstanceOrNot()
	return _instance
end
	
function Anyemaxituandialog.GetLayoutFileName()
    return "anyemaxituan.layout"
end

function Anyemaxituandialog:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, Anyemaxituandialog)
	self:ClearData()
    return self
end

function Anyemaxituandialog.DestroyDialog()
	if not _instance then
		return
	end
    --require("logic.task.taskmanager").getInstance().nAnyeCurSelIndex = -1
	if not _instance.m_bCloseIsHide then
		_instance:OnClose()
		_instance = nil
	else
		_instance:ToggleOpenClose()
	end
end

function Anyemaxituandialog:ClearData()
    self.vItemCellReward = {}
    self.nIndex = 1
	self.bRenxingShow = false
    self.bCallHelpShow = false
end


function Anyemaxituandialog:OnClose()
	self:ClearData()
    
	Dialog.OnClose(self)
	_instance = nil
end

return Anyemaxituandialog
