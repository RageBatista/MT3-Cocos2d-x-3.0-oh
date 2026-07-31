require "utils.tableutil"
RoleBaseData = {}
RoleBaseData.__index = RoleBaseData


function RoleBaseData:new()
	local self = {}
	setmetatable(self, RoleBaseData)
	self.roleid = 0
	self.nickname = "" 

	return self
end
function RoleBaseData:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	_os_:marshal_wstring(self.nickname)
	return _os_
end

function RoleBaseData:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	self.nickname = _os_:unmarshal_wstring(self.nickname)
	return _os_
end

return RoleBaseData
