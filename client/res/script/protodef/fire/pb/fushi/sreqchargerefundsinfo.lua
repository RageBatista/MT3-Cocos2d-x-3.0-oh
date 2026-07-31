require "utils.tableutil"
SReqChargeRefundsInfo = {}
SReqChargeRefundsInfo.__index = SReqChargeRefundsInfo



SReqChargeRefundsInfo.PROTOCOL_TYPE = 812484

function SReqChargeRefundsInfo.Create()
	print("enter SReqChargeRefundsInfo create")
	return SReqChargeRefundsInfo:new()
end
function SReqChargeRefundsInfo:new()
	local self = {}
	setmetatable(self, SReqChargeRefundsInfo)
	self.type = self.PROTOCOL_TYPE
	self.result = 0
	self.chargevalue = 0
	self.charge = 0

	return self
end
function SReqChargeRefundsInfo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SReqChargeRefundsInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.result)
	_os_:marshal_int32(self.chargevalue)
	_os_:marshal_int32(self.charge)
	return _os_
end

function SReqChargeRefundsInfo:unmarshal(_os_)
	self.result = _os_:unmarshal_int32()
	self.chargevalue = _os_:unmarshal_int32()
	self.charge = _os_:unmarshal_int32()
	return _os_
end

return SReqChargeRefundsInfo
