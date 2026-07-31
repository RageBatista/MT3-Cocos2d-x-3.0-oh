require "utils.mhsdutils"
require "logic.dialog"

require "utils.commonutil"

FaBaoMenPaiMain = {}
setmetatable(FaBaoMenPaiMain, Dialog)
FaBaoMenPaiMain.__index = FaBaoMenPaiMain
local _instance;
local _idx;
--//===============================
function FaBaoMenPaiMain:OnCreate()
    Dialog.OnCreate(self)
    SetPositionScreenCenter(self:GetWindow())
    local winMgr = CEGUI.WindowManager:getSingleton()


    self.icon = CEGUI.toItemCell(winMgr:getWindow("fabaomenpaimain/x5"));
    self.texiao1 = CEGUI.toItemCell(winMgr:getWindow("fabaomenpaimain/x1"));
    self.texiao2 = CEGUI.toItemCell(winMgr:getWindow("fabaomenpaimain/x2"));
    self.texiao3 = CEGUI.toItemCell(winMgr:getWindow("fabaomenpaimain/x3"));
    self.texiao33 = CEGUI.toItemCell(winMgr:getWindow("fabaomenpaimain/x33"));
    self.texiao4 = CEGUI.toItemCell(winMgr:getWindow("fabaomenpaimain/x4"));
    self.texiao1text = winMgr:getWindow("fabaomenpaimain/texiao1")
    self.texiao2text = winMgr:getWindow("fabaomenpaimain/texiao2")
    self.texiao3text = winMgr:getWindow("fabaomenpaimain/texiao3")
    self.texiao4text = winMgr:getWindow("fabaomenpaimain/texiao4")
	
    self.texiao1text1 = winMgr:getWindow("fabaomenpaimain/suo1")
    self.texiao2text2 = winMgr:getWindow("fabaomenpaimain/suo2")
    self.texiao3text3 = winMgr:getWindow("fabaomenpaimain/suo3")
	
    self.xja = winMgr:getWindow("fabaomenpaimain/xj11")
    self.xjb = winMgr:getWindow("fabaomenpaimain/xj22")
    self.xjc = winMgr:getWindow("fabaomenpaimain/xj33")
	
    self.texiao4text4 = winMgr:getWindow("fabaomenpaimain/mt44")
	
    self.lt = winMgr:getWindow("fabaomenpaimain/lutng")
	-- gGetGameUIManager():AddUIEffect(self.lt, MHSD_UTILS.get_effectpath(11096), true)
    self.level = winMgr:getWindow("fabaomenpaimain/levela")
    self.name = winMgr:getWindow("fabaomenpaimain/name")
    self.zhiye = winMgr:getWindow("fabaomenpaimain/zhiyetb")
    self.menpi = winMgr:getWindow("fabaomenpaimain/menpai")
    self.jieshao = winMgr:getWindow("fabaomenpaimain/jieshao")
    self.xiulian = CEGUI.toPushButton(winMgr:getWindow("fabaomenpaimain/tidya"))
    self.xiulian2 = CEGUI.toPushButton(winMgr:getWindow("fabaomenpaimain/tidyb"))
    self.selectedItem = 0
    self.fabaos={}
    self.xiulian:subscribeEvent("MouseButtonUp", FaBaoMenPaiMain.HandleXiuLianClick, self)
    self.texiao1:subscribeEvent(CEGUI.ItemCell.EventCellClick, FaBaoMenPaiMain.HandlePackBtnClicked, self);
    self.texiao2:subscribeEvent(CEGUI.ItemCell.EventCellClick, FaBaoMenPaiMain.HandlePackBtnClicked, self);
    self.texiao3:subscribeEvent(CEGUI.ItemCell.EventCellClick, FaBaoMenPaiMain.HandlePackBtnClicked, self);
    self.texiao4:subscribeEvent(CEGUI.ItemCell.EventCellClick, FaBaoMenPaiMain.HandlePackBtnClicked, self);

    local p = require("logic.item.fabao.cfabaoshopsl"):new()
    LuaProtocolManager:send(p)
   -- self:refreshFaBaoMenPaiMainList()
