------------------------------------------------------------------
-- 处理主角和主角宠物的数据更新
-- 服务器发下来有关主角和主宠物的数据更新，直接调用这个类里的函数，
-- 再通过事件多播，传给其他需要更新数据的类，比如MainCharacter等
------------------------------------------------------------------

require "utils.tableutil"
require "utils.scene_common"

MainRoleDataManager = {}
MainRoleDataManager.__index = MainRoleDataManager

local _instance
function gGetDataManager()
    return _instance
end

function MainRoleDataManager.newInstance()
    if not _instance then
        _instance = {}
        setmetatable(_instance, MainRoleDataManager)
        _instance:init()
    end
    return _instance
end

function MainRoleDataManager:init()
    self.m_iLastVisiteNpcID = 0 --最近访问的Npcid
	self.m_MainBattlerTempAttribute = {} --std:map<int,int> 进战斗的时候存一份人物主角的属性
	self.m_FossicNpc = {} --std:map<int64_t,int64_t>
	self.m_sFollowNpc = {} --std:set<int>	主角的跟随npc
	self.m_mHPMPStore = {} --std:map<int, int64_t> hp mp 存储
	self.m_ServerLevel = 0
	self.m_ServerLevelDays = 0
    self.m_GameSetting = {} --MapIntKey
	self.m_Titlemap = {}--TitleMap
	self.m_Contribution = 0 --公会贡献度
    self.m_VecLearnformation = {} --std:vector<stFormationInfo>
    self.m_nYuanBaoNumber = 0 --拥有的符石数
	self.m_nBindYuanBaoNumber = 0 --拥有的绑宝符石数
	self.m_nTotalRechargeYuanBaoNumber = 0 --总共充值的符石数
	self.m_nBuyYuanBaoDefaultPrice = 500 --求购符石时的默认价格
	self.m_nSellYuanBaoDefaultPrice = 500 --寄售符石时的默认价格
	self.m_nVipLevel = 0 --VIP等级
	self.m_fCurrentQili = 0			--当前气力值
    self.m_MapTaskShowNpc = {} --std:map<int, std:vector<int> > 
    self.m_MainCharacterData = stMainCharacterData.new() --stMainCharacterData
    self.m_fubenSettingMap = {}
    self.m_useQianNengGuoNum = 0 --使用潜能果次数

    --Event
    self.m_EventMainCharacterDataChange      = LuaEvent.new()
    self.m_EventMainBattlerAttributeChange   = LuaEvent.new()    --主角战斗属性变化
    self.m_EventMainPetAttributeChange       = LuaEvent.new()    --战斗宠物属性变化
    self.m_EventMainCharacterExpChange       = LuaEvent.new()
    self.m_EventMainCharacterQiLiChange      = LuaEvent.new()    --主角气力值变化
    self.m_EventMainCharacterHpMpChange      = LuaEvent.new()
    --尝试处理新角色造型
    self.m_EventMainCharacterModelChange     = LuaEvent.new()
    self.m_EventPetNumChange                 = LuaEvent.new()
    self.m_EventDeportPetNumChange           = LuaEvent.new()    --仓库宠物数量变化
    self.m_EventPetDataChange                = LuaEvent.new()
    self.m_EventPetSkillChange               = LuaEvent.new()
    self.m_EventPetNameChange                = LuaEvent.new()
    self.m_EventPetInternalChange            = LuaEvent.new()
    self.m_EventShowPetChange                = LuaEvent.new()
    self.m_EventBattlePetStateChange         = LuaEvent.new()    --战斗宠物变化
    self.m_EventBattlePetDataChange          = LuaEvent.new()    --战斗宠物数据变化
    self.m_EventExtendSkillMapChange         = LuaEvent.new()
    self.m_EventXuemaiChange                 = LuaEvent.new()
    self.m_EventSRsqStar                     = LuaEvent.new()    --冲星结果返回
    self.m_EventStarUp                       = LuaEvent.new()    --宠物升星
    self.m_EventActivityChange               = LuaEvent.new()    --活跃度改变
    self.m_EventYuanBaoNumberChange          = LuaEvent.new()    --符石数量改变多播消息
    self.m_EventBindYuanBaoNumberChange      = LuaEvent.new()    --绑定符石数量改变多播消息

    self.m_nnTimePre = -1
    self.m_posPreX = -1
    self.m_posPreY = -1
    self.m_nCheckMoveTime = 10*60*1000
    
end

function MainRoleDataManager.removeInstance()
    if _instance then
        _instance = nil
    end
end

function MainRoleDataManager:setServerLevel(serverlevel)
    self.m_ServerLevel = serverlevel
end

function MainRoleDataManager:setServerLevelDays(serverlevelday)
    self.m_ServerLevelDays = serverlevelday
end

function MainRoleDataManager:getServerLevel()
    return self.m_ServerLevel
end

function MainRoleDataManager:getServerLevelDays()
    return self.m_ServerLevelDays
end

function MainRoleDataManager:GetBattlePetID()
    return self.m_MainCharacterData.fightpet
end

function MainRoleDataManager:SetVipLevel(vipLevel)
    self.m_nVipLevel = vipLevel
end

function MainRoleDataManager:GetVipLevel()
    return self.m_nVipLevel
end

