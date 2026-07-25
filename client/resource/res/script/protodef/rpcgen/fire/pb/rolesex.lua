require "utils.tableutil"
RoleSex = {
	MALE = 1,
	FEMALE = 2
}
RoleSex.__index = RoleSex


function RoleSex:new()
	local self = {}
	setmetatable(self, RoleSex)
	return self
end
function RoleSex:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function RoleSex:unmarshal(_os_)
	return _os_
end

return RoleSex
