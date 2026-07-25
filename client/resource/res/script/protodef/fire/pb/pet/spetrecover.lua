require "utils.tableutil"
SPetRecover = {}
SPetRecover.__index = SPetRecover



SPetRecover.PROTOCOL_TYPE = 788586

function SPetRecover.Create()
	print("enter SPetRecover create")
	return SPetRecover:new()
end
function SPetRecover:new()
	local self = {}
	setmetatable(self, SPetRecover)
	self.type = self.PROTOCOL_TYPE
	self.petid = 0
	self.uniqid = 0

	return self
end
function SPetRecover:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SPetRecover:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.petid)
	_os_:marshal_int64(self.uniqid)
	return _os_
end

function SPetRecover:unmarshal(_os_)
	self.petid = _os_:unmarshal_int32()
	self.uniqid = _os_:unmarshal_int64()
	return _os_
end

return SPetRecover