function MainRoleDataManager:RefreshRoleScore(nId, nnValue)
    self.m_MainCharacterData.mapRoleScore[nId] = nnValue
end

function MainRoleDataManager:RefreshCurExp(curexp)
	if gGetDataManager() == nil then
        return
	end
	local oldexp = gGetDataManager():GetMainCharacterExperience()
	if curexp > oldexp then
        local conf = GameTable.effect.GetCEffectConfigTableInstance():getRecorder(fire.pb.attr.AttrType.EXP)
		if conf.id ~= -1 and conf.xianshi == 1 then
            GetMainCharacter():AddPopoMsg(conf.effectid, curexp - oldexp, conf.color, conf.order)
		end
	end
	gGetDataManager():UpdateMainCharacterExp(curexp)
    self.m_EventMainCharacterExpChange:Bingo()
end

function MainRoleDataManager:RefreshRoleHp(hp)
	if gGetDataManager() == nil or GetBattleManager() == nil then
        return
	end
	self.m_MainCharacterData.roleattribution[fire.pb.attr.AttrType.HP] = hp
    self.m_EventMainCharacterHpMpChange:Bingo()
	if GetBattleManager():IsInBattle() and GetBattleManager():GetMainBattleChar() then
        GetBattleManager():GetMainBattleChar():OnHpChangeOutSideBattle(hp)
	end
end

function MainRoleDataManager:UpdateFubenSetting(fbMap)
    self.m_fubenSettingMap = fbMap
end

--得到角色等级
function MainRoleDataManager:GetMainCharacterLevel()
	return self.m_MainCharacterData.roleattribution[fire.pb.attr.AttrType.LEVEL]
end

function MainRoleDataManager:GetMainCharacterStrength()
	return self.m_MainCharacterData.roleattribution[fire.pb.attr.AttrType.PHFORCE]
end

function MainRoleDataManager:GetMainCharacterVitality()
	return self.m_MainCharacterData.roleattribution[fire.pb.attr.AttrType.ENERGY]
end

function MainRoleDataManager:GetMainCharacterSex()
	return self.m_MainCharacterData.sex
end

--刷新主角数据
--pdata: RoleDetail
function MainRoleDataManager:UpdateMainCharacterData(pdata)
	local bTitleChange=false
	if self.m_MainCharacterData.TitleID~=pdata.title then
        bTitleChange=true
	end
	self.m_MainCharacterData:setData(pdata)
    print(">>>>MainRoleDataManager setData end<<<<<<")

	self.m_fCurrentQili = self.m_MainCharacterData.roleattribution[fire.pb.attr.AttrType.QILIZHI]

    --if GetMainCharacter() then
	if GetMainCharacter() and bTitleChange then
        GetMainCharacter():UpdataTitleTexture()
	end

--    if GetMainCharacter() and GetMainCharacter():GetMoveState() == eMove_Pacing then
-- 		GetMainCharacter():StopPacingMove()
-- 	end

	RoleSkillManager.InitRoleSkillAndAcupoint(self.m_MainCharacterData.school)

    self.m_EventMainCharacterDataChange:Bingo()
end

function MainRoleDataManager:GetMainCharacterShape()
	return self.m_MainCharacterData.shape
end

function MainRoleDataManager:GetMainCharacterCreateShape()
	local createshape = self.m_MainCharacterData.shape%100
	--if createshape == 0 then
	--	createshape = 10
    --end
	return createshape
end

--roleattr: const std:map<int,int>&
function MainRoleDataManager:SetMainBattlerTempAttribute(roleattr)
	--暂存属性
	self.m_MainBattlerTempAttribute = roleattr

    self.m_EventMainBattlerAttributeChange:Bingo()
end

function MainRoleDataManager:GetHPMPStoreByID(index)
	return self.m_mHPMPStore[index] or 0
end

function MainRoleDataManager:GetHPMPStore()
	return self.m_mHPMPStore
end

function MainRoleDataManager:setHPMPStore(index, data)
	self.m_mHPMPStore[index] = data
end

--战斗内刷新人物属性
--attribute: std:map<int,int>
function MainRoleDataManager:UpdateMainBattlerAttribute(attribute)
	for k,v in pairs(attribute) do
        self.m_MainCharacterData.roleattribution[k] = math.floor(v)
	end
    self.m_EventMainBattlerAttributeChange:Bingo()
end

--刷新主角经验
function MainRoleDataManager:UpdateMainCharacterExp(exp)
	self.m_MainCharacterData.exp = exp
	MainRoleExpDlg.updateExp()
end

