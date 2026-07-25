require "utils.tableutil"
SLeaveClan = {}
SLeaveClan.__index = SLeaveClan



SLeaveClan.PROTOCOL_TYPE = 808452

function SLeaveClan.Create()
	print("enter SLeaveClan create")
	return SLeaveClan:new()
end
function SLeaveClan:new()
	local self = {}
	setmetatable(self, SLeaveClan)
	self.type = self.PROTOCOL_TYPE
	self.memberid = 0

	return self
end
function SLeaveClan:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SLeaveClan:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.memberid)
	return _os_
end

function SLeaveClan:unmarshal(_os_)
	self.memberid = _os_:unmarshal_int64()
	return _os_
end

return SLeaveClan
