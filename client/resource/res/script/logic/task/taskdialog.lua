require "logic.dialog"
require "utils.commonutil"
require "logic.task.taskhelper"


require "protodef.rpcgen.fire.pb.circletask.specialqueststate"
local spcQuestState = SpecialQuestState:new()


local DEFAULT_COLOR = "ff743a0f"  

local TASK_FONT_SIZE = 13
local TASK_FONT_COLOR = "ffffffff" 

local TASK_FONT_SIZE1 = 12
local TASK_FONT_COLOR1 = "ffffffff" 

Renwudialog = {}
setmetatable(Renwudialog, Dialog)
Renwudialog.__index = Renwudialog

local _instance

local  nRiChangId = TaskHelper.nRiChangId
local  nHuodongId = TaskHelper.nHuodongId
local  nMainTaskId = TaskHelper.nMainTaskId
local  nFenZhiId = TaskHelper.nFenZhiId
local  nJuBaoId = TaskHelper.nJuBaoId
local  nLeaveTaskId = TaskHelper.nLeaveTaskId
local  nAnyeFollow = TaskHelper.nAnyeFollow

function Renwudialog:SetGroupBtnTreeItemStyle(item, isParent)
    if not item then
        return
    end
    local fontSize = TASK_FONT_SIZE
    if not isParent then
        fontSize = 12  -- 设置子节点字体大小为 12
    end
    local text = item:getText()
    text = CEGUI.String(string.format("[font='simhei-%d'][colour='%s']%s[/colour][/font]", fontSize, TASK_FONT_COLOR, text))
    item:setText(text)
end

function Renwudialog:SetGroupBtnTreeItemStylec(item)
  if not item then
    return
  end

  local text = item:getText()
  text = CEGUI.String(string.format("[font='simhei-%d'][colour='%s']%s[/colour][/font]", TASK_FONT_SIZE1, TASK_FONT_COLOR1, text))
  item:setText(text)
end

function Renwudialog.getInstance()
	if not _instance then
		_instance = Renwudialog:new()
		_instance:OnCreate()
	end
	return _instance
end

function Renwudialog.getInstanceAndShow()
	if not _instance then
		_instance = Renwudialog:new()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function Renwudialog.getInstanceNotCreate()
	return _instance
end

function Renwudialog.DestroyDialog()
	if _instance == nil then
		return
	end
	_instance.m_btnGotoGot.animation:stop()
	_instance.m_btnNowGot.animation:stop()
	_instance.m_btnRenxing.animation:stop()
	_instance.m_btnGiveUp.animation:stop()
	
	GetTaskManager().EventUpdateLastQuest:RemoveScriptFunctor(_instance.m_hUpdateLastQuest)
    GetTaskManager():RemoveTaskTraceStateChangeNotify(Renwudialog.OnTaskTraceStateChangeNotify)
	
	if _instance then		
		if TaskLabel.getInstanceNotCreate() then
			TaskLabel.getInstanceNotCreate().DestroyDialog()		
		else
			_instance:OnClose()
		end
	end

end

function Renwudialog:OnClose()
    self:clearData()
	self.tabHaveTask.m_groupbtnLeft:resetList()
	self.tabCanGetTask.m_groupbtnLeft:resetList()
	self.m_pRiChangItem = nil
	self.m_pJuBaoItem = nil
	self.m_pCanGetFenZhiItem = nil
	self.m_pAcpActivityItem = nil
    self.m_pHuoDongItem = nil
	self.m_pLeftItem = nil
	self.m_pScenarioItem = nil
	self.m_pCanGetLeftItem = nil
	self.m_pCanGetRiChangItem = nil
    self.m_pFenZhiItem = nil
	if _instance == nil then
		return
	end

	Dialog.OnClose(self)
	_instance = nil
end

function Renwudialog.ToggleOpenHide()
	
	if _instance == nil then
		_instance = Renwudialog.new()
	else
		local bVisible = _instance:IsVisible()
		if bVisible then
			_instance:OnClose();
		else
			_instance:SetVisible(true);
		end
	end
end

function Renwudialog:clearData()
    self.nRefreshAnyeUICdDt = 0
    self.nRefreshAnyeUICd = 1000
end

function Renwudialog.GetLayoutFileName()
	return "taskdialog_mtg.layout"
end

function Renwudialog.new()
	local self = {}
	setmetatable(self, Renwudialog)
	self.__index = Renwudialog
	self.m_nCurSelTaskId = 0
	self.m_iSelectedAcpTaskId = 0
    self:clearData()

	self:OnCreate()
	if GetTaskManager() then
		LogInsane("TaskManager not init")
		GetTaskManager():RegisterLuaTaskDlgFunction(Renwudialog.RemoveAcceptableQuest, "Renwudialog.RemoveAcceptableQuest")
	end
	return self
end

function Renwudialog:RemoveCanGetTasktItem(pParentItem, pChildItem)
	if not self.tabCanGetTask.m_groupbtnLeft:isTreeItemInList(pParentItem) then
		return
	end
	if pChildItem and self.m_iSelectedAcpTaskId == pChildItem:getID() then
		self.m_iSelectedAcpTaskId = 0;
		self.tabCanGetTask.m_txtRightIntro:Clear()
		self.tabCanGetTask.m_txtRightIntro:Refresh()
	end
	pParentItem:removeItem(pChildItem)
	pChildItem = nil
	if pParentItem:getItemCount() == 0 then
		self:RemoveAcpFirstLevelItem()
	end
end

function Renwudialog:RemoveAcpFirstLevelItem()
	if  self.m_pAcpActivityItem and 0 == self.m_pAcpActivityItem:getItemCount() then
         self.tabCanGetTask.m_groupbtnLeft:removeItem(self.m_pAcpActivityItem);
         self.m_pAcpActivityItem = nil
    end
    if (self.m_pCanGetLeftItem and 0 == self.m_pCanGetLeftItem:getItemCount()) then
         self.tabCanGetTask.m_groupbtnLeft:removeItem(self.m_pCanGetLeftItem)
         self.m_pCanGetLeftItem = nil
    end
    if (self.m_pCanGetFenZhiItem and 0 == self.m_pCanGetFenZhiItem:getItemCount()) then
         self.tabCanGetTask.m_groupbtnLeft:removeItem(self.m_pCanGetFenZhiItem)
         self.m_pCanGetFenZhiItem = nil
    end
	if (self.m_pCanGetRiChangItem and 0 == self.m_pCanGetRiChangItem:getItemCount()) then
         self.tabCanGetTask.m_groupbtnLeft:removeItem(self.m_pCanGetRiChangItem)
         self.m_pCanGetRiChangItem = nil
    end
end

function Renwudialog:removeAnyeTaskItem()
    if not  self.m_pAnyeFollowItem then 
        return
    end
    self.tabHaveTask.m_groupbtnLeft:removeItem(self.m_pAnyeFollowItem)
    self.m_pAnyeFollowItem = nil
    self.m_nCurSelTaskId = 0
    self:refreshDefaultSel()
    self.tabHaveTask.m_groupbtnLeft:getVertScrollbar():setScrollPosition(0)
    self.tabHaveTask.m_groupbtnLeft:invalidate()
end

function Renwudialog:RemoveAnyeFollowItem()
    if not self.m_pAnyeFollowItem then 
        return
    end
    if not self.anyeSearchTadkItem then 
        return
    end

     self:RemoveQuestItem(self.m_pAnyeFollowItem,self.anyeSearchTadkItem)
     self.m_pAnyeFollowItem = nil
     self.anyeSearchTadkItem = nil
     self.m_nCurSelTaskId = 0
    self:refreshDefaultSel()

