require "utils.tableutil"
CGetFirstPayReward = {}
CGetFirstPayReward.__index = CGetFirstPayReward



CGetFirstPayReward.PROTOCOL_TYPE = 812462

function CGetFirstPayReward.Create()
	print("enter CGetFirstPayReward create")
	return CGetFirstPayReward:new()
end
function CGetFirstPayReward:new()
	local self = {}
	setmetatable(self, CGetFirstPayReward)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CGetFirstPayReward:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CGetFirstPayReward:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CGetFirstPayReward:unmarshal(_os_)
	return _os_
end

return CGetFirstPayReward
