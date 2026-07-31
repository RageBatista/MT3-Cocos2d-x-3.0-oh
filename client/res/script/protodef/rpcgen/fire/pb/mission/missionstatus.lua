require "utils.tableutil"
MissionStatus = {
	ABANDON = -2,
	UNACCEPT = -1,
	COMMITED = 1,
	FAILED = 2,
	FINISHED = 3,
	PROCESSING = 4
}
MissionStatus.__index = MissionStatus


function MissionStatus:new()
	local self = {}
	setmetatable(self, MissionStatus)
	return self
end
function MissionStatus:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function MissionStatus:unmarshal(_os_)
	return _os_
end

return MissionStatus
