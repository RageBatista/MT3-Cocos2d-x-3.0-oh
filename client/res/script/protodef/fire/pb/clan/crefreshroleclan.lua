require "utils.tableutil"
CRefreshRoleClan = {}
CRefreshRoleClan.__index = CRefreshRoleClan



CRefreshRoleClan.PROTOCOL_TYPE = 808518

function CRefreshRoleClan.Create()
	print("enter CRefreshRoleClan create")
	return CRefreshRoleClan:new()
end
function CRefreshRoleClan:new()
	local self = {}
	setmetatable(self, CRefreshRoleClan)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CRefreshRoleClan:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CRefreshRoleClan:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CRefreshRoleClan:unmarshal(_os_)
	return _os_
end

return CRefreshRoleClan
