require "utils.mhsdutils"
require "logic.dialog"

require "utils.commonutil"

FaBaoMenPaiJinJie = {}
setmetatable(FaBaoMenPaiJinJie, Dialog)
FaBaoMenPaiJinJie.__index = FaBaoMenPaiJinJie
local _instance;
local _idx;
--//===============================
function FaBaoMenPaiJinJie:OnCreate()
    Dialog.OnCreate(self)
    SetPositionScreenCenter(self:GetWindow())
    local winMgr = CEGUI.WindowManager:getSingleton()

    self.name = winMgr:getWindow("fabaomenpaijinjie/name")

    self.m_gressExp = CEGUI.toProgressBar(winMgr:getWindow("fabaomenpaijinjie/exp"))
    self.item1 = CEGUI.toItemCell(winMgr:getWindow("fabaomenpaijinjie/item1"));
    self.item1111 = CEGUI.toItemCell(winMgr:getWindow("fabaomenpaijinjie/item1111"));
    self.item2 = CEGUI.toItemCell(winMgr:getWindow("fabaomenpaijinjie/item"));
    self.level = winMgr:getWindow("fabaomenpaijinjie/level")

    self.jieshao1 = winMgr:getWindow("fabaomenpaijinjie/di11/jieshao1")


    self.itemnum = winMgr:getWindow("fabaomenpaijinjie/itemnum")
    self.itemname = winMgr:getWindow("fabaomenpaijinjie/itemname")


    --self:UpdateProData()
    self.jinjie = CEGUI.toPushButton(winMgr:getWindow("fabaomenpaijinjie/bt"))
    self.jinjie:subscribeEvent("MouseButtonUp", FaBaoMenPaiJinJie.HandleJinJieClick, self)
    gGetGameUIManager():AddUIEffect(self.item1111, MHSD_UTILS.get_effectpath(11095), true)
    self.selectedItemId = 0
    local p = require("logic.item.fabao.cfabaoshopsl"):new()
    LuaProtocolManager:send(p)
   -- self:refreshFaBaoMenPaiJinJieList()
end

function FaBaoMenPaiJinJie:UpdateProData(fabaos)
    _idx=gGetDataManager():GetMainCharacterSchoolID()+100
    local fabaoexps = BeanConfigManager.getInstance():GetTableByName("item.cfabaoexp"):getAllID()
    local exps=0
    for _,id in pairs(fabaoexps) do
        local fabaoexp = BeanConfigManager.getInstance():GetTableByName("item.cfabaoexp"):getRecorder(id)
        exps=exps+fabaoexp.exp
    end

    local fabaoshop = BeanConfigManager.getInstance():GetTableByName("item.cfabaomenpai"):getRecorder(_idx-100)
    local cuexp=0
    if fabaos[_idx].level<10 then
        for index=1,fabaos[_idx].level-1 do
            local fabaoexpx = BeanConfigManager.getInstance():GetTableByName("item.cfabaoexp"):getRecorder(index)
            cuexp=cuexp+fabaoexpx.exp
        end
      --  local fabaoexpx = BeanConfigManager.getInstance():GetTableByName("item.cfabaoexp"):getRecorder(fabaos[_idx].level)

        cuexp=cuexp+fabaos[_idx].exp
        local nExpScale = cuexp / exps
        --self.m_gressExp:setText(data.exp .. "/" .. crc.nextexp)
        self.m_gressExp:setProgress(nExpScale)
    else
        self.m_gressExp:setProgress(1)
    end
    self.level:setText(fabaos[_idx].level)
    self.name:setText(fabaoshop.name)

    local img = gGetIconManager():GetImageByID(fabaoshop.icon)
    self.item1:SetImage(img)


    --local fabaotexiao = BeanConfigManager.getInstance():GetTableByName("item.cfabaotexiao"):getRecorder(_idx)


    local itemattr = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(fabaoshop.jinjieitem)

    local img2 = gGetIconManager():GetImageByID(itemattr.icon)

    self.item2:SetImage(img2)

    self.itemname:setText(itemattr.name)

    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    local mymoney=roleItemManager:GetItemNumByBaseID(fabaoshop.jinjieitem)


    local num=fabaoshop.jinjieitemnums[fabaos[_idx].jinjie]

    local strNumNeed_own1 = mymoney.."/"..num

    self.itemnum:setText(strNumNeed_own1)

    if mymoney >= num then
        self.itemnum:SetTextColor(0xffffffff)
    else
        self.itemnum:SetTextColor(0xfffd0303)
    end





    --local xiuliannum1 = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(522).value)
    --local xiuliannum2=xiuliannum1-fabaos[_idx].num
    --self.xiuliannum:setText(xiuliannum2.."/"..xiuliannum1)
    --
    --
    --
    --
    --
    --self.level1:setText(fabaos[_idx].level)
    --if fabaos[_idx].level>=10 then
    --    self.level2:setText(0)
    --else
    --    self.level2:setText(fabaos[_idx].level+1)
    --end
    --
    --
    --local totalSilver = CurrencyManager.getOwnCurrencyMount(1)
    --
    --
    --local Skill1 = BeanConfigManager.getInstance():GetTableByName("skill.cequipskill"):getRecorder(fabaos[_idx].texiao1)
    --self.jieshao1:setText(Skill1.describe)
    --
    --if fabaos[_idx].level+1 < 10 then
    --    local level=fabaos[_idx].level
    --    local fabaotexiao = BeanConfigManager.getInstance():GetTableByName("item.cfabaotexiao"):getRecorder(_idx)
    --    local EquipSkill = BeanConfigManager.getInstance():GetTableByName("skill.cequipskill"):getRecorder(fabaotexiao.texiaos[level])
    --    self.jieshao2:setText(EquipSkill.describe)
    --end
    --
    --self.jiage:setText(30000)
    --self.yongyou:setText(totalSilver)
