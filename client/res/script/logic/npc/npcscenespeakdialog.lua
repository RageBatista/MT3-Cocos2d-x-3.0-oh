require "logic.dialog"

NpcSceneSpeakDialog = { }
NpcSceneSpeakDialog.m_eFunction = 0

setmetatable(NpcSceneSpeakDialog, Dialog)
NpcSceneSpeakDialog.__index = NpcSceneSpeakDialog

local STATE_NONE = "WND_STATE_NONG"
local STATE_START_DELAYING = "WND_STATE_START_DELAYING"
local STATE_START_SHOWING = "WND_STATE_START_SHOWING"
local STATE_START_HIDING = "WND_STATE_START_HIDING"
local STATE_END_DELAYING = "WND_STATE_END_DELAYING"

local _instance
function NpcSceneSpeakDialog.getInstance()
    if not _instance then
        _instance = NpcSceneSpeakDialog:new()
        _instance:OnCreate()
    end
    return _instance
end

function NpcSceneSpeakDialog.getInstanceAndShow(npcid, npcbaseid, questid)
    if not _instance then
        _instance = NpcSceneSpeakDialog:new()
        _instance:OnCreate(npcid, npcbaseid, questid)
    else
        _instance:SetVisible(true)
    end
    return _instance
end

function NpcSceneSpeakDialog.getInstanceNotCreate()
    return _instance
end

function NpcSceneSpeakDialog.DestroyDialog()
    if _instance then
        local activeSheet = CEGUI.System:getSingleton():getGUISheet()
        if not activeSheet then return end

        local child_count = activeSheet:getChildCount()
        for i = 0, child_count - 1 do
            local pChild = activeSheet:getChildAtIdx(i)
            pChild:setAlpha(1)
        end

        if not _instance.m_bCloseIsHide then
            _instance:OnClose()
            _instance = nil
        else
            _instance:ToggleOpenClose()
        end

        if gGetScene() then
            gGetScene():OnExitSceneNpcSpeakState()
        end
    end
end

function NpcSceneSpeakDialog.ToggleOpenClose()
    if not _instance then
        _instance = NpcSceneSpeakDialog:new()
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function NpcSceneSpeakDialog.GetLayoutFileName()
    return "npcsceneaniback.layout"
end

function NpcSceneSpeakDialog:new()
    local self = { }
    self = Dialog:new()
    setmetatable(self, NpcSceneSpeakDialog)
    return self
end

function NpcSceneSpeakDialog:OnCreate(npcId, npcBaseId, questId)
    local activeSheet = CEGUI.System:getSingleton():getGUISheet()
    if not activeSheet then return end

    local childTbl = {}
    local child_count = activeSheet:getChildCount()
    for i = 0, child_count - 1 do
        local pChild = activeSheet:getChildAtIdx(i)
        table.insert(childTbl, pChild)
    end
    for _, pChild in pairs(childTbl) do
        if pChild then
            pChild:setAlpha(0)
        end
    end

    self:initUIWindow()
    self:initDataValue(npcId, npcBaseId, questId)

    self:GetWindow():setModalState(true)
    self:GetWindow():SeModalStateDrawEffect(false) 

    self:ResetSize()
    self:onBeginSpeak()
end

