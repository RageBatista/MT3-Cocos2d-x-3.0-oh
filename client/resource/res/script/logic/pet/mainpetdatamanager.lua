------------------------------------------------------------------
-- ԭ C++ MainRoleDataManager �еĳ������
------------------------------------------------------------------

require "logic.pet.mainpetdata"
require "logic.pet.petstoragedlg"

-------------------------------------------------------------

MainPetDataManager = {}
MainPetDataManager.__index = MainPetDataManager

local _instance

function MainPetDataManager.getInstance()
    if not _instance then
        _instance = MainPetDataManager:new()
    end
    return _instance
end

function MainPetDataManager.destroyInstance()
    if _instance then
        _instance = nil
    end
end

function MainPetDataManager:new()
    local self = {}
    setmetatable(self, MainPetDataManager)
    self.m_MyPackPetList = {}
    self.m_MyDeportPetList = {}
    self.m_PetMaxNum = 0
    self.m_iDeportCapacity = 3
    self.m_iLastRefreshPet = 0
    return self
end

-------------------------------------------------------------

function MainPetDataManager:AddPetToColumn(columnid, data)
	local petData = stMainPetData:new()
    petData:initWithLua(data)

	self:AddMyPet(petData, columnid)

	if not GetBattleManager():IsInBattle() then
		petstoragedlg.addPet(columnid, petData.key)
	end
end

function MainPetDataManager:AddMyPet(petData, columnid)
    if not gGetDataManager() then
        return
    end

    if not columnid then
        columnid = 1
    end

	if self:FindMyPetByID(petData.key, columnid) then
		return
    end
	
	self.m_iLastRefreshPet = petData.key

	-- ������ĳ���
	if columnid == 1 then
        table.insert(self.m_MyPackPetList, petData)
		if petData.key == gGetDataManager():GetMainCharacterShowpet() then
			local mapPetData = stMapPetData()
			mapPetData.roleid = gGetDataManager():GetMainCharacterID()
			mapPetData.showpetid = petData.baseid
			mapPetData.showpetname = petData.name
			mapPetData.showpetcolour = petData.colour
			mapPetData.level = petData.petattribution[fire.pb.attr.AttrType.LEVEL]
			gGetScene():AddScenePet(mapPetData)
		end
        table.sort(self.m_MyPackPetList, function(a,b) return a.key<b.key end)
		gGetDataManager().m_EventPetNumChange:Bingo()
	elseif columnid == 2 then
        table.insert(self.m_MyDeportPetList, petData)
		gGetDataManager().m_EventDeportPetNumChange:Bingo()
	end
end

function MainPetDataManager:RemovePetByID(thisID, columnid)
    if not gGetDataManager() then
        return false
    end

    if not columnid then
        columnid = 1
    end

	self.m_iLastRefreshPet = thisID

	if columnid == 1 then
        for k, petData in pairs(self.m_MyPackPetList) do
            if petData.key == thisID then
                table.remove(self.m_MyPackPetList,k)
                gGetDataManager().m_EventPetNumChange:Bingo()
		        return true
            end
        end
	elseif columnid == 2 then
        for k, petData in pairs(self.m_MyDeportPetList) do
            if petData.key == thisID then
                self.m_MyDeportPetList[k] = nil
                gGetDataManager().m_EventDeportPetNumChange:Bingo()
                return true
            end
        end
	end

	return false
end

function MainPetDataManager:isMyPetListEmpty()
	return TableUtil.tablelength(self.m_MyPackPetList) == 0
end

function MainPetDataManager:AddMyPetList(petList, columnid)
    if not columnid then
        columnid = 1
    end

	self:ClearPetList(columnid)
    for k, data in pairs(petList) do
	    local petData = stMainPetData:new()
        petData:initWithLua(data)
		self:AddMyPet(petData, columnid)
	end
end

