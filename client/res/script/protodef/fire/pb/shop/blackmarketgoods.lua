require "utils.tableutil"
BlackMarketGoods = {}
BlackMarketGoods.__index = BlackMarketGoods


function BlackMarketGoods:new()
	local self = {}
	setmetatable(self, BlackMarketGoods)
	self.id = 0
	self.saleroleid = 0
	self.itemid = 0
	self.num = 0
	self.key = 0
	self.price = 0
	self.uptime = 0
	self.itemtype = 0
	self.level= 0
	self.buyroleid= 0
	self.sellrolename=""
	self.buyrolename=""
	return self
end
function BlackMarketGoods:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.id)
	_os_:marshal_int64(self.saleroleid)
	_os_:marshal_int32(self.itemid)
	_os_:marshal_int32(self.num)
	_os_:marshal_int32(self.key)
	_os_:marshal_int32(self.price)
	_os_:marshal_int64(self.uptime)
	_os_:marshal_int32(self.itemtype)
	_os_:marshal_int32(self.petlevel)
	_os_:marshal_int64(self.buyroleid)
 	_os_:marshal_wstring(self.sellrolename)
	_os_:marshal_wstring(self.buyrolename)
	return _os_
end

function BlackMarketGoods:unmarshal(_os_)
	self.id = _os_:unmarshal_int64()
	self.saleroleid = _os_:unmarshal_int64()
	self.itemid = _os_:unmarshal_int32()
	self.num = _os_:unmarshal_int32()
	self.key = _os_:unmarshal_int32()
	self.price = _os_:unmarshal_int32()
	self.uptime = _os_:unmarshal_int64()
	self.itemtype = _os_:unmarshal_int32()
    self.petlevel = _os_:unmarshal_int32()
	self.buyroleid = _os_:unmarshal_int64()
    self.sellrolename = _os_:unmarshal_wstring(self.sellrolename)
	self.buyrolename = _os_:unmarshal_wstring(self.buyrolename)
	return _os_
end

return BlackMarketGoods
