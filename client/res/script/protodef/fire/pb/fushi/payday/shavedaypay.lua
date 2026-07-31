require "utils.tableutil"
SHaveDayPay = {}
SHaveDayPay.__index = SHaveDayPay



SHaveDayPay.PROTOCOL_TYPE = 812593

function SHaveDayPay.Create()
	print("enter SHaveDayPay create")
	return SHaveDayPay:new()
end
function SHaveDayPay:new()
	local self = {}
	setmetatable(self, SHaveDayPay)
	self.type = self.PROTOCOL_TYPE
	self.daypay = 0

	return self
end
function SHaveDayPay:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SHaveDayPay:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.daypay)
	return _os_
end

function SHaveDayPay:unmarshal(_os_)
	self.daypay = _os_:unmarshal_int32()
	return _os_
end

return SHaveDayPay
