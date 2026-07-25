require "utils.tableutil"
ItemAddInfo = {}
ItemAddInfo.__index = ItemAddInfo


function ItemAddInfo:new()
	local self = {}
	setmetatable(self, ItemAddInfo)
	self.itemid = 0
	self.itemnum = 0

	return self
end
function ItemAddInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.itemid)
	_os_:marshal_int32(self.itemnum)
	return _os_
end

function ItemAddInfo:unmarshal(_os_)
	self.itemid = _os_:unmarshal_int32()
	self.itemnum = _os_:unmarshal_int32()
	return _os_
end

return ItemAddInfo
