require "utils.tableutil"
CAttachGem = {}
CAttachGem.__index = CAttachGem



CAttachGem.PROTOCOL_TYPE = 787493

function CAttachGem.Create()
	print("enter CAttachGem create")
	return CAttachGem:new()
end
function CAttachGem:new()
	local self = {}
	setmetatable(self, CAttachGem)
	self.type = self.PROTOCOL_TYPE
	self.keyinpack = 0
	self.packid = 0
	self.gemkey = 0

	return self
end
function CAttachGem:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CAttachGem:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.keyinpack)
	_os_:marshal_char(self.packid)
	_os_:marshal_int32(self.gemkey)
	return _os_
end

function CAttachGem:unmarshal(_os_)
	self.keyinpack = _os_:unmarshal_int32()
	self.packid = _os_:unmarshal_char()
	self.gemkey = _os_:unmarshal_int32()
	return _os_
end

return CAttachGem
