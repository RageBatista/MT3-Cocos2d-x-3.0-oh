require "logic.dialog"

--状态文本
local OrderStateStrs = {
	11653,
	11654,
	11655,
	11656,
	11657
}

--状态值
local OrderStates = {
	None   = 0,
	OnSell = 1,
	Locked = 2,
	Sold   = 3,
	ToGet  = 4,
	Getted = 5
}
local prefix=1
CBGGoldDlg = {}
setmetatable(CBGGoldDlg, Dialog)
CBGGoldDlg.__index = CBGGoldDlg

local _instance
function CBGGoldDlg.getInstance()
	if not _instance then
		_instance = CBGGoldDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function CBGGoldDlg.getInstanceAndShow()
	if not _instance then
		_instance = CBGGoldDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function CBGGoldDlg.getInstanceNotCreate()
	return _instance
end

function CBGGoldDlg.DestroyDialog()
	if _instance then
		if _instance.currencyRegistered and _instance.havegold then
			CurrencyManager.unregisterTextWidget(_instance.havegold)
		end
		if _instance.currencyRegistered and _instance.haveDJQ then
			CurrencyManager.unregisterTextWidget(_instance.haveDJQ)
		end
		_instance.currencyRegistered = nil
		--_instance:reset()
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function CBGGoldDlg.ToggleOpenClose()
	if not _instance then
		_instance = CBGGoldDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function CBGGoldDlg.GetLayoutFileName()
	return "cbggolddlg.layout"
end

function CBGGoldDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, CBGGoldDlg)
	return self
end

