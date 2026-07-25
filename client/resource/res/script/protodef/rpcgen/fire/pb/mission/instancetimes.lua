require "utils.tableutil"
InstanceTimes = {}
InstanceTimes.__index = InstanceTimes


function InstanceTimes:new()
	local self = {}
	setmetatable(self, InstanceTimes)
	self.instanceid = 0
	self.finishedtimes = 0
	self.totaltimes = 0

	return self
end
function InstanceTimes:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.instanceid)
	_os_:marshal_int32(self.finishedtimes)
	_os_:marshal_int32(self.totaltimes)
	return _os_
end

function InstanceTimes:unmarshal(_os_)
	self.instanceid = _os_:unmarshal_int32()
	self.finishedtimes = _os_:unmarshal_int32()
	self.totaltimes = _os_:unmarshal_int32()
	return _os_
end

return InstanceTimes
