------------------------------------------------------------------
-- ԭ C++ stMainPetData ��
------------------------------------------------------------------

--	key,
--	baseid,             -- baseID������ID��
--	name,               -- ����
--	battlestate,        -- ս������
--	scale,              -- scale��С
--	kind,               -- ���ͣ�1Ұ����2������3���죬4���� PetTypeEnum: 
--	colour,             -- ��ɫֵ��1����7
--	growrate,           -- �ɳ���
--	petattribution,     -- ��������
--	petskilllist,       -- ���＼��
--	petskillexpires,    -- ���＼�ܣ�key=����id��value=ʱ�޼��ܵĵ���ʱ�䣬��ʱ�����Ƶļ���ֵΪ-1
--	curexp,             -- ��ǰ����
--	nextexp,            -- �������辭��
--	bLock,
--	bBind,
--	flag,               -- �����־ 1= ������2 = ��
--	timeout,            -- �����ʱ����������ʱ�䣨���룩
--	ownerid,            -- ����id
--	ownername,          -- ������
--	rank,               -- ���а�����
--	shape,              -- ��������
--	starId,
--	practiseTimes,      -- ��ǰʣ���ѵ������
--	zizhi,              -- ѵ����õ���δ���������
--	genguadd,
--	skill_grid,
--	score,              -- ����
--	basescore,          -- һ����������
--	petdye,             -- ����Ⱦɫ
--	initbfp,            -- �Զ�����ĵ���
--	autoBfp,            -- ���õļӵ㷽��
--	pointresetcount,    -- ����ӵ�����ô���
--	aptaddcount,        -- ������������
--	growrateaddcount,   -- �ɳ�����������
--	washcount,
--	shenshouinccount,   -- �������ɴ���
--	marketfreezeexpire, -- ��̯�����ֹʱ��,Ĭ��0������

-------------------------------------------------------------

stMainPetData = {}
stMainPetData.__index = stMainPetData

function stMainPetData:new()
    local self = {}
    setmetatable(self, stMainPetData)
    self:init()
    return self
end

function stMainPetData:init()
    self.key = 0
    self.baseid = 0
    self.name = ""
    self.battlestate = 0
    self.scale = 0
    self.kind = 0
    self.colour = eColourNull
    self.growrate = 0
    self.petattribution = {}
    self.petskilllist = {}
    self.petskillexpires = {}
    self.curexp = 0
    self.nextexp = 0
    self.bLock = false
    self.bBind = false
    self.flag = 0
    self.timeout = 0
    self.ownerid = 0
    self.ownername = ""
    self.rank = 0
    self.shape = 0
    self.starId = 0
    self.practiseTimes = 0
    self.zizhi = {}
    self.genguadd = 0
    self.skill_grid = 0
    self.score = 0
    self.basescore = 0
    self.petdye1 = 0
    self.petdye2 = 0
    self.initbfp = {}
    self.autoBfp = {}
    self.pointresetcount = 0
    self.aptaddcount = 0
    self.growrateaddcount = 0
    self.washcount = 0
    self.shenshouinccount = 0
    self.marketfreezeexpire = 0
    self.petinternallist = {}
end

