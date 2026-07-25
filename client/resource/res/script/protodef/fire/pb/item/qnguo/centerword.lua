require "utils.tableutil"
CEnterWord = {}
CEnterWord.__index = CEnterWord
--gs:CEnterWord
CEnterWord.PROTOCOL_TYPE = 810500

function CEnterWord.Create()
    return CEnterWord:new()
end
function CEnterWord:new()
    local self = {}
    setmetatable(self, CEnterWord)
    self.type = self.PROTOCOL_TYPE
    return self
end
function CEnterWord:encode()
    local os = FireNet.Marshal.OctetsStream:new()
    os:compact_uint32(self.type)
    local pos = self:marshal(nil)
    os:marshal_octets(pos:getdata())
    pos:delete()
    return os
end
function CEnterWord:marshal(ostream)
    local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
    return _os_
end

function CEnterWord:unmarshal(_os_)
    self.srcweaponkey = _os_:unmarshal_int32()
    return _os_
end

return CEnterWord
