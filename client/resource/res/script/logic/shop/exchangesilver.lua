------------------------------------------------------------------
-- 银币兑换（使用金币或符石）
------------------------------------------------------------------
require "logic.dialog"

ExchangeSilver = {}
setmetatable(ExchangeSilver, Dialog)
ExchangeSilver.__index = ExchangeSilver

local _instance
function ExchangeSilver.getInstance()
	if not _instance then
		_instance = ExchangeSilver:new()
		_instance:OnCreate()
	end
	return _instance
end

function ExchangeSilver.getInstanceAndShow()
	if not _instance then
		_instance = ExchangeSilver:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function ExchangeSilver.getInstanceNotCreate()
	return _instance
end

function ExchangeSilver.DestroyDialog()
	if _instance then
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function ExchangeSilver.ToggleOpenClose()
	if not _instance then
		_instance = ExchangeSilver:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function ExchangeSilver.GetLayoutFileName()
	return "npcxiaofeiqueren_mtg.layout"
end

function ExchangeSilver:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, ExchangeSilver)
	return self
end

function ExchangeSilver:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

	self.frameWindow = CEGUI.toFrameWindow(winMgr:getWindow("npcxiaofeiqueren_mtg/framewindow"))
	self.needNumText = winMgr:getWindow("npcxiaofeiqueren_mtg/textqian")
	self.needNumText:setProperty("TextColours", "FFFFFFFF")
	self.useGoldBtn = CEGUI.toPushButton(winMgr:getWindow("npcxiaofeiqueren_mtg/btnjinbi"))
	self.useStoneBtn = CEGUI.toPushButton(winMgr:getWindow("npcxiaofeiqueren_mtg/btnfushi"))
    self.goldIcon = winMgr:getWindow("npcxiaofeiqueren_mtg/btnjinbi/image1")
    self.stoneIcon = winMgr:getWindow("npcxiaofeiqueren_mtg/btnfushi/image1")

	self.useGoldBtn:subscribeEvent("Clicked", ExchangeSilver.handleUseGoldClicked, self)
	self.useStoneBtn:subscribeEvent("Clicked", ExchangeSilver.handleUseStoneClicked, self)
	self.frameWindow:getCloseButton():subscribeEvent("Clicked", ExchangeSilver.handleCloseClicked, self)

    if IsPointCardServer() then
        winMgr:getWindow("npcxiaofeiqueren_mtg/textduihuan"):setVisible(false)
        self.useStoneBtn:setVisible(false)

        local x = self.frameWindow:getPixelSize().width*0.5
        local text = winMgr:getWindow("npcxiaofeiqueren_mtg/textdaiti")
        SetPositionXOffset(text, x, 0.5)
        SetPositionXOffset(self.useGoldBtn, x, 0.5)
    end
end

function ExchangeSilver:setNeedNum(num)
	self.needNumText:setText(MoneyFormat(num))
	
	local goldRatio = GameTable.common.GetCCommonTableInstance():getRecorder(144).value
	local stoneRatio = GameTable.common.GetCCommonTableInstance():getRecorder(145).value
	
	local goldNum = math.ceil(num / goldRatio)
	local stoneNum = math.ceil(num / stoneRatio)
	
	local curGold = CurrencyManager.getOwnCurrencyMount(fire.pb.game.MoneyType.MoneyType_GoldCoin)
	local curStone = CurrencyManager.getOwnCurrencyMount(fire.pb.game.MoneyType.MoneyType_HearthStone)
	
	self.needGold = goldNum - curGold
	self.needStone = stoneNum - curStone
	
	if self.needGold > 0 then
		self.useGoldBtn:setProperty("ButtonBorderColour", "ffff0000")
	end
	if self.needStone > 0 then
		self.useStoneBtn:setProperty("ButtonBorderColour", "ffff0000")
	end
	
	self.useGoldBtn:setText(MoneyFormat(goldNum))
	self.useStoneBtn:setText(MoneyFormat(stoneNum))

    local w = self.useGoldBtn:getFont():getTextExtent(self.useGoldBtn:getText())
    local x = (self.useGoldBtn:getPixelSize().width - w)*0.5-self.goldIcon:getPixelSize().width
    self.goldIcon:setXPosition(CEGUI.UDim(0,x))

    w = self.useStoneBtn:getFont():getTextExtent(self.useStoneBtn:getText())
    x = (self.useStoneBtn:getPixelSize().width - w)*0.5-self.stoneIcon:getPixelSize().width
    self.stoneIcon:setXPosition(CEGUI.UDim(0,x))
end

function ExchangeSilver:handleUseGoldClicked(args)
	if self.needGold <= 0 then
		local p = require("protodef.fire.pb.shop.cexchangecurrency"):new()
		p.srcmoneytype = fire.pb.game.MoneyType.MoneyType_GoldCoin
		p.dstmoneytype = fire.pb.game.MoneyType.MoneyType_SilverCoin
		p.money = MoneyNumber(self.useGoldBtn:getText())
		LuaProtocolManager:send(p)
	else
		CurrencyManager.handleCurrencyNotEnough(fire.pb.game.MoneyType.MoneyType_GoldCoin, self.needGold)
	end
	ExchangeSilver.DestroyDialog()
end

function ExchangeSilver:handleUseStoneClicked(args)
	if self.needStone <= 0 then
		local p = require("protodef.fire.pb.shop.cexchangecurrency"):new()
		p.srcmoneytype = fire.pb.game.MoneyType.MoneyType_HearthStone
		p.dstmoneytype = fire.pb.game.MoneyType.MoneyType_SilverCoin
		p.money = MoneyNumber(self.useStoneBtn:getText())
		LuaProtocolManager:send(p)
	else
		CurrencyManager.handleCurrencyNotEnough(fire.pb.game.MoneyType.MoneyType_HearthStone)
	end
	ExchangeSilver.DestroyDialog()
end

function ExchangeSilver:handleCloseClicked(args)
	CurrencyManager.setAutoBuyArgs(nil)
	ExchangeSilver.DestroyDialog()
end

return ExchangeSilver
