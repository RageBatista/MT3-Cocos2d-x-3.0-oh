require "utils.tableutil"
CMarketCleanTradeLog = {}
CMarketCleanTradeLog.__index = CMarketCleanTradeLog



CMarketCleanTradeLog.PROTOCOL_TYPE = 810664

function CMarketCleanTradeLog.Create()
	print("enter CMarketCleanTradeLog create")
	return CMarketCleanTradeLog:new()
end
function CMarketCleanTradeLog:new()
	local self = {}
	setmetatable(self, CMarketCleanTradeLog)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CMarketCleanTradeLog:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CMarketCleanTradeLog:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CMarketCleanTradeLog:unmarshal(_os_)
	return _os_
end

return CMarketCleanTradeLog