end

function Renwudialog:addButtonAnimation(button, animationName)
    local animationDef = CEGUI.AnimationManager:getSingleton():getAnimation(animationName)
    if animationDef then
        local animation = CEGUI.AnimationManager:getSingleton():instantiateAnimation(animationDef)
        animation:setTargetWindow(button)
        animation:setSpeed(0.7)
        button.animation = animation
        button:subscribeEvent("MouseButtonDown", function()
            animation:start()
        end, self)
    end
end

function Renwudialog:OnCreate()
	Dialog.OnCreate(self)
	SetPositionOfWindowWithLabelsx(self:GetWindow())
	self.m_hUpdateLastQuest = GetTaskManager().EventUpdateLastQuest:InsertScriptFunctor(Renwudialog.RefreshLastTask)
    GetTaskManager():InsertTaskTraceStateChangeNotify(Renwudialog.OnTaskTraceStateChangeNotify)

	local winMgr = CEGUI.WindowManager:getSingleton()
	self.m_bg = CEGUI.toFrameWindow(winMgr:getWindow("TaskDialog_mtg"))
	
	
	self.tabHaveTask = {}
	self.tabHaveTask.m_bgRight = winMgr:getWindow("TaskDialog_mtg/right")
	self.tabHaveTask.m_groupbtnLeft = CEGUI.toGroupBtnTree(winMgr:getWindow("TaskDialog_mtg/tree"))
	self.tabHaveTask.m_txtRightTitle = winMgr:getWindow("TaskDialog_mtg/right/name")
	self.tabHaveTask.m_txtRightIntro = CEGUI.toRichEditbox(winMgr:getWindow("TaskDialog_mtg/right/jianjie"))
	self.tabHaveTask.m_txtRightDetail = CEGUI.toRichEditbox(winMgr:getWindow("TaskDialog_mtg/right/jianshu"))
	self.tabHaveTask.m_groupbtnLeft:subscribeEvent("ItemSelectionChanged", Renwudialog.HandleSelectedCurrentTask, self)

	self.tabCanGetTask = {}
	self.tabCanGetTask.m_bgRight = winMgr:getWindow("TaskDialog_mtg/right1")	
	self.tabCanGetTask.m_groupbtnLeft = CEGUI.toGroupBtnTree(winMgr:getWindow("TaskDialog_mtg/tree1"))
	self.tabCanGetTask.m_txtRightTitle = winMgr:getWindow("TaskDialog_mtg/right/name1")
	self.tabCanGetTask.m_txtRightIntro = CEGUI.toRichEditbox(winMgr:getWindow("TaskDialog_mtg/right/jianjie1"))
	self.tabCanGetTask.m_txtRightDetail = CEGUI.toRichEditbox(winMgr:getWindow("TaskDialog_mtg/right/jianshu1"))
	self.tabCanGetTask.m_groupbtnLeft:subscribeEvent("ItemSelectionChanged", Renwudialog.HandleSelectedAcpTask, self)
	
	self.m_btnGotoGot = CEGUI.toPushButton(winMgr:getWindow("TaskDialog_mtg/btnqianwang"))
	self:addButtonAnimation(self.m_btnGotoGot, "studyBtnPress")
	self.m_btnGotoGot:subscribeEvent("Clicked", Renwudialog.HandleAcceptBtnClicked, self)

	self.m_btnNowGot = CEGUI.toPushButton(winMgr:getWindow("TaskDialog_mtg/btnmashang"))
	self:addButtonAnimation(self.m_btnNowGot, "studyBtnPress")
	self.m_btnNowGot:subscribeEvent("Clicked", Renwudialog.clickGoto, self)
	
	self.m_btnRenxing = CEGUI.toPushButton(winMgr:getWindow("TaskDialog_mtg/btnrenxing"))
	self:addButtonAnimation(self.m_btnRenxing, "studyBtnPress")
	
	self.m_btnGiveUp = CEGUI.toPushButton(winMgr:getWindow("TaskDialog_mtg/btnfangqi"))
	self:addButtonAnimation(self.m_btnGiveUp, "studyBtnPress")
	self.m_btnGiveUp:subscribeEvent("Clicked", Renwudialog.HandleAbandonTask, self)

    self.m_meirenwu = winMgr:getWindow("TaskDialog_mtg/meirenwu")
    self.m_meirenwuText = winMgr:getWindow("TaskDialog_mtg/wurenwu")
    self.m_meirenwu:setVisible(false)
	self.m_meirenwuText:setVisible(false)
	self.m_nSelectID = 0
	
	self:UpdateCurrentTaskList()
	self:UpdateAcceptableTaskList()
end

function Renwudialog:RemoveQuestItem(pParentItem, pChildItem)
	LogInsane("Renwudialog:RemoveQuestItem")
	local m_pCurrentTree = self.tabHaveTask.m_groupbtnLeft
	if not m_pCurrentTree:isTreeItemInList(pParentItem) then
		return
	end
	
	local taskid = pChildItem and pChildItem:getID() or 0
	LogInsane(string.format("plz remove task id=%d, curtaskid=%d", taskid, self.m_nCurSelTaskId))
	local pChildItem = self.tabHaveTask.m_groupbtnLeft:findFirstItemWithID(taskid)
	if pChildItem and self.m_nCurSelTaskId == taskid then
		self.m_nCurSelTaskId = 0
	end
	
	pParentItem:removeItem(pChildItem)
	pChildItem = nil
	if pParentItem:getItemCount() == 0 then
		self:deleteCurTreeFirstItem()	
	end	
	
end


function Renwudialog:clickGoto(e)
	if self.m_nCurSelTaskId == 0 then
		return true;
	end
	
	require("logic.fuben.fubenmanager").getInstance():checkForSendExitFuben()	
	local nTaskTypeId = self.m_nCurSelTaskId
	local bLuaHandleSuccess = TaskHelper.OnClickCellGoto(self.m_nCurSelTaskId)
	Renwudialog.DestroyDialog()
	return true
end


