------------------------------------------------------------------
-- 时空宝盒
------------------------------------------------------------------

require "logic.dialog"


shikongbaohe = {}
setmetatable(shikongbaohe, Dialog)
shikongbaohe.__index = shikongbaohe

local _instance
function shikongbaohe.getInstance()
	if not _instance then
		_instance = shikongbaohe:new()
		_instance:OnCreate()
	end
	return _instance
end

function shikongbaohe.getInstanceAndShow()
	if not _instance then
		_instance = shikongbaohe:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function shikongbaohe.getInstanceOrNot()
	return _instance
end

function shikongbaohe.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function shikongbaohe:OnClose()
	Dialog.OnClose(_instance)
	_instance = nil
end

function shikongbaohe.ToggleOpenClose()
	if not _instance then
		_instance = shikongbaohe:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function shikongbaohe.GetLayoutFileName()

	return "Shikongbaohe.layout"
end

function shikongbaohe:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, shikongbaohe)
	return self
end

function shikongbaohe:OnCreate()
	Dialog.OnCreate(self)
	--SetPositionOfWindowWithLabel(self:GetWindow())
	local winMgr = CEGUI.WindowManager:getSingleton()

	
	
	--待机动画
	self.skbh_bg1 = winMgr:getWindow("shikongbaohe/bgtx")
	self.m_scrollReward = CEGUI.toScrollablePane(winMgr:getWindow("shikongbaohe/box"))
	self.m_scrollReward:EnableAllChildDrag(self.m_scrollReward)
	self.skbh_bg2 = winMgr:getWindow("shikongbaohe/bgtx1")
	self.skbh_bg1:setVisible(true)
	self.skbh_bg2:setVisible(false)

	
	self.bgEffect = gGetGameUIManager():AddUIEffect(self.skbh_bg1, "spine/my_spine/shikongbaohe", true)
    self.bgEffect:SetDefaultActName("daiji")--背景动画 --daiji   kaishi

	self.skbh_buy = winMgr:getWindow("shikongbaohe/all")
	self.skbh_buy:subscribeEvent("Clicked", shikongbaohe.BuyClicked, self)  --开始抽取 按钮响应事件

	self.skbh_day = winMgr:getWindow("shikongbaohe/timetext/txt")
	self.huobi = winMgr:getWindow("shikongbaohe/huafei/yu")
	self.huobileix  = 111
	local conf = BeanConfigManager.getInstance():GetTableByName("shop.ccurrencyiconpath"):getRecorder(self.huobileix)
	self.huobi:setProperty("Image", conf.iconpath)

	self:setshixcheng() -- 设置时辰文本
	
	
	self.skbh_yulan = winMgr:getWindow("shikongbaohe/yulan") --预览按钮
	self.skbh_yulan:subscribeEvent("Clicked", shikongbaohe.lookjiangchi, self)  --开始抽取 按钮响应事件
	
	self.skbh_jiangchi = winMgr:getWindow("shikongbaohe/jiangchi") --奖池框
	self.skbh_jiangchi:setVisible(false)--默认隐藏奖池
	self.skbh_jiangchi_x = winMgr:getWindow("shikongbaohe/jiangchi/x") --奖池框
	self.skbh_jiangchi_x:subscribeEvent("Clicked", shikongbaohe.lookjiangchi, self)  --开始抽取 按钮响应事件


	self.skbh_huafei = winMgr:getWindow("shikongbaohe/huafei/text") --花费数值
	self.onemoney = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(509).value)
	self.skbh_huafei:setText(self.onemoney)

	self:updateCurrencyDisplay()
	--初始化8个格子 只做显示用
	self.skbh_item = {}
	
	local zhuanpanbianhao = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(507).value)
	--local zhuanpanbianhao = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(507).value)
	---print(zhuanpanbianhao)
	local wheelTable = BeanConfigManager.getInstance():GetTableByName("game.cschoolwheel"):getRecorder(zhuanpanbianhao)

	local vcItemString = wheelTable.items

	local gezi = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(510).value)
	for a=1 ,gezi do

		self.skbh_item[a] = CEGUI.Window.toItemCell(winMgr:getWindow("shikongbaohe/box/item"..a)) --奖池道具格子
		self.skbh_item[a]:subscribeEvent("TableClick", shikongbaohe.HandleClickItemCellTarget, self)

		local vstrData = StringBuilder.Split(vcItemString[a-1], ";")--分割数据
		local itemId = tonumber(vstrData[1])
		local itemNum = tonumber(vstrData[2])
		
		
		--设置道具图片
		local itembean = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(itemId) --根据转盘表里 去 获取杂货表道具id
        if itembean then
			self.skbh_item[a]:SetImage(gGetIconManager():GetItemIconByID(itembean.icon))
			self.skbh_item[a]:setID(itemId)
		end
		
		--设置数量
		if itemNum > 1 then
		     self.skbh_item[a]:SetTextUnit(itemNum)
        end

	
		
	end
	



	--初始化时间
	self.State = 0
	self.time = 0
	
	
	
	self:GetWindow():subscribeEvent("WindowUpdate", shikongbaohe.HandleWindowUpdate, self)

	
	--关闭按钮
	self.close = winMgr:getWindow("shikongbaohe/x")
	self.close:subscribeEvent("Clicked", self.DestroyDialog, nil)
	


