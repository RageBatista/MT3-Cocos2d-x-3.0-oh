------------------------------------------------------------------
-- Item Object ��
------------------------------------------------------------------

FLY_FLAG_LINAN                  = 36022
FLY_FLAG_JIAXING                = 36025

WUXING_FLY_FLAG_EMPTY           = 36293
WUXING_FLY_FLAG_JIAXING         = 36297

FIRE_FOOD_MIN                   = 36367
FIRE_FOOD_MAX                   = 36370

c_iTreasureMapBaseID            = 36017
c_iSuperTreasureMapBaseID       = 36018
c_iHuoDongTreasureMapBaseID     = 36638

c_iTreasure_Map                 = 331300
c_iAdvanced_Treasure_Map        = 331301

c_iBaoChanBaseID                = 36124

c_iWorldPuzzleAntiqueIDMin      = 36079
c_iWorldPuzzleAntiqueIDMax      = 36090

-- װ������
eEquipType_ARMS                 = 0
eEquipType_CUFF                 = 1
eEquipType_ADORN                = 2
eEquipType_LORICAE              = 3
eEquipType_WAISTBAND            = 4
eEquipType_BOOT                 = 5
eEquipType_TIRE                 = 6
eEquipType_CLOAK               = 7
eEquipType_EYEPATCH             = 8
eEquipType_RESPIRATOR           = 9
eEquipType_VEIL                 = 10
eEquipType_FASHION              = 11
eEquipType_FASHION1             = 12
eEquipType_FASHION2             = 13
eEquipType_FASHION3             = 14
eEquipType_FASHION4             = 15
eEquipType_FASHION5             = 16
eEquipType_new1                 = 17
eEquipType_new2                 = 18
eEquipType_new3                 = 19
eEquipType_new4                 = 20
eEquipType_MAXTYPE              = 21
eEquipType_XPSHE			  =31	--星盘蛇
eEquipType_XPHU			      =32	--星盘虎
eEquipType_XPNIU			  =33	--星盘牛
eEquipType_XPTU			      =34	--星盘兔
eEquipType_XPLONG			  =35	--星盘龙
eEquipType_XPYANG			  =36	--星盘羊

newequip = {
	616,
	632,
	648,
	664,
	680,
	696,
	296,
	408,
	328,
	504,
	520,
	536,
	552,
	584,
	600,
	712,
	728,
	744
		}
		function IsNewEquip(typeId)
			for k,v in ipairs(newequip) do
				if v == typeId then
					return true;
				end
			end
			return false; 
		end
		
		function NewEquippos(typeid)
			if typeid==504 then
				return 31
			elseif typeid == 520 then
				return 32
			elseif typeid == 536 then
				return 33
			elseif typeid == 552 then
				return 34
			elseif typeid == 584 then
				return 35
			elseif typeid == 600 then
				return 36
		   elseif typeid == 616 then
				return 12
			elseif typeid == 632 then
				return 13
			elseif typeid == 648 then
				return 14
			elseif typeid == 664 then
				return 15
			elseif typeid == 680  then
				return 16
			elseif typeid == 696 then
				return 17
			elseif typeid == 296 then
				return 18
			elseif typeid == 408 then
				return 19
			elseif typeid == 328 then
				return 20
			elseif typeid == 712 then
				return 12
			elseif typeid == 728 then
				return 13
			elseif typeid == 744 then
				return 13
			end
		end