function CBGGoldDlg:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

	self.closeBtn = CEGUI.toPushButton(winMgr:getWindow("cbggolddlg/close"))
	self.minnum = winMgr:getWindow("cbggolddlg/top/unit1/di/text")
	self.maxnum = winMgr:getWindow("cbggolddlg/top/unit1/di/text1")
	self.minprice = winMgr:getWindow("cbggolddlg/top/unit1/di/text2")
	self.maxprice = winMgr:getWindow("cbggolddlg/top/unit1/di/text11")
	self.SearchButton = CEGUI.toPushButton(winMgr:getWindow("cbggolddlg/top/searchbtn"))
	self.buyscorllable = CEGUI.toScrollablePane(winMgr:getWindow("cbggolddlg/list/scorllable"))
	self.haveDJQ = winMgr:getWindow("cbggolddlg/top/unit1/di/text3")
	self.needDJQ = winMgr:getWindow("cbggolddlg/top/unit1/di/text31")
	self.BuyGoldButton = CEGUI.toPushButton(winMgr:getWindow("cbggolddlg/buy/buyinfo/"))
	self.BuyTab = CEGUI.toGroupButton(winMgr:getWindow("cbggolddlg/groupbtn/buybtn"))
	self.SellTab = CEGUI.toGroupButton(winMgr:getWindow("cbggolddlg/groupbtn/buybtn1"))
	self.RecordTab = CEGUI.toGroupButton(winMgr:getWindow("cbggolddlg/groupbtn/buybtn3"))
	self.SellScorllable = CEGUI.toScrollablePane(winMgr:getWindow("cbggolddlg/sell/sellbg/selllist"))
	self.havegold = winMgr:getWindow("cbggolddlg/top/unit1/di/text311")
	self.sellgold = winMgr:getWindow("cbggolddlg/top/unit1/di/text3111")
	self.sellprice = winMgr:getWindow("cbggolddlg/top/unit1/di/text3112")
	self.loading = winMgr:getWindow("cbggolddlg/list/scorllable/tips")
	self.taxfee = winMgr:getWindow("cbggolddlg/top/unit1/di/text31121")
	self.SellButton = CEGUI.toPushButton(winMgr:getWindow("cbggolddlg/sell/sellgoldbtn"))
	self.SellListS = CEGUI.toScrollablePane(winMgr:getWindow("cbg/b3/baibg/list"))
	self.BuyListS = CEGUI.toScrollablePane(winMgr:getWindow("cbg/b3/baibg/list1"))
	self.GetGoldButton = CEGUI.toPushButton(winMgr:getWindow("cbggolddlg/record/buttonget"))
	self.DownGoldButton = CEGUI.toPushButton(winMgr:getWindow("cbggolddlg/record/downbtn"))
	self.total = winMgr:getWindow("cbggolddlg/buy/total")

	self.buycontainer = winMgr:getWindow("cbggolddlg/buy")
	self.sellcontainer = winMgr:getWindow("cbggolddlg/sell")
	self.recordcontainer = winMgr:getWindow("cbggolddlg/record")
	self.closeBtn:subscribeEvent("Clicked", CBGGoldDlg.HandleCloseButtonClick, self)
	self.SearchButton:subscribeEvent("Clicked", CBGGoldDlg.OnSearchButtonClick, self)
	self.BuyGoldButton:subscribeEvent("Clicked", CBGGoldDlg.BuyGoldButtonClick, self)
	self.BuyTab:subscribeEvent("SelectStateChanged", CBGGoldDlg.OnTableSelected, self)
	self.SellTab:subscribeEvent("SelectStateChanged", CBGGoldDlg.OnTableSelected, self)
	self.RecordTab:subscribeEvent("SelectStateChanged", CBGGoldDlg.OnTableSelected, self)
	self.SellButton:subscribeEvent("Clicked", CBGGoldDlg.SellButtonClick, self)
	self.GetGoldButton:subscribeEvent("Clicked", CBGGoldDlg.GetGoldButtonClick, self)
	self.DownGoldButton:subscribeEvent("Clicked", CBGGoldDlg.DownGoldButtonClick, self)

	self.minnum:subscribeEvent("MouseClick", CBGGoldDlg.handleInputMinNumClicked, self)
	self.maxnum:subscribeEvent("MouseClick", CBGGoldDlg.handleInputMaxNumClicked, self)
	self.minprice:subscribeEvent("MouseClick", CBGGoldDlg.handleInputMinPriceClicked, self)
	self.maxprice:subscribeEvent("MouseClick", CBGGoldDlg.handleInputMaxPriceClicked, self)

	self.sellgold:subscribeEvent("MouseClick", CBGGoldDlg.handleInputSellGoldClicked, self)
	self.sellprice:subscribeEvent("MouseClick", CBGGoldDlg.handleInputSellPriceClicked, self)

	self.buttons = {}
	for i = 1, 3 do
		self.buttons[i] = CEGUI.toPushButton(winMgr:getWindow("cbggolddlg/button" .. tostring(i)))
		self.buttons[i]:setID(i)
		self.buttons[i]:subscribeEvent("Clicked", CBGGoldDlg.handleTabBtnClicked, self)
	end
	self.buyscorllable:subscribeEvent("NextPage", CBGGoldDlg.OnNextPage, self)

	self.buttons[1]:SetPushState(true)
	prefix=1
	self.currpage = 1
	self.maxpage = 0
	self.hasmore = false
	self.selllist = {}
	self.buylist = {}
	self.cells = {}
	self.sellcells = {}
	self.recordcells = {}
	self.buycells = {}
	self.selldata = {}
	self.orderlist = {}

	self.sellpid = -1
	self.buypid = -1
	self.orderpid = -1
	self.djq = 0

	self.loading:setVisible(true)
	self:cleaRecordList()
	CurrencyManager.registerTextWidget(fire.pb.game.MoneyType.MoneyType_GoldCoin, self.havegold)
	CurrencyManager.registerTextWidget(fire.pb.game.MoneyType.MoneyType_EreditPoint, self.haveDJQ)
	self.currencyRegistered = true
	self.havegold:setText(tostring(CurrencyManager.getOwnCurrencyMount(fire.pb.game.MoneyType.MoneyType_GoldCoin)))
	self:updateDjq(CurrencyManager.getOwnCurrencyMount(fire.pb.game.MoneyType.MoneyType_EreditPoint))
	--获取数据
	self:getGoldList()
	local p = require("protodef.fire.pb.shop.cgoldorderbrowseblackmarket"):new()
	LuaProtocolManager:send(p)
