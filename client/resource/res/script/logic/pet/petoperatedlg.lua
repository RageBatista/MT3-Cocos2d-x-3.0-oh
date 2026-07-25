require "logic.dialog"
require "logic.battle.battleskilltip"
require "logic.battle.battleskillpanel"

PetOperateDlg = {}
setmetatable(PetOperateDlg, Dialog)
PetOperateDlg.__index = PetOperateDlg

------------------------public:----------------------------
----------------singleton //////////////////////////-------
local _instance 
function PetOperateDlg.getInstance()
	LogInfo("enter get PetOperateDlg instance")

	if not _instance then
		_instance = PetOperateDlg.new()
		_instance:OnCreate()
	end

	return _instance
end

function PetOperateDlg.DestroyDialog()
	if _instance then
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function PetOperateDlg.GetSingletonDialogAndShowIt()
	
	if not _instance then
        _instance = PetOperateDlg.new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end
    return _instance
end

function PetOperateDlg.getInstanceNotCreate()
    return _instance
end

------------------------//////////////////////////----------------------

function PetOperateDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, PetOperateDlg)
	self.m_bEscClose = false;
	self.m_eDialogType = {};
	return self
end

function PetOperateDlg.GetLayoutFileName()
	return "PetOperateDlg.layout"
end

function PetOperateDlg:OnCreate()
	Dialog.OnCreate(self)

	local winMgr = CEGUI.WindowManager:getSingleton()
	
	self:GetWindow():setMousePassThroughEnabled(true)
	self:GetWindow():SetHandleDragMove(true)
	
	self.m_pSkillBtn = CEGUI.Window.toPushButton(winMgr:getWindow("PetOperateDlg/back/skill"))
	self.m_pPackBtn = CEGUI.Window.toPushButton(winMgr:getWindow("PetOperateDlg/back/skill1"))
	self.m_pDefenceBtn = CEGUI.Window.toPushButton(winMgr:getWindow("PetOperateDlg/back/skill2"))
	self.m_pProtectdBtn = CEGUI.Window.toPushButton(winMgr:getWindow("PetOperateDlg/back/skill3"))
	self.m_pEscapeBtn = CEGUI.Window.toPushButton(winMgr:getWindow("PetOperateDlg/back/skill7"))    
	self.m_pCancelBtn = CEGUI.Window.toPushButton(winMgr:getWindow("PetOperateDlg/back/cancel"))
	self.m_pAttackBtn = CEGUI.Window.toPushButton(winMgr:getWindow("PetOperateDlg/back/skill5"))
	
	self.m_pAutoBtn = CEGUI.Window.toPushButton(winMgr:getWindow("PetOperateDlg/back/auto"))
	
	self.m_pQuickBtn = tolua.cast(winMgr:getWindow("PetOperateDlg/back/skillbox"),"CEGUI::SkillBox")
	
	self.m_DownSkill = nil
	self.m_TipTime = 0
	self.m_TipShow = false	
	
	self.m_pSkillBtn:subscribeEvent("Clicked", PetOperateDlg.HandleSkillBtnClicked, self)
	self.m_pPackBtn:subscribeEvent("Clicked", PetOperateDlg.HandlePackBtnClicked, self)
	self.m_pDefenceBtn:subscribeEvent("Clicked", PetOperateDlg.HandleDefenceBtnClicked, self)
	self.m_pProtectdBtn:subscribeEvent("Clicked", PetOperateDlg.HandleProtectBtnClicked, self)
	self.m_pEscapeBtn:subscribeEvent("Clicked", PetOperateDlg.HandleEscapeBtnClicked, self)
	self.m_pCancelBtn:subscribeEvent("Clicked", PetOperateDlg.HandleCancelBtnClicked, self)
	self.m_pAttackBtn:subscribeEvent("MouseClick", PetOperateDlg.HandleAttackBtnClicked, self)
	
	self.m_pAutoBtn:subscribeEvent("Clicked", PetOperateDlg.HandleAutoBtnClicked, self)
	
	self.m_pQuickBtn:subscribeEvent("MouseClick", PetOperateDlg.HandleQuickBtnClicked, self)
	self.m_pQuickBtn:subscribeEvent("SKillBoxClick", PetOperateDlg.HandleQuickBtnDown, self)
	self.m_pQuickBtn:subscribeEvent("MouseButtonUp", PetOperateDlg.HandleQuickBtnUp, self)
	
	
	if gGetDataManager():GetMainCharacterLevel() < 20 then
		self:GetWindow():subscribeEvent("Hidden", PetOperateDlg.HandleHide, self)
	end
	
	self:ShowCancel(false)
	self.m_OperateType = 0  --eNone
	--self.m_pPackBtn:setEnabled(false)
	--self.m_pProtectdBtn:setEnabled(false)
	
	self.m_bConfirmEscape = false

