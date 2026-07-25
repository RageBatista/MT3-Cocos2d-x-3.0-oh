
require "logic.dialog"

Spacesetgiftdialog = {}
setmetatable(Spacesetgiftdialog, Dialog)
Spacesetgiftdialog.__index = Spacesetgiftdialog

local _instance
function Spacesetgiftdialog.getInstanceAndShow()
	if not _instance then
		_instance = Spacesetgiftdialog:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function Spacesetgiftdialog.DestroyDialog()
	if _instance then
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function Spacesetgiftdialog:clearData()
    self.nSetRewardNum = 0
end

function Spacesetgiftdialog:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, Spacesetgiftdialog)
    self:clearData()
	return self
end

function Spacesetgiftdialog:OnClose()
    gGetRoleItemManager().m_EventPackMoneyChange:RemoveScriptFunctor(self.m_hPackMoneyChange)
    if  self.spInputDlg then
        self.spInputDlg:DestroyDialog()
    end

    self:clearData()
    Dialog.OnClose(self)
end

function Spacesetgiftdialog:OnCreate(parent)
    Dialog.OnCreate(self,parent)

	local winMgr = CEGUI.WindowManager:getSingleton()
    
    self.btnLeft =  CEGUI.toPushButton(winMgr:getWindow("kongjianliwu/btn2"))
    self.btnLeft:subscribeEvent("MouseClick", Spacesetgiftdialog.clickSub, self)

    self.btnAdd =  CEGUI.toPushButton(winMgr:getWindow("kongjianliwu/btn1"))
    self.btnAdd:subscribeEvent("MouseClick", Spacesetgiftdialog.clickAdd, self)

    self.labelGiftCount = winMgr:getWindow("kongjianliwu/di/1") 
    self.labelGiftCount:subscribeEvent("MouseClick", Spacesetgiftdialog.clickLabelNum, self)

    self.labelNeedMoney = winMgr:getWindow("kongjianliwu/di1/xiaohao")  
    self.labelOwnMoney = winMgr:getWindow("kongjianliwu/di2/yongyou")

    self.btnBuyMoney = CEGUI.toPushButton(winMgr:getWindow("kongjianliwu/di2/btn3")) 
    self.btnBuyMoney:subscribeEvent("MouseClick", Spacesetgiftdialog.clicBuyMoney, self)

    self.btnConfirm = CEGUI.toPushButton(winMgr:getWindow("kongjianliwu/btnquxiao1"))
    self.btnConfirm:subscribeEvent("MouseClick", Spacesetgiftdialog.clickConfirm, self)

    self.btnCancel = CEGUI.toPushButton(winMgr:getWindow("kongjianliwu/btnquxiao"))
    self.btnCancel:subscribeEvent("MouseClick", Spacesetgiftdialog.clickCancel, self)

    self.m_hPackMoneyChange = gGetRoleItemManager().m_EventPackMoneyChange:InsertScriptFunctor(Spacesetgiftdialog.OnMoneyChange)
    
    --self.labelGiftCount:setText("1")

    self.nSetRewardNum = 10
    self:refreshOwnMoney()
    self:refreshSetGiftNumLabel()
end


function Spacesetgiftdialog:onNumInputChanged(num)
    if num == 0 then
		num = 1
	end
    self.nSetRewardNum = num
    self:refreshOwnMoney()
    self:refreshSetGiftNumLabel()
	
end

function Spacesetgiftdialog:clickLabelNum()
    local strValue = GameTable.common.GetCCommonTableInstance():getRecorder(331).value
    local nMaxNum = tonumber(strValue)

    local dlg = NumKeyboardDlg.getInstanceAndShow(self:GetWindow())
	if dlg then
		dlg:setTriggerBtn(self.numText)
        local maxNum = nMaxNum
        
		dlg:setMaxValue(maxNum)
		dlg:setInputChangeCallFunc(Spacesetgiftdialog.onNumInputChanged, self)
		
		local p = self.labelGiftCount:GetScreenPos()
		SetPositionOffset(dlg:GetWindow(), p.x-15, p.y-10, 0.5, 1)
	end