end

function CBGGoldDlg:OnNextPage(args)
	if self.hasmore then
		self.currpage = self.currpage + 1
		self.loading:setVisible(true)
		local minNum = tonumber(self.minnum:getText())
		local maxNum = tonumber(self.maxnum:getText())
		local minPrice = tonumber(self.minprice:getText())
		local maxPrice = tonumber(self.maxprice:getText())
		local p = require("protodef.fire.pb.shop.cgoldorderbrowseindex"):new()
		p.minnum = minNum
		p.maxnum = maxNum
		p.minprice = minPrice
		p.maxprice = maxPrice
		p.page = self.currpage
		LuaProtocolManager:send(p)
	else
		GetCTipsManager():AddMessageTip("当前已经是最后一页")
	end
end

function CBGGoldDlg:updateDjq(djq)
	self.djq = djq
	self.haveDJQ:setText(tostring(djq))
end

function CBGGoldDlg:cleaRecordList()
	for _, v in pairs(self.recordcells) do
		CEGUI.WindowManager:getSingleton():destroyWindow(v)
		self.buyscorllable:removeChildWindow(v)
	end
	self.buyscorllable:cleanupNonAutoChildren()
	self.recordcells = {}
end

function CBGGoldDlg:setGoldOrderIndex(data)
	self.loading:setVisible(false)
	self.hasmore = (data.hasmore >= 1)
	self.total:setText('总计: ' .. tostring(data.total) .. ' 条记录')
	local winMgr = CEGUI.WindowManager:getSingleton()
	if (data.isclear == 1) then
		self:cleaRecordList()
		self.currpage = 1
	end
	for k, v in pairs(data.goldlist) do
		local c = (prefix % 2 == 1 and "[colour='FF50321A']" or "")
		local prefixName = "/recordlist" .. tostring(prefix).."/"
		local layout = CEGUI.WindowManager:getSingleton():loadWindowLayout("cbggoldbuycell.layout", prefixName)
		self.buyscorllable:addChildWindow(layout)
		layout:setID(v.pid)
		layout.num = winMgr:getWindow(prefixName .. "cbggoldbuycell/gold")
		layout.price = winMgr:getWindow(prefixName .. "cbggoldbuycell/price")
		layout.rolename = winMgr:getWindow(prefixName .. "cbggoldbuycell/rolename")
		layout.date = winMgr:getWindow(prefixName .. "cbggoldbuycell/date")
		layout:setID(v.pid)
		layout.num:setText(c .. tostring(v.number))
		layout.price:setText(c .. tostring(v.price))
		layout.rolename:setText(c .. tostring(v.rolename))
		layout:subscribeEvent("SelectStateChanged", CBGGoldDlg.handleOrderCellClicked, self)
		layout.date:setText(c .. os.date("%y-%m-%d", math.floor(v.time * 0.001)))
		layout:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0, -3), CEGUI.UDim(0.0, (prefix - 1) * 40)))
		self.recordcells[v.pid] = layout
		self.orderlist[v.pid] = v
		prefix=prefix+1
	end
end

function CBGGoldDlg:handleOrderCellClicked(args)
	local pid = CEGUI.toWindowEventArgs(args).window:getID()
	self.orderpid = pid
	self.needDJQ:setText(tostring(math.floor(self.orderlist[pid].price)))
end

