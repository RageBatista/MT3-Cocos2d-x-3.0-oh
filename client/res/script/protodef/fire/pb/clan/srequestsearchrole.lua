require "utils.tableutil"
require "protodef.rpcgen.fire.pb.clan.invitationroleinfo"
SRequestSearchRole = {}
SRequestSearchRole.__index = SRequestSearchRole



SRequestSearchRole.PROTOCOL_TYPE = 808523

function SRequestSearchRole.Create()
	print("enter SRequestSearchRole create")
	return SRequestSearchRole:new()
end
function SRequestSearchRole:new()
	local self = {}
	setmetatable(self, SRequestSearchRole)
	self.type = self.PROTOCOL_TYPE
	self.invitationroleinfolist = InvitationRoleInfo:new()

	return self
end
function SRequestSearchRole:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRequestSearchRole:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	----------------marshal bean
	self.invitationroleinfolist:marshal(_os_) 
	return _os_
end

function SRequestSearchRole:unmarshal(_os_)
	----------------unmarshal bean

	self.invitationroleinfolist:unmarshal(_os_)

	return _os_
end

return SRequestSearchRole
