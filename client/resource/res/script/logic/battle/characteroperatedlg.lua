require "logic.dialog"
require "logic.pet.battlepetsummondlg"

CharacterOperateDlg = {}
setmetatable(CharacterOperateDlg, Dialog)
CharacterOperateDlg.__index = CharacterOperateDlg

local _instance

function CharacterOperateDlg.getInstance()
	if not _instance then
		_instance = CharacterOperateDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function CharacterOperateDlg.getInstanceAndShow()
	if not _instance then
		_instance = CharacterOperateDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function CharacterOperateDlg.getInstanceNotCreate()
	return _instance
end

function CharacterOperateDlg.DestroyDialog()
    BattleSkillTip.DestroyDialog()
	if _instance then
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function CharacterOperateDlg.ToggleOpenClose()
	if not _instance then
		_instance = CharacterOperateDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function CharacterOperateDlg.GetLayoutFileName()
	return "CharacterOperateDlg1.layout"
end

function CharacterOperateDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, CharacterOperateDlg)
	return self
end

function CharacterOperateDlg:OnCreate()
	Dialog.OnCreate(self)
    
	self.m_bEscClose = false
	self.m_bConfirmEscape = false

	local winMgr = CEGUI.WindowManager:getSingleton()

	self:GetWindow():SetHandleDragMove(true)
    
	self.m_pCancelBtn = CEGUI.toPushButton(winMgr:getWindow("CharacterOperateDlg/back/cancel"))

	self.m_pSkillBtn = CEGUI.toPushButton(winMgr:getWindow("CharacterOperateDlg/back/skill"))
	self.m_pPackBtn      = CEGUI.toPushButton(winMgr:getWindow("CharacterOperateDlg/back/skill1"))
	self.m_pDefenceBtn = CEGUI.toPushButton(winMgr:getWindow("CharacterOperateDlg/back/skill2"))
	
	self.m_pBeckonBtn = CEGUI.toPushButton(winMgr:getWindow("CharacterOperateDlg/back/skill4"))
	self.m_pAttackBtn = CEGUI.toPushButton(winMgr:getWindow("CharacterOperateDlg/back/skill5"))
	self.m_pProtectdBtn  = CEGUI.toPushButton(winMgr:getWindow("CharacterOperateDlg/back/skill6"))
	self.m_pEscapeBtn = CEGUI.toPushButton(winMgr:getWindow("CharacterOperateDlg/back/skill7"))
	self.m_pWaZaBtn = CEGUI.toPushButton(winMgr:getWindow("CharacterOperateDlg/back/skill8"))
	self.m_pCatchBtn = CEGUI.toPushButton(winMgr:getWindow("CharacterOperateDlg/back/skill9"))

	self.m_pQuickBtn = CEGUI.toSkillBox(winMgr:getWindow("CharacterOperateDlg/back/skillbox"))
	
	self.m_pCancelBtn:subscribeEvent("MouseClick", CharacterOperateDlg.HandleCancelBtnClicked, self)

	self.m_pSkillBtn:subscribeEvent("MouseClick", CharacterOperateDlg.HandleSkillBtnClicked, self)
	self.m_pPackBtn:subscribeEvent("Clicked", CharacterOperateDlg.HandlePackBtnClicked,self)
	self.m_pDefenceBtn:subscribeEvent("Clicked", CharacterOperateDlg.HandleDefenceBtnClicked, self)
	
	self.m_pBeckonBtn:subscribeEvent("Clicked", CharacterOperateDlg.HandleBeckonBtnClicked, self)
	self.m_pAttackBtn:subscribeEvent("MouseClick", CharacterOperateDlg.HandleAttackBtnClicked, self)
	self.m_pProtectdBtn:subscribeEvent("Clicked", CharacterOperateDlg.HandleProtectBtnClicked, self)
	self.m_pEscapeBtn:subscribeEvent("Clicked", CharacterOperateDlg.HandleEscapeBtnClicked, self)
	self.m_pWaZaBtn:subscribeEvent("Clicked", CharacterOperateDlg.HandleWaZaBtnClicked, self)
	self.m_pCatchBtn:subscribeEvent("Clicked", CharacterOperateDlg.HandleCatchBtnClicked, self)

	self.m_pQuickBtn:subscribeEvent("MouseClick", CharacterOperateDlg.HandleQuickBtnUp, self)
	self.m_pQuickBtn:subscribeEvent("SKillBoxClick", CharacterOperateDlg.HandleQuickBtnClicked, self)
	
	self.m_bauto = true
	self.m_iOp = opOther
	self:op(false)

