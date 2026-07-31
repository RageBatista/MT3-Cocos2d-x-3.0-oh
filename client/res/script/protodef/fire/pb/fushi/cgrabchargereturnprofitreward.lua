require "utils.tableutil"
CGrabChargeReturnProfitReward = {}
CGrabChargeReturnProfitReward.__index = CGrabChargeReturnProfitReward



CGrabChargeReturnProfitReward.PROTOCOL_TYPE = 812481

function CGrabChargeReturnProfitReward.Create()
	print("enter CGrabChargeReturnProfitReward create")
	return CGrabChargeReturnProfitReward:new()
end
function CGrabChargeReturnProfitReward:new()
	local self = {}
	setmetatable(self, CGrabChargeReturnProfitReward)
	self.type = self.PROTOCOL_TYPE
	self.id = 0

	return self
end
function CGrabChargeReturnProfitReward:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CGrabChargeReturnProfitReward:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.id)
	return _os_
end

function CGrabChargeReturnProfitReward:unmarshal(_os_)
	self.id = _os_:unmarshal_int32()
	return _os_
end

return CGrabChargeReturnProfitReward
