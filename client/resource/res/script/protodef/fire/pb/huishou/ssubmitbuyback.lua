require "utils.tableutil"
SSubmitBuyBack = {}
SSubmitBuyBack.__index = SSubmitBuyBack



SSubmitBuyBack.PROTOCOL_TYPE = 819410

function SSubmitBuyBack.Create()
	print("enter SSubmitBuyBack create")
	return SSubmitBuyBack:new()
end
function SSubmitBuyBack:new()
	local self = {}
	setmetatable(self, SSubmitBuyBack)
	self.type = self.PROTOCOL_TYPE
	self.id = 0
	self.itemnum = 0
	self.backnum = 0

	return self
end
function SSubmitBuyBack:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SSubmitBuyBack:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.id)
	_os_:marshal_int32(self.itemnum)
	_os_:marshal_int32(self.backnum)
	return _os_
end

function SSubmitBuyBack:unmarshal(_os_)
	self.id = _os_:unmarshal_int32()
	self.itemnum = _os_:unmarshal_int32()
	self.backnum = _os_:unmarshal_int32()
	return _os_
end

return SSubmitBuyBack