-- ��������
eItemType_NOTYPE                = 0
eItemType_PETITEM               = 1
eItemType_FOOD                  = 2
eItemType_DRUG                  = 3
eItemType_DIMARM                = 4
eItemType_GEM                   = 5
eItemType_GROCERY               = 6
eItemType_EQUIP_RELATIVE        = 7
eItemType_EQUIP                 = 8
eItemType_TASKITEM              = 9
eItemType_PETEQUIPITEM = 10
eClientTableType_NORMAL                     = 0
eClientTableType_STORAGE                    = 21
eClientTableType_BATTLEBAG                  = 22
eClientTableType_BATTLE_QUEST_BAG           = 23
eClientTableType_PETUSEITEM                 = 24
eClientTableType_NPC_SELL                   = 25
eClientTableType_PROTECT_BELOGINGS          = 26
eClientTableType_GIVEDLG                    = 28
eClientTableType_PRIVATESTOREDLG            = 29
eClientTableType_OTHERSTOREDLG              = 30
eClientTableType_TRADEDLG                   = 31
eClientTableType_STALLBUYDLG                = 32
eClientTableType_GIVEDLG_QUEST              = 33
eClientTableType_TRADE_COUNTER_1            = 34
eClientTableType_TRADE_COUNTER_2            = 35
eClientTableType_TRADE_COUNTER_3            = 36
eClientTableType_TRADE_COUNTER_4            = 37
eClientTableType_TRADE_COUNTER_5            = 38
eClientTableType_TRADE_COUNTER_6            = 39
eClientTableType_TRADE_COUNTER_7            = 40
eClientTableType_TRADE_COUNTER_8            = 41
eClientTableType_TRADE_COUNTER_9            = 42
eClientTableType_TRADE_COUNTER_10           = 43
eClientTableType_ITEM_TRADE_MIRROR          = 44
eClientTableType_COFC_SELL_SHOP             = 45
eClientTableType_SKILLREPAIRDLG             = 46
eClientTableType_SKILLREPAIREQUIP           = 47
eClientTableType_FAMILYREPAIRDLG            = 48
eClientTableType_FAMILYREPAIREQUIP          = 49
eClientTableType_OTHER_ROLE_EQUIP           = 50
eClientTableType_SPECIAL_BUY                = 51
eClientTableType_NPC_ZAXUE_GIVE             = 52
eClientTableType_ANTIQUE                    = 53
eClientTableType_RANKLIST_DISCOVERANTIQUE   = 54
eClientTableType_XUNBAO_SELLITEM_BAG        = 55
eClientTableType_SELL_TO_NPC                = 56

eUpdateFlag_IMAGE                           = 1
eUpdateFlag_COUNT                           = 2

-- from roleitem
-------------------------------------------------------------

FlyFlag_ID                      = 36000

Treasure_Map                    = 331300
Advanced_Treasure_Map           = 331301
Money_Tree                      = 340025

Money_Book                      = 50248

Pet_Soul                        = 50163
Pet_Holy_Soul                   = 50202

Pet_Guide_ID                    = 36266
Family_Guide_ID                 = 36265
Family_Manager_Book             = 36473
Faction_Manager_Book            = 36474

Pet_Star                        = 31093

Qian_Li_Xun_Die                 = 36253

ChongWuLanID4                   = 36069
ChongWuLanID5                   = 36118
PetSinkerID                     = 36324

WuLingCangID                    = 36068
WuLingCangID3                   = 36122
WuLingCangID4                   = 36123
WuLingCangID5                   = 36706
WuLingCangID6                   = 36707
WuLingCangID7                   = 36708
WuLingCangID8                   = 36709

MaBuXingNangID                  = 36067
QingBuXingNangID                = 36704
JinBuXingNangID                 = 36705

BaiHeID                         = 36036
NvErHongID                      = 36037
TurpetID                        = 37741


FASHION_DRESS                   = 184

LOTTERY_ITEM1                   = 36631
LOTTERY_ITEM2                   = 36632
LOTTERY_ITEM3                   = 36633

QG_EFFECT_ITEM1                 = 36358
QG_EFFECT_ITEM2                 = 36359
QG_EFFECT_ITEM3                 = 36360
QG_EFFECT_ITEM4                 = 36361

ZHENFA_BOOK                     = 278

XUEMAI_GEM_ELITE                = 36117
PET_RETURN                      = 33
PET_FOOD                        = 17
PET_SKILL_BOOK                  = 49
FLOWER_ITEM                     = 86
ORNAMENT_SYMBOL                 = 887
ARMORS_SYMBOL                   = 631
WEAPON_SYMBOL                   = 375
WEAPON_MANUAL                   = 23
PEARL_TYPE                      = 102
TASKCOMMON_WEAPON               = 49197
AirSeaLevel1                    = 36198
AirSeaLevel2                    = 36199
AirSeaLevel3                    = 36200
BIG_FLYFLAG_CLOTH               = 36259
SMALL_FLYFLAG_CLOTH             = 36258
QI_LI_WAN                       = 32027
AUTO_RECOVERY_ITEM              = 66
ROSE_ITEM_ID                    = 36134

-- from roleitemmanager
-------------------------------------------------------------

COALBIND_BASEID                 = 36031
COAL_BASEID                     = 36189

eItemFilterType_CanSale         = 0 -- �����̻����
eItemFilterType_CanStall        = 1 -- �ɰ�̯

