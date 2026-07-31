require "utils.tableutil"
CMailGetAward = {}
CMailGetAward.__index = CMailGetAward



CMailGetAward.PROTOCOL_TYPE = 787704

function CMailGetAward.Create()
	print("enter CMailGetAward create")
	return CMailGetAward:new()
end
function CMailGetAward:new()
	local self = {}
	setmetatable(self, CMailGetAward)
	self.type = self.PROTOCOL_TYPE
	self.kind = 0
	self.id = 0

	return self
end
function CMailGetAward:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CMailGetAward:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_char(self.kind)
	_os_:marshal_int64(self.id)
	return _os_
end

function CMailGetAward:unmarshal(_os_)
	self.kind = _os_:unmarshal_char()
	self.id = _os_:unmarshal_int64()
	return _os_
end

return CMailGetAward
