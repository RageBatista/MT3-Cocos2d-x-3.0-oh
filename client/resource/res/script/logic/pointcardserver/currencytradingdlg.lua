require "logic.dialog"
require "logic.pointcardserver.pointcardbuycell"
require "logic.pointcardserver.pointcardrecordcell"
require "logic.pointcardserver.pointcardsellcell"
require "logic.pointcardserver.quickpointcardselldlg"
require "logic.pointcardserver.quickpointcardbuydlg"
CurrencyTradingDlg = {}
setmetatable(CurrencyTradingDlg, Dialog)
CurrencyTradingDlg.__index = CurrencyTradingDlg

local _instance
function CurrencyTradingDlg.getInstance()
	if not _instance then
		_instance = CurrencyTradingDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function CurrencyTradingDlg.getInstanceAndShow(parent)
	if not _instance then
		_instance = CurrencyTradingDlg:new()
		_instance:OnCreate(parent)
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function CurrencyTradingDlg.getInstanceNotCreate()
	return _instance
end

function CurrencyTradingDlg.DestroyDialog()
	if _instance then 
        CurrencyManager.unregisterTextWidget(_instance.m_txtFushi)
        CurrencyManager.unregisterTextWidget(_instance.m_txtGold)
        gGetRoleItemManager().m_EventPackGoldChange:RemoveScriptFunctor(_instance.m_hPackGlodChange)
        gGetDataManager().m_EventYuanBaoNumberChange:RemoveScriptFunctor(_instance.m_hPackStoneChange)
        local manager = require "logic.pointcardserver.pointcardservermanager".getInstance()
        if manager.m_isTodayNotFree then
            require "logic.qiandaosongli.loginrewardmanager"
            local mgr = LoginRewardManager.getInstance()
            if mgr.m_firstchargeState == 0 then
                local dlg = require "logic.pointcardserver.messageforpointcardnotcashdlg".getInstance()
                if dlg then
                    dlg:Show()
                end
            else
                local dlg = require "logic.pointcardserver.messageforpointcarddlg".getInstance()
                if dlg then
                    dlg:Show()
                end
            end
        end
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function CurrencyTradingDlg.ToggleOpenClose()
	if not _instance then
		_instance = CurrencyTradingDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function CurrencyTradingDlg.GetLayoutFileName()
	return "cashexchange.layout"
end

function CurrencyTradingDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, CurrencyTradingDlg)
	return self
end