end

function PetOperateDlg:OnClose()
	BattleTiShi.DestroyDialog()
	BattleTiShi.CSetSkillID(0, 0)
	if gGetMessageManager() then
		gGetMessageManager():CloseConfirmBox(eConfirmBattleEscape, false)
	end
	Dialog.OnClose(self)
end

function PetOperateDlg:ShowCancel(bShow)
	self.m_pSkillBtn:setVisible(not bShow)
	self.m_pPackBtn:setVisible(not bShow)
	self.m_pDefenceBtn:setVisible(not bShow)
	self.m_pProtectdBtn:setVisible(not bShow)
	self.m_pEscapeBtn:setVisible(not bShow)
	self.m_pAttackBtn:setVisible(not bShow)
	self.m_pCancelBtn:setVisible(bShow)
	self.m_pAutoBtn:setVisible(not bShow)
	if bShow == false then
		BattleTiShi.getInstance().CSetSkillID(0, 1)
		if GetBattleManager():GetAutoCommandOperateType(1) == eOperate_Skill then
			SkillBoxControl.SetSkillInfo(self.m_pQuickBtn,GetBattleManager():GetAutoCommandOperateID(1),0,0)
			self.m_pQuickBtn:setVisible(true)
		else
			self.m_pQuickBtn:setVisible(false)
		end
	else
		self.m_pQuickBtn:setVisible(false)
	end
end

function PetOperateDlg:HandleAttackBtnClicked(args)
	self.m_OperateType = 6  --eAttack
	gGetGameOperateState():ChangeGameCursorType(eGameCursorType_BattleAttack);
	self:ShowCancel(true)
	BattleTiShi.getInstance().CSetText(MHSD_UTILS.get_resstring(11183))
	return true
end

function PetOperateDlg:HandleCancelBtnClicked(args)	
	if self.m_OperateType == 1 then  --eSkill
		BattleSkillPanel.ToggleOpenClose()
	end
    self:ShowCancel(false)
    return true
end

function PetOperateDlg:HandleAutoBtnClicked(args)
	GetBattleManager():BeginAutoOperate()
    return true
end

function PetOperateDlg:HandleSkillBtnClicked(args)
	BattleSkillPanel.showAndRefreshSkills(0)
	return true
end

function PetOperateDlg:HandlePackBtnClicked(args)
--	未使用代码
	self.m_OperateType = 2  --eItem

	local BB = require "logic.battle.battlebag"
	BB.CInitBag(1)
	self:SetVisible(false)

	return true
end

function PetOperateDlg:HandleDefenceBtnClicked(args)
	GetBattleManager():SendBattleCommand(0, eOperate_Defence)
	return true
end

function PetOperateDlg:HandleProtectBtnClicked(args)
--	未使用代码	
	self.m_OperateType = 4  --eProtect
    
	gGetGameOperateState():ChangeGameCursorType(eGameCursorType_BattleProtect)
--	gGetGameOperateState():SetOperateState(eCursorState_Protect)
	
	self:ShowCancel(true)

	BattleTiShi.getInstance().CSetText(MHSD_UTILS.get_resstring(11184))
	
	return true
