require "logic.dialog"
require "logic.skill.strengthusedlg"


ZuoyaoDlg = {
	m_autoDrug = false
}

setmetatable(ZuoyaoDlg,Dialog)
ZuoyaoDlg.__index = ZuoyaoDlg


local _instance



function ZuoyaoDlg.getInstance() 
	if not _instance then
		_instance = ZuoyaoDlg:new()
		_instance:onCreate()
	end
	return _instance

end


function ZuoyaoDlg.getInstanceAndShow()
	if not _instance then
		_instance = ZuoyaoDlg.new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function ZuoyaoDlg.getInstanceNotCreate()
	return _instance
end


function ZuoyaoDlg.DestroyDialog()
	if _instance then
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function ZuoyaoDlg:OnClose()
	Dialog.OnClose(self)
	_instance = nil
end

function ZuoyaoDlg.GetLayoutFileName()
	return "lifeskillzuoyao.layout"
end

function ZuoyaoDlg:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
	local frameWnd=CEGUI.toFrameWindow(winMgr:getWindow("lifeskillzuoyao/bg"))
	local closeBtn=CEGUI.toPushButton(frameWnd:getCloseButton())
	closeBtn:subscribeEvent("MouseClick",ZuoyaoDlg.HandleQuitClick,self)
    self.frameCount = 0
    self.m_drugSkillLevel = 0
	self:Init()
	--self:GetWindow():setRiseOnClickEnabled(false)
    self:GetWindow():subscribeEvent("WindowUpdate", ZuoyaoDlg.HandleWindowUpdate, self) 
    
end
function ZuoyaoDlg:Init()
	self.m_drugMaterialList = {}
	local ids = BeanConfigManager.getInstance():GetTableByName("item.cfoodanddrugeffect"):getAllID()
    for i, v in pairs(ids) do
        local itemRecord = BeanConfigManager.getInstance():GetTableByName("item.cfoodanddrugeffect"):getRecorder(v)
		if itemRecord.lianyaoMaterialWeight ~= "" then
			local eachItem = {id=ids[i], lianyaoMaterialWeight=itemRecord.lianyaoMaterialWeight}
			table.insert(self.m_drugMaterialList, eachItem)
		end
    end

	self.m_consumeType = 0
	self.m_consumeSilver = 0
	self.m_bMakingDrug = false

	self.m_bagMaterialList = nil
	self.m_drugSelectedList = {}
	ZuoyaoDlg.m_autoDrug = GonghuiSkillDlg.m_autoDrug
	self:SetDrugItemTable()
	self:SetRightPanel()
    self.m_bOpenDrugShop = false

end

function ZuoyaoDlg:HandleWindowUpdate(args)
    if self.frameCount < -90 and self.frameCount >= -99 then
        self:Init()
        self.frameCount = 0
    end

    self.frameCount  = self.frameCount + 1
    if self.m_bOpenDrugShop == false then
        return
    end

    local drugDlg = require("logic.shop.npcshop").getInstanceNotCreate()
    if not drugDlg or drugDlg:IsVisible() == false then
        self.m_bOpenDrugShop = false
        self.frameCount = -100
    end

end


function ZuoyaoDlg:CloseDialog()
    if _instance ~= nil then
        _instance:OnClose()

    end
end

function ZuoyaoDlg.new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, ZuoyaoDlg)
	return self	
end

function ZuoyaoDlg:HandleQuitClick()
	_instance:DestroyDialog()

end


function ZuoyaoDlg:ChangeConsumeType(args)
	
	local winMgr = CEGUI.WindowManager:getSingleton()
	local consumeDrug_cb = CEGUI.Window.toCheckbox(winMgr:getWindow("lifeskillzuoyao/bg/checkbox1"))
	local consumeSilver_cb = CEGUI.Window.toCheckbox(winMgr:getWindow("lifeskillzuoyao/bg/checkbox2"))
	local e = CEGUI.toWindowEventArgs(args)
	local checkboxName = e.window:getUserString("name")
	if checkboxName == "checkbox_drug" then
		if consumeDrug_cb:isSelected() then
			self.m_consumeType = 0
			if consumeSilver_cb then
				consumeSilver_cb:setSelected(false)
			end
		else
			self.m_consumeType = 1
			if consumeSilver_cb then
				consumeSilver_cb:setSelected(true)
			end
		end
	elseif checkboxName == "checkbox_silver" then
		if consumeSilver_cb:isSelected() then
			self.m_consumeType = 1
			if consumeDrug_cb then
				consumeDrug_cb:setSelected(false)
			end
		else
			self.m_consumeType = 0
			if consumeDrug_cb then
				consumeDrug_cb:setSelected(true)
			end
		end
	end
	
	local drugButton = CEGUI.toPushButton(winMgr:getWindow("lifeskillzuoyao/bg/btnlianyao"))
	if table.getn(self.m_drugSelectedList) <= 1 and self.m_consumeType == 0 then
		drugButton:setEnabled(false)
	else
		drugButton:setEnabled(true)
	end
