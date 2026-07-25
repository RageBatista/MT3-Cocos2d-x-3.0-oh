require "logic.dialog"
ReadTimeProgressDlg = {}
setmetatable(ReadTimeProgressDlg, Dialog)
ReadTimeProgressDlg.__index = ReadTimeProgressDlg

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function ReadTimeProgressDlg.getInstance()
    if not _instance then
        _instance = ReadTimeProgressDlg:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function ReadTimeProgressDlg.getInstanceAndShow()
    if not _instance then
        _instance = ReadTimeProgressDlg:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end
    
    return _instance
end

function ReadTimeProgressDlg.getInstanceNotCreate()
    return _instance
end
function ReadTimeProgressDlg:OnClose()
    if self.m_iTimeReadBarType == 2 then --使用任务道具fire.pb.mission.ReadTimeType.USE_TASK_ITEM
		MainPackDlg_EndUseTaskItem()
	end
	Dialog.OnClose(self)
end
function ReadTimeProgressDlg.DestroyDialog()
	if _instance then
        if GetMainCharacter() and _instance.m_bMoveClose and _instance.HMainCharacterMoveEvent ~= nil then
			GetMainCharacter().EventMainCharacterMove:RemoveScriptFunctor(_instance.HMainCharacterMoveEvent)
            _instance.HMainCharacterMoveEvent = nil
	    end
	    if GetBattleManager() and _instance.HBattleEvent ~= nil then
            GetBattleManager().EventBeginBattle:RemoveScriptFunctor(_instance.HBattleEvent)
            _instance.HBattleEvent = nil
	    end
	    if gGetScene() and _instance.HMapChangeEvent ~= nil then
            gGetScene().EventMapChange:RemoveScriptFunctor(_instance.HMapChangeEvent)
            _instance.HMapChangeEvent = nil
	    end

		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function ReadTimeProgressDlg.ToggleOpenClose()
	if not _instance then 
		_instance = ReadTimeProgressDlg:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end
function ReadTimeProgressDlg.GetLayoutFileName()
    return "readtimeprogressbardlg.layout"
end
function ReadTimeProgressDlg:OnCreate()

	self.dtype = ""
    ---------------
    Dialog.OnCreate(self)
    	
    self.m_bIsReadingTime = false
    self.m_fElapsedReadTime = 0
    self.m_fTotalReadTime = 5.0
    self.m_iTimeReadBarType = 0
    self.m_iConnectID = 0
    self.m_bIsFading = false
    self.m_fTotalFadeTime = 1.0
    self.m_bMoveClose = true

	self.HMainCharacterMoveEvent = GetMainCharacter().EventMainCharacterMove:InsertScriptFunctor(ReadTimeProgressDlg.BreakImpl)
	self.HBattleEvent = GetBattleManager().EventBeginBattle:InsertScriptFunctor(ReadTimeProgressDlg.BreakImpl)
	self.HMapChangeEvent = gGetScene().EventMapChange:InsertScriptFunctor(ReadTimeProgressDlg.BreakImpl)
    
    local winMgr = CEGUI.WindowManager:getSingleton()

	self.m_pBar = CEGUI.Window.toProgressBar(winMgr:getWindow("ReadTimeProgressDlg/ReadTimeBar"))
	if self.m_pBar ~= nil  then
		self.m_pBar:subscribeEvent("WindowUpdate",ReadTimeProgressDlg.HandleWindowUpdata,self)
		self.m_pBar:setProgress(0.0)
		self.m_pBar:setBarType(1)
	end

	self.m_pHead = winMgr:getWindow("ReadTimeProgressDlg/Back/Head")
	self.m_pBarText = winMgr:getWindow("ReadTimeProgressDlg/ReadTimeBar/Text")

	local Shape = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(gGetDataManager():GetMainCharacterShape())
	local iconpath = gGetIconManager():GetImagePathByID(Shape.headID):c_str()
	self.m_pHead:setProperty("Image", iconpath)

	self:GetWindow():setAlwaysOnTop(true)

	--self.m_ProgessBarLight = Nuclear.GetEngine():GetRenderer():LoadPicture("/image/loading/ProgressBarLights.tga")
	
	--local lxPos = CEGUI.CoordConverter.windowToScreenX(self.m_pBar,0)
	--local lyPos = CEGUI.CoordConverter.windowToScreenY(self.m_pBar,0)
	local lxPos = self.m_pBar:getXPosition().offset
	local lyPos = self.m_pBar:getYPosition().offset
	local rxPos = lxPos + self.m_pBar:getPixelSize().width
	local ryPos = lyPos + self.m_pBar:getPixelSize().height

	self.m_ProgessCoverRT = Nuclear.NuclearFRectt(lxPos,lyPos,rxPos,ryPos)

    self.m_rewardid = 0

    self.m_maptype = 0

