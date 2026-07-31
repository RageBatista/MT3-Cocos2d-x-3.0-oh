require "utils.tableutil"
SUnBindTel = {}
SUnBindTel.__index = SUnBindTel



SUnBindTel.PROTOCOL_TYPE = 786557

function SUnBindTel.Create()
	print("enter SUnBindTel create")
	return SUnBindTel:new()
end
function SUnBindTel:new()
	local self = {}
	setmetatable(self, SUnBindTel)
	self.type = self.PROTOCOL_TYPE
	self.status = 0

	return self
end
function SUnBindTel:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SUnBindTel:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_char(self.status)
	return _os_
end

function SUnBindTel:unmarshal(_os_)
	self.status = _os_:unmarshal_char()
	return _os_
end

return SUnBindTel