end

function ZuoyaoDlg:SetRightPanel()

	local winMgr = CEGUI.WindowManager:getSingleton()
	local consumeDrug_cb = CEGUI.Window.toCheckbox(winMgr:getWindow("lifeskillzuoyao/bg/checkbox1"))
    consumeDrug_cb:removeEvent("CheckStateChanged")
	consumeDrug_cb:subscribeEvent("CheckStateChanged" , ZuoyaoDlg.ChangeConsumeType, self)
	consumeDrug_cb:setUserString("name", "checkbox_drug")
	consumeDrug_cb:setSelected(true)
	local consumeSilver_cb = CEGUI.Window.toCheckbox(winMgr:getWindow("lifeskillzuoyao/bg/checkbox2"))
    consumeSilver_cb:removeEvent("CheckStateChanged")
	consumeSilver_cb:subscribeEvent("CheckStateChanged" , ZuoyaoDlg.ChangeConsumeType, self)
	consumeSilver_cb:setUserString("name", "checkbox_silver")
	
	-- 自动添加药材设置
	local drugSwitch = CEGUI.toSwitch(winMgr:getWindow("lifeskillzuoyao/bg/diban/switch"))
    drugSwitch:removeEvent("StatusChanged")
	drugSwitch:subscribeEvent("StatusChanged", ZuoyaoDlg.DrugSwitchChanged, self)
	
	local auto = self.m_autoDrug 
	if self.m_autoDrug == true then
		drugSwitch:setStatus(0)
		self:DrugSwitchChanged()
	end
	
	local selectTable = CEGUI.toItemTable(winMgr:getWindow("lifeskillzuoyao/bg/diban/itemtable2"))
	selectTable:setMousePassThroughEnabled(false)
    selectTable:removeEvent("TableClick")
	selectTable:subscribeEvent("TableClick", ZuoyaoDlg.handleDrugIconUnSelected, self)
	
	-- 设置炼药需银币数
	if self.m_consumeSilver == 0 then
		local commRecord = GameTable.common.GetCCommonTableInstance():getRecorder(101)
		if commRecord then
			local silver_st = winMgr:getWindow("lifeskillzuoyao/bg/yinbishu")
			self.m_consumeSilver = commRecord.value
			local formatStr = require "utils.mhsdutils".GetMoneyFormatString(self.m_consumeSilver)
	        local roleItemManager = require("logic.item.roleitemmanager").getInstance()
			if roleItemManager:GetPackMoney()  < tonumber(self.m_consumeSilver) then
				silver_st:setText("[colour='FFFF0000']"..formatStr)
			else 
				silver_st:setText(formatStr)
			end
		end
	end
	
	-- 获取玩家活力值
	local playerEnergy = gGetDataManager():GetMainCharacterData():GetValue(fire.pb.attr.AttrType.ENERGY)
	-- 需要消耗的活力值
    local dlg = GonghuiSkillDlg.getInstanceOrNot()
    if dlg then
        self.m_drugSkillLevel = dlg.m_drugSkillLevel
    end
	local needEnergy = math.floor(self.m_drugSkillLevel*0.5+20)
	local needEnergy_st = winMgr:getWindow("lifeskillzuoyao/bg/number1")
	
	local playerEnergy_st = winMgr:getWindow("lifeskillzuoyao/bg/number2")
	playerEnergy_st:setText(tostring(playerEnergy))
	if playerEnergy < needEnergy then
		local huoliColor = "FFFF0000"
		local textColor = "tl:"..huoliColor.." tr:"..huoliColor.." bl:"..huoliColor.." br:"..huoliColor
		needEnergy_st:setProperty("TextColours", textColor)
	else 
        needEnergy_st:setProperty("TextColours", playerEnergy_st:getProperty("TextColours"))
	end
	needEnergy_st:setText(tostring(needEnergy))
	-- 炼药按钮
	local drugButton = CEGUI.toPushButton(winMgr:getWindow("lifeskillzuoyao/bg/btnlianyao"))
	drugButton:removeEvent("Clicked")
	drugButton:subscribeEvent("Clicked", ZuoyaoDlg.DoDrug, self)
