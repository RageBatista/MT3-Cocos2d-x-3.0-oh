require "utils.tableutil"
SBuyMedic = {}
SBuyMedic.__index = SBuyMedic



SBuyMedic.PROTOCOL_TYPE = 808504

function SBuyMedic.Create()
	print("enter SBuyMedic create")
	return SBuyMedic:new()
end
function SBuyMedic:new()
	local self = {}
	setmetatable(self, SBuyMedic)
	self.type = self.PROTOCOL_TYPE
	self.itemid = 0
	self.itemnum = 0
	self.buyitemnum = 0

	return self
end
function SBuyMedic:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SBuyMedic:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.itemid)
	_os_:marshal_int32(self.itemnum)
	_os_:marshal_int32(self.buyitemnum)
	return _os_
end

function SBuyMedic:unmarshal(_os_)
	self.itemid = _os_:unmarshal_int32()
	self.itemnum = _os_:unmarshal_int32()
	self.buyitemnum = _os_:unmarshal_int32()
	return _os_
end

return SBuyMedic
