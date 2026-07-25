------------------------------------------------------------------
-- 角色技能管理类
------------------------------------------------------------------

-- 使用物品的粒子特效飞行
stUseItemEffectFly = {}
stUseItemEffectFly.__index = stUseItemEffectFly

function stUseItemEffectFly:new()
    local self = {}
    setmetatable(self, stUseItemEffectFly)
    self:init()
    return self
end

function stUseItemEffectFly:init()
	self.m_pUseItemEffect   = nil
	self.StartPoint         = nil
    self.EndPoint           = nil
    self.pDestWindow        = nil
    self.x                  = 0.0
    self.y                  = 0.0
    self.v_x                = 0.0
    self.v_y                = 0.0
    self.xtime              = 0.0
    self.ytime              = 0.0
    self.bdisappear         = false
    self.life               = 3000
    self.begintime          = 0
end

function stUseItemEffectFly:destroy()
	if self.m_pUseItemEffect then
		Nuclear.GetEngine():ReleaseEffect(self.m_pUseItemEffect)
		self.m_pUseItemEffect = nil
	end
end

function stUseItemEffectFly:Run()
	self.m_pUseItemEffect:SetLocation(Nuclear.NuclearPoint( math.floor(self.x), math.floor(self.y) ))
	Nuclear.GetEngine():DrawEffect(self.m_pUseItemEffect)

	local delta = math.floor(gGetServerTime() - self.begintime)
	self.begintime = gGetServerTime()

 	self.life = self.life - delta
 	if self.life <= 0 then
 		self:Stop()
 		return
 	end
	
	if delta > 50 then
		delta = 50
    end

	local bxreach = false
	local byreach = false
	if (self.StartPoint.x < self.EndPoint.x and self.x > self.EndPoint.x)
		or (self.StartPoint.x > self.EndPoint.x and self.x < self.EndPoint.x) then
		bxreach = true
	end
	if (self.StartPoint.y < self.EndPoint.y and self.y > self.EndPoint.y)
		or (self.StartPoint.y > self.EndPoint.y and self.y < self.EndPoint.y) then
		byreach = true
	end
	if bxreach and byreach then
		--self:Stop()
		return
	end
	if not bxreach then
		self.x = self.x + self.v_x * delta
	end
	if not byreach then
		self.y = self.y + self.v_y * delta
	end
end

function stUseItemEffectFly:Stop()
	self.bdisappear = true

	-- 如果是飞入包裹栏的粒子特效，飞入结束后，包裹按钮要有特效
	if self.pDestWindow == CEGUI.WindowManager:getSingleton():getWindow("MainControlDlg/back/pack") then
		MainControl.SetPackBtnFlash()
	end
end

function stUseItemEffectFly:PlayUseItemEffect(beginPnt, endPnt, destWindow, forGuide)
    if forGuide == nil then
        forGuide = false
    end

	local effectId = 10210
	if forGuide then
		effectId = 11070
	end

	self.m_pUseItemEffect = Nuclear.GetEngine():CreateEffect(MHSD_UTILS.get_effectpath(effectId))
	if not self.m_pUseItemEffect then
		return false
    end
	
	self.pDestWindow = destWindow
	self.StartPoint = beginPnt
	self.EndPoint = endPnt
	self.begintime = gGetServerTime()

	self.x = self.StartPoint.x
	self.y = self.StartPoint.y

	self.m_pUseItemEffect:SetLocation(Nuclear.NuclearPoint( math.floor(self.x), math.floor(self.y) ))

	self.ytime = 2000.0
	self.xtime = 1600.0
		
	self.v_x = (self.EndPoint.x - self.StartPoint.x) / self.xtime
	self.v_y = (self.EndPoint.y - self.StartPoint.y) / self.ytime

	return true
end

-------------------------------------------------------------

RoleSkillManager = {}
RoleSkillManager.__index = RoleSkillManager

local _instance

function RoleSkillManager.getInstance()
    if not _instance then
        _instance = RoleSkillManager:new()
        _instance.m_RoleSkillMap            = {}
        _instance.m_AcupointInfo            = {}
        _instance.m_ExtSkillMap             = {}
        _instance.m_listUseItemEffectFly    = {}
    end
    return _instance
end

function RoleSkillManager.destroyInstance()
    if _instance then
        _instance.m_RoleSkillMap            = {}
        _instance.m_AcupointInfo            = {}
        _instance.m_ExtSkillMap             = {}
        _instance.m_listUseItemEffectFly    = {}
        _instance = nil
    end
end