end




function ZuoyaoDlg:SetDrugItemTable()
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()

	local winMgr = CEGUI.WindowManager:getSingleton()
    self.itemTable = CEGUI.toItemTable(winMgr:getWindow("lifeskillzuoyao/bg/table"))
	if not self.m_bagMaterialList then
		self.m_bagMaterialList = {}
		--获得背包中的道具列表
		local bagitem_list = {}
		local keys = roleItemManager:GetItemKeyListByBag(fire.pb.item.BagTypes.BAG)
		for i = 1, keys:size() do
			local item = roleItemManager:FindItemByBagAndThisID(keys[i-1])
			for _,v in ipairs(self.m_drugMaterialList) do
				if item:GetObjectID() == v.id then
					local itemData = {}
					itemData.key = keys[i-1]
					itemData.id = item:GetObjectID()
					itemData.showCount = item:GetNum()
					-- 判断是否在已选择列表
					local found = self:IfInList(self.m_drugSelectedList, itemData.key)
					local selectCount = self:ItemCountInList(self.m_drugSelectedList, itemData.key)
					if found == false or (itemData.showCount-selectCount > 0) then
						table.insert(self.m_bagMaterialList, itemData)
					end
				end
			end
		end	
        --self.itemTable:setWantsMultiClickEvents(false)
        self.itemTable:removeEvent("TableClick")
		self.itemTable:subscribeEvent("TableClick", ZuoyaoDlg.handleDrugIconSelected, self)
	end

	local itemCount = table.getn(self.m_bagMaterialList)
	local rowCount = self.itemTable:GetRowCount()
	local colCount = self.itemTable:GetColCount()
	local index = 1
	for i = 1, rowCount*colCount do
		local cell = self.itemTable:GetCell(i-1)
		if cell then
			cell:Clear()
			cell:setID(0)
			if index <= itemCount then
				cell:SetCellTypeMask(1)
				local itemData = self.m_bagMaterialList[index]
				cell:setID(index)
				local roleItem = roleItemManager:FindItemByBagAndThisID(itemData.key)
				cell:SetImage(gGetIconManager():GetItemIconByID(roleItem:GetIcon()))
				
				local found = self:IfInList(self.m_drugSelectedList, itemData.key)
				if found == true then
					local count = self:ItemCountInList(self.m_drugSelectedList, itemData.key)
					local item = roleItemManager:FindItemByBagAndThisID(itemData.key)
					itemData.showCount = item:GetNum() - count
				end
				cell:SetTextUnit(itemData.showCount)
                SetItemCellBoundColorByQulityItemWithId(cell, itemData.id)
			elseif index == itemCount + 1 then
				-- 最后一个加上绿色符号
				cell:SetImage("chongwuui","chongwu_jiahao")
				cell:setID(10000)
			end
            cell:setWantsMultiClickEvents(false)
            
 			index = index + 1
		end
	end
	
end

function ZuoyaoDlg:SetDrugSelectedTable()
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local winMgr = CEGUI.WindowManager:getSingleton()
	local selectTable = CEGUI.toItemTable(winMgr:getWindow("lifeskillzuoyao/bg/diban/itemtable2"))
	local selectCount = table.getn(self.m_drugSelectedList) 
	for i = 1, 4 do
		local cell = selectTable:GetCell(i-1)
		if cell then
			cell:Clear()
			cell:setID(0)
			if i <= selectCount then
				cell:SetCellTypeMask(1)
				cell:setID(i)
				local key = self.m_drugSelectedList[i].key
				local roleItem = roleItemManager:FindItemByBagAndThisID(key)
				if roleItem then
					cell:SetImage(gGetIconManager():GetItemIconByID(roleItem:GetIcon()))
                    SetItemCellBoundColorByQulityItemWithId(cell, self.m_drugSelectedList[i].id)
				end
			end
            cell:setWantsMultiClickEvents(false)
		end
	end
	
	local drugButton = CEGUI.toPushButton(winMgr:getWindow("lifeskillzuoyao/bg/btnlianyao"))
	if selectCount <= 1 and self.m_consumeType == 0 then
		drugButton:setEnabled(false)
	else
		drugButton:setEnabled(true)
	end
