require "utils.tableutil"
CRoleAccusationCheck = {}
CRoleAccusationCheck.__index = CRoleAccusationCheck



CRoleAccusationCheck.PROTOCOL_TYPE = 810372

function CRoleAccusationCheck.Create()
	print("enter CRoleAccusationCheck create")
	return CRoleAccusationCheck:new()
end
function CRoleAccusationCheck:new()
	local self = {}
	setmetatable(self, CRoleAccusationCheck)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CRoleAccusationCheck:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CRoleAccusationCheck:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CRoleAccusationCheck:unmarshal(_os_)
	return _os_
end

return CRoleAccusationCheck
