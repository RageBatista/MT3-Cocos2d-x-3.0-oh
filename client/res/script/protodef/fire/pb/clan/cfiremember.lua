require "utils.tableutil"
CFireMember = {}
CFireMember.__index = CFireMember



CFireMember.PROTOCOL_TYPE = 808467

function CFireMember.Create()
	print("enter CFireMember create")
	return CFireMember:new()
end
function CFireMember:new()
	local self = {}
	setmetatable(self, CFireMember)
	self.type = self.PROTOCOL_TYPE
	self.memberroleid = 0
	self.reasontype = 0

	return self
end
function CFireMember:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CFireMember:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.memberroleid)
	_os_:marshal_int32(self.reasontype)
	return _os_
end

function CFireMember:unmarshal(_os_)
	self.memberroleid = _os_:unmarshal_int64()
	self.reasontype = _os_:unmarshal_int32()
	return _os_
end

return CFireMember
