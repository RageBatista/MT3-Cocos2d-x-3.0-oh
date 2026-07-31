------------------------------------------------------------------
-- 符石金币兑换银币
------------------------------------------------------------------
require "logic.dialog"

StoneGoldExchangeSilverDlg = {}
setmetatable(StoneGoldExchangeSilverDlg, Dialog)
StoneGoldExchangeSilverDlg.__index = StoneGoldExchangeSilverDlg

local _instance
function StoneGoldExchangeSilverDlg.getInstance()
	if not _instance then
		_instance = StoneGoldExchangeSilverDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function StoneGoldExchangeSilverDlg.getInstanceAndShow()
	if not _instance then
		_instance = StoneGoldExchangeSilverDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function StoneGoldExchangeSilverDlg.getInstanceNotCreate()
	return _instance
end

function StoneGoldExchangeSilverDlg.DestroyDialog()
	if _instance then
	_instance.exchangeBtn.animation:stop()
	_instance.cancelBtn.animation:stop()
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function StoneGoldExchangeSilverDlg.ToggleOpenClose()
	if not _instance then
		_instance = StoneGoldExchangeSilverDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function StoneGoldExchangeSilverDlg.GetLayoutFileName()
	return "duihuanyinbi.layout"
end

function StoneGoldExchangeSilverDlg:addButtonAnimation(button, animationName)
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


function StoneGoldExchangeSilverDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, StoneGoldExchangeSilverDlg)
	return self
end

function StoneGoldExchangeSilverDlg:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
	self.exchangeType = 0   -- 0：符石 1: 金币
	
	self.m_ccdhyb = winMgr:getWindow("duihuanyinbi/jiemian")

    local aniMan = CEGUI.AnimationManager:getSingleton()
    local animationOpen = aniMan:getAnimation("FrameWindow3ani") 
    self.animationInstance = aniMan:instantiateAnimation(animationOpen) 
    self.animationInstance:setTargetWindow(self.m_ccdhyb)
    self.animationInstance:start()
	
	self.stoneNum_st = winMgr:getWindow("duihuanyinbi/jiemian/zhi2")
	self.exchangeNum_st = winMgr:getWindow("duihuanyinbi/jiemian/zhi3/zhi")
	self.silverNum_st = winMgr:getWindow("duihuanyinbi/jiemian/zhi4")

	self.cancelBtn = CEGUI.toPushButton(winMgr:getWindow("duihuanyinbi/jiemian/quxiao"))
	self:addButtonAnimation(self.cancelBtn, "studyBtnPress")
	self.exchangeBtn = CEGUI.toPushButton(winMgr:getWindow("duihuanyinbi/jiemian/duihuan"))
	self:addButtonAnimation(self.exchangeBtn, "studyBtnPress")

    self.tipsButton = CEGUI.toPushButton(winMgr:getWindow("duihuanyinbi/jiemian/tips"))       --tips button
    self.tipsButton:subscribeEvent("Clicked", StoneGoldExchangeSilverDlg.handleClickTipButton, self)

	self.cancelBtn:subscribeEvent("Clicked", StoneGoldExchangeSilverDlg.handleCancelClicked, self)
	self.exchangeBtn:subscribeEvent("Clicked", StoneGoldExchangeSilverDlg.handleExchangeClicked, self)
	self.exchangeNum_st:subscribeEvent("MouseClick", StoneGoldExchangeSilverDlg.handleStoneNumClicked, self)
	
	-- 兑换方式
    self.exchangeGold_cb = CEGUI.toCheckbox(winMgr:getWindow("duihuanyinbi/jiemian/xuanze2"))
	self.exchangeGold_cb:subscribeEvent("CheckStateChanged" , StoneGoldExchangeSilverDlg.HandleExchangeTypeChange, self)
	self.exchangeGold_cb:setUserString("name", "checkbox_gold")

	self.exchangeStone_cb = CEGUI.toCheckbox(winMgr:getWindow("duihuanyinbi/jiemian/xuanze1"))
    if IsPointCardServer() then
        self.exchangeGold_cb:setMousePassThroughEnabled(true)
        self.exchangeStone_cb:setVisible(false)
        self.exchangeGold_cb:setXPosition(self.exchangeStone_cb:getXPosition())
    else
	    self.exchangeStone_cb:subscribeEvent("CheckStateChanged", StoneGoldExchangeSilverDlg.HandleExchangeTypeChange, self)
	    self.exchangeStone_cb:setUserString("name", "checkbox_stone")
    end
	
	self.ownStoneNum = CurrencyManager.getOwnCurrencyMount(fire.pb.game.MoneyType.MoneyType_HearthStone)
	self.ownGoldNum = CurrencyManager.getOwnCurrencyMount(fire.pb.game.MoneyType.MoneyType_GoldCoin)

	-- 兑换对象说明和图标
	self.exchangeType_st = winMgr:getWindow("duihuanyinbi/jiemian/wenben2")
	self.exchangeIcon_si = winMgr:getWindow("duihuanyinbi/jiemian/zhi2/tubiao")
	self.exchangeIcon1_si = winMgr:getWindow("duihuanyinbi/jiemian/zhi3/tubiao")
	
	-- 根据默认规则，决定默认选中项
    if IsPointCardServer() then
        self.exchangeGold_cb:setSelected(true)
        self.exchangeType = 1

        local stoneDes = winMgr:getWindow("duihuanyinbi/jiemian/di1/wenben5")
        local silverDes = winMgr:getWindow("duihuanyinbi/jiemian/di1/wenben6")
        stoneDes:setVisible(false)
        silverDes:setYPosition(stoneDes:getYPosition())

    else
	    if self.ownGoldNum <= 0 and self.ownStoneNum <= 0 then
		    self.exchangeGold_cb:setSelected(true)
		    self.exchangeType = 1
	    elseif self.ownGoldNum <= 0 then
		    self.exchangeStone_cb:setSelected(true)
	    else
		    self.exchangeGold_cb:setSelected(true)
		    self.exchangeType = 1
	    end
    end
	
    
    self.frameWindow = CEGUI.toFrameWindow(winMgr:getWindow("duihuanyinbi/jiemian"))
    self.frameWindow:getCloseButton():subscribeEvent("Clicked", StoneGoldExchangeSilverDlg.DestroyDialog, self)
