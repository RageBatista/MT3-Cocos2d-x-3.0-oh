require "logic.dialog"

BattleSkillTip = {}
setmetatable(BattleSkillTip, Dialog)
BattleSkillTip.__index = BattleSkillTip

local _instance
function BattleSkillTip.getInstance()
	if not _instance then
		_instance = BattleSkillTip:new()
		_instance:OnCreate()
	end
	return _instance
end

function BattleSkillTip.getInstanceAndShow()
	if not _instance then
		_instance = BattleSkillTip:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function BattleSkillTip.getInstanceNotCreate()
	return _instance
end

function BattleSkillTip.DestroyDialog()
	if _instance then
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function BattleSkillTip.ToggleOpenClose()
	if not _instance then
		_instance = BattleSkillTip:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function BattleSkillTip.GetLayoutFileName()
	return "skilltipsdialog.layout"
end

function BattleSkillTip:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, BattleSkillTip)
	return self
end

function BattleSkillTip:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

	self.m_pSkillName = winMgr:getWindow("skilltipsdialog/name")
	self.m_pSkillName:setText("")
	
	self.m_pSkillLevel = winMgr:getWindow("skilltipsdialog/level")
	self.m_pSkillLevelNum = winMgr:getWindow("skilltipsdialog/levelnumber")
	self.m_pSkillLevelNum:setText("")
	
	self.m_pSkillCostNum = winMgr:getWindow("skilltipsdialog/xiaohaonumber")
	self.m_pSkillCostNum:setText("")
	
	self.m_pSkillDesc = CEGUI.toRichEditbox(winMgr:getWindow("skilltipsdialog/richeditbox"))
	self.m_pSkillIcon = CEGUI.toSkillBox(winMgr:getWindow("skilltipsdialog/skill"))
	
end
 
