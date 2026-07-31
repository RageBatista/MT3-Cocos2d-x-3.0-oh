require "utils.class"

------------------------------------------------------------------
stCharacterChangeEquipData = class("stCharacterChangeEquipData")

function stCharacterChangeEquipData:init()
    self.colorTemplate = 1  --颜色模板
	self.weaponID = 0       --武器造型ID
	self.hatID = 0          --头饰ID
	self.weaponColor = 0
end

------------------------------------------------------------------
--玩家主角数据结构
stMainCharacterData = class("stMainCharacterData")

function stMainCharacterData:init()
    self.roleid            = 0 --int64_t  ID
	self.strName           = "" --std::wstring  名字
	self.race              = 0 --int
	self.shape             = 0 --int
	self.school            = 0 --int
	self.camp              = 0 --int
	self.schoolName        = "" --std::wstring
	self.schoolSkill       = "" --std::wstring
	self.sex               = eSexMale --eSexType  性别
	self.roleattribution   = {} --std::map<int, int> 主角属性
	self.TitleID           = 0 --int  称谓iD
	self.roleattrFloat     = {} --std::map<int, float> 玩家属性浮点值， 用于加点
	self.mapRoleScore      = {} --std::map<int, int> 记录各种分数
	self.exp               = 0 --int64_t  经验
	self.nexp              = 0 --int64_t  升级 需要经验
	self.fightpet          = 0 --int  当前战斗宠物
	self.showpet           = 0 --int  当前展示宠物
	self.servantid         = 0 --int
	self.masterid          = 0 --int64_t
	self.footprint         = 0 --int
	self.automovepathid    = 0 --int--巡游路径ID

	----------------------------------------------------------------------- 加点相关
	self.pointSchemeID     = 0 --int 当前加点方案
	self.pointSchemeChangeTimes = 0 --int 方案切换次数
	self.pointScheme       = {} --std::map<int, int > 潜能， 即方案分配的 剩余 点数
	self.cons              = 0 --int 体质
	self.iq                = 0 --int 魔力
	self.str               = 0 --int 力量
	self.endu              = 0 --int 耐力
	self.agi               = 0 --int 敏捷
	self.cons_save         = {} --std::vector<int> 已分配体质
	self.iq_save           = {} --std::vector<int> 已分配魔力
	self.str_save          = {} --std::vector<int> 已分配力量
	self.endu_save         = {} --std::vector<int> 耐力
	self.agi_save          = {} --std::vector<int> 敏捷
	self.totalScore        = 0 --int
	self.equipScore        = 0 --int
	self.manyPetScore      = 0 --int
	self.petScore          = 0 --int
	self.levelScore        = 0 --int
	self.xiulianScore      = 0 --int
	self.roleScore         = 0 --int
	self.skillScore        = 0 --int

	self.EquipData = stCharacterChangeEquipData.new()
end

