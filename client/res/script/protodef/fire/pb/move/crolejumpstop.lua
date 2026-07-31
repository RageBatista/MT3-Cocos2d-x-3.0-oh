require "utils.tableutil"
require "protodef.rpcgen.fire.pb.move.pos"
CRoleJumpStop = {}
CRoleJumpStop.__index = CRoleJumpStop



CRoleJumpStop.PROTOCOL_TYPE = 790479

function CRoleJumpStop.Create()
	print("enter CRoleJumpStop create")
	return CRoleJumpStop:new()
end
function CRoleJumpStop:new()
	local self = {}
	setmetatable(self, CRoleJumpStop)
	self.type = self.PROTOCOL_TYPE
	self.destpos = Pos:new()
	self.destz = 0

	return self
end
function CRoleJumpStop:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CRoleJumpStop:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	----------------marshal bean
	self.destpos:marshal(_os_) 
	_os_:marshal_char(self.destz)
	return _os_
end

function CRoleJumpStop:unmarshal(_os_)
	----------------unmarshal bean

	self.destpos:unmarshal(_os_)

	self.destz = _os_:unmarshal_char()
	return _os_
end

return CRoleJumpStop