--主角气血刷新
function MainRoleDataManager:UpdateHpChange(hpChange, hpmaxChange)
	local n = self.m_MainCharacterData.roleattribution[fire.pb.attr.AttrType.UP_LIMITED_HP] + hpmaxChange
    self.m_MainCharacterData.roleattribution[fire.pb.attr.AttrType.UP_LIMITED_HP] = n

	n = self.m_MainCharacterData.roleattribution[fire.pb.attr.AttrType.HP] + hpChange
    self.m_MainCharacterData.roleattribution[fire.pb.attr.AttrType.HP] = n

	if self.m_MainCharacterData.roleattribution[fire.pb.attr.AttrType.UP_LIMITED_HP] > self.m_MainCharacterData.roleattribution[fire.pb.attr.AttrType.MAX_HP] then
        self.m_MainCharacterData.roleattribution[fire.pb.attr.AttrType.UP_LIMITED_HP] = self.m_MainCharacterData.roleattribution[fire.pb.attr.AttrType.MAX_HP]
	end

	if self.m_MainCharacterData.roleattribution[fire.pb.attr.AttrType.HP] < 0 then
		self.m_MainCharacterData.roleattribution[fire.pb.attr.AttrType.HP] = 0
    end

	if self.m_MainCharacterData.roleattribution[fire.pb.attr.AttrType.HP] > self.m_MainCharacterData.roleattribution[fire.pb.attr.AttrType.UP_LIMITED_HP] then
		self.m_MainCharacterData.roleattribution[fire.pb.attr.AttrType.HP] = self.m_MainCharacterData.roleattribution[fire.pb.attr.AttrType.UP_LIMITED_HP]
    end

    self.m_EventMainCharacterHpMpChange:Bingo()
end

--主角法力刷新
function MainRoleDataManager:UpdateMpChange(mpChange, mpmaxChange)
    mpmaxChange = mpmaxChange or 0
	local n = self.m_MainCharacterData.roleattribution[fire.pb.attr.AttrType.MAX_MP] + mpmaxChange
    self.m_MainCharacterData.roleattribution[fire.pb.attr.AttrType.MAX_MP] = n

	n = self.m_MainCharacterData.roleattribution[fire.pb.attr.AttrType.MP] + mpChange
    self.m_MainCharacterData.roleattribution[fire.pb.attr.AttrType.MP] = n

	if self.m_MainCharacterData.roleattribution[fire.pb.attr.AttrType.MP] < 0 then
		self.m_MainCharacterData.roleattribution[fire.pb.attr.AttrType.MP] = 0
    end

	if self.m_MainCharacterData.roleattribution[fire.pb.attr.AttrType.MP] > self.m_MainCharacterData.roleattribution[fire.pb.attr.AttrType.MAX_MP] then
		self.m_MainCharacterData.roleattribution[fire.pb.attr.AttrType.MP] = self.m_MainCharacterData.roleattribution[fire.pb.attr.AttrType.MAX_MP]
    end

    self.m_EventMainCharacterHpMpChange:Bingo()
end

--half表示回复一般魔法
function MainRoleDataManager:MainRoleMpRecover(half)
	if half then
        self.m_MainCharacterData.roleattribution[fire.pb.attr.AttrType.MP] = self.m_MainCharacterData.roleattribution[fire.pb.attr.AttrType.MAX_MP]/2
	else
        self.m_MainCharacterData.roleattribution[fire.pb.attr.AttrType.MP] = self.m_MainCharacterData.roleattribution[fire.pb.attr.AttrType.MAX_MP]
	end
    self.m_EventMainCharacterHpMpChange:Bingo()
end

--主角怒气刷新
function MainRoleDataManager:UpdateSpChange(spChange)
	local n = self.m_MainCharacterData.roleattribution[fire.pb.attr.AttrType.SP] + spChange
    self.m_MainCharacterData.roleattribution[fire.pb.attr.AttrType.SP] = n

	if self.m_MainCharacterData.roleattribution[fire.pb.attr.AttrType.SP] < 0 then
		self.m_MainCharacterData.roleattribution[fire.pb.attr.AttrType.SP] = 0
    end

	if self.m_MainCharacterData.roleattribution[fire.pb.attr.AttrType.SP] > self.m_MainCharacterData.roleattribution[fire.pb.attr.AttrType.MAX_SP] then
		self.m_MainCharacterData.roleattribution[fire.pb.attr.AttrType.SP] = self.m_MainCharacterData.roleattribution[fire.pb.attr.AttrType.MAX_SP]
    end

    self.m_EventMainCharacterHpMpChange:Bingo()
end

function MainRoleDataManager:OnLevelChange(bUp)
	local level = self.m_MainCharacterData.roleattribution[fire.pb.attr.AttrType.LEVEL]
    NewRoleGuideManager.getInstance():GuideLevel(level)

    -- 若满足福利需求，则开启福利
	WelfareManager_OnLeveUpRefreshData()

	--播放升级特效
	if level%10 == 0 then
        local up = level/10
		if gGetGameUIManager() then
			gGetGameUIManager():PlayScreenEffect(up == 1 and 10281 or 10009 + up, 0.5, 0.5)
	    end
	else
        if gGetGameUIManager() and level~=2 then
			gGetGameUIManager():PlayScreenEffect(10280,0.5,0.5)
        end
	end

    if 1 < level and level <= 5 then
        gGetGameApplication():setFirstTimeEnterGameValue(10)
    end

    local mainRole = GetMainCharacter()
	if mainRole and bUp then
        mainRole:PlayEffect(MHSD_UTILS.get_effectpath(11047))
	end

    GetMainCharacter():SetLevel(level)
end

function MainRoleDataManager:GetMainCharacterShapeName()
	local shapeRecord = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(self.m_MainCharacterData.shape)
	if shapeRecord then
		return shapeRecord.shape
	end

	return "newfemale"
end

function MainRoleDataManager:GetCittaAirSeaMaxlimit()
	return 0
end

function MainRoleDataManager:setContribution(contribution)
	self.m_Contribution = contribution
end

