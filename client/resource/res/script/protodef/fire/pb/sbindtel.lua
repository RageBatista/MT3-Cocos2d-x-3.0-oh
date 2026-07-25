require "utils.tableutil"
SBindTel = {}
SBindTel.__index = SBindTel



SBindTel.PROTOCOL_TYPE = 786555

function SBindTel.Create()
	print("enter SBindTel create")
	return SBindTel:new()
end
function SBindTel:new()
	local self = {}
	setmetatable(self, SBindTel)
	self.type = self.PROTOCOL_TYPE
	self.status = 0

	return self
end
function SBindTel:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SBindTel:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_char(self.status)
	return _os_
end

function SBindTel:unmarshal(_os_)
	self.status = _os_:unmarshal_char()
	return _os_
end

return SBindTel
