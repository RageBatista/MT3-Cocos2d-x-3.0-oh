require "utils.mhsdutils"
require "logic.dialog"

require "utils.commonutil"

FaBaoMenPai = {}
setmetatable(FaBaoMenPai, Dialog)
FaBaoMenPai.__index = FaBaoMenPai
local _instance;
--//===============================
function FaBaoMenPai:OnCreate()
    Dialog.OnCreate(self)
    SetPositionScreenCenter(self:GetWindow())
    local winMgr = CEGUI.WindowManager:getSingleton()
    --
	
	
    self.item1 = CEGUI.toItemCell(winMgr:getWindow("fabaomenpai/cell/item"));
    self.tx = winMgr:getWindow("fabaomenpai/mid/text")
	
    --self.item2 = CEGUI.toItemCell(winMgr:getWindow("fabaoxilian/item"));
    self.jieshao = winMgr:getWindow("fabaomenpai/mid/text11")
    --
    self.name = winMgr:getWindow("fabaomenpai/mid/text1")
    --self.itemnum = winMgr:getWindow("fabaoxilian/itemnum")
    --self.itemname = winMgr:getWindow("fabaoxilian/itemname")
    --
    --
    ----self:UpdateProData()

    local menpai = BeanConfigManager.getInstance():GetTableByName("item.cfabaomenpai"):getRecorder(gGetDataManager():GetMainCharacterSchoolID())
    self.name:setText(menpai.name)
    local img = gGetIconManager():GetImageByID(menpai.icon)
    self.item1:SetImage(img)

    local EquipSkill = BeanConfigManager.getInstance():GetTableByName("skill.cequipskill"):getRecorder(menpai.texiaos[0])
    self.jieshao:setText(EquipSkill.describe)
    --self.selectedItemId = 0
    --local p = require("logic.item.fabao.cfabaoshopsl"):new()
    --LuaProtocolManager:send(p)
   -- self:refreshFaBaoMenPaiList()
    self.guanbi = CEGUI.toPushButton(winMgr:getWindow("fabaomenpai/guanbi"))
    self.guanbi:subscribeEvent("MouseButtonUp", FaBaoMenPai.HandleguanbiClick, self)
    self.btn = CEGUI.toPushButton(winMgr:getWindow("fabaomenpai/btn"))
    self.btn:subscribeEvent("MouseButtonUp", FaBaoMenPai.HandleClick, self)
end
function FaBaoMenPai:HandleguanbiClick(arg)
    self.DestroyDialog()
end
function FaBaoMenPai:HandleClick(arg)
    self.DestroyDialog()
    require "logic.item.fabao.fabaomenpai1".getInstanceAndShow()

end


function FaBaoMenPai.getInstance()
    if not _instance then
        _instance = FaBaoMenPai:new()
        _instance:OnCreate()
    end
    return _instance
end

function FaBaoMenPai.getInstanceAndShow()
    if not _instance then
        _instance = FaBaoMenPai:new()
        _instance:OnCreate()
    else
        _instance:SetVisible(true)
    end
    return _instance
end

function FaBaoMenPai.getInstanceNotCreate()
    return _instance
end

function FaBaoMenPai.getInstanceOrNot()
    return _instance
end

function FaBaoMenPai.GetLayoutFileName()
    return "fabaomenpai.layout"
end

function FaBaoMenPai:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, FaBaoMenPai)
    self:ClearData()
    return self
end

function FaBaoMenPai.DestroyDialog()
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
function FaBaoMenPai.ToggleOpenClose()
    if not _instance then
        _instance = FaBaoMenPai:new()
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function FaBaoMenPai:ClearData()
    self.nItemCellSelId = 0
    self.ScrollEquip = {}
    self.bLoadUI = false
    self.fRefreshLeftDt = 0
    self.vItemCellHero = {}
end

--[[
function FaBaoMenPai:ClearDataInClose()
	self.nItemCellSelId = 0
	self.ScrollEquip = nil
	self.bLoadUI = false
end
--]]

function FaBaoMenPai:ClearCellAll()
end

function FaBaoMenPai:OnClose()
    Dialog.OnClose(self)
    _instance = nil
    --require("logic.jingji.jingjipipeidialog3").DestroyDialog()
end

return FaBaoMenPai
