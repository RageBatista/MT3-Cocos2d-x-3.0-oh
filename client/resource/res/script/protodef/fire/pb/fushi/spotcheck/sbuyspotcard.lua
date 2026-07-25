require "utils.tableutil"
SBuySpotCard = {}
SBuySpotCard.__index = SBuySpotCard



SBuySpotCard.PROTOCOL_TYPE = 812634

function SBuySpotCard.Create()
	print("enter SBuySpotCard create")
	return SBuySpotCard:new()
end
function SBuySpotCard:new()
	local self = {}
	setmetatable(self, SBuySpotCard)
	self.type = self.PROTOCOL_TYPE
	return self
end
function SBuySpotCard:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SBuySpotCard:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function SBuySpotCard:unmarshal(_os_)
	return _os_
end

return SBuySpotCard
