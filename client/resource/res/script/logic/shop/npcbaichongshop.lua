------------------------------------------------------------------
-- 百宠仙池
------------------------------------------------------------------

require "logic.dialog"
require "manager.currencymanager"



NpcBaiChongShop = {}
setmetatable(NpcBaiChongShop, Dialog)
NpcBaiChongShop.__index = NpcBaiChongShop

local _instance
function NpcBaiChongShop.getInstance()
	if not _instance then
		_instance = NpcBaiChongShop:new()
		_instance:OnCreate()
	end
	return _instance
end

function NpcBaiChongShop.getInstanceAndShow()
	if not _instance then
		_instance = NpcBaiChongShop:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function NpcBaiChongShop.getInstanceOrNot()
	return _instance
end

function NpcBaiChongShop.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function NpcBaiChongShop:OnClose()
	Dialog.OnClose(_instance)
	_instance = nil
end

function NpcBaiChongShop.ToggleOpenClose()
	if not _instance then
		_instance = NpcBaiChongShop:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function NpcBaiChongShop.GetLayoutFileName()

	return "NpcBaiChongShop.layout"
end

function NpcBaiChongShop:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, NpcBaiChongShop)
	return self
end

function NpcBaiChongShop:OnCreate()
	Dialog.OnCreate(self)
	--SetPositionOfWindowWithLabel(self:GetWindow())
	local winMgr = CEGUI.WindowManager:getSingleton()

	--抽奖池初始化
	self:InitialData() 
	
		--关闭按钮
	self.bcclose = winMgr:getWindow("NpcBaiChongShop_mtg/x")
	self.bcclose:subscribeEvent("Clicked", self.DestroyDialog, nil)

	--百宠仙池背景
	self.BC_bg1 = winMgr:getWindow("NpcBaiChongShop_mtg/bg1")
	self.BC_bg2 = winMgr:getWindow("NpcBaiChongShop_mtg/bg2")

	
	

	self.BC_infoBtn = winMgr:getWindow("NpcBaiChongShop_mtg/Btn/info")
	self.BC_info_jm = winMgr:getWindow("NpcBaiChongShop_mtg/Btn/infoJM")
	self.BC_info_jm:setVisible(false)
	self.BC_info_jm:setProperty("AlwaysOnTop", "true")  --置顶

	
	self.BC_infoBtn:subscribeEvent("MouseClick", NpcBaiChongShop.close_info_jm, self)
	
	--抽取动画 的 特效控件
	self.Bc_Eff1 = winMgr:getWindow("NpcBaiChongShop_mtg/Btn/tx1")


	--空白处关闭结果画面
	self.JG_back = winMgr:getWindow("NpcBaiChongShop_mtg/jieguo")
	self.JG_black = winMgr:getWindow("NpcBaiChongShop_mtg/jieguo/close1")
	--self.JG_back:subscribeEvent("MouseClick", NpcBaiChongShop.closeJG, self)
	self.JG_black:subscribeEvent("MouseClick", NpcBaiChongShop.closeJG, self)

	self.JG_back:setVisible(false)
	self.JG_back:setProperty("Image", "set:LoginBack2 image:CommonBack9999")  --去除黑底

	--跳过动画
	self.checkBox1 = CEGUI.Window.toCheckbox(winMgr:getWindow("NpcBaiChongShop_mtg/Btn/danxuan"))
	--self.checkBox1:setSelectedNoEvent(false)
	self.checkBox1:subscribeEvent("CheckStateChanged", NpcBaiChongShop.HandleConfig1, self)
		self.tiaoguo = 0  -- 不跳过  默认



	--祈愿结果界面循环动画
	self.JG_donghua = winMgr:getWindow("NpcBaiChongShop_mtg/jieguo/eff")
	self.JG_donghua1 = winMgr:getWindow("NpcBaiChongShop_mtg/jieguo/eff1")
	self.JG_donghua2 = winMgr:getWindow("NpcBaiChongShop_mtg/jieguo/eff2")
	gGetGameUIManager():AddUIEffect(self.JG_donghua, "geffect/ui/MY_texiao/My_Baichong_Ani1", true) -- 播放动画 附着的变量、动画路径、是否循环
	gGetGameUIManager():AddUIEffect(self.JG_donghua1, "geffect/sence/mt_tidao/mt_tidao_lizi_1", true) -- 播放动画 附着的变量、动画路径、是否循环
	gGetGameUIManager():AddUIEffect(self.JG_donghua2, "geffect/sence/mt_tidao/mt_tidao_lizi_1", true) -- 播放动画 附着的变量、动画路径、是否循环



	
	--抽一次 按钮
	self.Buy1 = winMgr:getWindow("NpcBaiChongShop_mtg/qiyuan1")
	self.Buy10 = winMgr:getWindow("NpcBaiChongShop_mtg/qiyuan10")
	self.Buy1:subscribeEvent("Clicked", NpcBaiChongShop.Buy1Clicked, self)  --抽一次 按钮响应事件
	self.Buy10:subscribeEvent("Clicked", NpcBaiChongShop.Buy10Clicked, self)  --抽十次 按钮响应事件
	



	self.Qy_shop = winMgr:getWindow("NpcBaiChongShop_mtg/QYshop")
	self.Qy_shop:subscribeEvent("Clicked", NpcBaiChongShop.OpenQy_shop, self)  --打开祈愿商店


	self.ChanchuText = winMgr:getWindow("NpcBaiChongShop_mtg/Btn/text1")

	self.JG_items = {}
	self.JG_itemsNmae = {}
	--祈愿结果控件初始化
    for i = 1, 10 do
		self.JG_items[i] = CEGUI.Window.toItemCell(winMgr:getWindow("NpcBaiChongShop_mtg/jieguo/qp"..i))
		self.JG_itemsNmae[i] = winMgr:getWindow("NpcBaiChongShop_mtg/jieguo/qpName"..i)
		self.JG_items[i]:setVisible(false)
		self.JG_itemsNmae[i]:setVisible(false)
		
		gGetGameUIManager():AddUIEffect(self.JG_items[i], "geffect/ui/MY_texiao/My_Ylg_Ani1", true) -- 播放动画 附着的变量、动画路径、是否循环

	end
	
	

	 self:GetWindow():subscribeEvent("WindowUpdate", NpcBaiChongShop.HandleWindowUpdate, self)

	self.MY_Win_Time1 =  0  --计时变量 打开界面开始为0

