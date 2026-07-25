
require "logic.dialog"

Itemlocknoticedialog = {}
setmetatable(Itemlocknoticedialog, Dialog)
Itemlocknoticedialog.__index = Itemlocknoticedialog

local _instance = nil

function Itemlocknoticedialog.getInstanceAndShow()
	if not _instance then
		_instance = Itemlocknoticedialog:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function Itemlocknoticedialog:clearData()
    
end

function Itemlocknoticedialog:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, Itemlocknoticedialog)
    self:clearData()
	return self
end

function Itemlocknoticedialog.DestroyDialog()
    if  _instance then
        _instance:OnClose()
        _instance = nil
    end
end

function Itemlocknoticedialog:OnClose()
    Dialog.OnClose(self)
end

function Itemlocknoticedialog:OnCreate()
    Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

    
    self.btnConfirm =  CEGUI.toPushButton(winMgr:getWindow("anquansuotixing/btn"))
    self.btnConfirm:subscribeEvent("MouseClick", Itemlocknoticedialog.clickConfirm, self)

    self.btnClose =  CEGUI.toPushButton(winMgr:getWindow("anquansuotixing/guanbi"))
    self.btnClose:subscribeEvent("MouseClick", Itemlocknoticedialog.clickClose, self)

   
end

function Itemlocknoticedialog:clickClose(args)
    Itemlocknoticedialog.DestroyDialog()
end

function Itemlocknoticedialog:clickConfirm(args)
    --Itemlocknoticedialog.DestroyDialog()
    require("logic.item.itemsetpassworddialog").getInstanceAndShow()

end

function Itemlocknoticedialog:GetLayoutFileName()
	return "anquansuotixing/guanbi.layout"
end

return Itemlocknoticedialog