
require "logic.dialog"

Itemforcedeletelockdialog = {}
setmetatable(Itemforcedeletelockdialog, Dialog)
Itemforcedeletelockdialog.__index = Itemforcedeletelockdialog

local _instance = nil

function Itemforcedeletelockdialog.getInstanceAndShow()
	if not _instance then
		_instance = Itemforcedeletelockdialog:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function Itemforcedeletelockdialog:clearData()
    
end

function Itemforcedeletelockdialog:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, Itemforcedeletelockdialog)
    self:clearData()
	return self
end


function Itemforcedeletelockdialog.DestroyDialog()
    if  _instance then
        _instance:OnClose()
        _instance = nil
    end
end

function Itemforcedeletelockdialog:OnClose()
    Dialog.OnClose(self)
end

function Itemforcedeletelockdialog:OnCreate()
    Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

   
    self.btnConfirm =  CEGUI.toPushButton(winMgr:getWindow("anquansuoqiangzhijiechu/btn"))
    self.btnConfirm:subscribeEvent("MouseClick", Itemforcedeletelockdialog.clickConfirm, self)

    
    self.btnClose =  CEGUI.toPushButton(winMgr:getWindow("anquansuoqiangzhijiechu/guanbi"))
    self.btnClose:subscribeEvent("MouseClick", Itemforcedeletelockdialog.clickClose, self)
    
end

function Itemforcedeletelockdialog:clickClose(args)
    Itemforcedeletelockdialog.DestroyDialog()

end




function Itemforcedeletelockdialog:clickConfirm(args)
    local p =  require("protodef.fire.pb.cforcedelpassword"):new()
    LuaProtocolManager:send(p)
end




function Itemforcedeletelockdialog:GetLayoutFileName()
	return "anquansuoqiangzhijiechu.layout"
end


return Itemforcedeletelockdialog