end

function NpcBaiChongShop:HandleConfig1()  --单选框
	if self.tiaoguo == 1 then
		self.tiaoguo = 0
	--GetCTipsManager():AddMessageTip("当前为不跳过  ")
		
	else
		self.tiaoguo = 1
	--GetCTipsManager():AddMessageTip("当前为跳过  ")
	end
end


function NpcBaiChongShop:close_info_jm()  --显隐百宠介绍
	if not self.BC_info_jm:isVisible() then
		self.BC_info_jm:setVisible(true)
	else
		self.BC_info_jm:setVisible(false)
	end
end

 function NpcBaiChongShop:HandleWindowUpdate()  --更新参数
 	self.MY_Win_Time1 =  self.MY_Win_Time1 + 1

	 if self.MY_Win_Time1 == 4 then
	 	--产出概率文本 
		self.ChanchuText:setText("虎力大仙、大力金刚")
	 end
 end
 
function NpcBaiChongShop:yincangBCui()  --隐藏百宠仙池界面  为了祈愿结果

	self.BC_bg1:setVisible(false)
	self.BC_bg2:setVisible(false)
	self.Buy1:setVisible(false)
	self.Buy10:setVisible(false)
	self.Qy_shop:setVisible(false)
	self.ChanchuText:setVisible(false)
	self.bcclose:setVisible(false)
	self.BC_infoBtn:setVisible(false)
	self.BC_info_jm:setVisible(false)

	self.checkBox1:setVisible(false)

