require "utils.mhsdutils"
require "logic.dialog"
--require "logic.workshop.workshopdzlevelbtn"


JingMaiListCell = {}
setmetatable(JingMaiListCell, Dialog)
JingMaiListCell.__index = JingMaiListCell

local _instance;

--local nLevelArea = 15

function JingMaiListCell:new()
    local self = {}
    self = Dialog:new()
	--self.dzDlg = nil
    setmetatable(self, JingMaiListCell)
    return self
end

function JingMaiListCell:clearList()
	if not self.cells or #self.cells == 0 then return end
	for _,v in pairs(self.cells) do
		self.container:removeChildWindow(v)
	end
end

function JingMaiListCell:HandleCellClicked(args)
	local eventargs = CEGUI.toWindowEventArgs(args)
	local nId = eventargs.window:getID()
	--local dzDlg = require "logic.workshop.workshopdznew"
	local p = require "logic.workshop.jingmai.cjingmaisel":new()
	p.idx = 2 --normal
	p.index = nId --normal
	require "manager.luaprotocolmanager":send(p)


	
	self:SetVisible(false)
end

function JingMaiListCell:OnCreate()
    Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
    self.container = CEGUI.Window.toScrollablePane(winMgr:getWindow("jingmailistcell/container"))
	self:clearList()
	self.cells = {}
	local winMgr = CEGUI.WindowManager:getSingleton()
	local sizeScroll = self.container:getPixelSize()
	local nCellH = 60
	local strLevelzi = MHSD_UTILS.get_resstring(351)
    local strLevelArea =  GameTable.common.GetCCommonTableInstance():getRecorder(208).value
    local nLevelArea =  tonumber(strLevelArea)
	local schools = BeanConfigManager.getInstance():GetTableByName("skill.cjingmaizhanshi"):getRecorder(gGetDataManager():GetMainCharacterSchoolID())

	for nIndex=1,4 do

		--local wnd = winMgr:createWindow("TaharezLook/common_roll") --common_roll --common_equipbj
		local wnd = winMgr:createWindow("TaharezLook/ImageButton") --common_roll --common_equipbj
		wnd:setSize(CEGUI.UVector2(CEGUI.UDim(0, sizeScroll.width), CEGUI.UDim(0, nCellH)))
		wnd:setPosition(CEGUI.UVector2(CEGUI.UDim(0,0),CEGUI.UDim(0,(nIndex-1)*(nCellH+2))))
		wnd:setProperty("NormalImage", "set:my_jingmai image:btnA")
		wnd:setProperty("PushedImage", "set:my_jingmai image:btnA")
		wnd:setProperty("ButtonDefaultBorderEnable", "False")
		wnd:setProperty("ButtonDefaultColourEnable", "False")
		
		wnd:setID(nIndex)
		wnd:subscribeEvent("Clicked", JingMaiListCell.HandleCellClicked, self)
		self.container:addChildWindow(wnd)
		local strShowTitle =schools.names[nIndex-1]
		wnd:setText(strShowTitle)
		table.insert(self.cells, wnd)
	end
end

--//========================================
function JingMaiListCell.getInstance()
    if not _instance then
        _instance = JingMaiListCell:new()
        _instance:OnCreate()
    end
    return _instance
end

function JingMaiListCell.getInstanceAndShow()
    if not _instance then
        _instance = JingMaiListCell:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end
    return _instance
end

function JingMaiListCell.getInstanceNotCreate()
    return _instance
end

function JingMaiListCell.DestroyDialog()
	if _instance then
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end
function JingMaiListCell.closeDialog()
	if not _instance then 
		return
	end

--self.BtnSelLevel	
	
	--local dzDlg = require "logic.workshop.workshopdznew".getInstanceOrNot()
	--if dzDlg then
	--	dzDlg:closeForBeside()
	--end
	--[[
	if _instance.dzDlg then
		_instance.dzDlg:closeForBeside() 
	end
	--]]
	
	--[[
	_instance:OnClose()
	_instance = nil
	--]]
	
	_instance:SetVisible(false)
	
	
end

function JingMaiListCell:OnClose()
    _instance:clearList()
	Dialog.OnClose(self)
	_instance = nil
end

function JingMaiListCell.getInstanceOrNot()
	return _instance
end

function JingMaiListCell.GetLayoutFileName()
    return "jingmailistcell.layout"
end

return JingMaiListCell
