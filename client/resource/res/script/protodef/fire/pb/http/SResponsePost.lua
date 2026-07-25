require "utils.tableutil"
SResponsePost = {}
SResponsePost.__index = SResponsePost

SResponsePost.PROTOCOL_TYPE = 800301

function SResponsePost.Create()
    print("enter SResponsePost create")
    return SResponsePost:new()
end
function SResponsePost:new()
    local self = {}
    setmetatable(self, SResponsePost)
    self.type = self.PROTOCOL_TYPE
    self.retvalue = ""
    self.dataid = 0

    return self
end
function SResponsePost:encode()
    local os = FireNet.Marshal.OctetsStream:new()
    os:compact_uint32(self.type)
    local pos = self:marshal(nil)
    os:marshal_octets(pos:getdata())
    pos:delete()
    return os
end
function SResponsePost:marshal(ostream)
    local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
    _os_:marshal_wstring(self.retvalue)
    _os_:marshal_int32(self.dataid)
    return _os_
end

function SResponsePost:unmarshal(_os_)
    ----------------unmarshal list
    self.retvalue= _os_:unmarshal_wstring(self.retvalue)
    self.dataid = _os_:unmarshal_int32()
    return _os_
end

return SResponsePost
