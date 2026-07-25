require "utils.tableutil"
require "protodef.rpcgen.fire.pb.roleinfo"
SCreateRole = {
	CREATE_OK = 1,
	CREATE_ERROR = 2,
	CREATE_INVALID = 3,
	CREATE_DUPLICATED = 4,
	CREATE_OVERCOUNT = 5,
	CREATE_OVERLEN = 6,
	CREATE_SHORTLEN = 7
}
SCreateRole.__index = SCreateRole



SCreateRole.PROTOCOL_TYPE = 786436

function SCreateRole.Create()
	print("enter SCreateRole create")
	return SCreateRole:new()
end
function SCreateRole:new()
	local self = {}
	setmetatable(self, SCreateRole)
	self.type = self.PROTOCOL_TYPE
	self.newinfo = RoleInfo:new()

	return self
end
function SCreateRole:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SCreateRole:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	----------------marshal bean
	self.newinfo:marshal(_os_) 
	return _os_
end

function SCreateRole:unmarshal(_os_)
	----------------unmarshal bean

	self.newinfo:unmarshal(_os_)

	return _os_
end

return SCreateRole
