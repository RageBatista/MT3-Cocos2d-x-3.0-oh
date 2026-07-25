require "utils.tableutil"
CZuoQiShiYong = {}
CZuoQiShiYong.__index = CZuoQiShiYong



CZuoQiShiYong.PROTOCOL_TYPE = 800020

function CZuoQiShiYong.Create()
	print("enter CChangeSchool create")
	return CZuoQiShiYong:new()
end
function CZuoQiShiYong:new()
	local self = {}
	setmetatable(self, CZuoQiShiYong)
	self.type = self.PROTOCOL_TYPE
	self.zuoqiid = 0
	return self
end
function CZuoQiShiYong:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CZuoQiShiYong:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.zuoqiid)
	return _os_
end

function CZuoQiShiYong:unmarshal(_os_)
	self.zuoqiid = _os_:unmarshal_int32()
	return _os_
end

return CZuoQiShiYong