end

function PetOperateDlg:HandleEscapeBtnClicked(args)
	if GetBattleManager():GetRunawayConfirmCount(1) == 0 then
		if self.m_bConfirmEscape == false then
			self.m_bConfirmEscape = true
			self.m_pEscapeBtn:setEnabled(false)
			gGetMessageManager():CloseConfirmBox(eConfirmBattleEscape,false)
			gGetMessageManager():AddConfirmBox(eConfirmBattleEscape,MHSD_UTILS.get_resstring(1435),PetOperateDlg.HandleFreeConfirmEscapeClicked,self,PetOperateDlg.HandleFreeConfirmEscapeCancelClicked,self)
		end
	else
		self.m_OperateType = 5  --eEscape
		GetBattleManager():SendBattleCommand(0, eOperate_Runaway)
	end
	
	return true
end

function PetOperateDlg:HandleFreeConfirmEscapeClicked(args)
	self.m_bConfirmEscape = false
	self.m_pEscapeBtn:setEnabled(true)
	GetBattleManager():SetRunawayConfirmCount(1, 1)
	
	self.m_OperateType = 5  --eEscape
	GetBattleManager():SendBattleCommand(0, eOperate_Runaway)
	
	gGetMessageManager():CloseConfirmBox(eConfirmBattleEscape,false)
	return true
end

function PetOperateDlg:HandleFreeConfirmEscapeCancelClicked(args)
	self.m_bConfirmEscape = false
	self.m_pEscapeBtn:setEnabled(true)
	return MessageManager.HandleDefaultCancelEvent(MessageManager,args)
end

function PetOperateDlg:HandleQuickBtnClicked(args)
	local e = CEGUI.toWindowEventArgs(args)
	if self.m_TipShow == true then
		--self:HideSkillTip()
	else
		local SkillID = self.m_pQuickBtn:GetSkillID()
		GetBattleManager():SetCurSelectedSkillID(SkillID)
		self:ShowCancel(true)
		gGetGameOperateState():ChangeGameCursorType(eGameCursorType_BattleSkill)
		BattleTiShi.CSetSkillID(SkillID, 1)
	end
end
function PetOperateDlg:HandleQuickBtnDown(args)
	self:HideSkillTip()
	local e = CEGUI.toWindowEventArgs(args)
	self.m_DownSkill = e.window
end
function PetOperateDlg:HandleQuickBtnUp(args)
	local e = CEGUI.toWindowEventArgs(args)
end

function PetOperateDlg:run(delta)
	if _instance:IsVisible() ~= false then
		local pTargetWnd = CheckTipsWnd.GetCursorWindow()
		if pTargetWnd ~= nil then
			if self.m_TipShow == false then
				if self.m_DownSkill ~= nil then
					if self.m_DownSkill == pTargetWnd or pTargetWnd:isAncestor(self.m_DownSkill) then
						self.m_TipTime = self.m_TipTime + delta
						if self.m_TipTime >= 500 then
							--local SkillIndex = self:GetSelSkillIndex(self.m_DownSkill)
							--if SkillIndex > 0 then
                                BattleSkillTip.getInstance():SetSkill(self.m_DownSkill:GetSkillID())
								self.m_TipShow = true
							--end
						end
					else
						if pTargetWnd == nil then
							self.m_DownSkill = nil
						end
					end
				end
			end
		else
			self.m_DownSkill = nil
		end
	end
end

function PetOperateDlg:HideSkillTip()
	self.m_DownSkill = nil
	self.m_TipTime = 0
	self.m_TipShow = false
	BattleSkillTip.DestroyDialog()
end

function PetOperateDlg:HandleHide(args)
	return true
end

function PetOperateDlg.CSetVisible(b)
	if _instance then
		_instance:SetVisible(b)
	end
end

function PetOperateDlg.CShowAuto(b)
	if _instance then
		_instance.m_pAutoBtn:setVisible(b)
	end	
end

return PetOperateDlg 
