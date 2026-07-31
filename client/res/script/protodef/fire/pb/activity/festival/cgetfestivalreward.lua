require "utils.tableutil"
CGetFestivalReward = {}
CGetFestivalReward.__index = CGetFestivalReward



CGetFestivalReward.PROTOCOL_TYPE = 810537

function CGetFestivalReward.Create()
	print("enter CGetFestivalReward create")
	return CGetFestivalReward:new()
end
function CGetFestivalReward:new()
	local self = {}
	setmetatable(self, CGetFestivalReward)
	self.type = self.PROTOCOL_TYPE
	self.rewardid = 0

	return self
end
function CGetFestivalReward:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CGetFestivalReward:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.rewardid)
	return _os_
end

function CGetFestivalReward:unmarshal(_os_)
	self.rewardid = _os_:unmarshal_int32()
	return _os_
end

return CGetFestivalReward
