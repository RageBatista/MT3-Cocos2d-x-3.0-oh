------------------------------------------------------------------
-- 摆摊装备/宠物搜索中可添加删除的cell
------------------------------------------------------------------

StallSearchAttrCell = {
	TYPE_EQUIP_ATTR	= 1,	--装备基本属性
	TYPE_ 	= 2,	--宠物资质
	TYPE_PET_ATTR	= 3		--宠物基本属性
}
StallSearchAttrCell.__index = StallSearchAttrCell


local prefix = 0
local _choosedIds = {{}, {}, {}}
function StallSearchAttrCell.reset(cellType)
	_choosedIds = {{}, {}, {}}
end


function StallSearchAttrCell.new(cellType)
	local ret = {}
	setmetatable(ret, StallSearchAttrCell)
	ret:init(cellType)
	return ret
end

function StallSearchAttrCell:destroy()
	CEGUI.WindowManager:getSingleton():destroyWindow(self.window)
	_choosedIds[self.cellType][self.attrId] = nil
end

function StallSearchAttrCell:init(cellType)
	local winMgr = CEGUI.WindowManager:getSingleton()
	
	prefix = prefix+1
	self.window = winMgr:loadWindowLayout("baitansousuo_equipcell.layout", prefix)
	self.name = winMgr:getWindow(prefix .. "stallsearchequipcell/1")
	self.attrText = winMgr:getWindow(prefix .. "stallsearchequipcell/2")
	self.attrBtn = winMgr:getWindow(prefix .. "stallsearchequipcell/3")
	self.valText = winMgr:getWindow(prefix .. "stallsearchequipcell/5/1")
	self.delBtn = winMgr:getWindow(prefix .. "stallsearchequipcell/6")
	
	self.window:setID(prefix)
	self.delBtn:setID(prefix)
	
	self.attrText:subscribeEvent("MouseClick", StallSearchAttrCell.chooseAttr, self)
	self.attrBtn:subscribeEvent("Clicked", StallSearchAttrCell.chooseAttr, self)
	self.valText:subscribeEvent("MouseClick", StallSearchAttrCell.chooseValue, self)
	
	self.attrId = 0
	self.attrVal = 0

	self.cellType = cellType
	if cellType == StallSearchAttrCell.TYPE_PET_ZIZHI then
		self.name:setText(MHSD_UTILS.get_resstring(11416)) --资质成长
	end
end

function StallSearchAttrCell:chooseAttr(args)
	local menu = nil
	if self.cellType == StallSearchAttrCell.TYPE_EQUIP_ATTR then
		menu = StallSearchEquipBasicAttrMenu.toggleShowHide(_choosedIds[self.cellType])
	elseif self.cellType == StallSearchAttrCell.TYPE_PET_ZIZHI then
		menu = StallSearchPetZizhiMenu.toggleShowHide(_choosedIds[self.cellType])
	elseif self.cellType == StallSearchAttrCell.TYPE_PET_ATTR then
		menu = StallSearchPetAttrMenu.toggleShowHide(_choosedIds[self.cellType])
	end

	if menu then
		menu:setTriggerBtn(CEGUI.toWindowEventArgs(args).window)
		menu:setButtonClickCallBack(StallSearchAttrCell.handleAttrChoosed, self)
		
		local p = self.attrText:GetScreenPos()
		local s = self.attrText:getPixelSize()
		local s1 = menu.window:getPixelSize()
		local s2 = GetScreenSize()

		if s2.height - p.y - s.height >= s1.height then
			SetPositionOffset(menu.window, p.x -(s1.width-s.width)*0.5, p.y+s.height+10)
		else
			SetPositionOffset(menu.window, p.x -(s1.width-s.width)*0.5, p.y-s1.height+10)
		end
	end
end

function StallSearchAttrCell:handleAttrChoosed(btn)
	if self.attrId ~= 0 then
		_choosedIds[self.cellType][self.attrId] = nil
	end
	if self.cellType == StallSearchAttrCell.TYPE_PET_ZIZHI and btn:getID() == fire.pb.attr.AttrType.PET_GROW_RATE then
		self.attrText:setText(btn:getText() .. "(x1000)")
	else
		self.attrText:setText(btn:getText())
	end
	self.attrId = btn:getID()
	_choosedIds[self.cellType][self.attrId] = true
end

function StallSearchAttrCell:handleInputValueChanged(num)
	if num then
		self.valText:setText(num)
		self.attrVal = num
	else
		self.valText:setText("")
		self.attrVal = 0
	end
end

function StallSearchAttrCell:chooseValue(args)
	local dlg = NumKeyboardDlg.getInstanceAndShow()
	if dlg then
		dlg:setTriggerBtn(self.valText)
		dlg:setMaxValue(99999)
		dlg:setAllowClear(true)
		dlg:setInputChangeCallFunc(StallSearchAttrCell.handleInputValueChanged, self)
		
		local p = self.valText:GetScreenPos()
		local s = self.valText:getPixelSize()
		local s1 = dlg:GetWindow():getPixelSize()
		local s2 = GetScreenSize()

		if s2.height - s.height - p.y >= s1.height then
			SetPositionOffset(dlg:GetWindow(), p.x -(s1.width-s.width)*0.5, p.y+s.height+10)
		else
			SetPositionOffset(dlg:GetWindow(), p.x -(s1.width-s.width)*0.5, p.y-s1.height-5)
		end
	end
end

return StallSearchAttrCell