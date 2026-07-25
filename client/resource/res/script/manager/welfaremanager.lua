
stContinueLoginData = {}
stContinueLoginData.__index = stContinueLoginData

function stContinueLoginData:new()
    local self = {}
    setmetatable(self, stContinueLoginData)
    self:init()
    return self
end

function stContinueLoginData:init()
	self.isEnable       = false
	self.isDayOK        = {}    -- 3天中，哪一天的可以领
	self.isHaveUnGet    = {}    -- 是否有未领取的礼包

    self.isDayOK[0] = false
    self.isDayOK[1] = false
    self.isDayOK[2] = false

    self.isHaveUnGet[0] = false
    self.isHaveUnGet[1] = false
    self.isHaveUnGet[2] = false
end

-------------------------------------------------------------

stLeveUpData = {}
stLeveUpData.__index = stLeveUpData

function stLeveUpData:new()
    local self = {}
    setmetatable(self, stLeveUpData)
    self:init()
    return self
end

function stLeveUpData:init()
	self.isEnable           = false
	self.isHaveUnGetWelfare = {}    -- 是否可以领取对应级数的礼包
	self.isLevelOK          = {}    -- 用户等级是否满足升级礼包要求

    for i = 0, 9 do
        self.isHaveUnGetWelfare[i] = false
        self.isLevelOK[i] = false
    end
end

-------------------------------------------------------------

stCompensateData = {}
stCompensateData.__index = stCompensateData

function stCompensateData:new()
    local self = {}
    setmetatable(self, stCompensateData)
    self:init()
    return self
end

function stCompensateData:init()
	self.isEnable = false
end

-------------------------------------------------------------
    
-- 礼包类型
local MAIN_ENTRANCE     = 0
local CONTINUE_LOGIN    = 1
local LEVE_UP           = 2
local COMPENSATE        = 3

WelfareManager = {}
WelfareManager.__index = WelfareManager

local _instance

function gGetWelfareManager()
    return _instance
end

function WelfareManager.newInstance()
    if not _instance then
        _instance = WelfareManager:new()
    end
    return _instance
end

function WelfareManager.removeInstance()
	_instance = nil
end

function WelfareManager:new()
    local self = {}
    setmetatable(self, WelfareManager)

    self.m_nCount                   = 0     -- 显示的面板上可拿的礼包数目
    self.m_fNowTime                 = 0.0
    self.isCountDownEnable          = false
    self.m_IsCountChange            = false
	self.m_iDay                     = 0
    self.m_bChangeDay               = true
	self.m_bOnLineWelfareFinish     = true
	self.m_iGiftId                  = 0     -- 在线礼包ID

    -- 各种礼包的数据
	self.m_ContinusLoginData        = stContinueLoginData:new()
    self.m_CompensateData           = stCompensateData:new()
	self.m_LevelUpData              = stLeveUpData:new()

    -- 是否显示特效
    -- 0 主界面的福利按钮
    -- 1 福利面板上的连续登陆
    -- 2 福利面板上的升级
    -- 3 福利面板上的补偿
    self.m_bIsShowEffect            = {}

    -- 升级的等级数据
    self.m_nLevelData               = {}

    self.m_ContinusLoginData.isEnable = false
    self.m_LevelUpData.isEnable = false
    self.m_CompensateData.isEnable = false
    
    for i = 0, 4 do
        self.m_LevelUpData.isLevelOK[i] = false
        self.m_LevelUpData.isHaveUnGetWelfare[i] = false
        self.m_nLevelData[i] = 0
    end
    
    -- 初始化连续登陆礼包的领取状态
    for i = 0, 2 do
        self.m_ContinusLoginData.isDayOK[i] = false
        self.m_ContinusLoginData.isHaveUnGet[i] = false
    end
    
    -- 设置升级的等级数据
    for i = 0, 9 do
        self.m_nLevelData[i] = 0
    end

    -- 初始化等级列表
    self:setLevelData()
    
    -- 默认不显示特效
    for i = 0, 3 do
        self.m_bIsShowEffect[i] = false
    end

    return self
