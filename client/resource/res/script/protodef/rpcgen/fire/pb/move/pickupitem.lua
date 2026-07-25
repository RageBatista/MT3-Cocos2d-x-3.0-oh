require "utils.tableutil"
require "protodef.rpcgen.fire.pb.move.pos"
PickUpItem = {}
PickUpItem.__index = PickUpItem


function PickUpItem:new()
	local self = {}
	setmetatable(self, PickUpItem)
	self.uniqueid = 0
	self.baseid = 0
	self.pos = Pos:new()

	return self
end
function PickUpItem:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.uniqueid)
	_os_:marshal_int32(self.baseid)
	----------------marshal bean
	self.pos:marshal(_os_) 
	return _os_
end

function PickUpItem:unmarshal(_os_)
	self.uniqueid = _os_:unmarshal_int64()
	self.baseid = _os_:unmarshal_int32()
	----------------unmarshal bean

	self.pos:unmarshal(_os_)

	return _os_
end

return PickUpItem
