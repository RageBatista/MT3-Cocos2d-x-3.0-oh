------------------------------------------------------------------
-- 摆摊
------------------------------------------------------------------
require "logic.dialog"
require "logic.multimenuset"
require "logic.shop.stallupshelf"
require "logic.shop.stallpetupshelf"
require "logic.shop.stalldownshelf"
require "logic.currency.stoneexchangegolddlg"
require "logic.tips.commontipdlg"
require "logic.tips.commontiphelper"
require "logic.shop.stallbuydlg"
require "logic.shop.stalltradelogdlg"
require "logic.pet.petdetaildlg"
require "logic.shop.stallbuyconfirmdlg"
require "logic.waitingdlg"
require "logic.shop.stallsearchdlg"
require "logic.task.taskmanager"


local GROUP_BUY		= 1
local GROUP_SHOW	= 2
local GROUP_SELL	= 3


local LOGIC_NONE    = 0
local LOGIC_LEVEL   = 1
local LOGIC_ITEM    = 2
local LOGIC_QUALITY_RANGE   = 3
local LOGIC_LEVEL_RANGE     = 4


local WILL_SHOW_FIRST_TIP	= 1
local WILL_SHOW_LAST_TIP	= 2


local GROUPID = {
	PAGE		= 1,
	STALL		= 2,
	BUYCATALOG1	= 3,
	SHOWCATALOG1= 4,
	PET			= 5,
	BUYGOODS	= 6,
	SHOWGOODS	= 7
}

local function isTableEqual(t1, t2)
	if #t1 ~= #t2 then
		return false
	end
	for k,v in pairs(t1) do
		if v ~= t2[k] then
			return false
		end
	end
	return true
end

------------------------------------------------------------------
------[[ 商品类别选择的参数 ]]------
local Args = {}
Args.__index = Args
function Args.new()
	local ret = {}
	setmetatable(ret, Args)
	ret:reset()
	return ret
end

function Args:reset()
	self.catalog1 = 0
	self.catalog2 = 0
	self.catalog3 = {}
	self.rangeLow = 0
	self.rangeHigh = 0
	self.goodsType = 0
	self.logicType = 0
    self.curPage = 0
    self.maxPage = 0
	self.waitingForDefault = false --由服务器选择默认类型
end

function Args:copy(arg)
	self:reset()
	self.catalog1 = arg.catalog1
	self.catalog2 = arg.catalog2
	self.catalog3 = {}
    for k,v in pairs(arg.catalog3) do
        self.catalog3[k] = v
    end
	self.thirdmenus = arg.thirdmenus	--三级菜单项
	self.thirdGroupCount = arg.thirdGroupCount --三级菜单分组数
	self.rangeLow = arg.rangeLow
	self.rangeHigh = arg.rangeHigh
	self.goodsType = arg.goodsType
	self.logicType = arg.logicType
end

function Args:addCatalog3(id)
    table.insert(self.catalog3, id)
end

--参数是否足够确定某种商品（非关注）
function Args:haveSpecifyGoods()
	if self.catalog1 == 0 or self.catalog2 == 0 then
		return false
	end
	if self.logicType == LOGIC_NONE then
		return true
	end
	if (self.logicType == LOGIC_LEVEL or self.logicType == LOGIC_ITEM) and (#self.catalog3 ~= 0 or self.waitingForDefault) then
		return true
	end
	if (self.logicType == LOGIC_QUALITY_RANGE or self.logicType == LOGIC_LEVEL_RANGE) and (self.rangeLow ~= self.rangeHigh or self.waitingForDefault) then
		return true
	end
	return false
end

--参数对应的商品分类是否一样
function Args:isCatalogSame(arg)
	if self.catalog1 == 0 and arg.catalog1 == 0 then
		return true
	end
	if self.catalog1 ~= arg.catalog1 or
		self.catalog2 ~= arg.catalog2 or
		self.logicType ~= arg.logicType or
		self.goodsType ~= arg.goodsType
	  then
		return false
	end
	if self.logicType == LOGIC_NONE then
		return true
	end
	if (self.logicType == LOGIC_LEVEL or self.logicType == LOGIC_ITEM) then
		return isTableEqual(self.catalog3, arg.catalog3)
        --[[if #self.catalog3 ~= #arg.catalog3 then
            return false
        end
        for k,v in pairs(self.catalog3) do
            if v ~= arg.catalog[k] then
                return false
            end
        end
		return true--]]
	end
	if (self.logicType == LOGIC_QUALITY_RANGE or self.logicType == LOGIC_LEVEL_RANGE) and
		self.rangeLow == arg.rangeLow and self.rangeHigh == arg.rangeHigh then
		return true
	end
	return false
end

------------------------------------------------------------------

StallDlg = {}
setmetatable(StallDlg, Dialog)
StallDlg.__index = StallDlg

local _instance

function StallDlg.getInstance()
	if not _instance then
		_instance = StallDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function StallDlg.getInstanceAndShow(parent)
	if not _instance then
		_instance = StallDlg:new()
		_instance:OnCreate(parent)
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function StallDlg.getInstanceNotCreate()
	return _instance
end

function StallDlg.DestroyDialog()
	if _instance then 
		_instance.nextPageBtn.animation:stop()
			_instance.nextPageBtn.animation:stop()
				_instance.buyBtn.animation:stop()
					_instance.attentionBtn.animation:stop()
		local args = _instance.curArgs or _instance.buyArgs or _instance.showArgs
        if args then
			gCommon.stalldlgArgs = Args.new()
			gCommon.stalldlgArgs:copy(args)
		end
        
		CurrencyManager.unregisterTextWidget(_instance.ownMoneyText)
		gGetRoleItemManager():RemoveLuaItemNumChangeNotify(_instance.eventItemNumChange)	
		gGetDataManager().m_EventBattlePetStateChange:RemoveScriptFunctor(_instance.eventBattlePetStateChange)
		gGetDataManager().m_EventPetNumChange:RemoveScriptFunctor(_instance.eventPetNumChange)
		gGetDataManager().m_EventPetDataChange:RemoveScriptFunctor(_instance.eventPetDataChange)
		StallThirdMenu.savedCheckboxStates = {}
		Dialog.OnClose(_instance)
		if not _instance.m_bCloseIsHide then
			_instance = nil
		end
	end
end

function StallDlg.ToggleOpenClose()
	if not _instance then
		_instance = StallDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function StallDlg.GetLayoutFileName()
	return "baitan.layout"
end

function StallDlg:SetVisible(b)
    if b == false then
        Taskmanager.getInstance():setTaskOpenShopType(-1)
        WaitingDlg.hide()

        self.bagPetLoaded = false --will refresh after open
    end

	if self:IsVisible() ~= b and b then
        if b then
			--刷新商品列表
			if self.groupType ~= GROUP_SELL then
				self:queryStallGoods()
			end
		
			--刷新上架物品状态
			if self.myStallGoods then
				self:refreshMyStallGoodsState()
			end

            self:resetData()
        end
	end
	Dialog.SetVisible(self, b)
end

function StallDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, StallDlg)
	return self
end

function StallDlg:addButtonAnimation(button, animationName)
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

function StallDlg:OnCreate(parent)
	Dialog.OnCreate(self, parent)
	SetPositionOfWindowWithLabel(self:GetWindow())
	local winMgr = CEGUI.WindowManager:getSingleton()
	self.winMgr = winMgr
	
	self.buyAndShowView = winMgr:getWindow("baitan/fenye1")
	self.searchBtn = CEGUI.toPushButton(winMgr:getWindow("baitan/fenye1/sousuo"))
	self.buyCatalog1List = CEGUI.toScrollablePane(winMgr:getWindow("baitan/fenye1/liebiao"))
	self.showCatalog1List = CEGUI.toScrollablePane(winMgr:getWindow("baitan/fenye1/liebiao2"))
	self.ownMoneyText = winMgr:getWindow("baitan/fenye1/di1")
	self.ownMoneyText:setProperty("TextColours", "FFFFFFFF")
	--self.ownMoneyText:SetTextUnitColor(CEGUI.PropertyHelper:stringToColour("ffffffff"))
	self.currencyIcon = winMgr:getWindow("baitan/fenye1/di1/huobi")
	self.addMoneyBtn = CEGUI.toPushButton(winMgr:getWindow("baitan/fenye1/di1/jiahao"))
	self.showTipText = winMgr:getWindow("baitan/fenye1/gongshitip")
	self.attentionBtn = CEGUI.toPushButton(winMgr:getWindow("baitan/fenye1/guanzhu"))
	self:addButtonAnimation(self.attentionBtn, "studyBtnPress")
	
	self.buyBtn = CEGUI.toPushButton(winMgr:getWindow("baitan/fenye1/goumai"))
	self:addButtonAnimation(self.buyBtn, "studyBtnPress")
	
	self.lastPageBtn = CEGUI.toPushButton(winMgr:getWindow("baitan/fenye1/shangfan"))
	self:addButtonAnimation(self.lastPageBtn, "xstudyBtnPress")
	
	self.nextPageBtn = CEGUI.toPushButton(winMgr:getWindow("baitan/fenye1/xiafan"))
	self:addButtonAnimation(self.nextPageBtn, "xstudyBtnPress")
	
	self.pageText = winMgr:getWindow("baitan/fenye1/yema/1")
	self.buyGoodsBg = winMgr:getWindow("baitan/fenye1/di3/buygoodsbg")
	self.showGoodsBg = winMgr:getWindow("baitan/fenye1/di3/showgoodsbg")
	self.noGoodsView = winMgr:getWindow("baitan/fenye1/di3/emptyview")
	
	self.catalog2View = winMgr:getWindow("baitan/fenye1/di2")
	self.catalog2title = winMgr:getWindow("baitan/fenye1/di2/fenlei")
	self.touchHideArea = winMgr:getWindow("baitan/fenye1/di2/touchhidearea")

	self.touchHideArea:setRiseOnClickEnabled(false)
	
	self.thirdmenuBtn = CEGUI.toPushButton(winMgr:getWindow("baitan/tiaojian"))
	self.priceCondBtn = CEGUI.toPushButton(winMgr:getWindow("baitan/jiage"))
	self.thirdBtnArrow = winMgr:getWindow("baitan/tiaojian/arrow")
	self.priceBtnArrow = winMgr:getWindow("baitan/jiage/arrow")
	
	self.sellView = winMgr:getWindow("baitan/fenye2")
	self.stallTitle = winMgr:getWindow("baitan/fenye2/tanwei/biaotidi/stalltitle")
	self.stallScroll = CEGUI.toScrollablePane(winMgr:getWindow("baitan/fenye2/tanwei/liebiao"))
	self.stallItemBtn = CEGUI.toGroupButton(winMgr:getWindow("baitan/fenye2/daoju"))
	self.stallPetBtn = CEGUI.toGroupButton(winMgr:getWindow("baitan/fenye2/chongwu"))
	self.stallItemScroll = CEGUI.toScrollablePane(winMgr:getWindow("baitan/fenye2/di2/liebiao"))
	self.stallPetScroll = CEGUI.toScrollablePane(winMgr:getWindow("baitan/fenye2/di2/liebiao2"))
	self.bagItemTable = CEGUI.toItemTable(winMgr:getWindow("baitan/fenye2/di2/liebiao/itemtable"))
	self.tradeLog = CEGUI.toPushButton(winMgr:getWindow("baitan/fenye2/jiaoyijilu"))
	self.yccl = CEGUI.toPushButton(winMgr:getWindow("baitan/fenye2/baitanchuli"))
	
	
	self.smokeBg = winMgr:getWindow("baitan/Back/flagbg/smoke")
	local s = self.smokeBg:getPixelSize()
	local flagSmoke = gGetGameUIManager():AddUIEffect(self.smokeBg, "geffect/ui/mt_shengqishi/mt_shengqishi4", true, s.width*0.5, s.height)

	------------event------------
	self.searchBtn:subscribeEvent("Clicked", StallDlg.handleSearchClicked, self)
	self.attentionBtn:subscribeEvent("Clicked", StallDlg.handleAttentionClicked, self)
	self.buyBtn:subscribeEvent("Clicked", StallDlg.handleBuyClicked, self)
	self.touchHideArea:subscribeEvent("MouseClick", StallDlg.handleHideCatalog2View, self)
	self.tradeLog:subscribeEvent("Clicked", StallDlg.handleTradeLogClicked, self)
	self.yccl:subscribeEvent("Clicked", StallDlg.handleycClicked, self)
	self:GetWindow():subscribeEvent("Hidden", StallDlg.onWindowHidden, self)
	self.bagItemTable:subscribeEvent("TableClick", StallDlg.handleBagItemClicked, self)
	self.thirdmenuBtn:subscribeEvent("Clicked", StallDlg.handleThirdmenuBtnClicked, self)
	self.priceCondBtn:subscribeEvent("Clicked", StallDlg.handlePriceCondClicked, self)
	self.pageText:subscribeEvent("MouseClick", StallDlg.handlePageTextClicked, self)
	self.lastPageBtn:subscribeEvent("Clicked", StallDlg.handleLastPageClicked, self)
	self.nextPageBtn:subscribeEvent("Clicked", StallDlg.handleNextPageClicked, self)
	self.addMoneyBtn:subscribeEvent("Clicked", StallDlg.handleAddMoneyClicked, self)
	
	self:GetCloseBtn():removeEvent("Clicked")
	self:GetCloseBtn():subscribeEvent("Clicked", StallLabel.DestroyDialog, nil)
	
	
	self.stallItemBtn:setGroupID(GROUPID.STALL)
	self.stallPetBtn:setGroupID(GROUPID.STALL)
	self.stallItemBtn:subscribeEvent("SelectStateChanged", StallDlg.handleStallGroupBtnClicked, self)
	self.stallPetBtn:subscribeEvent("SelectStateChanged", StallDlg.handleStallGroupBtnClicked, self)

	------------init--------------
	if not ShopManager.marketThreeTable then
		ShopManager:convertMarketThreeTable()
	end
	
	local s = self.buyGoodsBg:getPixelSize()
	self.buyGoodsTable = TableView.create(self.buyGoodsBg)
	self.buyGoodsTable:setViewSize(s.width, s.height)
	self.buyGoodsTable:setPosition(0, 0)
	self.buyGoodsTable:setCellInterval(2, 3)
	self.buyGoodsTable:setColumCount(2)
	self.buyGoodsTable:setDataSourceFunc(self, StallDlg.goodsTableViewGetCellAtIndex)
	self.buyGoodsTable:setReachEdgeCallFunc(self, StallDlg.goodsTableViewReachEdge)
	
	self.showGoodsTable = TableView.create(self.showGoodsBg)
	self.showGoodsTable:setViewSize(s.width, s.height)
	self.showGoodsTable:setPosition(0, 0)
	self.showGoodsTable:setCellInterval(2, 3)
	self.showGoodsTable:setColumCount(2)
	self.showGoodsTable:setDataSourceFunc(self, StallDlg.goodsTableViewGetCellAtIndex)
	self.showGoodsTable:setReachEdgeCallFunc(self, StallDlg.goodsTableViewReachEdge)
	
	
	self.catalog2titleStr = self.catalog2title:getText()
	self.stallItemScroll:EnableAllChildDrag(self.stallItemScroll)

    self.buyArgs = Args.new() --购买页选择的参数
	self.buyArgs.groupType = GROUP_BUY
	self.buyArgs.catalog1Btns = {}
	self.buyArgs.catalog1Scroll = self.buyCatalog1List
	
    self.showArgs = Args.new() --公示页选择的参数
	self.showArgs.groupType = GROUP_SHOW
	self.showArgs.catalog1Btns = {}
	self.showArgs.catalog1Scroll = self.showCatalog1List
	
    self.curArgs = self.buyArgs --选择不同分页时分别指向buyArgs/showArgs
	self.tmpCatalog1 = 0 --临时保存，待选择了二级分类后赋值给curArgs.catalog1
	
	
	self.curBuyGoods = {}
	self.curShowGoods = {}
	self.selectedGoodsIdx = 0
	

	--search
    self.switchingPage = false
	self.isSearchMode = false
	self.searchProtocol = nil
	self.searchGoods = {}
	
    self.searchBtn:EnableClickAni(false)
	
    self.groupType = 0
    self:switchTabPage(GROUP_BUY)
	
	self.stallItemBtn:setSelected(true)
	self.thirdmenuBtn:setVisible(false)
	self.priceCondBtn:setVisible(false)
	self.isUpOrder = true --默认升序
	
	
	CurrencyManager.registerTextWidget(fire.pb.game.MoneyType.MoneyType_GoldCoin, self.ownMoneyText) --显示默认的摆摊货币类型
	
	self.eventItemNumChange = gGetRoleItemManager():InsertLuaItemNumChangeNotify(StallDlg.onEventBagItemNumChange)
	self.eventPetNumChange = gGetDataManager().m_EventPetNumChange:InsertScriptFunctor(StallDlg.onEventPetNumChange)
	self.eventPetDataChange = gGetDataManager().m_EventPetDataChange:InsertScriptFunctor(StallDlg.onEventPetDataChange)
	self.eventBattlePetStateChange = gGetDataManager().m_EventBattlePetStateChange:InsertScriptFunctor(StallDlg.handleEventPetBattleStateChange)

    self.lastOffset = {}
    self.lastSelectedMenuId = 0

    self.elapsed = 0
	self.elapseCount = 0

    if IsPointCardServer() then
        self.addMoneyBtn:setVisible(false)
    end

    --初始化关注容器
    self.attentionGoods = {}
	self.attentionGoods[GROUP_BUY] = {}
	self.attentionGoods[GROUP_SHOW] = {}
    ShopManager:queryAttention()
	
    if not StallDlg.isOpenForSpecialGoods and gCommon.stalldlgArgs then
		self.buyArgs:copy(gCommon.stalldlgArgs)
        if self.buyArgs.catalog1 ~= 0 then
		    self:selectCatalog1BtnById(self.buyArgs.catalog1)
			if self.buyArgs.logictype == LOGIC_NONE then
		        self.thirdmenuBtn:setVisible(false)
	        else
		        self.thirdmenuBtn:setVisible(true)
                self.thirdmenuBtn:setText(self.buyArgs.rangeLow .. "~" .. self.buyArgs.rangeHigh)
	        end
            self:refreshPriceOrderBtnVisible()
		    self:queryStallGoods()
	    end
	end
