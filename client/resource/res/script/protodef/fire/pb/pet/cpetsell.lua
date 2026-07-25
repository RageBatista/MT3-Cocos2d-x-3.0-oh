require "utils.tableutil"
CPetSell = {}
CPetSell.__index = CPetSell



CPetSell.PROTOCOL_TYPE = 788527

function CPetSell.Create()
	print("enter CPetSell create")
	return CPetSell:new()
end
function CPetSell:new()
	local self = {}
	setmetatable(self, CPetSell)
	self.type = self.PROTOCOL_TYPE
	self.petkey = 0

	return self
end
function CPetSell:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CPetSell:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.petkey)
	return _os_
end

function CPetSell:unmarshal(_os_)
	self.petkey = _os_:unmarshal_int32()
	return _os_
end

return CPetSell
