require "utils.tableutil"
CRequestTeamMatch = {}
CRequestTeamMatch.__index = CRequestTeamMatch



CRequestTeamMatch.PROTOCOL_TYPE = 794494

function CRequestTeamMatch.Create()
	print("enter CRequestTeamMatch create")
	return CRequestTeamMatch:new()
end
function CRequestTeamMatch:new()
	local self = {}
	setmetatable(self, CRequestTeamMatch)
	self.type = self.PROTOCOL_TYPE
	self.typematch = 0
	self.targetid = 0
	self.levelmin = 0
	self.levelmax = 0

	return self
end
function CRequestTeamMatch:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CRequestTeamMatch:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.typematch)
	_os_:marshal_int32(self.targetid)
	_os_:marshal_int32(self.levelmin)
	_os_:marshal_int32(self.levelmax)
	return _os_
end

function CRequestTeamMatch:unmarshal(_os_)
	self.typematch = _os_:unmarshal_int32()
	self.targetid = _os_:unmarshal_int32()
	self.levelmin = _os_:unmarshal_int32()
	self.levelmax = _os_:unmarshal_int32()
	return _os_
end

return CRequestTeamMatch