function MainPetDataManager:ClearPetList(columnid)
	if columnid == 1 then
		self.m_MyPackPetList = {}
	elseif columnid == 2 then
		self.m_MyDeportPetList = {}
	end
end

-- ���ĳ�������
function MainPetDataManager:UpdatePetName(roleid, petkey, name)
    if not gGetDataManager() then
        return
    end

	if roleid == gGetDataManager():GetMainCharacterID() then
		local petData = self:FindMyPetByID(petkey)
		if petData then
		    self.m_iLastRefreshPet = petkey
		    petData.name = name
		    gGetDataManager():FirePetNameChange(petkey)
		end
        return
	end

 	-- ���ĵ�ͼ�ϵĳ�������
    local showPet = gGetScene():FindPetByMasterID(roleid)
    if showPet then
        showPet:ChangeName(name)
    end
end

-- ˢ�³��ﾭ��
function MainPetDataManager:RefreshPetExp(petkey, exp)
	local petData = self:FindMyPetByID(petkey)
	if petData and gGetDataManager() then
		petData.curexp = exp
		gGetDataManager():FirePetDataChange(petkey)
		if petData == self:GetBattlePet() then
			gGetDataManager().m_EventBattlePetDataChange:Bingo()
		end
	end
end

function MainPetDataManager:RefreshPetScore(petkey, score, petBaseScore)
    local petData = self:FindMyPetByID(petkey)
	if petData and gGetDataManager() then
		petData.score = score
		petData.basescore = petBaseScore
		gGetDataManager():FirePetDataChange(petkey)
	end
end

-- ˢ�³��＼��
function MainPetDataManager:RefreshPetSkills(petkey, skills, expiredtimes)
	local petData = self:FindMyPetByID(petkey)
	if not petData or not GetBattleManager() or not gGetDataManager() then
		return
    end

	self.m_iLastRefreshPet = petkey
	petData.petskilllist = skills
	petData.petskillexpires = expiredtimes
	
    local btautoid = GetBattleManager():GetPetAutoSkillID()
    if btautoid ~= -1 then
        for k, petskill in pairs(skills) do
            if petskill.skillid/100 == btautoid/100 then
                GetBattleManager():SetPetAutoSkillID(petskill.skillid)
                break
            end
        end
    end

    gGetDataManager().m_EventPetSkillChange:Bingo(petkey)
end

function MainPetDataManager:IsMyPetFull()
	return TableUtil.tablelength(self.m_MyPackPetList) == self.m_PetMaxNum
end

function MainPetDataManager:GetPetNum()
	return TableUtil.tablelength(self.m_MyPackPetList)
end

function MainPetDataManager:getPet(index)
    local i = 1
    for k, petData in pairs(self.m_MyPackPetList) do
        if i == index then
            return petData
        end
        i = i + 1
    end
    return nil
end

function MainPetDataManager:GetDeportPetNum()
	return TableUtil.tablelength(self.m_MyDeportPetList)
end

function MainPetDataManager:getDeportPet(index)
    local i = 1
    for k, petData in pairs(self.m_MyDeportPetList) do
        if i == index then
            return petData
        end
        i = i + 1
    end
    return nil
end

-- �õ�����ļ�����
function MainPetDataManager:GetPetSkillNum(petData)
	return petData:getPetSkillNum()
end

function MainPetDataManager:GetPetLevel(petkey, columnid)
    if not columnid then
        columnid = 1
    end

	local petData = self:FindMyPetByID(petkey, columnid)
	if petData then
		return petData.petattribution[fire.pb.attr.AttrType.LEVEL]
	end
	return 0
end

function MainPetDataManager:GetMaxPetNum()
	return self.m_PetMaxNum
end