end

function CharacterOperateDlg:OnClose()
	BattleTiShi.DestroyDialog()
	BattleTiShi.CSetSkillID(0, 0)
	if gGetMessageManager() then
		gGetMessageManager():CloseConfirmBox(eConfirmBattleEscape, false)
	end
	Dialog.OnClose(self)
end

function CharacterOperateDlg:HandleCancelBtnClicked(e)    
	if self.m_bauto then
		GetBattleManager():BeginAutoOperate()
		BattleAutoFightDlg.CSetDaoJiShi(0)
	else
		gGetGameOperateState():ChangeGameCursorType(eGameCursorType_BattleNormal)
	end

	if self.m_iOp == opSkill then
		BattleSkillPanel.DestroyDialog()
    elseif m_iOp == opItem then
		self:HandlePackBtnClicked(e)
	end
	self.m_iOp = opOther

	self:op(false)
	return true
end
function CharacterOperateDlg:HandleSkillBtnClicked(e)    
	BattleSkillPanel.showAndRefreshSkills(0)
	return true
end
function CharacterOperateDlg:HandlePackBtnClicked(e)    
	BattleBag.CInitBag(0)
	self:SetOperateDlgVisible(false)
	return true
end
function CharacterOperateDlg:HandleDefenceBtnClicked(e)
	GetBattleManager():SendBattleCommand(0, eOperate_Defence)
	return true
end	
function CharacterOperateDlg:HandleBeckonBtnClicked(e)    
	BattlePetSummonDlg.getInstanceAndShow()
	return true;
end
function CharacterOperateDlg:HandleAttackBtnClicked(e)    
	gGetGameOperateState():ChangeGameCursorType(eGameCursorType_BattleAttack)
	self:op(true)
	BattleTiShi.CSetText(MHSD_UTILS.get_resstring(11183))
	return true;
end
function CharacterOperateDlg:HandleProtectBtnClicked(e)
    gGetGameOperateState():ChangeGameCursorType(eGameCursorType_BattleProtect)
	self:op(true)
	BattleTiShi.CSetText(MHSD_UTILS.get_resstring(11184))
	return true;
end

function CharacterOperateDlg:HandleConfirmEscape(e)
	GetBattleManager():SetRunawayConfirmCount(0, 1)    
	GetBattleManager():SendBattleCommand(0, eOperate_Runaway)

	gGetMessageManager():CloseConfirmBox(eConfirmBattleEscape, false)
	self.m_bConfirmEscape = false
	self.m_pEscapeBtn:setEnabled(true)
	return true
end
function CharacterOperateDlg:HandleConfirmEscapeCancel(e)
	self.m_bConfirmEscape = false
	self.m_pEscapeBtn:setEnabled(true)
	return MessageManager:HandleDefaultCancelEvent(e)
