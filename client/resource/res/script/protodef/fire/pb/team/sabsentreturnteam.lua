require "utils.tableutil"
SAbsentReturnTeam = {}
SAbsentReturnTeam.__index = SAbsentReturnTeam



SAbsentReturnTeam.PROTOCOL_TYPE = 794531

function SAbsentReturnTeam.Create()
	print("enter SAbsentReturnTeam create")
	return SAbsentReturnTeam:new()
end
function SAbsentReturnTeam:new()
	local self = {}
	setmetatable(self, SAbsentReturnTeam)
	self.type = self.PROTOCOL_TYPE
	self.ret = 0

	return self
end
function SAbsentReturnTeam:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SAbsentReturnTeam:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_char(self.ret)
	return _os_
end

function SAbsentReturnTeam:unmarshal(_os_)
	self.ret = _os_:unmarshal_char()
	return _os_
end

return SAbsentReturnTeam
