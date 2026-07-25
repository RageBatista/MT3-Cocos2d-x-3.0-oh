require "utils.tableutil"
Goods = {}
Goods.__index = Goods


function Goods:new()
	local self = {}
	setmetatable(self, Goods)
	self.goodsid = 0
	self.price = 0
	self.priorperiodprice = 0

	return self
end
function Goods:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.goodsid)
	_os_:marshal_int32(self.price)
	_os_:marshal_int32(self.priorperiodprice)
	return _os_
end

function Goods:unmarshal(_os_)
	self.goodsid = _os_:unmarshal_int32()
	self.price = _os_:unmarshal_int32()
	self.priorperiodprice = _os_:unmarshal_int32()
	return _os_
end

return Goods
