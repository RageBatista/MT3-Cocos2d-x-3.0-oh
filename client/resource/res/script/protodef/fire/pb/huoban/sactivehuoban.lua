require "utils.tableutil"
SActiveHuoBan = {}
SActiveHuoBan.__index = SActiveHuoBan



SActiveHuoBan.PROTOCOL_TYPE = 818841

function SActiveHuoBan.Create()
	print("enter SActiveHuoBan create")
	return SActiveHuoBan:new()
end
function SActiveHuoBan:new()
	local self = {}
	setmetatable(self, SActiveHuoBan)
	self.type = self.PROTOCOL_TYPE
	self.huobanid = 0
	self.state = 0

	return self
end
function SActiveHuoBan:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SActiveHuoBan:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.huobanid)
	_os_:marshal_int32(self.state)
	return _os_
end

function SActiveHuoBan:unmarshal(_os_)
	self.huobanid = _os_:unmarshal_int32()
	self.state = _os_:unmarshal_int32()
	return _os_
end

return SActiveHuoBan
