AddCashChargeReturnCell = {}

setmetatable(AddCashChargeReturnCell, Dialog)
AddCashChargeReturnCell.__index = AddCashChargeReturnCell
local prefix = 0
------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
function AddCashChargeReturnCell.CreateNewDlg(pParentDlg, id)
	LogInfo("enter AddCashChargeReturnCell.CreateNewDlg")
	local newDlg = AddCashChargeReturnCell:new()
	newDlg:OnCreate(pParentDlg,id)

    return newDlg
end
----/////////////////////////////////////////------

function AddCashChargeReturnCell.GetLayoutFileName()
    return "addcashchargereturncell.layout"
end

function AddCashChargeReturnCell:OnCreate(pParentDlg, id)
	LogInfo("enter AddCashChargeReturnCell oncreate")
	prefix = prefix + 1
    Dialog.OnCreate(self, pParentDlg, prefix)
	
	self.m_ID = id

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
	self.m_text = winMgr:getWindow(tostring(prefix) .. "addcashdlgcell/text")
	self.m_progress = CEGUI.toProgressBar(winMgr:getWindow(tostring(prefix) .. "addcashdlgcellprogress"))
	self.m_grabbtn = winMgr:getWindow(tostring(prefix) .. "addcashdlgcell/buttongrab")
	self.m_grabimage = winMgr:getWindow(tostring(prefix) .. "addcashdlgcell/imagegrab")
	
	self.m_Item = {};
	self.m_Item[0] = CEGUI.toItemCell(winMgr:getWindow(tostring(prefix) .. "addcashdlgcell/reward0"))
	self.m_Item[1] = CEGUI.toItemCell(winMgr:getWindow(tostring(prefix) .. "addcashdlgcell/reward1"))
	self.m_Item[2] = CEGUI.toItemCell(winMgr:getWindow(tostring(prefix) .. "addcashdlgcell/reward2"))
	
    -- subscribe event
	self.m_grabbtn:subscribeEvent("Clicked", AddCashChargeReturnCell.HandleGrabBtnClick, self) 
    --init settings

	LogInfo("exit AddCashChargeReturnCell OnCreate")
end

------------------- public: -----------------------------------

function AddCashChargeReturnCell:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, AddCashChargeReturnCell)

    return self
end

function AddCashChargeReturnCell:Init(id, curvalue, maxvalue, status, text)

	self.m_text:setText(text);
	
	self.m_progress:setText(math.min(curvalue, maxvalue).."/"..maxvalue)
	self.m_progress:setProgress(curvalue / maxvalue)
	
	local return0 = BeanConfigManager.getInstance():GetTableByName("fushi.cchargereturnprofit"):getRecorder(id)
	
	for k, v in pairs(self.m_Item) do
		
		v:setVisible(false);
		
	end
	
	for i = 0, return0.rewarditems:size() - 1 do --奖励控件 by changhao
		
		for j = 0, return0.rewardnums:size() - 1 do

			if i == j then

				self.m_Item[i]:setVisible(true);
				local item = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(return0.rewarditems[i])
                if item then
				    self.m_Item[i]:SetImage(gGetIconManager():GetImageByID(item.icon))
                    local number = return0.rewardnums[j]
                    if number>1 then
                     self.m_Item[i]:SetTextUnit(tostring(number));
                    else
                     self.m_Item[i]:SetTextUnit("");
                    end
				
			
				    self.m_Item[i]:setID(item.id)
				    self.m_Item[i]:subscribeEvent("TableClick", AddCashChargeReturnCell.HandleShowToolTipsWithItemID, self)				
				    SetItemCellBoundColorByQulityItem(self.m_Item[i], item.nquality)
                end
			end
		
		end
		
	end
	
	self:UpdateStatus(status);
			
end
function  AddCashChargeReturnCell:HandleShowToolTipsWithItemID(args)
    local e = CEGUI.toWindowEventArgs(args)
	local nItemId = e.window:getID()
	local e2 = CEGUI.toMouseEventArgs(args)
	local touchPos = e2.position
	
	local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
	if not itemAttrCfg then
		return
	end
	local nPosX = touchPos.x
	local nPosY = touchPos.y
	local Commontipdlg = require "logic.tips.commontipdlg"
	local commontipdlg = Commontipdlg.getInstanceAndShow()
	--local nType = Commontipdlg.eType.eComeFrom
	local nType = Commontipdlg.eType.eNormal 
	commontipdlg:RefreshItem(nType,nItemId,nPosX,nPosY)

end
function AddCashChargeReturnCell:HandleGrabBtnClick(args)
	
	local msg = CGrabChargeReturnProfitReward.Create()
	msg.id = self.m_ID;
	LuaProtocolManager.getInstance():send(msg)

	return true
	
