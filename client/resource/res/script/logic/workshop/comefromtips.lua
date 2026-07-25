require "utils.mhsdutils"
require "logic.dialog"



Comefromtips = {}
setmetatable(Comefromtips, Dialog)
Comefromtips.__index = Comefromtips
local _instance;

function Comefromtips:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, Comefromtips)
	self:ClearData()
    return self
end


function Comefromtips:ClearData()
	self.vCellCome = {}
	self.nItemId = -1
end

--[[
function Comefromtips:clearList()
end
--]]

function Comefromtips:HandleCellClicked(args)
end

function Comefromtips:OnCreate()
    Dialog.OnCreate(self)
	SetPositionScreenCenter(self:GetWindow())
	local winMgr = CEGUI.WindowManager:getSingleton()
	self.scrollPane = CEGUI.toScrollablePane(winMgr:getWindow("workshoptip_mtg/list"))
	
end
--[[
local groAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.cgroceryeffect"):getRecorder(nItemId)
	if not groAttrCfg then
		return
	end
	local nComeFromNum = groAttrCfg.vcomefrom:size()
	if nComeFromNum==0 then
		return
	end
--]]
function Comefromtips:RefreshWithItemId(nItemId)
	self.scrollPane:cleanupNonAutoChildren()
	self.vCellCome = {}
	self.nItemId = nItemId
	local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
	if not itemAttrCfg then
		return
	end
	local nComeFromNum = itemAttrCfg.vcomefrom:size()
	if nComeFromNum==0 then
		return
	end
	for nIndex=1,nComeFromNum do
		local nComeId = itemAttrCfg.vcomefrom[nIndex-1]
		self:AddCellCome(nComeId)
	end
end


function Comefromtips:AddCellCome(nComeId)
	local winMgr = CEGUI.WindowManager:getSingleton()
		
	local nOriginX = 0
	local nOriginY = 10
	local nItemCellW = 0
	local nItemCellH = 0
	local nSpaceX = 15
	local nSpaceY = 20
	local nRowCount = 3
	
	local nIndex = #self.vCellCome+1
	local comeCfg = BeanConfigManager.getInstance():GetTableByName("item.ccomefrom"):getRecorder(nComeId)
	if not comeCfg then
		return
	end
	local prefixName = "Comefromtips"..tostring(nIndex)
	local layoutCell = winMgr:loadWindowLayout("workshoptipcell_mtg.layout",prefixName)
	local sizeLayout = layoutCell:getPixelSize()
	nItemCellW = sizeLayout.width
	nItemCellH = sizeLayout.height
	
	layoutCell.labelName = winMgr:getWindow(prefixName.."workshoptipcell_mtg/text")
	layoutCell.itemCell =  CEGUI.toItemCell(winMgr:getWindow(prefixName.."workshoptipcell_mtg/itemcell"))
	self.scrollPane:addChildWindow(layoutCell)
	layoutCell.itemCell:subscribeEvent("MouseClick", self.HandleClickedCell, self)
	
	layoutCell.itemCell.nComeId = nComeId
	layoutCell.labelName:setText(comeCfg.strname)
	--local itemCell = CEGUI.toItemCell(layoutCell)
	local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(self.nItemId)
	--layoutCell.itemCell:SetImage(gGetIconManager():GetItemIconByID(itemAttrCfg.icon))
	
	layoutCell.itemCell:SetImage(comeCfg.stricon,comeCfg.stricon2)
	--layoutCell.itemCell:setProperty("Image",comeCfg.stricon)
	
	local nPosX,nPosY = MHSD_UTILS.GetPos(nIndex-1,nRowCount,nOriginX,nOriginY,nItemCellW,nItemCellH,nSpaceX,nSpaceY)
	--layoutCell:setSize(CEGUI.UVector2(CEGUI.UDim(0,nItemCellW), CEGUI.UDim(0,nItemCellH)))
	layoutCell:setPosition(CEGUI.UVector2(CEGUI.UDim(0,nPosX),CEGUI.UDim(0,nPosY)))
	self.vCellCome[nIndex] = layoutCell
	
