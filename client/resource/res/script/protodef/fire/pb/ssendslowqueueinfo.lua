require "utils.tableutil"
SSendSlowQueueInfo = {}
SSendSlowQueueInfo.__index = SSendSlowQueueInfo



SSendSlowQueueInfo.PROTOCOL_TYPE = 786484

function SSendSlowQueueInfo.Create()
	print("enter SSendSlowQueueInfo create")
	return SSendSlowQueueInfo:new()
end
function SSendSlowQueueInfo:new()
	local self = {}
	setmetatable(self, SSendSlowQueueInfo)
	self.type = self.PROTOCOL_TYPE
	self.order = 0
	self.queuelength = 0
	self.second = 0

	return self
end
function SSendSlowQueueInfo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SSendSlowQueueInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.order)
	_os_:marshal_int32(self.queuelength)
	_os_:marshal_int32(self.second)
	return _os_
end

function SSendSlowQueueInfo:unmarshal(_os_)
	self.order = _os_:unmarshal_int32()
	self.queuelength = _os_:unmarshal_int32()
	self.second = _os_:unmarshal_int32()
	return _os_
end

return SSendSlowQueueInfo
