require "utils.tableutil"
COneKeyApplyTeamInfo = {}
COneKeyApplyTeamInfo.__index = COneKeyApplyTeamInfo



COneKeyApplyTeamInfo.PROTOCOL_TYPE = 794517

function COneKeyApplyTeamInfo.Create()
	print("enter COneKeyApplyTeamInfo create")
	return COneKeyApplyTeamInfo:new()
end
function COneKeyApplyTeamInfo:new()
	local self = {}
	setmetatable(self, COneKeyApplyTeamInfo)
	self.type = self.PROTOCOL_TYPE
	self.teamid = 0

	return self
end
function COneKeyApplyTeamInfo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function COneKeyApplyTeamInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.teamid)
	return _os_
end

function COneKeyApplyTeamInfo:unmarshal(_os_)
	self.teamid = _os_:unmarshal_int64()
	return _os_
end

return COneKeyApplyTeamInfo
