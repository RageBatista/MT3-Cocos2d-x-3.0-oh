require "logic.dialog"

ZhuanZhiTips = {}
setmetatable(ZhuanZhiTips, Dialog)
ZhuanZhiTips.__index = ZhuanZhiTips

local _instance
function ZhuanZhiTips.getInstance()
	if not _instance then
		_instance = ZhuanZhiTips:new()
		_instance:OnCreate()
	end
	return _instance
end

function ZhuanZhiTips.getInstanceAndShow()
	if not _instance then
		_instance = ZhuanZhiTips:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function ZhuanZhiTips.getInstanceNotCreate()
	return _instance
end

function ZhuanZhiTips.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function ZhuanZhiTips.ToggleOpenClose()
	if not _instance then
		_instance = ZhuanZhiTips:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function ZhuanZhiTips.GetLayoutFileName()
	return "zhuanzhishuoming.layout"
end

function ZhuanZhiTips:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, ZhuanZhiTips)
	return self
end

function ZhuanZhiTips:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

	self.text1 = winMgr:getWindow("zhuanzhishuoming/zhiye2")
	self.text1:setText("")

	self.text2 = winMgr:getWindow("zhuanzhishuoming/juese1")
	self.text2:setText("")
end

function ZhuanZhiTips:RefreshData(schoollist, classlist)
	local str1 = ""
	local str2 = ""
	for i = 1, #schoollist do
		local Shape = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(schoollist[i])

		if i == #schoollist or i >= 10 then
			str1 = str1 .. Shape.name .. "."
		else
			str1 = str1 .. Shape.name .. ","
		end

	end
	self.text2:setText(str1)

	for i = 1, #classlist do
		local school = BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(classlist[i])

		if i == #classlist or i >= 10 then
			str2 = str2 .. school.name .. "."
		else
			str2 = str2 .. school.name .. ","
		end
	end
	self.text1:setText(str2)
end

return ZhuanZhiTips