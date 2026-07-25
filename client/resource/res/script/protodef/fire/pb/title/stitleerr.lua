require "utils.tableutil"
STitleErr = {}
STitleErr.__index = STitleErr



STitleErr.PROTOCOL_TYPE = 798439

function STitleErr.Create()
	print("enter STitleErr create")
	return STitleErr:new()
end
function STitleErr:new()
	local self = {}
	setmetatable(self, STitleErr)
	self.type = self.PROTOCOL_TYPE
	self.titleerr = 0

	return self
end
function STitleErr:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function STitleErr:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.titleerr)
	return _os_
end

function STitleErr:unmarshal(_os_)
	self.titleerr = _os_:unmarshal_int32()
	return _os_
end

return STitleErr
