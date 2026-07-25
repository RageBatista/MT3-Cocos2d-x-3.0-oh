require "utils.tableutil"
SCancelApplyClan = {}
SCancelApplyClan.__index = SCancelApplyClan



SCancelApplyClan.PROTOCOL_TYPE = 808496

function SCancelApplyClan.Create()
	print("enter SCancelApplyClan create")
	return SCancelApplyClan:new()
end
function SCancelApplyClan:new()
	local self = {}
	setmetatable(self, SCancelApplyClan)
	self.type = self.PROTOCOL_TYPE
	self.clanid = 0

	return self
end
function SCancelApplyClan:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SCancelApplyClan:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.clanid)
	return _os_
end

function SCancelApplyClan:unmarshal(_os_)
	self.clanid = _os_:unmarshal_int64()
	return _os_
end

return SCancelApplyClan
