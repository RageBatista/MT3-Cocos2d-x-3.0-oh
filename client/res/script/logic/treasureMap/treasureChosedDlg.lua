require "logic.dialog"
require "logic.treasureMap.treasureCell"

treasureChosedDlg = {}
setmetatable(treasureChosedDlg, Dialog)
treasureChosedDlg.__index = treasureChosedDlg

treasureChosedDlg.startTimer = false
treasureChosedDlg.elapse = 0
treasureChosedDlg.propertyId = 331300
function treasureChosedDlg.startRunTimer()
	treasureChosedDlg.startTimer = true
end	
	
function treasureChosedDlg.tick(dt)
	treasureChosedDlg.elapse = treasureChosedDlg.elapse + dt
	if treasureChosedDlg.elapse >= 2000 then
		treasureChosedDlg.startTimer = false
		treasureChosedDlg.elapse = 0
	    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
		local itemKey = roleItemManager:GetItemKeyByBaseID(treasureChosedDlg.propertyId)
		local pItem = roleItemManager:GetBagItem(itemKey)
        local itemNum = roleItemManager:GetItemNumByBaseID(treasureChosedDlg.propertyId)
        if itemNum > 0 then
            roleItemManager:UseItem(pItem)
        end
	end
end

local _instance
function treasureChosedDlg.getInstance()
	if not _instance then
		_instance = treasureChosedDlg:new()
		_instance:OnCreate() 
	end
	return _instance
end

function treasureChosedDlg.getInstanceAndShow()
	if not _instance then
		_instance = treasureChosedDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function treasureChosedDlg.getInstanceNotCreate()
	return _instance
end

function treasureChosedDlg.DestroyDialog()
	if _instance then
		for i = 1, #_instance.cell do
			_instance.cell[i]:OnClose()
			_instance.cell[i] = nil
		end

		local tipDlg = require("logic.tips.commontipdlg").getInstanceNotCreate()
		if tipDlg then
			tipDlg.DestroyDialog()
		end
		
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function treasureChosedDlg.ToggleOpenClose()
	if not _instance then
		_instance = treasureChosedDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function treasureChosedDlg.HandleBtnOkClicked()
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    local p = require("protodef.fire.pb.mission.cusetreasuremapend"):new()
	LuaProtocolManager:send(p)
	if _instance.propertyId == 331300 then
		local itemKey = roleItemManager:GetItemKeyByBaseID(_instance.propertyId)
		if itemKey ~= 0 then
			if _instance.awardId ~= 4 then -- 战斗
				treasureChosedDlg.startTimer = true
			else
				GetMainCharacter():SetFlyToEnable(true)
			end
		end
	end
	treasureChosedDlg.DestroyDialog()
end

function treasureChosedDlg.GetLayoutFileName()
	return "wabao_mtg.layout"
end

function treasureChosedDlg:new() 
	local self = {}
	self = Dialog:new()
	setmetatable(self, treasureChosedDlg)
	return self
end

function treasureChosedDlg:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
	local btnClose = CEGUI.toPushButton(winMgr:getWindow("wabao_mtg/close"))
	self.list = winMgr:getWindow("wabao_mtg/list")
	self.btnOk = CEGUI.toPushButton(winMgr:getWindow("wabao_mtg/btn"))
	self.btnOk:subscribeEvent("Clicked", treasureChosedDlg.HandleBtnOkClicked , self)
	btnClose:subscribeEvent("Clicked", treasureChosedDlg.HandleBtnOkClicked , self)
	self.btnOk:setEnabled(false)	
end

