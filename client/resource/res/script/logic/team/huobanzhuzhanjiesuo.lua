require "logic.dialog"

huobanzhuzhanjiesuo = {}
setmetatable(huobanzhuzhanjiesuo, Dialog)
huobanzhuzhanjiesuo.__index = huobanzhuzhanjiesuo

local _instance
function huobanzhuzhanjiesuo.getInstance()
	if not _instance then
		_instance = huobanzhuzhanjiesuo:new()
		_instance:OnCreate()
	end
	return _instance
end

function huobanzhuzhanjiesuo.getInstanceAndShow()
	if not _instance then
		_instance = huobanzhuzhanjiesuo:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function huobanzhuzhanjiesuo.getInstanceNotCreate()
	return _instance
end

function huobanzhuzhanjiesuo.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
            CurrencyManager.unregisterTextWidget(_instance.m_MoneytText)
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function huobanzhuzhanjiesuo.ToggleOpenClose()
	if not _instance then
		_instance = huobanzhuzhanjiesuo:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function huobanzhuzhanjiesuo.GetLayoutFileName()
	return "huobanzhuzhanjiesuo.layout"
end

function huobanzhuzhanjiesuo:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, huobanzhuzhanjiesuo)
	return self
end

function huobanzhuzhanjiesuo:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

    self.m_moneyKeyCell1 = CEGUI.Window.toGroupButton(winMgr:getWindow("huobanzhuzhanjiesuo1/di1/huoban"))
    self.m_moneyKeyCell1:setID(1)
    self.m_moneyKeyCell1:subscribeEvent("SelectStateChanged", self.HandleMoneyKey, self)
    self.m_moneyKeyCell2 = CEGUI.Window.toGroupButton(winMgr:getWindow("huobanzhuzhanjiesuo1/di1/huoban1"))
    self.m_moneyKeyCell2:setID(2)
    self.m_moneyKeyCell2:subscribeEvent("SelectStateChanged", self.HandleMoneyKey, self)
    self.m_moneyKeyCell3 = CEGUI.Window.toGroupButton(winMgr:getWindow("huobanzhuzhanjiesuo1/di1/huoban2"))
    self.m_moneyKeyCell3:setID(3)
    self.m_moneyKeyCell3:subscribeEvent("SelectStateChanged", self.HandleMoneyKey, self)

    self.m_honorKeyCell1 = CEGUI.Window.toGroupButton(winMgr:getWindow("huobanzhuzhanjiesuo1/di1/huoban3"))
    self.m_honorKeyCell1:setID(1)
    self.m_honorKeyCell1:subscribeEvent("SelectStateChanged", self.HandleHonorKey, self)
    self.m_honorKeyCell2 = CEGUI.Window.toGroupButton(winMgr:getWindow("huobanzhuzhanjiesuo1/di1/huoban4"))
    self.m_honorKeyCell2:setID(2)
    self.m_honorKeyCell2:subscribeEvent("SelectStateChanged", self.HandleHonorKey, self)
    self.m_honorKeyCell3 = CEGUI.Window.toGroupButton(winMgr:getWindow("huobanzhuzhanjiesuo1/di1/huoban42"))
    self.m_honorKeyCell3:setID(3)
    self.m_honorKeyCell3:subscribeEvent("SelectStateChanged", self.HandleHonorKey, self)
    self.m_heroId = 0

    self.m_MoneytText = winMgr:getWindow("huobanzhuzhanjiesuo1/diban/text1")
    self.m_HonorText = winMgr:getWindow("huobanzhuzhanjiesuo1/diban/text11")
    CurrencyManager.registerTextWidget(fire.pb.game.MoneyType.MoneyType_SilverCoin, self.m_MoneytText)
    local allHonor = gGetDataManager():GetMainCharacterData():GetScoreValue(fire.pb.attr.RoleCurrency.HONOR_SCORE)
    local formatStr = require "utils.mhsdutils".GetMoneyFormatString(allHonor)
    self.m_HonorText:setText(formatStr)
end
function huobanzhuzhanjiesuo:setHeroId(heroid)
    self.m_heroId = heroid
    self:refreshUI()
