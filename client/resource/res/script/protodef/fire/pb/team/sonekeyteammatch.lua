require "utils.tableutil"
SOneKeyTeamMatch = {}
SOneKeyTeamMatch.__index = SOneKeyTeamMatch



SOneKeyTeamMatch.PROTOCOL_TYPE = 794500

function SOneKeyTeamMatch.Create()
	print("enter SOneKeyTeamMatch create")
	return SOneKeyTeamMatch:new()
end
function SOneKeyTeamMatch:new()
	local self = {}
	setmetatable(self, SOneKeyTeamMatch)
	self.type = self.PROTOCOL_TYPE
	self.ret = 0

	return self
end
function SOneKeyTeamMatch:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SOneKeyTeamMatch:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.ret)
	return _os_
end

function SOneKeyTeamMatch:unmarshal(_os_)
	self.ret = _os_:unmarshal_int32()
	return _os_
end

return SOneKeyTeamMatch
