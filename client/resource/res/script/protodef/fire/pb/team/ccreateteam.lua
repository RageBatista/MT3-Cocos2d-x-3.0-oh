require "utils.tableutil"
CCreateTeam = {}
CCreateTeam.__index = CCreateTeam



CCreateTeam.PROTOCOL_TYPE = 794433

function CCreateTeam.Create()
	print("enter CCreateTeam create")
	return CCreateTeam:new()
end
function CCreateTeam:new()
	local self = {}
	setmetatable(self, CCreateTeam)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CCreateTeam:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CCreateTeam:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CCreateTeam:unmarshal(_os_)
	return _os_
end

return CCreateTeam
