require "logic.dialog"

PointMsgAddCashdlg = {}
setmetatable(PointMsgAddCashdlg, Dialog)
PointMsgAddCashdlg.__index = PointMsgAddCashdlg

local _instance
function PointMsgAddCashdlg.getInstance()
	if not _instance then
		_instance = PointMsgAddCashdlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function PointMsgAddCashdlg.getInstanceAndShow()
	if not _instance then
		_instance = PointMsgAddCashdlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function PointMsgAddCashdlg.getInstanceNotCreate()
	return _instance
end

function PointMsgAddCashdlg.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function PointMsgAddCashdlg.ToggleOpenClose()
	if not _instance then
		_instance = PointMsgAddCashdlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function PointMsgAddCashdlg.GetLayoutFileName()
	return "diankafutishi.layout"
end

function PointMsgAddCashdlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, PointMsgAddCashdlg)
	return self
end

function PointMsgAddCashdlg:OnCreate()
	local prefix = "addcash"
	Dialog.OnCreate(self, nil, prefix)
	local winMgr = CEGUI.WindowManager:getSingleton()
	self.m_okBtn = winMgr:getWindow(prefix .. "diankafutishi/btn")
	self.m_okBtn:setVisible(false)
	self.m_cancelBtn = winMgr:getWindow(prefix .. "diankafutishi/btn1")
	self.m_cancelBtn:setVisible(false)
	self.m_text = CEGUI.toRichEditbox(winMgr:getWindow(prefix .. "diankafutishi/di/rich"))
	self.m_centerBtn = winMgr:getWindow(prefix .. "diankafutishi/btn2")
	self.m_centerBtn:subscribeEvent("Clicked", PointMsgAddCashdlg.HandleCenterClick, self)
	self.m_centerBtn:setVisible(true)

	local bChanged = false
	local funopenclosetype = require("protodef.rpcgen.fire.pb.funopenclosetype"):new()
	local manager = require "logic.pointcardserver.pointcardservermanager".getInstanceNotCreate()
	if manager then
		if manager.m_OpenFunctionList.info then
			for i, v in pairs(manager.m_OpenFunctionList.info) do
				if v.key == funopenclosetype.FUN_CHECKPOINT then
					if v.state == 1 then
						self.m_text:Clear()
						self.m_text:AppendParseText(CEGUI.String(MHSD_UTILS.get_resstring(11595)))
						self.m_text:Refresh()
						bChanged = true
					end
				end
			end

		end
	end

	if not bChanged then
		self:InitText()
	end
end

function PointMsgAddCashdlg:InitText()
    self.m_text:Clear()
    self.m_text:AppendParseText(CEGUI.String(MHSD_UTILS.get_resstring(11547)))
    self.m_text:Refresh()
end
function PointMsgAddCashdlg:HandleCenterClick(e)
    PointMsgAddCashdlg.DestroyDialog()
end
return PointMsgAddCashdlg