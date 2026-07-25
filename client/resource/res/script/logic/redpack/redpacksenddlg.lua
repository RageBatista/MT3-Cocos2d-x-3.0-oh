require "logic.dialog"

RedPackSendDlg = {}
setmetatable(RedPackSendDlg, Dialog)
RedPackSendDlg.__index = RedPackSendDlg

local _instance
function RedPackSendDlg.getInstance()
	if not _instance then
		_instance = RedPackSendDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function RedPackSendDlg.getInstanceAndShow()
	if not _instance then
		_instance = RedPackSendDlg:new()    
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function RedPackSendDlg.getInstanceNotCreate()
	return _instance
end

function RedPackSendDlg.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function RedPackSendDlg.ToggleOpenClose()
	if not _instance then
		_instance = RedPackSendDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function RedPackSendDlg.GetLayoutFileName()
	return "hongbaojiemian.layout"
end

function RedPackSendDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, RedPackSendDlg)
	return self
end

function RedPackSendDlg:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

    self.m_main = winMgr:getWindow("hongbaojiemiansend")
    self.m_text1 = winMgr:getWindow("hongbaojiemiansend/hongbao1/ziti")
    self.m_Dec = CEGUI.toPushButton(winMgr:getWindow("hongbaojiemiansend/guize/tanhao"))
    self.m_Dec:subscribeEvent("MouseClick", RedPackDlg.HandleDesClicked, self)
    self.m_SubMoney = CEGUI.toPushButton(winMgr:getWindow("hongbaojiemiansend/jianhao"))
    self.m_AddMoney = CEGUI.toPushButton(winMgr:getWindow("hongbaojiemiansend/jiahao"))
    self.m_MoneyText = winMgr:getWindow("hongbaojiemiansend/shurukuang/text")
    self.m_SubNum = CEGUI.toPushButton(winMgr:getWindow("hongbaojiemiansend/jianhao1"))
    self.m_AddNum = CEGUI.toPushButton(winMgr:getWindow("hongbaojiemiansend/jiahao1"))
    self.m_NumText = winMgr:getWindow("hongbaojiemiansend/shurukuang/text1")
    self.m_TalkText = CEGUI.toRichEditbox(winMgr:getWindow("hongbaojiemiansend/kuang/zhezhao"))
    self.m_TalkText:subscribeEvent("CaratMoved",  RedPackSendDlg.HandleTextChange, self)
    self.m_TalkText:subscribeEvent("KeyboardTargetWndChanged",  RedPackSendDlg.HandleKeyboardTargetWndChanged, self)
    
    self.m_NormalText = winMgr:getWindow("hongbaojiemiansend/kuang/wenzi")
    self.m_TalkText:setMaxTextLength(32)
    self.m_SendBtn = CEGUI.toPushButton(winMgr:getWindow("hongbaojiemiansend/anniu3"))
    self.m_SendBtn:subscribeEvent("MouseClick", RedPackSendDlg.HandleSendClicked, self)
    self.m_img = winMgr:getWindow("hongbaojiemiansend/hongbao1/jinbi")
    self.m_AddMoney:subscribeEvent("MouseClick", RedPackSendDlg.HandleAddMoneyClicked, self)
    self.m_SubMoney:subscribeEvent("MouseClick", RedPackSendDlg.HandleSubMoneyClicked, self)
    self.m_AddNum:subscribeEvent("MouseClick", RedPackSendDlg.HandleAddNumClicked, self)
    self.m_SubNum:subscribeEvent("MouseClick", RedPackSendDlg.HandleSubNumClicked, self)
    self.m_MoneyText:subscribeEvent("MouseClick", RedPackSendDlg.handleMoneyKeyClicked, self)
    self.m_NumText:subscribeEvent("MouseClick", RedPackSendDlg.handleNumKeyClicked, self)
    self.m_imgNew = winMgr:getWindow("hongbaojiemiansend/jinbi1")
    self.m_textDengyu = winMgr:getWindow("hongbaojiemiansend/wenzi1")
    self.m_textMoneyMin = winMgr:getWindow("hongbaojiemiansend/ziti1")
    self.m_textMoneyMax = winMgr:getWindow("hongbaojiemiansend/wenzi2")
    self.m_MaxMoney = 0
    self.m_MinMoney = 0
    self.m_MaxNum = 0
    self.m_MinNum = 0
    self.m_Money = 0
    self.m_Num = 0
    self.m_index = 1
    
