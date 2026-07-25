require "utils.tableutil"
RoleColorType = {}
RoleColorType.__index = RoleColorType


function RoleColorType:new()
	local self = {}
	setmetatable(self, RoleColorType)
	self.colorpos1 = 0
	self.colorpos2 = 0

	return self
end
function RoleColorType:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.colorpos1)
	_os_:marshal_int32(self.colorpos2)
	return _os_
end

function RoleColorType:unmarshal(_os_)
	self.colorpos1 = _os_:unmarshal_int32()
	self.colorpos2 = _os_:unmarshal_int32()
	return _os_
end

return RoleColorType
