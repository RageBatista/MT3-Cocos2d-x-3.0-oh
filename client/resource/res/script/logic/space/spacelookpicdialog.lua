require "utils.mhsdutils"
require "logic.dialog"

Spacelookpicdialog = {}
setmetatable(Spacelookpicdialog, Dialog)
Spacelookpicdialog.__index = Spacelookpicdialog


local _instance

function Spacelookpicdialog.getInstance()
	if not _instance then
		_instance = Spacelookpicdialog:new()
		_instance:OnCreate()
	end
	return _instance
end

function Spacelookpicdialog.getInstanceAndShow()
	if not _instance then
		_instance = Spacelookpicdialog:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end


function Spacelookpicdialog.DestroyDialog()
	if _instance then
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function Spacelookpicdialog:OnClose()
    self:clearData()
	Dialog.OnClose(self)
end

function Spacelookpicdialog.GetLayoutFileName()
	return "kongjianchakanzhaopian.layout"
end

function Spacelookpicdialog.getInstanceNotCreate()
	return _instance
end

function Spacelookpicdialog:clearData()
    self.mapCallBack = {}
end

function Spacelookpicdialog:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, Spacelookpicdialog)
    self:clearData()
	return self
end

function Spacelookpicdialog:OnCreate()
     Dialog.OnCreate(self)
     --SetPositionScreenCenter(self:GetWindow())
	local winMgr = CEGUI.WindowManager:getSingleton()
	
    self.itemCell = CEGUI.toItemCell(winMgr:getWindow("kongjianchazhaopian/itemcell"))
    self.itemCell:SetBackGroundEnable(false)
    self:GetWindow():subscribeEvent("MouseClick", Spacelookpicdialog.clickClose, self)
    self:GetWindow():subscribeEvent("Click", Spacelookpicdialog.clickClose, self)

end

function Spacelookpicdialog:clickClose(args)
    Spacelookpicdialog.DestroyDialog()
end

return Spacelookpicdialog