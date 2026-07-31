require "utils.tableutil"
CBuyMonthCard = {}
CBuyMonthCard.__index = CBuyMonthCard



CBuyMonthCard.PROTOCOL_TYPE = 812687

function CBuyMonthCard.Create()
	print("enter CBuyMonthCard create")
	return CBuyMonthCard:new()
end
function CBuyMonthCard:new()
	local self = {}
	setmetatable(self, CBuyMonthCard)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CBuyMonthCard:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CBuyMonthCard:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CBuyMonthCard:unmarshal(_os_)
	return _os_
end

return CBuyMonthCard
