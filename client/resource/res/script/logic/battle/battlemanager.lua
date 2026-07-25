------------------------------------------------------------------
-- 角色道具管理类
------------------------------------------------------------------

eItemOpSoundType_Pickup         = 0
eItemOpSoundType_Putdown        = 1

-------------------------------------------------------------

BattleManager =
{
    m_RoleSkillMap = {},
    m_ExtSkillMap = {},
    m_EquipSkillMap = {},
    m_PetSkillMap = {},
    m_MainCharacterLevel = 0,
}
BattleManager.__index = BattleManager

local _instance

function BattleManager.getInstance()
    if not _instance then
        _instance = BattleManager:new()
    end
    return _instance
end

function BattleManager.destroyInstance()
    if _instance then
        _instance = nil
    end
end

function BattleManager:new()
    local self = {}
    setmetatable(self, BattleManager)
    return self
end


--void SaveBattleData();
function BattleManager.SaveBattleData()
    local mgr = BattleManager.getInstance()
	mgr:ReleaseBattleData()

	mgr.m_RoleSkillMap = RoleSkillManager.getInstance():GetRoleSkillMap()
	mgr.m_ExtSkillMap = RoleSkillManager.getInstance():GetRoleExtSkillIDArr()
	mgr.m_EquipSkillMap = RoleSkillManager.getInstance():GetRoleEquipSkillIDArr()
	mgr.m_MainCharacterLevel = gGetDataManager():GetMainCharacterLevel()
	BattleManager.SavePetBattleData()
end

function BattleManager.SavePetBattleData()
    local mgr = BattleManager.getInstance()
	mgr.m_PetSkillMap = RoleSkillManager.getInstance():GetPetBattleSkillIDArr()
end

function BattleManager.ReleaseBattleData()
    local mgr = BattleManager.getInstance()
	mgr.m_RoleSkillMap = {}
	mgr.m_ExtSkillMap = {}
	mgr.m_EquipSkillMap = {}
	mgr.m_PetSkillMap = {}
end

function BattleManager:GetRoleBattleSkillIDArr()
	local Result = {}    
    local sortskill = {}
    for k,v in pairs(self.m_RoleSkillMap) do
		--熟练度>0表示学会了的技能
		if v.blearn ~= nil and v.blearn == true then
			local skillsort = BeanConfigManager.getInstance():GetTableByName("skill.cschoolskillitem"):getRecorder(k)
			local skillinfo = BeanConfigManager.getInstance():GetTableByName("skill.cskillitem"):getRecorder(k)
			local skilltype = GameTable.skill.GetCSkillTypeConfigTableInstance():getRecorder(k)
			--只显示战斗内使用的技能
			if skillsort and skillinfo and skilltype and
                skillinfo.id ~= -1 and bit.band(skillinfo.bCanUseInBattle, 0x01) ~= 0 and
				skilltype.skilltype ~= 9 and
				skilltype.skilltype ~= 10 and
				skilltype.skilltype ~= 11 and
				skillsort.skillsort ~= 0 then
                local sinfo = {}
                sinfo.sortid = skillsort.skillsort;
                sinfo.skillid = skillinfo.id;
                table.insert(sortskill,sinfo)
			end
		end
	end
    table.sort(sortskill,function(a,b) return a.sortid<b.sortid end)
	for i=1,#sortskill do
        Result[i] = sortskill[i].skillid
    end
	return Result
end

function BattleManager:GetRoleExtSkillIDArr()
	return self.m_ExtSkillMap
end

function BattleManager:GetRoleEquipSkillIDArr()
	return self.m_EquipSkillMap
end

function BattleManager:GetPetBattleSkillIDArr()
    return self.m_PetSkillMap
end

function BattleManager:GetRoleSkillLevel(skillid)
    for k,v in pairs(self.m_RoleSkillMap) do
        if k == skillid then
            return v.level
        end
    end
	return 0;
end

function BattleManager:GetMainCharacterLevel()
    return self.m_MainCharacterLevel
end

return BattleManager
