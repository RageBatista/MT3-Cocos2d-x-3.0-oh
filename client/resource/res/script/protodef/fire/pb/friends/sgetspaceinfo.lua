require "utils.tableutil"
SGetSpaceInfo = {}
SGetSpaceInfo.__index = SGetSpaceInfo



SGetSpaceInfo.PROTOCOL_TYPE = 806640

function SGetSpaceInfo.Create()
	print("enter SGetSpaceInfo create")
	return SGetSpaceInfo:new()
end
function SGetSpaceInfo:new()
	local self = {}
	setmetatable(self, SGetSpaceInfo)
	self.type = self.PROTOCOL_TYPE
	self.giftnum = 0
	self.popularity = 0
	self.revnum = 0

	return self
end
function SGetSpaceInfo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SGetSpaceInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.giftnum)
	_os_:marshal_int32(self.popularity)
	_os_:marshal_int32(self.revnum)
	return _os_
end

function SGetSpaceInfo:unmarshal(_os_)
	self.giftnum = _os_:unmarshal_int32()
	self.popularity = _os_:unmarshal_int32()
	self.revnum = _os_:unmarshal_int32()
	return _os_
end

return SGetSpaceInfo
