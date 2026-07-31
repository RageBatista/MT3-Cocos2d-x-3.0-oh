require "logic.dialog"

NpcDialog = {}
setmetatable(NpcDialog, Dialog)
NpcDialog.__index = NpcDialog
NpcDialog.m_TalkDelay = 0

local M_ACTION_NORMAL = 0
local M_ACTION_QUIZE = 1

local SERVER_BOX_QUEST_NUMBER = 6

local eNpcTalkMainMenu = 0
local eNpcTalkChild1Menu = 1
local eNpcTalkChild2Menu =2
local eNpcTalkChild3Menu =3

local NPC_TALK_CHILDLEVEL1_RETURN = 10001
local NPC_TALK_CHILDLEVEL2_RETURN = 10002
local NPC_TALK_CHILDLEVEL3_RETURN = 10003
local NPC_TALK_LEAVE = 10004

local _instance
function NpcDialog.getInstance()
	if not _instance then
		_instance = NpcDialog:new()
		_instance:OnCreate()
	end
	return _instance
end

function NpcDialog.getInstanceAndShow()
	if not _instance then
		_instance = NpcDialog:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function NpcDialog.getInstanceNotCreate()
	return _instance
end

function NpcDialog.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function NpcDialog.ToggleOpenClose()
	if not _instance then
		_instance = NpcDialog:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function NpcDialog.GetLayoutFileName()
	return "npcdialog.layout"
end

function NpcDialog:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, NpcDialog)
	return self
end

function NpcDialog:OnCreate()
    self:initUIFrame()
    self:initDataValue()
end

function NpcDialog:showDialog(npcid, services, scenarioquests)
                        local pNpc = gGetScene():FindNpcByID(npcid)
                        local npcBaseId = pNpc:GetNpcBaseID()
						if npcBaseId == 171210 or npcBaseId == 171218 or npcBaseId == 171202 or npcBaseId == 171214 or  npcBaseId == 171206 then
        self.m_pback:setVisible(false)
        require("logic.npc.npctiaozhan").getInstance(npcid)
        return 
						end

    self.m_vseverid = services
    self.m_vquestid = scenarioquests
    self.m_eAction = M_ACTION_NORMAL
    self.m_npcId = npcid
    local funopenclosetype = require("protodef.rpcgen.fire.pb.funopenclosetype"):new()
    local manager = require "logic.pointcardserver.pointcardservermanager".getInstanceNotCreate()
    if manager then
        if manager.m_OpenFunctionList.info then
            for i,v in pairs(manager.m_OpenFunctionList.info) do
                if v.key == funopenclosetype.FUN_JHM then
                    if v.state == 1 then
                        local pNpc = gGetScene():FindNpcByID(npcid)
                        local npcBaseId = pNpc:GetNpcBaseID()
                        if npcBaseId == 161513 then
                            self.m_vseverid = {}
                        end
                    end
                end
            end
        end
    end

    if self:DefineNpcData() == false then
        NpcDialog.DestroyDialog()
        return
    end

    self:refreshNpcMenu(self.m_vseverid, "")
end

function NpcDialog:showMsgDialog(npckey,npcbaseid, services, introduce)
    self.m_vseverid = services
    self.m_eAction = M_ACTION_NORMAL
    self.m_npcId = npckey
    self.m_npcBaseId = npcbaseid
    if self:DefineNpcData() == false then
        NpcDialog.DestroyDialog()
        return
    end
    self:refreshNpcMenu(services, introduce)
end

function NpcDialog:DefineNpcData()
    local npc = gGetScene():FindNpcByID(self.m_npcId)

    if npc then
        self.m_npcBaseId = npc:GetNpcBaseID()
    else
        npc = gGetScene():FindNpcByBaseID(self.m_npcBaseId)
    end

    if npc == nil then return false end

    self.m_pNpcName:setText(npc:GetName())
    local Shape = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(npc:GetShapeID())
    local iconPath = gGetIconManager():GetImagePathByID(Shape.headID)

    if iconPath:c_str() == CEGUI.PropertyHelper:imageToString(gGetIconManager():getDefaultIcon()) then
        iconPath = gGetIconManager():GetImagePathByID(BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(gGetDataManager():GetMainCharacterShape()).headID)
    end

    self.m_pNpcIcon:setProperty("Image", iconPath:c_str())
    return true
