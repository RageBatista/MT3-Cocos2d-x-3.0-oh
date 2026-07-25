require "utils.tableutil"
CMarketTradeLog = {}
CMarketTradeLog.__index = CMarketTradeLog



CMarketTradeLog.PROTOCOL_TYPE = 810645

function CMarketTradeLog.Create()
	print("enter CMarketTradeLog create")
	return CMarketTradeLog:new()
end
function CMarketTradeLog:new()
	local self = {}
	setmetatable(self, CMarketTradeLog)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CMarketTradeLog:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CMarketTradeLog:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CMarketTradeLog:unmarshal(_os_)
	return _os_
end

return CMarketTradeLog
