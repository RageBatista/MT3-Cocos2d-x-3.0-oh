require "utils.tableutil"
CGetPetcolumnInfo = {}
CGetPetcolumnInfo.__index = CGetPetcolumnInfo



CGetPetcolumnInfo.PROTOCOL_TYPE = 788446

function CGetPetcolumnInfo.Create()
	print("enter CGetPetcolumnInfo create")
	return CGetPetcolumnInfo:new()
end
function CGetPetcolumnInfo:new()
	local self = {}
	setmetatable(self, CGetPetcolumnInfo)
	self.type = self.PROTOCOL_TYPE
	self.columnid = 0
	self.npckey = 0

	return self
end
function CGetPetcolumnInfo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CGetPetcolumnInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.columnid)
	_os_:marshal_int64(self.npckey)
	return _os_
end

function CGetPetcolumnInfo:unmarshal(_os_)
	self.columnid = _os_:unmarshal_int32()
	self.npckey = _os_:unmarshal_int64()
	return _os_
end

return CGetPetcolumnInfo
