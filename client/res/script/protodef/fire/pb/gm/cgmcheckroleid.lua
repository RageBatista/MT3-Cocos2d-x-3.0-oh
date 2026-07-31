require "utils.tableutil"
CGMCheckRoleID = {}
CGMCheckRoleID.__index = CGMCheckRoleID



CGMCheckRoleID.PROTOCOL_TYPE = 791434

function CGMCheckRoleID.Create()
	print("enter CGMCheckRoleID create")
	return CGMCheckRoleID:new()
end
function CGMCheckRoleID:new()
	local self = {}
	setmetatable(self, CGMCheckRoleID)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0

	return self
end
function CGMCheckRoleID:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CGMCheckRoleID:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	return _os_
end

function CGMCheckRoleID:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	return _os_
end

return CGMCheckRoleID
