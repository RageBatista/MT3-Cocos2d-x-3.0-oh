require "utils.tableutil"
CShowPetInfo = {}
CShowPetInfo.__index = CShowPetInfo



CShowPetInfo.PROTOCOL_TYPE = 788456

function CShowPetInfo.Create()
	print("enter CShowPetInfo create")
	return CShowPetInfo:new()
end
function CShowPetInfo:new()
	local self = {}
	setmetatable(self, CShowPetInfo)
	self.type = self.PROTOCOL_TYPE
	self.masterid = 0

	return self
end
function CShowPetInfo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CShowPetInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.masterid)
	return _os_
end

function CShowPetInfo:unmarshal(_os_)
	self.masterid = _os_:unmarshal_int64()
	return _os_
end

return CShowPetInfo
