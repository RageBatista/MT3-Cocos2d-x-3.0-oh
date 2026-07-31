require "utils.tableutil"
CRequestSetTeamMatchInfo = {}
CRequestSetTeamMatchInfo.__index = CRequestSetTeamMatchInfo



CRequestSetTeamMatchInfo.PROTOCOL_TYPE = 794499

function CRequestSetTeamMatchInfo.Create()
	print("enter CRequestSetTeamMatchInfo create")
	return CRequestSetTeamMatchInfo:new()
end
function CRequestSetTeamMatchInfo:new()
	local self = {}
	setmetatable(self, CRequestSetTeamMatchInfo)
	self.type = self.PROTOCOL_TYPE
	self.targetid = 0
	self.levelmin = 0
	self.levelmax = 0

	return self
end
function CRequestSetTeamMatchInfo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CRequestSetTeamMatchInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.targetid)
	_os_:marshal_int32(self.levelmin)
	_os_:marshal_int32(self.levelmax)
	return _os_
end

function CRequestSetTeamMatchInfo:unmarshal(_os_)
	self.targetid = _os_:unmarshal_int32()
	self.levelmin = _os_:unmarshal_int32()
	self.levelmax = _os_:unmarshal_int32()
	return _os_
end

return CRequestSetTeamMatchInfo
