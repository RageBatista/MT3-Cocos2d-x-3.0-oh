require "utils.tableutil"
require "protodef.rpcgen.fire.pb.move.pos"
SRoleMove = {}
SRoleMove.__index = SRoleMove



SRoleMove.PROTOCOL_TYPE = 790434

function SRoleMove.Create()
	print("enter SRoleMove create")
	return SRoleMove:new()
end
function SRoleMove:new()
	local self = {}
	setmetatable(self, SRoleMove)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0
	self.destpos = Pos:new()

	return self
end
function SRoleMove:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRoleMove:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	----------------marshal bean
	self.destpos:marshal(_os_) 
	return _os_
end

function SRoleMove:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	----------------unmarshal bean

	self.destpos:unmarshal(_os_)

	return _os_
end

return SRoleMove