function CBGGoldDlg:refreshGoldOrder()
	self:clearSellList()
	self:clearBuyList()

	local winMgr = CEGUI.WindowManager:getSingleton()
	for k, v in pairs(self.selllist) do
		local c = (k % 2 == 1 and "[colour='FF50321A']" or "")
		local prefixName = "selllist" .. tostring(k)
		local layout = CEGUI.WindowManager:getSingleton():loadWindowLayout("cellgoldsell.layout", prefixName)
		self.SellListS:addChildWindow(layout)
		layout.date = winMgr:getWindow(prefixName .. "cellgoldsell/date")
		layout.num = winMgr:getWindow(prefixName .. "cellgoldsell/num")
		layout.price = winMgr:getWindow(prefixName .. "cellgoldsell/price")
		layout.state = winMgr:getWindow(prefixName .. "cellgoldsell/state")
		layout:setID(v.pid)
		layout.num:setText(c .. tostring(v.number))
		layout.price:setText(c .. tostring(v.price))
		if OrderStateStrs[v.state] then
			layout.state:setText(c .. MHSD_UTILS.get_resstring(OrderStateStrs[v.state]))
		else
			layout.state:setText("")
		end
		layout:subscribeEvent("SelectStateChanged", CBGGoldDlg.handleSellCellClicked, self)
		layout.date:setText(c .. os.date("%y-%m-%d", math.floor(v.time * 0.001)))
		layout:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0, -1), CEGUI.UDim(0.0, (k - 1) * 40)))
		self.sellcells[v.pid] = layout
	end

	for k, v in pairs(self.buylist) do
		local c = (k % 2 == 1 and "[colour='FF50321A']" or "")
		local prefixName = "buylist" .. tostring(k)
		local layout = CEGUI.WindowManager:getSingleton():loadWindowLayout("cellgoldbuy.layout", prefixName)
		self.BuyListS:addChildWindow(layout)

		layout.money = winMgr:getWindow(prefixName .. "cellgoldbuy/money")
		layout.state = winMgr:getWindow(prefixName .. "cellgoldbuy/state")
		layout.num = winMgr:getWindow(prefixName .. "cellgoldbuy/num")
		layout.date = winMgr:getWindow(prefixName .. "cellgoldbuy/date")

		layout:setID(v.pid)
		layout.num:setText(c .. tostring(v.number))
		layout.money:setText(c .. tostring(v.price))
		if OrderStateStrs[v.state] then
			layout.state:setText(c .. MHSD_UTILS.get_resstring(OrderStateStrs[v.state]))
		else
			layout.state:setText("")
		end
		layout:subscribeEvent("SelectStateChanged", CBGGoldDlg.handleBuyCellClicked, self)
		layout.date:setText(c .. os.date("%y-%m-%d", math.floor(v.time * 0.001)))
		layout:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0, -1), CEGUI.UDim(0.0, (k - 1) * 40)))
		self.buycells[v.pid] = layout
	end
end

function CBGGoldDlg:setGoldOrderList(selllist, buylist)
	self.selllist = selllist
	self.buylist = buylist
	self:clearSellList()
	self:clearBuyList()
	self:refreshGoldOrder()
end

function CBGGoldDlg:addOrder(order)
	table.insert(self.selllist, order)
	self:clearSellList()
	self:clearBuyList()
	self:refreshGoldOrder()
end

function CBGGoldDlg:getOrderData(pid, isSell)
	if isSell then
		for _, v in ipairs(self.selllist) do
			if v.pid == pid then
				return v
			end
		end
	else
		for _, v in ipairs(self.buylist) do
			if v.pid == pid then
				return v
			end
		end
	end
	return nil
end

function CBGGoldDlg:clearSellList()
	for _, v in pairs(self.sellcells) do
		CEGUI.WindowManager:getSingleton():destroyWindow(v)
		self.SellListS:removeChildWindow(v)
	end
	self.SellListS:cleanupNonAutoChildren()
	self.sellcells = {}
end

function CBGGoldDlg:clearBuyList()
	for _, v in pairs(self.buycells) do
		CEGUI.WindowManager:getSingleton():destroyWindow(v)
		self.BuyListS:removeChildWindow(v)
	end
	self.BuyListS:cleanupNonAutoChildren()
	self.buycells = {}
end

function CBGGoldDlg:clearList()
	for _, v in pairs(self.cells) do
		CEGUI.WindowManager:getSingleton():destroyWindow(v)
		self.SellScorllable:removeChildWindow(v)
	end
	self.SellScorllable:cleanupNonAutoChildren()
	self.cells = {}
end

