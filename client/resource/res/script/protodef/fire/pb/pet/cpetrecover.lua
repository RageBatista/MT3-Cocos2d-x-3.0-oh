require "utils.tableutil"
CPetRecover = {}
CPetRecover.__index = CPetRecover



CPetRecover.PROTOCOL_TYPE = 788585

function CPetRecover.Create()
	print("enter CPetRecover create")
	return CPetRecover:new()
end
function CPetRecover:new()
	local self = {}
	setmetatable(self, CPetRecover)
	self.type = self.PROTOCOL_TYPE
	self.uniqid = 0

	return self
end
function CPetRecover:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CPetRecover:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.uniqid)
	return _os_
end

function CPetRecover:unmarshal(_os_)
	self.uniqid = _os_:unmarshal_int64()
	return _os_
end

return CPetRecover
