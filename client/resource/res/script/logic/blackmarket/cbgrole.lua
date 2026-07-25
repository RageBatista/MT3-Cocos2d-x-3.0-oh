require "logic.dialog"

cbgrole = {}
setmetatable(cbgrole, Dialog)
cbgrole.__index = cbgrole

local _instance
function cbgrole.getInstance()
	if not _instance then
		_instance = cbgrole:new()
		_instance:OnCreate()
	end
	return _instance
end

function cbgrole.getInstanceAndShow()
	if not _instance then
		_instance = cbgrole:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function cbgrole.getInstanceNotCreate()
	return _instance
end

function cbgrole.DestroyDialog()
	if _instance then
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function cbgrole.ToggleOpenClose()
	if not _instance then
		_instance = cbgrole:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function cbgrole.GetLayoutFileName()
	return "cbgrole.layout"
end

function cbgrole:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, cbgrole)
	return self
end

function cbgrole:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

	self.closeBtn = CEGUI.toPushButton(winMgr:getWindow("cbgrole/close"))
	self.RoleModel = winMgr:getWindow("cbgrole/buy/di/buyinfo/modal")
	self.Rolename = winMgr:getWindow("cbgrole/groupbtn/lbtip11")
	self.RoleLevel = winMgr:getWindow("cbgrole/groupbtn/lbtip111")
	self.RolePrice = winMgr:getWindow("cbgrole/groupbtn/lbtip1111")
	self.LastTime = winMgr:getWindow("cbgrole/groupbtn/lbtip11111")
	self.Buy = winMgr:getWindow("cbgrole/buy")
	self.Sell = winMgr:getWindow("cbgrole/sell")
	self.BuyBtn = CEGUI.toPushButton(winMgr:getWindow("cbgrole/buy/di/buyinfo/btnbuy"))
	self.WxBtn = CEGUI.toPushButton(winMgr:getWindow("cbgrole/buy/di/buyinfo/btnbuy1"))
	self.BuyTab = CEGUI.toGroupButton(winMgr:getWindow("cbgrole/groupbtn/buybtn"))
	self.SellTab = CEGUI.toGroupButton(winMgr:getWindow("cbgrole/groupbtn/buybtn1"))
	self.BuyRoleID = CEGUI.toEditbox(winMgr:getWindow("cbgrole/sell/di/KUANG/di/buyrole"))
	self.LastTimeMinute = CEGUI.toEditbox(winMgr:getWindow("cbgrole/sell/di/KUANG/di/buyrole1"))
	self.WeChat = CEGUI.toEditbox(winMgr:getWindow("cbgrole/sell/di/KUANG/di/buyrole11"))
	self.AliPay = CEGUI.toEditbox(winMgr:getWindow("cbgrole/sell/di/KUANG/di/buyrole2"))
	self.SellPrice = CEGUI.toEditbox(winMgr:getWindow("cbgrole/sell/di/KUANG/di/buyrole21"))
	self.SaleButton = CEGUI.toPushButton(winMgr:getWindow("cbgrole/sell/di/upbtutton"))
	self.BuyContainer = winMgr:getWindow("cbgrole/buy/di/buyinfo")
	self.closeBtn:subscribeEvent("Clicked", cbgrole.HandleCloseButtonClick, self)
	self.BuyBtn:subscribeEvent("Clicked", cbgrole.HandleBuyButtonClick, self)
	self.WxBtn:subscribeEvent("Clicked", cbgrole.HandleBuyButtonClick, self)
	self.BuyTab:subscribeEvent("SelectStateChanged", cbgrole.OnTableSelected, self)
	self.SellTab:subscribeEvent("SelectStateChanged", cbgrole.OnTableSelected, self)
	self.SaleButton:subscribeEvent("Clicked", cbgrole.HandleSaleButtonClick, self)
	self.buttons = {}
	for i = 1, 3 do
		self.buttons[i] = CEGUI.toPushButton(winMgr:getWindow("cbgrole/button" .. tostring(i)))
		self.buttons[i]:setID(i)
		self.buttons[i]:subscribeEvent("Clicked", cbgrole.handleTabBtnClicked, self)
	end
	self.buttons[3]:SetPushState(true)
	self.elapse = 0
	self.endtime = 0
	self.payid = 0
	local req = require("protodef.fire.pb.shop.cblackmarketroleinfo").Create()
	LuaProtocolManager.getInstance():send(req)

	self.m_pMainFrame:subscribeEvent("WindowUpdate", cbgrole.HandleWindowUpdate, self)