end


function ZuoyaoDlg:ClearDrugSelectedTable()
	self.m_drugSelectedList = {}
	self:SetDrugSelectedTable()
end


function ZuoyaoDlg:handleDrugIconUnSelected(args)
    if self.frameCount < 0 then
        return
    end
    if self.m_bMakingDrug == true then
        return
    end
	local wnd = CEGUI.toWindowEventArgs(args).window
	local cell = CEGUI.toItemCell(wnd)
	local select_index = cell:getID()
	if not select_index or select_index == 0 then
		return
	end

	-- 修改已选择炼药材料列表
	local cur_key = self.m_drugSelectedList[select_index].key
	local cur_id = self.m_drugSelectedList[select_index].id
	local drugList = {}
	for j = 1, table.getn(self.m_drugSelectedList) do
		if j ~= select_index then
			table.insert(drugList, self.m_drugSelectedList[j])
		end
	end
	self.m_drugSelectedList = drugList
	
    -- 修改背包炼药材料列表
	local index = -1
	for i = 1, table.getn(self.m_bagMaterialList) do
		if cur_key == self.m_bagMaterialList[i].key then
			index = i
			break
		end
	end
	
	if index == -1 then
		local itemData = {}
		itemData.key = cur_key
		itemData.id = cur_id
		itemData.showCount = 1
		table.insert(self.m_bagMaterialList, itemData)
	else
		local count = self.m_bagMaterialList[index].showCount
		self.m_bagMaterialList[index].showCount = count + 1
	end
	
    -- 刷新背包炼药材料界面
	self:SetDrugItemTable()
	-- 刷新炼药子界面
	self:SetDrugSelectedTable()
end

function ZuoyaoDlg:handleDrugIconSelected(args)
    if self.frameCount < 0 then
        return true
    end
    if self.m_bMakingDrug == true then
        return true
    end
	local wnd = CEGUI.toWindowEventArgs(args).window
	local cell = CEGUI.toItemCell(wnd)

	local index = cell:getID()
	if not index or index == 0 then
		return true
	elseif index == 10000 then
		self:HandleOpenDrugShop()
		return true
	end
	-- 修改背包炼药材料列表

	local itemID = self.m_bagMaterialList[index].id
	local itemKey = self.m_bagMaterialList[index].key
	local showCount = self.m_bagMaterialList[index].showCount

	local backKey = nil
	local backID = nil
	-- 判断已选择炼药材料列表状况
	if table.getn(self.m_drugSelectedList) < 4 then 
		local itemData = {}
		itemData.key= itemKey
		itemData.id = itemID
		table.insert(self.m_drugSelectedList, itemData)
	else
		local itemData = {}
		itemData.key= itemKey
		itemData.id = itemID
		table.insert(self.m_drugSelectedList, itemData)
		-- 把第一个选择项退回背包列表
		backKey = self.m_drugSelectedList[1].key
		backID = self.m_drugSelectedList[1].id
		local selectList = {}
		for i = 2, 5 do
			table.insert(selectList,self.m_drugSelectedList[i])
		end
		self.m_drugSelectedList = selectList
	end
	
	if showCount > 1 then
		cell:SetTextUnit(showCount - 1)
		self.m_bagMaterialList[index].showCount = showCount - 1
	else
		local bagList = {}
		for k = 1, table.getn(self.m_bagMaterialList) do
			if k ~= index then
				table.insert(bagList, self.m_bagMaterialList[k])
			end
		end
		self.m_bagMaterialList = bagList
	end
	
	if backKey then
		local index = -1
		for i = 1, table.getn(self.m_bagMaterialList) do
			if backKey == self.m_bagMaterialList[i].key then
				index = i 
				break
			end
		end
		
		if index == -1 then
			local itemData = {}
			itemData.key = backKey
			itemData.id = backID
			itemData.showCount = 1
			table.insert(self.m_bagMaterialList, itemData)
		else
			local count = self.m_bagMaterialList[index].showCount
			self.m_bagMaterialList[index].showCount = count + 1
		end
	end
	
    -- 刷新背包炼药材料界面
	self:SetDrugItemTable()
	-- 刷新炼药子界面
	self:SetDrugSelectedTable()

    return true