function stMainPetData:initWithLua(data)
    self.key = data.key
    self.baseid = data.id
    self.name = data.name
    self.battlestate = 0
    self.scale = data.scale
    self.kind = data.kind
    self.colour = data.colour
    self.growrate = data.growrate / 1000.0

    self.petattribution = {}
    self.petattribution[1240] = data.qianye
    self.petattribution[fire.pb.attr.AttrType.LEVEL] = data.level                   -- �ȼ�
    self.petattribution[fire.pb.attr.AttrType.PET_FIGHT_LEVEL] = data.uselevel      -- ��ս�ȼ�
    self.petattribution[fire.pb.attr.AttrType.HP] = data.hp                         -- ��ǰ����
    self.petattribution[fire.pb.attr.AttrType.MAX_HP] = data.maxhp                  -- �������
    self.petattribution[fire.pb.attr.AttrType.MP] = data.mp                         -- ��ǰ����
    self.petattribution[fire.pb.attr.AttrType.MAX_MP] = data.maxmp                  -- �����
    self.petattribution[fire.pb.attr.AttrType.ATTACK] = data.attack                 -- ����
    self.petattribution[fire.pb.attr.AttrType.DEFEND] = data.defend                 -- ����
    self.petattribution[fire.pb.attr.AttrType.SPEED] = data.speed                   -- �ٶ�
    self.petattribution[fire.pb.attr.AttrType.MAGIC_ATTACK] = data.magicattack      -- ��������
    self.petattribution[fire.pb.attr.AttrType.MAGIC_DEF] = data.magicdef            -- ��������
    self.petattribution[fire.pb.attr.AttrType.CONS] = data.bfp.cons                 -- ����
    self.petattribution[fire.pb.attr.AttrType.IQ] = data.bfp.iq                     -- ����
    self.petattribution[fire.pb.attr.AttrType.STR] = data.bfp.str                   -- ����
    self.petattribution[fire.pb.attr.AttrType.ENDU] = data.bfp.endu                 -- ����
    self.petattribution[fire.pb.attr.AttrType.AGI] = data.bfp.agi                   -- ����
    self.petattribution[fire.pb.attr.AttrType.POINT] = data.point                   -- Ǳ�ܡ�δ�������
    self.petattribution[fire.pb.attr.AttrType.PET_ATTACK_APT] = data.attackapt      -- ��������
    self.petattribution[fire.pb.attr.AttrType.PET_DEFEND_APT] = data.defendapt      -- ��������
    self.petattribution[fire.pb.attr.AttrType.PET_PHYFORCE_APT] = data.phyforceapt  -- ��������
    self.petattribution[fire.pb.attr.AttrType.PET_MAGIC_APT] = data.magicapt        -- ��������
    self.petattribution[fire.pb.attr.AttrType.PET_SPEED_APT] = data.speedapt        -- �ٶ�����
    self.petattribution[fire.pb.attr.AttrType.PET_DODGE_APT] = data.dodgeapt        -- ��������
    self.petattribution[fire.pb.attr.AttrType.PET_LIFE] = data.life                 -- ����

    self.curexp = data.exp
    self.nextexp = BeanConfigManager.getInstance():GetTableByName("pet.cpetnextexp"):getRecorder(data.level).exp
    if bit.band(data.flag, fire.pb.Pet.FLAG_LOCK) == 0 then
        self.bLock = false
    else
        self.bLock = true
    end
    if bit.band(data.flag, fire.pb.Pet.FLAG_BIND) == 0 then
        self.bBind = false
    else
        self.bBind = true
    end
    self.flag = data.flag
    self.timeout = data.timeout
    self.ownerid = data.ownerid
    self.ownername = data.ownername
    self.rank = data.rank
    self:RefreshShape()                     -- ��������shapeֵ
    self.starId = data.starid
    self.practiseTimes = data.practisetimes
    self.genguadd = data.changegengu
    self.skill_grid = data.skill_grids
    self.score = data.petscore
    self.basescore = data.petbasescore
    self.petdye1 = data.petdye1
    self.petdye2 = data.petdye2
		
    self.initbfp = {}
    self.initbfp.cons = data.initbfp.cons   -- ����
    self.initbfp.iq = data.initbfp.iq       -- ����
    self.initbfp.str = data.initbfp.str     -- ����
    self.initbfp.endu = data.initbfp.endu   -- ����
    self.initbfp.agi = data.initbfp.agi     -- ����

    self.autoBfp = {}
    self.autoBfp.cons = data.autoaddcons   -- ����
    self.autoBfp.iq = data.autoaddiq       -- ����
    self.autoBfp.str = data.autoaddstr     -- ����
    self.autoBfp.endu = data.autoaddendu   -- ����
    self.autoBfp.agi = data.autoaddagi     -- ����

    self.pointresetcount = data.pointresetcount
    self.aptaddcount = data.aptaddcount
    self.growrateaddcount = data.growrateaddcount
    self.washcount = data.washcount
    self.shenshouinccount = data.shenshouinccount
    self.marketfreezeexpire = data.marketfreezeexpire

    self.petskilllist = data.skills

    self.petskillexpires = data.skillexpires

    self.zizhi = data.zizhi

    if data.internals ~= nil then
        self.petinternallist = data.internals
    end