function treasureChosedDlg:initTreasureInfo(treasuretype, awardId, itemIds)
	local width = 145
	local height = 130
	local xO = 3
	local yO = 3
	local row = 5
	local col = -1
	
	local normalSpeed = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(147).value) -- 格子正常速度
	local minSlowNum = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(148).value)  -- 结束格子最小数
	local maxSlowNum = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(149).value)  -- 结束格子最大数
	local minTotalMoveNum = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(150).value) -- 总格子移动数量最小数
	local maxTotalMoveNum = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(151).value) -- 总格子移动数量最大数
	self.addSpeedNum = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(146).value) -- 加速格子数
	
	self.propertyId = 0
	if treasuretype == 0 then
		self.propertyId = 331300
	end
	self.awardId = awardId
	self.awardList = {}
	self.realAwardList = {} -- 界面上的20个图标
	self.realAwardNum = 20  -- 界面上的图标数量
	self.index = 0
	self.cell = {}   
	self.elapse = 0     
	self.curAwardIndex = math.random(1, 20) -- 当前光标所在item
	self.startIndex = self.curAwardIndex -- 开始位置
	self.moveNum = 1       -- 记录已经移动的格子数量
	self.tTime = 0      
	self.speed = 0         -- 正常速度
	self.addSpeed = 120    -- 开始加速度
	self.slowSpeed = 120   -- 最后减速度
	self.laseTime = 0 -- 记录之前格子移动的时间（已经移动的所有格子）
	self.slowNum = math.random(minSlowNum, maxSlowNum)                -- 最后减速的格子数
	self.totalMoveNum = math.random(minTotalMoveNum, maxTotalMoveNum) -- 需要移动的格子总数量
	self.baseSpeed = 300 * normalSpeed -- 基本速度
	self.totalTime = 0   --  格子移动的总时间
	self.closeTime = 0
	self:totalTimeNum()
	if awardId > 100 or awardId == 0 then
		self.closeTime = 300
	else
		self.closeTime = 900
	end
	for k,v in pairs(itemIds) do
		print(k,v)
	end
	self.realAwardList = itemIds
	self:realAwardListRandomSort(self.realAwardNum) -- 打乱显示在界面上奖励的顺序
	self:changeRealAwardPos(awardId)   -- 将真实奖励位置与实际光标停留位置交换
	for i = 1, self.realAwardNum do
		if (i-1)%row == 0 then
			col = col + 1
		end
		self.cell[i] = treasureCell.CreateNewDlg(self.list)
		self.cell[i]:GetWindow():setPosition(CEGUI.UVector2(CEGUI.UDim( 0, (i-1)%row*width + xO ), CEGUI.UDim(0,  col*height+yO  )))
		self.cell[i]:GetWindow():setID( i )
		self.cell[i]:reloadDataById(self.realAwardList[i])
	end
	self.cell[self.startIndex]:setBackVisible(true)
end
-- 打乱显示在界面上奖励的顺序
function treasureChosedDlg:realAwardListRandomSort( num )
	local N = num
	for i = 1, N do
		local j = math.random(N-i+1)+i-1
		self.realAwardList[i], self.realAwardList[j] = self.realAwardList[j], self.realAwardList[i]
	end
end
-- 将真实奖励位置与实际光标停留位置交换
function treasureChosedDlg:changeRealAwardPos( awardId )
	local tmp
	for i = 1, self.realAwardNum do
		if self.realAwardList[i] == awardId then
			tmp = i
		end
	end
	local realIndex = math.floor((self.totalMoveNum + self.startIndex - 1) % 20)
	if realIndex == 0 then
		realIndex = 20
	end
	self.realAwardList[realIndex], self.realAwardList[tmp] = self.realAwardList[tmp], self.realAwardList[realIndex]
end
-- 计算加速减速增加的时间
function treasureChosedDlg:addTime( num )
	local totalNum = 0
	if num <= 0 then
		return
	end
	for i = 1, num do
		totalNum = totalNum + i 
	end
	return totalNum
end
-- 计算格子移动总时间
function treasureChosedDlg:totalTimeNum()
	self.totalTime = self.baseSpeed * self.totalMoveNum + self.addSpeed * self:addTime(self.addSpeedNum) + self.slowSpeed * self:addTime(self.slowNum)
end

function treasureChosedDlg:update(delta)
	self.elapse = self.elapse + delta
	if self.elapse < self.totalTime then -- 小于总时间
		self.tTime = self.elapse
		if self.moveNum < self.addSpeedNum+1 then -- 前几个加速格子
			self.speed = (self.addSpeedNum+1 - self.moveNum)*self.addSpeed + self.baseSpeed
		elseif self.moveNum > self.totalMoveNum - self.slowNum then -- 后几个减速格子
			self.speed = (self.moveNum - (self.totalMoveNum - self.slowNum))*self.slowSpeed + self.baseSpeed
		else
			self.speed = self.baseSpeed   -- 中间匀速的格子
		end
		self.tTime = self.elapse - self.laseTime
		if self.tTime > self.speed then  
			if self.cell[self.curAwardIndex] then
				self.cell[self.curAwardIndex]:setBackVisible(false) --将前一个格子设置背景不可见
			end
			self.curAwardIndex = self.curAwardIndex + 1
			self.moveNum = self.moveNum + 1
			if self.curAwardIndex > self.realAwardNum then  
				self.curAwardIndex = 1   -- 重置格子标记
			end
			if self.cell[self.curAwardIndex] then
				self.cell[self.curAwardIndex]:setBackVisible(true)
			end
			self.laseTime = self.laseTime + self.speed
			
			if self.moveNum == self.totalMoveNum then  -- 转完将ok按钮置亮
				self.btnOk:setEnabled(true)
			end
		end
	elseif self.elapse > self.totalTime + self.closeTime then
		treasureChosedDlg.HandleBtnOkClicked()
	end
end

return treasureChosedDlg
