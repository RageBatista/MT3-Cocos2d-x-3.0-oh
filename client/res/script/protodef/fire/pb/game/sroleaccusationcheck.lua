require "utils.tableutil"
SRoleAccusationCheck = {}
SRoleAccusationCheck.__index = SRoleAccusationCheck



SRoleAccusationCheck.PROTOCOL_TYPE = 810373

function SRoleAccusationCheck.Create()
	print("enter SRoleAccusationCheck create")
	return SRoleAccusationCheck:new()
end
function SRoleAccusationCheck:new()
	local self = {}
	setmetatable(self, SRoleAccusationCheck)
	self.type = self.PROTOCOL_TYPE
	self.errorcode = 0

	return self
end
function SRoleAccusationCheck:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRoleAccusationCheck:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.errorcode)
	return _os_
end

function SRoleAccusationCheck:unmarshal(_os_)
	self.errorcode = _os_:unmarshal_int32()
	return _os_
end

return SRoleAccusationCheck
