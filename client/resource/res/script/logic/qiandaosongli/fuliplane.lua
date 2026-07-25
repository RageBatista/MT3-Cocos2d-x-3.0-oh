require "logic.dialog"
require "utils.commonutil"
require "logic.shop.ccnewgoodscell"
require "manager.currencymanager"

fuliplane = {}
setmetatable(fuliplane, Dialog)
fuliplane.__index = fuliplane
fuliplane.systemId =
{
    luandou = 1,
    shizhuang = 2,
    zhuangbei = 3,
    chongwu = 4,
}

local _instance

function fuliplane:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, fuliplane)
	return self
end

function fuliplane.getInstance(parent)
    if not _instance then
        _instance = fuliplane:new()
        _instance:OnCreate(parent)
    end
    
    return _instance
end

function fuliplane.getInstanceAndShow(parent)
    if not _instance then
        _instance = fuliplane:new()
        _instance:OnCreate(parent)
    else

    end
    _instance:SetVisible(true)
    return _instance
end


function fuliplane.getInstanceNotCreate()
	return _instance
end

function fuliplane.DestroyDialog()
	if _instance then 
	_instance.minusBtn.animation:stop()
	_instance.addBtn.animation:stop()
	_instance.buyBtn.animation:stop()
		CurrencyManager.unregisterTextWidget(_instance.ownMoneyText)
		if _instance.goodsTableView then
			_instance.goodsTableView:destroyCells()
		end
		if _instance.animationInstance then 
            _instance.animationInstance:stop()
            _instance.animationInstance = nil 
        end
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end
function fuliplane.ToggleOpenClose()
	if not _instance then
		_instance = fuliplane:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function fuliplane.GetLayoutFileName()
	return "fuliplane.layout"
end

function fuliplane:addButtonAnimation(button, animationName)
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

function fuliplane:OnCreate(parent)
    Dialog.OnCreate(self, parent)
	local winMgr = CEGUI.WindowManager:getSingleton()
	
	self.basewindow = CEGUI.toPushButton(winMgr:getWindow("fuliplane"))
	
    self.cc_duihuan = winMgr:getWindow("fuliplane/ccck1")
	

    local aniMan = CEGUI.AnimationManager:getSingleton()
    local animationOpen = aniMan:getAnimation("neidanhc") 
    self.animationInstance = aniMan:instantiateAnimation(animationOpen) 
    self.animationInstance:setTargetWindow(self.cc_duihuan)
    self.animationInstance:start()
	
	self.mapSysBtn = { }
	self.scrollPanel = CEGUI.toScrollablePane(winMgr:getWindow("fuliplane/liebiaodi/liebiao"))
	self.scrollPanel:EnableHorzScrollBar(true)
	self.awardPanel = CEGUI.toScrollablePane(winMgr:getWindow("fuliplane/reawardplane"))
	self.panelRightBg = winMgr:getWindow("fuliplane/neirong")
	self.btnPlane = winMgr:getWindow("fuliplane/neirongdi/btnplane")
	self.btnPlane:setVisible(false)
	self.totalPriceText = winMgr:getWindow("fuliplane/textzong")
	self.currencyIcon1 = winMgr:getWindow("fuliplane/textzong/yinbi1")
	self.ownMoneyText = winMgr:getWindow("fuliplane/textdan")
	self.currencyIcon2 = winMgr:getWindow("fuliplane/textzong/yinbi2")
	self.TitleText = winMgr:getWindow("fuliplane/Text")
	

	self.buyBtn = CEGUI.toPushButton(winMgr:getWindow("fuliplane/btngoumai"))
	self:addButtonAnimation(self.buyBtn, "studyBtnPress")
	
	self.refreshBtn = CEGUI.toPushButton(winMgr:getWindow("fuliplane/refresh"))
	--self.buyNumBg = winMgr:getWindow("fuliplane/shurukuang")
	self.buyNumText = winMgr:getWindow("fuliplane/shurukuang/numtext")
	
	self.addBtn = CEGUI.toPushButton(winMgr:getWindow("fuliplane/jiahao"))
	self:addButtonAnimation(self.addBtn, "studyBtnPress")
	
	self.minusBtn = CEGUI.toPushButton(winMgr:getWindow("fuliplane/btnjianhao"))
	self:addButtonAnimation(self.minusBtn, "studyBtnPress")
	
    self.itemNameText = winMgr:getWindow("fuliplane/ccck1/cczhyc1/name")
    self.itemmiaoshu = CEGUI.toRichEditbox(winMgr:getWindow("fuliplane/ccck1/cczhyc1/ccy1"))
	local send = require "protodef.fire.pb.game.cgetrecharge":new()
	require "manager.luaprotocolmanager":send(send)
	self.dayawardMap={}
	self.type = 0
	self.minusBtn:subscribeEvent("Clicked", fuliplane.handleMinusBuyNumClicked, self)
	self.addBtn:subscribeEvent("Clicked", fuliplane.handleAddBuyNumClicked, self)
	--self.buyNumBg:subscribeEvent("MouseClick", fuliplane.handleBuyNumClicked, self)
	self.buyBtn:subscribeEvent("Clicked", fuliplane.handleBuyClicked, self)
	self.refreshBtn:subscribeEvent("Clicked", fuliplane.handlerefreshClicked, self)
	self:inileftBtn()
	self.m_listCell = {}
