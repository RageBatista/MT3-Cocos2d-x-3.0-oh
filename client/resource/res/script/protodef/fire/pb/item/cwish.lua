require "utils.tableutil"
CWish = {}
CWish.__index = CWish



CWish.PROTOCOL_TYPE = 810020

function CWish.Create()
	print("enter CWish create")
	return CWish:new()
end
function CWish:new()
	local self = {}
	setmetatable(self, CWish)
	self.type = self.PROTOCOL_TYPE
	self.times = 0
	return self
end
function CWish:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CWish:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.times)
	return _os_
end

function CWish:unmarshal(_os_)
	self.times = _os_:unmarshal_int32()
	return _os_
end

return CWish
