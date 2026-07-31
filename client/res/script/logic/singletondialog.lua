require "logic.dialog"

local T = {}
setmetatable(T, Dialog)
T.__index = T
function T:GetSingletonDialogAndShowIt()
	if not self._instance then
		self._instance = self.new()
	end
	if not self._instance:IsVisible() then
		self._instance:SetVisible(true)
	end
	return self._instance
end

function T:DestroyDialog()
	if self._instance then
		self:OnClose()
		getmetatable(self)._instance = nil
	end
end

function T:OnClose()
	Dialog.OnClose(self);
	getmetatable(self)._instance = nil;
end

function T:getInstanceOrNot()
	return self._instance
end

function T:getInstanceNotCreateAndShow()
	  if self._instance then
    self._instance:SetVisible(true)
  end
end

function T:getInstance()
	if not self._instance then
		self._instance = self.new()
	end
	return self._instance
end

function T:hide()
	print("singletondialog  T:hide()")
  if self._instance then
    self._instance:SetVisible(false)
  end
end

function T:ToggleOpenHide()
	if not self._instance then
		self:GetSingletonDialogAndShowIt();
	else
		local bVisible = self._instance:IsVisible();
		if (bVisible) then
			self._instance:OnClose();
		else
			self._instance:SetVisible(true);
		end
	end
end

return T
