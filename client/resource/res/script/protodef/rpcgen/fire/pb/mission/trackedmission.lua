require "utils.tableutil"
TrackedMission = {}
TrackedMission.__index = TrackedMission


function TrackedMission:new()
	local self = {}
	setmetatable(self, TrackedMission)
	self.acceptdate = 0

	return self
end
function TrackedMission:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.acceptdate)
	return _os_
end

function TrackedMission:unmarshal(_os_)
	self.acceptdate = _os_:unmarshal_int64()
	return _os_
end

return TrackedMission
