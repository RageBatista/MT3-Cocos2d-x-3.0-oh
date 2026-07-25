------------------------------------------------------------------
-- 摆摊装备搜索
------------------------------------------------------------------

require "logic.shop.stallsearchmenuset"
require "logic.shop.stallsearchmenudlg"
require "logic.shop.stallequippreviewtip"
require "logic.shop.stallsearchattrcell"


local EquipSearch = {}
EquipSearch.__index = EquipSearch


function EquipSearch.new()
	local ret = {}
	setmetatable(ret, EquipSearch)
	ret:init()
	return ret
end

function EquipSearch:addButtonAnimation(button, animationName)
    local animationDef = CEGUI.AnimationManager:getSingleton():getAnimation(animationName)
    if animationDef then
        local animation = CEGUI.AnimationManager:getSingleton():instantiateAnimation(animationDef)
        animation:setTargetWindow(button)
        animation:setSpeed(0.7)
        button.animation = animation
        button:subscribeEvent("MouseButtonDown", function()
            animation:start()
        end, self)
    end
end

function EquipSearch:init()
	local winMgr = CEGUI.WindowManager:getSingleton()
	self.winMgr = winMgr

	self.window = winMgr:loadWindowLayout("baitansousuo_equip.layout")
	self.scroll = CEGUI.toScrollablePane(winMgr:getWindow("baitansousuo/sou2/scroll"))

	self.scroll:addChildWindow(self.window)
	self.window:setYPosition(CEGUI.UDim(0,0))

	self.resetBtn = winMgr:getWindow("baitansousuo/sou2/resetBtn")
	self:addButtonAnimation(self.resetBtn, "studyBtnPress")
	
	self.searchBtn = winMgr:getWindow("baitansousuo/sou2/searchBtn")
    self:addButtonAnimation(self.searchBtn, "studyBtnPress")
	
	self.resetBtn:subscribeEvent("Clicked", EquipSearch.handleResetClicked, self)
	self.searchBtn:subscribeEvent("Clicked", EquipSearch.handleSearchClicked, self)
	
	--类型
	self.typeText = winMgr:getWindow("baitansousuoequip/cell1/2")
	self.typeBtn = CEGUI.toPushButton(winMgr:getWindow("baitansousuoequip/cell1/3"))
	
	self.typeText:subscribeEvent("MouseClick", EquipSearch.chooseType, self)
	self.typeBtn:subscribeEvent("Clicked", EquipSearch.chooseType, self)
	
	--预览
	self.previewBtn = CEGUI.toPushButton(winMgr:getWindow("baitansousuoequip/cell1/4"))
	
	self.previewBtn:subscribeEvent("Clicked", EquipSearch.handlePreviewClicked, self)
	
	--等级
	self.levelText = winMgr:getWindow("baitansousuoequip/cell2/2")
	self.levelBtn = CEGUI.toPushButton(winMgr:getWindow("baitansousuoequip/cell2/3"))
	
	self.levelText:subscribeEvent("MouseClick", EquipSearch.chooseLevel, self)
	self.levelBtn:subscribeEvent("Clicked", EquipSearch.chooseLevel, self)
	
	--价格
	self.minPriceText = winMgr:getWindow("baitansousuoequip/cell3/2/2")
	self.maxPriceText = winMgr:getWindow("baitansousuoequip/cell3/4/2")
	
	self.minPriceText:subscribeEvent("MouseClick", EquipSearch.chooseMinPrice, self)
	self.maxPriceText:subscribeEvent("MouseClick", EquipSearch.chooseMaxPrice, self)
	
	--特效
	self.effectText = winMgr:getWindow("baitansousuoequip/cell4/2")
	self.effectBtn = CEGUI.toPushButton(winMgr:getWindow("baitansousuoequip/cell4/3"))
	
	self.effectText:subscribeEvent("MouseClick", EquipSearch.chooseEffect, self)
	self.effectBtn:subscribeEvent("Clicked", EquipSearch.chooseEffect, self)
	
	--特技
	self.skillText = winMgr:getWindow("baitansousuoequip/cell4/5")
	self.skillBtn = CEGUI.toPushButton(winMgr:getWindow("baitansousuoequip/cell4/6"))
	
	self.skillText:subscribeEvent("MouseClick", EquipSearch.chooseSkill, self)
	self.skillBtn:subscribeEvent("Clicked", EquipSearch.chooseSkill, self)

	--品质
	self.purpleCheckBox = CEGUI.toCheckbox(winMgr:getWindow("baitansousuoequip/cell9/3"))
	self.orangeCheckBox = CEGUI.toCheckbox(winMgr:getWindow("baitansousuoequip/cell9/4"))
	
	self.purpleCheckBox:subscribeEvent("CheckStateChanged", EquipSearch.chooseColor, self)
	self.orangeCheckBox:subscribeEvent("CheckStateChanged", EquipSearch.chooseColor, self)
	
	--基础属性
	self.attrWnd= winMgr:getWindow("baitansousuoequip/cell5")
	self.addAttrBtn = winMgr:getWindow("baitansousuoequip/cell5/add")
	self.addAttrBtn:subscribeEvent("Clicked", EquipSearch.addNewAttr, self)
	
	--附加属性
	self.additionalAttrText = winMgr:getWindow("baitansousuoequip/cell6/2")
	self.additionalAttrBtn = CEGUI.toPushButton(winMgr:getWindow("baitansousuoequip/cell6/3"))
	
	self.additionalAttrText:subscribeEvent("MouseClick", EquipSearch.chooseAdditionalAttr, self)
	self.additionalAttrBtn:subscribeEvent("Clicked", EquipSearch.chooseAdditionalAttr, self)

	--属性综合
	self.totalAttrText = winMgr:getWindow("baitansousuoequip/cell6/6/1")
	
	self.totalAttrText:subscribeEvent("MouseClick", EquipSearch.chooseTotalAttr, self)
	
	--评分
	self.scoreText = winMgr:getWindow("baitansousuoequip/cell7/4")
	
	self.scoreText:subscribeEvent("MouseClick", EquipSearch.chooseScore, self)
	
	
	--出售状态
    if not IsPointCardServer() then
	    self.onSellCheckBox = CEGUI.toCheckbox(winMgr:getWindow("baitansousuoequip/cell8/2"))
	    self.onShowCheckBox = CEGUI.toCheckbox(winMgr:getWindow("baitansousuoequip/cell8/3"))
	
	    self.onSellCheckBox:subscribeEvent("CheckStateChanged", EquipSearch.chooseSellState, self)
	    self.onShowCheckBox:subscribeEvent("CheckStateChanged", EquipSearch.chooseSellState, self)
    else
        local sellStateLine = winMgr:getWindow("baitansousuoequip/cell8")
        sellStateLine:setVisible(false)

        local h = sellStateLine:getPixelSize().height
        local childcount = self.window:getChildCount()
        for i=0, childcount-1 do
            local child = self.window:getChildAtIdx(i)
            if child then
                local y = child:getYPosition().offset
                child:setYPosition(CEGUI.UDim(0, y-h))
            end
        end

        local h = self.window:getHeight()
        h.offset = h.offset - sellStateLine:getPixelSize().height
        self.window:setHeight(h)
    end
	
	
	self.movableLines = {}
    table.insert(self.movableLines, winMgr:getWindow("baitansousuoequip/cell6"))
    table.insert(self.movableLines, winMgr:getWindow("baitansousuoequip/cell7"))
	
	self.attrCells = {}
	self:addNewAttr()

	self.args = {}
