require "utils.tableutil"
SGetClearTime = {}
SGetClearTime.__index = SGetClearTime



SGetClearTime.PROTOCOL_TYPE = 808546

function SGetClearTime.Create()
	print("enter SGetClearTime create")
	return SGetClearTime:new()
end
function SGetClearTime:new()
	local self = {}
	setmetatable(self, SGetClearTime)
	self.type = self.PROTOCOL_TYPE
	self.cleartime = 0

	return self
end
function SGetClearTime:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SGetClearTime:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.cleartime)
	return _os_
end

function SGetClearTime:unmarshal(_os_)
	self.cleartime = _os_:unmarshal_int64()
	return _os_
end

return SGetClearTime