end
function FaBaoMenPaiMain:HandleXiuLianClick(arg)
    require "logic.item.fabao.fabaomenpaiup".getInstanceAndShow()
end
function FaBaoMenPaiMain:UpdateProData(fabaos)
    for first, second in pairs(fabaos) do

        self.fabaos[first]=second
    end
    local idx=gGetDataManager():GetMainCharacterSchoolID()+100
    self.selectedItem=idx
    local fabao = BeanConfigManager.getInstance():GetTableByName("item.cfabaomenpai"):getRecorder(gGetDataManager():GetMainCharacterSchoolID())
    local img = gGetIconManager():GetImageByID(fabao.icon)
    self.icon:SetImage(img)
	
    local schoolConfig = BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(gGetDataManager():GetMainCharacterSchoolID())
    self.zhiye:setProperty("Image", schoolConfig.schooliconpath)
    --self.menpi:setProperty("Image", schoolConfig.schooliconpath)
    self.name:setText(fabao.name)
	self.level:setText("等级"..fabaos[idx].level)
	--print("eeeeeeeeeeee="..fabaos[idx].level)
	
    if fabaos[idx].level == 5 then
	self.xja:setVisible(true)
	elseif fabaos[idx].level == 8 then
	self.xja:setVisible(true)
	self.xjb:setVisible(true)
	elseif fabaos[idx].level == 10 then
	self.xja:setVisible(true)
	self.xjb:setVisible(true)
	self.xjc:setVisible(true)
	end
	if fabaos[idx].level == 10 and fabaos[idx].jinjie>=3 then
	     self.xiulian2:setVisible(true)
	     self.xiulian:setVisible(false)
        else
	     self.xiulian2:setVisible(false)
	     self.xiulian:setVisible(true)
        end


    if fabaos[idx].texiao1>0 then
        local EquipSkill = BeanConfigManager.getInstance():GetTableByName("skill.cequipskill"):getRecorder(fabaos[idx].texiao1)
        self.jieshao:setText(EquipSkill.describe)

    end
    
	

	
    self.texiao1text:setText(MHSD_UTILS.get_resstring(11722))
    self.texiao2text:setText(MHSD_UTILS.get_resstring(11722))
    self.texiao3text:setText(MHSD_UTILS.get_resstring(11722))
    self.texiao4text:setText(MHSD_UTILS.get_resstring(11722))
    self.texiao1:SetImage(nil)
    self.texiao2:SetImage(nil)
    self.texiao3:SetImage(nil)
    self.texiao4:SetImage(nil)
    self.texiao1:setID(0)
    self.texiao2:setID(0)
    self.texiao3:setID(0)
    self.texiao4:setID(0)
    if fabaos[idx].texiao2>0 then
        local EquipSkill = BeanConfigManager.getInstance():GetTableByName("skill.cequipskill"):getRecorder(fabaos[idx].texiao2)
        self.texiao1text:setText(EquipSkill.name)
        local img = gGetIconManager():GetImageByID(EquipSkill.icon)
        self.texiao1:SetImage(img)
        self.texiao1:setID(1)
	self.texiao1text1:setVisible(false)
    end
    if fabaos[idx].texiao3>0 then
        local EquipSkill = BeanConfigManager.getInstance():GetTableByName("skill.cequipskill"):getRecorder(fabaos[idx].texiao3)
        self.texiao2text:setText(EquipSkill.name)
        local img = gGetIconManager():GetImageByID(EquipSkill.icon)
        self.texiao2:SetImage(img)
        self.texiao2:setID(2)
    self.texiao2text2:setVisible(false)
    end
    if fabaos[idx].texiao4>0 then
        local EquipSkill = BeanConfigManager.getInstance():GetTableByName("skill.cequipskill"):getRecorder(fabaos[idx].texiao4)
        self.texiao3text:setText(EquipSkill.name)
        local img = gGetIconManager():GetImageByID(EquipSkill.icon)
        self.texiao3:SetImage(img)
        self.texiao3:setID(3)
    self.texiao3text3:setVisible(false)
    end
    if fabaos[idx].texiao5>0 then
        local EquipSkill = BeanConfigManager.getInstance():GetTableByName("skill.cequipskill"):getRecorder(fabaos[idx].texiao5)
        self.texiao4text:setText(EquipSkill.name)
        local img = gGetIconManager():GetImageByID(EquipSkill.icon)
        self.texiao4:SetImage(img)
        self.texiao4:setID(4)
        self.texiao33:setVisible(false)
        self.texiao4text4:setVisible(false)
    end