function CBGGoldDlg:mySell(data)
	self:clearList()
	self.selldata = data
	local itemHeight = 102
	local itemwidth = 252
	local idx = 1
	for k, v in pairs(self.selldata) do
		if v.state == OrderStates.OnSell then
			local winMgr = CEGUI.WindowManager:getSingleton()
			local prefixName = "mysell" .. tostring(idx)
			local layout = CEGUI.WindowManager:getSingleton():loadWindowLayout("cbggoldcell.layout", prefixName)
			self.SellScorllable:addChildWindow(layout)
			layout.num = winMgr:getWindow(prefixName .. "cbggoldcell/di/num")
			layout.price = winMgr:getWindow(prefixName .. "cbggoldcell/di/price/jiage")
			layout.downbtn = winMgr:getWindow(prefixName .. "cbggoldcell/quxia")
			layout.downbtn:setID(v.pid)
			layout.downbtn:subscribeEvent("Clicked", CBGGoldDlg.HandleDwon, self)
			layout.num:setText(tostring(v.number))
			layout.price:setText(tostring(v.price))

			self.cells[v.pid] = layout
			local sx = math.floor((idx - 1) % 2) * itemwidth
			local sy = math.floor((idx - 1) / 2) * itemHeight
			layout:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0, sx), CEGUI.UDim(0.0, sy)))
			idx = idx + 1
		end
	end
end

function CBGGoldDlg:DownGoldButtonClick(args)
	if self.sellpid == -1 then
		return
	end
	local order = self:getOrderData(self.sellpid, true)
	if not order or order.state ~= OrderStates.OnSell then
		return
	end
	gConfirmBox('您确定要下架该订单吗？', '下架', function()
		local pid = self.sellpid
		local p = require("protodef.fire.pb.shop.cgoldorderdownblackmarket"):new()
		p.pid = pid
		LuaProtocolManager:send(p)
	end)
end

function CBGGoldDlg:HandleDwon(args)
	local eventargs = CEGUI.toWindowEventArgs(args)
	local btn = eventargs.window
	local pid = btn:getID()
	gConfirmBox('您确定要下架该订单吗？', '下架', function()
		local p = require("protodef.fire.pb.shop.cgoldorderdownblackmarket"):new()
		p.pid = pid
		LuaProtocolManager:send(p)
	end)
end

function CBGGoldDlg:refreshGoldOrderState(pid, state)
	for _, v in ipairs(self.selllist) do
		if v.pid == pid then
			v.state = state
		end
	end
	for _, v in ipairs(self.buylist) do
		if v.pid == pid then
			v.state = state
		end
	end
	self:clearSellList()
	self:clearBuyList()
	self:refreshGoldOrder()
end

function CBGGoldDlg:deleteGoldOrder(pid)
	if self.sellpid == pid then
		self.sellpid = -1
	end
	if self.buypid == pid then
		self.buypid = -1
	end

	for k, v in ipairs(self.selllist) do
		if v.pid == pid then
			table.remove(self.selllist, k)
			break
		end
	end
	for k, v in ipairs(self.buylist) do
		if v.pid == pid then
			table.remove(self.buylist, k)
			break
		end
	end
	self:clearSellList()
	self:clearBuyList()
	self:refreshGoldOrder()
end

function CBGGoldDlg:handleSellCellClicked(args)
	local pid = CEGUI.toWindowEventArgs(args).window:getID()
	self.sellpid = pid
end

function CBGGoldDlg:handleBuyCellClicked(args)
	local pid = CEGUI.toWindowEventArgs(args).window:getID()
	self.buypid = pid
end

function CBGGoldDlg:HandleCloseButtonClick(args)
	self:DestroyDialog()
end

function CBGGoldDlg:getGoldList()
	self.loading:setVisible(true)
	local minNum = tonumber(self.minnum:getText())

	local maxNum = tonumber(self.maxnum:getText())

	local minPrice = tonumber(self.minprice:getText())

	local maxPrice = tonumber(self.maxprice:getText())

	local p = require("protodef.fire.pb.shop.cgoldorderbrowseindex"):new()
	p.minnum = minNum
	p.maxnum = maxNum
	p.minprice = minPrice
	p.maxprice = maxPrice
	p.page = self.currpage
	LuaProtocolManager:send(p)