function BattleSkillTip:SetSkill(aSkillID)
    if aSkillID == 0 then
		return
	end
	local SkillType = gGetSkillTypeByID(aSkillID)
	local iLevel = gGetDataManager():GetMainCharacterLevel()

    if SkillType == eSkillType_Equip then
        self.m_pSkillLevel:setVisible(false)
		self.m_pSkillLevelNum:setVisible(false)

		local EquipSkill = BeanConfigManager.getInstance():GetTableByName("skill.cequipskill"):getRecorder(aSkillID)
		if EquipSkill and EquipSkill.id == -1 then
			return
        end
		self.m_pSkillName:setText(EquipSkill.name)
        local sb = StringBuilder:new()
        local fParam1 = RoleSkillManager.getInstance():GetSkillRealCost(EquipSkill.costType,EquipSkill.costnum)
        sb:Set("parameter1", tostring(math.abs(fParam1)))
		local ws = sb:GetString(EquipSkill.cost)
        sb:delete()
		self.m_pSkillCostNum:setText(ws)
        
		self.m_pSkillDesc:Clear()
		self.m_pSkillDesc:AppendParseText(CEGUI.String(EquipSkill.describe))
		self.m_pSkillDesc:AppendBreak()
	elseif SkillType == eSkillType_Pet then        
		self.m_pSkillLevel:setVisible(false)
		self.m_pSkillLevelNum:setVisible(false)
		
		local skillBase = BeanConfigManager.getInstance():GetTableByName("skill.cpetskillconfig"):getRecorder(aSkillID)
		self.m_pSkillName:setText(skillBase.skillname)
		self.m_pSkillCostNum:setText(skillBase.param)
		self.m_pSkillDesc:Clear()
		self.m_pSkillDesc:AppendParseText(CEGUI.String(skillBase.skilldescribe))
	elseif SkillType == eSkillType_Marry then    
		self.m_pSkillLevel:setVisible(false)
		self.m_pSkillLevelNum:setVisible(false)
		self.m_pSkillCostNum:setVisible(false)
		local skillFriend = BeanConfigManager.getInstance():GetTableByName("skill.cfriendskill"):getRecorder(aSkillID)
		self.m_pSkillName:setText(skillFriend.name);
		self.m_pSkillDesc:Clear();
		self.m_pSkillDesc:AppendParseText(CEGUI.String(skillFriend.desc));
		self.m_pSkillIcon:SetImage(gGetIconManager():GetSkillIconByID(skillFriend.imageID))
	else
		self.m_pSkillLevel:setVisible(true);
		self.m_pSkillLevelNum:setVisible(true);

		local skillinfo = BeanConfigManager.getInstance():GetTableByName("skill.cskillitem"):getRecorder(aSkillID)
		if skillinfo and skillinfo.id == -1 then
			return
		end
        local showLevel = 0
        if  GetBattleManager():IsInBattle()==false  then
            showLevel = RoleSkillManager.getInstance():GetRoleSkillLevel(aSkillID)
        else        
            showLevel = require("logic.battle.battlemanager").getInstance():GetRoleSkillLevel(aSkillID)
        end
		self.m_pSkillName:setText(skillinfo.skillname);
		self.m_pSkillDesc:Clear();
        local schoolskillbase = BeanConfigManager.getInstance():GetTableByName("skill.cschoolskillitem"):getRecorder(aSkillID)
		if schoolskillbase and schoolskillbase.id ~= -1 then
            local sb = StringBuilder:new()
			local fParam1 = math.floor(schoolskillbase.paramA * showLevel + schoolskillbase.paramB)
            fParam1 = RoleSkillManager.getInstance():GetSkillRealCost(schoolskillbase.costTypeA,fParam1)
            sb:Set("parameter1", tostring(fParam1))
			local ws = sb:GetString(schoolskillbase.costA);
            sb:delete()
			self.m_pSkillCostNum:setText(ws);
            ---------------           
            local desc = ""
            if schoolskillbase then
                local levelRank = 0
                for i = 0, schoolskillbase.levellimit:size() -1 do
                    if schoolskillbase.levellimit[i] <= showLevel then
                        levelRank = i
                    else
                        break
                    end
                end
                if levelRank <= schoolskillbase.leveldescribe:size() -1 then
                    desc = schoolskillbase.skilldescribelist[levelRank]
                else
                    desc = skillinfo.skilldescribe
                end
            else
                desc = skillinfo.skilldescribe
            end
			if desc[0] ~= '<' then
				desc = "<T t=\"" .. desc .. "\"></T>"
			end
			self.m_pSkillDesc:AppendParseText(CEGUI.String(desc))
			self.m_pSkillDesc:AppendBreak();
		else
        
            local sb = StringBuilder:new()
			local fParam1 = math.abs(math.floor(schoolskillbase.paramA * showLevel + schoolskillbase.paramB))
            sb:Set("parameter1", tostring(fParam1))
			local ws = sb:GetString(skillinfo.costA);
            sb:delete()
			self.m_pSkillCostNum:setText(ws);

			ws = skillinfo.skilldescribe;
			if ws[0] ~= '<' then
				ws = "<T t=\"" .. ws .. "\"></T>"
			end
			self.m_pSkillDesc:AppendParseText(CEGUI.String(ws))
			self.m_pSkillDesc:AppendBreak();
		end
        self.m_pSkillLevelNum:setText(tostring(showLevel))
	end
    
    self.m_pSkillDesc:Refresh()
    SkillBoxControl.SetSkillInfo(self.m_pSkillIcon,aSkillID,0)
end

function BattleSkillTip:AppendSkillDescLine(ParseText)
	if self.m_pSkillDesc then
		self.m_pSkillDesc:AppendBreak()
		self.m_pSkillDesc:AppendParseText(ParseText)
		self.m_pSkillDesc:Refresh()
    end
end

function BattleSkillTip.showAndSetSkill(aSkillID)
    local dlg = BattleSkillTip.getInstanceAndShow()
    dlg:SetSkill(aSkillID)
end
return BattleSkillTip
