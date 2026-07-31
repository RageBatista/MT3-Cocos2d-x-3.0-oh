require "utils.tableutil"
SSwapMember = {}
SSwapMember.__index = SSwapMember



SSwapMember.PROTOCOL_TYPE = 794453

function SSwapMember.Create()
	print("enter SSwapMember create")
	return SSwapMember:new()
end
function SSwapMember:new()
	local self = {}
	setmetatable(self, SSwapMember)
	self.type = self.PROTOCOL_TYPE
	self.index1 = 0
	self.index2 = 0

	return self
end
function SSwapMember:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SSwapMember:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.index1)
	_os_:marshal_int32(self.index2)
	return _os_
end

function SSwapMember:unmarshal(_os_)
	self.index1 = _os_:unmarshal_int32()
	self.index2 = _os_:unmarshal_int32()
	return _os_
end

return SSwapMember
