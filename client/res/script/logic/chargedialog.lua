require "logic.dialog"
require "logic.chargecell"
require "logic.addcashchargereturncell"

require "utils.mhsdutils"
require "manager.beanconfigmanager"
require "protodef.fire.pb.fushi.creqserverid"
require "protodef.fire.pb.fushi.creqcharge"

ChargeDialog = {}
setmetatable(ChargeDialog, Dialog)
ChargeDialog.__index = ChargeDialog 
ChargeDialog.m_ChargeState = 1
ChargeDialog.m_ChargeFlag = 0

s_flagYHReqServiceID = 1

local _instance;
function ChargeDialog.GeneralReqCharge()
	local reqAction = CReqCharge.Create()
	LuaProtocolManager.getInstance():send(reqAction)
end

function ChargeDialog.getInstance()
	LogInfo("ChargeDialog getinstance")
    if not _instance then
        _instance = ChargeDialog:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function ChargeDialog.getInstanceAndShow()
	print("enter instance show")
    if not _instance then
        _instance = ChargeDialog:new()
        _instance:OnCreate()
	else
		print("set visible")
		_instance:SetVisible(true)
    end
    _instance:refreshDingyueBtn()
    return _instance
end

function ChargeDialog.getInstanceNotCreate()
    return _instance
end

function ChargeDialog.getInstanceNotCreateRefresh(id)
    if not _instance then
        return nil
    end
    _instance.payGoodsId = id
    _instance:refreshGoods(id)
    return _instance
end
function ChargeDialog.DestroyDialog()
	
	if _instance then
		if not _instance.m_bCloseIsHide then
			
			_instance:ResetAllProducts();
			
			_instance:ResetAllChargeReturn();
				
			if _instance.m_scriptNumber then
				gGetDataManager().m_EventYuanBaoNumberChange:RemoveScriptFunctor(_instance.m_scriptNumber)
			end
				
			_instance:OnClose()
			_instance = nil
				
		else
			_instance:ToggleOpenClose()		
		end
		
	end	
	
end

function ChargeDialog:getPayItem()

    local eHttpShareUrl = GetServerInfo():getHttpAdressByEnum(eHttpShareUrl)
    local action = eHttpShareUrl.."/api/pay/getpayitem"
    local param = {}
    param["account"] = gGetLoginManager():GetAccount()
    param["roleid"] = gGetDataManager():GetMainCharacterID()
	param["serverid"] = tostring(gGetLoginManager():getServerID())

    local actionname = "getPayItem"
    CTipsManager:ServerPost(action,param,actionname)
end
function ChargeDialog:CreateCell(param)
    if not _instance then
        return
    end

    _instance:ResetAllProducts()

    local i = 0
    local count = 0
    local firstId = 0
    _instance.param = param or {}
    _instance.paramById = {}
    _instance.m_cells = {}
    for _, v in pairs(_instance.param) do
        _instance.paramById[v.id] = v

        _instance.m_cells[v.id] = ChargeCell.CreateNewDlg(_instance.chargeScroll, v)
        if _instance.m_cells[v.id] then
            _instance.m_cells[v.id]:Init(v.id, v.price, v.price, v.price, v.price, v.price)
            _instance.m_cells[v.id]:GetWindow():setPosition(
            CEGUI.UVector2(CEGUI.UDim(0 ,math.fmod(i, 3) * (_instance.m_cells[v.id]:GetWindow():getPixelSize().width + 5)),
            CEGUI.UDim(0,math.floor((i)/3)*(_instance.m_cells[v.id]:GetWindow():getPixelSize().height + 5))))
            count = count + 1
            if firstId == 0 then
                firstId = v.id
            end
        end
        i = i + 1
    end

    _instance.m_httpReady = count > 0
    if firstId ~= 0 then
        _instance.payGoodsId = firstId
        _instance:refreshGoods(firstId)
    end
end
function ChargeDialog.ToggleOpenClose()
	if not _instance then
		_instance = ChargeDialog:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function ChargeDialog.IsShow()
    if _instance and _instance:IsVisible() then
        return true
    else
        return false
    end
end

----/////////////////////////////////////////------

function ChargeDialog.GetLayoutFileName()
    return "addcashdlg.layout"
end

function ChargeDialog:handleOnShown(args)
    if self:GetWindow() and self:GetWindow():isVisible() then
        self:refreshDingyueBtn()
    end
end

function ChargeDialog:split(str, dilimiter)
    -- 声明准备要分割的子字符串的前后索引, 以及保存分割后的子字符串的 table
    local frontIndex, backIndex, myTable = 0, 0, {}
    while true do
        -- 找到下一个要分割的字符串的索引位置
        backIndex = string.find(str, dilimiter, frontIndex + 1)
        -- 当查找到最后的时候 backIndex 将会是空的，就退出循环
        if backIndex ~= nil then
            table.insert(myTable, string.sub(str, frontIndex + 1, backIndex - 1))
        else
            table.insert(myTable, string.sub(str, frontIndex + 1))
            return myTable
        end
        -- 把后面找到的分隔符的索引位置交换给 frontIndex，用于继续往下查找
        frontIndex = backIndex
    end
end