end

function CBGGoldDlg:OnSearchButtonClick(args)
	prefix=1
	self.currpage = 1
	self:cleaRecordList()
	self:getGoldList()
end

function CBGGoldDlg:BuyGoldButtonClick(args)
	if self.orderpid == -1 then
		GetCTipsManager():AddMessageTip("请选择购买订单")
		return
	end
	self:updateDjq(CurrencyManager.getOwnCurrencyMount(fire.pb.game.MoneyType.MoneyType_EreditPoint))
	if self.djq == 0 then
		GetCTipsManager():AddMessageTip("您的代金券不足，无法购买")
		return
	end
	if tonumber(self.needDJQ:getText()) > self.djq then
		GetCTipsManager():AddMessageTip("您的代金券不足，无法购买")
		return
	end
	local req = require("protodef.fire.pb.shop.cgoldordertrade"):new()
	req.sellrole = self.orderlist[self.orderpid].roleid
	req.pid = self.orderpid
	LuaProtocolManager:send(req)
end

function CBGGoldDlg:SellButtonClick(args)
	local vipLevel = gGetDataManager():GetVipLevel()
	if vipLevel < 1 then
		GetCTipsManager():AddMessageTip("您的VIP等级不足，无法出售，需要VIP等级1")
		return
	end
	local p = require("protodef.fire.pb.shop.cgoldorderupblackmarket"):new()
	p.goldnumber = tonumber(self.sellgold:getText())
	p.rmb = MoneyNumber(self.sellprice:getText())
	LuaProtocolManager:send(p)
	self.sellgold:setText("0")
	self.sellprice:setText("0")
	self.taxfee:setText("0")
end

function CBGGoldDlg:OnTableSelected(args)
	local eventargs = CEGUI.toWindowEventArgs(args)
	local curr = eventargs.window
	if curr == self.BuyTab then
		self.buycontainer:setVisible(true)
		self.sellcontainer:setVisible(false)
		self.recordcontainer:setVisible(false)
	elseif curr == self.SellTab then
		self.buycontainer:setVisible(false)
		self.sellcontainer:setVisible(true)
		self.recordcontainer:setVisible(false)
	elseif curr == self.RecordTab then
		self.buycontainer:setVisible(false)
		self.sellcontainer:setVisible(false)
		self.recordcontainer:setVisible(true)
	end
end

function CBGGoldDlg:GetGoldButtonClick(args)
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

function CBGGoldDlg:handleInputMinNumClicked(args)
	local dlg = NumKeyboardDlg.getInstanceAndShow()
	if dlg then
		dlg:setTriggerBtn(self.minnum)
		dlg:setAllowClear(true)
		dlg:setInputChangeCallFunc(CBGGoldDlg.handleMinNumInputChanged, self)
		dlg:setCloseCallFunc(CBGGoldDlg.handleMinNumInputClosed, self)

		local p = self.minnum:GetScreenPos()
		local s = self.minnum:getPixelSize()
		local s1 = dlg:GetWindow():getPixelSize()
		SetPositionOffset(dlg:GetWindow(), p.x - (s1.width - s.width) * 0.5, p.y + s.height)
	end
end

function CBGGoldDlg:handleMinNumInputClosed()
	if self.minnum:getText() == "" then
		return
	end

	local num = tonumber(self.minnum:getText())

	local minVal = 0
	if num < minVal then
		self.minnum:setText(minVal)
		GetCTipsManager():AddMessageTip("不能输入低于0的数字")
	end
end

function CBGGoldDlg:handleMinNumInputChanged(num)
	if num then
		local maxVal = 100000000
		if num > maxVal then
			self.minnum:setText(maxVal)
			GetCTipsManager():AddMessageTip('最小值不能高于100000000') --���������������,���100000��ң�
			return
		end

		self.minnum:setText(num)
	else
		self.minnum:setText("")
	end
end

