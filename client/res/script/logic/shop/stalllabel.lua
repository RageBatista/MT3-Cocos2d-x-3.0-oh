require "utils.mhsdutils"
require "logic.dialog"
require "logic.shop.stalldlg"
require "logic.pointcardserver.currencytradingdlg"
require "handler.fire_pb_fushi"
require "logic.shop.treasurehousedlg"
require "config"
require "protodef.rpcgen.fire.pb.funopenclosetype"
require "logic.pointcardserver.pointcardservermanager"

StallLabel = {}
setmetatable(StallLabel, Dialog)
StallLabel.__index = StallLabel

local _instance

function StallLabel.getInstance()
	if not _instance then
		_instance = StallLabel:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function StallLabel.getInstanceNotCreate()
	return _instance
end

function StallLabel.GetLayoutFileName()
	return "lable2.layout"
end

function StallLabel:OnCreate()
	Dialog.OnCreate(self,nil, "StallLabel")
	self:GetWindow():setRiseOnClickEnabled(false)
	
	self.dialogs = {}
	self.curDialog = nil

	local winMgr = CEGUI.WindowManager:getSingleton()
	self.m_pButton1 = CEGUI.toPushButton(winMgr:getWindow( "StallLabelLable/button"))
	self.m_pButton2 = CEGUI.toPushButton(winMgr:getWindow( "StallLabelLable/button1"))
	self.m_pButton3 = CEGUI.toPushButton(winMgr:getWindow( "StallLabelLable/button2"))
    self.m_pButton4 = CEGUI.toPushButton(winMgr:getWindow( "StallLabelLable/button3"))
	
	self.cc_shanghui = CEGUI.toPushButton(winMgr:getWindow("StallLabelLable/buttonc1"))
	self.cc_shanghui:subscribeEvent("MouseClick", StallLabel.shAddMoneyClicked, self)
	
	self.cc_shangcheng = CEGUI.toPushButton(winMgr:getWindow("StallLabelLable/buttonc2"))
	self.cc_shangcheng:subscribeEvent("MouseClick", StallLabel.scAddMoneyClicked, self)
	
	self.cc_chongzhi = CEGUI.toPushButton(winMgr:getWindow("StallLabelLable/buttonc3"))
	self.cc_chongzhi:subscribeEvent("MouseClick", StallLabel.czAddMoneyClicked, self)

    self.m_pButton1:SetMouseLeaveReleaseInput(false)
    self.m_pButton2:SetMouseLeaveReleaseInput(false)
    self.m_pButton3:SetMouseLeaveReleaseInput(false)
	self.m_pButton4:SetMouseLeaveReleaseInput(false)

	self.buttons = {}
	self.buttons[1] = self.m_pButton1
	self.buttons[2] = self.m_pButton2
	self.buttons[3] = self.m_pButton3
	self.buttons[4] = self.m_pButton4
	
	self.m_pButton1:setID(1)
	self.m_pButton2:setID(2)
	self.m_pButton3:setID(3)
	self.m_pButton4:setID(4)
	
	self.m_pButton1:EnableClickAni(false)
	self.m_pButton2:EnableClickAni(false)
	self.m_pButton3:EnableClickAni(false)
	self.m_pButton4:EnableClickAni(false)
	if not IsPointCardServer() or (MT3.ChannelManager:IsAndroid() == 1 and Config.IsYingYongBao()) then
		self.m_pButton4:setVisible(false)
	else
		local mgr = PointCardServerManager.getInstanceNotCreate()
		if mgr and mgr.m_OpenFunctionList.info then
			for _,v in pairs(mgr.m_OpenFunctionList.info) do
                if v.key == FunOpenCloseType.FUN_BLACKMARKET then
                    if v.state == 1 then  --0功能开启 1功能关闭
                        self.m_pButton4:setVisible(false)
                    end
					break
                end
            end
		end
	end

    self.m_pButton1:setAlwaysOnTop(true)
    self.m_pButton2:setAlwaysOnTop(true)
    self.m_pButton3:setAlwaysOnTop(true)
	self.m_pButton4:setAlwaysOnTop(true)
    self:GetWindow():setModalState(true)
    self:GetWindow():setProperty("AllowModalStateClick", "False")
	

	self.m_pButton1:setText(MHSD_UTILS.get_resstring(11813)) --购买
	self.m_pButton2:setText(MHSD_UTILS.get_resstring(11813)) --出售
    self.m_pButton3:setText(MHSD_UTILS.get_resstring(IsPointCardServer() and 11813 or 11813)) --交易所/公示
	self.m_pButton4:setText(MHSD_UTILS.get_resstring(11813)) --地精市场

	self.m_pButton1:subscribeEvent("Clicked", StallLabel.handleLabelBtnClicked, self)
	self.m_pButton2:subscribeEvent("Clicked", StallLabel.handleLabelBtnClicked, self)
	self.m_pButton3:subscribeEvent("Clicked", StallLabel.handleLabelBtnClicked, self)
	self.m_pButton4:subscribeEvent("Clicked", StallLabel.handleLabelBtnClicked, self)
