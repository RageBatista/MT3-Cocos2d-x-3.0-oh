require "utils.tableutil"
CZuoQiGouMai = {}
CZuoQiGouMai.__index = CZuoQiGouMai



CZuoQiGouMai.PROTOCOL_TYPE = 800023

function CZuoQiGouMai.Create()
	print("enter CChangeSchool create")
	return CZuoQiGouMai:new()
end
function CZuoQiGouMai:new()
	local self = {}
	setmetatable(self, CZuoQiGouMai)
	self.type = self.PROTOCOL_TYPE
	self.zuoqiid = 0
	return self
end
function CZuoQiGouMai:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CZuoQiGouMai:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.zuoqiid)
	return _os_
end

function CZuoQiGouMai:unmarshal(_os_)
	self.zuoqiid = _os_:unmarshal_int32()
	return _os_
end

return CZuoQiGouMai