function ChargeDialog:HandlealipayClicked()
	-- case eHttpShareUrl:
	-- case eHttpInfoUrl:
	-- case eHttpChatUrl:
	-- case eHttpCommunityUrl:
	-- case eHttpNoticeUrl:
	-- case eHttpConfigUrl:
	-- case eHttpServerInfoUrl:
	-- case eHttpHorseRunUrl:
	-- case eHttpJinglingUrl:
	-- case eHttpKongjianUrl:
    if self.payGoodsId == 0 then
        GetCTipsManager():AddMessageTipByMsg("请先选择购买项目")
        return true
    end
    local selected = (self.paramById and self.paramById[self.payGoodsId]) or (self.param and self.param[self.payGoodsId]) or (self.m_socketGoods and self.m_socketGoods[self.payGoodsId])
    if not selected then
        GetCTipsManager():AddMessageTipByMsg("商品数据异常，请重试")
        self:getPayItem()
        ChargeDialog.GeneralReqCharge()
        return true
    end
    local eHttpShareUrl = GetServerInfo():getHttpAdressByEnum(eHttpShareUrl)
    local action = eHttpShareUrl.."/api/pay/getpay"
    local param = {}
    param["account"] = gGetLoginManager():GetAccount()
    param["roleid"] = gGetDataManager():GetMainCharacterID()
	param["serverid"] = tostring(gGetLoginManager():getServerID())
    param["payid"] = selected.id
    param["paytype"] = 1
    

    local actionname = "getPayUrl"
    CTipsManager:ServerPost(action,param,actionname)
end
function ChargeDialog:HandlewxpayClicked()
	-- case eHttpShareUrl:
	-- case eHttpInfoUrl:
	-- case eHttpChatUrl:
	-- case eHttpCommunityUrl:
	-- case eHttpNoticeUrl:
	-- case eHttpConfigUrl:
	-- case eHttpServerInfoUrl:
	-- case eHttpHorseRunUrl:
	-- case eHttpJinglingUrl:
	-- case eHttpKongjianUrl:
    if self.payGoodsId == 0 then
        GetCTipsManager():AddMessageTipByMsg("请先选择购买项目")
        return true
    end
    local selected = (self.paramById and self.paramById[self.payGoodsId]) or (self.param and self.param[self.payGoodsId]) or (self.m_socketGoods and self.m_socketGoods[self.payGoodsId])
    if not selected then
        GetCTipsManager():AddMessageTipByMsg("商品数据异常，请重试")
        self:getPayItem()
        ChargeDialog.GeneralReqCharge()
        return true
    end
    local eHttpShareUrl = GetServerInfo():getHttpAdressByEnum(eHttpShareUrl)
    local action = eHttpShareUrl.."/api/pay/getpay"
    local param = {}
    param["account"] = gGetLoginManager():GetAccount()
    param["roleid"] = gGetDataManager():GetMainCharacterID()
	param["serverid"] = tostring(gGetLoginManager():getServerID())
    param["payid"] = selected.id
    param["paytype"] = 2
    local actionname = "getPayUrl"
    CTipsManager:ServerPost(action,param,actionname)
end


function ChargeDialog:refreshGoods(id)
    local goods = (self.paramById and self.paramById[id]) or (self.param and self.param[id]) or (self.m_socketGoods and self.m_socketGoods[id])
    if not goods then
        return
    end
    goods.info = goods.info or ""
    local daylimit = nil
    local rolelimit = nil
    self.goodsname:setText(goods.name)
    self.goodsprice:setText(goods.price.."元")
    if goods.daylimit == 0 then
        daylimit = "不限购"
    else
        daylimit = '每日可购买'..goods.daylimit..'次'
    end    
    self.daylimit:setText(daylimit)

    if goods.rolelimit == 0 then
        rolelimit = "不限购"
    else
        rolelimit = '每个角色限购'..goods.rolelimit..'次'
    end    
    self.rolelimit:setText(rolelimit)


            
    local red = CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("FF8E8DDF"))
    local black = CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("FF000000"))
    self.richBox:Clear()


    local lineconet = 0
    for k, v in pairs(self:split(goods.info, "#")) do
        self.richBox:AppendText(CEGUI.String("　　"..v), red)
        self.richBox:AppendBreak()
        self.richBox:AppendText(CEGUI.String("　"), black)
        self.richBox:AppendBreak()
        lineconet = k
    end
    self.richBox:Refresh()

    local size = self.richBox:getPixelSize()
    local w = size.width
    local h =  lineconet * 50
    self.richBox:setSize(CEGUI.UVector2(CEGUI.UDim(0.0, w), CEGUI.UDim(0.0, h)))
end

function ChargeDialog:GetChargeRecord(goodid)
    local tableName = "fushi.caddcashlua"
    local tableData = BeanConfigManager.getInstance():GetTableByName(tableName)
    if not tableData then
        return nil
    end
    return tableData:getRecorder(goodid)
end

function ChargeDialog:BuildGoodsParam(goodid, price, yuanbao, present, beishu)
    local record = self:GetChargeRecord(goodid)
    local goods = {}
    goods.id = goodid
    goods.icon = record and record.itemicon or "set:jiangli image:1"
    goods.name = record and record.foodname or (tostring(yuanbao) .. "符石")
    goods.price = price
    goods.daylimit = 0
    goods.rolelimit = 0
    goods.info = ""
    goods.present = present or 0
    goods.beishu = beishu or 0
    return goods
