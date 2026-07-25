------------------------------------------------------------------
-- NPC宠物商店
------------------------------------------------------------------
require "logic.dialog"
require "logic.shop.goodscell"
require "logic.shop.npcpetshopcell"

NpcPetShop = {
	defaultNpcKey = 0
}
setmetatable(NpcPetShop, Dialog)
NpcPetShop.__index = NpcPetShop

local _instance
function NpcPetShop.getInstance()
	if not _instance then
		_instance = NpcPetShop:new()
		_instance:OnCreate()
	end
	return _instance
end

function NpcPetShop.getInstanceAndShow()
	if not _instance then
		_instance = NpcPetShop:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function NpcPetShop.getInstanceNotCreate()
	return _instance
end

function NpcPetShop.DestroyDialog()
	if _instance then
	_instance.buyBtn.animation:stop()--停止
        local Taskmanager = require("logic.task.taskmanager")
        Taskmanager.getInstance():setTaskOpenShopType(-1)

		CurrencyManager.unregisterTextWidget(_instance.ownMoneyText)
		_instance.tableView:destroyCells()
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function NpcPetShop.ToggleOpenClose()
	if not _instance then
		_instance = NpcPetShop:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function NpcPetShop.GetLayoutFileName()
	return "npcshopchongwu_mtg.layout"
end

function NpcPetShop:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, NpcPetShop)
	self.selectedGoodsId = 0
	return self
end

function NpcPetShop:addButtonAnimation(button, animationName)
    local animationDef = CEGUI.AnimationManager:getSingleton():getAnimation(animationName)
    if animationDef then
        local animation = CEGUI.AnimationManager:getSingleton():instantiateAnimation(animationDef)
        animation:setTargetWindow(button)
        animation:setSpeed(0.5)
        button.animation = animation
        button:subscribeEvent("MouseButtonDown", function()
            animation:start()
        end, self)
    end
end

function NpcPetShop:OnCreate()
	Dialog.OnCreate(self)
	SetPositionScreenCenter(self:GetWindow())
	local winMgr = CEGUI.WindowManager:getSingleton()
	self.winMgr = winMgr

	self.ownMoneyText = winMgr:getWindow("npcshopchongwu_mtg/textdan")
	self.currencyIcon = winMgr:getWindow("npcshopchongwu_mtg/textzong/yinbi2")
	self.priceText = winMgr:getWindow("npcshopchongwu_mtg/textdan1")
	self.buyBtn = CEGUI.toPushButton(winMgr:getWindow("npcshopchongwu_mtg/btngoumai"))
	self:addButtonAnimation(self.buyBtn, "studyBtnPress")
	self.petlistBg = winMgr:getWindow("npcshopchongwu_mtg/textbg")
	self.goodslistBg = CEGUI.toScrollablePane(winMgr:getWindow("npcshopchongwu_mtg/textbg/goodslist"))

	self.gainwayText = winMgr:getWindow("npcshopchongwu_mtg/textbg/huodetujing")
	self.btnlist = CEGUI.toScrollablePane(winMgr:getWindow("npcshopchongwu_mtg/btnlist"))
	

	self.buyBtn:subscribeEvent("Clicked", NpcPetShop.handleBuyClicked, self)
	
	self.gainwayStr = self.gainwayText:getText()
	self.gainwayText:setVisible(false)
	self.priceText:setText(0)

    self.requiredPetGoodsId = 0
	
    local s = self.goodslistBg:getPixelSize()
	self.tableView = TableView.create(self.goodslistBg, TableView.VERTICAL)
    self.tableView:setViewSize(s.width-20, s.height-20)
	self.tableView:setPosition(8, 8)
	self.tableView:setColumCount(2)
	self.tableView:setCellInterval(8, 8)
	self.tableView:setDataSourceFunc(self, NpcPetShop.tableViewGetCellAtIndex)
	self:loadLevelButtons()
end

function NpcPetShop:tableViewGetCellAtIndex(tableView, idx, cell)
	if not cell then
		cell = NpcPetShopCell.CreateNewDlg(tableView.container)
		cell.window:subscribeEvent("SelectStateChanged", NpcPetShop.handleGoodsCellClicked, self)
	end

    local goodsid = self.goodsids[idx]
	cell:setGoodsDataById(goodsid)
	cell.window:setSelected(self.selectedGoodsId == goodsid, true)
    if self.requiredPetGoodsId ~= 0 then
        cell.cornerImg:setVisible(self.requiredPetGoodsId == goodsid)
    end
	return cell
end

function NpcPetShop:selectGoodsByPetId(petId, showCornerImg)
	if showCornerImg == nil then
		showCornerImg = true
	end

	local ids = BeanConfigManager.getInstance():GetTableByName("shop.cpetshop"):getAllID()
	for _,id in pairs(ids) do
		local conf = BeanConfigManager.getInstance():GetTableByName("shop.cpetshop"):getRecorder(id)
		for j=0, conf.goodsids:size()-1 do
			local goods = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cgoods")):getRecorder(conf.goodsids[j])
			if goods and goods.itemId == petId then
				local btn = self.lvBtns[id]
				if not btn then
					ids = nil
					return
				end
				btn:setSelected(true) --will auto invoke function
				SetVeticalScrollOffset(self.btnlist, btn:getYPosition().offset)

                self.tableView:focusCellAtIdx(j)
                for _,cell in pairs(self.tableView.visibleCells) do
                    local goodsid = cell.window:getID()
                    if goodsid == goods.id then
                        cell.window:setSelected(true)  --will auto invoke function
                        if showCornerImg then
                            self.requiredPetGoodsId = goodsid
						    cell.cornerImg:setVisible(true)
					    end
                    end
                end
				ids = nil
				return
			end
		end
	end
	ids = nil
