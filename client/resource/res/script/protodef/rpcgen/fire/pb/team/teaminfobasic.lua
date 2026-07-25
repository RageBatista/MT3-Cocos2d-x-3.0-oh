require "utils.tableutil"
TeamInfoBasic = {}
TeamInfoBasic.__index = TeamInfoBasic


function TeamInfoBasic:new()
	local self = {}
	setmetatable(self, TeamInfoBasic)
	self.teamid = 0
	self.leaderid = 0
	self.minlevel = 0
	self.maxlevel = 0
	self.leadername = "" 
	self.leaderlevel = 0
	self.leaderschool = 0
	self.membernum = 0
	self.membermaxnum = 0
	self.targetid = 0

	return self
end
function TeamInfoBasic:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.teamid)
	_os_:marshal_int64(self.leaderid)
	_os_:marshal_int32(self.minlevel)
	_os_:marshal_int32(self.maxlevel)
	_os_:marshal_wstring(self.leadername)
	_os_:marshal_int32(self.leaderlevel)
	_os_:marshal_int32(self.leaderschool)
	_os_:marshal_int32(self.membernum)
	_os_:marshal_int32(self.membermaxnum)
	_os_:marshal_int32(self.targetid)
	return _os_
end

function TeamInfoBasic:unmarshal(_os_)
	self.teamid = _os_:unmarshal_int64()
	self.leaderid = _os_:unmarshal_int64()
	self.minlevel = _os_:unmarshal_int32()
	self.maxlevel = _os_:unmarshal_int32()
	self.leadername = _os_:unmarshal_wstring(self.leadername)
	self.leaderlevel = _os_:unmarshal_int32()
	self.leaderschool = _os_:unmarshal_int32()
	self.membernum = _os_:unmarshal_int32()
	self.membermaxnum = _os_:unmarshal_int32()
	self.targetid = _os_:unmarshal_int32()
	return _os_
end

return TeamInfoBasic
