require "utils.tableutil"
require "protodef.rpcgen.fire.pb.move.rolesimpleinfo"
SGMGetAroundRoles = {}
SGMGetAroundRoles.__index = SGMGetAroundRoles



SGMGetAroundRoles.PROTOCOL_TYPE = 790470

function SGMGetAroundRoles.Create()
	print("enter SGMGetAroundRoles create")
	return SGMGetAroundRoles:new()
end
function SGMGetAroundRoles:new()
	local self = {}
	setmetatable(self, SGMGetAroundRoles)
	self.type = self.PROTOCOL_TYPE
	self.roles = {}

	return self
end
function SGMGetAroundRoles:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SGMGetAroundRoles:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.roles))
	for k,v in ipairs(self.roles) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	return _os_
end

function SGMGetAroundRoles:unmarshal(_os_)
	----------------unmarshal vector
	local sizeof_roles=0,_os_null_roles
	_os_null_roles, sizeof_roles = _os_: uncompact_uint32(sizeof_roles)
	for k = 1,sizeof_roles do
		----------------unmarshal bean
		self.roles[k]=RoleSimpleInfo:new()

		self.roles[k]:unmarshal(_os_)

	end
	return _os_
end

return SGMGetAroundRoles
