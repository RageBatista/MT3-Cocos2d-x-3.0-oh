require "utils.tableutil"
CCancelForceDelPassword = {}
CCancelForceDelPassword.__index = CCancelForceDelPassword



CCancelForceDelPassword.PROTOCOL_TYPE = 786574

function CCancelForceDelPassword.Create()
	print("enter CCancelForceDelPassword create")
	return CCancelForceDelPassword:new()
end
function CCancelForceDelPassword:new()
	local self = {}
	setmetatable(self, CCancelForceDelPassword)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CCancelForceDelPassword:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CCancelForceDelPassword:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CCancelForceDelPassword:unmarshal(_os_)
	return _os_
end

return CCancelForceDelPassword
