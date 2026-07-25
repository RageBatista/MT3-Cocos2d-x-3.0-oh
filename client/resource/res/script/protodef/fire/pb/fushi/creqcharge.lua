require "utils.tableutil"
CReqCharge = {}
CReqCharge.__index = CReqCharge



CReqCharge.PROTOCOL_TYPE = 812454

function CReqCharge.Create()
	print("enter CReqCharge create")
	return CReqCharge:new()
end
function CReqCharge:new()
	local self = {}
	setmetatable(self, CReqCharge)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CReqCharge:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CReqCharge:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CReqCharge:unmarshal(_os_)
	return _os_
end

return CReqCharge
