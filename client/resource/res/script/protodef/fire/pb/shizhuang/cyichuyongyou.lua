require "utils.tableutil"
CYiChuYongYou = {}
CYiChuYongYou.__index = CYiChuYongYou



CYiChuYongYou.PROTOCOL_TYPE = 800014

function CYiChuYongYou.Create()
	print("enter CChangeSchool create")
	return CYiChuYongYou:new()
end
function CYiChuYongYou:new()
	local self = {}
	setmetatable(self, CYiChuYongYou)
	self.type = self.PROTOCOL_TYPE
	self.xx = 0
	return self
end
function CYiChuYongYou:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CYiChuYongYou:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.xx)
	return _os_
end

function CYiChuYongYou:unmarshal(_os_)
	self.xx = _os_:unmarshal_int32()
	return _os_
end

return CYiChuYongYou
