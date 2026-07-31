------------------------------------------------------------------
-- �̳�
------------------------------------------------------------------
require "logic.dialog"
require "logic.shop.goodscell"
require "manager.currencymanager"

local XIXIAN		= 1	--��������
local STRENGTHEN	= 2	--ǿ������
local XIANGOU		= 3 --ÿ���޹�
local VIPSHANGCHENG		= 4 --ÿ���޹�
local XIXIAN		= 5	--��������
local STRENGTHEN	= 6	--ǿ������
local XIANGOU		= 7 --ÿ���޹�
local VIPSHANGCHENG		= 8 --ÿ���޹�
local XIANGOU		= 9 --ÿ���޹�
local VIPSHANGCHENG		= 10 --ÿ���޹�

MallShop = {}
setmetatable(MallShop, Dialog)
MallShop.__index = MallShop

local _instance
function MallShop.getInstance()
	if not _instance then
		_instance = MallShop:new()
		_instance:OnCreate()
	end
	return _instance
end

function MallShop.getInstanceAndShow()
	if not _instance then
		_instance = MallShop:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function MallShop.getInstanceNotCreate()
	return _instance
end

function MallShop.DestroyDialog()
	if _instance then 
	if _instance.textScrollAnimation then
            _instance.textScrollAnimation:stop() 
        end
        if _instance.textScrollAnimation1 then
            _instance.textScrollAnimation1:stop()
        end
		CurrencyManager.unregisterTextWidget(_instance.ownMoneyText)
		_instance.goodsTable:destroyCells()
		Dialog.OnClose(_instance)
		if not _instance.m_bCloseIsHide then
			_instance = nil
		end
	end
end

function MallShop.ToggleOpenClose()
	if not _instance then
		_instance = MallShop:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function MallShop.GetLayoutFileName()
	return "npcshopshangcheng_mtg.layout"
end

function MallShop:SetVisible(b)
    if b == false then
        local Taskmanager = require("logic.task.taskmanager")
        Taskmanager.getInstance():setTaskOpenShopType(-1)
        self.buySuccessDlg:setVisible(false)
    end

	if self:IsVisible() ~= b then
        if b then
            local currencyType = self.curCurrencyType or self.defaultCurrency
            CurrencyManager.registerTextWidget(currencyType, self.ownMoneyText)

		    self:refreshTimeLeft()
        else
            CurrencyManager.unregisterTextWidget(self.ownMoneyText)
	    end
    end
	Dialog.SetVisible(self, b)
end

function MallShop:hideRequireGoods()
	if self.requireGoodsId then
		if self.goodsTable then
			for _,v in pairs(self.goodsTable.visibleCells) do
				if v.goodsid == self.requireGoodsId then
					v:showRequireCornerImage(false)
					break
				end
			end
		end
		self.requireGoodsId = nil
	end
end

function MallShop:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, MallShop)
	return self
end

