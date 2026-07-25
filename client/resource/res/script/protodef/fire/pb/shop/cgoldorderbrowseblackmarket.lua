require "utils.tableutil"
CGoldOrderBrowseBlackMarket = {}
CGoldOrderBrowseBlackMarket.__index = CGoldOrderBrowseBlackMarket



CGoldOrderBrowseBlackMarket.PROTOCOL_TYPE = 810673

function CGoldOrderBrowseBlackMarket.Create()
	print("enter CGoldOrderBrowseBlackMarket create")
	return CGoldOrderBrowseBlackMarket:new()
end
function CGoldOrderBrowseBlackMarket:new()
	local self = {}
	setmetatable(self, CGoldOrderBrowseBlackMarket)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CGoldOrderBrowseBlackMarket:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CGoldOrderBrowseBlackMarket:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CGoldOrderBrowseBlackMarket:unmarshal(_os_)
	return _os_
end

return CGoldOrderBrowseBlackMarket
