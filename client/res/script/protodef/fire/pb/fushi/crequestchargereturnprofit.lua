require "utils.tableutil"
CRequestChargeReturnProfit = {}
CRequestChargeReturnProfit.__index = CRequestChargeReturnProfit



CRequestChargeReturnProfit.PROTOCOL_TYPE = 812479

function CRequestChargeReturnProfit.Create()
	print("enter CRequestChargeReturnProfit create")
	return CRequestChargeReturnProfit:new()
end
function CRequestChargeReturnProfit:new()
	local self = {}
	setmetatable(self, CRequestChargeReturnProfit)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CRequestChargeReturnProfit:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CRequestChargeReturnProfit:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CRequestChargeReturnProfit:unmarshal(_os_)
	return _os_
end

return CRequestChargeReturnProfit
