require "logic.dialog"

ShouJiYanZheng = {}
setmetatable(ShouJiYanZheng, Dialog)
ShouJiYanZheng.__index = ShouJiYanZheng

local _instance
function ShouJiYanZheng.getInstance()
	if not _instance then
		_instance = ShouJiYanZheng:new()
		_instance:OnCreate()
	end
	return _instance
end

function ShouJiYanZheng.getInstanceAndShow()
	if not _instance then
		_instance = ShouJiYanZheng:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function ShouJiYanZheng.getInstanceNotCreate()
	return _instance
end

function ShouJiYanZheng.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function ShouJiYanZheng.ToggleOpenClose()
	if not _instance then
		_instance = ShouJiYanZheng:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function ShouJiYanZheng.GetLayoutFileName()
	return "shoujiyanzheng.layout"
end

function ShouJiYanZheng:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, ShouJiYanZheng)
	return self
end

function ShouJiYanZheng:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

	self.m_desc_free = winMgr:getWindow("shoujiyanzheng/text2")
	self.m_desc_pointcard = winMgr:getWindow("shoujiyanzheng/text3")
    if IsPointCardServer() then
        self.m_desc_free:setVisible(false)
        self.m_desc_pointcard:setVisible(true)
    else
        self.m_desc_free:setVisible(true)
        self.m_desc_pointcard:setVisible(false)
    end

	self.m_btn = CEGUI.toPushButton(winMgr:getWindow("shoujiyanzheng/btn"))
    self.m_btn:subscribeEvent("Clicked", ShouJiYanZheng.OnClicked, self)

	self.m_closeBtn = CEGUI.toPushButton(winMgr:getWindow("shoujiyanzheng/guanbi"))
    self.m_closeBtn:subscribeEvent("Clicked", ShouJiYanZheng.DestroyDialog, nil)
end

function ShouJiYanZheng:OnClicked()
    ShouJiYanZheng.DestroyDialog()
    require("logic.shoujianquan.shoujiguanlianshuru").getInstanceAndShow()
end

return ShouJiYanZheng