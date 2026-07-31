require "utils.tableutil"
SGetXshSpaceInfo = {}
SGetXshSpaceInfo.__index = SGetXshSpaceInfo



SGetXshSpaceInfo.PROTOCOL_TYPE = 806652

function SGetXshSpaceInfo.Create()
	print("enter SGetXshSpaceInfo create")
	return SGetXshSpaceInfo:new()
end
function SGetXshSpaceInfo:new()
	local self = {}
	setmetatable(self, SGetXshSpaceInfo)
	self.type = self.PROTOCOL_TYPE
	self.giftnum = 0
	self.popularity = 0
	self.revnum = 0

	return self
end
function SGetXshSpaceInfo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SGetXshSpaceInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.giftnum)
	_os_:marshal_int32(self.popularity)
	_os_:marshal_int32(self.revnum)
	return _os_
end

function SGetXshSpaceInfo:unmarshal(_os_)
	self.giftnum = _os_:unmarshal_int32()
	self.popularity = _os_:unmarshal_int32()
	self.revnum = _os_:unmarshal_int32()
	return _os_
end

return SGetXshSpaceInfo
