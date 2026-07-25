require "utils.tableutil"
CReqJionCamp = {}
CReqJionCamp.__index = CReqJionCamp



CReqJionCamp.PROTOCOL_TYPE = 806558

function CReqJionCamp.Create()
	print("enter CReqJionCamp create")
	return CReqJionCamp:new()
end
function CReqJionCamp:new()
	local self = {}
	setmetatable(self, CReqJionCamp)
	self.type = self.PROTOCOL_TYPE
	self.camptype = 0

	return self
end
function CReqJionCamp:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CReqJionCamp:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_char(self.camptype)
	return _os_
end

function CReqJionCamp:unmarshal(_os_)
	self.camptype = _os_:unmarshal_char()
	return _os_
end

return CReqJionCamp
