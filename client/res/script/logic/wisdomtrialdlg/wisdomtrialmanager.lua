WisdomTrialDlgManager = {}
WisdomTrialDlgManager.__index = WisdomTrialDlgManager

------------------- public: -----------------------------------

local _instance;
function WisdomTrialDlgManager.getInstance()
	LogInfo("enter get WisdomTrialDlgManager instance")
	if not _instance then
		_instance = WisdomTrialDlgManager:new()
	end
	
	return _instance
end

function WisdomTrialDlgManager.getInstanceNotCreate()
	return _instance
end

function WisdomTrialDlgManager.Destroy()
	if _instance then
		_instance = nil
	end
end



function WisdomTrialDlgManager:new()
	local self = {}
	setmetatable(self, WisdomTrialDlgManager)

    self.m_Helps = {}

	return self
    
end
return WisdomTrialDlgManager
