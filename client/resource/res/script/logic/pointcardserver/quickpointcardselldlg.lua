require "logic.dialog"

QuickPointCardSellDlg = {}
setmetatable(QuickPointCardSellDlg, Dialog)
QuickPointCardSellDlg.__index = QuickPointCardSellDlg

local _instance
function QuickPointCardSellDlg.getInstance()
	if not _instance then
		_instance = QuickPointCardSellDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function QuickPointCardSellDlg.getInstanceAndShow()
	if not _instance then
		_instance = QuickPointCardSellDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function QuickPointCardSellDlg.getInstanceNotCreate()
	return _instance
end

function QuickPointCardSellDlg.DestroyDialog()
	if _instance then 
        CurrencyManager.unregisterTextWidget(_instance.m_ownMoneyText)
        gGetDataManager().m_EventYuanBaoNumberChange:RemoveScriptFunctor(_instance.m_hPackStoneChange)
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function QuickPointCardSellDlg.ToggleOpenClose()
	if not _instance then
		_instance = QuickPointCardSellDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function QuickPointCardSellDlg.GetLayoutFileName()
	return "fastjimai.layout"
end

function QuickPointCardSellDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, QuickPointCardSellDlg)
	return self
end

function QuickPointCardSellDlg:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

	self.m_frameWindow = CEGUI.toFrameWindow(winMgr:getWindow("kuaijiegoumai/frame"))
	self.m_numText = winMgr:getWindow("kuaijiegoumai/shurukuang/zhi")
	self.m_minusBtn = CEGUI.toPushButton(winMgr:getWindow("kuaijiegoumai/jianhao"))
    self.m_minusBtn:subscribeEvent("MouseClick",QuickPointCardSellDlg.handleMinBtnClicked,self)
	self.m_addBtn = CEGUI.toPushButton(winMgr:getWindow("kuaijiegoumai/jiahao"))
    self.m_addBtn:subscribeEvent("MouseClick",QuickPointCardSellDlg.handleAddBtnClicked,self)
	self.m_ownMoneyText = winMgr:getWindow("kuaijiegoumai/zhi3/totalprice")
	self.m_feeText = winMgr:getWindow("kuaijiegoumai/zhi3/totalprice1")
	self.m_allMoneyText = winMgr:getWindow("kuaijiegoumai/zhi5/totalprice5")

    self.m_MaxBtn = CEGUI.toPushButton(winMgr:getWindow("kuaijiegoumai/frame/zuida"))
    self.m_MaxBtn:subscribeEvent("MouseClick",QuickPointCardSellDlg.handleMaxBtnClicked,self)
    self.m_numText:subscribeEvent("MouseClick",QuickPointCardSellDlg.handleInputBtnClicked,self)
    
    self.m_okBtn = CEGUI.toPushButton(winMgr:getWindow("kuaijiegoumai/frame/queren"))
    self.m_okBtn:subscribeEvent("MouseClick",QuickPointCardSellDlg.handleOkBtnClicked,self)
    self.m_cancelBtn = CEGUI.toPushButton(winMgr:getWindow("kuaijiegoumai/frame/quxiao"))
    self.m_cancelBtn:subscribeEvent("MouseClick",QuickPointCardSellDlg.handleCancelClicked,self)
    self.m_frameWindow:getCloseButton():removeEvent("Clicked")
	self.m_frameWindow:getCloseButton():subscribeEvent("Clicked", QuickPointCardSellDlg.handleCancelClicked, self)
    self.m_MaxNum = 0
    self.m_MinNum = 1
    self.m_Unit = 0
    self.m_Num = 1
    self.m_fee = 0

    self.m_ownStoneNum = CurrencyManager.getOwnCurrencyMount(fire.pb.game.MoneyType.MoneyType_HearthStone)

    CurrencyManager.registerTextWidget(fire.pb.game.MoneyType.MoneyType_HearthStone, self.m_ownMoneyText)
    self.m_hPackStoneChange = gGetDataManager().m_EventYuanBaoNumberChange:InsertScriptFunctor(QuickPointCardSellDlg.OnStoneChange)
