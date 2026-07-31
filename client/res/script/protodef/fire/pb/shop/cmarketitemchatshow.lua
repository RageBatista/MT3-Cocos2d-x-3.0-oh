require "utils.tableutil"
CMarketItemChatShow = {}
CMarketItemChatShow.__index = CMarketItemChatShow



CMarketItemChatShow.PROTOCOL_TYPE = 810665

function CMarketItemChatShow.Create()
	print("enter CMarketItemChatShow create")
	return CMarketItemChatShow:new()
end
function CMarketItemChatShow:new()
	local self = {}
	setmetatable(self, CMarketItemChatShow)
	self.type = self.PROTOCOL_TYPE
	self.id = 0
	self.itemtype = 0

	return self
end
function CMarketItemChatShow:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CMarketItemChatShow:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.id)
	_os_:marshal_int32(self.itemtype)
	return _os_
end

function CMarketItemChatShow:unmarshal(_os_)
	self.id = _os_:unmarshal_int64()
	self.itemtype = _os_:unmarshal_int32()
	return _os_
end

return CMarketItemChatShow