end

function StallLabel:new()
	local self={}
	self = Dialog:new()
	setmetatable(self, StallLabel)
	return self
end

function StallLabel:shAddMoneyClicked(args)-- 商会
    require("logic.shop.shoplabel").getInstance():showOnly(1)
    StallLabel.DestroyDialog()
end

function StallLabel:scAddMoneyClicked(args)-- 商城
    require("logic.shop.shoplabel").getInstance():showOnly(2)
    StallLabel.DestroyDialog()
end

function StallLabel:czAddMoneyClicked(args)-- 充值
    require("logic.shop.shoplabel").getInstance():showOnly(3)
    StallLabel.DestroyDialog()
end

function StallLabel.DestroyDialog()
	if _instance then
		if not _instance.m_bCloseIsHide then
			local dlg = StallDlg.getInstanceNotCreate()
            if dlg then
                dlg.DestroyDialog()
            end

            dlg = CurrencyTradingDlg.getInstanceNotCreate()
            if dlg then
                dlg.DestroyDialog()
            end

			dlg = TreasureHouseDlg.getInstanceNotCreate()
			if dlg then
				dlg.DestroyDialog()
			end

			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function StallLabel.show(idx)
    idx = idx or 1
	StallLabel.getInstance():showOnly(idx)
	_instance:GetWindow():setVisible(true)
    return _instance.curDialog
end

function StallLabel.openStallToBuy(itemid)
    StallDlg.isOpenForSpecialGoods = true
    StallLabel.show()
    if itemid and itemid > 0 then
        _instance.curDialog:selectGoodsCatalogByItemid(itemid)
    end
    StallDlg.isOpenForSpecialGoods = false
    return _instance.curDialog
end

function StallLabel:showOnly(index)
	self:setButtonPushed(index)
	
	if self.curIdx == index then
		return
	end
	self.curIdx = index
	
    local dlg = nil
	if index == 1 then
		dlg = self:getDialog(StallDlg)
        dlg:switchTabPage(1) --GROUP_BUY
	    dlg:resetData()
	elseif index == 2 then
		dlg = self:getDialog(StallDlg)
        dlg:switchTabPage(3) --GROUP_SELL
		dlg:resetData()
	elseif index == 3 then
        if IsPointCardServer() then
            dlg = self:getDialog(CurrencyTradingDlg)
        else
		    dlg = self:getDialog(StallDlg)
            dlg:switchTabPage(2) --GROUP_SHOW
		    dlg:resetData()
        end
	elseif index == 4 then
		dlg = self:getDialog(TreasureHouseDlg)
	end

    if dlg ~= self.curDialog then
        if self.curDialog then
		    self.curDialog:SetVisible(false)
	    end
        self.curDialog = dlg
    end
	
	self:SetVisible(true)
end

function StallLabel:getDialog(Dlg)
	local dlg = Dlg.getInstanceNotCreate()
	if not dlg then
		dlg = Dlg.getInstanceAndShow(self:GetWindow())
        dlg:GetWindow():setAlwaysOnTop(false)
	else
		dlg:SetVisible(true)
	end
	return dlg
end

function StallLabel:setButtonPushed(idx)
	for i,v in pairs(self.buttons) do
		v:SetPushState(i==idx)
	end
end

function StallLabel:handleLabelBtnClicked(e)
	local idx = CEGUI.toWindowEventArgs(e).window:getID()
    if idx == 2 then
        local lvLimit = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(160).value) --摆摊购买和出售等级
		local vipLevel = gGetDataManager():GetVipLevel()

	    if vipLevel < 1 then
	        local str = MHSD_UTILS.get_msgtipstring(193111)
	        str = string.gsub(str, "%$parameter1%$", lvLimit)
	        GetCTipsManager():AddMessageTip(str) --30级才可以出售物品，快升级哦！摆摊需要VIP
            return
        end
    elseif idx == 3 and IsPointCardServer() and b_fire_pb_fushi_OpenTrading ~= 1 then
        GetCTipsManager():AddMessageTipById(300011)
        return
    end
	self:showOnly(idx)
end

return StallLabel