end

function Comefromtips.getFirstCell()
    if _instance and _instance.vCellCome then
        NewRoleGuideManager.getInstance():setLuaGetWindow(_instance.vCellCome[1].itemCell)
    end
end

function Comefromtips:HandleClickedCell(e)
	LogInfo("Comefromtips.HandleClickedCell")
	local mouseArgs = CEGUI.toMouseEventArgs(e)
	local clickWin = mouseArgs.window
	local nComeId = clickWin.nComeId
	local comeCfg = BeanConfigManager.getInstance():GetTableByName("item.ccomefrom"):getRecorder(nComeId)
	if not comeCfg then
		return
	end
	if comeCfg.etype==1 then --open ui --1=shanghui 2=jifen
		local nUIId = comeCfg.nuiidornpcid
		local nParam = comeCfg.nparam
		self:OpenUI(nUIId,nParam)
	elseif comeCfg.etype==2 then --goto npc
		local nNpcId = comeCfg.nuiidornpcid
		self:gotoNpc(nNpcId)
	end
	 Comefromtips.DestroyDialog()
	--local workshoplabel = require("logic.workshop.workshoplabel").getInstance()
	--workshoplabel:OnClose()
	
end


function Comefromtips:getOpenGonghuiSkill(nUIId)
    local nItemId = self.nItemId

    local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
	if not itemAttrCfg then
		return -1
	end
    local Openui = require("logic.openui")
    if nUIId~= Openui.eUIId.bangpaijineng_03 then
        return -1
    end
    if itemAttrCfg.itemtypeid==310 then --武器模具
        return 300101
    elseif itemAttrCfg.itemtypeid==326 then --防具模具
        return 300201
    elseif itemAttrCfg.itemtypeid==342 then --饰品模具
        return 300301
    end
    return -1
end

function Comefromtips:OpenUI(nUIId,nParam)
	LogInfo("Comefromtips:OpenUI(nUIId)="..nUIId)
	local nItemId = self.nItemId
	if nParam ~= 0 then
		nItemId = nParam
	end

    local nGonghuiSkillId = self:getOpenGonghuiSkill(nUIId)
    if nGonghuiSkillId > 0 then
        nItemId=nGonghuiSkillId
    end
	--local nItemId = nParam --self.nItemId
	require("logic.openui").OpenUI(nUIId,nItemId)
end

function Comefromtips:gotoNpc(nNpcId)
	local TaskHelper = require "logic.task.taskhelper"
	TaskHelper.gotoNpc(nNpcId)

    require("logic.workshop.workshoplabel").DestroyDialog()
end


--//========================================
function Comefromtips.getInstance()
    if not _instance then
        _instance = Comefromtips:new()
        _instance:OnCreate()
    end
    return _instance
end

function Comefromtips.getInstanceAndShow()
    if not _instance then
        _instance = Comefromtips:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end
    return _instance
end

function Comefromtips.getInstanceNotCreate()
    return _instance
end

function Comefromtips.DestroyDialog()
	if _instance then
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

--[[
function Comefromtips.closeDialog()
	if not _instance then 
		return
	end
	_instance:OnClose()
	_instance = nil
end
--]]

function Comefromtips:ClearAllCell()
	
	for k,v in pairs(self.vCellCome) do 
		self.scrollPane:removeChildWindow(v)
		CEGUI.WindowManager:getSingleton():destroyWindow(v)
	end
end

function Comefromtips:OnClose()
	require ("logic.tips.commontipdlg").DestroyDialog()
	self:ClearAllCell()
	Dialog.OnClose(self)
	self:ClearData()
	_instance = nil
end

function Comefromtips.getInstanceOrNot()
	return _instance
end

function Comefromtips.GetLayoutFileName()
    return "workshoptip_mtg.layout"
end

return Comefromtips