end

function cbgrole:HandleWindowUpdate(e)
	local updateArgs = CEGUI.toUpdateEventArgs(e)
	local elapsed = updateArgs.d_timeSinceLastFrame
	self.elapse = self.elapse + elapsed
	if self.elapse >= 1 and self.BuyContainer:isVisible() then
		self.elapse = 0
		local time = gGetServerTime()/1000
		local lasttime = self.endtime - time
		local hours = math.floor((lasttime % (24 * 3600)) / 3600)
		local minutes = math.floor((lasttime % 3600) / 60)
		local seconds = math.floor(lasttime % 60)
		local timestr = string.format("%d小时 %d分 %d秒", hours, minutes, seconds)
		self.LastTime:setText(timestr)
		if lasttime < 0 then
			self.BuyContainer:setVisible(false)
		end
	end
end

function cbgrole:handleTabBtnClicked(args)
	local eventargs = CEGUI.toWindowEventArgs(args)
	local id = eventargs.window:getID()
	if id == 1 then
		self:DestroyDialog()
		require "logic.blackmarket.CBGGoldDlg".getInstanceAndShow()
		return
	elseif id == 2 then
		self:DestroyDialog()
		require "logic.blackmarket.cbgitemdlg".getInstanceAndShow()
		return
	elseif id == 3 then
		self.buttons[3]:SetPushState(true)
		return
	end
end

function cbgrole:HandleCloseButtonClick(args)
	self:DestroyDialog()
end

function cbgrole:onRoleInfo(data)
	self.BuyContainer:setVisible(true)
	self.Rolename:setText(data.rolename)
	self.payid = data.id
	self.RoleLevel:setText(tostring(data.level) .. "级")
	self.RolePrice:setText(tostring(data.price) .. "元")
	local time = gGetServerTime()/1000
	local lasttime = data.lasttime/1000 - time
	self.endtime = data.lasttime /1000
	if lasttime < 0 then
		self.BuyContainer:setVisible(false)
	else
		local hours = math.floor((lasttime  % (24 * 3600)) / 3600)
		local minutes = math.floor((lasttime % 3600) / 60)
		local seconds = math.floor(lasttime % 60)
		local timestr = string.format("%d小时 %d分 %d秒", hours, minutes, seconds)
		self.LastTime:setText(timestr)
		--���������
		local modelid = data.shape
		local rolecolor1 = data.rolecolor1
		local rolecolor2 = data.rolecolor2
		local components = data.components

		self.RoleModel:getGeometryBuffer():setRenderEffect(GameUImanager:createXPRenderEffect(0,
			cbgrole.performPostRenderFunctions))
		local pos = self.RoleModel:GetScreenPosOfCenter()
		local loc = Nuclear.NuclearPoint(pos.x, pos.y + 60)
		self.sprite = UISprite:new(tonumber(modelid))
		self.sprite:SetUILocation(loc)
		self.sprite:SetUIDirection(Nuclear.XPDIR_BOTTOMRIGHT)
		if components then
			if components[1] > 0 then
				self.sprite:SetSpriteComponent(eSprite_Weapon, components[1])
			end
			if components[6] > 0 then
				self.sprite:SetSpriteComponent(eSprite_Horse, components[6])
			end
		end
		self.sprite:SetDyePartIndex(0, rolecolor1)
		self.sprite:SetDyePartIndex(1, rolecolor2)
		self.sprite:SetUIScale(1.2)
	end

	print("lasttime=" .. tostring(data.lasttime/1000) .. " " .. tostring(time) .. " " .. tostring(lasttime))
end

