require "utils.tableutil"
MelonItemBagInfo = {}
MelonItemBagInfo.__index = MelonItemBagInfo


function MelonItemBagInfo:new()
	local self = {}
	setmetatable(self, MelonItemBagInfo)
	self.itemkey = 0
	self.bagid = 0

	return self
end
function MelonItemBagInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.itemkey)
	_os_:marshal_int32(self.bagid)
	return _os_
end

function MelonItemBagInfo:unmarshal(_os_)
	self.itemkey = _os_:unmarshal_int32()
	self.bagid = _os_:unmarshal_int32()
	return _os_
end

return MelonItemBagInfo