end

function NpcDialog:saveServices(menuSavedServices, orgServices)
    for _, v in pairs(orgServices) do
        table.insert(menuSavedServices, v)
    end
end

function NpcDialog:doLogicWidthoutAutoCommitOneService(introduce)
        local bPlayNpcSound = true
        local nNormalNpcPlay = require "manager.npcservicemanager".isNormalNpcSoundCanPlay(self.m_npcId, self.m_vseverid, self.m_vquestid)
        if nNormalNpcPlay == 0 then
            bPlayNpcSound = false
        end

        local npcConfig = BeanConfigManager.getInstance():GetTableByName("npc.cnpcconfig"):getRecorder(self.m_npcBaseId)

        if introduce ~= "" then
            self:dealNpcSpeak(introduce, bPlayNpcSound, 1)
        elseif npcConfig then
            if npcConfig.chitchatidlist:size() > 0 then
                local sb = StringBuilder.new()
                sb:Set("NpcName",tostring(self.m_pNpcName:getText()))
                local chatnum = npcConfig.chitchatidlist:size() - 1
                local nChatRand = math.random(0, chatnum)
                if npcConfig.time == 1 then
                    if GetMainCharacter():GetLevel() < 50 then
                        nChatRand = 2
                    else
                        local time = StringCover.getTimeStruct(gGetServerTime() / 1000)  
                        local day = time.tm_wday
                        if day >= 1 and day <= 4 then
                            nChatRand = 0
                        else
                            nChatRand = 1
                        end
                    end
                end
                local chat = BeanConfigManager.getInstance():GetTableByName("npc.cnpcchat"):getRecorder(npcConfig.chitchatidlist[nChatRand]).chat
                self:dealNpcSpeak(sb:GetString(chat), bPlayNpcSound, nChatRand)
                sb:delete()
            end
        end
end

function NpcDialog:AdjustMenuProperty(nDrawItemCnt)
    
    if nDrawItemCnt > SERVER_BOX_QUEST_NUMBER then
        nDrawItemCnt = SERVER_BOX_QUEST_NUMBER
        self.m_pServersBox:getVertScrollbar():EnbalePanGuesture(true)
    else
         self.m_pServersBox:getVertScrollbar():EnbalePanGuesture(false)
    end
    if nDrawItemCnt == 0 then
        self.m_pBgServersBox:setVisible(false)
    else
        self.m_pBgServersBox:setVisible(true)
    end

    local nHeight = self.m_nBgServerBoxHeight
    local nPos = self.m_nBgServerBoxPos
    local nBoxHeight = self.m_nServerBoxHeight
    local nBoxPos = self.m_pServersBox:getPosition()

    local nItemHight = self.m_nServerBoxTextHeight
    local nDiff = nItemHight * nDrawItemCnt - nBoxHeight.offset
    nBoxHeight.offset = nItemHight * nDrawItemCnt
    local nOffset = nDiff
    nHeight.offset = nHeight.offset + nOffset
    nPos.y.offset = nPos.y.offset - nOffset
    self.m_pBgServersBox:setPosition(nPos)
    self.m_pBgServersBox:setHeight(nHeight)
    self.m_pServersBox:setHeight(CEGUI.UDim(0, nBoxHeight.offset + 10))

    if nDrawItemCnt == 0 then
        self.m_pBgServersBox:setVisible(false)
   else
        self.m_pBgServersBox:setVisible(true)
    end
    
    
end

function NpcDialog:touchWithoutMenuCallback()
    if self.m_eAction == M_ACTION_NORMAL and self.m_bHaveService == false then
        NpcDialog.DestroyDialog()
    end
    return true
end

