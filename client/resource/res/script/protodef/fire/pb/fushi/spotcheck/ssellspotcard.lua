require "utils.tableutil"
SSellSpotCard = {}
SSellSpotCard.__index = SSellSpotCard



SSellSpotCard.PROTOCOL_TYPE = 812636

function SSellSpotCard.Create()
	print("enter SSellSpotCard create")
	return SSellSpotCard:new()
end
function SSellSpotCard:new()
	local self = {}
	setmetatable(self, SSellSpotCard)
	self.type = self.PROTOCOL_TYPE
	return self
end
function SSellSpotCard:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SSellSpotCard:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function SSellSpotCard:unmarshal(_os_)
	return _os_
end

return SSellSpotCard
