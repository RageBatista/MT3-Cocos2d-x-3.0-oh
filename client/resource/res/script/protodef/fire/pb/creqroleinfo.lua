require "utils.tableutil"
CReqRoleInfo = {}
CReqRoleInfo.__index = CReqRoleInfo



CReqRoleInfo.PROTOCOL_TYPE = 786508

function CReqRoleInfo.Create()
	print("enter CReqRoleInfo create")
	return CReqRoleInfo:new()
end
function CReqRoleInfo:new()
	local self = {}
	setmetatable(self, CReqRoleInfo)
	self.type = self.PROTOCOL_TYPE
	self.reqkey = 0

	return self
end
function CReqRoleInfo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CReqRoleInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.reqkey)
	return _os_
end

function CReqRoleInfo:unmarshal(_os_)
	self.reqkey = _os_:unmarshal_int32()
	return _os_
end

return CReqRoleInfo
