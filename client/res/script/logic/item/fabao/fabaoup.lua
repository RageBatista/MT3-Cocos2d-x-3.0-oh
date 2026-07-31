require "utils.mhsdutils"
require "logic.dialog"

require "utils.commonutil"

FaBaoUp = {}
setmetatable(FaBaoUp, Dialog)
FaBaoUp.__index = FaBaoUp
local _instance;
local _idx;
--//===============================
function FaBaoUp:OnCreate()
    Dialog.OnCreate(self)
    SetPositionScreenCenter(self:GetWindow())
    local winMgr = CEGUI.WindowManager:getSingleton()

    self.name = winMgr:getWindow("fabaoup/name")
    self.level1 = winMgr:getWindow("fabaoup/di11/level1")
    self.level2 = winMgr:getWindow("fabaoup/di11/level2")
    self.exp = winMgr:getWindow("fabaoup/di11/exp")

    self.item1 = CEGUI.toItemCell(winMgr:getWindow("fabaoup/item1"));
    self.item2 = CEGUI.toItemCell(winMgr:getWindow("fabaoup/item"));

    self.jieshao1 = winMgr:getWindow("fabaoup/di11/jieshao1")
    self.jieshao2 = winMgr:getWindow("fabaoup/di11/jieshao2")

    self.xa = winMgr:getWindow("fabaoup/xxaa")
    self.xb = winMgr:getWindow("fabaoup/xxbb")
    self.xc = winMgr:getWindow("fabaoup/xxcc")


    self.axaa = winMgr:getWindow("fabaoup/axxaa")
    self.axbb = winMgr:getWindow("fabaoup/axxbb")
    self.axcc = winMgr:getWindow("fabaoup/axxcc")

    self.axxaa = winMgr:getWindow("fabaoup/xxa")
    self.axxbb = winMgr:getWindow("fabaoup/xaxa")
    self.axxcc = winMgr:getWindow("fabaoup/xbxa")

    self.aa = winMgr:getWindow("fabaoup/xxb")
    self.bb = winMgr:getWindow("fabaoup/xxc")

    self.m_gressExp = CEGUI.toProgressBar(winMgr:getWindow("fabaoup/exp"))


    self.jiage = winMgr:getWindow("fabaoup/textzong")
    self.yongyou = winMgr:getWindow("fabaoup/textdan")

    self.xiuliannum = winMgr:getWindow("fabaoup/name11")

    --self:UpdateProData()
    self.xiulian1 = CEGUI.toPushButton(winMgr:getWindow("fabaoup/bt1"))
    self.xiulian1:subscribeEvent("MouseButtonUp", FaBaoUp.HandleXiuLianClick1, self)
    self.xiulian10 = CEGUI.toPushButton(winMgr:getWindow("fabaoup/bt10"))
    self.xiulian10:subscribeEvent("MouseButtonUp", FaBaoUp.HandleXiuLianClick10, self)
    self.xiulian2 = CEGUI.toPushButton(winMgr:getWindow("fabaoup/bt2"))
    self.xiulian2:subscribeEvent("MouseButtonUp", FaBaoUp.HandleXiuLianClick, self)
    self.selectedItemId = 0
    local p = require("logic.item.fabao.cfabaoshopsl"):new()
    LuaProtocolManager:send(p)
   -- self:refreshFaBaoUpList()
end


