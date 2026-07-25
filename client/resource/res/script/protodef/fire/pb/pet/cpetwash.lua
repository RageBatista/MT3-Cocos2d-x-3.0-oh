require "utils.tableutil"
CPetWash = {}
CPetWash.__index = CPetWash



CPetWash.PROTOCOL_TYPE = 788515

function CPetWash.Create()
	print("enter CPetWash create")
	return CPetWash:new()
end
function CPetWash:new()
	local self = {}
	setmetatable(self, CPetWash)
	self.type = self.PROTOCOL_TYPE
	self.petkey = 0

	return self
end
function CPetWash:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CPetWash:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.petkey)
	return _os_
end

function CPetWash:unmarshal(_os_)
	self.petkey = _os_:unmarshal_int32()
	return _os_
end

return CPetWash
