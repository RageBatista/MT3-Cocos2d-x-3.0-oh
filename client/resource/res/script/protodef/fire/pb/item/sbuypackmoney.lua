require "utils.tableutil"
SBuyPackMoney = {}
SBuyPackMoney.__index = SBuyPackMoney



SBuyPackMoney.PROTOCOL_TYPE = 787747

function SBuyPackMoney.Create()
	print("enter SBuyPackMoney create")
	return SBuyPackMoney:new()
end
function SBuyPackMoney:new()
	local self = {}
	setmetatable(self, SBuyPackMoney)
	self.type = self.PROTOCOL_TYPE
	self.money = 0

	return self
end
function SBuyPackMoney:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SBuyPackMoney:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.money)
	return _os_
end

function SBuyPackMoney:unmarshal(_os_)
	self.money = _os_:unmarshal_int32()
	return _os_
end

return SBuyPackMoney
