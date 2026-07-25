require "utils.commonutil"
require "logic.shop.commercedlg"
require "logic.shop.shopmanager"
require "logic.shop.mallshop"
require "logic.shop.stalldlg"
require "logic.shop.stallupshelf"
require "logic.shop.stallpetupshelf"
require "logic.shop.stallupokconfirm"
require "logic.shop.stalltradelogdlg"
require "logic.shop.scoreexchangeshop"
require "logic.shop.shoplabel"
require "logic.shop.commerceselldlg"

--从服务器获得限购或限售商品的已购买次数或已售卖次数
local p = require "protodef.fire.pb.shop.squerylimit"
function p:process()
	if self.querytype == 1 then  --已购买次数
		ShopManager.isBuyNumRecved = true
		for _,v in pairs(self.goodslimits) do
			ShopManager.goodsBuyNumLimit[v.goodsid] = v.number
		end

		--更新商会界面
		local dlg = CommerceDlg.getInstanceNotCreate()
		if dlg and dlg.tableview then
			dlg:recvBuyNumChanged(self.goodslimits)
		end

		--更新商城界面
		dlg = MallShop.getInstanceNotCreate()
		if dlg then
			if not dlg.goodsTable then
				dlg:loadGoodsByType(gCommon.curMallGoodsType)
			else
				dlg:recvBuyNumChanged(self.goodslimits)
			end

			dlg:refreshGoodsDetail()
		end

        dlg = ScoreExchangeShop.getInstanceNotCreate()
        if dlg then
            dlg:recvBuyNumChanged()
        end
		--更新ui界面
	    CommerceDlg.InitIfNeed()

	elseif self.querytype == 2 then  --已售卖次数
		ShopManager.isSellNumRecved = true
		for _,v in pairs(self.goodslimits) do
			ShopManager.goodsSellNumLimit[v.goodsid] = v.number
		end

        local dlg = CommerceSellDlg.getInstanceOrNot()
        if dlg then
            dlg:onSellNumLimitChanged()
        end
	end
end

--获取商品的现价
p = require "protodef.fire.pb.shop.sresponseshopprice"
function p:process()
	if self.shopid == SHOP_TYPE.COMMERCE then
		ShopManager.isPricesRecved = true
		ShopManager.queryPriceTimestamp = math.floor(gGetServerTime()*0.001)

		for _,v in pairs(self.goodslist) do
			ShopManager.goodsPrices[v.goodsid] = v.price
			ShopManager.goodsPreviousPrices[v.goodsid] = v.priorperiodprice
			--print('goods price', v.goodsid, v.price, v.priorperiodprice)
		end

		CommerceDlg.InitIfNeed()

		if require("logic.shop.quickbuydlg").getInstanceNotCreate() then
			require("logic.shop.quickbuydlg").getInstanceNotCreate():refreshPrice()
		end

		if require("logic.shop.commercequickselldlg").getInstanceNotCreate() then
			require("logic.shop.commercequickselldlg").getInstanceNotCreate():refreshPrice()
		end

        if require("logic.workshop.workshophcnew").getInstanceNotCreate() then
			require("logic.workshop.workshophcnew").getInstanceNotCreate():refreshShopGems()
		end
	end
end

--获取我的摊位物品
--actiontype: 1购买关注，2公示关注，3容器
p = require "protodef.fire.pb.shop.smarketcontainerbrowse"
function p:process()
    if self.actiontype ~= 3 then
        for _,v in pairs(self.goodslist) do
            ShopManager.attentionGoodsIds[v.id] = true
        end
        ShopManager.attentionGoodsIds.num[self.actiontype] = #self.goodslist
    end

	local dlg = StallDlg.getInstanceNotCreate()
	if dlg then
		if self.actiontype == 3 then
			dlg:refreshMyStallGoodsList(self.goodslist)
		else
			dlg:refreshAttentionContainer(self.actiontype == 1, self.goodslist)
		end
	end

    dlg = require("logic.chat.insertdlg").getInstanceNotCreate()
    if dlg then
        if self.actiontype == 3 then
            dlg:recvStallOnSellGoods(self.goodslist)
        else
            dlg:recvStallAttentionGoods(self.goodslist)
        end
    end
end

--根据一、二、三级菜单获取摆摊商品
p = require "protodef.fire.pb.shop.smarketbrowse"
function p:process()
	local dlg = StallUpShelf.getInstanceNotCreate()
	if dlg then
		dlg:recvStallGoods(self)
		return
	end

	dlg = StallDlg.getInstanceNotCreate()
	if dlg then
		dlg:recvStallGoods(self)
	end
end

--商品购买成功返回
p = require "protodef.fire.pb.shop.smarketbuy"
function p:process()
	local dlg = StallDlg.getInstanceNotCreate()
	if dlg then
		dlg:recvBuyStallGoodsRes(self.id, self.surplusnum)
	end
end

--上架的推荐价格
p = require "protodef.fire.pb.shop.sgetmarketupprice"
function p:process()
	local dlg = StallUpShelf.getInstanceNotCreate()
	if dlg then
		dlg:setRecommendPrice(self.containertype, self.price, self.stallprice)
	end
end

--珍品公示成功
p = require "protodef.fire.pb.shop.smarketupsucc"
function p:process()
    if not IsPointCardServer() then
	    local iniMgr = IniManager("SystemSetting.ini")
	    local exist,_,_,value = iniMgr:GetValueByName("GameConfig", "shangjiashijian", "")
	    if exist then
		    local timestamp = gGetServerTime()
		    if (timestamp - tonumber(value)) / (24*60*60*1000) < 7 then
			    return
		    end
		    iniMgr:RemoveValueByName("GameConfig", "shangjiashijian")
	    end

	    local dlg = StallUpOkConfirm.getInstanceAndShow()
	    dlg:setViewType(self.israrity)
    end
