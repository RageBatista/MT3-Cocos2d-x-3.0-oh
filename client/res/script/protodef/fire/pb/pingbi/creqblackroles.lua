require "utils.tableutil"
CReqBlackRoles = {}
CReqBlackRoles.__index = CReqBlackRoles



CReqBlackRoles.PROTOCOL_TYPE = 819143

function CReqBlackRoles.Create()
	print("enter CReqBlackRoles create")
	return CReqBlackRoles:new()
end
function CReqBlackRoles:new()
	local self = {}
	setmetatable(self, CReqBlackRoles)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CReqBlackRoles:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CReqBlackRoles:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CReqBlackRoles:unmarshal(_os_)
	return _os_
end

return CReqBlackRoles