function MainRoleDataManager:getContribution()
	return self.m_Contribution
end

--刷新战斗宠物的生命值
function MainRoleDataManager:UpdateBattlePetHpChange(hpChange, hpmaxChange)
    hpmaxChange = hpmaxChange or 0
	MainPetDataManager_UpdateBattlePetHpChange(hpChange, hpmaxChange)
end

--刷新战斗宠物的法力值
function MainRoleDataManager:UpdateBattlePetMpChange(mpChange, mpmaxChange)
    mpmaxChange = mpmaxChange or 0
    MainPetDataManager_UpdateBattlePetMpChange(mpChange, mpmaxChange)
end

function MainRoleDataManager:FirePetNameChange(petkey)
    self.m_EventPetNameChange:Bingo(petkey)
end

function MainRoleDataManager:AddMyPetList(petList, columnid)
    columnid = columnid or 1
	MainPetDataManager_ClearPetList(columnid)
	for _,data in pairs(petList) do
        local petData = stMainPetData:new()
        petData:initWithLua(data)
		MainPetDataManager.getInstance():AddMyPet(petData, columnid)
	end
end

function MainRoleDataManager:SetMaxPetNum(num)
	MainPetDataManager_SetMaxPetNum(num)
end

function MainRoleDataManager:BattlePetIsMyPackPet()
	return MainPetDataManager_BattlePetIsMyPackPet()
end

function MainRoleDataManager:IsMyPetFull()
	return MainPetDataManager_IsMyPetFull()
end

-- 若存在当前展示的宠物，则将宠物加入到添加场景宠物
function MainRoleDataManager:AddScenePetIfShowPetExist()
	MainPetDataManager_AddScenePetIfShowPetExist()
end

function MainRoleDataManager:UpdateGameSetting(newGameSetting)
    self.m_GameSetting = newGameSetting
end

function MainRoleDataManager:GetGameSetting()
	return self.m_GameSetting
end

--state: ePetState
function MainRoleDataManager:SetBattlePetState(state)
	MainPetDataManager_SetBattlePetState(state)
end

--更改了出战宠物，或者让出战宠物休息的话，战斗里的autocommand操作清空
function MainRoleDataManager:SetBattlePet(key)
	if GetBattleManager():IsInBattle() then
        GetBattleManager():ClearPetDefaultSkillID()	--清除宠物默认技能
		self:SetBattlePetState(ePetState_AlreadyFight)
	end
	self.m_MainCharacterData.fightpet = key
    if key == 0 then
	    GetBattleManager():ResetPetAutoOperateCommand()
    end
    self.m_EventBattlePetStateChange:Bingo()
	if GetBattleManager() and GetBattleManager():IsInBattle() then
        BattleManager.SavePetBattleData()
        if GetBattleManager():IsAutoOperate() then
            local dlg = BattleAutoFightDlg.getInstanceNotCreate()
            if dlg then
	            dlg:InitAllSkill()
            end
        end
        self.m_EventMainPetAttributeChange:Bingo()
	end
end

function MainRoleDataManager:ClearBattlePetOfEndBattleScene()
	MainPetDataManager_ClearBattlePetOfEndBattleScene()
end

function MainRoleDataManager:ResetPetState()
	MainPetDataManager_ResetPetState()
end

------------------------------/以下是称谓相关----------------------------------/
--info: TitleInfo
function MainRoleDataManager:AddTitle(info)
    self.m_Titlemap[info.titleid] = info
end

function MainRoleDataManager:RemoveTitle(id)
    for k,v in pairs(self.m_Titlemap) do
        if k == id then
            self.m_Titlemap[k] = nil
            break
        end
    end
end

function MainRoleDataManager:IsPlayerSelf(playerroleid)
	if self.m_MainCharacterData.roleid == playerroleid then
		return true
    end
	return false
end

function MainRoleDataManager:AddTitle(titleid, name, availtime)
    local info = require("protodef.rpcgen.fire.pb.title.titleinfo"):new()
    info.titleid = titleid
    info.name = name
    info.availtime = availtime
    self.m_Titlemap[titleid] = info
end

function MainRoleDataManager:UpdateCurTitle(roleid, titleid, titlename)
    if self:IsPlayerSelf(roleid) then
        if titleid < 0 and self:GetCurTitleID() < 0 then
            return
        end
        
        self.m_MainCharacterData.TitleID = titleid
        GetMainCharacter():SetTitle(titleid,titlename)
        self.m_EventMainCharacterDataChange:Bingo()
    else
        if gGetScene() then
            local pCurCharacter = gGetScene():FindCharacterByID(roleid)
            if pCurCharacter then
                if titleid < 0 and pCurCharacter:GetTitleID() < 0 then
                    return
                end
                pCurCharacter:SetTitle(titleid, titlename)
            end
        end
    end
end

function MainRoleDataManager:UnloadCurTitle(roleid)
    self:UpdateCurTitle(roleid, -1, "")
end

function MainRoleDataManager:GetCurTilte()
    local found = false
    for k,v in pairs(self.m_Titlemap) do
        if k == self.m_MainCharacterData.TitleID then
            found = true
            break
        end
    end
    if not found then
        return ""
    end

	if self.m_MainCharacterData.TitleID == -1 then
		return ""
    end

	if self.m_Titlemap[self.m_MainCharacterData.TitleID].name == "" then
        local title = BeanConfigManager.getInstance():GetTableByName("title.ctitleconfig"):getRecorder(self.m_MainCharacterData.TitleID)
		if title then
			return title.titlename
        end
	end
    
	return self.m_Titlemap[self.m_MainCharacterData.TitleID].name