end

-------------------------------------------------------------

-- 设置礼包的数据
function WelfareManager:setContinueLoginData(_type, day)
	self.m_iDay = day
	-- 先初始化
	for i = 0, 2 do
		self.m_ContinusLoginData.isDayOK[i] = false
		self.m_ContinusLoginData.isHaveUnGet[i] = false
	end

	local isEnable = false

	-- 再设置
	for i = 0, 2 do
		self.m_ContinusLoginData.isHaveUnGet[i] = self:isGetContinueLoginWelfare(_type, i + 1)
	end
	for i = 0, day - 1 do
		self.m_ContinusLoginData.isDayOK[i] = true
		isEnable = isEnable or (self.m_ContinusLoginData.isDayOK[i] and self.m_ContinusLoginData.isHaveUnGet[i])
	end

	self.m_ContinusLoginData.isEnable = isEnable
	self:setEffectEnabel(CONTINUE_LOGIN, isEnable)
end

-- 设置礼包的数据
function WelfareManager:setLeveUpData(_type)
	local roleLevel = 0
	if gGetDataManager() then
		roleLevel = gGetDataManager():GetMainCharacterLevel()
	end

	-- 是否有可拿的礼包
	local isCanGet = false
	for i = 0, 9 do
		self.m_LevelUpData.isHaveUnGetWelfare[i] = self:isGetNowLevelWelfare(_type, i + 1)

		-- 判断等级是否能领取奖励
		self.m_LevelUpData.isLevelOK[i] = (roleLevel >= self.m_nLevelData[i]) and (self.m_nLevelData[i] > 0)

		-- 判断是否有可拿的礼包
		isCanGet = isCanGet or (self.m_LevelUpData.isHaveUnGetWelfare[i] and self.m_LevelUpData.isLevelOK[i])
	end

	self.m_LevelUpData.isEnable = isCanGet
	self:setEffectEnabel(LEVE_UP, isCanGet)
	LoginRewardManager.SetLevelUpItemID(0)
end

-- 设置礼包的数据
function WelfareManager:setCompensateData(isEnable)
	self:setEffectEnabel(COMPENSATE, isEnable)
	self.m_CompensateData.isEnable = isEnable
end

-- 获得礼包数据
function WelfareManager:getCompensateData()
	return self.m_CompensateData
end

-- 获得礼包数据
function WelfareManager:getLeveUpData()
	return self.m_LevelUpData
end

-- 获得礼包数据
function WelfareManager:getContinueLoginData()
	return self.m_ContinusLoginData
end

-- 获取升级礼包各礼包状态
function WelfareManager:getLevelUpRewardLevelOk(index)
	return self.m_LevelUpData.isLevelOK[index]
end

-- 获取升级礼包各礼包状态
function WelfareManager:getLevelUpRewardUnGet(index)
	return self.m_LevelUpData.isHaveUnGetWelfare[index]
end

-- 刷新礼包子窗口数据
function WelfareManager:refresh()
	-- 刷新礼包按钮
	LogoInfoDialog.GetInstanceRefreshAllBtn()
end

-- 删除礼包数据
function WelfareManager:cleanData()
	self.m_ContinusLoginData.isEnable = false
	self.m_LevelUpData.isEnable = false
	self.m_CompensateData.isEnable = false
end

-- 获得特效是否能用
function WelfareManager:getEffectEnabel(index)
	index = index >= 3 and 3 or index
	index = index <= 0 and 0 or index
	return self.m_bIsShowEffect[index]
end

-- 设置特效开关
function WelfareManager:setEffectEnabel(index, enable)
	index = index >= 3 and 3 or index
	index = index <= 0 and 0 or index
	self.m_bIsShowEffect[index] = enable
end