end



function ChargeDialog:OnCreate()
	LogInfo("enter ChargeDialog oncreate")
    Dialog.OnCreate(self)
	SetPositionOfWindowWithLabel1(self:GetWindow())

    self:GetWindow():subscribeEvent("Shown", ChargeDialog.handleOnShown, self)
	
	self:GetCloseBtn():removeEvent("Clicked")
	self:GetCloseBtn():subscribeEvent("Clicked", ShopLabel.DestroyDialog, nil)

    local winMgr = CEGUI.WindowManager:getSingleton()

    self.leftDayText = winMgr:getWindow("addcash/diankatianshu")
    self.leftDayTime = winMgr:getWindow("addcash/shengyushijian")
    self.leftDayText:setVisible(false)
    self.leftDayTime:setVisible(false)

    self.m_btnServersec = CEGUI.toPushButton(winMgr:getWindow("addcash/shuoming"))
    self.m_btnServersec:subscribeEvent("MouseClick", ChargeDialog.HandleServerSecClick, self)
    local manager = require "logic.pointcardserver.pointcardservermanager".getInstanceNotCreate()
    if manager then
        if manager.m_isPointCardServer then
            self.m_btnServersec:setVisible(true)
        else
            self.m_btnServersec:setVisible(false)
        end
    end

    
    self.daycharge = CEGUI.toPushButton(winMgr:getWindow("addcash/daycharge"))
	self.daycharge:setID(1)
    self.daycharge:subscribeEvent("Clicked", ChargeDialog.HandleTabChangeClick, self)
    self.rolecharge = CEGUI.toPushButton(winMgr:getWindow("addcash/rolecharge"))
	self.rolecharge:setID(2)
    self.rolecharge:subscribeEvent("Clicked", ChargeDialog.HandleTabChangeClick, self)
	
	self.m_Yuanbao = {}
	self.m_Yuanbao["num"] = winMgr:getWindow("addcash/di/1/yuanbaonum") --符石数量 by changhao
	self.m_Yuanbao["parent"] = winMgr:getWindow("addcash/di") --符石数量 by changhao	




	self.chargeScroll = CEGUI.Window.toScrollablePane(winMgr:getWindow("addcash/chongzhidi/scrollchargenew"))
	self.m_cells = {}
    --local tableAllId = BeanConfigManager.getInstance():GetTableByName("SysConfig.Cchongzhiyemianpeizhi"):getAllID()
    -- for _, v in pairs(tableAllId) do
    --     local goods = BeanConfigManager.getInstance():GetTableByName("SysConfig.Cchongzhiyemianpeizhi"):getRecorder(v)
        
		

    --     self.m_cells[goods.id] = ChargeCell.CreateNewDlg(self.chargeScroll, goods.id)
    --     if self.m_cells[goods.id] then
    --         --self.m_cells[id]:Init(goods.id, price, yuanbao, present, beishu, yuanbao_max)
    --         self.m_cells[goods.id]:Init(goods.id, goods.price, goods.price, goods.price, goods.price, goods.price)
    --         self.m_cells[goods.id]:GetWindow():setPosition(
    --         CEGUI.UVector2(CEGUI.UDim(0 ,math.fmod(goods.id-1, 3) * (self.m_cells[goods.id]:GetWindow():getPixelSize().width + 5)),
    --         CEGUI.UDim(0,math.floor((goods.id-1)/3)*(self.m_cells[goods.id]:GetWindow():getPixelSize().height + 5)))) 
    --     end
       

    -- end
    self.richBox = CEGUI.toRichEditbox(winMgr:getWindow("addcash/jieshao/info"))
    self.goodsname = CEGUI.toRichEditbox(winMgr:getWindow("addcash/shangpinmingcheng/name"))
    self.goodsprice = CEGUI.toRichEditbox(winMgr:getWindow("addcash/shangpinjiage/price"))
    self.daylimit = CEGUI.toRichEditbox(winMgr:getWindow("addcash/meirixiangou/limit"))
    self.rolelimit = CEGUI.toRichEditbox(winMgr:getWindow("addcash/juesexiangou/limit"))
    
    self.param = {}
    self.paramById = {}
    self.m_httpReady = false
    self.m_socketGoods = {}
    self.m_goodsParamByIndex = {}
    self.payGoodsId = 0
    --self:refreshGoods(1)

    self.alipay = CEGUI.Window.toPushButton(winMgr:getWindow("addcash/alipay"))
    self.alipay:subscribeEvent("Clicked", ChargeDialog.HandlealipayClicked, self)
    self.wxpay = CEGUI.Window.toPushButton(winMgr:getWindow("addcash/wxpay"))
    self.wxpay:subscribeEvent("Clicked", ChargeDialog.HandlewxpayClicked, self)


	-- self.m_Back = {}
    -- self.m_Back["charge"] = {}
	-- self.m_Back["charge"]["back"] = CEGUI.Window.toScrollablePane(winMgr:getWindow("addcash/chongzhidi"))
	-- self.m_Back["charge"]["scroll"] = CEGUI.Window.toScrollablePane(winMgr:getWindow("addcash/chongzhidi/scrollcharge"))
	-- self.m_Back["charge"]["scroll"]:setVisible(false)
	

	-- self.m_Back["charge"]["back"]:setVisible(true)

	self:UpdateStatus();
	
	self.m_lastTime = 0;
	self.m_totalTime = 0;
	self.m_textCounter = 0;
	
    self.m_scriptNumber = gGetDataManager().m_EventYuanBaoNumberChange:InsertScriptFunctor(ChargeDialog.YuanbaoChanged)
	
    self:getPayItem() -- HTTP 商品详情源
	ChargeDialog.GeneralReqCharge(); -- Socket 商品状态/兜底源 by changhao
    --[[
    local datamanager = require "logic.chargedatamanager"
    if datamanager then
        local redpoint =  datamanager.GetRedPointStatus()
            if self.m_ReturnRedPoint then
            self.m_ReturnRedPoint:setVisible(redpoint)
        end
    end
    --]]