end

function ZuoyaoDlg:DrugSwitchChanged(args)

	local winMgr = CEGUI.WindowManager:getSingleton()
	local switch = CEGUI.toSwitch(winMgr:getWindow("lifeskillzuoyao/bg/diban/switch"))
	local switch_status = switch:getStatus()
	if switch_status == 1 then
		self.m_autoDrug = false
	else
		self.m_autoDrug = true
	end
	GonghuiSkillDlg.m_autoDrug = self.m_autoDrug
	if self.m_autoDrug == true then
		local autoDrug = false
		local selectCount = table.getn(self.m_drugSelectedList) 
		-- 检查炼药已选择数量
		if selectCount == 4 then
			return
		else
			-- 判断炼药材料数量是否大于四个
			local leftCount = 0
			for i = 1, table.getn(self.m_bagMaterialList) do
				leftCount = leftCount + self.m_bagMaterialList[i].showCount
				if leftCount >= 4 - selectCount then
					autoDrug = true
					break

				end
			end
		end
		if autoDrug then
			local left = 4 - selectCount
			for i = 1, table.getn(self.m_bagMaterialList) do
				local needMove = 0
				local itemData = self.m_bagMaterialList[i]
				local showCount = itemData.showCount
				if showCount >= left then
					needMove = left
				else 
					needMove = showCount
				end
				self.m_bagMaterialList[i].showCount = showCount - needMove
				for j = 1, needMove do
					local selectData = {}
					selectData.key = itemData.key
					selectData.id = itemData.id
					table.insert(self.m_drugSelectedList, selectData)
				end
				left = left - needMove
				if left <= 0 then
					break
				end
			end
			-- 重新整理self.m_bagMaterialList
			local bagList = {}
			for k = 1, table.getn(self.m_bagMaterialList) do
				if self.m_bagMaterialList[k].showCount > 0 then
					table.insert(bagList, self.m_bagMaterialList[k])
				end
			end
			self.m_bagMaterialList = bagList
			-- 刷新炼药子界面
			self:SetDrugSelectedTable()
			-- 刷新背包炼药材料界面
			self:SetDrugItemTable()
		else 
			-- 如果不足四个，就把炼药消耗自动转换为消耗银币
			local consumeSilver_cb = CEGUI.Window.toCheckbox(winMgr:getWindow("lifeskillzuoyao/bg/checkbox2"))
			consumeSilver_cb:setSelected(true)
		end
	end

end

function ZuoyaoDlg:DoDrug(args)
    if self.frameCount < 0 then
        return
    end
    if self.m_bMakingDrug == true then
        return
    end
	-- 判断银币是否足够
	if self.m_consumeType == 1 then
	    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
		if roleItemManager:GetPackMoney() < tonumber(self.m_consumeSilver) then
			GetCTipsManager():AddMessageTipById(141650)
			return
		end
	end

	-- 获取玩家活力值
	local playerEnergy = gGetDataManager():GetMainCharacterData():GetValue(fire.pb.attr.AttrType.ENERGY)

	local needEnergy = math.floor(self.m_drugSkillLevel*0.5+20)
	if playerEnergy < needEnergy then
		GetCTipsManager():AddMessageTipById(150100)
		return
	end

	local p = require "protodef.fire.pb.skill.liveskill.cliveskillmakedrug".Create()
	if self.m_consumeType == 0 then
		for i = 1, table.getn(self.m_drugSelectedList) do
			table.insert(p.makingslist, self.m_drugSelectedList[i].id)
		end
	else
		p.makingslist = {}
	end
	LuaProtocolManager.getInstance():send(p)
	self.m_bMakingDrug = true
end