function Renwudialog:UpdateCurrentTaskList()
  --special  quest
  local specialquests = GetTaskManager():GetSpecailQuestForLua()
  local specialquestnum = specialquests:size()
  for i = 0, specialquestnum - 1 do
    local specialquest = specialquests[i]
    if specialquest.questid ~= 0 and specialquest.queststate ~= spcQuestState.ABANDONED then
      if self.m_pRiChangItem == nil then
        local title = MHSD_UTILS.get_resstring(240) --day task
        self.m_pRiChangItem = self.tabHaveTask.m_groupbtnLeft:addItem(CEGUI.String(title), nRiChangId)
        SetGroupBtnTreeFirstIcon2(self.m_pRiChangItem)
        self:SetGroupBtnTreeItemStyle(self.m_pRiChangItem, true) -- 设置主节点样式
      end
      local dailyChild = self.m_pRiChangItem:addItem(CEGUI.String(specialquest.name), specialquest.questid)
      SetGroupBtnTreeSecondIcon2(dailyChild)
      self:RefreshItemNameAndColour(dailyChild, specialquest.queststate)
      self:SetGroupBtnTreeItemStyle(dailyChild, false) -- 设置子节点样式
    end
  end

  local activeQuests = GetTaskManager():GetReceiveQuestListForLua()
  local activeQuestnum = activeQuests:size()
  for i = 0, activeQuestnum - 1 do
    local activeQuest = activeQuests[i]
    if activeQuest.questid ~= 0 then
      if self.m_pRiChangItem == nil then
        local title = MHSD_UTILS.get_resstring(240) --day task
        self.m_pRiChangItem = self.tabHaveTask.m_groupbtnLeft:addItem(CEGUI.String(title),nRiChangId)
        SetGroupBtnTreeFirstIcon2(self.m_pRiChangItem)
        self:SetGroupBtnTreeItemStyle(self.m_pRiChangItem)
      end

      local config = BeanConfigManager.getInstance():GetTableByName("circletask.cspecialquestconfig"):getRecorder(activeQuest.questid)
      if config and config.id ~= -1 then
      local dailyChild = self.m_pRiChangItem:addItem(CEGUI.String(config.questname), activeQuest.questid)
      SetGroupBtnTreeSecondIcon2(child)
      self:RefreshItemNameAndColour(child, activeQuest.queststate)
      self:SetGroupBtnTreeItemStyle(child, false)
      end
    end
  end

  --scenario quest
  local scenarioquests = GetTaskManager():GetScenarioQuestListForLua()
  local scenarioquestnum = scenarioquests:size()
  for i = 0, scenarioquestnum - 1 do
    local scenarioquest = scenarioquests[i]
    
    local questTable = GameTable.mission.GetCMainMissionInfoTableInstance():getRecorder(scenarioquest.missionid)
    if questTable and questTable.id ~= -1 then
    
      local pParentItem = self:GetParentItemByTaskID(questTable.id, true)
      local strTaskName = questTable.MissionTypeString
      local dailyChild = pParentItem:addItem(CEGUI.String(strTaskName), questTable.id)
      SetGroupBtnTreeSecondIcon2(dailyChild)
      self:RefreshItemNameAndColour(dailyChild, scenarioquest.missionstatus)
      self:SetGroupBtnTreeItemStyle(dailyChild, false)
    end 
  end
    ---------------------
   local taskmanager = require("logic.task.taskmanager").getInstance()
   local bNeedToNpc =  taskmanager:isAnyeNeedToGotoNpc()
    

     local TaskHelper = require("logic.task.taskhelper") 
    --local nTaskTypeId  = TaskHelper.nAnyeTaskTypeId
    local taskmanager = require("logic.task.taskmanager").getInstance()
    if #taskmanager.vAnyeTask > 0 then
        if bNeedToNpc==false then
        if self.m_pAnyeFollowItem == nil then
        local title = MHSD_UTILS.get_resstring(11553) 
        self.m_pAnyeFollowItem = self.tabHaveTask.m_groupbtnLeft:addItem(CEGUI.String(title),nAnyeFollow)
      SetGroupBtnTreeFirstIcon2(self.m_pAnyeFollowItem)
      self:SetGroupBtnTreeItemStyle(self.m_pAnyeFollowItem) 
        end
        local nTaskTypeId  = TaskHelper.nAnyeTaskTypeId
        local strAnyeTitle = MHSD_UTILS.get_resstring(11559) 
        --local anyeRecord = BeanConfigManager.getInstance():GetTableByName("circletask.canyemaxituanconf"):getRecorder(nTaskTypeId)
        local dailyChild = self.m_pAnyeFollowItem:addItem(CEGUI.String(strAnyeTitle), nTaskTypeId)
      SetGroupBtnTreeSecondIcon2(dailyChild)
      self:RefreshItemNameAndColour(dailyChild, 2)
      self:SetGroupBtnTreeItemStyle(dailyChild, false)

        end
    end

  --//====================================
    local lastselectid = -1
    local Taskmanager = require("logic.task.taskmanager").getInstance()
     if Taskmanager.nLastSelTaskId ~= -1 then
        lastselectid = Taskmanager.nLastSelTaskId
     end
  
  local item = self.tabHaveTask.m_groupbtnLeft:findFirstItemWithID(lastselectid)
  if item == nil then
      self:refreshDefaultSel()
  else
    self.m_nCurSelTaskId = lastselectid
    self:DefaultSelectItem(nil, item)
  end
    ----------------------
    local taskmanager = require("logic.task.taskmanager").getInstance()
    if taskmanager.m_nAnyeFollowIndex >= 1 and taskmanager.m_nAnyeFollowIndex <= 8 then
      if self.m_pAnyeFollowItem == nil then
        local title = MHSD_UTILS.get_resstring(11553) --day task
        self.m_pAnyeFollowItem = self.tabHaveTask.m_groupbtnLeft:addItem(CEGUI.String(title),nAnyeFollow)
            SetGroupBtnTreeFirstIcon2(self.m_pAnyeFollowItem)
        self:SetGroupBtnTreeItemStyle(self.m_pAnyeFollowItem)
        end
            local oneTaskData =  taskmanager.vAnyeTask[taskmanager.m_nAnyeFollowIndex]
            if oneTaskData then
                local nTaskTypeId  = oneTaskData.id
                local anyeRecord = BeanConfigManager.getInstance():GetTableByName("circletask.canyemaxituanconf"):getRecorder(nTaskTypeId)
                if anyeRecord then
                self.anyeSearchTadkItem = self.m_pAnyeFollowItem:addItem(CEGUI.String(anyeRecord.followtitle), nTaskTypeId)
                SetGroupBtnTreeSecondIcon2(self.anyeSearchTadkItem)
                self:RefreshItemNameAndColour(self.anyeSearchTadkItem, 2)
                self:SetGroupBtnTreeItemStyle(self.anyeSearchTadkItem, false)
                end

            end
    end
end

function Renwudialog:DefaultSelectItem(pParentItem, pChildItem)
	if self.m_nCurSelTaskId ~= 0 and pParentItem then
		return false
	end
	LogInsane("Enter Renwudialog:DefaultSelectItem")
	if pParentItem and pParentItem:getItemCount() > 0 then
		LogInsane("Get First Tree Item")
		local pItem = pParentItem:getTreeItemFromIndex(0);
		if pItem then
			self.m_nCurSelTaskId = pItem:getID()
			LogInsane("First questid"..pItem:getID())
            self.tabHaveTask.m_groupbtnLeft:SetLastSelectItem(pItem);
            self.tabHaveTask.m_groupbtnLeft:SetLastOpenItem(pParentItem);
            self.tabHaveTask.m_groupbtnLeft:invalidate();
			self:RefreshQuestIntro(self.m_nCurSelTaskId);
			return true;
		end
	else 
		if pChildItem and self.m_nCurSelTaskId then
			local bCurTree = true
	 		local pParentItem = self:GetParentItemByTaskID(self.m_nCurSelTaskId, bCurTree)
	 		if not pParentItem then
	 			LogInsane("Not find questid "..self.m_nCurSelTaskId.."parent item")
	 			return true
	 		end
	 		LogInsane("Selected questid"..self.m_nCurSelTaskId)
            self.tabHaveTask.m_groupbtnLeft:SetLastSelectItem(pChildItem);
	        self.tabHaveTask.m_groupbtnLeft:SetLastOpenItem(pParentItem);
	        self.tabHaveTask.m_groupbtnLeft:invalidate();
			self:RefreshQuestIntro(self.m_nCurSelTaskId);
		end
	end

	return false;
end



