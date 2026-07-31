require "utils.tableutil"
CBaiTanError = {}
CBaiTanError.__index = CBaiTanError

CBaiTanError.PROTOCOL_TYPE = 817960

function CBaiTanError.Create()
    print("enter CBaiTanError create")
    return CBaiTanError:new()
end
function CBaiTanError:new()
    local self = {}
    setmetatable(self, CBaiTanError)
    self.type = self.PROTOCOL_TYPE
    return self
end
function CBaiTanError:encode()
    local os = FireNet.Marshal.OctetsStream:new()
    os:compact_uint32(self.type)
    local pos = self:marshal(nil)
    os:marshal_octets(pos:getdata())
    pos:delete()
    return os
end
function CBaiTanError:marshal(ostream)
    local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
    return _os_
end

function CBaiTanError:unmarshal(_os_)
    return _os_
end

return CBaiTanError
