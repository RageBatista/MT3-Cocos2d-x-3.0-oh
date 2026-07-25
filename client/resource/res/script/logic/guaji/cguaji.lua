require "utils.tableutil"
Cguaji = {}
Cguaji.__index = Cguaji



Cguaji.PROTOCOL_TYPE = 800001

function Cguaji.Create()
    print("enter Cguaji create")
    return Cguaji:new()
end
function Cguaji:new()
    local self = {}
    setmetatable(self, Cguaji)
    self.type = self.PROTOCOL_TYPE
    self.ready = 0
    self.leixing = {}
    return self
end
function Cguaji:encode()
    local os = FireNet.Marshal.OctetsStream:new()
    os:compact_uint32(self.type)
    local pos = self:marshal(nil)
    os:marshal_octets(pos:getdata())
    pos:delete()
    return os
end
function Cguaji:marshal(ostream)
    local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
    _os_:marshal_int32(self.ready)
    _os_:compact_uint32(TableUtil.tablelength(self.leixing))
    for k,v in ipairs(self.leixing) do
        ----------------marshal bean
        _os_:marshal_int32(v)
    end

    return _os_
end

function Cguaji:unmarshal(_os_)
    self.ready = _os_:unmarshal_int32()
    local sizeof_things=0,_os_null_things
    _os_null_things, sizeof_things = _os_: uncompact_uint32(sizeof_things)
    for k = 1,sizeof_things do
        ----------------unmarshal bean
        self.leixing[k]=SubmitUnit:new()

        self.leixing[k]:unmarshal(_os_)

    end

    return _os_
end

return Cguaji
