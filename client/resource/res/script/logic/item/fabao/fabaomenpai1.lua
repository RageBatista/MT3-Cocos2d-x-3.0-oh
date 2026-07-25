require "utils.mhsdutils"
require "logic.dialog"

require "utils.commonutil"

FaBaoMenPai1 = {}
setmetatable(FaBaoMenPai1, Dialog)
FaBaoMenPai1.__index = FaBaoMenPai1
local _instance;
local _idx;
local _index;
--//===============================
function FaBaoMenPai1:OnCreate()
    Dialog.OnCreate(self)
    SetPositionScreenCenter(self:GetWindow())
    local winMgr = CEGUI.WindowManager:getSingleton()

    self.m_pEquipCell={}
    self.m_pEquipText={}

		-- if menpai.fabaos[index-1].jinjie == 3 then
		-- self.m_pEquipCell[index]:SetCornerImage("Houbaoa", "xx")
    -- end
    
	    for index = 1, 4 do

        self.m_pEquipText[index] = winMgr:getWindow("fabaomenpai2/itemname"..index)
   
        self.m_pEquipCell[index] = CEGUI.toItemCell(winMgr:getWindow("fabaomenpai2/cell/item"..index));
        self.m_pEquipCell[index]:SetIndex(index);

        --self.m_pEquipCell[index]:SetHaveSelectedState(true);
        self.m_pEquipCell[index]:SetCellTypeMask(1);

		
		--print("GGGGGGGGGGG=="..fabaos.name.."="..menpai.tiaojians[index-1].."="..fabaos.jinjie)
	
    end
	
    ----self:UpdateProData()
    self.guanbi = CEGUI.toPushButton(winMgr:getWindow("fabaomenpai2/guanbi"))
    self.guanbi:subscribeEvent("MouseButtonUp", FaBaoMenPai1.HandleguanbiClick, self)
    self.btn = CEGUI.toPushButton(winMgr:getWindow("fabaomenpai2/btn"))
    self.btn:subscribeEvent("MouseButtonUp", FaBaoMenPai1.HandleClick, self)
    --
    --self.selectedItemId = 0
    local p = require("logic.item.fabao.cfabaoshopsl"):new()
    LuaProtocolManager:send(p)
   -- self:refreshFaBaoMenPai1List()
end
function FaBaoMenPai1:UpdateProData(fabaox)

    local menpai = BeanConfigManager.getInstance():GetTableByName("item.cfabaomenpai"):getRecorder(gGetDataManager():GetMainCharacterSchoolID())
    for index = 1, 4 do
        local fabaos = BeanConfigManager.getInstance():GetTableByName("item.cfabaoshop"):getRecorder(menpai.tiaojians[index-1])
        local img = gGetIconManager():GetImageByID(fabaos.icon)
        self.m_pEquipText[index]:setText(fabaos.name)
        self.m_pEquipCell[index]:SetImage(img)
        self.m_pEquipCell[index]:setID(index)
        --self.m_pEquipCell[index]:SetHaveSelectedState(true)
        self.m_pEquipCell[index]:subscribeEvent(CEGUI.ItemCell.EventCellClick, FaBaoMenPai1.HandleTableClick2, self);
		
		--print("GGGGGGGGGGG=="..fabaos.name.."="..menpai.tiaojians[index-1].."="..fabaos.jinjie)
		local indes=menpai.tiaojians[index-1]
		if not fabaox[indes] then
		self.m_pEquipCell[index]:SetCornerImage("Houbaoa", "ff")
		else 
		    if fabaox[indes].level < 10 then
			  self.m_pEquipCell[index]:SetCornerImage("Houbaoa", "ww")
			else
			  self.m_pEquipCell[index]:SetCornerImage("MenPaiFaBao", "yh")
			end
        end		
		
    end
end
function FaBaoMenPai1:HandleTableClick2(e)
    local MouseArgs = CEGUI.toMouseEventArgs(e);

    local pCell = CEGUI.toItemCell(MouseArgs.window);

    if (pCell == nil) then

        return true;
    end
    --local idx=pCell:getID()
    --local index=pCell:GetIndex()
    --if idx==6 then
      require "logic.item.fabao.fabaoshop".getInstanceAndShow()
    --    return true;
    --end
    --self.selectedItem=idx
    --self.selectedIndex=index
    --if self.fabaos[idx].weizhi==0 then
    --    self.zhudongbtn:setText(MHSD_UTILS.get_resstring(11718))
    --else
    --    self.zhudongbtn:setText(MHSD_UTILS.get_resstring(11719))
    --end
    --self:FaBaoXinXi(idx)
    --if idx==0 then
    --	require "logic.item.fabao.fabaoshop".getInstanceAndShow()
    --end


    local pTable = CEGUI.toItemTable(pCell:getParent());
    if (pTable == nil) then
        return true;
    end
    return true;
end
function FaBaoMenPai1:HandleClick(arg)
  --  if _idx==0 then
  --      return
  --  end
    local p = require("logic.item.fabao.cfabaoshopUp"):new()
    p.idx = 100 + gGetDataManager():GetMainCharacterSchoolID()
    p.leixing=88
    LuaProtocolManager:send(p)
    self.DestroyDialog()
end
function FaBaoMenPai1:HandleguanbiClick(arg)
   self.DestroyDialog()
end

function FaBaoMenPai1.getInstance()
    if not _instance then
        _instance = FaBaoMenPai1:new()
        _instance:OnCreate()
    end
    return _instance
end

function FaBaoMenPai1.getInstanceAndShow(idx,index)
    _idx=idx
    _index=index
    if not _instance then
        _instance = FaBaoMenPai1:new()
        _instance:OnCreate()
    else
        _instance:SetVisible(true)
    end
    return _instance
end

function FaBaoMenPai1.getInstanceNotCreate()
    return _instance
end

function FaBaoMenPai1.getInstanceOrNot()
    return _instance
end

function FaBaoMenPai1.GetLayoutFileName()
    return "fabaomenpai2.layout"
end

function FaBaoMenPai1:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, FaBaoMenPai1)
    self:ClearData()
    return self
end

function FaBaoMenPai1.DestroyDialog()
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
function FaBaoMenPai1.ToggleOpenClose()
    if not _instance then
        _instance = FaBaoMenPai1:new()
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function FaBaoMenPai1:ClearData()
    self.nItemCellSelId = 0
    self.ScrollEquip = {}
    self.bLoadUI = false
    self.fRefreshLeftDt = 0
    self.vItemCellHero = {}
end

--[[
function FaBaoMenPai1:ClearDataInClose()
	self.nItemCellSelId = 0
	self.ScrollEquip = nil
	self.bLoadUI = false
end
--]]

function FaBaoMenPai1:ClearCellAll()
end

function FaBaoMenPai1:OnClose()
    Dialog.OnClose(self)
    _instance = nil
    --require("logic.jingji.jingjipipeidialog3").DestroyDialog()
end

return FaBaoMenPai1
