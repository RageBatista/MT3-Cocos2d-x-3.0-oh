require "utils.tableutil"
CGetChargeRefunds = {}
CGetChargeRefunds.__index = CGetChargeRefunds



CGetChargeRefunds.PROTOCOL_TYPE = 812485

function CGetChargeRefunds.Create()
	print("enter CGetChargeRefunds create")
	return CGetChargeRefunds:new()
end
function CGetChargeRefunds:new()
	local self = {}
	setmetatable(self, CGetChargeRefunds)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CGetChargeRefunds:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CGetChargeRefunds:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CGetChargeRefunds:unmarshal(_os_)
	return _os_
end

return CGetChargeRefunds