function Renwudialog:RefreshQuestIntro(taskid)
	LogInfo("Renwudialog:RefreshQuestIntro(taskid)="..taskid)
	local pSpecialQuest = GetTaskManager():GetSpecialQuest(taskid)
	if pSpecialQuest then
		self:RefreshSpecialQuestIntro(taskid, pSpecialQuest)
		self.m_btnGotoGot:setVisible(true)
		self.m_btnGiveUp:setVisible(true)
		return
	end
	--//active task
	local activequest = GetTaskManager():GetReceiveQuest(taskid)
	if activequest then
		self:RefreshActiveQuestIntro(taskid, activequest)
		self.m_btnGotoGot:setVisible(true)
		self.m_btnGiveUp:setVisible(true)
		return
	end
	--//one time task
	local pScenarioQuest = GetTaskManager():GetScenarioQuest(taskid)
	if pScenarioQuest then
		self:RefreshScenarioQuestIntro(taskid, pScenarioQuest)
		self.m_btnGotoGot:setVisible(true)
		self.m_btnGiveUp:setVisible(true)
	end
    local pAnyeFollow = Taskmanager.getAnyeFollowTask(taskid)
    if pAnyeFollow then
        self:RefreshAnyeFollowIntro(taskid, pAnyeFollow)
		self.m_btnGotoGot:setVisible(true)
		self.m_btnGiveUp:setVisible(true)    
    end

    local TaskHelper = require("logic.task.taskhelper") 
    --local nTaskTypeId  = TaskHelper.nAnyeTaskTypeId

    if taskid == TaskHelper.nAnyeTaskTypeId then
        self:refreshAnyeTaskInfo()
		self.m_btnGotoGot:setVisible(true)
		self.m_btnGiveUp:setVisible(true)  
    end
end

function Renwudialog:refreshAnyeTaskInfo()
    local renwuListDlg = require("logic.task.renwulistdialog").getInstanceNotCreate()
    if renwuListDlg then
            if renwuListDlg:isHaveAnyeTrack()==false then
                return
            end
    end
    
     local taskManager = require("logic.task.taskmanager").getInstance()

    local strValue = GameTable.common.GetCCommonTableInstance():getRecorder(311).value
    local nAllHuan = tonumber(strValue)

    local TaskHelper = require("logic.task.taskhelper") 
    local nTaskTypeId  = TaskHelper.nAnyeTaskTypeId

    
    if nAllHuan==taskManager.nAnyeTimes then
        --_instance:removeTaskCell(nTaskTypeId)
        --return
    end

    local nAllLun = nAllHuan/8
    local nCurHuan = taskManager.nAnyeTimes + 1
    local nCurLun  = math.floor((nCurHuan-1)/8) + 1
    --local newUnit = _instance:getRenwuCell(nTaskTypeId)
    --newUnit.pTitle:setProperty("TextColours", "FFFFFF33")
    local strTrackName = require("utils.mhsdutils").get_resstring(11591)
    local sb = StringBuilder.new()
    sb:Set("parameter1",tostring(nCurLun))
    sb:Set("parameter2",tostring(nAllLun))
    strTrackName = sb:GetString(strTrackName)
    sb:delete()
    
	local strTrackContent =  require("utils.mhsdutils").get_resstring(11592)
    local sb2 = StringBuilder.new()
    sb2:Set("parameter1",tostring(nCurHuan))
    sb2:Set("parameter2",tostring(nAllHuan))
    strTrackContent = sb2:GetString(strTrackContent)
    sb2:delete()

    strTrackContent = self:replaceColor(strTrackContent)
    --local color = CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour(DEFAULT_COLOR))
    --self.richBox:SetColourRect(color)

    --self.tabHaveTask.m_txtRightIntro:SetColourRect(color)
	--self.tabHaveTask.m_txtRightDetail:SetColourRect(color)

    self:ShowQuestIntro(strTrackName,
	strTrackContent,
	strTrackContent,
	0,0,0,nil);

end

function Renwudialog:replaceColor(strContent)
    local strColor = DEFAULT_COLOR
    strColor = "c=".."\""..strColor.."\""
    local strOld = "c=\"FFFFFFFF\""
    strContent = string.gsub(strContent, strOld, strColor)
    return strContent
end


function Renwudialog:RefreshAnyeFollowIntro(taskid, data)
    local taskmanager = require("logic.task.taskmanager").getInstance()
    local taskData = taskmanager.vAnyeTask[taskmanager.m_nAnyeFollowIndex]
    if not taskData then
        return
    end
    local taskDataTime = taskmanager.vAnyeTask[taskmanager.m_nAnyeFollowIndex].legendend
    local taskDataStatus =  taskmanager.vAnyeTask[taskmanager.m_nAnyeFollowIndex].legend
    local anyeRecord = BeanConfigManager.getInstance():GetTableByName("circletask.canyemaxituanconf"):getRecorder(taskid)
    local strTrackContent = ""
    if taskDataStatus == 2 then
        strTrackContent = anyeRecord.dialogdes
    elseif taskDataStatus == 3 then
        strTrackContent = anyeRecord.dialogdessuccess
    elseif taskDataStatus == 4 then
        strTrackContent = anyeRecord.dialogdesfail
    end
    local sb = StringBuilder.new()
    taskmanager:getTaskInfoCorrectSb(taskData,sb)
    if taskDataStatus == 2 then
	    local data = gGetDataManager():GetMainCharacterData()
	    local level = data:GetValue(1230)
        local mapName = ""
        local indexIDs = BeanConfigManager.getInstance():GetTableByName("map.cworldmapconfig"):getAllID()
	    for _, v in pairs(indexIDs) do
		    local mapconfig = BeanConfigManager.getInstance():GetTableByName("map.cworldmapconfig"):getRecorder(v)
		    local minLevel = mapconfig.LevelLimitMin
		    local maxlevel = mapconfig.LevelLimitMax
		    if  level < maxlevel and level > minLevel or level == maxlevel or level == minLevel then
			    mapName = mapconfig.mapName
		    end
	    end
        sb:Set("mapName10",mapName)
        local serverTime = gGetServerTime()
        local disTime = taskDataTime - serverTime
        if disTime > 0 then
            local strTime = ""
            local min = math.floor((disTime / 1000) / 60)
            local strmin = ""
            if min < 10 then
                strmin = "0"..tostring(min)
            else
                strmin = tostring(min)
            end
    
            local sec = math.floor((disTime / 1000 -  min * 60))
            local strsec = ""
            if sec < 10 then
                strsec = "0"..tostring(sec)
            else
                strsec = tostring(sec)
            end
            sb:Set("time",strmin..":"..strsec)
        else
            sb:Set("time","00:00")
        end
        
    end
    strTrackContent = sb:GetString(strTrackContent)
    self:ShowQuestIntro(anyeRecord.followtitle,
	sb:GetString(anyeRecord.followtitledes),
	strTrackContent,
	0,0,0,nil);
    sb:delete()
end
function Renwudialog:RefreshItemNameAndColour(pItem, queststate)
	if queststate == spcQuestState.DONE then
        pItem:setTextColours(CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour(DEFAULT_COLOR)))
	elseif queststate == spcQuestState.FAIL then
        pItem:setTextColours(CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour(DEFAULT_COLOR)))
	else
        pItem:setTextColours(CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour(DEFAULT_COLOR), 
        	CEGUI.PropertyHelper:stringToColour(DEFAULT_COLOR), 
        	CEGUI.PropertyHelper:stringToColour(DEFAULT_COLOR), 
       		CEGUI.PropertyHelper:stringToColour(DEFAULT_COLOR)))
	end
