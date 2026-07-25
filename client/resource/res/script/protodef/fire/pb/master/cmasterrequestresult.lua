require "utils.tableutil"
CMasterRequestResult = {
	REFUSE = 0,
	ACCEPT = 1,
	OVERTIME = 2
}
CMasterRequestResult.__index = CMasterRequestResult



CMasterRequestResult.PROTOCOL_TYPE = 816460

function CMasterRequestResult.Create()
	print("enter CMasterRequestResult create")
	return CMasterRequestResult:new()
end
function CMasterRequestResult:new()
	local self = {}
	setmetatable(self, CMasterRequestResult)
	self.type = self.PROTOCOL_TYPE
	self.masterid = 0
	self.result = 0

	return self
end
function CMasterRequestResult:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CMasterRequestResult:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.masterid)
	_os_:marshal_int32(self.result)
	return _os_
end

function CMasterRequestResult:unmarshal(_os_)
	self.masterid = _os_:unmarshal_int64()
	self.result = _os_:unmarshal_int32()
	return _os_
end

return CMasterRequestResult