function RoleSkillManager:new()
    local self = {}
    setmetatable(self, RoleSkillManager)
    return self
end

function RoleSkillManager:GetRoleSkillMap()
    return self.m_RoleSkillMap
end

function RoleSkillManager.InitRoleSkillAndAcupoint(school)
    local mgr = RoleSkillManager.getInstance()
    local acupointlist = BeanConfigManager.getInstance():GetTableByName("role.acupointinfo"):getAllID()



    for j=1, #acupointlist do
        local sc = math.floor(acupointlist[j]/100)
		if sc == school then
			mgr.m_AcupointInfo[acupointlist[j]] = 0
        end
	end
	local skilllist = BeanConfigManager.getInstance():GetTableByName("skill.cskillitem"):getAllID()
    for j=1, #skilllist do
        local sc = math.floor(skilllist[j]/10000)
		if sc == school then
			local SkillAcupoint = BeanConfigManager.getInstance():GetTableByName("role.skillacupointconfig"):getRecorder(skilllist[j])
            local initlevel = 0
            if SkillAcupoint then
                initlevel = SkillAcupoint.initValue
            end
	        local data = {};
			data.level = initlevel
            data.blearn = false
			data.infodes = ""
			mgr.m_RoleSkillMap[skilllist[j]] = data
		end
	end
end

function RoleSkillManager.GetSkillUseType(skillid)
	local skilluse = 0;
	local skilltype = gGetSkillTypeByID(skillid);
	if skilltype == eSkillType_Normal or skilltype == eSkillType_Other 
                                      or skilltype == eSkillType_Marry 
                                      or skilltype == eSkillType_NuQi then
		local skillbase = BeanConfigManager.getInstance():GetTableByName("skill.cskillitem"):getRecorder(skillid)
		if skillbase then
			skilluse = skillbase.targettype
        end
	elseif skilltype == eSkillType_Pet then
		local petskill = BeanConfigManager.getInstance():GetTableByName("skill.cpetskillconfig"):getRecorder(skillid)
		if petskill then
			skilluse = petskill.targettype
		end
	elseif skilltype == eSkillType_Equip then
		local equipskill = BeanConfigManager.getInstance():GetTableByName("skill.cequipskill"):getRecorder(skillid)
		if equipskill then
			skilluse = equipskill.targettype
		end
	end
	return skilluse
end


function RoleSkillManager.GetSkillIconByID(skillid)
	local skilltype = gGetSkillTypeByID(skillid)
	if skilltype == eSkillType_Normal or skilltype == eSkillType_Other then
		local skillItem = BeanConfigManager.getInstance():GetTableByName("skill.cskillitem"):getRecorder(skillid)
		if skillItem then
			return skillItem.normalIcon
        end
	elseif skilltype == eSkillType_Pet then
		local skillItem = BeanConfigManager.getInstance():GetTableByName("skill.cpetskillconfig"):getRecorder(skillid)
		if skillItem then
			return skillItem.icon
        end
	elseif skilltype ==  eSkillType_Life then
		local Lifeskill = BeanConfigManager.getInstance():GetTableByName("skill.cpetskillconfig"):getRecorder(skillid)
		if Lifeskill.id ~= -1 then
			return Lifeskill.icon
        end
	elseif skilltype ==  eSkillType_Equip then
		local equipskill = BeanConfigManager.getInstance():GetTableByName("skill.cequipskill"):getRecorder(skillid)
		if equipskill then
			return equipskill.icon
        end
	end

	return 0
end

function RoleSkillManager:GetRoleBattleSkillIDArr()--人物技能
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
				bit.band(skillinfo.bCanUseInBattle, 0x01) ~= 0 and
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
	return Result;
end


function RoleSkillManager:UpdateSkillInfoWhenAcupointLevelUp(acupointid,playeffect)
	--local acupointinfo = GameTable.role.GetAcupointInfoTableInstance():getRecorder(acupointid)
    local acupointinfo = BeanConfigManager.getInstance():GetTableByName("role.acupointinfo"):getRecorder(acupointid)
	if acupointinfo then
        local sz = acupointinfo.pointToSkillList:size()-1

		for i=0,sz do
			local skillid = acupointinfo.pointToSkillList[i]

			local acupointlevel = self.m_AcupointInfo[acupointid]
            if self.m_RoleSkillMap[skillid] == nil then
                self.m_RoleSkillMap[skillid] = {}
            end
			self.m_RoleSkillMap[skillid].level = acupointlevel
			local SkillAcupoint = BeanConfigManager.getInstance():GetTableByName("role.skillacupointconfig"):getRecorder(skillid)
			if SkillAcupoint then
				local skillinfo = BeanConfigManager.getInstance():GetTableByName("role.skillinfoconfig"):getRecorder(skillid)
                if skillinfo then
                    local slsz = skillinfo.SkillLevelRequireList:size()-1
				    for j = 0, slsz do
					    --其实就是超过SkillLevelRequireList第一个临界等级，就算学会
					    if self.m_RoleSkillMap[skillid].level >= skillinfo.SkillLevelRequireList[j] then
						    self.m_RoleSkillMap[skillid].blearn = true
						    self.m_RoleSkillMap[skillid].infodes = skillinfo.SkillDesList[j]
					    end
				    end
                end
			end
		end
	end
