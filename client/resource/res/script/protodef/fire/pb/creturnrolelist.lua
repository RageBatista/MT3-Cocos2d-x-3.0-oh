require "utils.tableutil"
CReturnRoleList = {}
CReturnRoleList.__index = CReturnRoleList



CReturnRoleList.PROTOCOL_TYPE = 786477

function CReturnRoleList.Create()
	print("enter CReturnRoleList create")
	return CReturnRoleList:new()
end
function CReturnRoleList:new()
	local self = {}
	setmetatable(self, CReturnRoleList)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CReturnRoleList:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CReturnRoleList:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CReturnRoleList:unmarshal(_os_)
	return _os_
end

return CReturnRoleList
