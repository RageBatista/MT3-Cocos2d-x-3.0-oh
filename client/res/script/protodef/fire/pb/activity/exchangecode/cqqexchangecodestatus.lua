require "utils.tableutil"
CQQExchangeCodeStatus = {}
CQQExchangeCodeStatus.__index = CQQExchangeCodeStatus



CQQExchangeCodeStatus.PROTOCOL_TYPE = 819196

function CQQExchangeCodeStatus.Create()
	print("enter CQQExchangeCodeStatus create")
	return CQQExchangeCodeStatus:new()
end
function CQQExchangeCodeStatus:new()
	local self = {}
	setmetatable(self, CQQExchangeCodeStatus)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CQQExchangeCodeStatus:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CQQExchangeCodeStatus:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CQQExchangeCodeStatus:unmarshal(_os_)
	return _os_
end

return CQQExchangeCodeStatus