function NpcDialog:insertMenuItem()
    local nppcExcuteType = require "protodef.rpcgen.fire.pb.mission.npcexecutetasktypes":new()

    for _, v in pairs(self.m_vquestid) do
        local questname = GetTaskManager():GetQuestName(v)
        local strTaskTitle = questname
        local questinfo = GameTable.mission.GetCMainMissionInfoTableInstance():getRecorder(v)
        if questinfo.id ~= -1 then
            if questinfo.MissionType == nppcExcuteType.START_BATTLE or 
            questinfo.MissionType == nppcExcuteType.GIVE_ITEM then
                strTaskTitle = questinfo.BattlePreString
            end
        end
        local pTextLink = self.m_pServersBox:AppendLinkText(CEGUI.String(strTaskTitle), CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("ff8c5c2b")))
        pTextLink:setTextHorizontalCenter(true)
        pTextLink:setTextVerticalCenter(true)
        pTextLink:SetClickEventID(v)
        self.m_pServersBox:AppendBreak()
    end
end

function NpcDialog:IsAutoCommitOneService(quests, services)
    if require "utils.tableutil".tablelength(services) == 1 and require "utils.tableutil".tablelength(quests) == 0 then
        if self:IsAutoCommit(services[1]) then return true end
    end
    return false
end

function NpcDialog:IsAutoCommit(nServiceId)
    local config = BeanConfigManager.getInstance():GetTableByName("npc.cnpcserverconfig"):getRecorder(nServiceId)
    if not config then return false end
    if config.nautocommit == 1 then return true end
    return false
end


function NpcDialog:AddTipsMessage(npcId, npcBaseID, strMsg)
    self.m_npcId = npcId
    self.m_npcBaseId = npcBaseID
    self.m_pBgServersBox:setVisible(false)
    self:DefineNpcDataForTips()
    self:dealNpcSpeak(strMsg, true, 1)
end

function NpcDialog.AddTipsMessageForCpp(npcId, npcBaseID, strMsg, arg)
    NpcDialog.getInstance():AddTipsMessage(tonumber(npcId), tonumber(npcBaseID), strMsg)
end

function NpcDialog:getResSoundID(nChatRand, nNpcId)
	local npcConfig = BeanConfigManager.getInstance():GetTableByName("npc.cnpcconfig"):getRecorder(nNpcId)
    if not npcConfig then
        return -1
    end
	local voiceNum = npcConfig.voices:size()
	if voiceNum > 0 then
		local nVoiceRand = math.random(0, voiceNum-1)
		if nChatRand >= 0 and nChatRand < voiceNum then
			nVoiceRand = nChatRand
        end
        local nFindCount = 0
		while true do
			local soundRes = npcConfig.voices[nVoiceRand]
            
			if soundRes == "rand" then
				nVoiceRand = math.random(0, voiceNum-1)
			else
				break
            end

            nFindCount = nFindCount + 1
            if nFindCount > 100 then
                break
            end
        end

		return nVoiceRand
    end
	return -1
end

function NpcDialog:DefineNpcDataForTips()
	local modelid = 0
	local name = ""
	local npc = nil
	if self.m_npcId ~= 0 then
        npc = gGetScene():FindNpcByID(self.m_npcId)
	else
        npc = gGetScene():FindNpcByBaseID(self.m_npcBaseId)
    end
	if npc then
		self.m_npcId = npc:GetID()
		self.m_npcBaseId = npc:GetNpcBaseID()
		modelid = npc:GetShapeID()
		name = npc:GetName()
    end
	
	if modelid == 0 then
		local npcConfig = BeanConfigManager.getInstance():GetTableByName("npc.cnpcconfig"):getRecorder(self.m_npcBaseId)
        if npcConfig then
		    modelid = npcConfig.modelID
		    name = npcConfig.name
        end
    end
	if modelid == 0 then
		local MonsterData = GameTable.npc.GetCMonsterConfigTableInstance():getRecorder(self.m_npcBaseId)
        modelid = MonsterData.modelID
		name = MonsterData.name
    end

	if name == "" then
        name = gGetDataManager():GetMainCharacterName()
    end
	self.m_pNpcName:setText(name)
	local iconPath = ""
	if modelid == 0 then
		iconPath = gGetIconManager():GetImagePathByID(BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(gGetDataManager():GetMainCharacterShape()).headID)
	else
		local Shape = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(modelid)
		if Shape.id == -1 then
			iconPath = gGetIconManager():GetImagePathByID(BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(gGetDataManager():GetMainCharacterShape()).headID)
		else
			iconPath = gGetIconManager():GetImagePathByID(Shape.headID)
        end
    end
	if iconPath:c_str() == CEGUI.PropertyHelper:imageToString(gGetIconManager():getDefaultIcon()) then
		 iconPath = gGetIconManager():GetImagePathByID(BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(gGetDataManager():GetMainCharacterShape()).headID);
	end
	self.m_pNpcIcon:setProperty("Image", iconPath:c_str())