eMainPackState_Null             = 0
eMainPackState_Deport           = 1
eMainPackState_NpcSell          = 2
eMainPackState_Pearlrepair      = 3
eMainPackState_GemLevelup       = 4
eMainPackState_NpcSellWuJue     = 5
eMainPackState_UseTaskItem      = 7
eMainPackState_UpgradePetXueMai = 8
eMainPackState_ImportStarToPet  = 9
eMainPackState_EquipManual      = 10
eMainPackState_FlyFlagSupply    = 11
eMainPackState_BuyNpcItem       = 12

-------------------------------------------------------------

stObjLocation = {}
stObjLocation.__index = stObjLocation

function stObjLocation:new()
    local self = {}
    setmetatable(self, stObjLocation)
    self:init()
    return self
end

function stObjLocation:init()
	self.position = 0
	self.tableType = 0
end

function stObjLocation:equals(loc)
    if self.position == loc.position and self.tableType == loc.tableType then
        return true
    end
    return false
end

function stObjLocation:GetPostion()
    return self.position
end

function stObjLocation:GetTableType()
    return self.tableType
end

-------------------------------------------------------------

stFumoData = {}
stFumoData.__index = stFumoData

function stFumoData:new()
    local self = {}
    setmetatable(self, stFumoData)
    self:init()
    return self
end

function stFumoData:init()
    self.mapfumo = {}
    self.nFomoEndTime = 0
end

-------------------------------------------------------------

stPlusEffect = {}
stPlusEffect.__index = stPlusEffect

function stPlusEffect:new()
    local self = {}
    setmetatable(self, stPlusEffect)
    self:init()
    return self
end

function stPlusEffect:init()
    self.attrid = 0
    self.attrvalue = 0
    self.attrnum = 0
end

-------------------------------------------------------------

function gGetAntiqueType(typeID)
	if typeID > 0 then
		local a = bit.brshift(typeID, 8)
		local b = bit.band(bit.brshift(typeID, 4), 15)
		local c = bit.band(typeID, 15)
		if a > 0 and a <= 7 then
			if b == 11 and c == 6 then
				return a
			end
		end
	end

	return 0
end

function gIsAntiqueItem(typeID)
	local type = gGetAntiqueType(typeID)
	if type ~= 0 and type <= 7 then 
		return true
	end
	return false
end

-------------------------------------------------------------

tObject = {}
tObject.__index = tObject

function tObject:new()
    local self = {}
    setmetatable(self, tObject)
    self:init()
    return self
end

function tObject:init()
	self.data = {}
	self.loc = {}
	self.bNeedRequireData = true
end

function tObject:IsNeedRequireData()
    return self.bNeedRequireData
end

function tObject:SetNeedRequireData(needRequire)
    bNeedRequireData = needRequire
end

function tObject:Clone()
end

function tObject:MakeTips(_os_)
end

-------------------------------------------------------------

PetItemObject = {}
setmetatable(PetItemObject, tObject)
PetItemObject.__index = PetItemObject

function PetItemObject:new()
    local self = {}
    self = tObject:new()
    setmetatable(self, PetItemObject)
    self.bNeedRequireData = false
    return self
end

function PetItemObject:Clone()
    local p = PetItemObject:new()
	p.data = self.data
	p.loc = self.loc
	p.bNeedRequireData = self.bNeedRequireData
    return p
end

function PetItemObject:MakeTips(_os_)
end

PetEquipItemObject = {}
setmetatable(PetEquipItemObject, tObject)
PetEquipItemObject.__index = PetEquipItemObject

function PetEquipItemObject:new()
    local self = {}
    self = tObject:new()
    setmetatable(self, PetEquipItemObject)
	self.bNeedRequireData = true;
	self.petequippos = 0 
	self.petequipbaseEffect = {}
        self.petequipeffect = 0 
    return self
end

function PetEquipItemObject:Clone()
    local p = PetEquipItemObject:new()
    p.bNeedRequireData = self.bNeedRequireData
	p.petequippos = self.petequippos
	p.petequipbaseEffect = self.petequipbaseEffect
	p.petequipeffect = self.petequipeffect
    return p
end

