require "utils.tableutil"
CReceiveReward = {}
CReceiveReward.__index = CReceiveReward



CReceiveReward.PROTOCOL_TYPE = 817969

function CReceiveReward.Create()
	print("enter CReceiveReward create")
	return CReceiveReward:new()
end
function CReceiveReward:new()
	local self = {}
	setmetatable(self, CReceiveReward)
	self.type = self.PROTOCOL_TYPE
	self.rewardid =0
	self.reawardtype = 0
	
	return self
end
function CReceiveReward:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CReceiveReward:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.rewardid)
	_os_:marshal_int32(self.reawardtype)
	return _os_
end

function CReceiveReward:unmarshal(_os_)
    self.rewardid = _os_:unmarshal_int32()
	self.reawardtype = _os_:unmarshal_int32()
	return _os_
end

return CReceiveReward
