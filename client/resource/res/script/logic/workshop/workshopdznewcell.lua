require "utils.mhsdutils"
require "logic.dialog"
--require "logic.workshop.workshopdzlevelbtn"


Workshopdznewcell = {}
setmetatable(Workshopdznewcell, Dialog)
Workshopdznewcell.__index = Workshopdznewcell

local _instance;

--local nLevelArea = 15

function Workshopdznewcell:new()
    local self = {}
    self = Dialog:new()
	--self.dzDlg = nil
    setmetatable(self, Workshopdznewcell)
    return self
end

function Workshopdznewcell:clearList()
	if not self.cells or #self.cells == 0 then return end
	for _,v in pairs(self.cells) do
		self.container:removeChildWindow(v)
	end
end

function Workshopdznewcell:HandleCellClicked(args)
	local eventargs = CEGUI.toWindowEventArgs(args)
	local nId = eventargs.window:getID()
	--local dzDlg = require "logic.workshop.workshopdznew"
	local dzDlg = require "logic.workshop.workshopdznew".getInstanceOrNot()
	if dzDlg then 
		dzDlg:RefreshLevelArea(nId)
	end
	--[[
	if self.dzDlg then
		self.dzDlg:RefreshLevelArea(nId)
		self.dzDlg = nil
	end
	--]]
	
	--self.DestroyDialog()
	
	self:SetVisible(false)
end

function Workshopdznewcell:OnCreate()
    Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
    self.container = CEGUI.Window.toScrollablePane(winMgr:getWindow("workshopdznewcell/container"))
	self:clearList()
	self.cells = {}
	local winMgr = CEGUI.WindowManager:getSingleton()
	local sizeScroll = self.container:getPixelSize()
	local nCellH = 80
	local strLevelzi = MHSD_UTILS.get_resstring(351)
    local strLevelArea =  GameTable.common.GetCCommonTableInstance():getRecorder(208).value
    local nLevelArea =  tonumber(strLevelArea) 
	for nIndex=1,nLevelArea do
		local nArea = nIndex*10
		local wnd = winMgr:createWindow("TaharezLook/common_zbdj") 
		wnd:setSize(CEGUI.UVector2(CEGUI.UDim(0, sizeScroll.width), CEGUI.UDim(0, nCellH)))
		wnd:setPosition(CEGUI.UVector2(CEGUI.UDim(0,0),CEGUI.UDim(0,(nIndex-1)*(nCellH+5))))
		wnd:setID(nArea)
		wnd:subscribeEvent("Clicked", Workshopdznewcell.HandleCellClicked, self)
		self.container:addChildWindow(wnd)
		local strShowTitle
if nArea == 10 then
    strShowTitle = "星印"
else
    strShowTitle = nArea..strLevelzi
end
		wnd:setText(strShowTitle)
		table.insert(self.cells, wnd)
	end
end

--//========================================
function Workshopdznewcell.getInstance()
    if not _instance then
        _instance = Workshopdznewcell:new()
        _instance:OnCreate()
    end
    return _instance
end

function Workshopdznewcell.getInstanceAndShow()
    if not _instance then
        _instance = Workshopdznewcell:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end
    return _instance
end

function Workshopdznewcell.getInstanceNotCreate()
    return _instance
end

function Workshopdznewcell.DestroyDialog()
	if _instance then
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end
function Workshopdznewcell.closeDialog()
	if not _instance then 
		return
	end

--self.BtnSelLevel	
	
	local dzDlg = require "logic.workshop.workshopdznew".getInstanceOrNot()
	if dzDlg then 
		dzDlg:closeForBeside()
	end
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

function Workshopdznewcell:OnClose()
    _instance:clearList()
	Dialog.OnClose(self)
	_instance = nil
end

function Workshopdznewcell.getInstanceOrNot()
	return _instance
end

function Workshopdznewcell.GetLayoutFileName()
    return "workshopdznewcell.layout"
end

return Workshopdznewcell
