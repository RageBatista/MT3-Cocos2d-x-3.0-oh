require "utils.tableutil"
SSendQueueInfo = {}
SSendQueueInfo.__index = SSendQueueInfo



SSendQueueInfo.PROTOCOL_TYPE = 786480

function SSendQueueInfo.Create()
	print("enter SSendQueueInfo create")
	return SSendQueueInfo:new()
end
function SSendQueueInfo:new()
	local self = {}
	setmetatable(self, SSendQueueInfo)
	self.type = self.PROTOCOL_TYPE
	self.order = 0
	self.queuelength = 0
	self.minutes = 0

	return self
end
function SSendQueueInfo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SSendQueueInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.order)
	_os_:marshal_int32(self.queuelength)
	_os_:marshal_int32(self.minutes)
	return _os_
end

function SSendQueueInfo:unmarshal(_os_)
	self.order = _os_:unmarshal_int32()
	self.queuelength = _os_:unmarshal_int32()
	self.minutes = _os_:unmarshal_int32()
	return _os_
end

return SSendQueueInfo