-- 升级时更新冲级礼包数据(当升级时，调用这个函数检查是否能领礼包)
function WelfareManager:onLeveUpRefreshData()
	local roleLevel = 0
	if gGetDataManager() then
		roleLevel = gGetDataManager():GetMainCharacterLevel()
	end

	local isCanGet = false -- 是否有可拿的礼包
	for i = 0, 4 do
		self.m_LevelUpData.isLevelOK[i] = (roleLevel >= self.m_nLevelData[i] and self.m_nLevelData[i] > 0)
		isCanGet = isCanGet or (self.m_LevelUpData.isHaveUnGetWelfare[i] and self.m_LevelUpData.isLevelOK[i])
	end

	self.m_LevelUpData.isEnable = isCanGet
	self:setEffectEnabel(LEVE_UP, isCanGet)

	-- 修改提示小数字
	self:setCountNumber()

    -- 刷新界面
	self:refresh()
end

function WelfareManager:setCountDownEnable(enable)
	self.isCountDownEnable = enable
end

function WelfareManager:setBeginTime(elapse)
	self.m_fNowTime = elapse
	self.isCountDownEnable = elapse > 0
end

function WelfareManager:run(delta)
    local elapse = delta / 1000.0

	if self.isCountDownEnable then
		self.m_fNowTime = self.m_fNowTime - elapse
		if self.m_fNowTime > 0 then
			MTG_OnLineWelfareDlg.RemoteSetTime(self.m_fNowTime)
			MTG_OnLineWelfareDlg.RemoteSetBtnEnable(false)
		else
			self.m_fNowTime = 0
			self.isCountDownEnable = false

			MTG_OnLineWelfareDlg.RemoteSetTime(self.m_fNowTime)
			MTG_OnLineWelfareDlg.RemoteSetBtnEnable(true)
		end
	end

	if gGetGameApplication():IsZerosHours() then
		if not self.m_bChangeDay then
			if self.m_iDay >= 3 then
				self.m_iDay = 3
			else
				self.m_iDay = self.m_iDay + 1
			end
            self:setContinueLoginData(0, self.m_iDay)

			self:setCountNumber()
			self:refresh()
			self.m_bChangeDay = not self.m_bChangeDay
		end
	elseif self.m_bChangeDay then
		self.m_bChangeDay = not self.m_bChangeDay
	end
end

-- 设置小数字提示
function WelfareManager:setCount(x)
	self.m_nCount = x >= 4 and 4 or x
	self.m_nCount = x <= 0 and 0 or x
	self.m_IsCountChange = true

	-- 设置主福利窗口特效开关
	self:setEffectEnabel(MAIN_ENTRANCE, self.m_nCount > 0)
end

-- 获得主界面上需要显示的数字
function WelfareManager:getCount()
	return self.m_nCount
end

-- 修改主界面上需要显示的数字
function WelfareManager:setCountNumber()
	local cnt = 0
	cnt = cnt + (self:getContinueLoginData().isEnable and 1 or 0)
	cnt = cnt + (self:getLeveUpData().isEnable and 1 or 0)
	cnt = cnt + (self:getCompensateData().isEnable and 1 or 0)
	self:setCount(cnt)
end

function WelfareManager:setOnLineWelfareFinish(b)
	self.m_bOnLineWelfareFinish = b
end

function WelfareManager:getOnLineWelfareFinish()
	return self.m_bOnLineWelfareFinish
end

function WelfareManager:setGiftId(id)
	self.m_iGiftId = id
end

function WelfareManager:getGiftId()
	return self.m_iGiftId
end

-- 计算连续登陆时，可以拿哪一天的礼包
function WelfareManager:isGetContinueLoginWelfare(x, flag)
	return bit.band(bit.brshift(x, flag), 1) == 0
end

-- 计算升级礼包里每一级是否能拿礼包
function WelfareManager:isGetNowLevelWelfare(x, level)
	return bit.band(bit.brshift(x, level), 1) == 0
end

-- 设定一些需要检查的等级，当到达等级时，可以领礼包
function WelfareManager:setLevelData()
	local nbegin = 1
	for i = 0, 9 do
		self.m_nLevelData[i] = nbegin
		nbegin = nbegin + 10
		nbegin = (nbegin / 10) * 10
	end
end

return WelfareManager
