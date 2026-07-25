require "utils.tableutil"
SMonthCard = {}
SMonthCard.__index = SMonthCard



SMonthCard.PROTOCOL_TYPE = 812688

function SMonthCard.Create()
	print("enter SMonthCard create")
	return SMonthCard:new()
end
function SMonthCard:new()
	local self = {}
	setmetatable(self, SMonthCard)
	self.type = self.PROTOCOL_TYPE
	self.endtime = 0
	self.grab = 0

	return self
end
function SMonthCard:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SMonthCard:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.endtime)
	_os_:marshal_int32(self.grab)
	return _os_
end

function SMonthCard:unmarshal(_os_)
	self.endtime = _os_:unmarshal_int64()
	self.grab = _os_:unmarshal_int32()
	return _os_
end

return SMonthCard