function CurrencyTradingDlg:OnCreate(parent)
	Dialog.OnCreate(self, parent)
    SetPositionOfWindowWithLabel(self:GetWindow())
	local winMgr = CEGUI.WindowManager:getSingleton()

    self:GetCloseBtn():removeEvent("Clicked")
	self:GetCloseBtn():subscribeEvent("Clicked", StallLabel.DestroyDialog, nil)

    --主界面
    
    --左边3个group  gourpid  1
    self.m_gbtnTrade = CEGUI.Window.toGroupButton(winMgr:getWindow("cashexchange_main/trade"))
    self.m_gbtnTrade:setGroupID(3)
    self.m_gbtnTrade:subscribeEvent("SelectStateChanged",CurrencyTradingDlg.HandleTradeClick,self)
    self.m_gbtnPersonal = CEGUI.Window.toGroupButton(winMgr:getWindow("cashexchange_main/personal"))
    self.m_gbtnPersonal:setGroupID(3)
    self.m_gbtnPersonal:subscribeEvent("SelectStateChanged",CurrencyTradingDlg.HandlePersonalClick,self)
    self.m_gbtnRecoed = CEGUI.Window.toGroupButton(winMgr:getWindow("cashexchange_main/record"))
    self.m_gbtnRecoed:setGroupID(3)
    self.m_gbtnRecoed:subscribeEvent("SelectStateChanged",CurrencyTradingDlg.HandleRecoedClick,self)
    
    --后边两个group groupid  2
    self.m_gbtnBuy = CEGUI.Window.toGroupButton(winMgr:getWindow("cashexchange_main/ask"))
    self.m_gbtnBuy:setGroupID(2)
    self.m_gbtnBuy:subscribeEvent("SelectStateChanged",CurrencyTradingDlg.HandleBuyClick,self)
    self.m_gbtnSell = CEGUI.Window.toGroupButton(winMgr:getWindow("cashexchange_main/sell"))
    self.m_gbtnSell:setGroupID(2)
    self.m_gbtnSell:subscribeEvent("SelectStateChanged",CurrencyTradingDlg.HandleSellClick,self)
    --符石数量

    self.m_txtFushi = winMgr:getWindow("cashexchange_main/OP/nowfushidi/nowfushishu")
    self.m_txtGold = winMgr:getWindow("cashexchange_main/OP/nowfushidi/nowfushishu1")

    self.m_ownStoneNum = CurrencyManager.getOwnCurrencyMount(fire.pb.game.MoneyType.MoneyType_HearthStone)
	self.m_ownGoldNum = CurrencyManager.getOwnCurrencyMount(fire.pb.game.MoneyType.MoneyType_GoldCoin)

    self.m_txtFushi:setText(self.m_ownStoneNum)
    self.m_txtGold:setText(self.m_ownGoldNum)

    CurrencyManager.registerTextWidget(fire.pb.game.MoneyType.MoneyType_HearthStone, self.m_txtFushi)
    CurrencyManager.registerTextWidget(fire.pb.game.MoneyType.MoneyType_GoldCoin, self.m_txtGold)

    self.m_hPackGlodChange = gGetRoleItemManager().m_EventPackGoldChange:InsertScriptFunctor(CurrencyTradingDlg.OnGoldChange)
    self.m_hPackStoneChange = gGetDataManager().m_EventYuanBaoNumberChange:InsertScriptFunctor(CurrencyTradingDlg.OnStoneChange)

    --交易区

    --个人买卖
    self.m_LeftSellBg = winMgr:getWindow("cashexchange_main/jiaoyiqu/qiugoudi")
    self.m_LeftBuyBg = winMgr:getWindow("cashexchange_main/jiaoyiqu/qiugoudi1")
    self.m_CoverSell = winMgr:getWindow("cashexchange_main/jiaoyiqu/qiugoudi/wuxinxi1")
    self.m_CoverSell:setVisible(false)
    self.m_CoverBuy = winMgr:getWindow("cashexchange_main/jiaoyiqu/qiugoudi/wuxinxi2")
    self.m_CoverBuy:setVisible(false)
    self.m_CoverRecord = winMgr:getWindow("cashexchange_main/jiaoyiqu/qiugoudi/wuxinxi3")
    self.m_CoverRecord:setVisible(false)
    --交易记录
    self.m_LeftRecordBg = winMgr:getWindow("cashexchange_main/jiaoyiqu/jioayijilu")
    --求购
    self.m_BuyBg = winMgr:getWindow("cashexchange_main/OP1")
    self.m_BuyNum = winMgr:getWindow("cashexchange_main/OP/shuliang")
    self.m_BuyNum:subscribeEvent("MouseClick",CurrencyTradingDlg.HandleBuyNumClick,self)
    self.m_BuyUnit = winMgr:getWindow("cashexchange_main/OP/danjia")
    self.m_BuyUnit:subscribeEvent("MouseClick",CurrencyTradingDlg.HandleBuyUnitClick,self)
    self.m_BuyMoney = winMgr:getWindow("cashexchange_main/OP/fushinumdi1/huafei")
    self.m_BuyFee = winMgr:getWindow("cashexchange_main/OP/fushinumdi1/shouxufei")

    self.m_btnBuyReset = CEGUI.toPushButton(winMgr:getWindow("cashexchange_main/OP/reset"))
    self.m_btnBuyReset:subscribeEvent("MouseClick",CurrencyTradingDlg.HandleBuyResetClick,self)
    self.m_btnBuyAdd = CEGUI.toPushButton(winMgr:getWindow("cashexchange_main/OP/add"))
    self.m_btnBuyAdd:subscribeEvent("MouseClick",CurrencyTradingDlg.HandleBuyAddClick,self)
    self.m_btnBuyBuy = CEGUI.toPushButton(winMgr:getWindow("cashexchange_main/OP/add1"))
    self.m_btnBuyBuy:subscribeEvent("MouseClick",CurrencyTradingDlg.HandleBuyBuyClick,self)

    self.m_defaultBuyNum = winMgr:getWindow("cashexchange_main/OP/shuliangdi/inoutnotice3")
    self.m_defaultBuyUnit = winMgr:getWindow("cashexchange_main/OP/danjiadi/inputnotice4")
    self.m_defaultBuyTotal = winMgr:getWindow("cashexchange_main/OP/huafeidi/countGB3")
    self.m_defaultBuyFee = winMgr:getWindow("cashexchange_main/OP/shouxufeidi/countGB4")

    --寄存
    self.m_SellBg = winMgr:getWindow("cashexchange_main/OP2")
    self.m_SellNum = winMgr:getWindow("cashexchange_main/OP/shuliang2")
    self.m_SellNum:subscribeEvent("MouseClick",CurrencyTradingDlg.HandleSellNumClick,self)
    self.m_SellUnit = winMgr:getWindow("cashexchange_main/OP/danjia2")
    self.m_SellUnit:subscribeEvent("MouseClick",CurrencyTradingDlg.HandleSellUnitClick,self)
    self.m_SellMoney = winMgr:getWindow("cashexchange_main/OP/shourudi/shouru")
    self.m_SellFee = winMgr:getWindow("cashexchange_main/OP/shuidi/shui")

    self.m_btnSellReset = CEGUI.toPushButton(winMgr:getWindow("cashexchange_main/OP/reset1"))
    self.m_btnSellReset:subscribeEvent("MouseClick",CurrencyTradingDlg.HandleSellResetClick,self)
    self.m_btnSellAdd = CEGUI.toPushButton(winMgr:getWindow("cashexchange_main/OP/add2"))
    self.m_btnSellAdd:subscribeEvent("MouseClick",CurrencyTradingDlg.HandleSellAddClick,self)
    self.m_btnSellBuy = CEGUI.toPushButton(winMgr:getWindow("cashexchange_main/OP/add11"))
    self.m_btnSellBuy:subscribeEvent("MouseClick",CurrencyTradingDlg.HandleSellBuyClick,self)

    self.m_defaultSellNum = winMgr:getWindow("cashexchange_main/OP/shuliangdi2/inputnotice1")
    self.m_defaultSellUnit = winMgr:getWindow("cashexchange_main/OP/danjiadi2/inputnotice2")
    self.m_defaultSellTotal = winMgr:getWindow("cashexchange_main/OP/shourudi/countGB1")
    self.m_defaultSellFee = winMgr:getWindow("cashexchange_main/OP/shuidi/countGB2")

    --初始化按钮

    self.m_gbtnTrade:setSelected(true)
    self.m_gbtnBuy:setSelected(true)
    --选中求购
    self:RightGroupSelect("buy")
    --选中交易区
    self:LeftGroupSelect(1)
    
    self:InitData()

    local huoliColor = "FFF5E7D2"
    self.DefaultTextColor = "tl:"..huoliColor.." tr:"..huoliColor.." bl:"..huoliColor.." br:"..huoliColor
    huoliColor = "FFFF0000"
    self.RedTextColor = "tl:"..huoliColor.." tr:"..huoliColor.." bl:"..huoliColor.." br:"..huoliColor
    huoliColor = "FF50321A"
    self.DefaultTextColorSell = "tl:"..huoliColor.." tr:"..huoliColor.." bl:"..huoliColor.." br:"..huoliColor
    self.m_index = 1
    self.m_sellIndex = -1
    self.m_buyIndex = -1
    --列表
    --卖
    self.m_ListSell = winMgr:getWindow("cashexchange_main/jiaoyiqu/qiugoudi/jimailiebiao")

    local s = self.m_ListSell:getPixelSize()
	self.m_TableViewSell = TableView.create(self.m_ListSell)
	self.m_TableViewSell:setViewSize(s.width-20, s.height-20)
	self.m_TableViewSell:setPosition(10, 10)
	self.m_TableViewSell:setColumCount(1)
    self.m_TableViewSell:setDataSourceFunc(self, CurrencyTradingDlg.tableViewGetCellAtIndexSell)
    --买
    self.m_ListBuy = winMgr:getWindow("cashexchange_main/jiaoyiqu/qiugoudi/goumailiebiao")

    local s = self.m_ListBuy:getPixelSize()
	self.m_TableViewBuy= TableView.create(self.m_ListBuy)
	self.m_TableViewBuy:setViewSize(s.width-20, s.height-20)
	self.m_TableViewBuy:setPosition(10, 10)
	self.m_TableViewBuy:setColumCount(1)
    self.m_TableViewBuy:setDataSourceFunc(self, CurrencyTradingDlg.tableViewGetCellAtIndexBuy)

    self.m_ListRecord = winMgr:getWindow("cashexchange_main/jiaoyiqu/jioayijilu/jiluliebiao")

    local s = self.m_ListRecord:getPixelSize()
	self.m_TableViewRecord= TableView.create(self.m_ListRecord)
	self.m_TableViewRecord:setViewSize(s.width-20, s.height-20)
	self.m_TableViewRecord:setPosition(10, 10)
	self.m_TableViewRecord:setColumCount(1)
    self.m_TableViewRecord:setDataSourceFunc(self, CurrencyTradingDlg.tableViewGetCellAtIndexRecord)

    self.m_timeRefresh = 5

    self.blnResetCells = false
