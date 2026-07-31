require "utils.tableutil"
MedicItem = {}
MedicItem.__index = MedicItem


function MedicItem:new()
	local self = {}
	setmetatable(self, MedicItem)
	self.itemid = 0
	self.itemnum = 0

	return self
end
function MedicItem:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.itemid)
	_os_:marshal_int32(self.itemnum)
	return _os_
end

function MedicItem:unmarshal(_os_)
	self.itemid = _os_:unmarshal_int32()
	self.itemnum = _os_:unmarshal_int32()
	return _os_
end

return MedicItem
