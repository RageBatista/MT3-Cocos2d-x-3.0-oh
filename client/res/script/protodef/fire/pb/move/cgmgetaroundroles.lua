require "utils.tableutil"
CGMGetAroundRoles = {}
CGMGetAroundRoles.__index = CGMGetAroundRoles



CGMGetAroundRoles.PROTOCOL_TYPE = 790469

function CGMGetAroundRoles.Create()
	print("enter CGMGetAroundRoles create")
	return CGMGetAroundRoles:new()
end
function CGMGetAroundRoles:new()
	local self = {}
	setmetatable(self, CGMGetAroundRoles)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CGMGetAroundRoles:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CGMGetAroundRoles:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CGMGetAroundRoles:unmarshal(_os_)
	return _os_
end

return CGMGetAroundRoles
