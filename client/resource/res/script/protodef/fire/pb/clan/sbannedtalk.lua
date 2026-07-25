require "utils.tableutil"
SBannedtalk = {}
SBannedtalk.__index = SBannedtalk



SBannedtalk.PROTOCOL_TYPE = 808490

function SBannedtalk.Create()
	print("enter SBannedtalk create")
	return SBannedtalk:new()
end
function SBannedtalk:new()
	local self = {}
	setmetatable(self, SBannedtalk)
	self.type = self.PROTOCOL_TYPE
	self.memberid = 0
	self.flag = 0

	return self
end
function SBannedtalk:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SBannedtalk:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.memberid)
	_os_:marshal_int32(self.flag)
	return _os_
end

function SBannedtalk:unmarshal(_os_)
	self.memberid = _os_:unmarshal_int64()
	self.flag = _os_:unmarshal_int32()
	return _os_
end

return SBannedtalk
