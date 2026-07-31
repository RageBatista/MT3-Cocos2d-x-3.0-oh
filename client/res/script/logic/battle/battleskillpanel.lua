require "logic.dialog"
require "logic.battle.battleskilltip"

BattleSkillPanel = {}
setmetatable(BattleSkillPanel, Dialog)
BattleSkillPanel.__index = BattleSkillPanel

local _instance

function BattleSkillPanel.getInstance()
	if not _instance then
		_instance = BattleSkillPanel:new()
		_instance:OnCreate()
	end
	return _instance
end

function BattleSkillPanel.getInstanceAndShow()
	if not _instance then
		_instance = BattleSkillPanel:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function BattleSkillPanel.getInstanceNotCreate()
	return _instance
end

function BattleSkillPanel.DestroyDialog()
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

function BattleSkillPanel.ToggleOpenClose()
	if not _instance then
		_instance = BattleSkillPanel:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function BattleSkillPanel.GetLayoutFileName()
	return "skilllist.layout"
end

function BattleSkillPanel:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, BattleSkillPanel)
	return self
end

function BattleSkillPanel:OnCreate()
	Dialog.OnCreate(self)
    self.m_SkillType = 0
	self.m_mode = 0
    self:GetWindow():setMousePassThroughEnabled(true)
	self:GetWindow():setRiseOnClickEnabled(false)
    
	local winMgr = CEGUI.WindowManager:getSingleton()

	self.m_SkillBG = winMgr:getWindow("SkillList/back/biankuang");
	self.m_SkillBG:setRiseOnClickEnabled(false);
    
    self.m_pCancel = CEGUI.toPushButton(winMgr:getWindow("SkillList/back/cancel"))
    self.m_pCancel:subscribeEvent("Clicked", BattleSkillPanel.HandleCancelClicked,self)
    self.m_pCancel:setVisible(false)

	self.m_pHeiDi = winMgr:getWindow("SkillList/heidi");
	self.m_pHeiDi:setRiseOnClickEnabled(false);
	self.m_pHeiDi:subscribeEvent("MouseClick", BattleSkillPanel.HandleHeiDiClicked, self)
	self.m_pHeiDi:setVisible(true)
    
    self.m_SkillIco = {}
    self.m_SkillText = {}
    for i = 1, 9 do
		self.m_SkillIco[i] = CEGUI.toSkillBox(winMgr:getWindow("SkillList/back/skill" .. tostring(i)))
		self.m_SkillIco[i]:setRiseOnClickEnabled(false)
		self.m_SkillIco[i]:subscribeEvent("MouseClick", BattleSkillPanel.HandleTableMoudeUp, self.m_SkillIco[i])
		self.m_SkillIco[i]:subscribeEvent("MouseButtonDown", BattleSkillPanel.HandleTableClick, self.m_SkillIco[i])

		self.m_SkillText[i] = winMgr:getWindow("SkillList/back/text" .. tostring(i));
    end

	self.m_SkillZero = winMgr:getWindow("SkillList/back/biankuang/textpet")
end
 
function BattleSkillPanel:HandleHeiDiClicked(e)
	gGetGameOperateState():ChangeGameCursorType(eGameCursorType_BattleNormal)
	self.ToggleOpenClose()
	return true
end

function BattleSkillPanel:HandleCancelClicked(e)    
	BattleTiShi.CSetSkillID(0,0)
	if self.m_mode == 1 then
        self:ShowSkill(true)

		BattleSkillTip.DestroyDialog()
        self.m_mode = 0
		self.m_pCancel:setVisible(false)
    end
	return true;
end

function BattleSkillPanel:HandleTableMoudeUp(args)    
    local pCell = CEGUI.toSkillBox(CEGUI.toWindowEventArgs(args).window)    
	if pCell == nil then
		return false
	end    
    pCell:releaseInput()
	local SkillID = pCell:GetSkillID()
	if SkillID == 0 then
		return false
	end
    local panel = BattleSkillPanel.getInstance()
    if panel.m_TipShow ~= true then
		GetBattleManager():SetCurSelectedSkillID(SkillID)
        		
		if panel.m_SkillType == 0 then --技能
			gGetGameOperateState():ChangeGameCursorType(eGameCursorType_BattleSkill)
					
			if GetBattleManager():IsMainCharOperate() then
			    BattleTiShi.CSetSkillID(SkillID,0)
				GetBattleManager():SetAutoCommandOperateType(0, eOperate_Skill)
				GetBattleManager():SetAutoCommandOperateID(0, SkillID)
				BattleAutoFightDlg.CSendAutoOperateData( 0, eOperate_Skill, SkillID)
				GetBattleManager():SetFirstShowQuickButton(true)
			elseif GetBattleManager():IsMainPetOperate() then
			    BattleTiShi.CSetSkillID(SkillID,1)
				GetBattleManager():SetAutoCommandOperateType(1, eOperate_Skill);
				GetBattleManager():SetAutoCommandOperateID(1, SkillID);
				BattleAutoFightDlg.CSendAutoOperateData(1, eOperate_Skill, SkillID)
			end
		elseif panel.m_SkillType == 1 then --特技
			gGetGameOperateState():ChangeGameCursorType(eGameCursorType_BattleSkill) --竟然没有特技的鼠标类型,只好在按下的地方再次分辨了
		end
		panel.m_mode = 1;
		panel:ShowSkill(false)
    end
    return true
