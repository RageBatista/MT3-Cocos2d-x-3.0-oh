require "logic.dialog"

QuickPointCardBuyDlg = {}
setmetatable(QuickPointCardBuyDlg, Dialog)
QuickPointCardBuyDlg.__index = QuickPointCardBuyDlg

local _instance
function QuickPointCardBuyDlg.getInstance()
	if not _instance then
		_instance = QuickPointCardBuyDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function QuickPointCardBuyDlg.getInstanceAndShow()
	if not _instance then
		_instance = QuickPointCardBuyDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function QuickPointCardBuyDlg.getInstanceNotCreate()
	return _instance
end

function QuickPointCardBuyDlg.DestroyDialog()
	if _instance then 
        CurrencyManager.unregisterTextWidget(_instance.m_ownMoneyText)
        gGetDataManager().m_EventYuanBaoNumberChange:RemoveScriptFunctor(_instance.m_hPackGlodChange)
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function QuickPointCardBuyDlg.ToggleOpenClose()
	if not _instance then
		_instance = QuickPointCardBuyDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function QuickPointCardBuyDlg.GetLayoutFileName()
	return "fastqiugou.layout"
end

function QuickPointCardBuyDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, QuickPointCardBuyDlg)
	return self
end

function QuickPointCardBuyDlg:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

	self.m_frameWindow = CEGUI.toFrameWindow(winMgr:getWindow("kuaijiegoumai/frame"))
	self.m_numText = winMgr:getWindow("kuaijiegoumai/shurukuang/zhi")
	self.m_minusBtn = CEGUI.toPushButton(winMgr:getWindow("kuaijiegoumai/jianhao"))
    self.m_minusBtn:subscribeEvent("MouseClick",QuickPointCardBuyDlg.handleMinBtnClicked,self)
	self.m_addBtn = CEGUI.toPushButton(winMgr:getWindow("kuaijiegoumai/jiahao"))
    self.m_addBtn:subscribeEvent("MouseClick",QuickPointCardBuyDlg.handleAddBtnClicked,self)
	self.m_ownMoneyText = winMgr:getWindow("kuaijiegoumai/zhi3/totalprice")
	self.m_feeText = winMgr:getWindow("kuaijiegoumai/zhi3/totalprice1")
	self.m_allMoneyText = winMgr:getWindow("kuaijiegoumai/zhi5/totalprice5")

    self.m_MaxBtn = CEGUI.toPushButton(winMgr:getWindow("kuaijiegoumai/frame/zuida"))
    self.m_MaxBtn:subscribeEvent("MouseClick",QuickPointCardBuyDlg.handleMaxBtnClicked,self)
    
    self.m_okBtn = CEGUI.toPushButton(winMgr:getWindow("kuaijiegoumai/frame/queren"))
    self.m_okBtn:subscribeEvent("MouseClick",QuickPointCardBuyDlg.handleOkBtnClicked,self)
    self.m_cancelBtn = CEGUI.toPushButton(winMgr:getWindow("kuaijiegoumai/frame/quxiao"))
    self.m_cancelBtn:subscribeEvent("MouseClick",QuickPointCardBuyDlg.handleCancelClicked,self)
    self.m_numText:subscribeEvent("MouseClick",QuickPointCardBuyDlg.handleInputBtnClicked,self)
    self.m_frameWindow:getCloseButton():removeEvent("Clicked")
	self.m_frameWindow:getCloseButton():subscribeEvent("Clicked", QuickPointCardBuyDlg.handleCancelClicked, self)
    self.m_MaxNum = 0
    self.m_MinNum = 1
    self.m_Unit = 0
    self.m_Num = 1
    self.m_fee = 0

    self.m_ownGlodNum = CurrencyManager.getOwnCurrencyMount(fire.pb.game.MoneyType.MoneyType_GoldCoin)

    CurrencyManager.registerTextWidget(fire.pb.game.MoneyType.MoneyType_GoldCoin, self.m_ownMoneyText)

    self.m_hPackGlodChange = gGetRoleItemManager().m_EventPackGoldChange:InsertScriptFunctor(CurrencyTradingDlg.OnGoldChange)
end
function QuickPointCardBuyDlg:OnGoldChange()
    local dlg = require"logic.pointcardserver.quickpointcardselldlg".getInstanceNotCreate()
    if dlg then
        dlg.m_ownGlodNum = CurrencyManager.getOwnCurrencyMount(fire.pb.game.MoneyType.MoneyType_GoldCoin)
    end
