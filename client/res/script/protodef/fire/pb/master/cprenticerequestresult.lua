require "utils.tableutil"
CPrenticeRequestResult = {
	REFUSE = 0,
	ACCEPT = 1,
	OVERTIME = 2
}
CPrenticeRequestResult.__index = CPrenticeRequestResult



CPrenticeRequestResult.PROTOCOL_TYPE = 816441

function CPrenticeRequestResult.Create()
	print("enter CPrenticeRequestResult create")
	return CPrenticeRequestResult:new()
end
function CPrenticeRequestResult:new()
	local self = {}
	setmetatable(self, CPrenticeRequestResult)
	self.type = self.PROTOCOL_TYPE
	self.prenticeid = 0
	self.result = 0

	return self
end
function CPrenticeRequestResult:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CPrenticeRequestResult:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.prenticeid)
	_os_:marshal_int32(self.result)
	return _os_
end

function CPrenticeRequestResult:unmarshal(_os_)
	self.prenticeid = _os_:unmarshal_int64()
	self.result = _os_:unmarshal_int32()
	return _os_
end

return CPrenticeRequestResult
