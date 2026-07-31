require "utils.tableutil"
SRoleOffline = {}
SRoleOffline.__index = SRoleOffline



SRoleOffline.PROTOCOL_TYPE = 786481

function SRoleOffline.Create()
	print("enter SRoleOffline create")
	return SRoleOffline:new()
end
function SRoleOffline:new()
	local self = {}
	setmetatable(self, SRoleOffline)
	self.type = self.PROTOCOL_TYPE
	return self
end
function SRoleOffline:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRoleOffline:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function SRoleOffline:unmarshal(_os_)
	return _os_
end

return SRoleOffline
