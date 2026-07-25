require "utils.tableutil"
SStartPlayCG = {}
SStartPlayCG.__index = SStartPlayCG



SStartPlayCG.PROTOCOL_TYPE = 786455

function SStartPlayCG.Create()
	print("enter SStartPlayCG create")
	return SStartPlayCG:new()
end
function SStartPlayCG:new()
	local self = {}
	setmetatable(self, SStartPlayCG)
	self.type = self.PROTOCOL_TYPE
	self.id = 0

	return self
end
function SStartPlayCG:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SStartPlayCG:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.id)
	return _os_
end

function SStartPlayCG:unmarshal(_os_)
	self.id = _os_:unmarshal_int32()
	return _os_
end

return SStartPlayCG
