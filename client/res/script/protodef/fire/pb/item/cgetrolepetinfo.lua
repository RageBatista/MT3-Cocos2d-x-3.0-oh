require "utils.tableutil"
CGetRolePetInfo = {}
CGetRolePetInfo.__index = CGetRolePetInfo



CGetRolePetInfo.PROTOCOL_TYPE = 787482

function CGetRolePetInfo.Create()
	print("enter CGetRolePetInfo create")
	return CGetRolePetInfo:new()
end
function CGetRolePetInfo:new()
	local self = {}
	setmetatable(self, CGetRolePetInfo)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0

	return self
end
function CGetRolePetInfo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CGetRolePetInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	return _os_
end

function CGetRolePetInfo:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	return _os_
end

return CGetRolePetInfo
