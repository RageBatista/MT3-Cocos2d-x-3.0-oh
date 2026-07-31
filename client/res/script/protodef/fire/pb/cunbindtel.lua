require "utils.tableutil"
CUnBindTel = {}
CUnBindTel.__index = CUnBindTel



CUnBindTel.PROTOCOL_TYPE = 786556

function CUnBindTel.Create()
	print("enter CUnBindTel create")
	return CUnBindTel:new()
end
function CUnBindTel:new()
	local self = {}
	setmetatable(self, CUnBindTel)
	self.type = self.PROTOCOL_TYPE
	self.tel = 0

	return self
end
function CUnBindTel:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CUnBindTel:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.tel)
	return _os_
end

function CUnBindTel:unmarshal(_os_)
	self.tel = _os_:unmarshal_int64()
	return _os_
end

return CUnBindTel
