require "utils.tableutil"
SConfirmCharge = {}
SConfirmCharge.__index = SConfirmCharge



SConfirmCharge.PROTOCOL_TYPE = 812457

function SConfirmCharge.Create()
	print("enter SConfirmCharge create")
	return SConfirmCharge:new()
end
function SConfirmCharge:new()
	local self = {}
	setmetatable(self, SConfirmCharge)
	self.type = self.PROTOCOL_TYPE
	self.billid = 0
	self.goodid = 0
	self.goodnum = 0
	self.goodname = "" 
	self.price = 0
	self.serverid = 0
	self.extra = "" 

	return self
end
function SConfirmCharge:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SConfirmCharge:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.billid)
	_os_:marshal_int32(self.goodid)
	_os_:marshal_int32(self.goodnum)
	_os_:marshal_wstring(self.goodname)
	_os_:marshal_int32(self.price)
	_os_:marshal_int32(self.serverid)
	_os_:marshal_wstring(self.extra)
	return _os_
end

function SConfirmCharge:unmarshal(_os_)
	self.billid = _os_:unmarshal_int64()
	self.goodid = _os_:unmarshal_int32()
	self.goodnum = _os_:unmarshal_int32()
	self.goodname = _os_:unmarshal_wstring(self.goodname)
	self.price = _os_:unmarshal_int32()
	self.serverid = _os_:unmarshal_int32()
	self.extra = _os_:unmarshal_wstring(self.extra)
	return _os_
end

return SConfirmCharge
