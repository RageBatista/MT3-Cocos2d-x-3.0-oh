require "utils.tableutil"
CAcceptToTeam = {}
CAcceptToTeam.__index = CAcceptToTeam



CAcceptToTeam.PROTOCOL_TYPE = 787235

function CAcceptToTeam.Create()
	print("enter CAcceptToTeam create")
	return CAcceptToTeam:new()
end
function CAcceptToTeam:new()
	local self = {}
	setmetatable(self, CAcceptToTeam)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0
	self.accept = 0

	return self
end
function CAcceptToTeam:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CAcceptToTeam:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	_os_:marshal_int32(self.accept)
	return _os_
end

function CAcceptToTeam:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	self.accept = _os_:unmarshal_int32()
	return _os_
end

return CAcceptToTeam
