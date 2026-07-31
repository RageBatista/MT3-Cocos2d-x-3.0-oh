------------------------------------------------------------------
-- 摆摊交易记录，只记录珍品交易记录
------------------------------------------------------------------
require "logic.dialog"

local GROUPID_BUY = 1
local GROUPID_SELL = 2

------------------------------------------------------------------
local StallTradeLogCell = {}
StallTradeLogCell.__index = StallTradeLogCell
function StallTradeLogCell.new(prefix)
	local ret = {}
	setmetatable(ret, StallTradeLogCell)
	ret:init(prefix)
	return ret
end

function StallTradeLogCell:init(prefix)
	local winMgr = CEGUI.WindowManager:getSingleton()
	self.window = CEGUI.toGroupButton(winMgr:loadWindowLayout("baitanjiaoyijilucell.layout", prefix))
	self.icon = CEGUI.toItemCell(winMgr:getWindow(prefix .. "baitanjiaoyijilucell/wupin"))
	self.name = winMgr:getWindow(prefix .. "baitanjiaoyijilucell/mingzi")
	self.price = winMgr:getWindow(prefix .. "baitanjiaoyijilucell/huobizhi")
	
	self.window:EnableClickAni(false)
end

function StallTradeLogCell:reset()
	self.name:setText("???")
	self.name:setProperty("TextColours", "ff8c5e2a")
	self.price:setText("???")
	self.icon:SetImage(nil)
	self.icon:SetTextUnit("")
	self.icon:SetBackGroundImage("ccui", "chongwu_di")
end

--log { itemid, level, price }
function StallTradeLogCell:setInfo(log)
	self.price:setText(MoneyFormat(log.price))

	local goods = ShopManager.marketThreeTable[log.itemid]
	if not goods or goods.id == -1 then
		self:reset()
		return
	end

	if goods.itemtype == STALL_GOODS_T.PET then
		local petAttr = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(goods.itemid)
		if not petAttr then
			self:reset()
			return
		end
		self.name:setProperty("TextColours", "ff8c5e2a")
		self.name:setText("[colour=\'" .. petAttr.colour .. "\']" .. petAttr.name)
		local shapeData = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(petAttr.modelid)
		local image = gGetIconManager():GetImageByID(shapeData.littleheadID)
        self.icon:SetStyle(CEGUI.ItemCellStyle_IconExtend)
		self.icon:SetImage(image)
		self.icon:SetTextUnit("")
        SetItemCellBoundColorByQulityPet(self.icon, petAttr.quality)

	else
		local itemAttr = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(goods.itemid)
		if itemAttr then
            self.name:setProperty("TextColours", "ff8c5e2a")
			self.name:setText(itemAttr.name)
			local image = gGetIconManager():GetImageByID(itemAttr.icon)
            SetItemCellBoundColorByQulityItem(self.icon, itemAttr.nquality, itemAttr.itemtypeid)
            self.icon:SetStyle(CEGUI.ItemCellStyle_IconInside)
			self.icon:SetImage(image)
			if log.num > 1 then
				self.icon:SetTextUnit(tostring(log.num))
			elseif log.level > 0 then
				self.icon:SetTextUnit("Lv." .. log.level)
            else
                self.icon:SetTextUnit("")
			end
		else
			self:reset()
		end
	end
end
------------------------------------------------------------------

StallTradeLogDlg = {}
setmetatable(StallTradeLogDlg, Dialog)
StallTradeLogDlg.__index = StallTradeLogDlg

local _instance
function StallTradeLogDlg.getInstance()
	if not _instance then
		_instance = StallTradeLogDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function StallTradeLogDlg.getInstanceAndShow()
	if not _instance then
		_instance = StallTradeLogDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function StallTradeLogDlg.getInstanceNotCreate()
	return _instance
end

function StallTradeLogDlg.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function StallTradeLogDlg.ToggleOpenClose()
	if not _instance then
		_instance = StallTradeLogDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function StallTradeLogDlg.GetLayoutFileName()
	return "baitanjiaoyijilu.layout"
end

function StallTradeLogDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, StallTradeLogDlg)
	return self
end

