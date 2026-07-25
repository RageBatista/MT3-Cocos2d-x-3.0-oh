
require "logic.dialog"

Itemdeletelocksuccessdialog = {}
setmetatable(Itemdeletelocksuccessdialog, Dialog)
Itemdeletelocksuccessdialog.__index = Itemdeletelocksuccessdialog

local _instance = nil

function Itemdeletelocksuccessdialog.getInstanceAndShow()
	if not _instance then
		_instance = Itemdeletelocksuccessdialog:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function Itemdeletelocksuccessdialog:clearData()
    
end

function Itemdeletelocksuccessdialog:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, Itemdeletelocksuccessdialog)
    self:clearData()
	return self
end

function Itemdeletelocksuccessdialog.DestroyDialog()
    if  _instance then
        _instance:OnClose()
        _instance = nil
    end
end

function Itemdeletelocksuccessdialog:OnClose()
    Dialog.OnClose(self)
end

function Itemdeletelocksuccessdialog:OnCreate()
    Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

    
    self.btnConfirm =  CEGUI.toPushButton(winMgr:getWindow("anquansuojiechutixing/btn"))
    self.btnConfirm:subscribeEvent("MouseClick", Itemdeletelocksuccessdialog.clickConfirm, self)

    self.btnClose =  CEGUI.toPushButton(winMgr:getWindow("anquansuojiechutixing/guanbi"))
    self.btnClose:subscribeEvent("MouseClick", Itemdeletelocksuccessdialog.clickClose, self)


   
end

function Itemdeletelocksuccessdialog:clickClose(args)
    Itemdeletelocksuccessdialog.DestroyDialog()
end

function Itemdeletelocksuccessdialog:clickConfirm(args)
    require("logic.item.itemsetpassworddialog").getInstanceAndShow()
end

function Itemdeletelocksuccessdialog:GetLayoutFileName()
	return "anquansuojiechutixing.layout"
end

return Itemdeletelocksuccessdialog