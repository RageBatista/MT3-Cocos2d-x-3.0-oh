require "utils.tableutil"
CRequestStopTeamMatch = {}
CRequestStopTeamMatch.__index = CRequestStopTeamMatch



CRequestStopTeamMatch.PROTOCOL_TYPE = 794496

function CRequestStopTeamMatch.Create()
	print("enter CRequestStopTeamMatch create")
	return CRequestStopTeamMatch:new()
end
function CRequestStopTeamMatch:new()
	local self = {}
	setmetatable(self, CRequestStopTeamMatch)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CRequestStopTeamMatch:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CRequestStopTeamMatch:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CRequestStopTeamMatch:unmarshal(_os_)
	return _os_
end

return CRequestStopTeamMatch
