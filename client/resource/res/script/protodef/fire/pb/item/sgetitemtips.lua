require "utils.tableutil"
SGetItemTips = {}
SGetItemTips.__index = SGetItemTips



SGetItemTips.PROTOCOL_TYPE = 787454

function SGetItemTips.Create()
	print("enter SGetItemTips create")
	return SGetItemTips:new()
end
function SGetItemTips:new()
	local self = {}
	setmetatable(self, SGetItemTips)
	self.type = self.PROTOCOL_TYPE
	self.packid = 0
	self.keyinpack = 0
	self.tips = FireNet.Octets() 

	return self
end
function SGetItemTips:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SGetItemTips:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.packid)
	_os_:marshal_int32(self.keyinpack)
	_os_: marshal_octets(self.tips)
	return _os_
end

function SGetItemTips:unmarshal(_os_)
	self.packid = _os_:unmarshal_int32()
	self.keyinpack = _os_:unmarshal_int32()
	_os_:unmarshal_octets(self.tips)
	return _os_
end

return SGetItemTips
