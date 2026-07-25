require "utils.tableutil"
CCancelApplyClan = {}
CCancelApplyClan.__index = CCancelApplyClan



CCancelApplyClan.PROTOCOL_TYPE = 808495

function CCancelApplyClan.Create()
	print("enter CCancelApplyClan create")
	return CCancelApplyClan:new()
end
function CCancelApplyClan:new()
	local self = {}
	setmetatable(self, CCancelApplyClan)
	self.type = self.PROTOCOL_TYPE
	self.clanid = 0

	return self
end
function CCancelApplyClan:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CCancelApplyClan:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.clanid)
	return _os_
end

function CCancelApplyClan:unmarshal(_os_)
	self.clanid = _os_:unmarshal_int64()
	return _os_
end

return CCancelApplyClan
