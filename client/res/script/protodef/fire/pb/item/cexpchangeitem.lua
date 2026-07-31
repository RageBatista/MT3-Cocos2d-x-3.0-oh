require "utils.tableutil"
CExpChangeItem = {}
CExpChangeItem.__index = CExpChangeItem

CExpChangeItem.PROTOCOL_TYPE = 817961

function CExpChangeItem.Create()
    print("enter CExpChangeItem create")
    return CExpChangeItem:new()
end
function CExpChangeItem:new()
    local self = {}
    setmetatable(self, CExpChangeItem)
    self.type = self.PROTOCOL_TYPE
    return self
end
function CExpChangeItem:encode()
    local os = FireNet.Marshal.OctetsStream:new()
    os:compact_uint32(self.type)
    local pos = self:marshal(nil)
    os:marshal_octets(pos:getdata())
    pos:delete()
    return os
end
function CExpChangeItem:marshal(ostream)
    local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
    return _os_
end

function CExpChangeItem:unmarshal(_os_)
    return _os_
end

return CExpChangeItem
