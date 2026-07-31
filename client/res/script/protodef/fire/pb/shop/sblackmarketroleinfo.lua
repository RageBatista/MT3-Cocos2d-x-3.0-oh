require "utils.tableutil"
SBlackMarketRoleInfo = {}
SBlackMarketRoleInfo.__index = SBlackMarketRoleInfo
SBlackMarketRoleInfo.PROTOCOL_TYPE = 800316
function SBlackMarketRoleInfo.Create()
    print("enter SBlackMarketRoleInfo create")
    return SBlackMarketRoleInfo:new()
end

function SBlackMarketRoleInfo:new()
    local self = {}
    setmetatable(self, SBlackMarketRoleInfo)
    self.type = self.PROTOCOL_TYPE
    self.id = 0
    self.price = 0
    self.lasttime = 0
    self.roleid = 0
    self.rolename = ""
    self.level = 0
    self.shape = 0
    self.rolecolor1 = 0
    self.rolecolor2 = 0
    self.components = {}
    return self
end

function SBlackMarketRoleInfo:encode()
    local os = FireNet.Marshal.OctetsStream:new()
    os:compact_uint32(self.type)
    local pos = self:marshal(nil)
    os:marshal_octets(pos:getdata())
    pos:delete()
    return os
end

function SBlackMarketRoleInfo:marshal(ostream)
    local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
    _os_:marshal_int32(self.id)
    _os_:marshal_int32(self.price)
    _os_:marshal_int64(self.lasttime)
    _os_:marshal_int64(self.roleid)
    _os_:marshal_wstring(self.rolename)
    _os_:marshal_int32(self.level)
    _os_:marshal_int32(self.shape)
    _os_:marshal_int32(self.rolecolor1)
    _os_:marshal_int32(self.rolecolor2)
    _os_:compact_uint32(TableUtil.tablelength(self.components))
    for k, v in pairs(self.components) do
        _os_:marshal_char(k)
        _os_:marshal_int32(v)
    end
    return _os_
end

function SBlackMarketRoleInfo:unmarshal(_os_)
    self.id = _os_:unmarshal_int32()
    self.price = _os_:unmarshal_int32()
    self.lasttime = _os_:unmarshal_int64()
    self.roleid = _os_:unmarshal_int64()
    self.rolename = _os_:unmarshal_wstring(self.rolename )
    self.level = _os_:unmarshal_int32()
    self.shape = _os_:unmarshal_int32()
    self.rolecolor1 = _os_:unmarshal_int32()
    self.rolecolor2 = _os_:unmarshal_int32()
    local sizeof_components = 0, _os_null_components
    _os_null_components, sizeof_components = _os_:uncompact_uint32(sizeof_components)   
    for k = 1, sizeof_components do
        local newkey, newvalue
        newkey = _os_:unmarshal_char()
        newvalue = _os_:unmarshal_int32()
        self.components[newkey] = newvalue
    end
    return _os_
end

return SBlackMarketRoleInfo
