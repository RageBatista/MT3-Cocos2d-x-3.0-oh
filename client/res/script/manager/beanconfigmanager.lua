
BeanConfigManager = {}
BeanConfigManager.__index = BeanConfigManager

local _instance
function BeanConfigManager.getInstance()
    if not _instance then
        _instance = BeanConfigManager:new()
    end

    return _instance
end

function BeanConfigManager.removeInstance()
	_instance = nil
end

function BeanConfigManager:Initialize(xmlpath, binpath)
	self.m_xmlPath = xmlpath
	self.m_binPath = binpath

    --preload
    self:GetTableByName("message.cstringres") --sometimes it can't get recorder during sdk login, preload it here
end


function BeanConfigManager:new()
    local self = {}
    setmetatable(self, BeanConfigManager)

	self.m_xmlPath = ""
	self.m_tableInstance = {}
    return self
end

function BeanConfigManager:MakeTableValue(tablename)
	local xmlfilename  = self.m_xmlPath .. tablename .. ".xml"
	local binfilename  = self.m_binPath .. tablename .. ".bin"
	local mod = require("tabledef." .. tablename)
	if not mod then
		print('[LUA ERROR] table name is error: '..tablename)
		LogErr('[LUA ERROR] table name is error: '..tablename)
		return
	end
	self.m_tableInstance[tablename] = mod:new()
	return self.m_tableInstance[tablename]:LoadBeanFromBinFile(binfilename)
end

function BeanConfigManager:GetTableByName(tablename) --item.itemattr --item.CItemAttr

    tablename = g_getCorrectTableFilePath(tablename)
    tablename = g_CheckSimpTableName(tablename)
	if not self.m_tableInstance[tablename] then
		self:MakeTableValue(tablename)
	end
	return self.m_tableInstance[tablename]
end

return BeanConfigManager