end

function NpcDialog:touchCallback(e)
    local mouseArgs = CEGUI.toMouseEventArgs(e)
    local pos = mouseArgs.position
    local pBox=CEGUI.toRichEditbox(mouseArgs.window)
    local component = pBox:GetComponentByPos(pos)

    if not component and pBox:isClickSelectLine() then
        component = pBox:GetLinkTextOnPos(pos)
    end

    if component == nil then
        return self:touchWithoutMenuCallback()
    elseif (component:GetType() == CEGUI.RichEditboxComponentType_Text or component:GetType() == CEGUI.RichEditboxComponentType_Image) and self.m_bHaveService == false then
        NpcDialog.DestroyDialog()
        return true
    elseif (component:GetType() == CEGUI.RichEditboxComponentType_Text or component:GetType() == CEGUI.RichEditboxComponentType_Image) and self.m_bHaveService == true then
        return true
    elseif self.m_eAction == M_ACTION_QUIZE then
        local req = require "protodef.fire.pb.npc.canswerquestion".Create()
        req.npckey = self.m_npcId
        req.questionid = self.m_iQuestID
        req.questiontype = self.m_iQuestType
        req.xiangguanid = self.m_iQuestXiangguanId
        req.answerid = component:GetUserID()
        LuaProtocolManager.getInstance():send(req)
        NpcDialog.DestroyDialog()
        return true
    end

    local id = 0
    if component:GetType() == CEGUI.RichEditboxComponentType_LinkText then
        local pLinkcomponent = tolua.cast(component, "CEGUI::RichEditboxLinkTextComponent")
        if pLinkcomponent:GetClickEventID() ~= 0 then
            id = pLinkcomponent:GetClickEventID()
            local queststate = GetTaskManager():GetQuestState(id)
            if queststate == eMissionIconAcceptalbe then
                local commitquest = require "protodef.fire.pb.mission.ccommitmission":new()
                commitquest.missionid = id
                commitquest.npckey = self.m_npcID
                LuaProtocolManager.getInstance():send(commitquest)
                NpcDialog.DestroyDialog()
            else
            
                require "manager.npcservicemanager".ParseCommitScenarioQuest(self.m_npcId, id,queststate,0)
            end
            return true
        end
        id = component:GetUserID()
    end

    if self:menuClickCallback(id) then return true end

    local NpcServiceConfig = BeanConfigManager.getInstance():GetTableByName("npc.cnpcserverconfig"):getRecorder(id)
    if NpcServiceConfig and NpcServiceConfig.id ~= -1 then
        if NpcServiceConfig.childservice:size() > 0 then
            if self.m_eNpcDialogLevel == eNpcTalkMainMenu then
                self.m_eNpcDialogLevel = eNpcTalkChild1Menu
            elseif self.m_eNpcDialogLevel == eNpcTalkChild1Menu then
                self.m_eNpcDialogLevel = eNpcTalkChild2Menu
            elseif self.m_eNpcDialogLevel == eNpcTalkChild2Menu then
                self.m_eNpcDialogLevel = eNpcTalkChild3Menu
            end

             local childservice = {}
            for i =0, NpcServiceConfig.childservice:size() - 1 do
                table.insert(childservice, NpcServiceConfig.childservice[i])
            end

            self:refreshNpcMenu(childservice, NpcServiceConfig.servicedescribe)
            return true
        end
    end

    self:CheckDealWithManager(id)
	return true
