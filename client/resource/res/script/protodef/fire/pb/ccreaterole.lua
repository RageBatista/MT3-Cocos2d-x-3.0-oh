require "utils.tableutil"
CCreateRole = {
	NAMELEN_MAX = 14,
	NAMELEN_MIN = 4
}
CCreateRole.__index = CCreateRole



CCreateRole.PROTOCOL_TYPE = 786435

function CCreateRole.Create()
	print("enter CCreateRole create")
	return CCreateRole:new()
end
function CCreateRole:new()
	local self = {}
	setmetatable(self, CCreateRole)
	self.type = self.PROTOCOL_TYPE
	self.name = "" 
	self.school = 0
	self.shape = 0
	self.code = "" 

	return self
end
function CCreateRole:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CCreateRole:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_wstring(self.name)
	_os_:marshal_int32(self.school)
	_os_:marshal_int32(self.shape)
	_os_:marshal_wstring(self.code)
	return _os_
end

function CCreateRole:unmarshal(_os_)
	self.name = _os_:unmarshal_wstring(self.name)
	self.school = _os_:unmarshal_int32()
	self.shape = _os_:unmarshal_int32()
	self.code = _os_:unmarshal_wstring(self.code)
	return _os_
end

return CCreateRole