function MallShop:OnCreate()
	Dialog.OnCreate(self)
	SetPositionOfWindowWithLabel1(self:GetWindow())
	local winMgr = CEGUI.WindowManager:getSingleton()
    local scrollPane = CEGUI.Window.toScrollablePane(winMgr:getWindow("npcshopshangcheng_mtg/cchdck"))
	self.listBg = winMgr:getWindow("npcshopshangcheng_mtg/textbg")
	self.unchooseBg = winMgr:getWindow("npcshopshangcheng_mtg/textbg2/unchoosebg")
	self.detailBg = winMgr:getWindow("npcshopshangcheng_mtg/textbg2/detailBg")
	self.zhekouBg = winMgr:getWindow("npcshopshangcheng_mtg/textbg2/writebg")
	self.currencyIcon1 = winMgr:getWindow("npcshopshangcheng_mtg/textbg2/writebg/yin")
	self.oldPriceText = winMgr:getWindow("npcshopshangcheng_mtg/textbg2/writebg/yuanjiatext")
	self.redline = winMgr:getWindow("npcshopshangcheng_mtg/textbg2/writebg/yuanjiatext/redline")
	self.currencyIcon2 = winMgr:getWindow("npcshopshangcheng_mtg/textbg2/writebg/yin2")
	self.nowPriceText = winMgr:getWindow("npcshopshangcheng_mtg/textbg2/writebg1/yuanjiatext1")
	self.zhoukouValue = winMgr:getWindow("npcshopshangcheng_mtg/textbg2/imagejiangjia/6zhe")
	self.detailText = CEGUI.toRichEditbox(winMgr:getWindow("npcshopshangcheng_mtg/textbg2/detailBg/detailText"))
	self.curGoodsName = winMgr:getWindow("npcshopshangcheng_mtg/textbg2/detailBg/curgoodsname")
	self.minusBtn = CEGUI.toPushButton(winMgr:getWindow("npcshopshangcheng_mtg/btnjianhao"))
	self.buyNumText = winMgr:getWindow("npcshopshangcheng_mtg/shurukuang/buynum")
	self.addBtn = CEGUI.toPushButton(winMgr:getWindow("npcshopshangcheng_mtg/jiahao"))
	self.priceText = winMgr:getWindow("npcshopshangcheng_mtg/textzong")
	self.priceText:setProperty("TextColours", "FFFFFFFF")
	self.currencyIcon3 = winMgr:getWindow("npcshopshangcheng_mtg/textzong/yinbi1")
	self.ownMoneyText = winMgr:getWindow("npcshopshangcheng_mtg/textdan")
	self.ownMoneyText:setProperty("TextColours", "FFFFFFFF")
	self.currencyIcon4 = winMgr:getWindow("npcshopshangcheng_mtg/textzong/yinbi2")
	self.buyBtn = CEGUI.toPushButton(winMgr:getWindow("npcshopshangcheng_mtg/btngoumai"))
	self.groupBtn1 = CEGUI.toGroupButton(winMgr:getWindow("npcshopshangcheng_mtg/ccbtn1"))
	self.groupBtn2 = CEGUI.toGroupButton(winMgr:getWindow("npcshopshangcheng_mtg/ccbtn2"))
	self.groupBtn3 = CEGUI.toGroupButton(winMgr:getWindow("npcshopshangcheng_mtg/ccbtn3"))
	self.groupBtn4 = CEGUI.toGroupButton(winMgr:getWindow("npcshopshangcheng_mtg/ccbtn4"))
	self.groupBtn5 = CEGUI.toGroupButton(winMgr:getWindow("npcshopshangcheng_mtg/ccbtn5"))
	self.groupBtn6 = CEGUI.toGroupButton(winMgr:getWindow("npcshopshangcheng_mtg/ccbtn6"))
	self.groupBtn7 = CEGUI.toGroupButton(winMgr:getWindow("npcshopshangcheng_mtg/ccbtn7"))
	self.groupBtn8 = CEGUI.toGroupButton(winMgr:getWindow("npcshopshangcheng_mtg/ccbtn8"))
	self.groupBtn9 = CEGUI.toGroupButton(winMgr:getWindow("npcshopshangcheng_mtg/ccbtn9"))
	self.groupBtn10 = CEGUI.toGroupButton(winMgr:getWindow("npcshopshangcheng_mtg/ccbtn10"))
	self.groupBtn11 = CEGUI.toGroupButton(winMgr:getWindow("npcshopshangcheng_mtg/ccbtn11"))
	self.groupBtn12 = CEGUI.toGroupButton(winMgr:getWindow("npcshopshangcheng_mtg/ccbtn12"))
	self.timeLeft1 = winMgr:getWindow("npcshopshangcheng_mtg/texthuodong")
	self.timeLeft2 = winMgr:getWindow("npcshopshangcheng_mtg/texttime")
    self.buySuccessDlg = winMgr:getWindow("npcshopshangcheng_mtg/chenggong")
	self.buySuccessDes = winMgr:getWindow("npcshopshangcheng_mtg/chenggong/wenben")

	
	self.shanchengText = CEGUI.toRichEditbox(winMgr:getWindow("npcshopshangcheng_mtg/shangchengts"))
	self.shanchengText:Clear()
    self.shanchengText:AppendParseText(CEGUI.String(MHSD_UTILS.get_resstring(7403)))
    self.shanchengText:Refresh() 
	
	local animationDefcc1 = CEGUI.AnimationManager:getSingleton():getAnimation("shangchenggundong1")
    self.textScrollAnimation = CEGUI.AnimationManager:getSingleton():instantiateAnimation(animationDefcc1)
    self.textScrollAnimation:setTargetWindow(self.shanchengText)
    self.textScrollAnimation:start()
    
	
	local animationDefcc2 = CEGUI.AnimationManager:getSingleton():getAnimation("shangchenggundong2")
    self.textScrollAnimation1 = CEGUI.AnimationManager:getSingleton():instantiateAnimation(animationDefcc2)
    self.textScrollAnimation1:setTargetWindow(self.shanchengText) 
	
	
    self.shanchengText:subscribeEvent(
        "AnimationEnded", 
        function(args)
            self.textScrollAnimation1:start() 
        end
    )
	

    self.lastOffset = {}
    self.lastSelectedType = 1

	self.minusBtn:subscribeEvent("Clicked", MallShop.handleMinusClicked, self)
	self.addBtn:subscribeEvent("Clicked", MallShop.handleAddClicked, self)
	self.groupBtn1:subscribeEvent("SelectStateChanged", MallShop.handleGroupBtnClicked, self)
	self.groupBtn2:subscribeEvent("SelectStateChanged", MallShop.handleGroupBtnClicked, self)
	self.groupBtn3:subscribeEvent("SelectStateChanged", MallShop.handleGroupBtnClicked, self)
	self.groupBtn4:subscribeEvent("SelectStateChanged", MallShop.handleGroupBtnClicked, self)
	self.groupBtn5:subscribeEvent("SelectStateChanged", MallShop.handleGroupBtnClicked, self)
	self.groupBtn6:subscribeEvent("SelectStateChanged", MallShop.handleGroupBtnClicked, self)
	self.groupBtn7:subscribeEvent("SelectStateChanged", MallShop.handleGroupBtnClicked, self)
	self.groupBtn8:subscribeEvent("SelectStateChanged", MallShop.handleGroupBtnClicked, self)
	self.groupBtn9:subscribeEvent("SelectStateChanged", MallShop.handleGroupBtnClicked, self)
	self.groupBtn10:subscribeEvent("SelectStateChanged", MallShop.handleGroupBtnClicked, self)
	self.groupBtn11:subscribeEvent("SelectStateChanged", MallShop.handleGroupBtnClicked, self)
	self.groupBtn12:subscribeEvent("SelectStateChanged", MallShop.handleGroupBtnClicked, self)
	
	
	
	self.buyBtn:subscribeEvent("Clicked", MallShop.handleBuyClicked, self)
	self.buyNumText:subscribeEvent("MouseClick", MallShop.handleBuyNumClicked, self)
	
	self:addButtonAnimation(self.addBtn, "studyBtnPress")
    self:addButtonAnimation(self.buyBtn, "studyBtnPress")
    self:addButtonAnimation(self.minusBtn, "studyBtnPress")
	
	scrollPane:addChildWindow(self.groupBtn1)
    scrollPane:addChildWindow(self.groupBtn2)
    scrollPane:addChildWindow(self.groupBtn3)
    scrollPane:addChildWindow(self.groupBtn4)
    scrollPane:addChildWindow(self.groupBtn5)
    scrollPane:addChildWindow(self.groupBtn6)
    scrollPane:addChildWindow(self.groupBtn7)
	scrollPane:addChildWindow(self.groupBtn8)
	scrollPane:addChildWindow(self.groupBtn9)
	scrollPane:addChildWindow(self.groupBtn10)
	scrollPane:addChildWindow(self.groupBtn11)
	scrollPane:addChildWindow(self.groupBtn12)

	
	self:GetCloseBtn():removeEvent("Clicked")
	self:GetCloseBtn():subscribeEvent("Clicked", ShopLabel.hide, nil)

    self.buySuccessDlg:setVisible(false)
    self.buySuccessStr = self.buySuccessDes:getText()
    self.elapsed = 0
	
	

    local tabNameTable = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cmallshoptabname"))
    if tabNameTable then
        if tabNameTable:getSize() < 12 then
            for i=tabNameTable:getSize()+1, 12 do
                self["groupBtn" .. i]:setVisible(false)
                self["groupBtn" .. i]:setID(0)
            end
        end

        for i,id in ipairs(tabNameTable:getAllID()) do
            local conf = tabNameTable:getRecorder(id)
            self["groupBtn" .. i]:setText(conf.tabname)
            self["groupBtn" .. i]:setID(id)
        end
    else
        self.groupBtn1:setID(1)
	    self.groupBtn2:setID(2)
	    self.groupBtn3:setID(3)
	    self.groupBtn4:setID(4)
		self.groupBtn5:setID(5)
	    self.groupBtn6:setID(6)
	    self.groupBtn7:setID(7)
	    self.groupBtn8:setID(8)
		self.groupBtn9:setID(9)
	    self.groupBtn10:setID(10)
		self.groupBtn11:setID(11)
		self.groupBtn12:setID(12)
    end
	
	self.detailBg:setVisible(false)
    self.detailTextMinH = self.detailText:getPixelSize().height
    self.detailTextMaxH = self.detailTextMinH + self.zhekouBg:getPixelSize().height

    local s = self.listBg:getPixelSize()
	self.goodsTable = TableView.create(self.listBg)
	self.goodsTable:setViewSize(s.width-20, s.height-20)
	self.goodsTable:setPosition(10, 10)
	self.goodsTable:setColumCount(3)
	self.goodsTable:setCellInterval(5, 5)
	self.goodsTable:setDataSourceFunc(self, MallShop.tableViewGetCellAtIndex)
    self.cellWidth = (s.width-32-5*2)/3
	
    local conf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cnpcsale")):getRecorder(SHOP_TYPE.MALL)
    self.defaultCurrency = conf.currency

	self:loadMallShopTable()
	
	self.curGoodsType = 0

	if self.groupBtn1:isVisible() then
	    self.groupBtn1:setSelected(true)----商城打开默认第一个按钮位置
    else
        self.groupBtn1:setSelected(true)
    end
	
	self:refreshTimeLeft()


