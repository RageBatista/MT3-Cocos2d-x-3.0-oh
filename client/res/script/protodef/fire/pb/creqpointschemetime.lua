require "utils.tableutil"
CReqPointSchemeTime = {}
CReqPointSchemeTime.__index = CReqPointSchemeTime



CReqPointSchemeTime.PROTOCOL_TYPE = 786541

function CReqPointSchemeTime.Create()
	print("enter CReqPointSchemeTime create")
	return CReqPointSchemeTime:new()
end
function CReqPointSchemeTime:new()
	local self = {}
	setmetatable(self, CReqPointSchemeTime)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CReqPointSchemeTime:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CReqPointSchemeTime:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CReqPointSchemeTime:unmarshal(_os_)
	return _os_
end

return CReqPointSchemeTime