end

function AddCashChargeReturnCell:SetPrice(price, cashkind,unititem)
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
		num = math.mod(num, math.pow(10,i-1))

		if txt>0 then
			t_price[pos] = "set:MainControl10 image:blue" .. txt
			pos = pos+1
			zerovisible = true
		else
			if zerovisible then
			t_price[pos] = "set:MainControl10 image:blue" .. txt
				pos = pos+1
			end
		end
	end
	-- self.m_cashicon  榛樿锛?  鍥炬爣鏄汉姘戝竵 3闊╁厓
	if cashkind == 2 then
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
end

function AddCashChargeReturnCell:SetYuanbao(yuanbao)
	if yuanbao >= 1000000 then return end
	if yuanbao == 0 then
		self.m_yuanbaoNumWnd:setVisible(false)
		self.m_yuanbaoPicWnd:setVisible(false)
		return
	else
		self.m_yuanbaoNumWnd:setVisible(true)
		self.m_yuanbaoPicWnd:setVisible(true)
	end

	local num = yuanbao
	local pos = 1
	local zerovisible = false
	for i = 6,1,-1 do
		local txt = math.floor(num/math.pow(10,i-1))
		num = math.mod(num, math.pow(10,i-1))

		self.m_yuanbao[pos]:setVisible(true)
		if txt > 0 then 
			self.m_yuanbao[pos]:setProperty("Image", "set:MainControl10 image:blue" .. txt)
			zerovisible = true
			pos = pos + 1
		else
			if zerovisible then
				self.m_yuanbao[pos]:setProperty("Image", "set:MainControl10 image:blue" .. txt)
				pos = pos + 1
			end
		end
	end
	for i= pos,6 do
		self.m_yuanbao[i]:setVisible(false)
	end
end

function AddCashChargeReturnCell:SetExtra(present)
	if present >= 100000 then return end

	if present == 0 then 
		self.m_extraback:setVisible(false)
	else
		self.m_extraback:setVisible(true)
	end

	local offflag =  (present < 1000)
	local num = present
	local zerovisible = false
	local pos = 1
	if offflag then 
		self.m_extra[1]:setVisible(false)
		pos = 2 
	end

	for i = 5,1,-1 do
		local txt = math.floor(num/math.pow(10,i-1))
		num = math.mod(num, math.pow(10,i-1))

		self.m_extra[pos]:setVisible(true)
		if txt > 0 then 
			self.m_extra[pos]:setProperty("Image", "set:MainControl10 image:red" .. txt)
			zerovisible = true
			pos = pos + 1
		else
			if zerovisible then
				self.m_extra[pos]:setProperty("Image", "set:MainControl10 image:red" .. txt)
				pos = pos + 1
			end
		end
	end
	for i= pos,5 do
		self.m_extra[i]:setVisible(false)
	end
end

function AddCashChargeReturnCell:SetFanbei(isFanbei)
	if isFanbei then
		self.m_buybtn:setProperty("HoverImage", "set:MainControl10 image:chongzhiback1")
	    self.m_buybtn:setProperty("NormalImage", "set:MainControl10 image:chongzhiback1")
	    self.m_buybtn:setProperty("PushedImage", "set:MainControl10 image:chongzhiback1")
	    self.m_buybtn:setProperty("DisabledImage", "set:set:MainControl10 image:chongzhiback1")
	    self.m_FanbeiMark:setVisible(true)
	else
		self.m_buybtn:setProperty("HoverImage", "set:MainControl10 image:chongzhiback")
	    self.m_buybtn:setProperty("NormalImage", "set:MainControl10 image:chongzhiback")
	    self.m_buybtn:setProperty("PushedImage", "set:MainControl10 image:chongzhiback")
	    self.m_buybtn:setProperty("DisabledImage", "set:set:MainControl10 image:chongzhiback")
	    self.m_FanbeiMark:setVisible(false)
	end
end

function AddCashChargeReturnCell:UpdateStatus(status)
	
	if status == 0 then --已领取 by changhao
		
		self.m_grabbtn:setVisible(false);
		self.m_grabimage:setVisible(true);
		
	elseif status == 1 then --可以领取 by changhao
	
		self.m_grabbtn:setVisible(true);
		self.m_grabbtn:setEnabled(true);
		self.m_grabimage:setVisible(false);
		
	else --不能领取 by changhao
	
		self.m_grabbtn:setVisible(true);
		self.m_grabbtn:setEnabled(false);
		self.m_grabimage:setVisible(false);
		
	end
	
end

return AddCashChargeReturnCell