end
function ChargeDialog:HandleServerSecClick(e)
    require"logic.pointcardserver.pointmsgaddcashdlg".getInstanceAndShow()
end
function ChargeDialog:UpdateGood(id, goodid, price, yuanbao, present, beishu, yuanbao_max)

	self.m_cell = self.m_cell or {}
    self.param = self.param or {}
    self.paramById = self.paramById or {}
    self.m_socketGoods = self.m_socketGoods or {}
    self.m_goodsParamByIndex = self.m_goodsParamByIndex or {}
    local goodsParam = self:BuildGoodsParam(goodid, price, yuanbao, present, beishu)
    self.m_socketGoods[goodid] = goodsParam
    self.m_goodsParamByIndex[id] = goodsParam

    if self.m_httpReady and next(self.paramById) ~= nil then
        return
    end
    self.param[goodid] = goodsParam
    self.paramById[goodid] = goodsParam
	
	if self.m_cell[id] == nil then

		self:AddGood(id, goodid, price, yuanbao, present, beishu, yuanbao_max);
		
	else
	
		self.m_cell[id]:Init(goodid, price, yuanbao, present, beishu, yuanbao_max);
		
	end

    if self.payGoodsId == 0 then
        self.payGoodsId = goodid
        self:refreshGoods(goodid)
    end
	
end

function ChargeDialog:AddGood(id, goodid, price, yuanbao, present, beishu, yuanbao_max)
    local goodsParam = nil
    if self.m_goodsParamByIndex then
        goodsParam = self.m_goodsParamByIndex[id]
    end
    if not goodsParam then
        goodsParam = self:BuildGoodsParam(goodid, price, yuanbao, present, beishu)
    end

	self.m_cell[id] = ChargeCell.CreateNewDlg(self.chargeScroll, goodsParam)
    if self.m_cell[id] then
	    self.m_cell[id]:Init(goodid, price, yuanbao, present, beishu, yuanbao_max)
	    self.m_cell[id]:GetWindow():setPosition(
        CEGUI.UVector2(CEGUI.UDim(0 ,math.fmod(id-1, 3) * (self.m_cell[id]:GetWindow():getPixelSize().width + 5)),
        CEGUI.UDim(0,math.floor((id-1)/3)*(self.m_cell[id]:GetWindow():getPixelSize().height + 5)))) 
    end
end

function ChargeDialog:refreshProductPos()
    local cells = self.m_cell or self.m_cells
    if not cells then 
        return
    end
    local pcManager = require "logic.pointcardserver.pointcardservermanager".getInstance()
    if pcManager.bDingyueOpen==false then

        for nId,cellDlg in pairs(cells) do
            if nId==1 then
                cellDlg:SetVisible(false)
            end
            local nPosX = (nId-2)%3 * (cellDlg:GetWindow():getPixelSize().width + 5)
            local nPosY = math.floor((nId-2)/3)*(cellDlg:GetWindow():getPixelSize().height + 5)
            if cellDlg:GetWindow() then
                cellDlg:GetWindow():setPosition(CEGUI.UVector2(CEGUI.UDim(0 , nPosX),CEGUI.UDim(0, nPosY))) 
            end
        end

    else
        for nId,cellDlg in pairs(cells) do
            if nId==1 then
                cellDlg:SetVisible(true)
            end
            local nPosX = (nId-1)%3 * (cellDlg:GetWindow():getPixelSize().width + 5)
            local nPosY = math.floor((nId-1)/3)*(cellDlg:GetWindow():getPixelSize().height + 5)
            if cellDlg:GetWindow() then
                cellDlg:GetWindow():setPosition(CEGUI.UVector2(CEGUI.UDim(0 , nPosX),CEGUI.UDim(0, nPosY))) 
            end
        end

    end

end

