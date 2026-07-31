require "utils.tableutil"
CHornSend = {}
CHornSend.__index = CHornSend
--gs:CUseHornReq
CHornSend.PROTOCOL_TYPE = 792500

-- 广播类型常量
CHornSend.BROADCAST_TYPE_LOCAL = 1       -- 本服广播
CHornSend.BROADCAST_TYPE_CROSS_ZONE = 2  -- 全服广播

function CHornSend.Create()
    return CHornSend:new()
end

function CHornSend:new()
    local self = {}
    setmetatable(self, CHornSend)
    self.type = self.PROTOCOL_TYPE
    self.broadcastType = 1    -- 广播类型：1=本服，2=跨服
    self.content = ""        -- 广播内容
    self.itemId = 0          -- 喇叭道具ID
    self.color = 0           -- 字体颜色
    return self
end

function CHornSend:encode()
    local os = FireNet.Marshal.OctetsStream:new()
    os:compact_uint32(self.type)
    local pos = self:marshal(nil)
    os:marshal_octets(pos:getdata())
    pos:delete()
    return os
end

function CHornSend:marshal(ostream)
    local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
    _os_:marshal_int32(self.broadcastType)
    _os_:marshal_wstring(self.content)
    _os_:marshal_int32(self.itemId)
    _os_:marshal_int32(self.color)
    return _os_
end

function CHornSend:unmarshal(_os_)
    self.broadcastType = _os_:unmarshal_int32()
    self.content = _os_:unmarshal_wstring()
    self.itemId = _os_:unmarshal_int32()
    self.color = _os_:unmarshal_int32()
    return _os_
end

return CHornSend
