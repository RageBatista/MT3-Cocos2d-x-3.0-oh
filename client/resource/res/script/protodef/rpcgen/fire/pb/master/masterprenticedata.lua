require "utils.tableutil"
MasterPrenticeData = {}
MasterPrenticeData.__index = MasterPrenticeData


function MasterPrenticeData:new()
	local self = {}
	setmetatable(self, MasterPrenticeData)
	self.roleid = 0
	self.nickname = "" 
	self.level = 0
	self.school = 0
	self.lastofflinetime = 0
	self.onlinestate = 0

	return self
end
function MasterPrenticeData:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	_os_:marshal_wstring(self.nickname)
	_os_:marshal_int32(self.level)
	_os_:marshal_int32(self.school)
	_os_:marshal_int64(self.lastofflinetime)
	_os_:marshal_int32(self.onlinestate)
	return _os_
end

function MasterPrenticeData:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	self.nickname = _os_:unmarshal_wstring(self.nickname)
	self.level = _os_:unmarshal_int32()
	self.school = _os_:unmarshal_int32()
	self.lastofflinetime = _os_:unmarshal_int64()
	self.onlinestate = _os_:unmarshal_int32()
	return _os_
end

return MasterPrenticeData
