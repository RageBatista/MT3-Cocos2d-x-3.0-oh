require "utils.tableutil"
CRequestUpdateRoleInfo = {}
CRequestUpdateRoleInfo.__index = CRequestUpdateRoleInfo



CRequestUpdateRoleInfo.PROTOCOL_TYPE = 806533

function CRequestUpdateRoleInfo.Create()
	print("enter CRequestUpdateRoleInfo create")
	return CRequestUpdateRoleInfo:new()
end
function CRequestUpdateRoleInfo:new()
	local self = {}
	setmetatable(self, CRequestUpdateRoleInfo)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0

	return self
end
function CRequestUpdateRoleInfo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CRequestUpdateRoleInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	return _os_
end

function CRequestUpdateRoleInfo:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	return _os_
end

return CRequestUpdateRoleInfo
