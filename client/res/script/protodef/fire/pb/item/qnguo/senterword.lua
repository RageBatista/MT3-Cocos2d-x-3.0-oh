SEnterWord = {}
SEnterWord.__index = SEnterWord

SEnterWord.PROTOCOL_TYPE = 810501

function SEnterWord.Create()
    return SEnterWord:new()
end

function SEnterWord:new()
    local self = {}
    setmetatable(self, SEnterWord)
    self.type = self.PROTOCOL_TYPE
    self.returnData = require "protodef.fire.pb.item.qnguo.returndata":new()
    return self
end
function SEnterWord:encode()
    local os = FireNet.Marshal.OctetsStream:new()
    os:compact_uint32(self.type)
    local pos = self:marshal(nil)
    os:marshal_octets(pos:getdata())
    pos:delete()
    return os
end
function SEnterWord:marshal(ostream)
    local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
    self.returnData:marshal(_os_)
    return _os_
end

function SEnterWord:unmarshal(_os_)
    print("SEnterWord:unmarshal>>>>>>>>>>>>>>>>>>>")
    self.returnData:unmarshal(_os_)
    return _os_
end

return SEnterWord

----------------------------------------
