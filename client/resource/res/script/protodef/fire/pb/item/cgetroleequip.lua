require "utils.tableutil"
CGetRoleEquip = {}
CGetRoleEquip.__index = CGetRoleEquip



CGetRoleEquip.PROTOCOL_TYPE = 787478

function CGetRoleEquip.Create()
	print("enter CGetRoleEquip create")
	return CGetRoleEquip:new()
end
function CGetRoleEquip:new()
	local self = {}
	setmetatable(self, CGetRoleEquip)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0
	self.sendmsg = 0

	return self
end
function CGetRoleEquip:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CGetRoleEquip:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	_os_:marshal_char(self.sendmsg)
	return _os_
end

function CGetRoleEquip:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	self.sendmsg = _os_:unmarshal_char()
	return _os_
end

return CGetRoleEquip
