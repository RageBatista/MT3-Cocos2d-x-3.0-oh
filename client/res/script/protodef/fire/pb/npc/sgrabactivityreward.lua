require "utils.tableutil"
SGrabActivityReward = {}
SGrabActivityReward.__index = SGrabActivityReward



SGrabActivityReward.PROTOCOL_TYPE = 795534

function SGrabActivityReward.Create()
	print("enter SGrabActivityReward create")
	return SGrabActivityReward:new()
end
function SGrabActivityReward:new()
	local self = {}
	setmetatable(self, SGrabActivityReward)
	self.type = self.PROTOCOL_TYPE
	return self
end
function SGrabActivityReward:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SGrabActivityReward:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function SGrabActivityReward:unmarshal(_os_)
	return _os_
end

return SGrabActivityReward