end
function QuickPointCardSellDlg:OnStoneChange()
    local dlg = require"logic.pointcardserver.quickpointcardselldlg".getInstanceNotCreate()
    if dlg then
        dlg.m_ownStoneNum = CurrencyManager.getOwnCurrencyMount(fire.pb.game.MoneyType.MoneyType_HearthStone)
    end
end
function QuickPointCardSellDlg:handleInputBtnClicked(e)
	local dlg = NumKeyboardDlg.getInstanceAndShow()
	if dlg then
		dlg:setTriggerBtn(self.m_numText)
		dlg:setMaxValue(self.m_MaxNum)
		dlg:setInputChangeCallFunc(QuickPointCardSellDlg.onMoneyInputChanged, self)
		dlg:setCloseCallFunc(QuickPointCardSellDlg.onNumClose, self)
        local strbuilder = StringBuilder:new()
        strbuilder:Set("parameter1", tostring(self.m_MaxNum))
        local content = strbuilder:GetString(MHSD_UTILS.get_msgtipstring(300019))
        strbuilder:delete()
        dlg:setMaxMsg(content)
		local p = self.m_numText:GetScreenPos()
		SetPositionOffset(dlg:GetWindow(), p.x, p.y + 300, 0.5, 1)
	end
end
function QuickPointCardSellDlg:onMoneyInputChanged(num)
    self.m_Num = num
    self:refreshText()
end
function QuickPointCardSellDlg:onNumClose()
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
function QuickPointCardSellDlg:handleMaxBtnClicked(e)
    self.m_Num = self.m_MaxNum
    self:refreshText()
end
function QuickPointCardSellDlg:handleMinBtnClicked(e)
    if self.m_Num <= self.m_MinNum then
        local strbuilder = StringBuilder:new()
        strbuilder:Set("parameter1", tostring(self.m_MinNum))
        local content = strbuilder:GetString(MHSD_UTILS.get_msgtipstring(300018))
        strbuilder:delete()
        GetCTipsManager():AddMessageTip(content)
    else
        self.m_Num = self.m_Num - 1
    end
    self:refreshText()
end
function QuickPointCardSellDlg:refreshText()

    local fee = self.m_fee / 100 * self.m_Unit * self.m_Num
    local feeFloor = math.floor(fee)
    if feeFloor ~= fee then
        feeFloor = feeFloor + 1
        fee = feeFloor
    end
    self.m_allMoneyText:setText(MoneyFormat(self.m_Unit * self.m_Num))
    self.m_feeText:setText(fee)
    self.m_numText:setText(tostring(MoneyFormat(self.m_Num)))
end
function QuickPointCardSellDlg:handleAddBtnClicked(e)
    if self.m_Num >= self.m_MaxNum then
        local strbuilder = StringBuilder:new()
        strbuilder:Set("parameter1", tostring(self.m_MinNum))
        local content = strbuilder:GetString(MHSD_UTILS.get_msgtipstring(300019))
        strbuilder:delete()
        GetCTipsManager():AddMessageTip(content)
    else
        self.m_Num = self.m_Num + 1
    end
    self:refreshText()
end
function QuickPointCardSellDlg:handleOkBtnClicked(e)
    local p = require("protodef.fire.pb.fushi.spotcheck.csellspotcard"):new()
    p.sellnum = self.m_Num
    p.sellprice = self.m_Unit
    LuaProtocolManager:send(p)
    QuickPointCardSellDlg.DestroyDialog()
end
function QuickPointCardSellDlg:handleCancelClicked(e)
    QuickPointCardSellDlg.DestroyDialog()
end
function QuickPointCardSellDlg:setData(num, unit, fee)
    self.m_MaxNum = num
    self.m_Unit = unit
    self.m_fee = fee
    if self.m_ownStoneNum < self.m_MaxNum then
        self.m_MaxNum = math.floor(self.m_ownStoneNum)
    end
    local record = BeanConfigManager.getInstance():GetTableByName("fushi.cbankconfig"):getRecorder(1)
    local maxnum = record.buynummax
    self.m_MinNum = record.buynummin
    if self.m_MaxNum < self.m_MinNum then
        self.m_MaxNum = self.m_MinNum
    end
    if self.m_MaxNum > maxnum then
        self.m_MaxNum = maxnum
    end
    self.m_Num = self.m_MinNum
    self:refreshText()
end
return QuickPointCardSellDlg