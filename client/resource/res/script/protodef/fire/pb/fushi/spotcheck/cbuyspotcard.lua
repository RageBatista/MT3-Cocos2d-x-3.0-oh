require "utils.tableutil"
CBuySpotCard = {}
CBuySpotCard.__index = CBuySpotCard



CBuySpotCard.PROTOCOL_TYPE = 812633

function CBuySpotCard.Create()
	print("enter CBuySpotCard create")
	return CBuySpotCard:new()
end
function CBuySpotCard:new()
	local self = {}
	setmetatable(self, CBuySpotCard)
	self.type = self.PROTOCOL_TYPE
	self.buynum = 0
	self.buyprice = 0

	return self
end
function CBuySpotCard:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CBuySpotCard:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.buynum)
	_os_:marshal_int32(self.buyprice)
	return _os_
end

function CBuySpotCard:unmarshal(_os_)
	self.buynum = _os_:unmarshal_int32()
	self.buyprice = _os_:unmarshal_int32()
	return _os_
end

return CBuySpotCard
