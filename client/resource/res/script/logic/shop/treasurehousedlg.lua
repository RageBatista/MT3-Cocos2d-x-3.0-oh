------------------------------------------------------------------
-- 藏宝阁
------------------------------------------------------------------
require "logic.dialog"

------------------------------------------------------------------

--订单状态名字(程序内字符串)
local OrderStateStrs = {
	11653,	--在售
	11654,	--锁定
	11655,	--已售
	11656,	--待领取
	11657	--领取完成
}

--订单状态
local OrderStates = {
	None		= 0,
	OnSell		= 1,	--在售
	Locked		= 2,	--锁定
	Sold		= 3,	--已售
	ToGet		= 4,	--待领取
	Getted		= 5		--领取完成
}

local SellHistoryCell = { prefixIdx = 0 }
SellHistoryCell.__index = SellHistoryCell
function SellHistoryCell:new()
	local ret = {}
	setmetatable(ret, SellHistoryCell)
	ret:init()
	return ret
end

function SellHistoryCell:init()
	SellHistoryCell.prefixIdx = SellHistoryCell.prefixIdx + 1
	local prefix = tostring(SellHistoryCell.prefixIdx)

	local winMgr = CEGUI.WindowManager:getSingleton()
	self.window = CEGUI.toGroupButton(winMgr:loadWindowLayout("cbgcell1.layout", prefix))
	self.seq = winMgr:getWindow(prefix .. "cbgcell1/xuhao")
	self.date = winMgr:getWindow(prefix .. "cbgcell1/riqi")
	self.dingDan = winMgr:getWindow(prefix .. "cbgcell1/dingdanhao")
	self.state = winMgr:getWindow(prefix .. "cbgcell1/zhuangtai")
end

--idx: from 1
--data: GoldOrder
function SellHistoryCell:setData(idx, data, imgid)
	local c = (imgid == 1 and "[colour='FF50321A']" or "")
	self.seq:setText(c .. idx)
	self.dingDan:setText(c .. data.pid)
	self.date:setText(c .. os.date("%y-%m-%d", math.floor(data.time*0.001)))

	if OrderStateStrs[data.state] then
		self.state:setText(c .. MHSD_UTILS.get_resstring(OrderStateStrs[data.state]))
	else
		self.state:setText("")
	end

	self.window:setID(data.pid)
end

------------------------------------------------------------------

local BuyHistoryCell = {  prefixIdx = 0 }
BuyHistoryCell.__index = BuyHistoryCell
function BuyHistoryCell:new()
	local ret = {}
	setmetatable(ret, BuyHistoryCell)
	ret:init()
	return ret
end

function BuyHistoryCell:init()
	BuyHistoryCell.prefixIdx = BuyHistoryCell.prefixIdx + 1
	local prefix = tostring(BuyHistoryCell.prefixIdx)

	local winMgr = CEGUI.WindowManager:getSingleton()
	self.window = CEGUI.toGroupButton(winMgr:loadWindowLayout("cbgcell2.layout", prefix))
	self.seq = winMgr:getWindow(prefix .. "cbgcell2/xuhao")
	self.state = winMgr:getWindow(prefix .. "cbgcell2/zhuangtai")
	self.num = winMgr:getWindow(prefix .. "cbgcell2/shuliang")
end

--idx: from 1
--data: GoldOrder
function BuyHistoryCell:setData(idx, data, imgid)
	local c = (imgid == 1 and "[colour='FF50321A']" or "")
	self.seq:setText(c .. idx)
	self.num:setText(c .. data.number)

	if OrderStateStrs[data.state] then
		self.state:setText(c .. MHSD_UTILS.get_resstring(OrderStateStrs[data.state]))
	else
		self.state:setText("")
	end

	self.window:setID(data.pid)
end

------------------------------------------------------------------

TreasureHouseDlg = {}
setmetatable(TreasureHouseDlg, Dialog)
TreasureHouseDlg.__index = TreasureHouseDlg

local _instance
function TreasureHouseDlg.getInstance()
	if not _instance then
		_instance = TreasureHouseDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function TreasureHouseDlg.getInstanceAndShow(parent)
	if not _instance then
		_instance = TreasureHouseDlg:new()
		_instance:OnCreate(parent)
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function TreasureHouseDlg.getInstanceNotCreate()
	return _instance