end
function FaBaoMenPaiMain:HandlePackBtnClicked(args)
    local wnd = CEGUI.toWindowEventArgs(args).window
    local cell = CEGUI.toItemCell(wnd)
    local idx = cell:getID()
    if idx==0 then
        return
    end
    local function ClickYes(self, args)
        gGetMessageManager():CloseConfirmBox(eConfirmNormal, false)
        require "logic.item.fabao.fabaoxilian".getInstanceAndShow(self.selectedItem,idx)
    end
    local function ClickNo(self, args)
        gGetMessageManager():CloseConfirmBox(eConfirmNormal, false)
    end
    local texiaoid=0
    if idx==1 then
        texiaoid=self.fabaos[self.selectedItem].texiao2
    end
    if idx==2 then
        texiaoid=self.fabaos[self.selectedItem].texiao3
    end
    if idx==3 then
        texiaoid=self.fabaos[self.selectedItem].texiao4
    end
    if idx==4 then
        texiaoid=self.fabaos[self.selectedItem].texiao5
    end
    local EquipSkill = BeanConfigManager.getInstance():GetTableByName("skill.cequipskill"):getRecorder(texiaoid)

    gGetMessageManager():AddConfirmBox(eConfirmNormal, EquipSkill.describe, ClickYes,
            self, ClickNo, self,0,0,nil,MHSD_UTILS.get_resstring(11728),MHSD_UTILS.get_resstring(11725))

end
function FaBaoMenPaiMain:HandleJinJieClick(arg)
    if _idx==0 then
        return
    end
    local p = require("logic.item.fabao.cfabaoshopUp"):new()
    p.idx = _idx
    p.leixing=14
    LuaProtocolManager:send(p)
    self.DestroyDialog()
end


function FaBaoMenPaiMain.getInstance()
    if not _instance then
        _instance = FaBaoMenPaiMain:new()
        _instance:OnCreate()
    end
    return _instance
end

function FaBaoMenPaiMain.getInstanceAndShow(idx)
    _idx=idx
    if not _instance then
        _instance = FaBaoMenPaiMain:new()
        _instance:OnCreate()
    else
        _instance:SetVisible(true)
    end
    return _instance
end

function FaBaoMenPaiMain.getInstanceNotCreate()
    return _instance
end

function FaBaoMenPaiMain.getInstanceOrNot()
    return _instance
end

function FaBaoMenPaiMain.GetLayoutFileName()
    return "fabaomenpaimain.layout"
end

function FaBaoMenPaiMain:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, FaBaoMenPaiMain)
    self:ClearData()
    return self
end

function FaBaoMenPaiMain.DestroyDialog()
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
function FaBaoMenPaiMain.ToggleOpenClose()
    if not _instance then
        _instance = FaBaoMenPaiMain:new()
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function FaBaoMenPaiMain:ClearData()
    self.nItemCellSelId = 0
    self.ScrollEquip = {}
    self.bLoadUI = false
    self.fRefreshLeftDt = 0
    self.vItemCellHero = {}
end

--[[
function FaBaoMenPaiMain:ClearDataInClose()
	self.nItemCellSelId = 0
	self.ScrollEquip = nil
	self.bLoadUI = false
end
--]]

function FaBaoMenPaiMain:ClearCellAll()
end

function FaBaoMenPaiMain:OnClose()
    Dialog.OnClose(self)
    _instance = nil
    --require("logic.jingji.jingjipipeidialog3").DestroyDialog()
end

return FaBaoMenPaiMain