function ZuoyaoDlg:MakeDrugCallback(result, itemid)
	if gGetDataManager() == nil then
        return
	end
	
	-- 炼药成功
	if result == 0 then 
		local itemRecord = BeanConfigManager.getInstance():GetTableByName("item.cfoodanddrugeffect"):getRecorder(itemid)
        if itemRecord then
		    local msg = require "utils.mhsdutils".get_msgtipstring(150105)
		    msg = string.gsub(msg, "%$parameter1%$", itemRecord.name)
		    msg = string.gsub(msg, "%$parameter2%$", itemRecord.itemNameColor)
		    GetCTipsManager():AddMessageTip(msg)
        end
	elseif result == 1 then
		GetCTipsManager():AddMessageTipById(150104)
	else
		GetCTipsManager():AddMessageTipById(150103)
	end
	local winMgr = CEGUI.WindowManager:getSingleton()
	if result == 0 or result == 1 then 
		--重置活力值
		
		local playerEnergy = gGetDataManager():GetMainCharacterData():GetValue(fire.pb.attr.AttrType.ENERGY)
		local playerEnergy_st = winMgr:getWindow("lifeskillzuoyao/bg/number2")
		playerEnergy_st:setText(tostring(playerEnergy))
		-- 需要消耗的活力值
		local needEnergy = math.floor(self.m_drugSkillLevel*0.5+20)
		local needEnergy_st = winMgr:getWindow("lifeskillzuoyao/bg/number1")
		if playerEnergy < needEnergy then
		    local huoliColor = "FFFF0000"
		    local textColor = "tl:"..huoliColor.." tr:"..huoliColor.." bl:"..huoliColor.." br:"..huoliColor
		    needEnergy_st:setProperty("TextColours", textColor)
		else 
            needEnergy_st:setProperty("TextColours", playerEnergy_st:getProperty("TextColours"))
		end
        needEnergy_st:setText(tostring(needEnergy))
		-- 重置公会界面的活力值
        if GonghuiSkillDlg.getInstanceOrNot() then
            GonghuiSkillDlg.getInstanceOrNot():OnStrengthChange()
        end
		if self.m_consumeType == 0 then
			-- 清除炼药材料选择界面
			self:ClearDrugSelectedTable()
			-- 如果是自动添加药材开关是开，就自动添加药材
			if self.m_autoDrug == true then
				self:DrugSwitchChanged()
			end
		end
	end
	
	
	local silver_st = winMgr:getWindow("lifeskillzuoyao/bg/yinbishu")
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	if roleItemManager:GetPackMoney()  < tonumber(self.m_consumeSilver) then
		silver_st:setText("[colour='FFFF0000']"..self.m_consumeSilver)
	end
	self.m_bMakingDrug = false
end

function ZuoyaoDlg:IfInList(searchList, key)
	for j = 1, table.getn(searchList) do
		if key == searchList[j].key then
			return true
		end
	end
	return false
end

function ZuoyaoDlg:ItemCountInList(searchList, key)
	local count = 0
	for j = 1, table.getn(searchList) do
		if key == searchList[j].key then
			count = count + 1
		end
	end
	return count
end


function ZuoyaoDlg:HandleOpenDrugShop(args)
    if self.frameCount < 0 then 
        return
    end
    -- 打开药品商店，快速购买药品
	self:GetWindow():setProperty("AllowModalStateClick", "False")
	local dlg = require("logic.shop.npcshop").getInstanceAndShow()
	dlg:setShopType(SHOP_TYPE.MEDICINE)
	self:GetWindow():setProperty("AllowModalStateClick", "True")
    self.m_bOpenDrugShop = true
end

function ZuoyaoDlg:OnItemNumberChange()

    local drugDlg = require("logic.shop.npcshop").getInstanceNotCreate()

    if not drugDlg then
        return
    else 
        local drugVisible = drugDlg:IsVisible()
        if drugVisible == false then
            return
        end
    end

	local dlg = ZuoyaoDlg.getInstanceNotCreate()
	if dlg then
		if  dlg.m_bMakingDrug == true then
			return
		end
		dlg.m_bagMaterialList = nil
		-- 如果是自动添加药材开关是开，就自动添加药材
		if dlg.m_autoDrug == true  then
		end
	end
end


return ZuoyaoDlg