end

function stMainPetData:initWithCplusplus(data)
    self.key = data.key
    self.baseid = data.id
    self.name = data.name
    self.battlestate = 0
    self.scale = data.scale
    self.kind = data.kind
    self.colour = data.colour
    self.growrate = data.growrate / 1000.0

    self.petattribution = {}
    self.petattribution[1240] = data.qianye
    self.petattribution[fire.pb.attr.AttrType.LEVEL] = data.level                   -- �ȼ�
    self.petattribution[fire.pb.attr.AttrType.PET_FIGHT_LEVEL] = data.uselevel      -- ��ս�ȼ�
    self.petattribution[fire.pb.attr.AttrType.HP] = data.hp                         -- ��ǰ����
    self.petattribution[fire.pb.attr.AttrType.MAX_HP] = data.maxhp                  -- �������
    self.petattribution[fire.pb.attr.AttrType.MP] = data.mp                         -- ��ǰ����
    self.petattribution[fire.pb.attr.AttrType.MAX_MP] = data.maxmp                  -- �����
    self.petattribution[fire.pb.attr.AttrType.ATTACK] = data.attack                 -- ����
    self.petattribution[fire.pb.attr.AttrType.DEFEND] = data.defend                 -- ����
    self.petattribution[fire.pb.attr.AttrType.SPEED] = data.speed                   -- �ٶ�
    self.petattribution[fire.pb.attr.AttrType.MAGIC_ATTACK] = data.magicattack      -- ��������
    self.petattribution[fire.pb.attr.AttrType.MAGIC_DEF] = data.magicdef            -- ��������
    self.petattribution[fire.pb.attr.AttrType.CONS] = data.bfp.cons                 -- ����
    self.petattribution[fire.pb.attr.AttrType.IQ] = data.bfp.iq                     -- ����
    self.petattribution[fire.pb.attr.AttrType.STR] = data.bfp.str                   -- ����
    self.petattribution[fire.pb.attr.AttrType.ENDU] = data.bfp.endu                 -- ����
    self.petattribution[fire.pb.attr.AttrType.AGI] = data.bfp.agi                   -- ����
    self.petattribution[fire.pb.attr.AttrType.POINT] = data.point                   -- Ǳ�ܡ�δ�������
    self.petattribution[fire.pb.attr.AttrType.PET_ATTACK_APT] = data.attackapt      -- ��������
    self.petattribution[fire.pb.attr.AttrType.PET_DEFEND_APT] = data.defendapt      -- ��������
    self.petattribution[fire.pb.attr.AttrType.PET_PHYFORCE_APT] = data.phyforceapt  -- ��������
    self.petattribution[fire.pb.attr.AttrType.PET_MAGIC_APT] = data.magicapt        -- ��������
    self.petattribution[fire.pb.attr.AttrType.PET_SPEED_APT] = data.speedapt        -- �ٶ�����
    self.petattribution[fire.pb.attr.AttrType.PET_DODGE_APT] = data.dodgeapt        -- ��������
    self.petattribution[fire.pb.attr.AttrType.PET_LIFE] = data.life                 -- ����

    self.curexp = data.exp
    self.nextexp = BeanConfigManager.getInstance():GetTableByName("pet.cpetnextexp"):getRecorder(data.level).exp
    if bit.band(data.flag, fire.pb.Pet.FLAG_LOCK) == 0 then
        self.bLock = false
    else
        self.bLock = true
    end
    if bit.band(data.flag, fire.pb.Pet.FLAG_BIND) == 0 then
        self.bBind = false
    else
        self.bBind = true
    end
    self.flag = data.flag
    self.timeout = data.timeout
    self.ownerid = data.ownerid
    self.ownername = data.ownername
    self.rank = data.rank
    self:RefreshShape()                     -- ��������shapeֵ
    self.starId = data.starid
    self.practiseTimes = data.practisetimes
    self.genguadd = data.changegengu
    self.skill_grid = data.skill_grids
    self.score = data.petscore
    self.basescore = data.petbasescore
    self.petdye1 = data.petdye1
    self.petdye2 = data.petdye2
		
    self.initbfp = {}
    self.initbfp.cons = data.initbfp.cons   -- ����
    self.initbfp.iq = data.initbfp.iq       -- ����
    self.initbfp.str = data.initbfp.str     -- ����
    self.initbfp.endu = data.initbfp.endu   -- ����
    self.initbfp.agi = data.initbfp.agi     -- ����

    self.autoBfp = {}
    self.autoBfp.cons = data.autoaddcons   -- ����
    self.autoBfp.iq = data.autoaddiq       -- ����
    self.autoBfp.str = data.autoaddstr     -- ����
    self.autoBfp.endu = data.autoaddendu   -- ����
    self.autoBfp.agi = data.autoaddagi     -- ����

    self.pointresetcount = data.pointresetcount
    self.aptaddcount = data.aptaddcount
    self.growrateaddcount = data.growrateaddcount
    self.washcount = data.washcount
    self.shenshouinccount = data.shenshouinccount
    self.marketfreezeexpire = data.marketfreezeexpire