--fire::pb::RoleDetail
function stMainCharacterData:setData(data)
    self.roleid = data.roleid
	self.strName = data.rolename

	--角色造型
	print(">>>>角色id: "..tostring(self.roleid).." >>data.shape: "..tostring(data.shape))
	if data.shape <=20 then
		self.shape = 1010100+data.shape
	elseif data.shape <300 then
		self.shape = 2010100+data.shape%100
	else
		self.shape = data.shape
    end

	print(">>>>角色id: "..tostring(self.roleid).." >>造型id: "..tostring(self.shape))

	self.sex = GetRoleSex(data.shape) --eSexFemale
	self.school = data.school
    self.schoolName = GetSchoolName(self.school)
	self.TitleID = data.title

	self.roleattribution[fire.pb.attr.AttrType.CONS] = math.floor(data.bfp.cons)
	self.roleattribution[fire.pb.attr.AttrType.IQ] = math.floor(data.bfp.iq)
	self.roleattribution[fire.pb.attr.AttrType.STR] = math.floor(data.bfp.str)
	self.roleattribution[fire.pb.attr.AttrType.ENDU] = math.floor(data.bfp.endu)
	self.roleattribution[fire.pb.attr.AttrType.AGI] = math.floor(data.bfp.agi)
	self.roleattribution[fire.pb.attr.AttrType.HP] = math.floor(data.hp)
	self.roleattribution[fire.pb.attr.AttrType.MP] = math.floor(data.mp)
	self.roleattribution[fire.pb.attr.AttrType.ATTACK] = math.floor(data.damage)
	self.roleattribution[fire.pb.attr.AttrType.DEFEND] = math.floor(data.defend)
	self.roleattribution[fire.pb.attr.AttrType.HIT_RATE] = math.floor(data.hit)
	self.roleattribution[fire.pb.attr.AttrType.DODGE_RATE] = math.floor(data.dodge)
	self.roleattribution[fire.pb.attr.AttrType.SPEED] = math.floor(data.speed)
	self.roleattribution[fire.pb.attr.AttrType.SEAL] = math.floor(data.seal)
	self.roleattribution[fire.pb.attr.AttrType.UNSEAL] = math.floor(data.unseal)
	self.roleattribution[fire.pb.attr.AttrType.PHY_CRITC_LEVEL] = math.floor(data.phy_critc_level)
	self.roleattribution[fire.pb.attr.AttrType.ANTI_PHY_CRITC_LEVEL] = math.floor(data.anti_phy_critc_level)
	self.roleattribution[fire.pb.attr.AttrType.MAGIC_CRITC_LEVEL] = math.floor(data.magic_critc_level)
	self.roleattribution[fire.pb.attr.AttrType.ANTI_MAGIC_CRITC_LEVEL] = math.floor(data.anti_magic_critc_level)
    self.roleattribution[fire.pb.attr.AttrType.HEAL_CRIT_PCT] = math.floor(data.heal_critc_pct * 100 + 0.5)
    self.roleattribution[fire.pb.attr.AttrType.HEAL_CRIT_LEVEL] = math.floor(data.heal_critc_level)
    self.roleattribution[fire.pb.attr.AttrType.ANTI_CRIT_LEVEL] = math.floor(data.anti_critc_level)
    self.roleattribution[fire.pb.attr.AttrType.PHY_CRIT_PCT] = math.floor(data.phy_critc_pct * 100 + 0.5)
    self.roleattribution[fire.pb.attr.AttrType.MAGIC_CRIT_PCT] = math.floor(data.magic_critc_pct * 100 + 0.5)
	self.roleattribution[fire.pb.attr.AttrType.MAX_HP] = math.floor(data.maxhp)
	self.roleattribution[fire.pb.attr.AttrType.MAX_MP] = math.floor(data.maxmp)
	self.roleattribution[fire.pb.attr.AttrType.MAX_SP] = math.floor(data.maxsp)
	self.roleattribution[fire.pb.attr.AttrType.SP] = math.floor(data.sp)
	self.roleattribution[fire.pb.attr.AttrType.UP_LIMITED_HP] = math.floor(data.uplimithp)
	self.roleattribution[fire.pb.attr.AttrType.ENERGY] = math.floor(data.energy)
	self.roleattribution[fire.pb.attr.AttrType.ENLIMIT] = math.floor(data.enlimit)
	--self.roleattribution[fire.pb.attr.AttrType.PHFORCE] = data.phyforce
	--self.roleattribution[fire.pb.attr.AttrType.PFLIMIT] = data.pflimit
	self.roleattribution[fire.pb.attr.AttrType.MAGIC_ATTACK] = math.floor(data.magicattack)
	self.roleattribution[fire.pb.attr.AttrType.MAGIC_DEF] = math.floor(data.magicdef)
	--self.roleattribution[fire.pb.attr.AttrType.RENQI] = data.renqi
	self.roleattribution[fire.pb.attr.AttrType.SCHOOLFUND] = math.floor(data.schoolvalue)
	self.roleattribution[fire.pb.attr.AttrType.LEVEL] = math.floor(data.level)
	self.roleattribution[fire.pb.attr.AttrType.ACTIVENESS] = math.floor(data.activeness)
	self.roleattribution[fire.pb.attr.AttrType.SEAL] = math.floor(data.seal)
	self.roleattribution[fire.pb.attr.AttrType.MEDICAL] = math.floor(data.medical)
	self.roleattribution[fire.pb.attr.AttrType.KONGZHI_MIANYI] = math.floor(data.kongzhimianyi)
	self.roleattribution[fire.pb.attr.AttrType.KONGZHI_JIACHENG] = math.floor(data.kongzhijiacheng)
	self.roleattribution[fire.pb.attr.AttrType.ZHILIAO_JIASHEN] = math.floor(data.zhiliaojiashen)	--990
	self.roleattribution[fire.pb.attr.AttrType.WULI_DIKANG] = math.floor(data.wulidikang)
	self.roleattribution[fire.pb.attr.AttrType.FASHU_DIKANG] = math.floor(data.fashudikang)
	self.roleattribution[fire.pb.attr.AttrType.FASHU_CHUANTOU] = math.floor(data.fashuchuantou)
	self.roleattribution[fire.pb.attr.AttrType.WULI_CHUANTOU] = math.floor(data.wulichuantou)

   -- self.footprint = data.footlogoid

	self.exp = data.exp
	self.nexp = BeanConfigManager.getInstance():GetTableByName("role.cresmoneyconfig"):getRecorder(data.level).nextexp
	--self.servantid = data.servantid
	self.fightpet = data.petindex
	self.showpet = data.showpet
	self.masterid = data.masterid
	self.pointScheme = data.point
	self.pointSchemeChangeTimes = data.schemechanges
	self.pointSchemeID = data.pointscheme
	self.cons = data.bfp.cons			--体质
	self.iq   = data.bfp.iq				--魔力
	self.str  = data.bfp.str			--力量
	self.endu = data.bfp.endu			--耐力
	self.agi  = data.bfp.agi			--敏捷

    for _,v in pairs(data.bfp.cons_save) do
        table.insert(self.cons_save, v)
    end

    for _,v in pairs(data.bfp.iq_save) do
        table.insert(self.iq_save, v)
    end

    for _,v in pairs(data.bfp.str_save) do
        table.insert(self.str_save, v)
    end

    for _,v in pairs(data.bfp.endu_save) do
        table.insert(self.endu_save, v)
    end

    for _,v in pairs(data.bfp.agi_save) do
        table.insert(self.agi_save, v)
    end
end

function stMainCharacterData:GetValue(key)
    return self.roleattribution[key] or 0
end

function stMainCharacterData:GetFloatValue(key)
    return self.roleattrFloat[key] or 0
end

function stMainCharacterData:setFloatValue(key, data)
	self.roleattrFloat[key] = data
end

function stMainCharacterData:GetScoreValue(key)
    return self.mapRoleScore[key] or 0
end


------------------------------------------------------------------

scene_util = {}

function scene_util.GetPetNameColor(colour)
	local ret = string.format("[colrect='tl:%s tr:%s bl:%s br:%s']", "ffffffff", "ffffffff", "ffffffff", "ffffffff")
	return ret
end

function scene_util.GetPetColour(colour)
	local ret = "ffffffff"
	return ret
end

return scene_util
