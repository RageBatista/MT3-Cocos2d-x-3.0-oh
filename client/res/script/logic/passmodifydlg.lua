require "logic.dialog"

PassModifyDlg = {}
setmetatable(PassModifyDlg, Dialog)
PassModifyDlg.__index = PassModifyDlg
require "logic.http.HttpManager"
	require "logic.http.LuaJson"
local _instance
function PassModifyDlg.getInstance()
	if not _instance then
		_instance = PassModifyDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function PassModifyDlg.getInstanceAndShow()
	if not _instance then
		_instance = PassModifyDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function PassModifyDlg.getInstanceNotCreate()
	return _instance
end

function PassModifyDlg.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function PassModifyDlg.ToggleOpenClose()
	if not _instance then
		_instance = PassModifyDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function PassModifyDlg.GetLayoutFileName()
	return "passmodify.layout"
end

function PassModifyDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, PassModifyDlg)
	return self
end

function PassModifyDlg:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

	self.btnsavepass = CEGUI.toPushButton(winMgr:getWindow("passmodify/savepass"))
	self.oldpass = CEGUI.toEditbox(winMgr:getWindow("passmodify/oldpass"))
	self.newpass = CEGUI.toEditbox(winMgr:getWindow("passmodify/newpass"))
	self.cpass = CEGUI.toEditbox(winMgr:getWindow("passmodify/cpass"))
	
	self.oldpass:setTextMasked(true);
	self.cpass:setTextMasked(true);
	self.newpass:setTextMasked(true);
    self.btnsavepass :subscribeEvent("Clicked", PassModifyDlg.modifyPass, self)

end
function PassModifyDlg.ParamToString(param)
	local newparam = nil
    for k,v in pairs(param) do
		if newparam == nil then
			newparam = k..'='..v
		else
			newparam = newparam.. '&' .. k..'='..v
		end
    end
	return newparam
end
function PassModifyDlg:modifyPass()
	if self.cpass:getText()~=self.newpass:getText() then
		GetCTipsManager():AddMessageTip('确认新密码与新密码不一致')
		return
	end
	local eHttpShareUrl = GetServerInfo():getHttpAdressByEnum(eHttpShareUrl)
    local action = eHttpShareUrl.."/api/charge_award/modifypass"
    local param = {}
    param["account"] = gGetLoginManager():GetAccount()
    param["password"] = self.oldpass:getText()
    param["newpass"] = self.newpass:getText()
	param["serverid"] = tostring(gGetLoginManager():getServerID())
    local actionname = "modifyPass"
    CTipsManager:ServerPost(action,param,actionname)
end

return PassModifyDlg