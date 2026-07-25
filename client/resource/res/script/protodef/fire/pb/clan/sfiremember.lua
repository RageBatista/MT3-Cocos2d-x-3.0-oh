require "utils.tableutil"
SFireMember = {}
SFireMember.__index = SFireMember



SFireMember.PROTOCOL_TYPE = 808468

function SFireMember.Create()
	print("enter SFireMember create")
	return SFireMember:new()
end
function SFireMember:new()
	local self = {}
	setmetatable(self, SFireMember)
	self.type = self.PROTOCOL_TYPE
	self.memberroleid = 0

	return self
end
function SFireMember:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SFireMember:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.memberroleid)
	return _os_
end

function SFireMember:unmarshal(_os_)
	self.memberroleid = _os_:unmarshal_int64()
	return _os_
end

return SFireMember
