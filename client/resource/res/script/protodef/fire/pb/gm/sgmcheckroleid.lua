require "utils.tableutil"
require "protodef.rpcgen.fire.pb.move.rolesimpleinfo"
SGMCheckRoleID = {}
SGMCheckRoleID.__index = SGMCheckRoleID



SGMCheckRoleID.PROTOCOL_TYPE = 791435

function SGMCheckRoleID.Create()
	print("enter SGMCheckRoleID create")
	return SGMCheckRoleID:new()
end
function SGMCheckRoleID:new()
	local self = {}
	setmetatable(self, SGMCheckRoleID)
	self.type = self.PROTOCOL_TYPE
	self.roleinfo = RoleSimpleInfo:new()

	return self
end
function SGMCheckRoleID:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SGMCheckRoleID:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	----------------marshal bean
	self.roleinfo:marshal(_os_) 
	return _os_
end

function SGMCheckRoleID:unmarshal(_os_)
	----------------unmarshal bean

	self.roleinfo:unmarshal(_os_)

	return _os_
end

return SGMCheckRoleID
