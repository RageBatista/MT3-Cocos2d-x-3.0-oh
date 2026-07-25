require "utils.tableutil"
CRequestMonthCard = {}
CRequestMonthCard.__index = CRequestMonthCard



CRequestMonthCard.PROTOCOL_TYPE = 812691

function CRequestMonthCard.Create()
	print("enter CRequestMonthCard create")
	return CRequestMonthCard:new()
end
function CRequestMonthCard:new()
	local self = {}
	setmetatable(self, CRequestMonthCard)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CRequestMonthCard:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CRequestMonthCard:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CRequestMonthCard:unmarshal(_os_)
	return _os_
end

return CRequestMonthCard
