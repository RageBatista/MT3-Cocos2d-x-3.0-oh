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

LuaProtocolManager = {}
LuaProtocolManager.__index = LuaProtocolManager

function LuaProtocolManager.Dispatch(luap)
    print("dispatch enter")
    if not gGetNetConnection() then
        return
    end
    LuaProtocolManager.getInstance():ProtocolRun(luap.type, luap.data)
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
    --print("protocolrun enter type " .. type.." octdata"..tostring(octdata))
    print("protocolrun enter type " .. type)
    local createfunc = self.m_MapLuaProtocols[type]
    if createfunc then
        local lp = createfunc()
        if lp then
            if lp.process then
                local _os_ = FireNet.Marshal.OctetsStream:new(octdata)
                lp:unmarshal(_os_)
                lp:process()
                _os_:delete() -- yeqing 2016-01-12
            else
                LogErr("<Protocol Not Processed> type: " .. type)
            end
        end
    else
        print("lua protocol unknown: type: " .. type)
    end
end

function LuaProtocolManager:RegisterLuaProtocolCreator(type, func)
    self.m_MapLuaProtocols[type] = func
end

function LuaProtocolManager:UnRegisterLuaProtocolCreator(type)
    self.m_MapLuaProtocols[type] = nil
end

return LuaProtocolManager
