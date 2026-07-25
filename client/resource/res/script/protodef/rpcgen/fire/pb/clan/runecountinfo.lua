require "utils.tableutil"
RuneCountInfo = {}
RuneCountInfo.__index = RuneCountInfo


function RuneCountInfo:new()
	local self = {}
	setmetatable(self, RuneCountInfo)
	self.roleid = 0
	self.rolename = "" 
	self.level = 0
	self.school = 0
	self.position = 0
	self.givenum = 0
	self.acceptnum = 0
	self.givelevel = 0

	return self
end
function RuneCountInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	_os_:marshal_wstring(self.rolename)
	_os_:marshal_int32(self.level)
	_os_:marshal_int32(self.school)
	_os_:marshal_int32(self.position)
	_os_:marshal_int32(self.givenum)
	_os_:marshal_int32(self.acceptnum)
	_os_:marshal_int32(self.givelevel)
	return _os_
end

function RuneCountInfo:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	self.rolename = _os_:unmarshal_wstring(self.rolename)
	self.level = _os_:unmarshal_int32()
	self.school = _os_:unmarshal_int32()
	self.position = _os_:unmarshal_int32()
	self.givenum = _os_:unmarshal_int32()
	self.acceptnum = _os_:unmarshal_int32()
	self.givelevel = _os_:unmarshal_int32()
	return _os_
end

return RuneCountInfo
