------------------------------------------------------------------
-- 确定/取消 确认框
------------------------------------------------------------------
require "logic.dialog"

MessageBoxSimple = {}
setmetatable(MessageBoxSimple, Dialog)
MessageBoxSimple.__index = MessageBoxSimple

local _instance

function MessageBoxSimple.show(text, okFunc, okTarget, cancelFunc, cancelTarget, okTitle, cancelTitle)
	if not _instance or not _instance:IsVisible() then
		if not _instance then
			_instance = MessageBoxSimple:new()
			_instance:OnCreate()
		else
			_instance:SetVisible(true)
		end
	end
	_instance:pushMsg(text, okFunc, okTarget, cancelFunc, cancelTarget, okTitle, cancelTitle)
	return
end

function MessageBoxSimple.DestroyDialog()
	if _instance then
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function MessageBoxSimple.GetLayoutFileName()
	return "messageboxsimple.layout"
end

function MessageBoxSimple:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, MessageBoxSimple)
	return self
end

function MessageBoxSimple:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

	self.okBtn = CEGUI.toPushButton(winMgr:getWindow("messageboxsimple/OK"))
	self.cancelBtn = CEGUI.toPushButton(winMgr:getWindow("messageboxsimple/Canle"))
	self.text = winMgr:getWindow("messageboxsimple/text")

	self.okBtn:subscribeEvent("Clicked", MessageBoxSimple.handleOkClicked, self)
	self.cancelBtn:subscribeEvent("Clicked", MessageBoxSimple.handleCancelClicked, self)

	self.args = {}
	self.curArg = nil
	self.defaultOkTitle = self.okBtn:getText()
	self.defaultCancelTitle = self.cancelBtn:getText()
end

function MessageBoxSimple:pushMsg(text, okFunc, okTarget, cancelFunc, cancelTarget, okTitle, cancelTitle)
	local arg = {}
	arg.text = text
	arg.okFunc = okFunc
	arg.okTarget = okTarget
	arg.cancelFunc = cancelFunc
	arg.cancelTarget = cancelTarget
	arg.okTitle = okTitle
	arg.cancelTitle = cancelTitle
	
	if not self.curArg then
		self.curArg = arg
		self:refresh()
	else
		table.insert(self.args, arg)
	end
end

function MessageBoxSimple:refresh()
	if self.curArg then
		self.text:setText(self.curArg.text)
		if string.find(self.curArg.text, "%[colour") then
			self.text:setProperty("TextColours", "FFFFFFFF")
		else
			self.text:setProperty("TextColours", "ff8c5e2a")
		end
			
		self.okBtn:setText(self.curArg.okTitle or self.defaultOkTitle)
		self.cancelBtn:setText(self.curArg.cancelTitle or self.defaultCancelTitle)
	else
		MessageBoxSimple.DestroyDialog()
	end
end

function MessageBoxSimple:handleOkClicked(args)
	if self.curArg and self.curArg.okFunc then
		self.curArg.okFunc(self.curArg.okTarget)
		self.curArg = nil
	end
	
	if self.args[1] then
		self.curArg = self.args[1]
		table.remove(self.args, 1)
		self:refresh()
	else
		MessageBoxSimple.DestroyDialog()
	end
end

function MessageBoxSimple:handleCancelClicked(args)
	if self.curArg and self.curArg.cancelFunc then
		self.curArg.cancelFunc(self.curArg.cancelTarget)
		self.curArg = nil
	end
	
	if self.args[1] then
		self.curArg = self.args[1]
		table.remove(self.args, 1)
		self:refresh()
	else
		MessageBoxSimple.DestroyDialog()
	end
end

return MessageBoxSimple
