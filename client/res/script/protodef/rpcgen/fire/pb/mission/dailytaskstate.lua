require "utils.tableutil"
DailyTaskState = {}
DailyTaskState.__index = DailyTaskState


function DailyTaskState:new()
	local self = {}
	setmetatable(self, DailyTaskState)
	self.id = 0
	self.state = 0

	return self
end
function DailyTaskState:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_char(self.id)
	_os_:marshal_char(self.state)
	return _os_
end

function DailyTaskState:unmarshal(_os_)
	self.id = _os_:unmarshal_char()
	self.state = _os_:unmarshal_char()
	return _os_
end

return DailyTaskState