end

function shikongbaohe:lookjiangchi()  --显隐奖池

	self.skbh_jiangchi:setVisible(not self.skbh_jiangchi:isVisible())
	
	
end
function shikongbaohe:updateCurrencyDisplay()--更新货币
    -- 获取货币管理实例
    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    
    -- 获取货币数量
    self.yongyouhuobi = CurrencyManager.getOwnCurrencyMount(111)
    
    -- 更新货币显示窗口
    local winMgr = CEGUI.WindowManager:getSingleton()
    self.skbh_yongyou = winMgr:getWindow("shikongbaohe/yongyou/text")
    self.skbh_yongyou:setText(tostring(self.yongyouhuobi))
    
    -- 日志输出，便于调试
  --  print("Currency updated. Current amount: " .. tostring(self.yongyouhuobi))
end


function shikongbaohe:HandleWindowUpdate()  --更新参数

	self:updateCurrencyDisplay()
	 if self.State == 1 then --开始抽取
	 	self.time = self.time + 1
		
		if self.time >= 20 then--95 then --动画播放完毕
			
			local p = require "protodef.fire.pb.game.cbeginschoolwheel1":new()
			require "manager.luaprotocolmanager":send(p)
			
			local p = require "protodef.fire.pb.game.cendschoolwheel1":new()
	        require "manager.luaprotocolmanager":send(p)
			self.skbh_bg1:setVisible(true)
			self.skbh_bg2:setVisible(false)

			--
			self.skbh_buy:setEnabled(true)--设置按钮可用
			self.time  = 0 --停止抽取 归零
			self.State = 0 --停止抽取 归零

		end
		
	 end

end



 --1开始抽取 播放特效动画
function shikongbaohe:BuyClicked()
    
	if self.yongyouhuobi < self.onemoney then
		GetCTipsManager():AddMessageTip("货币不足，无法抽取")
		return
	end
	

	self.skbh_bg1:setVisible(false)
	self.skbh_bg2:setVisible(true)
	local effect = gGetGameUIManager():AddUIEffect(self.skbh_bg2, "spine/my_spine/shikongbaohe", true)
    effect:SetDefaultActName("kaishi")--背景动画 --daiji   kaishi
		
	self.skbh_buy:setEnabled(false)--设置按钮不可用
	self.State = 1  --开始抽取
	
end



function shikongbaohe:HandleClickItemCellTarget(args)

    local e = CEGUI.toWindowEventArgs(args)
	local idx = e.window:getID()
	local e = CEGUI.toMouseEventArgs(args)
	local touchPos = e.position
    

    local nItemId = idx 
	local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
	if not itemAttrCfg then
		return
	end
	local nPosX = touchPos.x
	local nPosY = touchPos.y
	local Commontipdlg = require "logic.tips.commontipdlg"
	local commontipdlg = Commontipdlg.getInstanceAndShow()
	local nType = Commontipdlg.eType.eNormal 
	commontipdlg:RefreshItem(nType,nItemId,nPosX,nPosY)
end


--设置时辰
function shikongbaohe:setshixcheng()
		local time = StringCover.getTimeStruct(gGetServerTime() / 1000)  
	    local hour = time.tm_hour

		if hour == 0 or hour ==23 then
        strhour = "子时"
		end
		if hour == 1 or hour == 2 then
        strhour = "丑时"
		end
		if hour == 4 or hour == 3 then
        strhour = "寅时"
		end
		if hour == 5 or hour == 6 then
        strhour = "卯时"
		end
		if hour == 8 or hour == 7 then
        strhour = "辰时"
		end
		if hour == 10 or hour == 9 then
        strhour = "巳时"
		end
		if hour == 12 or hour == 11 then
        strhour = "午时"
		end
		if hour == 14 or hour == 13 then
        strhour = "未时"
		end
		if hour == 16 or hour == 15 then
        strhour = "申时"
		end
		if hour == 18 or hour == 17 then
        strhour = "酉时"
		end
		if hour == 20 or hour == 19 then
        strhour = "戌时"
		end
		if hour == 22 or hour == 21 then
        strhour = "亥时"
		end
		
		self.skbh_day:setText("当前时间:"..strhour)


end


 

return shikongbaohe