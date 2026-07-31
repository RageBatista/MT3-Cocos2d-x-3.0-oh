require "utils.tableutil"
CRequestSpaceRoleInfo = {}
CRequestSpaceRoleInfo.__index = CRequestSpaceRoleInfo



CRequestSpaceRoleInfo.PROTOCOL_TYPE = 806538

function CRequestSpaceRoleInfo.Create()
	print("enter CRequestSpaceRoleInfo create")
	return CRequestSpaceRoleInfo:new()
end
function CRequestSpaceRoleInfo:new()
	local self = {}
	setmetatable(self, CRequestSpaceRoleInfo)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0
	self.reqtype = 0

	return self
end
function CRequestSpaceRoleInfo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CRequestSpaceRoleInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	_os_:marshal_int32(self.reqtype)
	return _os_
end

function CRequestSpaceRoleInfo:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	self.reqtype = _os_:unmarshal_int32()
	return _os_
end

return CRequestSpaceRoleInfo
