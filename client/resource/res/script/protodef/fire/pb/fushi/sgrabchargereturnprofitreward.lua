require "utils.tableutil"
SGrabChargeReturnProfitReward = {}
SGrabChargeReturnProfitReward.__index = SGrabChargeReturnProfitReward



SGrabChargeReturnProfitReward.PROTOCOL_TYPE = 812482

function SGrabChargeReturnProfitReward.Create()
	print("enter SGrabChargeReturnProfitReward create")
	return SGrabChargeReturnProfitReward:new()
end
function SGrabChargeReturnProfitReward:new()
	local self = {}
	setmetatable(self, SGrabChargeReturnProfitReward)
	self.type = self.PROTOCOL_TYPE
	self.id = 0
	self.status = 0

	return self
end
function SGrabChargeReturnProfitReward:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SGrabChargeReturnProfitReward:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.id)
	_os_:marshal_int32(self.status)
	return _os_
end

function SGrabChargeReturnProfitReward:unmarshal(_os_)
	self.id = _os_:unmarshal_int32()
	self.status = _os_:unmarshal_int32()
	return _os_
end

return SGrabChargeReturnProfitReward
