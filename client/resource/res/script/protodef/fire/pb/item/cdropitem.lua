require "utils.tableutil"
CDropItem = {}
CDropItem.__index = CDropItem



CDropItem.PROTOCOL_TYPE = 787449

function CDropItem.Create()
	print("enter CDropItem create")
	return CDropItem:new()
end
function CDropItem:new()
	local self = {}
	setmetatable(self, CDropItem)
	self.type = self.PROTOCOL_TYPE
	self.packid = 0
	self.keyinpack = 0
	self.npcid = 0

	return self
end
function CDropItem:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CDropItem:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.packid)
	_os_:marshal_int32(self.keyinpack)
	_os_:marshal_int32(self.npcid)
	return _os_
end

function CDropItem:unmarshal(_os_)
	self.packid = _os_:unmarshal_int32()
	self.keyinpack = _os_:unmarshal_int32()
	self.npcid = _os_:unmarshal_int32()
	return _os_
end

return CDropItem