function PetEquipItemObject:MakeTips(_os_)
        self.bNeedRequireData = false
	    self.petequippos= _os_:unmarshal_int32()
		self.petequipbaseEffect = {}
	    local baseeffectnum = _os_:unmarshal_int32()
	    for i = 1, baseeffectnum do
		  if not _os_:eos() then
			local baseattrid = _os_:unmarshal_int32()
			local baseattrvalue = _os_:unmarshal_int32()
			self.petequipbaseEffect[baseattrid] = baseattrvalue
		  end
	    end
	    self.petequipeffect= _os_:unmarshal_int32()
end

function PetEquipItemObject:GetMapPetEquipBaseEffect()
    return self.petequipbaseEffect
end
function PetEquipItemObject:GetPetEquipBaseEffectAllKey()
	local vKey = {}
    for k,v in pairs(self.petequipbaseEffect) do
        table.insert(vKey, k)
    end
    table.sort(vKey, function (v1, v2)
		return v1 < v2
	end)
    return vKey
end
function PetEquipItemObject:GetPetEquipBaseEffect(baseeffecKey)
    for k,v in pairs(self.petequipbaseEffect) do
        if k == baseeffecKey then
            return v
        end
    end
    return 0
end
-------------------------------------------------------------

FoodObject = {}
setmetatable(FoodObject, tObject)
FoodObject.__index = FoodObject

function FoodObject:new()
    local self = {}
    self = tObject:new()
    setmetatable(self, FoodObject)
    self.effectDes = nil
    self.qualiaty = 0
    return self
end

function FoodObject:Clone()
    local p = FoodObject:new()
	p.data = self.data
	p.loc = self.loc
	p.bNeedRequireData = false
    p.effectDes = self.effectDes
    p.qualiaty = self.qualiaty
    return p
end

function FoodObject:MakeTips(_os_)
    self.bNeedRequireData = false
    self.qualiaty = _os_:unmarshal_int32()

	local des = BeanConfigManager.getInstance():GetTableByName("item.cfoodanddrugeffect"):getRecorder(self.data.id).effectdescribe
    local sb = require "utils.stringbuilder":new()
	self.effectDes = sb:GetString(des)
    sb:delete()
end

-------------------------------------------------------------

DrugObject = {}
setmetatable(DrugObject, tObject)
DrugObject.__index = DrugObject

function DrugObject:new()
    local self = {}
    self = tObject:new()
    setmetatable(self, DrugObject)
    self.effectDes = nil
    self.qualiaty = 0
    return self
end

function DrugObject:Clone()
    local p = DrugObject:new()
	p.data = self.data
	p.loc = self.loc
	p.bNeedRequireData = self.bNeedRequireData
    p.effectDes = self.effectDes
    p.qualiaty = self.qualiaty
    return p
end

function DrugObject:MakeTips(_os_)
	self.bNeedRequireData = false;
    self.qualiaty = _os_:unmarshal_int32()

	local des = BeanConfigManager.getInstance():GetTableByName("item.cfoodanddrugeffect"):getRecorder(self.data.id).effectdescribe
    local sb = require "utils.stringbuilder":new()
	self.effectDes = sb:GetString(des)
    sb:delete()
end

-------------------------------------------------------------

ResumeObject = {}
setmetatable(ResumeObject, DrugObject)
ResumeObject.__index = ResumeObject

function ResumeObject:new()
    local self = {}
    self = DrugObject:new()
    setmetatable(self, ResumeObject)
	self.bNeedRequireData = true;
	self.qualiaty = 0;
	self.remainValue = 0;
    return self
end

function ResumeObject:Clone()
    local p = ResumeObject:new()
	p.data = self.data
	p.loc = self.loc
	p.bNeedRequireData = self.bNeedRequireData
    p.effectDes = self.effectDes
    p.qualiaty = self.qualiaty
    p.remainValue = self.remainValue
    return p
end

function ResumeObject:MakeTips(_os_)
    self.remainValue = _os_:unmarshal_int32()
end

-------------------------------------------------------------

DimarmObiect = {}
setmetatable(DimarmObiect, tObject)
DimarmObiect.__index = DimarmObiect

function DimarmObiect:new()
    local self = {}
    self = tObject:new()
    setmetatable(self, DimarmObiect)
    self.endure = 100
    self.damage = 0
    return self
end

function DimarmObiect:Clone()
    local p = DimarmObiect:new()
	p.data = self.data
	p.loc = self.loc
	p.bNeedRequireData = self.bNeedRequireData
    p.endure = self.endure
    p.damage = self.damage
    return p
end

function DimarmObiect:MakeTips(_os_)
    self.bNeedRequireData = false
    self.endure = _os_:unmarshal_int32()