function NpcSceneSpeakDialog:npcSpeakStart()
    local questinfo = GameTable.mission.GetCMainMissionInfoTableInstance():getRecorder(self.m_questID)
    if self.m_iConversationIndex >= questinfo.ScenarioInfoNpcConversationList:size() then
        if string.len(questinfo.ScenarioInfoBranchNote) > 0 then
            return true
        end
        return false
    end

    if questinfo.ScenarioInfoNpcID:size() ~= questinfo.ScenarioInfoNpcConversationList:size() then
        return false
    end

    if questinfo.ScenarioInfoNpcID[self.m_iConversationIndex] == 1 then
        self.m_pName:setText(gGetDataManager():GetMainCharacterName())
        local roleShape = gGetDataManager():GetMainCharacterShape()
        local npcShape = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(roleShape)
        local iconpath = gGetIconManager():GetImagePathByID(npcShape.headID)
        self.m_pHeadIcon:setProperty("Image", iconpath:c_str())
        self.m_bMainCharSpeak = true
    else
        self.m_npcBaseID = questinfo.ScenarioInfoNpcID[self.m_iConversationIndex]
        self.m_bMainCharSpeak = false
    end

    local strFacePath = ""
    if self.m_iConversationIndex < questinfo.BiaoQingA:size() then
        strFacePath = questinfo.BiaoQingA[self.m_iConversationIndex]
    end

    local nNpcId = self.m_npcBaseID
    local strNpcSound = ""
    if self.m_iConversationIndex < questinfo.vNpcChatSound:size() then
        strNpcSound = questinfo.vNpcChatSound[self.m_iConversationIndex]
    end

    if string.find(questinfo.ScenarioInfoNpcConversationList[self.m_iConversationIndex], "NAME") or string.find(questinfo.ScenarioInfoNpcConversationList[self.m_iConversationIndex], "SCHOOL") then
        local sb = StringBuilder:new()
        sb:Set("NAME", gGetDataManager():GetMainCharacterName())
        sb:Set("SCHOOL", gGetDataManager():GetMainCharacterSchoolName())
        local str = sb:GetString(questinfo.ScenarioInfoNpcConversationList[self.m_iConversationIndex])
        sb:delete()
        self:dealNpcSpeak(str, strFacePath, nNpcId, strNpcSound)
    else
        self:dealNpcSpeak(questinfo.ScenarioInfoNpcConversationList[self.m_iConversationIndex], strFacePath, nNpcId, strNpcSound)
    end

    self.m_iConversationIndex = self.m_iConversationIndex + 1
    return true
end

function NpcSceneSpeakDialog.finishShowTalk(questid)
    return NpcSceneSpeakDialog.getInstance():npcSpeakEnd(questid)
end

function NpcSceneSpeakDialog:npcSpeakEnd(questid)
    require "logic.npc.npcdialog".handleWindowShut()

    NpcSceneSpeakDialog.m_eFunction = eFinishQuest
    self.m_questID = questid

     local questinfo = GameTable.mission.GetCMainMissionInfoTableInstance():getRecorder(questid)

     if self.m_iConversationIndex >= questinfo.ScenarioInfoFinishConversationList:size() then
        if questinfo.NoteInfo ~= "" then
            GetCTipsManager():AddMessageTip(questinfo.NoteInfo)
        end
        return false
     end

     if questinfo.ScenarioInfoFinishNpcID:size() ~= questinfo.ScenarioInfoFinishConversationList:size() then
        return false
     end

    if questinfo.ScenarioInfoFinishNpcID[self.m_iConversationIndex] == 1 then
        self.m_pName:setText(gGetDataManager():GetMainCharacterName())

        local roleShape = gGetDataManager():GetMainCharacterShape()
        local npcShape = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(roleShape)
        local iconpath = gGetIconManager():GetImagePathByID(npcShape.headID)
        self.m_pHeadIcon:setProperty("Image", iconpath:c_str())
        self.m_bMainCharSpeak= true
    else
        self.m_npcBaseID = questinfo.ScenarioInfoFinishNpcID[self.m_iConversationIndex]
        self.m_bMainCharSpeak = false;
    end

    local strFacePath = ""
    if self.m_iConversationIndex < questinfo.BiaoQingB:size() then
        strFacePath = questinfo.BiaoQingB[self.m_iConversationIndex]
    end
    local nNpcId = self.m_npcBaseID
    local strNpcSound = ""
    if self.m_iConversationIndex < questinfo.vNpcChatSoundFinish:size() then
        strNpcSound = questinfo.vNpcChatSoundFinish[self.m_iConversationIndex]
    end

    if string.find(questinfo.ScenarioInfoFinishConversationList[self.m_iConversationIndex], "NAME") or string.find(questinfo.ScenarioInfoFinishConversationList[self.m_iConversationIndex], "SCHOOL") then
        local sb = StringBuilder:new()
        sb:Set("NAME", gGetDataManager():GetMainCharacterName())
        sb:Set("SCHOOL", gGetDataManager():GetMainCharacterSchoolName())
        local str = sb:GetString(questinfo.ScenarioInfoFinishConversationList[self.m_iConversationIndex])
        sb:delete()
        self:dealNpcSpeak(str, strFacePath, nNpcId, strNpcSound)
    else
        self:dealNpcSpeak(questinfo.ScenarioInfoFinishConversationList[self.m_iConversationIndex], strFacePath, nNpcId, strNpcSound)
    end
    
    self.m_iConversationIndex = self.m_iConversationIndex + 1
    return true
end

