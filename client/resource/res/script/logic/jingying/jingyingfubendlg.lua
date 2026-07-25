

require "logic.dialog"
require "utils.mhsdutils"
require "manager.beanconfigmanager"
require "logic.task.renwulistdialog"
require "logic.jingying.jingyingenddlg"

Jingyingfubendlg = {
    m_iLeftTime = 0,

}
setmetatable(Jingyingfubendlg, Dialog)
Jingyingfubendlg.__index = Jingyingfubendlg 

local _instance

function Jingyingfubendlg.IsShow()

    if _instance and _instance:IsVisible() then
        return true
    end

    return false
end

function Jingyingfubendlg.getInstance()
	LogInfo("Jingyingfubendlg.getInstance")
    if not _instance then
        _instance = Jingyingfubendlg:new()
        _instance:OnCreate()
    end

    return _instance
end

function Jingyingfubendlg.getInstanceAndShow( fubenType )
    if not _instance then
        _instance = Jingyingfubendlg:new()
        _instance:OnCreate( fubenType )
	else
		_instance:SetVisible(true)
    end
    return _instance
end

function Jingyingfubendlg.getInstanceNotCreate()
    return _instance
end

function Jingyingfubendlg.DestroyDialog()
    Renwulistdialog.outJingyingFuben()
    if _instance then
    	GetTaskManager().EventUpdateLastQuest:RemoveScriptFunctor(_instance.m_hUpdateLastQuest)
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function Jingyingfubendlg:OnClose()
    Dialog.OnClose(self)
end

function Jingyingfubendlg.ToggleOpenClose( fubenType )
	if not _instance then 
		_instance = Jingyingfubendlg:new() 
		_instance:OnCreate( fubenType )
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function Jingyingfubendlg.GetLayoutFileName()
    return "jingyingfuben_mtg.layout"
end

function Jingyingfubendlg:OnCreate( fubenType )
	LogInfo("enter Jingyingfubendlg oncreate")
    Dialog.OnCreate(self)
    self._fubenType = fubenType
    local winMgr = CEGUI.WindowManager:getSingleton()
    
    self.closeBtn = CEGUI.Window.toPushButton(winMgr:getWindow("jingyingfuben_mtg/btn"))
    self.closeBtn:setVisible(true)
    self.closeBtn:subscribeEvent("Clicked", Jingyingfubendlg.HandleExitMapBtnClicked, self)
    
    self.m_pTaskTrace = CEGUI.Window.toRichEditbox(winMgr:getWindow("jingyingfuben_mtg/main"))
    self.m_pTaskTrace:setMousePassThroughEnabled(true)
    self.m_pTaskTraceName = winMgr:getWindow("jingyingfuben_mtg/name")
    self.m_pTaskTraceName:setMousePassThroughEnabled(true)
    self.m_pTaskTraceMark = winMgr:getWindow("jingyingfuben_mtg/mark")
    self.m_pTaskTraceMark:setMousePassThroughEnabled(true)
    self.m_pTaskBack = winMgr:getWindow("jingyingfuben_mtgcell")
    self.m_pTaskBack:subscribeEvent("MouseButtonDown", Jingyingfubendlg.HandleGoToClicked, self)
    

    self.nBgFrameHeightOld = self.m_pTaskBack:getPixelSize().height
	self.nBoxHeightOld = self.m_pTaskTrace:getPixelSize().height

    self:RefreshJingyingTask(fubenType)
    self.m_hUpdateLastQuest = GetTaskManager().EventUpdateLastQuest:InsertScriptFunctor(Jingyingfubendlg.RefreshLastTask)
    self:HideOrShowMainBtns(false)
    self:RefreshJingyingTask()
    
    Renwulistdialog.enterJingyingfuben()
    
end

function Jingyingfubendlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, Jingyingfubendlg)
    return self
end

function Jingyingfubendlg:refreshCellForEnd(bEnd)
	if bEnd then
		local strEndTitle = require("utils.mhsdutils").get_resstring(11260)
		_instance.m_pTaskTraceName:setText(strEndTitle) 
		_instance.m_pTaskTrace:Clear()
		_instance.m_pTaskTrace:Refresh()
        self.m_pTaskBack:setVisible(true)
		self.m_pTaskBack:setEnabled(true)
		self.m_pTaskTraceMark:setVisible(false) --battle zi
		
	else
		self.m_pTaskBack:setVisible(true)
		self.m_pTaskBack:setEnabled(true)
		self.m_pTaskTraceMark:setVisible(true)
	end
end