end
function CharacterOperateDlg:HandleEscapeBtnClicked(e)
    local startID = GetNumberValueForStrKey("NEWER_BATTLE_ID_START")
	local endID = GetNumberValueForStrKey("NEWER_BATTLE_ID_END")

	if GetBattleManager():GetBattleID() >= startID and GetBattleManager():GetBattleID() <= endID then
        return true
    end

	if GetBattleManager():GetRunawayConfirmCount(0) == 0 then
		if self.m_bConfirmEscape == false then
			self.m_pEscapeBtn:setEnabled(false)
			gGetMessageManager():AddConfirmBox(eConfirmBattleEscape, 
                                                MHSD_UTILS.get_resstring(1435), 
                                                CharacterOperateDlg.HandleConfirmEscape, self,
                                                CharacterOperateDlg.HandleConfirmEscapeCancel, self)
			self.m_bConfirmEscape = true
		end
	else
		GetBattleManager():SendBattleCommand(0, eOperate_Runaway)
	end
	return true;
end
function CharacterOperateDlg:HandleWaZaBtnClicked(e)
    local RoleEquipSkill = require("logic.battle.battlemanager").getInstance():GetRoleEquipSkillIDArr()
    if table.getn(RoleEquipSkill) == 0 then
		GetChatManager():AddTipsMsg(150082)
		return true
	end
	BattleSkillPanel.showAndRefreshSkills(1)
	return true;
end
function CharacterOperateDlg:HandleCatchBtnClicked(e)
    if MainPetDataManager.getInstance():IsMyPetFull() then
		GetChatManager():AddTipsMsg(100041)
	else
		local bCanPick = false;
		for i = 1, 28 do
			local pBattler =  GetBattleManager():FindBattlerByID(i);
			if pBattler then
			    bCanPick = pBattler:CanPick(eGameCursorType_BattleCatch, GetBattleManager():GetCurSelectedSkillID(), GetBattleManager():GetCurSelectedItem())
			    if bCanPick then
				    break
                end
            end
		end
		if not bCanPick then
			GetChatManager():AddTipsMsg(160305)
			return true
		end

		gGetGameOperateState():ChangeGameCursorType(eGameCursorType_BattleCatch)
		self:op(true)
		BattleTiShi.CSetText(MHSD_UTILS.get_resstring(11185))
	end
	return true;
end
function CharacterOperateDlg:HandleQuickBtnUp(e)
    local MouseArgs = CEGUI.toMouseEventArgs(e)
	local pCell = CEGUI.toSkillBox(MouseArgs.window);

	if pCell == nil then
		return false
	end
	pCell:releaseInput();
	local SkillID = pCell:GetSkillID()
	if SkillID == 0 then
		return false
	end
	if self.m_TipShow == false then
		GetBattleManager():SetCurSelectedSkillID(SkillID)
		self:op(true)
		gGetGameOperateState():ChangeGameCursorType(eGameCursorType_BattleSkill)
		BattleTiShi.CSetSkillID(SkillID, 0)	
	end
	return true;
end
function CharacterOperateDlg:HandleQuickBtnClicked(e)
    self:HideSkillTip()
	local MouseArgs = CEGUI.toMouseEventArgs(e)
	local pCell = CEGUI.toSkillBox(MouseArgs.window);
	if pCell == nil then
		return false
	end
	pCell:captureInput()
	local skillid = pCell:GetSkillID()
	if skillid == 0 then
		return false
	end
	self.m_DownSkill = MouseArgs.window
	return true;
end

function CharacterOperateDlg:op(b)
	if b == false then
		if GetBattleManager():IsAutoOperate() then
			self.m_pCancelBtn:setProperty("NormalImage", "set:common image:common_biaoshi_cc")
			self.m_pCancelBtn:setProperty("PushedImage", "set:common image:common_biaoshi_cc")
		else
			self.m_pCancelBtn:setProperty("NormalImage", "set:fightui image:automatic")
			self.m_pCancelBtn:setProperty("PushedImage", "set:fightui image:automatic")
		end
		self.m_bauto = true
	else
		self.m_pCancelBtn:setProperty("NormalImage", "set:fightui image:return")
		self.m_pCancelBtn:setProperty("PushedImage", "set:fightui image:return")
		self.m_bauto = false
	end
	self.m_pSkillBtn:setVisible(not b)
	self.m_pPackBtn:setVisible(not b)
	self.m_pDefenceBtn:setVisible(not b)

	self.m_pBeckonBtn:setVisible(not b)
	self.m_pAttackBtn:setVisible(not b)
	self.m_pProtectdBtn:setVisible(not b)
	self.m_pEscapeBtn:setVisible(not b)
	self.m_pWaZaBtn:setVisible(not b)
	self.m_pCatchBtn:setVisible(not b)
	if b == false then
		self:ShowQuickBtn()
	else
		self.m_pQuickBtn:setVisible(false)
	end
