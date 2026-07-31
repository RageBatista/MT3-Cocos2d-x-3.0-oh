require "utils.tableutil"
CGetCheckCode = {}
CGetCheckCode.__index = CGetCheckCode



CGetCheckCode.PROTOCOL_TYPE = 786553

function CGetCheckCode.Create()
	print("enter CGetCheckCode create")
	return CGetCheckCode:new()
end
function CGetCheckCode:new()
	local self = {}
	setmetatable(self, CGetCheckCode)
	self.type = self.PROTOCOL_TYPE
	self.tel = 0

	return self
end
function CGetCheckCode:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CGetCheckCode:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.tel)
	return _os_
end

function CGetCheckCode:unmarshal(_os_)
	self.tel = _os_:unmarshal_int64()
	return _os_
end

return CGetCheckCode