-- ���ս�������ʱ��ͬʱˢbuffid
function MainPetDataManager:ClearBattlePet()
    if not gGetDataManager() or not GetBattleManager() then
        return
    end

    local fightpet = gGetDataManager():GetMainCharacterFightpet()
	if fightpet > 0 and GetBattleManager():IsInBattle() and self:FindMyPetByID(fightpet) then
		GetBattleManager():ClearPetDefaultSkillID()	-- �������Ĭ�ϼ���
		self:SetBattlePetState(ePetState_AlreadyFight)
		BattleManager.SavePetBattleData()
	end

	gGetDataManager():SetMainCharacterFightpet(0)
	GetBattleManager():ResetPetAutoOperateCommand()
	gGetDataManager().m_EventBattlePetStateChange:Bingo()
end

-- ս������������Ϣ
function MainPetDataManager:ClearBattlePetOfEndBattleScene()
	local battlePet = self:GetBattlePet()
	if battlePet and battlePet.petattribution[fire.pb.attr.AttrType.PET_LIFE] < fire.pb.DataInit.PET_FIGHT_LIFE_LIMIT
      and battlePet.kind ~= fire.pb.pet.PetTypeEnum.SACREDANIMAL then
        local p = require("protodef.fire.pb.pet.csetfightpetrest"):new()
        LuaProtocolManager:send(p)
		self:ClearBattlePet()
	end
end

-- ����columnidΪ������id,�����е�idΪ1���ֿ��е�idΪ2
function MainPetDataManager:FindMyPetByID(thisID, columnid)
    if not columnid then
        columnid = 1
    end

	if columnid == 1 then
		for k, petData in pairs(self.m_MyPackPetList) do
			if petData.key == thisID then
				return petData
			end
		end
	elseif columnid == 2 then
		for k, petData in pairs(self.m_MyDeportPetList) do
			if petData.key == thisID then
				return petData
			end
		end
	end
	
	return nil
end

-- ���òֿ��������
function MainPetDataManager:SetDeportCapacity(num)
	self.m_iDeportCapacity = num
end

-- ��ȡ�ֿ��������
function MainPetDataManager:GetDeportCapacity()
	return self.m_iDeportCapacity
end

-- �������¸������ݵĳ���id
function MainPetDataManager:SetLastRefreshPetID(id)
	self.m_iLastRefreshPet = id;
end

-- ˢ��ս����������
function MainPetDataManager:UpdateBattlePetAttribute(key, value)
	local battlePet = self:GetBattlePet()
	if battlePet then
        battlePet.petattribution[key] = value
	end
end

-- ˢ��ս�����������ֵ
function MainPetDataManager:UpdateBattlePetHpChange(hpChange, hpmaxChange)
    if not gGetDataManager() then
        return
    end

	local battlePet = self:GetBattlePet()
	if battlePet then
		battlePet.petattribution[fire.pb.attr.AttrType.HP] = battlePet.petattribution[fire.pb.attr.AttrType.HP] + hpChange
		battlePet.petattribution[fire.pb.attr.AttrType.MAX_HP] = battlePet.petattribution[fire.pb.attr.AttrType.MAX_HP] + hpmaxChange
		if battlePet.petattribution[fire.pb.attr.AttrType.HP] < 0 then
			battlePet.petattribution[fire.pb.attr.AttrType.HP] = 0
        end
		if battlePet.petattribution[fire.pb.attr.AttrType.HP] > battlePet.petattribution[fire.pb.attr.AttrType.MAX_HP] then
			battlePet.petattribution[fire.pb.attr.AttrType.HP] = battlePet.petattribution[fire.pb.attr.AttrType.MAX_HP]
        end
		gGetDataManager().m_EventBattlePetDataChange:Bingo()
	end
end

