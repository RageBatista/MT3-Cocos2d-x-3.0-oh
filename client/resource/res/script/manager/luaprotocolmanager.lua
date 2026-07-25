require "handler.fire_pb_pet"
require "handler.fire_pb_item"
require "handler.fire_pb"
require "handler.fire_pb_fushi"
require "handler.fire_pb_npc"
require "handler.fire_pb_task"
require "handler.fire_pb_friends"
require "handler.fire_pb_battle"
require "handler.fire_pb_team"
require "handler.fire_pb_ranklist"
require "handler.fire_pb_title"
require "handler.fire_pb_skill"
require "handler.fire_pb_specialquest"
require "handler.fire_pb_buff"
require "handler.fire_pb_lock"
require "handler.fire_pb_msg"
require "handler.fire_pb_pingbi"
require "handler.fire_pb_faction"
require "handler.fire_pb_activity_common"
require "handler.fire_pb_activity_gumumijing"
require "handler.fire_pb_master"
require "handler.fire_pb_product"
require "handler.fire_pb_skill_liveskill"
require "handler.fire_pb_hook"
require "handler.fire_pb_shop"
require "handler.fire_pb_skill_particleskill"
require "handler.fire_pb_fubencodef"
require "handler.fire_pb_move"
require "handler.fire_pb_game"
require "handler.fire_pb_attr"
require "handler.fire_pb_talk"
require "handler.fire_pb_discards"
require "handler.fire_pb_cross"
require "handler.fire_pb_school"
require "handler.fire_pb_potentialfruit"


LuaProtocolManager = {}
LuaProtocolManager.__index = LuaProtocolManager

function LuaProtocolManager.Dispatch(luap)
	print("dispatch enter")
    LogInfo(string.format("[LuaProtocol] Dispatch enter type=%s size=%s hasNet=%s",
        tostring(luap and luap.type), tostring(luap and luap.data and luap.data:size()), tostring(gGetNetConnection() ~= nil)))
    if not gGetNetConnection() then
        LogInfo("[LuaProtocol] Dispatch skipped: net connection nil")
        return
    end
	LuaProtocolManager.getInstance():ProtocolRun(luap.type, luap.data)
    LogInfo(string.format("[LuaProtocol] Dispatch leave type=%s", tostring(luap and luap.type)))
end

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function LuaProtocolManager.getInstance()
    if not _instance then
        _instance = LuaProtocolManager:new()
    end

    return _instance
end

function LuaProtocolManager.removeInstance()
	_instance = nil
end

function LuaProtocolManager:new()
    local self = {}
    setmetatable(self, LuaProtocolManager)

	self.m_MapLuaProtocols = {}
    return self
end

function LuaProtocolManager:send(p)
    if not gGetNetConnection() then
        return
    end
	local _os_ = p:encode()
	print("[Lua Send Protocol] " .. p.type)
    gGetNetConnection():luasend(_os_:getdata())
    _os_:delete() -- yeqing 2016-01-12
end

function LuaProtocolManager:ProtocolRun(type, octdata)

	print("protocolrun enter type " .. type)
    LogInfo(string.format("[LuaProtocol] ProtocolRun enter type=%s dataLen=%s creator=%s",
        tostring(type), tostring(octdata and octdata:size()), tostring(self.m_MapLuaProtocols[type] ~= nil)))
	local createfunc = self.m_MapLuaProtocols[type] 
	if createfunc then 
		local lp = createfunc() 
		if lp then
            LogInfo(string.format("[LuaProtocol] ProtocolRun created type=%s hasProcess=%s", tostring(type), tostring(lp.process ~= nil)))
            if lp.process then
			    local _os_  = FireNet.Marshal.OctetsStream:new(octdata)
                LogInfo(string.format("[LuaProtocol] ProtocolRun before unmarshal type=%s", tostring(type)))
			    lp:unmarshal(_os_)
                local roleCount = nil
                if lp.roles then
                    roleCount = #lp.roles
                end
                LogInfo(string.format("[LuaProtocol] ProtocolRun after unmarshal type=%s roleCount=%s prevRole=%s",
                    tostring(type), tostring(roleCount), tostring(lp.prevloginroleid)))
                LogInfo(string.format("[LuaProtocol] ProtocolRun before process type=%s", tostring(type)))
			    lp:process()
                LogInfo(string.format("[LuaProtocol] ProtocolRun after process type=%s", tostring(type)))
                _os_:delete() -- yeqing 2016-01-12
            else
                LogErr("<Protocol Not Processed> type: " .. type)
                LogInfo(string.format("[LuaProtocol] ProtocolRun no process type=%s", tostring(type)))
            end
		end
	else
		print("lua protocol unknown: type: " .. type)
        LogInfo(string.format("[LuaProtocol] ProtocolRun unknown type=%s", tostring(type)))
	end
end

function LuaProtocolManager:RegisterLuaProtocolCreator(type, func)
	self.m_MapLuaProtocols[type] = func
    if type == 786434 or type == 786515 or type == 786516 then
        LogInfo(string.format("[LuaProtocol] Register creator type=%s func=%s", tostring(type), tostring(func)))
    end
end

function LuaProtocolManager:UnRegisterLuaProtocolCreator(type)
	self.m_MapLuaProtocols[type] = nil
end

return LuaProtocolManager
