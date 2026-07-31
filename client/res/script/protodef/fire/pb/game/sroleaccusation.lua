require "utils.tableutil"
SRoleAccusation = {}
SRoleAccusation.__index = SRoleAccusation



SRoleAccusation.PROTOCOL_TYPE = 810371

function SRoleAccusation.Create()
	print("enter SRoleAccusation create")
	return SRoleAccusation:new()
end
function SRoleAccusation:new()
	local self = {}
	setmetatable(self, SRoleAccusation)
	self.type = self.PROTOCOL_TYPE
	self.isbereported = 0

	return self
end
function SRoleAccusation:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRoleAccusation:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_char(self.isbereported)
	return _os_
end

function SRoleAccusation:unmarshal(_os_)
	self.isbereported = _os_:unmarshal_char()
	return _os_
end

return SRoleAccusation