end

function NpcDialog.getDialogPastTime()
    if _instance then
        return _instance.m_TalkDelay
    end
    return 0
end

function NpcDialog:CheckDealWithManager(id)
    if require "manager.npcservicemanager".DispatchHandler(self.m_npcId, id) == 0 then
        local req = require "protodef.fire.pb.npc.cnpcservice".Create()
        req.npckey = self.m_npcId
        req.serviceid = id
        LuaProtocolManager.getInstance():send(req)
        NpcDialog.DestroyDialog()
    end
end

function NpcDialog:menuClickCallback(serviceid)
    if serviceid == NPC_TALK_CHILDLEVEL1_RETURN then
        self.m_eNpcDialogLevel = eNpcTalkMainMenu
        self:refreshNpcMenu(self.m_menu1Services, self.m_Menu1Introduce)
        return true
    elseif serviceid == NPC_TALK_CHILDLEVEL2_RETURN then
        self.m_eNpcDialogLevel = eNpcTalkChild1Menu
        self:refreshNpcMenu(self.m_menu2Services, self.m_Menu2Introduce)
        return true
    elseif serviceid == NPC_TALK_CHILDLEVEL3_RETURN then
        m_eNpcDialogLevel = eNpcTalkChild2Menu
        self:refreshNpcMenu(self.m_menu3Services, self.m_Menu3Introduce)
        return true
    elseif serviceid == NPC_TALK_LEAVE then
        NpcDialog.DestroyDialog()
        return true
	-- 1 2 3 ����ν ������������Э�� ֻ�ܼ����� ���²�
    elseif serviceid == 900054 or serviceid == 900055 or serviceid == 900056 then
        local strMsg =  require "utils.mhsdutils".get_msgtipstring(170031)
        local function ClickYes(args)
            local req = require "protodef.fire.pb.npc.cnpcservice".Create()
            req.npckey = self.m_npcId
            req.serviceid = serviceid
            LuaProtocolManager.getInstance():send(req)
            gGetMessageManager():CloseConfirmBox(eConfirmNormal, false)
        end
        gGetMessageManager():AddConfirmBox(eConfirmNormal, strMsg, ClickYes, 0, MessageManager.HandleDefaultCancelEvent, MessageManager)
        NpcDialog.DestroyDialog()
        return true
    end
    return false
end

function NpcDialog:adjustSpeakContentPos()
	local y = (self.nOldTalkBoxHeight - self.m_pNpcTalkBox:GetExtendSize().height ) * 0.5
    if y<0 then
        y = 8
        
        self.m_pNpcTalkBox:getVertScrollbar():EnbalePanGuesture(true)
        self.m_pNpcTalkBox:setMousePassThroughEnabled(false)
    else
       self.m_pNpcTalkBox:getVertScrollbar():EnbalePanGuesture(false) 
       self.m_pNpcTalkBox:setMousePassThroughEnabled(true)
    end
    local pos = self.m_pNpcTalkBox:getPosition()
    pos.y.offset = y
	self.m_pNpcTalkBox:setPosition(pos)


end

function NpcDialog.setStartAnswerQuestion(lastresult, questionid, questiontype, npckey, xiangguanid, time)
    if NpcDialog.isShow() then
        NpcDialog.DestroyDialog()
    end

    NpcDialog.getInstance():dealQuestionLogic(lastresult, questionid, questiontype, npckey, xiangguanid, time)
end

function NpcDialog:isNormalType()
    if self.m_eAction == M_ACTION_QUIZE then
        return false
    end
    return true
end

