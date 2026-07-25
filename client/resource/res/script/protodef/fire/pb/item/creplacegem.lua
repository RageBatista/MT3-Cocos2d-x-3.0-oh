require "utils.tableutil"
CReplaceGem = {}
CReplaceGem.__index = CReplaceGem



CReplaceGem.PROTOCOL_TYPE = 787766

function CReplaceGem.Create()
	print("enter CReplaceGem create")
	return CReplaceGem:new()
end
function CReplaceGem:new()
	local self = {}
	setmetatable(self, CReplaceGem)
	self.type = self.PROTOCOL_TYPE
	self.ret = 0
	self.srckey = 0
	self.deskey = 0

	return self
end
function CReplaceGem:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CReplaceGem:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.ret)
	_os_:marshal_int32(self.srckey)
	_os_:marshal_int32(self.deskey)
	return _os_
end

function CReplaceGem:unmarshal(_os_)
	self.ret = _os_:unmarshal_int32()
	self.srckey = _os_:unmarshal_int32()
	self.deskey = _os_:unmarshal_int32()
	return _os_
end

return CReplaceGem
