require "utils.tableutil"
CXiLianEquip = {}
CXiLianEquip.__index = CXiLianEquip
--gs:CXiLianEquip
CXiLianEquip.PROTOCOL_TYPE = 810493

function CXiLianEquip.Create()
    return CXiLianEquip:new()
end
function CXiLianEquip:new()
    local self = {}
    setmetatable(self, CXiLianEquip)
    self.type = self.PROTOCOL_TYPE
    self.srcweaponkey = 0
    return self
end
function CXiLianEquip:encode()
    local os = FireNet.Marshal.OctetsStream:new()
    os:compact_uint32(self.type)
    local pos = self:marshal(nil)
    os:marshal_octets(pos:getdata())
    pos:delete()
    return os
end
function CXiLianEquip:marshal(ostream)
    local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
    _os_:marshal_int32(self.srcweaponkey)
    return _os_
end

function CXiLianEquip:unmarshal(_os_)
    self.srcweaponkey = _os_:unmarshal_int32()
    return _os_
end

return CXiLianEquip
