require "utils.tableutil"
CDelGem = {}
CDelGem.__index = CDelGem



CDelGem.PROTOCOL_TYPE = 787702

function CDelGem.Create()
	print("enter CDelGem create")
	return CDelGem:new()
end
function CDelGem:new()
	local self = {}
	setmetatable(self, CDelGem)
	self.type = self.PROTOCOL_TYPE
	self.keyinpack = 0
	self.isequip = 0
	self.gempos = 0

	return self
end
function CDelGem:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CDelGem:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.keyinpack)
	_os_:marshal_char(self.isequip)
	_os_:marshal_int32(self.gempos)
	return _os_
end

function CDelGem:unmarshal(_os_)
	self.keyinpack = _os_:unmarshal_int32()
	self.isequip = _os_:unmarshal_char()
	self.gempos = _os_:unmarshal_int32()
	return _os_
end

return CDelGem