end


function NpcBaiChongShop:huifuBCui()  --恢复百宠仙池界面  为了祈愿结果

	self.BC_bg1:setVisible(true)
	self.BC_bg2:setVisible(true)
	self.Buy1:setVisible(true)
	self.Buy10:setVisible(true)
	self.Qy_shop:setVisible(true)
	self.ChanchuText:setVisible(true)
	self.bcclose:setVisible(true)
	self.BC_infoBtn:setVisible(true)

	self.checkBox1:setVisible(true)

end

function NpcBaiChongShop:OpenQy_shop()
	require "logic.shop.NpcQiYuanShop"--打开祈愿商店
	NpcQiYuanShop.getInstanceAndShow()--打开祈愿商店
	
	
end

-- 辅助函数：生成一个 0 到 1 之间的随机数
function NpcBaiChongShop:getRandom()
    return math.random()
end

-- 随机选择函数
function NpcBaiChongShop:randomSelectItem()
	local totalProbability = 0 --总概率
    for i = 1, #self.items do
		totalProbability = totalProbability + self.items[i].probability
	end


    local randomValue = self:getRandom() * totalProbability  -- 将随机数乘以总概率

    local cumulativeProbability = 0

    for _, item in ipairs(self.items ) do
        cumulativeProbability = cumulativeProbability + item.probability

        if randomValue < cumulativeProbability then
            return item.itemid
        end
    end

    -- 如果没有找到合适的，返回最后一个元素的编号
    return self.items[1].itemid
end

-- 测试随机选择
--GetCTipsManager():AddMessageTip(self:randomSelectItem())

-- 判断仙玉数量
function NpcBaiChongShop:Buy_ok()
     self.yongyouhuobi = CurrencyManager.getOwnCurrencyMount(111)

end

--1特效开始播放   买一个
function NpcBaiChongShop:Buy1Clicked()

		--检查背包容量
		if not CheckBagCapacityForItem(self.items[1].itemid, tonumber(2)) then
			GetCTipsManager():AddMessageTip("背包空间不足，无法祈愿") --背包空间不足
			return
		end

local onemoney = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(900).value)
local tmpmoney = CurrencyManager.getOwnCurrencyMount(111)
	 if tmpmoney < onemoney then
		 GetCTipsManager():AddMessageTip("梦想值不足，无法祈愿")
		 return
	 end


	if self.tiaoguo == 1 then 
		--跳过动画的情况
		local effect = gGetGameUIManager():AddUIEffect(self.Bc_Eff1, "geffect/ui/MY_texiao/My_BC_Ani4", false) --�ϳ���Ч ����
		self:yincangBCui() --隐藏百宠仙池界面

		if effect then
			effect:AddNotify(GameUImanager:createNotify(self.Buy1_onEffectEnd))
		end

	
	else
		-----不跳过动画的情况
		local effect = gGetGameUIManager():AddUIEffect(self.Bc_Eff1, "geffect/ui/MY_texiao/My_BC_Ani3", false) --�ϳ���Ч ����
		self:yincangBCui() --隐藏百宠仙池界面

		if effect then
			effect:AddNotify(GameUImanager:createNotify(self.Buy1_onEffectEnd))
		end
	
	end
		
		
	local p = require("protodef.fire.pb.item.cwish").Create()
		p.times = 1
		LuaProtocolManager:send(p)
end
--2特效播放结束   买一个
function NpcBaiChongShop.Buy1_onEffectEnd()--特效播放结束
	if _instance then
		_instance.effectEnd = true
		_instance:handleBuy1()
	end

end