end
function RedPackSendDlg:HandleDesClicked(e)
    local tips1 = require "logic.workshop.tips1"
    local title = MHSD_UTILS.get_resstring(11490)
    local tipsid = 11487
    if self.m_index == 1 then
        tipsid = 11487
    elseif self.m_index == 2 then
        tipsid = 11488
    elseif self.m_index == 3 then
        tipsid = 11489
    end
    local manager = require "logic.pointcardserver.pointcardservermanager".getInstanceNotCreate()
    if manager then
        if manager.m_isPointCardServer then
             if self.m_index == 1 then
                tipsid = 11516
            elseif self.m_index == 2 then
                tipsid = 11517
            elseif self.m_index == 3 then
                tipsid = 11518
            end       
        end
    end

    local strAllString = MHSD_UTILS.get_resstring(tipsid)
    local tips_instance = tips1.getInstanceAndShow(strAllString, title)
end
function RedPackSendDlg:HandleTextChange(e)
    local str = self.m_TalkText:GetPureText()
    local ret,strNew = RedPackSendDlg.ShiedText(str)
    if ret then
        str = strNew
        self.m_TalkText:Clear()
        self.m_TalkText:AppendText(CEGUI.String(str))
        
        self.m_TalkText:Refresh()
        self.m_TalkText:SetCaratEnd()
    end
    local splited = false
    str, splited = SliptStrByCharCount(str, 32)
    if splited then
        self.m_TalkText:Clear()
        self.m_TalkText:AppendText(CEGUI.String(str))
        
        self.m_TalkText:Refresh() 
        self.m_TalkText:SetCaratEnd() 
    end
  
