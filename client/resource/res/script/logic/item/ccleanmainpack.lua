require "utils.tableutil"
CCleanMainPack = {}
CCleanMainPack.__index = CCleanMainPack

CCleanMainPack.PROTOCOL_TYPE = 787480

function CCleanMainPack.Create()
    print("enter CCleanMainPack create")
    return CCleanMainPack:new()
end
function CCleanMainPack:new()
    local self = {}
    setmetatable(self, CCleanMainPack)
    self.type = self.PROTOCOL_TYPE
    return self
end
function CCleanMainPack:encode()
    local os = FireNet.Marshal.OctetsStream:new()
    os:compact_uint32(self.type)
    local pos = self:marshal(nil)
    os:marshal_octets(pos:getdata())
    pos:delete()
    return os
end
function CCleanMainPack:marshal(ostream)
    local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
    return _os_
end

function CCleanMainPack:unmarshal(_os_)
    return _os_
end

return CCleanMainPack