end

function MainRoleDataManager:GetCurTitleID()
	return self.m_MainCharacterData.TitleID
end

function MainRoleDataManager:HasTitles()
    return TableUtil.tablelength(self.m_Titlemap) > 0
end

--learnformation: std:map<int, fire:pb:FormBean>
function MainRoleDataManager:SetMainCharacterLearnFormation(learnformation)
	self.m_VecLearnformation = {}
    for i=1,10 do
        if learnformation[i] then
            table.insert(self.m_VecLearnformation, learnformation[i])
        else
            local formation = {}
            formation.activetimes = 0
            formation.level = 0
            formation.exp = 0
            table.insert(self.m_VecLearnformation, formation)
        end
    end
    FormationManager.InitFormation()
end

--idx从1开始
function MainRoleDataManager:getFormation(i)
	return self.m_VecLearnformation[i]
end

function MainRoleDataManager:GetMainCharacterAttribute(attributeid)
    for k,v in pairs(self.m_MainCharacterData.roleattribution) do
        if k == attributeid then
            return self.m_MainCharacterData.roleattribution[attributeid]
        end
    end
    return -1
end

function MainRoleDataManager:GetYuanBaoNumber()
	return self.m_nYuanBaoNumber
end

function MainRoleDataManager:GetUseQianNengGuoNum()
    return self.m_useQianNengGuoNum
end

function MainRoleDataManager:setUseQianNengGuoNum(num)
    self.m_useQianNengGuoNum = num
end

function MainRoleDataManager:SetYuanBaoNumber(nNumber) --设置符石数
	self.m_nYuanBaoNumber=nNumber
    self.m_EventYuanBaoNumberChange:Bingo()
end

function MainRoleDataManager:SetBindYuanBaoNuber(nNumber) --设置符石数
	self.m_nBindYuanBaoNumber=nNumber
    self.m_EventBindYuanBaoNumberChange:Bingo()
end

function MainRoleDataManager:SetTotalRechargeYuanBaoNumber(nNumber) --设置总充值符石数
	self.m_nTotalRechargeYuanBaoNumber = nNumber
end

function MainRoleDataManager:GetBindYuanBaoNumber()
	return self.m_nBindYuanBaoNumber
end

function MainRoleDataManager:GetTotalYuanBaoNumber()
	return self.m_nYuanBaoNumber + self.m_nBindYuanBaoNumber
end

function MainRoleDataManager:GetTotalRechargeYuanBaoNumber()
	return self.m_nTotalRechargeYuanBaoNumber
end

function MainRoleDataManager:GetBuyYuanBaoDefaultPrice()
	return self.m_nBuyYuanBaoDefaultPrice
end

function MainRoleDataManager:GetSellYuanBaoDefaultPrice()
	return self.m_nSellYuanBaoDefaultPrice
end

function MainRoleDataManager:SetBuyYuanBaoDefaultPrice(price)
	self.m_nBuyYuanBaoDefaultPrice = price
end

function MainRoleDataManager:SetSellYuanBaoDefaultPrice(price)
	self.m_nSellYuanBaoDefaultPrice = price
end

function MainRoleDataManager:UpdateTitleMap(Stitlemap)
	self.m_Titlemap = Stitlemap
end

function MainRoleDataManager:GetTitleMap()
	return self.m_Titlemap
end

function MainRoleDataManager:GetAllTitleID()
    local vecTitleID = {}
    for k,v in pairs(self.m_Titlemap) do
        table.insert(vecTitleID, v.titleid)
    end
    return vecTitleID
end

--当前血量是否是满血的80%
function MainRoleDataManager:IsHpEightyPercentFull()
	local curHp = self.m_MainCharacterData.roleattribution[fire.pb.attr.AttrType.HP]
	local maxHp = self.m_MainCharacterData.roleattribution[fire.pb.attr.AttrType.MAX_HP]

	if curHp >= (maxHp * 0.8) then
		return true
    end

	return false
end

--玩家是否受伤
function MainRoleDataManager:IsMainCharacterInjured()
	local ulHp = self.m_MainCharacterData.roleattribution[fire.pb.attr.AttrType.UP_LIMITED_HP]
	local maxHp = self.m_MainCharacterData.roleattribution[fire.pb.attr.AttrType.MAX_HP]

	if ulHp ~= maxHp then
		return true
    end
	return false
end

function MainRoleDataManager:GetMainCharacterData()
	return self.m_MainCharacterData
end

function MainRoleDataManager:GetMainBattlerTempAttribute()
	return self.m_MainBattlerTempAttribute
end

function MainRoleDataManager:GetFossicNpc()
	return self.m_FossicNpc
end

--得到主角的气力值
function MainRoleDataManager:GetMainCharacterQiLi()
	return self.m_MainCharacterData.roleattribution[fire.pb.attr.AttrType.QILIZHI]
end

function MainRoleDataManager:GetMainCharacterActivity() --得到主角当前活跃度
	return self.m_MainCharacterData.roleattribution[fire.pb.attr.AttrType.ACTIVENESS]
