require "logic.dialog"

PointCardGuideDlg = {}
setmetatable(PointCardGuideDlg, Dialog)
PointCardGuideDlg.__index = PointCardGuideDlg

local _instance
function PointCardGuideDlg.getInstance()
	if not _instance then
		_instance = PointCardGuideDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function PointCardGuideDlg.getInstanceAndShow()
	if not _instance then
		_instance = PointCardGuideDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function PointCardGuideDlg.getInstanceNotCreate()
	return _instance
end

function PointCardGuideDlg.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function PointCardGuideDlg.ToggleOpenClose()
	if not _instance then
		_instance = PointCardGuideDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function PointCardGuideDlg.GetLayoutFileName()
	return "zhiyindingzhi_mtg1.layout"
end

function PointCardGuideDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, PointCardGuideDlg)
	return self
end

function PointCardGuideDlg:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

    self.btnOk = CEGUI.toPushButton(winMgr:getWindow("zhiyindingzhi_mtg1/OK"))
    self.btnOk:subscribeEvent("MouseClick", PointCardGuideDlg.HandleOKBtnClick, self)
end

function PointCardGuideDlg:HandleOKBtnClick(args)
    NewRoleGuideManager.getInstance():setGuideModel(1)
    self:sendModelSelectPro(1)
    PointCardGuideDlg.DestroyDialog()
end

function PointCardGuideDlg:sendModelSelectPro( model )
    local csetpilottype = require "protodef.fire.pb.csetpilottype"
	local req = csetpilottype.Create()
    req.pilotType = model
	LuaProtocolManager.getInstance():send(req)
end

return PointCardGuideDlg