end
function CurrencyTradingDlg:OnGoldChange()
    local dlg = require"logic.pointcardserver.currencytradingdlg".getInstanceNotCreate()
    if dlg then
        dlg.m_ownGoldNum = CurrencyManager.getOwnCurrencyMount(fire.pb.game.MoneyType.MoneyType_GoldCoin)
        dlg:BuyChangeTextColor()
        dlg:SellChangeTextColor()
    end
end
function CurrencyTradingDlg:HandleQuickBuyClick()
    --快捷卖出  用的是卖出的手续费

    --没有记录
    local manager = require"logic.pointcardserver.pointcardservermanager".getInstance()
    if #manager.m_SpotSells == 0 then
        GetCTipsManager():AddMessageTipById(190052)
        return true   
    end
    --没有选择
    if self.m_sellIndex == -1 then
        GetCTipsManager():AddMessageTipById(190051)
        return true
    end
    --钱不够
    local unit = manager.m_SpotSells[self.m_sellIndex + 1].price
    local fee = self.m_buyfee / 100 * unit
    local feeFloor = math.floor(fee)
    if feeFloor ~= fee then
        feeFloor = feeFloor + 1
        fee = feeFloor
    end
    if self.m_ownGoldNum < (unit + fee) * self.m_buynummin then
        GetCTipsManager():AddMessageTipById(160118)
        return true
    end
    
    if self.m_index == 1 then
        local num = manager.m_SpotSells[self.m_sellIndex + 1].num
        local dlg = require "logic.pointcardserver.quickpointcardbuydlg".getInstanceAndShow()
        dlg:setData(num, unit, self.m_buyfee)
    end    

end
function CurrencyTradingDlg:HandleQuickSellClick()
    --快捷卖出  用的是卖出的手续费

    --没有记录
    local manager = require"logic.pointcardserver.pointcardservermanager".getInstance()
    if #manager.m_SpotBuys == 0 then
        GetCTipsManager():AddMessageTipById(190052)
        return true   
    end
    --没有选择
    if self.m_buyIndex == -1 then
        GetCTipsManager():AddMessageTipById(190051)
        return true
    end
    --钱不够
    if self.m_ownStoneNum < 1 then
        CurrencyManager.handleCurrencyNotEnough(fire.pb.game.MoneyType.MoneyType_HearthStone, 0, 0, 0, 0)
        return true
    end
    
    if self.m_index == 1 then
        local num = manager.m_SpotBuys[self.m_buyIndex + 1].num
        local unit = manager.m_SpotBuys[self.m_buyIndex + 1].price
        local dlg = require "logic.pointcardserver.quickpointcardselldlg".getInstanceAndShow()
        dlg:setData(num, unit, self.m_sellfee)
    end

end
function CurrencyTradingDlg:OnStoneChange()
    local dlg = require"logic.pointcardserver.currencytradingdlg".getInstanceNotCreate()
    if dlg then
        dlg.m_ownStoneNum = CurrencyManager.getOwnCurrencyMount(fire.pb.game.MoneyType.MoneyType_HearthStone)
        dlg:BuyChangeTextColor()
        dlg:SellChangeTextColor()
    end 
end
function CurrencyTradingDlg:InitData()
    local record = BeanConfigManager.getInstance():GetTableByName("fushi.cbankconfig"):getRecorder(1)
    self.m_buynummin = record.buynummin
    self.m_buynummax = record.buynummax
    self.m_buyunitmin = record.buyunitmin
    self.m_buyunitmax = record.buyunitmax
    self.m_buyfee = record.buyfee
    self.m_sellnummin = record.sellnummin
    self.m_sellnummax = record.sellnummax
    self.m_sellunitmin = record.sellunitmin
    self.m_sellunitmax = record.sellunitmax
    self.m_sellfee = record.cellfee

    self.m_buynum = 0
    self.m_buyunit = 0
    self.m_sellnum = 0
    self.m_sellunit = 0
    self.m_buytotal = 0
    self.m_buyfeetotal = 0
    self.m_selltotal = 0
    self.m_sellfeetotal= 0
end

function CurrencyTradingDlg:HandleSellUnitClick(e)
	local dlg = NumKeyboardDlg.getInstanceAndShow()
	if dlg then
		dlg:setTriggerBtn(self.m_SellUnit)
		dlg:setMaxValue(self.m_sellunitmax)
		dlg:setInputChangeCallFunc(CurrencyTradingDlg.onMoneyInputChangedForSellUnit, self)
		dlg:setCloseCallFunc(CurrencyTradingDlg.onNumCloseForSellUnit, self)
        local strbuilder = StringBuilder:new()
        strbuilder:Set("parameter1", tostring(self.m_sellunitmax))
        local content = strbuilder:GetString(MHSD_UTILS.get_msgtipstring(300017))
        strbuilder:delete()
        dlg:setMaxMsg(content)
		local p = self.m_SellUnit:GetScreenPos()
		SetPositionOffset(dlg:GetWindow(), p.x-350, p.y+130, 0.5, 1)
	end
end