end

function TreasureHouseDlg.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function TreasureHouseDlg.ToggleOpenClose()
	if not _instance then
		_instance = TreasureHouseDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function TreasureHouseDlg.GetLayoutFileName()
	return "cbg.layout"
end

function TreasureHouseDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, TreasureHouseDlg)
	return self
end

function TreasureHouseDlg:OnCreate(parent)
	Dialog.OnCreate(self, parent)
	SetPositionOfWindowWithLabel(self:GetWindow())
	local winMgr = CEGUI.WindowManager:getSingleton()

	self.urlText = winMgr:getWindow("cbg/b1/chaolianjie")
	self.numText = winMgr:getWindow("cbg/b2/wenzi/xiaojianpan")
	self.priceText = winMgr:getWindow("cbg/b2/wenzi/xiaojianpan1")
	self.okBtn = CEGUI.toPushButton(winMgr:getWindow("cbg/b2/btn1"))
	self.sellHistoryBg = winMgr:getWindow("cbg/b3/baibg/list")
	self.cancelBtn = CEGUI.toPushButton(winMgr:getWindow("cbg/b3/btn1"))
	self.getMoneyBtn = CEGUI.toPushButton(winMgr:getWindow("cbg/b3/btn11"))
	self.buyHistoryBg = winMgr:getWindow("cbg/b3/baibg/list1")
	self.lineText = winMgr:getWindow("cbg/b1/hengxian")

	self.okBtn:subscribeEvent("Clicked", TreasureHouseDlg.handleOkClicked, self)
	self.cancelBtn:subscribeEvent("Clicked", TreasureHouseDlg.handleCancelClicked, self)
	self.getMoneyBtn:subscribeEvent("Clicked", TreasureHouseDlg.handleGetMoneyClicked, self)
	self.urlText:subscribeEvent("MouseClick", TreasureHouseDlg.handleUrlClicked, self)
	self.numText:subscribeEvent("MouseClick", TreasureHouseDlg.handleInputNumClicked, self)
	self.priceText:subscribeEvent("MouseClick", TreasureHouseDlg.handleInputPriceClicked, self)

	self:GetCloseBtn():removeEvent("Clicked")
	self:GetCloseBtn():subscribeEvent("Clicked", StallLabel.DestroyDialog, nil)
	
	local s = self.sellHistoryBg:getPixelSize()
	self.sellTable = TableView.create(self.sellHistoryBg)
	self.sellTable:setViewSize(s.width, s.height)
	self.sellTable:setDataSourceFunc(self, TreasureHouseDlg.sellTableViewGetCellAtIndex)
	
	s = self.buyHistoryBg:getPixelSize()
	self.buyTable = TableView.create(self.buyHistoryBg)
	self.buyTable:setViewSize(s.width, s.height)
	self.buyTable:setDataSourceFunc(self, TreasureHouseDlg.buyTableViewGetCellAtIndex)
	
	self.selllist = {}
	self.buylist = {}

	self.sellpid = -1 --订单号
	self.buypid = -1

	self.urlStr = GameTable.common.GetCCommonTableInstance():getRecorder(430).value
	self.urlText:setText(self.urlStr)
	local linestr = string.gsub(self.urlStr, "%S", "_")
	self.lineText:setText(linestr)

	--金币订单浏览
	local p = require("protodef.fire.pb.shop.cgoldorderbrowseblackmarket"):new()
	LuaProtocolManager:send(p)

	--[[< test
	for i=1,10 do
		local t = GoldOrder:new()
		t.pid = i
		table.insert(self.selllist, t)
	end
	self.sellTable:setCellCount(#self.selllist)
	self.sellTable:reloadData()
	-->]]
end

function TreasureHouseDlg:setGoldOrderList(selllist, buylist)
	self.selllist = selllist
	self.buylist = buylist

	self.sellTable:setCellCount(#selllist)
	self.sellTable:reloadData()
	
	self.buyTable:setCellCount(#buylist)
	self.buyTable:reloadData()
end

function TreasureHouseDlg:getOrderData(pid, isSell)
	if isSell then
		for _,v in ipairs(self.selllist) do
			if v.pid == pid then
				return v
			end
		end
	else
		for _,v in ipairs(self.buylist) do
			if v.pid == pid then
				return v
			end
		end
	end
	return nil
end

function TreasureHouseDlg:addOrder(order)
	table.insert(self.selllist, order)
	self.sellTable:setCellCount(#self.selllist)
	self.sellTable:reloadData()

	local bar = self.sellTable.scroll:getVertScrollbar()
	local pageH = bar:getPageSize()
    local docH = math.max(bar:getDocumentSize(), pageH)
	self.sellTable:setContentOffset(pageH-docH)
end

function TreasureHouseDlg:refreshGoldOrderState(pid, state)
	for _,v in ipairs(self.selllist) do
		if v.pid == pid then
			v.state = state
		end
	end

	for _,v in ipairs(self.sellTable.visibleCells) do
		if v.window:getID() == pid then
			if OrderStateStrs[state] then
				v.state:setText(MHSD_UTILS.get_resstring(OrderStateStrs[state]))
			else
				v.state:setText("")
			end
		end
	end
end

function TreasureHouseDlg:deleteGoldOrder(pid)
	if self.sellpid == pid then
		self.sellpid = -1
	end

	for k,v in ipairs(self.selllist) do
		if v.pid == pid then
			table.remove(self.selllist, k)
			break
		end
	end

	local offset = self.sellTable:getContentOffset()
	self.sellTable:setCellCount(#self.selllist)
	self.sellTable:reloadData()
	self.sellTable:setContentOffset(offset)
end

function TreasureHouseDlg:sellTableViewGetCellAtIndex(tableView, idx, cell)
	if not cell then
		cell = SellHistoryCell:new()
		cell.window:subscribeEvent("SelectStateChanged", TreasureHouseDlg.handleSellCellClicked, self)
	end

	local imgid = (#self.selllist-idx)%2
	cell.window:SetStateImageExtendID(imgid)

	local data = self.selllist[#self.selllist-idx]
	cell:setData(idx+1, data, imgid)
	if self.sellpid ~= -1 and self.sellpid == data.pid then
		cell.window:setSelected(true, false)
	else
		cell.window:setSelected(false, false)
	end
	return cell
end

function TreasureHouseDlg:buyTableViewGetCellAtIndex(tableView, idx, cell)
	if not cell then
		cell = BuyHistoryCell:new()
		cell.window:subscribeEvent("SelectStateChanged", TreasureHouseDlg.handleBuyCellClicked, self)
	end

	local imgid = (#self.buylist-idx)%2
	cell.window:SetStateImageExtendID(imgid)

	local data = self.buylist[#self.buylist-idx]
	cell:setData(idx+1, data, imgid)
	if self.buypid ~= -1 and self.buypid == data.pid then
		cell.window:setSelected(true, false)
	else
		cell.window:setSelected(false, false)
	end
	return cell
end

function TreasureHouseDlg:handleSellCellClicked(args)
	local pid = CEGUI.toWindowEventArgs(args).window:getID()
	self.sellpid = pid
end

function TreasureHouseDlg:handleBuyCellClicked(args)
	local pid = CEGUI.toWindowEventArgs(args).window:getID()
	self.buypid = pid
end

function TreasureHouseDlg:handleNumInputClosed()
	if self.numText:getText() == "" then
		return
	end

	local num = tonumber(self.numText:getText())

	local minVal = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(439).value) --藏宝阁金币最少数量
	if num < minVal then
		self.numText:setText(minVal)
		GetCTipsManager():AddMessageTipById(162183) --您输入的数量过少，最少100金币
	end
end

function TreasureHouseDlg:handleNumInputChanged(num)
	if num then
		local maxVal = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(441).value) --藏宝阁金币最多数量
		if num > maxVal then
			self.numText:setText(maxVal)
			GetCTipsManager():AddMessageTipById(162185) --您输入的数量过多,最多100000金币！
			return
		end

		self.numText:setText(num)
	else
		self.numText:setText("")
	end
end

function TreasureHouseDlg:handleInputNumClicked(args)
	local dlg = NumKeyboardDlg.getInstanceAndShow()
	if dlg then
		dlg:setTriggerBtn(self.numText)
		dlg:setAllowClear(true)
		dlg:setInputChangeCallFunc(TreasureHouseDlg.handleNumInputChanged, self)
		dlg:setCloseCallFunc(TreasureHouseDlg.handleNumInputClosed, self)
		
		local p = self.numText:GetScreenPos()
		local s = self.numText:getPixelSize()
		local s1 = dlg:GetWindow():getPixelSize()
		SetPositionOffset(dlg:GetWindow(), p.x -(s1.width-s.width)*0.5, p.y+s.height)
	end
end

function TreasureHouseDlg:handlePriceInputClosed()
	if self.priceText:getText() == "" then
		return
	end

	local num = MoneyNumber(self.priceText:getText())

	local minVal = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(438).value) --藏宝阁人民币最少数量
	if num < minVal then
		self.priceText:setText(MoneyFormat(minVal))
		GetCTipsManager():AddMessageTipById(162177) --您输入的数量过少，最少10元
	end
end

function TreasureHouseDlg:handlePriceInputChanged(num)
	if num then
		local maxVal = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(440).value) --藏宝阁人民币最多数量
		if num > maxVal then
			self.priceText:setText(MoneyFormat(maxVal))
			GetCTipsManager():AddMessageTipById(162184) --您输入的数量过多,最多10000元！
			return
		end

		self.priceText:setText(MoneyFormat(num))
	else
		self.priceText:setText("")
	end
end

function TreasureHouseDlg:handleInputPriceClicked(args)
	local dlg = NumKeyboardDlg.getInstanceAndShow()
	if dlg then
		dlg:setTriggerBtn(self.priceText)
		dlg:setAllowClear(true)
		dlg:setInputChangeCallFunc(TreasureHouseDlg.handlePriceInputChanged, self)
		dlg:setCloseCallFunc(TreasureHouseDlg.handlePriceInputClosed, self)
		
		local p = self.priceText:GetScreenPos()
		local s = self.priceText:getPixelSize()
		local s1 = dlg:GetWindow():getPixelSize()
		SetPositionOffset(dlg:GetWindow(), p.x -(s1.width-s.width)*0.5, p.y+s.height)
	end
end

function TreasureHouseDlg:handleOkClicked(args)
	-- 限制上架
    local shoujianquanmgr = require "logic.shoujianquan.shoujianquanmgr"
    if shoujianquanmgr.needBindTelAgain() then
        require("logic.shoujianquan.shoujiyanzheng").getInstanceAndShow()
        return
    elseif shoujianquanmgr.notBind7Days() then
        require("logic.shoujianquan.shoujiguanlianqueren").getInstanceAndShow()
        return
    end

	if self.numText:getText() == "" or self.numText:getText() == "0" or
	   self.priceText:getText() == "" or self.priceText:getText() == "0" then
		return
	end

	local maxNum = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(442).value) --藏宝阁最多单数
	if #self.selllist > maxNum then
		GetCTipsManager():AddMessageTipById(162188) --地精市场目前最多上架5单
		return
	end

	local p = require("protodef.fire.pb.shop.cgoldorderupblackmarket"):new()
	p.goldnumber = tonumber(self.numText:getText())
	p.rmb = MoneyNumber(self.priceText:getText())
	LuaProtocolManager:send(p)

	self.numText:setText("")
	self.priceText:setText("")
end

function TreasureHouseDlg:handleCancelClicked(args)
	if self.sellpid == -1 then
		return
	end

	local order = self:getOrderData(self.sellpid, true)
	if not order or (order.state ~= OrderStates.OnSell and order.state ~= OrderStates.Locked) then
		return
	end

	local p = require("protodef.fire.pb.shop.cgoldorderdownblackmarket"):new()
	p.pid = self.sellpid
	LuaProtocolManager:send(p)
end

function TreasureHouseDlg:handleGetMoneyClicked(args)
	if self.buypid == -1 then
		return
	end

	local order = self:getOrderData(self.buypid, false)
	if not order or order.state ~= OrderStates.ToGet then
		return
	end

	local p = require("protodef.fire.pb.shop.cgoldordertakeoutblackmarket"):new()
	p.pid = self.buypid
	LuaProtocolManager:send(p)
end

function TreasureHouseDlg:handleUrlClicked(args)
	IOS_MHSD_UTILS.OpenURL(self.urlStr)
end

return TreasureHouseDlg