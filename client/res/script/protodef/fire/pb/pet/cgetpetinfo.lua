require "utils.tableutil"
CGetPetInfo = {}
CGetPetInfo.__index = CGetPetInfo



CGetPetInfo.PROTOCOL_TYPE = 788525

function CGetPetInfo.Create()
	print("enter CGetPetInfo create")
	return CGetPetInfo:new()
end
function CGetPetInfo:new()
	local self = {}
	setmetatable(self, CGetPetInfo)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0
	self.petkey = 0

	return self
end
function CGetPetInfo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CGetPetInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	_os_:marshal_int32(self.petkey)
	return _os_
end

function CGetPetInfo:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	self.petkey = _os_:unmarshal_int32()
	return _os_
end

return CGetPetInfo
