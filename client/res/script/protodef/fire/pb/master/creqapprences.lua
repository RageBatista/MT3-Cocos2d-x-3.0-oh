require "utils.tableutil"
CReqApprences = {}
CReqApprences.__index = CReqApprences



CReqApprences.PROTOCOL_TYPE = 816480

function CReqApprences.Create()
	print("enter CReqApprences create")
	return CReqApprences:new()
end
function CReqApprences:new()
	local self = {}
	setmetatable(self, CReqApprences)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CReqApprences:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CReqApprences:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CReqApprences:unmarshal(_os_)
	return _os_
end

return CReqApprences