function ChargeDialog:refreshDingYueLeftTime()
    local pcManager = require "logic.pointcardserver.pointcardservermanager".getInstance()
    local curTime = gGetServerTime()
    if not IsPointCardServer() or not pcManager.nnDingyueOverTime or pcManager.nnDingyueOverTime == 0 or pcManager.nnDingyueOverTime <= curTime then
        self.leftDayText:setVisible(false)
        self.leftDayTime:setVisible(false)
        return
    end

    self.leftDayText:setVisible(true)
    self.leftDayTime:setVisible(true)
    local leftTime = math.floor((pcManager.nnDingyueOverTime - curTime)*0.001) --秒数
    local hour = math.floor(leftTime / (60*60))
    local day = math.floor(hour / 24)
    hour = hour % 24
    if day > 0 then
        local min = math.floor((leftTime % 3600) / 60)
        if min > 0 then
            hour = hour+1
            if hour == 24 then
                day = day + 1
                hour = 0
            end
        end
    end

    if day > 0 and hour == 0 then
        self.leftDayTime:setText(tostring(day) .. MHSD_UTILS.get_resstring(317))
    elseif day == 0 and hour >= 0 then
        local min = math.floor((leftTime % 3600) / 60)
        if hour == 0 and min >= 0 then
            min = math.max(min, 1)
            self.leftDayTime:setText(tostring(min) .. MHSD_UTILS.get_resstring(71)) --分
        elseif hour > 0 and min == 0 then            
            self.leftDayTime:setText(tostring(hour) .. MHSD_UTILS.get_resstring(318))
        elseif hour > 0 and min > 0 then
            self.leftDayTime:setText(string.format("%d%s%d%s", hour, MHSD_UTILS.get_resstring(318), min, MHSD_UTILS.get_resstring(71)))
        end
    else
        self.leftDayTime:setText(string.format("%d%s%d%s", day, MHSD_UTILS.get_resstring(317), hour, MHSD_UTILS.get_resstring(318)))
    end
end

function  ChargeDialog:refreshDingyueBtn()
    if not IsPointCardServer() then
        return
    end
    self:refreshProductPos()

    local pcManager = require "logic.pointcardserver.pointcardservermanager".getInstance()
    if pcManager.bDingyueOpen==false then
        self.leftDayText:setVisible(false)
        self.leftDayTime:setVisible(false)
        return
    end

    local cells = self.m_cell or self.m_cells
    if not cells then
        return
    end
    local cellBtn = cells[1]
    if not cellBtn then
         return
    end
    if not cellBtn.imageGray then
        return
    end

    local curTime = gGetServerTime()
    if pcManager.nnDingyueOverTime==0 or pcManager.nnDingyueOverTime <= curTime then
         cellBtn.imageGray:setVisible(false)
    else
         cellBtn.imageGray:setVisible(true)
    end
  
    self:refreshDingYueLeftTime()
end

function ChargeDialog:ResetAllProducts()
	if self.m_cell then
		for k,v in pairs(self.m_cell) do
			v:OnClose()
			v = nil
		end
		self.m_cell = nil
    end
    if self.m_cells then
        for k,v in pairs(self.m_cells) do
            v:OnClose()
            v = nil
        end
        self.m_cells = nil
    end
    self.m_goodsParamByIndex = {}
end

--加一个充值返利单元 by changhao
function ChargeDialog:UpdateChargeReturn(id, curprogress, maxprogress, status, text)
	

end

function ChargeDialog:ResetAllChargeReturn()
	
	if not self.m_chargereturncell then return end

	for k,v in pairs(self.m_chargereturncell) do
		v:OnClose()
		v = nil
	end
	self.m_chargereturncell = nil
	
end

function ChargeDialog:GetStatus(state)
	local statustable = {}
	statustable[0] = MHSD_UTILS.get_resstring(2760)
	statustable[1] = MHSD_UTILS.get_resstring(2762)
	statustable[2] = MHSD_UTILS.get_resstring(2761)
	return statustable[state]
end

------------------- private: -----------------------------------

function ChargeDialog:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, ChargeDialog)

    return self
end


function ChargeDialog:HandleTabChangeClick(args)
	local winargs = CEGUI.toWindowEventArgs(args)
	local btn = winargs.window
	local btnID = btn:getID()
    if btnID == 1 then
        DayChargeDialog.getInstanceAndShow()
    else
        RoleChargeDialog.getInstanceAndShow()
    end
end

function ChargeDialog:UpdateChargeReturnCellStatus(id, status) --更新一下某个充值返利单元状态 by changhao
	
	self.m_chargereturncell[id]:UpdateStatus(status);
	
end

function ChargeDialog:UpdateStatus()
	
	local yuanbaonum = gGetDataManager():GetYuanBaoNumber()
	
	local final = "0";
	
    local cash =  MoneyFormat(yuanbaonum)
	self.m_Yuanbao["num"]:setText(cash);
		
end

--更新符石  by changhao
function ChargeDialog.YuanbaoChanged()
	
    if _instance ~= nil then
		
        _instance:UpdateStatus();
	
    end

end

function ChargeDialog.onInternetReconnected()
	if _instance then
        _instance:getPayItem()
        _instance.GeneralReqCharge()
	end
end

function ChargeDialog:setTeQuanText(text, numWnd,textWnd)
    if #text>0 then
        numWnd:setVisible(true)
        textWnd:setVisible(true)
        textWnd:setText(text)
    else
        numWnd:setVisible(false)
        textWnd:setVisible(false)
    end
end

