PointCardServerManager = {}
PointCardServerManager.__index = PointCardServerManager


------------------- public: -----------------------------------
--点卡服务器数据管理
local _instance;
function PointCardServerManager.getInstance()
	LogInfo("enter get PointCardServerManager instance")
	if not _instance then
		_instance = PointCardServerManager:new()
	end
	
	return _instance
end

function PointCardServerManager.getInstanceNotCreate()
	return _instance
end

function PointCardServerManager.Destroy()
	if _instance then
		_instance = nil
	end
end

function PointCardServerManager:new()
	local self = {}
	setmetatable(self, PointCardServerManager)

    self.m_isPointCardServer = false
    self.m_isTodayNotFree = false

    self.m_SpotBuys = {}
    self.m_SpotSells = {}
    self.m_RoleBuys = {}
    self.m_RoleSells = {}
    self.m_Records = {}

    self.m_OpenFunctionList = {}
    self.nnDingyueOverTime = 0
    self.bDingyueOpen = true

	return self
end

return PointCardServerManager
