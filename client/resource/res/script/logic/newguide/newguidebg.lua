require "logic.dialog"

newguidebg = {}
setmetatable(newguidebg, Dialog)
newguidebg.__index = newguidebg

local _instance
function newguidebg.getInstance()
	if not _instance then
		_instance = newguidebg:new()
		_instance:OnCreate()
	end
	return _instance
end

function newguidebg.getInstanceAndShow()
	if not _instance then
		_instance = newguidebg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function newguidebg.getInstanceNotCreate()
	return _instance
end

function newguidebg.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function newguidebg.ToggleOpenClose()
	if not _instance then
		_instance = newguidebg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function newguidebg.GetLayoutFileName()
	return "xinshoumengban_mtg.layout"
end

function newguidebg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, newguidebg)
	return self
end

function newguidebg:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

	self.bg1 = winMgr:getWindow("xinshoumengban_mtg/bg1")
	self.bg2 = winMgr:getWindow("xinshoumengban_mtg/bg2")
	self.bg3 = winMgr:getWindow("xinshoumengban_mtg/bg3")
	self.bg4 = winMgr:getWindow("xinshoumengban_mtg/bg4")

    self:GetWindow():setTopMost(true)
    self:GetWindow():getParent():bringWindowAbove(NewRoleGuideManager.getInstance():GetGuideDialog(NewRoleGuideManager.getInstance():getCurGuideId()), self:GetWindow())
end

function newguidebg.init(left, right, top, bottom)
    local sWidth = GetScreenSize().width
    local sHeight = GetScreenSize().height
    if _instance then
        _instance.bg1:setSize(CEGUI.UVector2(CEGUI.UDim(0, left), CEGUI.UDim(0, sHeight)))
        _instance.bg1:setPosition(NewVector2(0, 0))
        _instance.bg2:setSize(CEGUI.UVector2(CEGUI.UDim(0, sWidth - right), CEGUI.UDim(0, sHeight)))
        _instance.bg2:setPosition(NewVector2(right, 0))
        _instance.bg3:setSize(CEGUI.UVector2(CEGUI.UDim(0, right-left), CEGUI.UDim(0, top)))
        _instance.bg3:setPosition(NewVector2(left, 0))
        _instance.bg4:setSize(CEGUI.UVector2(CEGUI.UDim(0, right - left), CEGUI.UDim(0, sHeight-bottom)))
        _instance.bg4:setPosition(NewVector2(left, bottom)) 
    end
end

return newguidebg