require "logic.dialog"

JinglingQuestDialog = {}
setmetatable(JinglingQuestDialog, Dialog)
JinglingQuestDialog.__index = JinglingQuestDialog

local totalTabCount = 2
local _instance
function JinglingQuestDialog.getInstance()
	if not _instance then
		_instance = JinglingQuestDialog:new()
		_instance:OnCreate()
	end
	return _instance
end

function JinglingQuestDialog.getInstanceAndShow()
	if not _instance then
		_instance = JinglingQuestDialog:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function JinglingQuestDialog.getInstanceNotCreate()
	return _instance
end

function JinglingQuestDialog.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function JinglingQuestDialog.ToggleOpenClose()
	if not _instance then
		_instance = JinglingQuestDialog:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function JinglingQuestDialog.GetLayoutFileName()
	return "lable.layout"
end

function JinglingQuestDialog:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, JinglingQuestDialog)
	return self
end

function JinglingQuestDialog:OnCreate()
    Dialog.OnCreate(self, nil, "jinglinglabel")
    local winMgr = CEGUI.WindowManager:getSingleton()

    self.m_pButton1 = CEGUI.toPushButton(winMgr:getWindow("jinglinglabel" .. "Lable/button"))
    self.m_pButton2 = CEGUI.toPushButton(winMgr:getWindow("jinglinglabel" .. "Lable/button1"))
    self.m_pButton3 = CEGUI.toPushButton(winMgr:getWindow("jinglinglabel" .. "Lable/button2"))
    self.m_pButton4 = CEGUI.toPushButton(winMgr:getWindow("jinglinglabel" .. "Lable/button3"))
    self.m_pButton5 = CEGUI.toPushButton(winMgr:getWindow("jinglinglabel" .. "Lable/button4"))

    self.m_pButton1:SetMouseLeaveReleaseInput(false)
    self.m_pButton2:SetMouseLeaveReleaseInput(false)
    self.m_pButton3:SetMouseLeaveReleaseInput(false)
    self.m_pButton4:SetMouseLeaveReleaseInput(false)
    self.m_pButton5:SetMouseLeaveReleaseInput(false)

    self.m_pButton3:setVisible(false)
    self.m_pButton4:setVisible(false)
    self.m_pButton5:setVisible(false)

    self.m_pButton1:subscribeEvent("Clicked", JinglingQuestDialog.HandleLabel1BtnClicked, self)
    self.m_pButton2:subscribeEvent("Clicked", JinglingQuestDialog.HandleLabel2BtnClicked, self)
end

function JinglingQuestDialog:HandleLabel1BtnClicked(e)
    require "logic.jingling.jinglingdlg".ClickTabRedian()
    return true
end

function JinglingQuestDialog:HandleLabel2BtnClicked(e)
    require "logic.jingling.jinglingdlg".ClickWenda()
    return true
end

function JinglingQuestDialog.showTab(index)
    _instance:setButtonPushed(index)
    require "logic.jingling.jinglingdlg".showPage(index)
end

function JinglingQuestDialog.show(index)
    JinglingQuestDialog.getInstance()
    JinglingQuestDialog.showTab(index)
end

function JinglingQuestDialog:setButtonPushed(idx)
    for i = 1, totalTabCount do
        self["m_pButton" .. i]:SetPushState(i == idx)
    end
end

return JinglingQuestDialog