function CurrencyTradingDlg:BuyChangeTextColor()
    if self.m_ownGoldNum < self.m_buytotal + self.m_buyfeetotal then
        self.m_BuyFee:setProperty("TextColours", self.RedTextColor)
        self.m_BuyMoney:setProperty("TextColours", self.RedTextColor)
    else
        self.m_BuyFee:setProperty("TextColours", self.DefaultTextColor)
        self.m_BuyMoney:setProperty("TextColours", self.DefaultTextColor)
    end
end
function CurrencyTradingDlg:SellChangeTextColor()
    if self.m_ownStoneNum < self.m_sellnum then
        self.m_SellNum:setProperty("TextColours", self.RedTextColor)
    else
        self.m_SellNum:setProperty("TextColours", self.DefaultTextColorSell)
    end
end
function CurrencyTradingDlg:onMoneyInputChangedForSellUnit(num)
    self.m_sellunit = num
    self.m_SellUnit:setText(tostring(MoneyFormat(num)))
    if self.m_sellunit > 0 then
        self.m_defaultSellUnit:setVisible(false)
    else
        self.m_SellUnit:setText("")
        self.m_defaultSellUnit:setVisible(true)
    end
    self.m_selltotal = self.m_sellnum * self.m_sellunit
    if  self.m_selltotal > 0 then
        self.m_SellMoney:setText(MoneyFormat(self.m_selltotal))
        self.m_defaultSellTotal:setVisible(false)
        self.m_defaultSellFee:setVisible(false)
    else
        self.m_SellMoney:setText("")
        self.m_defaultSellTotal:setVisible(true)
        self.m_defaultSellFee:setVisible(true)
    end
    
    local fee = self.m_sellfee / 100 * self.m_selltotal
    local feeFloor = math.floor(fee)
    if feeFloor ~= fee then
        feeFloor = feeFloor + 1
        fee = feeFloor
    end

    self.m_sellfeetotal = fee
    if self.m_sellfeetotal > 0 then
        self.m_SellFee:setText(MoneyFormat(self.m_sellfeetotal))
    else
        self.m_SellFee:setText("")
    end 
end
function CurrencyTradingDlg:onNumCloseForSellUnit()
    if self.m_sellunit < self.m_sellunitmin then
        local strbuilder = StringBuilder:new()
        strbuilder:Set("parameter1", tostring(self.m_sellunitmin))
        local content = strbuilder:GetString(MHSD_UTILS.get_msgtipstring(300010))
        strbuilder:delete()
        GetCTipsManager():AddMessageTip(content)
        self.m_sellunit = self.m_sellunitmin
        self.m_SellUnit:setText(tostring(MoneyFormat(self.m_sellunitmin)))
        if self.m_sellunit > 0 then
            self.m_defaultSellUnit:setVisible(false)
        else
            self.m_SellUnit:setText("")
            self.m_defaultSellUnit:setVisible(true)
        end
        self.m_selltotal = self.m_sellnum * self.m_sellunit
        if  self.m_selltotal > 0 then
            self.m_defaultSellTotal:setVisible(false)
            self.m_defaultSellFee:setVisible(false)
            self.m_SellMoney:setText(MoneyFormat(self.m_selltotal))
        else
            self.m_SellMoney:setText("")
            self.m_defaultSellTotal:setVisible(true)
            self.m_defaultSellFee:setVisible(true)
        end
        
        local fee = self.m_sellfee / 100 * self.m_selltotal
        local feeFloor = math.floor(fee)
        if feeFloor ~= fee then
            feeFloor = feeFloor + 1
            fee = feeFloor
        end

        self.m_sellfeetotal = fee
        if self.m_sellfeetotal > 0 then
            self.m_SellFee:setText(MoneyFormat(self.m_sellfeetotal))
        else
            self.m_SellFee:setText("")
        end
        return
    end
end

function CurrencyTradingDlg:HandleSellNumClick(e)
	local dlg = NumKeyboardDlg.getInstanceAndShow()
	if dlg then
		dlg:setTriggerBtn(self.m_SellNum)
		dlg:setMaxValue(self.m_sellnummax)
		dlg:setInputChangeCallFunc(CurrencyTradingDlg.onMoneyInputChangedForSellNum, self)
		dlg:setCloseCallFunc(CurrencyTradingDlg.onNumCloseForSellNum, self)
        local strbuilder = StringBuilder:new()
        strbuilder:Set("parameter1", tostring(self.m_sellnummax))
        local content = strbuilder:GetString(MHSD_UTILS.get_msgtipstring(300019))
        strbuilder:delete()
        dlg:setMaxMsg(content)
		local p = self.m_SellNum:GetScreenPos()
		SetPositionOffset(dlg:GetWindow(), p.x-350, p.y+130, 0.5, 1)
	end
end
function CurrencyTradingDlg:onMoneyInputChangedForSellNum(num)
    self.m_sellnum = num
    self.m_SellNum:setText(tostring(num))
    if self.m_sellnum > 0 then
        self.m_defaultSellNum:setVisible(false)
    else
        self.m_SellNum:setText("")
        self.m_defaultSellNum:setVisible(true)
    end
    self.m_selltotal = self.m_sellnum * self.m_sellunit
    if  self.m_selltotal > 0 then
        self.m_SellMoney:setText(MoneyFormat(self.m_selltotal))
        self.m_defaultSellTotal:setVisible(false)
        self.m_defaultSellFee:setVisible(false)
    else
        self.m_SellMoney:setText("")
        self.m_defaultSellTotal:setVisible(true)
        self.m_defaultSellFee:setVisible(true)
    end
    
    local fee = self.m_sellfee / 100 * self.m_selltotal
    local feeFloor = math.floor(fee)
    if feeFloor ~= fee then
        feeFloor = feeFloor + 1
        fee = feeFloor
    end

    self.m_sellfeetotal = fee
    if self.m_sellfeetotal > 0 then
        self.m_SellFee:setText(MoneyFormat(self.m_sellfeetotal))
    else
        self.m_SellFee:setText("")
    end

    self:SellChangeTextColor()
    