end

function RoleSkillManager:UpdateAcupointLevel(pointid,level)
	local prelevel = self.m_AcupointInfo[pointid]
	self.m_AcupointInfo[pointid] = level

	--local acupointinfo = GameTable.role.GetAcupointInfoTableInstance():getRecorder(pointid)
    local acupointinfo = BeanConfigManager.getInstance():GetTableByName("role.acupointinfo"):getRecorder(pointid)
	if acupointinfo.id ~= 0 then
        local parastring = {}
        table.insert(parastring,acupointinfo.name)
        table.insert(parastring,tostring(level))
        GetChatManager():AddTipsMsg(142309, 0, parastring, false)
	end
	
	self:UpdateSkillInfoWhenAcupointLevelUp(pointid);
end

function RoleSkillManager:UpdateRoleSkillAndAcupoint()
	--计算技能熟练度
	for k,v in pairs(self.m_AcupointInfo) do
		if v > 0 then
			self:UpdateSkillInfoWhenAcupointLevelUp(k,false)	--参数为false表示不播特效
		end
    end
end

function RoleSkillManager:InsertAcupointInfo(nKey, nValue)
	self.m_AcupointInfo[nKey] = nValue
end

function RoleSkillManager:GetRoleSkillLevel(skillid)
    for k,v in pairs(self.m_RoleSkillMap) do
		--熟练度>0表示学会了的技能
		if k == skillid then
            return v.level
		end
	end
    return 0
end

function RoleSkillManager:IsAcupointFullLevel(acupointid)
	for k,v in pairs(self.m_AcupointInfo) do
		if k == acupointid then			
            --return v == GameTable.role.GetAcupointInfoTableInstance():getRecorder(acupointid).maxlevel
            return v == BeanConfigManager.getInstance():GetTableByName("role.acupointinfo"):getRecorder(acupointid).maxlevel
		end
    end
    return false
end

function RoleSkillManager:GetAcupointLevelUpMoneyConsume(acupointid)
	if self:IsAcupointFullLevel(acupointid) then
		return 0
	end

	local acupointRule = 1
	--local info = GameTable.role.GetAcupointInfoTableInstance():getRecorder(acupointid)
    local info = BeanConfigManager.getInstance():GetTableByName("role.acupointinfo"):getRecorder(acupointid)
	if info and info.id ~= -1 then
		if info.isJueji == true then return 0 end
		acupointRule = info.studyCostRule
	end
	
	local acupointlevel = 0
    for k,v in pairs(self.m_AcupointInfo) do
		if k == acupointid then			
            acupointlevel = self.m_AcupointInfo[acupointid]
		end
    end

	local AcupointLevelUpInfo = BeanConfigManager.getInstance():GetTableByName("role.acupointlevelup"):getRecorder(acupointlevel + 1)
	if AcupointLevelUpInfo and AcupointLevelUpInfo.id ~= -1 then
		--return static_cast<int64_t>(AcupointLevelUpInfo.moneyCostRule[acupointRule - 1]);
		return AcupointLevelUpInfo.moneyCostRule[acupointRule - 1]
    end
	return 0
end

function RoleSkillManager:GetAcupointLevelUpExperienceConsume(acupointid)
	if self:IsAcupointFullLevel(acupointid) then
		return 0
	end
	local acupointrank = math.floor((acupointid%100)/10)
	local acupointlevel = 0;
	
    for k,v in pairs(self.m_AcupointInfo) do
		if k == acupointid then			
            acupointlevel = self.m_AcupointInfo[acupointid]
		end
    end
	local AcupointLevelUpInfo = BeanConfigManager.getInstance():GetTableByName("role.acupointlevelup"):getRecorder(acupointlevel + 1)
	if AcupointLevelUpInfo and AcupointLevelUpInfo.id ~= -1 then
		--return static_cast<int64_t>(AcupointLevelUpInfo.needExp[acupointrank - 1]);
		return AcupointLevelUpInfo.needExp[acupointrank - 1]
	end
	return 0;
