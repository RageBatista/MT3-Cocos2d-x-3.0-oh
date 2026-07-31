require "utils.tableutil"
CReg = {}
CReg.__index = CReg



CReg.PROTOCOL_TYPE = 810534

function CReg.Create()
	print("enter CReg create")
	return CReg:new()
end
function CReg:new()
	local self = {}
	setmetatable(self, CReg)
	self.type = self.PROTOCOL_TYPE
	self.month = 0

	return self
end
function CReg:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CReg:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.month)
	return _os_
end

function CReg:unmarshal(_os_)
	self.month = _os_:unmarshal_int32()
	return _os_
end

return CReg
