
require "logic.dialog"

Itemsetpsdsuccessdialog = {}
setmetatable(Itemsetpsdsuccessdialog, Dialog)
Itemsetpsdsuccessdialog.__index = Itemsetpsdsuccessdialog

local _instance = nil

function Itemsetpsdsuccessdialog.getInstanceAndShow()
	if not _instance then
		_instance = Itemsetpsdsuccessdialog:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function Itemsetpsdsuccessdialog:clearData()
    
end

function Itemsetpsdsuccessdialog:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, Itemsetpsdsuccessdialog)
    self:clearData()
	return self
end

function Itemsetpsdsuccessdialog.DestroyDialog()
    if  _instance then
        _instance:OnClose()
        _instance = nil
    end
end

function Itemsetpsdsuccessdialog:OnClose()
    Dialog.OnClose(self)
end

function Itemsetpsdsuccessdialog:OnCreate()
    Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

    self.richboxPsd1 = CEGUI.toRichEditbox(winMgr:getWindow("anquansuoshezhichenggong/shurukuang/text"))
    
    self.btnConfirm =  CEGUI.toPushButton(winMgr:getWindow("anquansuoshezhichenggong/btn"))
    self.btnConfirm:subscribeEvent("MouseClick", Itemsetpsdsuccessdialog.clickConfirm, self)

    self.btnClose =  CEGUI.toPushButton(winMgr:getWindow("anquansuoshezhichenggong/guanbi"))
    self.btnClose:subscribeEvent("MouseClick", Itemsetpsdsuccessdialog.clickClose, self)


    local itemManager = require("logic.item.roleitemmanager").getInstance()
    local strContent = require("utils.mhsdutils").get_resstring(11688)

    local sb = StringBuilder.new()
    sb:Set("parameter1",itemManager.strLockPsd)
    strContent = sb:GetString(strContent)
    sb:delete()

     local itemManager = require("logic.item.roleitemmanager").getInstance()
     self.richboxPsd1:Clear()
     self.richboxPsd1:AppendParseText(CEGUI.String(strContent))
     self.richboxPsd1:Refresh()
end

function Itemsetpsdsuccessdialog:clickClose(args)
    Itemsetpsdsuccessdialog.DestroyDialog()
end

function Itemsetpsdsuccessdialog:clickConfirm(args)
    Itemsetpsdsuccessdialog.DestroyDialog()
end

function Itemsetpsdsuccessdialog:GetLayoutFileName()
	return "anquansuoshezhichenggong.layout"
end

return Itemsetpsdsuccessdialog