require "utils.tableutil"
STakeBackTempMarketContainerItem = {}
STakeBackTempMarketContainerItem.__index = STakeBackTempMarketContainerItem



STakeBackTempMarketContainerItem.PROTOCOL_TYPE = 810669

function STakeBackTempMarketContainerItem.Create()
	print("enter STakeBackTempMarketContainerItem create")
	return STakeBackTempMarketContainerItem:new()
end
function STakeBackTempMarketContainerItem:new()
	local self = {}
	setmetatable(self, STakeBackTempMarketContainerItem)
	self.type = self.PROTOCOL_TYPE
	self.succ = 0

	return self
end
function STakeBackTempMarketContainerItem:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function STakeBackTempMarketContainerItem:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.succ)
	return _os_
end

function STakeBackTempMarketContainerItem:unmarshal(_os_)
	self.succ = _os_:unmarshal_int32()
	return _os_
end

return STakeBackTempMarketContainerItem
