require "utils.tableutil"
CRecoverPetInfo = {}
CRecoverPetInfo.__index = CRecoverPetInfo



CRecoverPetInfo.PROTOCOL_TYPE = 788587

function CRecoverPetInfo.Create()
	print("enter CRecoverPetInfo create")
	return CRecoverPetInfo:new()
end
function CRecoverPetInfo:new()
	local self = {}
	setmetatable(self, CRecoverPetInfo)
	self.type = self.PROTOCOL_TYPE
	self.uniqid = 0

	return self
end
function CRecoverPetInfo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CRecoverPetInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.uniqid)
	return _os_
end

function CRecoverPetInfo:unmarshal(_os_)
	self.uniqid = _os_:unmarshal_int64()
	return _os_
end

return CRecoverPetInfo
