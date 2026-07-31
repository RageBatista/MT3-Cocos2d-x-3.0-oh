require "utils.tableutil"
CReceiveCheckCode = {}
CReceiveCheckCode.__index = CReceiveCheckCode



CReceiveCheckCode.PROTOCOL_TYPE = 786570

function CReceiveCheckCode.Create()
	print("enter CReceiveCheckCode create")
	return CReceiveCheckCode:new()
end
function CReceiveCheckCode:new()
	local self = {}
	setmetatable(self, CReceiveCheckCode)
	self.type = self.PROTOCOL_TYPE
	self.checkcodetype = 0

	return self
end
function CReceiveCheckCode:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CReceiveCheckCode:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_char(self.checkcodetype)
	return _os_
end

function CReceiveCheckCode:unmarshal(_os_)
	self.checkcodetype = _os_:unmarshal_char()
	return _os_
end

return CReceiveCheckCode
