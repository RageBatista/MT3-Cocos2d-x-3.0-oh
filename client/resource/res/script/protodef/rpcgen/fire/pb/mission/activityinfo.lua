require "utils.tableutil"
ActivityInfo = {}
ActivityInfo.__index = ActivityInfo


function ActivityInfo:new()
	local self = {}
	setmetatable(self, ActivityInfo)
	self.activityid = 0
	self.state = 0
	self.activitystate = 0
	self.finishtimes = 0
	self.nextid = 0
	self.nextnextid = 0

	return self
end
function ActivityInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.activityid)
	_os_:marshal_int32(self.state)
	_os_:marshal_int32(self.activitystate)
	_os_:marshal_int32(self.finishtimes)
	_os_:marshal_int32(self.nextid)
	_os_:marshal_int32(self.nextnextid)
	return _os_
end

function ActivityInfo:unmarshal(_os_)
	self.activityid = _os_:unmarshal_int32()
	self.state = _os_:unmarshal_int32()
	self.activitystate = _os_:unmarshal_int32()
	self.finishtimes = _os_:unmarshal_int32()
	self.nextid = _os_:unmarshal_int32()
	self.nextnextid = _os_:unmarshal_int32()
	return _os_
end

return ActivityInfo
