------------------------------------------------------------------
-- 祈愿商店
------------------------------------------------------------------

require "logic.dialog"
require "manager.currencymanager"



NpcQiYuanShop = {}
setmetatable(NpcQiYuanShop, Dialog)
NpcQiYuanShop.__index = NpcQiYuanShop

local _instance
function NpcQiYuanShop.getInstance()
	if not _instance then
		_instance = NpcQiYuanShop:new()
		_instance:OnCreate()
	end
	return _instance
end

function NpcQiYuanShop.getInstanceAndShow()
	if not _instance then
		_instance = NpcQiYuanShop:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function NpcQiYuanShop.getInstanceOrNot()
	return _instance
end

function NpcQiYuanShop.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function NpcQiYuanShop:OnClose()
	Dialog.OnClose(_instance)
	_instance = nil
end

function NpcQiYuanShop.ToggleOpenClose()
	if not _instance then
		_instance = NpcQiYuanShop:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function NpcQiYuanShop.GetLayoutFileName()

	return "NpcQiYuanShop.layout"
	--return "NpcQifuShop_mtg.layout"
end

function NpcQiYuanShop:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, NpcQiYuanShop)
	return self
end

function NpcQiYuanShop:OnCreate()
	Dialog.OnCreate(self)
	--SetPositionOfWindowWithLabel(self:GetWindow())
	local winMgr = CEGUI.WindowManager:getSingleton()
	
	self.ItemPool={}
	 local conf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cnpcsale")):getRecorder(17)



	 
	 for index =1 ,#conf.goodsids do
	 self.ItemPool[index]=conf.goodsids[index]
	 end
	--道具介绍
	self.ItemText = {
	"70级无级别•自选装备包。 少侠确定要兑换么？",   --变异大力金刚
	"80级无级别•自选装备包。 少侠确定要兑换么？",   --资质培养丹
	"锦衣兑换卡一个。 少侠确定要兑换么？",   --变异龙龟
	"火灵兽宠物，拥有特殊技能。 少侠确定要兑换么？",   --净瓶玉露
	"雷灵兽宠物，拥有特殊技能。 少侠确定要兑换么？",    --金柳露
	"水灵兽宠物，拥有特殊技能。 少侠确定要兑换么？",   --变异虎力大仙
	"土灵兽宠物，拥有特殊技能。 少侠确定要兑换么？",  --吉祥锦囊
	"变异虎力大仙宠物，拥有特殊技能。 少侠确定要兑换么？",   --变异苏摩罗
	"变异元宝大王宠物，拥有特殊技能。 少侠确定要兑换么？",   --千叶莲露
	"变异启明星宠物，拥有特殊技能。 少侠确定要兑换么？",   --变异嘲风
	"变异苏摩罗宠物，拥有特殊技能。 少侠确定要兑换么？",    --变异铜臂

	}
	
	
	--每个气泡商品变量数组初始化
	self.m_qipao = {}
	self.m_qipaoBg =  {}
	self.m_qipaoName =  {}
	self.m_qipaoCost = {}
    self.m_boxItem = {}
	self.m_sel = {}
	--每个气泡商品初始化
    for i = 1, 11 do
		self.m_qipao[i] = winMgr:getWindow("NpcQifuShop_mtg/qipao"..i) --气泡商品
		self.m_qipaoBg[i] = winMgr:getWindow("NpcQifuShop_mtg/qipao"..i.."/bg") --背景图
		self.m_qipaoName[i] = winMgr:getWindow("NpcQifuShop_mtg/qipao"..i.."/name")  --道具名字
		self.m_qipaoCost[i] = winMgr:getWindow("NpcQifuShop_mtg/qipao"..i.."/cost")  --价格
        self.m_boxItem[i] = CEGUI.Window.toItemCell(winMgr:getWindow("NpcQifuShop_mtg/qipao"..i.."/item"))  --道具格
		


		self.m_sel[i] = winMgr:getWindow("NpcQifuShop_mtg/qipao"..i.."/bg/sel")--选中框
		self.m_sel[i]:setVisible(false)
		
        self.m_qipaoBg[i]:subscribeEvent("MouseClick",NpcQiYuanShop.HandleItemClicked,self) --道具格详情响应事件
		self.m_qipaoBg[i]:setID(i)
		self:setQifuDataId(i, self.ItemPool[i])

    end
	
	--背景
	self.background = winMgr:getWindow("NpcQifuShop_mtg")
	self.background:subscribeEvent("MouseClick", NpcQiYuanShop.HandlClickBg, self) 


	--吉里兑换框
	self.duihuakuang = winMgr:getWindow("NpcQifuShop_mtg/text")
	--选中的商品名字
	self.SelItemName = winMgr:getWindow("NpcQifuShop_mtg/name")
	--选中的商品花费
	self.SelItemHuafei = winMgr:getWindow("NpcQifuShop_mtg/huafei")
	
	-- 拥有的蕴灵币初始化
	self.ownMoneyText = winMgr:getWindow("NpcQifuShop_mtg/yongyou")
	
	--拥有的蕴灵币刷新
	self:updateYlb()
	
	--加号 变量初始化
	self.jiahaoBtn = winMgr:getWindow("NpcQifuShop_mtg/jiahao")
	self.jiahaoBtn:subscribeEvent("Clicked", NpcQiYuanShop.handleAddClicked, self)

	--减号 变量初始化
	self.jianhaoBtn = winMgr:getWindow("NpcQifuShop_mtg/jianhao")
	self.jianhaoBtn:subscribeEvent("Clicked", NpcQiYuanShop.handleMinusClicked, self)

	--选购数量 变量初始化
	self.BuyNum = winMgr:getWindow("NpcQifuShop_mtg/Num")
	self.BuyNum:subscribeEvent("MouseClick", NpcQiYuanShop.handleBuyNumClicked, self)
	self.BuyNum:setText(1)

	--兑换按钮
	self.BuyBtn = winMgr:getWindow("NpcQifuShop_mtg/duihuan")
	self.BuyBtn:subscribeEvent("MouseClick", NpcQiYuanShop.handleBuyClicked, self)



	
	--蕴灵币 详情按钮
	self.ylbXq = winMgr:getWindow("NpcQifuShop_mtg/xianqing1")
	self.ylbXqBtn = CEGUI.toPushButton(winMgr:getWindow("NpcQifuShop_mtg/xianqing"))  --初始化详情按钮
	self.ylbXqBtn:subscribeEvent(CEGUI.PushButton.EventClicked, NpcQiYuanShop.handleylbXqBtnOnClicked, self)  --详情按钮响应事件

	
	--关闭按钮
	self.bcclose = winMgr:getWindow("NpcQifuShop_mtg/x")
	self.bcclose:subscribeEvent("Clicked", self.DestroyDialog, nil)
	
	self.curCurrencyType = 16 --货币类型 蕴灵币：16
	self.selectedGoodsId = 0 
	
	self:SelFirst(1) --默认选第一个




