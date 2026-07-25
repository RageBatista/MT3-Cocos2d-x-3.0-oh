------------------------------------------------------------------
-- ·ûÊ¯¶Ò»»½ð±Ò
------------------------------------------------------------------
require "logic.dialog"

StoneExchangeGoldDlg = {}
setmetatable(StoneExchangeGoldDlg, Dialog)
StoneExchangeGoldDlg.__index = StoneExchangeGoldDlg

local _instance
function StoneExchangeGoldDlg.getInstance()
	if not _instance then
		_instance = StoneExchangeGoldDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function StoneExchangeGoldDlg.getInstanceAndShow()
	if not _instance then
		_instance = StoneExchangeGoldDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function StoneExchangeGoldDlg.getInstanceNotCreate()
	return _instance
end

function StoneExchangeGoldDlg.DestroyDialog()
	if _instance then
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function StoneExchangeGoldDlg.ToggleOpenClose()
	if not _instance then
		_instance = StoneExchangeGoldDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function StoneExchangeGoldDlg.GetLayoutFileName()
	return "duihuanjinbi.layout"
end

function StoneExchangeGoldDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, StoneExchangeGoldDlg)
	return self
end

function StoneExchangeGoldDlg:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

	self.stoneNum = winMgr:getWindow("duihuanjinbi/jiemian/zhi1")
	self.exchangeNum = winMgr:getWindow("duihuanjinbi/jiemian/zhi2/zhi")
	self.goldNum = winMgr:getWindow("duihuanjinbi/jiemian/zhi3")
	self.cancelBtn = CEGUI.toPushButton(winMgr:getWindow("duihuanjinbi/jiemian/quxiao"))
	self.exchangeBtn = CEGUI.toPushButton(winMgr:getWindow("duihuanjinbi/jiemian/duihuan"))

    self.tipBtn = CEGUI.toPushButton(winMgr:getWindow("duihuanjinbi/jiemian/tips"))
    self.tipBtn:subscribeEvent("Clicked", StoneExchangeGoldDlg.handleTipBtnClick, self)

	self.cancelBtn:subscribeEvent("Clicked", StoneExchangeGoldDlg.handleCancelClicked, self)
	self.exchangeBtn:subscribeEvent("Clicked", StoneExchangeGoldDlg.handleExchangeClicked, self)
	self.exchangeNum:subscribeEvent("MouseClick", StoneExchangeGoldDlg.handleStoneNumClicked, self)
	
	self.exchangeRatio = GameTable.common.GetCCommonTableInstance():getRecorder(143).value
	self.ownStoneNum = CurrencyManager.getOwnCurrencyMount(fire.pb.game.MoneyType.MoneyType_HearthStone)
	self.stoneNum:setText(MoneyFormat(self.ownStoneNum))
	self.exchangeNum:setText(1)
	self.goldNum:setText(MoneyFormat(self.exchangeRatio * 1))

    self.frameWindow = CEGUI.toFrameWindow(winMgr:getWindow("duihuanjinbi/jiemian"))
    self.frameWindow:getCloseButton():subscribeEvent("Clicked", StoneExchangeGoldDlg.DestroyDialog, self)
end

function StoneExchangeGoldDlg:onNumInputChanged(num)
	if num == 0 then
		num = 1
	end
	self.exchangeNum:setText(MoneyFormat(num))
	self.goldNum:setText(MoneyFormat(self.exchangeRatio * num))
end

function StoneExchangeGoldDlg:handleStoneNumClicked(args)
	if NumKeyboardDlg.getInstanceNotCreate() then
		NumKeyboardDlg.getInstanceNotCreate():SetVisible(true)
		return
	end
	
	local dlg = NumKeyboardDlg.getInstanceAndShow(self:GetWindow())
	if dlg then
		dlg:setTriggerBtn(self.exchangeNum)
		dlg:setMaxValue(tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(363).value))
		dlg:setInputChangeCallFunc(StoneExchangeGoldDlg.onNumInputChanged, self)
		
		local p = self.exchangeNum:GetScreenPos()
		SetPositionOffset(dlg:GetWindow(), p.x-self.exchangeNum:getPixelSize().width*0.5, p.y-10, 0.5, 1)
	end
end

function StoneExchangeGoldDlg:handleCancelClicked(args)
	StoneExchangeGoldDlg.DestroyDialog()
end

function StoneExchangeGoldDlg:handleTipBtnClick(args)
    local tipsStr = require("utils.mhsdutils").get_resstring(11617)
    local title = require("utils.mhsdutils").get_resstring(11616)
    local tipdlg = require "logic.workshop.tips1".getInstanceAndShow(tipsStr, title)
    SetPositionScreenCenter(tipdlg:GetWindow())
end

function StoneExchangeGoldDlg:handleExchangeClicked(args)
	if self.ownStoneNum == 0 or self.ownStoneNum < MoneyNumber(self.exchangeNum:getText()) then
		StoneExchangeGoldDlg.DestroyDialog()
		CurrencyManager.handleCurrencyNotEnough(fire.pb.game.MoneyType.MoneyType_HearthStone)
		return
	end
	
	local p = require("protodef.fire.pb.shop.cexchangecurrency"):new()
	p.srcmoneytype = fire.pb.game.MoneyType.MoneyType_HearthStone
	p.dstmoneytype = fire.pb.game.MoneyType.MoneyType_GoldCoin
	p.money = MoneyNumber(self.exchangeNum:getText())
	LuaProtocolManager:send(p)
		
	StoneExchangeGoldDlg.DestroyDialog()
end

return StoneExchangeGoldDlg
