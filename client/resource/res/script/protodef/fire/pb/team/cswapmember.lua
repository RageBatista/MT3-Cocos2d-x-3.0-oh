require "utils.tableutil"
CSwapMember = {}
CSwapMember.__index = CSwapMember



CSwapMember.PROTOCOL_TYPE = 794452

function CSwapMember.Create()
	print("enter CSwapMember create")
	return CSwapMember:new()
end
function CSwapMember:new()
	local self = {}
	setmetatable(self, CSwapMember)
	self.type = self.PROTOCOL_TYPE
	self.index1 = 0
	self.index2 = 0

	return self
end
function CSwapMember:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CSwapMember:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.index1)
	_os_:marshal_int32(self.index2)
	return _os_
end

function CSwapMember:unmarshal(_os_)
	self.index1 = _os_:unmarshal_int32()
	self.index2 = _os_:unmarshal_int32()
	return _os_
end

return CSwapMember
