require "utils.tableutil"
CConfirmCharge = {}
CConfirmCharge.__index = CConfirmCharge



CConfirmCharge.PROTOCOL_TYPE = 812456

function CConfirmCharge.Create()
	print("enter CConfirmCharge create")
	return CConfirmCharge:new()
end
function CConfirmCharge:new()
	local self = {}
	setmetatable(self, CConfirmCharge)
	self.type = self.PROTOCOL_TYPE
	self.goodid = 0
	self.goodnum = 0
	self.extra = "" 

	return self
end
function CConfirmCharge:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CConfirmCharge:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.goodid)
	_os_:marshal_int32(self.goodnum)
	_os_:marshal_wstring(self.extra)
	return _os_
end

function CConfirmCharge:unmarshal(_os_)
	self.goodid = _os_:unmarshal_int32()
	self.goodnum = _os_:unmarshal_int32()
	self.extra = _os_:unmarshal_wstring(self.extra)
	return _os_
end

return CConfirmCharge