end

-------------------------------------------------------------

GemObject = {}
setmetatable(GemObject, tObject)
GemObject.__index = GemObject

function GemObject:new()
    local self = {}
    self = tObject:new()
    setmetatable(self, GemObject)
    self.gemmyEquipType = nil
    self.effectName = nil
    return self
end

function GemObject:Clone()
    local p = GemObject:new()
	p.data = self.data
	p.loc = self.loc
	p.bNeedRequireData = self.bNeedRequireData
    p.gemmyEquipType = self.gemmyEquipType
    p.effectName = self.effectName
    return p
end

function GemObject:MakeTips(_os_)
end

-------------------------------------------------------------

GroceryObject = {}
setmetatable(GroceryObject, tObject)
GroceryObject.__index = GroceryObject

function GroceryObject:new()
    local self = {}
    self = tObject:new()
    setmetatable(self, GroceryObject)

	self.bNeedRequireData = false
	self.flytimeleft = 0
	self.replenishtime = 0
	self.mapID = 0
	self.x = 0
	self.y = 0
	self.antiqueLevel = 0

	self.baochanNpcID = 0
	self.baochanMapID = 0
	self.baochanX = 0
	self.baochanY = 0

	self.familyname = ""
	self.freshnessdate = 0
	self.nLevel = 0
	self.mapfumo = {}

    return self
end

function GroceryObject:GetFumoValueWithId(nId)
    for id, val in pairs(self.mapfumo) do
        if id == nId then
            return val
        end
    end
	return 0;
end

function GroceryObject:Clone()
    local p = GroceryObject:new()

	p.bNeedRequireData = self.bNeedRequireData
	p.flytimeleft = self.flytimeleft
	p.replenishtime = self.replenishtime
	p.mapID = self.mapID
	p.x = self.x
	p.y = self.y
	p.antiqueLevel = self.antiqueLevel

	p.baochanNpcID = self.baochanNpcID
	p.baochanMapID = self.baochanMapID
	p.baochanX = self.baochanX
	p.baochanY = self.baochanY

	p.familyname = self.familyname
	p.freshnessdate = self.freshnessdate
	p.nLevel = self.nLevel
	p.mapfumo = self.mapfumo

    return p
end

function GroceryObject:MakeTips(_os_)
    local nItemId = self.data.id

    local nTypeId = 0
    local itemTable = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
    if itemTable then
        nTypeId = itemTable.itemtypeid
    end

	if (nItemId <= FLY_FLAG_JIAXING and nItemId >= FLY_FLAG_LINAN) or
		(nItemId <= WUXING_FLY_FLAG_JIAXING and nItemId >= WUXING_FLY_FLAG_EMPTY) then
        self.flytimeleft = _os_:unmarshal_int32()
        self.replenishtime = _os_:unmarshal_int32()
	elseif nTypeId == 358 then
        self.nLevel = _os_:unmarshal_int32()
	elseif nItemId == c_iTreasure_Map or nItemId == c_iAdvanced_Treasure_Map then -- �ر�ͼ
        self.mapID = _os_:unmarshal_int32()
        self.x = _os_:unmarshal_int32()
        self.y = _os_:unmarshal_int32()
	elseif nItemId == c_iTreasureMapBaseID or nItemId == c_iSuperTreasureMapBaseID or nItemId == c_iHuoDongTreasureMapBaseID then
        self.mapID = _os_:unmarshal_int32()
        self.x = _os_:unmarshal_int32()
        self.y = _os_:unmarshal_int32()
	elseif nItemId == c_iBaoChanBaseID then
        self.baochanNpcID = _os_:unmarshal_int32()
        self.baochanMapID = _os_:unmarshal_int32()
        self.baochanX = _os_:unmarshal_int32()
        self.baochanY = _os_:unmarshal_int32()
	elseif nItemId >= FIRE_FOOD_MIN and nItemId <= FIRE_FOOD_MAX then
        self.familyname = _os_:unmarshal_wstring(self.familyname)
        self.freshnessdate = _os_:unmarshal_int64()
	end

	local record = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId);
	if record and gIsAntiqueItem(record.itemtypeid) then
        self.antiqueLevel = _os_:unmarshal_int32()
	end
end

-------------------------------------------------------------

TaskObject = {}
setmetatable(TaskObject, tObject)
TaskObject.__index = TaskObject

