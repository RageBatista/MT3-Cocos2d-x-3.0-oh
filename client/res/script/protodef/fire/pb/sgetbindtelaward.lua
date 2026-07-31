require "utils.tableutil"
SGetBindTelAward = {}
SGetBindTelAward.__index = SGetBindTelAward



SGetBindTelAward.PROTOCOL_TYPE = 786562

function SGetBindTelAward.Create()
	print("enter SGetBindTelAward create")
	return SGetBindTelAward:new()
end
function SGetBindTelAward:new()
	local self = {}
	setmetatable(self, SGetBindTelAward)
	self.type = self.PROTOCOL_TYPE
	self.status = 0

	return self
end
function SGetBindTelAward:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SGetBindTelAward:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_char(self.status)
	return _os_
end

function SGetBindTelAward:unmarshal(_os_)
	self.status = _os_:unmarshal_char()
	return _os_
end

return SGetBindTelAward
