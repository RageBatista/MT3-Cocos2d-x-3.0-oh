require "utils.tableutil"
RewardItemUnit = {}
RewardItemUnit.__index = RewardItemUnit


function RewardItemUnit:new()
	local self = {}
	setmetatable(self, RewardItemUnit)
	self.baseid = 0
	self.num = 0

	return self
end
function RewardItemUnit:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.baseid)
	_os_:marshal_int32(self.num)
	return _os_
end

function RewardItemUnit:unmarshal(_os_)
	self.baseid = _os_:unmarshal_int32()
	self.num = _os_:unmarshal_int32()
	return _os_
end

return RewardItemUnit
