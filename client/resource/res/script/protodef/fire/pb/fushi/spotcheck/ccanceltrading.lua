require "utils.tableutil"
CCancelTrading = {}
CCancelTrading.__index = CCancelTrading



CCancelTrading.PROTOCOL_TYPE = 812643

function CCancelTrading.Create()
	print("enter CCancelTrading create")
	return CCancelTrading:new()
end
function CCancelTrading:new()
	local self = {}
	setmetatable(self, CCancelTrading)
	self.type = self.PROTOCOL_TYPE
	self.tradingid = "" 

	return self
end
function CCancelTrading:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CCancelTrading:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_wstring(self.tradingid)
	return _os_
end

function CCancelTrading:unmarshal(_os_)
	self.tradingid = _os_:unmarshal_wstring(self.tradingid)
	return _os_
end

return CCancelTrading
