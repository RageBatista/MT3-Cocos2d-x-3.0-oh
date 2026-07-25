require "logic.dialog"

ZhuanZhiBaoShiList = {}
setmetatable(ZhuanZhiBaoShiList, Dialog)
ZhuanZhiBaoShiList.__index = ZhuanZhiBaoShiList

local _instance
function ZhuanZhiBaoShiList.getInstance()
	if not _instance then
		_instance = ZhuanZhiBaoShiList:new()
		_instance:OnCreate()
	end
	return _instance
end

function ZhuanZhiBaoShiList.getInstanceAndShow()
	if not _instance then
		_instance = ZhuanZhiBaoShiList:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function ZhuanZhiBaoShiList.getInstanceNotCreate()
	return _instance
end

function ZhuanZhiBaoShiList.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function ZhuanZhiBaoShiList.ToggleOpenClose()
	if not _instance then
		_instance = ZhuanZhiBaoShiList:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function ZhuanZhiBaoShiList.GetLayoutFileName()
	return "zhuanzhibaoshilist.layout"
end

function ZhuanZhiBaoShiList:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, ZhuanZhiBaoShiList)
	return self
end

function ZhuanZhiBaoShiList:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

	self.m_GemList = CEGUI.toScrollablePane(winMgr:getWindow("zhuanzhibaoshilist/list"))

end

function ZhuanZhiBaoShiList:SetData(qulity, gemid)
	self.m_Qulity = qulity
	local winMgr = CEGUI.WindowManager:getSingleton()

	local count = 0
	for id = 1, 9 do
		local nTabId = BaoShiLvStartID[self.m_Qulity] +(id - 1)

		if nTabId ~= gemid then
			local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nTabId)
			if not itemAttrCfg then
				return
			end

			local prefix = id + 10000

			local button = CEGUI.toPushButton(winMgr:loadWindowLayout("zhuanzhibaoshicell.layout", "" .. prefix))
			local itemCell = CEGUI.toItemCell(winMgr:getWindow(prefix .. "zhuanzhibaoshicell/daojukuang"))
			local name = winMgr:getWindow(prefix .. "zhuanzhibaoshicell/mingcheng")
			local describe = winMgr:getWindow(prefix .. "zhuanzhibaoshicell/miaoshu")

			name:setText(itemAttrCfg.name)
			itemCell:SetImage(gGetIconManager():GetItemIconByID(itemAttrCfg.icon))
			SetItemCellBoundColorByQulityItemWithId(itemCell, itemAttrCfg.id)

			local gemconfig = BeanConfigManager.getInstance():GetTableByName("item.cgemeffect"):getRecorder(nTabId)
			if gemconfig then
				local strEffect = gemconfig.effectdes
				describe:setText(strEffect)
			end

			self.m_GemList:addChildWindow(button)

			button:setID(itemAttrCfg.id)

			button:setPosition(CEGUI.UVector2(CEGUI.UDim(0, 2), CEGUI.UDim(0, 2 + count * button:getHeight():asAbsolute(0))))
			button:subscribeEvent("MouseClick", ZhuanZhiBaoShiList.ChooseGem, self)

			count = count + 1
		end

	end

end

function ZhuanZhiBaoShiList:ChooseGem(e)

	local wndArg = CEGUI.toWindowEventArgs(e)
	if not wndArg.window then
		return
	end
	local nId = wndArg.window:getID()

	local dlg = ZhuanZhiBaoShi.getInstanceNotCreate()
	if dlg then
		dlg:SetNextGemData(nId)
	end

	ZhuanZhiBaoShiList.DestroyDialog()
end

return ZhuanZhiBaoShiList