end

function fuliplane:inileftBtn()--初始化按钮
    local winMgr = CEGUI.WindowManager:getSingleton()
    local tableAllId = BeanConfigManager.getInstance():GetTableByName("fushi.cfulisystembtnshow"):getAllID()
    local startX = 1  -- 设置起始 x 坐标
    local space = 10   -- 设置按钮之间的间距
    for _, v in pairs(tableAllId) do
      local bthInfo =BeanConfigManager.getInstance():GetTableByName("fushi.cfulisystembtnshow"):getRecorder(v)
      local btnw = 180
        local btnh = 55
        local btn = CEGUI.toGroupButton(winMgr:createWindow("TaharezLook/GroupButtontj"))
        btn:setGroupID(0)
        btn:setProperty("Font", "simhei-12")
        btn:setID(v)
        btn:setText(bthInfo.systemname)
        btn:setSize(CEGUI.UVector2(CEGUI.UDim(0, btnw), CEGUI.UDim(0, btnh)))
        btn:EnableClickAni(false)
        local img = winMgr:createWindow("TaharezLook/StaticImage")
        img:setProperty("Image", bthInfo.btnimage)
        img:setMousePassThroughEnabled(true)
        img:setAlwaysOnTop(true)
        img:setSize(CEGUI.UVector2(CEGUI.UDim(0, 30), CEGUI.UDim(0, 30)))
        img:setPosition(CEGUI.UVector2(CEGUI.UDim(0, 20), CEGUI.UDim(0,13)))
        img:setVisible(true)
        btn:addChildWindow(img)
        self.scrollPanel:addChildWindow(btn)
        -- 修改按钮位置
        btn:setPosition(CEGUI.UVector2(CEGUI.UDim(0, startX + (v-1) * (btnw + space)), CEGUI.UDim(0, 0)))
        btn:subscribeEvent("SelectStateChanged", fuliplane.handleScoreGroupBtnClicked, self)
        self.mapSysBtn[v] = btn	
    end
    self.mapSysBtn[1]:setSelected(true)
    self:initplane()
end

function fuliplane:handleScoreGroupBtnClicked(args)--按钮事件
    local nSysId = CEGUI.toWindowEventArgs(args).window:getID()
	local showinfo =BeanConfigManager.getInstance():GetTableByName("fushi.cfulisystembtnshow"):getRecorder(nSysId)
	self:GetWindow():setText(showinfo.btnimage)
	self:clearplanecell()
	self:createDlg(nSysId)

end

function fuliplane:initplane()
	local showinfo =BeanConfigManager.getInstance():GetTableByName("fushi.cfulisystembtnshow"):getRecorder(1)
	self:GetWindow():setText(showinfo.btnimage)
	self:clearplanecell()
	self:createDlg(1)