end



function Renwudialog:GetParentItemByTaskID(taskid, bCurrentTree)
	local nParId = 0 
	local nTaskTypeId = taskid
	local eTaskType = TaskHelper.GetTaskShowTypeWithId(nTaskTypeId)
	nParId = eTaskType
	
	local treeTask
	if bCurrentTree then
		treeTask = self.tabHaveTask.m_groupbtnLeft
	else
		treeTask = self.tabCanGetTask.m_groupbtnLeft
	end

	if nParId == nRiChangId then
        if bCurrentTree then
      if not self.m_pRiChangItem then
        local title = MHSD_UTILS.get_resstring(240) --ri chang 
        self.m_pRiChangItem = treeTask:addItem(CEGUI.String(title), nRiChangId)
        SetGroupBtnTreeFirstIcon2(self.m_pRiChangItem);
        self:SetGroupBtnTreeItemStyle(self.m_pRiChangItem, true)
      end
      return self.m_pRiChangItem;
    else 
      if not self.m_pCanGetRiChangItem then
        local strTitle = MHSD_UTILS.get_resstring(240);
        self.m_pCanGetRiChangItem = treeTask:addItem(CEGUI.String(strTitle), nRiChangId)
        SetGroupBtnTreeFirstIcon2(self.m_pCanGetRiChangItem);
        self:SetGroupBtnTreeItemStyle(self.m_pCanGetRiChangItem, true) 
      end
      return self.m_pCanGetRiChangItem;
    end
        return nil;
	elseif nParId == nHuodongId then
        if bCurrentTree then
            if not self.m_pHuoDongItem then
                local title = MHSD_UTILS.get_resstring(241)
                self.m_pHuoDongItem = treeTask:addItem(CEGUI.String(title), nHuodongId)
                SetGroupBtnTreeFirstIcon2(self.m_pHuoDongItem)
                self:SetGroupBtnTreeItemStyle(self.m_pHuoDongItem, true) 
            end
            return self.m_pHuoDongItem;
        else
            if not self.m_pAcpActivityItem then
                local title = MHSD_UTILS.get_resstring(241)
                self.m_pAcpActivityItem = treeTask:addItem(CEGUI.String(title), nHuodongId)
                SetGroupBtnTreeFirstIcon2(self.m_pAcpActivityItem)
                self:SetGroupBtnTreeItemStyle(self.m_pAcpActivityItem, true) 
            end
            return self.m_pAcpActivityItem;
        end
	elseif nParId == nMainTaskId then --zhu xian
        if bCurrentTree then
            LogInsane("add scenrio task")
            if not self.m_pScenarioItem then
                local title = MHSD_UTILS.get_resstring(243)
                self.m_pScenarioItem = treeTask:addItem(CEGUI.String(title), nMainTaskId)
                SetGroupBtnTreeFirstIcon2(self.m_pScenarioItem);
                self:SetGroupBtnTreeItemStyle(self.m_pScenarioItem, true) 
            end
            return self.m_pScenarioItem;
        else
            if not self.m_pCanGetFenZhiItem then
                local title = MHSD_UTILS.get_resstring(244)
                self.m_pCanGetFenZhiItem = treeTask:addItem(CEGUI.String(title), nFenZhiId)
                SetGroupBtnTreeFirstIcon2(self.m_pCanGetFenZhiItem);
                self:SetGroupBtnTreeItemStyle(self.m_pCanGetFenZhiItem, true) 
            end
            return self.m_pCanGetFenZhiItem;
        end
	elseif nParId == nFenZhiId then
        if bCurrentTree then
            if not self.m_pFenZhiItem then
                local title = MHSD_UTILS.get_resstring(244)
                self.m_pFenZhiItem = treeTask:addItem(CEGUI.String(title), nFenZhiId)
                SetGroupBtnTreeFirstIcon2(self.m_pFenZhiItem);
                self:SetGroupBtnTreeItemStyle(self.m_pFenZhiItem, true) 
            end
            return self.m_pFenZhiItem;
        else
            if not self.m_pCanGetFenZhiItem then
                local title = MHSD_UTILS.get_resstring(244);
                self.m_pCanGetFenZhiItem = treeTask:addItem(CEGUI.String(title), nFenZhiId)
                SetGroupBtnTreeFirstIcon2(self.m_pCanGetFenZhiItem)
                self:SetGroupBtnTreeItemStyle(self.m_pCanGetFenZhiItem, true) 
            end
            return self.m_pCanGetFenZhiItem;
        end
	elseif nParId == nJuBaoId then
        if bCurrentTree then
            if not self.m_pJuBaoItem then
                local title = MHSD_UTILS.get_resstring(11376);
                self.m_pJuBaoItem = treeTask:addItem(CEGUI.String(title), nJuBaoId)
                SetGroupBtnTreeFirstIcon2(self.m_pJuBaoItem);
                self:SetGroupBtnTreeItemStyle(self.m_pJuBaoItem, true) 
            end
            return self.m_pJuBaoItem;
        else
            if not self.m_pCanGetLeftItem then
                local title = MHSD_UTILS.get_resstring(242);
                self.m_pCanGetLeftItem = treeTask:addItem(CEGUI.String(title), nLeaveTaskId)
                SetGroupBtnTreeFirstIcon2(self.m_pCanGetLeftItem);
                self:SetGroupBtnTreeItemStyle(self.m_pCanGetLeftItem, true) 
            end
            return self.m_pCanGetLeftItem;
        end
	elseif nParId == nLeaveTaskId then
        if bCurrentTree then
            if not self.m_pLeftItem then
                local title = MHSD_UTILS.get_resstring(11444);
                self.m_pLeftItem = treeTask:addItem(CEGUI.String(title), nLeaveTaskId)
                SetGroupBtnTreeFirstIcon2(self.m_pLeftItem);
                self:SetGroupBtnTreeItemStyle(self.m_pLeftItem, true) 
            end
            return self.m_pLeftItem;
        else
            if not self.m_pCanGetLeftItem then
                local title = MHSD_UTILS.get_resstring(11444);
                self.m_pCanGetLeftItem = treeTask:addItem(CEGUI.String(title), nLeaveTaskId)
                SetGroupBtnTreeFirstIcon2(self.m_pCanGetLeftItem);
                self:SetGroupBtnTreeItemStyle(self.m_pCanGetLeftItem, true) 
            end
            return self.m_pCanGetLeftItem;
        end
    elseif nParId == nAnyeFollow then
         if self.m_pAnyeFollowItem then
            return self.m_pAnyeFollowItem;
        else
            return nil
        end
	else
		return nil
	end
end