end
function CurrencyTradingDlg:onNumCloseForSellNum()
    if self.m_sellnum < self.m_sellnummin then
        local strbuilder = StringBuilder:new()
        strbuilder:Set("parameter1", tostring(self.m_sellnummin))
        local content = strbuilder:GetString(MHSD_UTILS.get_msgtipstring(300018))
        strbuilder:delete()
        GetCTipsManager():AddMessageTip(content)
        self.m_sellnum = self.m_sellnummin
        self.m_SellNum:setText(tostring(self.m_sellnummin))
        if self.m_sellnum > 0 then
            self.m_defaultSellNum:setVisible(false)
        else
            self.m_SellNum:setText("")
            self.m_defaultSellNum:setVisible(true)
        end
        self.m_selltotal = self.m_sellnum * self.m_sellunit
        if  self.m_selltotal > 0 then
            self.m_defaultSellTotal:setVisible(false)
            self.m_defaultSellFee:setVisible(false)
            self.m_SellMoney:setText(MoneyFormat(self.m_selltotal))
        else
            self.m_SellMoney:setText("")
            self.m_defaultSellTotal:setVisible(true)
            self.m_defaultSellFee:setVisible(true)
        end
        
        local fee = self.m_sellfee / 100 * self.m_selltotal
        local feeFloor = math.floor(fee)
        if feeFloor ~= fee then
            feeFloor = feeFloor + 1
            fee = feeFloor
        end

        self.m_sellfeetotal = fee
        if self.m_sellfeetotal > 0 then
            self.m_SellFee:setText(MoneyFormat(self.m_sellfeetotal))
        else
            self.m_SellFee:setText("")
        end

        self:SellChangeTextColor()
        return
    end
end

function CurrencyTradingDlg:HandleBuyNumClick(e)
	local dlg = NumKeyboardDlg.getInstanceAndShow()
	if dlg then
		dlg:setTriggerBtn(self.m_BuyNum)
		dlg:setMaxValue(self.m_buynummax)
		dlg:setInputChangeCallFunc(CurrencyTradingDlg.onMoneyInputChangedForBuyNum, self)
		dlg:setCloseCallFunc(CurrencyTradingDlg.onNumCloseForBuyNum, self)
        
        local strbuilder = StringBuilder:new()
        strbuilder:Set("parameter1", tostring(self.m_buynummax))
        local content = strbuilder:GetString(MHSD_UTILS.get_msgtipstring(300019))
        strbuilder:delete()
        dlg:setMaxMsg(content)
		local p = self.m_BuyNum:GetScreenPos()
		SetPositionOffset(dlg:GetWindow(), p.x-350, p.y+130, 0.5, 1)
	end
end
function CurrencyTradingDlg:onMoneyInputChangedForBuyNum(num)
    self.m_buynum = num 
    self.m_BuyNum:setText(tostring(num))
    if self.m_buynum > 0 then
        self.m_defaultBuyNum:setVisible(false)
    else
        self.m_defaultBuyNum:setVisible(true)
        self.m_BuyNum:setText("")
    end
    self.m_buytotal = self.m_buynum * self.m_buyunit
    if  self.m_buytotal > 0 then
        self.m_defaultBuyTotal:setVisible(false)
        self.m_defaultBuyFee:setVisible(false)
        self.m_BuyMoney:setText(MoneyFormat(self.m_buytotal))
    else
        self.m_defaultBuyTotal:setVisible(true)
        self.m_defaultBuyFee:setVisible(true)
        self.m_BuyMoney:setText("")
    end
    
    local fee = self.m_buyfee / 100 * self.m_buytotal
    local feeFloor = math.floor(fee)
    if feeFloor ~= fee then
        feeFloor = feeFloor + 1
        fee = feeFloor
    end

    self.m_buyfeetotal = fee
    if self.m_buyfeetotal > 0 then
        self.m_BuyFee:setText(MoneyFormat(self.m_buyfeetotal))
    else
        self.m_BuyFee:setText("")
    end
    self:BuyChangeTextColor()
end
function CurrencyTradingDlg:onNumCloseForBuyNum()
    if self.m_buynum < self.m_buynummin then
        local strbuilder = StringBuilder:new()
        strbuilder:Set("parameter1", tostring(self.m_buynummin))
        local content = strbuilder:GetString(MHSD_UTILS.get_msgtipstring(300018))
        strbuilder:delete()
        GetCTipsManager():AddMessageTip(content)
        self.m_buynum = self.m_buynummin
        self.m_BuyNum:setText(tostring(self.m_buynummin))
        if self.m_buynum > 0 then
            self.m_defaultBuyNum:setVisible(false)
        else
            self.m_defaultBuyNum:setVisible(true)
            self.m_BuyNum:setText("")
        end
        self.m_buytotal = self.m_buynum * self.m_buyunit
        if  self.m_buytotal > 0 then
            self.m_defaultBuyTotal:setVisible(false)
            self.m_defaultBuyFee:setVisible(false)
            self.m_BuyMoney:setText(MoneyFormat(self.m_buytotal))
        else
            self.m_defaultBuyTotal:setVisible(true)
            self.m_defaultBuyFee:setVisible(true)
            self.m_BuyMoney:setText("")
        end
        
        local fee = self.m_buyfee / 100 * self.m_buytotal
        local feeFloor = math.floor(fee)
        if feeFloor ~= fee then
            feeFloor = feeFloor + 1
            fee = feeFloor
        end

        self.m_buyfeetotal = fee
        if self.m_buyfeetotal > 0 then
            self.m_BuyFee:setText(MoneyFormat(self.m_buyfeetotal))
        else
            self.m_BuyFee:setText("")
        end
        self:BuyChangeTextColor()
        return
    end
end

function CurrencyTradingDlg:HandleBuyUnitClick(e)
	local dlg = NumKeyboardDlg.getInstanceAndShow()
	if dlg then
		dlg:setTriggerBtn(self.m_BuyUnit)
		dlg:setMaxValue(self.m_buyunitmax)
		dlg:setInputChangeCallFunc(CurrencyTradingDlg.onMoneyInputChangedForBuyUnit, self)
		dlg:setCloseCallFunc(CurrencyTradingDlg.onNumCloseForBuyUnit, self)
        local strbuilder = StringBuilder:new()
        strbuilder:Set("parameter1", tostring(self.m_buyunitmax))
        local content = strbuilder:GetString(MHSD_UTILS.get_msgtipstring(300017))
        strbuilder:delete()
        dlg:setMaxMsg(content)
		local p = self.m_BuyUnit:GetScreenPos()
		SetPositionOffset(dlg:GetWindow(), p.x-350, p.y+130, 0.5, 1)
	end
