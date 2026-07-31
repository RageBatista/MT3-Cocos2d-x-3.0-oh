

FubenGuideDialog = {}
setmetatable(FubenGuideDialog, Dialog)
FubenGuideDialog.__index = FubenGuideDialog 
ConfirmToEnterFubenType=0
------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function FubenGuideDialog.getInstance()
	LogInfo("enter FubenGuideDialog")
    if not _instance then
        _instance = FubenGuideDialog:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function FubenGuideDialog.getInstanceAndShow()
	LogInfo("enter instance show")
    if not _instance then
        _instance = FubenGuideDialog:new()
        _instance:OnCreate()
	else
		LogInfo("set visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function FubenGuideDialog.getInstanceNotCreate()
    return _instance
end

function FubenGuideDialog.DestroyDialog()
	if _instance then 
		Renwulistdialog.exitFuben()
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function FubenGuideDialog.ToggleOpenClose()
	if not _instance then 
		_instance = FubenGuideDialog:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end
----/////////////////////////////////////////------

function FubenGuideDialog.GetLayoutFileName()
    return "fubenguide.layout"
end

function FubenGuideDialog:OnCreate()
	LogInfo("enter FubenGuideDialog oncreate")
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
    self.m_ExitBtn=CEGUI.Window.toPushButton(winMgr:getWindow("fubenguide/btn") )
    self.m_ExitBtn:subscribeEvent("Clicked", FubenGuideDialog.HandleClickExitBtn, self)
    
    self.m_FubenName=winMgr:getWindow("fubenguide/name")
    self.m_FubenDecribe=CEGUI.Window.toRichEditbox(winMgr:getWindow("fubenguide/main"))
    
    self.m_GotoLinkBtn=CEGUI.Window.toPushButton(winMgr:getWindow("fubenguidecell") )
    self.m_GotoLinkBtn:subscribeEvent("Clicked", FubenGuideDialog.HandleGotoLinkBtn, self)
    
    self.m_BattleImage=winMgr:getWindow("fubenguide/mark")
    self.m_BattleImage:setVisible(false)
    LogInfo("m_BattleImage setvisible false")
    
    self.m_Time=winMgr:getWindow("fubenguide/image")
    self.m_Time:setVisible(false)
    
    self.TaskEndImage=winMgr:getWindow("fubenguide/finish")
    self.TaskEndImage:setVisible(false)
    
    self.m_NpcList={}
    self.m_BattleNpcNum=0
    self.m_TaskId=0
    
   
    
    Jingyingfubendlg.DestroyDialog()
    
    
	Renwulistdialog.enterFuben()
	LogInfo("exit FubenGuideDialog OnCreate")
end

------------------- private: -----------------------------------

function FubenGuideDialog:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, FubenGuideDialog)

    return self
end



function FubenGuideDialog:HandleClickExitBtn(args)
  LogInfo("FubenGuideDialog:HandleClickRestorBtn")
  
  require "logic.jingying.jingyingenddlg"
  Jingyingenddlg.sendOutJingying()

  FubenGuideDialog.DestroyDialog()
  return true
end

function FubenGuideDialog:RefreshTask(taskId,mapId,currentTimes,defaultTimes)
   LogInfo("FubenGuideDialog:RefreshTask")
   self.m_FubenDecribe:Clear()
   LogInfo("taskId:"..tostring(taskId))
   self.m_TaskId=taskId
   local record=BeanConfigManager.getInstance():GetTableByName("circletask.cspecialquestconfig"):getRecorder(taskId)
   LogInfo("recordId:"..tostring(record.id))
   if record and record.id~=-1 then
      LogInfo("tacename:"..record.tracname)
      self.m_FubenName:setText(record.tracname)
   end
  self.m_FubenDecribe:Refresh()
  LogInfo("End FubenGuideDialog:RefreshTask")
end

function FubenGuideDialog:ClearNpcList()
   
    self.m_NpcList=nil
end
function FubenGuideDialog:AddNpc(npcId,npcKey,posX,posY)
    LogInfo("FubenGuideDialog:AddNpc")
    LogInfo("FubenGuideDialog:AddNpc npcid:"..tostring(npcId))
    LogInfo("FubenGuideDialog:AddNpc npcKey:"..tostring(npcKey))
    LogInfo("FubenGuideDialog:AddNpc npcxPos:"..tostring(posX))
    LogInfo("FubenGuideDialog:AddNpc npcyPos:"..tostring(posY))
    if  self.m_NpcList==nil then
        self.m_NpcList={}
    end
    self.m_NpcList[npcKey]={}
    self.m_NpcList[npcKey].npcKey=npcKey
    self.m_NpcList[npcKey].npcId=npcId
    self.m_NpcList[npcKey].xPos=posX
    self.m_NpcList[npcKey].yPos=posY
    
    self.m_BattleNpcNum=self.m_BattleNpcNum+1
    
    
    
end

function FubenGuideDialog:RemoveNpc(npcKey)
   LogInfo("FubenGuideDialog:RemoveNpc")
   LogInfo("FubenGuideDialog:RemoveNpckey:"..tostring(npcKey))
   if  self.m_NpcList==nil then
        return
    end
   self.m_NpcList[npcKey]=nil
   self.m_BattleNpcNum=self.m_BattleNpcNum-1
   
   self:RefreshTask(self.m_TaskId,0,0,0)
   
   for k,v in pairs( self.m_NpcList) do
		
         local npcKey=v.npcKey
         LogInfo("RemoveNpc vector npckey:"..tostring(npcKey))
   end
end

function FubenGuideDialog.HandleConfirmEnterFuben(args)
  LogInfo("FubenGuideDialog:HandleConfirmEnterFuben")
  gGetMessageManager():CloseConfirmBox(eConfirmTeamLeaderEnterFuben,false)
  ConfirmToEnterFubenType=0
  return true
end

function FubenGuideDialog:HandleGotoLinkBtn(args)
   LogInfo("FubenGuideDialog:HandleGotoLinkBtn")
   self.m_FubenDecribe:OnFirstGotoLinkClick();
   return true
end

function FubenGuideDialog:NotifyFubenEnd()
   LogInfo("FubenGuideDialog:NotifyFubenEnd")
   self.m_FubenDecribe:Clear()
   local parseText=MHSD_UTILS.get_msgtipstring(142920)
   self.m_FubenDecribe:AppendParseText(CEGUI.String(parseText))
   self.m_FubenDecribe:Refresh()
   self.TaskEndImage:setVisible(true)
   return true
end


