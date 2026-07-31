require "utils.tableutil"
require "protodef.rpcgen.fire.pb.move.pos"
SRoleJumpDrawback = {}
SRoleJumpDrawback.__index = SRoleJumpDrawback



SRoleJumpDrawback.PROTOCOL_TYPE = 790480

function SRoleJumpDrawback.Create()
	print("enter SRoleJumpDrawback create")
	return SRoleJumpDrawback:new()
end
function SRoleJumpDrawback:new()
	local self = {}
	setmetatable(self, SRoleJumpDrawback)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0
	self.srcpos = Pos:new()
	self.srcz = 0

	return self
end
function SRoleJumpDrawback:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRoleJumpDrawback:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	----------------marshal bean
	self.srcpos:marshal(_os_) 
	_os_:marshal_char(self.srcz)
	return _os_
end

function SRoleJumpDrawback:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	----------------unmarshal bean

	self.srcpos:unmarshal(_os_)

	self.srcz = _os_:unmarshal_char()
	return _os_
end

return SRoleJumpDrawback
