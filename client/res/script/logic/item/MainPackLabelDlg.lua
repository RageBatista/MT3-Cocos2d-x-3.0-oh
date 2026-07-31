require "utils.mhsdutils"
require "logic.item.mainpackdlg"
require "logic.shop.commerceselldlg"

local super = require "logic.LabelDlg"
local Depot = require "logic.item.depot"

local DLG_CLASSES = { }
DLG_CLASSES[0] = CMainPackDlg
DLG_CLASSES[1] = Depot
--注释出售按钮 DLG_CLASSES[2] = CommerceSellDlg

CMainPackLabelDlg = { }
setmetatable(CMainPackLabelDlg, super)
CMainPackLabelDlg.__index = CMainPackLabelDlg

function CMainPackLabelDlg:OnClose()
	for i = 0, self.d_usedLabel - 1 do
		local pDlg = self:GetDialogInstance(i, false)
		if (pDlg) then
			local dlgWin = pDlg:GetWindow()
			if (dlgWin) then
				dlgWin:removeEvent(CEGUI.Window.EventAlphaChanged)
				dlgWin:removeEvent(CEGUI.Window.EventInheritsAlphaChanged)
				dlgWin:removeEvent(CEGUI.Window.EventHidden)
				dlgWin:removeEvent(CEGUI.Window.EventShown)
			end

			pDlg:OnClose()
		end
	end

	if (self.m_pMainFrame) then
		for i, v in pairs(CLabelDlg.s_labels) do
			if v == self.m_pMainFrame:getName() then
				table.remove(CLabelDlg.s_labels, i)
				break
			end
		end
	end
	super.OnClose(self)
    require("logic.tips.commontipdlg").DestroyDialog()
end

function CMainPackLabelDlg:Show(index)
	if index == nil then
		index = 0
	end

	if (self.d_usedLabel <= 0) then
		return false
	end

	if (index < 0 or index >= self.d_usedLabel) then
		return false
	end

	for i = 0, self.d_usedLabel - 1 do
		if (i == index) then
			self.d_labels[i].d_btn:SetPushState(true)
			self:createOrShowDialog(i)
		else
			self.d_labels[i].d_btn:SetPushState(false)

			local pDialog = self:GetDialogInstance(i, false)
			if (pDialog) then
				pDialog:SetVisible(false)
			end
		end
	end

	self:GetWindow():setVisible(self:getNeedShow())
	self.d_curshow = index
	self:SetVisible(true)

	return true
end

function CMainPackLabelDlg:getNeedShow()
	for i = 0, LABEL_NUM - 1 do
		local pDialog = self:GetDialogInstance(i, false)
		if (pDialog) then
			local dlgWin = pDialog:GetWindow()
			if (dlgWin) then
				if (dlgWin:isVisible() and dlgWin:getEffectiveAlpha() > 0.95) then
					return true
				end
			end
		end
	end
	if (isDepotVisible()) then
		return true
	end
	return false
end

function CMainPackLabelDlg:HandleDlgStateChange(e)
	self:GetWindow():setVisible(self:getNeedShow())
	return true
end

-- 当背包、仓库等页签窗口的ZOrder发生变化时，重新把本窗口提到这些页签窗口的前面
function CMainPackLabelDlg:HandleDialogZOrderChanged(e)
	local args = CEGUI.toWindowEventArgs(e)
	if args and args.window and args.window:isVisible() and self.m_pMainFrame and self.m_pMainFrame:getParent() then
		self.m_pMainFrame:getParent():bringWindowAbove(self.m_pMainFrame, args.window)
	end
end

function CMainPackLabelDlg:createOrShowDialog(i)
	local pDialog = self:GetDialogInstance(i, false)
	if (not pDialog) then
		pDialog = self:GetDialogInstance(i, true)
		if (pDialog) then
			local dlgWin = pDialog:GetWindow()
			if (dlgWin) then
				dlgWin:subscribeEvent(CEGUI.Window.EventAlphaChanged, CMainPackLabelDlg.HandleDlgStateChange, self)
				dlgWin:subscribeEvent(CEGUI.Window.EventInheritsAlphaChanged, CMainPackLabelDlg.HandleDlgStateChange, self)
				dlgWin:subscribeEvent(CEGUI.Window.EventHidden, CMainPackLabelDlg.HandleDlgStateChange, self)
				dlgWin:subscribeEvent(CEGUI.Window.EventShown, CMainPackLabelDlg.HandleDlgStateChange, self)
				dlgWin:subscribeEvent(CEGUI.Window.EventZOrderChanged, CMainPackLabelDlg.HandleDialogZOrderChanged, self)
			end


			function pDialog:DestroyDialog()
				if (CMainPackLabelDlg:getInstanceOrNot()) then
					CMainPackLabelDlg:getInstanceOrNot():DestroyDialog()
				end
			end
		end
	end

	if pDialog then
		pDialog:SetVisible(true)

		local dlgWin = pDialog:GetWindow()
		if (dlgWin) then
			dlgWin:setModalState(true)
			self:GetWindow():getParent():bringWindowAbove(self:GetWindow(), dlgWin)
		end
	end
end

function CMainPackLabelDlg:HandleLabelClick(e)
	local mouseevent = CEGUI.toMouseEventArgs(e)
	local curButton = CEGUI.toPushButton(mouseevent.window)
	if (curButton == nil) then
		return true
	end

	for i = 0, self.d_usedLabel - 1 do
		if (self.d_labels[i].d_btn == mouseevent.window) then
			self.d_labels[i].d_btn:SetPushState(true)

			self:createOrShowDialog(i)

		else
			self.d_labels[i].d_btn:SetPushState(false)

			local pDialog = self:GetDialogInstance(i, false)
			if (pDialog) then
				pDialog:SetVisible(false)
			end
		end
	end

	self:GetWindow():setVisible(self:getNeedShow())
	self.d_curshow = index
	self:SetVisible(true)

	return true
end

function CMainPackLabelDlg:AddLabel(title)
	if (self.d_usedLabel < 0 or self.d_usedLabel >= LABEL_NUM) then
		return false
	end
	self.d_labels[self.d_usedLabel].d_btn:setText(title)
	self.d_labels[self.d_usedLabel].d_btn:subscribeEvent(CEGUI.PushButton.EventClicked, CMainPackLabelDlg.HandleLabelClick, self)
	self.d_labels[self.d_usedLabel].d_btn:setVisible(true)
	self.d_labels[self.d_usedLabel].d_btn:EnableClickAni(false)
	self.d_usedLabel = self.d_usedLabel + 1
	return true
end

function CMainPackLabelDlg:getPrefix()
	return enumLabel.enumPackLabel
end

function CMainPackLabelDlg:GetDialogInstance(index, autonew)
	local dlgClass = DLG_CLASSES[index]
	if (dlgClass) then
		if (autonew) then
			return dlgClass:getInstance()
		else
			return dlgClass:getInstanceOrNot()
		end
	end
	return nil
end

function CMainPackLabelDlg:OnCreate()
	super.OnCreate(self)
	self:AddLabel(MHSD_UTILS.get_resstring(2696))
	self:AddLabel(MHSD_UTILS.get_resstring(2697))
   --注释出售按 self:AddLabel(MHSD_UTILS.get_resstring(2698))
end

function CMainPackLabelDlg.new()
	local obj = { }
	setmetatable(obj, CMainPackLabelDlg)
	obj:OnCreate()
	return obj
end

return CMainPackLabelDlg