end

--刷新气力值
function MainRoleDataManager:UpdateMainCharacterQili(qili)
	self.m_MainCharacterData.roleattribution[fire.pb.attr.AttrType.QILIZHI] = qili
	self.m_fCurrentQili = qili
    self.m_EventMainCharacterQiLiChange:Bingo()
end

--添加跟随npc
function MainRoleDataManager:AddFollowNpc(npcid)
	local basedata = BeanConfigManager.getInstance():GetTableByName("npc.cnpcconfig"):getRecorder(npcid)
	if not basedata then
 		return
    end
 
	if basedata.npctype ~= eNpcFollow then
 		return
    end

	table.insert(self.m_sFollowNpc, npcid)

	local follownpcnum = #self.m_sFollowNpc

	gGetScene():AddSceneFollowNpc(npcid, follownpcnum)
end

--删除跟随npc
function MainRoleDataManager:RemoveFollowNpc(npcid)
    if npcid == 0 then
        if #self.m_sFollowNpc > 0 then
            npcid = self.m_sFollowNpc[1]
        end
    end
    for k,v in pairs(self.m_sFollowNpc) do
        if v == npcid then
            gGetScene():RemoveSceneObjectByID(eSceneObjFollowNpc,npcid)
            table.remove(self.m_sFollowNpc, k)
            break
        end
    end
end

function MainRoleDataManager:AddSceneFollowNpcOnMapChange()
	for i,npcid in pairs(self.m_sFollowNpc) do
		gGetScene():AddSceneFollowNpc(npcid, i)
	end
end

function MainRoleDataManager:GetMainCharacterID()
	return self.m_MainCharacterData.roleid
end

function MainRoleDataManager:GetMainCharacterShowpet()
	return self.m_MainCharacterData.showpet
end

function MainRoleDataManager:SetMainCharacterShowpet(showpet)
	self.m_MainCharacterData.showpet = showpet
end

function MainRoleDataManager:GetMainCharacterName()
	return self.m_MainCharacterData.strName
end

function MainRoleDataManager:GetMainCharacterSchoolName()
	return self.m_MainCharacterData.schoolName
end

function MainRoleDataManager:GetMainCharacterSchoolID()
	return self.m_MainCharacterData.school
end

function MainRoleDataManager:GetMainCharacterExperience()
	return self.m_MainCharacterData.exp
end

function MainRoleDataManager:GetMainCharacterFightpet()
	return self.m_MainCharacterData.fightpet
end

function MainRoleDataManager:SetMainCharacterFightpet(fightpet)
	self.m_MainCharacterData.fightpet = fightpet
end

function MainRoleDataManager:FirePetDataChange(petkey)
    self.m_EventPetDataChange:Bingo(petkey)
end

--not used
function MainRoleDataManager:addTaskShowNpc(nTaskId, vTaskShowNpc)
    if self.m_MapTaskShowNpc[nTaskId] then
        return
    end
    self.m_MapTaskShowNpc[nTaskId] = vTaskShowNpc

    for _,v in pairs(vTaskShowNpc) do
        self:addTaskShowNpcWithId(v)
    end
end

--not used
function MainRoleDataManager:deleteTaskShowNpc(nTaskId)
	for k,pvNpcId in pairs(self.m_MapTaskShowNpc) do
	    if k == nTaskId then
             for _,nNpcId in pairs(pvNpcId) do
                local bHaveInNextTask = self:isNextTaskHaveNpcId(nTaskId, nNpcId)
			    if not bHaveInNextTask then
                    gGetScene():deleteSceneTaskShowNpc(nNpcId)
			    end
             end
             self.m_MapTaskShowNpc[k] = nil
             break
        end
	end
end

function MainRoleDataManager:getNextTaskId(nTaskId)
	local taskInfoTable = GameTable.mission.GetCMainMissionInfoTableInstance():getRecorder(nTaskId)
	if taskInfoTable.id == -1 then
        return -1
	end

	if taskInfoTable.PostMissionList.size() == 1 then
        return taskInfoTable.PostMissionList[0]
	end

	local nMyRoleId = self:GetMainCharacterCreateShape()
	for nIndex = 0, taskInfoTable.PostMissionList.size()-1 do
        local nTaskIdNext = taskInfoTable.PostMissionList[nIndex]
		local taskInfoTable2 = GameTable.mission.GetCMainMissionInfoTableInstance():getRecorder(nTaskIdNext)
		if taskInfoTable2.id ~= -1 then
            for nIndexRoleId = 0, taskInfoTable2.RequestRoleIDList.size()-1 do
                local nRoleId = taskInfoTable2.RequestRoleIDList[nIndexRoleId]
				if nRoleId == nMyRoleId then
                    return taskInfoTable2.id
				end
			end
		end
	end
	return -1
end

function MainRoleDataManager:isNextTaskHaveNpcId(nTaskId, nNpcId)
	local nTaskIdNext = self:getNextTaskId(nTaskId)
	if nTaskIdNext == -1 then
        return false
	end

	local taskInfoTable2 = GameTable.mission.GetCMainMissionInfoTableInstance():getRecorder(nTaskIdNext)
	if taskInfoTable2.id == -1 then
        return false
	end

	for nIndex=0, taskInfoTable2.vTaskShowNpc.size()-1 do
		local nNpcId2 = taskInfoTable2.vTaskShowNpc[nIndex]
		if nNpcId == nNpcId2 then
			return true
		end
	end
	return false