end
function huobanzhuzhanjiesuo:refreshUI()
    local winMgr = CEGUI.WindowManager:getSingleton()
    local Head1 = CEGUI.Window.toItemCell(winMgr:getWindow("huobanzhuzhanjiesuo1/di1/huoban/touxiang"))
    local Head2 = CEGUI.Window.toItemCell(winMgr:getWindow("huobanzhuzhanjiesuo1/di1/huoban/touxiang1"))
    local Head3 = CEGUI.Window.toItemCell(winMgr:getWindow("huobanzhuzhanjiesuo1/di1/huoban/touxiang2"))
    local Head4 = CEGUI.Window.toItemCell(winMgr:getWindow("huobanzhuzhanjiesuo1/di1/huoban/touxiang3"))
    local Head5 = CEGUI.Window.toItemCell(winMgr:getWindow("huobanzhuzhanjiesuo1/di1/huoban/touxiang4"))
    local Head6 = CEGUI.Window.toItemCell(winMgr:getWindow("huobanzhuzhanjiesuo1/di1/huoban/touxiang42"))

    local record = BeanConfigManager.getInstance():GetTableByName("npc.cherobaseinfo"):getRecorder(self.m_heroId)
    local imageId = gGetIconManager():GetImageByID(record.headid)
    Head1:SetImage(imageId)
    Head2:SetImage(imageId)
    Head3:SetImage(imageId)
    Head4:SetImage(imageId)
    Head5:SetImage(imageId)
    Head6:SetImage(imageId)

    local allHonor = gGetDataManager():GetMainCharacterData():GetScoreValue(fire.pb.attr.RoleCurrency.HONOR_SCORE)

    local honorText1 = winMgr:getWindow("huobanzhuzhanjiesuo1/diban/text123")
    local honorText2 = winMgr:getWindow("huobanzhuzhanjiesuo1/diban/text124")
    local honorText3 = winMgr:getWindow("huobanzhuzhanjiesuo1/diban/text1242")

    local moneyText1 = winMgr:getWindow("huobanzhuzhanjiesuo1/diban/text12")
    local moneyText2 = winMgr:getWindow("huobanzhuzhanjiesuo1/diban/text121")
    local moneyText3 = winMgr:getWindow("huobanzhuzhanjiesuo1/diban/text122")

    local record = BeanConfigManager.getInstance():GetTableByName("npc.cherobaseinfo"):getRecorder(self.m_heroId)

    self.canHonor1 = self:setMoneyText(honorText1, record.day7_money[0], allHonor)
    self.canHonor2 = self:setMoneyText(honorText2, record.day30_money[0], allHonor)
    self.canHonor3 = self:setMoneyText(honorText3, record.forever_money[0], allHonor)
    
    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    local allMoney = roleItemManager:GetPackMoney()

    self.canMoney1 = self:setMoneyText(moneyText1, record.day7_money[1], allMoney)
    self.canMoney2 = self:setMoneyText(moneyText2, record.day30_money[1], allMoney)
    self.canMoney3 = self:setMoneyText(moneyText3, record.forever_money[1], allMoney)

end

function huobanzhuzhanjiesuo:setMoneyText(textObject, number, allNumber)
    local formatStr = require "utils.mhsdutils".GetMoneyFormatString(number)
    textObject:setText(formatStr)
    if number <= allNumber then
        textObject:setProperty("TextColours", "tl:ff8c5e2a tr:ff8c5e2a bl:ff8c5e2a br:ff8c5e2a")
        return true
    else
        textObject:setProperty("TextColours", "tl:ff8c5e2a tr:ff8c5e2a bl:ff8c5e2a br:ff8c5e2a")
        return false
    end
end
function huobanzhuzhanjiesuo:HandleMoneyKey(args)
    local cell = CEGUI.toWindowEventArgs(args).window
    local id = cell:getID()
    self:ClearSelect()
    local record = BeanConfigManager.getInstance():GetTableByName("npc.cherobaseinfo"):getRecorder(self.m_heroId)
    local strbuilder = StringBuilder:new()
    strbuilder:Set("Parameter1", record.name)
    strbuilder:Set("Parameter2", BeanConfigManager.getInstance():GetTableByName("message.cstringres"):getRecorder(11122).msg)
    local msgid = 0
    if id == 1 then
        strbuilder:Set("Parameter3", "\n" .. record.day7_money[1])
        msgid = 150122
    elseif id == 2 then
        strbuilder:Set("Parameter3", "\n" .. record.day30_money[1])
        msgid = 150145
    elseif id == 3 then
        strbuilder:Set("Parameter3", "\n" .. record.forever_money[1])
        msgid = 150146
    end
    local msg = strbuilder:GetString(MHSD_UTILS.get_msgtipstring(msgid))
    strbuilder:delete()
    local function ClickYes(self, args)
        gGetMessageManager():CloseConfirmBox(eConfirmNormal, false)
        local enablemsg = false
        local needmoney = 0
        local totalprice = 0
        local roleItemManager = require("logic.item.roleitemmanager").getInstance()
        local allMoney = roleItemManager:GetPackMoney()

        if id == 1 and self.canMoney1 == false then
            needmoney = record.day7_money[1] - allMoney
            totalprice = record.day7_money[1]
            enablemsg = true
        elseif id == 2 and self.canMoney2 == false then
            needmoney = record.day30_money[1] - allMoney
            totalprice = record.day30_money[1]
            enablemsg = true
        elseif id == 3 and self.canMoney3 == false then
            needmoney = record.forever_money[1] - allMoney
            totalprice = record.forever_money[1]
            enablemsg = true
        end
        if enablemsg then
            local strbuilder = StringBuilder:new()

            strbuilder:Set("Parameter2", BeanConfigManager.getInstance():GetTableByName("message.cstringres"):getRecorder(11122).msg)
            local msg = require "protodef.fire.pb.huoban.cactivehuoban":new()
            msg.huobanid = self.m_heroId
            msg.activetype = 1
            msg.activetime = id - 1
            -- 		local msg=strbuilder:GetString(MHSD_UTILS.get_msgtipstring(160015))
            strbuilder:delete()
            CurrencyManager.handleCurrencyNotEnough(fire.pb.game.MoneyType.MoneyType_SilverCoin, needmoney, totalprice, msg)
        else
            local p = require "protodef.fire.pb.huoban.cactivehuoban":new()
            p.huobanid = self.m_heroId
            p.activetype = 1
            p.activetime = id - 1
            require "manager.luaprotocolmanager":send(p)
        end
        
    end
    local function ClickNo(self, args)
        gGetMessageManager():CloseConfirmBox(eConfirmNormal, false)
    end
    gGetMessageManager():AddConfirmBox(eConfirmNormal, msg, ClickYes, self, ClickNo, self, 0, 0, nil, "", "")