--    self.petskilllist = data.skills
--    self.petskillexpires = data.skillexpires
--    self.zizhi = data.zizhi
end

function stMainPetData:RefreshShape()
    local petBaseData = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(self.baseid)
    if petBaseData then
        self.shape = petBaseData.modelid
    end
end

function stMainPetData:GetShapeID()
    if self.shape == 0 then
        self:RefreshShape()
    end
    return self.shape
end

function stMainPetData:GetPetNameTextColour()
    local petBaseData = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(self.baseid)
    if petBaseData then
        return "[colour='" .. petBaseData.colour .. "']"
	end
    return "[colour='FFFFFFFF']"
end

function stMainPetData:getAttribute(key)
    return math.floor(self.petattribution[key])
end

function stMainPetData:setAttribute(key, value)
    self.petattribution[key] = value
end

function stMainPetData:getSkilllistlen()
    return #self.petskilllist
end

function stMainPetData:getCurexp()
    return self.curexp
end

function stMainPetData:getNextexp()
    return self.nextexp
end

function stMainPetData:getSkill(index)
    return self.petskilllist[index]
end

function stMainPetData:getSkillexp(skillid)
    for i = 1, #self.petskilllist do
        if self.petskilllist[i].skillid == skillid then
            return self.petskilllist[i].skillexp
		end
    end
    return 0
end

function stMainPetData:isSkillBind(skillid)
    local petBaseData = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(self.baseid)
    if petBaseData then
        for i = 0, petBaseData.skillid:size()-1 do
            if petBaseData.skillid[i] == skillid then
                return petBaseData.isbindskill[i] == 1 and true or false
		    end
        end
    end
    return false
end

function stMainPetData:getzizhi(key)
    return self.zizhi[key]
end

function stMainPetData:setZizhi(key, value)
    self.zizhi[key] = value
end

function stMainPetData:clearZizhi()
    self.zizhi = {}
    self.genguadd = 0
end

function stMainPetData:setPetSkillExpires(key, value)
    self.petskillexpires[key] = value
end

function stMainPetData:getPetSkillExpires(key)
    return self.petskillexpires[key]
end

-- ��ȡ���ﱻ��֤�ļ���
function stMainPetData:getIdentifiedSkill()
    for i = 1, #self.petskilllist do
        if self.petskilllist[i].certification == 1 then
            return self.petskilllist[i]
		end
    end
    return nil
end

-- ��ȡ���＼����
function stMainPetData:getPetSkillNum()
    return #self.petskilllist
end


function stMainPetData:getInternallistlen()
    return #self.petinternallist
end

function stMainPetData:getInternal(index)
    return self.petinternallist[index]
end

return stMainPetData
-------------------------------------------------------------