function NpcDialog:dealQuestionLogic(lastresult, questionid, questiontype, npckey, xiangguanid, time)
    self.m_npcId = npckey
    self:DefineNpcData()
    self.m_eAction = M_ACTION_QUIZE
    self.m_iQuestType = questiontype
    self.m_iQuestXiangguanId = xiangguanid

    if lastresult == 1 then--��� 
        GetCTipsManager():AddMessageTip(MHSD_UTILS.get_msgtipstring(144876))

    elseif lastresult == 0 then
    else
    --���
        GetCTipsManager():AddMessageTip(MHSD_UTILS.get_msgtipstring(144877))
    end

    if questionid == -1 then  --��Ŀ�Ѵ���
        self.m_npcID = npckey
        self:DefineNpcData()
        if questiontype ~= 7 then
            self:dealNpcSpeak(MHSD_UTILS.get_msgtipstring(140710))
        end
        self.m_eAction = M_ACTION_NORMAL
        self.m_pServersBox:removeAllEvents()
        self.m_pServersBox:subscribeEvent("MouseClick", NpcDialog.touchCallback, self)
        self.m_pBgServersBox:setVisible(false)
        if questiontype ~= 7 then
            GetCTipsManager():AddMessageTip(MHSD_UTILS.get_msgtipstring(140710))
         end
        NpcDialog.DestroyDialog()
        return
    end
    self.m_iQuestID = questionid
    self.m_pServersBox:Clear()
    if questiontype == 7 then
        self.m_askquestionTime = time * 1000
        self.m_askquestionTimeText:setVisible(true)
    end

    local question = BeanConfigManager.getInstance():GetTableByName("mission.ctiku"):getRecorder(questionid)
    if  not question then
        return
    end

    self.m_pNpcTalkBox:Clear()
    local idx = string.find(question.question, "<T")
    if idx then 
        self.m_pNpcTalkBox:AppendParseText(CEGUI.String(question.question))
    else
        self.m_pNpcTalkBox:AppendText(CEGUI.String(question.question))
    end
    self.m_pNpcTalkBox:AppendBreak();
    self.m_pNpcTalkBox:Refresh();
    self.m_pNpcTalkBox:getVertScrollbar():setScrollPosition(0)
    self:adjustSpeakContentPos()

    local nRandom = math.random(1, 4) --�ı�һ����ȷ�𰸵�λ��
    if nRandom == 1 then
        if question.answer1 ~= "" then
            local pTextLink = self.m_pServersBox:AppendLinkText(CEGUI.String(question.answer1), CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("ff8c5c2b")))
            pTextLink:setTextHorizontalCenter(true)
            pTextLink:SetUserID(1)
            self.m_pServersBox:AppendBreak()
        end
    end

    if question.answer2 ~= "" then
        local pTextLink = self.m_pServersBox:AppendLinkText(CEGUI.String(question.answer2), CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("ff8c5c2b")))
        pTextLink:setTextHorizontalCenter(true)
        pTextLink:SetUserID(2)
        self.m_pServersBox:AppendBreak()
    end

    if nRandom == 2 then
        if question.answer1 ~= "" then
            local pTextLink = self.m_pServersBox:AppendLinkText(CEGUI.String(question.answer1), CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("ff8c5c2b")))
            pTextLink:setTextHorizontalCenter(true)
            pTextLink:SetUserID(1)
            self.m_pServersBox:AppendBreak()
        end
    end

    if question.answer3 ~= "" then
        local pTextLink = self.m_pServersBox:AppendLinkText(CEGUI.String(question.answer3), CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("ff8c5c2b")))
        pTextLink:setTextHorizontalCenter(true)
        pTextLink:SetUserID(3)
        self.m_pServersBox:AppendBreak()
    end

    if nRandom == 3 then
        if question.answer1 ~= "" then
            local pTextLink = self.m_pServersBox:AppendLinkText(CEGUI.String(question.answer1), CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("ff8c5c2b")))
            pTextLink:setTextHorizontalCenter(true)
            pTextLink:SetUserID(1)
            self.m_pServersBox:AppendBreak()
        end
    end

    if question.answer4 ~= "" then
        local pTextLink = self.m_pServersBox:AppendLinkText(CEGUI.String(question.answer4), CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("ff8c5c2b")))
        pTextLink:setTextHorizontalCenter(true)
        pTextLink:SetUserID(4)
        self.m_pServersBox:AppendBreak()
    end

    if nRandom == 4 then
        if question.answer1 ~= "" then
            local pTextLink = self.m_pServersBox:AppendLinkText(CEGUI.String(question.answer1), CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("ff8c5c2b")))
            pTextLink:setTextHorizontalCenter(true)
            pTextLink:SetUserID(1)
            self.m_pServersBox:AppendBreak()
        end
    end

    self.m_pServersBox:Refresh()
    self:AdjustMenuProperty(self.m_pServersBox:GetLineCount())
    self.m_pServersBox:getVertScrollbar():setScrollPosition(0)
