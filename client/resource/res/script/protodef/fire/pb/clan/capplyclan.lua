require "utils.tableutil"
CApplyClan = {}
CApplyClan.__index = CApplyClan



CApplyClan.PROTOCOL_TYPE = 808453

function CApplyClan.Create()
	print("enter CApplyClan create")
	return CApplyClan:new()
end
function CApplyClan:new()
	local self = {}
	setmetatable(self, CApplyClan)
	self.type = self.PROTOCOL_TYPE
	self.clanid = 0

	return self
end
function CApplyClan:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CApplyClan:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.clanid)
	return _os_
end

function CApplyClan:unmarshal(_os_)
	self.clanid = _os_:unmarshal_int64()
	return _os_
end

return CApplyClan