function Renwudialog:RefreshData(index)
	self.m_nSelectID = index
	if index == 1 then
        self.tabHaveTask.m_bgRight:setVisible(true)
		self.tabCanGetTask.m_groupbtnLeft:setVisible(false)
		self.tabCanGetTask.m_bgRight:setVisible(false)
		self.m_btnGiveUp:setVisible(true)
        self.m_btnGotoGot:setVisible(false)
		self.m_btnNowGot:setVisible(true)
		self.m_btnRenxing:setVisible(false)
        self.tabHaveTask.m_groupbtnLeft:setVisible(true)
        self.m_meirenwu:setVisible(false)
        self.m_meirenwuText:setVisible(false)
	else
        self.tabHaveTask.m_bgRight:setVisible(false)
        self.m_btnGotoGot:setVisible(true)
		self.m_btnGiveUp:setVisible(false)		
        self.tabHaveTask.m_groupbtnLeft:setVisible(false)
		self.tabCanGetTask.m_bgRight:setVisible(true)
		self.tabCanGetTask.m_groupbtnLeft:setVisible(true)
		self.m_btnNowGot:setVisible(false)
		self.m_btnRenxing:setVisible(false)
        self.m_meirenwu:setVisible(false)
        self.m_meirenwuText:setVisible(false)
        local acceptablequests = GetTaskManager():GetAcceptableQuestListForLua()
        local acceptablequestnum = acceptablequests:size()
        if acceptablequestnum == 0 then
            self.m_btnGotoGot:setVisible(false)
		    self.tabCanGetTask.m_bgRight:setVisible(false)
		    self.tabCanGetTask.m_groupbtnLeft:setVisible(false)
            self.m_meirenwu:setVisible(true)
            self.m_meirenwuText:setVisible(true)
        end

	end	
end


-------------------------------------------------------------------------------------

function Renwudialog.RemoveAcceptableQuest(questid)
	LogInsane("Renwudialog.RemoveAcceptableQuest")
	if _instance == nil then
		return
	end
	if questid == nil then
		return
	end
	local item = _instance.tabCanGetTask.m_groupbtnLeft:findFirstItemWithID(questid)
	local pParentItem = _instance:GetParentItemByTaskID(questid, false)
	if pParentItem then
		_instance:RemoveCanGetTasktItem(pParentItem, item)
	end
end

function Renwudialog.OpenAcceptQuest(selectid)
	if _instance == nil then
		Renwudialog.getSingletonDialog()
	end
	local self = _instance
	local selectid = selectid or 0
	LogInsane("Renwudialog.OpenAcceptQuest"..selectid)
	self.m_pTabControl:setSelectedTabAtIndex(1)
	if selectid > 0 and self.m_iSelectedAcpTaskId ~= selectid then
		local pItem = self.tabCanGetTask.m_groupbtnLeft:findFirstItemWithID(selectid)
		if pItem then
			self.m_iSelectedAcpTaskId = selectid
			local pParentItem = self:GetParentItemByTaskID(self.m_iSelectedAcpTaskId,false)
			if pParentItem then
	            self.tabCanGetTask.m_groupbtnLeft:SetLastOpenItem(pParentItem)
	           	self.tabCanGetTask.m_groupbtnLeft:SetLastSelectItem(pItem);
	            self.tabCanGetTask.m_groupbtnLeft:invalidate()
				self:RefreshAcceptableQuestIntro(self.m_iSelectedAcpTaskId)
			end
		end
	end
	return 1
end

function Renwudialog.OnTaskTraceStateChangeNotify(questid)
	
end

--//updata task when task state change
function Renwudialog.RefreshLastTask(taskid)
	local self = _instance
	if self == nil then
		return
	end
		
	self:RefreshQuestItem(taskid)	
end

---------------------------------------------------------------------------------
function Renwudialog.UpdateAcceptList()
    if not _instance then
        return
    end
    _instance:UpdateAcceptableTaskList()

end

--//can accept task
function Renwudialog:UpdateAcceptableTaskList()
    LogInsane("Renwudialog:UpdateAcceptableTaskList")
    if self == nil then
        self = _instance
    end
    if self == nil then
        return
    end
    self.tabCanGetTask.m_groupbtnLeft:resetList()
    self.m_pCanGetFenZhiItem = nil
    self.m_pAcpActivityItem = nil
    self.m_pCanGetLeftItem = nil
    self.m_pCanGetRiChangItem = nil
    local acceptablequests = GetTaskManager():GetAcceptableQuestListForLua()
    local bFind = false
    for i = 0, acceptablequests:size() - 1 do
        if acceptablequests[i] == self.m_iSelectedAcpTaskId then
            bFind = true
            break
        end
    end
    if not bFind then
        self.m_iSelectedAcpTaskId = 0
    end

    self.m_btnNowGot:setVisible(false)
    for i = 0, acceptablequests:size() - 1 do
        local questid = acceptablequests[i]
        local pParentItem = self:GetParentItemByTaskID(questid,false)
        if pParentItem then
            local strTaskName = ""
            local nTaskTypeId = questid
            local acceptCfg = BeanConfigManager.getInstance():GetTableByName("mission.cacceptabletask"):getRecorder(nTaskTypeId)
            if not acceptCfg then
                return
            end
            strTaskName = acceptCfg.name
            local child = pParentItem:addItem(CEGUI.String(strTaskName), questid)
            SetGroupBtnTreeSecondIcon2(child)
            self:SetGroupBtnTreeItemStyle(child, false)  -- 设置子节点样式

            self.m_btnNowGot:setVisible(true)

            if self.m_iSelectedAcpTaskId == 0 then
                self.m_iSelectedAcpTaskId = questid
                self.tabCanGetTask.m_groupbtnLeft:SetLastOpenItem(pParentItem)
                self.tabCanGetTask.m_groupbtnLeft:invalidate()
                self:RefreshAcceptableQuestIntro(questid)
            end
        end
    end
end

--//confirm abandon task
function Renwudialog.HandleConfirmAbandonTask()
	
     local bSendCancelEvent = false
	gGetMessageManager():CloseConfirmBox(eConfirmAbandonTask,bSendCancelEvent)

	if _instance == nil then
		return
	end

    local TaskHelper = require("logic.task.taskhelper") 
    local nTaskTypeId  = TaskHelper.nAnyeTaskTypeId

    if _instance.m_nCurSelTaskId == TaskHelper.nAnyeTaskTypeId then
        local giveupAnye = require("protodef.fire.pb.circletask.anye.cabandonanye").Create()
        giveupAnye.questid = 1080000
        LuaProtocolManager.getInstance():send(giveupAnye)
        return
    end

	if _instance.m_nCurSelTaskId > 0 then
		LogInsane("send abandonquest protocol")
		require "protodef.fire.pb.circletask.cabandonquest"
        local abandonquest = CAbandonQuest.Create()
        local pAnyeFollow = Taskmanager.getAnyeFollowTask(_instance.m_nCurSelTaskId)
        --暗夜马戏团放弃处理
        if pAnyeFollow then
            abandonquest.questid = 1080000 --search task
        else
            abandonquest.questid = _instance.m_nCurSelTaskId
        end
        
        LuaProtocolManager.getInstance():send(abandonquest)
    end
    LogInsane("Close confirm message")
    --gGetMessageManager():CloseConfirmBox(eConfirmAbandonTask,false)
	
	
	--临时处理
	require "logic.task.taskhelper".SendIsHavePingDingAnBangTask()	
