require "utils.tableutil"
CBonusQuery = {}
CBonusQuery.__index = CBonusQuery



CBonusQuery.PROTOCOL_TYPE = 808476

function CBonusQuery.Create()
	print("enter CBonusQuery create")
	return CBonusQuery:new()
end
function CBonusQuery:new()
	local self = {}
	setmetatable(self, CBonusQuery)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CBonusQuery:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CBonusQuery:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CBonusQuery:unmarshal(_os_)
	return _os_
end

return CBonusQuery
