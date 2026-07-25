require "utils.tableutil"
SCleanMainPack = {}
SCleanMainPack.__index = SCleanMainPack

SCleanMainPack.PROTOCOL_TYPE = 787481

function SCleanMainPack.Create()
    print("enter SCleanMainPack create")
    return SCleanMainPack:new()
end
function SCleanMainPack:new()
    local self = {}
    setmetatable(self, SCleanMainPack)
    self.type = self.PROTOCOL_TYPE
    return self
end
function SCleanMainPack:encode()
    local os = FireNet.Marshal.OctetsStream:new()
    os:compact_uint32(self.type)
    local pos = self:marshal(nil)
    os:marshal_octets(pos:getdata())
    pos:delete()
    return os
end
function SCleanMainPack:marshal(ostream)
    local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
    return _os_
end

function SCleanMainPack:unmarshal(_os_)
    return _os_
end

return SCleanMainPack
