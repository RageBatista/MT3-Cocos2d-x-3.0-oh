require "utils.tableutil"
SReplaceGem = {}
SReplaceGem.__index = SReplaceGem



SReplaceGem.PROTOCOL_TYPE = 787765

function SReplaceGem.Create()
	print("enter SReplaceGem create")
	return SReplaceGem:new()
end
function SReplaceGem:new()
	local self = {}
	setmetatable(self, SReplaceGem)
	self.type = self.PROTOCOL_TYPE
	self.srckey = 0
	self.deskey = 0

	return self
end
function SReplaceGem:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SReplaceGem:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.srckey)
	_os_:marshal_int32(self.deskey)
	return _os_
end

function SReplaceGem:unmarshal(_os_)
	self.srckey = _os_:unmarshal_int32()
	self.deskey = _os_:unmarshal_int32()
	return _os_
end

return SReplaceGem