end

function EquipSearch:addNewAttr()
	if #self.attrCells == StallSearchEquipBasicAttrMenu.getBasicAttrCount() then
		return
	end
	local cell = StallSearchAttrCell.new(StallSearchAttrCell.TYPE_EQUIP_ATTR)
	cell.delBtn:subscribeEvent("MouseClick", EquipSearch.delAttrCell, self)
	self.attrWnd:addChildWindow(cell.window)
	self.scroll:EnableChildDrag(cell.window)
	table.insert(self.attrCells, cell)
	self:refreshDeploy()

	if #self.attrCells == StallSearchEquipBasicAttrMenu.getBasicAttrCount() then
		self.addAttrBtn:setVisible(false)
	end
end

function EquipSearch:delAttrCell(args)
	local id = CEGUI.toWindowEventArgs(args).window:getID()
	for i=1, #self.attrCells do
		if self.attrCells[i].window:getID() == id then
			self.attrCells[i]:destroy()
			table.remove(self.attrCells, i)
			break
		end
	end
	
	self:refreshDeploy()
	if not self.addAttrBtn:isVisible() then
		self.addAttrBtn:setVisible(true)
	end
end

function EquipSearch:refreshDeploy()
	local onlyOne = (#self.attrCells == 1)
	self.addAttrBtn:setXPosition(CEGUI.UDim(0, (onlyOne and 670 or 745)))
	
	local y = 0
	for _,v in pairs(self.attrCells) do
		v.window:setPosition(NewVector2(0, y))
		if onlyOne then
			v.delBtn:setVisible(false)
		elseif not v.delBtn:isVisible() then
			v.delBtn:setVisible(true)
		end
		y = y + v.window:getPixelSize().height
	end

	self.attrWnd:setHeight(CEGUI.UDim(0, y))
	
	
	y = self.attrWnd:getYPosition().offset + y
	for _,v in pairs(self.movableLines) do
		v:setPosition(NewVector2(0, y))
		y = y + v:getPixelSize().height
	end
	self.window:setSize(NewVector2(self.window:getPixelSize().width, y))
end

------------------------------------------------------------------

function EquipSearch:handlePreviewClicked(args)
	if not self.args or not self.args.type or not self.args.level then
		GetCTipsManager():AddMessageTipById(190001) --类型和等级是必填的
		return
	end

	local itemids = {}
	local secondconf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cmarketsecondtable")):getRecorder(self.args.type)
	local countPerGroup = secondconf.thirdmenus:size() / secondconf.groupNum

	for i=0, countPerGroup-1 do
		local thirdId = secondconf.thirdmenus[i]
		local thirdconf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cmarketthreetable")):getRecorder(thirdId)
		if self.args.level == thirdconf.value then
			--如果没有选颜色品质，默认按紫色的预览
			if self.purpleCheckBox:isSelected() or not self.orangeCheckBox:isSelected() then
				table.insert(itemids, thirdconf.itemid)
			end

			--如果选了橙色再加上橙色的装备id
			if self.orangeCheckBox:isSelected() then
				thirdId = secondconf.thirdmenus[ countPerGroup + i ]
				thirdconf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cmarketthreetable")):getRecorder(thirdId)
				table.insert(itemids, thirdconf.itemid)
			end
			break
		end
	end


	local dlg = StallEquipPreviewTip.getInstanceAndShow()
	dlg:setEquipName(self.typeText:getText())
	dlg:setEquipItemIds(itemids)

	local p = self.previewBtn:GetScreenPos()
	local s = self.previewBtn:getPixelSize()
	local s1 = dlg:GetWindow():getPixelSize()

	dlg:GetWindow():setPosition(NewVector2(p.x-(s1.width-s.width)*0.5, p.y+s.height+10))
end

function EquipSearch:chooseType(args)
	local menu = StallSearchEquipTypeMenu.toggleShowHide()
	if menu then
		menu:setTriggerBtn(CEGUI.toWindowEventArgs(args).window)
		menu:setButtonClickCallBack(EquipSearch.handleTypeChoosed, self)
		local s = GetScreenSize()
		SetPositionOffset(menu.window, s.width*0.5, s.height*0.5-180, 0.5, 0)
	end
end

function EquipSearch:handleTypeChoosed(btn)
	self.typeText:setText(btn:getText())
	self.args.type = btn:getID()
end

function EquipSearch:chooseLevel(args)
	local menu = StallSearchEquipLevelMenu.toggleShowHide()
	if menu then
		menu:setTriggerBtn(CEGUI.toWindowEventArgs(args).window)
		menu:setButtonClickCallBack(EquipSearch.handleLevelChoosed, self)
		
		local p = self.levelText:GetScreenPos()
		local s = self.levelText:getPixelSize()
		local s1 = menu.window:getPixelSize()
		SetPositionOffset(menu.window, p.x -(s1.width-s.width)*0.5, p.y+s.height+10)
	end
end

function EquipSearch:handleLevelChoosed(btn)
	self.levelText:setText(btn:getText())
	self.args.level = btn:getID()
end

function EquipSearch:chooseMinPrice(args)
	local dlg = NumKeyboardDlg.getInstanceAndShow()
	if dlg then
		dlg:setTriggerBtn(self.minPriceText)
		dlg:setMaxValue(999999999)
		dlg:setAllowClear(true)
		dlg:setInputChangeCallFunc(EquipSearch.handleMinPriceInputChanged, self)
		dlg:setCloseCallFunc(EquipSearch.handleMinPriceKeyboardClosed, self)
		
		local p = self.minPriceText:GetScreenPos()
		local s = self.minPriceText:getPixelSize()
		local s1 = dlg:GetWindow():getPixelSize()
		SetPositionOffset(dlg:GetWindow(), p.x -(s1.width-s.width)*0.5, p.y+s.height+10)
	end
end

function EquipSearch:handleMinPriceInputChanged(num)
	if num then
		self.minPriceText:setText(MoneyFormat(num))
		self.args.minPrice = num
	else
		self.minPriceText:setText("")
		self.args.minPrice = nil
	end
end

function EquipSearch:handleMinPriceKeyboardClosed()
	if self.args.maxPrice and self.args.minPrice and self.args.maxPrice < self.args.minPrice then
		self.minPriceText:setText(self.maxPriceText:getText())
		self.args.minPrice = self.args.maxPrice

		GetCTipsManager():AddMessageTipById(190002) --最高价格不能小于最小价格
	end
end

function EquipSearch:chooseMaxPrice(args)
	local dlg = NumKeyboardDlg.getInstanceAndShow()
	if dlg then
		dlg:setTriggerBtn(self.maxPriceText)
		dlg:setMaxValue(999999999)
		dlg:setAllowClear(true)
		dlg:setInputChangeCallFunc(EquipSearch.handleMaxPriceInputChanged, self)
		dlg:setCloseCallFunc(EquipSearch.handleMaxPriceKeyboardClosed, self)
		
		local p = self.maxPriceText:GetScreenPos()
		local s = self.maxPriceText:getPixelSize()
		local s1 = dlg:GetWindow():getPixelSize()
		SetPositionOffset(dlg:GetWindow(), p.x -(s1.width-s.width)*0.5, p.y+s.height+10)
	end
end

function EquipSearch:handleMaxPriceInputChanged(num)
	if num then
		self.maxPriceText:setText(MoneyFormat(num))
		self.args.maxPrice = num
	else
		self.maxPriceText:setText("")
		self.args.maxPrice = nil
	end
end

function EquipSearch:handleMaxPriceKeyboardClosed()
	if self.args.minPrice and self.args.maxPrice and self.args.maxPrice < self.args.minPrice then
		self.maxPriceText:setText(self.minPriceText:getText())
		self.args.maxPrice = self.args.minPrice

		GetCTipsManager():AddMessageTipById(190002) --最高价格不能小于最小价格
	end
end

function EquipSearch:chooseEffect(args)
	local menu = StallSearchEquipEffectMenu.toggleShowHide()
	if menu then
		menu:setTriggerBtn(CEGUI.toWindowEventArgs(args).window)
		menu:setButtonClickCallBack(EquipSearch.handleEffectChoosed, self)
		local s = GetScreenSize()
		SetPositionOffset(menu.window, s.width*0.5, s.height*0.5-180, 0.5, 0)
	end
end

function EquipSearch:handleEffectChoosed(btn)
	if btn:getID() ~= 0 then
		self.effectText:setText(btn:getText())
		self.args.effect = btn:getID()
	else
		self.effectText:setText("")
		self.args.effect = nil
	end
end

function EquipSearch:chooseSkill(args)
	local menu = StallSearchEquipSkillMenu.toggleShowHide()
	if menu then
		menu:setTriggerBtn(CEGUI.toWindowEventArgs(args).window)
		menu:setButtonClickCallBack(EquipSearch.handleSkillChoosed, self)
		local s = GetScreenSize()
		SetPositionOffset(menu.window, s.width*0.5, s.height*0.5-180, 0.5, 0)
	end
end

function EquipSearch:handleSkillChoosed(btn)
	if btn:getID() ~= 0 then
		self.skillText:setText(btn:getText())
		self.args.skill = btn:getID()
	else
		self.skillText:setText("")
		self.args.skill = nil
	end
end

--4紫、5橙
function EquipSearch:chooseColor(args)
	self.args.color = {}

	--至少选择一种
	local box = CEGUI.toCheckbox(CEGUI.toWindowEventArgs(args).window)
	if (box == self.purpleCheckBox and not self.orangeCheckBox:isSelected()) or
		(box == self.orangeCheckBox and not self.purpleCheckBox:isSelected()) then
		box:setSelectedNoEvent(true)
		return
	end

	if self.purpleCheckBox:isSelected() then
		table.insert(self.args.color, 4)
	end

	if self.orangeCheckBox:isSelected() then
		table.insert(self.args.color, 5)
	end
end

function EquipSearch:chooseAdditionalAttr(args)
	local dlg = StallSearchMenuDlg.getInstanceAndShow()
	dlg:setMenuType(StallSearchMenuDlg.TYPE_EQUIP_ADDITIONAL_ATTR)
	dlg:setChoosedCallFunc(EquipSearch.handleAdditionalAttrChoosed, self)
	if self.args.additionalAttrs then
		dlg:setChoosedIds(self.args.additionalAttrs)
	end
end

function EquipSearch:handleAdditionalAttrChoosed(text, choosedIds)
	self.additionalAttrText:setText(text)
	self.args.additionalAttrs = choosedIds
end

function EquipSearch:chooseTotalAttr(args)
	local dlg = NumKeyboardDlg.getInstanceAndShow()
	if dlg then
		dlg:setTriggerBtn(self.totalAttrText)
		dlg:setMaxValue(100)
		dlg:setAllowClear(true)
		dlg:setInputChangeCallFunc(EquipSearch.handleTotalAttrInputChanged, self)
		
		local p = self.totalAttrText:GetScreenPos()
		local s = self.totalAttrText:getPixelSize()
		local s1 = dlg:GetWindow():getPixelSize()
		SetPositionOffset(dlg:GetWindow(), p.x -(s1.width-s.width)*0.5, p.y-s1.height-10)
	end
end

function EquipSearch:handleTotalAttrInputChanged(num)
	if num then
		self.totalAttrText:setText(num)
		self.args.totalAttr = num
	else
		self.totalAttrText:setText("")
		self.args.totalAttr = nil
	end
end

function EquipSearch:chooseScore(args)
	local dlg = NumKeyboardDlg.getInstanceAndShow()
	if dlg then
		dlg:setTriggerBtn(self.scoreText)
		dlg:setMaxValue(9999)
		dlg:setAllowClear(true)
		dlg:setInputChangeCallFunc(EquipSearch.handleScoreInputChanged, self)
		
		local p = self.scoreText:GetScreenPos()
		local s = self.scoreText:getPixelSize()
		local s1 = dlg:GetWindow():getPixelSize()
		SetPositionOffset(dlg:GetWindow(), p.x -(s1.width-s.width)*0.5, p.y-s1.height-10)
	end
end

function EquipSearch:handleScoreInputChanged(num)
	if num then
		self.scoreText:setText(num)
		self.args.score = num
	else
		self.scoreText:setText("")
		self.args.score = nil
	end
end

function EquipSearch:chooseSellState(args)
	local checkbox = CEGUI.toCheckbox(CEGUI.toWindowEventArgs(args).window)
	self.onSellCheckBox:setSelectedNoEvent( checkbox == self.onSellCheckBox )
	self.onShowCheckBox:setSelectedNoEvent( checkbox == self.onShowCheckBox )
end

function EquipSearch:handleResetClicked(args)
	self.args = {}

	for i=1, #self.attrCells do
		local cell = self.attrCells[i]
		if i == 1 then
			cell.attrText:setText("")
			cell.valText:setText("")
			cell.attrId = 0
			cell.attrVal = 0
			self.attrWnd:setHeight(CEGUI.UDim(0, cell.window:getPixelSize().height))
		else
			cell:destroy()
			self.attrCells[i] = nil
		end
	end
	
	self.typeText:setText("")
	self.levelText:setText("")
	self.minPriceText:setText("")
	self.maxPriceText:setText("")
	self.effectText:setText("")
	self.skillText:setText("")
	self.additionalAttrText:setText("")
	self.totalAttrText:setText("")
	self.scoreText:setText("")

    if not IsPointCardServer() then
	    self.onSellCheckBox:setSelectedNoEvent(true)
	    self.onShowCheckBox:setSelectedNoEvent(false)

	    self.purpleCheckBox:setSelectedNoEvent(true)
	    self.orangeCheckBox:setSelectedNoEvent(true)
    end
	
	self:refreshDeploy()
end

function EquipSearch:handleSearchClicked(args)
	if not self.args or not self.args.type or not self.args.level then
		GetCTipsManager():AddMessageTipById(190001) --类型和等级是必填的
		return
	end
	
	local stallDlg = require("logic.shop.stalldlg").getInstanceNotCreate()
	if stallDlg then
        if not IsPointCardServer() then
		    local groupType = (self.onSellCheckBox:isSelected() and 1 or 2)  --1.buy 2.show
		    stallDlg:showEquipSearch(groupType, self.args.type)
        else
            stallDlg:showEquipSearch(1, self.args.type)
        end

		local p = self:sendSearchRequest()
		stallDlg.searchProtocol = p
		stallDlg.isSearchMode = true
	end

	require("logic.shop.stallsearchdlg").getInstanceNotCreate():GetWindow():setVisible(false)
end

function EquipSearch:sendSearchRequest()
	local p = require("protodef.fire.pb.shop.cmarketsearchequip"):new()
	p.euqiptype = self.args.type
	p.level = self.args.level
	p.pricemin = (self.args.minPrice and self.args.minPrice or 0)
	p.pricemax = (self.args.maxPrice and self.args.maxPrice or 0)
	p.effect = (self.args.effect and self.args.effect or 0)
	p.skill = (self.args.skill and self.args.skill or 0)
	
	if self.args.color then
		p.color = self.args.color
	else
		p.color = {4, 5} --default  4紫，5橙
	end

	local AttrBean = require("protodef.rpcgen.fire.pb.shop.marketsearchattr")
	for _,v in pairs(self.attrCells) do
		if v.attrId ~= 0 and v.attrVal ~= 0 then
			local t = AttrBean:new()
			t.attrid = v.attrId
			t.attrval = v.attrVal
			table.insert(p.basicattr, t)
		end
	end

	if self.args.additionalAttrs then
		p.additionalattr = self.args.additionalAttrs
	end

    if self.args.totalAttr and self.args.totalAttr ~= 0 then
        p.totalattr = self.args.totalAttr
    end

	p.score = (self.args.score and self.args.score or 0)
    if not IsPointCardServer() then
	    p.sellstate = (self.onSellCheckBox:isSelected() and 1 or 2) --1.上架中 2.公示中
    else
        p.sellstate = 1
    end

	LuaProtocolManager:send(p)

	return p
end

return EquipSearch