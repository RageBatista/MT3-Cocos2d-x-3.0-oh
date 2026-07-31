require "utils.tableutil"
COneKeyTeamMatch = {}
COneKeyTeamMatch.__index = COneKeyTeamMatch



COneKeyTeamMatch.PROTOCOL_TYPE = 794498

function COneKeyTeamMatch.Create()
	print("enter COneKeyTeamMatch create")
	return COneKeyTeamMatch:new()
end
function COneKeyTeamMatch:new()
	local self = {}
	setmetatable(self, COneKeyTeamMatch)
	self.type = self.PROTOCOL_TYPE
	self.channeltype = 0
	self.text = "" 

	return self
end
function COneKeyTeamMatch:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function COneKeyTeamMatch:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.channeltype)
	_os_:marshal_wstring(self.text)
	return _os_
end

function COneKeyTeamMatch:unmarshal(_os_)
	self.channeltype = _os_:unmarshal_int32()
	self.text = _os_:unmarshal_wstring(self.text)
	return _os_
end

return COneKeyTeamMatch