end
local function getShieldStr(str)
	assert(str)
	--local len = string.len(str)
    --汉字和英文分开处理
    local cNum, eNum = GetCharCount(str)
	local size = {}
	for i = 1, cNum do
		size[i] = '*'
	end
    for j = 1, eNum do
		size[#size + 1] = '*'
	end
	return table.concat(size)
end
function RedPackSendDlg.ShiedText(inText)
    inText = MHSD_UTILS.trim(inText)
	local shied = false
	if string.len(inText)>0 then
		local configtable = BeanConfigManager.getInstance():GetTableByName("chat.cbanwords")
		local banwordids = configtable:getAllID()
		for _,id in pairs(banwordids) do
			local word = configtable:getRecorder(id).BanWords
			word = MHSD_UTILS.trim(word)
			if string.match(inText, word) then
				shied = true
			end
            if shied then
                inText = string.gsub(inText, word, getShieldStr(word))
            end
		end
	end
	return shied, inText
end
function RedPackSendDlg:HandleSendClicked(e)

    local money = CurrencyManager.getOwnCurrencyMount(fire.pb.game.MoneyType.MoneyType_HearthStone)
	local manager = require "logic.pointcardserver.pointcardservermanager".getInstanceNotCreate()
    if manager then
        if manager.m_isPointCardServer then
            money = CurrencyManager.getOwnCurrencyMount(fire.pb.game.MoneyType.MoneyType_GoldCoin)
        end
    end
    if money < self.m_Money then
       
        if manager then
            if manager.m_isPointCardServer then
                CurrencyManager.handleCurrencyNotEnough(fire.pb.game.MoneyType.MoneyType_GoldCoin, 0, 0, 0, 0)
            else
                CurrencyManager.handleCurrencyNotEnough(fire.pb.game.MoneyType.MoneyType_HearthStone, 0, 0, 0, 0)
                self.DestroyDialog()
            end
        end
        --require("logic.shop.shoplabel").getInstance():showOnly(3)
        
        return
    end

    local dlg = require("logic.redpack.redpacksendconfirmdlg").getInstanceAndShow()
    if dlg then
        if string.len(self.m_TalkText:GetPureText()) == 0 then
            dlg:setData(self.m_index, self.m_Money, self.m_Num, self.m_NormalText:getText())
        else
            dlg:setData(self.m_index, self.m_Money, self.m_Num, self.m_TalkText:GetPureText())
        end
        
    end


    --self.DestroyDialog()
end
function RedPackSendDlg:handleMoneyKeyClicked(e)
	if NumKeyboardDlg.getInstanceNotCreate() then
		NumKeyboardDlg.getInstanceNotCreate():SetVisible(true) --保持键盘在最上面
        NumKeyboardDlg:setTriggerBtn(self.m_MoneyText)
		NumKeyboardDlg:setMaxValue(self.m_MaxMoney)
        --dlg:setMinValue(self.m_MinMoney)
		NumKeyboardDlg:setInputChangeCallFunc(RedPackSendDlg.onMoneyInputChanged, self)
		NumKeyboardDlg:setCloseCallFunc(RedPackSendDlg.onMoneyClose, self)
		local p = self.m_MoneyText:GetScreenPos()
		SetPositionOffset(NumKeyboardDlg:GetWindow(), p.x-350, p.y+130, 0.5, 1)
		return
	end
	
	local dlg = NumKeyboardDlg.getInstanceAndShow()
	if dlg then
		dlg:setTriggerBtn(self.m_MoneyText)
		dlg:setMaxValue(self.m_MaxMoney)
        --dlg:setMinValue(self.m_MinMoney)
		dlg:setInputChangeCallFunc(RedPackSendDlg.onMoneyInputChanged, self)
		dlg:setCloseCallFunc(RedPackSendDlg.onMoneyClose, self)
		local p = self.m_MoneyText:GetScreenPos()
		SetPositionOffset(dlg:GetWindow(), p.x-350, p.y+130, 0.5, 1)
	end
end
function RedPackSendDlg:onMoneyClose()
    if self.m_Money < self.m_MinMoney then
        self.m_Money = self.m_MinMoney
        self.m_MoneyText:setText(tostring(self.m_MinMoney))
        local money = CurrencyManager.getOwnCurrencyMount(fire.pb.game.MoneyType.MoneyType_HearthStone)
	    local manager = require "logic.pointcardserver.pointcardservermanager".getInstanceNotCreate()
        if manager then
            if manager.m_isPointCardServer then
                money = CurrencyManager.getOwnCurrencyMount(fire.pb.game.MoneyType.MoneyType_GoldCoin)
            end
        end
        if money< self.m_MinMoney then
            local huoliColor = "FFFF0000"
	        local textColor = "tl:"..huoliColor.." tr:"..huoliColor.." bl:"..huoliColor.." br:"..huoliColor
	        self.m_MoneyText:setProperty("TextColours", textColor)
        else 
            local huoliColor = "ff472b20"
	        local textColor = "tl:"..huoliColor.." tr:"..huoliColor.." bl:"..huoliColor.." br:"..huoliColor
	        self.m_MoneyText:setProperty("TextColours", textColor)
        end
        return
    end
end
function RedPackSendDlg:Update(delta)
    --local text = self.m_TalkText:GetPureText()
    --self.m_NormalText:setVisible((text == "" and self.m_TalkText:hasInputFocus()))
end
function RedPackSendDlg:HandleKeyboardTargetWndChanged(args)
    local wnd = CEGUI.toWindowEventArgs(args).window
    if wnd == self.m_TalkText then
        self.m_NormalText:setVisible(false)
    else
        if self.m_TalkText:GetPureText() == "" then
            self.m_NormalText:setVisible(true)
        end
    end
end
function RedPackSendDlg:onMoneyInputChanged(num)

    self.m_Money = num
    self.m_MoneyText:setText(tostring(num))
    local money = CurrencyManager.getOwnCurrencyMount(fire.pb.game.MoneyType.MoneyType_HearthStone)
	local manager = require "logic.pointcardserver.pointcardservermanager".getInstanceNotCreate()
    if manager then
        if manager.m_isPointCardServer then
            money = CurrencyManager.getOwnCurrencyMount(fire.pb.game.MoneyType.MoneyType_GoldCoin)
        end
    end
    if money< num then
        local huoliColor = "FFFF0000"
	    local textColor = "tl:"..huoliColor.." tr:"..huoliColor.." bl:"..huoliColor.." br:"..huoliColor
	    self.m_MoneyText:setProperty("TextColours", textColor)
    else 
        local huoliColor = "ff472b20"
	    local textColor = "tl:"..huoliColor.." tr:"..huoliColor.." bl:"..huoliColor.." br:"..huoliColor
	    self.m_MoneyText:setProperty("TextColours", textColor)
    end
end
function RedPackSendDlg:onNumClose()
    if self.m_Num < self.m_MinNum then
        self.m_Num = self.m_MinNum
        self.m_NumText:setText(tostring(self.m_MinNum))
        return
    end
end
function RedPackSendDlg:onNumInputChanged(num)

    self.m_Num = num
    self.m_NumText:setText(tostring(num))
end
function RedPackSendDlg:handleNumKeyClicked(e)
	if NumKeyboardDlg.getInstanceNotCreate() then
		NumKeyboardDlg.getInstanceNotCreate():SetVisible(true) --保持键盘在最上面
        NumKeyboardDlg:setTriggerBtn(self.m_NumText)
		NumKeyboardDlg:setMaxValue(self.m_MaxNum)
        --dlg:setMinValue(self.m_MinNum)
		NumKeyboardDlg:setInputChangeCallFunc(RedPackSendDlg.onNumInputChanged, self)
		NumKeyboardDlg:setCloseCallFunc(RedPackSendDlg.onNumClose, self)
		local p = self.m_NumText:GetScreenPos()
		SetPositionOffset(NumKeyboardDlg:GetWindow(), p.x-15, p.y-10, 0.5, 1)
		return true
	end
	
	local dlg = NumKeyboardDlg.getInstanceAndShow()
	if dlg then
		dlg:setTriggerBtn(self.m_NumText)
		dlg:setMaxValue(self.m_MaxNum)
        --dlg:setMinValue(self.m_MinNum)
		dlg:setInputChangeCallFunc(RedPackSendDlg.onNumInputChanged, self)
		dlg:setCloseCallFunc(RedPackSendDlg.onNumClose, self)
		local p = self.m_NumText:GetScreenPos()
		SetPositionOffset(dlg:GetWindow(), p.x-15, p.y-10, 0.5, 1)
	end
end
function RedPackSendDlg:HandleAddMoneyClicked(e)

    if self.m_Money >= self.m_MaxMoney then
        GetCTipsManager():AddMessageTipById(160044)
    else
        self.m_Money = self.m_Money + 1
        self.m_MoneyText:setText(tostring(self.m_Money))
        local money = CurrencyManager.getOwnCurrencyMount(fire.pb.game.MoneyType.MoneyType_HearthStone)
	    local manager = require "logic.pointcardserver.pointcardservermanager".getInstanceNotCreate()
        if manager then
            if manager.m_isPointCardServer then
                money = CurrencyManager.getOwnCurrencyMount(fire.pb.game.MoneyType.MoneyType_GoldCoin)
            end
        end
        if money< self.m_Money then
            local huoliColor = "FFFF0000"
	        local textColor = "tl:"..huoliColor.." tr:"..huoliColor.." bl:"..huoliColor.." br:"..huoliColor
	        self.m_MoneyText:setProperty("TextColours", textColor)
        else 
            local huoliColor = "ff472b20"
	        local textColor = "tl:"..huoliColor.." tr:"..huoliColor.." bl:"..huoliColor.." br:"..huoliColor
	        self.m_MoneyText:setProperty("TextColours", textColor)
        end
    end
end
function RedPackSendDlg:HandleSubMoneyClicked(e)
    if self.m_Money <= self.m_MinMoney then
        GetCTipsManager():AddMessageTipById(160044)
    else
        self.m_Money = self.m_Money - 1
        self.m_MoneyText:setText(tostring(self.m_Money))
        local money = CurrencyManager.getOwnCurrencyMount(fire.pb.game.MoneyType.MoneyType_HearthStone)
    	local manager = require "logic.pointcardserver.pointcardservermanager".getInstanceNotCreate()
        if manager then
            if manager.m_isPointCardServer then
                money = CurrencyManager.getOwnCurrencyMount(fire.pb.game.MoneyType.MoneyType_GoldCoin)
            end
        end
        if money< self.m_Money then
            local huoliColor = "FFFF0000"
	        local textColor = "tl:"..huoliColor.." tr:"..huoliColor.." bl:"..huoliColor.." br:"..huoliColor
	        self.m_MoneyText:setProperty("TextColours", textColor)
        else 
            local huoliColor = "ff472b20"
	        local textColor = "tl:"..huoliColor.." tr:"..huoliColor.." bl:"..huoliColor.." br:"..huoliColor
	        self.m_MoneyText:setProperty("TextColours", textColor)
        end
    end
end
function RedPackSendDlg:HandleAddNumClicked(e)
    if self.m_Num >= self.m_MaxNum then
        GetCTipsManager():AddMessageTipById(160044)
    else
        self.m_Num = self.m_Num + 1
        self.m_NumText:setText(tostring(self.m_Num))
    end
end
function RedPackSendDlg:HandleSubNumClicked(e)
    if self.m_Num <= self.m_MinNum then
        GetCTipsManager():AddMessageTipById(160044)
    else
        self.m_Num = self.m_Num - 1
        self.m_NumText:setText(tostring(self.m_Num))
    end
end
function RedPackSendDlg:InitData(index)
    self.m_index = index
    self.m_textDengyu:setVisible(true)
    self.m_img:setProperty("Image", "set:common image:common_jinb")
	local manager = require "logic.pointcardserver.pointcardservermanager".getInstanceNotCreate()
    if manager then
        if manager.m_isPointCardServer then
            self.m_imgNew:setProperty("Image", "set:common image:common_jinb")
            self.m_textDengyu:setVisible(false)
        else
            self.m_imgNew:setProperty("Image", "set:lifeskillui image:fushi")
        end
    end
	local manager = require "logic.pointcardserver.pointcardservermanager".getInstanceNotCreate()
    if manager then
        if manager.m_isPointCardServer then
            index = index + 1000
        end
    end
    local record = BeanConfigManager.getInstance():GetTableByName("fushi.credpackconfig"):getRecorder(index)
    self.m_main:setText(record.name)
    self.m_textMoneyMin:setText(MHSD_UTILS.get_resstring(11514)..record.fushimin)
    self.m_textMoneyMax:setText(MHSD_UTILS.get_resstring(11515)..record.fishimax)
    self.m_text1:setText(record.name)
    self.m_MaxMoney = record.fishimax
    self.m_MinMoney = record.fushimin
    self.m_MoneyText:setText(tostring(record.fushimin))
    local money = CurrencyManager.getOwnCurrencyMount(fire.pb.game.MoneyType.MoneyType_HearthStone)
	local manager = require "logic.pointcardserver.pointcardservermanager".getInstanceNotCreate()
    if manager then
        if manager.m_isPointCardServer then
            money = CurrencyManager.getOwnCurrencyMount(fire.pb.game.MoneyType.MoneyType_GoldCoin)
        end
    end
    if money< record.fushimin then
        local huoliColor = "FFFF0000"
	    local textColor = "tl:"..huoliColor.." tr:"..huoliColor.." bl:"..huoliColor.." br:"..huoliColor
	    self.m_MoneyText:setProperty("TextColours", textColor)
    else 
        local huoliColor = "ff472b20"
	    local textColor = "tl:"..huoliColor.." tr:"..huoliColor.." bl:"..huoliColor.." br:"..huoliColor
	    self.m_MoneyText:setProperty("TextColours", textColor)
    end
    self.m_Money = record.fushimin
    self.m_MaxNum = record.packmax
    self.m_MinNum = record.packmin
    self.m_NumText:setText(tostring(record.packmin))
    self.m_Num = record.packmin
end
return RedPackSendDlg