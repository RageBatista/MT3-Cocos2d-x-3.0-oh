------------------------------------------------------------------
-- 摆摊宠物搜索
------------------------------------------------------------------
require "logic.shop.stallsearchattrcell"
require "logic.shop.stallsearchmenuset"
require "logic.shop.stallsearchmenudlg"
require "logic.shop.stallpetpreviewtip"


local PetSearch = {}
PetSearch.__index = PetSearch


local MAX_CELL_ADDED = 6 --最大可添加的cell，资质和属性都是6条


function PetSearch.new()
	local ret = {}
	setmetatable(ret, PetSearch)
	ret:init()
	return ret
end

function PetSearch:addButtonAnimation(button, animationName)
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

function PetSearch:init()
	local winMgr = CEGUI.WindowManager:getSingleton()
	self.winMgr = winMgr

	self.window = winMgr:loadWindowLayout("baitansousuo_pet.layout")
	self.scroll = CEGUI.toScrollablePane(winMgr:getWindow("baitansousuo/sou3/scroll"))

	self.scroll:addChildWindow(self.window)
	self.window:setYPosition(CEGUI.UDim(0,0))

	self.resetBtn = winMgr:getWindow("baitansousuo/sou3/resetBtn")
	self:addButtonAnimation(self.resetBtn, "studyBtnPress")
	
	self.searchBtn = winMgr:getWindow("baitansousuo/sou3/searchBtn")
	self:addButtonAnimation(self.searchBtn, "studyBtnPress")

	self.resetBtn:subscribeEvent("Clicked", PetSearch.handleResetClicked, self)
	self.searchBtn:subscribeEvent("Clicked", PetSearch.handleSearchClicked, self)
	
	--类型
	self.typeText = winMgr:getWindow("baitansousuopet/type/text")
	self.typeBtn = CEGUI.toPushButton(winMgr:getWindow("baitansousuopet/type/btn"))
	self.normalBox = CEGUI.toCheckbox(winMgr:getWindow("baitansousuopet/type/normal"))
	self.bianyiBox = CEGUI.toCheckbox(winMgr:getWindow("baitansousuopet/type/bianyi"))
	self.previewBtn = winMgr:getWindow("baitansousuopet/type/preview")

	self.typeText:subscribeEvent("MouseClick", PetSearch.chooseType, self)
	self.typeBtn:subscribeEvent("Clicked", PetSearch.chooseType, self)
	self.normalBox:subscribeEvent("CheckStateChanged", PetSearch.chooseTypeBox, self)
	self.bianyiBox:subscribeEvent("CheckStateChanged", PetSearch.chooseTypeBox, self)
	self.previewBtn:subscribeEvent("Clicked", PetSearch.handlePreviewClicked, self)
	
	--等级
	self.minLevelText = winMgr:getWindow("baitansousuopet/level/min/text")
	self.maxLevelText = winMgr:getWindow("baitansousuopet/level/max/text")

	self.minLevelText:subscribeEvent("MouseClick", PetSearch.chooseMinLevel, self)
	self.maxLevelText:subscribeEvent("MouseClick", PetSearch.chooseMaxLevel, self)
	
	--价格
	self.minPriceText = winMgr:getWindow("baitansousuopet/price/min/text")
	self.maxPriceText = winMgr:getWindow("baitansousuopet/price/max/text")

	self.minPriceText:subscribeEvent("MouseClick", PetSearch.chooseMinPrice, self)
	self.maxPriceText:subscribeEvent("MouseClick", PetSearch.chooseMaxPrice, self)
	
	--资质成长
	self.zizhiWnd = winMgr:getWindow("baitansousuopet/zizhi")
	self.addZizhiBtn = winMgr:getWindow("baitansousuopet/zizhi/add")

	self.zizhiCells = {}
	self.addZizhiBtn:subscribeEvent("Clicked", PetSearch.addZizhiCell, self)
	
	--包含技能
	self.skillText = winMgr:getWindow("baitansousuopet/skill/text")
	self.skillBtn = CEGUI.toPushButton(winMgr:getWindow("baitansousuopet/skill/btn"))

	self.skillText:subscribeEvent("MouseClick", PetSearch.chooseSkill, self)
	self.skillBtn:subscribeEvent("Clicked", PetSearch.chooseSkill, self)
	
	--技能总和
	self.totalSkillNumText = winMgr:getWindow("baitansousuopet/skilltotal/input/text")

	self.totalSkillNumText:subscribeEvent("MouseClick", PetSearch.chooseTotalSkill, self)
	
	--基础属性
	self.attrWnd = winMgr:getWindow("baitansousuopet/attr")
	self.addAttrBtn = winMgr:getWindow("baitansousuopet/attr/add")

	self.attrCells = {}
	self.addAttrBtn:subscribeEvent("Clicked", PetSearch.addAttrCell, self)

	
	--评分
	self.scoreText = winMgr:getWindow("baitansousuopet/score/input/text")

	self.scoreText:subscribeEvent("MouseClick", PetSearch.chooseScore, self)
	
	--出售状态
    if not IsPointCardServer() then
	    self.sellBox = CEGUI.toCheckbox(winMgr:getWindow("baitansousuopet/sellstate/sell"))
	    self.showBox = CEGUI.toCheckbox(winMgr:getWindow("baitansousuopet/sellstate/show"))

	    self.sellBox:subscribeEvent("CheckStateChanged", PetSearch.chooseSellState, self)
	    self.showBox:subscribeEvent("CheckStateChanged", PetSearch.chooseSellState, self)
    else
        local sellStateLine = winMgr:getWindow("baitansousuopet/sellstate")
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


	self.movableCells = {} --资质数目变化时要跟着移动的cell
	self.movableCells[1] = winMgr:getWindow("baitansousuopet/attr")
   -- self.movableCells[2] = winMgr:getWindow("baitansousuopet/level")
   -- self.movableCells[3] = winMgr:getWindow("baitansousuopet/score")

	self:addZizhiCell()
	self:addAttrCell()

	self.args = {}
