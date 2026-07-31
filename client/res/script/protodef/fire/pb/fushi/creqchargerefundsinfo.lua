require "utils.tableutil"
CReqChargeRefundsInfo = {}
CReqChargeRefundsInfo.__index = CReqChargeRefundsInfo



CReqChargeRefundsInfo.PROTOCOL_TYPE = 812483

function CReqChargeRefundsInfo.Create()
	print("enter CReqChargeRefundsInfo create")
	return CReqChargeRefundsInfo:new()
end
function CReqChargeRefundsInfo:new()
	local self = {}
	setmetatable(self, CReqChargeRefundsInfo)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CReqChargeRefundsInfo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CReqChargeRefundsInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CReqChargeRefundsInfo:unmarshal(_os_)
	return _os_
end

return CReqChargeRefundsInfo
