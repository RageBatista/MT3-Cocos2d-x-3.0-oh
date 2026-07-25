require "utils.tableutil"
CListPack = {}
CListPack.__index = CListPack



CListPack.PROTOCOL_TYPE = 787444

function CListPack.Create()
	print("enter CListPack create")
	return CListPack:new()
end
function CListPack:new()
	local self = {}
	setmetatable(self, CListPack)
	self.type = self.PROTOCOL_TYPE
	self.packid = 0
	self.npcid = 0

	return self
end
function CListPack:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CListPack:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.packid)
	_os_:marshal_int64(self.npcid)
	return _os_
end

function CListPack:unmarshal(_os_)
	self.packid = _os_:unmarshal_int32()
	self.npcid = _os_:unmarshal_int64()
	return _os_
end

return CListPack