end

function NpcDialog:run(delta)
    self.m_TalkDelay = self.m_TalkDelay + delta

    if self.m_askquestionTime > 0 then
        self.m_askquestionTime = self.m_askquestionTime - delta

        if self.m_askquestionTime < 0 then self.m_askquestionTime = 0 end
        
        self.m_askquestionTimeText:setText(math.floor(self.m_askquestionTime / 1000).."S")
        if self.m_askquestionTime <= 0 and self.m_askquestionTimeText:isVisible() then
            GetCTipsManager():AddMessageTip(MHSD_UTILS.get_msgtipstring(160237))
            NpcDialog.DestroyDialog()
        end
    end
end

function NpcDialog.isShow()
    if _instance then
        return true
    end
    return false
end

function NpcDialog.handleWindowShut()
    if _instance then
        NpcDialog.DestroyDialog()
    end
end

function NpcDialog:refreshNpcMenu(services, introduce)
    self.m_pServersBox:SetLineSpace(36)
    local pTextLink = self.m_pServersBox:AppendLinkText(CEGUI.String(""))
    pTextLink:setTextHorizontalCenter(true)
    pTextLink:setTextVerticalCenter(true)

    self.m_nServerBoxTextHeight = pTextLink:getPixelSize().height
    self:setMenuInfo(services, introduce)
    self.m_pNpcTalkBox:Clear()

    if self:IsAutoCommitOneService(self.m_vquestid, services) == false then
        self:doLogicWidthoutAutoCommitOneService(introduce)
    end

    self.m_pNpcTalkBox:Refresh()
    self.m_pNpcTalkBox:getVertScrollbar():setScrollPosition(0)
    self.m_pServersBox:Clear()
    self.m_pBgServersBox:setVisible(false)

    if require "utils.tableutil".tablelength(self.m_vquestid) > 0 and self.m_eNpcDialogLevel == eNpcTalkMainMenu then
        self:insertMenuItem()
    end

    for _, v in pairs(services) do
        local config = BeanConfigManager.getInstance():GetTableByName("npc.cnpcserverconfig"):getRecorder(v)
        if config and config.id ~= -1 then
        local textLink = self.m_pServersBox:AppendLinkText(CEGUI.String(config.severStr), CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("ff8c5c2b")))
        textLink:setTextHorizontalCenter(true)
        textLink:setTextVerticalCenter(true)
        textLink:SetUserID(v)
        self.m_pServersBox:AppendBreak()
        end
    end

    self.m_bHaveService = true
    self.m_pServersBox:Refresh()
    self.m_pServersBox:getVertScrollbar():setScrollPosition(0)
    self:AdjustMenuProperty(self.m_pServersBox:GetLineCount())
end

function NpcDialog:setMenuInfo(services, introduce)
    if self.m_eNpcDialogLevel == eNpcTalkMainMenu then
        self.m_menu1Services = {}
        self:saveServices(self.m_menu1Services, services)
        self.m_Menu1Introduce = introduce
    elseif self.m_eNpcDialogLevel == eNpcTalkChild1Menu then
        self.m_menu2Services = {}
        self:saveServices(self.m_menu2Services, services)
        self.m_Menu2Introduce = introduce
    elseif self.m_eNpcDialogLevel == eNpcTalkChild2Menu then
        self.m_menu3Services = {}
        self:saveServices(self.m_menu3Services, services)
        self.m_Menu3Introduce = introduce
    end
