require "utils.tableutil"

XingChenItem = {}
XingChenItem.__index = XingChenItem


function XingChenItem:new()
	local self = {}
	setmetatable(self, XingChenItem)
	self.id = 0
	self.pos = 0
	self.level = 0
	self.pinzhi = 0
	self.naijiu = 0
	self.shuxing = 0
	self.xishu = 0
	return self
end
function XingChenItem:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	_os_:marshal_int64(self.id)
	_os_:marshal_int32(self.pos)
	_os_:marshal_int32(self.level)
	_os_:marshal_int32(self.pinzhi)
	_os_:marshal_int32(self.naijiu)
	_os_:marshal_float(self.shuxing)
	_os_:marshal_float(self.xishu)
	return _os_
end

function XingChenItem:unmarshal(_os_)

	self.id = _os_:unmarshal_int64()
	self.pos = _os_:unmarshal_int32()
	self.level = _os_:unmarshal_int32()
	self.pinzhi = _os_:unmarshal_int32()
	self.naijiu = _os_:unmarshal_int32()
	self.shuxing = _os_:unmarshal_float()
	self.xishu = _os_:unmarshal_float()
	return _os_
end

return XingChenItem