end

function Spacesetgiftdialog.OnMoneyChange()
	if not _instance then
		return
	end
    _instance:refreshOwnMoney()
end

function Spacesetgiftdialog:clickConfirm(args)
    local strText = self.labelGiftCount:getText()
    local nNum = tonumber(strText)
    if nNum<=0 then
        local strShowTip = require("utils.mhsdutils").get_resstring(11534)
		GetCTipsManager():AddMessageTip(strShowTip)
        return 
    end
    local p = require "protodef.fire.pb.friends.csetspacegift":new()
	p.giftnum = nNum
	require "manager.luaprotocolmanager":send(p)
    Spacesetgiftdialog.DestroyDialog()
end

function Spacesetgiftdialog:clickCancel(args)
    Spacesetgiftdialog.DestroyDialog()
end

function Spacesetgiftdialog:refreshOwnMoney()
    local nUserMoney = require("logic.item.roleitemmanager").getInstance():GetPackMoney()
    self.labelOwnMoney:setText(tostring(nUserMoney))
    self:refreshSetGiftNumLabel()

end

function Spacesetgiftdialog:clicBuyMoney(args)
    local dlg = require "logic.currency.stonegoldexchangesilverdlg".getInstanceAndShow()
	dlg:GetWindow():setAlwaysOnTop(true)

--[[
    local nMoneyType = fire.pb.game.MoneyType.MoneyType_SilverCoin
	local nShowNeed = nNeedMoney - nUserMoney
	CurrencyManager.handleCurrencyNotEnough(nMoneyType, nShowNeed)
    --]]
end

function Spacesetgiftdialog:clickSub(args)
    self.nSetRewardNum = self.nSetRewardNum - 1
    if self.nSetRewardNum < 0 then
        self.nSetRewardNum = 0
    end
    self:refreshSetGiftNumLabel()
end

function Spacesetgiftdialog:clickAdd(args)
    
    local strValue = GameTable.common.GetCCommonTableInstance():getRecorder(331).value
    local nMaxNum = tonumber(strValue)

    if self.nSetRewardNum >= nMaxNum then
        return
    end

    self.nSetRewardNum = self.nSetRewardNum + 1
    self:refreshSetGiftNumLabel()
end

function Spacesetgiftdialog:refreshSetGiftNumLabel()
    self.labelGiftCount:setText(self.nSetRewardNum) 
    local strValue = GameTable.common.GetCCommonTableInstance():getRecorder(330).value
    local nNeedMoney = tonumber(strValue)
    local nNeedMoneyAll = self.nSetRewardNum * nNeedMoney
    self.labelNeedMoney:setText(tostring(nNeedMoneyAll))

    self:refreshOwnColor(nNeedMoneyAll)
end

function Spacesetgiftdialog:refreshOwnColor(nNeedNum)
    local nUserMoney = require("logic.item.roleitemmanager").getInstance():GetPackMoney()
    local strContent = tostring(nNeedNum)
    if nUserMoney >= nNeedNum then
        --local color = CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("ff50321a"))
        --self.labelOwnMoney:SetTextColor(0xff50321a)
        local strColor = "ff50321a"
        strContent = "[colour=".."\'"..strColor.."\'".."]"..strContent
    else
     
        --local color = CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("ffff0000"))
        --self.labelOwnMoney:SetTextColor(0xffff0000)
          local strColor = "ffff0000"
        strContent = "[colour=".."\'"..strColor.."\'".."]"..strContent
    end
    self.labelNeedMoney:setProperty("TextColours","ffffffff")
    self.labelNeedMoney:setText(strContent)
end

function Spacesetgiftdialog:GetLayoutFileName()
	return "kongjianliwu.layout"
end


return Spacesetgiftdialog