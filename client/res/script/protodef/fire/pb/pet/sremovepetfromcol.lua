require "utils.tableutil"
SRemovePetFromCol = {}
SRemovePetFromCol.__index = SRemovePetFromCol



SRemovePetFromCol.PROTOCOL_TYPE = 788445

function SRemovePetFromCol.Create()
	print("enter SRemovePetFromCol create")
	return SRemovePetFromCol:new()
end
function SRemovePetFromCol:new()
	local self = {}
	setmetatable(self, SRemovePetFromCol)
	self.type = self.PROTOCOL_TYPE
	self.columnid = 0
	self.petkey = 0

	return self
end
function SRemovePetFromCol:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRemovePetFromCol:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.columnid)
	_os_:marshal_int32(self.petkey)
	return _os_
end

function SRemovePetFromCol:unmarshal(_os_)
	self.columnid = _os_:unmarshal_int32()
	self.petkey = _os_:unmarshal_int32()
	return _os_
end

return SRemovePetFromCol
