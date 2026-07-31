require "utils.tableutil"
MarketGoods = {}
MarketGoods.__index = MarketGoods


function MarketGoods:new()
	local self = {}
	setmetatable(self, MarketGoods)
	self.id = 0
	self.saleroleid = 0
	self.itemid = 0
	self.num = 0
	self.noticenum = 0
	self.key = 0
	self.price = 0
	self.showtime = 0
	self.expiretime = 0
	self.itemtype = 0
	self.level = 0
	self.attentionnumber = 0

	return self
end
function MarketGoods:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.id)
	_os_:marshal_int64(self.saleroleid)
	_os_:marshal_int32(self.itemid)
	_os_:marshal_int32(self.num)
	_os_:marshal_int32(self.noticenum)
	_os_:marshal_int32(self.key)
	_os_:marshal_int32(self.price)
	_os_:marshal_int64(self.showtime)
	_os_:marshal_int64(self.expiretime)
	_os_:marshal_int32(self.itemtype)
	_os_:marshal_int32(self.level)
	_os_:marshal_int32(self.attentionnumber)
	return _os_
end

function MarketGoods:unmarshal(_os_)
	self.id = _os_:unmarshal_int64()
	self.saleroleid = _os_:unmarshal_int64()
	self.itemid = _os_:unmarshal_int32()
	self.num = _os_:unmarshal_int32()
	self.noticenum = _os_:unmarshal_int32()
	self.key = _os_:unmarshal_int32()
	self.price = _os_:unmarshal_int32()
	self.showtime = _os_:unmarshal_int64()
	self.expiretime = _os_:unmarshal_int64()
	self.itemtype = _os_:unmarshal_int32()
	self.level = _os_:unmarshal_int32()
	self.attentionnumber = _os_:unmarshal_int32()
	return _os_
end

return MarketGoods