-- 设置VIP的信息
-- 参数1 要查看的VIP等级
function ChargeDialog:SetVipInfo(vipLevel,goVipLevel,vipExp)
	
    self.m_VipLevel = vipLevel
    self.m_GoVipLevel = goVipLevel
    self.m_VipExp = vipExp

    local winMgr = CEGUI.WindowManager:getSingleton()
    local leftVipIconWnd = winMgr:getWindow("Charge/VIPBG/leftVipIcon")
	local progressWnd = CEGUI.toProgressBar(winMgr:getWindow("Charge/VIPBG/Progress"))
	--local rightVipIconWnd = winMgr:getWindow("Charge/VIPBG/rightVipIcon")
    local fuShiTypeWnd = winMgr:getWindow("Charge/VIPBG/typeText")
	local fuShiTextWnd = winMgr:getWindow("Charge/VIPBG/typeText2")
    local fuShiMaxWnd = winMgr:getWindow("Charge/VIPBG/typeText3")
	--local fuShiIconWnd = winMgr:getWindow("Charge/VIPBG/fushiicon")
    local tequanTypeWnd = winMgr:getWindow("Charge/VIPBG/jianglibg/typeText1")
    local tequan1TextNum = winMgr:getWindow("Charge/VIPBG/jianglibg/tequan1")
	local tequan1TextWnd = winMgr:getWindow("Charge/VIPBG/jianglibg/typeText2")
    local tequan2TextNum = winMgr:getWindow("Charge/VIPBG/jianglibg/tequan2")
	local tequan2TextWnd = winMgr:getWindow("Charge/VIPBG/jianglibg/typeText3")
    local tequan3TextNum = winMgr:getWindow("Charge/VIPBG/jianglibg/tequan21")
    local tequan3TextWnd = winMgr:getWindow("Charge/VIPBG/jianglibg/typeText31")
	local prevPageBtn = winMgr:getWindow("Charge/VIPBG/prevPageBtn")
	local nextPageBtn = winMgr:getWindow("Charge/VIPBG/nextPageBtn")
    local ChongZhiLeiJi = winMgr:getWindow("Charge/VIPBG/bg/viplv/yichongzhi")
	local LeiJiShuLiang = winMgr:getWindow("Charge/VIPBG/bg/viplv/chongzhimoney")

    local table =  BeanConfigManager.getInstance():GetTableByName("fushi.cvipinfo")
    
    print("vipLevel=====>%s",self.m_VipLevel)
    if self.m_VipLevel == VipDialog.m_MaxVipLevel then
        local record = table:getRecorder(self.m_VipLevel)
        --local leftVipIcon = "set:vip image:VIP" .. (self.m_VipLevel)

        
        --leftVipIconWnd:setProperty("Image",leftVipIcon)


        --:setVisible(false)
        progressWnd:setVisible(false)
        fuShiTextWnd:setVisible(false)
        if vipExp < record.exp then
            fuShiTextWnd:setText(record.exp - vipExp.."元")
            fuShiTypeWnd:setVisible(true)
            fuShiTextWnd:setVisible(true)
            fuShiMaxWnd:setVisible(false)
            local width = fuShiTextWnd:getProperty("HorzExtent") + 50
            local newPosX = fuShiTextWnd:getXPosition()
            -- fuShiIconWnd:setXPosition(CEGUI.UDim(0,newPosX.offset + width))
            -- fuShiIconWnd:setVisible(true)
        else
            fuShiTypeWnd:setVisible(false)
            fuShiTextWnd:setVisible(false)
            --fuShiIconWnd:setVisible(false)
            fuShiMaxWnd:setVisible(true)
        end
        prevPageBtn:setVisible(true)
        nextPageBtn:setVisible(false)

		--设置到达11级后，显示已经充实的rmb
		ChongZhiLeiJi:setVisible(true)
		LeiJiShuLiang:setVisible(true)

		LeiJiShuLiang:setText(vipExp.."元")

        
	    local strbuilder = StringBuilder:new()
	    strbuilder:Set("parameter1", self.m_VipLevel)
        local msg=strbuilder:GetString(MHSD_UTILS.get_msgtipstring(190022))
        strbuilder:delete()

        tequanTypeWnd:setText(msg)
        self:setTeQuanText(record.type1,tequan1TextNum,tequan1TextWnd)
        self:setTeQuanText(record.type2,tequan2TextNum,tequan2TextWnd)
        self:setTeQuanText(record.type3,tequan3TextNum,tequan3TextWnd)

        -- 设置道具
        for i=1,5 do
            local itemWnd = CEGUI.toItemCell(winMgr:getWindow("Charge/VIPBG/jianglibg/item"..i))
            itemWnd:setVisible(false)
        end
        local items = record.itemids
        local itemscount = record.itemcounts
        for i=0,items:size()-1 do
            local itemWnd = CEGUI.toItemCell(winMgr:getWindow("Charge/VIPBG/jianglibg/item"..i + 1))
            local itemId = items[i]
		    local item = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(itemId);
            local itemIcon = gGetIconManager():GetItemIconByID(item.icon)
            if itemscount[i] ~= 0 then
                itemWnd:setVisible(true)
                itemWnd:setID(itemId)
                itemWnd:SetImage(itemIcon)
                itemWnd:SetTextUnit(itemscount[i])
                SetItemCellBoundColorByQulityItemWithId(itemWnd,items[i])
            end
        end
    else
        local record = table:getRecorder(self.m_VipLevel )
		--设置会员等级显示
        local nextRecord = table:getRecorder(self.m_VipLevel + 1 )
        --local leftVipIcon = "set:vip image:VIP" .. (self.m_VipLevel)
        --leftVipIconWnd:setProperty("Image",leftVipIcon)


        leftVipIconWnd:setProperty("Text","累充档次"..(self.m_VipLevel))
        --local rightVipIcon = "set:vip image:VIP" .. (self.m_VipLevel + 1)
        --rightVipIconWnd:setProperty("Image",rightVipIcon)
        --rightVipIconWnd:setProperty("Text","VIP"..(self.m_VipLevel + 1))
        leftVipIconWnd:setVisible(true)


        --rightVipIconWnd:setVisible(true)
        if vipExp > nextRecord.exp then
            progressWnd:setText(nextRecord.exp.."/"..nextRecord.exp)
            progressWnd:setProgress(1.0)
        else
            progressWnd:setText(vipExp.."/"..nextRecord.exp)
            --progressWnd:setProgress((vipExp-record.exp)/(nextRecord.exp-record.exp))
			progressWnd:setProgress(vipExp/nextRecord.exp)
        end
        if vipExp < nextRecord.exp then
            fuShiTextWnd:setText(nextRecord.exp - vipExp.."元")
        else
            fuShiTextWnd:setText("0".."元")
        end
        progressWnd:setVisible(true)
        fuShiTextWnd:setVisible(true)
        prevPageBtn:setVisible(self.m_VipLevel > 0)
        nextPageBtn:setVisible(true)
        fuShiTextWnd:setVisible(true)
        fuShiTypeWnd:setVisible(true)
        --fuShiIconWnd:setVisible(true)
        fuShiMaxWnd:setVisible(false)
        local width = fuShiTextWnd:getProperty("HorzExtent") + 50
        local newPosX = fuShiTextWnd:getXPosition()
        --fuShiIconWnd:setXPosition(CEGUI.UDim(0,newPosX.offset + width))
        --fuShiIconWnd:setVisible(true)
		ChongZhiLeiJi:setVisible(false)
		LeiJiShuLiang:setVisible(false)

        self:setTeQuanText(record.type1,tequan1TextNum,tequan1TextWnd)
        self:setTeQuanText(record.type2,tequan2TextNum,tequan2TextWnd)
        self:setTeQuanText(record.type3,tequan3TextNum,tequan3TextWnd)

	    local strbuilder = StringBuilder:new()
	    strbuilder:Set("parameter1", self.m_VipLevel)
        local msg=strbuilder:GetString(MHSD_UTILS.get_msgtipstring(190022))
        strbuilder:delete()

        tequanTypeWnd:setText(msg)

        -- 设置道具
        for i=1,5 do
            local itemWnd = CEGUI.toItemCell(winMgr:getWindow("Charge/VIPBG/jianglibg/item"..i))
            itemWnd:setVisible(false)
        end
        local items = record.itemids
        local itemscount = record.itemcounts
        for i=0,items:size()-1 do
            local itemWnd = CEGUI.toItemCell(winMgr:getWindow("Charge/VIPBG/jianglibg/item"..i + 1))
            local itemId = items[i]
		    local item = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(itemId);
            if item ~= nil then
                local itemIcon = gGetIconManager():GetItemIconByID(item.icon)
                if itemscount[i] ~= 0 then
                    itemWnd:setVisible(true)
                    itemWnd:setID(itemId)
                    itemWnd:SetImage(itemIcon)
                    itemWnd:SetTextUnit(itemscount[i])
                    SetItemCellBoundColorByQulityItemWithId(itemWnd,items[i])
                end
            else
                itemWnd:setVisible(false)
            end
        end
    end
    --[[
    self.m_IsMaxVipLevel = self.m_VipLevel == VipDialog.m_MaxVipLevel
    if self.m_IsMaxVipLevel then
        self.m_VipLevel = vipLevel - 1
    end

	-- 取当前数据
    local curRecord = table:getRecorder(self.m_VipLevel)
    local curRecordExp = 0
    if curRecord ~= nil then
        curRecordExp = curRecord.exp;
    end
    -- 取下一级数据
    local nextRecord = table:getRecorder(self.m_VipLevel + 1)
    if nextRecord == nil then
        return
    end

    -- 设置左VIP图标
    local iconName = "set:itemicon0 image:" .. (VipDialog.m_VipIconIndex + self.m_VipLevel)
    if self.m_IsMaxVipLevel then
        iconName = "set:itemicon0 image:" .. (VipDialog.m_VipIconIndex + VipDialog.m_MaxVipLevel)
    end
    leftVipIconWnd:setProperty("Image",iconName)
    -- 设置进度条
    if vipExp < nextRecord.exp and vipExp >= curRecordExp then
        progressWnd:setText(vipExp.."/"..nextRecord.exp)
        progressWnd:setProgress((vipExp-curRecordExp)/(nextRecord.exp-curRecordExp))
    elseif vipExp >= nextRecord.exp then
        progressWnd:setText(nextRecord.exp.."/"..nextRecord.exp)
        progressWnd:setProgress(1.0)
    else
        progressWnd:setText(vipExp.."/"..nextRecord.exp)
        progressWnd:setProgress(0.0)
    end
    -- 设置右VIP图标
    if not self.m_IsMaxVipLevel then
        local iconName = "set:itemicon0 image:" .. (VipDialog.m_VipIconIndex + self.m_VipLevel + 1)
        rightVipIconWnd:setProperty("Image",iconName)
        rightVipIconWnd:setVisible(true)
    else
        rightVipIconWnd:setVisible(false)
    end
    -- 设置还需要充值的数量
    if vipExp < nextRecord.exp then
        fuShiTextWnd:setText(nextRecord.exp-vipExp)
    else
        fuShiTextWnd:setText("0")
    end
    fuShiTextWnd:setVisible(not self.m_IsMaxVipLevel)
    fuShiTypeWnd:setVisible(not self.m_IsMaxVipLevel)
    fuShiMaxWnd:setVisible(self.m_IsMaxVipLevel)
    -- 设置符石图标的位置
    local width = fuShiTextWnd:getProperty("HorzExtent") + 20
    local newPosX = fuShiTextWnd:getXPosition()
    fuShiIconWnd:setXPosition(CEGUI.UDim(0,newPosX.offset + width))
    fuShiIconWnd:setVisible(not self.m_IsMaxVipLevel)
    -- 设置特权文本
    tequan1TextWnd:setText(nextRecord.type1)
    tequan2TextWnd:setText(nextRecord.type2)
    -- 设置左翻页
    prevPageBtn:setVisible(self.m_VipLevel>0) --禁止翻页.
    -- 设置右翻页
    nextPageBtn:setVisible(self.m_VipLevel<VipDialog.m_MaxVipLevel) --禁止翻页.
    -- 设置道具
    for i=1,5 do
        local itemWnd = CEGUI.toItemCell(winMgr:getWindow("Charge/VIPBG/jianglibg/item"..i))
        itemWnd:setVisible(false)
    end
    local items = nextRecord.itemids
    local itemscount = nextRecord.itemcounts
    for i=0,items:size()-1 do
        local itemWnd = CEGUI.toItemCell(winMgr:getWindow("Charge/VIPBG/jianglibg/item"..i + 1))
        local itemId = items[i]
		local item = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(itemId);
        local itemIcon = gGetIconManager():GetItemIconByID(item.icon)
        if itemscount[i] ~= 0 then
            itemWnd:setVisible(true)
            itemWnd:setID(itemId)
            itemWnd:SetImage(itemIcon)
            itemWnd:setText(itemscount[i])
            SetItemCellBoundColorByQulityItemWithId(itemWnd,items[i])
        end
    end
    --]]
    -- 收费按钮缴费
    local chargedBtn = CEGUI.toPushButton(winMgr:getWindow("Charge/VIPBG/ChongZhiBtn"))
    chargedBtn:setVisible(false)
    local lingquBtn = CEGUI.toPushButton(winMgr:getWindow("Charge/VIPBG/LingQuBtn"))
    lingquBtn:setVisible(false)

