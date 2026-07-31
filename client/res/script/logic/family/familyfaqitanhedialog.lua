require "logic.dialog"

FamilyFaQiTanHeDialog = {}
setmetatable(FamilyFaQiTanHeDialog, Dialog)
FamilyFaQiTanHeDialog.__index = FamilyFaQiTanHeDialog

local _instance
function FamilyFaQiTanHeDialog.getInstance()
	if not _instance then
		_instance = FamilyFaQiTanHeDialog:new()
		_instance:OnCreate()
	end
	return _instance
end

function FamilyFaQiTanHeDialog.getInstanceAndShow()
	if not _instance then
		_instance = FamilyFaQiTanHeDialog:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function FamilyFaQiTanHeDialog.getInstanceNotCreate()
	return _instance
end

function FamilyFaQiTanHeDialog.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function FamilyFaQiTanHeDialog.ToggleOpenClose()
	if not _instance then
		_instance = FamilyFaQiTanHeDialog:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function FamilyFaQiTanHeDialog.GetLayoutFileName()
	return "familytanhe.layout"
end

function FamilyFaQiTanHeDialog:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, FamilyFaQiTanHeDialog)
	return self
end

function FamilyFaQiTanHeDialog:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

	self.m_pFrameWindow = CEGUI.toFrameWindow(winMgr:getWindow("tanhe/ditu"))
	self.m_pFrameWindow:getCloseButton():subscribeEvent("Clicked", FamilyFaQiTanHeDialog.DestroyDialog, nil)

	--self.m_TouXiang = winMgr:getWindow("tanhe/ditu/textbg/touxiang")
	self.m_Desc = CEGUI.toRichEditbox(winMgr:getWindow("tanhe/ditu/textbg/richanbox"))
    self.m_Text = CEGUI.toRichEditbox(winMgr:getWindow("tanhe/ditu/textbg/text"))

	self.m_FaQiTanHeBtn = CEGUI.toPushButton(winMgr:getWindow("tanhe/ditu/btn"))
    self.m_FaQiTanHeBtn:subscribeEvent("Clicked", FamilyFaQiTanHeDialog.OnFaQiTanHe, self)

    self:refreshUI()
end

-- Ë¢ÐÂ½çÃæ
function FamilyFaQiTanHeDialog:refreshUI()
    local datamanager = require "logic.faction.factiondatamanager"

    local sb = require "utils.stringbuilder":new()
    sb:SetNum("parameter1", datamanager.m_impeach.maxnum)
    local strDesc = MHSD_UTILS.get_resstring(11608)
    strDesc = sb:GetString(strDesc)
    sb:delete()
    self.m_Desc:Clear()
    self.m_Desc:AppendParseText(CEGUI.String(strDesc))
    self.m_Desc:Refresh()

    local strText = MHSD_UTILS.get_resstring(11609)
    self.m_Text:Clear()
    self.m_Text:AppendParseText(CEGUI.String(strText))
    self.m_Text:Refresh()
end

function FamilyFaQiTanHeDialog:OnFaQiTanHe()
    local function onConfirm(self, args)
        gGetMessageManager():CloseCurrentShowMessageBox()
        local datamanager = require "logic.faction.factiondatamanager"
        datamanager.m_bClickToShowImpeachUI = true
        datamanager.RequestImpeach(1)
    end

    local function onCancel(self, args)
        if CEGUI.toWindowEventArgs(args).handled ~= 1 then
            gGetMessageManager():CloseCurrentShowMessageBox()
        end
    end

    if gGetMessageManager() then
        gGetMessageManager():AddMessageBox(
            "", MHSD_UTILS.get_msgtipstring(172049),
            onConfirm, self, onCancel, self,
            eMsgType_Normal, 30000, 0, 0, nil,
            MHSD_UTILS.get_resstring(2037),
            MHSD_UTILS.get_resstring(2038))
    end
end

return FamilyFaQiTanHeDialog