require "utils.tableutil"
CDefineTeam = {}
CDefineTeam.__index = CDefineTeam



CDefineTeam.PROTOCOL_TYPE = 805548

function CDefineTeam.Create()
	print("enter CDefineTeam create")
	return CDefineTeam:new()
end
function CDefineTeam:new()
	local self = {}
	setmetatable(self, CDefineTeam)
	self.type = self.PROTOCOL_TYPE
	self.answer = 0

	return self
end
function CDefineTeam:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CDefineTeam:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_short(self.answer)
	return _os_
end

function CDefineTeam:unmarshal(_os_)
	self.answer = _os_:unmarshal_short()
	return _os_
end

return CDefineTeam
