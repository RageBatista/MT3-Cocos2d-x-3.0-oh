require "utils.tableutil"
CQueryConsumeDayPay = {}
CQueryConsumeDayPay.__index = CQueryConsumeDayPay



CQueryConsumeDayPay.PROTOCOL_TYPE = 812595

function CQueryConsumeDayPay.Create()
	print("enter CQueryConsumeDayPay create")
	return CQueryConsumeDayPay:new()
end
function CQueryConsumeDayPay:new()
	local self = {}
	setmetatable(self, CQueryConsumeDayPay)
	self.type = self.PROTOCOL_TYPE
	self.yesorno = 0

	return self
end
function CQueryConsumeDayPay:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CQueryConsumeDayPay:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.yesorno)
	return _os_
end

function CQueryConsumeDayPay:unmarshal(_os_)
	self.yesorno = _os_:unmarshal_int32()
	return _os_
end

return CQueryConsumeDayPay
