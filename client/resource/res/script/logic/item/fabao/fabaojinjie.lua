require "utils.mhsdutils"
require "logic.dialog"

require "utils.commonutil"

FaBaoJinJie = {}
setmetatable(FaBaoJinJie, Dialog)
FaBaoJinJie.__index = FaBaoJinJie
local _instance;
local _idx;
--//===============================
function FaBaoJinJie:OnCreate()
    Dialog.OnCreate(self)
    SetPositionScreenCenter(self:GetWindow())
    local winMgr = CEGUI.WindowManager:getSingleton()

    self.name = winMgr:getWindow("fabaojinjie/name")

    self.m_gressExp = CEGUI.toProgressBar(winMgr:getWindow("fabaojinjie/exp"))
    self.item1 = CEGUI.toItemCell(winMgr:getWindow("fabaojinjie/item1"));
    self.item2 = CEGUI.toItemCell(winMgr:getWindow("fabaojinjie/item"));


    self.jieshao1 = winMgr:getWindow("fabaojinjie/di11/jieshao1")


    self.itemnum = winMgr:getWindow("fabaojinjie/itemnum")
    self.itemname = winMgr:getWindow("fabaojinjie/itemname")


    --self:UpdateProData()
    self.jinjie = CEGUI.toPushButton(winMgr:getWindow("fabaojinjie/bt"))
    self.jinjie:subscribeEvent("MouseButtonUp", FaBaoJinJie.HandleJinJieClick, self)

    self.selectedItemId = 0
    local p = require("logic.item.fabao.cfabaoshopsl"):new()
    LuaProtocolManager:send(p)
   -- self:refreshFaBaoJinJieList()
end

function FaBaoJinJie:UpdateProData(fabaos)

    local fabaoexps = BeanConfigManager.getInstance():GetTableByName("item.cfabaoexp"):getAllID()
    local exps=0
    for _,id in pairs(fabaoexps) do
        local fabaoexp = BeanConfigManager.getInstance():GetTableByName("item.cfabaoexp"):getRecorder(id)
        exps=exps+fabaoexp.exp
    end

    local fabaoshop = BeanConfigManager.getInstance():GetTableByName("item.cfabaoshop"):getRecorder(_idx)
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

    self.name:setText(fabaoshop.name)

    local img = gGetIconManager():GetImageByID(fabaoshop.icon)
    self.item1:SetImage(img)


    local fabaotexiao = BeanConfigManager.getInstance():GetTableByName("item.cfabaotexiao"):getRecorder(_idx)


    local itemattr = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(fabaotexiao.jinjieitem)

    local img2 = gGetIconManager():GetImageByID(itemattr.icon)

    self.item2:SetImage(img2)

    self.itemname:setText(itemattr.name)

    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    local mymoney=roleItemManager:GetItemNumByBaseID(fabaotexiao.jinjieitem)


    local num=fabaotexiao.jinjieitemnums[fabaos[_idx].jinjie]

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
function FaBaoJinJie:HandleJinJieClick(arg)
    if _idx==0 then
        return
    end
    local p = require("logic.item.fabao.cfabaoshopUp"):new()
    p.idx = _idx
    p.leixing=3
    LuaProtocolManager:send(p)
    self.DestroyDialog()
end


function FaBaoJinJie.getInstance()
    if not _instance then
        _instance = FaBaoJinJie:new()
        _instance:OnCreate()
    end
    return _instance
end

function FaBaoJinJie.getInstanceAndShow(idx)
    _idx=idx
    if not _instance then
        _instance = FaBaoJinJie:new()
        _instance:OnCreate()
    else
        _instance:SetVisible(true)
    end
    return _instance
end

function FaBaoJinJie.getInstanceNotCreate()
    return _instance
end

function FaBaoJinJie.getInstanceOrNot()
    return _instance
end

function FaBaoJinJie.GetLayoutFileName()
    return "fabaojinjie.layout"
end

function FaBaoJinJie:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, FaBaoJinJie)
    self:ClearData()
    return self
end

function FaBaoJinJie.DestroyDialog()
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
function FaBaoJinJie.ToggleOpenClose()
    if not _instance then
        _instance = FaBaoJinJie:new()
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function FaBaoJinJie:ClearData()
    self.nItemCellSelId = 0
    self.ScrollEquip = {}
    self.bLoadUI = false
    self.fRefreshLeftDt = 0
    self.vItemCellHero = {}
end

--[[
function FaBaoJinJie:ClearDataInClose()
	self.nItemCellSelId = 0
	self.ScrollEquip = nil
	self.bLoadUI = false
end
--]]

function FaBaoJinJie:ClearCellAll()
end

function FaBaoJinJie:OnClose()
    Dialog.OnClose(self)
    _instance = nil
    --require("logic.jingji.jingjipipeidialog3").DestroyDialog()
end

return FaBaoJinJie