end
function Renwudialog:RefreshQuestItem(questid)
	LogInfo("Renwudialog:RefreshQuestItem(questid)")
	local pParentItem = self:GetParentItemByTaskID(questid, true)
	if pParentItem == nil then
		return
	end
	local item = self.tabHaveTask.m_groupbtnLeft:findFirstItemWithID(questid)
	local queststate = 0
	local name = ""
	local pSpecialquest
	local pActivequest
	local pScenarioQuest
	
	--queststate=0  init value
	--//=====================================
	pSpecialquest = GetTaskManager():GetSpecialQuest(questid)
	if pSpecialquest then
		queststate = pSpecialquest.queststate
		name = pSpecialquest.name
	end
	--//=====================================
	if queststate == 0 then
		pActivequest = GetTaskManager():GetReceiveQuest(questid)
		if pActivequest then
			
			local config = BeanConfigManager.getInstance():GetTableByName("circletask.cspecialquestconfig"):getRecorder(questid)
			if not config or config.id == -1 then
				return
			end
			queststate = pActivequest.queststate
			name = config.questname
		end
	end
	LogInsane("Refresh pActivequest Quest status="..queststate)
	--//=====================================
	if queststate == 0 then
		pScenarioQuest = GetTaskManager():GetScenarioQuest(questid)
		if pScenarioQuest then
			local questinfo = GameTable.mission.GetCMainMissionInfoTableInstance():getRecorder(questid)
			if not questinfo or questinfo.id == -1 then
				return
			end
			queststate = pScenarioQuest.missionstatus
			
			local firstpos = string.find(questinfo.MissionName, "%$", 0)
			if firstpos then
				name = string.sub(questinfo.MissionName, 0, firstpos - 1)
			else
				name = questinfo.MissionName
			end
		end
	end
	
	--//=====================================
	if queststate == 0 or queststate == spcQuestState.ABANDONED then
	    self:RemoveQuestItem(pParentItem, item)
        self:refreshDefaultSel()
        self.tabHaveTask.m_groupbtnLeft:getVertScrollbar():setScrollPosition(0)
		return
	end
	--//=====================================
	if item == nil then
        item = pParentItem:addItem(CEGUI.String(name), questid)
        SetGroupBtnTreeSecondIcon2(item)
        self:SetGroupBtnTreeItemStyle(item, false) -- 设置子节点样式
    else
        item:setText(CEGUI.String(name))
    end
	
	local m_pCurrentTree = self.tabHaveTask.m_groupbtnLeft
	m_pCurrentTree:SetLastOpenItem(pParentItem)
	m_pCurrentTree:SetLastSelectItem(item)
	self:RefreshItemNameAndColour(item, queststate)
	self.m_nCurSelTaskId = questid
	m_pCurrentTree:invalidate()
    self:RefreshQuestIntro(self.m_nCurSelTaskId)
end


function Renwudialog:refreshDefaultSel()
    if not self:DefaultSelectItem(self.m_pRiChangItem) then
			if not self:DefaultSelectItem(self.m_pHuoDongItem) then
				if not self:DefaultSelectItem(self.m_pJuBaoItem) then
					if not self:DefaultSelectItem(self.m_pLeftItem) then
						if not self:DefaultSelectItem(self.m_pScenarioItem) then
							self:DefaultSelectItem(self.m_pFenZhiItem)
						end
					end
				end
			end
	end
end

function Renwudialog:deleteCurTreeFirstItem()
	
	local pParentItem = self.tabHaveTask.m_groupbtnLeft
	if self.m_pRiChangItem and self.m_pRiChangItem:getItemCount() == 0 then
		pParentItem:removeItem(self.m_pRiChangItem)
		self.m_pRiChangItem = nil
	end
	if self.m_pHuoDongItem and self.m_pHuoDongItem:getItemCount() == 0 then
		pParentItem:removeItem(self.m_pHuoDongItem)
		self.m_pHuoDongItem = nil
	end
	if self.m_pLeftItem and self.m_pLeftItem:getItemCount() == 0 then
		pParentItem:removeItem(self.m_pLeftItem)
		self.m_pLeftItem = nil
	end
	if self.m_pScenarioItem and self.m_pScenarioItem:getItemCount() == 0 then
		pParentItem:removeItem(self.m_pScenarioItem)
		self.m_pScenarioItem = nil
	end
	if self.m_pFenZhiItem and self.m_pFenZhiItem:getItemCount() == 0 then
		LogInsane("Remove self.m_pFenZhiItem")
		pParentItem:removeItem(self.m_pFenZhiItem)
		self.m_pFenZhiItem = nil
	end
	if self.m_pJuBaoItem and self.m_pJuBaoItem:getItemCount() == 0 then
		pParentItem:removeItem(self.m_pJuBaoItem)
		self.m_pJuBaoItem = nil
	end
		
end

function Renwudialog:RefreshActiveQuestIntro(taskid, quest)
    LogInsane("Renwudialog:RefreshActiveQuestIntro")
    if quest == nil then return end

    local config = BeanConfigManager.getInstance():GetTableByName("circletask.cspecialquestconfig"):getRecorder(taskid)

    local sb = StringBuilder.new()
    local strTaskDes = ""
	local strTaskName = ""
	local strTaskMubiao = ""

    sb:SetNum("Number1", quest.sumnum-1)
    sb:SetNum("Number2", quest.sumnum)

    TaskHelper.SetSbFormat_Active_Menpai(quest,sb)

    self:ShowQuestIntro(config.questname, sb:GetString(config.aim), sb:GetString(config.discribe), 0, 0, 0, nil)
    sb:delete()
end

function Renwudialog:RefreshSpecialQuestIntro(taskid, quest)
	LogInsane("Renwudialog:RefreshSpecialQuestIntro")
 	if quest == nil then
 		LogInsane("the Special quest is nil")
 		return
 	end
	local pQuest = quest
	local nRound = pQuest.round
	local nTaskTypeId = taskid
	local nTaskDetailId = pQuest.questtype
	
	if quest.queststate == spcQuestState.FAIL then
		self:ShowFailQuestIntro(quest.questid)	
		return
	end
	local sb = StringBuilder.new()
	local strTaskDes = ""
	local strTaskName = ""
	local strTaskMubiao = ""
		
	local npcConfig = BeanConfigManager.getInstance():GetTableByName("npc.cnpcconfig"):getRecorder(quest.dstnpcid)
    if npcConfig then
	    sb:Set("NPCName",npcConfig.name)
    end
	sb:SetNum("npcid", quest.dstnpcid)
		
	local nMaxNum = TaskHelper.GetRepeatTaskMaxCount(nTaskDetailId)
	sb:SetNum("Number", nRound)
	sb:SetNum("Number1", nMaxNum)

	TaskHelper.SetSbFormat_repeatTaskAll(pQuest,sb)

	
	local repeatCfg = BeanConfigManager.getInstance():GetTableByName("circletask.crepeattask"):getRecorder(nTaskDetailId)
	if not repeatCfg or repeatCfg.id == -1 then
		return false
	end
	strTaskName = repeatCfg.strtaskname
	strTaskMubiao = repeatCfg.strtasktitle
	strTaskDes = repeatCfg.strtaskdes
	local items = std.vector_fire__pb__circletask__RewardItemUnit_()
	self:ShowQuestIntro(sb:GetString(strTaskName),sb:GetString(strTaskMubiao),sb:GetString(strTaskDes),0,0,0,items)
	sb:delete()
end





function Renwudialog:RefreshScenarioQuestIntro(taskid, quest)
	
	if quest == nil then
		return
	end
	local m_pCurrentTaskIntro = self.tabHaveTask.m_txtRightIntro
	local questinfo = GameTable.mission.GetCMainMissionInfoTableInstance():getRecorder(taskid)
	if questinfo.id == -1 then
		m_pCurrentTaskIntro:Clear()
		m_pCurrentTaskIntro:Refresh()
		return;
	end

	local items = std.vector_fire__pb__circletask__RewardItemUnit_()

	local sb = StringBuilder:new()
	sb:SetNum("number", quest.missionvalue)
	sb:Set("NAME",gGetDataManager():GetMainCharacterName())
	self:ShowQuestIntro(questinfo.MissionName,
		sb:GetString(questinfo.TaskInfoPurposeListA),
		sb:GetString(questinfo.TaskInfoDescriptionListA),
		questinfo.ExpReward,questinfo.MoneyReward,questinfo.SMoney,items);
	
    sb:delete()

