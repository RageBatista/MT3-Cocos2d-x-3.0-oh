require "utils.tableutil"
SPetError = {}
SPetError.__index = SPetError



SPetError.PROTOCOL_TYPE = 788449

function SPetError.Create()
	print("enter SPetError create")
	return SPetError:new()
end
function SPetError:new()
	local self = {}
	setmetatable(self, SPetError)
	self.type = self.PROTOCOL_TYPE
	self.peterror = 0

	return self
end
function SPetError:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SPetError:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.peterror)
	return _os_
end

function SPetError:unmarshal(_os_)
	self.peterror = _os_:unmarshal_int32()
	return _os_
end

return SPetError
