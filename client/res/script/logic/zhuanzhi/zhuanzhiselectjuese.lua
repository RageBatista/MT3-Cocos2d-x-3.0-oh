require "logic.dialog"

ZhuanZhiSelectJueSe = {}
setmetatable(ZhuanZhiSelectJueSe, Dialog)
ZhuanZhiSelectJueSe.__index = ZhuanZhiSelectJueSe

local _instance



function ZhuanZhiSelectJueSe.getInstance()
	if not _instance then
		_instance = ZhuanZhiSelectJueSe:new()
		_instance:OnCreate()
	end
	return _instance
end

function ZhuanZhiSelectJueSe.getInstanceAndShow()
	if not _instance then
		_instance = ZhuanZhiSelectJueSe:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function ZhuanZhiSelectJueSe.getInstanceNotCreate()
	return _instance
end

function ZhuanZhiSelectJueSe.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function ZhuanZhiSelectJueSe.ToggleOpenClose()
	if not _instance then
		_instance = ZhuanZhiSelectJueSe:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function ZhuanZhiSelectJueSe.GetLayoutFileName()
	return "zhuanzhijuese.layout"
end

function ZhuanZhiSelectJueSe:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, ZhuanZhiSelectJueSe)
	return self
end

function ZhuanZhiSelectJueSe:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

	self.list = CEGUI.toScrollablePane(winMgr:getWindow("zhuanzhijuesechoose/list"))

	for id = 0, 16 do
		--BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(gGetDataManager():GetMainCharacterShape())
		local Shape = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(SchoolID[1][id + 1])
--local Shape = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(SchoolID[ZhuanZhiSex][id + 1])
		local prefix = id

		local button = CEGUI.toPushButton(winMgr:loadWindowLayout("zhuanzhijuesecell.layout","".. prefix))

		local nametext = winMgr:getWindow(prefix .. "zhuanzhijuesecell/text")

		local HeadIcon = CEGUI.Window.toItemCell(winMgr:getWindow(prefix.. "zhuanzhijuesecell/item"))

		HeadIcon:SetImage(gGetIconManager():GetImageByID(Shape.littleheadID))

		self.list:addChildWindow(button)

		nametext:setText(Shape.name)

		button:setID(id + 1)

		button:setPosition(CEGUI.UVector2(CEGUI.UDim(0, 1), CEGUI.UDim(0, 1 + id * button:getHeight():asAbsolute(0))))
		button:subscribeEvent("MouseClick", ZhuanZhiSelectJueSe.ChooseJueSe, self)

		
	end

end

function ZhuanZhiSelectJueSe:ChooseJueSe(e)
	local wndArg = CEGUI.toWindowEventArgs(e)
	if not wndArg.window then
		return
	end
	local nId = wndArg.window:getID()

	local dlg = ZhuanZhiDlg.getInstanceNotCreate()
	if dlg then
		dlg:RefreshSelectSchool(nId)
	end

	ZhuanZhiSelectJueSe.DestroyDialog()
end

return ZhuanZhiSelectJueSe