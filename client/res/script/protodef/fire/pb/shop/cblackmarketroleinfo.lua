require "utils.tableutil"
CBlackMarketRoleInfo = {}
CBlackMarketRoleInfo.__index = CBlackMarketRoleInfo



CBlackMarketRoleInfo.PROTOCOL_TYPE = 800315

function CBlackMarketRoleInfo.Create()
	print("enter CBlackMarketRoleInfo create")
	return CBlackMarketRoleInfo:new()
end
function CBlackMarketRoleInfo:new()
	local self = {}
	setmetatable(self, CBlackMarketRoleInfo)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CBlackMarketRoleInfo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CBlackMarketRoleInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CBlackMarketRoleInfo:unmarshal(_os_)
	return _os_
end

return CBlackMarketRoleInfo
