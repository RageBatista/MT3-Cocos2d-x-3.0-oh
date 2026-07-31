require "utils.tableutil"
CReqChargeMoney = {}
CReqChargeMoney.__index = CReqChargeMoney



CReqChargeMoney.PROTOCOL_TYPE = 786512

function CReqChargeMoney.Create()
	print("enter CReqChargeMoney create")
	return CReqChargeMoney:new()
end
function CReqChargeMoney:new()
	local self = {}
	setmetatable(self, CReqChargeMoney)
	self.type = self.PROTOCOL_TYPE
	self.num = 0
	self.ordersnplatform = "" 

	return self
end
function CReqChargeMoney:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CReqChargeMoney:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.num)
	_os_:marshal_wstring(self.ordersnplatform)
	return _os_
end

function CReqChargeMoney:unmarshal(_os_)
	self.num = _os_:unmarshal_int32()
	self.ordersnplatform = _os_:unmarshal_wstring(self.ordersnplatform)
	return _os_
end

return CReqChargeMoney
