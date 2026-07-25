require "utils.tableutil"
CExtPackSize = {}
CExtPackSize.__index = CExtPackSize



CExtPackSize.PROTOCOL_TYPE = 787737

function CExtPackSize.Create()
	print("enter CExtPackSize create")
	return CExtPackSize:new()
end
function CExtPackSize:new()
	local self = {}
	setmetatable(self, CExtPackSize)
	self.type = self.PROTOCOL_TYPE
	self.packid = 0

	return self
end
function CExtPackSize:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CExtPackSize:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.packid)
	return _os_
end

function CExtPackSize:unmarshal(_os_)
	self.packid = _os_:unmarshal_int32()
	return _os_
end

return CExtPackSize
