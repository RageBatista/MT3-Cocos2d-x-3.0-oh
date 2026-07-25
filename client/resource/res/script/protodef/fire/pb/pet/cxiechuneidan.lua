require "utils.tableutil"
Cxiechuneidan = {}
Cxiechuneidan.__index = Cxiechuneidan

Cxiechuneidan.PROTOCOL_TYPE = 817976

function Cxiechuneidan.Create()
    print("enter Cxiechuneidan create")
    local obj = Cxiechuneidan:new()
    -- 初始化所有字段为0，避免nil
    obj.petkey = 0
    obj.idx = 0
    obj.internalid = 0
    return obj
end

function Cxiechuneidan:new()
    local self = {}
    setmetatable(self, Cxiechuneidan)
    self.type = self.PROTOCOL_TYPE
    -- 字段初始化（避免nil）
    self.petkey = 0         -- 宠物key
    self.idx = 0            -- 位置索引
    self.internalid = 0     -- 内丹ID
    return self
end

function Cxiechuneidan:encode()
    local os = FireNet.Marshal.OctetsStream:new()
    os:compact_uint32(self.type)
    local pos = self:marshal(nil)
    os:marshal_octets(pos:getdata())
    pos:delete()
    return os
end

-- 修复marshal方法：确保所有参数为数字（非nil）
function Cxiechuneidan:marshal(ostream)
    local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
    -- 为每个字段添加兜底，确保不是nil
    _os_:marshal_int32(self.petkey or 0)         -- 防止petkey为nil
    _os_:marshal_int32(self.idx or 0)            -- 防止idx为nil
    _os_:marshal_int32(self.internalid or 0)     -- 防止internalid为nil
    return _os_
end

function Cxiechuneidan:unmarshal(_os_)
    self.petkey = _os_:unmarshal_int32()
    self.idx = _os_:unmarshal_int32()
    self.internalid = _os_:unmarshal_int32()
    return _os_
end

return Cxiechuneidan