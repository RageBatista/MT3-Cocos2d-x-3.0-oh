require "utils.tableutil"
SQueryConsumeDayPay = {}
SQueryConsumeDayPay.__index = SQueryConsumeDayPay



SQueryConsumeDayPay.PROTOCOL_TYPE = 812594

function SQueryConsumeDayPay.Create()
	print("enter SQueryConsumeDayPay create")
	return SQueryConsumeDayPay:new()
end
function SQueryConsumeDayPay:new()
	local self = {}
	setmetatable(self, SQueryConsumeDayPay)
	self.type = self.PROTOCOL_TYPE
	return self
end
function SQueryConsumeDayPay:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SQueryConsumeDayPay:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function SQueryConsumeDayPay:unmarshal(_os_)
	return _os_
end

return SQueryConsumeDayPay