end

function RoleSkillManager:IsTheAcupointCanLevelUp(acupointid, showMsg)
	if self:IsAcupointFullLevel(acupointid) then
		if showMsg and GetChatManager() then
            GetChatManager():AddTipsMsg(141229)
        end
		return false
	end
	--local info = GameTable.role.GetAcupointInfoTableInstance():getRecorder(acupointid)
    local info = BeanConfigManager.getInstance():GetTableByName("role.acupointinfo"):getRecorder(acupointid)
	if info == nil then return false end
	local nRoleLevel = gGetDataManager():GetMainCharacterLevel()
	local nCurLevel = self:GetAcupointLevelByID(acupointid)

	if info.isMain == true then
		--通过和角色等级比较来判断是否还能升级
		if nCurLevel < nRoleLevel then
			return true
		end
        local parastring = {}
        table.insert(parastring,tostring(nCurLevel+1))
        GetChatManager():AddTipsMsg(141230, 0, parastring, false)
		return false
	end

	--yanji 20150902 
    local acupoints = MHSD_UTILS.split_string(info.dependAcupoint, ",")
	local nFirstAcupiontID = tonumber(acupoints[1])
    
    for k,v in pairs(self.m_AcupointInfo) do
		if k == nFirstAcupiontID then
            if nCurLevel < v then
			    return true
		    else
                local info1 = BeanConfigManager.getInstance():GetTableByName("role.acupointinfo"):getRecorder(nFirstAcupiontID)
                if info1 and info1.pointToSkillList:size() > 0 then
                    local skillconfig = BeanConfigManager.getInstance():GetTableByName("skill.cskillitem"):getRecorder(info1.pointToSkillList[0])
                    
				    if showMsg and GetChatManager() then
                        local parastring = {}
                        table.insert(parastring,skillconfig.skillname)
                        table.insert(parastring,tostring(v+1))
                        GetChatManager():AddTipsMsg(141232, 0, parastring, false)
                    end
                end
			    return false
		    end
        end
    end

	return false
end

function RoleSkillManager:GetAcupointLevelByID(acupointid)
    for k,v in pairs(self.m_AcupointInfo) do
		if k == acupointid then			
            return v
		end
    end
    return 0
end

--请求升级技能
-->0 金钱不足的额度
--0 升级的金钱足够
-- -1 非正常错误
function RoleSkillManager:RequestAcupointLevelUp(acupointid, showMsg)
	--判断是否可以一键升级
	if acupointid == 0 then
		--找出可以升级的技能及需要花费的金钱
		for k,v in pairs(self.m_AcupointInfo) do
			--local info = GameTable.role.GetAcupointInfoTableInstance():getRecorder(k)
            local info = BeanConfigManager.getInstance():GetTableByName("role.acupointinfo"):getRecorder(k)
			if info and info.isJueji == true then return 0 end
			if info and info.id ~= -1 then
			    local curLevel = v
			    local acupoints = {}
			    local delimiters = ",";

			    MHSD_UTILS.split_string(info.dependAcupoint, delimiters, acupoints)
			    local dependID = tonumber(acupoints[0]);
			    if dependID ~= 0 then
				    local dependLevel = info.dependLevel;
				    local actualLevel = self:GetAcupointLevelByID(dependID)
				    if actualLevel >= dependLevel then
					    if curLevel < actualLevel then --判断是否能升级
						    --判断升一级的钱是否足够
						    local levelUpMoney = self:GetAcupointLevelUpMoneyConsume(k)
						    if levelUpMoney > gGetRoleItemManager():GetPackMoney() then
							    return levelUpMoney - gGetRoleItemManager():GetPackMoney()
						    end
						    return 0
					    end
				    end
			    else
				    if curLevel < gGetDataManager():GetMainCharacterLevel() then --如果还能升级的话
					    --判断金钱是否足够
					    local levelUpMoney = self:GetAcupointLevelUpMoneyConsume(k)
					    if levelUpMoney > gGetRoleItemManager():GetPackMoney() then
						    return levelUpMoney - gGetRoleItemManager():GetPackMoney()
					    end
					    return 0
				    end
			    end
            end
		end
		return 0
	else
		if self:IsTheAcupointCanLevelUp(acupointid, showMsg) then
			--如果储备金不够，可能需要弹出2次确认
			local nConsume = self:GetAcupointLevelUpMoneyConsume(acupointid)
			if nConsume > RoleItemManager_GetPackMoney() then
				return nConsume - RoleItemManager_GetPackMoney()
			else
				return 0
            end
		end
	end
	return -1