function cbgrole.performPostRenderFunctions(id)
	if cbgrole:getInstance().sprite then
		cbgrole:getInstance().sprite:RenderUISprite()
	end
end

function cbgrole:HandleBuyButtonClick(args)
	local eventargs = CEGUI.toWindowEventArgs(args)
	local win = eventargs.window
	if win == self.BuyBtn then
		--alipay
		local roleid = gGetDataManager():GetMainCharacterID()
		local serverid = gGetLoginManager():getServerID()
		local eHttpShareUrl = GetServerInfo():getHttpAdressByEnum(eHttpShareUrl)
		local url = eHttpShareUrl .. "/api/getpay"
		local param = {}
		param["paytype"] = "1"
		param["roleid"] = roleid
		param["serverid"] = serverid
		param["payid"] = self.payid
		HttpManager.getInstance():PostData(url, toUrlData(param), 100, cbgrole.onHttpResonse)
	else
		--wechat
		local roleid = gGetDataManager():GetMainCharacterID()
		local serverid = gGetLoginManager():getServerID()
		local eHttpShareUrl = GetServerInfo():getHttpAdressByEnum(eHttpShareUrl)
		local url = eHttpShareUrl .. "/api/getpay"
		local param = {}
		param["paytype"] = "0"
		param["roleid"] = roleid
		param["serverid"] = serverid
		param["payid"] = self.payid
		HttpManager.getInstance():PostData(url, toUrlData(param), 101, cbgrole.onHttpResonse)
	end
end

function cbgrole:OnTableSelected(args)
	local eventargs = CEGUI.toWindowEventArgs(args)
	local win = eventargs.window
	if win == self.BuyTab then
		self.Buy:setVisible(true)
		self.Sell:setVisible(false)
	elseif win == self.SellTab then
		self.Buy:setVisible(false)
		self.Sell:setVisible(true)
	end
end

function cbgrole:HandleSaleButtonClick(args)
	if self.BuyRoleID:getText() == "" then
		GetCTipsManager():AddMessageTip("请输入购买者角色ID")
		return
	end
	if self.SellPrice:getText() == "" then
		GetCTipsManager():AddMessageTip("请输入出售价格")
		return
	end
	local time = tonumber(self.LastTimeMinute:getText())
	if self.LastTimeMinute:getText() == "" or self.LastTimeMinute:getText() == "0" or time < 5 then
		GetCTipsManager():AddMessageTip("请输入交易时长，不能为0，必须大于等于5分钟")
		return
	end
	if self.AliPay:getText() == "" then
		GetCTipsManager():AddMessageTip("请输入支付宝账号")
		return
	end
	if self.WeChat:getText() == "" then
		GetCTipsManager():AddMessageTip("请输入微信或QQ联系方式")
		return
	end
	local roleid = gGetDataManager():GetMainCharacterID()
	if self.BuyRoleID:getText() == tostring(roleid) then
		GetCTipsManager():AddMessageTip("不能出售给自己")
		return
	end
	local money = tonumber(self.SellPrice:getText())
	if money<150 then
		GetCTipsManager():AddMessageTip("出售金额不能低于150")
		return
	end
	local buyrole = tonumber(self.BuyRoleID:getText())
	local price = tonumber(self.SellPrice:getText())
	local alipay = self.AliPay:getText()
	local wechat = self.WeChat:getText()
	local msg = require("protodef.fire.pb.shop.cblackmarketroleup").Create()
	msg.buyrole = buyrole
	msg.price = price
	msg.time = time
	msg.alipay = alipay
	msg.wechat = wechat
	LuaProtocolManager.getInstance():send(msg)
end


function cbgrole.onHttpResonse(jsonstr, id)
	if id == 100 or id == 101 then
		local param = JSON.toJSON(jsonstr)
		if param.code == 0 then
			GetCTipsManager():AddMessageTip(param.msg)
		else
			IOS_MHSD_UTILS.OpenURL(base64decode(param.url))
			_instance:DestroyDialog()
		end
	else
		GetCTipsManager():AddMessageTip("获取支付信息失败，或支付功能暂未开放")
	end
end

return cbgrole
