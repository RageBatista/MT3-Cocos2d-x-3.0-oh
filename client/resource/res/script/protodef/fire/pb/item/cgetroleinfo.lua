require "utils.tableutil"
CGetRoleInfo = {}
CGetRoleInfo.__index = CGetRoleInfo



CGetRoleInfo.PROTOCOL_TYPE = 787709

function CGetRoleInfo.Create()
	print("enter CGetRoleInfo create")
	return CGetRoleInfo:new()
end
function CGetRoleInfo:new()
	local self = {}
	setmetatable(self, CGetRoleInfo)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0

	return self
end
function CGetRoleInfo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CGetRoleInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	return _os_
end

function CGetRoleInfo:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	return _os_
end

return CGetRoleInfo
