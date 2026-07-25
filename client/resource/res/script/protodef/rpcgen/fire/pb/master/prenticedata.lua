require "utils.tableutil"
PrenticeData = {}
PrenticeData.__index = PrenticeData


function PrenticeData:new()
	local self = {}
	setmetatable(self, PrenticeData)
	self.roleid = 0
	self.rolename = "" 
	self.flag = 0

	return self
end
function PrenticeData:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	_os_:marshal_wstring(self.rolename)
	_os_:marshal_int32(self.flag)
	return _os_
end

function PrenticeData:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	self.rolename = _os_:unmarshal_wstring(self.rolename)
	self.flag = _os_:unmarshal_int32()
	return _os_
end

return PrenticeData
