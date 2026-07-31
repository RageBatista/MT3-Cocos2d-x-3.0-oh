ReturnData = {}
ReturnData.__index = ReturnData

function ReturnData:new()
    local self = {}
    setmetatable(self, ReturnData)
    self.useqiannengguonum = 0

    return self
end

function ReturnData:marshal(ostream)
    local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
    _os_:marshal_int32(self.useqiannengguonum)
    return _os_
end

function ReturnData:unmarshal(_os_)
    print("RoleDetail:unmarshal>>>>>>>>>>>>>>>>>>>")
    self.useqiannengguonum = _os_:unmarshal_int32()
    return _os_
end

return ReturnData