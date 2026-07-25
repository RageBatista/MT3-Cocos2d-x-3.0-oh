require "utils.tableutil"
SYiChuShiYong = {}
SYiChuShiYong.__index = SYiChuShiYong



SYiChuShiYong.PROTOCOL_TYPE = 800015

function SYiChuShiYong.Create()
	print("enter CChangeSchool create")
	return SYiChuShiYong:new()
end
function SYiChuShiYong:new()
	local self = {}
	setmetatable(self, SYiChuShiYong)
	self.type = self.PROTOCOL_TYPE
	self.shape = 0
	return self
end
function SYiChuShiYong:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SYiChuShiYong:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.shape)
	return _os_
end

function SYiChuShiYong:unmarshal(_os_)
	self.shape = _os_:unmarshal_int32()
	return _os_
end

return SYiChuShiYong
