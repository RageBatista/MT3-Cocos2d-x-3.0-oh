require "utils.tableutil"
SDismissTeam = {}
SDismissTeam.__index = SDismissTeam



SDismissTeam.PROTOCOL_TYPE = 794466

function SDismissTeam.Create()
	print("enter SDismissTeam create")
	return SDismissTeam:new()
end
function SDismissTeam:new()
	local self = {}
	setmetatable(self, SDismissTeam)
	self.type = self.PROTOCOL_TYPE
	return self
end
function SDismissTeam:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SDismissTeam:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function SDismissTeam:unmarshal(_os_)
	return _os_
end

return SDismissTeam
