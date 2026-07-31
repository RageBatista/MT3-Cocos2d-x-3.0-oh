require "utils.tableutil"
CLeaveBingFengLand = {}
CLeaveBingFengLand.__index = CLeaveBingFengLand



CLeaveBingFengLand.PROTOCOL_TYPE = 804558

function CLeaveBingFengLand.Create()
	print("enter CLeaveBingFengLand create")
	return CLeaveBingFengLand:new()
end
function CLeaveBingFengLand:new()
	local self = {}
	setmetatable(self, CLeaveBingFengLand)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CLeaveBingFengLand:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CLeaveBingFengLand:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CLeaveBingFengLand:unmarshal(_os_)
	return _os_
end

return CLeaveBingFengLand
