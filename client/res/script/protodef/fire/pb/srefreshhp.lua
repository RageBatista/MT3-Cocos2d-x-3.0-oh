require "utils.tableutil"
SRefreshHp = {}
SRefreshHp.__index = SRefreshHp



SRefreshHp.PROTOCOL_TYPE = 786446

function SRefreshHp.Create()
	print("enter SRefreshHp create")
	return SRefreshHp:new()
end
function SRefreshHp:new()
	local self = {}
	setmetatable(self, SRefreshHp)
	self.type = self.PROTOCOL_TYPE
	self.hp = 0

	return self
end
function SRefreshHp:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRefreshHp:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.hp)
	return _os_
end

function SRefreshHp:unmarshal(_os_)
	self.hp = _os_:unmarshal_int32()
	return _os_
end

return SRefreshHp