end
function fuliplane:clearplanecell()--清理界面上的cell
	if self.goodsTableView then
		self.goodsTableView:destroyCells()
	end
	if not self.m_listCell then
        return
    end
    for i,v in pairs(self.m_listCell) do
		v:OnClose()
	end
	self.m_listCell={}
	if self.TitleText:isVisible() then
		self.TitleText:setVisible(false)
	end
	if self.btnPlane:isVisible() then
		self.btnPlane:setVisible(false)
	end
	if self.refreshBtn:isVisible() then
		self.refreshBtn:setVisible(false)
	end
	if self.awardPanel:isVisible() then
		self.awardPanel:setVisible(false)
	end
	if self.panelRightBg:isVisible() then
		self.panelRightBg:setVisible(false)
	end
end

function fuliplane:setShopType(shopType)--设置当前页面的商品
	self.panelRightBg:setVisible(true)
	local conf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cnpcsale")):getRecorder(shopType)
	if not conf then
		return
	end
	self.saleConf = conf
	self.goodsIds = {}
	local rolelv = gGetDataManager():GetMainCharacterLevel()
	local n = 0
	for i=0, conf.goodsids:size()-1 do
		local goodsConf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cgoods")):getRecorder(conf.goodsids[i])
		if goodsConf.limitLookLv <= rolelv then 
			self.goodsIds[n] = conf.goodsids[i]
			n = n+1
		end
	end
	
	--self.itemNameText:setText(conf.shopName)
	
	CurrencyManager.setCurrencyIcon(conf.currency, self.currencyIcon1)
	CurrencyManager.setCurrencyIcon(conf.currency, self.currencyIcon2)
	CurrencyManager.registerTextWidget(conf.currency, self.ownMoneyText)
	self.selectedCellIdx = 0
	self.currencyType = conf.currency
	
	local s = self.panelRightBg:getPixelSize()
	self.goodsTableView = TableView.create(self.panelRightBg)
	self.goodsTableView:setViewSize(s.width-25, s.height-20)
	self.goodsTableView:setPosition(10, 10)
	self.goodsTableView:setColumCount(2)
    self.goodsTableView:setCellInterval(5, 5)
	self.goodsTableView:setCellCount(TableUtil.tablelength(self.goodsIds))
	self.goodsTableView:setDataSourceFunc(self, fuliplane.tableViewGetCellAtIndex)
	self.goodsTableView:reloadData()
	self.btnPlane:setVisible(true)
	self:refreshSelectedGoods()

end
function fuliplane:refreshSelectedGoods()--刷新选中的商品
	local goodsId = self.goodsIds[self.selectedCellIdx]
	self.curGoodsconf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cgoods")):getRecorder(goodsId)
	if self.curGoodsconf then
		self.buyNumText:setText(1)
		self.totalPriceText:setText(MoneyFormat(self.curGoodsconf.prices[0]))
	end
	self.itemNameText:setText(self.curGoodsconf.name)
	self.itemmiaoshu:Clear()
	local ceguiString = CEGUI.String(self.curGoodsconf.des)
	self.itemmiaoshu:AppendParseText(ceguiString)
	self.itemmiaoshu:Refresh() 	
end
function fuliplane:tableViewGetCellAtIndex(tableView, idx, cell)--插入cell
	if not cell then
		cell = CcnewGoodsCell.CreateNewDlg(tableView.container)
		cell.window:subscribeEvent("MouseClick", fuliplane.handleGoodsCellClicked, self)
        cell.itemCell:subscribeEvent("MouseClick", fuliplane.handleGoodsItemCellClicked, self)
	end
	cell:setGoodsDataById(self.goodsIds[idx])
	cell.window:setID(idx)
	cell.window:setSelected( self.selectedCellIdx == idx )
	cell:showRequireCornerImage( self.requireGoodsCellIdx == idx )
	return cell