end
function ReadTimeProgressDlg.setTreasureData(treasuretype, rewardid)
    local dlg = ReadTimeProgressDlg.getInstanceNotCreate()
    if dlg then
        if treasuretype == 0 then
            dlg.m_maptype = 331300
        end
    dlg.m_rewardid = rewardid
    end
    
end

---------------- private: -----------------------------------
function ReadTimeProgressDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, ReadTimeProgressDlg)
    return self
end

function ReadTimeProgressDlg:HandleWindowUpdata(e)  
    local UpdataArgs = CEGUI.toUpdateEventArgs(e)
	local elapsedTime=UpdataArgs.d_timeSinceLastFrame
	if self.m_bIsReadingTime then
		self.m_fElapsedReadTime = self.m_fElapsedReadTime + elapsedTime
		
		if self.m_pBar ~= nil then
			self:GetWindow():setAlpha(1.0)
			local fProgress=self.m_fElapsedReadTime/self.m_fTotalReadTime
			self.m_pBar:setProgress(fProgress)

			--读条采集，遇战斗类型，需要提前结束读条
			if self.m_iTimeReadBarType == 3 and self.m_iConnectID>0 then --fire.pb.mission.ReadTimeType.FOSSICK
				if fProgress > self.m_iConnectID * 0.2 then
					self:EndReadTime()
				end
			end
        end
        if self.m_fElapsedReadTime> self.m_fTotalReadTime then
			self:EndReadTime()
		end		
	else
		if self.m_bIsFading then
			self.m_fElapsedFadeTime = self.m_fElapsedFadeTime + elapsedTime
			if self.m_fElapsedFadeTime>self.m_fTotalFadeTime then
				self:EndFade()
			else
				local alpha=self.m_fElapsedFadeTime/self.m_fTotalFadeTime
				alpha=math.cos(alpha*3.1415926*0.5)
				self:GetWindow():setAlpha(alpha)
			end
		end
	end
	return true
end

function ReadTimeProgressDlg:StartReadTime()
	self.m_fElapsedFadeTime=0.0
	self.m_fElapsedReadTime=0.0
	self.m_bIsReadingTime=true
	self.m_bIsFading=false
end