end

function NpcQiYuanShop:HandlClickBg() --点击背景的情况 --关闭提示
	self.ylbXq:setVisible(false)
end

function NpcQiYuanShop:updateYlb() --拥有的蕴灵币刷新 取变量的方式
		
	local MoneyText = RoleItemManager.getInstance():GetItemNumByBaseID(400752)

	-- local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	-- local MoneyText = roleItemManager:GetMoneyByMoneyType(16)
	self.ownMoneyText:setText(CurrencyManager.getOwnCurrencyMount(110))  --将金钱数值格式化为带有逗号分隔的字符串
	
    --self.ownMoneyText:setText(MoneyFormat(zhenHunShiCount))

end

-- function NpcQiYuanShop:handleBuyClicked() --兑换响应的事件
	-- local m_npcId = 83  --未知
	-- local m_id = 111232  --NPC服务总表ID

    -- if require "manager.npcservicemanager".DispatchHandler(m_npcId, m_id) == 0 then

        -- local req = require "protodef.fire.pb.npc.cnpcservice".Create()
        -- req.npckey = m_npcId
        -- req.serviceid = m_id
        -- LuaProtocolManager.getInstance():send(req)
        -- --NpcDialog.DestroyDialog()
    -- end

-- end

function NpcQiYuanShop:handleBuyClicked() --兑换响应的事件

	 if self.selectedGoodsId == 0 then
		GetCTipsManager():AddMessageTip("未选定商品")
		 return
	 end
	
	local SelGoodsId = self.ItemPool[self.selectedGoodsId]
	
	local conf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cgoods")):getRecorder(SelGoodsId)
	local num = tonumber(self.BuyNum:getText())
	if num == 0 then
		return
	end

	--检查购买等级
	if not CurrencyManager.checkRoleLevel(SelGoodsId, true) then
		GetCTipsManager():AddMessageTip("购买等级不足")
		return
	end
	


	--检查背包容量
	 if not CheckBagCapacityForItem(conf.itemId, num) then
		 GetCTipsManager():AddMessageTipById(160062) --背包空间不足
		 return
	 end
	 

	

	local p = require("protodef.fire.pb.shop.cbuynpcshop").Create()
	p.shopid = 17 --原血瓶商店的id
	p.goodsid = self.ItemPool[self.selectedGoodsId]
	
	
	p.num = num
	p.buytype = fire.pb.shop.ShopBuyType.NORMAL_SHOP 

	-- 从 self.priceText 中获取文本，并通过 MoneyNumber 函数转换为数值，存储在 price 变量中
	local price = MoneyNumber(self.SelItemHuafei:getText())  
	-- 计算所需货币金额，即 price 减去从 self.ownMoneyText 获取并转换后的数值，存储在 needMoney 变量中
	local needMoney = price - MoneyNumber(self.ownMoneyText:getText())  
	-- 如果所需货币金额大于 0
	if needMoney > 0 then  
		-- 处理货币不足的情况，调用 CurrencyManager 的 handleCurrencyNotEnough 方法
		-- 传递当前货币类型、所需金额、价格、未知参数 p 和自身货币文本
		CurrencyManager.handleCurrencyNotEnough(self.curCurrencyType, needMoney, price, p, self.ownMoneyText)  
		GetCTipsManager():AddMessageTip("蕴灵币不足")
		-- 函数在此处返回
		return  
	end
	
	LuaProtocolManager:send(p)
	
	--刷新拥有的蕴灵币--本地计算，直接取变量的话 数据有延迟
	
	--local MoneyText = RoleItemManager.getInstance():GetItemNumByBaseID(400752)
	local MoneyText2 = self.curGoodsPrice * num

	--self.ownMoneyText:setText(MHSD_UTILS.GetMoneyFormatString(MoneyText-MoneyText2))  --将金钱数值格式化为带有逗号分隔的字符串
	
	--GetCTipsManager():AddMessageTip("成功兑换".. num .."个" .. conf.name)

	--self.ownMoneyText:setText(CurrencyManager.getOwnCurrencyMount(8)-MoneyText2)
	