function CBGGoldDlg:handleInputMaxNumClicked(args)
	local dlg = NumKeyboardDlg.getInstanceAndShow()
	if dlg then
		dlg:setTriggerBtn(self.maxnum)
		dlg:setAllowClear(true)
		dlg:setInputChangeCallFunc(CBGGoldDlg.handleMaxNumInputChanged, self)
		dlg:setCloseCallFunc(CBGGoldDlg.handleMaxNumInputClosed, self)

		local p = self.maxnum:GetScreenPos()
		local s = self.maxnum:getPixelSize()
		local s1 = dlg:GetWindow():getPixelSize()
		SetPositionOffset(dlg:GetWindow(), p.x - (s1.width - s.width) * 0.5, p.y + s.height)
	end
end

function CBGGoldDlg:handleMaxNumInputClosed()
	if self.maxnum:getText() == "" then
		return
	end

	local num = tonumber(self.maxnum:getText())

	local minVal = 0
	if num < minVal then
		self.maxnum:setText(minVal)
		GetCTipsManager():AddMessageTip("不能输入低于0的数字")
	end
end

function CBGGoldDlg:handleMaxNumInputChanged(num)
	if num then
		local maxVal = 100000000
		if num > maxVal then
			self.maxnum:setText(maxVal)
			GetCTipsManager():AddMessageTip('最大值不能高于100000000')
			return
		end

		self.maxnum:setText(num)
	else
		self.maxnum:setText("")
	end
end

--===================================================================
function CBGGoldDlg:handleInputMinPriceClicked(args)
	local dlg = NumKeyboardDlg.getInstanceAndShow()
	if dlg then
		dlg:setTriggerBtn(self.minprice)
		dlg:setAllowClear(true)
		dlg:setInputChangeCallFunc(CBGGoldDlg.handleMinPriceInputChanged, self)
		dlg:setCloseCallFunc(CBGGoldDlg.handleMinPriceInputClosed, self)

		local p = self.minprice:GetScreenPos()
		local s = self.minprice:getPixelSize()
		local s1 = dlg:GetWindow():getPixelSize()
		SetPositionOffset(dlg:GetWindow(), p.x - (s1.width - s.width) * 0.5, p.y + s.height)
	end
end

function CBGGoldDlg:handleMinPriceInputClosed()
	if self.minprice:getText() == "" then
		return
	end

	local num = tonumber(self.minprice:getText())

	local minVal = 0
	if num < minVal then
		self.minprice:setText(minVal)
		GetCTipsManager():AddMessageTip("不能输入低于0的数字")
	end
end

function CBGGoldDlg:handleMinPriceInputChanged(num)
	if num then
		local maxVal = 10000
		if num > maxVal then
			self.minprice:setText(maxVal)
			GetCTipsManager():AddMessageTip('最小值不能高于10000') --���������������,���100000��ң�
			return
		end

		self.minprice:setText(num)
	else
		self.minprice:setText("")
	end
end

function CBGGoldDlg:handleInputMaxPriceClicked(args)
	local dlg = NumKeyboardDlg.getInstanceAndShow()
	if dlg then
		dlg:setTriggerBtn(self.maxprice)
		dlg:setAllowClear(true)
		dlg:setInputChangeCallFunc(CBGGoldDlg.handleMaxPriceInputChanged, self)
		dlg:setCloseCallFunc(CBGGoldDlg.handleMaxPriceInputClosed, self)

		local p = self.maxprice:GetScreenPos()
		local s = self.maxprice:getPixelSize()
		local s1 = dlg:GetWindow():getPixelSize()
		SetPositionOffset(dlg:GetWindow(), p.x - (s1.width - s.width) * 0.5, p.y + s.height)
	end
end

function CBGGoldDlg:handleMaxPriceInputClosed()
	if self.maxprice:getText() == "" then
		return
	end

	local num = tonumber(self.maxprice:getText())

	local minVal = 0
	if num < minVal then
		self.maxprice:setText(minVal)
		GetCTipsManager():AddMessageTip("不能输入低于0的数字")
	end
end

