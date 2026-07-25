------------------------------------------------------------------
-- 金币兑换（使用符石）
------------------------------------------------------------------
require "logic.dialog"

ExchangeGold = {}
setmetatable(ExchangeGold, Dialog)
ExchangeGold.__index = ExchangeGold

local _instance
function ExchangeGold.getInstance()
	if not _instance then
		_instance = ExchangeGold:new()
		_instance:OnCreate()
	end
	return _instance
end

function ExchangeGold.getInstanceAndShow()
	if not _instance then
		_instance = ExchangeGold:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function ExchangeGold.getInstanceNotCreate()
	return _instance
end

function ExchangeGold.DestroyDialog()
	if _instance then
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function ExchangeGold.ToggleOpenClose()
	if not _instance then
		_instance = ExchangeGold:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function ExchangeGold.GetLayoutFileName()
	return "npcjinbiqueren_mtg.layout"
end

function ExchangeGold:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, ExchangeGold)
	return self
end

function ExchangeGold:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

	self.frameWindow = CEGUI.toFrameWindow(winMgr:getWindow("npcjinbiqueren_mtg/framewindow"))
	self.needNumText = winMgr:getWindow("npcjinbiqueren_mtg/textqian")
	self.useStoneBtn = CEGUI.toPushButton(winMgr:getWindow("npcjinbiqueren_mtg/btnfushi"))
    self.moneyIcon = winMgr:getWindow("npcjinbiqueren_mtg/btnfushi/image1")

	self.useStoneBtn:subscribeEvent("Clicked", ExchangeGold.handleUseStoneClicked, self)
	self.frameWindow:getCloseButton():subscribeEvent("Clicked", ExchangeGold.handleCloseClicked, self)
end

function ExchangeGold:setNeedNum(num)
	self.needNumText:setText(MoneyFormat(num))
	
	local stoneRatio = GameTable.common.GetCCommonTableInstance():getRecorder(143).value
	local stoneNum = math.ceil(num / stoneRatio)
	local curStone = CurrencyManager.getOwnCurrencyMount(fire.pb.game.MoneyType.MoneyType_HearthStone)
	
	self.needStone = stoneNum - curStone
	
	if self.needStone > 0 then
		self.useStoneBtn:setProperty("ButtonBorderColour", "ffff0000")
	end
	
	self.useStoneBtn:setText(MoneyFormat(stoneNum))

    local w = self.useStoneBtn:getFont():getTextExtent(self.useStoneBtn:getText())
    local x = (self.useStoneBtn:getPixelSize().width - w)*0.5-self.moneyIcon:getPixelSize().width
    self.moneyIcon:setXPosition(CEGUI.UDim(0,x))
end

function ExchangeGold:handleUseStoneClicked(args)
	if self.needStone <= 0 then
		local p = require("protodef.fire.pb.shop.cexchangecurrency"):new()
		p.srcmoneytype = fire.pb.game.MoneyType.MoneyType_HearthStone
		p.dstmoneytype = fire.pb.game.MoneyType.MoneyType_GoldCoin
		p.money = MoneyNumber(self.useStoneBtn:getText())
		LuaProtocolManager:send(p)
	else
		CurrencyManager.handleCurrencyNotEnough(fire.pb.game.MoneyType.MoneyType_HearthStone)
	end
	ExchangeGold.DestroyDialog()
end

function ExchangeGold:handleCloseClicked(args)
	CurrencyManager.setAutoBuyArgs(nil)
	ExchangeGold.DestroyDialog()
end

return ExchangeGold