end


---超出价格 显示红色
function NpcQiYuanShop:handleBuycolour()
	local own_num = MoneyNumber(self.ownMoneyText:getText()) --拥有的资金
	local price_num = MoneyNumber(self.SelItemHuafei:getText())	--花费的价格
	
		
	if own_num < price_num then
		self.SelItemHuafei:setProperty("TextColours", "FFfc9b84")--红色
		self.SelItemHuafei:setProperty("BorderColour", "FFb81507")--红色
		
	else
		self.SelItemHuafei:setProperty("TextColours", "FFFFFFFF")--白色
		self.SelItemHuafei:setProperty("BorderColour", "FF935C27")--白色
	end

end


function NpcQiYuanShop:handleAddClicked() --加号响应的事件
	if self.selectedGoodsId == 0 then
		return
	end
	local num = tonumber(self.BuyNum:getText())
	if num < 99 then
		self.BuyNum:setText(num+1)
		self.SelItemHuafei:setText(MoneyFormat(self.curGoodsPrice * (num+1)))

	end
	self:handleBuycolour()
end
function NpcQiYuanShop:handleMinusClicked() --减号响应的事件
	if self.selectedGoodsId == 0 then
		return
	end
	local num = tonumber(self.BuyNum:getText())
	if num > 1 then
		self.BuyNum:setText(num-1)
		self.SelItemHuafei:setText(MoneyFormat(self.curGoodsPrice * (num-1)))

	end
	self:handleBuycolour()
end
function NpcQiYuanShop:handleBuyNumClicked() --选购数量响应的事件
	if self.selectedGoodsId == 0 or self.reachBuyNumLimit then

		return
	end
	if NumKeyboardDlg.getInstanceNotCreate() then
		NumKeyboardDlg.getInstanceNotCreate():SetVisible(true) --保持键盘在最上面
		
		return
	end
	
	local dlg = NumKeyboardDlg.getInstanceAndShow()
	if dlg then
		dlg:setTriggerBtn(self.BuyNum)
		dlg:setMaxValue(99)
		dlg:setInputChangeCallFunc(NpcQiYuanShop.onNumInputChanged, self)
		
		local p = self.BuyNum:GetScreenPos()
		SetPositionOffset(dlg:GetWindow(), p.x-110, p.y-10, 0, 1)
		
	end
	self:handleBuycolour()

