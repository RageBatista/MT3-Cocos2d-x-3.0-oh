require "utils.tableutil"
CSellSpotCard = {}
CSellSpotCard.__index = CSellSpotCard



CSellSpotCard.PROTOCOL_TYPE = 812635

function CSellSpotCard.Create()
	print("enter CSellSpotCard create")
	return CSellSpotCard:new()
end
function CSellSpotCard:new()
	local self = {}
	setmetatable(self, CSellSpotCard)
	self.type = self.PROTOCOL_TYPE
	self.sellnum = 0
	self.sellprice = 0

	return self
end
function CSellSpotCard:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CSellSpotCard:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.sellnum)
	_os_:marshal_int32(self.sellprice)
	return _os_
end

function CSellSpotCard:unmarshal(_os_)
	self.sellnum = _os_:unmarshal_int32()
	self.sellprice = _os_:unmarshal_int32()
	return _os_
end

return CSellSpotCard