end

function NpcDialog:dealNpcSpeak(strMsg, bPlaySceneNpcSound, nChatRand)
	self.m_pNpcTalkBox:Clear()
	local idx = string.find(strMsg, "<T")
	if idx then 
		self.m_pNpcTalkBox:AppendParseText(CEGUI.String(strMsg))
	else
		self.m_pNpcTalkBox:AppendText(CEGUI.String(strMsg))
	end

    local npcConfig = BeanConfigManager.getInstance():GetTableByName("npc.cnpcconfig"):getRecorder(self.m_npcBaseId)
    if npcConfig then
	    local voiceNum = npcConfig.voices:size()
	    if voiceNum > 0 then
		    local nVoiceRand = self:getResSoundID(nChatRand, self.m_npcBaseId)
		    if nVoiceRand >= 0 and nVoiceRand < voiceNum then
			    local soundRes = npcConfig.voices[nVoiceRand]
			    if bPlaySceneNpcSound then
				    gGetGameUIManager():PlayNPCSound(soundRes, self.m_npcBaseId)
                end
            end
        end
    end

	self.m_pNpcTalkBox:AppendBreak()
	self.m_pNpcTalkBox:Refresh()
	self.m_bHaveService = false
	self:adjustSpeakContentPos()
end

function NpcDialog:initUIFrame()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
    self.m_pback =  winMgr:getWindow("NpcDialog/back")
    self.m_pBgServersBox =  winMgr:getWindow("NpcDialog/back/bg")
    self.m_pNpcName = winMgr:getWindow("NpcDialog/name")
    self.m_pNpcIcon = winMgr:getWindow("NpcDialog/icon")
    self.m_pNpcTalkBox = CEGUI.toRichEditbox(winMgr:getWindow("NpcDialog/RichEditBox"))
    self.m_pServersBox = CEGUI.toRichEditbox(winMgr:getWindow("NpcDialog/RichEditBox1"))
    self.m_askquestionTimeText = winMgr:getWindow("NpcDialog/back/bg/time")
    self.m_pNpcTalkBox:SetBackGroundEnable(false)

    self.nOldTalkBoxHeight = self.m_pNpcTalkBox:getPixelSize().height
end

function NpcDialog:initDataValue()
    self.m_NpcTalkBgHeight = self.m_pNpcTalkBox:getPixelSize().height
    --self.m_pNpcTalkBox:subscribeEvent("MouseClick", NpcDialog.touchCallback, self)

    self.m_pServersBox:SetBackGroundEnable(false)
    self.m_pServersBox:EnableClickSelectLine(true)
    self.m_pServersBox:subscribeEvent("MouseClick", NpcDialog.touchCallback, self)
    self.m_pServersBox:SetLineSpace(36)
    local pTextLink = self.m_pServersBox:AppendLinkText(CEGUI.String(""))
    pTextLink:setTextHorizontalCenter(true)
    pTextLink:setTextVerticalCenter(true)
    self.m_nServerBoxTextHeight = pTextLink:getPixelSize().height

    self.m_npcId = 0
    self.m_vseverid ={}
    self.m_vquestid = {}
    self.m_npcBaseId = 0
    self.m_bHaveService = true
    self.m_eAction = 0
    self.m_nBgServerBoxHeight = self.m_pBgServersBox:getHeight()
    self.m_nBgServerBoxPos = self.m_pBgServersBox:getPosition()
    self.m_nServerBoxHeight = self.m_pServersBox:getHeight()

    self.m_eNpcDialogLevel = eNpcTalkMainMenu
    self.m_menu1Services = {}
    self.m_menu2Services = {}
    self.m_menu2Services = {}

    self.m_iQuestType = 0
    self.m_iQuestXiangguanId = 0
    self.m_iQuestID = 0

    self.m_Menu1Introduce = ""
    self.m_Menu2Introduce = ""
    self.m_Menu3Introduce = ""

    self.m_askquestionTime = 0
end


return NpcDialog
