require "utils.tableutil"
SPingJi = {}
SPingJi.__index = SPingJi



SPingJi.PROTOCOL_TYPE = 795667

function SPingJi.Create()
	print("enter SPingJi create")
	return SPingJi:new()
end
function SPingJi:new()
	local self = {}
	setmetatable(self, SPingJi)
	self.type = self.PROTOCOL_TYPE
	self.grade = 0
	self.exp = 0

	return self
end
function SPingJi:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SPingJi:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_char(self.grade)
	_os_:marshal_int32(self.exp)
	return _os_
end

function SPingJi:unmarshal(_os_)
	self.grade = _os_:unmarshal_char()
	self.exp = _os_:unmarshal_int32()
	return _os_
end

return SPingJi
