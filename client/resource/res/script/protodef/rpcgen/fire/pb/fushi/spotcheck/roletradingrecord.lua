require "utils.tableutil"
RoleTradingRecord = {}
RoleTradingRecord.__index = RoleTradingRecord


function RoleTradingRecord:new()
	local self = {}
	setmetatable(self, RoleTradingRecord)
	self.tradingid = "" 
	self.tradingtype = 0
	self.num = 0
	self.price = 0
	self.tradingtime = 0

	return self
end
function RoleTradingRecord:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_wstring(self.tradingid)
	_os_:marshal_int32(self.tradingtype)
	_os_:marshal_int32(self.num)
	_os_:marshal_int32(self.price)
	_os_:marshal_int64(self.tradingtime)
	return _os_
end

function RoleTradingRecord:unmarshal(_os_)
	self.tradingid = _os_:unmarshal_wstring(self.tradingid)
	self.tradingtype = _os_:unmarshal_int32()
	self.num = _os_:unmarshal_int32()
	self.price = _os_:unmarshal_int32()
	self.tradingtime = _os_:unmarshal_int64()
	return _os_
end

return RoleTradingRecord