end
function huobanzhuzhanjiesuo:HandleHonorKey(args)
    local cell = CEGUI.toWindowEventArgs(args).window
    local id = cell:getID()
    self:ClearSelect()
    local record = BeanConfigManager.getInstance():GetTableByName("npc.cherobaseinfo"):getRecorder(self.m_heroId)
    local strbuilder = StringBuilder:new()
    strbuilder:Set("Parameter1", record.name)
    strbuilder:Set("Parameter2", BeanConfigManager.getInstance():GetTableByName("message.cstringres"):getRecorder(11123).msg)
    local msgid = 0
    if id == 1 then
        strbuilder:Set("Parameter3", "\n" .. record.day7_money[0])
        msgid = 150122
    elseif id == 2 then
        strbuilder:Set("Parameter3", "\n" .. record.day30_money[0])
        msgid = 150145
    elseif id == 3 then
        strbuilder:Set("Parameter3", "\n" .. record.forever_money[0])
        msgid = 150146
    end
    local msg = strbuilder:GetString(MHSD_UTILS.get_msgtipstring(msgid))
    strbuilder:delete()
    local function ClickYes(self, args)
        gGetMessageManager():CloseConfirmBox(eConfirmNormal, false)
        local enablemsg = false
        local needmoney = 0
        local totalprice = 0
        local allMoney = gGetDataManager():GetMainCharacterData():GetScoreValue(fire.pb.attr.RoleCurrency.HONOR_SCORE)
        if id == 1 and self.canHonor1 == false then
            needmoney = record.day7_money[0] - allMoney
            totalprice = record.day7_money[0]
            enablemsg = true
        elseif id == 2 and self.canHonor2 == false then
            needmoney = record.day30_money[0] - allMoney
            totalprice = record.day30_money[0]
            enablemsg = true
        elseif id == 3 and self.canHonor3 == false then
            needmoney = record.forever_money[0] - allMoney
            totalprice = record.forever_money[0]
            enablemsg = true
        end
        if enablemsg then
            local strbuilder = StringBuilder:new()

            strbuilder:Set("Parameter2", BeanConfigManager.getInstance():GetTableByName("message.cstringres"):getRecorder(11123).msg)

            local msg = strbuilder:GetString(MHSD_UTILS.get_msgtipstring(150148))
            strbuilder:delete()
            GetCTipsManager():AddMessageTip(msg)
        else
            local p = require "protodef.fire.pb.huoban.cactivehuoban":new()
            p.huobanid = self.m_heroId
            p.activetype = 0
            p.activetime = id - 1
            require "manager.luaprotocolmanager":send(p)
        end
        
    end
    local function ClickNo(self, args)
        gGetMessageManager():CloseConfirmBox(eConfirmNormal, false)
    end
    gGetMessageManager():AddConfirmBox(eConfirmNormal, msg, ClickYes, self, ClickNo, self, 0, 0, nil, "", "")
end
function huobanzhuzhanjiesuo:ClearSelect()
    self.m_moneyKeyCell1:setSelected(false)
    self.m_moneyKeyCell2:setSelected(false)
    self.m_moneyKeyCell3:setSelected(false)
    self.m_honorKeyCell1:setSelected(false)
    self.m_honorKeyCell2:setSelected(false)
    self.m_honorKeyCell3:setSelected(false)
end
return huobanzhuzhanjiesuo