-- ˢ��ս������ķ���ֵ
function MainPetDataManager:UpdateBattlePetMpChange(mpChange, mpmaxChange)
    if not gGetDataManager() then
        return
    end

	local battlePet = self:GetBattlePet()
	if battlePet then
		battlePet.petattribution[fire.pb.attr.AttrType.MP] = battlePet.petattribution[fire.pb.attr.AttrType.MP] + mpChange
		battlePet.petattribution[fire.pb.attr.AttrType.MAX_MP] = battlePet.petattribution[fire.pb.attr.AttrType.MAX_MP] + mpmaxChange
		if battlePet.petattribution[fire.pb.attr.AttrType.MP] < 0 then
			battlePet.petattribution[fire.pb.attr.AttrType.MP] = 0
        end
		if battlePet.petattribution[fire.pb.attr.AttrType.MP] > battlePet.petattribution[fire.pb.attr.AttrType.MAX_MP] then
			battlePet.petattribution[fire.pb.attr.AttrType.MP] = battlePet.petattribution[fire.pb.attr.AttrType.MAX_MP]
        end
		gGetDataManager().m_EventBattlePetDataChange:Bingo()
	end
end

-- ����ս�������ս��״̬
function MainPetDataManager:SetBattlePetState(state)
	local battlePet = self:GetBattlePet()
	if battlePet then
		battlePet.battlestate = bit.bor(battlePet.battlestate, state)
	end
end

function MainPetDataManager:ResetPetState()
	for k, petData in pairs(self.m_MyPackPetList) do
		petData.battlestate = ePetState_Normal
	end
end

function MainPetDataManager:SetMaxPetNum(num)
	self.m_PetMaxNum = num
end

-- ս�������Ƿ�������еĳ������������
function MainPetDataManager:BattlePetIsMyPackPet()
    if not gGetDataManager() then
        return false
    end

    for k, petData in pairs(self.m_MyPackPetList) do
        if gGetDataManager():GetBattlePetID() == petData.key then
            return true
        end
    end
	return false
end

-- �����ڵ�ǰչʾ�ĳ���򽫳�����뵽���ӳ�������
function MainPetDataManager:AddScenePetIfShowPetExist()
    if not gGetDataManager() then
        return
    end

	for k, petData in pairs(self.m_MyPackPetList) do
		if petData.key == gGetDataManager():GetMainCharacterShowpet() then
			local mapPetData = stMapPetData()
		    mapPetData.roleid = GetMainCharacter():GetID()
		    mapPetData.showpetid = petData.baseid
		    mapPetData.showpetname = petData.name
		    mapPetData.showpetcolour = petData.colour
		    mapPetData.level = petData.scale
		    gGetScene():AddScenePet(mapPetData)
        end
	end
end

-- �õ���ǰ��ս��������
function MainPetDataManager:GetBattlePet()
    if not gGetDataManager() then
        return nil
    end

	for k, petData in pairs(self.m_MyPackPetList) do
		if petData.key == gGetDataManager():GetMainCharacterFightpet() then
			return petData
        end
	end
	return nil
end

-- �õ�ս�����＼���б�(����ս��)
function MainPetDataManager:GetBattlePetSkillList()
    local petSkillList = {}
    petSkillList._size = 0
    function petSkillList:size()
        return self._size
    end

	local petData = self:GetBattlePet()
	if petData then
        for i = 1, #petData.petskilllist do
            petSkillList[petSkillList._size] = petData.petskilllist[i]
            petSkillList._size = petSkillList._size + 1
        end
	end

    return petSkillList
end

-- ����չʾ�еĳ��ˢ�³���״̬
function MainPetDataManager:UpdateShowPet(petKey)
    if gGetDataManager() then
        gGetDataManager():SetMainCharacterShowpet(petKey)
	    gGetDataManager().m_EventShowPetChange:Bingo()
    end
end

function MainPetDataManager:RefreshPetInternals(petkey, skills, expiredtimes)
	local petData = self:FindMyPetByID(petkey)
	if not petData or not GetBattleManager() or not gGetDataManager() then
		return
    end

	self.m_iLastRefreshPet = petkey
	petData.petinternallist = skills
	petData.petinternalexpires = {}
	

    gGetDataManager().m_EventPetInternalChange:Bingo(petkey)
end

return MainPetDataManager
