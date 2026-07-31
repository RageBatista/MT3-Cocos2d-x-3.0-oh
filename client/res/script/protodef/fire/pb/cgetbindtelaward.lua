require "utils.tableutil"
CGetBindTelAward = {}
CGetBindTelAward.__index = CGetBindTelAward



CGetBindTelAward.PROTOCOL_TYPE = 786561

function CGetBindTelAward.Create()
	print("enter CGetBindTelAward create")
	return CGetBindTelAward:new()
end
function CGetBindTelAward:new()
	local self = {}
	setmetatable(self, CGetBindTelAward)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CGetBindTelAward:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CGetBindTelAward:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CGetBindTelAward:unmarshal(_os_)
	return _os_
end

return CGetBindTelAward
