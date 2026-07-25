require "utils.tableutil"
CExpelMember = {}
CExpelMember.__index = CExpelMember



CExpelMember.PROTOCOL_TYPE = 794442

function CExpelMember.Create()
	print("enter CExpelMember create")
	return CExpelMember:new()
end
function CExpelMember:new()
	local self = {}
	setmetatable(self, CExpelMember)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0

	return self
end
function CExpelMember:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CExpelMember:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	return _os_
end

function CExpelMember:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	return _os_
end

return CExpelMember