end
function fuliplane:handleGoodsCellClicked(args)--点击cell
	LogInfo("----------")
	local idx = CEGUI.toWindowEventArgs(args).window:getID()
	if self.selectedCellIdx == idx then
		self:handleAddBuyNumClicked()
	else
		self.selectedCellIdx = idx
		self:refreshSelectedGoods()
	end
end
function fuliplane:handleGoodsItemCellClicked(args)--点击显示详情
    GameItemTable.HandleShowToolTipsWithItemID(args)

    local cell = CEGUI.toGroupButton(CEGUI.toWindowEventArgs(args).window:getParent())
    if cell then
        cell:setSelected(true)

        local idx = cell:getID()
        if self.selectedCellIdx == idx then
		    self:handleAddBuyNumClicked()
	    else
		    self.selectedCellIdx = idx
		    self:refreshSelectedGoods()
	    end
    end
end
function fuliplane:handleBuyNumClicked(args)--小键盘
	
	if NumKeyboardDlg.getInstanceNotCreate() then
		NumKeyboardDlg.getInstanceNotCreate():SetVisible(true) --���ּ�����������
		return
	end
	
	local dlg = NumKeyboardDlg.getInstanceAndShow()
	if dlg then
		dlg:setTriggerBtn(self.buyNumBg)
		dlg:setMaxValue(99)
		dlg:setInputChangeCallFunc(fuliplane.onNumInputChanged, self)
		
		local p = self.buyNumBg:GetScreenPos()
		local s = self.buyNumBg:getPixelSize()
		SetPositionOffset(dlg:GetWindow(), p.x+s.width*0.5, p.y-20, 0.5, 1)
	end
end
function fuliplane:onNumInputChanged(num)--小键盘
	if num == 0 then
		self.buyNumText:setText(1)
		self.totalPriceText:setText(MoneyFormat(self.curGoodsconf.prices[0]))
	else
		self.buyNumText:setText(num)
		self.totalPriceText:setText(MoneyFormat(self.curGoodsconf.prices[0] * num))
	end

    CurrencyManager.setCompareTextWidget(self.ownMoneyText, self.totalPriceText)
end
function fuliplane:handleMinusBuyNumClicked(args)--减号
	local num = tonumber(self.buyNumText:getText())
	if num > 1 then
		self.buyNumText:setText(num-1)
		self.totalPriceText:setText(MoneyFormat(self.curGoodsconf.prices[0] * (num-1)))
		CurrencyManager.setCompareTextWidget(self.ownMoneyText, self.totalPriceText)
	end
end

function fuliplane:handleAddBuyNumClicked(args)--加号
	local num = tonumber(self.buyNumText:getText())
	if num < 99 then
		self.buyNumText:setText(num+1)
		self.totalPriceText:setText(MoneyFormat(self.curGoodsconf.prices[0] * (num+1)))
		CurrencyManager.setCompareTextWidget(self.ownMoneyText, self.totalPriceText)
	end
end

function fuliplane:handleBuyClicked(args)

    if not CurrencyManager.checkRoleLevel(self.goodsIds[self.selectedCellIdx], true) then
        return
    end
    
    local conf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cgoods")):getRecorder(self.goodsIds[self.selectedCellIdx])

    if not CheckBagCapacityForItem(conf.itemId, tonumber(self.buyNumText:getText())) then
        GetCTipsManager():AddMessageTipById(160062) 
        return
    end
    
    local p = require("protodef.fire.pb.shop.cbuynpcshop").Create()
    p.shopid = self.saleConf.id
    p.goodsid = self.goodsIds[self.selectedCellIdx]
    p.num = tonumber(self.buyNumText:getText())
    p.buytype = fire.pb.shop.ShopBuyType.NORMAL_SHOP
    
    local totalprice = MoneyNumber(self.totalPriceText:getText())
    local needMoney = totalprice - MoneyNumber(self.ownMoneyText:getText())
    if needMoney > 0 then
        -- 货币不足
        CurrencyManager.handleCurrencyNotEnough(self.currencyType, needMoney, totalprice, p, self.ownMoneyText)
        GetCTipsManager():AddMessageTipById(193519) -- 货币不足提示
    else
        -- 兑换成功
        LuaProtocolManager:send(p)
       -- GetCTipsManager():AddMessageTipById(193520) -- 兑换成功提示
        self:refreshSelectedGoods()
    end
