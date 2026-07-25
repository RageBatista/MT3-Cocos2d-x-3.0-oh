require "utils.tableutil"
CAbsentReturnTeam = {}
CAbsentReturnTeam.__index = CAbsentReturnTeam



CAbsentReturnTeam.PROTOCOL_TYPE = 794441

function CAbsentReturnTeam.Create()
	print("enter CAbsentReturnTeam create")
	return CAbsentReturnTeam:new()
end
function CAbsentReturnTeam:new()
	local self = {}
	setmetatable(self, CAbsentReturnTeam)
	self.type = self.PROTOCOL_TYPE
	self.absent = 0

	return self
end
function CAbsentReturnTeam:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CAbsentReturnTeam:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_char(self.absent)
	return _os_
end

function CAbsentReturnTeam:unmarshal(_os_)
	self.absent = _os_:unmarshal_char()
	return _os_
end

return CAbsentReturnTeam
