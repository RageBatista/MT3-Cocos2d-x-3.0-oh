require "utils.tableutil"
CGetBindTel = {}
CGetBindTel.__index = CGetBindTel



CGetBindTel.PROTOCOL_TYPE = 786558

function CGetBindTel.Create()
	print("enter CGetBindTel create")
	return CGetBindTel:new()
end
function CGetBindTel:new()
	local self = {}
	setmetatable(self, CGetBindTel)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CGetBindTel:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CGetBindTel:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CGetBindTel:unmarshal(_os_)
	return _os_
end

return CGetBindTel
