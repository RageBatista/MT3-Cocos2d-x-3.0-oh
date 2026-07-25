require "utils.mhsdutils"
require "logic.dialog"
require "logic.pet.petpropertydlgnew"
require "logic.pet.petlianyaodlg"
require "logic.pet.petfeeddlg"
require "logic.pet.petaddskillbook"
require "logic.pet.petgallerydlg"


TaskLabel = {}
setmetatable(TaskLabel, Dialog)
TaskLabel.__index = TaskLabel

local _instance

function TaskLabel.getInstance()
	if not _instance then
		_instance = TaskLabel:new()
		_instance:OnCreate()
	end
	return _instance
end

function TaskLabel.getInstanceNotCreate()
	return _instance
end

function TaskLabel.GetLayoutFileName()
	return "lable.layout"
end

function TaskLabel:OnCreate()
	Dialog.OnCreate(self,nil, "tasklabel")
	self:GetWindow():setRiseOnClickEnabled(false)

	local winMgr = CEGUI.WindowManager:getSingleton()
	self.m_pButton1 = CEGUI.toPushButton(winMgr:getWindow(tostring("tasklabel") .. "Lable/button"))
    self.m_pButton1:SetMouseLeaveReleaseInput(false)
	self.m_pButton2 = CEGUI.toPushButton(winMgr:getWindow(tostring("tasklabel") .. "Lable/button1"))
    self.m_pButton2:SetMouseLeaveReleaseInput(false)
	self.m_pButton3 = CEGUI.toPushButton(winMgr:getWindow(tostring("tasklabel") .. "Lable/button2"))
    self.m_pButton3:SetMouseLeaveReleaseInput(false)
	self.m_pButton4 = CEGUI.toPushButton(winMgr:getWindow(tostring("tasklabel") .. "Lable/button3"))
    self.m_pButton4:SetMouseLeaveReleaseInput(false)
	self.m_pButton5 = CEGUI.toPushButton(winMgr:getWindow(tostring("tasklabel") .. "Lable/button4"))
    self.m_pButton5:SetMouseLeaveReleaseInput(false)
	
	self.m_pButton1:setText(MHSD_UTILS.get_resstring( 11200 ))
	self.m_pButton2:setText(MHSD_UTILS.get_resstring( 11201 ))
	self.m_pButton3:setVisible(false);
	self.m_pButton4:setVisible(false);
	self.m_pButton5:setVisible(false);
	
	self.m_pButton1:EnableClickAni(false)
	self.m_pButton2:EnableClickAni(false)
	self.m_pButton3:EnableClickAni(false)
	self.m_pButton4:EnableClickAni(false)
	self.m_pButton5:EnableClickAni(false)
	
	self.m_pButton1:subscribeEvent("Clicked", TaskLabel.HandleLabel1BtnClicked, self);
	self.m_pButton2:subscribeEvent("Clicked", TaskLabel.HandleLabel2BtnClicked, self);
	--self.m_pButton3:subscribeEvent("Clicked", PetLabel.HandleLabel3BtnClicked, self);
	--self.m_pButton4:subscribeEvent("Clicked", PetLabel.HandleLabel4BtnClicked, self);
	
end


function TaskLabel:new()
	local self={}
	self = Dialog:new()
	setmetatable(self, TaskLabel)
	return self
end

function TaskLabel.DestroyDialog()
	LogInfo("TaskLabel destroy dialog")
	
	if _instance then
		--close all
		local dlg = Renwudialog.getInstanceNotCreate()
		if dlg then
			dlg:OnClose()
		end	
		
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function TaskLabel.Show(index)
	--在这里更新显示任务
	TaskLabel.getInstance()
	index = index or (gCommon.curTaskLabelIdx or 1)
	gCommon.curTaskLabelIdx = nil
	_instance:ShowOnly(index)
end


function TaskLabel:setButtonPushed(idx)
	local function getBtn(idx)
		return  (idx==1 and self.m_pButton1 or
		(idx==2 and self.m_pButton2 or
		(idx==3 and self.m_pButton3 or
		(idx==4 and self.m_pButton4 or
		(idx==5 and self.m_pButton5)))))
	end
	local btn = getBtn(gCommon.curTaskLabelIdx)
	if btn then
		btn:SetPushState(false)
	end
	
	btn = getBtn(idx)
	if btn then
		btn:SetPushState(true)
	end
end

function TaskLabel:ShowOnly(index)
	self:setButtonPushed(index)
	if gCommon.curTaskLabelIdx == index then
		return
	end
	
	if index == 1 then
		local  dlg = Renwudialog.getInstanceAndShow()
		dlg:RefreshData(index)
		self:SubscribeEvent(dlg:GetWindow())
		self:GetWindow():getParent():bringWindowAbove(self:GetWindow(), dlg:GetWindow())
	elseif index == 2 then
		local  dlg = Renwudialog.getInstanceAndShow()
		dlg:RefreshData(index)
		self:SubscribeEvent(dlg:GetWindow())
		self:GetWindow():getParent():bringWindowAbove(self:GetWindow(), dlg:GetWindow())
	end		

	--self:SetVisible(true)
	gCommon.curTaskLabelIdx = index
end

function TaskLabel:HandleLabel1BtnClicked(e)
	LogInfo("label 1 clicked")
	TaskLabel.getInstance():ShowOnly(1)
	return true
end

function TaskLabel:HandleLabel2BtnClicked(e)
	LogInfo("label 2 clicked")
	TaskLabel.getInstance():ShowOnly(2)
	return true
end


function TaskLabel:SubscribeEvent(wnd)
	wnd:subscribeEvent("AlphaChanged", TaskLabel.HandleDlgStateChange, self)
	wnd:subscribeEvent("Shown", TaskLabel.HandleDlgStateChange, self)
	wnd:subscribeEvent("Hidden", TaskLabel.HandleDlgStateChange, self)
	wnd:subscribeEvent("InheritAlphaChanged", TaskLabel.HandleDlgStateChange, self)
end

function TaskLabel:RemoveEvent(wnd)
	wnd:removeEvent("AlphaChanged")
	wnd:removeEvent("Shown")
	wnd:removeEvent("Hidden")
	wnd:removeEvent("InheritAlphaChanged")
end

function TaskLabel:HandleDlgStateChange(args)
	local  dlg = Renwudialog.getInstanceNotCreate()
	if dlg and dlg:IsVisible() and dlg:GetWindow():getEffectiveAlpha() > 0.95 then
		self:SetVisible(true)
		return
	end
	
	self:SetVisible(false)
end


return TaskLabel
