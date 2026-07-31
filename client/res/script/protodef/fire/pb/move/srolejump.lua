require "utils.tableutil"
require "protodef.rpcgen.fire.pb.move.pos"
SRoleJump = {}
SRoleJump.__index = SRoleJump



SRoleJump.PROTOCOL_TYPE = 790478

function SRoleJump.Create()
	print("enter SRoleJump create")
	return SRoleJump:new()
end
function SRoleJump:new()
	local self = {}
	setmetatable(self, SRoleJump)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0
	self.srcpos = Pos:new()
	self.destpos = Pos:new()
	self.jumptype = 0

	return self
end
function SRoleJump:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRoleJump:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	----------------marshal bean
	self.srcpos:marshal(_os_) 
	----------------marshal bean
	self.destpos:marshal(_os_) 
	_os_:marshal_char(self.jumptype)
	return _os_
end

function SRoleJump:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	----------------unmarshal bean

	self.srcpos:unmarshal(_os_)

	----------------unmarshal bean

	self.destpos:unmarshal(_os_)

	self.jumptype = _os_:unmarshal_char()
	return _os_
end

return SRoleJump
