require "utils.tableutil"
CBuyPackMoney = {}
CBuyPackMoney.__index = CBuyPackMoney



CBuyPackMoney.PROTOCOL_TYPE = 787746

function CBuyPackMoney.Create()
	print("enter CBuyPackMoney create")
	return CBuyPackMoney:new()
end
function CBuyPackMoney:new()
	local self = {}
	setmetatable(self, CBuyPackMoney)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CBuyPackMoney:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CBuyPackMoney:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CBuyPackMoney:unmarshal(_os_)
	return _os_
end

return CBuyPackMoney