function TaskObject:new()
    local self = {}
    self = tObject:new()
    setmetatable(self, TaskObject)
	self.bNeedRequireData = false
    self.effectName = nil
	self.readBarTime = 0
    self.readBarText = nil
	self.mapID = 0
	self.x = 0
	self.y = 0
    return self
end

function TaskObject:Clone()
    local p = TaskObject:new()
	p.data = self.data
	p.loc = self.loc
	p.bNeedRequireData = self.bNeedRequireData
	p.effectName = self.effectName
	p.readBarTime = self.readBarTime
	p.readBarText = self.readBarText
	p.mapID = self.mapID
	p.x = self.x
	p.y = self.y
    return p
end

function TaskObject:MakeTips(_os_)
    if self.data.id == c_iGuide_Notes then
        self.mapID = _os_:unmarshal_int32()
        self.x = _os_:unmarshal_int32()
        self.y = _os_:unmarshal_int32()
    end
end

-------------------------------------------------------------

EquipObject = {}
setmetatable(EquipObject, tObject)
EquipObject.__index = EquipObject

function EquipObject:new()
    local self = {}
    self = tObject:new()
    setmetatable(self, EquipObject)

	self.identify = 0
	self.equipscore = 0
    self.prefix = nil
    self.crystalprogress = 0
	self.sexNeed = 0
    self.roleNeed =
    {
        _size = 0,
	    size = function() return _size end
    }
    self.blesslv = 0
    self.baseEffect = {}
	self.extrabaseEffect = {}--熔炼属性
    self.plusEffect = {}
	self.extraplusEffect = {}--熔炼属性
    self.gemlist = {}
    self.GemAttributeMap = {}
	self.crystalnum = 0
	self.percent = 0
	self.repairTimes = 0
	self.endure = 500
	self.endureuplimit = 500
	self.skillid = 0
	self.skilleffect = 0
	self.equipsit=0
	self.newskillid = 0
	self.newskilleffect = 0
	self.speceffectid = 0
    self.maker = ""
	self.vFumo = {}

    return self
end

function EquipObject:Clone()
    local p = EquipObject:new()
	p.data = self.data
	p.loc = self.loc
	p.bNeedRequireData = self.bNeedRequireData
	p.identify = self.identify
	p.equipscore = self.equipscore
	p.prefix = self.prefix
	p.crystalprogress = self.crystalprogress
	p.sexNeed = self.sexNeed
	p.roleNeed = self.roleNeed
	p.blesslv = self.blesslv
	p.baseEffect = self.baseEffect
	p.extrabaseEffect = self.extrabaseEffect--熔炼属性
	p.plusEffect = self.plusEffect
	p.extraplusEffect = self.extraplusEffect--熔炼属性
    p.gemlist = self.gemlist
    p.GemAttributeMap = self.GemAttributeMap
	p.crystalnum = self.crystalnum
	p.percent = self.percent
	p.repairTimes = self.repairTimes
	p.endure = self.endure
	p.endureuplimit = self.endureuplimit
	p.skillid = self.skillid
	p.skilleffect = self.skilleffect
	p.equipsit = self.equipsit
	p.newskillid = self.newskillid
	p.newskilleffect = self.newskilleffect
	p.speceffectid = self.speceffectid
	p.maker = self.maker
	p.vFumo = self.vFumo
    return p
end

function EquipObject:GetMapBaseEffect()
    return self.baseEffect
end

function EquipObject:GetMapPlusEffect()
    return self.plusEffect
end

function EquipObject:GetBaseEffectAllKey()
	local vKey = {}
    for k,v in pairs(self.baseEffect) do
        table.insert(vKey, k)
    end
    table.sort(vKey, function (v1, v2)
		return v1 < v2
	end)
    return vKey
end
--熔炼属性
function EquipObject:GetExtraBaseEffectAllKey()
	local vKey = {}
    for k,v in pairs(self.extrabaseEffect) do
        table.insert(vKey, k)
    end
    table.sort(vKey, function (v1, v2)
		return v1 < v2
	end)
    return vKey
end
--熔炼属性
function EquipObject:GetExtraBaseEffect(extrabaseeffecKey)
    for k,v in pairs(self.extrabaseEffect) do
        if k == extrabaseeffecKey then
            return v
        end
    end
    return 0
end

function EquipObject:GetBaseEffect(baseeffecKey)
    for k,v in pairs(self.baseEffect) do
        if k == baseeffecKey then
            return v
        end
    end
    return 0
