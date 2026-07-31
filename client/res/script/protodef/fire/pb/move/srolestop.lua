require "utils.tableutil"
require "protodef.rpcgen.fire.pb.move.pos"
SRoleStop = {}
SRoleStop.__index = SRoleStop



SRoleStop.PROTOCOL_TYPE = 790443

function SRoleStop.Create()
	print("enter SRoleStop create")
	return SRoleStop:new()
end
function SRoleStop:new()
	local self = {}
	setmetatable(self, SRoleStop)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0
	self.pos = Pos:new()

	return self
end
function SRoleStop:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRoleStop:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	----------------marshal bean
	self.pos:marshal(_os_) 
	return _os_
end

function SRoleStop:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	----------------unmarshal bean

	self.pos:unmarshal(_os_)

	return _os_
end

return SRoleStop
