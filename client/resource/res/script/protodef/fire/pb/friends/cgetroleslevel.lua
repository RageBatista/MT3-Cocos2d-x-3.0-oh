require "utils.tableutil"
CGetRolesLevel = {}
CGetRolesLevel.__index = CGetRolesLevel



CGetRolesLevel.PROTOCOL_TYPE = 806645

function CGetRolesLevel.Create()
	print("enter CGetRolesLevel create")
	return CGetRolesLevel:new()
end
function CGetRolesLevel:new()
	local self = {}
	setmetatable(self, CGetRolesLevel)
	self.type = self.PROTOCOL_TYPE
	self.roles = {}
	self.gettype = 0

	return self
end
function CGetRolesLevel:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CGetRolesLevel:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.roles))
	for k,v in ipairs(self.roles) do
		_os_:marshal_int64(v)
	end

	_os_:marshal_int32(self.gettype)
	return _os_
end

function CGetRolesLevel:unmarshal(_os_)
	----------------unmarshal vector
	local sizeof_roles=0,_os_null_roles
	_os_null_roles, sizeof_roles = _os_: uncompact_uint32(sizeof_roles)
	for k = 1,sizeof_roles do
		self.roles[k] = _os_:unmarshal_int64()
	end
	self.gettype = _os_:unmarshal_int32()
	return _os_
end

return CGetRolesLevel
