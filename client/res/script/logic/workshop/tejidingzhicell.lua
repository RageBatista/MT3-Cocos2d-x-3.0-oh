require "utils.mhsdutils"
require "logic.dialog"


tejidingzhicell = {}
setmetatable(tejidingzhicell, Dialog)
tejidingzhicell.__index = tejidingzhicell

local _instance;


function tejidingzhicell:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, tejidingzhicell)
    return self
end

function tejidingzhicell:clearList()
	if not self.cells or #self.cells == 0 then return end
	for _,v in pairs(self.cells) do
		self.container:removeChildWindow(v)
	end
end

function tejidingzhicell:HandleCellClicked(args)
	local eventargs = CEGUI.toWindowEventArgs(args)
	local nId = eventargs.window:getID()
	local dzDlg = require "logic.workshop.tejidingzhi".getInstanceOrNot()
	if dzDlg then 
		local effectinfo =BeanConfigManager.getInstance():GetTableByName("item.csetfumoInfo"):getRecorder(nId)
		if self.type == 1 then
			dzDlg:RefreshEffectArea(eventargs.window:getText(),nId,effectinfo.itemid,effectinfo.itemnum)
		end
		if self.type == 2 then
			dzDlg:RefreshSkillArea(eventargs.window:getText(),nId,effectinfo.itemid,effectinfo.itemnum)
		end
		if self.type == 3 then
			dzDlg:RefreshNewSkillArea(eventargs.window:getText(),nId,effectinfo.itemid,effectinfo.itemnum)
		end
		if self.type == 4 then
			dzDlg:RefreshNewEffectArea(eventargs.window:getText(),nId,effectinfo.itemid,effectinfo.itemnum)
		end
	end
	
	self:SetVisible(false)
end

function tejidingzhicell:OnCreate()
    Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
    self.container = CEGUI.Window.toScrollablePane(winMgr:getWindow("tejidingzhicell/container"))
	self:clearList()
	self.cells = {}
	self.type= 0
end

function tejidingzhicell:setSkillList(listtype)
	self.type = listtype
  --   LogInfo("当前技能".typelist[listtype])
	local winMgr = CEGUI.WindowManager:getSingleton()
	local sizeScroll = self.container:getPixelSize()
	local nCellH = 50
	local tableAllId = BeanConfigManager.getInstance():GetTableByName("item.csetfumoInfo"):getAllID()
	local skilllist={}
	self:clearList()
	for k, v in pairs(tableAllId) do
		if	listtype == 1 then
			if BeanConfigManager.getInstance():GetTableByName("item.csetfumoInfo"):getRecorder(v).effect == 1 then
				table.insert(skilllist, v)
			end
		end
		if	listtype == 2 then
			if BeanConfigManager.getInstance():GetTableByName("item.csetfumoInfo"):getRecorder(v).skill == 1 then
				table.insert(skilllist, v)
			end
		end
		if	listtype == 3 then
			if BeanConfigManager.getInstance():GetTableByName("item.csetfumoInfo"):getRecorder(v).fujiaone == 1 then
				table.insert(skilllist, v)
			end
		end
		if	listtype == 4 then
			if BeanConfigManager.getInstance():GetTableByName("item.csetfumoInfo"):getRecorder(v).fujiatwo == 1 then
				table.insert(skilllist, v)
			end
		end
		
	end
	for k, v in pairs(skilllist) do
		local nArea = v
		  local wnd = winMgr:createWindow("TaharezLook/common_zbdj") ---器灵镶嵌列表按钮
		  wnd:setSize(CEGUI.UVector2(CEGUI.UDim(0, sizeScroll.width), CEGUI.UDim(0, nCellH)))
		  wnd:setPosition(CEGUI.UVector2(CEGUI.UDim(0,0),CEGUI.UDim(0,(k-1)*(nCellH+5))))
		  wnd:setID(nArea)
		  wnd:subscribeEvent("Clicked", tejidingzhicell.HandleCellClicked, self)
		  self.container:addChildWindow(wnd)
		  local strShowTitle = BeanConfigManager.getInstance():GetTableByName("item.csetfumoInfo"):getRecorder(v)
		  wnd:setProperty("NormalTextColour","ff743a0f")
		  wnd:setText(strShowTitle.name)
		  
		  table.insert(self.cells, wnd)
	end
end

--//========================================
function tejidingzhicell.getInstance()
    if not _instance then
        _instance = tejidingzhicell:new()
        _instance:OnCreate()
    end
    return _instance
end

function tejidingzhicell.getInstanceAndShow()
    if not _instance then
        _instance = tejidingzhicell:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end
    return _instance
end

function tejidingzhicell.getInstanceNotCreate()
    return _instance
end

function tejidingzhicell.DestroyDialog()
	if _instance then
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end
function tejidingzhicell.closeDialog()
	if not _instance then 
		return
	end

	local dzDlg = require "logic.workshop.tejidingzhi".getInstanceOrNot()
	if dzDlg then 
		dzDlg:closeForBeside()
	end

	
	_instance:SetVisible(false)
	
	
end

function tejidingzhicell:OnClose()
    _instance:clearList()
	Dialog.OnClose(self)
	_instance = nil
end

function tejidingzhicell.getInstanceOrNot()
	return _instance
end

function tejidingzhicell.GetLayoutFileName()
    return "tejidingzhicell.layout"
end

return tejidingzhicell