function ReadTimeProgressDlg:EndReadTime()
	
    if self.callback then
        self.callback()
        self.callback = nil
    end
    ----------------
    self.m_fElapsedFadeTime=0.0
	self.m_fElapsedReadTime=0.0
	--self.m_bIsReadingTime=false

	if self.m_iTimeReadBarType == 7 then --fire.pb.mission.ReadTimeType.END_AREA_QUEST
        local commitquest = require "protodef.fire.pb.mission.ccommitmission":new()
		commitquest.missionid = self.m_pBar:getID()
		commitquest.npckey = self.m_iConnectID
		LuaProtocolManager.getInstance():send(commitquest)
    elseif self.m_iTimeReadBarType == 10 then --藏宝图
        local p = require("protodef.fire.pb.mission.cusetreasuremapend"):new()
	    LuaProtocolManager:send(p)
	    if self.m_maptype == 331300 then
            local roleItemManager = require("logic.item.roleitemmanager").getInstance()
		    local itemKey = roleItemManager:GetItemKeyByBaseID(self.m_maptype)
		    if itemKey ~= 0 then
			    if self.m_rewardid ~= 4 then -- 战斗
				    treasureChosedDlg.startTimer = true
			    else
				    GetMainCharacter():SetFlyToEnable(true)
			    end
		    end
	    end
	elseif self.m_iConnectID == 0 or self.m_iTimeReadBarType == 3 then
		local EndTreasuremap = fire.pb.mission.CTreasuremapEnd:new()
		EndTreasuremap.progresstype=self.m_iTimeReadBarType
		gGetNetConnection():send(EndTreasuremap)
	elseif self.m_iTimeReadBarType == 2 then --使用任务道具fire.pb.mission.ReadTimeType.USE_TASK_ITEM
		MainPackDlg_EndUseTaskItem()
         local nBagId = self.m_pBar:getID()
        local nItemKey = self.m_iConnectID

	    require "protodef.fire.pb.item.cappenditem"
	    local useItem = CAppendItem.Create()
        useItem.keyinpack = self.m_iConnectID
        useItem.idtype = fire.pb.item.IDType.ROLE
        useItem.id = GetMainCharacter():GetID()
	    LuaProtocolManager.getInstance():send(useItem)
		self.m_iConnectID = 0
		self.m_iTimeReadBarType = 0
        
       
        local roleItemManager = require("logic.item.roleitemmanager").getInstance()
        roleItemManager:showUseItemEffect(nBagId,nItemKey)
	elseif self.m_iTimeReadBarType == 4 then --unuse fire.pb.mission.ReadTimeType.OPEN_BOX
		--gGetNetConnection():send(fire.pb.npc.CNpcService(self.m_iConnectID,349)) --349为开宝箱服务
        local copenchest = require "protodef.fire.pb.npc.copenchest":new()
        copenchest.chestnpckey = self.m_iConnectID
        require "manager.luaprotocolmanager":send(copenchest)
	elseif self.m_iTimeReadBarType == 5 then  --scenario task fire.pb.mission.ReadTimeType.END_TALK_QUEST
		local commitquest = require "protodef.fire.pb.mission.ccommitmission":new()
		commitquest.missionid = self.m_pBar:getID()
		commitquest.npckey = self.m_iConnectID
		LuaProtocolManager.getInstance():send(commitquest)
	elseif self.m_iTimeReadBarType == 6 then  --scenario task fire.pb.mission.ReadTimeType.BEGIN_BATTLE_QUEST
    
        local beginbattle = require "protodef.fire.pb.mission.cactivemissionaibattle":new()
        beginbattle.missionid = self.m_pBar:getID()
        beginbattle.npckey = self.m_iConnectID
        require "manager.luaprotocolmanager":send(beginbattle)

	end
	
	self:StartFade()
end
function ReadTimeProgressDlg:StartFade()
	self.m_fElapsedFadeTime=0.0
	self.m_fElapsedReadTime=0.0
	self.m_bIsReadingTime=false
	self.m_bIsFading=true
end
function ReadTimeProgressDlg:EndFade()
	self.m_fElapsedFadeTime=0.0
	self.m_fElapsedReadTime=0.0
	self.m_bIsReadingTime=false
	self.m_bIsFading=false
    	
	if self.m_bIsReadingTime ~= true then
		--[[if self.m_ProgessBarLight ~= 0 then
			Nuclear.GetEngine():GetRenderer():FreePicture(self.m_ProgessBarLight)
			self.m_ProgessBarLight = 0
		end]]

		self:DestroyDialog()
	end
end
function ReadTimeProgressDlg:SetName(strName)
	if self.m_pBarText then
		self.m_pBarText:setText("[border='FF190400']" .. strName)
	end
end
function ReadTimeProgressDlg:Break(btype)
	if btype==self.m_iTimeReadBarType then
		self:BreakImpl()
	end
end
function ReadTimeProgressDlg.BreakImpl()
    if _instance == nil then
        return
    end