end



------------------------------------------------------------------

------[[ 外部接口 ]]------

--定位到购买列表中的某种物品，任务购买时调用
--@arg 物品相关的参数，如要求最低等级或最低品质，无要求则传nil
function StallDlg:selectGoodsCatalogByItemid(itemid, arg)
	local thirdconf = ShopManager.marketThreeTable[itemid]
	if not thirdconf then
		return
	end

	self.requireItemId = itemid --需要定位的物品

    --切换到购买分页
    self:switchPageIfNeed(GROUP_BUY)

    local secondconf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cmarketsecondtable")):getRecorder(thirdconf.twono)
	self.curArgs.thirdmenus = secondconf.thirdmenus
	self.curArgs.thirdGroupCount = secondconf.groupNum

	self.buyArgs:reset()
    self.buyArgs.catalog1 = thirdconf.firstno
	self.buyArgs.catalog2 = thirdconf.twono
    if thirdconf.logictype == LOGIC_NONE then
        self.buyArgs.catalog3 = {0}
    else
	    --self.buyArgs:addCatalog3(thirdconf.id)
        --三级菜单id，如果有分组取每组相同商品的id
	    local groupNum = (secondconf.groupNum>0 and secondconf.groupNum or 1)
	    local numPerGroup = secondconf.thirdmenus:size() / groupNum

	    for i=0, secondconf.thirdmenus:size()-1 do
		    if thirdconf.id == secondconf.thirdmenus[i] then
			    i = i % numPerGroup
			    for j=0, groupNum-1 do
				    self.curArgs:addCatalog3(secondconf.thirdmenus[j*numPerGroup+i])
			    end
			    break
		    end
	    end
    end
	self.buyArgs.rangeLow = 0
	self.buyArgs.rangeHigh = 0
	self.buyArgs.goodsType = thirdconf.itemtype
	self.buyArgs.logicType = thirdconf.logictype
	self.curArgs = self.buyArgs


	self.pageText:setText(self.buyArgs.curPage .. "/" .. self.buyArgs.maxPage)
	self:refreshPriceOrderBtnVisible()
	self.isUpOrder = true
	self:changePriceCondBtnImage()
	
	self:selectCatalog1BtnById(thirdconf.firstno, false)
	
	if thirdconf.logictype == LOGIC_NONE then
		self.thirdmenuBtn:setVisible(false)
	else
		self.thirdmenuBtn:setVisible(true)
	end
	
	if self.curArgs.catalog1 == STALL_CATALOG1_T.GEM_EQUIP or self.curArgs.catalog1 == STALL_CATALOG1_T.PATTERN then --3:珍品装备 8:制造符
		self.thirdmenuBtn:setText(thirdconf.name)
	else
		self.curArgs.waitingForDefault = true --请求默认显示，由服务器选择三级菜单id或区间
		self.thirdmenuBtn:setText(MHSD_UTILS.get_resstring(11309)) --读取中...
	end
	
	self:queryStallGoods()
end

function StallDlg:DestroyDialog1()
	if self._instance then
        if self.sprite then
            self.sprite:delete()
            self.sprite = nil
        end
		if self.smokeBg then
		    gGetGameUIManager():RemoveUIEffect(self.smokeBg)
		end
		if self.roleEffectBg then
		    gGetGameUIManager():RemoveUIEffect(self.roleEffectBg)
		end
		self:OnClose()
		getmetatable(self)._instance = nil
        _instance = nil
	end
end

--定位出售分页中的某个背包物品，从背包上架物品时调用
function StallDlg:showSellGroupPage(itemkey)
    self:switchTabPage(GROUP_SELL)
	if itemkey then
		self.selectedItemkey = itemkey
		local count = self.bagItemTable:GetCellCount()
		for i=0, count-1 do
			local cell = self.bagItemTable:GetCell(i)
			if not cell:isVisible() then
				break
			end
			cell:SetSelected(cell:getID2() == itemkey)
		end

		local parent = StallLabel.getInstance():GetWindow()
		local dlg = StallUpShelf.getInstanceAndShow(parent)
		dlg:setItemKey(itemkey)
	end
end

function StallDlg:switchPageIfNeed(groupType)
	--切换购买/公示分页
    local idx = 0
    if groupType == GROUP_BUY then
        idx = 1
    elseif groupType == GROUP_SELL then
        idx = 2
    elseif groupType == GROUP_SHOW then
        idx = 3
    end
	StallLabel.getInstance():showOnly(idx)
end

--普通搜索，根据给出的三级菜单id筛选
function StallDlg:doNormalSearch(catalog3, groupType)
	--切换购买/公示分页
	self:switchPageIfNeed(groupType)
	
	--隐藏二级菜单
	self.catalog2View:setVisible(false)
	
	local thirdconf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cmarketthreetable")):getRecorder(catalog3)
	local secondconf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cmarketsecondtable")):getRecorder(thirdconf.twono)
	local firstconf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cmarketfirsttable")):getRecorder(thirdconf.firstno)
	
	self.curArgs:reset()
	self.curArgs.catalog1 = firstconf.id
	self.curArgs.catalog2 = thirdconf.twono
	self.curArgs.rangeLow = 0
	self.curArgs.rangeHigh = 0
	self.curArgs.goodsType = thirdconf.itemtype
	self.curArgs.logicType = thirdconf.logictype
	self.curArgs.thirdmenus = secondconf.thirdmenus
	self.curArgs.thirdGroupCount = secondconf.groupNum
	self.curArgs.curPage = 0
	self.curArgs.maxPage = 0
	
	if thirdconf.logictype == LOGIC_NONE then
		self.thirdmenuBtn:setVisible(false)
        self.curArgs.catalog3 = {0}
	else
		self.thirdmenuBtn:setVisible(true)
        --三级菜单id，如果有分组取每组相同商品的id
	    local groupNum = (secondconf.groupNum>0 and secondconf.groupNum or 1)
	    local numPerGroup = secondconf.thirdmenus:size() / groupNum

	    for i=0, secondconf.thirdmenus:size()-1 do
		    if catalog3 == secondconf.thirdmenus[i] then
			    i = i % numPerGroup
			    for j=0, groupNum-1 do
				    self.curArgs:addCatalog3(secondconf.thirdmenus[j*numPerGroup+i])
			    end
			    break
		    end
	    end
	end

    self.pageText:setText(0 .. "/" .. 0)
	self:selectCatalog1BtnById(thirdconf.firstno, false)

	self.curArgs.waitingForDefault = true
	self.thirdmenuBtn:setText(MHSD_UTILS.get_resstring(11309)) --读取中...
    self:refreshPriceOrderBtnVisible()

    local p = require("protodef.fire.pb.shop.cmarketsearchpet"):new()
    p.pettype = thirdconf.itemid
    if not IsPointCardServer() then
	    p.sellstate = (groupType == GROUP_BUY and 1 or 2)  --1.上架中 2.公示中
    else
        p.sellstate = 1
    end
    LuaProtocolManager:send(p)

    self.isSearchMode = true
	--[[self:queryStallGoods()
    self.isSearchMode = false]]
end

--珍品装备搜索
function StallDlg:showEquipSearch(groupType, catalog2)
	--切换购买/公示分页
	self:switchPageIfNeed(groupType)
	self.priceCondBtn:setVisible(true)
	self.searchGoods = {}

	local secondconf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cmarketsecondtable")):getRecorder(catalog2)

	self.curArgs:reset()
	self.curArgs.catalog1 = STALL_CATALOG1_T.GEM_EQUIP
	self.curArgs.catalog2 = catalog2
	self.curArgs.rangeLow = 0
	self.curArgs.rangeHigh = 0
	self.curArgs.thirdmenus = secondconf.thirdmenus
	self.curArgs.thirdGroupCount = secondconf.groupNum
	self.curArgs.curPage = 0
	self.curArgs.maxPage = 0

	local catalog3 = self:getCatalog3ConfByArg(0)
	if catalog3[1] then
		local thirdconf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cmarketthreetable")):getRecorder(catalog3[1])
		self.curArgs.goodsType = thirdconf.itemtype
		self.curArgs.logicType = thirdconf.logictype
	end


	self.catalog2View:setVisible(false)

	self.pageText:setText(0 .. "/" .. 0)
	self:selectCatalog1BtnById(STALL_CATALOG1_T.GEM_EQUIP, false)

	self.thirdmenuBtn:setVisible(false)

	self.curBuyGoods = {}
	self.curShowGoods = {}
	self.buyGoodsTable:setCellCount(0)
	self.buyGoodsTable:reloadData()
    self.showGoodsTable:setCellCount(0)
	self.showGoodsTable:reloadData()
	self.noGoodsView:setVisible(true)
end

--宠物搜索
function StallDlg:showPetSearch(groupType, catalog3)
	--切换购买/公示分页
	self:switchPageIfNeed(groupType)
	self.priceCondBtn:setVisible(true)
	self.searchGoods = {}

	local thirdconf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cmarketthreetable")):getRecorder(catalog3)

	self.curArgs:reset()
	self.curArgs.catalog1 = thirdconf.firstno
	self.curArgs.catalog2 = thirdconf.twono
	self.curArgs:addCatalog3(catalog3)
	self.curArgs.rangeLow = 0
	self.curArgs.rangeHigh = 0
	self.curArgs.thirdmenus = nil
	self.curArgs.thirdGroupCount = 0
	self.curArgs.curPage = 0
	self.curArgs.maxPage = 0
    self.curArgs.goodsType = STALL_GOODS_T.PET

	self.catalog2View:setVisible(false)
	self.pageText:setText(0 .. "/" .. 0)
	self:selectCatalog1BtnById(thirdconf.firstno, false)

	self.thirdmenuBtn:setVisible(false)

	self.curBuyGoods = {}
	self.curShowGoods = {}
	self.buyGoodsTable:setCellCount(0)
	self.buyGoodsTable:reloadData()
    self.showGoodsTable:setCellCount(0)
	self.showGoodsTable:reloadData()
	self.noGoodsView:setVisible(true)
end

--浏览聊天中的摆摊商品
--p: smarketitemchatshow
function StallDlg:showChatStallGoods(p)
    --切换购买/公示分页
    local groupType = p.browsetype
	self:switchPageIfNeed(groupType)
	self.priceCondBtn:setVisible(true)

    local secondconf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cmarketsecondtable")):getRecorder(p.twono)

	self.curArgs:reset()
	self.curArgs.catalog1 = p.firstno
	self.curArgs.catalog2 = p.twono
	self.curArgs.catalog3 = p.threeno
	self.curArgs.rangeLow = 0
	self.curArgs.rangeHigh = 0
	self.curArgs.thirdmenus = secondconf.thirdmenus
	self.curArgs.thirdGroupCount = secondconf.groupNum
	self.curArgs.curPage = p.currpage
	self.curArgs.maxPage = p.totalpage
	
	if #p.goodslist > 0 then
		self.curArgs.goodsType = p.goodslist[1].itemtype
	end
    
    self:refreshThirdMenuBtnText(p.threeno[1], 0, 0)
    self:refreshPriceOrderBtnVisible()

	self.catalog2View:setVisible(false)
	self.pageText:setText(p.currpage .. "/" .. p.totalpage)
	self:selectCatalog1BtnById(p.firstno, false)

    if groupType == GROUP_BUY then
		self.curBuyGoods = p.goodslist
	elseif groupType == GROUP_SHOW then
		self.curShowGoods = p.goodslist
		self:genShowGoodsTimers(p.goodslist)
	end

    self.chatStallGoodsId = p.id
    self:refreshGoodsList()
    self.chatStallGoodsId = nil
end

--模拟点击一级菜单的效果
function StallDlg:openCatalog1ById(catalog1Id)
	self:switchPageIfNeed(GROUP_BUY)
	local btn = self.buyArgs.catalog1Btns[catalog1Id]
	if btn then
        self.catalog2View:setVisible(false)
		local arg = CEGUI.WindowEventArgs(btn)
		self:handleCatalog1Clicked(arg)
        btn:setSelected(true, false)
		SetVeticalScrollCellTop(self.buyArgs.catalog1Scroll, btn)
        self.tableView2:setContentOffset(0)
	end
end

--打开摆摊出售页签
function StallDlg.showStallSell(itemkey)
	local lvLimit = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(160).value) --摆摊购买和出售等级
	if lvLimit > gGetDataManager():GetMainCharacterLevel() then
		local str = MHSD_UTILS.get_msgtipstring(160057)
		str = string.gsub(str, "%$parameter1%$", lvLimit)
		GetCTipsManager():AddMessageTip(str) --30级开放摆摊功能，快升级哦！
		return false
	end

	-- VIP 等级判断
    local vipLevel = gGetDataManager():GetVipLevel()
    if vipLevel < 1 then
        GetCTipsManager():AddMessageTipById(193111)
        return false
    end

	if StallDlg.canSellItem(itemkey) then
        StallDlg.notQueryGoods = true
		require("logic.shop.stalllabel").show(2)
		_instance:showSellGroupPage(itemkey)
        StallDlg.notQueryGoods = nil
	end
