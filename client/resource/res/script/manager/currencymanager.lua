------------------------------------------------------------------
-- ���ҹ���
------------------------------------------------------------------
require "utils.typedefine"
require "utils.tableutil"
require "logic.shop.exchangesilver"
require "logic.shop.exchangegold"

CurrencyManager = {}

CurrencyManager.currencyTypes = {}
CurrencyManager.compareWidgets = {}
CurrencyManager.registerWidgets = {}
CurrencyManager.autoBuyArgs = nil --{price, protcol}
CurrencyManager.otherMoneyEventNum = 0
local m = CurrencyManager


--��ʽ����Ǯ������ÿ3λ��һ����
function MoneyFormat(num)
	local str = tostring(num)
	if #str <= 3 then
		return str
	end
	
	local t = {}
	local i = 1
	local offset = 0
	while true do
		offset = (i == 1 and #str % 3 ~= 0) and #str % 3 or 3
		table.insert(t, string.sub(str, i, i + offset - 1))
		i = i + offset
		if i > #str then
			break
		end
	end
	return table.concat(t, ",")
end

function MoneyNumber(str)
	str = string.gsub(str, ",", "")
	return tonumber(str)
end

function CurrencyManager.init()
    if gGetRoleItemManager() and gGetDataManager() then
        if not m.eventMoneyChange then
            m.eventMoneyChange = gGetRoleItemManager().m_EventPackMoneyChange:InsertScriptFunctor(CurrencyManager.onPackMoneyChanged)
        end
        if not m.eventGoldChange then
		    m.eventGoldChange = gGetRoleItemManager().m_EventPackGoldChange:InsertScriptFunctor(CurrencyManager.onPackGoldChanged)
        end
        if not m.eventStoneChange then
		    m.eventStoneChange = gGetDataManager().m_EventYuanBaoNumberChange:InsertScriptFunctor(CurrencyManager.onStoneChanged)
        end
        if not m.eventOtherMoneyChange then
		    m.eventOtherMoneyChange = gGetRoleItemManager().m_EventTypeMoneyChange:InsertScriptFunctor(CurrencyManager.onOtherMoneyChange)
        end
    end
end

function CurrencyManager.purgeData()
    if gGetRoleItemManager() and gGetDataManager() then
        if m.eventMoneyChange then
            gGetRoleItemManager().m_EventPackMoneyChange:RemoveScriptFunctor(m.eventMoneyChange)
        end
        if m.eventGoldChange then
            gGetRoleItemManager().m_EventPackGoldChange:RemoveScriptFunctor(m.eventGoldChange)
        end
        if m.eventStoneChange then
            gGetDataManager().m_EventYuanBaoNumberChange:RemoveScriptFunctor(m.eventStoneChange)
        end
        if m.eventOtherMoneyChange then
            gGetRoleItemManager().m_EventTypeMoneyChange:RemoveScriptFunctor(m.eventOtherMoneyChange)
        end
    end

    m.eventMoneyChange = nil
    m.eventGoldChange = nil
    m.eventStoneChange = nil
    m.eventOtherMoneyChange = nil
end

--���û���ͼ��
--@currencyType		fire.pb.game.MoneyType
--@iconWidget		StaticImage
function CurrencyManager.setCurrencyIcon(currencyType, iconWidget)
	local conf = BeanConfigManager.getInstance():GetTableByName("shop.ccurrencyiconpath"):getRecorder(currencyType)
	iconWidget:setProperty("Image", conf.iconpath)
end

function CurrencyManager.getCurrencyName(currencyType)
	return BeanConfigManager.getInstance():GetTableByName("shop.ccurrencyiconpath"):getRecorder(currencyType).name
end

--�������ò����»��ҵ�Ǯ��
--@currencyType		fire.pb.game.MoneyType
--@textWidget		StaticText
function CurrencyManager.registerTextWidget(currencyType, textWidget)
	if m.currencyTypes[textWidget] == currencyType then
		return
	end
	m.unregisterTextWidget(textWidget)
	
	--if not m.registerWidgets[currencyType] or TableUtil.tablelength(m.registerWidgets[currencyType]) == 0 then
	m.registerWidgets[currencyType] = m.registerWidgets[currencyType] or {}
		
	--end
	
	textWidget:setText(MoneyFormat(m.getOwnCurrencyMount(currencyType)))
	table.insert(m.registerWidgets[currencyType], textWidget)
	m.currencyTypes[textWidget] = currencyType
end

--��textWidget��ֵ�仯�������compareWidget��С����compareWidget��ʾ���(��ɫ)
function CurrencyManager.setCompareTextWidget(textWidget, compareWidget)
    m.compareWidgets[textWidget] = compareWidget
    if not compareWidget then
        return
    end
    if MoneyNumber(textWidget:getText()) < MoneyNumber(compareWidget:getText()) then
        compareWidget:setProperty("BorderEnable", "True")  --  描边
        compareWidget:setProperty("TextColours", "FFFF0000")  --  货币不足-红色
    else
        compareWidget:setProperty("BorderEnable", "True")  --  描边
        compareWidget:setProperty("TextColours", "FFFFFFFF")  --  货币足够-白色
    end
end


function CurrencyManager.unregisterTextWidget(textWidget)
	local currencyType = m.currencyTypes[textWidget]
	if not currencyType then
		return
	end
	
	m.compareWidgets[textWidget] = nil
	
	if not m.registerWidgets or not m.registerWidgets[currencyType] then
		return
	end
	
	for i,v in pairs(m.registerWidgets[currencyType]) do
		if v == textWidget then
			table.remove(m.registerWidgets[currencyType], i)
			break
		end
	end
	
	m.currencyTypes[textWidget] = nil
end

--��ѯ��ע��ؼ�����Ӧ�Ļ�������
function CurrencyManager.getWidgetCurrencyType(widget)
	return m.currencyTypes[textWidget] or fire.pb.game.MoneyType.MoneyType_None
end

--��ȡ��ǰĳ�ֻ��ҵ�Ǯ��
function CurrencyManager.getOwnCurrencyMount(currencyType)
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	if currencyType == fire.pb.game.MoneyType.MoneyType_SilverCoin then  --����
			return roleItemManager:GetPackMoney()
			
		elseif currencyType == fire.pb.game.MoneyType.MoneyType_GoldCoin then  --���
			return roleItemManager:GetGold()
			
		elseif currencyType == fire.pb.game.MoneyType.MoneyType_HearthStone then  --��ʯ
			return gGetDataManager():GetYuanBaoNumber()
			
		--[[elseif currencyType == fire.pb.game.MoneyType.MoneyType_XiaYiVal or  --��ֵ
               currencyType == fire.pb.game.MoneyType.MoneyType_WuXunVal or  --����ֵ
			   currencyType == fire.pb.game.MoneyType.MoneyType_FestivalPoint or  --���ջ���
			   currencyType == fire.pb.game.MoneyType.MoneyType_GoodTeacherVal or  --��ʦֵ
               currencyType == fire.pb.game.MoneyType.MoneyType_ProfContribute or  --ְҵ����
               currencyType == fire.pb.game.MoneyType.MoneyType_FactionContribute then  --���ṱ��
        --]]
        else
			LogInfo("走到了这里"..currencyType)
			return roleItemManager:GetMoneyByMoneyType(currencyType)
		end
	return 0
end

--�Ƿ�֧�����𣬷��ػ����Ǯ��
function CurrencyManager.canAfford(currencyType, price)
	local ownNum = m.getOwnCurrencyMount(currencyType)
	return price-ownNum
end

--�������ȼ��Ƿ���Թ���
function CurrencyManager.checkRoleLevel(goodsId, showTip)
	local rolelv = gGetDataManager():GetMainCharacterLevel()
	local goodsConf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cgoods")):getRecorder(goodsId)
	if rolelv < goodsConf.lvMin then
		if showTip then
			local str = MHSD_UTILS.get_msgtipstring(150502)
			str = string.gsub(str, "(.*)%$parameter1%$(.*)%$parameter2%$(.*)", "%1" .. goodsConf.lvMin .. "%2" .. goodsConf.name .. "%3")
			GetCTipsManager():AddMessageTip(str) --���ĵȼ�����xx�����޷�����xxx
		end
		return false
	elseif rolelv > goodsConf.lvMax then
		if showTip then
			local str = MHSD_UTILS.get_msgtipstring(150503)
			str = string.gsub(str, "(.*)%$parameter1%$(.*)%$parameter2%$(.*)", "%1" .. goodsConf.lvMin .. "%2" .. goodsConf.name .. "%3")
			GetCTipsManager():AddMessageTip(str) --���ĵȼ�����xx�����޷�����xxx
		end
		return false
	end
	return true
end

--Ǯ����ʱ������ʱ��������Ӧ���͵Ļ����㹻ʱ�����͹���Э��
function CurrencyManager.setAutoBuyArgs(currencyType, price, protocol, widget)
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    if m.scheduleForAutoBuyRes then
        CurrencyManager.stopScheduleAutoBuyRes()
    end

	if not currencyType or not price or not protocol then
		CurrencyManager.autoBuyArgs = nil
		roleItemManager:setShowMoneyFlyEffect(true)
		return
	end
	CurrencyManager.autoBuyArgs = {currencyType=currencyType, price=price, protocol=protocol, widget=widget}
	roleItemManager:setShowMoneyFlyEffect(false)
end


function CurrencyManager.handleCurrencyNotEnough(currencyType, needNum, price, protocol, widget)
	if currencyType == fire.pb.game.MoneyType.MoneyType_HearthStone then  --��ʯ
		CurrencyManager.setAutoBuyArgs(nil)
		gGetMessageManager():AddConfirmBox(
			eConfirmNormal,
			MHSD_UTILS.get_msgtipstring(150506),
			function()
				require("logic.shop.shoplabel").showRecharge()
				gGetMessageManager():CloseConfirmBox(eConfirmNormal,false)
			end,0,
			MessageManager.HandleDefaultCancelEvent,MessageManager
		)
		return
	end
	
	if currencyType and price and protocol then
		CurrencyManager.setAutoBuyArgs(currencyType, price, protocol, widget)
	end
	
	if currencyType == fire.pb.game.MoneyType.MoneyType_SilverCoin then  --����
		local dlg = ExchangeSilver.getInstanceAndShow()
		dlg:setNeedNum(needNum)
		
	elseif currencyType == fire.pb.game.MoneyType.MoneyType_GoldCoin then  --���
        if IsPointCardServer() then
            CurrencyManager.setAutoBuyArgs(nil)
            GetCTipsManager():AddMessageTipById(160118) --��Ҳ���
        else
		    -- local dlg = ExchangeGold.getInstanceAndShow()
		    -- dlg:setNeedNum(needNum)
            GetCTipsManager():AddMessageTipById(160118) --��Ҳ���
        end
	end
end

function CurrencyManager.isCppprotocol()
	if m.autoBuyArgs then
		m.autoBuyArgs.isCppProtocol = true
	end
end

function CurrencyManager.refreshWidgets(currencyType)
    if currencyType and currencyType == m.scheduleCurrencyType then
        CurrencyManager.stopScheduleAutoBuyRes()
    end

    local ignoreWidget = nil --�һ��Զ�����ʱǮ�����������ټ��٣�Ϊ�Ż����飬��������Զ�����Ͳ�ˢ�¸�widget

	if m.autoBuyArgs then
        --auto buy goods
	    if m.autoBuyArgs.currencyType == currencyType and
		   m.autoBuyArgs.price <= m.getOwnCurrencyMount(currencyType)
	      then
            ignoreWidget = m.autoBuyArgs.widget

            if m.autoBuyArgs.isCppProtocol then
                gGetNetConnection():send(m.autoBuyArgs.protocol)
            else
                LuaProtocolManager:send(m.autoBuyArgs.protocol)
            end
		    CurrencyManager.setAutoBuyArgs(nil)

            local widgets = m.registerWidgets[currencyType]
	        if widgets and #widgets > 0 then
		        m.scheduleForAutoBuyRes = true
                m.scheduleCurrencyType = currencyType
                m.elapsed = 0
	        end
	    end
	end
	
    --refresh texts
	local widgets = m.registerWidgets[currencyType]
	if not widgets then
		return
	end
	local num = m.getOwnCurrencyMount(currencyType)
	for _,v in pairs(widgets) do
        if v ~= ignoreWidget then
		    v:setText(MoneyFormat(num))
		
		    if m.compareWidgets[v] then
			    local compareWidget = m.compareWidgets[v]
			    if num < MoneyNumber(compareWidget:getText()) then
				    compareWidget:setProperty("BorderEnable", "True")
			    else
				    compareWidget:setProperty("BorderEnable", "True")
			    end
		    end
        end
	end
end

----------------------------------------------------------------
--autoBuyArgs~=nilʱ����ã���ֹ����ʧ�ܺ�Ǯ����ˢ��
function  CurrencyManager.tick(delta)
    m.elapsed = m.elapsed + delta
    if m.elapsed > 1000 then
        CurrencyManager.stopScheduleAutoBuyRes()
    end
end

function CurrencyManager.stopScheduleAutoBuyRes()
    m.scheduleForAutoBuyRes = false
    m.elapsed = 0
    local tmp = m.scheduleCurrencyType
    m.scheduleCurrencyType = nil
    m.refreshWidgets(tmp)
end

--�������仯
function CurrencyManager.onPackMoneyChanged()
	m.refreshWidgets(fire.pb.game.MoneyType.MoneyType_SilverCoin)
end

--��ʯ���仯
function CurrencyManager.onStoneChanged()
	m.refreshWidgets(fire.pb.game.MoneyType.MoneyType_HearthStone)
end

--������仯 new add
function CurrencyManager.onPackGoldChanged()
	m.refreshWidgets(fire.pb.game.MoneyType.MoneyType_GoldCoin)
end

--fire.pb.game.MoneyType�е���������
function CurrencyManager.onOtherMoneyChange(moneyType)
    m.refreshWidgets(moneyType)
end