end

function BattleSkillPanel:HandleTableClick(args)
	BattleSkillPanel.getInstance():HideSkillTip()
    local pCell = CEGUI.toSkillBox(CEGUI.toWindowEventArgs(args).window)
	if pCell == nil then
		return false
	end
	pCell:captureInput()
	local skillid = pCell:GetSkillID()
	if skillid == 0 then
		return false
	end
	BattleSkillPanel.getInstance().m_DownSkill = pCell
	return true
end

function BattleSkillPanel:HideSkillTip()
	self.m_DownSkill = nil
	self.m_TipTime = 0
	self.m_TipShow = false
	BattleSkillTip.DestroyDialog()
end

function BattleSkillPanel:ShowSkill(bShow)
	for i = 1,9 do
		local bVisible = bShow
		if self.m_SkillIco[i]:GetSkillID() ~= 0 and bShow then
			bVisible = true
		else
			bVisible = false
		end
		self.m_SkillIco[i]:setVisible(bVisible)
		self.m_SkillText[i]:setVisible(bVisible)
	end
	self.m_SkillBG:setVisible(bShow);

	if GetBattleManager():IsMainCharOperate() then
		if CharacterOperateDlg.getInstanceNotCreate() then
			CharacterOperateDlg.getInstanceNotCreate():SetOperateDlgVisible(bShow)
			if bShow == true then
				CharacterOperateDlg.getInstanceNotCreate():ShowQuickBtn()
			end
		end
	elseif GetBattleManager():IsMainPetOperate() then
		PetOperateDlg.CSetVisible(bShow)
	end

    if bShow == true then
	    self.m_pCancel:setVisible(false)
	    self.m_pHeiDi:setVisible(true)
    else
	    self.m_pCancel:setVisible(true)
	    self.m_pHeiDi:setVisible(false)
    end
    return true;
end
function BattleSkillPanel:CheckCost(iPlayerOrPet, iCostType, iCostNum)
    if iCostType <= 0 or iCostNum <= 0 then
		return true
	end

	local CurCostValue = 0
	if iPlayerOrPet == 0 then
		local MCD = gGetDataManager():GetMainCharacterData()
		CurCostValue = MCD:GetValue(iCostType)
	elseif iPlayerOrPet == 1 then
		local pBattlePet = MainPetDataManager.getInstance():GetBattlePet()
		if pBattlePet then
			CurCostValue = pBattlePet:getAttribute(iCostType)
		end
    end

	if CurCostValue < iCostNum then
		return false
    end
	return true
end
function BattleSkillPanel:CheckFilterBuff(SkillID)
	local Battler = GetBattleManager():GetMainBattleChar()
	local skillconfig = BeanConfigManager.getInstance():GetTableByName("skill.cskillconfig"):getRecorder(SkillID)
	if skillconfig == nil then
		return true
	end
	local BuffCount = Battler:GetBattleBuffCount()
	for i = 1, BuffCount do
		local BuffInfo = sBattleBuff()
		Battler:GetBattleBuffInfoByIndex(i - 1, BuffInfo)
		if BuffInfo.buffid == skillconfig.isfilterbuff then
			return false
		end
	end
	return true
