require "utils.tableutil"
CDismissTeam = {}
CDismissTeam.__index = CDismissTeam



CDismissTeam.PROTOCOL_TYPE = 794487

function CDismissTeam.Create()
	print("enter CDismissTeam create")
	return CDismissTeam:new()
end
function CDismissTeam:new()
	local self = {}
	setmetatable(self, CDismissTeam)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CDismissTeam:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CDismissTeam:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CDismissTeam:unmarshal(_os_)
	return _os_
end

return CDismissTeam
