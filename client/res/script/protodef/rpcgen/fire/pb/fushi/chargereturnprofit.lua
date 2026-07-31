require "utils.tableutil"
ChargeReturnProfit = {}
ChargeReturnProfit.__index = ChargeReturnProfit


function ChargeReturnProfit:new()
	local self = {}
	setmetatable(self, ChargeReturnProfit)
	self.id = 0
	self.value = 0
	self.maxvalue = 0
	self.status = 0

	return self
end
function ChargeReturnProfit:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.id)
	_os_:marshal_int32(self.value)
	_os_:marshal_int32(self.maxvalue)
	_os_:marshal_int32(self.status)
	return _os_
end

function ChargeReturnProfit:unmarshal(_os_)
	self.id = _os_:unmarshal_int32()
	self.value = _os_:unmarshal_int32()
	self.maxvalue = _os_:unmarshal_int32()
	self.status = _os_:unmarshal_int32()
	return _os_
end

return ChargeReturnProfit
