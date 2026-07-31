require "logic.dialog"
ChargeCell = {}

setmetatable(ChargeCell, Dialog)
ChargeCell.__index = ChargeCell
local prefix = 0
local gChargeWaitTime = 0

function ChargeCell.CreateNewDlg(pParentDlg, param)
	LogInfo("enter ChargeCell.CreateNewDlg")
	local newDlg = ChargeCell:new()
	newDlg:OnCreate(pParentDlg,param)

    return newDlg
end

function ChargeCell.GetLayoutFileName()
    return "addcashcell.layout"
end

function ChargeCell:OnCreate(pParentDlg, param)
	LogInfo("enter ChargeCell oncreate")
	prefix = prefix + 1
    Dialog.OnCreate(self, pParentDlg, prefix)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
	
	self.m_buybtn= CEGUI.Window.toGroupButton(winMgr:getWindow(tostring(prefix) .. "addcashcell"))
	self.m_buybtn:subscribeEvent("SelectStateChanged", ChargeCell.HandleBuyBtnClick, self) 
	
	self.m_icon = winMgr:getWindow(tostring(prefix) .. "addcashcell/item")

	self.m_icon:setProperty("Image", tostring(param.icon))

	self.fanbei = winMgr:getWindow(tostring(prefix) .. "addcashcell/fanbei")
	local num = tonumber(param['beishu'])*1
	if num > 0 then
		self.fanbei:setProperty("Image", "set:iconui image:fanbei_0000_"..tostring(param.beishu))
		
		self.fanbei:setVisible(true)
	else
		self.fanbei:setVisible(false)
	end

	self.xiangou = winMgr:getWindow(tostring(prefix) .. "addcashcell/xiangou")
	self.xiangoutxt = winMgr:getWindow(tostring(prefix) .. "addcashcell/xiangou/text")
	if tonumber(param.daylimit) > 0 then
		self.xiangoutxt:setText("今日限购"..param.daylimit.."个")
		self.xiangou:setVisible(true)
	elseif tonumber(param.rolelimit) > 0 then
		self.xiangoutxt:setText("角色限购"..param.rolelimit.."个")
		self.xiangou:setVisible(true)
	else
		self.xiangou:setVisible(false)
	end
	-- self.effect = winMgr:getWindow(tostring(prefix) .. "addcashcell/effect")
	-- gGetGameUIManager():AddUIEffect(self.effect, "geffect/ui/texiao/texiao13", true)

	self.price = winMgr:getWindow(tostring(prefix) .. "addcashcell/price")
    self.price:setText("￥ "..tostring(param.price))

	
	self.name = winMgr:getWindow(tostring(prefix) .. "addcashcell/name")
    self.name:setText(tostring(param.name))


	self.m_ID = param.id




	LogInfo("exit ChargeCell OnCreate")
end

function ChargeCell:clickDingyueInfo()
    local title = MHSD_UTILS.get_resstring(11611)
	local strAllString = MHSD_UTILS.get_resstring(11612)
	local tips1 = require "logic.workshop.tips1"
    tips1.getInstanceAndShow(strAllString, title)
end

------------------- public: -----------------------------------

function ChargeCell:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, ChargeCell)

    return self
end

function ChargeCell:Init(goodid, price, yuanbao, present, beishu, yuanbao_max)
	--local rec = BeanConfigManager.getInstance():GetTableByName("fushi.caddcashlua"):getRecorder(goodid)
	--print("rec.itemicon===%s",rec.itemicon)
	-- if rec then
	-- 	self.m_icon:setProperty("Image", rec.itemicon)
	-- 	if rec.kind ~= 5 then
	-- 		self:SetPrice(price, rec.cashkind,rec.unititem)
	-- 	end
	-- end
--    if IsPointCardServer() then
--        self.m_day:setVisible(true)
--        self.m_day:setProperty("Image", rec.dayRes)
--    end

	self.goodid = goodid
    self.fushinum = yuanbao
	
	self.price = price

	self.yuanbaomax = yuanbao_max

	
	-- --unicomonly 
	-- if Config.MOBILE_ANDROID == 1 and Config.CUR_3RD_LOGIN_SUFFIX == "unsd" then
	-- 	if goodid == 114 or goodid == 115 or goodid == 116 then
	-- 	end
	-- end

end

function ChargeCell:HandleBuyBtnClick(args)
	ChargeDialog.getInstanceNotCreateRefresh(self.goodid)
end

function ChargeCell:SetPrice(price, cashkind,unititem)
	if price >= 1000000 then return end

	local num = price
	local t_price = {}
	local pos = 1
	local zerovisible = false
	for i = 6,1,-1 do
		local txt = math.floor(num/math.pow(10,i-1))
		if i == 3 and cashkind == 2 then
			zerovisible = true
		end
		num = math.fmod(num, math.pow(10,i-1))

		if txt>0 then
			t_price[pos] = "set:jiangli image:blue" .. txt
			pos = pos+1
			zerovisible = true
		else
			if zerovisible then
			t_price[pos] = "set:jiangli image:blue" .. txt
				pos = pos+1
			end
		end
	end
	-- self.m_cashicon  默认＝1  图标是人民币 3韩元
    --[[	if cashkind == 2 then
		self.m_cashicon:setProperty("Image", "set:MainControl10 image:zdollar")
		pos = pos+1
		t_price[pos-1] = t_price[pos-2]
		t_price[pos-2] = t_price[pos-3]
		t_price[pos-3] = "set:MainControl10 image:z0"
	elseif  unititem then 
		self.m_cashicon:setProperty("Image", unititem)
	end

	
	for i=1, pos-1 do
		self.m_price[i]:setProperty("Image", t_price[i])
		self.m_price[i]:setVisible(true)
	end
	for i=pos, 6 do
		self.m_price[i]:setVisible(false)
	end
    ]]
end

function ChargeCell:SetYuanbao(yuanbao, kind)
	if yuanbao >= 1000000 then return end

	local num = yuanbao
	local pos = 1
	local zerovisible = false
	for i = 6,1,-1 do
		local txt = math.floor(num/math.pow(10,i-1))
		num = math.fmod(num, math.pow(10,i-1))

		--[[        self.m_yuanbao[pos]:setVisible(true)
		if txt > 0 then 
			self.m_yuanbao[pos]:setProperty("Image", "set:jiangli image:blue" .. txt)
			zerovisible = true
			pos = pos + 1
		else
			if zerovisible then
				self.m_yuanbao[pos]:setProperty("Image", "set:jiangli image:blue" .. txt)
				pos = pos + 1
			end
		end]]

	end
    --[[	for i= pos,6 do
		self.m_yuanbao[i]:setVisible(false)
	end]]

end

function ChargeCell:SetExtra(present)

end
function ChargeCell.update(delta)
    if gChargeWaitTime > 0 then
        gChargeWaitTime = gChargeWaitTime - delta
    end
end
return ChargeCell