end

--//accept task info 
function Renwudialog:ShowQuestIntro(strTaskName, strTaskMubiao, discribe, nexp, money, smoney, items)
	LogInsane("Renwudialog:ShowQuestIntro"..strTaskName)		

	self.tabHaveTask.m_txtRightTitle:setText(strTaskName)
	--self.tabHaveTask.m_txtRightIntro:setText(strTaskMubiao)
	self.tabHaveTask.m_txtRightIntro:Clear()
	self.tabHaveTask.m_txtRightIntro:AppendParseText(CEGUI.String(strTaskMubiao))
	self.tabHaveTask.m_txtRightIntro:Refresh()
	self.tabHaveTask.m_txtRightIntro:getVertScrollbar():setScrollPosition(0)
	--self.tabHaveTask.m_txtRightDetail:setText(discribe)
	self.tabHaveTask.m_txtRightDetail:Clear()
	self.tabHaveTask.m_txtRightDetail:AppendBreak()
	self.tabHaveTask.m_txtRightDetail:AppendParseText(CEGUI.String(discribe))
	self.tabHaveTask.m_txtRightDetail:Refresh()
	self.tabHaveTask.m_txtRightDetail:getVertScrollbar():setScrollPosition(0)
	
end

--//accept task info 
function Renwudialog:RefreshAcceptableQuestIntro(nTaskTypeId)
	local acceptCfg = BeanConfigManager.getInstance():GetTableByName("mission.cacceptabletask"):getRecorder(nTaskTypeId)
	if acceptCfg.id ==-1 then
		return
	end
		
	local strTaskName = acceptCfg.name
	local strTaskMubiao = acceptCfg.aim
	local strDescribe = acceptCfg.discribe
	
	self.tabCanGetTask.m_txtRightTitle:setText(strTaskName)	
	--self.tabCanGetTask.m_txtRightIntro:setText(strTaskMubiao)
	
	self.tabCanGetTask.m_txtRightIntro:Clear()
	self.tabCanGetTask.m_txtRightIntro:AppendBreak()
	self.tabCanGetTask.m_txtRightIntro:AppendParseText(CEGUI.String(strTaskMubiao))
	self.tabCanGetTask.m_txtRightIntro:Refresh()
	self.tabCanGetTask.m_txtRightIntro:getVertScrollbar():setScrollPosition(0)
	
	
	self.tabCanGetTask.m_txtRightDetail:Clear()
	self.tabCanGetTask.m_txtRightDetail:AppendBreak()
	
	--self.tabCanGetTask.m_txtRightDetail:setText(strDescribe)
	self.tabCanGetTask.m_txtRightDetail:AppendParseText(CEGUI.String(strDescribe))
	self.tabCanGetTask.m_txtRightDetail:Refresh()
	self.tabCanGetTask.m_txtRightDetail:getVertScrollbar():setScrollPosition(0)
end

function Renwudialog:ShowFailQuestIntro(taskid)
end

function Renwudialog:HandleSelectedCurrentTask(e)
	--LogInfo("Renwudialog:HandleSelectedCurrentTask")
	print('Renwudialog:HandleSelectedCurrentTask')
	local sitem = self.tabHaveTask.m_groupbtnLeft:getSelectedItem()
	if sitem == nil then
		return true
	end
	local taskid = sitem:getID()
	if self.m_nCurSelTaskId == taskid then
		return true
	end
	self.m_nCurSelTaskId = taskid;
	LogInfo("Renwudialog:HandleSelectedCurrentTask=taskid="..taskid)
	self:RefreshQuestIntro(self.m_nCurSelTaskId)

    local Taskmanager = require("logic.task.taskmanager").getInstance()
    Taskmanager.nLastSelTaskId = self.m_nCurSelTaskId
	LogInfo("Renwudialog:HandleSelectedCurrentTask=end")
end
function Renwudialog:update(nDt)
    self.nRefreshAnyeUICdDt =  self.nRefreshAnyeUICdDt + nDt
    if self.nRefreshAnyeUICdDt >= self.nRefreshAnyeUICd then
        self:updateAnyeUI()
        self.nRefreshAnyeUICdDt = 0
    end    
end

function Renwudialog:updateAnyeUI()
    local taskmanager = require("logic.task.taskmanager").getInstance()
    local pAnyeFollow = taskmanager.getAnyeFollowTask(self.m_nCurSelTaskId)
    if pAnyeFollow and self.m_nSelectID == 1 then
        local oneSearchData = taskmanager.vAnyeTask[taskmanager.m_nAnyeFollowIndex] 
        if not oneSearchData then
            return
        end
        if oneSearchData.legend == 2 then
              self:RefreshAnyeFollowIntro(self.m_nCurSelTaskId, oneSearchData)
        end 
    end
end
function Renwudialog:HandleSelectedAcpTask(e)
	local sitem = self.tabCanGetTask.m_groupbtnLeft:getSelectedItem();
	if sitem == nil then
		return true
	end

	local taskid = sitem:getID();
	if self.m_iSelectedAcpTaskId == taskid then
		return true
	end
	self.m_iSelectedAcpTaskId = taskid;
	self:RefreshAcceptableQuestIntro(taskid)
	return true;
end

function Renwudialog.HandleCancelAbandonTask()
     local bSendCancelEvent = false
	gGetMessageManager():CloseConfirmBox(eConfirmAbandonTask,bSendCancelEvent)
end

function Renwudialog:HandleAbandonTask(e)

	
	if self.m_nCurSelTaskId == 0 then
		return true
	end
	local pParentItem = self:GetParentItemByTaskID(self.m_nCurSelTaskId, true);
	if pParentItem == self.m_pScenarioItem
        or self.m_nCurSelTaskId == 904001 then

		GetCTipsManager():AddMessageTip(GameTable.message.GetCMessageTipTableInstance():getRecorder(141484).msg)
		return true;
	end
    local msg = 141086 
    if self.m_nCurSelTaskId == 701001 or self.m_nCurSelTaskId == 701002 then
        msg = 170038
    end
	local tip = GameTable.message.GetCMessageTipTableInstance():getRecorder(msg)
	if tip.id ~= -1 then
        gGetMessageManager():AddConfirmBox(eConfirmAbandonTask,
		tip.msg,
		Renwudialog.HandleConfirmAbandonTask,
	  	Renwudialog,
	  	Renwudialog.HandleCancelAbandonTask,
	  	Renwudialog)

	end
	return true;

end

function Renwudialog:HandleAcceptBtnClicked(e)
	
	--local  Taskhelpergoto = require "logic.task.taskhelpergoto"
	if self.m_iSelectedAcpTaskId == 0 then
		return true
	end
	
	require("logic.fuben.fubenmanager").getInstance():checkForSendExitFuben()
	
	local nTaskTypeId = self.m_iSelectedAcpTaskId
	
	TaskHelper.ClickAcceptTask(nTaskTypeId)

	Renwudialog.DestroyDialog()
    return true;
	
end



	
return Renwudialog