end


function MallShop:addButtonAnimation(button, animationName)
    local animationDef = CEGUI.AnimationManager:getSingleton():getAnimation(animationName)
    if animationDef then
        local animation = CEGUI.AnimationManager:getSingleton():instantiateAnimation(animationDef)
        animation:setTargetWindow(button)
        animation:setSpeed(0.7)  -- 设置动画播放速度
        button:subscribeEvent("MouseButtonDown", function()
            animation:start()
        end, self)
    end
end



function MallShop:selectGoodsByItemid(itemid, num)
	num = (num and math.max(num, 1) or 1)
	
	--k: group btn type
	for k,v in pairs(self.mallShopTable) do
		
		--i: goods idx
		for i, v1 in pairs(v) do
			local goods = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cgoods")):getRecorder(v1.id)
			
			if goods.itemId == itemid then
				local groupBtn = self["groupBtn" .. k]
				groupBtn:setSelected(true)
				local cell = self.goodsTable:focusCellAtIdx(i-1)
				if cell then
					cell.window:setSelected(true)
					cell:showRequireCornerImage(true)
					self.requireGoodsId = goods.id
					self.selectedGoodsId = goods.id
					self:refreshGoodsDetail()
					
					self.buyNumText:setText(num)
					self.priceText:setText(MoneyFormat(self.curGoodsPrice * num))
					CurrencyManager.setCompareTextWidget(self.ownMoneyText, self.priceText)
				end
				return
			end
		end
	end
