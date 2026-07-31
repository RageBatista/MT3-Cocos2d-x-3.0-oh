require "utils.tableutil"
SPetWash = {}
SPetWash.__index = SPetWash



SPetWash.PROTOCOL_TYPE = 788516

function SPetWash.Create()
	print("enter SPetWash create")
	return SPetWash:new()
end
function SPetWash:new()
	local self = {}
	setmetatable(self, SPetWash)
	self.type = self.PROTOCOL_TYPE
	self.petkey = 0

	return self
end
function SPetWash:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SPetWash:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.petkey)
	return _os_
end

function SPetWash:unmarshal(_os_)
	self.petkey = _os_:unmarshal_int32()
	return _os_
end

return SPetWash
