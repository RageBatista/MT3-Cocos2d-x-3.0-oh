require "utils.tableutil"
MissionInfo = {}
MissionInfo.__index = MissionInfo


function MissionInfo:new()
	local self = {}
	setmetatable(self, MissionInfo)
	self.missionid = 0
	self.missionstatus = 0
	self.missionvalue = 0
	self.missionround = 0
	self.dstnpckey = 0

	return self
end
function MissionInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.missionid)
	_os_:marshal_int32(self.missionstatus)
	_os_:marshal_int32(self.missionvalue)
	_os_:marshal_int32(self.missionround)
	_os_:marshal_int64(self.dstnpckey)
	return _os_
end

function MissionInfo:unmarshal(_os_)
	self.missionid = _os_:unmarshal_int32()
	self.missionstatus = _os_:unmarshal_int32()
	self.missionvalue = _os_:unmarshal_int32()
	self.missionround = _os_:unmarshal_int32()
	self.dstnpckey = _os_:unmarshal_int64()
	return _os_
end

return MissionInfo