end

function EquipObject:GetPlusEffectAllKey(vKey)
	local vKey = {}
    for k,v in pairs(self.plusEffect) do
        table.insert(vKey, k)
    end
    table.sort(vKey, function (v1, v2)
		return v1 < v2
	end)
    return vKey
end
function EquipObject:GetExtraPlusEffect(vKey)
    for k,v in pairs(self.extraplusEffect) do
        if k == vKey then
            return v
        end
    end
    return 0
end
function EquipObject:GetPlusEffect(nKey)
    for k,v in pairs(self.plusEffect) do
        if k == nKey then
            return v
        end
    end
    return nil
end

function EquipObject:GetGemlist()
	local gemvector = {}
    gemvector._size = 0
	function gemvector:size()
		return self._size
	end

    for _,v in pairs(self.gemlist) do
        gemvector[gemvector._size] = v
        gemvector._size = gemvector._size + 1
        --table.insert(gemvector, v)
    end

    return gemvector
end

function EquipObject:GetGemAttributeMap()
    return self.GemAttributeMap
end

function EquipObject:getFumoCount()
	return #self.vFumo
end

function EquipObject:getFumoDataWidthIndex(nIndex)
    if nIndex < 0 or nIndex >= #self.vFumo then
		return nil
	end
	return self.vFumo[nIndex + 1]
end

function EquipObject:GetFumoIdWithIndex(nIndex)
	local vFumoId = {}
    vFumoId._size = 0
	function vFumoId:size()
		return self._size
	end

    if nIndex < 0 or nIndex >= #self.vFumo then
		return
	end

    local fumoData = self.vFumo[nIndex + 1]
    for k,v in pairs(fumoData.mapfumo) do
        vFumoId[vFumoId._size] = k
        vFumoId._size = vFumoId._size + 1
        --table.insert(vFumoId, k)
    end

    return vFumoId
end

function EquipObject:GetFumoValueWithId(nIndex, nId)
    if nIndex < 0 or nIndex >= #self.vFumo then
		return -1
	end

    local fumoData = self.vFumo[nIndex + 1]
    for k,v in pairs(fumoData.mapfumo) do
        if k == nId then
            return v
        end
    end

	return -1;
end

function EquipObject:MakeTips(_os_)
	self.bNeedRequireData = false
