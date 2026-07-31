require "utils.tableutil"
ItemRecoverInfoBean = {}
ItemRecoverInfoBean.__index = ItemRecoverInfoBean


function ItemRecoverInfoBean:new()
	local self = {}
	setmetatable(self, ItemRecoverInfoBean)
	self.itemid = 0
	self.uniqid = 0
	self.remaintime = 0
	self.cost = 0

	return self
end
function ItemRecoverInfoBean:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.itemid)
	_os_:marshal_int64(self.uniqid)
	_os_:marshal_int32(self.remaintime)
	_os_:marshal_int32(self.cost)
	return _os_
end

function ItemRecoverInfoBean:unmarshal(_os_)
	self.itemid = _os_:unmarshal_int32()
	self.uniqid = _os_:unmarshal_int64()
	self.remaintime = _os_:unmarshal_int32()
	self.cost = _os_:unmarshal_int32()
	return _os_
end

return ItemRecoverInfoBean
