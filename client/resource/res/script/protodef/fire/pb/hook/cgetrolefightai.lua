require "utils.tableutil"
CGetRoleFightAI = {}
CGetRoleFightAI.__index = CGetRoleFightAI



CGetRoleFightAI.PROTOCOL_TYPE = 810342

function CGetRoleFightAI.Create()
	print("enter CGetRoleFightAI create")
	return CGetRoleFightAI:new()
end
function CGetRoleFightAI:new()
	local self = {}
	setmetatable(self, CGetRoleFightAI)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CGetRoleFightAI:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CGetRoleFightAI:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CGetRoleFightAI:unmarshal(_os_)
	return _os_
end

return CGetRoleFightAI
