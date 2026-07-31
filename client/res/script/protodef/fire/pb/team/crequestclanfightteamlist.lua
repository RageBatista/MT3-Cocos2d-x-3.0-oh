require "utils.tableutil"
CRequestClanFightTeamList = {}
CRequestClanFightTeamList.__index = CRequestClanFightTeamList



CRequestClanFightTeamList.PROTOCOL_TYPE = 794557

function CRequestClanFightTeamList.Create()
	print("enter CRequestClanFightTeamList create")
	return CRequestClanFightTeamList:new()
end
function CRequestClanFightTeamList:new()
	local self = {}
	setmetatable(self, CRequestClanFightTeamList)
	self.type = self.PROTOCOL_TYPE
	self.isfresh = 0
	self.start = 0
	self.num = 0

	return self
end
function CRequestClanFightTeamList:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CRequestClanFightTeamList:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.isfresh)
	_os_:marshal_int64(self.start)
	_os_:marshal_int32(self.num)
	return _os_
end

function CRequestClanFightTeamList:unmarshal(_os_)
	self.isfresh = _os_:unmarshal_int32()
	self.start = _os_:unmarshal_int64()
	self.num = _os_:unmarshal_int32()
	return _os_
end

return CRequestClanFightTeamList
