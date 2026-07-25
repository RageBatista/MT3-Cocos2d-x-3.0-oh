require "utils.tableutil"
require "protodef.rpcgen.fire.pb.move.pos"
SSetRoleLocation = {}
SSetRoleLocation.__index = SSetRoleLocation



SSetRoleLocation.PROTOCOL_TYPE = 790436

function SSetRoleLocation.Create()
	print("enter SSetRoleLocation create")
	return SSetRoleLocation:new()
end
function SSetRoleLocation:new()
	local self = {}
	setmetatable(self, SSetRoleLocation)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0
	self.position = Pos:new()
	self.locz = 0

	return self
end
function SSetRoleLocation:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SSetRoleLocation:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	----------------marshal bean
	self.position:marshal(_os_) 
	_os_:marshal_char(self.locz)
	return _os_
end

function SSetRoleLocation:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	----------------unmarshal bean

	self.position:unmarshal(_os_)

	self.locz = _os_:unmarshal_char()
	return _os_
end

return SSetRoleLocation
