require "utils.tableutil"
CRankGetInfo = {}
CRankGetInfo.__index = CRankGetInfo



CRankGetInfo.PROTOCOL_TYPE = 810256

function CRankGetInfo.Create()
	print("enter CRankGetInfo create")
	return CRankGetInfo:new()
end
function CRankGetInfo:new()
	local self = {}
	setmetatable(self, CRankGetInfo)
	self.type = self.PROTOCOL_TYPE
	self.ranktype = 0
	self.rank = 0
	self.id = 0

	return self
end
function CRankGetInfo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CRankGetInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.ranktype)
	_os_:marshal_int32(self.rank)
	_os_:marshal_int64(self.id)
	return _os_
end

function CRankGetInfo:unmarshal(_os_)
	self.ranktype = _os_:unmarshal_int32()
	self.rank = _os_:unmarshal_int32()
	self.id = _os_:unmarshal_int64()
	return _os_
end

return CRankGetInfo
