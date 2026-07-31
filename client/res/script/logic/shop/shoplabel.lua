require "utils.mhsdutils"
require "logic.dialog"
require "logic.shop.mallshop"
require "logic.shop.commercedlg"
require "logic.chargedialog"

ShopLabel = {}
setmetatable(ShopLabel, Dialog)
ShopLabel.__index = ShopLabel

local _instance
local Dlgs =
{
	CommerceDlg,
	MallShop,
	ChargeDialog
}

function ShopLabel.getInstance()
	if not _instance then
		_instance = ShopLabel:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function ShopLabel.getInstanceNotCreate()
	return _instance
end

function ShopLabel.GetLayoutFileName()
	return "lableshanhui.layout"
end

function ShopLabel:SetVisible(b)
	if self:IsVisible() ~= b and b then
		require("logic.shop.shopmanager"):checkNumLimit()
	end
	Dialog.SetVisible(self, b)
end

function ShopLabel:OnCreate()
	Dialog.OnCreate(self,nil, "shoplabel")
	self:GetWindow():setRiseOnClickEnabled(false)
	
	self.dialogs = {}
	self.curDialog = nil

	local winMgr = CEGUI.WindowManager:getSingleton()
	self.m_pButton1 = CEGUI.toPushButton(winMgr:getWindow( "shoplabelLable/button"))
    self.m_pButton1:SetMouseLeaveReleaseInput(false)
	self.m_pButton2 = CEGUI.toPushButton(winMgr:getWindow( "shoplabelLable/button1"))
    self.m_pButton2:SetMouseLeaveReleaseInput(false)
	self.m_pButton3 = CEGUI.toPushButton(winMgr:getWindow( "shoplabelLable/button2"))
    self.m_pButton3:SetMouseLeaveReleaseInput(false)
    self.m_pButton4 = CEGUI.toPushButton(winMgr:getWindow( "shoplabelLable/button3"))
	
	self.cc_baitanc = CEGUI.toPushButton(winMgr:getWindow("shoplabelLable/baitanc"))
	self.cc_baitanc:subscribeEvent("MouseClick", ShopLabel.btAddMoneyClicked, self)

	self.m_ReturnRedPoint = CEGUI.toPushButton(winMgr:getWindow( "shoplabelLable/button/image4"))

	self.buttons = {}
	self.buttons[1] = self.m_pButton1
	self.buttons[2] = self.m_pButton2
	self.buttons[3] = self.m_pButton3
	
	self.m_pButton1:setID(1)
	self.m_pButton2:setID(2)
	self.m_pButton3:setID(3)
	
	self.m_pButton1:EnableClickAni(false)
	self.m_pButton2:EnableClickAni(false)
	self.m_pButton3:EnableClickAni(false)
	self.m_pButton4:setVisible(false)

	self.m_pButton1:setText(MHSD_UTILS.get_resstring(11813)) --商会
	self.m_pButton2:setText(MHSD_UTILS.get_resstring(11813)) --商城
	self.m_pButton3:setText(MHSD_UTILS.get_resstring(11813)) --会员
	self.m_pButton1:subscribeEvent("Clicked", ShopLabel.handleLabelBtnClicked, self)
	self.m_pButton2:subscribeEvent("Clicked", ShopLabel.handleLabelBtnClicked, self)
	self.m_pButton3:subscribeEvent("Clicked", ShopLabel.handleLabelBtnClicked, self)
	
	self.isFirstOpenCommerceDlg = true
    local datamanager = require "logic.chargedatamanager"
    if datamanager then
        local redpoint =  datamanager.GetRedPointStatus()
        if self.m_ReturnRedPoint then
            self.m_ReturnRedPoint:setVisible(redpoint)
        end
    end
end



function ShopLabel:new()
	local self={}
	self = Dialog:new()
	setmetatable(self, ShopLabel)
	return self
end

function ShopLabel.DestroyDialog()
	if _instance then
		if not _instance.m_bCloseIsHide then
			for _,v in pairs(Dlgs) do
				local dlg = v.getInstanceNotCreate()
				if dlg then
					_instance:removeEvent(dlg:GetWindow())
					dlg.DestroyDialog()
				end
			end

			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function ShopLabel:btAddMoneyClicked(args)
    --StallLabel.getInstance():showOnly(1)
    require("logic.shop.stalllabel").show()
	ShopLabel.DestroyDialog()
end

function ShopLabel.hide()
	if _instance then
		--隐藏商品的需求角标
		for _,v in pairs(_instance.dialogs) do
			v:SetVisible(false)
			if v.hideRequireGoods then
				v:hideRequireGoods()
			end
		end
		
		_instance:GetWindow():setVisible(false)
		_instance.isFirstOpenCommerceDlg = true
		
		if _instance.callbackWhenHide then
			_instance.callbackWhenHide()
			_instance.callbackWhenHide = nil
		end
        --点卡服处理
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
	end
end

