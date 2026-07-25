require "utils.tableutil"
SXiLianEquip = {}
SXiLianEquip.__index = SXiLianEquip

SXiLianEquip.PROTOCOL_TYPE = 810494

function SXiLianEquip.Create()
    return SXiLianEquip:new()
end
function SXiLianEquip:new()
    local self = {}
    setmetatable(self, SXiLianEquip)
    self.type = self.PROTOCOL_TYPE
    return self
end
function SXiLianEquip:encode()
    local os = FireNet.Marshal.OctetsStream:new()
    os:compact_uint32(self.type)
    local pos = self:marshal(nil)
    os:marshal_octets(pos:getdata())
    pos:delete()
    return os
end
function SXiLianEquip:marshal(ostream)
    local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
    return _os_
end

function SXiLianEquip:unmarshal(_os_)
    return _os_
end

return SXiLianEquip
