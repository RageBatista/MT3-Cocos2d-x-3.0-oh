require "utils.mhsdutils"
require "logic.dialog"

require "utils.commonutil"

FaBaoXiLian = {}
setmetatable(FaBaoXiLian, Dialog)
FaBaoXiLian.__index = FaBaoXiLian
local _instance;
local _idx;
local _index;
--//===============================
function FaBaoXiLian:OnCreate()
    Dialog.OnCreate(self)
    SetPositionScreenCenter(self:GetWindow())
    local winMgr = CEGUI.WindowManager:getSingleton()

    self.item1 = CEGUI.toItemCell(winMgr:getWindow("fabaoxilian/item1"));
    self.item2 = CEGUI.toItemCell(winMgr:getWindow("fabaoxilian/item"));


    self.jieshao1 = winMgr:getWindow("fabaoxilian/di11/jieshao1")

    self.name = winMgr:getWindow("fabaoxilian/di11/texiaoname")
    self.itemnum = winMgr:getWindow("fabaoxilian/itemnum")
    self.itemname = winMgr:getWindow("fabaoxilian/itemname")


    --self:UpdateProData()
    self.jinjie = CEGUI.toPushButton(winMgr:getWindow("fabaoxilian/bt"))
    self.jinjie:subscribeEvent("MouseButtonUp", FaBaoXiLian.HandleXiLianClick, self)

    self.selectedItemId = 0
    local p = require("logic.item.fabao.cfabaoshopsl"):new()
    LuaProtocolManager:send(p)
   -- self:refreshFaBaoXiLianList()
end

function FaBaoXiLian:UpdateProData(fabaos)


   -- local fabaoshop = BeanConfigManager.getInstance():GetTableByName("item.cfabaoshop"):getRecorder(_idx)


    if _index==1 then
        local EquipSkill = BeanConfigManager.getInstance():GetTableByName("skill.cequipskill"):getRecorder(fabaos[_idx].texiao2)
        local img = gGetIconManager():GetImageByID(EquipSkill.icon)
        self.item1:SetImage(img)
        self.jieshao1:setText(EquipSkill.describe)
		self.jieshao1:setProperty("TextColours", "FF723b06")
        self.name:setText(EquipSkill.name)
    end
    if _index==2 then
        local EquipSkill = BeanConfigManager.getInstance():GetTableByName("skill.cequipskill"):getRecorder(fabaos[_idx].texiao3)
        local img = gGetIconManager():GetImageByID(EquipSkill.icon)
        self.item1:SetImage(img)
        self.jieshao1:setText(EquipSkill.describe)
		self.jieshao1:setProperty("TextColours", "FF723b06")
        self.name:setText(EquipSkill.name)
    end
    if _index==3 then
        local EquipSkill = BeanConfigManager.getInstance():GetTableByName("skill.cequipskill"):getRecorder(fabaos[_idx].texiao4)
        local img = gGetIconManager():GetImageByID(EquipSkill.icon)
        self.item1:SetImage(img)
        self.jieshao1:setText(EquipSkill.describe)
		self.jieshao1:setProperty("TextColours", "FF723b06")
        self.name:setText(EquipSkill.name)
    end
    if _index==4 then
        local EquipSkill = BeanConfigManager.getInstance():GetTableByName("skill.cequipskill"):getRecorder(fabaos[_idx].texiao5)
        local img = gGetIconManager():GetImageByID(EquipSkill.icon)
        self.item1:SetImage(img)
        self.jieshao1:setText(EquipSkill.describe)
		self.jieshao1:setProperty("TextColours", "FF723b06")
        self.name:setText(EquipSkill.name)
    end

    local fabaotexiao = BeanConfigManager.getInstance():GetTableByName("item.cfabaotexiao"):getRecorder(_idx)
    if _idx>100 then
        fabaotexiao = BeanConfigManager.getInstance():GetTableByName("item.cfabaomenpai"):getRecorder(_idx-100)
    end

    local itemattr = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(fabaotexiao.xilianitem)

    local img2 = gGetIconManager():GetImageByID(itemattr.icon)

    self.item2:SetImage(img2)

    self.itemname:setText(itemattr.name)

    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    local mymoney=roleItemManager:GetItemNumByBaseID(fabaotexiao.xilianitem)


    local num=fabaotexiao.xilianitemnums[_index-1]

    local strNumNeed_own1 = mymoney.."/"..num

    self.itemnum:setText(strNumNeed_own1)

    if mymoney >= num then
        self.itemnum:SetTextColor(0xffffffff)
    else
        self.itemnum:SetTextColor(0xfffd0303)
    end

end
function FaBaoXiLian:HandleXiLianClick(arg)
    if _idx==0 then
        return
    end
    local p = require("logic.item.fabao.cfabaoshopUp"):new()
    p.idx = _idx
    p.leixing=3+_index
    LuaProtocolManager:send(p)
  --  self.DestroyDialog()
end


function FaBaoXiLian.getInstance()
    if not _instance then
        _instance = FaBaoXiLian:new()
        _instance:OnCreate()
    end
    return _instance
end

function FaBaoXiLian.getInstanceAndShow(idx,index)
    _idx=idx
    _index=index
    if not _instance then
        _instance = FaBaoXiLian:new()
        _instance:OnCreate()
    else
        _instance:SetVisible(true)
    end
    return _instance
end

function FaBaoXiLian.getInstanceNotCreate()
    return _instance
end

function FaBaoXiLian.getInstanceOrNot()
    return _instance
end

function FaBaoXiLian.GetLayoutFileName()
    return "fabaoxilian.layout"
end

function FaBaoXiLian:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, FaBaoXiLian)
    self:ClearData()
    return self
end

function FaBaoXiLian.DestroyDialog()
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
function FaBaoXiLian.ToggleOpenClose()
    if not _instance then
        _instance = FaBaoXiLian:new()
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function FaBaoXiLian:ClearData()
    self.nItemCellSelId = 0
    self.ScrollEquip = {}
    self.bLoadUI = false
    self.fRefreshLeftDt = 0
    self.vItemCellHero = {}
end

--[[
function FaBaoXiLian:ClearDataInClose()
	self.nItemCellSelId = 0
	self.ScrollEquip = nil
	self.bLoadUI = false
end
--]]

function FaBaoXiLian:ClearCellAll()
end

function FaBaoXiLian:OnClose()
    Dialog.OnClose(self)
    _instance = nil
    --require("logic.jingji.jingjipipeidialog3").DestroyDialog()
end

return FaBaoXiLian
