require "utils.tableutil"
CForceDelPassword = {}
CForceDelPassword.__index = CForceDelPassword



CForceDelPassword.PROTOCOL_TYPE = 786572

function CForceDelPassword.Create()
	print("enter CForceDelPassword create")
	return CForceDelPassword:new()
end
function CForceDelPassword:new()
	local self = {}
	setmetatable(self, CForceDelPassword)
	self.type = self.PROTOCOL_TYPE
	self.code = "" 

	return self
end
function CForceDelPassword:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CForceDelPassword:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_wstring(self.code)
	return _os_
end

function CForceDelPassword:unmarshal(_os_)
	self.code = _os_:unmarshal_wstring(self.code)
	return _os_
end

return CForceDelPassword
