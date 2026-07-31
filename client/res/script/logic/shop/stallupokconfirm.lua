------------------------------------------------------------------
-- 摆摊上架成功确认
------------------------------------------------------------------
require "logic.dialog"

StallUpOkConfirm = {}
setmetatable(StallUpOkConfirm, Dialog)
StallUpOkConfirm.__index = StallUpOkConfirm

local _instance
function StallUpOkConfirm.getInstance()
	if not _instance then
		_instance = StallUpOkConfirm:new()
		_instance:OnCreate()
	end
	return _instance
end

function StallUpOkConfirm.getInstanceAndShow()
	if not _instance then
		_instance = StallUpOkConfirm:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function StallUpOkConfirm.getInstanceNotCreate()
	return _instance
end

function StallUpOkConfirm.DestroyDialog()
	if _instance then
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function StallUpOkConfirm.ToggleOpenClose()
	if not _instance then
		_instance = StallUpOkConfirm:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function StallUpOkConfirm.GetLayoutFileName()
	return "baitanshangjiachenggong.layout"
end

function StallUpOkConfirm:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, StallUpOkConfirm)
	return self
end

function StallUpOkConfirm:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

	self.titleText = winMgr:getWindow("baitanshangjiachenggong/diban/biaoti/wenzi")
	self.shangjiaText = winMgr:getWindow("baitanshangjiachenggong/diban/wenben2")
	self.checkbox = CEGUI.toCheckbox(winMgr:getWindow("baitanshangjiachenggong/diban/tishi"))
	self.okBtn = CEGUI.toPushButton(winMgr:getWindow("baitanshangjiachenggong/diban/queding"))
	self.taxText = winMgr:getWindow("baitanshangjiachenggong/diban/wenben31")
	self.gongshiText = winMgr:getWindow("baitanshangjiachenggong/diban/gongshi")

	self.okBtn:subscribeEvent("Clicked", StallUpOkConfirm.handleOkClicked, self)

end

function StallUpOkConfirm:setViewType(israrity)
	local title1, title2 = string.match(self.titleText:getText(), "(.*)/(.*)")
	if israrity == 0 then --非珍品
		self.titleText:setText(title1)
		self.gongshiText:setVisible(false)
	else
		self.titleText:setText(title2)
		self.shangjiaText:setVisible(false)
	end
end

function StallUpOkConfirm:handleOkClicked(args)
	if self.checkbox:isSelected() then
		--保存时间点，7天内不再显示这个提示
		local timestamp = gGetServerTime()
		local iniMgr = IniManager("SystemSetting.ini")
		iniMgr:WriteValueByName("GameConfig", "shangjiashijian", tostring(timestamp))
	end
	StallUpOkConfirm.DestroyDialog()
end

return StallUpOkConfirm
