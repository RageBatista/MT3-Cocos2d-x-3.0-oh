require "utils.tableutil"
Sguaji = {}
Sguaji.__index = Sguaji



Sguaji.PROTOCOL_TYPE = 800002

function Sguaji.Create()
    print("enter Sguaji create")
    return Sguaji:new()
end
function Sguaji:new()
    local self = {}
    setmetatable(self, Sguaji)
    self.type = self.PROTOCOL_TYPE
    self.guanbi = 0

    return self
end
function Sguaji:encode()
    local os = FireNet.Marshal.OctetsStream:new()
    os:compact_uint32(self.type)
    local pos = self:marshal(nil)
    os:marshal_octets(pos:getdata())
    pos:delete()
    return os
end
function Sguaji:marshal(ostream)
    local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
    _os_:marshal_int32(self.guanbi)
    return _os_
end

function Sguaji:unmarshal(_os_)
    self.guanbi = _os_:unmarshal_int32()
    return _os_
end

return Sguaji
