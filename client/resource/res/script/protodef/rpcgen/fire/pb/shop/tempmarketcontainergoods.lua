require "utils.tableutil"
TempMarketContainerGoods = {}
TempMarketContainerGoods.__index = TempMarketContainerGoods


function TempMarketContainerGoods:new()
	local self = {}
	setmetatable(self, TempMarketContainerGoods)
	self.itemid = 0
	self.num = 0
	self.key = 0
	self.itemtype = 0
	self.level = 0

	return self
end
function TempMarketContainerGoods:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.itemid)
	_os_:marshal_int32(self.num)
	_os_:marshal_int32(self.key)
	_os_:marshal_int32(self.itemtype)
	_os_:marshal_int32(self.level)
	return _os_
end

function TempMarketContainerGoods:unmarshal(_os_)
	self.itemid = _os_:unmarshal_int32()
	self.num = _os_:unmarshal_int32()
	self.key = _os_:unmarshal_int32()
	self.itemtype = _os_:unmarshal_int32()
	self.level = _os_:unmarshal_int32()
	return _os_
end

return TempMarketContainerGoods
