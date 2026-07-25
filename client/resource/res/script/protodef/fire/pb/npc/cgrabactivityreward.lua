require "utils.tableutil"
CGrabActivityReward = {}
CGrabActivityReward.__index = CGrabActivityReward



CGrabActivityReward.PROTOCOL_TYPE = 795531

function CGrabActivityReward.Create()
	print("enter CGrabActivityReward create")
	return CGrabActivityReward:new()
end
function CGrabActivityReward:new()
	local self = {}
	setmetatable(self, CGrabActivityReward)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CGrabActivityReward:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CGrabActivityReward:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CGrabActivityReward:unmarshal(_os_)
	return _os_
end

return CGrabActivityReward