--	--如果宝箱打开被打断的话，关闭宝箱
--	if _instance.m_iTimeReadBarType == 4 then --fire.pb.mission.ReadTimeType.OPEN_BOX
--		local pNpc = gGetScene():FindNpcByID(_instance.m_iConnectID)
--		if pNpc then
--			--pNpc:SetDefaultAction(eActionBattleStand)
--		end
--        --_instance:EndFade()
--	end
	
	if _instance.m_bIsFading ~= true then
		_instance:SetName(MHSD_UTILS.get_resstring(2230))
		_instance:StartFade()
	end
    	
	if _instance.m_iTimeReadBarType == 2 then --使用任务道具fire.pb.mission.ReadTimeType.USE_TASK_ITEM
		MainPackDlg_EndUseTaskItem()
	end
	_instance.m_iTimeReadBarType = 0
end
function ReadTimeProgressDlg.Start(strName, nType, fTotalReadTime, iQuestNpcID, barid)
    local dlg = ReadTimeProgressDlg.getInstanceAndShow()
	if dlg.m_bIsReadingTime or	(dlg.m_bIsReadingTime==false and dlg.m_bIsFading == true) then
		return
    end
	if dlg.m_iTimeReadBarType == 2 then --使用任务道具fire.pb.mission.ReadTimeType.USE_TASK_ITEM
		MainPackDlg_EndUseTaskItem()
		dlg.m_iTimeReadBarType = 0
	end

	dlg.m_fTotalReadTime = fTotalReadTime/1000
    dlg:SetName(strName)
	dlg:StartReadTime()
	dlg.m_iTimeReadBarType=nType
	dlg.m_pBar:setID(barid)
	
	if dlg.m_iTimeReadBarType == 3 and iQuestNpcID  == 1 then --fire.pb.mission.ReadTimeType.FOSSICK
		dlg.m_iConnectID = math.random(1,5)
	else
		dlg.m_iConnectID = iQuestNpcID;
	end
	dlg:ChackForPlayScenarioTaskEffect()
end



function ReadTimeProgressDlg:ChackForPlayScenarioTaskEffect()
	if self.m_pBar == nil then
        return false
    end
	local nScenarioTaskId = self.m_pBar:getID()
	local questinfo = GameTable.mission.GetCMainMissionInfoTableInstance():getRecorder(nScenarioTaskId)
	if questinfo.id == -1 then
		return false
	end
	local nPlayEffectId = questinfo.ProcessBarTeXiao
	-- gGetGameUIManager()->GetMainRootWnd()
    gGetGameUIManager():AddUIEffect(self.m_pBar, MHSD_UTILS.get_effectpath(nPlayEffectId), false)
	return true
end
--设置走动时不打断
function ReadTimeProgressDlg.SetMoveNoClose()
    if _instance == nil then
        return
    end
	if GetMainCharacter() then
        GetMainCharacter().EventMainCharacterMove:RemoveScriptFunctor(_instance.HMainCharacterMoveEvent)
        _instance.HMainCharacterMoveEvent = nil
		_instance.m_bMoveClose = false
	end
end
function ReadTimeProgressDlg:Draw()
	if gGetGameUIManager():IsGameUIVisible() ~= true then
		return
	end

	--[[if self.m_bIsReadingTime and self.m_pBar:getProgress() < 0.98 then
		local frt = self.m_ProgessCoverRT

		local barwidth = self.m_pBar:getProgress() * self.m_pBar:getPixelSize().d_width
		frt.left = frt.left + barwidth -4.0
		frt.right = frt.left + 8.0
		if barwidth > 187.0 then --超过187时，变短
			frt.bottom = frt.top + (self.m_pBar:getPixelSize().d_width - barwidth) * 19/21
		end
		
		Nuclear.GetEngine():GetRenderer():DrawPicture(self.m_ProgessBarLight,frt,Nuclear.NuclearColor(0xffffffff))
	end]]
end

function ReadTimeProgressDlg.CannotMove()
    if _instance == nil then
        return false
    end
    return _instance.m_iTimeReadBarType==5  --protodef.fire.pb.mission.ReadTimeType.END_TALK_QUEST
end

function ReadTimeProgressDlg.setType( type )
    _instance.m_iConnectID = type
end

return ReadTimeProgressDlg