end
function CurrencyTradingDlg:onMoneyInputChangedForBuyUnit(num)
    self.m_buyunit = num
    self.m_BuyUnit:setText(tostring(MoneyFormat(num)))
    if self.m_buyunit > 0 then
        self.m_defaultBuyUnit:setVisible(false)
    else
        self.m_defaultBuyUnit:setVisible(true)
        self.m_BuyUnit:setText("")
    end
    self.m_buytotal = self.m_buynum * self.m_buyunit
    if  self.m_buytotal > 0 then
        self.m_defaultBuyTotal:setVisible(false)
        self.m_defaultBuyFee:setVisible(false)
        self.m_BuyMoney:setText(MoneyFormat(self.m_buytotal))
    else
        self.m_defaultBuyTotal:setVisible(true)
        self.m_defaultBuyFee:setVisible(true)
        self.m_BuyMoney:setText("")
    end
    
    local fee = self.m_buyfee / 100 * self.m_buytotal
    local feeFloor = math.floor(fee)
    if feeFloor ~= fee then
        feeFloor = feeFloor + 1
        fee = feeFloor
    end

    self.m_buyfeetotal = fee
    if self.m_buyfeetotal > 0 then
        self.m_BuyFee:setText(MoneyFormat(self.m_buyfeetotal))
    else
        self.m_BuyFee:setText("")
    end
    self:BuyChangeTextColor()
end
function CurrencyTradingDlg:onNumCloseForBuyUnit()
    if self.m_buyunit < self.m_buyunitmin then
        local strbuilder = StringBuilder:new()
        strbuilder:Set("parameter1", tostring(self.m_buyunitmin))
        local content = strbuilder:GetString(MHSD_UTILS.get_msgtipstring(300010))
        strbuilder:delete()
        GetCTipsManager():AddMessageTip(content)
        self.m_buyunit = self.m_buyunitmin
        self.m_BuyUnit:setText(tostring(MoneyFormat(self.m_buyunitmin)))
        if self.m_buyunit > 0 then
            self.m_defaultBuyUnit:setVisible(false)
        else
            self.m_defaultBuyUnit:setVisible(true)
            self.m_BuyUnit:setText("")
        end
        self.m_buytotal = self.m_buynum * self.m_buyunit
        if  self.m_buytotal > 0 then
            self.m_defaultBuyTotal:setVisible(false)
            self.m_defaultBuyFee:setVisible(false)
            self.m_BuyMoney:setText(MoneyFormat(self.m_buytotal))
        else
            self.m_defaultBuyTotal:setVisible(true)
            self.m_defaultBuyFee:setVisible(true)
            self.m_BuyMoney:setText("")
        end
        
        local fee = self.m_buyfee / 100 * self.m_buytotal
        local feeFloor = math.floor(fee)
        if feeFloor ~= fee then
            feeFloor = feeFloor + 1
            fee = feeFloor
        end

        self.m_buyfeetotal = fee
        if self.m_buyfeetotal > 0 then
            self.m_BuyFee:setText(MoneyFormat(self.m_buyfeetotal))
        else
            self.m_BuyFee:setText("")
        end
        self:BuyChangeTextColor()
        return
    end
end
function CurrencyTradingDlg:HandleBuyResetClick(e)
    self:ClearBuyNum()
end
function CurrencyTradingDlg:HandleBuyAddClick(e)
    require("logic.shop.shoplabel").showRecharge()
end
--求购
function CurrencyTradingDlg:HandleBuyBuyClick(e)
    if self.m_buytotal <=0 then
        GetCTipsManager():AddMessageTipById(190041)
        return true
    end
    if self.m_ownGoldNum < self.m_buytotal + self.m_buyfeetotal then
        GetCTipsManager():AddMessageTipById(160118)
        return true
    end

    -- 限制买入
    --local shoujianquanmgr = require "logic.shoujianquan.shoujianquanmgr"
    --if shoujianquanmgr.needBindTelAgain() then
      --  require("logic.shoujianquan.shoujiyanzheng").getInstanceAndShow()
      --  return
   -- elseif shoujianquanmgr.notBind7Days() then
      --  require("logic.shoujianquan.shoujiguanlianqueren").getInstanceAndShow()
     --   return
  --  end

    local function ClickYes(self, args)
        local p = require("protodef.fire.pb.fushi.spotcheck.cbuyspotcard"):new()
        p.buynum = self.m_buynum
        p.buyprice = self.m_buyunit
        LuaProtocolManager:send(p)
        gGetMessageManager():CloseConfirmBox(eConfirmNormal, false)
    end
    local function ClickNo(self, args)
        gGetMessageManager():CloseConfirmBox(eConfirmNormal, false)
    end
    local strbuilder = StringBuilder:new()
    strbuilder:Set("parameter1", tostring(self.m_buynum))
    strbuilder:Set("parameter2", tostring(self.m_buyunit * self.m_buynum))
    local content = strbuilder:GetString(MHSD_UTILS.get_resstring(11549))
    gGetMessageManager():AddConfirmBox(eConfirmNormal, content, ClickYes, 
    self, ClickNo, self,0,0,nil,MHSD_UTILS.get_resstring(2035),MHSD_UTILS.get_resstring(2036))
    strbuilder:delete()
end

function CurrencyTradingDlg:HandleSellResetClick(e)
    self:ClearSellNum()
end
function CurrencyTradingDlg:HandleSellAddClick(e)
    require("logic.shop.shoplabel").showRecharge()
