require "utils.tableutil"
CRequestRolePos = {
	BYNAME = 1,
	BYID = 2
}
CRequestRolePos.__index = CRequestRolePos



CRequestRolePos.PROTOCOL_TYPE = 786487

function CRequestRolePos.Create()
	print("enter CRequestRolePos create")
	return CRequestRolePos:new()
end
function CRequestRolePos:new()
	local self = {}
	setmetatable(self, CRequestRolePos)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0
	self.rolename = "" 
	self.searchtype = 0

	return self
end
function CRequestRolePos:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CRequestRolePos:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	_os_:marshal_wstring(self.rolename)
	_os_:marshal_char(self.searchtype)
	return _os_
end

function CRequestRolePos:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	self.rolename = _os_:unmarshal_wstring(self.rolename)
	self.searchtype = _os_:unmarshal_char()
	return _os_
end

return CRequestRolePos