function NpcSceneSpeakDialog:dealNpcSpeak(strMsg, facePath, npcid, npcSound)
    if not self.m_bMainCharSpeak then
        local npcconfig = BeanConfigManager.getInstance():GetTableByName("npc.cnpcconfig"):getRecorder(self.m_npcBaseID)
        if npcconfig then
            local npcshape = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(npcconfig.modelID)
            self:defineNpcSpeakWords(npcshape.headID, npcconfig.name, strMsg, facePath, npcid, npcSound)
        end
    else
        self:defineNpcSpeakWords(0, "", strMsg, facePath, npcid, npcSound)
    end
end


function NpcSceneSpeakDialog:mouchClickCallback(e)
    if  self.m_WndState ~= STATE_START_SHOWING then
        return true
    end

    self:nextChatClick()
    return true
end

function NpcSceneSpeakDialog:nextChatClick()
    self.m_fNextChatTimeDt = 0
    self.m_bUpNextCd = false

    if NpcSceneSpeakDialog.m_eFunction == eCommitQuest then
        if self:npcSpeakStart() == false then
            NpcServiceManager.HandleCompleteScenarioQuest(self.m_npcID, self.m_questID)
        end
    elseif NpcSceneSpeakDialog.m_eFunction == eFinishQuest then
        if NpcSceneSpeakDialog.finishShowTalk(self.m_questID) == false then
            NpcSceneSpeakDialog.handleWindowShut()

            local questinfo = GameTable.mission.GetCMainMissionInfoTableInstance():getRecorder(self.m_questID)
            if questinfo and questinfo.id ~= -1 then
                if questinfo.ScenarioInfoAnimationID >0 or questinfo.RewardMapJumpType > 0 then
                    local taskEnd = require "protodef.fire.pb.mission.cmissiondialogend":new()
                    taskEnd.missionid = self.m_questID
                    require "manager.luaprotocolmanager":send(taskEnd)
                end
            end

        end
    end
end

function NpcSceneSpeakDialog.handleWindowShut()
    if _instance then
        _instance.m_WndState = STATE_START_HIDING
        _instance.m_fAniElapseTime = 0
    end
end

function NpcSceneSpeakDialog:onBeginSpeak()
    GetMainCharacter():StopMove()
    GetMainCharacter():clearGoTo()

    gGetScene():HideAllCharExceptTeammate()
end

function NpcSceneSpeakDialog:onEndSpeak()
--    gGetScene():OnExitSceneNpcSpeakState()
end