end

------[[ 筛选操作相关 ]]------

--点击一级分类
function StallDlg:handleCatalog1Clicked(args)
	print('StallDlg:handleCatalog1Clicked')
	local btn = CEGUI.toWindowEventArgs(args).window
	
	if btn:getID() == 0 then --关注
		self.isSearchMode = false
		self.searchProtocol = nil
		self.searchGoods = {}

		self.buyArgs:reset()
		self.showArgs:reset()
		self.catalog2View:setVisible(false)
		self.priceCondBtn:setVisible(false)
		self.thirdmenuBtn:setVisible(false)
		self.curBuyGoods = {}
        self.curShowGoods = {}
		--self:refreshGoodsList()
        self.buyGoodsTable:setCellCount(0)
		self.buyGoodsTable:reloadData()
        self.showGoodsTable:setCellCount(0)
		self.showGoodsTable:reloadData()
		self.noGoodsView:setVisible(true)

        self:queryStallGoods()

        self.attentionBtn:setText(MHSD_UTILS.get_resstring(7417)) --关注
		
	elseif self.curArgs.catalog1 ~= btn:getID() or self.tmpCatalog1 ~= btn:getID() or not self.catalog2View:isVisible() then
		self.tmpCatalog1 = btn:getID()
		self.catalog2View:setVisible(true)
		
		local str = string.gsub(self.catalog2titleStr, "XX", btn:getText())
		self.catalog2title:setText(str)
		
		self:refreshCatalog2View()
	end
end

--点击二级分类
function StallDlg:handleCatalog2Clicked(args)
	local secondmenuid = CEGUI.toWindowEventArgs(args).window:getID()

	local conf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cmarketsecondtable")):getRecorder(secondmenuid)
	self.curArgs.thirdmenus = conf.thirdmenus
    self.curArgs.thirdGroupCount = conf.groupNum

	self.curArgs:reset()
	self.curArgs.catalog1 = self.tmpCatalog1
	self.curArgs.catalog2 = secondmenuid

	local arg = 0
    --3:珍品装备 8:模具，这两个默认按人物等级来选择
	if self.tmpCatalog1 == STALL_CATALOG1_T.GEM_EQUIP or self.tmpCatalog1 == STALL_CATALOG1_T.PATTERN
        or STALL_CATALOG1_T.EQUIP_FORGE==self.tmpCatalog1 
        then
		arg = gGetDataManager():GetMainCharacterLevel()
	end
	local thirdids = nil
	thirdids, self.curArgs.rangeLow, self.curArgs.rangeHigh = self:getCatalog3ConfByArg(arg)
	local thirdconf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cmarketthreetable")):getRecorder(thirdids[1])
	
	self.curArgs.catalog3 = thirdids
	self.curArgs.goodsType = thirdconf.itemtype
	self.curArgs.logicType = thirdconf.logictype
	
	if thirdconf.logictype == LOGIC_NONE then
		self.curArgs.catalog3 = {0}
		self.thirdmenuBtn:setVisible(false)
	else
		self.thirdmenuBtn:setVisible(true)
	end
	
	--3:珍品装备 8:模具，这两个默认按人物等级来选择
	if self.curArgs.catalog1 == STALL_CATALOG1_T.GEM_EQUIP or self.curArgs.catalog1 == STALL_CATALOG1_T.PATTERN 
        or STALL_CATALOG1_T.EQUIP_FORGE==self.curArgs.catalog1
        then

		self.thirdmenuBtn:setText(thirdconf.name)
	else
		self.curArgs.waitingForDefault = true
		self.thirdmenuBtn:setText(MHSD_UTILS.get_resstring(11309)) --读取中...
	end

	self.curArgs.curPage = 0
	self:queryStallGoods()
	
	self.curBuyGoods = {}
	self.catalog2View:setVisible(false)
	self:refreshPriceOrderBtnVisible()
	self.isUpOrder = true
	self:changePriceCondBtnImage()
end

--点击三级分类
function StallDlg:handleCatalog3Clicked(btn)
	self.thirdmenuBtn:setText(btn:getText())
	self.curArgs.catalog3 = {}
	 --3珍品装备 10任务物品
	if self.curArgs.thirdGroupCount > 1 then
		local menu = StallThirdMenu.getInstanceNotCreate()
		if menu and menu.checkBoxes then
			menu.notCheckChange = true
			for k,v in pairs(menu.checkBoxes) do
				if v:isSelected() then
					local idx = (self.curArgs.thirdmenus:size()/self.curArgs.thirdGroupCount)*(k-1) + btn:getID()
					if self.curArgs.thirdmenus:size() > idx then
						print("handleCatalog3Clicked", self.curArgs.thirdmenus[idx])
						self.curArgs:addCatalog3(self.curArgs.thirdmenus[idx])
					end
				end
			end
			self.curArgs.rangeLow = 0
			self.curArgs.rangeHigh = 0
		end
	else
		if self.curArgs.thirdmenus:size() == 1 then
			self.curArgs:addCatalog3(self.curArgs.thirdmenus[0])
			self.curArgs.rangeLow = btn:getID()
			self.curArgs.rangeHigh = btn:getID2()
		else
			self.curArgs:addCatalog3(btn:getID())
			self.curArgs.rangeLow = 0
			self.curArgs.rangeHigh = 0
		end
	end
	
	self.curArgs.curPage = 0
	self:queryStallGoods()
end

--获得默认的第三类分类或区间
--@arg 等级或品质
function StallDlg:getCatalog3ConfByArg(arg)
	local secondconf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cmarketsecondtable")):getRecorder(self.curArgs.catalog2)
	if secondconf.thirdmenus:size() == 1 then
        if arg == 0 then
			return {secondconf.thirdmenus[0]}, 0, 0
		end

		local thirdconf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cmarketthreetable")):getRecorder(secondconf.thirdmenus[0])
		if thirdconf.logictype == 0 then
			return {secondconf.thirdmenus[0]}, 0, 0
		end
		
		for i=thirdconf.valuerange:size()-2,0,-1 do
			if arg >= thirdconf.valuerange[i] then
				return {secondconf.thirdmenus[0]}, thirdconf.valuerange[i], thirdconf.valuerange[i+1]
			end
		end
		
	else
		local states = nil
		if StallThirdMenu.savedCheckboxStates then
			states = StallThirdMenu.savedCheckboxStates[self.curArgs.catalog1]
		end

		local groupNum = (secondconf.groupNum>0 and secondconf.groupNum or 1)
		local numPerGroup = secondconf.thirdmenus:size() / groupNum

		if arg ~= 0 then --有传入参数的话按参数值选择
			for i=numPerGroup-1,0,-1 do
				local conf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cmarketthreetable")):getRecorder(secondconf.thirdmenus[i])
				if arg >= conf.value then
					local thirdIds = {}
					for j=0, groupNum-1 do
						--print('add default third id', secondconf.thirdmenus[j*numPerGroup+i])
						if not states or not states[j+1] or states[j+1] == 1 then
							table.insert(thirdIds, secondconf.thirdmenus[j*numPerGroup+i])
						end
					end
					return thirdIds, 0, 0
				end
			end
		else --没有参数的话默认每组第一个
			local thirdIds = {}
			for i=0, groupNum-1 do
				if not states or not states[i+1] or states[i+1] == 1 then
					table.insert(thirdIds, secondconf.thirdmenus[i*numPerGroup])
				end
			end
			return thirdIds, 0, 0
		end
	end
	
	return {secondconf.thirdmenus[0]}, 0, 0
end



------[[ 界面逻辑 ]]------

--创建购买的一级菜单
function StallDlg:loadBuyCatalog1List()
	local ids = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cmarketfirsttable")):getAllID()
	--排序
	for i=1, #ids-1 do
		for j=i+1, #ids do
			local confI = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cmarketfirsttable")):getRecorder(ids[i])
			local confJ = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cmarketfirsttable")):getRecorder(ids[j])
			if confI.order > confJ.order then
				ids[i], ids[j] = ids[j], ids[i]
			end
		end
	end

	local btnw = self.buyArgs.catalog1Scroll:getPixelSize().width
	local btnh = 67
	for i=0, #ids do
		local btn = CEGUI.toGroupButton(self.winMgr:createWindow("TaharezLook/CellGroupButtonshui"))
		btn:setGroupID(GROUPID.BUYCATALOG1)
		btn:setProperty("Font", "simhei-13")
		btn:setSize(CEGUI.UVector2(CEGUI.UDim(0, btnw-2), CEGUI.UDim(0, btnh)))
		btn:EnableClickAni(false)
		self.buyArgs.catalog1Scroll:addChildWindow(btn)
		btn:setPosition(CEGUI.UVector2(CEGUI.UDim(0, 0), CEGUI.UDim(0, i*(btnh+2))))
		btn:subscribeEvent("MouseClick", StallDlg.handleCatalog1Clicked, self)
		
		local arrow = self.winMgr:createWindow("TaharezLook/StaticImage")
		arrow:setProperty("Image", "set:common image:common_youjiantou")
		arrow:setProperty("ImageSizeEnable", "False")
		arrow:setMousePassThroughEnabled(true)
		btn:addChildWindow(arrow)
		SetPositionOffset(arrow, btnw-20, btnh*0.52, 1, 0.52)
		
		if i == 0 then
			btn:setID(0)
			btn:setText(MHSD_UTILS.get_resstring(11802)) --关注
			btn:setSelected(true)

		else
			local conf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cmarketfirsttable")):getRecorder(ids[i])
			btn:setID(conf.id)
			btn:setText(conf.name)
		end
		
		self.buyArgs.catalog1Btns[btn:getID()] = btn
	end
	
	ids = nil
	self.buyCatalog1ListLoaded = true
end

--创建公示的一级菜单
function StallDlg:loadShowCatalog1List()
	local ids = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cmarketfirsttable")):getAllID()
	local btnw = self.showArgs.catalog1Scroll:getPixelSize().width
	local btnh = 67
	local n = 0
	for i=0, #ids do
		local conf = nil
		if i > 0 then
			conf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cmarketfirsttable")):getRecorder(ids[i])
		end
		if i == 0 or (conf and conf.isfloating == 0) then
			local btn = CEGUI.toGroupButton(self.winMgr:createWindow("TaharezLook/CellGroupButtonshui"))
			btn:setGroupID(GROUPID.BUYCATALOG1)
			btn:setProperty("Font", "simhei-13")
			btn:setSize(CEGUI.UVector2(CEGUI.UDim(0, btnw-2), CEGUI.UDim(0, btnh)))
			btn:EnableClickAni(false)
			self.showArgs.catalog1Scroll:addChildWindow(btn)
			btn:setPosition(CEGUI.UVector2(CEGUI.UDim(0, 0), CEGUI.UDim(0, n*(btnh+2))))
			btn:subscribeEvent("MouseClick", StallDlg.handleCatalog1Clicked, self)
			
			local arrow = self.winMgr:createWindow("TaharezLook/StaticImage")
			arrow:setProperty("Image", "set:common image:common_youjiantou")
			arrow:setProperty("ImageSizeEnable", "False")
			arrow:setMousePassThroughEnabled(true)
			btn:addChildWindow(arrow)
			SetPositionOffset(arrow, btnw-20, btnh*0.52, 1, 0.52)
			
			if i == 0 then
				btn:setID(0)
				btn:setText(MHSD_UTILS.get_resstring(11802)) --关注
			else
				btn:setID(conf.id)
				btn:setText(conf.name)
			end
			
			self.showArgs.catalog1Btns[btn:getID()] = btn
			n = n+1
		end
	end
	
	ids = nil
	self.showCatalog1ListLoaded = true
end

function StallDlg:resetData()
    if self.tableView2 then
        self.tableView2:setContentOffset(0)
    end
    self.lastOffset = {}
end


--创建二级菜单
function StallDlg:refreshCatalog2View()
	local conf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cmarketfirsttable")):getRecorder(self.tmpCatalog1)
	self.secondmenus = conf.secondmenus
	
	local s = self.catalog2View:getPixelSize()
	if not self.tableView2 then
		self.tableView2 = TableView.create(self.catalog2View)
		self.tableView2:setViewSize(s.width-21, s.height-55)
		self.tableView2:setPosition(10, 50)
		self.tableView2:setColumCount(2)
		self.tableView2:setCellInterval(4, 2)
		self.tableView2:setDataSourceFunc(self, StallDlg.catalog2TableViewGetCellAtIndex)
	end
	self.tableView2.container:moveToFront()

    local offset = 0
    local offpos = 0
    if self.tableView2 and self.lastOffset then
        offset = self.tableView2:getContentOffset()
        self.lastOffset[self.lastSelectedMenuId] = offset
        self.lastSelectedMenuId = self.tmpCatalog1
    end

	if self.tableView2 and self.lastOffset then
        if self.lastOffset[ self.tmpCatalog1] then
            offpos = self.lastOffset[ self.tmpCatalog1]
        end
	end

	self.tableView2:setCellCountAndSize(self.secondmenus:size(), s.width*0.5-10, 105)
    
    self.tableView2:setContentOffset(offpos)

	self.tableView2:reloadData()
end

function StallDlg:catalog2TableViewGetCellAtIndex(tableView, idx, cell)
	if not cell then
		local prefix = "stall2_" .. tableView:genCellPrefix()
		cell = {}
		cell.window = CEGUI.toPushButton(self.winMgr:loadWindowLayout("baitancell4.layout", prefix))
		cell.window:EnableClickAni(false)
		cell.itemcell = CEGUI.toItemCell(self.winMgr:getWindow(prefix .. "baitancell4/daoju"))
		cell.name = self.winMgr:getWindow(prefix .. "baitancell4/mingzi")
		cell.window:subscribeEvent("MouseClick", StallDlg.handleCatalog2Clicked, self)
	end
	
	if self.tmpCatalog1 == STALL_CATALOG1_T.GEM_PET then  --珍品宠物
		cell.itemcell:SetStyle(CEGUI.ItemCellStyle_IconExtend)
	else
		cell.itemcell:SetStyle(CEGUI.ItemCellStyle_IconInside)
	end
	
	local conf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cmarketsecondtable")):getRecorder(self.secondmenus[idx])
    if conf then
	    cell.name:setText(conf.name)
	    cell.itemcell:SetImage(gGetIconManager():GetImageByID(conf.iconid))
	    cell.window:setID(conf.id)
    else
        cell.name:setText("ErrorID " .. self.secondmenus[idx])
        cell.window:setID(self.secondmenus[idx])
    end
	return cell
end


------[[ 数据操作 ]]------

--请求商品列表 -> recvStallGoods
function StallDlg:queryStallGoods(showWaitingDlg)
    self.switchingPage = false
    if self.notQueryGoods or not self.curArgs then
        return
    end
    local nIsSearch = 0
    if self.isSearchMode then
        nIsSearch = 1
    end

	self.isSearchMode = false
	self.searchProtocol = nil
	self.searchGoods = {}
	
	--如果已浏览过某一类商品，则刷新一次该类
	if self.curArgs:haveSpecifyGoods() then
		
		self.curArgs.curPage = math.max(self.curArgs.curPage, 1)
		
		local p = require("protodef.fire.pb.shop.cmarketbrowse"):new()
		p.browsetype = self.curArgs.groupType
		p.firstno = self.curArgs.catalog1
		p.twono = self.curArgs.catalog2
        p.issearch = nIsSearch
		for _,v in pairs(self.curArgs.catalog3) do
			table.insert(p.threeno, v)
		end
		p.limitmin = self.curArgs.rangeLow
		p.limitmax = self.curArgs.rangeHigh
		p.itemtype = self.curArgs.goodsType
		p.currpage = self.curArgs.curPage
		p.pricesort = (self.isUpOrder and 1 or 2) --1升序  2降序

		print('------ cmarketbrowse 1 --------')
		for k,v in pairs(p) do
			print(k,v)
            if k == "threeno" then
                for k1,v1 in pairs(v) do
                    print(' ', k1, v1)
                end
            end
		end
		LuaProtocolManager:send(p)
		
		if showWaitingDlg == nil or showWaitingDlg == true then
			local parent = (self.curArgs.groupType == GROUP_BUY and self.buyGoodsBg or self.showGoodsBg)
			WaitingDlg.show(parent, MHSD_UTILS.get_resstring(11321))
		end
		
	--默认浏览关注类
	else
		self.curArgs:reset()

		local p = require("protodef.fire.pb.shop.cmarketattentionbrowse"):new()
		p.attentype = self.curArgs.groupType
		LuaProtocolManager:send(p)
	end
