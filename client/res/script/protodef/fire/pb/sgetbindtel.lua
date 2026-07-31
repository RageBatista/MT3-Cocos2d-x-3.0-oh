require "utils.tableutil"
SGetBindTel = {}
SGetBindTel.__index = SGetBindTel



SGetBindTel.PROTOCOL_TYPE = 786559

function SGetBindTel.Create()
	print("enter SGetBindTel create")
	return SGetBindTel:new()
end
function SGetBindTel:new()
	local self = {}
	setmetatable(self, SGetBindTel)
	self.type = self.PROTOCOL_TYPE
	self.tel = 0
	self.createdate = 0
	self.isfistloginofday = 0
	self.isgetbindtelaward = 0
	self.isbindtelagain = 0

	return self
end
function SGetBindTel:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SGetBindTel:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.tel)
	_os_:marshal_int64(self.createdate)
	_os_:marshal_char(self.isfistloginofday)
	_os_:marshal_char(self.isgetbindtelaward)
	_os_:marshal_char(self.isbindtelagain)
	return _os_
end

function SGetBindTel:unmarshal(_os_)
	self.tel = _os_:unmarshal_int64()
	self.createdate = _os_:unmarshal_int64()
	self.isfistloginofday = _os_:unmarshal_char()
	self.isgetbindtelaward = _os_:unmarshal_char()
	self.isbindtelagain = _os_:unmarshal_char()
	return _os_
end

return SGetBindTel