function Jingyingfubendlg:isHaveFubenTask()
    
    local hasFubenTask = false
    
    if _instance._fubenType == 1 then
        
        local tt = BeanConfigManager.getInstance():GetTableByName("mission.cjingyingconfig")
        local ids = tt:getAllID()
        local num = tt:getSize()

        for i = 1, num, 1 do
            local nFubenId = ids[i]
            local record = tt:getRecorder(nFubenId)
            local nTaskTypeId = record.taskid
            local pActiveQuest = GetTaskManager():GetReceiveQuest(nTaskTypeId)
            if pActiveQuest then
                hasFubenTask = true
            end
        end
	
	    local bEnd = not hasFubenTask
        return hasFubenTask

    elseif _instance._fubenType == 2 then
        local tt = BeanConfigManager.getInstance():GetTableByName("instance.cshiguangzhixuenpc")
        local ids = tt:getAllID()
        local num = tt:getSize()

        for i = 1, num do
            local nFubenId = ids[i]
            local record = tt:getRecorder(nFubenId)
            local nTaskTypeId = record.taskid
            local pActiveQuest = GetTaskManager():GetReceiveQuest(nTaskTypeId)
            if pActiveQuest then
                hasFubenTask = true
            end
        end
	
	    local bEnd = not hasFubenTask
        return hasFubenTask
    end
    
end


function Jingyingfubendlg:RefreshJingyingTask( fubenType )
    if fubenType == 1 then 

        local hasText = false
        local tt = BeanConfigManager.getInstance():GetTableByName("mission.cjingyingconfig")
        local ids = tt:getAllID()
        
        local num = #ids

        for i = 1, num, 1 do
            local record = tt:getRecorder(ids[i])
            if self:RefreshATask(record.taskid) then
                hasText = true
                break
            end
        end
        
        local bEnd = not hasText
        self:refreshCellForEnd(bEnd)
    elseif fubenType == 2 then 
        --local ids = std.vector_int_()
        local hasText = false                                                               
        local tt = BeanConfigManager.getInstance():GetTableByName("instance.cshiguangzhixuenpc")
        local ids = tt:getAllID()
        local num = tt:getSize()
        for i = 1, num do
            local record = tt:getRecorder(ids[i])
            if self:RefreshATask(record.taskid) then
                hasText = true
                break
            end
        end
        
        local bEnd = not hasText
        self:refreshCellForEnd(bEnd)
    end

end


function Jingyingfubendlg:RefreshATask(nTaskTypeId)
	LogInfo("Jingyingfubendlg:RefreshATask(nTaskTypeId)="..nTaskTypeId)
    local pActiveQuest = GetTaskManager():GetReceiveQuest(nTaskTypeId)
    if not pActiveQuest then
		return false
	end		
	local nNpcId = pActiveQuest.dstnpcid
	local nMapId = pActiveQuest.dstmapid
	local strNpcName = pActiveQuest.npcname
	local tt		
    if self._fubenType == 1 then 
        tt = BeanConfigManager.getInstance():GetTableByName("circletask.cfubentask")
    elseif self._fubenType == 2 then 
        tt = BeanConfigManager.getInstance():GetTableByName("instance.cshiguangzhixueconfig")
    end 
	
    local fubenTaskTable = tt:getRecorder(nTaskTypeId)
    if not fubenTaskTable or fubenTaskTable.id == -1 then
		LogInfo("error=nTaskTypeId"..nTaskTypeId)
        return false
    end

    self.m_pTaskTraceMark:setVisible(true)
       
    local sb = StringBuilder:new()
    local npcConfig = BeanConfigManager.getInstance():GetTableByName("npc.cnpcconfig"):getRecorder(pActiveQuest.dstnpcid)
    if npcConfig then
        sb:Set("NPCName", npcConfig.name)
    end
	sb:Set("mapid", "0")
    sb:Set("xPos", "0")
    sb:Set("yPos", "0")
	sb:Set("npcid","0")
		
    self.m_pTaskTraceName:setText(fubenTaskTable.tracetitle)
    self.m_pTaskTrace:Clear()
    local strContent = fubenTaskTable.tracedes
   
    self.m_pTaskTrace:AppendParseText(CEGUI.String(sb:GetString(strContent)))
    self.m_pTaskTrace:Refresh()

	sb:delete()
		
   	local nAddHeight = self.m_pTaskTrace:GetExtendSize().height - self.nBoxHeightOld
    nAddHeight = nAddHeight > 0 and nAddHeight or 0
	nAddHeight = nAddHeight + 10

    self.m_pTaskBack:setHeight(CEGUI.UDim(0,self.nBgFrameHeightOld + nAddHeight))
    self.m_pTaskTrace:setHeight(CEGUI.UDim(0,self.nBoxHeightOld + nAddHeight))

   -- self.closeBtn:setpositionY
    self.closeBtn:setYPosition(CEGUI.UDim(0, self.m_pTaskTrace:getYPosition().offset + self.nBoxHeightOld + nAddHeight + 85))
	self.m_pTaskBack.nTaskTypeId = nTaskTypeId
    require("logic.task.renwulistdialog").showFubenTaskPanel()
	return true
