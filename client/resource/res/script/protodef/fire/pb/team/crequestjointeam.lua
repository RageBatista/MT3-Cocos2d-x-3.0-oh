require "utils.tableutil"
CRequestJoinTeam = {}
CRequestJoinTeam.__index = CRequestJoinTeam



CRequestJoinTeam.PROTOCOL_TYPE = 794449

function CRequestJoinTeam.Create()
	print("enter CRequestJoinTeam create")
	return CRequestJoinTeam:new()
end
function CRequestJoinTeam:new()
	local self = {}
	setmetatable(self, CRequestJoinTeam)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0

	return self
end
function CRequestJoinTeam:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CRequestJoinTeam:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	return _os_
end

function CRequestJoinTeam:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	return _os_
end

return CRequestJoinTeam
