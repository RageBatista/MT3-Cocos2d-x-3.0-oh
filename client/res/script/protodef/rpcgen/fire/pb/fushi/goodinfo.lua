require "utils.tableutil"
GoodInfo = {}
GoodInfo.__index = GoodInfo


function GoodInfo:new()
	local self = {}
	setmetatable(self, GoodInfo)
	self.goodid = 0
	self.price = 0
	self.fushi = 0
	self.present = 0
	self.beishu = 0

	return self
end
function GoodInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.goodid)
	_os_:marshal_int32(self.price)
	_os_:marshal_int32(self.fushi)
	_os_:marshal_int32(self.present)
	_os_:marshal_int32(self.beishu)
	return _os_
end

function GoodInfo:unmarshal(_os_)
	self.goodid = _os_:unmarshal_int32()
	self.price = _os_:unmarshal_int32()
	self.fushi = _os_:unmarshal_int32()
	self.present = _os_:unmarshal_int32()
	self.beishu = _os_:unmarshal_int32()
	return _os_
end

return GoodInfo