end

-- 切换到VIP对话框.
-- 参数1 当前的VIP等级
-- 参数2 已充符石数
-- 参数3 可领奖励
-- 参数4 已领奖励
function ChargeDialog:SwitchVipState()    
    local winMgr = CEGUI.WindowManager:getSingleton()
    local fushiWnd = winMgr:getWindow("addcash/main/panelchargereturn")
    fushiWnd:setVisible(false)

    if winMgr:isWindowPresent("Charge/VIPBG/ChongZhiBtn") then
        local chargedBtn = winMgr:getWindow("Charge/VIPBG/ChongZhiBtn")
        chargedBtn:setVisible(false)
    end

    if self.m_VipWnd == nil then
        self.m_VipWnd = winMgr:loadWindowLayout("vip.layout","Charge/")
        local fushiWndPos = fushiWnd:getPosition()
        local fushiWidth = fushiWnd:getPixelSize().width
        local fushiHeight = fushiWnd:getPixelSize().height
        local paterWnd = winMgr:getWindow("addcash")
        if paterWnd then
            paterWnd:addChildWindow(self.m_VipWnd)
        end
        if self.m_VipWnd then
            self.m_VipWnd:setPosition(fushiWndPos)
            self.m_VipWnd:setWidth(CEGUI.UDim(0,fushiWidth))
            self.m_VipWnd:setHeight(CEGUI.UDim(0,fushiHeight))
        end
        -- 安装左移事件
	    local prevPageBtn = CEGUI.toPushButton(winMgr:getWindow("Charge/VIPBG/prevPageBtn"))
        prevPageBtn:subscribeEvent("Clicked",ChargeDialog.HandlePrevVipPage,self)
        -- 安装右移事件
	    local nextPageBtn = CEGUI.toPushButton(winMgr:getWindow("Charge/VIPBG/nextPageBtn"))
        nextPageBtn:subscribeEvent("Clicked",ChargeDialog.HandleNextVipPage,self)
        --安装图标事件
        for i=1,5 do
            local itemWnd = CEGUI.toItemCell(winMgr:getWindow("Charge/VIPBG/jianglibg/item"..i))
            itemWnd:subscribeEvent("TableClick", GameItemTable.HandleShowToolTipsWithItemID)
        end
    end
    
end

function ChargeDialog:HandlePrevVipPage(args)
    if not self.m_VipLevel then
		return
	end
    self:SetVipInfo(self.m_VipLevel-1,self.m_GoVipLevel,self.m_VipExp)
end

function ChargeDialog:HandleNextVipPage(args)
	if not self.m_VipLevel then
		return
	end
    self:SetVipInfo(self.m_VipLevel+1,self.m_GoVipLevel,self.m_VipExp)
end


return ChargeDialog