end

--摆摊交易记录
p = require "protodef.fire.pb.shop.smarkettradelog"
function p:process()
	local dlg = StallTradeLogDlg.getInstanceNotCreate()
	if dlg then
		dlg:setTradeLogData(self)
	end
end

--商城购买成功
p = require "protodef.fire.pb.shop.snotifybuysuccess"
function p:process()
    if self.notifytype == fire.pb.shop.ShopBuyType.MALL_SHOP then
        local dlg = MallShop.getInstanceNotCreate()
        if dlg then
            dlg:recvBuySuccess(self)
        end

        local ranseDlg =  require"logic.ranse.ranselabel".getInstanceNotCreate()
        if ranseDlg then
            ranseDlg:refreshItemShow()
        end
    end
end

--摆摊搜索结果
p = require "protodef.fire.pb.shop.smarketsearchresult"
function p:process()
	local dlg = StallDlg.getInstanceNotCreate()
	if dlg then
		dlg:recvSearchResult(self)
	end
end

--关注
p = require "protodef.fire.pb.shop.sattentiongoods"
function p:process()
	if self.attentiontype == 1 then --关注
		GetCTipsManager():AddMessageTipById(190015) --关注成功！
	elseif self.attentiontype == 2 then --取消关注
		GetCTipsManager():AddMessageTipById(190016) --取消关注成功
	end

    local n = (self.attentiontype == 1 and 1 or -1)
    ShopManager.attentionGoodsIds.num[self.attentype] = ShopManager.attentionGoodsIds.num[self.attentype] + n
    ShopManager.attentionGoodsIds[self.id] = (self.attentiontype == 1 and true or nil)

	local dlg = StallDlg.getInstanceNotCreate()
	if dlg then
		dlg:refreshGoodsAttention(self.attentype, self.attentiontype, self.id)
	end
end

p = require "protodef.fire.pb.shop.smarketpettips"
function p:process()
	local petData = require("logic.pet.mainpetdata"):new()
    petData:initWithLua(self.pettips)
	LuaRecvPetTipsData(petData, self.tipstype)
end

--浏览聊天中的摆摊商品
p = require "protodef.fire.pb.shop.smarketitemchatshow"
function p:process()
    StallDlg.notQueryGoods = true
    require("logic.shop.stalllabel").show()
    local dlg = StallDlg.getInstanceNotCreate()
    if dlg then
        dlg:showChatStallGoods(self)
    end
    StallDlg.notQueryGoods = nil
end

p = require "protodef.fire.pb.shop.stempmarketcontainer"
function p:process()
    ShopManager.hefuGoodsList = self.goodslist
	if #self.goodslist > 0 then
		MainControl.ShowBtnInFirstRow(MainControlBtn_HeFuBag)
	end
end

p = require "protodef.fire.pb.shop.stakebacktempmarketcontaineritem"
function p:process()
	if self.succ == 1 then
		local dlg = require("logic.shop.hefubagdlg").getInstanceNotCreate()
		if dlg then
			dlg.DestroyDialog()
		end

		MainControl.ShowBtnInFirstRow(MainControlBtn_HeFuBag, false)
	end
end

local function GetBlackMarketItemDialog()
	return require("logic.blackmarket.cbgitemdlg").getInstanceNotCreate()
end

local function GetBlackMarketRoleDialog()
	return require("logic.blackmarket.cbgrole").getInstanceNotCreate()
end

-- 黑市个人寄售浏览
p = require "protodef.fire.pb.shop.sblackmarketcontainerbrowse"
function p:process()
	local dlg = GetBlackMarketItemDialog()
	if dlg then
		dlg:onMySell(self)
	end
end

-- 黑市商品浏览
p = require "protodef.fire.pb.shop.sblackmarketitembrowse"
function p:process()
	local dlg = GetBlackMarketItemDialog()
	if dlg then
		dlg:onSellItemResult(self)
	end
end

-- 黑市角色信息
p = require "protodef.fire.pb.shop.sblackmarketroleinfo"
function p:process()
	local dlg = GetBlackMarketRoleDialog()
	if dlg then
		dlg:onRoleInfo(self)
	end
end

local function GetGoldOrderDialog()
	local dlg = require("logic.blackmarket.cbggolddlg").getInstanceNotCreate()
	if dlg then
		return dlg
	end
	return require("logic.shop.treasurehousedlg").getInstanceNotCreate()
end

-- 金币订单分页浏览
p = require "protodef.fire.pb.shop.sgoldorderbrowseindex"
function p:process()
	local dlg = GetGoldOrderDialog()
	if dlg and dlg.setGoldOrderIndex then
		dlg:setGoldOrderIndex(self)
	end
end

-- 金币订单浏览
p = require "protodef.fire.pb.shop.sgoldorderbrowseblackmarket"
function p:process()
	local dlg = GetGoldOrderDialog()
	if dlg then
		dlg:setGoldOrderList(self.salelist, self.buylist)
	end
end

-- 添加新订单
p = require "protodef.fire.pb.shop.sgoldorderupblackmarket"
function p:process()
	local dlg = GetGoldOrderDialog()
	if dlg then
		dlg:addOrder(self.order)
	end
end

-- 更新订单状态
p = require "protodef.fire.pb.shop.srefreshgoldorderstate"
function p:process()
	local dlg = GetGoldOrderDialog()
	if dlg then
		dlg:refreshGoldOrderState(self.pid, self.state)
	end
end

-- 删除订单
p = require "protodef.fire.pb.shop.sgoldorderdownblackmarket"
function p:process()
	local dlg = GetGoldOrderDialog()
	if dlg then
		dlg:deleteGoldOrder(self.pid)
	end
end
