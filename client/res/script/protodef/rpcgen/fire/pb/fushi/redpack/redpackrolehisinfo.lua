require "utils.tableutil"
RedPackRoleHisInfo = {}
RedPackRoleHisInfo.__index = RedPackRoleHisInfo


function RedPackRoleHisInfo:new()
	local self = {}
	setmetatable(self, RedPackRoleHisInfo)
	self.roleid = 0
	self.rolename = "" 
	self.redpackmoney = 0

	return self
end
function RedPackRoleHisInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	_os_:marshal_wstring(self.rolename)
	_os_:marshal_int32(self.redpackmoney)
	return _os_
end

function RedPackRoleHisInfo:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	self.rolename = _os_:unmarshal_wstring(self.rolename)
	self.redpackmoney = _os_:unmarshal_int32()
	return _os_
end

return RedPackRoleHisInfo