end

--更新出售界面显示的背包物品
function StallDlg:refreshBagItemTable()
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local roleItems = roleItemManager:FilterBagItem(eItemFilterType_CanStall)
	self:sortBagItems(roleItems)
	
	local foundLastSelected = false
	if roleItems:size() > 0 then
		self.bagItemTable:setVisible(true)
        local col = self.bagItemTable:GetColCount()
		local row = math.ceil(roleItems:size() / col)
		if self.bagItemTable:GetRowCount() ~= row then
			self.bagItemTable:SetRowCount(row)
			local h = self.bagItemTable:GetCellHeight()
			local spaceY = self.bagItemTable:GetSpaceY()
			self.bagItemTable:setHeight(CEGUI.UDim(0, (h+spaceY)*row))
			self.stallItemScroll:EnableAllChildDrag(self.stallItemScroll)
		end
		
		for i=0, row*col-1 do
			local cell = self.bagItemTable:GetCell(i)
			cell:Clear()
			cell:SetHaveSelectedState(true)
			if i < roleItems:size() then
				cell:setVisible(true)
				local item = roleItems[i]
				local img = gGetIconManager():GetImageByID(item:GetIcon())
				cell:SetImage(img)
                refreshItemCellBind(cell,item:GetObject().loc.tableType,item:GetThisID())
				
				local itemAttr = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(item:GetObjectID())
				if itemAttr then
                    SetItemCellBoundColorByQulityItem(cell, itemAttr.nquality, itemAttr.itemtypeid)
					local text = ""
					if itemAttr.maxNum > 1 then --可堆叠的物品
                local curNum = item:GetNum()
                    text = curNum > 1 and curNum or "" 
                    else
                local level = Commontiphelper.getItemLevelValue(item:GetObjectID(), item:GetObject())
                    text = (level > 0 and level .. "级") or ""
                end
                    cell:SetTextUnit(text)
                local font_size = 10 
                    cell:setProperty("Font", "simhei-" .. font_size) 
                    cell:setProperty("BackgroundEnabled", "False") 
				--	setProperty("BackgroundEnabled", "False")
                end

						--[[local firstType = item:GetFirstType()
						if firstType == eItemType_FOOD or firstType == eItemType_DRUG then
							local obj = item:GetObject()
							local data = (firstType == eItemType_FOOD and obj)
							if data then
								cell:SetTextUnit("Lv." .. data.qualiaty)
							end
						elseif item:GetItemLevel() > 0 then
							cell:SetTextUnit("Lv." .. item:GetItemLevel())
						else
							cell:SetTextUnit(1)
						end--]]
					--end
			--	end
				
				
				--显示珍品角标
				if ShopManager:needShowRarityIcon(STALL_GOODS_T.ITEM, item:GetObjectID()) then
                --if item:isTreasure() then
					cell:SetCornerImageAtPos("ccui1", "newzp", 0, 1)----摆摊出售界面的珍品图标
				end
				
				cell:setID(item:GetObjectID()) --baseid
				cell:setID2(item:GetThisID())  --itemkey
				
				if self.selectedItemkey == item:GetThisID() then
					foundLastSelected = true
					cell:SetSelected(true)
				end
			else
				cell:setVisible(false)
			end
		end
	else
		self.bagItemTable:setVisible(false)
	end
	
	if not foundLastSelected then
		self.selectedItemkey = 0
	end
	
	roleItems = nil
	self.bagItemLoaded = true
end

--更新出售界面显示的宠物列表
function StallDlg:refreshBagPetTable()
	self.bagPetCells = {}
	self.stallPetScroll:cleanupNonAutoChildren()
	
	local num = MainPetDataManager.getInstance():GetPetNum()
	for i=1, num do
		local prefix = "stallpet" .. i
		local cell = {}
		cell.window = CEGUI.toGroupButton(self.winMgr:loadWindowLayout("baitancell3.layout", prefix))
		cell.window:setGroupID(GROUPID.PET)
		cell.window:setID(i)
		cell.window:EnableClickAni(false)
		cell.itemcell = CEGUI.toItemCell(self.winMgr:getWindow(prefix .. "baitancell3/daoju"))
		cell.nameText = self.winMgr:getWindow(prefix .. "baitancell3/mingzi")
		cell.levelText = self.winMgr:getWindow(prefix .. "baitancell3/dengji")
        cell.lockImg = self.winMgr:getWindow(prefix .. "baitancell3/lock")
		cell.window:subscribeEvent("MouseClick", StallDlg.handleBagPetClicked, self)
		self.stallPetScroll:addChildWindow(cell.window)
		SetPositionOffset(cell.window, 0, (i-1)*(cell.window:getPixelSize().height+3))
		
        cell.itemcell:SetStyle(CEGUI.ItemCellStyle_IconExtend)

		local petData = MainPetDataManager.getInstance():getPet(i)
		local shapeData = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(petData:GetShapeID())
		local image = gGetIconManager():GetImageByID(shapeData.littleheadID)
		cell.itemcell:SetImage(image)
		cell.levelText:setText(petData:getAttribute(fire.pb.attr.AttrType.LEVEL) .. MHSD_UTILS.get_resstring(3))
		cell.nameText:setText(petData.name)
		
		if not ShopManager.marketThreeTable[petData.baseid] then
			cell.levelText:setProperty("TextColours", "FF828282")
			cell.nameText:setProperty("TextColours", "FF828282")
			cell.isNormalPet = true --普通宠物，不在摆摊表里
		end
		
		--显示珍品角标
		--if ShopManager:isRarity(STALL_GOODS_T.PET, petData.baseid) then
        local petAttr = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(petData.baseid)
        if petAttr then
            SetItemCellBoundColorByQulityPet(cell.itemcell, petAttr.quality)
        end
        local bTreasure = isPetTreasure(petData)
        if bTreasure then
			cell.itemcell:SetCornerImageAtPos("ccui1", "newzp", 0, 1)
		else
			cell.levelText:setProperty("TextColours", "FF828282")
			cell.nameText:setProperty("TextColours", "FF828282")
			cell.isNormalPet = true --普通宠物
		end
		
		if petData.key == gGetDataManager():GetBattlePetID() then --出战
			cell.itemcell:SetCornerImageAtPos("ccui", "chongwu_zhan", 1, 0.5)
		end

		if petData.flag == 2 then --绑定
			cell.itemcell:SetCornerImageAtPos("common_equip", "suo", 1, 0.8)
		end

	    if petData.marketfreezeexpire > gGetServerTime() then
            cell.lockImg:setVisible(true)
            cell.isLocked = true
        else
            cell.lockImg:setVisible(false)
        end
		
		cell.petData = petData
		self.bagPetCells[i] = cell
	end
	
	self.bagPetLoaded = true
end