end

function MainRoleDataManager:addTaskShowNpcWithId(nNpcId)
	local nCurMapId = gGetScene():GetMapID()
	local basedata = BeanConfigManager.getInstance():GetTableByName("npc.cnpcconfig"):getRecorder(nNpcId)
	if not basedata then
		return false
    end

	if basedata.npctype ~= eNpcTaskShow then
		return false
    end

	if nCurMapId ~= basedata.mapid then
		return false
    end

	gGetScene():addSceneTaskShowNpc(nNpcId)
	return true
end

function MainRoleDataManager:addTaskShowNpcAll()
    for _,pvNpcId in pairs(self.m_MapTaskShowNpc) do
        for _,nNpcId in pairs(pvNpcId) do
            self:addTaskShowNpcWithId(nNpcId)
        end
    end
end

function MainRoleDataManager:deleteTaskShowNpcAll()
    for _,pvNpcId in pairs(self.m_MapTaskShowNpc) do
        for _,nNpcId in pairs(pvNpcId) do
            gGetScene():deleteSceneTaskShowNpc(nNpcId)
        end
    end

	self.m_MapTaskShowNpc = {}
end

function MainRoleDataManager:getTitleTime(id)
    for _,v in pairs(self.m_Titlemap) do
        if v.titleid == id then
            return v.availtime
        end
    end
	return 0
end

function MainRoleDataManager:setRoleAttrFloatValue(key, data)
    self.m_MainCharacterData:setFloatValue(key, data)
end

function MainRoleDataManager:refreshRoleData(p)
    local bLevelChange = false
    local bLevelUpChange = false
	local bPointChange = false --???????

	if gGetDataManager() == nil then
        return
    end
	
    local data = self.m_MainCharacterData
    for k,v in pairs(p.datas) do
		--new add , 直接存储浮点值
		data.roleattrFloat[k] = v

        if GetBattleManager() and not GetBattleManager():IsInBattle() then
            local oldvalue
            if data.roleattribution[k] then
                oldvalue = data.roleattribution[k]
			else
				oldvalue = 0
			end
            local delta = math.floor(v - oldvalue)
            if delta > 0 then
                local conf = GameTable.effect.GetCEffectConfigTableInstance():getRecorder(k)
                if conf.id ~= -1 and conf.xianshi == 1 then
                    GetMainCharacter():AddPopoMsg(conf.effectid, delta, conf.color, conf.order)
                end
			elseif delta < 0 then
				local conf = GameTable.effect.GetCEffectConfigTableInstance():getRecorder(k)
				if conf.id ~= -1 and conf.xianshi == 1 then 
					GetMainCharacter():AddPopoMsgReduce(conf.reduceeffectid, delta, conf.reducecolor, conf.order)
				end
			end

        end

		--等级改变特殊处理
		if k == fire.pb.attr.AttrType.LEVEL then
			bLevelChange = true
			local curlevel = v
			if curlevel > data.roleattribution[fire.pb.attr.AttrType.LEVEL] then
                bLevelUpChange = true
            end
			if curlevel > 10 and (curlevel - data.roleattribution[fire.pb.attr.AttrType.LEVEL]) == 1 then
				GetCTipsManager():AddMessageTipById(140406)
			end

			data.roleattribution[k] = math.floor(curlevel)

            NotifyManager.EventLevelChange(curlevel)
			YangChengListDlg.notifySkillAdd()
			HuoDongManager.SendList()

            if MT3.ChannelManager:isDefineSDK() then
		        if MT3.ChannelManager:IsAndroid() then
                    MT3.ChannelManager:onRecordRoleInf()
                end
            end

            local clevel = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(351).value)
            if curlevel == clevel then
                gGetGameApplication():CallEvaluate()
            end

		elseif k == fire.pb.attr.AttrType.ENERGY then  --当前活力
			local curEnegy = v
			local lastEnegy = data.roleattribution[fire.pb.attr.AttrType.ENERGY]
			local maxEnegy = data.roleattribution[fire.pb.attr.AttrType.ENLIMIT]

			local cfg = GameTable.common.GetCCommonTableInstance():getRecorder(164)
			local xishu = tonumber(cfg.value)
			if curEnegy > maxEnegy * xishu then
				YangChengListDlg.notifyHuoyueduAdd()
			else
				YangChengListDlg.dealwithHuoyueduChange()
			end

			data.roleattribution[k] = math.floor(curEnegy)
		end
 
        if k == fire.pb.attr.AttrType.PHY_CRIT_PCT
          or k == fire.pb.attr.AttrType.MAGIC_CRIT_PCT
          or k == fire.pb.attr.AttrType.HEAL_CRIT_PCT then

            data.roleattribution[k] = math.floor(v * 100 + 0.5)
        else
            data.roleattribution[k] = math.floor(v)
        end

		
		if k == fire.pb.attr.AttrType.QILIZHI then
			gGetDataManager():UpdateMainCharacterQili(v)
        end

		if k == fire.pb.attr.AttrType.POINT then
			bPointChange = true
			local toAddPoint = v

			local xidian = toAddPoint == data.roleattribution[fire.pb.attr.AttrType.LEVEL] * 5

			if bLevelChange and toAddPoint > 0 or xidian then
				YangChengListDlg.nofityRolePointAdd()
			else
				YangChengListDlg.dealwithRoleAddpointStatus()
			end
		end
    end

	if bLevelChange then
		local level = data.roleattribution[fire.pb.attr.AttrType.LEVEL]
		data.nexp = BeanConfigManager.getInstance():GetTableByName("role.cresmoneyconfig"):getRecorder(level).nextexp
		
		TaskHelper.SendIsHavePingDingAnBangTask(0)
	end

	self.m_EventMainCharacterDataChange:Bingo()

	if GetBattleManager() and GetBattleManager():IsInBattle() and not gGetGameApplication():IsInLittleGame() then
		self.m_EventMainBattlerAttributeChange:Bingo()
	end

	if bLevelChange then
        --TODO 干嘛的
		gGetDataManager():OnLevelChange(bLevelUpChange)
        LoginRewardManager.UpdateLevelShowDlg()
	end

	if bPointChange then
		CharacterPropertyAddPtrDlg.getInstanceExistAndShow()
		AddPointManager.getInstanceAndUpdate()
	end
