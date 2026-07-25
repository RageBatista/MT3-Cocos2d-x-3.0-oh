require "utils.tableutil"
SNotifyBuySuccess = {}
SNotifyBuySuccess.__index = SNotifyBuySuccess



SNotifyBuySuccess.PROTOCOL_TYPE = 810657

function SNotifyBuySuccess.Create()
	print("enter SNotifyBuySuccess create")
	return SNotifyBuySuccess:new()
end
function SNotifyBuySuccess:new()
	local self = {}
	setmetatable(self, SNotifyBuySuccess)
	self.type = self.PROTOCOL_TYPE
	self.notifytype = 0
	self.name = "" 
	self.number = 0
	self.money = 0
	self.currency = 0
	self.itemorpet = 0
	self.units = "" 

	return self
end
function SNotifyBuySuccess:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SNotifyBuySuccess:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.notifytype)
	_os_:marshal_wstring(self.name)
	_os_:marshal_int32(self.number)
	_os_:marshal_int32(self.money)
	_os_:marshal_int32(self.currency)
	_os_:marshal_int32(self.itemorpet)
	_os_:marshal_wstring(self.units)
	return _os_
end

function SNotifyBuySuccess:unmarshal(_os_)
	self.notifytype = _os_:unmarshal_int32()
	self.name = _os_:unmarshal_wstring(self.name)
	self.number = _os_:unmarshal_int32()
	self.money = _os_:unmarshal_int32()
	self.currency = _os_:unmarshal_int32()
	self.itemorpet = _os_:unmarshal_int32()
	self.units = _os_:unmarshal_wstring(self.units)
	return _os_
end

return SNotifyBuySuccess
