require "utils.tableutil"
CRequestTeamMatchList = {}
CRequestTeamMatchList.__index = CRequestTeamMatchList



CRequestTeamMatchList.PROTOCOL_TYPE = 794509

function CRequestTeamMatchList.Create()
	print("enter CRequestTeamMatchList create")
	return CRequestTeamMatchList:new()
end
function CRequestTeamMatchList:new()
	local self = {}
	setmetatable(self, CRequestTeamMatchList)
	self.type = self.PROTOCOL_TYPE
	self.targetid = 0
	self.startteamid = 0
	self.num = 0

	return self
end
function CRequestTeamMatchList:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CRequestTeamMatchList:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.targetid)
	_os_:marshal_int64(self.startteamid)
	_os_:marshal_int32(self.num)
	return _os_
end

function CRequestTeamMatchList:unmarshal(_os_)
	self.targetid = _os_:unmarshal_int32()
	self.startteamid = _os_:unmarshal_int64()
	self.num = _os_:unmarshal_int32()
	return _os_
end

return CRequestTeamMatchList