function StallDlg:refreshAttentionContainer(isBuyAttention, goodslist)
    if not self.attentionGoods or not self.curArgs or self.curArgs.catalog1 ~= 0 then
        return
    end

	local groupType = (isBuyAttention and GROUP_BUY or GROUP_SHOW)
	self.attentionGoods[groupType] = goodslist

    if groupType == GROUP_SHOW then
        self:genShowGoodsTimers(goodslist)
    end
	
	if self.curArgs.catalog1 == 0 and self.curArgs.groupType == groupType then
		if #goodslist > 0 then
			self.curArgs.curPage = 1
			self.curArgs.maxPage = math.ceil(#goodslist / 8)
			self.pageText:setText("1/" .. self.curArgs.maxPage)
		else
			self.curArgs.curPage = 0
			self.curArgs.maxPage = 0
			self.pageText:setText("0/0")
		end
		self:refreshGoodsList()
	end
end

--containerType: 1购买关注，2公示关注
--attentionType: 1关注  2取消关注
function StallDlg:refreshGoodsAttention(containerType, attentionType, goodsId)
    if not self.curArgs then
        return
    end

	local tableview = (self.curArgs.groupType==GROUP_BUY and self.buyGoodsTable or self.showGoodsTable)
	local cells = tableview.visibleCells
	for k,cell in pairs(cells) do
		if cell.goodsId == goodsId then

			local isAttentioned = (attentionType==1 and true or false)
            if cell.isAttentioned == isAttentioned then
                break
            end
            cell.isAttentioned = isAttentioned
            local attentionCount = cell.attentionBg:getID()
            if isAttentioned then
                attentionCount = attentionCount+1
            else
                attentionCount = attentionCount-1
            end
            cell.attentionBg:setID(attentionCount)
            self:setHeartCount(cell, attentionCount)

			if cell.isAttentioned then
				--显示关注角标
                cell.cornerImg:setProperty("Image", "set:ccui1 image:newgz");
			
			elseif cell.itemtype == STALL_GOODS_T.PET then
				--显示珍品角标
                cell.cornerImg:setProperty("Image", "set:ccui1 image:newzp");
			else
                local goods = self:getGoodsDataAtIndex(k)
                if goods and ShopManager:needShowRarityIcon(goods.itemtype, goods.itemid) then
				    --显示珍品角标
                    cell.cornerImg:setProperty("Image", "set:ccui1 image:newzp");
			    else
				    --cell.itemcell:SetCornerImageAtPos(nil, 0, 0)
                    cell.cornerImg:setProperty("Image", "");
			    end
            end

			if cell.itemcell:getID2()+1 == self.selectedGoodsIdx then
				if cell.isAttentioned then
					self.attentionBtn:setText(MHSD_UTILS.get_resstring(7418)) --取消关注
				else
					self.attentionBtn:setText(MHSD_UTILS.get_resstring(7417)) --关注
				end
			end
			break
		end
	end
end

--更新我的摊位
function StallDlg:refreshMyStallGoodsList(goodslist)
    self.goodslist = goodslist
	print('refreshMyStallGoodsList', #goodslist)
	self.stallScroll:cleanupNonAutoChildren()

    --检查是否需要关闭下架界面
    local downShelfDlg = StallDownShelf.getInstanceNotCreate()
    local downShelfGoodsId = (downShelfDlg and downShelfDlg.goods.id or nil)
    local foundDownShelfGoods = false

	self.myStallGoods = {}
	for i,v in pairs(goodslist) do
		local prefix = "mystallgoods_" .. i
		local cell = {}
		cell.window = CEGUI.toGroupButton(self.winMgr:loadWindowLayout("baitancell2.layout", prefix))
		cell.window:EnableClickAni(false)
		cell.itemcell = CEGUI.toItemCell(self.winMgr:getWindow(prefix .. "baitancell2/daoju"))
		cell.itemcell:setMousePassThroughEnabled(true)
		cell.name = self.winMgr:getWindow(prefix .. "baitancell2/mingzi")
		cell.price = self.winMgr:getWindow(prefix .. "baitancell2/di")
		cell.price:setProperty("TextColours", "FFFFFFFF")
		cell.currencyIcon = self.winMgr:getWindow(prefix .. "baitancell2/di/huobi")
        cell.timeLabel = self.winMgr:getWindow(prefix .. "baitancell2/time")
        cell.timeLabel:setVisible(false)
		
		cell.window:setID(i)
		cell.window:subscribeEvent("MouseClick", StallDlg.handleMyStallGoodsClicked, self)
		
		self.stallScroll:addChildWindow(cell.window)
		local row = math.floor((i-1)/2)
		local col = (i-1)%2
		local s = cell.window:getPixelSize()
		SetPositionOffset(cell.window, col*(s.width+1), row*(s.height+1))
		
		cell.type = v.itemtype
		cell.goods = v --MarketGoods
		
		cell.price:setText(MoneyFormat(v.price))
		
		if cell.type == STALL_GOODS_T.ITEM then --item
			local itemAttr = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(v.itemid)
            if itemAttr then
    cell.name:setText(itemAttr.name)
    SetItemCellBoundColorByQulityItem(cell.itemcell, itemAttr.nquality, itemAttr.itemtypeid)
    local image = gGetIconManager():GetImageByID(itemAttr.icon)
    cell.itemcell:SetStyle(CEGUI.ItemCellStyle_IconInside)
    cell.itemcell:SetImage(image)
    if itemAttr.maxNum > 1 then --可堆叠的物品
        cell.itemcell:SetTextUnit(v.num > 1 and v.num or "")
    elseif v.level > 0 then
        cell.itemcell:SetTextUnit(v.level .. "级")
		--cell.itemcell:setProperty("BorderEnable", "false")
		--cell.itemcell:setProperty("BordrColours", "FFFFFFFF")
		--cell.itemcell:setProperty("TextColours", "FFFFFFFF")
    end
end
		elseif cell.type == STALL_GOODS_T.PET then --pet
			local petAttr = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(v.itemid)
            if petAttr then
                cell.name:setProperty("TextColours", "ff743a0f")
			    cell.name:setText(petAttr.name)
			    local shapeData = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(petAttr.modelid)
                SetItemCellBoundColorByQulityPet(cell.itemcell, petAttr.quality)
			    local image = gGetIconManager():GetImageByID(shapeData.littleheadID)
                cell.itemcell:SetStyle(CEGUI.ItemCellStyle_IconExtend)
			    cell.itemcell:SetImage(image)
            end
		end
		
		if v.showtime > gGetServerTime() and not IsPointCardServer() then --公示中
			cell.itemcell:SetCornerImageAtPos("ccui1", "newgs", 0, 1)
		elseif ShopManager:needShowRarityIcon(v.itemtype, v.itemid) then --显示珍品角标
			cell.itemcell:SetCornerImageAtPos("ccui1", "newzp", 0, 1)
		end
		
		self.myStallGoods[i] = cell

        if downShelfGoodsId and downShelfGoodsId == v.id then
            foundDownShelfGoods = true
        end
	end

    if not foundDownShelfGoods and downShelfDlg then
        StallDownShelf.DestroyDialog()
    end
	
    self:refreshMyStallGoodsState()
	self.stallTitle:setText(#goodslist .. "/8")
end

function StallDlg:refreshMyStallGoodsShowTime()
    if IsPointCardServer() then
        return
    end

	if not self.myStallGoods or #self.myStallGoods == 0 then
		return
	end
	
	local leftTime, leftHour, leftMin
	local serverTime = gGetServerTime()
	
	for i, v in pairs(self.myStallGoods) do
        if not v.outdate then
		    if v.goods.showtime > serverTime then
			    leftTime = math.max(math.floor((v.goods.showtime - serverTime)/1000), 0)
			    leftHour = math.floor(leftTime/3600)
			    leftMin = math.floor((leftTime%3600)/60)
			    if leftMin < 10 then
				    if leftHour == 0 and leftMin == 0 then
					    leftMin = 1
				    end
				    leftMin = "0" .. leftMin
			    end
			    if leftHour < 10 then
				    leftHour = "0" .. leftHour
			    end
			    v.timeLabel:setVisible(true)
			    v.timeLabel:setText(leftHour .. ":" .. leftMin)
			
		    elseif v.timeLabel:isVisible() then
			    v.timeLabel:setVisible(false)
			    --显示珍品角标
			    if ShopManager:needShowRarityIcon(v.goods.itemtype, v.goods.itemid) then
				    v.itemcell:SetCornerImageAtPos("ccui1", "newzp", 0, 1)
			    else
				    v.itemcell:SetCornerImageAtPos(nil, 0, 1)
			    end
		    end
        end
	end
end

function StallDlg:refreshBagItemsLockState()
    if not self.bagItemTable then
        return
    end
    local count = self.bagItemTable:GetCellCount()
	for i=0, count-1 do
		local cell = self.bagItemTable:GetCell(i)
		if not cell:isVisible() then
			break
		end
		
        if cell:isUserStringDefined("cool") then
            if cell:getUserString("cool") == "true" then
                refreshItemCellBind(cell, fire.pb.item.BagTypes.BAG, cell:getID2())
            end
        end
	end
end

function StallDlg:getGoodsCountAtCurPage()
	if not self.curArgs then
		return 0
	end
	
    --搜索模式
	if self.isSearchMode then
        if self.curArgs.maxPage == 1 then
            return #self.searchGoods
        end
		if self.curArgs.curPage < self.curArgs.maxPage then
			return 8
		end
		return #self.searchGoods % 8
	end
	
    --关注页
	if self.curArgs.catalog1 == 0 then
        if not self.attentionGoods then
            return 0
        end
        if self.curArgs.maxPage == 1 then
            return #self.attentionGoods[self.curArgs.groupType]
        end
        if self.curArgs.curPage < self.curArgs.maxPage then
			return 8
		end
		return #self.attentionGoods[self.curArgs.groupType]  % 8
	end
	
	if self.curArgs.groupType == GROUP_BUY then
        if not self.curBuyGoods then
            return 0
        end
        if not IsPointCardServer() then
            if self.curArgs.logicType == LOGIC_QUALITY_RANGE or
               self.curArgs.logicType == LOGIC_LEVEL_RANGE
              then
                if self.curArgs.maxPage == 1 then
                    return #self.curBuyGoods
                end
                if self.curArgs.curPage < self.curArgs.maxPage then
			        return 8
		        end
                return #self.curBuyGoods % 8
            end
        end
		return #self.curBuyGoods
	end
	
	return self.curShowGoods and #self.curShowGoods or 0
end

--idx从1开始
function StallDlg:getGoodsDataAtIndex(idx)
	if not self.curArgs then
		return nil
	end
	
	if self.isSearchMode then
		if self.curArgs.curPage > 0 then
			return self.searchGoods[(self.curArgs.curPage-1)*8+idx]
		end
		return nil
	end
	
	if self.curArgs.catalog1 == 0 then
        if not self.attentionGoods then
            return nil
        end
		local goods = self.attentionGoods[self.curArgs.groupType]
		if goods then
			return goods[(self.curArgs.curPage-1)*8+idx]
		end
		return nil
	end
	
	if self.curArgs.groupType == GROUP_BUY then
        if not IsPointCardServer() and
          (self.curArgs.logicType == LOGIC_QUALITY_RANGE or
           self.curArgs.logicType == LOGIC_LEVEL_RANGE)
          then
            return self.curBuyGoods[(self.curArgs.curPage-1)*8+idx]
        end
		return self.curBuyGoods[idx]
	end
	
	return self.curShowGoods[idx]
end

--idx从1开始
function StallDlg:getShowGoodsTimerAtIndex(idx)
	if not self.curArgs then
		return nil
	end
	
	if self.isSearchMode then
		return self.showGoodsTimer[(self.curArgs.curPage-1)*8+idx]
	end
	
	return self.showGoodsTimer[idx]
end

--更新购买或公示的商品列表
function StallDlg:refreshGoodsList(notResetGoodsIdx)
    if not notResetGoodsIdx then
		self.selectedGoodsIdx = 0
    end

	if self.curArgs.groupType == GROUP_BUY then    
		local s = self.buyGoodsBg:getPixelSize()
		local n = self:getGoodsCountAtCurPage()
		self.buyGoodsTable:setCellCountAndSize(n, s.width*0.5, 110)
		self.buyGoodsTable:setContentOffset(0)
		self.buyGoodsTable:reloadData()
		
		self.noGoodsView:setVisible(n == 0)
		
	elseif self.curArgs.groupType == GROUP_SHOW then
		local s = self.showGoodsBg:getPixelSize()
		local n = self:getGoodsCountAtCurPage()
		self.showGoodsTable:setCellCountAndSize(n, s.width*0.5, 110)
		self.showGoodsTable:setContentOffset(0)
		self.showGoodsTable:reloadData()
		
		self.noGoodsView:setVisible(n == 0)
	end

    self.buyBtn:setText(MHSD_UTILS.get_resstring(7419)) --购买

	local goodsCell = self:getSelectedGoodsCell()
	if not goodsCell then
		return
	end

	if goodsCell.isAttentioned then
		self.attentionBtn:setText(MHSD_UTILS.get_resstring(7418)) --取消关注
	else
		self.attentionBtn:setText(MHSD_UTILS.get_resstring(7417)) --关注
	end
end

function StallDlg:goodsTableViewGetCellAtIndex(tableView, idx, cell)
	if not cell then
		local prefix = self.curArgs.groupType .. "stallgoods_" .. tableView:genCellPrefix()
		cell = {}
		cell.window = CEGUI.toGroupButton(self.winMgr:loadWindowLayout("baitancell1.layout", prefix))
		cell.window:EnableClickAni(false)
		cell.itemcell = CEGUI.toItemCell(self.winMgr:getWindow(prefix .. "baitancell1/wupin"))
		cell.name = self.winMgr:getWindow(prefix .. "baitancell1/mingzi")
		cell.currencyIcon = self.winMgr:getWindow(prefix .. "baitancell1/di/huobi")
		cell.price = self.winMgr:getWindow(prefix .. "baitancell1/di")
		cell.price:setProperty("TextColours", "FFFFFFFF")
		cell.heart = self.winMgr:getWindow(prefix .. "baitancell1/guanzhu/heartBg/heart")
		cell.heartBg = self.winMgr:getWindow(prefix .. "baitancell1/guanzhu/heartBg")
		cell.attentionBg = self.winMgr:getWindow(prefix .. "baitancell1/guanzhu")
		cell.timer = self.winMgr:getWindow(prefix .. "baitancell1/shijian")
        cell.cornerImg = self.winMgr:getWindow(prefix .. "baitancell1/jiaobiao")
        cell.levelText = self.winMgr:getWindow(prefix .. "baitancell1/dengji")
		cell.levelText:setProperty("TextColours", "FFFFFFFF")
        cell.numText = self.winMgr:getWindow(prefix .. "baitancell1/shuliang")
		cell.numText:setProperty("TextColours", "FFFFFFFF")
		
		cell.heartBgH = cell.heartBg:getPixelSize().height
		cell.itemcell:subscribeEvent("TableClick", StallDlg.handleGoodsCellItemClicked, self)
		cell.window:subscribeEvent("SelectStateChanged", StallDlg.handleGoodsCellClicked, self)
		cell.attentionBg:subscribeEvent("MouseClick", StallDlg.handleGoodsCellAttentionClicked, self)
		if self.curArgs.groupType == GROUP_BUY then
			cell.window:setGroupID(GROUPID.BUYGOODS)
		elseif self.curArgs.groupType == GROUP_SHOW then
			cell.window:setGroupID(GROUPID.SHOWGOODS)
		end
	end
	
	cell.window:setID(idx+1) --goods index
	if self.curArgs.groupType == GROUP_BUY then
		cell.window:setSelected(self.selectedGoodsIdx == idx+1)
		if cell.timer:isVisible() then
			cell.timer:setVisible(false)
		end
	else
		cell.window:setSelected(self.selectedGoodsIdx == idx+1)
		if not cell.timer:isVisible() then
			cell.timer:setVisible(true)
		end
		local timer = self:getShowGoodsTimerAtIndex(idx+1)
		if timer then
			cell.timer:setText(timer)
		end
	end

	local goods = self:getGoodsDataAtIndex(idx+1)
	if goods then
        cell.goodsId = goods.id
		cell.itemcell:setID(goods.itemid) --item id
		cell.itemcell:setID2(idx) --tableview cell index
		cell.itemcell:SetTextUnit("")
		cell.price:setText(MoneyFormat(goods.price))
		cell.itemtype = goods.itemtype
		cell.attentionBg:setID(goods.attentionnumber)
		cell.isAttentioned = self:isGoodsAttentioned(goods.id)
		self:setHeartCount(cell, goods.attentionnumber)
		cell.numText:setText("")
        cell.levelText:setText("")

		if goods.itemtype == STALL_GOODS_T.ITEM then
			local itemAttr = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(goods.itemid)
			if itemAttr then
                local firstType = itemAttr.itemtypeid % 16
                cell.isEquip = (firstType == eItemType_EQUIP)

                cell.name:setProperty("TextColours", "ff50321a")
				cell.name:setText(itemAttr.name)
				local image = gGetIconManager():GetImageByID(itemAttr.icon)
                SetItemCellBoundColorByQulityItem(cell.itemcell, itemAttr.nquality, itemAttr.itemtypeid)
                cell.itemcell:SetStyle(CEGUI.ItemCellStyle_IconInside)
				cell.itemcell:SetImage(image)

				if itemAttr.maxNum > 1 then --可堆叠的物品
					print("item maxnum", itemAttr.maxNum)
                    cell.numText:setText(goods.num>1 and goods.num or "")
				end
                
                if goods.level > 10 then
					cell.levelText:setText(goods.level .. "级")
				end
			end
		elseif goods.itemtype == STALL_GOODS_T.PET then
            cell.isEquip = false
			local petAttr = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(goods.itemid)
            if petAttr then
                cell.name:setProperty("TextColours", "ff8c5e2a")
				cell.name:setText(petAttr.name)
			  --  cell.name:setText("[colour=\'" .. petAttr.colour .. "\']" .. petAttr.name)
			    local shapeData = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(petAttr.modelid)
			    local image = gGetIconManager():GetImageByID(shapeData.littleheadID)
                cell.itemcell:SetStyle(CEGUI.ItemCellStyle_IconExtend)
			    cell.itemcell:SetImage(image)
                SetItemCellBoundColorByQulityPet(cell.itemcell, petAttr.quality)
			    --cell.itemcell:SetTextUnit("")
            end
		end
		
		
		if self.curArgs.groupType == GROUP_BUY and self.requireItemId and self.requireItemId == goods.itemid then
			--显示需求角标
            cell.cornerImg:setProperty("Image", "set:ccui1 image:newxq");
			if idx == 0 then
				cell.window:setSelected(true)
			end
		elseif cell.isAttentioned then
			--显示关注角标
            cell.cornerImg:setProperty("Image", "set:ccui1 image:newgz");
			
		elseif goods.itemtype == STALL_GOODS_T.PET or ShopManager:needShowRarityIcon(goods.itemtype, goods.itemid) then
			--显示珍品角标
            cell.cornerImg:setProperty("Image", "set:ccui1 image:newzp");
		else
			--cell.itemcell:SetCornerImageAtPos(nil, 0, 0)
            cell.cornerImg:setProperty("Image", "");
		end

        --珍品显示关注
        --点卡服/宠物/珍品
        if IsPointCardServer() or goods.itemtype == STALL_GOODS_T.PET or ShopManager:isRarity(goods.itemtype, goods.itemid) then
            cell.attentionBg:setVisible(true)
        else
            cell.attentionBg:setVisible(false)
        end

        if goods.id == self.chatStallGoodsId then
            cell.window:setSelected(true)
        end
	end
	return cell
end

function StallDlg:goodsTableViewReachEdge(tableView, isTop)
    tableView.scroll:getVertScrollbar():Stop()
    tableView.scroll:getVertScrollbar():setScrollPosition(0)
    if isTop then
        self:handleLastPageClicked(nil)
    else
        self:handleNextPageClicked(nil)
    end
end


------[[ utils ]]------

--是否可以上架出售
function StallDlg.canSellItem(itemkey)
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local roleItem = roleItemManager:GetBagItem(itemkey)
	if not roleItem then
		return false
	end

	if roleItem:isBind() then
        GetCTipsManager():AddMessageTipById(160209) --此物品已绑定，无法上架
        return false
    end

	if roleItem:GetObject().data.markettime > gGetServerTime() then
		GetCTipsManager():AddMessageTipById(160447) --冻结期物品无法摆摊
		return false
	end

	if roleItem:GetItemTypeID() == ITEM_TYPE.HORSE then
		local rideItemId = RoleItemManager.getInstance():getRideItemId()
		if rideItemId ~= 0 and rideItemId == roleItem:GetObjectID() then
			local num = roleItemManager:GetItemNumByBaseID(rideItemId)
			if num == 1 then
				GetCTipsManager():AddMessageTipById(180000) --请先下坐骑
				return false
			end
		end
	end

	return true
end

--切换分页时显示隐藏某些元素
function StallDlg:refreshShowHide(btn, isTabBtn)
	if isTabBtn then
		self.buyAndShowView:setVisible( btn == GROUP_BUY or btn == GROUP_SHOW )
		self.sellView:setVisible( btn == GROUP_SELL )
		self.buyBtn:setVisible( btn == GROUP_BUY )
		self.showTipText:setVisible( btn == GROUP_SHOW )
		self.buyCatalog1List:setVisible( btn == GROUP_BUY )
		self.buyGoodsBg:setVisible( btn == GROUP_BUY )
		self.showCatalog1List:setVisible( btn == GROUP_SHOW )
		self.showGoodsBg:setVisible( btn == GROUP_SHOW )
	else
		self.stallItemScroll:setVisible( btn == self.stallItemBtn )
		self.stallPetScroll:setVisible( btn == self.stallPetBtn )
	end
end

--根据一级菜单id选择一级菜单相应按钮
function StallDlg:selectCatalog1BtnById(id, check)
	if check == nil and not self.isSearchMode then
        check = true
    end
	if check and not self.curArgs:haveSpecifyGoods() then
		self.curArgs:reset()
		id = 0  --如果没有选择特定的商品，则选择关注
	end
	
	SetVeticalScrollCellTop(self.curArgs.catalog1Scroll, self.curArgs.catalog1Btns[id])
	
	local btn = self.curArgs.catalog1Btns[id]
	if btn then
		if not btn:isSelected() then
			btn:setSelected(true)
		end
		return
	end
end

--按照摆摊三级表里的顺序排序物品
function StallDlg:sortBagItems(roleItems)
	if roleItems:size() < 2 then
		return
	end
	
	for i=0, roleItems:size()-2 do
		for j=i+1, roleItems:size()-1 do
			local idi = roleItems[i]:GetObjectID()
			local idj = roleItems[j]:GetObjectID()
			local itemi = ShopManager.marketThreeTable[idi]
			local itemj = ShopManager.marketThreeTable[idj]
			if itemi and itemj then
				if itemi.firstno > itemj.firstno then
					roleItems[i], roleItems[j] = roleItems[j], roleItems[i]
				elseif itemi.firstno == itemj.firstno and itemi.twono > itemj.twono then
					roleItems[i], roleItems[j] = roleItems[j], roleItems[i]
				elseif itemi.firstno == itemj.firstno and itemi.twono == itemj.twono and itemi.id > itemj.id then
					roleItems[i], roleItems[j] = roleItems[j], roleItems[i]
				end
			end
		end
	end
end

--检查我的摊位上的商品是否过期并刷一遍公示时间
function StallDlg:refreshMyStallGoodsState()
	local timestamp = gGetServerTime()
	for _,v in pairs(self.myStallGoods) do
		--print('my stall goods expiretime', timestamp, v.goods.expiretime)
		if not v.outdate and v.goods.expiretime > 0 and timestamp >= v.goods.expiretime then
			v.itemcell:SetCornerImageAtPos("ccui1", "newgq", 0, 1)
			v.outdate = true
            LogWar(string.format("(debug)[Stall] outdate, goodsid:%.0f, expiretime:%.0f, curtime:%.0f", v.goods.id, v.goods.expiretime, timestamp))
		end
	end
	
	self:refreshMyStallGoodsShowTime()
end

--设置商品cell上显示的关注度
function StallDlg:setHeartCount(goodscell, num)
	local maxnum = 10
	local _, y = GetPositionOffsetByAnchor(goodscell.heartBg, 0, 1)
	local h = goodscell.heartBgH * math.min(1, num/maxnum)
	goodscell.heartBg:setHeight(CEGUI.UDim(0, h))
	SetPositionYOffset(goodscell.heartBg, y, 1)
	SetPositionYOffset(goodscell.heart, h, 1)
end

function StallDlg:isGoodsAttentioned(goodsid)
    if ShopManager.attentionGoodsIds and ShopManager.attentionGoodsIds[goodsid] then
        return ShopManager.attentionGoodsIds[goodsid]
    end
	return false
end

function StallDlg:getAttentionNum(groupType)
    if ShopManager.attentionGoodsIds then
        return ShopManager.attentionGoodsIds.num[groupType]
    end
    return 0
end

--隐藏商品cell上的‘需求’角标
function StallDlg:hideRequireGoods()
	if self.requireItemId then
		if self.buyGoodsTable then
			for _,v in pairs(self.buyGoodsTable.visibleCells) do
				if v.itemcell:getID() == self.requireItemId then
					if ShopManager:needShowRarityIcon(v.itemtype, self.requireItemId) then
						v.itemcell:SetCornerImageAtPos("ccui1", "newzp", 0, 1) --显示珍品角标
					else
						v.itemcell:SetCornerImageAtPos(nil, 0, 0)
					end
				end
			end
		end
		self.requireItemId = nil
	end
end

--self.selectedGoodsIdx从1开始
function StallDlg:getSelectedGoodsCell()
	if self.selectedGoodsIdx == 0 or not self.curArgs then
		return nil
	end
	local tableview = (self.curArgs.groupType==GROUP_BUY and self.buyGoodsTable or self.showGoodsTable)
	return tableview:getCellAtIdx(self.selectedGoodsIdx-1)
end

function StallDlg:refreshThirdMenuBtnText(catalog3Id, limitmin, limitmax)
    if not self.curArgs or not catalog3Id or catalog3Id == 0 then
        self.thirdmenuBtn:setVisible(false)
        return
    end

    local thirdconf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cmarketthreetable")):getRecorder(catalog3Id)
    if thirdconf.logictype == LOGIC_NONE then
		self.thirdmenuBtn:setVisible(false)
        return
    end

	self.thirdmenuBtn:setVisible(true)

    self.curArgs.goodsType = thirdconf.itemtype
	self.curArgs.logicType = thirdconf.logictype

    --三级菜单的分类方式：1.等级 2.物品id 3.品质区间 4.等级区间
	if self.curArgs.logicType == LOGIC_LEVEL or self.curArgs.logicType == LOGIC_ITEM then
		self.thirdmenuBtn:setText(thirdconf.name)
			
	elseif self.curArgs.logicType == LOGIC_QUALITY_RANGE or self.curArgs.logicType == LOGIC_LEVEL_RANGE then
		if self.curArgs.waitingForDefault then
			if self:getGoodsCountAtCurPage() > 0 then
				self.thirdmenuBtn:setText(limitmin .. "~" .. limitmax)
			else --如果没有找到商品则默认显示表里的最低区间
				self.curArgs.rangeLow = thirdconf.valuerange[0]+1
				self.curArgs.rangeHigh = thirdconf.valuerange[1]
				self.thirdmenuBtn:setText(self.curArgs.rangeLow .. "~" .. self.curArgs.rangeHigh)
			end
		end
	end
end

function StallDlg:refreshPriceOrderBtnVisible()
	if not IsPointCardServer() then
		local t = self.curArgs.catalog1
		if t == STALL_CATALOG1_T.JUNIOR_SHOUJUE or
		   t == STALL_CATALOG1_T.MEDICINE or
		   t == STALL_CATALOG1_T.FOOD or
		   t == STALL_CATALOG1_T.PATTERN or
		   t == STALL_CATALOG1_T.FUMO_JUANZHOU or
		   t == STALL_CATALOG1_T.TASK_EQUIP or
		   t == STALL_CATALOG1_T.TREASURE
		  then
			self.priceCondBtn:setVisible(false)
		else
			self.priceCondBtn:setVisible(true)
		end
	else
		self.priceCondBtn:setVisible(true)
	end
end

------[[ 界面交互 ]]------

--点击商品cell
function StallDlg:handleGoodsCellClicked(args)
	self.selectedGoodsIdx = CEGUI.toWindowEventArgs(args).window:getID()

	local goodsCell = self:getSelectedGoodsCell()
	if not goodsCell then
		return
	end

	if goodsCell.isAttentioned then
		self.attentionBtn:setText(MHSD_UTILS.get_resstring(7418)) --取消关注
	else
		self.attentionBtn:setText(MHSD_UTILS.get_resstring(7417)) --关注
	end

    local goods = self:getGoodsDataAtIndex(goodsCell.window:getID())
    if goods and gGetServerTime() - goods.showtime < 60000 then --预购1分钟内
        self.buyBtn:setText(MHSD_UTILS.get_resstring(7420)) --预购
    else
        self.buyBtn:setText(MHSD_UTILS.get_resstring(7419)) --购买
    end
end

function StallDlg:handleGoodsCellAttentionClicked(args)
	local attentionNum = CEGUI.toWindowEventArgs(args).window:getID()

	local str = MHSD_UTILS.get_resstring(11453) --关注人数
	GetCTipsManager():AddMessageTip(str .. attentionNum)
end

--点击商品cell上的itemcell
function StallDlg:handleGoodsCellItemClicked(args)
	local itemcell = CEGUI.toWindowEventArgs(args).window
	
	local tableview = (self.curArgs.groupType==GROUP_BUY and self.buyGoodsTable or self.showGoodsTable)
	local goodscell = tableview:getCellAtIdx(itemcell:getID2())
	if goodscell then
		goodscell.window:setSelected(true)
	end
	
	--show tip
    local goods = self:getGoodsDataAtIndex(itemcell:getID2()+1)
	if not goods then
		return
	end

	if goodscell.itemtype == STALL_GOODS_T.PET then
		local dlg = PetDetailDlg.getInstanceAndShow()
		dlg:setPet(goods.itemid, goods.key, goods.saleroleid)
		dlg:GetWindow():setVisible(false) --先隐藏，收到详细数据后再显示

		--switch pet tips
		if self.curArgs.catalog1 ~= 0 and (self:getGoodsCountAtCurPage() > 1 or self.curArgs.curPage >1) then
			dlg:showSwitchPageArrow(true)
			dlg:setSwitchPageCallFunc(StallDlg.handleSwitchItemTips, self)
			dlg:setCloseCallFunc(function()
				self.switchTipsState = nil
			end)
		end
		
	else
        --request tips data
        local p = require("protodef.fire.pb.item.cotheritemtips"):new()
        p.roleid = goods.saleroleid
        p.packid = fire.pb.item.BagTypes.MARKET
        p.keyinpack = goods.key
	    LuaProtocolManager:send(p)

		local pos = itemcell:GetScreenPosOfCenter()
        local roleItem = RoleItem:new()
	    roleItem:SetItemBaseData(itemcell:getID(), 0)
        roleItem:SetObjectID(itemcell:getID())
        local tip = Commontiphelper.showItemTip(itemcell:getID(), roleItem:GetObject(), true, false, pos.x, pos.y)
		tip:showSwitchPageArrow(false)
        tip.isStallTip = true
        tip.roleid = goods.saleroleid
        tip.roleItem = roleItem
        tip.itemkey = goods.key

		--switch item tips
		if self.curArgs.catalog1 ~= 0 and (roleItem:GetFirstType() == eItemType_EQUIP and (self:getGoodsCountAtCurPage() > 1 or self.curArgs.curPage > 1)) then
			tip.enableSwitch = true
			tip:setSwitchPageCallFunc(StallDlg.handleSwitchItemTips, self)
			tip:setCloseCallFunc(function()
				self.switchTipsState = nil
			end)
		end
		
		if require("logic.tips.equipcomparetipdlg").getInstanceNotCreate() then
			return
		end

		local winH = GetScreenSize().height
		local tipH = tip:GetWindow():getPixelSize().height
		if itemcell:getID2()%2 == 0 then --左列
			local x = itemcell:getParent():GetScreenPos().x + itemcell:getParent():getPixelSize().width
			local y = (winH - tipH)*0.5
			tip:GetWindow():setPosition(NewVector2(x, y))
		else
			local x = itemcell:getParent():GetScreenPos().x-tip:GetWindow():getPixelSize().width
			local y = (winH - tipH)*0.5
			tip:GetWindow():setPosition(NewVector2(x, y))
		end
	end
end

--点击我的摊位上的商品
function StallDlg:handleMyStallGoodsClicked(args)
	local n = CEGUI.toWindowEventArgs(args).window:getID()
	local cell = self.myStallGoods[n]
	if not cell then
		return
	end
	
	local parent = StallLabel.getInstance():GetWindow()
	if cell.type == STALL_GOODS_T.ITEM then
		if cell.outdate then
			local dlg = StallUpShelf.getInstanceAndShow(parent)
			dlg:setGoodsData(cell.goods)
		else
			local dlg = StallDownShelf.getInstanceAndShow(parent)
			dlg:setGoodsData(cell.goods)
		end
	else
		local dlg = StallPetUpShelf.getInstanceAndShow(parent)
		dlg:setGoodsData(cell.goods, cell.outdate)
	end
end

--点击三级菜单，弹出三级菜单列表
function StallDlg:handleThirdmenuBtnClicked(args)
	if not self.curArgs.thirdmenus or self.curArgs.thirdmenus:size() == 0 then
		return
	end

	local menu = StallThirdMenu.toggleShowHide(self.curArgs.thirdmenus, self.curArgs.catalog1, self.curArgs.thirdGroupCount)
	if menu then 
		menu:setTriggerBtn(self.thirdmenuBtn)
		menu:setButtonClickCallBack(StallDlg.handleCatalog3Clicked, self)
		menu.curGroupType = self.curArgs.groupType
		menu:setCloseCallBack(function()
			self.thirdBtnArrow:setProperty("Image", "set:common image:dowm")

			if not self.curArgs or menu.curGroupType ~= self.curArgs.groupType then
				return
			end

			--如果有分组且没有选择具体的三级菜单，则把之前选择的刷一遍
			if menu.checkBoxes and not menu.notCheckChange then
				local tmpCatalog3 = {}
				local catalog3Idx = 0
				--先确定选取的是每组中的第几个
				for _,v in pairs(self.curArgs.catalog3) do
					for i=0, self.curArgs.thirdmenus:size()-1 do
						if self.curArgs.thirdmenus[i] == v then
							catalog3Idx = i % (self.curArgs.thirdmenus:size()/self.curArgs.thirdGroupCount)
							break
						end
					end
					break
				end
				--再保存勾选上的
				for k,v in pairs(menu.checkBoxes) do
					if v:isSelected() then
						local idx = (self.curArgs.thirdmenus:size()/self.curArgs.thirdGroupCount)*(k-1) + catalog3Idx
						if self.curArgs.thirdmenus:size() > idx then
							table.insert(tmpCatalog3, self.curArgs.thirdmenus[idx])
						end
					end
				end
				--如果勾选的分组有变化则重新请求数据
				if not isTableEqual(tmpCatalog3, self.curArgs.catalog3) then
					self.curArgs.catalog3 = tmpCatalog3
					self:queryStallGoods()
				end
			end
		end)
		local pos = self.thirdmenuBtn:GetScreenPos()
		local s = self.thirdmenuBtn:getPixelSize()
		local s1 = menu.window:getPixelSize()
		SetPositionOffset(menu.window, pos.x-(s1.width-s.width)*0.8, pos.y+s.height)
		
		self.thirdBtnArrow:setProperty("Image", "set:common image:up")
	else
		self.thirdBtnArrow:setProperty("Image", "set:common image:dowm")
	end
	print('thirdmenu size', self.curArgs.thirdmenus:size())
end

--点击价格排序
function StallDlg:handlePriceCondClicked(args)
	local menu = PriceOrderMenu.toggleShowHide()
	if menu then
		menu:setTriggerBtn(self.priceCondBtn)
		menu:setButtonClickCallBack(StallDlg.handlePriceOrderClicked, self)
		
		local pos = self.priceCondBtn:GetScreenPos()
		local s = self.priceCondBtn:getPixelSize()
		local s1 = menu.window:getPixelSize()
		SetPositionOffset(menu.window, pos.x-(s1.width-s.width)*0.8, pos.y+s.height)
	end
end

function StallDlg:changePriceCondBtnImage()
	if self.isUpOrder then --升序
		self.priceBtnArrow:setProperty("Image", "set:common image:up")
	else
		self.priceBtnArrow:setProperty("Image", "set:common image:dowm")
	end
end

function StallDlg:sortGoodsByPrice(goods, isUpOrder)
	if not goods or #goods < 2 then
		return
	end
	for i=1, #goods-1 do
		for j=i+1, #goods do
			if isUpOrder and goods[i].price > goods[j].price or
				not isUpOrder and goods[i].price < goods[j].price then
				goods[i], goods[j] = goods[j], goods[i]
			end
		end
	end
end

--点击价格排序的弹出按钮
function StallDlg:handlePriceOrderClicked(btn)
	local oldOrder = self.isUpOrder
	self.isUpOrder = (btn:getID() == 1)
	self:changePriceCondBtnImage()
	
	if self.isSearchMode then
		if oldOrder ~= self.isUpOrder and self.searchGoods and #self.searchGoods > 0 then
			self:sortGoodsByPrice(self.searchGoods, self.isUpOrder)
		end
		if self.curArgs.maxPage > 0 then
			self.curArgs.curPage = 1
			self.pageText:setText("1/" .. self.curArgs.maxPage)
		end
		self:refreshGoodsList()
		
	else
		self.curArgs.curPage = 0
		self.curArgs.maxPage = 0
		self:queryStallGoods(true)
	end
end

--点击摆摊分页（购买/出售/公示）
function StallDlg:switchTabPage(groupType)
    if self.groupType == groupType then
        return
    end
    self.groupType = groupType

    if self.isSearchMode then
        self.isSearchMode = false
        self.searchProtocol = nil
        self.buyArgs:reset()
        self.showArgs:reset()
    end

	self:refreshShowHide(groupType, true)
	self.catalog2View:setVisible(false)
    self.attentionBtn:setText(MHSD_UTILS.get_resstring(7417)) --关注
	
	self.isUpOrder = true
	self:changePriceCondBtnImage()
	
	if groupType == GROUP_BUY then
		if not self.buyCatalog1ListLoaded then
			self.curArgs = self.buyArgs
			self:loadBuyCatalog1List() --初始化时会到这里，默认选中关注类
		else
			if not self.curArgs then --switch here from sell group
				self.curArgs = self.buyArgs

			elseif self.showCatalog1ListLoaded and (not self.buyArgs:isCatalogSame(self.showArgs) or self.isSearchMode) then
				self.buyArgs:copy(self.showArgs) --复制参数
				if self.buyGoodsTable then
					self.buyGoodsTable:setCellCount(0)
					self.buyGoodsTable:reloadData()
					self.noGoodsView:setVisible(true)
				end
            elseif self.showArgs.catalog1 == 0 then
                if self.showGoodsTable then
				    self.showGoodsTable:setCellCount(0)
				    self.showGoodsTable:reloadData()		
			    end
                self.noGoodsView:setVisible(true)
			end
			self.pageText:setText(self.buyArgs.curPage .. "/" .. self.buyArgs.maxPage)
			self.curArgs = self.buyArgs
			self:selectCatalog1BtnById(self.buyArgs.catalog1)
			self.curArgs.curPage = 0
			
			if self.isSearchMode then
				if self.searchProtocol then
					self.searchProtocol.sellstate = self.curArgs.groupType
					LuaProtocolManager:send(self.searchProtocol)
					self.searchGoods = {}
				end
			else
				self:queryStallGoods()
			end
		end
		
	elseif groupType == GROUP_SHOW then
		if not self.showCatalog1ListLoaded then
			self:loadShowCatalog1List()
		end
		
		if (not self.showArgs:isCatalogSame(self.buyArgs) or self.isSearchMode)
		   and self.showArgs.catalog1Btns[self.buyArgs.catalog1] ~= nil then
			self.showArgs:copy(self.buyArgs) --复制参数
			if self.showGoodsTable then
				self.showGoodsTable:setCellCount(0)
				self.showGoodsTable:reloadData()		
			end
        elseif self.showArgs.catalog1 == 0 then
            if self.showGoodsTable then
				self.showGoodsTable:setCellCount(0)
				self.showGoodsTable:reloadData()		
			end
            self.noGoodsView:setVisible(true)
		end

		self.pageText:setText(self.showArgs.curPage .. "/" .. self.showArgs.maxPage)
		self.curArgs = self.showArgs
		if not self.isSearchMode then
			if self.curArgs.logicType == LOGIC_NONE then
				self.thirdmenuBtn:setVisible(false)
			else
				self.thirdmenuBtn:setVisible(true)
			end
		end
		self:selectCatalog1BtnById(self.showArgs.catalog1)
		self.curArgs.curPage = 0
		
		if self.isSearchMode then
			if self.searchProtocol then
				self.searchProtocol.sellstate = self.curArgs.groupType
				LuaProtocolManager:send(self.searchProtocol)
				self.searchGoods = {}
			end
		else
			self:queryStallGoods()
		end
		
	else
		self.curArgs = nil
		self.stallItemBtn:setSelected(true)
		
		if not self.isRequestedMyStall then
			local p = require("protodef.fire.pb.shop.cmarketcontainerbrowse"):new()
			LuaProtocolManager:send(p)
			self.isRequestedMyStall = true
			
		elseif self.myStallGoods then
			self:refreshMyStallGoodsState()
            self:refreshBagItemsLockState()
		end
	end
end

--[[function Familychengyuandialog:OnYaoQingBtnHandler(args)
    require("logic.family.familyyaoqingdialog").getInstanceAndShow()
   -- self.DestroyDialog(true)
end--]]

--[[function StallDlg.showCommerce()
require("logic.shop.ShopLabel").showOnly(1)
	--ShopLabel.getInstance():showOnly(1)
	--self.DestroyDialog(true)
end

function StallDlg.showMallShop()
require("logic.shop.ShopLabel").showOnly(2)
	--ShopLabel.getInstance():showOnly(2)
	--self.DestroyDialog(true)
end--]]

--点击出售分页（背包物品/宠物）
function StallDlg:handleStallGroupBtnClicked(args)
	local btn = CEGUI.toWindowEventArgs(args).window
	self:refreshShowHide(btn)
	
	if btn == self.stallItemBtn then
		if not self.bagItemLoaded then
			self:refreshBagItemTable()
		end
	elseif btn == self.stallPetBtn then
		if not self.bagPetLoaded then
			self:refreshBagPetTable()
		end
	end
end

--点击二级面板周围的区域自动关闭二级菜单
function StallDlg:handleHideCatalog2View(args)
	self.catalog2View:setVisible(false)
	if self.tmpCatalog1 ~= self.curArgs.catalog1 then
		self.curArgs.catalog1Btns[self.tmpCatalog1]:setSelected(false)
		self.tmpCatalog1 = 0
		SetVeticalScrollCellTop(self.curArgs.catalog1Scroll, self.curArgs.catalog1Btns[self.curArgs.catalog1])
		self.curArgs.catalog1Btns[self.curArgs.catalog1]:setSelected(true, false)
	end
end

--点击交易记录
function StallDlg:handleTradeLogClicked(args)
	StallTradeLogDlg.getInstanceAndShow()
end

--异常处理
function StallDlg:handleycClicked(args)
	require "protodef.fire.pb.shop.cbaitanerror";
	local cbaitanerror = CBaiTanError.Create();
	LuaProtocolManager.getInstance():send(cbaitanerror);
end

--点击搜索
function StallDlg:handleSearchClicked(args)
	StallSearchDlg.getInstanceAndShow()
end

--点击出售分页的背包物品
function StallDlg:handleBagItemClicked(args)
	local cell = CEGUI.toItemCell(CEGUI.toWindowEventArgs(args).window)
	print('bagitem click', cell:getID(), cell:getID2())

    if not StallDlg.canSellItem(cell:getID2()) then
		return
	end
	
	local parent = StallLabel.getInstance():GetWindow()
	local dlg = StallUpShelf.getInstanceAndShow(parent)
	dlg:setItemKey(cell:getID2())
end

--点击出售分页的宠物
function StallDlg:handleBagPetClicked(args)
	local btn = CEGUI.toWindowEventArgs(args).window

	local cell = self.bagPetCells[btn:getID()]
	local conf = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(cell.petData.baseid)
    if not conf then return end
	local commonConf = GameTable.common.GetCCommonTableInstance():getRecorder(261) --珍品宠物出售等级限制
	local lvLimit = (commonConf.id ~= -1 and tonumber(commonConf.value) or 35)
	if conf.uselevel < lvLimit and conf.kind ~= fire.pb.pet.PetTypeEnum.SACREDANIMAL then
		local str = MHSD_UTILS.get_msgtipstring(150511)
		str = string.gsub(str, "%$parameter1%$", lvLimit)
		GetCTipsManager():AddMessageTip(str) --参战等级低于35级的宠物不能上架
		return
	end
	

	 if conf.kind == fire.pb.pet.PetTypeEnum.WILD then --野生宠物不能上架
		GetCTipsManager():AddMessageTipById(160056) --这只宠物普普通通，不能上架哦！
		return
	end
	
	if cell.petData.key == gGetDataManager():GetBattlePetID() then
		GetCTipsManager():AddMessageTipById(150509) --参战宠物不能上架
		return
	end

	local serverTime = gGetServerTime()
	if cell.petData.marketfreezeexpire > serverTime then
		local leftDay = math.ceil((cell.petData.marketfreezeexpire-serverTime) / (24*60*60*1000))
        leftDay = math.min(leftDay, conf.marketfreezetime)
		local str = MHSD_UTILS.get_msgtipstring(190021) --您购买的宠物有x天冻结期，x天后才可再次出售
		str = str:gsub("%$parameter1%$(.*)%$parameter2%$", conf.marketfreezetime .. "%1" .. leftDay)
		GetCTipsManager():AddMessageTip(str)
		return
	end
	
	local parent = StallLabel.getInstance():GetWindow()
	local dlg = StallPetUpShelf.getInstanceAndShow(parent)
	dlg:setPetData(cell.petData)
end

function StallDlg:onNumInputChanged(num)
    if not IsPointCardServer() and self.curArgs.maxPage > 1 and num > 1 then
		local t = self.curArgs.catalog1
		if t == STALL_CATALOG1_T.JUNIOR_SHOUJUE or
		   t == STALL_CATALOG1_T.TASK_EQUIP or
		   t == STALL_CATALOG1_T.PATTERN or
		   t == STALL_CATALOG1_T.TREASURE
		  then
			GetCTipsManager():AddMessageTipById(180033) --摊位有限，其他商品正在排队
            self.pageText:setText(1 .. "/" .. self.curArgs.maxPage)
            NumKeyboardDlg.DestroyDialog()
			return
		end
	end

	if num == 0 then
		self.curArgs.curPage = 1
	else
		self.curArgs.curPage = num
	end
	
	self.pageText:setText(math.min(self.curArgs.curPage, self.curArgs.maxPage) .. "/" .. self.curArgs.maxPage)
end

--点击输入页码
function StallDlg:handlePageTextClicked(args)
	if NumKeyboardDlg.getInstanceNotCreate() then
		NumKeyboardDlg.getInstanceNotCreate():SetVisible(true) --保持键盘在最上面
		return
	end
	
	local dlg = NumKeyboardDlg.getInstanceAndShow()
	if dlg then
		dlg:setTriggerBtn(self.pageText)
		dlg:setMaxValue(self.curArgs.maxPage)
		dlg:setInputChangeCallFunc(StallDlg.onNumInputChanged, self)
		if self.isSearchMode or self.curArgs.catalog1 == 0 then
			dlg:setCloseCallFunc(StallDlg.refreshGoodsList, self)
		else
			dlg:setCloseCallFunc(StallDlg.queryStallGoods, self)
		end
		
		local p = self.pageText:GetScreenPosOfCenter()
		SetPositionOffset(dlg:GetWindow(), p.x, p.y-self.pageText:getPixelSize().height*0.5-10, 0.5, 1)
	end
end

--点击上一页
function StallDlg:handleLastPageClicked(args)
	if self.curArgs.curPage - 1 > 0 then
		self.curArgs.curPage = self.curArgs.curPage - 1
		if self.isSearchMode or self.curArgs.catalog1 == 0 then
			self.pageText:setText(self.curArgs.curPage .. "/" .. self.curArgs.maxPage)
			self:refreshGoodsList()
		elseif not self.switchingPage then
            self.switchingPage = true
			self:queryStallGoods()
		end
	end
end

--点击下一页
function StallDlg:handleNextPageClicked(args)
	if not IsPointCardServer() and self.curArgs.maxPage > 1 then
		local t = self.curArgs.catalog1
		if t == STALL_CATALOG1_T.JUNIOR_SHOUJUE  or
		   t == STALL_CATALOG1_T.PATTERN or
		   t == STALL_CATALOG1_T.TREASURE
		  then
		    GetCTipsManager():AddMessageTipById(180033) --摊位有限，其他商品正在排队
		    return
		end
	end
	
	if self.curArgs.curPage + 1 <= self.curArgs.maxPage then
		self.curArgs.curPage = self.curArgs.curPage + 1
		if self.isSearchMode or self.curArgs.catalog1 == 0 then
			self.pageText:setText(self.curArgs.curPage .. "/" .. self.curArgs.maxPage)
			self:refreshGoodsList()
		elseif not self.switchingPage then
            self.switchingPage = true
			self:queryStallGoods()
		end
	end
end

--点击增加金币
function StallDlg:handleAddMoneyClicked(args)
	--GainGoldWayDlg.getInstanceAndShow()
	local dlg = StoneExchangeGoldDlg.getInstanceAndShow()
	dlg:GetWindow():setAlwaysOnTop(true)
	--dlg:GetWindow():subscribeEvent("AlphaChanged", StallDlg.handleStoneExchangeGoldDlgAlphaChanged, self)
end

--点击关注
function StallDlg:handleAttentionClicked(args)
	local goodsCell = self:getSelectedGoodsCell()
	if not goodsCell then
		GetCTipsManager():AddMessageTipById(190018) --请选择要关注的商品
		return
	end

    if not goodsCell.attentionBg:isVisible() then
        GetCTipsManager():AddMessageTipById(190023) --只有珍品可以被关注
        return
    end

    if not goodsCell.isAttentioned then
        if self:getAttentionNum(self.curArgs.groupType) >= 8 then
            GetCTipsManager():AddMessageTipById(190032) --关注商品不得超过8件
            return
        end
    end

	local p = require("protodef.fire.pb.shop.cattentiongoods"):new()
	p.id = goodsCell.goodsId
	p.itemtype = (goodsCell.isEquip and 3 or goodsCell.itemtype)
    p.attentype = self.curArgs.groupType
	p.attentiontype = (goodsCell.isAttentioned and 2 or 1) --1关注  2取消关注

	LuaProtocolManager:send(p)

end

--点击珍品的购买确认
function StallDlg:handleBuyConfrimed(goods)
	
	--如果是可堆叠的物品
	if goods.itemtype == STALL_GOODS_T.ITEM then
		local itemAttr = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(goods.itemid)
		if itemAttr and itemAttr.maxNum > 1 then --可堆叠的物品
			--打开可改数量的购买界面
			local parent = StallLabel.getInstance():GetWindow()
			local dlg = StallBuyDlg.getInstanceAndShow(parent)
			dlg:setGoodsData(goods)
			return
		end
    elseif goods.itemtype == STALL_GOODS_T.PET then
        local petAttr = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(goods.itemtype)
        if petAttr and petAttr.kind ~= fire.pb.pet.PetTypeEnum.SACREDANIMAL then --非神兽
		    local commonConf = GameTable.common.GetCCommonTableInstance():getRecorder(261) --珍品宠物出售等级限制
		    local lvLimit = (commonConf.id ~= -1 and tonumber(commonConf.value) or 35)
            if gGetDataManager():GetMainCharacterLevel() < lvLimit then
			    local str = MHSD_UTILS.get_msgtipstring(160309)
			    str = string.gsub(str, "%$parameter1%$", lvLimit)
                GetCTipsManager():AddMessageTip(str) --35级以上才可以购买珍品宠物
                return
            end
        end
	end
	
	local p = require("protodef.fire.pb.shop.cmarketbuy"):new()
	p.id = goods.id
	p.saleroleid = goods.saleroleid
	p.itemid = goods.itemid
	p.num = 1
	
	print('--------cmarketbuy-------')
	for k,v in pairs(p) do
		print(k,v)
	end
	
	--金币是否够
	local needMoney = CurrencyManager.canAfford(fire.pb.game.MoneyType.MoneyType_GoldCoin, goods.price)
	if needMoney > 0 then
		CurrencyManager.handleCurrencyNotEnough(fire.pb.game.MoneyType.MoneyType_GoldCoin, needMoney, goods.price, p, self.ownMoneyText)
		return
	end
	
	LuaProtocolManager:send(p)
end

--点击购买
function StallDlg:handleBuyClicked(args)
	local lvLimit = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(160).value) --摆摊购买和出售等级
	if lvLimit > gGetDataManager():GetMainCharacterLevel() then
		local str = MHSD_UTILS.get_msgtipstring(160057)
		str = string.gsub(str, "%$parameter1%$", lvLimit)
		GetCTipsManager():AddMessageTip(str) --30级开放摆摊功能，快升级哦！
		return
	end
	
	local goods = self:getGoodsDataAtIndex(self.selectedGoodsIdx)
	if not goods then
		return
	end
	
    if goods.itemtype == STALL_GOODS_T.ITEM then
	    --检查背包容量
	    if not CheckBagCapacityForItem(goods.itemid, 1) then
		    GetCTipsManager():AddMessageTipById(160062) --背包空间不足
		    return
	    end
    elseif goods.itemtype == STALL_GOODS_T.PET then
        --检查宠物栏数量
		if MainPetDataManager.getInstance():IsMyPetFull() then
			GetCTipsManager():AddMessageTipById(160036) --宠物栏已满，无法购买
			return
		end
    end
	
	if goods.saleroleid == gGetDataManager():GetMainCharacterID() then
		GetCTipsManager():AddMessageTipById(150508) --不能购买自己上架的商品
		return
	end
	

	-- VIP 等级判断
    local vipLevel = gGetDataManager():GetVipLevel()
    if vipLevel < 1 then
        GetCTipsManager():AddMessageTipById(193111)
        return
    end

	if ShopManager:isRarity(goods.itemtype, goods.itemid) then
		local parent = StallLabel.getInstance():GetWindow()
		local dlg = StallBuyConfirmDlg.getInstanceAndShow(parent)
		dlg:setGoodsData(goods)
		dlg:setCallBack(self, StallDlg.handleBuyConfrimed)
	else
		self:handleBuyConfrimed(goods)
	end
end

--显示上一个或下一个宠物/装备详情
function StallDlg:handleSwitchItemTips(isNext)
	if isNext then
		if self.selectedGoodsIdx == self:getGoodsCountAtCurPage() then
			if self.curArgs.curPage == self.curArgs.maxPage then
				GetCTipsManager():AddMessageTipById(190019) --这已经是最后一件商品了
			else
                self.curArgs.curPage = self.curArgs.curPage + 1
                if self.isSearchMode or self.curArgs.catalog1 == 0 then
			        self.pageText:setText(self.curArgs.curPage .. "/" .. self.curArgs.maxPage)
                    self.selectedGoodsIdx = 1
			        self:refreshGoodsList(true)

					if self.isSearchMode then
						self:refreshGoodsTip()
					end
                else
				    self.switchTipsState = WILL_SHOW_FIRST_TIP
				    self:queryStallGoods()	--请求下一页数据并显示第一个宠物的tip
                end
			end
			return
		else
			self.selectedGoodsIdx = self.selectedGoodsIdx + 1
		end
		
	else
		if self.selectedGoodsIdx == 1 then
			if self.curArgs.curPage == 1 then
				GetCTipsManager():AddMessageTipById(190020) --这已经是第一件商品了
			else
				self.curArgs.curPage = self.curArgs.curPage - 1
                if self.isSearchMode or self.curArgs.catalog1 == 0 then
			        self.pageText:setText(self.curArgs.curPage .. "/" .. self.curArgs.maxPage)
                    self.selectedGoodsIdx = 8
			        self:refreshGoodsList(true)

					if self.isSearchMode then
						self:refreshGoodsTip()
					end
                else
				    self.switchTipsState = WILL_SHOW_LAST_TIP
				    self:queryStallGoods()
                end
			end
			return
		else
			self.selectedGoodsIdx = self.selectedGoodsIdx - 1
		end
	end
	
	self:refreshGoodsTip()
end

function StallDlg:refreshGoodsTip()
	local goodsCell = self:getSelectedGoodsCell()
	if goodsCell then
		goodsCell.window:setSelected(true, false)
	end
	local goodsData = self:getGoodsDataAtIndex(self.selectedGoodsIdx)
	if goodsData then
		if goodsData.itemtype == STALL_GOODS_T.PET then
			local dlg = PetDetailDlg.getInstanceNotCreate()
			if dlg then
				dlg:setPet(goodsData.itemid, goodsData.key, goodsData.saleroleid)
			end
		else
			local dlg = Commontipdlg.getInstanceNotCreate()
			if dlg then
				--request tips data
				local p = require("protodef.fire.pb.item.cotheritemtips"):new()
				p.roleid = goodsData.saleroleid
				p.packid = fire.pb.item.BagTypes.MARKET
				p.keyinpack = goodsData.key
				LuaProtocolManager:send(p)

				local roleItem = RoleItem:new()
				roleItem:SetItemBaseData(goodsCell.itemcell:getID(), 0)
				roleItem:SetObjectID(goodsCell.itemcell:getID())

				local pos = dlg:GetWindow():GetScreenPos()
				Commontiphelper.showItemTip(goodsCell.itemcell:getID(), roleItem:GetObject(), true, false, pos.x, pos.y)
				dlg:GetWindow():setPosition(NewVector2(pos.x, pos.y))
				dlg:showSwitchPageArrow(false)
				dlg.enableSwitch = true
				dlg.isStallTip = true
				dlg.roleid = goodsData.saleroleid
				dlg.roleItem = roleItem
				dlg.itemkey = goodsData.key
			end
		end
	end
end

------[[ 事件处理 ]]------

--收到摆摊商品 p:smarketbrowse
function StallDlg:recvStallGoods(p)
    WaitingDlg.hide()
    self.switchingPage = false
	print('StallDlg:recvStallGoods', #p.goodslist)
	--test
    --[[if #p.goodslist > 0 then
        for i=1,9 do
            table.insert(p.goodslist, p.goodslist[1])
        end
    end--]]
	
	--判断收到的数据是否与当前需要展示的分类一致
	if not self.curArgs or self.curArgs.groupType ~= p.browsetype then
		return
	end
	if self.curArgs.waitingForDefault then
		if not (self.curArgs.catalog1 == p.firstno and
				self.curArgs.catalog2 == p.twono and
				isTableEqual(self.curArgs.catalog3, p.threeno))
			then
			return
		end
	else
		if not (self.curArgs.catalog1 == p.firstno and
				self.curArgs.catalog2 == p.twono and
				isTableEqual(self.curArgs.catalog3, p.threeno) and
				self.curArgs.rangeLow == p.limitmin and
				self.curArgs.rangeHigh == p.limitmax and
				self.curArgs.curPage == p.currpage)
			then
			return
		end
	end

	self.curArgs.rangeLow = p.limitmin
	self.curArgs.rangeHigh = p.limitmax

    if p.browsetype == GROUP_BUY then
		self.curBuyGoods = p.goodslist
	elseif p.browsetype == GROUP_SHOW then
		self.curShowGoods = p.goodslist
		self:genShowGoodsTimers(p.goodslist)
	end
	
	if #p.goodslist > 0 then
		self.curArgs.curPage = p.currpage
		self.curArgs.maxPage = p.totalpage
        if not IsPointCardServer() and
          (self.curArgs.logicType == LOGIC_QUALITY_RANGE or
           self.curArgs.logicType == LOGIC_LEVEL_RANGE)
          then
            self.curArgs.maxPage = math.ceil(#p.goodslist / 8)
        end
	else
		self.curArgs.curPage = 0
		self.curArgs.maxPage = 0
	end

	self.pageText:setText(self.curArgs.curPage .. "/" .. self.curArgs.maxPage)
	
    --三级菜单按钮文字
    if self.thirdmenuBtn:isVisible() then
		self:refreshThirdMenuBtnText(p.threeno[1], p.limitmin, p.limitmax)
	end
    self.curArgs.waitingForDefault = false

	self:refreshGoodsList()
	
	--show tip
	if self.switchTipsState == WILL_SHOW_FIRST_TIP then
		self.selectedGoodsIdx = 1
	elseif self.switchTipsState == WILL_SHOW_LAST_TIP then
		self.selectedGoodsIdx = 8
	end
	
	if self.selectedGoodsIdx ~= 0 then
		self:refreshGoodsTip()
	end
end

function StallDlg:genShowGoodsTimers(goodslist)
    self.showGoodsTimer = {}
	local leftTime, leftHour, leftMin
	local serverTime = gGetServerTime()
	for k,v in pairs(goodslist) do
		leftTime = math.max(math.floor((v.showtime - serverTime)/1000), 0)
		leftHour = math.floor(leftTime/3600)
		leftMin = math.floor((leftTime%3600)/60)
		if leftMin < 10 then
			if leftHour == 0 and leftMin == 0 then
				leftMin = 1
                LogWar(string.format("(debug)[Stall] show over, goodsid:%.0f, showtime:%.0f, curtime:%.0f", v.id, v.showtime, serverTime))
			end
			leftMin = "0" .. leftMin
		end
		if leftHour < 10 then
			leftHour = "0" .. leftHour
		end
		self.showGoodsTimer[k] = leftHour .. ":" .. leftMin
	end
end

--收到搜索商品
function StallDlg:recvSearchResult(p)
	print('recv search result, goods count: ' .. #p.goodslist)
	if not self.isSearchMode then
		return
	end
	
	--判断收到的数据是否与当前需要展示的分类一致
	if not self.curArgs or self.curArgs.groupType ~= p.browsetype then
		return
	end
	if not (self.curArgs.catalog1 == p.firstno and self.curArgs.catalog2 == p.twono) then
		return
	end
	
	self.searchGoods = p.goodslist
	self.isUpOrder = true
	self:sortGoodsByPrice(self.searchGoods, true)
	
	if p.browsetype == GROUP_SHOW then
		self:genShowGoodsTimers(p.goodslist)
	end
	
	if #p.goodslist > 0 then
		self.curArgs.curPage = p.currpage
		self.curArgs.maxPage = p.totalpage
	else
		self.curArgs.curPage = 0
		self.curArgs.maxPage = 0
	end
	self.pageText:setText(p.currpage .. "/" .. p.totalpage)
	
	self:refreshGoodsList()
	
end

--购买商品后的响应消息, surplusnum 剩余数量
function StallDlg:recvBuyStallGoodsRes(stallgoodsid, surplusnum)
    print("buy stall goods", stallgoodsid, surplusnum)
    if not self.curArgs or self.curArgs.groupType ~= GROUP_BUY then
        return
    end

	if self.curArgs.catalog1 == 0 then --关注
		if not self.attentionGoods then
			return
		end
		local goodslist = self.attentionGoods[GROUP_BUY]
		if goodslist then
			for k,v in pairs(goodslist) do
				if v.id == stallgoodsid then
					table.remove(goodslist, k)
					if math.ceil(k/8) == self.curArgs.curPage then
						self:refreshGoodsList()
					end
					break
				end
			end
		end
		
	elseif self.curBuyGoods then
		for k,v in pairs(self.curBuyGoods) do
			if v.id == stallgoodsid then
                if surplusnum == 0 then
				    --table.remove(self.curBuyGoods, k)
				    --self:refreshGoodsList()
					self:queryStallGoods(false)
                else
                    v.num = surplusnum
					for _,v in pairs(self.buyGoodsTable.visibleCells) do
						if v.goodsId == stallgoodsid then
							--v.itemcell:SetTextUnit(surplusnum>1 and surplusnum or "")
                            v.numText:setText(surplusnum>1 and surplusnum or "")
                            break
						end
					end
                end
				break
			end
		end
	end
end

--我的摊位上物品数量变化
function StallDlg:recvMyStallItemNumChanged(itemkey, num)
    print("my stall item sold", itemkey, num)
    if self.myStallGoods then
        for k,v in pairs(self.myStallGoods) do
		    if v.goods.key == itemkey then
                if num == 0 then
                    table.remove(self.goodslist, k)
                    self:refreshMyStallGoodsList(self.goodslist)
                else
			        v.itemcell:SetTextUnit(num>1 and num or "")
				    v.goods.num = num
                end
                break
		    end
	    end
    end
end

--背包物品数量变化
function StallDlg.onEventBagItemNumChange(bagid, itemkey, itembaseid)
	if not _instance or bagid ~= fire.pb.item.BagTypes.BAG then
		return
	end

	--不可用于摆摊
	if not ShopManager.marketThreeTable[itembaseid] then
		return
	end

	--删除物品
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local item = roleItemManager:GetBagItem(itemkey)
	if not item then
		_instance:refreshBagItemTable()
		return
	end
	
	--已显示物品的数量变化
	for i=0, _instance.bagItemTable:GetCellCount()-1 do
		local cell = _instance.bagItemTable:GetCell(i)
		if not cell:isVisible() then
			break
		end
		
		if cell:getID2() == itemkey then
			local curNum = item:GetNum()
			cell:SetTextUnit(curNum>1 and curNum or "")
			return
		end
	end

	--有添加的物品
	_instance:refreshBagItemTable()  
end

--宠物数量变化
function StallDlg.onEventPetNumChange()
	if _instance and _instance:IsVisible() and _instance.bagPetCells then
		_instance:refreshBagPetTable()
	end
end

--宠物数据变化
function StallDlg.onEventPetDataChange(key)
	if _instance and _instance.bagPetCells then
		for _,v in pairs(_instance.bagPetCells) do
			if v.petData.key == key then
				v.levelText:setText(v.petData:getAttribute(fire.pb.attr.AttrType.LEVEL))
			end
		end
	end
end

--出战宠物变化
function StallDlg.handleEventPetBattleStateChange()
	if _instance and _instance.bagPetCells then
		for _,v in pairs(_instance.bagPetCells) do
			if v.petData.key == gGetDataManager():GetBattlePetID() then --出战
				v.itemcell:SetCornerImageAtPos("ccui", "chongwu_zhan", 1, 0.5)
			else
				v.itemcell:SetCornerImageAtPos(nil, 1, 0.5)
			end
		end
	end
end

--金币兑换界面的alpha变化，因为有层级问题，这里特殊处理
--[[function StallDlg:handleStoneExchangeGoldDlgAlphaChanged(args)
	local dlg = StoneExchangeGoldDlg.getInstanceNotCreate()
	if dlg then
		if dlg:GetWindow():getAlpha() < 0.95 and self:GetWindow():getAlpha() > 0.95 then
			dlg:GetWindow():setAlpha(1)
			self:GetWindow():getParent():bringWindowAbove(dlg:GetWindow(), ShopLabel.getInstance():GetWindow())
		end
	end
end]]

function StallDlg:onWindowHidden(args)
	self.catalog2View:setVisible(false)
end

--断线重连后数据刷新
function StallDlg.onInternetReconnected()
	if _instance then
		if _instance.bagItemLoaded then --刷新背包列表
			_instance:refreshBagItemTable()
		end
		if _instance.bagPetLoaded then --刷新背包宠物列表
			_instance:refreshBagPetTable()
		end
		if _instance.isRequestedMyStall then --刷新货架
			local p = require("protodef.fire.pb.shop.cmarketcontainerbrowse"):new()
			LuaProtocolManager:send(p)

			self.switchTipsState = nil
			local dlg = PetDetailDlg.getInstanceNotCreate()
			if dlg then
				PetDetailDlg.DestroyDialog()
			end

			dlg = Commontipdlg.getInstanceNotCreate()
			if dlg then
				Commontipdlg.DestroyDialog()
			end
		end
	end
end


function StallDlg:update(dt)
    if not self:GetWindow() then
        return
    end

    if not self:GetWindow():isVisible() or self.groupType == GROUP_BUY then
        return
    end

    self.elapsed = self.elapsed + dt
    if self.elapsed > self.elapseCount * 1000 then
        self.elapseCount = self.elapseCount + 1

        --出售分页
        if self.groupType == GROUP_SELL then
		    if self.stallPetScroll:isVisible() then
                --宠物的冻结状态
			    for _,cell in pairs(self.bagPetCells) do
				    if cell.isLocked and cell.petData.marketfreezeexpire <= gGetServerTime() then
					    cell.lockImg:setVisible(false)
				    end
			    end

            elseif self.stallItemScroll:isVisible() then
                --背包物品的冻结状态
                self:refreshBagItemsLockState()
		    end
		
            if not IsPointCardServer() then
		        if self.groupType == GROUP_SELL then
                    --摊位上物品的公示倒计时
			        self:refreshMyStallGoodsShowTime()
		        end
            end

        elseif self.groupType == GROUP_SHOW then
            --公示分页，刷新公示倒计时
            if self.showGoodsTable and self.curShowGoods and #self.curShowGoods > 0 then
				self:genShowGoodsTimers(self.curShowGoods)
                for _,cell in pairs(self.showGoodsTable.visibleCells) do
					local idx = cell.window:getID()
					local timer = self:getShowGoodsTimerAtIndex(idx)
					if timer then
						cell.timer:setText(timer)
					end
				end
            end
        end
    end
end

return StallDlg
