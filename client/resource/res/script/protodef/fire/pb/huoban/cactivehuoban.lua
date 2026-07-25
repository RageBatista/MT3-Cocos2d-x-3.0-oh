require "utils.tableutil"
CActiveHuoBan = {}
CActiveHuoBan.__index = CActiveHuoBan



CActiveHuoBan.PROTOCOL_TYPE = 818840

function CActiveHuoBan.Create()
	print("enter CActiveHuoBan create")
	return CActiveHuoBan:new()
end
function CActiveHuoBan:new()
	local self = {}
	setmetatable(self, CActiveHuoBan)
	self.type = self.PROTOCOL_TYPE
	self.huobanid = 0
	self.activetype = 0
	self.activetime = 0

	return self
end
function CActiveHuoBan:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CActiveHuoBan:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.huobanid)
	_os_:marshal_int32(self.activetype)
	_os_:marshal_int32(self.activetime)
	return _os_
end

function CActiveHuoBan:unmarshal(_os_)
	self.huobanid = _os_:unmarshal_int32()
	self.activetype = _os_:unmarshal_int32()
	self.activetime = _os_:unmarshal_int32()
	return _os_
end

return CActiveHuoBan