end


function Jingyingfubendlg.isFubenTask(nTaskTypeId)
	local bFubenTask = false
	
    if _instance._fubenType == 1 then 
        local jyInstance = nil
        jyInstance = BeanConfigManager.getInstance():GetTableByName("mission.cjingyingconfig")
        local vcTableId = jyInstance:getAllID(vcTableId)
        local num = #vcTableId
        for nIndex = 1, num, 1 do
            local record = jyInstance:getRecorder(vcTableId[nIndex])
            if record.taskid == nTaskTypeId then
                bFubenTask = true
			    break
            end
        end
	    return bFubenTask
    elseif _instance._fubenType == 2 then 
        local jyInstance = BeanConfigManager.getInstance():GetTableByName("instance.cshiguangzhixuenpc")
        local vTableId = jyInstance:getAllID()
        local num = #vTableId
        for nIndex = 1, num, 1 do
            local record = jyInstance:getRecorder(vTableId[nIndex])
            if record.taskid == nTaskTypeId then
                bFubenTask = true
			    break
            end
        end
	    return bFubenTask
    end

   
end


function Jingyingfubendlg.RefreshLastTask(questid)    
    if not _instance then
        return
    end
    local isJingyingTask = Jingyingfubendlg.isFubenTask(questid)
    if not isJingyingTask then
        return
    end
    if _instance:RefreshATask(questid) then
        _instance.m_pTaskBack:setVisible(true)
		_instance:refreshCellForEnd(false)
    else
		_instance:refreshCellForEnd(true)
    end
end

function Jingyingfubendlg:HandleGoToClicked(e)

    local bHaveFubenTask = Jingyingfubendlg.isHaveFubenTask()
    if not bHaveFubenTask then
        Jingyingenddlg.sendOutJingying()
        return 
    end
    
	local mouseArgs = CEGUI.toMouseEventArgs(e)
	local clickWin = mouseArgs.window
    local nTaskTypeId = clickWin.nTaskTypeId
	local pActiveQuest = GetTaskManager():GetReceiveQuest(nTaskTypeId)
    if not pActiveQuest then
		return
	end	
    if GetTeamManager():isMyselfAbsent() then
        if GetChatManager() then
			GetChatManager():AddTipsMsg(144840)
		end
        return
    end		
	local nNpcId = pActiveQuest.dstnpcid
	local nMapId = pActiveQuest.dstmapid
	local nNpcKey = pActiveQuest.dstnpckey
	local nTargetPosX = pActiveQuest.dstx
	local nTargetPosY = pActiveQuest.dsty
	local nRandX,nRandY = require("logic.task.taskhelper").GetRandPosWithMapId(nMapId)
	
	local flyWalkData = {}
	require("logic.task.taskhelpergoto").GetInitedFlyWalkData(flyWalkData)
	--//-======================================
	flyWalkData.nMapId = nMapId
	flyWalkData.nNpcId = nNpcId
	flyWalkData.nNpcKey = nNpcKey
	flyWalkData.nRandX = nRandX
	flyWalkData.nRandY = nRandY
	--flyWalkData.bXunLuo = 0
	flyWalkData.nTargetPosX = nTargetPosX
	flyWalkData.nTargetPosY = nTargetPosY
	--//-======================================
	require("logic.task.taskhelpergoto").FlyOrWalkTo(flyWalkData)
	
    return true
end
 

function Jingyingfubendlg:HandleExitMapBtnClicked(args)
    if GetTeamManager():IsMyselfLeader() then
        local strMsg =  require "utils.mhsdutils".get_msgtipstring(166114)
        local function ClickYes(args)
            GetMainCharacter():clearGoTo()
            Jingyingenddlg.sendOutJingying()
            gGetMessageManager():CloseConfirmBox(eConfirmNormal, false)
        end
        gGetMessageManager():AddConfirmBox(eConfirmNormal, strMsg, ClickYes, 0, MessageManager.HandleDefaultCancelEvent, MessageManager)
    else
        GetMainCharacter():clearGoTo()
        Jingyingenddlg.sendOutJingying()
    end
    return true
end

function Jingyingfubendlg:HideOrShowMainBtns(flag)
    LogoInfoDialog.GetInstanceRefreshAllBtn()
	
    if flag then
        if gGetWelfareManager() then
			LogoInfoDialog.GetInstanceRefreshAllBtn()
        end
    end
end

function Jingyingfubendlg:HandleWindowUpate(args)

end

function Jingyingfubendlg.SetTimeLabelVisible(flag)
	print("Jingyingfubendlg.SetTimeLabelVisible")
    if _instance ~= nil then
    end
end

return Jingyingfubendlg




