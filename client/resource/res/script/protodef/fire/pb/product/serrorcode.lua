require "utils.tableutil"
SErrorCode = {}
SErrorCode.__index = SErrorCode



SErrorCode.PROTOCOL_TYPE = 803441

function SErrorCode.Create()
	print("enter SErrorCode create")
	return SErrorCode:new()
end
function SErrorCode:new()
	local self = {}
	setmetatable(self, SErrorCode)
	self.type = self.PROTOCOL_TYPE
	self.errorcode = 0

	return self
end
function SErrorCode:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SErrorCode:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.errorcode)
	return _os_
end

function SErrorCode:unmarshal(_os_)
	self.errorcode = _os_:unmarshal_int32()
	return _os_
end

return SErrorCode