end
 
function CharacterOperateDlg.InitOperateBtnEnbale()
    local dlg = CharacterOperateDlg.getInstanceAndShow()
    
	dlg.m_pEscapeBtn:setEnabled(not GetBattleManager():IsEscapeForbiddenBattle())
    local roleskill = require("logic.battle.battlemanager").getInstance():GetRoleEquipSkillIDArr()
    local ct = table.getn(roleskill)
	if ct == 0 then
		local pImage = "set:fightui image:stunt"
		dlg.m_pWaZaBtn:setProperty("NormalImage", pImage)
		dlg.m_pWaZaBtn:setProperty("PushedImage", pImage)
	else
		local pImage = "set:fightui image:stunt2"
		dlg.m_pWaZaBtn:setProperty("NormalImage", pImage)
		dlg.m_pWaZaBtn:setProperty("PushedImage", pImage)
	end
	
    local autodlg = require "logic.battleautofightdlg"
    if autodlg then
        autodlg.CSetAutoFight(false)
    end
end

function CharacterOperateDlg:run(delta)
	local pTargetWnd = CheckTipsWnd.GetCursorWindow()
	if pTargetWnd ~= nil then
		if self.m_TipShow == false then
			if self.m_DownSkill ~= nil then
				if self.m_DownSkill == pTargetWnd or pTargetWnd:isAncestor(self.m_DownSkill) then
					self.m_TipTime = self.m_TipTime + delta;
					if self.m_TipTime >= 500 then
						local pCell = self.m_DownSkill
						if pCell == nil then
							return
					    end
						local skillid = pCell:GetSkillID()
						if skillid == 0 then
							return
						end
						BattleSkillTip.showAndSetSkill(skillid, 0)
						self.m_TipShow = true
                    end
				else
					if pTargetWnd == nil then
						self.m_DownSkill = nil
					end
				end
			end
		end
	else
		self.m_DownSkill = nil;
	end
end

function CharacterOperateDlg:ShowQuickBtn()
    BattleTiShi.CSetSkillID(0, 0)
	if GetBattleManager():GetAutoCommandOperateType(0) == eOperate_Skill then
		local bShow = true;
		if GetBattleManager():IsInPVPBattle() then
			local skillconfig = BeanConfigManager.getInstance():GetTableByName("skill.cskillconfig"):getRecorder(GetBattleManager():GetAutoCommandOperateID(0))
			if skillconfig.isonlypve == 1 then
				bShow = false
            end
		end
		SkillBoxControl.SetSkillInfo(self.m_pQuickBtn, GetBattleManager():GetAutoCommandOperateID(0),0)
		if GetBattleManager():GetFirstShowQuickButton() == true and bShow then
			self.m_pQuickBtn:setVisible(true)
		else
			self.m_pQuickBtn:setVisible(false)
		end
	else
		self.m_pQuickBtn:setVisible(false)
	end
end

function CharacterOperateDlg:getCancelBtn()
    return self.m_pCancelBtn
end

function CharacterOperateDlg:HideSkillTip()
	self.m_DownSkill = nil
	self.m_TipTime = 0
	self.m_TipShow = false
	BattleSkillTip.DestroyDialog()
end

function CharacterOperateDlg:SetOperateDlgVisible(bVisible)
	self:SetVisible(bVisible)
end

return CharacterOperateDlg
