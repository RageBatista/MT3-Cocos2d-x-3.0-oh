require "utils.tableutil"
SStopTeamMatch = {}
SStopTeamMatch.__index = SStopTeamMatch



SStopTeamMatch.PROTOCOL_TYPE = 794497

function SStopTeamMatch.Create()
	print("enter SStopTeamMatch create")
	return SStopTeamMatch:new()
end
function SStopTeamMatch:new()
	local self = {}
	setmetatable(self, SStopTeamMatch)
	self.type = self.PROTOCOL_TYPE
	return self
end
function SStopTeamMatch:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SStopTeamMatch:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function SStopTeamMatch:unmarshal(_os_)
	return _os_
end

return SStopTeamMatch
