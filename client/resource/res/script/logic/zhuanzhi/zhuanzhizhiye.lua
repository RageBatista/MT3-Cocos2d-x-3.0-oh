require "logic.dialog"

ZhuanZhiZhiYe = {}
setmetatable(ZhuanZhiZhiYe, Dialog)
ZhuanZhiZhiYe.__index = ZhuanZhiZhiYe

local _instance
function ZhuanZhiZhiYe.getInstance()
	if not _instance then
		_instance = ZhuanZhiZhiYe:new()
		_instance:OnCreate()
	end
	return _instance
end

function ZhuanZhiZhiYe.getInstanceAndShow()
	if not _instance then
		_instance = ZhuanZhiZhiYe:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function ZhuanZhiZhiYe.getInstanceNotCreate()
	return _instance
end

function ZhuanZhiZhiYe.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function ZhuanZhiZhiYe.ToggleOpenClose()
	if not _instance then
		_instance = ZhuanZhiZhiYe:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function ZhuanZhiZhiYe.GetLayoutFileName()
	return "zhuanzhixuanze.layout"
end

function ZhuanZhiZhiYe:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, ZhuanZhiZhiYe)
	return self
end

function ZhuanZhiZhiYe:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

	self.list = CEGUI.toScrollablePane(winMgr:getWindow("zhuanzhidi/list"))

end

function ZhuanZhiZhiYe:GenerateClassInfo(schoolid)

	local winMgr = CEGUI.WindowManager:getSingleton()

	for id = 1, #ZhiYeStrID[1][schoolid] do
		local school = BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(ZhiYeStrID[1][schoolid][id])

		local prefix = id

		local button = CEGUI.toPushButton(winMgr:loadWindowLayout("zhuanzhizhiyecell.layout","".. prefix))

		local nametext = winMgr:getWindow(prefix .. "zhuanzhizhiyecell/text")
		nametext:setText(school.name)

		local HeadIcon = winMgr:getWindow(prefix.. "zhuanzhizhiyecell/tubiao")
		HeadIcon:setProperty("Image", school.schooliconpath)
		
		self.list:addChildWindow(button)

		button:setID(id)

		button:setPosition(CEGUI.UVector2(CEGUI.UDim(0, 2), CEGUI.UDim(0, 2 + (id-1) * button:getHeight():asAbsolute(0))))
		button:subscribeEvent("MouseClick", ZhuanZhiZhiYe.HundleSelectClick, self)

		
	end

end

function ZhuanZhiZhiYe:HundleSelectClick(e)
	local wndArg = CEGUI.toWindowEventArgs(e)
	if not wndArg.window then
		return
	end
	local nId = wndArg.window:getID()

	local dlg = ZhuanZhiDlg.getInstanceNotCreate()
	if dlg then
		dlg:RefreshSelectClass(nId)
	end

	ZhuanZhiZhiYe.DestroyDialog()
end

return ZhuanZhiZhiYe