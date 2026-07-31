require "utils.tableutil"
InstanceInfo = {}
InstanceInfo.__index = InstanceInfo


function InstanceInfo:new()
	local self = {}
	setmetatable(self, InstanceInfo)
	self.id = 0
	self.instanceid = 0
	self.state = 0
	self.instancestate = 0
	self.starttime = 0
	self.endtime = 0
	self.finishedtimes = 0
	self.totaltimes = 0

	return self
end
function InstanceInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.id)
	_os_:marshal_int32(self.instanceid)
	_os_:marshal_int32(self.state)
	_os_:marshal_int32(self.instancestate)
	_os_:marshal_int64(self.starttime)
	_os_:marshal_int64(self.endtime)
	_os_:marshal_int32(self.finishedtimes)
	_os_:marshal_int32(self.totaltimes)
	return _os_
end

function InstanceInfo:unmarshal(_os_)
	self.id = _os_:unmarshal_int32()
	self.instanceid = _os_:unmarshal_int32()
	self.state = _os_:unmarshal_int32()
	self.instancestate = _os_:unmarshal_int32()
	self.starttime = _os_:unmarshal_int64()
	self.endtime = _os_:unmarshal_int64()
	self.finishedtimes = _os_:unmarshal_int32()
	self.totaltimes = _os_:unmarshal_int32()
	return _os_
end

return InstanceInfo
