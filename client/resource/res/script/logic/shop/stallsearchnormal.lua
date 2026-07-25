------------------------------------------------------------------
-- 摆摊普通搜索
------------------------------------------------------------------

local NormalSearch = {}
NormalSearch.__index = NormalSearch


local history_SAVE_KEY = "stallNSearch"

local LOGIC_NONE    = 0
local LOGIC_LEVEL   = 1
local LOGIC_ITEM    = 2
local LOGIC_QUALITY_RANGE   = 3
local LOGIC_LEVEL_RANGE     = 4

local HISTROY_COUNT = 12


function NormalSearch.new()
	local ret = {}
	setmetatable(ret, NormalSearch)
	ret:init()
	return ret
end

function NormalSearch:init()
	local winMgr = CEGUI.WindowManager:getSingleton()
	self.winMgr = winMgr

	self.inputBox = CEGUI.toEditbox(winMgr:getWindow("baitansousuo/sou1/neirong/1"))
	self.searchBtn = CEGUI.toPushButton(winMgr:getWindow("baitansousuo/sou1/sousuo"))
	self.onSellBox = CEGUI.toCheckbox(winMgr:getWindow("baitansousuo/sou1/1"))
	self.onShowBox = CEGUI.toCheckbox(winMgr:getWindow("baitansousuo/sou1/2"))
    self.placeHolder = winMgr:getWindow("baitansousuo/sou1/neirong/1/placeholder")
	self.adviceBg = winMgr:getWindow("baitansousuo/advicebg")
	self.adviceBg:setVisible(false)
	

	local historyStr = CCUserDefault:sharedUserDefault():getStringForKey(history_SAVE_KEY)
	self.history = {}
	if historyStr ~= "" then
        local dataTable = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cmarketthreetable"))
		for s in historyStr:gmatch('[^,]+') do
			local id = tonumber(s)
            local conf = dataTable:getRecorder(id)
			if conf and conf.cansale == 1 then
				table.insert(self.history, id)
			end
		end
	end

	self.historyCells = {}
	for i=1, HISTROY_COUNT do
		local cell = CEGUI.toGroupButton(winMgr:getWindow("baitansousuo/sou1/lishi/" .. i))
		cell:EnableClickAni(false)
		cell:setID(i)
		cell:SetBorderEnable(false)
		cell:subscribeEvent("SelectStateChanged", NormalSearch.handleHistoryCellClicked, self)
		self.historyCells[i] = cell
	end
	self:refreshhistoryCells()
	
    self.inputBox:subscribeEvent("KeyboardTargetWndChanged", NormalSearch.OnKeyboardTargetWndChanged, self)
	self.searchBtn:subscribeEvent("Clicked", NormalSearch.handleSearchClicked, self)

    if not IsPointCardServer() then
	    self.onSellBox:subscribeEvent("CheckStateChanged", NormalSearch.handleCheckBoxClicked, self)
	    self.onShowBox:subscribeEvent("CheckStateChanged", NormalSearch.handleCheckBoxClicked, self)
    else
        self.onSellBox:setVisible(false)
        self.onShowBox:setVisible(false)
        winMgr:getWindow("baitansousuo/sou1/wenben3"):setVisible(false)
    end


	self.inputBox:SetShieldSpace(true)
	self.inputBox:SetNormalColourRect(0xFFFFFFFF)

	local s = self.adviceBg:getPixelSize()
    self.cellSize = {width=(s.width-10)*0.5, height=80}
	self.adviceTable = TableView.create(self.adviceBg)
	self.adviceTable:setViewSize(s.width-10, s.height-10)
	self.adviceTable:setPosition(5, 5)
	self.adviceTable:setColumCount(2)
    self.adviceTable:setCellInterval(-1, 0)
	self.adviceTable:setDataSourceFunc(self, NormalSearch.adviceTableViewGetCellAtIndex)

	self.toSearchGoodsId = 0
	self.searchOnSell = true --是否搜索上架(公示)
end

function NormalSearch:refreshhistoryCells()
	for k,v in pairs(self.historyCells) do
		if self.history[k] then
			v:setVisible(true)
			v:setText(self:getNameByGoodsId(self.history[k]))
		else
			v:setVisible(false)
		end
	end
end

function NormalSearch:savehistory()
	CCUserDefault:sharedUserDefault():setStringForKey(history_SAVE_KEY, table.concat(self.history, ","))
end

function NormalSearch:adviceTableViewGetCellAtIndex(tableView, idx, cell)
	if not cell then
		cell = {}
		cell.window = CEGUI.toGroupButton(self.winMgr:createWindow("TaharezLook/CellGroupButton2"))
		cell.window:setSize(NewVector2(self.cellSize.width, self.cellSize.height))
		cell.window:EnableClickAni(false)
		cell.window:SetBorderEnable(false)
		cell.window:subscribeEvent("MouseClick", NormalSearch.handleAdviceCellClicked, self)
	end
	cell.window:setSelected(false)
	if self.filterDatas and self.filterDatas[idx+1] then
        local conf = self.filterDatas[idx+1]
		cell.window:setText(GetGoodsNameByItemId(conf.itemtype, conf.itemid, false))
		cell.window:setID(idx+1)
	end
	return cell