function NpcSceneSpeakDialog:run(delay)
    self.m_fAniElapseTime = self.m_fAniElapseTime + delay
    if self.m_WndState == STATE_START_DELAYING then
        if self.m_fAniElapseTime >= self.m_fAniDelayTime then
            self.m_WndState = STATE_START_SHOWING
            self.m_fAniElapseTime = 0
        end
    elseif self.m_WndState == STATE_START_SHOWING then
        if self.m_fAniElapseTime <= self.m_fAniTotalTime then
            local bottomPos = self.m_pBottomPanel:getPosition()
            local bottomSize = self.m_pBottomPanel:getSize()
            bottomPos.y.offset = bottomPos.y.offset - self.m_fAniSpeedBottom * delay
            self.m_pBottomPanel:setPosition(bottomPos)
            self.m_pBottomPanel:setSize(bottomSize)

            local topPos = self.m_pTopPanel:getPosition()
            local topSize = self.m_pTopPanel:getSize()
            topPos.y.offset = topPos.y.offset + self.m_fAniSpeedTop * delay
            self.m_pTopPanel:setPosition(topPos)
            self.m_pTopPanel:setSize(topSize)

            local m_iconPos = self.m_pHeadIcon:getPosition()
            local m_iconSize = self.m_pHeadIcon:getSize()
            m_iconPos.x.offset = m_iconPos.x.offset + self.m_fIconSpeed * delay
            self.m_pHeadIcon:setPosition(m_iconPos)
            self.m_pHeadIcon:setSize(m_iconSize)

            local m_namePos = self.m_pNameBg:getPosition()
            local m_nameSize = self.m_pNameBg:getSize()
            m_namePos.y.offset = m_namePos.y.offset - self.m_fNameSpeed * delay
            self.m_pNameBg:setPosition(m_namePos)
            self.m_pNameBg:setSize(m_nameSize)
        end
    elseif self.m_WndState == STATE_START_HIDING then
        if self.m_fAniElapseTime >= self.m_fAniTotalTime then
            self.m_fAniElapseTime = 0
            self:ResetSize()
            self.m_WndState = STATE_END_DELAYING
        else
            local topPos = self.m_pTopPanel:getPosition()
            local topSize = self.m_pTopPanel:getSize()
            topPos.y.offset = topPos.y.offset - self.m_fAniSpeedTop * delay
            self.m_pTopPanel:setPosition(topPos)
            self.m_pTopPanel:setSize(topSize)

            local bottomPos = self.m_pBottomPanel:getPosition()
            local bottomSize = self.m_pBottomPanel:getSize()
            bottomPos.y.offset = bottomPos.y.offset + self.m_fAniSpeedBottom * delay
            self.m_pBottomPanel:setPosition(bottomPos)
            self.m_pBottomPanel:setSize(bottomSize)

            local m_iconPos = self.m_pHeadIcon:getPosition()
            local m_iconSize = self.m_pHeadIcon:getSize()
            m_iconPos.x.offset = m_iconPos.x.offset - self.m_fIconSpeed * delay
            self.m_pHeadIcon:setPosition(m_iconPos)
            self.m_pHeadIcon:setSize(m_iconSize)

            local m_namePos = self.m_pNameBg:getPosition()
            local m_nameSize = self.m_pNameBg:getSize()
            m_namePos.y.offset = m_namePos.y.offset + self.m_fNameSpeed * delay
            self.m_pNameBg:setPosition(m_namePos)
            self.m_pNameBg:setSize(m_nameSize)
        end
    elseif self.m_WndState == STATE_END_DELAYING then
        if self.m_fAniElapseTime >= self.m_fAniOverDelayTime then
            self.m_WndState = STATE_NONE
            self:onEndSpeak()
            NpcSceneSpeakDialog.DestroyDialog()
        end
    end

    if self.m_bUpNextCd then
        self.m_fNextChatTimeDt = self.m_fNextChatTimeDt + delay
        if self.m_fNextChatTimeDt >= self.m_fNextChatTime then
            self:nextChatClick()
        end
    end
end

function NpcSceneSpeakDialog:ResetSize()
    local bottomPos = self.m_pBottomPanel:getPosition()
    local bottomSize = self.m_pBottomPanel:getSize()
    bottomPos.y.offset = bottomPos.y.offset + self.m_udimBottomYSizeMax
    self.m_pBottomPanel:setPosition(bottomPos)
    self.m_pBottomPanel:setSize(bottomSize)

    local topPos = self.m_pTopPanel:getPosition()
    local topSize = self.m_pTopPanel:getSize()
    topPos.y.offset = topPos.y.offset - self.m_udimTopYSizeMax
    self.m_pTopPanel:setPosition(topPos)
    self.m_pTopPanel:setSize(topSize)

    local iconWidth = self.m_pHeadIcon:getPixelSize().width
    local nameHeight = self.m_pNameBg:getPixelSize().height

    local m_iconPos = self.m_pHeadIcon:getPosition()
    local m_iconSize = self.m_pHeadIcon:getSize()
    m_iconPos.x.offset = m_iconPos.x.offset - iconWidth
    self.m_pHeadIcon:setPosition(m_iconPos)
    self.m_pHeadIcon:setSize(m_iconSize)

    local m_namePos = self.m_pNameBg:getPosition()
    local m_iconSize = self.m_pNameBg:getSize()
    m_namePos.y.offset = m_namePos.y.offset + nameHeight
    self.m_pNameBg:setPosition(m_namePos)
    self.m_pNameBg:setSize(m_iconSize)
end

function NpcSceneSpeakDialog:DestroyDialog1()----动画1
	if self._instance then
        if self.sprite then
            self.sprite:delete()
            self.sprite = nil
        end
		if self.smokeBg then
		    gGetGameUIManager():RemoveUIEffect(self.smokeBg)
		end
		if self.roleEffectBg then
		    gGetGameUIManager():RemoveUIEffect(self.roleEffectBg)
		end
		self:OnClose()
		getmetatable(self)._instance = nil
        _instance = nil
	end
end