end

function RoleSkillManager:GetRoleAcupointVec() 
	local acupointVec = {}
    local acupointKey = {}
    for k,v in pairs(self.m_AcupointInfo) do
        table.insert(acupointKey,k)
    end
    table.sort(acupointKey, function (v1, v2)
	    return v1 < v2
	end)
    for k,v in pairs(acupointKey) do
        table.insert(acupointVec,v)
        table.insert(acupointVec,self.m_AcupointInfo[v])
    end
	return acupointVec
end

function RoleSkillManager:GetRoleExtSkillIDArr()
	local Result = {}
    
    for k,v in pairs(self.m_ExtSkillMap) do
		table.insert(Result,k)
    end
	return Result
end

function RoleSkillManager:ClearExtSkill()
	self.m_ExtSkillMap = {}
end

function RoleSkillManager:InsertExtSkill(nKey, nValue)
	self.m_ExtSkillMap[nKey] = nValue;
end


--设置技能特技
function RoleSkillManager:ClearEquipSkillMap()
	self.m_EquipSkillMap = {}
	self.m_EquipEffectMap = {}
end

function RoleSkillManager:InsertEquipSkillMap(skillData,effectData)
    if self.m_EquipSkillMap == nil then
        self.m_EquipSkillMap = {}
    end
    if self.m_EquipEffectMap == nil then
        self.m_EquipEffectMap = {}
    end
    if skillData then
        for k,skillID in pairs(skillData) do 
	        table.insert(self.m_EquipSkillMap,skillID)
	    end
    end
    if effectData then
        for k,effectID in pairs(effectData) do 
	        table.insert(self.m_EquipEffectMap,effectID)
	    end
    end
end
function RoleSkillManager:GetRoleEquipSkillIDArr()
	return self.m_EquipSkillMap
end
function RoleSkillManager:GetSkillRealCost(tp,val)
    local rt = 1
    if tp == 120 then
        for i = 1,#self.m_EquipEffectMap do
            if self.m_EquipEffectMap[i] == 430025 then
                rt = rt * 0.8
            end
        end
    end
    return math.ceil(val * rt)
end

function RoleSkillManager:GetPetBattleSkillIDArr()
	local Result = {}
    local petlist = MainPetDataManager.getInstance():GetBattlePetSkillList()
    for i=0,petlist._size-1 do        
		local skillBase = BeanConfigManager.getInstance():GetTableByName("skill.cpetskillconfig"):getRecorder(petlist[i].skillid)
		if skillBase and skillBase.skilltype == 2 then	--必须是主动使用的技能
            table.insert(Result,skillBase.id)
		end
    end
	return Result
end

-------------------------------------------------------------

function RoleSkillManager:AddUseItemEffect(destwndname, startpos)
	local winMgr = CEGUI.WindowManager:getSingleton()
	if not winMgr:isWindowPresent(destwndname) then
		return
    end
	
	local pDesWindow = winMgr:getWindow(destwndname)
	local endpos = Nuclear.NuclearFPoint(pDesWindow:GetScreenPos().x, pDesWindow:GetScreenPos().y)

	local pEffectFly = stUseItemEffectFly:new()
	if pEffectFly:PlayUseItemEffect(startpos, endpos) then
		table.insert(self.m_listUseItemEffectFly, pEffectFly)
	end
end

function RoleSkillManager:AddNewGuideEffect(loc)
	-- 起始点
	local beginPoint = Nuclear.NuclearFPoint(loc.x, loc.y)

	-- 终点
	local guideId = NewRoleGuideManager.getInstance():getCurGuideId()
	local window = NewRoleGuideManager.getInstance():GetGuideClickWnd(guideId)
	if not window then return end

	local wndScreenPos = window:GetScreenPosOfCenter()
	local endPoint = Nuclear.NuclearFPoint(wndScreenPos.x, wndScreenPos.y)

	local pEffectFly = stUseItemEffectFly:new()
	if pEffectFly:PlayUseItemEffect(beginPoint, endPoint, nil, true) then
		table.insert(self.m_listUseItemEffectFly, pEffectFly)
	end
end

function RoleSkillManager:DrawEffect()
    for index, pEffectFly in pairs(self.m_listUseItemEffectFly) do
		pEffectFly:Run()
		-- 如果应该消失了
		if pEffectFly.bdisappear then
			self.m_listUseItemEffectFly[index] = nil
		end
	end
end

-------------------------------------------------------------

return RoleSkillManager