end

function PetSearch:addZizhiCell()
	if #self.zizhiCells == MAX_CELL_ADDED then
		return
	end

	local cell = StallSearchAttrCell.new(StallSearchAttrCell.TYPE_PET_ZIZHI)
	cell.delBtn:subscribeEvent("MouseClick", PetSearch.delZizhiCell, self)
	self.zizhiWnd:addChildWindow(cell.window)
	self.scroll:EnableChildDrag(cell.window)
	table.insert(self.zizhiCells, cell)
	self:refreshDeploy(self.zizhiWnd, self.addZizhiBtn, self.zizhiCells, 1)

	if #self.zizhiCells == MAX_CELL_ADDED then
		self.addZizhiBtn:setVisible(false)
	end
end

function PetSearch:delZizhiCell(args)
	local id = CEGUI.toWindowEventArgs(args).window:getID()
	for i=1, #self.zizhiCells do
		if self.zizhiCells[i].window:getID() == id then
			self.zizhiCells[i]:destroy()
			table.remove(self.zizhiCells, i)
			break
		end
	end
	
	self:refreshDeploy(self.zizhiWnd, self.addZizhiBtn, self.zizhiCells, 1)

	if not self.addZizhiBtn:isVisible() then
		self.addZizhiBtn:setVisible(true)
	end
end

function PetSearch:addAttrCell()
	if #self.attrCells == MAX_CELL_ADDED then
		return
	end

	local cell = StallSearchAttrCell.new(StallSearchAttrCell.TYPE_PET_ATTR)
	cell.delBtn:subscribeEvent("MouseClick", PetSearch.delAttrCell, self)
	self.attrWnd:addChildWindow(cell.window)
	self.scroll:EnableChildDrag(cell.window)
	table.insert(self.attrCells, cell)
	self:refreshDeploy(self.attrWnd, self.addAttrBtn, self.attrCells, 2)

	if #self.attrCells == MAX_CELL_ADDED then
		self.addAttrBtn:setVisible(false)
	end
end