function NpcSceneSpeakDialog:defineNpcSpeakWords(headID, npcName, msg, facePath, npcId, npcSound)
    local name = npcName
    if headID == 0 then
        npcName = gGetDataManager():GetMainCharacterName()
        local roleShape = gGetDataManager():GetMainCharacterShape()
        local npcShape = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(roleShape)
        if npcShape.id ~= -1 then
            headID = npcShape.headID
            npcId = 0
        end
    end

    if name ~= "" then
        self.m_pName:setText(name)
    end

    if headID > 0 then
        local iconpath = gGetIconManager():GetImagePathByID(headID):c_str()
        if string.len(iconpath) > 0 then
            self.m_pHeadIcon:setProperty("Image", iconpath)
        end
    end

    if string.len(facePath) > 0 then
        self.m_pHeadIcon:setProperty("Image", facePath)
    end

    if self.m_pContentBox then
        self.m_pContentBox:Clear()
        if not string.find(msg, "<T") then
            msg = "<T t=\"" .. tostring(msg) .. "\"></T>"
        end
        self.m_pContentBox:AppendParseText(CEGUI.String(msg))
        self.m_pContentBox:Refresh()

        local extentHeight = self.m_pContentBox:GetExtendSize().height
        self.m_pContentBox:setYPosition(CEGUI.UDim(0,(self.m_ContentBoxBgHeight - extentHeight) * 0.5))
    end

    if npcId >= 0 and string.len(npcSound) > 0 then
        gGetGameUIManager():PlayNPCSound(npcSound, npcId, true)
    end

    self.m_fNextChatTimeDt = 0
    self.m_bUpNextCd = true
end

function NpcSceneSpeakDialog.isShow()
    if _instance then
        return true
    end
    return false
end

function NpcSceneSpeakDialog:initUIWindow()
    Dialog.OnCreate(self)
    local winMgr = CEGUI.WindowManager:getSingleton()
    self.m_pTopPanel = winMgr:getWindow("npcsceneaniback/TopPanel")
    self.m_pBottomPanel = winMgr:getWindow("npcsceneaniback/BottomPanel")
    self.m_pHeadIcon = winMgr:getWindow("npcsceneaniback/BottomPanel/head")
    self.m_pName = winMgr:getWindow("npcsceneaniback/BottomPanel/name")
    self.m_pContentBox = CEGUI.toRichEditbox(winMgr:getWindow("npcsceneaniback/BottomPanel/content"))
    self.m_ContentBoxBgHeight = self.m_pContentBox:getPixelSize().height
    self.m_pNameBg = winMgr:getWindow("npcsceneaniback/BottomPanel/bac1")
    self:GetWindow():subscribeEvent("MouseButtonDown", NpcSceneSpeakDialog.mouchClickCallback, self)
	self.smokeBg = winMgr:getWindow("npcsceneaniback/BottomPanel/jian")
	local s = self.smokeBg:getPixelSize()
	local flagSmoke = gGetGameUIManager():AddUIEffect(self.smokeBg, "geffect/ui/mt_shengqishi/mt_shengqishi13", true, s.width*0.5, s.height)
end

function NpcSceneSpeakDialog:initDataValue(npcId, npcBaseId, questId)
    self.m_iConversationIndex = 0
    self.m_bMainCharSpeak = false
    self.m_npcBaseID = npcBaseId
    self.m_npcID = npcId
    self.m_questID = questId
    self.m_fAniElapseTime = 0
    self.m_fNextChatTime = 20000
    self.m_WndState = STATE_START_DELAYING
    self.m_fAniDelayTime = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(175).value)
    self.m_fAniTotalTime = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(172).value)
    self.m_fAniOverDelayTime = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(176).value)
    self.m_iconXOld = self.m_pHeadIcon:getXPosition()
    self.m_nameYOld = self.m_pNameBg:getYPosition()
    self.m_udimTopYSizeMax = self.m_pTopPanel:getPixelSize().height
    self.m_udimBottomYSizeMax = self.m_pBottomPanel:getPixelSize().height
    self.m_udimBottomYPosOrg = self.m_pBottomPanel:getYPosition().offset
    self.m_udimTopYPosOrg = 0
    self.m_fAniSpeedTop = self.m_udimTopYSizeMax / self.m_fAniTotalTime
    self.m_fAniSpeedBottom = self.m_udimBottomYSizeMax / self.m_fAniTotalTime
    local iconWidth = self.m_pHeadIcon:getWidth()
    local nameHeight = self.m_pNameBg:getHeight()
    self.m_fIconSpeed = iconWidth.offset / self.m_fAniTotalTime
    self.m_fNameSpeed = nameHeight.offset / self.m_fAniTotalTime
end


return NpcSceneSpeakDialog