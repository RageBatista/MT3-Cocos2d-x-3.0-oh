require "utils.tableutil"
SGrabBonus = {}
SGrabBonus.__index = SGrabBonus



SGrabBonus.PROTOCOL_TYPE = 808475

function SGrabBonus.Create()
	print("enter SGrabBonus create")
	return SGrabBonus:new()
end
function SGrabBonus:new()
	local self = {}
	setmetatable(self, SGrabBonus)
	self.type = self.PROTOCOL_TYPE
	return self
end
function SGrabBonus:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SGrabBonus:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function SGrabBonus:unmarshal(_os_)
	return _os_
end

return SGrabBonus