end
function QuickPointCardBuyDlg:handleInputBtnClicked(e)
	local dlg = NumKeyboardDlg.getInstanceAndShow()
	if dlg then
		dlg:setTriggerBtn(self.m_numText)
		dlg:setMaxValue(self.m_MaxNum)
		dlg:setInputChangeCallFunc(QuickPointCardBuyDlg.onMoneyInputChanged, self)
		dlg:setCloseCallFunc(QuickPointCardBuyDlg.onNumClose, self)
        local strbuilder = StringBuilder:new()
        strbuilder:Set("parameter1", tostring(self.m_MaxNum))
        local content = strbuilder:GetString(MHSD_UTILS.get_msgtipstring(300019))
        strbuilder:delete()
        dlg:setMaxMsg(content)
		local p = self.m_numText:GetScreenPos()
		SetPositionOffset(dlg:GetWindow(), p.x, p.y + 300, 0.5, 1)
	end
end
function QuickPointCardBuyDlg:onMoneyInputChanged(num)
    self.m_Num = num
    self:refreshText()
end
function QuickPointCardBuyDlg:onNumClose()
    if self.m_Num < self.m_MinNum then
        local strbuilder = StringBuilder:new()
        strbuilder:Set("parameter1", tostring(self.m_MinNum))
        local content = strbuilder:GetString(MHSD_UTILS.get_msgtipstring(300018))
        strbuilder:delete()
        GetCTipsManager():AddMessageTip(content)
        self.m_Num = self.m_MinNum
        self:refreshText()
    end
end
function QuickPointCardBuyDlg:handleMaxBtnClicked(e)
    self.m_Num = self.m_MaxNum
    self:refreshText()
end
function QuickPointCardBuyDlg:handleMinBtnClicked(e)
    if self.m_Num <= self.m_MinNum then
        local strbuilder = StringBuilder:new()
        strbuilder:Set("parameter1", tostring(self.m_MaxNum))
        local content = strbuilder:GetString(MHSD_UTILS.get_msgtipstring(300018))
        strbuilder:delete()
        GetCTipsManager():AddMessageTip(content)
    else
        self.m_Num = self.m_Num - 1
    end
    self:refreshText()
end
function QuickPointCardBuyDlg:refreshText()

    local fee = self.m_fee / 100 * self.m_Unit * self.m_Num
    local feeFloor = math.floor(fee)
    if feeFloor ~= fee then
        feeFloor = feeFloor + 1
        fee = feeFloor
    end
    self.m_allMoneyText:setText(MoneyFormat(self.m_Unit * self.m_Num))
    self.m_feeText:setText(MoneyFormat(fee))
    self.m_numText:setText(tostring(self.m_Num))
end
function QuickPointCardBuyDlg:handleAddBtnClicked(e)
    if self.m_Num >= self.m_MaxNum then
        local strbuilder = StringBuilder:new()
        strbuilder:Set("parameter1", tostring(self.m_MaxNum))
        local content = strbuilder:GetString(MHSD_UTILS.get_msgtipstring(300019))
        strbuilder:delete()
        GetCTipsManager():AddMessageTip(content)
    else
        self.m_Num = self.m_Num + 1
    end
    self:refreshText()
end
function QuickPointCardBuyDlg:handleOkBtnClicked(e)
    local p = require("protodef.fire.pb.fushi.spotcheck.cbuyspotcard"):new()
    p.buynum = self.m_Num
    p.buyprice = self.m_Unit
    LuaProtocolManager:send(p)
    QuickPointCardBuyDlg.DestroyDialog()
end
function QuickPointCardBuyDlg:handleCancelClicked(e)
    QuickPointCardBuyDlg.DestroyDialog()
end
function QuickPointCardBuyDlg:setData(num, unit, fee)
    self.m_MaxNum = num
    self.m_Unit = unit
    self.m_fee = fee
    if self.m_ownGlodNum < self.m_MaxNum * self.m_Unit + self.m_MaxNum * self.m_Unit * self.m_fee then
        local num = math.floor(self.m_ownGlodNum /(1 + self.m_fee / 100) /self.m_Unit)
        self.m_MaxNum = num 
    end
    local record = BeanConfigManager.getInstance():GetTableByName("fushi.cbankconfig"):getRecorder(1)
    self.m_MinNum = record.sellnummin
    local maxnum = record.sellnummax
    if self.m_MaxNum > maxnum then
        self.m_MaxNum = maxnum
    end
    self.m_Num = self.m_MinNum
    self:refreshText()
end

return QuickPointCardBuyDlg