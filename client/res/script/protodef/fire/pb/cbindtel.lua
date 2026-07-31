require "utils.tableutil"
CBindTel = {}
CBindTel.__index = CBindTel



CBindTel.PROTOCOL_TYPE = 786554

function CBindTel.Create()
	print("enter CBindTel create")
	return CBindTel:new()
end
function CBindTel:new()
	local self = {}
	setmetatable(self, CBindTel)
	self.type = self.PROTOCOL_TYPE
	self.tel = 0
	self.code = "" 

	return self
end
function CBindTel:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CBindTel:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.tel)
	_os_:marshal_wstring(self.code)
	return _os_
end

function CBindTel:unmarshal(_os_)
	self.tel = _os_:unmarshal_int64()
	self.code = _os_:unmarshal_wstring(self.code)
	return _os_
end

return CBindTel