end

function NpcPetShop:loadLevelButtons()
	local conf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cnpcsale")):getRecorder(SHOP_TYPE.PET)
	if not conf then
		return
	end
	--self:GetWindow():setText(conf.shopName)
	
	self.saleConf = conf
	CurrencyManager.setCurrencyIcon(conf.currency, self.currencyIcon)
	CurrencyManager.registerTextWidget(conf.currency, self.ownMoneyText)
	
	--show button list
	self.lvBtns = {}
	local rolelv = gGetDataManager():GetMainCharacterLevel()
	local ids = BeanConfigManager.getInstance():GetTableByName("shop.cpetshop"):getAllID()
	local btnw = self.btnlist:getPixelSize().width-80
	local btnh = 65
	local n = 0
	local lvChar = MHSD_UTILS.get_resstring(3)
	for _,id in pairs(ids) do
		local conf = BeanConfigManager.getInstance():GetTableByName("shop.cpetshop"):getRecorder(id)
		if conf.limitLookLv <= rolelv then
			local btn = CEGUI.toGroupButton(self.winMgr:createWindow("TaharezLook/GroupButtoncc1"))
			btn:setGroupID(0)
			btn:setProperty("Font", "simhei-13")
			btn:setID(id)
			btn:setText(conf.showLv .. lvChar)
			btn:setSize(CEGUI.UVector2(CEGUI.UDim(0, btnw), CEGUI.UDim(0, btnh)))
			btn:EnableClickAni(false)
			self.btnlist:addChildWindow(btn)
			btn:setPosition(CEGUI.UVector2(CEGUI.UDim(0, 10), CEGUI.UDim(0, n*(btnh+5))))
			btn:subscribeEvent("SelectStateChanged", NpcPetShop.handleLevelBtnClicked, self)
			if n == 0 then
				btn:setSelected(true)
			end
			self.lvBtns[id] = btn
			n = n+1
		end
	end
end

function NpcPetShop:handleGoodsCellClicked(args)
	local goodsid = CEGUI.toWindowEventArgs(args).window:getID()
	self.selectedGoodsId = goodsid
	print('select npcPetShop goods, goodsid:', goodsid)
	
	local goodsconf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cgoods")):getRecorder(goodsid)
	local petAttr = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(goodsconf.itemId)
    if petAttr then
	    local str = self.gainwayStr:gsub("map", petAttr.bornmapdes)
	    self.gainwayText:setText(str)
	    self.gainwayText:setVisible(true)
    end
	
	self.priceText:setText(MoneyFormat(goodsconf.prices[0]))
	if goodsconf.prices[0] > MoneyNumber(self.ownMoneyText:getText()) then
		self.priceText:setProperty("BorderEnable", "True")
	else
		self.priceText:setProperty("BorderEnable", "True")
	end
end

function NpcPetShop:handleLevelBtnClicked(args)
	local confId = CEGUI.toWindowEventArgs(args).window:getID()
	--self:loadGoods(confId)

    self.selectedGoodsId = 0
	self.gainwayText:setVisible(false)
	self.priceText:setText(0)
    self.priceText:setProperty("BorderEnable", "True")
	
	local conf = BeanConfigManager.getInstance():GetTableByName("shop.cpetshop"):getRecorder(confId)
    self.goodsids = conf.goodsids
    self.tableView:setCellCount(conf.goodsids:size())
    self.tableView:reloadData()
end

function NpcPetShop:handleBuyClicked(args)
	if self.selectedGoodsId == 0 then
		GetCTipsManager():AddMessageTipById(150500) --请先选择要购买的宠物
	else
        --if GetBattleManager():IsInBattle() then
		--    GetCTipsManager():AddMessageTipById(160321) --战斗中不能放生
		--    return
	    --end

		--检查宠物栏数量
		local MaxPetNum = 8
		local vipLevel = gGetDataManager():GetVipLevel()
		local record = BeanConfigManager.getInstance():GetTableByName("fushi.cvipinfo"):getRecorder(vipLevel)
		MaxPetNum = MaxPetNum + record.petextracount

		if MainPetDataManager.getInstance():GetPetNum() == MaxPetNum then
			GetCTipsManager():AddMessageTipById(160036) --宠物栏已满，无法购买
			return
		end
		
		--检查购买等级
		if not CurrencyManager.checkRoleLevel(self.selectedGoodsId, true) then
			return
		end
		
		local p = require("protodef.fire.pb.shop.cbuynpcshop").Create()
		p.shopid = SHOP_TYPE.PET
		p.goodsid = self.selectedGoodsId
		p.num = 1
		p.buytype = fire.pb.shop.ShopBuyType.PET_SHOP
		
		local conf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cgoods")):getRecorder(self.selectedGoodsId)
		local needMoney = conf.prices[0] - CurrencyManager.getOwnCurrencyMount(self.saleConf.currency)
		if needMoney > 0 then
			--GET MONEY
			CurrencyManager.handleCurrencyNotEnough(self.saleConf.currency, needMoney, conf.prices[0], p, self.ownMoneyText)
		else
			
			LuaProtocolManager:send(p)
		end
	end
end

return NpcPetShop
