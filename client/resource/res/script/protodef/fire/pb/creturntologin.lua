require "utils.tableutil"
CReturnToLogin = {}
CReturnToLogin.__index = CReturnToLogin



CReturnToLogin.PROTOCOL_TYPE = 786482

function CReturnToLogin.Create()
	print("enter CReturnToLogin create")
	return CReturnToLogin:new()
end
function CReturnToLogin:new()
	local self = {}
	setmetatable(self, CReturnToLogin)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CReturnToLogin:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CReturnToLogin:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CReturnToLogin:unmarshal(_os_)
	return _os_
end

return CReturnToLogin
