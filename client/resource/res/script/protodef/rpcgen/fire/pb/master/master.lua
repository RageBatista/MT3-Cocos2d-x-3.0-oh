require "utils.tableutil"
Master = {}
Master.__index = Master


function Master:new()
	local self = {}
	setmetatable(self, Master)
	self.roleid = 0
	self.nickname = "" 
	self.level = 0
	self.school = 0
	self.shape = 0
	self.rank = 0
	self.declaration = "" 

	return self
end
function Master:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	_os_:marshal_wstring(self.nickname)
	_os_:marshal_int32(self.level)
	_os_:marshal_int32(self.school)
	_os_:marshal_int32(self.shape)
	_os_:marshal_int32(self.rank)
	_os_:marshal_wstring(self.declaration)
	return _os_
end

function Master:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	self.nickname = _os_:unmarshal_wstring(self.nickname)
	self.level = _os_:unmarshal_int32()
	self.school = _os_:unmarshal_int32()
	self.shape = _os_:unmarshal_int32()
	self.rank = _os_:unmarshal_int32()
	self.declaration = _os_:unmarshal_wstring(self.declaration)
	return _os_
end

return Master
