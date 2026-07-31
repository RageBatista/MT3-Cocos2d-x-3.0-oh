Renwucell = {}
Renwucell.__index = Renwucell

local EffectCountDown = 10
function Renwucell.new(questid)
	local self = {}
	setmetatable(self, Renwucell)

    self.nWeightOrder = 0

	self.id = questid
	local winMgr = CEGUI.WindowManager:getSingleton()
	local name_prefix = tostring(questid)
	self.pBtn = CEGUI.toPushButton(winMgr:loadWindowLayout("TaskTrackcell.layout", name_prefix))
	self.pBtn:EnableClickAni(false) 
	self.pTitle = winMgr:getWindow(name_prefix.."TaskTrackcell/name")
    self.pTitle:setMousePassThroughEnabled(true)
    self.pBattleIcon = winMgr:getWindow(name_prefix.."TaskTrackcell/mark")
    self.pBattleIcon:setMousePassThroughEnabled(true)
	self.pContent = CEGUI.toRichEditbox(winMgr:getWindow(name_prefix.."TaskTrackcell/main"))
    self.pContent:setMousePassThroughEnabled(true)
    self.pContent:setReadOnly(true)
    self.pBtn:subscribeEvent("MouseClick", Renwucell.HandleGoToClicked, self)
    self.iPos = 0;
    local missioninfo = GameTable.mission.GetCMainMissionInfoTableInstance():getRecorder(questid)
    if missioninfo.id ~= -1 and missioninfo.MissionType == 40 then
       self.pBattleIcon:setVisible(true)
    else
       self.pBattleIcon:setVisible(false)
    end

	NewRoleGuideManager.getInstance():GuideStartTask(questid, self.pBtn:getName(), self.pBtn:getName())
	local effectLevel = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(168).value)
	if gGetDataManager():GetMainCharacterLevel() <= effectLevel then
		NewRoleGuideManager.getInstance():AddParticalEffect(self.pBtn)
	end
	

    self.nWidthOld = self.pBtn:getPixelSize().width
    self.nHeightOld = self.pBtn:getPixelSize().height
	return self
end

function Renwucell:SetBattleIconVisible(bVisible)
	self.pBattleIcon:setVisible(bVisible)
end

function Renwucell:HandleGoToClicked(e)
    local questinfo = GameTable.mission.GetCMainMissionInfoTableInstance():getRecorder(self.id)
    if questinfo and questinfo.Tipsid ~= 0 and GetTeamManager():IsOnTeam() then
        GetCTipsManager():AddMessageTip(GameTable.message.GetCMessageTipTableInstance():getRecorder(questinfo.Tipsid).msg,false)
        return true;
    end
	gGetGameUIManager():setCurrentItemId(-1)
	self:OnGoToClicked()
	if gGetDataManager():GetMainCharacterLevel() <= 10 then
		self.bNeedCountDown = true
		self.fCountDown = 0
	end
	return true
end

function Renwucell:HandleGuideEnd(e)
	local wndE=CEGUI.toWindowEventArgs(e)
    if wndE.window then
        wndE.window:setClippedByParent(true)
        gGetGameUIManager():RemoveUIEffect(wndE.window)
    end
    return true;
end
    
	
function Renwucell:OnGoToClicked()
	if self.bFail then
		Renwudialog.getSingletonDialog().RefreshLastTask(self.id)
		return
	end
	local taskHelper = require "logic.task.taskhelper"
	taskHelper.OnClickCellGoto(self.id)
	
   
end

function Renwucell:ResetHeight()        
    local ContentSize = self.pContent:GetExtendSize()
    local TitleSize = self.pTitle:getPixelSize()    
    
	local aa = ContentSize.height
    ContentSize.height = ContentSize.height + 15

    local minWidth =  self.nWidthOld
    local minHeight = self.nHeightOld

    local pBtnWidth = minWidth   
	
    local pBtnHeight = ContentSize.height+ TitleSize.height + 15
    if pBtnHeight < minHeight then
    	pBtnHeight = minHeight
    end

    self.pBtn:setSize(CEGUI.UVector2(CEGUI.UDim(0, pBtnWidth), CEGUI.UDim(0, pBtnHeight)))
    self.pContent:setHeight(CEGUI.UDim(0,ContentSize.height));
end

function Renwucell:Run(elapsed)
	if not self.bNeedCountDown then
		return
	end
	
	self.fCountDown = self.fCountDown + (elapsed / 1000)	
	if self.fCountDown > EffectCountDown then
		self.bNeedCountDown = false
		if gGetDataManager():GetMainCharacterLevel() <= 10 then
        	self.pEffect = gGetGameUIManager():AddUIEffect(self.pBtn, MHSD_UTILS.get_effectpath(10230))
        	self.pBtn:SetGuideState(true)
        	self.pBtn:removeEvent("GuideEnd")
        	self.pBtn:subscribeEvent("GuideEnd", Renwucell.HandleGuideEnd, self)
        	self.pBtn:setClippedByParent(false)
		end
	end
end

return Renwucell