end
function NpcQiYuanShop:onNumInputChanged(num)  --键盘输入后的事件
	if num == 0 then
		self.BuyNum:setText(1)
		self.SelItemHuafei:setText(MoneyFormat(self.curGoodsPrice))
	else
		self.BuyNum:setText(num)
		self.SelItemHuafei:setText(MoneyFormat(self.curGoodsPrice * num))
	end


	self:handleBuycolour()


end
function NpcQiYuanShop:SelFirst(idx) --选择商品项目

	
	local index = idx --1
	
	--GetCTipsManager():AddMessageTip(index)
	self.selectedGoodsId = index
	
	self.BuyNum:setText(1)
	
	--选中的商品名字，吉里说的话（商品简介）
	local text1 = tostring(self.ItemText[index])
	self.duihuakuang:setText(text1)
	
	--选中的商品名字变量赋值
	local L_SelItemName = self.m_qipaoName[index]:getText()
	self.SelItemName:setText(L_SelItemName)
	
	--选中的商品花费变量赋值
	local L_SelItemHuafei = self.m_qipaoCost[index]:getText()
	self.SelItemHuafei:setText(L_SelItemHuafei)
	
	
	self.curGoodsPrice = string.gsub(L_SelItemHuafei, ",", "")
	
	--选中的商品显示金色框
	for i = 1, 11 do
		self.m_sel[i]:setVisible(false)
    end
	self.m_sel[index]:setVisible(true)

	self:handleBuycolour()
end

function NpcQiYuanShop:setQifuDataId(idx ,goodsid) --设置祈福商品
	local conf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cgoods")):getRecorder(goodsid)  --cgoods
	if not conf then
		return
	end
	
	self.m_qipaoName[idx]:setText(GetGoodsNameByItemId(conf.type, conf.itemId, false))  --名字
	
	local qipaoCost = MHSD_UTILS.GetMoneyFormatString(conf.prices[0]) --将金钱数值格式化为带有逗号分隔的字符串
	self.m_qipaoCost[idx]:setText(qipaoCost) --价格
	
	if conf.type == 1 then --item道具类
		local item = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(conf.itemId)
		if not item then
			return
		end
        self.m_boxItem[idx]:SetStyle(CEGUI.ItemCellStyle_IconInside)
		self.m_boxItem[idx]:SetImage( gGetIconManager():GetImageByID(item.icon))
        --self.m_qipaoBg[idx]:setID(conf.itemId)

	elseif conf.type == 2 then --pet宠物类
		local petAttr = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(conf.itemId)
        if petAttr then
		    local shapeData = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(petAttr.modelid)
		    local image = gGetIconManager():GetImageByID(shapeData.littleheadID)
            self.m_boxItem[idx]:SetStyle(CEGUI.ItemCellStyle_IconExtend)
		    self.m_boxItem[idx]:SetImage(image)
			--self.m_qipaoBg[idx]:setID(conf.itemId)

        end
	end
		


end

function NpcQiYuanShop:handleylbXqBtnOnClicked()  --详情按钮响应事件

	if not self.ylbXq:isVisible() then
		self.ylbXq:setVisible(true)
	else
		self.ylbXq:setVisible(false)
	end
end

 function NpcQiYuanShop:HandleItemClicked(args) --道具格详情响应事件



	local e = CEGUI.toMouseEventArgs(args)
	local touchPos = e.position
	
	local index = e.window:getID()
	
	--GetCTipsManager():AddMessageTip(index)
	self.selectedGoodsId = index
	
	self.BuyNum:setText(1)
	
	--选中的商品名字，吉里说的话（商品简介）
	local text1 = tostring(self.ItemText[index])
	self.duihuakuang:setText(text1)
	
	--选中的商品名字变量赋值
	local L_SelItemName = self.m_qipaoName[index]:getText()
	self.SelItemName:setText(L_SelItemName)
	
	--选中的商品花费变量赋值
	local L_SelItemHuafei = self.m_qipaoCost[index]:getText()
	self.SelItemHuafei:setText(L_SelItemHuafei)
	
	
	self.curGoodsPrice = string.gsub(L_SelItemHuafei, ",", "")
	
	--选中的商品显示金色框
	for i = 1, 11 do
		self.m_sel[i]:setVisible(false)
    end
	self.m_sel[index]:setVisible(true)

	self:handleBuycolour()
 end
 
 

return NpcQiYuanShop