end

function MallShop:loadMallShopTable()
	self.mallShopTable = {}
	local ids = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cmallshop")):getAllID()
	local rolelv = gGetDataManager():GetMainCharacterLevel()
	for _,id in pairs(ids) do
		local goodsConf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cgoods")):getRecorder(id)
		if goodsConf then
			if goodsConf.limitLookLv <= rolelv then --���ɼ��ȼ�����
				local conf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cmallshop")):getRecorder(id)
				self.mallShopTable[conf.type] = self.mallShopTable[conf.type] or {}
				table.insert(self.mallShopTable[conf.type], conf)
			end
		else
			print("[ERROR] ID in CMallShop but not in CGoods: " .. id)
		end
	end
	ids = nil

    --order
    for _,v in pairs(self.mallShopTable) do
        for i = 1, #v - 1 do
            for j = i+1, #v do
                if v[i].order > v[j].order then
                    v[i], v[j] = v[j], v[i]
                end
            end
        end
    end
end

function MallShop:resetData()
    if self.goodsTable then
        self.goodsTable:setContentOffset(0)
    end
    self.lastOffset = {}
end

--1.�������� 2.ǿ������ 3.ÿ���޹� 4.VIP�̳�
function MallShop:loadGoodsByType(goodsType)
	self.curGoodsType = goodsType
	
	if not ShopManager:checkNumLimit() then
		return
	end
	
	if not self.mallShopTable[goodsType] then
		return
	end
	
    local offset = 0
    local offpos = 0
    if self.goodsTable and self.lastOffset then
        offset = self.goodsTable:getContentOffset()
        self.lastOffset[self.lastSelectedType] = offset
        self.lastSelectedType = self.curGoodsType
    end

	if self.goodsTable and self.lastOffset then
        if self.lastOffset[ self.curGoodsType] then
            offpos = self.lastOffset[ self.curGoodsType]
        end
	end

	self.goodsTable:setCellCount(#self.mallShopTable[goodsType])
    self.goodsTable:setContentOffset(offpos)
    self.goodsTable:reloadData()
end

function MallShop:tableViewGetCellAtIndex(tableView, idx, cell)
	local conf = self.mallShopTable[self.curGoodsType][idx+1]
	if not cell then
		cell = GoodsCell.CreateNewDlg(tableView.container)
        cell.window:setWidth(CEGUI.UDim(0, self.cellWidth))
		cell.window:subscribeEvent("MouseClick", MallShop.handleGoodsCellClicked, self)
        cell.itemCell:subscribeEvent("MouseClick", MallShop.handleGoodsItemCellClicked, self)
		cell.window:setGroupID(1)
	end
	cell:setGoodsDataById(conf.id)
    local buyNum = ShopManager.goodsBuyNumLimit[conf.id]
    if buyNum then
        local num = self:getLimitNum(conf.id) - buyNum
        cell.itemCell:SetTextUnit(num > 1 and num or "")
    else
        cell.itemCell:SetTextUnit("")
    end
	cell.window:setID(conf.id)
	cell.window:setSelected( self.selectedGoodsId == conf.id )
	if self.requireGoodsId then
		cell:showRequireCornerImage( self.requireGoodsId == conf.id )
	end
	return cell
end

function MallShop:getLimitNum(goodsid)
    local conf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cgoods")):getRecorder(goodsid)
    if conf then
        if conf.limitType == 2 then --���޹�
            local vipLevel = gGetDataManager():GetVipLevel()
            local record = BeanConfigManager.getInstance():GetTableByName("fushi.cvipinfo"):getRecorder(vipLevel)
            if record then
                return conf.limitNum + record.limitnumber1
            end
        end
        return conf.limitNum
    end
    return 0
end

function MallShop:recvBuyNumChanged(goodslimits)
    for _, v in pairs(self.goodsTable.visibleCells) do
        local buyNum = ShopManager.goodsBuyNumLimit[v.goodsid]
        local limitNum = self:getLimitNum(v.goodsid)

        -- 💖💖💖  调用 setGoodsDataById 刷新商品信息 💖💖💖  
        v:setGoodsDataById(v.goodsid, buyNum)  

        if buyNum and limitNum > 0 then
            if buyNum >= limitNum then
                v:setCornerImage(GoodsCell.CORNER_IMG_EMP)
            end

            local num = limitNum - buyNum
            v.itemCell:SetTextUnit(num > 1 and num or "")
        end
    end

    local buyNum = ShopManager.goodsBuyNumLimit[self.selectedGoodsId]
    if buyNum then
        local limitNum = self:getLimitNum(self.selectedGoodsId)
        self.maxNum = limitNum - buyNum
    end
end

function MallShop:refreshGoodsDetail()
	if self.selectedGoodsId == 0 then
		self.unchooseBg:setVisible(true)
		self.detailBg:setVisible(false)
		return
	end
	self.unchooseBg:setVisible(false)
	self.detailBg:setVisible(true)

	local mallConf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cmallshop")):getRecorder(self.selectedGoodsId)
	local goodsConf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cgoods")):getRecorder(self.selectedGoodsId)

	-- ԭ���ּ�
	self.curGoodsName:setText(GetGoodsNameByItemId(goodsConf.type, goodsConf.itemId))
	if goodsConf.oldprices[0] ~= goodsConf.prices[0] then
		self.zhekouBg:setVisible(true)
		CurrencyManager.setCurrencyIcon(goodsConf.currencys[0], self.currencyIcon1)
		CurrencyManager.setCurrencyIcon(goodsConf.currencys[0], self.currencyIcon2)
		self.oldPriceText:setText(MoneyFormat(goodsConf.oldprices[0]))
		self.nowPriceText:setText(MoneyFormat(goodsConf.prices[0]))

		local str = self.oldPriceText:getText()
		local des = string.gsub(str, "%S", "_")
		self.redline:setText(des)

		self.zhoukouValue:setText(math.floor(goodsConf.prices[0] / goodsConf.oldprices[0] * 100) * 0.1)

        self.detailText:setHeight(CEGUI.UDim(0, self.detailTextMinH))
	else
		self.zhekouBg:setVisible(false)
        self.detailText:setHeight(CEGUI.UDim(0, self.detailTextMaxH))
	end

	CurrencyManager.setCurrencyIcon(goodsConf.currencys[0], self.currencyIcon3)
	CurrencyManager.setCurrencyIcon(goodsConf.currencys[0], self.currencyIcon4)

	self.curCurrencyType = goodsConf.currencys[0]
	self.curGoodsPrice = goodsConf.prices[0]
	self.buyNumText:setText(1)

	local price = goodsConf.prices[0] * tonumber(self.buyNumText:getText())
	self.priceText:setText(MoneyFormat(price))
	CurrencyManager.registerTextWidget(goodsConf.currencys[0], self.ownMoneyText)
	CurrencyManager.setCompareTextWidget(self.ownMoneyText, self.priceText)


	-- �޹�����
	if goodsConf.limitType ~= 0 then
        -- ����
        local limitNum = self:getLimitNum(self.selectedGoodsId)
	    local sb = require "utils.stringbuilder":new()
	    sb:Set("parameter", limitNum)
	    local strmsg = sb:GetString(goodsConf.des)
        sb:delete()
	    self.detailText:Clear()
        self.detailText:AppendParseText(CEGUI.String(strmsg))
	    self.detailText:Refresh()

        local buyNum = ShopManager.goodsBuyNumLimit[self.selectedGoodsId]
		if buyNum then
			self.maxNum = limitNum - buyNum
			print("mallshop buy maxnum", self.maxNum, limitNum, buyNum)
		else
			self.maxNum = 99
			self.reachBuyNumLimit = false
		end

		if buyNum and limitNum > 0 and buyNum >= limitNum then
			-- �ۿ�
			--[[self.minusBtn:setEnabled(false)
			self.addBtn:setEnabled(false)--]]
			self.reachBuyNumLimit = true
		else
			self.reachBuyNumLimit = false
		end
	else
        self.detailText:Clear()
        self.detailText:AppendParseText(CEGUI.String(goodsConf.des))
	    self.detailText:Refresh()

		self.maxNum = 99
		self.reachBuyNumLimit = false
	end
end

function MallShop:refreshTimeLeft()
	local t = os.date("*t", math.floor(gGetServerTime()*0.001))
	local day = 7 - (t.wday == 1 and 7 or t.wday - 1)
	local h = 24 - t.hour
	if h == 24 then
        day = day + 1
        h = 0
    end
	
	local str = ""
	if day > 0 then
		str = day .. MHSD_UTILS.get_resstring(317)
	end
	
	if h > 0 then
		str = str .. h .. MHSD_UTILS.get_resstring(318)
	end
	
	if day == 0 and h == 0 then
		str = 7 .. MHSD_UTILS.get_resstring(317)
	end
	
	if str ~= "" then
		self.timeLeft2:setText(str)
	else
		self.timeLeft1:setVisible(false)
		self.timeLeft2:setVisible(false)
	end
end

function MallShop:handleGoodsCellClicked(args)
	local id = CEGUI.toWindowEventArgs(args).window:getID()
	if self.selectedGoodsId == id then
		self:handleAddClicked()
	else
		self.selectedGoodsId = id
		self:refreshGoodsDetail()
        self.detailText:getVertScrollbar():setScrollPosition(0)
	end
end

function MallShop:handleGoodsItemCellClicked(args)
    local cell = CEGUI.toGroupButton(CEGUI.toWindowEventArgs(args).window:getParent())
    if cell then
        cell:setSelected(true)
        if cell:getID() ~= self.selectedGoodsId then
            self.selectedGoodsId = cell:getID()
            self:refreshGoodsDetail()
        end
    end

    GameItemTable.HandleShowToolTipsWithItemID(args)

    local goodsConf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cgoods")):getRecorder(self.selectedGoodsId)
    -- �޹�����
	if goodsConf.limitType ~= 0 then
        local commontipdlg = Commontipdlg.getInstanceNotCreate()

        -- ����
        local limitNum = self:getLimitNum(self.selectedGoodsId)
	    local sb = require "utils.stringbuilder":new()
	    sb:Set("parameter", limitNum)
	    local strmsg = sb:GetString(goodsConf.des)
        sb:delete()
        commontipdlg.richBox:AppendParseText(CEGUI.String(strmsg))
	    commontipdlg.richBox:Refresh()
        commontipdlg:RefreshSize(false)

        local pos = CEGUI.toWindowEventArgs(args).window:GetScreenPosOfCenter()
	    commontipdlg:RefreshPosCorrect(pos.x, pos.y)
    end
end

function MallShop:onNumInputChanged(num)
	if num == 0 then
		self.buyNumText:setText(1)
		self.priceText:setText(MoneyFormat(self.curGoodsPrice))
	else
		self.buyNumText:setText(num)
		self.priceText:setText(MoneyFormat(self.curGoodsPrice * num))
	end
	CurrencyManager.setCompareTextWidget(self.ownMoneyText, self.priceText)
end

function MallShop:handleMinusClicked(args)
	if self.selectedGoodsId == 0 then
		return
	end
	local num = tonumber(self.buyNumText:getText())
	if num > 1 then
		self.buyNumText:setText(num-1)
		self.priceText:setText(MoneyFormat(self.curGoodsPrice * (num-1)))
	end
	CurrencyManager.setCompareTextWidget(self.ownMoneyText, self.priceText)
end

function MallShop:handleAddClicked(args)
	if self.selectedGoodsId == 0 then
		return
	end
	local num = tonumber(self.buyNumText:getText())
	if num < self.maxNum then
		self.buyNumText:setText(num+1)
		self.priceText:setText(MoneyFormat(self.curGoodsPrice * (num+1)))
	end
	CurrencyManager.setCompareTextWidget(self.ownMoneyText, self.priceText)
end

function MallShop:handleBuyNumClicked(args)
	if self.selectedGoodsId == 0 or self.reachBuyNumLimit then
		return
	end
	if NumKeyboardDlg.getInstanceNotCreate() then
		NumKeyboardDlg.getInstanceNotCreate():SetVisible(true) --���ּ�����������
		return
	end
	
	local dlg = NumKeyboardDlg.getInstanceAndShow()
	if dlg then
		dlg:setTriggerBtn(self.buyNumText)
		dlg:setMaxValue(self.maxNum)
		dlg:setInputChangeCallFunc(MallShop.onNumInputChanged, self)
		
		local p = self.buyNumText:GetScreenPos()
		SetPositionOffset(dlg:GetWindow(), p.x-110, p.y-10, 0, 1)
	end
end

function MallShop:handleGroupBtnClicked(args)
	local id = CEGUI.toWindowEventArgs(args).window:getID()
	if id ~= self.curGoodsType then
		self.selectedGoodsId = 0
        self.curCurrencyType = nil
		self:refreshGoodsDetail()
		self:loadGoodsByType(id)
		
		self.zhekouBg:setVisible(false)
		self.buyNumText:setText(0)
		self.priceText:setText(0)
	--	self.priceText:setProperty("BorderEnable", "false")
		
		self.reachBuyNumLimit = false
		
		if id == XIANGOU then
			self.timeLeft1:setVisible(true)
			self.timeLeft2:setVisible(true)
			self:refreshTimeLeft()
		else
			self.timeLeft1:setVisible(false)
			self.timeLeft2:setVisible(false)
		end
		
		if CurrencyManager.getWidgetCurrencyType(self.ownMoneyText) ~= self.defaultCurrency then
			CurrencyManager.setCurrencyIcon(self.defaultCurrency, self.currencyIcon3)
			CurrencyManager.setCurrencyIcon(self.defaultCurrency, self.currencyIcon4)
			CurrencyManager.registerTextWidget(self.defaultCurrency, self.ownMoneyText) --��ʾĬ�ϵ��̳ǻ�������
		end
	end
end

function MallShop:handleBuyClicked(args)
	--test
	--[[self:selectGoodsByItemid(350006, 3)
	do return end--]]
	
	if self.selectedGoodsId == 0 then
		return
	end
	
	--�ۼƳ�ֵ����
	local mallConf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cmallshop")):getRecorder(self.selectedGoodsId)
    if IsPointCardServer() then
	    if mallConf.totalrecharge > gGetDataManager():GetTotalRechargeYuanBaoNumber() then
		    local str = MHSD_UTILS.get_msgtipstring(160012) --�ۼƳ�ֵxxx���ܹ���˵���
		    str = str:gsub("%$parameter1%$", mallConf.totalrecharge)
		    GetCTipsManager():AddMessageTip(str)
		    return
	    end
    else
        if mallConf.viplevel > gGetDataManager():GetVipLevel() then
            local str = MHSD_UTILS.get_msgtipstring(190066) --VIP�ȼ��ﵽ$parameter1$���ſɹ���˵���
		    str = str:gsub("%$parameter1%$", mallConf.viplevel)
		    GetCTipsManager():AddMessageTip(str)
            return
        end
    end

	--��鹺��ȼ�
	if not CurrencyManager.checkRoleLevel(self.selectedGoodsId, true) then
		return
	end
	
	--�޹�����
	local conf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cgoods")):getRecorder(self.selectedGoodsId)
	local buyNum = ShopManager.goodsBuyNumLimit[self.selectedGoodsId]
	local limitNum = self:getLimitNum(self.selectedGoodsId)

	if buyNum and buyNum >= limitNum then
        if conf.limitType == 1 then
		    GetCTipsManager():AddMessageTipById(160013) --���չ���������Ѵ�����
        elseif conf.limitType == 2 then
            GetCTipsManager():AddMessageTipById(160014) --�Ѵﱾ���޹��������������ٹ���
        end
		return
	end
	
	local num = tonumber(self.buyNumText:getText())
	if num == 0 then
		return
	end
	
	--��鱳������
	if not CheckBagCapacityForItem(conf.itemId, num) then
		GetCTipsManager():AddMessageTipById(160062) --�����ռ䲻��
		return
	end
	
	local p = require("protodef.fire.pb.shop.cbuymallshop").Create()
	p.shopid = SHOP_TYPE.MALL
	p.goodsid = self.selectedGoodsId
	p.num = num
	
	local price = MoneyNumber(self.priceText:getText())
	local needMoney = price - MoneyNumber(self.ownMoneyText:getText())
	--print('mall needMoney', needMoney)
	if needMoney > 0 then
		--GET MONEY
		CurrencyManager.handleCurrencyNotEnough(self.curCurrencyType, needMoney, price, p, self.ownMoneyText)
		return
	end
	
	LuaProtocolManager:send(p)

    self:refreshGoodsDetail()
end

--@p: fire.pb.shop.snotifybuysuccess
function MallShop:recvBuySuccess(p)
	if not self:IsVisible() then
		return false
	end
    local str = string.gsub(self.buySuccessStr, "num", p.number)
    str = string.gsub(str, "item", p.name)
    self.buySuccessDes:setText(str)
    self.buySuccessDlg:setVisible(true)
    self.buySuccessDlg:moveToFront()
    self.elapsed = 0
end

function MallShop.onVipLevelChanged()
    if _instance then
        _instance.goodsTable:reloadData()
        _instance:refreshGoodsDetail()
    end
end

function MallShop:update(dt)
    if self.buySuccessDlg:isVisible() then
        self.elapsed = self.elapsed + dt
        if self.elapsed >= 1000 then
            self.buySuccessDlg:setVisible(false)
        end
    end
end

return MallShop
