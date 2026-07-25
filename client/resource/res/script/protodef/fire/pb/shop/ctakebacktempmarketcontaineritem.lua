require "utils.tableutil"
CTakeBackTempMarketContainerItem = {}
CTakeBackTempMarketContainerItem.__index = CTakeBackTempMarketContainerItem



CTakeBackTempMarketContainerItem.PROTOCOL_TYPE = 810668

function CTakeBackTempMarketContainerItem.Create()
	print("enter CTakeBackTempMarketContainerItem create")
	return CTakeBackTempMarketContainerItem:new()
end
function CTakeBackTempMarketContainerItem:new()
	local self = {}
	setmetatable(self, CTakeBackTempMarketContainerItem)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CTakeBackTempMarketContainerItem:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CTakeBackTempMarketContainerItem:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CTakeBackTempMarketContainerItem:unmarshal(_os_)
	return _os_
end

return CTakeBackTempMarketContainerItem