function PetSearch:delAttrCell(args)
	local id = CEGUI.toWindowEventArgs(args).window:getID()
	for i=1, #self.attrCells do
		if self.attrCells[i].window:getID() == id then
			self.attrCells[i]:destroy()
			table.remove(self.attrCells, i)
			break
		end
	end
	
	self:refreshDeploy(self.attrWnd, self.addAttrBtn, self.attrCells, 2)

	if not self.addAttrBtn:isVisible() then
		self.addAttrBtn:setVisible(true)
	end
end

function PetSearch:refreshDeploy(wnd, addBtn, cells, fromIdx)
	local onlyOne = (#cells == 1)
	addBtn:setXPosition(CEGUI.UDim(0, (onlyOne and 670 or 745)))
	
	local y = 0
	for _,v in pairs(cells) do
		v.window:setPosition(NewVector2(0, y))
		if onlyOne then
			v.delBtn:setVisible(false)
		elseif not v.delBtn:isVisible() then
			v.delBtn:setVisible(true)
		end
		y = y + v.window:getPixelSize().height
	end
	
	wnd:setHeight(CEGUI.UDim(0, y))
	
	
	y = wnd:getYPosition().offset + y
	for i=fromIdx, #self.movableCells do
		local cell = self.movableCells[i]
		cell:setPosition(NewVector2(0, y))
		y = y + cell:getPixelSize().height
	end
	self.window:setSize(NewVector2(self.window:getPixelSize().width, y))
end

function PetSearch:chooseTypeBox(args)
	local box = CEGUI.toCheckbox(CEGUI.toWindowEventArgs(args).window)
	self.normalBox:setSelectedNoEvent( box == self.normalBox )
	self.bianyiBox:setSelectedNoEvent( box == self.bianyiBox )

    if self.args.type then
        local idx1 = (self.bianyiBox:isSelected() and 2 or 1)
        local data = StallSearchPetTypeMenu.getData(idx1, self.petTypeIdx2, self.petTypeIdx3)
        if data then
            self.typeText:setText(data.name)
            self.args.type = data.id
        else
            self.typeText:setText("")
            self.args.type = nil
        end
    end
end

function PetSearch:chooseType(args)
	local menu = StallSearchPetTypeMenu.toggleShowHide(self.bianyiBox:isSelected())
	if menu then
		menu:setTriggerBtn(CEGUI.toWindowEventArgs(args).window)
		menu:setButtonClickCallBack(PetSearch.handleTypeChoosed, self)
		local s = GetScreenSize()
		SetPositionOffset(menu.window, s.width*0.5, s.height*0.5-180, 0.5, 0)
	end
end

function PetSearch:handleTypeChoosed(btn)
	--self.typeText:setText(btn:getText())
	--self.args.type = btn:getID()
    local idx1 = (self.bianyiBox:isSelected() and 2 or 1)
    local data = StallSearchPetTypeMenu.getData(idx1, btn:getID(), btn:getID2())
    if data then
        self.typeText:setText(data.name)
        self.args.type = data.id
        self.petTypeIdx2 = btn:getID()
        self.petTypeIdx3 = btn:getID2()
    end
end

function PetSearch:handlePreviewClicked(args)
	if not self.args.type then
		GetCTipsManager():AddMessageTipById(190006) --需要先选定类型
		return
	end

	local conf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cmarketthreetable")):getRecorder(self.args.type)
	local petId = conf.itemid

	local dlg = StallPetPreviewTip.getInstanceAndShow()
	dlg:setPetName(self.typeText:getText())
	dlg:setPetId(petId)

	local p = self.previewBtn:GetScreenPos()
	local s = self.previewBtn:getPixelSize()
	local s1 = dlg:GetWindow():getPixelSize()

	dlg:GetWindow():setPosition(NewVector2(p.x-(s1.width-s.width)*0.5, p.y+s.height+10))
end

function PetSearch:chooseMinLevel()
	local dlg = NumKeyboardDlg.getInstanceAndShow()
	if dlg then
		dlg:setTriggerBtn(self.minLevelText)
		dlg:setMaxValue(110)
		dlg:setAllowClear(true)
		dlg:setInputChangeCallFunc(PetSearch.handleMinLevelInputChanged, self)
		dlg:setCloseCallFunc(PetSearch.handleMinLevelKeyboardClosed, self)
		
		local p = self.minLevelText:GetScreenPos()
		local s = self.minLevelText:getPixelSize()
		local s1 = dlg:GetWindow():getPixelSize()
		SetPositionOffset(dlg:GetWindow(), p.x -(s1.width-s.width)*0.5, p.y+s.height+10)
	end
end

function PetSearch:handleMinLevelInputChanged(num)
	if num then
		self.minLevelText:setText(MoneyFormat(num))
		self.args.minLevel = num
	else
		self.minLevelText:setText("")
		self.args.minLevel = nil
	end
end

function PetSearch:handleMinLevelKeyboardClosed()
	if self.args.maxLevel and self.args.minLevel and self.args.maxLevel < self.args.minLevel then
		self.minLevelText:setText(self.maxLevelText:getText())
		self.args.minLevel = self.args.maxLevel

		GetCTipsManager():AddMessageTipById(190007) --最高等级不能低于最小等级
	end
end

function PetSearch:chooseMaxLevel()
	local dlg = NumKeyboardDlg.getInstanceAndShow()
	if dlg then
		dlg:setTriggerBtn(self.maxLevelText)
		dlg:setMaxValue(110)
		dlg:setAllowClear(true)
		dlg:setInputChangeCallFunc(PetSearch.handleMaxLevelInputChanged, self)
		dlg:setCloseCallFunc(PetSearch.handleMaxLevelKeyboardClosed, self)
		
		local p = self.maxLevelText:GetScreenPos()
		local s = self.maxLevelText:getPixelSize()
		local s1 = dlg:GetWindow():getPixelSize()
		SetPositionOffset(dlg:GetWindow(), p.x -(s1.width-s.width)*0.5, p.y+s.height+10)
	end
end

function PetSearch:handleMaxLevelInputChanged(num)
	if num then
		self.maxLevelText:setText(MoneyFormat(num))
		self.args.maxLevel = num
	else
		self.maxLevelText:setText("")
		self.args.maxLevel = nil
	end
end

function PetSearch:handleMaxLevelKeyboardClosed()
	if self.args.minLevel and self.args.maxLevel and self.args.maxLevel < self.args.minLevel then
		self.maxLevelText:setText(self.minLevelText:getText())
		self.args.maxLevel = self.args.minLevel

		GetCTipsManager():AddMessageTipById(190007) --最高等级不能低于最小等级
	end
end

function PetSearch:chooseMinPrice()
	local dlg = NumKeyboardDlg.getInstanceAndShow()
	if dlg then
		dlg:setTriggerBtn(self.minPriceText)
		dlg:setMaxValue(999999999)
		dlg:setAllowClear(true)
		dlg:setInputChangeCallFunc(PetSearch.handleMinPriceInputChanged, self)
		dlg:setCloseCallFunc(PetSearch.handleMinPriceKeyboardClosed, self)
		
		local p = self.minPriceText:GetScreenPos()
		local s = self.minPriceText:getPixelSize()
		local s1 = dlg:GetWindow():getPixelSize()
		SetPositionOffset(dlg:GetWindow(), p.x -(s1.width-s.width)*0.5, p.y+s.height+10)
	end
end

function PetSearch:handleMinPriceInputChanged(num)
	if num then
		self.minPriceText:setText(MoneyFormat(num))
		self.args.minPrice = num
	else
		self.minPriceText:setText("")
		self.args.minPrice = nil
	end
end

function PetSearch:handleMinPriceKeyboardClosed()
	if self.args.maxPrice and self.args.minPrice and self.args.maxPrice < self.args.minPrice then
		self.minPriceText:setText(self.maxPriceText:getText())
		self.args.minPrice = self.args.maxPrice

		GetCTipsManager():AddMessageTipById(190002) --最高价格不能小于最小价格
	end
end

function PetSearch:chooseMaxPrice()
	local dlg = NumKeyboardDlg.getInstanceAndShow()
	if dlg then
		dlg:setTriggerBtn(self.maxPriceText)
		dlg:setMaxValue(999999999)
		dlg:setAllowClear(true)
		dlg:setInputChangeCallFunc(PetSearch.handleMaxPriceInputChanged, self)
		dlg:setCloseCallFunc(PetSearch.handleMaxPriceKeyboardClosed, self)
		
		local p = self.maxPriceText:GetScreenPos()
		local s = self.maxPriceText:getPixelSize()
		local s1 = dlg:GetWindow():getPixelSize()
		SetPositionOffset(dlg:GetWindow(), p.x -(s1.width-s.width)*0.5, p.y+s.height+10)
	end
end

function PetSearch:handleMaxPriceInputChanged(num)
	if num then
		self.maxPriceText:setText(MoneyFormat(num))
		self.args.maxPrice = num
	else
		self.maxPriceText:setText("")
		self.args.maxPrice = nil
	end
end

function PetSearch:handleMaxPriceKeyboardClosed()
	if self.args.minPrice and self.args.maxPrice and self.args.maxPrice < self.args.minPrice then
		self.maxPriceText:setText(self.minPriceText:getText())
		self.args.maxPrice = self.args.minPrice

		GetCTipsManager():AddMessageTipById(190002) --最高价格不能小于最小价格
	end
end

function PetSearch:chooseSkill(args)
	local dlg = StallSearchMenuDlg.getInstanceAndShow()
	dlg:setMenuType(StallSearchMenuDlg.TYPE_PET_SKILL)
	dlg:setChoosedCallFunc(PetSearch.handleSkillChoosed, self)
	if self.args.skillids then
		dlg:setChoosedIds(self.args.skillids)
	end
end

function PetSearch:handleSkillChoosed(text, choosedIds)
	self.skillText:setText(text)
	self.args.skillids = choosedIds
end

function PetSearch:chooseTotalSkill()
	local dlg = NumKeyboardDlg.getInstanceAndShow()
	if dlg then
		dlg:setTriggerBtn(self.totalSkillNumText)
		dlg:setMaxValue(20)
		dlg:setAllowClear(true)
		dlg:setInputChangeCallFunc(PetSearch.handleTotalSkillNumInputChanged, self)
		
		local p = self.totalSkillNumText:GetScreenPos()
		local s = self.totalSkillNumText:getPixelSize()
		local s1 = dlg:GetWindow():getPixelSize()
		local s2 = GetScreenSize()

		if s2.height - s.height - p.y >= s1.height then
			SetPositionOffset(dlg:GetWindow(), p.x -(s1.width-s.width)*0.5, p.y+s.height+10)
		else
			SetPositionOffset(dlg:GetWindow(), p.x -(s1.width-s.width)*0.5, p.y-s1.height-5)
		end
	end
end

function PetSearch:handleTotalSkillNumInputChanged(num)
	if num then
		self.totalSkillNumText:setText(num)
		self.args.totalSkillNum = num
	else
		self.totalSkillNumText:setText("")
		self.args.totalSkillNum = nil
	end
end

function PetSearch:chooseScore()
	local dlg = NumKeyboardDlg.getInstanceAndShow()
	if dlg then
		dlg:setTriggerBtn(self.scoreText)
		dlg:setMaxValue(9999)
		dlg:setAllowClear(true)
		dlg:setInputChangeCallFunc(PetSearch.handleScoreInputChanged, self)
		
		local p = self.scoreText:GetScreenPos()
		local s = self.scoreText:getPixelSize()
		local s1 = dlg:GetWindow():getPixelSize()
		SetPositionOffset(dlg:GetWindow(), p.x -(s1.width-s.width)*0.5, p.y-s1.height-10)
	end
end

function PetSearch:handleScoreInputChanged(num)
	if num then
		self.scoreText:setText(num)
		self.args.score = num
	else
		self.scoreText:setText("")
		self.args.score = nil
	end
end

function PetSearch:chooseSellState(args)
	local checkbox = CEGUI.toCheckbox(CEGUI.toWindowEventArgs(args).window)
	self.sellBox:setSelectedNoEvent( checkbox == self.sellBox )
	self.showBox:setSelectedNoEvent( checkbox == self.showBox )
end

function PetSearch:handleResetClicked(args)
	self.args = {}
	for i=1, #self.zizhiCells do
		local cell = self.zizhiCells[i]
		if i == 1 then
			cell.attrText:setText("")
			cell.valText:setText("")
			cell.attrId = 0
			cell.attrVal = 0
			self.zizhiWnd:setHeight(CEGUI.UDim(0, cell.window:getPixelSize().height))
		else
			cell:destroy()
			self.zizhiCells[i] = nil
		end
	end

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
	self.normalBox:setSelectedNoEvent(true)
	self.bianyiBox:setSelectedNoEvent(false)
	self.minLevelText:setText("")
	self.maxLevelText:setText("")
	self.minPriceText:setText("")
	self.maxPriceText:setText("")
	self.skillText:setText("")
	self.totalSkillNumText:setText("")
	self.scoreText:setText("")
    if not IsPointCardServer() then
	    self.sellBox:setSelectedNoEvent(true)
	    self.showBox:setSelectedNoEvent(false)
    end

	self:refreshDeploy(self.attrWnd, self.addAttrBtn, self.attrCells, 2)
	self:refreshDeploy(self.zizhiWnd, self.addZizhiBtn, self.zizhiCells, 1)
end

function PetSearch:handleSearchClicked(args)
	if not self.args.type then
		GetCTipsManager():AddMessageTipById(190006) --请输入宠物类型
		return
	end

	local stallDlg = require("logic.shop.stalldlg").getInstanceNotCreate()
	if stallDlg then
        if not IsPointCardServer() then
		    local groupType = (self.sellBox:isSelected() and 1 or 2)  --1.buy 2.show
		    stallDlg:showPetSearch(groupType, self.args.type)
        else
            stallDlg:showPetSearch(1, self.args.type)
        end

		local p = self:sendSearchRequest()
		stallDlg.searchProtocol = p
		stallDlg.isSearchMode = true
	end

	require("logic.shop.stallsearchdlg").getInstanceNotCreate():GetWindow():setVisible(false)
end

function PetSearch:sendSearchRequest()
	local p = require("protodef.fire.pb.shop.cmarketsearchpet"):new()
	local conf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cmarketthreetable")):getRecorder(self.args.type)
	p.pettype = conf.itemid
	p.levelmin = (self.args.minLevel and self.args.minLevel or 0)
	p.levelmax = (self.args.maxLevel and self.args.maxLevel or 0)
	p.pricemin = (self.args.minPrice and self.args.minPrice or 0)
	p.pricemax = (self.args.maxPrice and self.args.maxPrice or 0)

	local AttrBean = require("protodef.rpcgen.fire.pb.shop.marketsearchattr")
	for _,v in pairs(self.zizhiCells) do
		if v.attrId ~= 0 and v.attrVal ~= 0 then
			local t = AttrBean:new()
			t.attrid = v.attrId
			t.attrval = v.attrVal
			table.insert(p.zizhi, t)
		end
	end

	p.skills = (self.args.skillids and self.args.skillids or {})
	p.totalskillnum = (self.args.totalSkillNum and self.args.totalSkillNum or 0)

	for _,v in pairs(self.attrCells) do
		if v.attrId ~= 0 and v.attrVal ~= 0 then
			local t = AttrBean:new()
			t.attrid = v.attrId
			t.attrval = v.attrVal
			table.insert(p.attr, t)
		end
	end

	p.score = (self.args.score and self.args.score or 0)
    if not IsPointCardServer() then
	    p.sellstate = (self.sellBox:isSelected() and 1 or 2)  --1.上架中 2.公示中
    else
        p.sellstate = 1
    end

	LuaProtocolManager:send(p)

	return p
end

return PetSearch