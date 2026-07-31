require "utils.tableutil"
SProductMadeUp = {}
SProductMadeUp.__index = SProductMadeUp



SProductMadeUp.PROTOCOL_TYPE = 803442

function SProductMadeUp.Create()
	print("enter SProductMadeUp create")
	return SProductMadeUp:new()
end
function SProductMadeUp:new()
	local self = {}
	setmetatable(self, SProductMadeUp)
	self.type = self.PROTOCOL_TYPE
	self.maketype = 0
	self.itemkey = 0

	return self
end
function SProductMadeUp:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SProductMadeUp:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.maketype)
	_os_:marshal_int32(self.itemkey)
	return _os_
end

function SProductMadeUp:unmarshal(_os_)
	self.maketype = _os_:unmarshal_int32()
	self.itemkey = _os_:unmarshal_int32()
	return _os_
end

return SProductMadeUp
