require "utils.tableutil"
CRankGetPetInfo = {}
CRankGetPetInfo.__index = CRankGetPetInfo



CRankGetPetInfo.PROTOCOL_TYPE = 810258

function CRankGetPetInfo.Create()
	print("enter CRankGetPetInfo create")
	return CRankGetPetInfo:new()
end
function CRankGetPetInfo:new()
	local self = {}
	setmetatable(self, CRankGetPetInfo)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0
	self.infotype = 0

	return self
end
function CRankGetPetInfo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CRankGetPetInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.roleid)
	_os_:marshal_int32(self.infotype)
	return _os_
end

function CRankGetPetInfo:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int32()
	self.infotype = _os_:unmarshal_int32()
	return _os_
end

return CRankGetPetInfo
