require "utils.tableutil"
SGetChargeRefunds = {}
SGetChargeRefunds.__index = SGetChargeRefunds



SGetChargeRefunds.PROTOCOL_TYPE = 812486

function SGetChargeRefunds.Create()
	print("enter SGetChargeRefunds create")
	return SGetChargeRefunds:new()
end
function SGetChargeRefunds:new()
	local self = {}
	setmetatable(self, SGetChargeRefunds)
	self.type = self.PROTOCOL_TYPE
	self.result = 0

	return self
end
function SGetChargeRefunds:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SGetChargeRefunds:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.result)
	return _os_
end

function SGetChargeRefunds:unmarshal(_os_)
	self.result = _os_:unmarshal_int32()
	return _os_
end

return SGetChargeRefunds