end
function BattleSkillPanel:RefreshSkills(SkillType)
	self.m_SkillZero:setVisible(true)
	for i = 1, 9 do
		self.m_SkillIco[i]:SetSkillID(0)
		self.m_SkillIco[i]:setVisible(false)
		self.m_SkillText[i]:setVisible(false)
	end
    if GetBattleManager():IsMainCharOperate() then	
		self.m_SkillType = SkillType
		if SkillType == 0 then
            local SkillIDArr = require("logic.battle.battlemanager").getInstance():GetRoleBattleSkillIDArr()
            local SkillCount = #SkillIDArr

            local sortskill = {}
            local sortskillcount = 0
            for i = 0,SkillCount-1 do                          
                local bshow = true
				if GetBattleManager():IsInPVPBattle() == true then
				    local skillconfig = BeanConfigManager.getInstance():GetTableByName("skill.cskillconfig"):getRecorder(SkillIDArr[i+1])
				    if skillconfig and skillconfig.isonlypve == 1 then
                        bshow = false
                    end
                end
                if bshow then
                    local skillsort = BeanConfigManager.getInstance():GetTableByName("skill.cschoolskillitem"):getRecorder(SkillIDArr[i+1])
				    local skillinfo = BeanConfigManager.getInstance():GetTableByName("skill.cskillitem"):getRecorder(SkillIDArr[i+1])
                    local sinfo = {}
                    sinfo.sortid = skillsort.skillsort;
                    sinfo.skillid = skillinfo.id;
                    table.insert(sortskill,sinfo)
                    sortskillcount = sortskillcount+1
                end
            end
		
			local index = 9
            local extSkillIDArr = require("logic.battle.battlemanager").getInstance():GetRoleExtSkillIDArr()
            local extSkillCount = #extSkillIDArr 
            for i = 0,extSkillCount-1 do                  
                local bshow = true
				if GetBattleManager():IsInPVPBattle() == true then
				    local skillconfig = BeanConfigManager.getInstance():GetTableByName("skill.cskillconfig"):getRecorder(extSkillIDArr[i+1])
				    if skillconfig and skillconfig.isonlypve == 1 then
                        bshow = false
                    end
                end
                if bshow then
                    local sinfo = {}
                    sinfo.sortid = index
                    sinfo.skillid = extSkillIDArr[i+1]
                    table.insert(sortskill,sinfo)
                    index = index + 1
                    sortskillcount = sortskillcount+1
                end
            end

            table.sort(sortskill,function(a,b) return a.sortid<b.sortid end)
			index = 1
			if sortskillcount > 0 then
				self.m_SkillZero:setVisible(false)
            end
			local iLevel = gGetDataManager():GetMainCharacterLevel()
            for k,v in pairs(sortskill) do
                SkillBoxControl.SetSkillInfo(self.m_SkillIco[index],v.skillid,0)
				local skillitemcfg = BeanConfigManager.getInstance():GetTableByName("skill.cschoolskillitem"):getRecorder(v.skillid)
                if skillitemcfg.id > 0 then
					self.m_SkillText[index]:setText(skillitemcfg.skillabbrname)
				else
					self.m_SkillText[index]:setText("")
                end
				self.m_SkillIco[index]:setVisible(true)
				self.m_SkillText[index]:setVisible(true)

                local schoolskillbase = BeanConfigManager.getInstance():GetTableByName("skill.cschoolskillitem"):getRecorder(v.skillid)
				local fParam1 = 0
				if schoolskillbase then
					fParam1 = schoolskillbase.paramA * iLevel + schoolskillbase.paramB
                end
				local skillinfo = BeanConfigManager.getInstance():GetTableByName("skill.cskillitem"):getRecorder(v.skillid)
				local rt0 = self:CheckFilterBuff(self.m_SkillIco[index]:GetSkillID())
				if rt0 == false then
			        local huoliColor = "FFFF0000"
			        local textColor = "tl:"..huoliColor.." tr:"..huoliColor.." bl:"..huoliColor.." br:"..huoliColor
					self.m_SkillText[index]:setProperty("TextColours", textColor)
					--self.m_SkillIco[index]:setEnabled(false)
				else
					--self.m_SkillIco[index]:setEnabled(true)
	                fParam1 = RoleSkillManager.getInstance():GetSkillRealCost(skillinfo.costTypeA,fParam1)
					local rt = self:CheckCost(0, skillinfo.costTypeA, fParam1)
					if rt == false then
						local huoliColor = "FFFF0000"
						local textColor = "tl:"..huoliColor.." tr:"..huoliColor.." bl:"..huoliColor.." br:"..huoliColor
						self.m_SkillText[index]:setProperty("TextColours", textColor)
					else
						local huoliColor = "fffff2df"
						local textColor = "tl:"..huoliColor.." tr:"..huoliColor.." bl:"..huoliColor.." br:"..huoliColor
						self.m_SkillText[index]:setProperty("TextColours", textColor)
					end
                end
                index = index + 1
            end
		elseif SkillType == 1 then
            local equipSkillIDArr = require("logic.battle.battlemanager").getInstance():GetRoleEquipSkillIDArr()
            local index = 1
            local scount = 0        

            for k,v in pairs(equipSkillIDArr) do  
                local equipSkill = BeanConfigManager.getInstance():GetTableByName("skill.cequipskill"):getRecorder(v)
                if equipSkill and equipSkill.id > 0 then                                
                    local bshow = true
				    if GetBattleManager():IsInPVPBattle() == true then
				        local skillconfig = BeanConfigManager.getInstance():GetTableByName("skill.cskillconfig"):getRecorder(v)
				        if skillconfig and skillconfig.isonlypve == 1 then
                            bshow = false
                        end
                    end
                    if bshow then
                        SkillBoxControl.SetSkillInfo(self.m_SkillIco[index],v,0)
					    self.m_SkillIco[index]:setVisible(true)
					    self.m_SkillText[index]:setVisible(true)
					    self.m_SkillText[index]:setText(equipSkill.name)
						local rt0 = self:CheckFilterBuff(self.m_SkillIco[index]:GetSkillID())
						if rt0 == false then
							local huoliColor = "FFFF0000"
							local textColor = "tl:"..huoliColor.." tr:"..huoliColor.." bl:"..huoliColor.." br:"..huoliColor
							self.m_SkillText[index]:setProperty("TextColours", textColor)
							--self.m_SkillIco[index]:setEnabled(false)
						else
							--self.m_SkillIco[index]:setEnabled(true)
	                        local rCost = RoleSkillManager.getInstance():GetSkillRealCost(equipSkill.costType,equipSkill.costnum)
							local rt = self:CheckCost(0, equipSkill.costType, rCost)
							if rt == false then
								local huoliColor = "FFFF0000"
								local textColor = "tl:"..huoliColor.." tr:"..huoliColor.." bl:"..huoliColor.." br:"..huoliColor
								self.m_SkillText[index]:setProperty("TextColours", textColor)
							else
								local huoliColor = "fffff2df"
								local textColor = "tl:"..huoliColor.." tr:"..huoliColor.." bl:"..huoliColor.." br:"..huoliColor
								self.m_SkillText[index]:setProperty("TextColours", textColor)
							end
						end
					    index = index + 1
                        scount = scount + 1
                    end
                end
            end
            if scount > 0 then
                self.m_SkillZero:setVisible(false)
            end
		end
	elseif GetBattleManager():IsMainPetOperate() then
        local SkillIDArr = require("logic.battle.battlemanager").getInstance():GetPetBattleSkillIDArr()
        local SkillCount = #SkillIDArr
        local index = 1
        for i = 0,SkillCount-1 do       
            local bshow = true
			if GetBattleManager():IsInPVPBattle() == true then
				local skillconfig = BeanConfigManager.getInstance():GetTableByName("skill.cskillconfig"):getRecorder(SkillIDArr[i+1])
				if skillconfig and skillconfig.isonlypve == 1 then
                    bshow = false
                end
            end
            if bshow then
			    local skillBase = BeanConfigManager.getInstance():GetTableByName("skill.cpetskillconfig"):getRecorder(SkillIDArr[i+1])
           
                self.m_SkillZero:setVisible(false);
			    SkillBoxControl.SetSkillInfo(self.m_SkillIco[index], skillBase.id,0)
			    self.m_SkillIco[index]:setVisible(true)
			    self.m_SkillText[index]:setVisible(true)
			    self.m_SkillText[index]:setText(skillBase.skillname)
				local rt0 = self:CheckFilterBuff(self.m_SkillIco[index]:GetSkillID())
				if rt0 == false then
					local huoliColor = "FFFF0000"
					local textColor = "tl:"..huoliColor.." tr:"..huoliColor.." bl:"..huoliColor.." br:"..huoliColor
					self.m_SkillText[index]:setProperty("TextColours", textColor)
					--self.m_SkillIco[index]:setEnabled(false)
				else
					--self.m_SkillIco[index]:setEnabled(true)
					local rt = self:CheckCost(1, skillBase.costType, skillBase.costnum)
					if rt == false then
						local huoliColor = "FFFF0000"
						local textColor = "tl:"..huoliColor.." tr:"..huoliColor.." bl:"..huoliColor.." br:"..huoliColor
						self.m_SkillText[index]:setProperty("TextColours", textColor)
					else
						local huoliColor = "fffff2df"
						local textColor = "tl:"..huoliColor.." tr:"..huoliColor.." bl:"..huoliColor.." br:"..huoliColor
						self.m_SkillText[index]:setProperty("TextColours", textColor)
					end
				end
			    index = index + 1
            end
        end
	end
end

function BattleSkillPanel:run(delta)
    local pTargetWnd = CheckTipsWnd.GetCursorWindow()
    if pTargetWnd ~= nil then
        if self.m_TipShow == false then
            if self.m_DownSkill ~= nil then
                if self.m_DownSkill == pTargetWnd or pTargetWnd:isAncestor(m_DownSkill) then
                    self.m_TipTime = self.m_TipTime + delta
					if self.m_TipTime >= 500 then
						local pCell = self.m_DownSkill
						if pCell == nil then
							return
                        end
						local skillid = pCell:GetSkillID()
						if skillid == 0 then
							return
                        end
						BattleSkillTip.showAndSetSkill(skillid)
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
        self.m_DownSkill = nil
    end
end

function BattleSkillPanel.showAndRefreshSkills(id)    
    local dlg = BattleSkillPanel.getInstanceAndShow()
    dlg:RefreshSkills(id)
end
return BattleSkillPanel
