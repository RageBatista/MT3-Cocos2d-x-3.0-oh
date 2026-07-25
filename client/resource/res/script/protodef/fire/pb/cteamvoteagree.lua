require "utils.tableutil"
CTeamVoteAgree = {}
CTeamVoteAgree.__index = CTeamVoteAgree



CTeamVoteAgree.PROTOCOL_TYPE = 786525

function CTeamVoteAgree.Create()
	print("enter CTeamVoteAgree create")
	return CTeamVoteAgree:new()
end
function CTeamVoteAgree:new()
	local self = {}
	setmetatable(self, CTeamVoteAgree)
	self.type = self.PROTOCOL_TYPE
	self.result = 0

	return self
end
function CTeamVoteAgree:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CTeamVoteAgree:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_char(self.result)
	return _os_
end

function CTeamVoteAgree:unmarshal(_os_)
	self.result = _os_:unmarshal_char()
	return _os_
end

return CTeamVoteAgree