--1特效开始播放   买十个
function NpcBaiChongShop:Buy10Clicked()

	if not CheckBagCapacityForItem(self.items[1].itemid, tonumber(10)) then
		GetCTipsManager():AddMessageTip("背包空间不足，无法祈愿") --背包空间不足
		return
	end
	local tenmoney = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(901).value)
	local tmpmoney = CurrencyManager.getOwnCurrencyMount(111)
	 if tmpmoney < tenmoney then
		 GetCTipsManager():AddMessageTip("梦想值不足，无法祈愿")
		 return
	 end

	if self.tiaoguo == 1 then 
		--跳过动画的情况
		local effect = gGetGameUIManager():AddUIEffect(self.Bc_Eff1, "geffect/ui/MY_texiao/My_BC_Ani4", false) --�ϳ���Ч ����
		self:yincangBCui() --隐藏百宠仙池界面

		if effect then
			effect:AddNotify(GameUImanager:createNotify(self.Buy10_onEffectEnd))
		end

	
	else
		-----不跳过动画的情况
		local effect = gGetGameUIManager():AddUIEffect(self.Bc_Eff1, "geffect/ui/MY_texiao/My_BC_Ani3", false) --�ϳ���Ч ����
		self:yincangBCui() --隐藏百宠仙池界面

		if effect then
			effect:AddNotify(GameUImanager:createNotify(self.Buy10_onEffectEnd))
		end
	
	end
	
	local p = require("protodef.fire.pb.item.cwish").Create()
		p.times = 10
		LuaProtocolManager:send(p)
end
--2特效播放结束   买十个
function NpcBaiChongShop.Buy10_onEffectEnd()--特效播放结束
	if _instance then
		_instance.effectEnd = true
		_instance:handleBuy10()
	end
	
end

function NpcBaiChongShop:handleBuy1()

	for i = 1, 10 do
		self.JG_items[i]:setVisible(false)
		self.JG_itemsNmae[i]:setVisible(false)
	end
	
	self.JG_back:setVisible(true)
	self.JG_items[1]:setVisible(true)
	self.JG_itemsNmae[1]:setVisible(true)

	
	-- local itemid = self:randomSelectItem()
	
	-- local conf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cgoods")):getRecorder(itemid)  --cgoods
	-- if not conf then
		-- return
	-- end
	
	-- local item = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(conf.itemId)
	-- if not item then
		-- return
	-- end
	
	--GetCTipsManager():AddMessageTip("恭喜获得"..self.ret[1].itemname)

	local s1 = self.JG_items[1]:getPixelSize()
	--for i = 1, #self.items do
	--	if self.items[i].itemid == itemid then
			gGetGameUIManager():AddWindowSprite(self.JG_items[1],  self.ret[1].shapeid, Nuclear.XPDIR_BOTTOMRIGHT, s1.width * 0.5, s1.height * 0.5 + 50, true)
			self.JG_itemsNmae[1]:setText(self.ret[1].itemname)
	--	end
	--end
	


	
	
	-- local p = require("protodef.fire.pb.shop.cbuymallshop").Create()
	-- p.shopid = 17
	-- p.num = 1
	-- p.goodsid = itemid

	
	-- LuaProtocolManager:send(p)
	



	--获得蕴灵币
	-- local p = require("protodef.fire.pb.shop.cbuymallshop").Create()
	-- p.shopid = 17
	-- p.num = math.random(1, 198)
	
	-- GetCTipsManager():AddMessageTip("此次祈愿获得"..p.num.."枚蕴灵币。")
	-- p.goodsid = 11054
	-- LuaProtocolManager:send(p)




end
 
