require "utils.tableutil"
SError = {}
SError.__index = SError



SError.PROTOCOL_TYPE = 786451

function SError.Create()
	print("enter SError create")
	return SError:new()
end
function SError:new()
	local self = {}
	setmetatable(self, SError)
	self.type = self.PROTOCOL_TYPE
	self.error = 0

	return self
end
function SError:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SError:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.error)
	return _os_
end

function SError:unmarshal(_os_)
	self.error = _os_:unmarshal_int32()
	return _os_
end

return SError
