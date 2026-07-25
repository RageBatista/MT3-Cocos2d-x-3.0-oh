require "utils.tableutil"
SUpdateMemberLevel = {}
SUpdateMemberLevel.__index = SUpdateMemberLevel



SUpdateMemberLevel.PROTOCOL_TYPE = 794459

function SUpdateMemberLevel.Create()
	print("enter SUpdateMemberLevel create")
	return SUpdateMemberLevel:new()
end
function SUpdateMemberLevel:new()
	local self = {}
	setmetatable(self, SUpdateMemberLevel)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0
	self.level = 0

	return self
end
function SUpdateMemberLevel:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SUpdateMemberLevel:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	_os_:marshal_int32(self.level)
	return _os_
end

function SUpdateMemberLevel:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	self.level = _os_:unmarshal_int32()
	return _os_
end

return SUpdateMemberLevel
