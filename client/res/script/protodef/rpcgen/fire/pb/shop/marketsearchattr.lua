require "utils.tableutil"
MarketSearchAttr = {}
MarketSearchAttr.__index = MarketSearchAttr


function MarketSearchAttr:new()
	local self = {}
	setmetatable(self, MarketSearchAttr)
	self.attrid = 0
	self.attrval = 0

	return self
end
function MarketSearchAttr:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.attrid)
	_os_:marshal_int32(self.attrval)
	return _os_
end

function MarketSearchAttr:unmarshal(_os_)
	self.attrid = _os_:unmarshal_int32()
	self.attrval = _os_:unmarshal_int32()
	return _os_
end

return MarketSearchAttr
