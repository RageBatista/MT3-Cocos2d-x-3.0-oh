require "utils.tableutil"
SRelocateRolePos = {
	MAX_DISTANCE = 600
}
SRelocateRolePos.__index = SRelocateRolePos



SRelocateRolePos.PROTOCOL_TYPE = 790459

function SRelocateRolePos.Create()
	print("enter SRelocateRolePos create")
	return SRelocateRolePos:new()
end
function SRelocateRolePos:new()
	local self = {}
	setmetatable(self, SRelocateRolePos)
	self.type = self.PROTOCOL_TYPE
	return self
end
function SRelocateRolePos:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRelocateRolePos:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function SRelocateRolePos:unmarshal(_os_)
	return _os_
end

return SRelocateRolePos
