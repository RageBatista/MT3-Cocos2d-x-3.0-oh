require "utils.tableutil"
CRequestRankList = {}
CRequestRankList.__index = CRequestRankList



CRequestRankList.PROTOCOL_TYPE = 810233

function CRequestRankList.Create()
	print("enter CRequestRankList create")
	return CRequestRankList:new()
end
function CRequestRankList:new()
	local self = {}
	setmetatable(self, CRequestRankList)
	self.type = self.PROTOCOL_TYPE
	self.ranktype = 0
	self.page = 0

	return self
end
function CRequestRankList:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CRequestRankList:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.ranktype)
	_os_:marshal_int32(self.page)
	return _os_
end

function CRequestRankList:unmarshal(_os_)
	self.ranktype = _os_:unmarshal_int32()
	self.page = _os_:unmarshal_int32()
	return _os_
end

return CRequestRankList