end
--寄卖
function CurrencyTradingDlg:HandleSellBuyClick(e)
    if self.m_selltotal <=0 then
        GetCTipsManager():AddMessageTipById(190041)
        return true
    end
    if self.m_ownStoneNum < self.m_sellnum then
        CurrencyManager.handleCurrencyNotEnough(fire.pb.game.MoneyType.MoneyType_HearthStone, 0, 0, 0, 0)
        return true
    end

    -- 限制卖出
   -- local shoujianquanmgr = require "logic.shoujianquan.shoujianquanmgr"
    --if shoujianquanmgr.needBindTelAgain() then
    --    require("logic.shoujianquan.shoujiyanzheng").getInstanceAndShow()
    --    return
   -- elseif shoujianquanmgr.notBind7Days() then
     --   require("logic.shoujianquan.shoujiguanlianqueren").getInstanceAndShow()
    --    return
   -- end

    local function ClickYes(self, args)
        local p = require("protodef.fire.pb.fushi.spotcheck.csellspotcard"):new()
        p.sellnum = self.m_sellnum
        p.sellprice = self.m_sellunit
        LuaProtocolManager:send(p)
        gGetMessageManager():CloseConfirmBox(eConfirmNormal, false)
    end
    local function ClickNo(self, args)
        gGetMessageManager():CloseConfirmBox(eConfirmNormal, false)
    end
    local strbuilder = StringBuilder:new()
    strbuilder:Set("parameter1", tostring(self.m_sellnum))
    strbuilder:Set("parameter2", tostring(self.m_sellunit * self.m_sellnum))
    local content = strbuilder:GetString(MHSD_UTILS.get_resstring(11538))
    gGetMessageManager():AddConfirmBox(eConfirmNormal, content, ClickYes, 
    self, ClickNo, self,0,0,nil,MHSD_UTILS.get_resstring(2035),MHSD_UTILS.get_resstring(2036))
    strbuilder:delete()

end

function CurrencyTradingDlg:HandleTradeClick(e)
    self:LeftGroupSelect(1)
end
function CurrencyTradingDlg:HandlePersonalClick(e)
    self:LeftGroupSelect(2)
end
function CurrencyTradingDlg:HandleRecoedClick(e)
    self:LeftGroupSelect(3)
end
function CurrencyTradingDlg:HandleBuyClick(e)
    self:RightGroupSelect("buy")
end
function CurrencyTradingDlg:HandleSellClick(e)
    self:RightGroupSelect("sell")
end

function CurrencyTradingDlg:LeftGroupSelect(id)
    self.m_index = id
    self.resetCells = true
    if id == 1 then
        --交易区
        self.m_LeftSellBg:setVisible(true)
        self.m_LeftBuyBg:setVisible(true)
        self.m_LeftRecordBg:setVisible(false)
        local p = require("protodef.fire.pb.fushi.spotcheck.ctradingspotcardview"):new()
        LuaProtocolManager:send(p)
        self.m_timeRefresh = 5
    elseif id == 2 then
        --个人买卖
        self.m_LeftSellBg:setVisible(true)
        self.m_LeftBuyBg:setVisible(true)
        self.m_LeftRecordBg:setVisible(false)
        local p = require("protodef.fire.pb.fushi.spotcheck.croletradingview"):new()
        LuaProtocolManager:send(p)
    elseif id == 3 then
        --交易记录
        self.m_LeftSellBg:setVisible(false)
        self.m_LeftBuyBg:setVisible(false)
        self.m_LeftRecordBg:setVisible(true)
        local p = require("protodef.fire.pb.fushi.spotcheck.croletradingrecordview"):new()
        LuaProtocolManager:send(p)
    end


end
function CurrencyTradingDlg:update(delta)
    if self.m_index == 1 then
        if self.m_timeRefresh <= 0 then
            self.m_timeRefresh = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(362).value)
            local p = require("protodef.fire.pb.fushi.spotcheck.ctradingspotcardview"):new()
            LuaProtocolManager:send(p)
        end
        self.m_timeRefresh = self.m_timeRefresh - delta / 1000
    end
end
function CurrencyTradingDlg:refreshDataSpot()
    self.m_sellIndex = -1
    self.m_buyIndex = -1
    if self.m_index ~= 1 then
        return
    end
    local manager = require"logic.pointcardserver.pointcardservermanager".getInstance()
    local size = #manager.m_SpotSells 

    if size == 0 then
        self.m_CoverSell:setVisible(true)
    else
        self.m_CoverSell:setVisible(false)
    end
    if self.blnResetCells then
        self.m_TableViewSell:destroyCells()
        self.m_TableViewSell:clear()
    end

	self.m_TableViewSell:setCellCountAndSize(TableUtil.tablelength(manager.m_SpotSells), 475, 30)
	self.m_TableViewSell:reloadData()

    size = #manager.m_SpotBuys 

    if size == 0 then
        self.m_CoverBuy:setVisible(true)
    else
        self.m_CoverBuy:setVisible(false)
    end
    if self.blnResetCells then
        self.m_TableViewBuy:destroyCells()
        self.m_TableViewBuy:clear()
    end
	self.m_TableViewBuy:setCellCountAndSize(TableUtil.tablelength(manager.m_SpotBuys), 475, 30)
	self.m_TableViewBuy:reloadData()


end
function CurrencyTradingDlg:refreshDataRole()
    self.m_sellIndex = -1
    self.m_buyIndex = -1
    if self.m_index ~= 2 then
        return
    end
    local manager = require"logic.pointcardserver.pointcardservermanager".getInstance()
    local size = #manager.m_RoleSells 

    if size == 0 then
        self.m_CoverSell:setVisible(true)
    else
        self.m_CoverSell:setVisible(false)
    end
    self.m_TableViewSell:destroyCells()
    self.m_TableViewSell:clear()
	self.m_TableViewSell:setCellCountAndSize(TableUtil.tablelength(manager.m_RoleSells), 475, 30)
	self.m_TableViewSell:reloadData()

    size = #manager.m_RoleBuys 

    if size == 0 then
        self.m_CoverBuy:setVisible(true)
    else
        self.m_CoverBuy:setVisible(false)
    end
    self.m_TableViewBuy:destroyCells()
    self.m_TableViewBuy:clear()

	self.m_TableViewBuy:setCellCountAndSize(TableUtil.tablelength(manager.m_RoleBuys), 475, 30)
	self.m_TableViewBuy:reloadData()
    
end
function CurrencyTradingDlg:refreshDataRecord()
    self.m_sellIndex = -1
    self.m_buyIndex = -1
    local manager = require"logic.pointcardserver.pointcardservermanager".getInstance()
    local size = #manager.m_Records 

    if size == 0 then
        self.m_CoverRecord:setVisible(true)
    else
        self.m_CoverRecord:setVisible(false)
    end
    self.m_TableViewRecord:clear()
	self.m_TableViewRecord:setCellCountAndSize(TableUtil.tablelength(manager.m_Records), 480, 50)
	self.m_TableViewRecord:reloadData()