end

function MainRoleDataManager:update(nDt)
    local nRoleLevel = gGetDataManager():GetMainCharacterLevel()
    if nRoleLevel >= 21 then
        return 
    end
    local bInbattle = GetBattleManager():IsInBattle()
    local nnNowTime = gGetServerTime()
    local nOneDayTime = 24*60*60*1000
    if nnNowTime <= nOneDayTime then
        return
    end
    local rolePos = GetMainCharacter():GetLocation()
    if  rolePos.x==self.m_posPreX and 
        rolePos.y==self.m_posPreY and 
        bInbattle == false
        then
            local nNoMoveTime = nnNowTime-self.m_nnTimePre
            if self.m_nnTimePre~=-1 and nNoMoveTime > self.m_nCheckMoveTime then
                self:sendProtocolToOffline()
                self.m_nnTimePre = -1
                self.m_posPreX =-1
                self.m_posPreY = -1
            end
    else
        self.m_nnTimePre = nnNowTime
        self.m_posPreX = rolePos.x
        self.m_posPreY = rolePos.y
    end
end

function MainRoleDataManager:sendProtocolToOffline()
    local p = require "protodef.fire.pb.game.cnooperationkick":new()
	require "manager.luaprotocolmanager":send(p)
end

------------------------------------------------------------------
--call from c++
function MainRoleData_getNumValue(name)
    if _instance and _instance.m_MainCharacterData[name] then
        return _instance.m_MainCharacterData[name]
    end
    return 0
end

function MainRoleData_getAttr(attrType)
    if _instance and _instance.m_MainCharacterData.roleattribution[attrType] then
        return _instance.m_MainCharacterData.roleattribution[attrType]
    end
    return 0
end

function MainRoleData_getStrValue(name)
    if _instance and _instance.m_MainCharacterData[name] then
        return _instance.m_MainCharacterData[name]
    end
    return ""
end

function MainRoleDataManager.SetLastVisitNpcID(npcID)
    if _instance then
	    _instance.m_iLastVisiteNpcID = npcID
    end
end

function MainRoleDataManager.SetMainCharacterShape(shapeid)
    if _instance then
	    _instance.m_MainCharacterData.shape = shapeid
    end
end

function MainRoleDataManager.GetCurTilte_()
    if _instance then
        return _instance:GetCurTilte()
    end
    return ""
end

function MainRoleData_AddSceneFollowNpcOnMapChange()
    if _instance then
        _instance:AddSceneFollowNpcOnMapChange()
    end
end

function MainRoleData_addTaskShowNpcAll()
    if _instance then
        _instance:addTaskShowNpcAll()
    end
end

--这里战斗宠物属性附加值
function MainRoleData_UpdateMainPetAttribute(attribute)
    if _instance then
	    for k,v in pairs(attribute) do
            MainPetDataManager_UpdateBattlePetAttribute(k, v)
	    end
        _instance.m_EventMainPetAttributeChange:Bingo()
    end
end

function MainRoleData_UpdateMainBattlerAttribute(attribute)
    if _instance then
        _instance:UpdateMainBattlerAttribute(attribute)
    end
end

function MainRoleData_UpdateSpChange(spChange)
    if _instance then
        _instance:UpdateSpChange(spChange)
    end
end

function MainRoleData_UpdateMpChange(mpChange, mpmaxChange)
    if _instance then
        _instance:UpdateMpChange(mpChange, mpmaxChange)
    end
end

function MainRoleData_UpdateHpChange(hpChange, hpmaxChange)
    if _instance then
        hpmaxChange = hpmaxChange or 0
        _instance:UpdateHpChange(hpChange, hpmaxChange)
    end
end

function MainRoleData_PostBattlePetStateChangeEvent()
    if _instance then
        _instance.m_EventBattlePetStateChange:Bingo()
    end
end

function MainRoleData_GetBattlePetID()
    if _instance then
        return _instance:GetBattlePetID()
    end
    return 0
end

function MainRoleData_SetBattlePet(key)
    if _instance then
        _instance:SetBattlePet(key)
    end
end

return MainRoleDataManager
