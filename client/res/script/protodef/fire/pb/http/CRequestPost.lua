require "utils.tableutil"
CRequestPost = {}
CRequestPost.__index = CRequestPost

CRequestPost.PROTOCOL_TYPE = 800300

function CRequestPost.Create()
    print("enter CRequestPost create")
    return CRequestPost:new()
end
function CRequestPost:new()
    local self = {}
    setmetatable(self, CRequestPost)
    self.type = self.PROTOCOL_TYPE
    self.url = ""
    self.postdata=""
    self.dataid=0
    return self
end
function CRequestPost:encode()
    local os = FireNet.Marshal.OctetsStream:new()
    os:compact_uint32(self.type)
    local pos = self:marshal(nil)
    os:marshal_octets(pos:getdata())
    pos:delete()
    return os
end
function CRequestPost:marshal(ostream)
    local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
    _os_:marshal_wstring(self.url)
    _os_:marshal_wstring(self.postdata)
    _os_:marshal_int32(self.dataid)
    return _os_
end

function CRequestPost:unmarshal(_os_)
    self.url = _os_:unmarshal_wstring(self.url)
    self.postdata = _os_:unmarshal_wstring(self.postdata)
    self.dataid = _os_:unmarshal_int32()
    return _os_
end

return CRequestPost
