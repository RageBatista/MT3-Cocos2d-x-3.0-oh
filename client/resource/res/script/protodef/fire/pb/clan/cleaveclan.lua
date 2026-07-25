require "utils.tableutil"
CLeaveClan = {}
CLeaveClan.__index = CLeaveClan



CLeaveClan.PROTOCOL_TYPE = 808451

function CLeaveClan.Create()
	print("enter CLeaveClan create")
	return CLeaveClan:new()
end
function CLeaveClan:new()
	local self = {}
	setmetatable(self, CLeaveClan)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CLeaveClan:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CLeaveClan:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CLeaveClan:unmarshal(_os_)
	return _os_
end

return CLeaveClan