end

function StoneGoldExchangeSilverDlg:ResetExchangeCount()
	self.ownStoneNum = CurrencyManager.getOwnCurrencyMount(fire.pb.game.MoneyType.MoneyType_HearthStone)
	self.ownGoldNum = CurrencyManager.getOwnCurrencyMount(fire.pb.game.MoneyType.MoneyType_GoldCoin)
	self.exchangeRatio = GameTable.common.GetCCommonTableInstance():getRecorder(145).value
	local strID = 11263
	local conf = BeanConfigManager.getInstance():GetTableByName("shop.ccurrencyiconpath"):getRecorder(fire.pb.game.MoneyType.MoneyType_HearthStone)
	local exchangeCount = self.ownStoneNum
	if self.exchangeType == 1 then
		exchangeCount = self.ownGoldNum
		self.exchangeRatio = GameTable.common.GetCCommonTableInstance():getRecorder(144).value
		conf = BeanConfigManager.getInstance():GetTableByName("shop.ccurrencyiconpath"):getRecorder(fire.pb.game.MoneyType.MoneyType_GoldCoin)
		strID = 11267
	end
	self.stoneNum_st:setText(MoneyFormat(exchangeCount))
	self.exchangeNum_st:setText(1)
	self.silverNum_st:setText(MoneyFormat(self.exchangeRatio*1))
	
	self.exchangeIcon_si:setProperty("Image", conf.iconpath)
	self.exchangeIcon1_si:setProperty("Image", conf.iconpath)
	self.exchangeType_st:setText(BeanConfigManager.getInstance():GetTableByName("message.cstringres"):getRecorder(strID).msg)
end