end
function FaBaoMenPaiJinJie:HandleJinJieClick(arg)
    if _idx==0 then
        return
    end
    local p = require("logic.item.fabao.cfabaoshopUp"):new()
    p.idx = _idx
    p.leixing=14
    LuaProtocolManager:send(p)
    self.DestroyDialog()
end


function FaBaoMenPaiJinJie.getInstance()
    if not _instance then
        _instance = FaBaoMenPaiJinJie:new()
        _instance:OnCreate()
    end
    return _instance
end

function FaBaoMenPaiJinJie.getInstanceAndShow()

    if not _instance then
        _instance = FaBaoMenPaiJinJie:new()
        _instance:OnCreate()
    else
        _instance:SetVisible(true)
    end
    return _instance
end

function FaBaoMenPaiJinJie.getInstanceNotCreate()
    return _instance
end

function FaBaoMenPaiJinJie.getInstanceOrNot()
    return _instance
end

function FaBaoMenPaiJinJie.GetLayoutFileName()
    return "fabaomenpaijinjie.layout"
end

function FaBaoMenPaiJinJie:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, FaBaoMenPaiJinJie)
    self:ClearData()
    return self
end

function FaBaoMenPaiJinJie.DestroyDialog()
    if not _instance then
        return
    end
    if not _instance.m_bCloseIsHide then
        _instance:OnClose()
        _instance = nil
    else
        _instance:ToggleOpenClose()
    end
end
function FaBaoMenPaiJinJie.ToggleOpenClose()
    if not _instance then
        _instance = FaBaoMenPaiJinJie:new()
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function FaBaoMenPaiJinJie:ClearData()
    self.nItemCellSelId = 0
    self.ScrollEquip = {}
    self.bLoadUI = false
    self.fRefreshLeftDt = 0
    self.vItemCellHero = {}
end

--[[
function FaBaoMenPaiJinJie:ClearDataInClose()
	self.nItemCellSelId = 0
	self.ScrollEquip = nil
	self.bLoadUI = false
end
--]]

function FaBaoMenPaiJinJie:ClearCellAll()
end

function FaBaoMenPaiJinJie:OnClose()
    Dialog.OnClose(self)
    _instance = nil
    --require("logic.jingji.jingjipipeidialog3").DestroyDialog()
end

return FaBaoMenPaiJinJie
