require "utils.tableutil"
SQQExchangeCodeStatus = {}
SQQExchangeCodeStatus.__index = SQQExchangeCodeStatus



SQQExchangeCodeStatus.PROTOCOL_TYPE = 819197

function SQQExchangeCodeStatus.Create()
	print("enter SQQExchangeCodeStatus create")
	return SQQExchangeCodeStatus:new()
end
function SQQExchangeCodeStatus:new()
	local self = {}
	setmetatable(self, SQQExchangeCodeStatus)
	self.type = self.PROTOCOL_TYPE
	self.status = 0

	return self
end
function SQQExchangeCodeStatus:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SQQExchangeCodeStatus:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.status)
	return _os_
end

function SQQExchangeCodeStatus:unmarshal(_os_)
	self.status = _os_:unmarshal_int32()
	return _os_
end

return SQQExchangeCodeStatus