function FaBaoUp:UpdateProData(fabaos)
     if fabaos[_idx].level < 5 then
	 self.axxaa:setVisible(true)
	 self.axxbb:setVisible(false)
	 elseif fabaos[_idx].level >= 5 and fabaos[_idx].level < 8 then
	 self.aa:setVisible(false)
	 self.axxbb:setVisible(true)
	 self.axxaa:setVisible(true)
	 elseif fabaos[_idx].level >= 8 and fabaos[_idx].level < 10 then
	 self.axxcc:setVisible(true)
	 self.bb:setVisible(false)
	 end
	 
     if fabaos[_idx].jinjie == 1 then
	 self.xa:setVisible(true)
	 self.axaa:setVisible(true)
	 elseif fabaos[_idx].jinjie == 2 then
	 self.xa:setVisible(true)
	 self.xb:setVisible(true)
	 self.axaa:setVisible(true)
	 self.axbb:setVisible(true)
	 elseif fabaos[_idx].jinjie == 3 then
	 self.xa:setVisible(true)
	 self.xb:setVisible(true)
	 self.xc:setVisible(true)
	 self.axaa:setVisible(true)
	 self.axbb:setVisible(true)
	 self.axcc:setVisible(true)
	 end

    if (fabaos[_idx].level>=5 and fabaos[_idx].jinjie==0) or (fabaos[_idx].level>=8 and fabaos[_idx].jinjie==1) or (fabaos[_idx].level>=10 and fabaos[_idx].jinjie==2) then


        local function ClickYes(self, args)
            gGetMessageManager():CloseConfirmBox(eConfirmNormal, false)
            if _instance then
                _instance.DestroyDialog()
            end
            require "logic.item.fabao.fabaojinjie".getInstanceAndShow(_idx)

        end
        local function ClickNo(self, args)
            gGetMessageManager():CloseConfirmBox(eConfirmNormal, false)
            if _instance then
                _instance.DestroyDialog()
            end
        end

        local text = MHSD_UTILS.get_resstring(11723)
        gGetMessageManager():AddConfirmBox(eConfirmNormal, text, ClickYes,
                self, ClickNo, self,0,0,nil,MHSD_UTILS.get_resstring(11724),MHSD_UTILS.get_resstring(11725))
    end



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
        local fabaoexpx = BeanConfigManager.getInstance():GetTableByName("item.cfabaoexp"):getRecorder(fabaos[_idx].level)
        self.exp:setText(fabaos[_idx].exp.."/"..fabaoexpx.exp)
        cuexp=cuexp+fabaos[_idx].exp
        local nExpScale = cuexp / exps
        --self.m_gressExp:setText(data.exp .. "/" .. crc.nextexp)
        self.m_gressExp:setProgress(nExpScale)
    else
        self.exp:setText(fabaos[_idx].exp.."/0")
        self.m_gressExp:setProgress(1)
    end

    local xiuliannum1 = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(523).value)
    local xiuliannum2=xiuliannum1-fabaos[_idx].num
    self.xiuliannum:setText(xiuliannum2.."/"..xiuliannum1)





    local itemid = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(521).value)
    local itemattr = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(itemid)

    local img = gGetIconManager():GetImageByID(fabaoshop.icon)
    self.item1:SetImage(img)

    local img2 = gGetIconManager():GetImageByID(itemattr.icon)
    self.item2:SetImage(img2)

    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    local mymoney=roleItemManager:GetItemNumByBaseID(itemid)
    self.item2:SetTextUnit(mymoney)



    self.name:setText(fabaoshop.name)
    self.level1:setText(fabaos[_idx].level)
    if fabaos[_idx].level>=10 then
        self.level2:setText(0)
    else
        self.level2:setText(fabaos[_idx].level+1)
    end


    local totalSilver = CurrencyManager.getOwnCurrencyMount(1)


    local Skill1 = BeanConfigManager.getInstance():GetTableByName("skill.cequipskill"):getRecorder(fabaos[_idx].texiao1)
    self.jieshao1:setText(Skill1.describe)

    if fabaos[_idx].level+1 <= 10 then
        local level=fabaos[_idx].level
        local fabaotexiao = BeanConfigManager.getInstance():GetTableByName("item.cfabaotexiao"):getRecorder(_idx)
        local EquipSkill = BeanConfigManager.getInstance():GetTableByName("skill.cequipskill"):getRecorder(fabaotexiao.texiaos[level])
        self.jieshao2:setText(EquipSkill.describe)
    end
    local moneyx=tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(525).value)
    self.jiage:setText(moneyx)
	if totalSilver < moneyx then
    self.yongyou:setText(totalSilver)
	self.yongyou:setProperty("TextColours", "FFFF0000")
	else
    self.yongyou:setText(totalSilver)
	self.yongyou:setProperty("TextColours", "FFEDE0CF")
	end
	
	
end
function FaBaoUp:HandleXiuLianClick(arg)
    local itemid = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(521).value)
    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    local mymoney=roleItemManager:GetItemNumByBaseID(itemid)
    if mymoney<1 then
        return
    end
    if _idx==0 then
        return
    end
    local p = require("logic.item.fabao.cfabaoshopUp"):new()
    p.idx = _idx
    p.leixing=2
    LuaProtocolManager:send(p)
end
function FaBaoUp:HandleXiuLianClick1(arg)

    if _idx==0 then
        return
    end
    local p = require("logic.item.fabao.cfabaoshopUp"):new()
    p.idx = _idx
    p.leixing=1
    LuaProtocolManager:send(p)
end
function FaBaoUp:HandleXiuLianClick10(arg)
    if _idx==0 then
        return
    end
    local p = require("logic.item.fabao.cfabaoshopUp"):new()
    p.idx = _idx
    p.leixing=10
    LuaProtocolManager:send(p)
end


function FaBaoUp.getInstance()
    if not _instance then
        _instance = FaBaoUp:new()
        _instance:OnCreate()
    end
    return _instance
end

function FaBaoUp.getInstanceAndShow(idx)
    _idx=idx
    if not _instance then
        _instance = FaBaoUp:new()
        _instance:OnCreate()
    else
        _instance:SetVisible(true)
    end
    return _instance
end

function FaBaoUp.getInstanceNotCreate()
    return _instance
end

function FaBaoUp.getInstanceOrNot()
    return _instance
end

function FaBaoUp.GetLayoutFileName()
    return "fabaoup.layout"
end

function FaBaoUp:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, FaBaoUp)
    self:ClearData()
    return self
end

function FaBaoUp.DestroyDialog()
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
function FaBaoUp.ToggleOpenClose()
    if not _instance then
        _instance = FaBaoUp:new()
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function FaBaoUp:ClearData()
    self.nItemCellSelId = 0
    self.ScrollEquip = {}
    self.bLoadUI = false
    self.fRefreshLeftDt = 0
    self.vItemCellHero = {}
end

--[[
function FaBaoUp:ClearDataInClose()
	self.nItemCellSelId = 0
	self.ScrollEquip = nil
	self.bLoadUI = false
end
--]]

function FaBaoUp:ClearCellAll()
end

function FaBaoUp:OnClose()
    Dialog.OnClose(self)
    _instance = nil
    --require("logic.jingji.jingjipipeidialog3").DestroyDialog()
end

return FaBaoUp
