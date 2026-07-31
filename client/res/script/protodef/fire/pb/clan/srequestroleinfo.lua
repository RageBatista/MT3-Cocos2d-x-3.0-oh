require "utils.tableutil"
require "protodef.rpcgen.fire.pb.clan.roleinfodes"
SRequestRoleInfo = {}
SRequestRoleInfo.__index = SRequestRoleInfo



SRequestRoleInfo.PROTOCOL_TYPE = 808503

function SRequestRoleInfo.Create()
	print("enter SRequestRoleInfo create")
	return SRequestRoleInfo:new()
end
function SRequestRoleInfo:new()
	local self = {}
	setmetatable(self, SRequestRoleInfo)
	self.type = self.PROTOCOL_TYPE
	self.roleinfo = RoleInfoDes:new()

	return self
end
function SRequestRoleInfo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRequestRoleInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	----------------marshal bean
	self.roleinfo:marshal(_os_) 
	return _os_
end

function SRequestRoleInfo:unmarshal(_os_)
	----------------unmarshal bean

	self.roleinfo:unmarshal(_os_)

	return _os_
end

return SRequestRoleInfo
