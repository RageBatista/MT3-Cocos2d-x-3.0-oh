require "utils.tableutil"
SConsumeDayPay = {}
SConsumeDayPay.__index = SConsumeDayPay



SConsumeDayPay.PROTOCOL_TYPE = 812596

function SConsumeDayPay.Create()
	print("enter SConsumeDayPay create")
	return SConsumeDayPay:new()
end
function SConsumeDayPay:new()
	local self = {}
	setmetatable(self, SConsumeDayPay)
	self.type = self.PROTOCOL_TYPE
	return self
end
function SConsumeDayPay:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SConsumeDayPay:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function SConsumeDayPay:unmarshal(_os_)
	return _os_
end

return SConsumeDayPay
