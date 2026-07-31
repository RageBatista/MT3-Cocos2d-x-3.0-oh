require "logic.dialog"

FirstEnterPointMsgDlg = {}
setmetatable(FirstEnterPointMsgDlg, Dialog)
FirstEnterPointMsgDlg.__index = FirstEnterPointMsgDlg

local _instance
function FirstEnterPointMsgDlg.getInstance()
	if not _instance then
		_instance = FirstEnterPointMsgDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function FirstEnterPointMsgDlg.getInstanceAndShow()
	if not _instance then
		_instance = FirstEnterPointMsgDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function FirstEnterPointMsgDlg.getInstanceNotCreate()
	return _instance
end

function FirstEnterPointMsgDlg.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
            local manager = require "logic.pointcardserver.pointcardservermanager".getInstance()
            if manager.m_isTodayNotFree then
                require "logic.qiandaosongli.loginrewardmanager"
                local mgr = LoginRewardManager.getInstance()
                if mgr.m_firstchargeState == 0 then
                    local dlg = require "logic.pointcardserver.messageforpointcardnotcashdlg".getInstance()
                    if dlg then
                        dlg:Show()
                    end
                else
                    local dlg = require "logic.pointcardserver.messageforpointcarddlg".getInstance()
                    if dlg then
                        dlg:Show()
                    end
                end

            end
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function FirstEnterPointMsgDlg.ToggleOpenClose()
	if not _instance then
		_instance = FirstEnterPointMsgDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function FirstEnterPointMsgDlg.GetLayoutFileName()
	return "diankafutishi.layout"
end

function FirstEnterPointMsgDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, FirstEnterPointMsgDlg)
	return self
end

function FirstEnterPointMsgDlg:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
	self.m_okBtn = winMgr:getWindow("diankafutishi/btn")
	self.m_okBtn:subscribeEvent("MouseClick", FirstEnterPointMsgDlg.HandleOkClick, self)
	self.m_cancelBtn = winMgr:getWindow("diankafutishi/btn1")
	self.m_cancelBtn:subscribeEvent("MouseClick", FirstEnterPointMsgDlg.HandleCancelClick, self)
	self.m_text = CEGUI.toRichEditbox(winMgr:getWindow("diankafutishi/di/rich"))

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

function FirstEnterPointMsgDlg:InitText()
    self.m_text:Clear()
    self.m_text:AppendParseText(CEGUI.String(MHSD_UTILS.get_resstring(11547)))
    self.m_text:Refresh()
end
function FirstEnterPointMsgDlg:HandleCancelClick(e)
    FirstEnterPointMsgDlg.DestroyDialog()
end
function FirstEnterPointMsgDlg:HandleOkClick(e)
    local dlg = require"logic.selectserversdialog".getInstanceNotCreate()
    if dlg then
        dlg:SelectServerFinish()
    end
    FirstEnterPointMsgDlg.DestroyDialog()
end
return FirstEnterPointMsgDlg