--双加属性
	 
		self.lockstate=_os_:unmarshal_char()
		local dsize=_os_:unmarshal_int32()
		self.shuangjia={}
		for i=1,dsize do
				local propid = _os_:unmarshal_int32()
				local propval = _os_:unmarshal_int32()
                self.shuangjia[propid]=propval
		end
	


	self.baseEffect = {}
	local baseeffectnum = _os_:unmarshal_int32()
	for i = 1, baseeffectnum do
		if not _os_:eos() then
			local baseattrid = _os_:unmarshal_int32()
			local baseattrvalue = _os_:unmarshal_int32()
			self.baseEffect[baseattrid] = baseattrvalue
		end
	end
	self.extrabaseEffect = {}
	local extrabaseeffectnum = _os_:unmarshal_int32()
	for i = 1, extrabaseeffectnum do
		if not _os_:eos() then
			local extrabaseattrid = _os_:unmarshal_int32()
			local extrabaseattrvalue = _os_:unmarshal_int32()
			self.extrabaseEffect[extrabaseattrid] = extrabaseattrvalue
		end
	end

	self.plusEffect = {}
	local pluseffectnum = _os_:unmarshal_int32()
	for i = 1, pluseffectnum do
		if not _os_:eos() then
			local plusattrid =_os_:unmarshal_int32()
			local plusattrvalue = _os_:unmarshal_int32()
			local plusattrrefine = 0;
            self.plusEffect[i] = stPlusEffect:new()
			self.plusEffect[i].attrid = plusattrid;
			self.plusEffect[i].attrvalue = plusattrvalue;
			self.plusEffect[i].attrnum = plusattrrefine;
		end
	end
	self.extraplusEffect = {}
	local extrapluseffectnum = _os_:unmarshal_int32()
	for i = 1, extrapluseffectnum do
		if not _os_:eos() then
			local extraplusattrid = _os_:unmarshal_int32()
			local extraplusattrvalue = _os_:unmarshal_int32()
			self.extraplusEffect[extraplusattrid] = extraplusattrvalue
		end
	end

	self.skillid = _os_:unmarshal_int32()
	self.skilleffect = _os_:unmarshal_int32()
	self.equipsit = _os_:unmarshal_int32()
	self.newskillid = _os_:unmarshal_int32()
	self.newskilleffect = _os_:unmarshal_int32()

	if not _os_:eos() then
		self.gemlist = {}
		local gemnum = _os_:unmarshal_int32()
		for i = 1, gemnum do
			if not _os_:eos() then
				local gemid = _os_:unmarshal_int32()
                table.insert(self.gemlist, gemid)
			end
		end
	end

	if #self.gemlist > 0 then
		self.GemAttributeMap = {}
		for k,v in pairs(self.gemlist) do
			local gemconfig = BeanConfigManager.getInstance():GetTableByName("item.cgemeffect"):getRecorder(v);
			if gemconfig then
				for i = 0, gemconfig.effecttype:size()-1 do
                    if not self.GemAttributeMap[gemconfig.effecttype[i]] then
                        self.GemAttributeMap[gemconfig.effecttype[i]] = 0
                    end
					self.GemAttributeMap[gemconfig.effecttype[i]] = self.GemAttributeMap[gemconfig.effecttype[i]] + gemconfig.effect[i];
				end
			end
		end
	end

	

	self.endure = _os_:unmarshal_int32()
	self.endureuplimit = _os_:unmarshal_int32()
	self.repairTimes = _os_:unmarshal_int32()
	self.equipscore = _os_:unmarshal_int32()
    self.maker = _os_:unmarshal_wstring(self.maker)

	if not _os_:eos() then
		self.vFumo = {}
		local nFumoCount = _os_:unmarshal_int32()
		for nIndexCount = 0, nFumoCount-1 do
			local fumoData = stFumoData:new()

			local nFumoNum = _os_:unmarshal_int32()
			for i = 0, nFumoNum-1 do
				if not _os_:eos() then
					local nFumoId = _os_:unmarshal_int32()
					local nFumoValue = _os_:unmarshal_int32()
					if nFumoId > 0 then
						fumoData.mapfumo[nFumoId] = nFumoValue
					end
				end
			end

			fumoData.nFomoEndTime = _os_:unmarshal_int64()

            table.insert(self.vFumo, fumoData)
		end
	end

	if not _os_:eos() then
		self.crystalnum = _os_:unmarshal_int32()
        self.crystalprogress = _os_:unmarshal_int32()
	end

	if not _os_:eos() then
		self.blesslv = _os_:unmarshal_int32()
	end
	
end

-------------------------------------------------------------

EquipRelativeObject = {}
setmetatable(EquipRelativeObject, tObject)
EquipRelativeObject.__index = EquipRelativeObject

function EquipRelativeObject:new()
    local self = {}
    self = tObject:new()
    setmetatable(self, EquipRelativeObject)
    self.bNeedRequireData = false
    self.level = nil
    self.relativeEquip = ""
    return self
end

function EquipRelativeObject:Clone()
    local p = EquipRelativeObject:new()
	p.data = self.data
	p.loc = self.loc
	p.bNeedRequireData = self.bNeedRequireData
	p.level = self.level
	p.relativeEquip = self.relativeEquip
    return p
end

function EquipRelativeObject:MakeTips(_os_)
end

-------------------------------------------------------------

PetSoulObject = {}
setmetatable(PetSoulObject, tObject)
PetSoulObject.__index = PetSoulObject

function PetSoulObject:new()
    local self = {}
    self = tObject:new()
    setmetatable(self, PetSoulObject)
    return self
end

function PetSoulObject:Clone()
    local p = PetSoulObject:new()
	p.data = self.data
	p.loc = self.loc
	p.bNeedRequireData = self.bNeedRequireData
    return p
end

function PetSoulObject:MakeTips(_os_)
    self.data:unmarshal(_os_)
    self.bNeedRequireData = false
end

-------------------------------------------------------------

PetStarObject = {}
setmetatable(PetStarObject, tObject)
PetStarObject.__index = PetStarObject

function PetStarObject:new()
    local self = {}
    self = tObject:new()
    setmetatable(self, PetStarObject)
    return self
end

function PetStarObject:Clone()
    local p = PetStarObject:new()
	p.data = self.data
	p.loc = self.loc
	p.bNeedRequireData = self.bNeedRequireData
    return p
end

function PetStarObject:MakeTips(_os_)
    self.bNeedRequireData = false
end

-------------------------------------------------------------
