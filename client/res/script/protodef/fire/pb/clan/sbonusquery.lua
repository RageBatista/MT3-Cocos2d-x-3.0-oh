require "utils.tableutil"
SBonusQuery = {}
SBonusQuery.__index = SBonusQuery



SBonusQuery.PROTOCOL_TYPE = 808477

function SBonusQuery.Create()
	print("enter SBonusQuery create")
	return SBonusQuery:new()
end
function SBonusQuery:new()
	local self = {}
	setmetatable(self, SBonusQuery)
	self.type = self.PROTOCOL_TYPE
	self.bonus = 0

	return self
end
function SBonusQuery:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SBonusQuery:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.bonus)
	return _os_
end

function SBonusQuery:unmarshal(_os_)
	self.bonus = _os_:unmarshal_int32()
	return _os_
end

return SBonusQuery
