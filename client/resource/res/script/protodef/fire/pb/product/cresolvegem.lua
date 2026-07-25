require "utils.tableutil"
CResolveGem = {}
CResolveGem.__index = CResolveGem



CResolveGem.PROTOCOL_TYPE = 803453

function CResolveGem.Create()
	print("enter CResolveGem create")
	return CResolveGem:new()
end
function CResolveGem:new()
	local self = {}
	setmetatable(self, CResolveGem)
	self.type = self.PROTOCOL_TYPE
	self.itemkey = 0

	return self
end
function CResolveGem:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CResolveGem:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.itemkey)
	return _os_
end

function CResolveGem:unmarshal(_os_)
	self.itemkey = _os_:unmarshal_int32()
	return _os_
end

return CResolveGem