function StoneGoldExchangeSilverDlg:HandleExchangeTypeChange(args)
	local winMgr = CEGUI.WindowManager:getSingleton()
	local e = CEGUI.toWindowEventArgs(args)
	local checkboxName = e.window:getUserString("name")
	if checkboxName == "checkbox_gold" then
		if self.exchangeGold_cb:isSelected() then
			self.exchangeType = 1
			self.exchangeStone_cb:setSelected(false)
			self:ResetExchangeCount()
		else
			self.exchangeType = 0
			self.exchangeStone_cb:setSelected(true)
		end
		
	elseif checkboxName == "checkbox_stone" then
		if self.exchangeStone_cb:isSelected() then
			self.exchangeType = 0
			self.exchangeGold_cb:setSelected(false)
			self:ResetExchangeCount()
		else
			self.exchangeType = 1
			self.exchangeGold_cb:setSelected(true)
		end
	end
	
	
	
end


function StoneGoldExchangeSilverDlg:onNumInputChanged(num)
	if num == 0 then
		num = 1
	end
	self.exchangeNum_st:setText(MoneyFormat(num))
	self.silverNum_st:setText(MoneyFormat(self.exchangeRatio * num))
end

function StoneGoldExchangeSilverDlg:handleStoneNumClicked(args)
	if NumKeyboardDlg.getInstanceNotCreate() then
		NumKeyboardDlg.getInstanceNotCreate():SetVisible(true) --保持键盘在最上面
		return
	end
	
	local dlg = NumKeyboardDlg.getInstanceAndShow(self:GetWindow())
	if dlg then
		dlg:setTriggerBtn(self.exchangeNum_st)
		dlg:setMaxValue(tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(364).value))
		dlg:setInputChangeCallFunc(StoneGoldExchangeSilverDlg.onNumInputChanged, self)
		
		local p = self.exchangeNum_st:GetScreenPos()
		SetPositionOffset(dlg:GetWindow(), p.x-self.exchangeNum_st:getPixelSize().width*0.5, p.y-10, 0.5, 1)
	end
end

function StoneGoldExchangeSilverDlg:handleCancelClicked(args)
	StoneGoldExchangeSilverDlg.DestroyDialog()
end

function StoneGoldExchangeSilverDlg:handleClickTipButton(args)
    local tipsStr = ""
    if IsPointCardServer() then
        tipsStr = require("utils.mhsdutils").get_resstring(11614)
    else
        tipsStr = require("utils.mhsdutils").get_resstring(11613)
    end
    local title = require("utils.mhsdutils").get_resstring(11615)
    local tipdlg = require "logic.workshop.tips1".getInstanceAndShow(tipsStr, title)
    SetPositionScreenCenter(tipdlg:GetWindow())
end

function StoneGoldExchangeSilverDlg:handleExchangeClicked(args)
	
	local ownCount = self.ownStoneNum
	if self.exchangeType == 1 then
		ownCount = self.ownGoldNum
	end
	if ownCount == 0 or ownCount < MoneyNumber(self.exchangeNum_st:getText()) then
		local moneyType = fire.pb.game.MoneyType.MoneyType_HearthStone
		if self.exchangeType == 0 then
			StoneGoldExchangeSilverDlg.DestroyDialog()
			CurrencyManager.handleCurrencyNotEnough(moneyType)
		else
			GetCTipsManager():AddMessageTipById(160118)
		end
		return
	end
	
	local p = require("protodef.fire.pb.shop.cexchangecurrency"):new()
	p.srcmoneytype = fire.pb.game.MoneyType.MoneyType_HearthStone
	if self.exchangeType == 1 then
		p.srcmoneytype = fire.pb.game.MoneyType.MoneyType_GoldCoin
	end
	p.dstmoneytype = fire.pb.game.MoneyType.MoneyType_SilverCoin
	p.money = MoneyNumber(self.exchangeNum_st:getText())
	LuaProtocolManager:send(p)
	
	StoneGoldExchangeSilverDlg.DestroyDialog()
	
end


return StoneGoldExchangeSilverDlg