end

function NormalSearch:getNameByGoodsId(goodsId)
	local conf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cmarketthreetable")):getRecorder(goodsId)
	if conf then
		return GetGoodsNameByItemId(conf.itemtype, conf.itemid, false)
	end
	return ""
end

function NormalSearch:getFilterDatas()
	local totallyMatchId = 0
	local inputName = self.inputBox:getText()
	local filterResult = {}
	local allName = {}

    local dataTable = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cmarketthreetable"))
    local ids = dataTable:getAllID()
    for _,id in pairs(ids) do
        local conf = dataTable:getRecorder(id)
		--if conf.itemtype ~= STALL_GOODS_T.PET and conf.firstno ~= STALL_CATALOG1_T.GEM_EQUIP then --宠物和珍品装备除外
        if conf.cansale == 1 then
		    local name = GetGoodsNameByItemId(conf.itemtype, conf.itemid, false)
		    if not allName[name] then
			    allName[name] = true
			    if inputName == "" then
				    table.insert(filterResult, conf)
			    else
				    local name = GetGoodsNameByItemId(conf.itemtype, conf.itemid, false)
				    if name:find(inputName) then
					    table.insert(filterResult, conf)

					    if name == inputName then --如果名字完全相同就设为即将搜索的id
						    totallyMatchId = conf.id
					    end
				    end
			    end
		    end
        end
	end
	return filterResult, totallyMatchId
end

function NormalSearch:doSearch()
    local exist = false
    for _,id in ipairs(self.history) do
        if id == self.toSearchGoodsId then
            exist = true
        end
    end

    if not exist then
        table.insert(self.history, self.toSearchGoodsId)
	    if #self.history > HISTROY_COUNT then
		    table.remove(self.history, 1)
	    end
	    self:savehistory()
	    self:refreshhistoryCells()
    end

	for _,v in pairs(self.historyCells) do
		v:setSelected(false)
	end

	--检查搜索的商品是否可公示
	if not self.searchOnSell then
		local thirdConf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cmarketthreetable")):getRecorder(self.toSearchGoodsId)
		local firstConf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cmarketfirsttable")):getRecorder(thirdConf.firstno)
		if firstConf.isfloating == 1 then --价格不浮动的可以公示
			GetCTipsManager():AddMessageTipById(190004) --该商品不可以公示
			return
		end
	end

	local stallDlg = require("logic.shop.stalldlg").getInstanceNotCreate()
	if stallDlg then
		stallDlg:doNormalSearch(self.toSearchGoodsId, (self.searchOnSell and 1 or 2)) --1.buy 2.show
	end

	require("logic.shop.stallsearchdlg").getInstanceNotCreate():GetWindow():setVisible(false)
end

--失去输入焦点
function NormalSearch:OnKeyboardTargetWndChanged(args)
    local wnd = CEGUI.toWindowEventArgs(args).window
    if wnd == self.inputBox then
        self.placeHolder:setVisible(false)
    else
        if self.inputBox:getText() == "" then
            self.placeHolder:setVisible(true)
        end

        local inputStr = self.inputBox:getText()
		self.filterDatas, self.toSearchGoodsId = self:getFilterDatas()
		if self.toSearchGoodsId == 0 and #self.filterDatas > 0 then
			self.adviceBg:setVisible(true)
			self.willCheckTipsWnd = false
			self.adviceTable:setCellCount(#self.filterDatas)
			self.adviceTable:reloadData()
            self.adviceTable:setContentOffset(0)
		end
    end
end

function NormalSearch:handleSearchClicked(args)
	if self.toSearchGoodsId == 0 then
		GetCTipsManager():AddMessageTipById(190005) --请输入正确的商品名字
		return
	end
	self:doSearch()
end

function NormalSearch:handleHistoryCellClicked(args)
	local idx = CEGUI.toWindowEventArgs(args).window:getID()
	self.inputBox:setText(self:getNameByGoodsId(self.history[idx]))
	self.toSearchGoodsId = self.history[idx]
    self.placeHolder:setVisible(false)
end

function NormalSearch:handleAdviceCellClicked(args)
	local wnd = CEGUI.toWindowEventArgs(args).window
	self.inputBox:setText(wnd:getText())
	self.adviceBg:setVisible(false)
    self.placeHolder:setVisible(false)

	local goodsId = self.filterDatas[wnd:getID()].id
	self.toSearchGoodsId = goodsId
	
	for _,v in pairs(self.history) do
		if v == goodsId then
			return
		end
	end

	self.adviceBg:setVisible(false)
	self:doSearch()
end

function NormalSearch:handleCheckBoxClicked(args)
	local checkbox = CEGUI.toCheckbox(CEGUI.toWindowEventArgs(args).window)
	if checkbox == self.onSellBox then
		self.searchOnSell = true
		self.onSellBox:setSelectedNoEvent(true)
		self.onShowBox:setSelectedNoEvent(false)
	else
		self.searchOnSell = false
		self.onSellBox:setSelectedNoEvent(false)
		self.onShowBox:setSelectedNoEvent(true)
	end
end

return NormalSearch