require "utils.tableutil"
CRoleOffline = {}
CRoleOffline.__index = CRoleOffline



CRoleOffline.PROTOCOL_TYPE = 786449

function CRoleOffline.Create()
	print("enter CRoleOffline create")
	return CRoleOffline:new()
end
function CRoleOffline:new()
	local self = {}
	setmetatable(self, CRoleOffline)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CRoleOffline:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CRoleOffline:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CRoleOffline:unmarshal(_os_)
	return _os_
end

return CRoleOffline