function StallTradeLogDlg:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

	self.sellListBg = winMgr:getWindow("baitanjiaoyijilu/chushouqu/liebiao")
	self.sellEmptyView = winMgr:getWindow("baitanjiaoyijilu/chushouqu/sell_empty_view")
	self.buyListBg = winMgr:getWindow("baitanjiaoyijilu/goumaiqu/liebiao")
	self.buyEmptyView = winMgr:getWindow("baitanjiaoyijilu/goumaiqu/buy_empty_view")
	self.cleanBtn = CEGUI.toPushButton(winMgr:getWindow("baitanjiaoyijilu/qingchujilu"))

	if IsPointCardServer() then
		local text = winMgr:getWindow("baitanjiaoyijilu/wenben2")
		text:setVisible(false)

		text = winMgr:getWindow("baitanjiaoyijilu/wenben3")
		text:setVisible(true)
	else
		local text = winMgr:getWindow("baitanjiaoyijilu/wenben3")
		text:setVisible(false)

		text = winMgr:getWindow("baitanjiaoyijilu/wenben2")
		text:setVisible(true)
	end

	self.cleanBtn:subscribeEvent("Clicked", StallTradeLogDlg.handleCleanClicked, self)

	local s = self.buyListBg:getPixelSize()
	self.buyTable = TableView.create(self.buyListBg)
	self.buyTable:setViewSize(s.width, s.height)
	self.buyTable:setCellSize(450, 100)
	self.buyTable:setPosition(0, 0)
	self.buyTable:setDataSourceFunc(self, StallTradeLogDlg.tableViewGetCellAtIndex)
	self.selectedBuyCellIdx = -1

	s = self.sellListBg:getPixelSize()
	self.sellTable = TableView.create(self.sellListBg)
	self.sellTable:setViewSize(s.width, s.height)
	self.sellTable:setCellSize(450, 100)
	self.sellTable:setPosition(0, 0)
	self.sellTable:setDataSourceFunc(self, StallTradeLogDlg.tableViewGetCellAtIndex)
	self.selectSellCellIdx = -1

	local p = require("protodef.fire.pb.shop.cmarkettradelog"):new()
	LuaProtocolManager:send(p)
	
	--self:test()
end


--p: LogBean
function StallTradeLogDlg:setTradeLogData(p)
	self.datas = p

	--buy
	if #p.buylog > 0 then
		self.buyEmptyView:setVisible(false)
		self.buyTable:setCellCount(#p.buylog)
		self.buyTable:reloadData()
		
	elseif self.buyTable then
		self.buyTable:clear()
		self.buyEmptyView:setVisible(true)
	end
	
	--sell
	if #p.salelog > 0 then
		self.sellEmptyView:setVisible(false)
		self.sellTable:setCellCount(#p.salelog)
		self.sellTable:reloadData()
		
	elseif self.sellTable then
		self.sellTable:clear()
		self.sellEmptyView:setVisible(true)
	end
end

function StallTradeLogDlg:tableViewGetCellAtIndex(tableView, idx, cell)
	if not cell then
		local prefix = (tableView==self.buyTable and "b" or "s") .. tableView:genCellPrefix()
		cell = StallTradeLogCell.new(prefix)
		cell.window:setGroupID( tableView==self.buyTable and GROUPID_BUY or GROUPID_SELL )
		cell.window:subscribeEvent("SelectStateChanged", StallTradeLogDlg.handleCellClicked, self)
	end
	
	cell.name:setText(idx)
	cell.window:setID(idx)
	
	if tableView == self.buyTable then
		cell.window:setSelected(self.selectedBuyCellIdx == idx, false)
        local n = #self.datas.buylog - idx
		cell:setInfo(self.datas.buylog[n])
	else
		cell.window:setSelected(self.selectSellCellIdx == idx, false)
        local n = #self.datas.salelog - idx
		cell:setInfo(self.datas.salelog[n])
	end
	
	return cell
end

function StallTradeLogDlg:handleCellClicked(args)
	local wnd = CEGUI.toGroupButton(CEGUI.toWindowEventArgs(args).window)
	if wnd:getGroupID() == GROUPID_BUY then
		self.selectedBuyCellIdx = wnd:getID()
	else
		self.selectSellCellIdx = wnd:getID()
	end
end

function StallTradeLogDlg:handleConfirmClean(args)
	if self.datas and (#self.datas.buylog > 0 or #self.datas.salelog > 0) then
		local p = require("protodef.fire.pb.shop.cmarketcleantradelog"):new()
		LuaProtocolManager:send(p)
	else
		return
	end

	self.buyEmptyView:setVisible(true)
	self.buyTable:setCellCount(0)
	self.buyTable:reloadData()
	
	self.sellEmptyView:setVisible(true)
	self.sellTable:setCellCount(0)
	self.sellTable:reloadData()
end

function StallTradeLogDlg:handleCleanClicked(args)
	MessageBoxSimple.show(
		MHSD_UTILS.get_resstring(11441),  --确定要清除交易记录吗？
		StallTradeLogDlg.handleConfirmClean, self, nil, nil
	)
end

-- JUST FOR DEBUG --
function StallTradeLogDlg:test()
	local datas = {
		{itemid=500285, level=0, price=1},
		{itemid=500286, level=50, price=2},
		{itemid=500287, level=0, price=3},
		{itemid=500288, level=60, price=4},
		{itemid=500289, level=30, price=5},
		{itemid=500290, level=20, price=6}
	}
	
	local p = {buylog=datas, salelog=datas}
	self:setTradeLogData( p )
end

return StallTradeLogDlg