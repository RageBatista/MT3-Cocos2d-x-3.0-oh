require "utils.tableutil"
require "protodef.rpcgen.fire.pb.roleinfo"
SReturnRoleList = {}
SReturnRoleList.__index = SReturnRoleList



SReturnRoleList.PROTOCOL_TYPE = 786478

function SReturnRoleList.Create()
	print("enter SReturnRoleList create")
	return SReturnRoleList:new()
end
function SReturnRoleList:new()
	local self = {}
	setmetatable(self, SReturnRoleList)
	self.type = self.PROTOCOL_TYPE
	self.prevloginroleid = 0
	self.prevroleinbattle = 0
	self.roles = {}
	self.gacdon = 0

	return self
end
function SReturnRoleList:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SReturnRoleList:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.prevloginroleid)
	_os_:marshal_char(self.prevroleinbattle)

	----------------marshal list
	_os_:compact_uint32(TableUtil.tablelength(self.roles))
	for k,v in ipairs(self.roles) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	_os_:marshal_int32(self.gacdon)
	return _os_
end

function SReturnRoleList:unmarshal(_os_)
	self.prevloginroleid = _os_:unmarshal_int64()
	self.prevroleinbattle = _os_:unmarshal_char()
	----------------unmarshal list
	local sizeof_roles=0 ,_os_null_roles
	_os_null_roles, sizeof_roles = _os_: uncompact_uint32(sizeof_roles)
	for k = 1,sizeof_roles do
		----------------unmarshal bean
		self.roles[k]=RoleInfo:new()

		self.roles[k]:unmarshal(_os_)

	end
	self.gacdon = _os_:unmarshal_int32()
	return _os_
end

return SReturnRoleList
