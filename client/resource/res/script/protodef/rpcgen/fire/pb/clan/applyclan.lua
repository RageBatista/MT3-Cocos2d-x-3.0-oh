require "utils.tableutil"
ApplyClan = {}
ApplyClan.__index = ApplyClan


function ApplyClan:new()
	local self = {}
	setmetatable(self, ApplyClan)
	self.clankey = 0
	self.applystate = 0

	return self
end
function ApplyClan:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.clankey)
	_os_:marshal_int32(self.applystate)
	return _os_
end

function ApplyClan:unmarshal(_os_)
	self.clankey = _os_:unmarshal_int64()
	self.applystate = _os_:unmarshal_int32()
	return _os_
end

return ApplyClan
