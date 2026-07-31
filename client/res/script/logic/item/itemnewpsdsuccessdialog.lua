
require "logic.dialog"

Itemnewpsdsuccessdialog = {}
setmetatable(Itemnewpsdsuccessdialog, Dialog)
Itemnewpsdsuccessdialog.__index = Itemnewpsdsuccessdialog

local _instance = nil

function Itemnewpsdsuccessdialog.getInstanceAndShow()
	if not _instance then
		_instance = Itemnewpsdsuccessdialog:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function Itemnewpsdsuccessdialog:clearData()
    
end

function Itemnewpsdsuccessdialog:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, Itemnewpsdsuccessdialog)
    self:clearData()
	return self
end

function Itemnewpsdsuccessdialog.DestroyDialog()
    if  _instance then
        _instance:OnClose()
        _instance = nil
    end
end

function Itemnewpsdsuccessdialog:OnClose()
    Dialog.OnClose(self)
end

function Itemnewpsdsuccessdialog:OnCreate()
    Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

    self.richboxPsd1 = CEGUI.toRichEditbox(winMgr:getWindow("anquansuochongzhichenggong/shurukuang/text"))
    
    self.btnConfirm =  CEGUI.toPushButton(winMgr:getWindow("anquansuochongzhichenggong/btn"))
    self.btnConfirm:subscribeEvent("MouseClick", Itemnewpsdsuccessdialog.clickConfirm, self)

    self.btnClose =  CEGUI.toPushButton(winMgr:getWindow("anquansuochongzhichenggong/guanbi"))
    self.btnClose:subscribeEvent("MouseClick", Itemnewpsdsuccessdialog.clickClose, self)



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

function Itemnewpsdsuccessdialog:clickClose(args)
    Itemnewpsdsuccessdialog.DestroyDialog()
end

function Itemnewpsdsuccessdialog:clickConfirm(args)
    Itemnewpsdsuccessdialog.DestroyDialog()
end

function Itemnewpsdsuccessdialog:GetLayoutFileName()
	return "anquansuochongzhichenggong.layout"
end

return Itemnewpsdsuccessdialog