function CBGGoldDlg:handleMaxPriceInputChanged(num)
	if num then
		local maxVal = 100000
		if num > maxVal then
			self.maxprice:setText(maxVal)
			GetCTipsManager():AddMessageTip('最大值不能高于100000')
			return
		end

		self.maxprice:setText(num)
	else
		self.maxprice:setText("")
	end
end

----------------------------------------------------------------
function CBGGoldDlg:handleInputSellGoldClicked(args)
	local dlg = NumKeyboardDlg.getInstanceAndShow()
	if dlg then
		dlg:setTriggerBtn(self.sellgold)
		dlg:setAllowClear(true)
		dlg:setInputChangeCallFunc(CBGGoldDlg.handleSellGoldInputChanged, self)
		dlg:setCloseCallFunc(CBGGoldDlg.handleSellGoldInputClosed, self)

		local p = self.sellgold:GetScreenPos()
		local s = self.sellgold:getPixelSize()
		local s1 = dlg:GetWindow():getPixelSize()
		SetPositionOffset(dlg:GetWindow(), p.x - (s1.width - s.width) * 0.5, p.y + s.height)
	end
end

function CBGGoldDlg:handleSellGoldInputClosed()
	if self.sellgold:getText() == "" then
		return
	end

	local num = tonumber(self.sellgold:getText())

	local minVal = 0
	if num < minVal then
		self.sellgold:setText(minVal)
		GetCTipsManager():AddMessageTip("不能输入低于0的数字")
	end
end

function CBGGoldDlg:handleSellGoldInputChanged(num)
	if num then
		local maxVal = 10000000
		if num > tonumber(maxVal) then
			self.sellgold:setText(maxVal)
			GetCTipsManager():AddMessageTip('最大值不能高于10000000')
			return
		end

		self.sellgold:setText(num)
	else
		self.sellgold:setText("")
	end
end

function CBGGoldDlg:handleInputSellPriceClicked(args)
	local dlg = NumKeyboardDlg.getInstanceAndShow()
	if dlg then
		dlg:setTriggerBtn(self.sellprice)
		dlg:setAllowClear(true)
		dlg:setInputChangeCallFunc(CBGGoldDlg.handleSellPriceInputChanged, self)
		dlg:setCloseCallFunc(CBGGoldDlg.handleSellPriceInputClosed, self)

		local p = self.sellprice:GetScreenPos()
		local s = self.sellprice:getPixelSize()
		local s1 = dlg:GetWindow():getPixelSize()
		SetPositionOffset(dlg:GetWindow(), p.x - (s1.width - s.width) * 0.5, p.y + s.height)
	end
end

function CBGGoldDlg:handleSellPriceInputClosed()
	if self.sellprice:getText() == "" then
		return
	end

	local num = tonumber(self.sellprice:getText())

	local minVal = 10
	if num < minVal then
		self.sellprice:setText(minVal)
		GetCTipsManager():AddMessageTip("不能输入低于10的数字")
	end
end

function CBGGoldDlg:handleSellPriceInputChanged(num)
	if num then
		local maxVal = 10000
		if num > maxVal then
			self.sellprice:setText(maxVal)
			GetCTipsManager():AddMessageTip('最大值不能高于10000')
			return
		end

		self.sellprice:setText(num)
	else
		self.sellprice:setText("")
	end
	if self.sellprice:getText() == "" then
		self.taxfee:setText("0")
	else
		local fee = math.floor(tonumber(self.sellprice:getText()) * 0.2)
		self.taxfee:setText(tostring(fee))
	end
end

function CBGGoldDlg:handleTabBtnClicked(args)
	local eventargs = CEGUI.toWindowEventArgs(args)
	local id = eventargs.window:getID()
	if id == 1 then
		self.buttons[1]:SetPushState(true)
		return
	elseif id == 2 then
		self:DestroyDialog()
		require "logic.blackmarket.cbgitemdlg".getInstanceAndShow()
		return
	elseif id == 3 then
		self:DestroyDialog()
		require "logic.blackmarket.cbgrole".getInstanceAndShow()
		return
	end
end

return CBGGoldDlg
