require "utils.tableutil"
CGetRecharge = {}
CGetRecharge.__index = CGetRecharge



CGetRecharge.PROTOCOL_TYPE = 817967

function CGetRecharge.Create()
	print("enter CGetRecharge create")
	return CGetRecharge:new()
end
function CGetRecharge:new()
	local self = {}
	setmetatable(self, CGetRecharge)
	self.type = self.PROTOCOL_TYPE

	return self
end
function CGetRecharge:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CGetRecharge:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CGetRecharge:unmarshal(_os_)
	return _os_
end

return CGetRecharge
