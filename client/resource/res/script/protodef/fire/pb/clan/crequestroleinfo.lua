require "utils.tableutil"
CRequestRoleInfo = {}
CRequestRoleInfo.__index = CRequestRoleInfo



CRequestRoleInfo.PROTOCOL_TYPE = 808502

function CRequestRoleInfo.Create()
	print("enter CRequestRoleInfo create")
	return CRequestRoleInfo:new()
end
function CRequestRoleInfo:new()
	local self = {}
	setmetatable(self, CRequestRoleInfo)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0
	self.moduletype = 0

	return self
end
function CRequestRoleInfo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CRequestRoleInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	_os_:marshal_int32(self.moduletype)
	return _os_
end

function CRequestRoleInfo:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	self.moduletype = _os_:unmarshal_int32()
	return _os_
end

return CRequestRoleInfo