function ShopLabel.show() 
	if not _instance then
		ShopLabel.getInstance():showOnly(1)
	else
		_instance:GetWindow():setVisible(true)
		_instance.curDialog:SetVisible(true)
		_instance:GetWindow():getParent():bringWindowAbove(_instance:GetWindow(), _instance.curDialog:GetWindow())
	end
end
function ShopLabel.show3() 
	if not _instance then
		ShopLabel.getInstance():showOnly(3)
	else
		_instance:GetWindow():setVisible(true)
		_instance.curDialog:SetVisible(true)
		_instance:GetWindow():getParent():bringWindowAbove(_instance:GetWindow(), _instance.curDialog:GetWindow())
	end
end


function ShopLabel.showCommerce()
	ShopLabel.getInstance():showOnly(1)
end

function ShopLabel.showMallShop()
	ShopLabel.getInstance():showOnly(2)
end

function ShopLabel.showRecharge()
    --点卡服处理
	ShopLabel.getInstance():showOnly(3)
    local manager = require "logic.pointcardserver.pointcardservermanager".getInstanceNotCreate()
    if manager then
        if manager.m_isTodayNotFree then
 	        _instance.m_pButton1:setEnabled(false)
	        _instance.m_pButton2:setEnabled(false)
        end
    end
end

function ShopLabel.showAllButton()
    if _instance then
 	    _instance.m_pButton1:setEnabled(true)
	    _instance.m_pButton2:setEnabled(true)
    end
end

function ShopLabel:showOnly(index)
	self:setButtonPushed(index)
	
	if self.curDialog and self.curDialog:IsVisible() and self.curIdx == index then
		return
	end
	self.curIdx = index
	
	if self.curDialog then
		self.curDialog:SetVisible(false)
	end
	
	if index == 1 then
		self.curDialog = self:getDialog(CommerceDlg)
	    self.curDialog:resetData()
            self.curDialog.m_shcctips:Clear()
            self.curDialog.m_shcctips:AppendParseText(CEGUI.String(MHSD_UTILS.get_resstring(7402)))
            self.curDialog.m_shcctips:Refresh()
            self.curDialog.m_shcctips:show()		
	elseif index == 2 then
		self.curDialog = self:getDialog(MallShop)
		self.curDialog:resetData()
	elseif index == 3 then
		self.curDialog = self:getDialog(ChargeDialog)
        -- self.curDialog.m_TabBtn["charge"]:setSelected(true)
        -- self.curDialog.m_Back["charge"]["back"]:setVisible(true)
		-- self.curDialog.m_Back["chargereturn"]["back"]:setVisible(false)
		-- self.curDialog.m_Yuanbao["parent"]:setVisible(true)
        self.curDialog:refreshDingyueBtn()
	end
	
	self:SetVisible(true)
	self.dialogs[index] = self.curDialog
	self:GetWindow():getParent():bringWindowAbove(self:GetWindow(), self.curDialog:GetWindow())
end

function ShopLabel:getDialog(Dlg)
	local dlg = Dlg.getInstanceNotCreate()
	if not dlg then
		dlg = Dlg.getInstanceAndShow()
		self:subscribeEvent(dlg:GetWindow())
	else
		dlg:SetVisible(true)
	end
	return dlg
end

function ShopLabel:setButtonPushed(idx)
	for i,v in pairs(self.buttons) do
		v:SetPushState(i==idx)
	end
end

function ShopLabel:subscribeEvent(wnd)
	wnd:subscribeEvent("AlphaChanged", ShopLabel.handleDlgStateChange, self)
	wnd:subscribeEvent("Shown", ShopLabel.handleDlgStateChange, self)
	wnd:subscribeEvent("Hidden", ShopLabel.handleDlgStateChange, self)
	wnd:subscribeEvent("InheritAlphaChanged", ShopLabel.handleDlgStateChange, self)
end

function ShopLabel:removeEvent(wnd)
	wnd:removeEvent("AlphaChanged")
	wnd:removeEvent("Shown")
	wnd:removeEvent("Hidden")
	wnd:removeEvent("InheritAlphaChanged")
end

function ShopLabel:handleDlgStateChange(args)
	if not self.curIdx or not Dlgs[self.curIdx] or not Dlgs[self.curIdx].getInstanceNotCreate() then
		return
	end
	local curWnd = Dlgs[self.curIdx].getInstanceNotCreate():GetWindow()
	for _,v in pairs(Dlgs) do
		local dlg = v.getInstanceNotCreate()
		if dlg and dlg:IsVisible() and dlg:GetWindow():getEffectiveAlpha() > 0.95 then
			self:SetVisible(true)
			self:GetWindow():getParent():bringWindowAbove(self:GetWindow(), curWnd)
			return true
		end
	end

	self:SetVisible(false)
end

function ShopLabel:handleLabelBtnClicked(e)
	local idx = CEGUI.toWindowEventArgs(e).window:getID()
	self:showOnly(idx)
end

return ShopLabel