function NpcBaiChongShop:handleBuy10()
	
	self.JG_back:setVisible(true)
	for i = 1, #self.ret do
		self.JG_items[i]:setVisible(true)
		self.JG_itemsNmae[i]:setVisible(true)
		
		-- local itemid = self:randomSelectItem()
		-- local conf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cgoods")):getRecorder(itemid)  --cgoods
		-- if not conf then
			-- return
		-- end
	
		-- local item = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(conf.itemId)
		-- if not item then
			-- return
		-- end

		--GetCTipsManager():AddMessageTip("恭喜获得"..self.ret[i].itemicon)
		if i == 1 then
			local s1 = self.JG_items[1]:getPixelSize()
		--	for a = 1, #self.ret do
		--		if self.items[a].itemid == itemid then
					gGetGameUIManager():AddWindowSprite(self.JG_items[1],  self.ret[i].shapeid, Nuclear.XPDIR_BOTTOMRIGHT, s1.width * 0.5, s1.height * 0.5 + 50, true)
					self.JG_itemsNmae[1]:setText(self.ret[i].itemname)

		--		end
		--	end
			
			-- local p = require("protodef.fire.pb.shop.cbuymallshop").Create()
			-- p.shopid = 17
			-- p.num = 1
			-- p.goodsid = itemid
			-- LuaProtocolManager:send(p)
		else
		--	for a = 1, #self.ret do
			--	if self.items[a].itemid == itemid then
					self.JG_items[i]:SetImage( gGetIconManager():GetImageByID(self.ret[i].itemicon))
					self.JG_itemsNmae[i]:setText(self.ret[i].itemname)
			--	end
		--	end
			
			-- local p = require("protodef.fire.pb.shop.cbuymallshop").Create()
			-- p.shopid = 17
			-- p.num = 1
			-- p.goodsid = itemid
			-- LuaProtocolManager:send(p)
		end
	end
	
	-- local p = require("protodef.fire.pb.item.cwish").Create()
		-- p.times = 10
		-- LuaProtocolManager:send(p)
	--获得蕴灵币
	-- local p = require("protodef.fire.pb.shop.cbuymallshop").Create()
	-- p.shopid = 17
	-- p.num = math.random(1000, 1980)
	
	-- GetCTipsManager():AddMessageTip("此次祈愿获得"..p.num.."枚蕴灵币。")
	-- p.goodsid = 11054
	-- LuaProtocolManager:send(p)

	
end
 
function NpcBaiChongShop:closeJG()
	self.JG_back:setVisible(false)
	
	for i = 1, 10 do
		self.JG_items[i]:setVisible(false)
		self.JG_itemsNmae[i]:setVisible(false)
	end
	
	self:huifuBCui() --恢复百宠仙池界面

end

function NpcBaiChongShop:result(datas)
	self.ret = {}
	 local map = BeanConfigManager.getInstance():GetTableByName("item.cwish"):getAllID()
	for k ,v in ipairs (datas) do
		
		for x = 1 ,#map do	
		local lmap = BeanConfigManager.getInstance():GetTableByName("item.cwish"):getRecorder(x)
		if v == lmap.itemid then
		
		self.ret[k] = BeanConfigManager.getInstance():GetTableByName("item.cwish"):getRecorder(x)
		

		end
		end			
	end
end
 
function NpcBaiChongShop:InitialData()  --初始化百宠仙池
-- 一个包含编号和对应概率的数组
-- self.items = {



    -- {id = 	7805	,name = 	"变异泡泡"	,shapeID = 	1100101	, probability = 	10	},
    -- {id = 	7806	,name = 	"变异野猪"	,shapeID = 	1100102	, probability = 	25	},
    -- {id = 	7807	,name = 	"变异大海龟"	,shapeID = 	1100103	, probability = 	25	},
    -- {id = 	7808	,name = 	"变异海毛虫"	,shapeID = 	1100104	, probability = 	25	},
    -- {id = 	7809	,name = 	"变异老虎"	,shapeID = 	1100105	, probability = 	25	},
    -- {id = 	7810	,name = 	"变异羊头怪"	,shapeID = 	1100106	, probability = 	25	}



-- }
	
	self.items =BeanConfigManager.getInstance():GetTableByName("item.cwish"):getAllID()
	for k ,v in ipairs (self.items) do
	
	self.items[k] = BeanConfigManager.getInstance():GetTableByName("item.cwish"):getRecorder(k)

	end
	

end

return NpcBaiChongShop