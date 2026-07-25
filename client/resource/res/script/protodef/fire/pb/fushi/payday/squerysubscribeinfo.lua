require "utils.tableutil"
SQuerySubscribeInfo = {}
SQuerySubscribeInfo.__index = SQuerySubscribeInfo



SQuerySubscribeInfo.PROTOCOL_TYPE = 812598

function SQuerySubscribeInfo.Create()
	print("enter SQuerySubscribeInfo create")
	return SQuerySubscribeInfo:new()
end
function SQuerySubscribeInfo:new()
	local self = {}
	setmetatable(self, SQuerySubscribeInfo)
	self.type = self.PROTOCOL_TYPE
	self.subscribetime = 0
	self.expiretime = 0

	return self
end
function SQuerySubscribeInfo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SQuerySubscribeInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.subscribetime)
	_os_:marshal_int64(self.expiretime)
	return _os_
end

function SQuerySubscribeInfo:unmarshal(_os_)
	self.subscribetime = _os_:unmarshal_int64()
	self.expiretime = _os_:unmarshal_int64()
	return _os_
end

return SQuerySubscribeInfo