end

function fuliplane:createDlg(nSysId)--根据类型显示信息
    if nSysId == fuliplane.systemId.luandou then
		self.buyBtn:setText("购  买")
        self:setShopType(19)
    elseif nSysId == fuliplane.systemId.shizhuang then
		self.buyBtn:setText("购  买")
		self:setShopType(20)
    elseif nSysId == fuliplane.systemId.zhuangbei then
		self.buyBtn:setText("购  买")
		self:setShopType(21)
    elseif nSysId == fuliplane.systemId.chongwu then
		self.buyBtn:setText("购  买")
		self:setShopType(22)
    end
end

function fuliplane:handlerefreshClicked()
	local yuanbaonum = gGetDataManager():GetYuanBaoNumber()
	if yuanbaonum < 500000 then
		GetChatManager():AddTipsMsg(191255);
		return
	end
	local function onConfirm(self, args)
		gGetMessageManager():CloseCurrentShowMessageBox()

		require "protodef.fire.pb.game.crefreshdayaward";
		local CRefreshDayAward = CRefreshDayAward.Create();
		LuaProtocolManager.getInstance():send(CRefreshDayAward);
		return true
	end

	local function onCancel(self, args)
		if CEGUI.toWindowEventArgs(args).handled ~= 1 then
			gGetMessageManager():CloseCurrentShowMessageBox()
		end
	end

	if gGetMessageManager() then
		gGetMessageManager():AddMessageBox(
				"", MHSD_UTILS.get_msgtipstring(191256),
				onConfirm, self, onCancel, self,
				eMsgType_Normal, 30000, 0, 0, nil,
				MHSD_UTILS.get_resstring(2037),
				MHSD_UTILS.get_resstring(2038))
	end
end

function fuliplane:setDayInfo(id)
	self.awardPanel:setVisible(true)
	local itemDayTable = self:getAwardInfo(id)
	self.type=id
	for index, value in ipairs(itemDayTable) do
		local cellclass =  require "logic.qiandaosongli.fulidayreawardcell"
		local cell = cellclass.CreateNewDlg(self.awardPanel)
		local x = CEGUI.UDim(0, 5)
		local y = CEGUI.UDim(0, cell:GetWindow():getPixelSize().height*(index-1) + (index - 1)*8)
		local pos = CEGUI.UVector2(x,y)
		cell:GetWindow():setPosition(pos)
		cell:setId(value)
		local flag = self.dayawardMap[value]
		if flag == nil then
			flag = -1
		end
		cell:setFlag(flag)
		cell:settype(id)
		cell:setItemInfo()
		table.insert(self.m_listCell, cell )
	end
end
function fuliplane:getAwardInfo(id)
	if id == 1 then
		self.dayawardMap = LoginRewardManager.getInstance():GetDayReawardMap()
	    return	BeanConfigManager.getInstance():GetTableByName("game.cdayreaward"):getAllID()
	end
	if id == 2 then
		return	BeanConfigManager.getInstance():GetTableByName("game.conepayaward"):getAllID()
	end
	if id == 3 then
		self.dayawardMap = LoginRewardManager.getInstance():GetTotalReawardMap()
	    return	BeanConfigManager.getInstance():GetTableByName("game.ctotalreaward"):getAllID()
	end
end
function fuliplane:UpdateCellData()
	if self.type == 1 then
		self.dayawardMap = LoginRewardManager.getInstance():GetDayReawardMap()
	end
	if self.type == 3 then
		self.dayawardMap = LoginRewardManager.getInstance():GetTotalReawardMap()
	end
	
	for i , v in pairs( self.m_listCell ) do
		local flag = self.dayawardMap[v:getId()]
		if flag ==nil then
			flag=-1
		end
		v:setFlag(flag)
		v:setItemInfo()
	end
end
function fuliplane:UpdateTitleText()
	self.DestroyDialog()
end
return fuliplane