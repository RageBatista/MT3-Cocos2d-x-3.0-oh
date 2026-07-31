require "utils.tableutil"
CMovePetColumn = {}
CMovePetColumn.__index = CMovePetColumn



CMovePetColumn.PROTOCOL_TYPE = 788448

function CMovePetColumn.Create()
	print("enter CMovePetColumn create")
	return CMovePetColumn:new()
end
function CMovePetColumn:new()
	local self = {}
	setmetatable(self, CMovePetColumn)
	self.type = self.PROTOCOL_TYPE
	self.srccolumnid = 0
	self.petkey = 0
	self.dstcolumnid = 0
	self.npckey = 0

	return self
end
function CMovePetColumn:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CMovePetColumn:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.srccolumnid)
	_os_:marshal_int32(self.petkey)
	_os_:marshal_int32(self.dstcolumnid)
	_os_:marshal_int64(self.npckey)
	return _os_
end

function CMovePetColumn:unmarshal(_os_)
	self.srccolumnid = _os_:unmarshal_int32()
	self.petkey = _os_:unmarshal_int32()
	self.dstcolumnid = _os_:unmarshal_int32()
	self.npckey = _os_:unmarshal_int64()
	return _os_
end

return CMovePetColumn
