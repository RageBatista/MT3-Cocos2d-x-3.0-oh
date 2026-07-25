require "utils.tableutil"
CRequestHaveTeam = {}
CRequestHaveTeam.__index = CRequestHaveTeam



CRequestHaveTeam.PROTOCOL_TYPE = 794515

function CRequestHaveTeam.Create()
	print("enter CRequestHaveTeam create")
	return CRequestHaveTeam:new()
end
function CRequestHaveTeam:new()
	local self = {}
	setmetatable(self, CRequestHaveTeam)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0

	return self
end
function CRequestHaveTeam:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CRequestHaveTeam:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	return _os_
end

function CRequestHaveTeam:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	return _os_
end

return CRequestHaveTeam
