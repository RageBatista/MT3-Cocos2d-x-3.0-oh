require "utils.mhsdutils"
require "logic.dialog"

HookManager = {}
HookManager.__index = HookManager

local _instance;
function HookManager.getInstance()
	LogInfo("enter get HookManager instance")
    if not _instance then
        _instance = HookManager:new()
    end
    
    return _instance
end

function HookManager.getInstanceNotCreate()
    return _instance
end

function HookManager.Destroy()
	if _instance then 
		LogInfo("destroy HookManager")
		gGetRoleItemManager():RemoveLuaItemNumChangeNotify(_instance.m_hItemNumChangeNotify)
		_instance = nil
	end
end


function HookManager.getInstanceAndUpdate()
	LogInfo("HookManager.getInstanceExistAndUpdate")
		
	if not _instance then
        _instance = HookManager:new()
    end
    return _instance

end

------------------- private: -----------------------------------

function HookManager:new()
    local self = {}
	setmetatable(self, HookManager)
	self:Init()

    	return self
end

function HookManager:Init()
	LogInfo("HookManager Init")

	self.m_hookData = {}
	self.m_skillData = {}
	
	self.m_nLevelMapID = 0

end

function HookManager:GetLevelMapID()
	local data = gGetDataManager():GetMainCharacterData()
	local level = data:GetValue(1230);
	local maplist =  self:GetMapChooseTotalMapID()
	for i , v in pairs( maplist ) do 
		
		local nMapID = v
		local mapconfig = BeanConfigManager.getInstance():GetTableByName("map.cworldmapconfig"):getRecorder(nMapID)
		local minLevel = mapconfig.LevelLimitMin
		local maxlevel = mapconfig.LevelLimitMax
		if  level < maxlevel and level > minLevel or level == maxlevel or level == minLevel then
			self.m_nLevelMapID = nMapID
			return self.m_nLevelMapID	
		end
	end
end


function HookManager:SetHookDataSrv( list )
	self.m_hookData = list
end

function HookManager:GetHookData()
	
	return self.m_hookData
end

function HookManager:SetSkillDataSrv( list )
	self.m_skillData = list
end

function HookManager:GetSkillData()
	return self.m_skillData
end

function HookManager:GetMapChooseTotalMapID()
	local ids = std.vector_int_()
	local num = BeanConfigManager.getInstance():GetTableByName("map.cworldmapconfig"):getAllID()
	local mapIDList = {}
	for _, v in pairs(num) do
		local mapconfig = BeanConfigManager.getInstance():GetTableByName("map.cworldmapconfig"):getRecorder(v)
		local sonMapStr = mapconfig.sonmapid
		if sonMapStr ~= "0" then
			local sonMapID = HookManager.GetSubMapIDByString(sonMapStr)
			for index , id in pairs( sonMapID ) do
				table.insert(mapIDList, tonumber(id))				
			end
		end
	end	
	return mapIDList
end

function HookManager.GetSubMapIDByString(strSubMaps)
	local sub_str_tab = {};
	local str = strSubMaps;
	while (true) do 
		local pos = string.find(str, ",");
		if not pos then
			sub_str_tab[#sub_str_tab + 1] = str;
			break;
		end
		local sub_str = string.sub(str, 1, pos - 1);
		sub_str_tab[#sub_str_tab + 1] = sub_str;
		str = string.sub(str, pos + 1, #str);
	end
	return sub_str_tab;
end



return HookManager
