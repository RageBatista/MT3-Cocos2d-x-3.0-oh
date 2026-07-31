require "logic.dialog"

CostConfirmBox = {}
setmetatable(CostConfirmBox, Dialog)
CostConfirmBox.__index = CostConfirmBox

local _instance
function CostConfirmBox.getInstance()
	if not _instance then
		_instance = CostConfirmBox:new()
		_instance:OnCreate()
	end
	return _instance
end

function CostConfirmBox.getInstanceAndShow()
	if not _instance then
		_instance = CostConfirmBox:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function CostConfirmBox.getInstanceNotCreate()
	return _instance
end

function CostConfirmBox.DestroyDialog()
	if _instance then
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function CostConfirmBox.GetLayoutFileName()
	return "messageboxchongwu_mtg.layout"
end

function CostConfirmBox:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, CostConfirmBox)
	return self
end

function CostConfirmBox:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

	self.sureBtn = CEGUI.toPushButton(winMgr:getWindow("messageboxchongwu_mtg/OK"))
	self.cancel = CEGUI.toPushButton(winMgr:getWindow("messageboxchongwu_mtg/Canle"))
	self.text = winMgr:getWindow("messageboxchongwu_mtg/text")
	self.des = winMgr:getWindow("messageboxchongwu_mtg/des")
	self.costNum = winMgr:getWindow("messageboxchongwu_mtg/coinNum")
	self.icon = winMgr:getWindow("messageboxchongwu_mtg/corn")

	self.sureBtn:subscribeEvent("Clicked", CostConfirmBox.handleSureClicked, self)
	self.cancel:subscribeEvent("Clicked", CostConfirmBox.handleCancelClicked, self)

end

function CostConfirmBox.show(text, des, cost, surefunc, suretarget, cancelfunc, canceltarget)
	CostConfirmBox.getInstanceAndShow()
	_instance.text:setText(text)
	_instance.des:setText(des)
	_instance.costNum:setText(cost)
	_instance.surefunc = surefunc
	_instance.suretarget = suretarget
	_instance.cancelfunc = cancelfunc
	_instance.canceltarget = canceltarget
	return _instance
end

function CostConfirmBox:handleSureClicked(args)
	local surefunc = self.surefunc
	local suretarget = self.suretarget
	
	self.DestroyDialog()
	if surefunc then
		surefunc(suretarget)
	end
	
end

function CostConfirmBox:handleCancelClicked(args)
	local cancelfunc = self.cancelfunc
	local canceltarget = self.canceltarget
	
	self.DestroyDialog()
	if cancelfunc then
		cancelfunc(canceltarget)
	end
end

return CostConfirmBox