end
function CurrencyTradingDlg:RightGroupSelect(str)
    if str == "buy" then
        self.m_BuyBg:setVisible(true)
        self.m_SellBg:setVisible(false)
    elseif str == "sell" then
        self.m_BuyBg:setVisible(false)
        self.m_SellBg:setVisible(true)
    end

end

function CurrencyTradingDlg:ClearBuyNum()
    self.m_BuyNum:setText("")
    self.m_BuyUnit:setText("")
    self.m_BuyMoney:setText("")
    self.m_BuyFee:setText("")
    self.m_defaultBuyNum:setVisible(true)
    self.m_defaultBuyUnit:setVisible(true)
    self.m_defaultBuyTotal:setVisible(true)
    self.m_defaultBuyFee:setVisible(true)
    self.m_buynum = 0
    self.m_buyunit = 0
    self.m_buytotal = 0
    self.m_buyfeetotal = 0

end

function CurrencyTradingDlg:ClearSellNum()
    self.m_SellNum:setText("")
    self.m_SellUnit:setText("")
    self.m_SellMoney:setText("")
    self.m_SellFee:setText("")
    self.m_defaultSellNum:setVisible(true)
    self.m_defaultSellUnit:setVisible(true)
    self.m_defaultSellTotal:setVisible(true)
    self.m_defaultSellFee:setVisible(true)
    self.m_sellnum = 0
    self.m_sellunit = 0
    self.m_selltotal = 0
    self.m_sellfeetotal= 0
end

function CurrencyTradingDlg:tableViewGetCellAtIndexSell(tableView, idx, cell)
	if not cell then
		cell = PointCardSellCell.CreateNewDlg(tableView.container)
		cell.window:subscribeEvent("MouseClick", CurrencyTradingDlg.HandleSellCellClicked, self)
        cell.m_btnDelete:subscribeEvent("MouseClick", CurrencyTradingDlg.HandleSellDeleteClicked, self)
	end
    local manager = require"logic.pointcardserver.pointcardservermanager".getInstance()
    if self.m_index == 1 then
        cell:setDataForSpot(manager.m_SpotSells[idx + 1], idx + 1, #manager.m_SpotSells)
    else
        cell:setDataForRole(manager.m_RoleSells[idx + 1], idx + 1, #manager.m_RoleSells)
    end
    cell.m_btnDelete:setID(idx)
	cell.window:setID(idx)
	return cell
end

function CurrencyTradingDlg:tableViewGetCellAtIndexBuy(tableView, idx, cell)
	if not cell then
		cell = PointCardBuyCell.CreateNewDlg(tableView.container)
		cell.window:subscribeEvent("MouseClick", CurrencyTradingDlg.HandleBuyCellClicked, self)
        cell.m_btnDelete:subscribeEvent("MouseClick", CurrencyTradingDlg.HandleBuyDeleteClicked, self)
	end
    local manager = require"logic.pointcardserver.pointcardservermanager".getInstance()
    if self.m_index == 1 then
        cell:setDataForSpot(manager.m_SpotBuys[idx + 1], idx + 1)
    else
        cell:setDataForRole(manager.m_RoleBuys[idx + 1], idx + 1)
    end
    cell.m_btnDelete:setID(idx)
	cell.window:setID(idx)
	return cell
end
function CurrencyTradingDlg:HandleSellCellClicked(e)
    if self.m_index == 1 then
        local eventargs = CEGUI.toWindowEventArgs(e)
        local id = eventargs.window:getID()
        self.m_sellIndex = id
        self:HandleQuickBuyClick()
    end
end
function CurrencyTradingDlg:HandleBuyCellClicked(e)
    if self.m_index == 1 then
        local eventargs = CEGUI.toWindowEventArgs(e)
        local id = eventargs.window:getID()
        self.m_buyIndex = id
        self:HandleQuickSellClick()
    end
end
function CurrencyTradingDlg:HandleSellDeleteClicked(e)
    if self.m_index == 2 then
        local eventargs = CEGUI.toWindowEventArgs(e)
        local id = eventargs.window:getID()
        local manager = require"logic.pointcardserver.pointcardservermanager".getInstance()
	    if manager.m_RoleSells[id + 1] then
            local function ClickYes(self, args)
                local p = require("protodef.fire.pb.fushi.spotcheck.ccanceltrading"):new()
                p.tradingid = manager.m_RoleSells[id + 1].tradingid
                LuaProtocolManager:send(p)
                gGetMessageManager():CloseConfirmBox(eConfirmNormal, false)
            end
            local function ClickNo(self, args)
                gGetMessageManager():CloseConfirmBox(eConfirmNormal, false)
            end
            gGetMessageManager():AddConfirmBox(eConfirmNormal, MHSD_UTILS.get_resstring(11539), ClickYes, 
            self, ClickNo, self,0,0,nil,MHSD_UTILS.get_resstring(2035),MHSD_UTILS.get_resstring(2036))
        end
    end
end
function CurrencyTradingDlg:HandleBuyDeleteClicked(e)
    if self.m_index == 2 then
        local eventargs = CEGUI.toWindowEventArgs(e)
        local id = eventargs.window:getID()
        local manager = require"logic.pointcardserver.pointcardservermanager".getInstance()
	    if manager.m_RoleBuys[id + 1] then
            local function ClickYes(self, args)
                local p = require("protodef.fire.pb.fushi.spotcheck.ccanceltrading"):new()
                p.tradingid = manager.m_RoleBuys[id + 1].tradingid
                LuaProtocolManager:send(p)
                gGetMessageManager():CloseConfirmBox(eConfirmNormal, false)
            end
            local function ClickNo(self, args)
                gGetMessageManager():CloseConfirmBox(eConfirmNormal, false)
            end
            gGetMessageManager():AddConfirmBox(eConfirmNormal, MHSD_UTILS.get_resstring(11539), ClickYes, 
            self, ClickNo, self,0,0,nil,MHSD_UTILS.get_resstring(2035),MHSD_UTILS.get_resstring(2036))
        end
    end
end

function CurrencyTradingDlg:tableViewGetCellAtIndexRecord(tableView, idx, cell)
	if not cell then
		cell = PointCardRecordCell.CreateNewDlg(tableView.container)
	end
    local manager = require"logic.pointcardserver.pointcardservermanager".getInstance()
	cell:setData(manager.m_Records[idx + 1])
	cell.window:setID(idx)
	return cell
end

return CurrencyTradingDlg