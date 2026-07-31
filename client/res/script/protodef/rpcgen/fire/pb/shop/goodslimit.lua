require "utils.tableutil"
GoodsLimit = {}
GoodsLimit.__index = GoodsLimit


function GoodsLimit:new()
	local self = {}
	setmetatable(self, GoodsLimit)
	self.goodsid = 0
	self.number = 0

	return self
end
function GoodsLimit:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.goodsid)
	_os_:marshal_int32(self.number)
	return _os_
end

function GoodsLimit:unmarshal(_os_)
	self.goodsid = _os_:unmarshal_int32()
	self.number = _os_:unmarshal_int32()
	return _os_
end

return GoodsLimit
