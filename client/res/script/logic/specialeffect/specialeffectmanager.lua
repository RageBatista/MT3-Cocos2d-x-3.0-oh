require "utils.tableutil"
SpecialEffectManager = {}
SpecialEffectManager.__index = SpecialEffectManager

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function SpecialEffectManager.getInstance()
	LogInfo("enter get specialeffectmanager instance")
    if not _instance then
        _instance = SpecialEffectManager:new()
    end
    
    return _instance
end

function SpecialEffectManager.getInstanceNotCreate()
    return _instance
end

function SpecialEffectManager.Destroy()
	if _instance then 
		LogInfo("destroy specialeffectmanager")
		for k,v in pairs(_instance.m_lLocationEffect) do	
			if v.effect then
				Nuclear.GetEngine():GetWorld():RemoveEffect(tolua.cast(Nuclear.GetEngine():GetWorld(), "Nuclear::IWorld"), v.effect)
			end
		end
		_instance.m_lLocationEffect = nil
		_instance.m_lScreenEffect = nil
		_instance = nil
	end
end

------------------- private: -----------------------------------

function SpecialEffectManager:new()
    local self = {}
	setmetatable(self, SpecialEffectManager)

	self.m_lScreenEffect = {}
	self.m_lLocationEffect = {}

    return self
end

function SpecialEffectManager:run(delta)
	if TableUtil.tablelength(self.m_lScreenEffect) == 0 and TableUtil.tablelength(self.m_lLocationEffect) == 0 then
		return
	end 
	
	local serverTime = gGetServerTime()	
	local time = StringCover.getTimeStruct(serverTime / 1000)
	local year = time.tm_year + 1900
	local month = time.tm_mon + 1
	local day = time.tm_mday
	local hour = time.tm_hour
	local minute = time.tm_min
	local second = time.tm_sec
	local curTime = string.format("%04d-%02d-%02d %02d:%02d:%02d", year, month, day, hour, minute, second)
	for k,v in pairs(self.m_lScreenEffect) do
		if v.starttime < curTime and v.deadline > curTime then
			v.inTime = true
		else
			v.inTime = false
		end
	end
	for k,v in pairs(self.m_lScreenEffect) do
		if v.inTime then
			v.time = v.time - delta
			if v.time < 0 then
				local cp = Nuclear.GetEngine():GetWorld():GetViewport(tolua.cast(Nuclear.GetEngine():GetWorld(), "Nuclear::IWorld"))
				Nuclear.GetEngine():GetWorld():PlayEffect(tolua.cast(Nuclear.GetEngine():GetWorld(), "Nuclear::IWorld") , MHSD_UTILS.get_effectpath(v.effectid), v.layer, (cp.left+cp.right)/2, (cp.top+cp.bottom)/2, 1, false, 2)
				v.time = v.cd
			end
		end		
	end

	local temp = {}
	for k,v in pairs(self.m_lLocationEffect) do 
		if v.starttime < curTime and v.deadline > curTime then
			if not v.effect then
				v.effect = Nuclear.GetEngine():GetWorld():SetEffect(tolua.cast(Nuclear.GetEngine():GetWorld(),"Nuclear::IWorld"), MHSD_UTILS.get_effectpath(v.effectid) , v.layer, v.xpos, v.ypos,true)
			end
		else
			if v.effect then
				Nuclear.GetEngine():GetWorld():RemoveEffect(tolua.cast(Nuclear.GetEngine():GetWorld(), "Nuclear::IWorld"), v.effect)
			end
			table.insert(temp, k)
		end
	end
	for i,v in ipairs(temp) do
		self.m_lLocationEffect[v] = nil
	end

end

function SpecialEffectManager:InitScreenEffect()

end

function SpecialEffectManager:InitLocationEffect()
	LogInfo("SpecialEffectManager InitLocationEffect")
	self.m_lLocationEffect = nil
	self.m_lLocationEffect = {}
end

return SpecialEffectManager
