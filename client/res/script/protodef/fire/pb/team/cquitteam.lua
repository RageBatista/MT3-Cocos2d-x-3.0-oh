require "utils.tableutil"
CQuitTeam = {}
CQuitTeam.__index = CQuitTeam



CQuitTeam.PROTOCOL_TYPE = 794440

function CQuitTeam.Create()
	print("enter CQuitTeam create")
	return CQuitTeam:new()
end
function CQuitTeam:new()
	local self = {}
	setmetatable(self, CQuitTeam)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CQuitTeam:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CQuitTeam:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CQuitTeam:unmarshal(_os_)
	return _os_
end

return CQuitTeam
